import '../models/virtual_lecture.dart';
import 'virtual_lecture_interactive_builder.dart';

/// Full university limits lecture — textbook depth, 45–60 minutes offline.
abstract final class VirtualLectureLimitsComprehensive {
  static List<LectureSegment> segments(LectureMode mode) {
    final List<LectureSegment> theory = _theorySegments();
    final List<LectureSegment> examples =
        VirtualLectureInteractiveBuilder.examplesForMode('limits', mode);
    final List<LectureSegment> closing = _closingSegments();

    if (mode == LectureMode.review) {
      return <LectureSegment>[
        theory[0],
        theory[4],
        theory[10],
        ...examples.take(1),
        closing[0],
      ];
    }
    if (mode == LectureMode.exam) {
      return <LectureSegment>[
        theory[0],
        ...examples.skip(2),
        closing[0],
      ];
    }

    return <LectureSegment>[
      ...theory,
      ...examples,
      closing[0],
      closing[1],
    ];
  }

  static List<String> objectives() => <String>[
        'Define limits in plain language and formal notation',
        'Explain why limits were invented and how they connect to continuity',
        'Evaluate limits graphically, numerically, and algebraically',
        'Work one-sided, infinite, and limits-at-infinity problems',
        'Apply limit laws and spot when limits fail to exist',
        'Solve easy through exam-style examples with full justification',
        'Connect limits to engineering and physics applications',
      ];

  static LectureSmartNotes notes() => const LectureSmartNotes(
        definitions: <String>[
          'Limit: f(x) → L as x → a means values of f(x) get arbitrarily close to L when x is close to a.',
          'One-sided limit: approach from left (x → a⁻) or right (x → a⁺) only.',
          'Continuity at a: lim (x→a) f(x) = f(a).',
        ],
        formulas: <String>[
          'lim (x→a) [f(x) + g(x)] = lim f + lim g (when limits exist)',
          'lim (x→a) [f(x)·g(x)] = (lim f)(lim g)',
          'lim (x→a) f(x)/g(x) = (lim f)/(lim g) if lim g ≠ 0',
          'lim (x→∞) 1/x = 0,  lim (x→∞) x^n = ∞ for n > 0',
        ],
        examples: <String>[
          'lim (x→4) (x²−16)/(x−4) = 8 after factoring',
          'lim (x→0⁺) 1/x = +∞',
          'lim (x→∞) (2x+1)/(x−3) = 2',
        ],
        commonMistakes: <String>[
          'Plugging in when direct substitution gives 0/0',
          'Assuming left and right limits match without checking',
          'Treating ∞ as a real number instead of unbounded behavior',
        ],
        tips: <String>[
          'Factor before substituting on rational holes',
          'Build a table when algebra is messy',
          'Zoom the graph near the approach point',
        ],
      );

  static LectureSummary summary() => const LectureSummary(
        learned: <String>[
          'Limit intuition and historical motivation',
          'Formal notation and one-sided limits',
          'Graphical and numerical estimation',
          'Algebraic techniques and limit laws',
          'Infinite limits and limits at infinity',
          'Continuity connection and DNE cases',
          'Five guided interactive examples',
        ],
        keyFormulas: <String>[
          'lim (x→a) f(x) = L',
          'a² − b² = (a − b)(a + b)',
          'lim (x→a) f(x) exists iff left = right',
        ],
        applications: <String>[
          'Instantaneous velocity (physics)',
          'Structural load approaching failure (engineering)',
          'Marginal behavior in economics',
        ],
        reviewTopics: <String>['Continuity', 'Derivatives as limits of difference quotients'],
        homeworkRecommendation:
            'Complete the lesson quiz, rework three examples without notes, then attempt two exam-style problems.',
      );

