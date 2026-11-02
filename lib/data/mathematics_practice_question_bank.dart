import 'dart:math' as math;

import '../models/math_practice_question.dart';

/// Local fallback math questions — unique stems by kind & difficulty.
class MathematicsPracticeQuestionBank {
  MathematicsPracticeQuestionBank._();

  static const int quizQuestionCount = 50;
  static const int examQuestionCount = 30;

  static int questionCountFor(String sessionTier) {
    return switch (sessionTier) {
      'exam' => examQuestionCount,
      'quiz' => quizQuestionCount,
      _ => 12,
    };
  }

  static List<MathPracticeQuestion> build({
    required String lessonId,
    required String topicName,
    required String courseName,
    required String sessionTier,
    required Set<String> excludeHashes,
    int seed = 0,
  }) {
    final int target = questionCountFor(sessionTier);
    final math.Random rng = math.Random('${lessonId}_${sessionTier}_$seed'.hashCode);
    final List<MathPracticeQuestion> out = <MathPracticeQuestion>[];
    final Set<String> seen = Set<String>.from(excludeHashes);

    final List<MathPracticeDifficulty> difficulties = _difficultyMix(target, rng);
    final List<MathPracticeQuestionKind> kinds = _kindMix(target, rng);

    var i = 0;
    var attempts = 0;
    while (out.length < target && attempts < target * 40) {
      attempts++;
      final MathPracticeDifficulty diff = difficulties[out.length % difficulties.length];
      final MathPracticeQuestionKind kind = kinds[out.length % kinds.length];
      final MathPracticeQuestion q = _buildOne(
        lessonId: lessonId,
        topicName: topicName,
        courseName: courseName,
        sessionTier: sessionTier,
        kind: kind,
        difficulty: diff,
        index: i++,
        rng: rng,
      );
      if (!seen.add(q.hashKey)) continue;
      out.add(q);
    }

    out.shuffle(rng);
    return out.take(target).toList();
  }

  static List<MathPracticeDifficulty> _difficultyMix(int n, math.Random rng) {
    final int easy = (n * 0.35).round().clamp(1, n);
    final int mid = (n * 0.35).round().clamp(1, n - easy);
    final int hard = (n - easy - mid).clamp(0, n);
    return <MathPracticeDifficulty>[
      ...List<MathPracticeDifficulty>.filled(easy, MathPracticeDifficulty.easy),
      ...List<MathPracticeDifficulty>.filled(mid, MathPracticeDifficulty.intermediate),
      ...List<MathPracticeDifficulty>.filled(hard, MathPracticeDifficulty.advanced),
    ]..shuffle(rng);
  }

  static List<MathPracticeQuestionKind> _kindMix(int n, math.Random rng) {
    final int mcq = (n * 0.4).round().clamp(1, n);
    final int graph = (n * 0.3).round().clamp(1, n - mcq);
    final int free = (n - mcq - graph).clamp(0, n);
    return <MathPracticeQuestionKind>[
      ...List<MathPracticeQuestionKind>.filled(mcq, MathPracticeQuestionKind.multipleChoice),
      ...List<MathPracticeQuestionKind>.filled(graph, MathPracticeQuestionKind.graph),
      ...List<MathPracticeQuestionKind>.filled(free, MathPracticeQuestionKind.freeResponse),
    ]..shuffle(rng);
  }

  static MathPracticeQuestion _buildOne({
    required String lessonId,
    required String topicName,
    required String courseName,
    required String sessionTier,
    required MathPracticeQuestionKind kind,
    required MathPracticeDifficulty difficulty,
    required int index,
    required math.Random rng,
  }) {
    final int a = rng.nextInt(12) + 2;
    final int b = rng.nextInt(9) + 1;
    final int c = a + b;
    final String diff = difficulty.label;

    switch (kind) {
      case MathPracticeQuestionKind.multipleChoice:
        final List<String> wrong = <String>[
          '${c + 1}',
          '${c - 1}',
          '${c + 2}',
          '${a * b}',
          '${a - b}',
        ]..shuffle(rng);
        final String correct = '$c';
        final List<String> options = <String>[correct, wrong[0], wrong[1], wrong[2]];
        options.shuffle(rng);
        return MathPracticeQuestion(
          id: '${sessionTier}_${lessonId}_mcq_$index',
          prompt:
              '[$diff · MCQ] Using $topicName ($courseName): What is $a + $b?',
          kind: kind,
          difficulty: difficulty,
          options: options,
          correctOptionIndex: options.indexOf(correct),
        );
      case MathPracticeQuestionKind.graph:
        return MathPracticeQuestion(
          id: '${sessionTier}_${lessonId}_graph_$index',
          prompt:
              '[$diff · Graph] Sketch or describe the graph related to $topicName: '
              'How does ${_yEquals(a, b)} behave as x increases?',
          kind: kind,
          difficulty: difficulty,
          graphNote: 'Focus on slope, intercepts, or symmetry for $topicName.',
        );
      case MathPracticeQuestionKind.freeResponse:
        return MathPracticeQuestion(
          id: '${sessionTier}_${lessonId}_free_$index',
          prompt:
              '[$diff · Solve] Apply $topicName to compute: ($a + $b) × ${rng.nextInt(5) + 2} '
              '− ${rng.nextInt(4) + 1}. Show your steps.',
          kind: kind,
          difficulty: difficulty,
        );
    }
  }

  static String _yEquals(int a, int b) => 'y = ${a}x + $b';
}
