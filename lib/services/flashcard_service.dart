import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/flashcard.dart';
import '../models/parsed_question.dart';
import '../utils/spaced_repetition.dart';
import 'auth_service.dart';
import 'openai_service.dart';

class FlashcardService extends ChangeNotifier {
  FlashcardService(this._auth, this._openAi);

  final AuthService _auth;
  final OpenAiService _openAi;
  bool _generating = false;
  bool get isGenerating => _generating;
  final List<Flashcard> _demoCards = <Flashcard>[];

  CollectionReference<Map<String, dynamic>>? get _collection {
    final String? uid = _auth.uid;
    if (uid == null || !AppConfig.hasFirebase) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('flashcards');
  }

  Stream<List<Flashcard>> watchFlashcards() {
    final String? uid = _auth.uid;
    if (uid == null) return Stream<List<Flashcard>>.value(<Flashcard>[]);

    if (!AppConfig.hasFirebase) {
      return Stream<List<Flashcard>>.multi((StreamController<List<Flashcard>> controller) {
        void emit() => controller.add(List<Flashcard>.from(_demoCards));
        emit();
        void listener() => emit();
        addListener(listener);
        controller.onCancel = () => removeListener(listener);
      });
    }

    return _collection!
        .orderBy('nextReviewAt')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Flashcard.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  List<Flashcard> dueCards(List<Flashcard> all) =>
      all.where((Flashcard c) => c.isDue).toList();

  int dueCount(List<Flashcard> all) => dueCards(all).length;

  Future<Flashcard?> findByQuestionId(String questionId) async {
    final List<Flashcard> all = await watchFlashcards().first;
    for (final Flashcard card in all) {
      if (card.questionId == questionId) return card;
    }
    return null;
  }

  Future<Flashcard> addCard({
    required String questionId,
    required String front,
    required String back,
    required String courseCode,
  }) async {
    final String? uid = _auth.uid;
    if (uid == null) throw Exception('Sign in to save flashcards.');

    final Flashcard? existing = await findByQuestionId(questionId);
    if (existing != null) return existing;

    final Flashcard card = Flashcard(
      id: AppConfig.hasFirebase ? _collection!.doc().id : 'demo-${DateTime.now().millisecondsSinceEpoch}',
      questionId: questionId,
      front: front.trim(),
      back: back.trim(),
      courseCode: courseCode,
      easeFactor: 2.5,
      intervalDays: 0,
      repetitions: 0,
      nextReviewAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    if (!AppConfig.hasFirebase) {
      _demoCards.add(card);
      notifyListeners();
      return card;
    }

    await _collection!.doc(card.id).set(card.toMap());
    notifyListeners();
    return card;
  }

  Future<void> importFromQuestions(List<ParsedQuestion> questions, String Function(String questionId) answerFor) async {
    for (final ParsedQuestion q in questions) {
      final String back = answerFor(q.id);
      if (back.trim().isEmpty) continue;
      await addCard(
        questionId: q.id,
        front: q.text,
        back: back,
        courseCode: q.courseCode,
      );
    }
  }

  Future<void> rateCard(String cardId, int quality) async {
    final List<Flashcard> all = await watchFlashcards().first;
    final Flashcard card = all.firstWhere((Flashcard c) => c.id == cardId);
    final Sm2Result result = applySm2(
      Sm2State(
        easeFactor: card.easeFactor,
        intervalDays: card.intervalDays,
        repetitions: card.repetitions,
      ),
      quality,
    );

    final Map<String, dynamic> update = <String, dynamic>{
      'easeFactor': result.easeFactor,
      'intervalDays': result.intervalDays,
      'repetitions': result.repetitions,
      'nextReviewAt': result.nextReviewAt.toIso8601String(),
    };

    if (!AppConfig.hasFirebase) {
      final int index = _demoCards.indexWhere((Flashcard c) => c.id == cardId);
      if (index >= 0) {
        final Flashcard old = _demoCards[index];
        _demoCards[index] = Flashcard(
          id: old.id,
          questionId: old.questionId,
          front: old.front,
          back: old.back,
          courseCode: old.courseCode,
          easeFactor: result.easeFactor,
          intervalDays: result.intervalDays,
          repetitions: result.repetitions,
          nextReviewAt: result.nextReviewAt,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
      return;
    }

    await _collection!.doc(cardId).update(update);
    notifyListeners();
  }

  Future<int> generateFromTopic({required String topic, int count = 10}) async {
    _generating = true;
    notifyListeners();
    try {
      final List<Map<String, String>> pairs = await _openAi.generateFlashcardsFromTopic(topic: topic, count: count);
      int added = 0;
      for (final Map<String, String> pair in pairs) {
        await addCard(
          questionId: 'topic-${DateTime.now().microsecondsSinceEpoch}-$added',
          front: pair['front']!,
          back: pair['back']!,
          courseCode: topic.length > 24 ? topic.substring(0, 24) : topic,
        );
        added++;
      }
      return added;
    } finally {
      _generating = false;
      notifyListeners();
    }
  }

  Future<int> generateDeckWithAi({
    required String courseCode,
    required List<String> questionTexts,
    String? answerHint,
  }) async {
    _generating = true;
    notifyListeners();
    try {
      final List<Map<String, String>> pairs = await _openAi.generateFlashcardPairs(
        courseCode: courseCode,
        questionTexts: questionTexts,
        answerHint: answerHint,
      );
      int count = 0;
      for (final Map<String, String> pair in pairs) {
        await addCard(
          questionId: 'ai-${DateTime.now().microsecondsSinceEpoch}-$count',
          front: pair['front']!,
          back: pair['back']!,
          courseCode: courseCode,
        );
        count++;
      }
      return count;
    } finally {
      _generating = false;
      notifyListeners();
    }
  }

  Future<void> deleteCard(String cardId) async {
    if (!AppConfig.hasFirebase) {
      _demoCards.removeWhere((Flashcard c) => c.id == cardId);
      notifyListeners();
      return;
    }
    await _collection!.doc(cardId).delete();
    notifyListeners();
  }
}
