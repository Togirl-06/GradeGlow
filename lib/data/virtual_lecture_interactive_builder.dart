import '../models/virtual_lecture.dart';
import 'virtual_lecture_topic_profile.dart';

/// Builds quiz-style interactive examples — professor teaches, student chooses each step.
abstract final class VirtualLectureInteractiveBuilder {
  static LectureSegment build({
    required LecturePhase phase,
    required String title,
    required String summarySpeech,
    required String summaryCaption,
    required List<LectureInteractiveBeat> beats,
    int durationSeconds = 120,
  }) {
    return LectureSegment(
      phase: phase,
      professorSpeech: summarySpeech,
      caption: summaryCaption,
      whiteboard: beats.first.whiteboard,
      durationSeconds: durationSeconds,
      beats: beats,
    );
  }

  static LectureKnowledgeCheck mc({
    required String prompt,
    required List<String> options,
    required int correctIndex,
    required String explanation,
  }) {
    return LectureKnowledgeCheck(
      prompt: prompt,
      kind: KnowledgeCheckKind.multipleChoice,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
      requireCorrect: true,
    );
  }

  static LectureInteractiveBeat _eq(
    String speech,
    String caption,
    String title,
    String equation, {
    String? highlight,
    List<String> lines = const <String>[],
    LectureKnowledgeCheck? choice,
    int durationSeconds = 42,
  }) {
    return LectureInteractiveBeat(
      professorSpeech: speech,
      caption: caption,
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.equation,
        title: title,
        equation: equation,
        highlight: highlight,
        lines: lines,
      ),
      studentChoice: choice,
      durationSeconds: durationSeconds,
    );
  }

  /// 3x + 7 = 22 — full interactive tutoring flow.
  static List<LectureInteractiveBeat> twoStepEquationBeats({
    String equation = '3x + 7 = 22',
    String answer = '5',
  }) {
    return <LectureInteractiveBeat>[
      _eq(
        "Let's solve this equation together. Our goal is to find the value of x. "
        'Remember — whatever we do to one side, we must do to the other to keep it balanced.',
        'Read the problem',
        'Problem',
        equation,
        lines: <String>['Solve for x'],
        durationSeconds: 55,
      ),
      _eq(
        'First, we need to get x by itself. I am highlighting the +7. '
        'Since 7 is being added, what is the opposite operation?',
        'What undoes +7?',
        'Step 1 — Plan',
        equation,
        highlight: '+7',
        lines: <String>['Get x alone', 'Undo the +7'],
        choice: mc(
          prompt: 'What operation undoes adding 7?',
          options: <String>['Add 7', 'Subtract 7', 'Multiply by 7', 'Divide by 7'],
          correctIndex: 1,
          explanation: 'Subtraction undoes addition — subtract 7 from both sides.',
        ),
        durationSeconds: 50,
      ),
      _eq(
        "Excellent! Let's subtract 7 from both sides.",
        'Subtract 7 from both sides',
        'Step 1 — Work',
        '3x + 7 − 7 = 22 − 7',
        lines: <String>['Same operation both sides'],
      ),
      _eq(
        'The +7 and −7 cancel on the left. On the right, 22 minus 7 is 15.',
        'Simplify',
        'Simplified',
        '3x = 15',
        lines: <String>['Left: 3x', 'Right: 15'],
      ),
      _eq(
        'Now x is being multiplied by 3. What operation should we use next?',
        'Undo multiplication',
        'Step 2 — Plan',
        '3x = 15',
        highlight: '3',
        lines: <String>['x is multiplied by 3'],
        choice: mc(
          prompt: 'What operation undoes multiplying by 3?',
          options: <String>['Multiply by 3', 'Divide by 3', 'Add 3', 'Subtract 3'],
          correctIndex: 1,
          explanation: 'Division undoes multiplication — divide both sides by 3.',
        ),
      ),
      _eq(
        'Perfect. Divide both sides by 3.',
        'Divide both sides by 3',
        'Step 2 — Work',
        '3x / 3 = 15 / 3',
        lines: <String>['Divide both sides'],
      ),
      _eq(
        'Great job! We have found that x equals $answer.',
        'Solution',
        'Answer',
        'x = $answer',
        highlight: answer,
        lines: <String>['Solution found'],
      ),
      _eq(
        "Let's check. Substitute x = $answer into the original equation.",
        'Check your answer',
        'Verify',
        '3($answer) + 7 = 22',
        lines: <String>['Substitute x = $answer'],
      ),
      _eq(
        'Three times five is fifteen. Fifteen plus seven is twenty-two.',
        'Simplify both sides',
        'Verify',
        '15 + 7 = 22',
        lines: <String>['3($answer) = 15'],
      ),
      _eq(
        'Twenty-two equals twenty-two. Since both sides match, our solution is correct.',
        'Verified ✓',
        'Verified',
        '22 = 22  ✓',
        lines: <String>['Both sides equal', 'x = $answer is correct'],
        durationSeconds: 45,
      ),
    ];
  }

  /// lim (x→4) (x² − 16) / (x − 4) — interactive limit example.
  static List<LectureInteractiveBeat> limitFactoringBeats() {
    return <LectureInteractiveBeat>[
      _eq(
        'Let us find this limit together. First, read the expression carefully — '
        'we are asking what value the fraction approaches as x gets close to 4.',
        'Read the limit',
        'Problem',
        'lim (x→4)  (x² − 16) / (x − 4)',
        lines: <String>['As x approaches 4'],
        durationSeconds: 50,
      ),
      _eq(
        'Try plugging in x = 4 directly. What do you get in the numerator and denominator?',
        'Direct substitution',
        'Try x = 4',
        '0 / 0',
        highlight: '0 / 0',
        lines: <String>['Numerator → 0', 'Denominator → 0'],
        choice: mc(
          prompt: 'Direct substitution gives which indeterminate form?',
          options: <String>['0 / 0', '4 / 0', '∞', 'Already simplified'],
          correctIndex: 0,
          explanation: 'Both numerator and denominator are 0 — we must simplify first.',
        ),
      ),
      _eq(
        'Right — 0/0 means we factor and cancel before substituting.',
        'Factor the numerator',
        'Step 1 — Factor',
        'x² − 16 = (x − 4)(x + 4)',
        lines: <String>['Difference of squares'],
        choice: mc(
          prompt: 'How should we factor x² − 16?',
          options: <String>[
            '(x − 4)(x + 4)',
            '(x − 2)(x + 2)',
            'x(x − 16)',
            'Cannot factor',
          ],
          correctIndex: 0,
          explanation: 'x² − 16 is a difference of squares: (x − 4)(x + 4).',
        ),
      ),
      _eq(
        'Now rewrite the limit with the factored form and cancel the common factor.',
        'Cancel (x − 4)',
        'Step 2 — Cancel',
        '(x − 4)(x + 4) / (x − 4)  →  x + 4',
        lines: <String>['Cancel matching factors'],
      ),
      _eq(
        'After canceling, substitute x = 4 into x + 4. What is the limit?',
        'Evaluate',
        'Step 3 — Substitute',
        'x + 4  →  4 + 4  =  8',
        highlight: '8',
        choice: mc(
          prompt: 'lim (x→4) (x² − 16)/(x − 4) equals…',
          options: <String>['0', '4', '8', 'Does not exist'],
          correctIndex: 2,
          explanation: 'After simplifying, the limit is 4 + 4 = 8.',
        ),
      ),
      _eq(
        'Eight is our answer. The hole at x = 4 does not change the limit value.',
        'Verified ✓',
        'Answer',
        'lim = 8  ✓',
        lines: <String>['Limit exists', 'Answer: 8'],
        durationSeconds: 45,
      ),
    ];
  }

  /// f(x) = x² + 2x − 3, find f(3) — polynomial evaluation.
  static List<LectureInteractiveBeat> polynomialEvaluationBeats({
    String function = 'f(x) = x² + 2x − 3',
    int input = 3,
    String result = '12',
  }) {
    final int square = input * input;
    final int linear = 2 * input;
    final int sum = square + linear - 3;

    return <LectureInteractiveBeat>[
      _eq(
        'Here is a polynomial evaluation problem. We will substitute a value for x '
        'and simplify step by step — just like a quiz, but I guide you.',
        'Read the problem',
        'Problem',
        '$function ,  find f($input)',
        lines: <String>['Evaluate at x = $input'],
        durationSeconds: 48,
      ),
      _eq(
        'First step: replace every x with $input. What should f($input) look like?',
        'Substitute',
        'Step 1 — Substitute',
        'f($input) = ($input)² + 2($input) − 3',
        highlight: '$input',
        choice: mc(
          prompt: 'What value do we substitute for x?',
          options: <String>['$input', '${input + 1}', '${input - 2}', '0'],
          correctIndex: 0,
          explanation: 'The problem asks for f($input), so replace x with $input everywhere.',
        ),
      ),
      _eq(
        'Good. Now evaluate the exponent: what is $input squared?',
        'Evaluate powers',
        'Step 2 — Square',
        'f($input) = $square + 2($input) − 3',
        highlight: '$square',
        choice: mc(
          prompt: 'What is $input² ?',
          options: <String>['$square', '$input', '${input * 3}', '${square + 1}'],
          correctIndex: 0,
          explanation: '$input × $input = $square.',
        ),
      ),
      _eq(
        'Next, compute 2 times $input, then combine all terms.',
        'Combine terms',
        'Step 3 — Simplify',
        'f($input) = $square + $linear − 3 = $sum',
        highlight: '$sum',
        lines: <String>['$square + $linear − 3'],
      ),
      _eq(
        'Let us verify: $square plus $linear minus 3 equals $sum. Our evaluation is correct.',
        'Verified ✓',
        'Answer',
        'f($input) = $sum  ✓',
        lines: <String>['Final answer: $result'],
        durationSeconds: 45,
      ),
    ];
  }

  /// f(x) = x³, find f′(x) using the power rule.
  static List<LectureInteractiveBeat> powerRuleBeats() {
    return <LectureInteractiveBeat>[
      _eq(
        'Let us differentiate together. The power rule says: bring down the exponent, '
        'then reduce the power by one.',
        'Read the problem',
        'Problem',
        'f(x) = x³   →   find f′(x)',
        lines: <String>['Use the power rule'],
        durationSeconds: 48,
      ),
      _eq(
        'For x³, what exponent do we bring down as the coefficient?',
        'Identify exponent',
        'Step 1 — Exponent',
        'f(x) = x³',
        highlight: '3',
        choice: mc(
          prompt: 'In x³, which number is the exponent?',
          options: <String>['3', '1', 'x', '0'],
          correctIndex: 0,
          explanation: 'The exponent on x is 3.',
        ),
      ),
      _eq(
        'Multiply by that exponent, then subtract 1 from the power.',
        'Apply power rule',
        'Step 2 — Apply rule',
        'f′(x) = 3 · x³⁻¹ = 3x²',
        highlight: '3x²',
        choice: mc(
          prompt: 'f′(x) for x³ equals…',
          options: <String>['3x²', 'x²', '3x³', 'x⁴'],
          correctIndex: 0,
          explanation: 'Bring down 3 and reduce the power: 3x².',
        ),
      ),
      _eq(
        'Three x squared is our derivative. You can check by noting the slope of x³ grows like x².',
        'Verified ✓',
        'Answer',
        'f′(x) = 3x²  ✓',
        lines: <String>['Power rule confirmed'],
        durationSeconds: 42,
      ),
    ];
  }

  /// g(x) = 2x + 5, find g(4) — linear evaluation.
  static List<LectureInteractiveBeat> linearEvaluationBeats({
    String function = 'g(x) = 2x + 5',
    int input = 4,
    String result = '13',
  }) {
    final int product = 2 * input;
    final int sum = product + 5;

    return <LectureInteractiveBeat>[
      _eq(
        'Let us evaluate this function step by step. Substitute the input value, '
        'then simplify — you choose each move.',
        'Read the problem',
        'Problem',
        '$function ,  find g($input)',
        lines: <String>['Evaluate at x = $input'],
      ),
      _eq(
        'Replace x with $input everywhere in the expression.',
        'Substitute',
        'Step 1 — Substitute',
        'g($input) = 2($input) + 5',
        highlight: '$input',
        choice: mc(
          prompt: 'What value replaces x?',
          options: <String>['$input', '${input + 1}', '0', 'x'],
          correctIndex: 0,
          explanation: 'We need g($input), so x becomes $input.',
        ),
      ),
      _eq(
        'Multiply first: what is 2 times $input?',
        'Multiply',
        'Step 2 — Multiply',
        'g($input) = $product + 5',
        highlight: '$product',
        choice: mc(
          prompt: '2 × $input = ?',
          options: <String>['$product', '${product + 2}', '$input', '${input + 5}'],
          correctIndex: 0,
          explanation: '2 × $input = $product.',
        ),
      ),
      _eq(
        'Add 5 to finish.',
        'Add',
        'Step 3 — Add',
        'g($input) = $sum',
        highlight: '$sum',
        lines: <String>['$product + 5 = $sum'],
      ),
      _eq(
        'Our answer checks out: g($input) = $result.',
        'Verified ✓',
        'Answer',
        'g($input) = $result  ✓',
        durationSeconds: 40,
      ),
    ];
  }

  /// Pick an interactive example flow based on lesson topic keywords.
  static List<LectureInteractiveBeat> beatsForTopic(String topic) {
    final String t = topic.toLowerCase();
    if (t.contains('limit')) return limitFactoringBeats();
    if (t.contains('derivative') || t.contains('differentiation') || t == 'power rule') {
      return powerRuleBeats();
    }
    if (t.contains('two-step') ||
        t.contains('multi-step') ||
        t.contains('one-step') ||
        t.contains('literal equation')) {
      return twoStepEquationBeats();
    }
    if (t.contains('polynomial')) {
      return polynomialEvaluationBeats();
    }
    if (t.contains('equation') && !t.contains('differential')) {
      return twoStepEquationBeats();
    }
    return linearEvaluationBeats();
  }

  static LectureSegment primaryExample(String topic, {LecturePhase phase = LecturePhase.guidedExamples}) {
    final List<LectureInteractiveBeat> beats = beatsForTopic(topic);
    return build(
      phase: phase,
      title: 'Example 1',
      summarySpeech: 'Interactive example — solve step by step with me.',
      summaryCaption: 'Your turn at each step',
      beats: beats,
      durationSeconds: 120,
    );
  }

  static LectureSegment secondaryExample(String topic) {
    final String t = topic.toLowerCase();
    if (t.contains('limit')) {
      return build(
        phase: LecturePhase.guidedExamples,
        title: 'Example 2',
        summarySpeech: 'Another limit — same factoring strategy.',
        summaryCaption: 'Practice the method',
        beats: <LectureInteractiveBeat>[
          _eq(
            'New problem: lim (x→3) (x² − 9)/(x − 3). What form do you get when x = 3?',
            'New limit problem',
            'Problem',
            'lim (x→3)  (x² − 9) / (x − 3)',
            choice: mc(
              prompt: 'Direct substitution gives…',
              options: <String>['0/0', '3', '9', 'Undefined'],
              correctIndex: 0,
              explanation: 'Plugging in x = 3 gives 0/0 — factor first.',
            ),
          ),
          _eq(
            'Factor x² − 9, cancel, then substitute.',
            'Factor & cancel',
            'Solution',
            '→ x + 3  →  6  ✓',
            highlight: '6',
            lines: <String>['Answer: 6'],
          ),
        ],
        durationSeconds: 90,
      );
    }
    if (t.contains('derivative') || t.contains('differentiation')) {
      return build(
        phase: LecturePhase.guidedExamples,
        title: 'Example 2',
        summarySpeech: 'Differentiate x⁴ using the power rule.',
        summaryCaption: 'Power rule practice',
        beats: <LectureInteractiveBeat>[
          _eq(
            'Find the derivative of x⁴. Which rule applies?',
            'f(x) = x⁴',
            'Problem',
            'f(x) = x⁴',
            choice: mc(
              prompt: 'Best rule for x⁴?',
              options: <String>['Power rule', 'Product rule', 'Chain rule', 'Quotient rule'],
              correctIndex: 0,
              explanation: 'x⁴ is a single power term — use the power rule.',
            ),
          ),
          _eq(
            'Bring down 4 and reduce the exponent.',
            'Apply rule',
            'Answer',
            'f′(x) = 4x³  ✓',
            highlight: '4x³',
          ),
        ],
        durationSeconds: 80,
      );
    }
    return build(
      phase: LecturePhase.guidedExamples,
      title: 'Example 2',
      summarySpeech: 'A harder evaluation — watch for signs.',
      summaryCaption: 'Harder practice',
      beats: polynomialEvaluationBeats(
        function: 'h(x) = x² − x + 2',
        input: 2,
        result: '4',
      ),
      durationSeconds: 100,
    );
  }

  /// One example per mode tier — each problem is unique and on-topic.
  static List<LectureSegment> examplesForMode(
    String topic,
    LectureMode mode, {
    String courseId = '',
    LectureTopicCategory? category,
  }) {
    final LectureTopicCategory resolved = category ??
        VirtualLectureTopicProfile.categoryFor(topic: topic, courseId: courseId, module: '');

    return switch (mode) {
      LectureMode.review => <LectureSegment>[_refreshExample(topic, courseId: courseId, category: resolved)],
      LectureMode.exam => <LectureSegment>[
          _deepExampleC(topic, courseId: courseId, category: resolved),
        ],
      LectureMode.comprehensive || LectureMode.concept => <LectureSegment>[
          _refreshExample(topic, courseId: courseId, category: resolved),
          _standardExampleA(topic, courseId: courseId, category: resolved),
          _standardExampleB(topic, courseId: courseId, category: resolved),
          _deepExampleC(topic, courseId: courseId, category: resolved),
          practiceExample(topic, courseId: courseId, category: resolved),
        ],
      LectureMode.practice => <LectureSegment>[
          _standardExampleA(topic, courseId: courseId, category: resolved),
          _standardExampleB(topic, courseId: courseId, category: resolved),
          practiceExample(topic, courseId: courseId, category: resolved),
        ],
      LectureMode.deepLearning => <LectureSegment>[
          _deepExampleA(topic, courseId: courseId, category: resolved),
          _deepExampleB(topic, courseId: courseId, category: resolved),
          _deepExampleC(topic, courseId: courseId, category: resolved),
          practiceExample(topic, courseId: courseId, category: resolved),
          _refreshExample(topic, courseId: courseId, category: resolved),
        ],
    };
  }

  static LectureSegment _refreshExample(
    String topic, {
    String courseId = '',
    LectureTopicCategory? category,
  }) {
    return build(
      phase: LecturePhase.guidedExamples,
      title: 'Quick Example',
      summarySpeech: 'Quick refresh — one problem on $topic, your turn at each step.',
      summaryCaption: 'Mind refresh example',
      beats: _refreshBeats(topic, courseId: courseId, category: category),
      durationSeconds: 75,
    );
  }

  static LectureSegment _standardExampleA(
    String topic, {
    String courseId = '',
    LectureTopicCategory? category,
  }) {
    return build(
      phase: LecturePhase.guidedExamples,
      title: 'Example 1',
      summarySpeech: 'First $topic example — solve step by step together.',
      summaryCaption: 'Example 1 — your turn',
      beats: _firstBeats(topic, courseId: courseId, category: category),
      durationSeconds: 100,
    );
  }

  static LectureSegment _standardExampleB(
    String topic, {
    String courseId = '',
    LectureTopicCategory? category,
  }) {
    return build(
      phase: LecturePhase.guidedExamples,
      title: 'Example 2',
      summarySpeech: 'Second $topic example — different problem, same strategy.',
      summaryCaption: 'Example 2 — your turn',
      beats: _secondBeats(topic, courseId: courseId, category: category),
      durationSeconds: 95,
    );
  }

  static LectureSegment _deepExampleA(
    String topic, {
    String courseId = '',
    LectureTopicCategory? category,
  }) =>
      _standardExampleA(topic, courseId: courseId, category: category);

  static LectureSegment _deepExampleB(
    String topic, {
    String courseId = '',
    LectureTopicCategory? category,
  }) =>
      _standardExampleB(topic, courseId: courseId, category: category);

  static LectureSegment _deepExampleC(
    String topic, {
    String courseId = '',
    LectureTopicCategory? category,
  }) {
    return build(
      phase: LecturePhase.practiceProblems,
      title: 'Example 3',
      summarySpeech: 'Third $topic example — practice until it clicks.',
      summaryCaption: 'Example 3 — your turn',
      beats: _thirdBeats(topic, courseId: courseId, category: category),
      durationSeconds: 105,
    );
  }

  static LectureSegment practiceExample(
    String topic, {
    String courseId = '',
    LectureTopicCategory? category,
  }) {
    return build(
      phase: LecturePhase.practiceProblems,
      title: 'Your Turn',
      summarySpeech: 'Try this $topic problem — I pause so you can think before each step.',
      summaryCaption: 'Practice problem',
      beats: _thirdBeats(topic, courseId: courseId, category: category),
      durationSeconds: 110,
    );
  }

  static List<LectureInteractiveBeat> _refreshBeats(
    String topic, {
    String courseId = '',
    LectureTopicCategory? category,
  }) {
    final String t = topic.toLowerCase();
    if (_isTrigTopic(t, courseId, category)) return _unitCircleQuickBeats();
    if (t.contains('limit')) {
      return <LectureInteractiveBeat>[
        _eq(
          'Quick limit refresh: what happens when we plug in directly?',
          'Limit refresh',
          'Problem',
          'lim (x→3)  (x² − 9) / (x − 3)',
          choice: mc(
            prompt: 'Direct substitution gives…',
            options: <String>['0/0', '3', '6', 'Undefined'],
            correctIndex: 0,
            explanation: '0/0 means factor and cancel before substituting.',
          ),
        ),
        _eq(
          'After factoring and canceling, the limit is 6.',
          'Answer',
          'Solution',
          '→ x + 3  →  6  ✓',
          highlight: '6',
        ),
      ];
    }
    if (t.contains('derivative') || t.contains('differentiation') || t == 'power rule') {
      return <LectureInteractiveBeat>[
        _eq(
          'Quick derivative refresh: find f′(x) for x².',
          'Power rule',
          'Problem',
          'f(x) = x²',
          choice: mc(
            prompt: 'f′(x) = ?',
            options: <String>['2x', 'x', 'x²', '2'],
            correctIndex: 0,
            explanation: 'Power rule: bring down 2 → 2x.',
          ),
        ),
        _eq('Answer: f′(x) = 2x.', 'Verified', 'Answer', 'f′(x) = 2x  ✓', highlight: '2x'),
      ];
    }
    if (_isEquationTopic(t, courseId)) {
      return <LectureInteractiveBeat>[
        _eq(
          'Quick equation refresh: solve 2x − 5 = 11.',
          'One-step plan',
          'Problem',
          '2x − 5 = 11',
          highlight: '−5',
          choice: mc(
            prompt: 'What undoes subtracting 5?',
            options: <String>['Subtract 5', 'Add 5', 'Divide by 5', 'Multiply by 5'],
            correctIndex: 1,
            explanation: 'Add 5 to both sides first.',
          ),
        ),
        _eq('Divide both sides by 2.', 'Solve', 'Answer', 'x = 8  ✓', highlight: '8'),
      ];
    }
    if (t.contains('polynomial')) {
      return polynomialEvaluationBeats(function: 'f(x) = x + 4', input: 3, result: '7')
          .take(3)
          .toList();
    }
    return _topicAwareFallbackBeats(topic, courseId, category, variant: 0);
  }

  static List<LectureInteractiveBeat> _firstBeats(
    String topic, {
    String courseId = '',
    LectureTopicCategory? category,
  }) {
    final String t = topic.toLowerCase();
    if (_isTrigTopic(t, courseId, category)) {
      return t == 'unit circle' ? unitCircleBeats() : trigValueBeats(angle: 'π/6', fn: 'sin');
    }
    if (t.contains('limit')) return limitFactoringBeats();
    if (t.contains('derivative') || t.contains('differentiation') || t == 'power rule') {
      return powerRuleBeats();
    }
    if (_isEquationTopic(t, courseId)) return twoStepEquationBeats();
    if (t.contains('polynomial')) return polynomialEvaluationBeats();
    return _topicAwareFallbackBeats(topic, courseId, category, variant: 1);
  }

  static List<LectureInteractiveBeat> _secondBeats(
    String topic, {
    String courseId = '',
    LectureTopicCategory? category,
  }) {
    final String t = topic.toLowerCase();
    if (_isTrigTopic(t, courseId, category)) {
      return t == 'unit circle'
          ? trigCoordinateBeats(angle: '3π/4')
          : trigValueBeats(angle: 'π/4', fn: 'cos');
    }
    if (t.contains('limit')) {
      return <LectureInteractiveBeat>[
        _eq(
          'New limit: lim (x→2) (x² − 4)/(x − 2). Identify the form first.',
          'Example 2',
          'Problem',
          'lim (x→2)  (x² − 4) / (x − 2)',
          choice: mc(
            prompt: 'Direct substitution gives…',
            options: <String>['0/0', '2', '4', 'Undefined'],
            correctIndex: 0,
            explanation: 'Plugging in x = 2 gives 0/0 — factor x² − 4.',
          ),
        ),
        _eq(
          'Factor, cancel, substitute x = 2 into x + 2.',
          'Solution',
          'Answer',
          'x + 2  →  4  ✓',
          highlight: '4',
        ),
      ];
    }
    if (t.contains('derivative') || t.contains('differentiation') || t == 'power rule') {
      return <LectureInteractiveBeat>[
        _eq(
          'Differentiate f(x) = 4x². Keep the coefficient.',
          'Example 2',
          'Problem',
          'f(x) = 4x²',
          choice: mc(
            prompt: 'f′(x) = ?',
            options: <String>['8x', '4x', '2x', '4x²'],
            correctIndex: 0,
            explanation: '4 · 2x = 8x.',
          ),
        ),
        _eq('Verified.', 'Answer', 'Solution', 'f′(x) = 8x  ✓', highlight: '8x'),
      ];
    }
    if (_isEquationTopic(t, courseId)) {
      return _equationExampleBeats(
        problem: '5x − 8 = 17',
        undoTerm: '−8',
        undoPrompt: 'What undoes subtracting 8?',
        undoOptions: <String>['Subtract 8', 'Add 8', 'Divide by 8', 'Multiply by 8'],
        undoCorrect: 1,
        undoExplanation: 'Add 8 to both sides.',
        afterUndo: '5x − 8 + 8 = 17 + 8',
        simplified: '5x = 25',
        coeffHighlight: '5',
        dividePrompt: 'What undoes multiplying by 5?',
        divideOptions: <String>['Multiply by 5', 'Divide by 5', 'Add 5', 'Subtract 5'],
        divideCorrect: 1,
        divideExplanation: 'Divide both sides by 5.',
        divisionWork: '5x / 5 = 25 / 5',
        answer: '5',
        verify: '5(5) − 8 = 17  ✓',
      );
    }
    if (t.contains('polynomial')) {
      return polynomialEvaluationBeats(function: 'h(x) = x² − x + 2', input: 2, result: '4');
    }
    return _topicAwareFallbackBeats(topic, courseId, category, variant: 2);
  }

  static List<LectureInteractiveBeat> _thirdBeats(
    String topic, {
    String courseId = '',
    LectureTopicCategory? category,
  }) {
    final String t = topic.toLowerCase();
    if (_isTrigTopic(t, courseId, category)) {
      return t == 'unit circle'
          ? trigQuadrantBeats()
          : trigValueBeats(angle: '5π/6', fn: 'sin');
    }
    if (t.contains('limit')) {
      return <LectureInteractiveBeat>[
        _eq(
          'Practice limit: lim (x→1) (x² − 1)/(x − 1).',
          'Example 3',
          'Problem',
          'lim (x→1)  (x² − 1) / (x − 1)',
          choice: mc(
            prompt: 'After simplifying, the limit equals…',
            options: <String>['0', '1', '2', 'DNE'],
            correctIndex: 2,
            explanation: 'Cancels to x + 1 → 2 as x → 1.',
          ),
        ),
        _eq('Answer: 2.', 'Verified', 'Answer', 'lim = 2  ✓', highlight: '2'),
      ];
    }
    if (t.contains('derivative') || t.contains('differentiation') || t == 'power rule') {
      return <LectureInteractiveBeat>[
        _eq(
          'Differentiate f(x) = x³ + 2x² − 5x.',
          'Example 3',
          'Problem',
          'f(x) = x³ + 2x² − 5x',
          choice: mc(
            prompt: 'Derivative of x³ + 2x² − 5x is…',
            options: <String>['3x² + 4x − 5', '3x² + 2x − 5', 'x² + 4x − 5', '3x² + 4x'],
            correctIndex: 0,
            explanation: 'Term by term: 3x² + 4x − 5.',
          ),
        ),
        _eq('Verified.', 'Answer', 'Solution', 'f′(x) = 3x² + 4x − 5  ✓'),
      ];
    }
    if (_isEquationTopic(t, courseId)) {
      return _equationExampleBeats(
        problem: '4x + 3 = 27',
        undoTerm: '+3',
        undoPrompt: 'What undoes adding 3?',
        undoOptions: <String>['Add 3', 'Subtract 3', 'Multiply by 3', 'Divide by 3'],
        undoCorrect: 1,
        undoExplanation: 'Subtract 3 from both sides.',
        afterUndo: '4x + 3 − 3 = 27 − 3',
        simplified: '4x = 24',
        coeffHighlight: '4',
        dividePrompt: 'What undoes multiplying by 4?',
        divideOptions: <String>['Multiply by 4', 'Divide by 4', 'Add 4', 'Subtract 4'],
        divideCorrect: 1,
        divideExplanation: 'Divide both sides by 4.',
        divisionWork: '4x / 4 = 24 / 4',
        answer: '6',
        verify: '4(6) + 3 = 27  ✓',
      );
    }
    if (t.contains('polynomial')) {
      return linearEvaluationBeats(function: 'k(x) = 2x − 3', input: 5, result: '7');
    }
    return _topicAwareFallbackBeats(topic, courseId, category, variant: 3);
  }

  static bool _isTrigTopic(String t, String courseId, LectureTopicCategory? category) {
    if (category == LectureTopicCategory.trigonometry) return true;
    return VirtualLectureTopicProfile.isTrigonometry(t, courseId);
  }

  static bool _isEquationTopic(String t, String courseId) {
    return VirtualLectureTopicProfile.isAlgebraEquationTopic(topic: t, courseId: courseId);
  }

  static List<LectureInteractiveBeat> _unitCircleQuickBeats() {
    return <LectureInteractiveBeat>[
      _eq(
        'On the unit circle, what is sin(π/6)?',
        'Unit circle refresh',
        'Problem',
        'sin(π/6) = ?',
        choice: mc(
          prompt: 'sin(π/6) equals…',
          options: <String>['1/2', '√2/2', '√3/2', '1'],
          correctIndex: 0,
          explanation: 'At π/6, the y-coordinate is 1/2.',
        ),
      ),
      _eq('Answer: sin(π/6) = 1/2.', 'Verified', 'Answer', 'sin(π/6) = 1/2  ✓', highlight: '1/2'),
    ];
  }

  static List<LectureInteractiveBeat> unitCircleBeats() {
    return <LectureInteractiveBeat>[
      _eq(
        'The unit circle has radius 1. For angle π/3, find cos(π/3) and sin(π/3).',
        'Unit circle example',
        'Problem',
        'θ = π/3  →  (cos θ, sin θ) = ?',
        lines: <String>['Use special triangle values'],
        choice: mc(
          prompt: 'cos(π/3) equals…',
          options: <String>['1/2', '√3/2', '√2/2', '1'],
          correctIndex: 0,
          explanation: 'At π/3, x-coordinate (cosine) is 1/2.',
        ),
      ),
      _eq(
        'Correct — cos(π/3) = 1/2. The y-coordinate is sin(π/3).',
        'Find sine',
        'Step 2',
        'sin(π/3) = ?',
        choice: mc(
          prompt: 'sin(π/3) equals…',
          options: <String>['√3/2', '1/2', '1', '√2/2'],
          correctIndex: 0,
          explanation: 'At π/3, y-coordinate (sine) is √3/2.',
        ),
      ),
      _eq(
        'The point on the unit circle is (1/2, √3/2).',
        'Coordinates',
        'Answer',
        '(cos(π/3), sin(π/3)) = (1/2, √3/2)  ✓',
        highlight: '√3/2',
      ),
    ];
  }

  static List<LectureInteractiveBeat> trigCoordinateBeats({required String angle}) {
    return <LectureInteractiveBeat>[
      _eq(
        'Find the coordinates on the unit circle at θ = $angle.',
        'Coordinates',
        'Problem',
        'P($angle) = (cos $angle, sin $angle)',
        choice: mc(
          prompt: 'θ = 3π/4 is in which quadrant?',
          options: <String>['Quadrant II', 'Quadrant I', 'Quadrant III', 'Quadrant IV'],
          correctIndex: 0,
          explanation: '3π/4 is between π/2 and π — Quadrant II.',
        ),
      ),
      _eq(
        'In Quadrant II, cos is negative and sin is positive.',
        'Signs',
        'Step 2',
        'cos(3π/4) = −√2/2,  sin(3π/4) = √2/2',
        highlight: '−√2/2',
      ),
    ];
  }

  static List<LectureInteractiveBeat> trigQuadrantBeats() {
    return <LectureInteractiveBeat>[
      _eq(
        'Find sin(5π/6) using the unit circle and reference angle.',
        'Reference angle',
        'Problem',
        'sin(5π/6) = ?',
        choice: mc(
          prompt: 'Reference angle for 5π/6 is…',
          options: <String>['π/6', 'π/4', 'π/3', 'π/2'],
          correctIndex: 0,
          explanation: '5π/6 is π − π/6, so reference angle is π/6.',
        ),
      ),
      _eq(
        'Quadrant II → sine is positive. sin(5π/6) = sin(π/6) = 1/2.',
        'Answer',
        'Solution',
        'sin(5π/6) = 1/2  ✓',
        highlight: '1/2',
      ),
    ];
  }

  static List<LectureInteractiveBeat> trigValueBeats({
    required String angle,
    required String fn,
  }) {
    final String label = fn == 'cos' ? 'cos' : 'sin';
    return <LectureInteractiveBeat>[
      _eq(
        'Evaluate $label($angle) using the unit circle.',
        'Trig value',
        'Problem',
        '$label($angle) = ?',
        choice: mc(
          prompt: '$label($angle) equals…',
          options: fn == 'cos'
              ? <String>['√2/2', '1/2', '√3/2', '0']
              : <String>['1/2', '√2/2', '√3/2', '1'],
          correctIndex: fn == 'cos' && angle.contains('π/4') ? 0 : 0,
          explanation: 'Read the ${fn == 'cos' ? 'x' : 'y'}-coordinate at $angle on the unit circle.',
        ),
      ),
      _eq(
        'Use the special angle value from the unit circle.',
        'Answer',
        'Solution',
        '$label($angle) = ${fn == 'cos' && angle.contains('π/4') ? '√2/2' : '1/2'}  ✓',
      ),
    ];
  }

  static List<LectureInteractiveBeat> _topicAwareFallbackBeats(
    String topic,
    String courseId,
    LectureTopicCategory? category,
    {required int variant}
  ) {
    final LectureTopicCategory cat = category ??
        VirtualLectureTopicProfile.categoryFor(topic: topic, courseId: courseId, module: '');

    if (cat == LectureTopicCategory.trigonometry) {
      return switch (variant % 3) {
        0 => _unitCircleQuickBeats(),
        1 => trigValueBeats(angle: 'π/4', fn: 'cos'),
        _ => trigQuadrantBeats(),
      };
    }
    if (cat == LectureTopicCategory.geometry) {
      return <LectureInteractiveBeat>[
        _eq(
          'In $topic, identify what is given and what you must find.',
          '$topic problem',
          'Problem',
          'Given → find missing measure',
          lines: <String>['Draw & label', 'Choose theorem'],
        ),
        _eq('Apply the theorem step by step.', 'Solution', 'Answer', 'Missing value found  ✓'),
      ];
    }
    if (cat == LectureTopicCategory.statistics || cat == LectureTopicCategory.probability) {
      return <LectureInteractiveBeat>[
        _eq(
          '$topic example: organize the data first.',
          topic,
          'Problem',
          'Data → statistic',
          lines: <String>['Define sample space or data set'],
        ),
        _eq('Compute and interpret in context.', 'Answer', 'Result', 'Statistic computed  ✓'),
      ];
    }
    if (cat == LectureTopicCategory.basicMath || _isNumberSenseTopic(topic)) {
      return numberSenseBeats(topic, variant: variant);
    }
    if (cat == LectureTopicCategory.biology || cat == LectureTopicCategory.chemistry) {
      return subjectConceptBeats(topic, variant: variant);
    }
    if (topic.toLowerCase().contains('polynomial') || cat == LectureTopicCategory.precalculus) {
      return polynomialEvaluationBeats(
        function: 'f(x) = x² + 1',
        input: 3 + variant,
        result: '${10 + variant}',
      );
    }
    // Last resort: still name the topic — never invent unrelated calculus.
    return subjectConceptBeats(topic, variant: variant);
  }

  static bool _isNumberSenseTopic(String topic) {
    final String t = topic.toLowerCase();
    return t.contains('natural number') ||
        t.contains('whole number') ||
        t.contains('integer') ||
        t.contains('rational') ||
        t.contains('real number') ||
        t.contains('number line') ||
        t.contains('absolute value') ||
        t.contains('number set');
  }

  /// Interactive membership / counting problems locked to the named number topic.
  static List<LectureInteractiveBeat> numberSenseBeats(String topic, {int variant = 0}) {
    final String t = topic.toLowerCase();
    final String setLabel = t.contains('natural')
        ? 'ℕ'
        : t.contains('whole')
            ? 'whole numbers'
            : t.contains('integer')
                ? 'ℤ'
                : t.contains('rational')
                    ? 'ℚ'
                    : t.contains('real')
                        ? 'ℝ'
                        : topic;

    final List<({String value, bool member, String why})> bank =
        t.contains('natural')
            ? <({String value, bool member, String why})>[
                (value: '7', member: true, why: '7 is a positive counting number.'),
                (value: '0', member: false, why: 'In the usual counting definition, 0 is not natural.'),
                (value: '−2', member: false, why: 'Negatives are not natural numbers.'),
                (value: '1/2', member: false, why: 'Fractions are not natural numbers.'),
              ]
            : t.contains('whole')
                ? <({String value, bool member, String why})>[
                    (value: '0', member: true, why: 'Whole numbers include zero.'),
                    (value: '4', member: true, why: '4 is a non-negative counting number.'),
                    (value: '−1', member: false, why: 'Negatives are not whole numbers.'),
                    (value: '3/4', member: false, why: 'Fractions are not whole numbers.'),
                  ]
                : t.contains('integer')
                    ? <({String value, bool member, String why})>[
                        (value: '−5', member: true, why: 'Integers include negatives.'),
                        (value: '0', member: true, why: 'Zero is an integer.'),
                        (value: '2/3', member: false, why: 'Non-integer fractions are not integers.'),
                        (value: '√2', member: false, why: '√2 is irrational, not an integer.'),
                      ]
                    : t.contains('rational')
                        ? <({String value, bool member, String why})>[
                            (value: '2/5', member: true, why: '2/5 is a ratio of integers.'),
                            (value: '−3', member: true, why: '−3 = −3/1, so it is rational.'),
                            (value: '√2', member: false, why: '√2 cannot be written as a/b.'),
                            (value: 'π', member: false, why: 'π is irrational.'),
                          ]
                        : <({String value, bool member, String why})>[
                            (value: '√2', member: true, why: '√2 is a real irrational.'),
                            (value: 'π', member: true, why: 'π is real.'),
                            (value: '3/4', member: true, why: 'Rationals are a subset of reals.'),
                            (value: '√−1', member: false, why: '√−1 is imaginary, not real.'),
                          ];

    final ({String value, bool member, String why}) item = bank[variant % bank.length];
    return <LectureInteractiveBeat>[
      _eq(
        'Interactive check for $topic only. Decide whether ${item.value} belongs to $setLabel.',
        'Membership — $topic',
        'Problem',
        '${item.value} ∈ $setLabel ?',
        lines: <String>['Use the definition of $topic', 'Yes or no with a reason'],
        choice: mc(
          prompt: 'Is ${item.value} in $setLabel ($topic)?',
          options: <String>['Yes', 'No', 'Sometimes', 'Cannot tell'],
          correctIndex: item.member ? 0 : 1,
          explanation: item.why,
        ),
        durationSeconds: 55,
      ),
      _eq(
        item.why,
        'Reason',
        'Solution',
        item.member ? '${item.value} ∈ $setLabel  ✓' : '${item.value} ∉ $setLabel  ✓',
        lines: <String>['Definition of $topic', item.why],
      ),
      _eq(
        'Place ${item.value} on the number line and label whether it is part of $topic.',
        'Number line',
        'Visual',
        'Number line · $topic',
        lines: <String>['Mark ${item.value}', item.member ? 'Inside $setLabel' : 'Outside $setLabel'],
      ),
    ];
  }

  /// Generic but topic-locked concept check (no unrelated formulas).
  static List<LectureInteractiveBeat> subjectConceptBeats(String topic, {int variant = 0}) {
    final List<String> focuses = <String>[
      'definition',
      'example',
      'common mistake',
      'real-world use',
    ];
    final String focus = focuses[variant % focuses.length];
    return <LectureInteractiveBeat>[
      _eq(
        'Stay on $topic. For this interactive beat we focus on the $focus of $topic.',
        '$topic — $focus',
        'Problem',
        topic,
        lines: <String>['Topic lock: $topic', 'Focus: $focus'],
        choice: mc(
          prompt: 'What should we do first when studying $topic?',
          options: <String>[
            'State the definition of $topic clearly',
            'Skip to a different lesson topic',
            'Memorize an unrelated formula',
            'Ignore examples',
          ],
          correctIndex: 0,
          explanation: 'Always start from the definition of $topic before examples or formulas.',
        ),
      ),
      _eq(
        'Write one precise sentence that captures $topic, then give a matching example.',
        'Definition + example',
        'Board',
        'Def($topic) → example',
        lines: <String>['Definition', 'Example that matches', 'Non-example'],
      ),
    ];
  }

  static List<LectureInteractiveBeat> _equationExampleBeats({
    required String problem,
    required String undoTerm,
    required String undoPrompt,
    required List<String> undoOptions,
    required int undoCorrect,
    required String undoExplanation,
    required String afterUndo,
    required String simplified,
    required String coeffHighlight,
    required String dividePrompt,
    required List<String> divideOptions,
    required int divideCorrect,
    required String divideExplanation,
    required String divisionWork,
    required String answer,
    required String verify,
  }) {
    return <LectureInteractiveBeat>[
      _eq(
        'Let us solve this equation together — pick the right operation at each step.',
        'Read the problem',
        'Problem',
        problem,
        lines: <String>['Solve for x'],
      ),
      _eq(
        'What operation undoes $undoTerm?',
        'Plan step 1',
        'Step 1',
        problem,
        highlight: undoTerm,
        choice: mc(
          prompt: undoPrompt,
          options: undoOptions,
          correctIndex: undoCorrect,
          explanation: undoExplanation,
        ),
      ),
      _eq('Apply it to both sides.', 'Work step 1', 'Step 1 — Work', afterUndo),
      _eq('Simplify.', 'Simplified', 'Simplified', simplified),
      _eq(
        'Now undo the coefficient on x.',
        'Plan step 2',
        'Step 2',
        simplified,
        highlight: coeffHighlight,
        choice: mc(
          prompt: dividePrompt,
          options: divideOptions,
          correctIndex: divideCorrect,
          explanation: divideExplanation,
        ),
      ),
      _eq('Divide both sides.', 'Work step 2', 'Step 2 — Work', divisionWork),
      _eq('Solution found.', 'Answer', 'Answer', 'x = $answer', highlight: answer),
      _eq('Verify by substituting back.', 'Verified ✓', 'Verify', verify),
    ];
  }
}
