import '../models/virtual_lecture.dart';
import 'virtual_lecture_interactive_algebra.dart';
import 'virtual_lecture_interactive_builder.dart';
import 'virtual_lecture_limits_comprehensive.dart';
import 'virtual_lecture_topic_lecture.dart';
import 'virtual_lecture_topic_profile.dart';

/// Offline professor-style lecture scripts when AI is unavailable.
class VirtualLectureFallback {
  VirtualLectureFallback._();

  static VirtualLectureScript build({
    required String topic,
    required String course,
    required String module,
    required LectureMode mode,
    String courseId = '',
    String lessonId = '',
  }) {
    final VirtualLectureTopicProfile profile = VirtualLectureTopicProfile.resolve(
      topic: topic,
      course: course,
      courseId: courseId,
      module: module,
      lessonId: lessonId,
    );

    final bool isLimits = profile.category == LectureTopicCategory.limits;
    final bool isDerivative = profile.category == LectureTopicCategory.derivatives;
    final bool isAlgebraEquation = profile.category == LectureTopicCategory.algebraEquations;

    final List<LectureSegment> segments = isLimits
        ? VirtualLectureLimitsComprehensive.segments(mode)
        : isDerivative
            ? _derivativeSegments(mode)
            : isAlgebraEquation
                ? VirtualLectureInteractiveAlgebra.segments(mode)
                : VirtualLectureTopicLecture.segments(profile: profile, mode: mode);

    final int minutes = switch (mode) {
      LectureMode.review => 18,
      LectureMode.comprehensive => 65,
      LectureMode.concept => 55,
      LectureMode.practice => 35,
      LectureMode.exam => 25,
      LectureMode.deepLearning => 80,
    };

    final List<LectureSegment> fitted = mode.isFullLecture
        ? segments
        : _fitSegments(segments, mode.targetSegments);

    return VirtualLectureScript(
      mode: mode,
      topic: topic,
      course: course,
      module: module,
      objectives: isLimits
          ? VirtualLectureLimitsComprehensive.objectives()
          : isAlgebraEquation
              ? VirtualLectureInteractiveAlgebra.objectives()
              : VirtualLectureTopicLecture.objectives(profile),
      estimatedMinutes: minutes,
      segments: fitted,
      notes: isLimits
          ? VirtualLectureLimitsComprehensive.notes()
          : isAlgebraEquation
              ? VirtualLectureInteractiveAlgebra.notes()
              : VirtualLectureTopicLecture.notes(profile),
      summary: isLimits
          ? VirtualLectureLimitsComprehensive.summary()
          : isAlgebraEquation
              ? VirtualLectureInteractiveAlgebra.summary()
              : VirtualLectureTopicLecture.summary(profile),
    );
  }

  static List<LectureSegment> _fitSegments(
    List<LectureSegment> all,
    int target,
  ) {
    if (all.length <= target) return all;
    return all.take(target).toList();
  }

  static List<LectureSegment> _derivativeSegments(LectureMode mode) {
    final List<LectureSegment> beginner = _derivativeBeginnerSegments();
    final List<LectureSegment> core = _derivativeCoreSegments();
    final List<LectureSegment> examples =
        VirtualLectureInteractiveBuilder.examplesForMode('derivatives', mode, courseId: 'calculus_1');
    final List<LectureSegment> closing = _derivativeClosingSegments();

    return switch (mode) {
      LectureMode.review => <LectureSegment>[
        _derivativeRefreshIntro(),
        core[2],
        ...examples,
        core[3],
        closing[0],
        closing[1],
      ],
      LectureMode.exam => <LectureSegment>[
        _derivativeRefreshIntro(),
        ...examples,
        core[3],
        closing[0],
      ],
      LectureMode.comprehensive || LectureMode.concept => <LectureSegment>[
        core[0],
        core[1],
        core[2],
        ...examples,
        core[3],
        closing[0],
        closing[1],
      ],
      LectureMode.practice => <LectureSegment>[
        core[0],
        ...examples,
        core[3],
        closing[0],
        closing[1],
      ],
      LectureMode.deepLearning => <LectureSegment>[
        beginner[0],
        beginner[1],
        core[1],
        core[2],
        ...examples,
        beginner[2],
        core[3],
        closing[0],
        closing[1],
      ],
    };
  }

