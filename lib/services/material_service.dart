import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_config.dart';
import '../models/study_material.dart';
import '../utils/image_processor.dart';
import '../utils/io_file_bytes.dart';
import '../utils/study_file_types.dart';
import 'auth_service.dart';
import 'question_service.dart';

class MaterialUploadInput {
  const MaterialUploadInput({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.courseId,
    required this.courseCode,
    required this.professor,
    required this.examType,
    required this.semester,
    required this.topics,
    required this.isAnonymous,
    this.rotationDegrees = 0,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final String courseId;
  final String courseCode;
  final String professor;
  final String examType;
  final String semester;
  final List<String> topics;
  final bool isAnonymous;
  final int rotationDegrees;
}

class MaterialService extends ChangeNotifier {
  MaterialService(this._auth, this._questionService);

  final AuthService _auth;
  final QuestionService _questionService;
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  Stream<List<StudyMaterial>> watchMyUploads({int limit = 8}) {
    final String? uid = _auth.uid;
    return watchMaterials().map((List<StudyMaterial> all) {
      if (uid == null) return <StudyMaterial>[];
      final List<StudyMaterial> mine = all.where((StudyMaterial m) => m.uploaderId == uid).toList();
      return mine.take(limit).toList();
    });
  }

  Stream<List<StudyMaterial>> watchMaterials() {
    if (!AppConfig.hasFirebase) {
      return Stream<List<StudyMaterial>>.value(<StudyMaterial>[]);
    }
    return FirebaseFirestore.instance
        .collection('materials')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    StudyMaterial.fromMap(doc.id, doc.data()),
              )
              .toList(),
        );
  }

  Future<Uint8List?> pickPdf() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: StudyFileTypes.documentExtensions,
      withData: true,
      dialogTitle: 'Select a file',
    );
    if (result == null || result.files.isEmpty) return null;
    final PlatformFile file = result.files.first;
    if (file.bytes != null && file.bytes!.isNotEmpty) return file.bytes;
    if (!kIsWeb && file.path != null && file.path!.isNotEmpty) {
      return readFileBytes(file.path!);
    }
    return null;
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source, imageQuality: 95);
    if (file == null) return null;
    return file.readAsBytes();
  }

  Future<StudyMaterial> upload(MaterialUploadInput input) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to upload.');

    _isUploading = true;
    notifyListeners();

    try {
      Uint8List bytes = input.bytes;
      String mimeType = input.mimeType;
      String fileName = input.fileName;

      if (mimeType.startsWith('image/')) {
        bytes = enhanceScan(bytes, rotationDegrees: input.rotationDegrees);
        mimeType = 'image/jpeg';
        if (!fileName.toLowerCase().endsWith('.jpg')) {
          fileName = '$fileName.jpg';
        }
      }

      final String materialId = DateTime.now().millisecondsSinceEpoch.toString();
      String downloadUrl = '';
      if (AppConfig.hasFirebase) {
        final Reference ref = FirebaseStorage.instance
            .ref('users/$uid/materials/$materialId-$fileName');
        await ref.putData(bytes, SettableMetadata(contentType: mimeType));
        downloadUrl = await ref.getDownloadURL();
      }

      final StudyMaterial material = StudyMaterial(
        id: materialId,
        fileName: fileName,
        downloadUrl: downloadUrl,
        mimeType: mimeType,
        courseId: input.courseId,
        courseCode: input.courseCode,
        professor: input.professor,
        examType: input.examType,
        semester: input.semester,
        topics: input.topics,
        isAnonymous: input.isAnonymous,
        uploaderId: input.isAnonymous ? '' : uid,
        createdAt: DateTime.now(),
        parseStatus: 'processing',
      );

      if (AppConfig.hasFirebase) {
        await FirebaseFirestore.instance.collection('materials').doc(materialId).set(material.toMap());
      }

      await _questionService.parseMaterial(
        material: material,
        fileBytes: bytes,
        mimeType: mimeType,
      );

      if (AppConfig.hasFirebase) {
        await FirebaseFirestore.instance.collection('materials').doc(materialId).update(<String, dynamic>{
          'parseStatus': 'done',
        });
      }

      return material.copyWith(parseStatus: 'done');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}

extension on StudyMaterial {
  StudyMaterial copyWith({String? parseStatus}) {
    return StudyMaterial(
      id: id,
      fileName: fileName,
      downloadUrl: downloadUrl,
      mimeType: mimeType,
      courseId: courseId,
      courseCode: courseCode,
      professor: professor,
      examType: examType,
      semester: semester,
      topics: topics,
      isAnonymous: isAnonymous,
      uploaderId: uploaderId,
      createdAt: createdAt,
      parseStatus: parseStatus ?? this.parseStatus,
    );
  }
}
