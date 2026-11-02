import '../models/virtual_lecture.dart';
import 'virtual_lecture_interactive_builder.dart';
import 'virtual_lecture_topic_profile.dart';

/// Interactive tutoring scripts — professor teaches, asks, waits, animates each step.
class VirtualLectureInteractiveAlgebra {
  VirtualLectureInteractiveAlgebra._();

  static bool matchesTopic(String topic, {String courseId = ''}) {
    return VirtualLectureTopicProfile.isAlgebraEquationTopic(
      topic: topic,
      courseId: courseId,
    );
  }

  static List<String> objectives() => <String>[
        'Choose the correct inverse operation at each step',
        'Keep equations balanced',
        'Verify solutions by substitution',
        'Complete a full interactive lecture without skipping steps',
      ];

  static List<LectureSegment> segments(LectureMode mode) {
    final List<LectureSegment> examples =
        VirtualLectureInteractiveBuilder.examplesForMode('equations', mode);

    const LectureSegment concept = LectureSegment(
      phase: LecturePhase.conceptExplanation,
      professorSpeech:
          'Golden rule: whatever you do to one side, do to the other. '
          'Addition undoes subtraction, division undoes multiplication.',
      caption: 'Balance rule',
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.equation,
        title: 'Balance',
        equation: 'same operation → both sides',
        lines: <String>['+ ↔ −', '× ↔ ÷'],
      ),
      durationSeconds: 45,
    );

    const LectureSegment summary = LectureSegment(
      phase: LecturePhase.lessonSummary,
      professorSpeech:
          'Undo addition by subtracting. Undo multiplication by dividing. '
          'Always balance both sides, then substitute to verify.',
      caption: 'Key takeaways',
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.text,
        title: 'Key Takeaways',
        lines: <String>[
          'Undo + with −',
          'Undo × with ÷',
          'Same operation on both sides',
          'Verify by substituting',
        ],
      ),
      durationSeconds: 40,
    );

    const LectureSegment homework = LectureSegment(
      phase: LecturePhase.homeworkRecommendation,
      professorSpeech: 'Practice more equations in the quiz, then use AI Tutor if stuck.',
      caption: 'Next steps',
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.text,
        title: 'Next',
        lines: <String>['Quiz', 'Practice problems', 'AI Tutor'],
      ),
      durationSeconds: 28,
    );

    return switch (mode) {
      LectureMode.review => <LectureSegment>[
          const LectureSegment(
            phase: LecturePhase.introduction,
            professorSpeech:
                'Quick algebra review — one interactive example on the board, your turn at each step.',
            caption: 'Review mode',
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: 'Algebra Review',
              lines: <String>['One example', 'You choose steps', 'Verify answer'],
            ),
            durationSeconds: 30,
          ),
          concept,
          ...examples,
          summary,
          homework,
        ],
      LectureMode.exam => <LectureSegment>[
          const LectureSegment(
            phase: LecturePhase.introduction,
            professorSpeech:
                'Exam mode — solve on the board with minimal hints. You must pick the right operation at every step.',
            caption: 'Exam challenge',
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: 'Exam Mode',
              lines: <String>['Harder checks', 'Guided solving', 'No skipping steps'],
            ),
            durationSeconds: 28,
          ),
          ...examples,
          summary,
        ],
      LectureMode.comprehensive || LectureMode.concept => <LectureSegment>[
          const LectureSegment(
            phase: LecturePhase.introduction,
            professorSpeech:
                'Welcome to a complete algebra lecture. I teach on the board — you choose each step, '
                'and we verify together through five full interactive examples.',
            caption: 'Full lecture',
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: 'Algebra I — Complete',
              lines: <String>['Textbook depth', 'Five examples', 'Interactive steps'],
            ),
            durationSeconds: 90,
          ),
          const LectureSegment(
            phase: LecturePhase.objectives,
            professorSpeech:
                'You will isolate the variable, pick the correct inverse operation, '
                'and check your answer by substitution on every problem type.',
            caption: 'Goals',
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.table,
              title: 'Today',
              lines: <String>['Balance both sides', 'Undo + then ×', 'Substitute to verify'],
            ),
            durationSeconds: 60,
          ),
          concept,
          ...examples,
          summary,
          homework,
        ],
      LectureMode.practice => <LectureSegment>[
          const LectureSegment(
            phase: LecturePhase.introduction,
            professorSpeech:
                'Practice mode — solve equations while I animate each step on the board. I pause for your answer.',
            caption: 'Practice mode',
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: 'Guided Practice',
              lines: <String>['You choose operations', 'Board shows work', 'Check together'],
            ),
            durationSeconds: 32,
          ),
          ...examples,
          summary,
          homework,
        ],
      LectureMode.deepLearning => <LectureSegment>[
          const LectureSegment(
            phase: LecturePhase.introduction,
            professorSpeech:
                'New to equations? We start at zero, go slow, and solve three different '
                'problems step by step — you choose every move on the board.',
            caption: 'Deep learning',
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: 'Algebra From Zero',
              lines: <String>['Three unique problems', 'Slow pace', 'Full verification'],
            ),
            durationSeconds: 45,
          ),
          const LectureSegment(
            phase: LecturePhase.objectives,
            professorSpeech:
                'By the end you will balance equations, pick inverse operations, '
                'and verify every answer by substitution.',
            caption: 'Goals',
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.table,
              title: 'Today',
              lines: <String>['Balance', 'Inverse ops', 'Three examples', 'Check work'],
            ),
            durationSeconds: 35,
          ),
          concept,
          ...examples,
          summary,
          homework,
        ],
    };
  }

  static LectureSmartNotes notes() {
    return const LectureSmartNotes(
      definitions: <String>['Two-step equation: undo +/− first, then ×/÷.'],
      formulas: <String>['Balance: same operation on both sides'],
      examples: <String>['3x + 7 = 22 → x = 5', '5x − 8 = 17 → x = 5', '4x + 3 = 27 → x = 6'],
      commonMistakes: <String>['Only operating on one side', 'Dividing wrong term'],
      tips: <String>['Always substitute back to verify'],
    );
  }

  static LectureSummary summary() {
    return const LectureSummary(
      learned: <String>[
        'Inverse operations',
        'Balancing equations',
        'Interactive step-by-step solving',
        'Checking by substitution',
      ],
      keyFormulas: <String>['3x + 7 = 22 → x = 5'],
      applications: <String>['Word problems', 'Science formulas'],
      reviewTopics: <String>['One-step equations', 'Like terms'],
      homeworkRecommendation: 'Complete the quiz and practice three more two-step equations.',
    );
  }
}
