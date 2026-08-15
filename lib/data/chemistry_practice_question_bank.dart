import 'dart:math' as math;

import '../models/math_practice_question.dart';

/// Local fallback chemistry questions for quiz and exam activities.
class ChemistryPracticeQuestionBank {
  ChemistryPracticeQuestionBank._();

  static const int quizQuestionCount = 50;
  static const int examQuestionCount = 30;
  static const int examPassThreshold = 18;

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
    final math.Random rng = math.Random('chem_${lessonId}_${sessionTier}_$seed'.hashCode);
    final List<MathPracticeQuestion> out = <MathPracticeQuestion>[];
    final Set<String> seen = Set<String>.from(excludeHashes);

    final List<String> mcqStems = <String>[
      'Which statement best describes $topicName?',
      'What is the primary driving force in $topicName?',
      'Which safety precaution applies to $topicName experiments?',
      'Which particle-level model explains $topicName?',
      'Which periodic trend is most relevant to $topicName?',
      'What type of reaction is central to $topicName?',
      'Which unit is appropriate when measuring quantities in $topicName?',
      'Which Lewis structure feature matters most for $topicName?',
    ];

    final List<String> mcqOptionsA = <String>[
      'Electron transfer lowers system energy',
      'Only macroscopic observations matter',
      'Mass is not conserved',
      'Temperature has no effect',
    ];

    final List<String> freeStems = <String>[
      'Explain $topicName in your own words with one laboratory example.',
      'Balance a representative equation related to $topicName and identify the reaction type.',
      'Calculate moles given a mass scenario related to $topicName (show units).',
      'Draw the electron movement for a key step in $topicName.',
      'List two real-world applications of $topicName in $courseName.',
    ];

    var index = 0;
    while (out.length < target) {
      final bool useMcq = index % 3 != 2;
      final MathPracticeQuestion q;
      if (useMcq) {
        final String stem = mcqStems[index % mcqStems.length];
        final List<String> options = List<String>.from(mcqOptionsA);
        options.shuffle(rng);
        q = MathPracticeQuestion(
          id: '${lessonId}_chem_$index',
          prompt: stem,
          kind: MathPracticeQuestionKind.multipleChoice,
          difficulty: _difficultyFor(index, sessionTier),
          options: options,
          correctOptionIndex: 0,
        );
      } else {
        q = MathPracticeQuestion(
          id: '${lessonId}_chem_$index',
          prompt: freeStems[index % freeStems.length],
          kind: MathPracticeQuestionKind.freeResponse,
          difficulty: _difficultyFor(index, sessionTier),
        );
      }
      index++;
      if (!seen.add(q.hashKey)) continue;
      out.add(q);
    }

    out.shuffle(rng);
    return out.take(target).toList();
  }

  static MathPracticeDifficulty _difficultyFor(int index, String tier) {
    if (tier == 'exam') {
      return index.isEven ? MathPracticeDifficulty.advanced : MathPracticeDifficulty.intermediate;
    }
    return switch (index % 3) {
      0 => MathPracticeDifficulty.easy,
      1 => MathPracticeDifficulty.intermediate,
      _ => MathPracticeDifficulty.advanced,
    };
  }
}
