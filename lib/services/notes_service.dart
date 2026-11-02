import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/note_item.dart';
import 'auth_service.dart';

class NotesService extends ChangeNotifier {
  NotesService(this._auth);

  final AuthService _auth;
  final List<NoteItem> _demoNotes = <NoteItem>[];

  Stream<List<NoteItem>> watchNotes() {
    final String? uid = _auth.uid;
    if (uid == null) return Stream<List<NoteItem>>.value(<NoteItem>[]);

    if (_auth.isDemoMode) {
      return Stream<List<NoteItem>>.multi((StreamController<List<NoteItem>> controller) {
        controller.add(List<NoteItem>.from(_demoNotes));
        void listener() => controller.add(List<NoteItem>.from(_demoNotes));
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => NoteItem.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<NoteItem> uploadPdfBytes(Uint8List bytes, String fileName) async {
    final String? uid = _auth.uid;
    if (uid == null) {
      throw Exception('You must be signed in to upload notes.');
    }

    final String noteId = DateTime.now().millisecondsSinceEpoch.toString();

    if (_auth.isDemoMode) {
      final NoteItem note = NoteItem(
        id: noteId,
        name: fileName,
        downloadUrl: '',
        sizeBytes: bytes.length,
        createdAt: DateTime.now(),
      );
      _demoNotes.insert(0, note);
      notifyListeners();
      return note;
    }

    final Reference ref = FirebaseStorage.instance.ref('users/$uid/notes/$noteId-$fileName');
    final UploadTask upload = ref.putData(
      bytes,
      SettableMetadata(contentType: 'application/pdf'),
    );
    await upload;
    final String downloadUrl = await ref.getDownloadURL();

    final NoteItem note = NoteItem(
      id: noteId,
      name: fileName,
      downloadUrl: downloadUrl,
      sizeBytes: bytes.length,
      createdAt: DateTime.now(),
    );

    await FirebaseFirestore.instance.collection('users').doc(uid).collection('notes').doc(noteId).set(note.toMap());
    return note;
  }
}