  static List<LectureSegment> _theorySegments() {
    return <LectureSegment>[
      _seg(
        phase: LecturePhase.introduction,
        speech:
            'Welcome to a complete university lecture on limits. Over the next hour we will build '
            'every idea from intuition through formal definitions, multiple solution methods, '
            'worked examples from easy to exam-level, and real applications. Do not rush — '
            'every definition will be complete.',
        caption: 'Full limits lecture',
        title: 'Limits — Complete Course',
        lines: <String>['Textbook depth', 'Interactive checkpoints', '45–60 minutes'],
        seconds: 90,
      ),
      _seg(
        phase: LecturePhase.objectives,
        speech:
            'By the end you will define limits precisely, explain why mathematicians invented them, '
            'evaluate limits by graphs, tables, and algebra, handle one-sided and infinite limits, '
            'state limit laws, recognize when limits fail, connect limits to continuity, and solve '
            'representative engineering problems.',
        caption: 'Learning objectives',
        title: 'What You Will Master',
        lines: objectives(),
        seconds: 75,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'What is a limit? Informally: as x gets closer and closer to a number a, '
            'f(x) gets closer and closer to a value L. We write lim (x→a) f(x) = L. '
            'Crucially, we care about the journey toward a, not necessarily the value at a.',
        caption: '1 — What is a limit?',
        title: 'Definition (Informal)',
        equation: 'lim (x→a) f(x) = L',
        lines: <String>['x approaches a', 'f(x) approaches L', 'f(a) may differ'],
        seconds: 100,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Why did mathematicians invent limits? Calculus needs instantaneous rate of change — '
            'speed at one instant, slope of a tangent line. Average rates use two points; '
            'instantaneous rates require zooming in forever. Limits formalize that infinite zoom '
            'without logical contradictions.',
        caption: '2 — Why limits exist',
        title: 'Historical Motivation',
        lines: <String>['Zeno’s paradox resolved', 'Instantaneous velocity', 'Tangent slopes'],
        seconds: 110,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Real-world intuition: a car’s speedometer shows speed now — not average speed over the last hour. '
            'Engineers ask what stress approaches as load increases. Economists study marginal behavior '
            'as quantity changes by tiny amounts. Limits model “what happens as we get arbitrarily close.”',
        caption: '3 — Real-world intuition',
        title: 'Applications Preview',
        lines: <String>['Speed at an instant', 'Load → failure', 'Marginal cost'],
        seconds: 95,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'As x approaches a value, inputs get closer without necessarily equaling a. '
            'Outputs may settle on L, blow up to infinity, oscillate, or approach different values from left vs right.',
        caption: '4 — Behavior as x → a',
        title: 'Approaching a Value',
        lines: <String>['Inputs near a', 'Outputs may settle', 'Left vs right matter'],
        seconds: 90,
        check: _mc(
          'As x approaches 2, which quantity are we studying?',
          <String>['f(2) exactly', 'Values of f(x) near x = 2', 'Only x = 2', 'Average of f'],
          1,
          'Limits study behavior near a, not necessarily the value at a.',
        ),
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Approaching is not the same as reaching. A function can have a hole at x = 2 yet still '
            'have limit 4 as x → 2. The limit describes the trend; the function value at the point is separate.',
        caption: '5 — Approach ≠ reach',
        title: 'Removable Discontinuity',
        equation: 'f(2) undefined,  lim (x→2) f(x) = 4',
        lines: <String>['Hole on graph', 'Limit still exists', 'Define f(2) to fix'],
        seconds: 95,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'One-sided limits: x → a⁻ means approach from the left; x → a⁺ from the right. '
            'A two-sided limit exists only when both one-sided limits exist and are equal.',
        caption: '6 — One-sided limits',
        title: 'Left vs Right',
        equation: 'lim (x→a) f(x) = L  ⇔  lim (x→a⁻) f = lim (x→a⁺) f = L',
        lines: <String>['Check both sides', 'Piecewise graphs', 'Jump → DNE'],
        seconds: 100,
      ),
      _seg(
        phase: LecturePhase.visualDemonstration,
        speech:
            'Infinite limits: as x approaches 0 from the right, 1/x grows without bound. '
            'We write lim (x→0⁺) 1/x = +∞. Infinity here describes unbounded behavior, not a number.',
        caption: '7 — Infinite limits',
        title: 'y = 1/x',
        kind: WhiteboardKind.graph,
        graphFunction: 'reciprocal',
        lines: <String>['Vertical asymptote', '+∞ from right', '−∞ from left'],
        seconds: 105,
        check: _mc(
          'As x → 0⁺, what happens to 1/x?',
          <String>['→ 0', '→ +∞', '→ −∞', '→ 1'],
          1,
          'Positive ÷ tiny positive → unbounded positive.',
        ),
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Limits at infinity describe end behavior: as x grows without bound, what does f(x) approach? '
            'For rational functions, compare highest-degree terms. Example: lim (x→∞) (2x+1)/(x−3) = 2.',
        caption: '8 — Limits at infinity',
        title: 'End Behavior',
        equation: 'lim (x→∞) (2x+1)/(x−3) = 2',
        lines: <String>['Leading terms dominate', 'Horizontal asymptote', 'Compare degrees'],
        seconds: 110,
      ),
      _seg(
        phase: LecturePhase.visualDemonstration,
        speech:
            'Graphical interpretation: zoom near x = a. Trace the curve from both sides. '
            'If both branches aim at the same height L, the limit is L. Tables give the same estimate numerically.',
        caption: '9–10 — Graph & table',
        title: 'Graphical + Numerical',
        kind: WhiteboardKind.graph,
        graphFunction: 'quadratic',
        graphApproachX: 2,
        graphLimitY: 4,
        lines: <String>['Trace branches', 'Build x → a table', 'Compare estimates'],
        seconds: 100,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Algebraic evaluation: try direct substitution first. If you get 0/0, factor, rationalize, '
            'or simplify. Example: (x²−16)/(x−4) → (x−4)(x+4)/(x−4) → x+4 → 8 as x → 4.',
        caption: '11 — Algebraic methods',
        title: 'Factor & Cancel',
        equation: 'lim (x→4) (x²−16)/(x−4) = lim (x→4) (x+4) = 8',
        lines: <String>['Substitute first', 'Factor on 0/0', 'Cancel common terms'],
        seconds: 105,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Limit laws let us split sums, products, and quotients when individual limits exist. '
            'Constants factor out. These laws justify moving term-by-term in long expressions.',
        caption: '12 — Limit laws',
        title: 'Limit Laws',
        equation: 'lim(f+g) = lim f + lim g',
        lines: <String>['Sum, product, quotient', 'Constant multiple', 'Power rule for limits'],
        seconds: 95,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Limits fail when: left ≠ right (jump), oscillation (sin(1/x) at 0), or unbounded different behavior. '
            'Never assume a limit exists — always check the evidence.',
        caption: '13 — When limits DNE',
        title: 'Non-Existence',
        lines: <String>['Left ≠ right', 'Oscillation', 'Unbounded mismatch'],
        seconds: 90,
        check: _mc(
          'If left-hand limit ≠ right-hand limit, the two-sided limit…',
          <String>['Equals the average', 'Does not exist', 'Equals left only', 'Equals 0'],
          1,
          'Both one-sided limits must match for a two-sided limit.',
        ),
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Continuity at a point requires three things: f(a) defined, lim (x→a) f(x) exists, and they are equal. '
            'Limits are the bridge between discrete tables and smooth curves in calculus.',
        caption: '14 — Continuity link',
        title: 'Continuity',
        equation: 'Continuous at a  ⇔  lim (x→a) f(x) = f(a)',
        lines: <String>['No hole/jump/break', 'Polynomials continuous', 'Limits enable derivatives'],
        seconds: 100,
      ),
      _seg(
        phase: LecturePhase.studentParticipation,
        speech:
            'Common misconceptions: “plug in always works,” “∞ is a number,” “limit equals function value.” '
            'Can you predict: for f(x) = |x|/x at 0, does the two-sided limit exist?',
        caption: '15 — Misconceptions',
        title: 'Watch Out',
        lines: <String>['Plug-in fails on 0/0', '∞ is behavior', 'Check one-sided'],
        seconds: 85,
        check: _mc(
          'For f(x) = |x|/x, does lim (x→0) f(x) exist?',
          <String>['Yes, equals 0', 'Yes, equals 1', 'No — left ≠ right', 'Yes, equals −1'],
          2,
          'Left limit is −1, right limit is +1 — not equal.',
        ),
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Engineering example: stress S(ε) in a material may approach a failure threshold as strain ε → ε₀ '
            'even if the material has not failed yet. Physics: average velocity → instantaneous velocity as Δt → 0.',
        caption: '18 — Real applications',
        title: 'Engineering & Physics',
        lines: <String>['Failure thresholds', 'Instant velocity', 'Signal stabilization'],
        seconds: 95,
      ),
      const LectureSegment(
        phase: LecturePhase.guidedExamples,
        professorSpeech:
            'Now we solve five interactive examples — easy to exam-level. '
            'At each step I pause so you choose the operation before I write on the board.',
        caption: '16–17 — Worked examples',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Guided Examples',
          lines: <String>['Easy → medium → hard', 'Your turn each step', 'Verify every answer'],
        ),
        durationSeconds: 70,
      ),
    ];
  }

  static List<LectureSegment> _closingSegments() {
    return <LectureSegment>[
      const LectureSegment(
        phase: LecturePhase.lessonSummary,
        professorSpeech:
            'You have completed a full limits lecture: definition, motivation, one-sided and infinite limits, '
            'limit laws, continuity, misconceptions, five worked examples, and applications. '
            'You should not need outside videos for these core ideas.',
        caption: 'Summary & key takeaways',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Key Takeaways',
          lines: <String>[
            'Limits = approaching behavior',
            'Check one-sided before two-sided',
            'Factor on 0/0',
            '∞ describes unbounded growth',
            'Continuity needs lim = value',
          ],
        ),
        durationSeconds: 90,
      ),
      const LectureSegment(
        phase: LecturePhase.homeworkRecommendation,
        professorSpeech:
            'Homework: finish the lesson quiz, rework three examples closed-book, and use Raise Hand '
            'if you want five more examples on any subtopic — the lecture expands without restarting.',
        caption: 'Next steps',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Recommended',
          lines: <String>['Lesson quiz', 'Closed-book rework', 'Raise Hand for more depth'],
        ),
        durationSeconds: 60,
      ),
    ];
  }

  static LectureSegment _seg({
    required LecturePhase phase,
    required String speech,
    required String caption,
    required String title,
    List<String> lines = const <String>[],
    String? equation,
    WhiteboardKind kind = WhiteboardKind.text,
    String graphFunction = 'quadratic',
    double? graphApproachX,
    double? graphLimitY,
    int seconds = 90,
    LectureKnowledgeCheck? check,
  }) {
    return LectureSegment(
      phase: phase,
      professorSpeech: speech,
      caption: caption,
      whiteboard: LectureWhiteboardFrame(
        kind: kind,
        title: title,
        lines: lines,
        equation: equation,
        graphFunction: graphFunction,
        graphApproachX: graphApproachX,
        graphLimitY: graphLimitY,
      ),
      durationSeconds: seconds,
      knowledgeCheck: check,
    );
  }

  static LectureKnowledgeCheck _mc(
    String prompt,
    List<String> options,
    int correct,
    String explanation,
  ) {
    return LectureKnowledgeCheck(
      prompt: prompt,
      kind: KnowledgeCheckKind.multipleChoice,
      options: options,
      correctIndex: correct,
      explanation: explanation,
      requireCorrect: false,
    );
  }
}
