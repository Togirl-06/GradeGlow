import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/parsed_question.dart';
import '../models/search_filters.dart';
import '../models/study_material.dart';
import 'openai_service.dart';

class QuestionService extends ChangeNotifier {
  QuestionService(this._openAi);

  final OpenAiService _openAi;
  final List<ParsedQuestion> _demoQuestions = <ParsedQuestion>[];

  Stream<List<ParsedQuestion>> watchQuestions(SearchFilters filters) {
    if (!AppConfig.hasFirebase) {
      return Stream<List<ParsedQuestion>>.value(_applyFilters(_demoQuestions, filters));
    }
    return FirebaseFirestore.instance
        .collection('questions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      final List<ParsedQuestion> items = snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => ParsedQuestion.fromMap(doc.id, doc.data()))
          .toList();
      return _applyFilters(items, filters);
    });
  }

  List<ParsedQuestion> _applyFilters(List<ParsedQuestion> items, SearchFilters filters) {
    if (filters.courseCode != null && filters.courseCode!.isNotEmpty) {
      final String code = filters.courseCode!.toUpperCase();
      items = items.where((ParsedQuestion q) => q.courseCode.toUpperCase() == code).toList();
    }
    if (filters.professor != null && filters.professor!.isNotEmpty) {
      items = items.where((ParsedQuestion q) => q.professor == filters.professor).toList();
    }
    if (filters.semester != null && filters.semester!.isNotEmpty) {
      items = items.where((ParsedQuestion q) => q.semester == filters.semester).toList();
    }
    if (filters.examType != null && filters.examType!.isNotEmpty) {
      items = items.where((ParsedQuestion q) => q.examType == filters.examType).toList();
    }
    if (filters.questionType != null && filters.questionType!.isNotEmpty) {
      items = items.where((ParsedQuestion q) => q.questionType == filters.questionType).toList();
    }
    if (filters.hasSolution != null) {
      items = items.where((ParsedQuestion q) => q.hasSolution == filters.hasSolution).toList();
    }
    if (filters.topic != null && filters.topic!.isNotEmpty) {
      final String topic = filters.topic!.toLowerCase();
      items = items.where((ParsedQuestion q) {
        return q.topics.any((String t) => t.toLowerCase().contains(topic));
      }).toList();
    }
    if (filters.query != null && filters.query!.trim().isNotEmpty) {
      final String q = filters.query!.toLowerCase();
      items = items.where((ParsedQuestion item) => item.text.toLowerCase().contains(q)).toList();
    }
    return items;
  }

  Future<ParsedQuestion?> getQuestion(String id) async {
    if (!AppConfig.hasFirebase) {
      return _demoQuestions.cast<ParsedQuestion?>().firstWhere(
            (ParsedQuestion? q) => q?.id == id,
            orElse: () => null,
          );
    }
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('questions').doc(id).get();
    if (!doc.exists) return null;
    return ParsedQuestion.fromMap(doc.id, doc.data()!);
  }

  Future<void> parseMaterial({
    required StudyMaterial material,
    required Uint8List fileBytes,
    required String mimeType,
  }) async {
    final String contentHint = mimeType.startsWith('image/')
        ? 'Scanned exam image (${fileBytes.length} bytes). Infer questions from course context and filename ${material.fileName}.'
        : 'PDF exam file ${material.fileName}. Infer realistic questions for ${material.courseCode} ${material.examType}.';

    final List<Map<String, dynamic>> parsed = await _openAi.parseExamQuestions(
      courseCode: material.courseCode,
      examType: material.examType,
      sourceLabel: material.fileName,
      contentHint: contentHint,
    );

    if (!AppConfig.hasFirebase) {
      for (int i = 0; i < parsed.length; i++) {
        final Map<String, dynamic> item = parsed[i];
        _demoQuestions.add(
          ParsedQuestion(
            id: 'demo-$i-${DateTime.now().millisecondsSinceEpoch}',
            materialId: material.id,
            courseId: material.courseId,
            courseCode: material.courseCode,
            professor: material.professor,
            semester: material.semester,
            examType: material.examType,
            questionType: item['questionType'] as String? ?? 'General',
            topics: material.topics,
            text: item['text'] as String? ?? '',
            orderIndex: i,
            hasSolution: false,
            createdAt: DateTime.now(),
          ),
        );
      }
      notifyListeners();
      return;
    }

    final WriteBatch batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < parsed.length; i++) {
      final Map<String, dynamic> item = parsed[i];
      final DocumentReference<Map<String, dynamic>> ref =
          FirebaseFirestore.instance.collection('questions').doc();
      final ParsedQuestion question = ParsedQuestion(
        id: ref.id,
        materialId: material.id,
        courseId: material.courseId,
        courseCode: material.courseCode,
        professor: material.professor,
        semester: material.semester,
        examType: material.examType,
        questionType: item['questionType'] as String? ?? 'General',
        topics: <String>[
          ...material.topics,
          ...(item['topics'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => e.toString()),
        ],
        text: item['text'] as String? ?? '',
        orderIndex: i,
        hasSolution: false,
        createdAt: DateTime.now(),
      );
      batch.set(ref, question.toMap());
    }
    await batch.commit();
  }
}
