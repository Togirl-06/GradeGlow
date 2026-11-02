import 'dart:math' as math;

import '../models/math_practice_question.dart';

/// Local fallback biology questions for practice and exams.
class BiologyPracticeQuestionBank {
  BiologyPracticeQuestionBank._();

  static const int quizQuestionCount = 20;
  static const int examQuestionCount = 25;
  static const int examPassThreshold = 15;

  static int questionCountFor(String sessionTier) {
    return switch (sessionTier) {
      'exam' => examQuestionCount,
      'practice' => quizQuestionCount,
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
    final math.Random rng = math.Random('bio_${lessonId}_${sessionTier}_$seed'.hashCode);
    final List<MathPracticeQuestion> out = <MathPracticeQuestion>[];
    final Set<String> seen = Set<String>.from(excludeHashes);

    final List<String> mcq = <String>[
      'Which statement best describes $topicName?',
      'What structure is most essential to $topicName?',
      'Which laboratory technique best investigates $topicName?',
      'What happens if $topicName fails in an organism?',
      'Which scale of organization is central to $topicName?',
      'Which comparison clarifies $topicName?',
    ];

    final List<String> options = <String>[
      'Structure supports function in a regulated process',
      'Biology ignores evidence',
      'Only memorization matters',
      'Diagrams are optional forever',
    ];

    final List<String> free = <String>[
      'Explain $topicName with a labeled diagram description.',
      'Give a clinical or ecological case involving $topicName.',
      'List mechanism steps for $topicName.',
      'Compare two related structures tied to $topicName in $courseName.',
    ];

    var index = 0;
    while (out.length < target) {
      final bool useMcq = index % 3 != 2;
      final MathPracticeQuestion q;
      if (useMcq) {
        final List<String> opts = List<String>.from(options)..shuffle(rng);
        q = MathPracticeQuestion(
          id: '${lessonId}_bio_$index',
          prompt: mcq[index % mcq.length],
          kind: MathPracticeQuestionKind.multipleChoice,
          difficulty: index % 3 == 0
              ? MathPracticeDifficulty.easy
              : index % 3 == 1
                  ? MathPracticeDifficulty.intermediate
                  : MathPracticeDifficulty.advanced,
          options: opts,
          correctOptionIndex: opts.indexOf(options.first).clamp(0, opts.length - 1),
        );
      } else {
        q = MathPracticeQuestion(
          id: '${lessonId}_bio_$index',
          prompt: free[index % free.length],
          kind: MathPracticeQuestionKind.freeResponse,
          difficulty: MathPracticeDifficulty.intermediate,
        );
      }
      index++;
      if (!seen.add(q.hashKey)) continue;
      out.add(q);
    }

    out.shuffle(rng);
    return out.take(target).toList();
  }
}
