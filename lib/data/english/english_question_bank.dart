import 'dart:math';

import '../../models/english_lesson.dart';
import '../../services/english_adaptive_service.dart';
import 'question_bank/challenge_questions.dart';
import 'question_bank/grammar_questions.dart';
import 'question_bank/hard_questions.dart';
import 'question_bank/topic_questions.dart';
import 'question_bank/topic_supplements.dart';

/// Topic-only question pools — never mixes unrelated grammar or vocabulary.
class EnglishQuestionBank {
  EnglishQuestionBank({Random? random, EnglishAdaptiveService? adaptive})
      : _random = random ?? Random(),
        _adaptive = adaptive ?? const EnglishAdaptiveService();

  final Random _random;
  final EnglishAdaptiveService _adaptive;

  /// Max extra drills per session, all from the current lesson topic.
  static const int extraPerSession = 12;
  static const int hardPerSession = 12;
  static const int easyCapInExtras = 0;
  static const int maxSessionSteps = 32;

  late final Map<String, List<EnglishActivity>> _allPools =
      _buildTopicPools();

  Map<String, List<EnglishActivity>> _buildTopicPools() {
    final Map<String, List<EnglishActivity>> pools =
        <String, List<EnglishActivity>>{
      ...grammarQuestionBank,
      ...topicQuestionBank,
    };
    for (final MapEntry<String, List<EnglishActivity>> e
        in hardQuestionBank.entries) {
      pools.putIfAbsent(e.key, () => <EnglishActivity>[]).addAll(e.value);
    }
    final Map<String, List<EnglishActivity>> supplements = buildTopicSupplements();
    for (final MapEntry<String, List<EnglishActivity>> e in supplements.entries) {
      pools.putIfAbsent(e.key, () => <EnglishActivity>[]).addAll(e.value);
    }
    for (final MapEntry<String, List<EnglishActivity>> e
        in challengeQuestionBank.entries) {
      pools.putIfAbsent(e.key, () => <EnglishActivity>[]).addAll(e.value);
    }
    return pools;
  }

  /// Core lesson + adaptive extras from the same topic only.
  List<EnglishActivity> expandLesson(
    EnglishLessonScript script, {
    EnglishCefrLevel learnerLevel = EnglishCefrLevel.b1,
  }) {
    final Set<String> usedIds = <String>{};
    final List<EnglishActivity> core = script.activities;
    for (final EnglishActivity a in core) {
      usedIds.add(a.id);
    }

    final int targetExtras =
        _adaptive.targetExtrasForLevel(learnerLevel);

    final List<EnglishActivity> extras = pickForLesson(
      script.id,
      excludeIds: usedIds,
      count: targetExtras,
      learnerLevel: learnerLevel,
    );

    final List<EnglishActivity> merged = <EnglishActivity>[...core, ...extras];
    if (merged.length > maxSessionSteps) {
      return merged.sublist(0, maxSessionSteps);
    }
    return merged;
  }

  List<EnglishActivity> pickForLesson(
    String lessonId, {
    required Set<String> excludeIds,
    int count = extraPerSession,
    EnglishCefrLevel learnerLevel = EnglishCefrLevel.b1,
  }) {
    final List<EnglishActivity> pool = List<EnglishActivity>.from(
      _allPools[lessonId] ?? <EnglishActivity>[],
    );

    final List<EnglishActivity> levelPool = _adaptive.filterByLevel(
      pool,
      learnerLevel,
      tolerance: learnerLevel.rank <= 2 ? 2 : 1,
    );

    final List<EnglishActivity> available = levelPool
        .where((EnglishActivity q) =>
            !excludeIds.contains(q.id) && _belongsToLesson(q, lessonId))
        .toList();

    final List<EnglishActivity> picked = _pickWithQuizBias(
      available,
      count,
      excludeIds,
    );

    return _adaptive.diversifyKinds(picked);
  }

  bool _isQuizQuestion(EnglishActivity q) {
    return switch (q.kind) {
      EnglishActivityKind.multipleChoice ||
      EnglishActivityKind.fillBlank ||
      EnglishActivityKind.rapidReview ||
      EnglishActivityKind.listening ||
      EnglishActivityKind.sentenceBuilder ||
      EnglishActivityKind.correction ||
      EnglishActivityKind.explainError ||
      EnglishActivityKind.bestSentence ||
      EnglishActivityKind.readingInference ||
      EnglishActivityKind.vocabularyContext ||
      EnglishActivityKind.questionCard ||
      EnglishActivityKind.miniConversation =>
        true,
      _ => false,
    };
  }

  List<EnglishActivity> _pickWithQuizBias(
    List<EnglishActivity> available,
    int count,
    Set<String> excludeIds,
  ) {
    final List<EnglishActivity> quiz = available
        .where((EnglishActivity q) => _isQuizQuestion(q))
        .toList()
      ..shuffle(_random);
    final List<EnglishActivity> other = available
        .where((EnglishActivity q) => !_isQuizQuestion(q))
        .toList()
      ..shuffle(_random);

    final int quizTarget = (count * 0.65).ceil().clamp(5, count);
    final List<EnglishActivity> picked = <EnglishActivity>[];

    void takeFrom(List<EnglishActivity> source, int limit) {
      for (final EnglishActivity q in source) {
        if (picked.length >= count || picked.length >= limit) break;
        if (excludeIds.contains(q.id)) continue;
        picked.add(q);
        excludeIds.add(q.id);
      }
    }

    takeFrom(quiz, quizTarget);
    takeFrom(other, count);
    takeFrom(quiz, count);
    takeFrom(other, count);
    return picked;
  }

  bool _belongsToLesson(EnglishActivity activity, String lessonId) {
    return activity.id.contains(lessonId);
  }

  int bankSizeForLesson(String lessonId) => _allPools[lessonId]?.length ?? 0;

  int get totalQuestions =>
      _allPools.values.fold<int>(0, (int n, List<EnglishActivity> l) => n + l.length);
}

final EnglishQuestionBank englishQuestionBank = EnglishQuestionBank();