  static LectureSegment _derivativeRefreshIntro() {
    return const LectureSegment(
      phase: LecturePhase.introduction,
      professorSpeech:
          'Welcome back! Let us refresh derivatives — instantaneous rate of change, '
          'tangent slope, and the power rule — with extra worked examples and solutions.',
      caption: 'Mind refresh — derivatives',
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.text,
        title: 'Derivatives Refresh',
        lines: <String>['Slope of tangent', 'Power rule', 'Write every step'],
      ),
      durationSeconds: 50,
    );
  }

  static List<LectureSegment> _derivativeBeginnerSegments() {
    return <LectureSegment>[
      const LectureSegment(
        phase: LecturePhase.introduction,
        professorSpeech:
            'If rates of change are new to you, start here. A derivative answers: '
            'at this exact moment, how fast is something changing?',
        caption: 'From zero — rates of change',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Why Derivatives?',
          lines: <String>['Speed at an instant', 'Slope of tangent', 'Economics & science'],
        ),
        durationSeconds: 60,
      ),
      const LectureSegment(
        phase: LecturePhase.conceptExplanation,
        professorSpeech:
            'Average speed uses two points: Δy/Δx. Instantaneous speed uses an infinitely small step. '
            'The derivative is that limiting slope — we write f′(x) or dy/dx.',
        caption: 'Average vs instantaneous',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.equation,
          title: 'Slope Idea',
          equation: "f′(x) = lim (Δx→0) Δy/Δx",
          lines: <String>['Secant → tangent', 'Steep = fast change'],
        ),
        durationSeconds: 65,
      ),
      const LectureSegment(
        phase: LecturePhase.guidedExamples,
        professorSpeech:
            'Constant rule: derivative of 5 is 0. Sum rule: derivative of a sum is the sum of derivatives. '
            'We stack these with the power rule on each term.',
        caption: 'Rules you combine',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.equation,
          title: 'Building Blocks',
          equation: 'd/dx[c] = 0,  d/dx[xⁿ] = n·xⁿ⁻¹',
          lines: <String>['Term by term', 'Coefficients stay'],
        ),
        durationSeconds: 55,
      ),
    ];
  }

  static List<LectureSegment> _derivativeCoreSegments() {
    return <LectureSegment>[
      const LectureSegment(
        phase: LecturePhase.introduction,
        professorSpeech:
            'Welcome. Today: derivatives — the instantaneous rate of change. '
            'Think speedometer vs average speed on a road trip.',
        caption: 'Derivatives as rate of change',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Derivatives',
          lines: <String>['Slope of tangent', 'Rate of change', "Notation: f′(x), dy/dx"],
        ),
        durationSeconds: 50,
      ),
      const LectureSegment(
        phase: LecturePhase.visualDemonstration,
        professorSpeech:
            'On this graph, the tangent line at a point shows the derivative — steep means fast change.',
        caption: 'Tangent slope visualization',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.graph,
          title: 'Tangent line',
          graphFunction: 'quadratic',
        ),
        durationSeconds: 60,
      ),
      const LectureSegment(
        phase: LecturePhase.conceptExplanation,
        professorSpeech:
            'Power rule: d/dx[xⁿ] = n·xⁿ⁻¹. Bring the exponent down, reduce the power by one. '
            'We will apply this to several polynomials with full solutions.',
        caption: 'Power rule stated clearly',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.equation,
          title: 'Power Rule',
          equation: 'd/dx [xⁿ] = n·xⁿ⁻¹',
          lines: <String>['n comes down', 'Exponent drops by 1'],
        ),
        durationSeconds: 55,
      ),
      const LectureSegment(
        phase: LecturePhase.knowledgeCheck,
        professorSpeech: 'Quick check on the power rule before more examples.',
        caption: 'Checkpoint',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Check',
          lines: <String>['Power rule', 'Tangent slope', 'Instantaneous rate'],
        ),
        durationSeconds: 40,
        knowledgeCheck: LectureKnowledgeCheck(
          prompt: "What is f′(x) for f(x) = x²?",
          kind: KnowledgeCheckKind.predictStep,
          options: <String>['x', '2x', 'x²', '2'],
          correctIndex: 1,
          explanation: 'Power rule: bring down 2, new exponent is 1 → 2x.',
        ),
      ),
    ];
  }

  static List<LectureSegment> _derivativeClosingSegments() {
    return <LectureSegment>[
      const LectureSegment(
        phase: LecturePhase.lessonSummary,
        professorSpeech:
            'Derivatives measure instantaneous change. Use the power rule term by term, '
            'and always write intermediate steps in your solutions.',
        caption: 'Wrap-up',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Summary',
          lines: <String>['Derivative = tangent slope', 'Power rule on each term', 'Show all steps'],
        ),
        durationSeconds: 45,
      ),
      const LectureSegment(
        phase: LecturePhase.homeworkRecommendation,
        professorSpeech:
            'Take the 50-question quiz, rework two examples from memory, then use AI Tutor for help.',
        caption: 'Next steps',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Next',
          lines: <String>['Quiz', 'Redo examples', 'AI Tutor'],
        ),
        durationSeconds: 30,
      ),
    ];
  }
}
