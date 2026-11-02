import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/quiz_question.dart';
import 'auth_service.dart';
import 'openai_service.dart';

class QuizService extends ChangeNotifier {
  QuizService(this._auth, this._openAi);

  final AuthService _auth;
  final OpenAiService _openAi;

  final List<QuizRecord> _demoQuizzes = <QuizRecord>[];

  Stream<List<QuizRecord>> watchQuizzes() {
    final String? uid = _auth.uid;
    if (uid == null) return Stream<List<QuizRecord>>.value(<QuizRecord>[]);

    if (_auth.isDemoMode) {
      return Stream<List<QuizRecord>>.multi((StreamController<List<QuizRecord>> controller) {
        void emit() => controller.add(List<QuizRecord>.from(_demoQuizzes));
        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => QuizRecord.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  Future<List<QuizQuestion>> generateFromNote(String noteName) async {
    _isGenerating = true;
    notifyListeners();

    try {
      final List<QuizQuestion> questions = await _openAi.generateQuiz(noteName: noteName);
      final String? uid = _auth.uid;
      if (uid != null) {
        final QuizRecord record = QuizRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          noteName: noteName,
          questionCount: questions.length,
          createdAt: DateTime.now(),
        );
        if (_auth.isDemoMode) {
          _demoQuizzes.insert(0, record);
        } else {
          await FirebaseFirestore.instance.collection('users').doc(uid).collection('quizzes').doc(record.id).set(
            <String, dynamic>{
              'noteName': record.noteName,
              'questionCount': record.questionCount,
              'createdAt': record.createdAt.toIso8601String(),
            },
          );
        }
      }
      return questions;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}
