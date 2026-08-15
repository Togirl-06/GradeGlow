/// Domain category for offline lecture routing and interactive examples.
enum LectureTopicCategory {
  limits,
  derivatives,
  algebraEquations,
  trigonometry,
  geometry,
  precalculus,
  calculusOther,
  statistics,
  probability,
  linearAlgebra,
  differentialEquations,
  discreteMath,
  numericalMethods,
  basicMath,
  chemistry,
  biology,
  general,
}

/// Topic-specific lecture metadata used to build accurate offline scripts.
class VirtualLectureTopicProfile {
  const VirtualLectureTopicProfile({
    required this.topic,
    required this.course,
    required this.courseId,
    required this.module,
    required this.lessonId,
    required this.category,
    required this.objectives,
    required this.introSpeech,
    required this.whySpeech,
    required this.conceptSpeech,
    required this.mainEquation,
    required this.conceptLines,
    required this.visualSpeech,
    required this.graphFunction,
    required this.methodSpeech,
    required this.methodLines,
    required this.mistakesSpeech,
    required this.mistakesLines,
    required this.applicationsSpeech,
    required this.applicationLines,
    required this.checkPrompt,
    required this.checkOptions,
    required this.checkCorrectIndex,
    required this.checkExplanation,
    required this.definitions,
    required this.formulas,
    required this.exampleIdeas,
    required this.commonMistakes,
    required this.tips,
    required this.summaryLearned,
    required this.summaryApplications,
    required this.summaryReview,
  });

  final String topic;
  final String course;
  final String courseId;
  final String module;
  final String lessonId;
  final LectureTopicCategory category;

  final List<String> objectives;
  final String introSpeech;
  final String whySpeech;
  final String conceptSpeech;
  final String mainEquation;
  final List<String> conceptLines;
  final String visualSpeech;
  final String graphFunction;
  final String methodSpeech;
  final List<String> methodLines;
  final String mistakesSpeech;
  final List<String> mistakesLines;
  final String applicationsSpeech;
  final List<String> applicationLines;
  final String checkPrompt;
  final List<String> checkOptions;
  final int checkCorrectIndex;
  final String checkExplanation;
  final List<String> definitions;
  final List<String> formulas;
  final List<String> exampleIdeas;
  final List<String> commonMistakes;
  final List<String> tips;
  final List<String> summaryLearned;
  final List<String> summaryApplications;
  final List<String> summaryReview;

  static VirtualLectureTopicProfile resolve({
    required String topic,
    required String course,
    required String courseId,
    required String module,
    required String lessonId,
  }) {
    final LectureTopicCategory category = categoryFor(
      topic: topic,
      courseId: courseId,
      module: module,
    );
    final _TopicContent content = _contentFor(
      topic: topic,
      course: course,
      courseId: courseId,
      module: module,
      category: category,
    );

    return VirtualLectureTopicProfile(
      topic: topic,
      course: course,
      courseId: courseId,
      module: module,
      lessonId: lessonId,
      category: category,
      objectives: content.objectives,
      introSpeech: content.introSpeech,
      whySpeech: content.whySpeech,
      conceptSpeech: content.conceptSpeech,
      mainEquation: content.mainEquation,
      conceptLines: content.conceptLines,
      visualSpeech: content.visualSpeech,
      graphFunction: content.graphFunction,
      methodSpeech: content.methodSpeech,
      methodLines: content.methodLines,
      mistakesSpeech: content.mistakesSpeech,
      mistakesLines: content.mistakesLines,
      applicationsSpeech: content.applicationsSpeech,
      applicationLines: content.applicationLines,
      checkPrompt: content.checkPrompt,
      checkOptions: content.checkOptions,
      checkCorrectIndex: content.checkCorrectIndex,
      checkExplanation: content.checkExplanation,
      definitions: content.definitions,
      formulas: content.formulas,
      exampleIdeas: content.exampleIdeas,
      commonMistakes: content.commonMistakes,
      tips: content.tips,
      summaryLearned: content.summaryLearned,
      summaryApplications: content.summaryApplications,
      summaryReview: content.summaryReview,
    );
  }

  static LectureTopicCategory categoryFor({
    required String topic,
    required String courseId,
    required String module,
  }) {
    final String t = topic.toLowerCase();
    final String c = courseId.toLowerCase();
    final String m = module.toLowerCase();

    if (t.contains('limit') && !t.contains('rate limit')) {
      return LectureTopicCategory.limits;
    }
    // Faculty courses first — avoid "differentiation" false positives in bio/chem.
    if (isChemistryCourse(courseId)) {
      return LectureTopicCategory.chemistry;
    }
    if (isBiologyCourse(courseId)) {
      return LectureTopicCategory.biology;
    }
    if (_isDerivativeTopic(t, c)) {
      return LectureTopicCategory.derivatives;
    }
    if (isAlgebraEquationTopic(topic: topic, courseId: courseId)) {
      return LectureTopicCategory.algebraEquations;
    }

    return switch (c) {
      'trigonometry' => LectureTopicCategory.trigonometry,
      'geometry' => LectureTopicCategory.geometry,
      'precalculus' => LectureTopicCategory.precalculus,
      'calculus_1' || 'calculus_2' => _calculusCategory(t),
      'statistics' => LectureTopicCategory.statistics,
      'probability' => LectureTopicCategory.probability,
      'linear_algebra' => LectureTopicCategory.linearAlgebra,
      'differential_equations' => LectureTopicCategory.differentialEquations,
      'discrete_mathematics' => LectureTopicCategory.discreteMath,
      'numerical_methods' => LectureTopicCategory.numericalMethods,
      'basic_mathematics' || 'algebra_1' => _basicCategory(t, m),
      _ => _inferFromTitle(t, m),
    };
  }

  static bool isBiologyCourse(String courseId) {
    return courseId.contains('biology') ||
        courseId.contains('anatomy') ||
        courseId.contains('physiology') ||
        courseId.contains('genetics') ||
        courseId.contains('microbiology') ||
        courseId.contains('ecology') ||
        courseId.contains('evolution') ||
        courseId.contains('immunology') ||
        courseId.contains('neuroscience') ||
        courseId == 'diversity_of_life' ||
        courseId == 'biotechnology' ||
        courseId == 'bioinformatics';
  }

  static bool isChemistryCourse(String courseId) {
    return courseId.contains('chemistry') ||
        courseId == 'biochemistry' ||
        courseId == 'electrochemistry';
  }

  static bool isTrigonometry(String topic, String courseId) {
    final String t = topic.toLowerCase();
    if (courseId == 'trigonometry') return true;
    return t.contains('unit circle') ||
        t.contains('trigonometric') ||
        t.contains('radian') ||
        t == 'sine' ||
        t == 'cosine' ||
        t == 'tangent' ||
        t.contains('law of sines') ||
        t.contains('law of cosines') ||
        t.contains('inverse trigonometric');
  }

  static bool isAlgebraEquationTopic({
    required String topic,
    required String courseId,
  }) {
    final String t = topic.toLowerCase();
    if (_isNonAlgebraEquationTopic(t, courseId)) return false;
    return t.contains('two-step') ||
        t.contains('multi-step') ||
        t.contains('one-step') ||
        t.contains('literal equation') ||
        (t.contains('equation') && courseId == 'algebra_1');
  }

  static bool _isDerivativeTopic(String t, String courseId) {
    if (courseId == 'numerical_methods' || courseId == 'differential_equations') {
      return false;
    }
    return t.contains('derivative') ||
        t == 'power rule' ||
        t.contains('product rule') ||
        t.contains('quotient rule') ||
        t.contains('chain rule') ||
        t.contains('implicit differentiation') ||
        (t.contains('differentiation') && !t.contains('numerical'));
  }

  static bool _isNonAlgebraEquationTopic(String t, String courseId) {
    if (courseId == 'differential_equations') return true;
    return t.contains('differential') ||
        t.contains('boolean') ||
        t.contains('trigonometric') ||
        t.contains('parametric') ||
        t.contains('separable') ||
        t.contains('exact equation') ||
        t.contains('homogeneous equation') ||
        t.contains('nonhomogeneous') ||
        t.contains('polar') ||
        t.contains('matrix');
  }

  static LectureTopicCategory _calculusCategory(String t) {
    if (t.contains('limit')) return LectureTopicCategory.limits;
    if (_isDerivativeTopic(t, 'calculus_1')) return LectureTopicCategory.derivatives;
    return LectureTopicCategory.calculusOther;
  }

  static LectureTopicCategory _basicCategory(String t, String m) {
    if (m.contains('equation') || t.contains('equation')) {
      return LectureTopicCategory.algebraEquations;
    }
    return LectureTopicCategory.basicMath;
  }

  static LectureTopicCategory _inferFromTitle(String t, String m) {
    if (m.contains('trig') || t.contains('sin') || t.contains('cos')) {
      return LectureTopicCategory.trigonometry;
    }
    if (m.contains('geometry') || t.contains('triangle') || t.contains('circle')) {
      return LectureTopicCategory.geometry;
    }
    if (t.contains('probability') || m.contains('probability')) {
      return LectureTopicCategory.probability;
    }
    if (t.contains('statistic') || m.contains('statistic')) {
      return LectureTopicCategory.statistics;
    }
    return LectureTopicCategory.general;
  }

  static _TopicContent _contentFor({
    required String topic,
    required String course,
    required String courseId,
    required String module,
    required LectureTopicCategory category,
  }) {
    final String t = topic.toLowerCase();

    if (t == 'unit circle') {
      return _unitCircleContent(topic, course);
    }
    if (category == LectureTopicCategory.trigonometry) {
      return _trigonometryContent(topic, course, module);
    }
    if (category == LectureTopicCategory.geometry) {
      return _geometryContent(topic, course, module);
    }
    if (category == LectureTopicCategory.statistics) {
      return _statisticsContent(topic, course);
    }
    if (category == LectureTopicCategory.probability) {
      return _probabilityContent(topic, course);
    }
    if (category == LectureTopicCategory.linearAlgebra) {
      return _linearAlgebraContent(topic, course);
    }
    if (category == LectureTopicCategory.differentialEquations) {
      return _differentialEquationsContent(topic, course);
    }
    if (category == LectureTopicCategory.discreteMath) {
      return _discreteContent(topic, course);
    }
    if (category == LectureTopicCategory.precalculus) {
      return _precalculusContent(topic, course);
    }
    if (category == LectureTopicCategory.calculusOther) {
      return _calculusOtherContent(topic, course);
    }
    if (category == LectureTopicCategory.chemistry) {
      return _chemistryContent(topic, course, module);
    }
    if (category == LectureTopicCategory.biology) {
      return _biologyContent(topic, course, module);
    }
    if (category == LectureTopicCategory.basicMath) {
      return _basicMathContent(topic, course, module);
    }
    return _generalContent(topic, course, module, category);
  }

  static _TopicContent _unitCircleContent(String topic, String course) {
    return _TopicContent(
      objectives: <String>[
        'Define the unit circle and locate angles in radians and degrees',
        'Read (cos θ, sin θ) as coordinates on the circle',
        'Evaluate exact trig values at π/6, π/4, π/3, and π/2',
        'Determine signs of sin and cos in each quadrant',
        'Use reference angles to find trig values in any quadrant',
      ],
      introSpeech:
          'Welcome to $course. Today we master the unit circle — the foundation of all trigonometry. '
          'Every sine and cosine value you will ever use comes from this circle of radius one centered at the origin.',
      whySpeech:
          'Before calculators, engineers and navigators memorized the unit circle. It connects angles to coordinates, '
          'powers wave models in physics, and makes solving trigonometric equations possible.',
      conceptSpeech:
          'The unit circle is the set of points (x, y) where x² + y² = 1. For any angle θ in standard position, '
          'the terminal side intersects the circle at (cos θ, sin θ). The x-coordinate is cosine; the y-coordinate is sine.',
      mainEquation: 'x² + y² = 1,  (cos θ, sin θ)',
      conceptLines: <String>[
        'Radius = 1',
        'x = cos θ',
        'y = sin θ',
        'Quadrant I: both +',
        'Quadrant II: cos −, sin +',
      ],
      visualSpeech:
          'Watch the sine wave trace values as θ moves around the circle — height on the y-axis is sin θ, '
          'horizontal position is cos θ.',
      graphFunction: 'sine',
      methodSpeech:
          'To find a trig value: (1) locate the angle on the circle, (2) identify the reference angle in quadrant I, '
          '(3) read the special value, (4) apply the quadrant sign.',
      methodLines: <String>[
        'Draw angle from positive x-axis',
        'Find reference angle',
        'Use special triangle values',
        'Apply ASTC sign rule',
      ],
      mistakesSpeech:
          'Common mistakes: swapping sin and cos, forgetting quadrant signs, using degrees when the problem uses radians.',
      mistakesLines: <String>[
        'cos is x, sin is y',
        'Check quadrant before sign',
        'Convert degrees ↔ radians carefully',
      ],
      applicationsSpeech:
          'Unit circle values appear in AC circuits, sound waves, navigation bearings, and any periodic model.',
      applicationLines: <String>['Physics waves', 'Engineering rotation', 'GPS navigation'],
      checkPrompt: 'On the unit circle, what are the coordinates at θ = π/2?',
      checkOptions: <String>['(0, 1)', '(1, 0)', '(−1, 0)', '(0, −1)'],
      checkCorrectIndex: 0,
      checkExplanation: 'At π/2 the point is at the top of the circle: x = cos(π/2) = 0, y = sin(π/2) = 1.',
      definitions: <String>[
        'Unit circle: circle with radius 1 centered at the origin.',
        'Standard position: vertex at origin, initial side on positive x-axis.',
        'Reference angle: acute angle to the x-axis in quadrant I.',
      ],
      formulas: <String>[
        'x² + y² = 1',
        'P(θ) = (cos θ, sin θ)',
        'sin²θ + cos²θ = 1',
        'π rad = 180°',
      ],
      exampleIdeas: <String>[
        'Find sin(π/6) and cos(π/6)',
        'Find coordinates at θ = 3π/4',
        'Determine quadrant of θ = 5π/6',
      ],
      commonMistakes: <String>[
        'Swapping sin and cos coordinates',
        'Wrong quadrant sign',
        'Degree/radian mix-up',
      ],
      tips: <String>['Draw the circle first', 'Memorize π/6 and π/4 values', 'Use ASTC for signs'],
      summaryLearned: <String>[
        'Unit circle definition',
        'Coordinates (cos θ, sin θ)',
        'Special angles',
        'Quadrant signs',
        'Reference angles',
      ],
      summaryApplications: <String>['Wave models', 'Rotation', 'Navigation'],
      summaryReview: <String>['Radians', 'Right triangle trig', 'Pythagorean identity'],
    );
  }

  static _TopicContent _trigonometryContent(String topic, String course, String module) {
    final String t = topic.toLowerCase();
    final String fn = t.contains('cosine')
        ? 'cosine'
        : t.contains('sine')
            ? 'sine'
            : t.contains('tangent')
                ? 'tangent'
                : 'trigonometric';
    final String eq = switch (fn) {
      'sine' => 'sin θ = opposite / hypotenuse',
      'cosine' => 'cos θ = adjacent / hypotenuse',
      'tangent' => 'tan θ = opposite / adjacent = sin θ / cos θ',
      _ => 'SOH-CAH-TOA for right triangles',
    };

    return _TopicContent(
      objectives: <String>[
        'Define $topic precisely in $course',
        'Connect $topic to the unit circle and right triangles',
        'Evaluate and interpret $fn ratios',
        'Solve representative $topic problems step by step',
      ],
      introSpeech:
          'Welcome to $course — $module. Today\'s focus is $topic and only $topic. '
          'We build from definitions through worked examples until you can solve problems independently.',
      whySpeech:
          '$topic connects geometry to measurement. Engineers use it for forces, architects for angles, '
          'and scientists for waves and periodic phenomena.',
      conceptSpeech:
          'In $topic we study how angles relate to side ratios and circle coordinates. '
          'Every formula today is about $topic — not unrelated algebra.',
      mainEquation: eq,
      conceptLines: <String>['Angle θ', 'Ratio interpretation', 'Unit circle link', 'Domain & range'],
      visualSpeech:
          'This sine graph shows how $fn values oscillate as angles increase — the shape you will analyze in $topic.',
      graphFunction: 'sine',
      methodSpeech:
          'Strategy for $topic: sketch the angle, identify opposite/adjacent/hypotenuse or circle coordinates, '
          'then apply the correct ratio or identity.',
      methodLines: <String>['Draw a diagram', 'Label sides', 'Choose correct ratio', 'Simplify exactly'],
      mistakesSpeech:
          'Watch for reciprocal confusion (sec vs cos), dividing by zero at odd multiples of π/2, and radian/degree errors.',
      mistakesLines: <String>['Label sides first', 'Check denominator ≠ 0', 'Use exact values when asked'],
      applicationsSpeech:
          '$topic appears in surveying, physics components, signal processing, and structural load analysis.',
      applicationLines: <String>['Right triangles', 'Forces on inclines', 'Periodic models'],
      checkPrompt: 'Which ratio is opposite over hypotenuse?',
      checkOptions: <String>['sin θ', 'cos θ', 'tan θ', 'cot θ'],
      checkCorrectIndex: 0,
      checkExplanation: 'SOH: sin θ = opposite / hypotenuse.',
      definitions: <String>['$topic: core ratio/identity for angle θ in $course.'],
      formulas: <String>[eq, 'sin²θ + cos²θ = 1'],
      exampleIdeas: <String>['Evaluate at a special angle', 'Find side length', 'Identify quadrant sign'],
      commonMistakes: <String>['Wrong ratio selected', 'Calculator mode error'],
      tips: <String>['Draw first', 'Link to unit circle'],
      summaryLearned: <String>['Definition of $topic', 'Key formulas', 'Worked examples'],
      summaryApplications: <String>['Triangles', 'Waves', 'Navigation'],
      summaryReview: <String>['Unit circle', 'Radians', 'Pythagorean theorem'],
    );
  }

  static _TopicContent _geometryContent(String topic, String course, String module) {
    return _TopicContent(
      objectives: <String>[
        'State definitions and theorems for $topic',
        'Draw and label accurate diagrams',
        'Prove or apply $topic in multi-step problems',
      ],
      introSpeech:
          'Welcome to $course. We study $topic in $module with complete definitions, diagrams, and proofs.',
      whySpeech:
          '$topic supports architecture, design, computer graphics, and any field requiring spatial reasoning.',
      conceptSpeech:
          '$topic is about shapes, measurements, and logical relationships. We always start with a labeled diagram.',
      mainEquation: _geometryEquation(topic),
      conceptLines: <String>['Given information', 'Theorem to apply', 'Logical chain', 'Conclusion'],
      visualSpeech: 'Observe how $topic appears in this diagram — relationships become clear when we mark equal parts.',
      graphFunction: 'linear',
      methodSpeech: 'Geometry method: draw, mark givens, choose theorem, write a justified chain of statements.',
      methodLines: <String>['Sketch & label', 'List givens', 'Pick theorem', 'Justify each step'],
      mistakesSpeech: 'Avoid assuming lines are parallel or angles equal without justification.',
      mistakesLines: <String>['No unmarked assumptions', 'State theorem used', 'Include units'],
      applicationsSpeech: '$topic is used in construction, design, maps, and robotics path planning.',
      applicationLines: <String>['Architecture', 'CAD design', 'Navigation'],
      checkPrompt: 'What should you draw first in a geometry problem?',
      checkOptions: <String>['Labeled diagram', 'Final answer', 'Calculator', 'Formula sheet only'],
      checkCorrectIndex: 0,
      checkExplanation: 'A labeled diagram clarifies givens and relationships before computing.',
      definitions: <String>['$topic: vocabulary and theorems from $module.'],
      formulas: <String>[_geometryEquation(topic)],
      exampleIdeas: <String>['Find missing angle', 'Prove congruence', 'Compute area'],
      commonMistakes: <String>['Skipping diagram', 'Unjustified steps'],
      tips: <String>['Mark equal parts', 'Name theorems explicitly'],
      summaryLearned: <String>['$topic definitions', 'Theorems', 'Worked proofs'],
      summaryApplications: <String>['Design', 'Construction'],
      summaryReview: <String>['Prior geometry topics', 'Algebra skills'],
    );
  }

  static String _geometryEquation(String topic) {
    final String t = topic.toLowerCase();
    if (t.contains('pythagorean')) return 'a² + b² = c²';
    if (t.contains('area')) return 'Area formulas depend on shape';
    if (t.contains('volume')) return 'Volume = base area × height (prisms)';
    if (t.contains('circle')) return 'C = 2πr,  A = πr²';
    return 'Theorem + givens → conclusion';
  }

  static _TopicContent _statisticsContent(String topic, String course) {
    return _TopicContent(
      objectives: <String>[
        'Define $topic and its role in data analysis',
        'Compute and interpret $topic from data sets',
        'Distinguish when $topic is appropriate',
      ],
      introSpeech: 'Welcome to $course. Today: $topic — how we summarize and interpret data responsibly.',
      whySpeech: '$topic helps turn raw data into decisions in medicine, business, and research.',
      conceptSpeech:
          'In $topic we quantify patterns. Always identify the population, sample, and what the number means in context.',
      mainEquation: _statsEquation(topic),
      conceptLines: <String>['Population vs sample', 'Center vs spread', 'Context matters'],
      visualSpeech: 'A distribution shape tells us whether mean alone is enough — always look at the data plot.',
      graphFunction: 'linear',
      methodSpeech: 'Steps: organize data, choose the correct statistic, compute carefully, interpret in context.',
      methodLines: <String>['Sort or plot data', 'Apply formula', 'Check outliers', 'Interpret'],
      mistakesSpeech: 'Do not confuse mean and median; watch for outliers and small sample sizes.',
      mistakesLines: <String>['Report units', 'Mention outliers', 'State sample size'],
      applicationsSpeech: '$topic is used in clinical trials, quality control, and survey analysis.',
      applicationLines: <String>['Medical studies', 'Manufacturing QC', 'Polling'],
      checkPrompt: 'Which measure is most affected by outliers?',
      checkOptions: <String>['Mean', 'Median', 'Mode', 'Range'],
      checkCorrectIndex: 0,
      checkExplanation: 'Extreme values pull the mean; median is more resistant.',
      definitions: <String>['$topic: statistical measure in $course.'],
      formulas: <String>[_statsEquation(topic)],
      exampleIdeas: <String>['Compute from small data set', 'Compare two groups'],
      commonMistakes: <String>['Ignoring context', 'Confusing mean/median'],
      tips: <String>['Plot first', 'Report units'],
      summaryLearned: <String>['$topic definition', 'Computation', 'Interpretation'],
      summaryApplications: <String>['Research', 'Business analytics'],
      summaryReview: <String>['Data types', 'Spread measures'],
    );
  }

  static String _statsEquation(String topic) {
    final String t = topic.toLowerCase();
    if (t.contains('variance') || t.contains('standard deviation')) return 'σ² = Σ(x−μ)²/n';
    if (t.contains('mean')) return 'x̄ = Σx / n';
    if (t.contains('regression')) return 'y = mx + b (least-squares line)';
    return 'Statistic = formula applied to data';
  }

  static _TopicContent _probabilityContent(String topic, String course) {
    return _TopicContent(
      objectives: <String>[
        'Define sample space and events for $topic',
        'Apply probability rules correctly',
        'Solve $topic problems with clear reasoning',
      ],
      introSpeech: 'Welcome to $course. $topic — quantifying uncertainty with rigorous rules.',
      whySpeech: 'Probability underlies insurance, games, machine learning, and risk assessment.',
      conceptSpeech:
          'Every probability statement needs a sample space. Events are subsets; probabilities are between 0 and 1.',
      mainEquation: 'P(A) = favorable outcomes / total outcomes (equally likely)',
      conceptLines: <String>['Sample space', 'Event', 'Complement', 'Independence'],
      visualSpeech: 'Tree diagrams and tables organize compound events so we do not double-count outcomes.',
      graphFunction: 'linear',
      methodSpeech: 'List the sample space, identify the event, apply addition or multiplication rules as appropriate.',
      methodLines: <String>['Define sample space', 'Count carefully', 'Apply rule', 'Check P ≤ 1'],
      mistakesSpeech: 'Do not add probabilities of overlapping events without inclusion–exclusion.',
      mistakesLines: <String>['Check overlap', 'Independent vs dependent', 'Conditional setup'],
      applicationsSpeech: '$topic models reliability, medical testing, and financial risk.',
      applicationLines: <String>['Insurance', 'Quality testing', 'Sports analytics'],
      checkPrompt: 'If P(A) = 0.3, what is P(not A)?',
      checkOptions: <String>['0.7', '0.3', '1.3', '0.03'],
      checkCorrectIndex: 0,
      checkExplanation: 'Complement rule: P(Aᶜ) = 1 − P(A) = 0.7.',
      definitions: <String>['$topic: probability concept in $course.'],
      formulas: <String>['P(Aᶜ) = 1 − P(A)', 'P(A ∪ B) for mutually exclusive events'],
      exampleIdeas: <String>['Coin and die problems', 'Conditional probability'],
      commonMistakes: <String>['Double counting', 'Assuming independence'],
      tips: <String>['Make a table', 'Check complements'],
      summaryLearned: <String>['$topic rules', 'Sample spaces', 'Examples'],
      summaryApplications: <String>['Risk analysis', 'Testing'],
      summaryReview: <String>['Counting', 'Sets'],
    );
  }

  static _TopicContent _linearAlgebraContent(String topic, String course) {
    return _TopicContent(
      objectives: <String>[
        'Define $topic in vector/matrix language',
        'Perform $topic computations step by step',
        'Interpret results geometrically when possible',
      ],
      introSpeech: 'Welcome to $course. $topic — the language of multivariable systems.',
      whySpeech: 'Linear algebra powers graphics, machine learning, and engineering systems.',
      conceptSpeech: 'Vectors represent direction and magnitude; matrices encode linear transformations and systems.',
      mainEquation: 'Ax = b  (matrix equation)',
      conceptLines: <String>['Vectors', 'Matrices', 'Linear combinations', 'Solutions'],
      visualSpeech: 'Rows and columns organize coefficients so elimination stays systematic.',
      graphFunction: 'linear',
      methodSpeech: 'Write the augmented matrix, use row operations, back-substitute, interpret the solution set.',
      methodLines: <String>['Set up matrix', 'Row reduce', 'Identify pivots', 'State solution'],
      mistakesSpeech: 'Dimension mismatch breaks matrix multiplication — always check sizes.',
      mistakesLines: <String>['Check dimensions', 'Track row ops', 'Free vs leading variables'],
      applicationsSpeech: '$topic appears in 3D graphics, network flows, and data compression.',
      applicationLines: <String>['Computer graphics', 'Networks', 'Data science'],
      checkPrompt: 'What does a pivot position indicate?',
      checkOptions: <String>['Leading variable', 'Free variable always', 'No solution', 'Zero row only'],
      checkCorrectIndex: 0,
      checkExplanation: 'A pivot marks a leading variable in row-echelon form.',
      definitions: <String>['$topic: linear algebra concept.'],
      formulas: <String>['Ax = b', 'Row operation rules'],
      exampleIdeas: <String>['Solve 2×2 system', 'Compute determinant'],
      commonMistakes: <String>['Dimension errors', 'Arithmetic slips in elimination'],
      tips: <String>['Align columns', 'Check with substitution'],
      summaryLearned: <String>[topic, 'Matrix methods', 'Examples'],
      summaryApplications: <String>['Graphics', 'ML pipelines'],
      summaryReview: <String>['Systems of equations', 'Vectors'],
    );
  }

  static _TopicContent _differentialEquationsContent(String topic, String course) {
    return _TopicContent(
      objectives: <String>[
        'Classify the type of $topic',
        'Solve standard $topic forms step by step',
        'Interpret solutions in context',
      ],
      introSpeech: 'Welcome to $course. $topic — modeling rates of change with differential equations.',
      whySpeech: 'Populations, circuits, and motion are modeled with derivatives — not just algebra.',
      conceptSpeech:
          'A differential equation relates a function to its derivatives. Classification determines the solution method.',
      mainEquation: 'dy/dx = f(x, y)',
      conceptLines: <String>['Order', 'Linearity', 'Initial conditions', 'General vs particular'],
      visualSpeech: 'Slope fields preview solution behavior before we find an explicit formula.',
      graphFunction: 'linear',
      methodSpeech: 'Identify the DE type, apply the matching technique (separation, integrating factor, etc.), apply ICs.',
      methodLines: <String>['Classify DE', 'Choose method', 'Integrate', 'Apply initial condition'],
      mistakesSpeech: 'Losing the +C constant or misapplying separation when variables are not separable.',
      mistakesLines: <String>['Include +C', 'Check domain', 'Verify by substitution'],
      applicationsSpeech: '$topic models cooling, radioactive decay, spring motion, and population growth.',
      applicationLines: <String>['Physics', 'Biology', 'Engineering'],
      checkPrompt: 'What does an initial condition specify?',
      checkOptions: <String>['A point on the solution curve', 'The slope field only', 'The general +C', 'The domain only'],
      checkCorrectIndex: 0,
      checkExplanation: 'Initial conditions pick the particular solution through a given point.',
      definitions: <String>['$topic: differential equation type in $course.'],
      formulas: <String>['dy/dx = f(x,y)', 'Separation: ∫g(y)dy = ∫f(x)dx'],
      exampleIdeas: <String>['Separable example', 'First-order linear'],
      commonMistakes: <String>['Wrong classification', 'Missing +C'],
      tips: <String>['Verify by differentiation', 'Sketch slope field'],
      summaryLearned: <String>['$topic classification', 'Solution method', 'Applications'],
      summaryApplications: <String>['Modeling change'],
      summaryReview: <String>['Integration', 'Derivatives'],
    );
  }

  static _TopicContent _discreteContent(String topic, String course) {
    return _TopicContent(
      objectives: <String>[
        'State formal definitions for $topic',
        'Construct proofs or structures for $topic',
        'Apply $topic in counting or algorithm contexts',
      ],
      introSpeech: 'Welcome to $course. $topic — rigorous reasoning about finite structures.',
      whySpeech: 'Logic and counting underpin computer science, cryptography, and combinatorics.',
      conceptSpeech: '$topic uses precise definitions. Every claim needs a justified argument.',
      mainEquation: _discreteEquation(topic),
      conceptLines: <String>['Definitions', 'Proof strategy', 'Structure', 'Conclusion'],
      visualSpeech: 'Tables and trees organize cases so we do not miss possibilities in counting.',
      graphFunction: 'linear',
      methodSpeech: 'State definitions, choose proof method (direct, contrapositive, induction), write clearly.',
      methodLines: <String>['Define terms', 'Pick proof type', 'Write steps', 'Conclude'],
      mistakesSpeech: 'Induction requires a valid base case AND a correct inductive step.',
      mistakesLines: <String>['Check base case', 'Assume IH correctly', 'Count without duplication'],
      applicationsSpeech: '$topic supports algorithms, networks, and secure communication.',
      applicationLines: <String>['Algorithms', 'Cryptography', 'Networks'],
      checkPrompt: 'Proof by induction requires which two parts?',
      checkOptions: <String>['Base case and inductive step', 'Only base case', 'Only inductive step', 'Contradiction only'],
      checkCorrectIndex: 0,
      checkExplanation: 'Both the base case and inductive step are required.',
      definitions: <String>['$topic: discrete mathematics concept.'],
      formulas: <String>[_discreteEquation(topic)],
      exampleIdeas: <String>['Small counting problem', 'Short proof'],
      commonMistakes: <String>['Incomplete induction', 'Double counting'],
      tips: <String>['Write what you assume', 'Check small cases'],
      summaryLearned: <String>['$topic definitions', 'Proofs', 'Examples'],
      summaryApplications: <String>['CS foundations'],
      summaryReview: <String>['Logic', 'Sets'],
    );
  }

  static String _discreteEquation(String topic) {
    final String t = topic.toLowerCase();
    if (t.contains('counting') || t.contains('permutation')) return 'nPr = n!/(n−r)!';
    if (t.contains('combination')) return 'nCr = n!/(r!(n−r)!)';
    if (t.contains('induction')) return 'P(1) true, P(k)⇒P(k+1) ⇒ P(n) ∀n';
    return 'Precise definition → logical conclusion';
  }

  static _TopicContent _precalculusContent(String topic, String course) {
    final String t = topic.toLowerCase();
    final String graph = t.contains('logarithm') || t.contains('exponential')
        ? 'reciprocal'
        : t.contains('trig') || t.contains('sin')
            ? 'sine'
            : 'quadratic';
    return _TopicContent(
      objectives: <String>[
        'Define $topic and its key properties',
        'Graph and analyze $topic',
        'Solve $topic problems algebraically',
      ],
      introSpeech: 'Welcome to $course. $topic prepares you for calculus — definitions, graphs, and manipulation.',
      whySpeech: '$topic appears throughout calculus, modeling, and engineering functions.',
      conceptSpeech: 'We connect tables, graphs, and formulas. Domain and range guide every solution.',
      mainEquation: _precalcEquation(topic),
      conceptLines: <String>['Domain', 'Range', 'Transformations', 'Key points'],
      visualSpeech: 'The graph reveals zeros, asymptotes, and end behavior — always sketch when possible.',
      graphFunction: graph,
      methodSpeech: 'Identify the function family, use its properties, solve step by step, verify graphically.',
      methodLines: <String>['Classify function', 'Apply properties', 'Solve', 'Verify on graph'],
      mistakesSpeech: 'Domain restrictions matter especially for logs, rationals, and even roots.',
      mistakesLines: <String>['State domain', 'Check extraneous solutions', 'Use inverse correctly'],
      applicationsSpeech: '$topic models growth, decay, motion, and optimization previews.',
      applicationLines: <String>['Population models', 'Finance', 'Physics previews'],
      checkPrompt: 'Before solving, what should you identify first?',
      checkOptions: <String>['Domain and function type', 'Final decimal only', 'Calculator brand', 'Homework due date'],
      checkCorrectIndex: 0,
      checkExplanation: 'Function type and domain determine valid steps.',
      definitions: <String>['$topic: precalculus function/concept.'],
      formulas: <String>[_precalcEquation(topic)],
      exampleIdeas: <String>['Evaluate at a point', 'Find inverse', 'Graph transformation'],
      commonMistakes: <String>['Domain ignored', 'Log laws misapplied'],
      tips: <String>['Sketch quick graph', 'Check domain'],
      summaryLearned: <String>['$topic properties', 'Graphs', 'Examples'],
      summaryApplications: <String>['Calculus prep'],
      summaryReview: <String>['Algebra', 'Function notation'],
    );
  }

  static String _precalcEquation(String topic) {
    final String t = topic.toLowerCase();
    if (t.contains('exponential')) return 'f(x) = a·bˣ';
    if (t.contains('logarithm')) return 'log_b(x) = y ⇔ bʸ = x';
    if (t.contains('polynomial')) return 'f(x) = a_n xⁿ + … + a₀';
    if (t.contains('rational')) return 'f(x) = p(x)/q(x)';
    return 'f(x) with domain restrictions';
  }

  static _TopicContent _calculusOtherContent(String topic, String course) {
    return _TopicContent(
      objectives: <String>[
        'Explain $topic in calculus terms',
        'Apply $topic to functions and models',
        'Work exam-style $topic problems',
      ],
      introSpeech: 'Welcome to $course. Complete lecture on $topic — theory, visuals, and guided examples.',
      whySpeech: '$topic connects derivatives and integrals to real optimization and motion problems.',
      conceptSpeech: 'Calculus tools let us analyze change, area, and accumulation — $topic is one essential piece.',
      mainEquation: 'Calculus tools: limits, derivatives, integrals',
      conceptLines: <String>['Setup', 'Apply theorem', 'Interpret', 'Verify'],
      visualSpeech: 'Graph behavior confirms whether your calculus setup matches the problem scenario.',
      graphFunction: 'quadratic',
      methodSpeech: 'Translate the word problem, differentiate or integrate as needed, interpret units.',
      methodLines: <String>['Define variables', 'Write equation', 'Differentiate/integrate', 'Interpret'],
      mistakesSpeech: 'Units and domain restrictions break models if ignored after differentiation.',
      mistakesLines: <String>['Check units', 'Verify critical points', 'Test endpoints'],
      applicationsSpeech: '$topic is used in economics marginals, physics motion, and engineering design.',
      applicationLines: <String>['Optimization', 'Related rates', 'Motion'],
      checkPrompt: 'Critical points occur where…',
      checkOptions: <String>["f′(x) = 0 or undefined", 'f(x) = 0 always', 'f″(x) > 0 always', 'x = 0 only'],
      checkCorrectIndex: 0,
      checkExplanation: 'Critical points are where the derivative is zero or undefined (in the interior).',
      definitions: <String>['$topic: calculus application/concept.'],
      formulas: <String>['Depends on $topic — see notes'],
      exampleIdeas: <String>['Optimization word problem', 'Motion analysis'],
      commonMistakes: <String>['Forgot chain rule', 'Ignored domain'],
      tips: <String>['Draw diagram', 'Check second derivative test'],
      summaryLearned: <String>['$topic method', 'Examples'],
      summaryApplications: <String>['Science & engineering'],
      summaryReview: <String>['Derivatives', 'Integrals'],
    );
  }

  static _TopicContent _basicMathContent(String topic, String course, String module) {
    final String t = topic.toLowerCase();
    if (t.contains('natural number')) {
      return _numberSetContent(
        topic: topic,
        course: course,
        module: module,
        symbol: 'ℕ',
        meaning:
            'Natural numbers are the counting numbers: 1, 2, 3, … (some texts also include 0). '
            'They answer “how many?” for whole objects — people, books, steps.',
        equation: 'ℕ = {1, 2, 3, …}  (or {0, 1, 2, …})',
        lines: <String>[
          'Counting: 1, 2, 3, …',
          'Closed under + and ×',
          'Not closed under − or ÷',
          'ℕ ⊂ ℤ ⊂ ℚ ⊂ ℝ',
        ],
        examples: <String>[
          'Counting students in a classroom',
          'Page numbers in a book',
          'Steps on a staircase',
        ],
        checkPrompt: 'Which is always a natural number (in the usual counting definition)?',
        checkOptions: <String>['7', '−3', '1/2', '√2'],
        checkCorrectIndex: 0,
        checkExplanation: '7 is a positive counting number. Negatives, fractions, and irrationals are not natural.',
      );
    }
    if (t.contains('whole number')) {
      return _numberSetContent(
        topic: topic,
        course: course,
        module: module,
        symbol: 'ℤ⁺₀ / wholes',
        meaning:
            'Whole numbers are 0, 1, 2, 3, … — natural numbers with zero included. '
            'Zero matters: it means “none,” and it is the identity for addition.',
        equation: 'Whole numbers = {0, 1, 2, 3, …}',
        lines: <String>['Includes 0', 'No negatives', 'No fractions', 'Used for counts & empty sets'],
        examples: <String>['Zero apples left', 'House numbers', 'Scores that can be zero'],
        checkPrompt: 'What do whole numbers add that some definitions of natural numbers omit?',
        checkOptions: <String>['Zero', 'Negatives', 'Fractions', 'Decimals'],
        checkCorrectIndex: 0,
        checkExplanation: 'Whole numbers always include 0.',
      );
    }
    if (t.contains('integer')) {
      return _numberSetContent(
        topic: topic,
        course: course,
        module: module,
        symbol: 'ℤ',
        meaning:
            'Integers are …, −2, −1, 0, 1, 2, … — whole numbers extended with negatives. '
            'They model direction: debt vs savings, left vs right on a number line.',
        equation: 'ℤ = {…, −2, −1, 0, 1, 2, …}',
        lines: <String>['Negatives included', 'Closed under + and −', 'Number line both ways', 'ℕ ⊂ ℤ'],
        examples: <String>['Bank balance', 'Temperature below zero', 'Floors below ground'],
        checkPrompt: 'Which number is an integer but not a whole number?',
        checkOptions: <String>['−4', '0', '3', '1/2'],
        checkCorrectIndex: 0,
        checkExplanation: '−4 is an integer; whole numbers stop at zero and go up.',
      );
    }
    if (t.contains('rational')) {
      return _numberSetContent(
        topic: topic,
        course: course,
        module: module,
        symbol: 'ℚ',
        meaning:
            'Rational numbers are ratios of integers a/b with b ≠ 0. '
            'Decimals either terminate or repeat. Fractions, integers, and many decimals live here.',
        equation: 'ℚ = { a/b | a, b ∈ ℤ, b ≠ 0 }',
        lines: <String>['Fraction form', 'b ≠ 0', 'Terminate or repeat', 'ℤ ⊂ ℚ'],
        examples: <String>['Half a pizza (1/2)', 'Money \$0.25', '3 = 3/1'],
        checkPrompt: 'Which is rational?',
        checkOptions: <String>['2/5', '√2', 'π', '√3'],
        checkCorrectIndex: 0,
        checkExplanation: '2/5 is a ratio of integers. √2 and π are irrational.',
      );
    }
    if (t.contains('real number') || t == 'reals') {
      return _numberSetContent(
        topic: topic,
        course: course,
        module: module,
        symbol: 'ℝ',
        meaning:
            'Real numbers fill the entire number line: rationals plus irrationals like √2 and π. '
            'Every point on the continuous line is a real number.',
        equation: 'ℝ = ℚ ∪ {irrationals}',
        lines: <String>['Entire number line', 'Includes √2, π', 'ℚ ⊂ ℝ', 'No imaginary part'],
        examples: <String>['Exact circle circumference involves π', 'Diagonal of unit square = √2', 'Any thermometer reading'],
        checkPrompt: 'Which is real but not rational?',
        checkOptions: <String>['√2', '3/4', '−7', '0.5'],
        checkCorrectIndex: 0,
        checkExplanation: '√2 cannot be written as a/b with integers a, b ≠ 0.',
      );
    }

    return _TopicContent(
      objectives: <String>[
        'Understand $topic concretely and symbolically',
        'Perform $topic operations accurately',
        'Apply $topic to word problems',
      ],
      introSpeech: 'Welcome to $course — $module. Today we master $topic from intuition through practice.',
      whySpeech: '$topic builds the number sense used in every later math course and daily finance.',
      conceptSpeech: '$topic connects concrete models to symbols. We move carefully from meaning to notation.',
      mainEquation: _basicEquation(topic),
      conceptLines: <String>['Concrete model', 'Symbol rule', 'Worked example', 'Check reasonableness'],
      visualSpeech: 'Number lines and area models make $topic tangible before we abstract.',
      graphFunction: 'linear',
      methodSpeech: 'Identify the operation, apply the rule step by step, estimate to verify reasonableness.',
      methodLines: <String>['Read carefully', 'Choose operation', 'Compute', 'Estimate check'],
      mistakesSpeech: 'Sign errors and order-of-operations mistakes dominate — write each step.',
      mistakesLines: <String>['Track signs', 'PEMDAS order', 'Include units'],
      applicationsSpeech: '$topic appears in budgeting, measurement, and science calculations.',
      applicationLines: <String>['Finance', 'Measurement', 'Science units'],
      checkPrompt: 'Before calculating, what helps catch errors?',
      checkOptions: <String>['Estimate reasonableness', 'Skip steps', 'Guess', 'Only use calculator'],
      checkCorrectIndex: 0,
      checkExplanation: 'An estimate tells you if the final answer is in the right ballpark.',
      definitions: <String>['$topic: foundational concept in $module.'],
      formulas: <String>[_basicEquation(topic)],
      exampleIdeas: <String>['Compute', 'Word problem', 'Compare quantities'],
      commonMistakes: <String>['Sign errors', 'Operation choice'],
      tips: <String>['Draw a model', 'Estimate first'],
      summaryLearned: <String>['$topic meaning', 'Rules', 'Examples'],
      summaryApplications: <String>['Daily math', 'Finance'],
      summaryReview: <String>['Prior number skills'],
    );
  }

  static _TopicContent _numberSetContent({
    required String topic,
    required String course,
    required String module,
    required String symbol,
    required String meaning,
    required String equation,
    required List<String> lines,
    required List<String> examples,
    required String checkPrompt,
    required List<String> checkOptions,
    required int checkCorrectIndex,
    required String checkExplanation,
  }) {
    return _TopicContent(
      objectives: <String>[
        'Define $topic precisely and recognize $symbol notation',
        'Place examples of $topic on the number line',
        'Compare $topic to neighboring number sets',
        'Apply $topic in counting and measurement contexts',
      ],
      introSpeech:
          'Welcome to $course — $module. Today’s full lecture is only about $topic. '
          'We will define $topic, write it with $symbol, place examples on the number line, '
          'compare it to other number sets, and practice until the idea is rock solid.',
      whySpeech:
          'Why $topic matters: every later math idea — equations, fractions, algebra, calculus — '
          'stands on knowing which numbers you are allowed to use. Misnaming $topic causes exam errors.',
      conceptSpeech: meaning,
      mainEquation: equation,
      conceptLines: lines,
      visualSpeech:
          'On the board I draw a number line and mark only the values that belong to $topic. '
          'If a point is not in $topic, we do not mark it as a member.',
      graphFunction: 'linear',
      methodSpeech:
          'To decide if a value belongs to $topic: (1) recall the definition, (2) check against $symbol, '
          '(3) place it on the number line, (4) say yes or no with a reason.',
      methodLines: <String>[
        'Recall definition of $topic',
        'Check membership in $symbol',
        'Place on number line',
        'Justify yes/no',
      ],
      mistakesSpeech:
          'Common mistakes with $topic: mixing it up with a different number set, forgetting edge cases '
          '(like zero), or treating a fraction as a counting number.',
      mistakesLines: <String>[
        'Wrong set membership',
        'Forgetting zero when it matters',
        'Calling a fraction a counting number',
      ],
      applicationsSpeech:
          'Real uses of $topic: ${examples.join('; ')}. Each example should make you ask: '
          'is this quantity actually in $topic?',
      applicationLines: examples,
      checkPrompt: checkPrompt,
      checkOptions: checkOptions,
      checkCorrectIndex: checkCorrectIndex,
      checkExplanation: checkExplanation,
      definitions: <String>['$topic ($symbol): $meaning'],
      formulas: <String>[equation],
      exampleIdeas: examples,
      commonMistakes: <String>['Confusing number sets', 'Skipping the definition'],
      tips: <String>['Say the definition aloud', 'Use the number line'],
      summaryLearned: <String>['Definition of $topic', '$symbol notation', 'Membership tests'],
      summaryApplications: examples,
      summaryReview: <String>['Counting', 'Number line', 'Neighboring sets'],
    );
  }

  static String _basicEquation(String topic) {
    final String t = topic.toLowerCase();
    if (t.contains('percent')) return 'part = (percent/100) × whole';
    if (t.contains('fraction')) return 'a/b + c/d → common denominator';
    if (t.contains('natural number')) return 'ℕ = {1, 2, 3, …}';
    if (t.contains('whole number')) return 'Whole = {0, 1, 2, 3, …}';
    if (t.contains('integer')) return 'ℤ = {…, −2, −1, 0, 1, 2, …}';
    if (t.contains('rational')) return 'ℚ = { a/b | a, b ∈ ℤ, b ≠ 0 }';
    if (t.contains('real number')) return 'ℝ = all points on the number line';
    if (t.contains('number')) return 'Number sets: ℕ ⊂ ℤ ⊂ ℚ ⊂ ℝ';
    return 'Definition & rules for $topic';
  }

  static _TopicContent _chemistryContent(String topic, String course, String module) {
    return _TopicContent(
      objectives: <String>[
        'Explain $topic at the particulate level — atoms, bonds, electrons',
        'Connect $topic to laboratory observations and safety',
        'Predict reaction outcomes and balance related equations',
        'Apply $topic to real-world industrial and biological contexts',
      ],
      introSpeech:
          'Welcome to the chemistry laboratory. Today we study $topic in $course. '
          'Before we write a single formula, let me ask: why does this process happen at all? '
          'Atoms seek lower energy. Watch the board — nothing appears instantly; we build every structure step by step.',
      whySpeech:
          '$topic explains what you observe in the lab — color changes, gas evolution, heat, pH shifts. '
          'Industry, medicine, and environmental science all depend on mastering this concept.',
      conceptSpeech:
          'Core model for $topic: identify species, track electron movement, note bond breaking and formation, '
          'and relate macroscopic data to the particulate picture.',
      mainEquation: 'Balanced equation for a representative $topic process',
      conceptLines: <String>[
        'Particulate model',
        'Electron movement',
        'Energy change',
        'Lab observation',
      ],
      visualSpeech:
          'Watch the animation: reactants approach, bonds weaken, new bonds form, products appear. '
          'I will pause after each electron shift so you can predict the next step.',
      graphFunction: 'linear',
      methodSpeech:
          'Problem method for $topic: (1) write the balanced equation, (2) identify reaction type, '
          '(3) apply mole ratios or equilibrium reasoning, (4) verify with units and significant figures.',
      methodLines: <String>[
        'Balance & classify',
        'Draw electron movement',
        'Calculate with units',
        'Check lab safety',
      ],
      mistakesSpeech:
          'Common errors: skipping Lewis structures, confusing coefficients with subscripts, '
          'ignoring state symbols, or mixing up kinetics and equilibrium.',
      mistakesLines: <String>[
        'Show electron arrows',
        'Balance last atom (H, O)',
        'Include states (s, l, g, aq)',
      ],
      applicationsSpeech:
          '$topic appears in synthesis routes, analytical tests, environmental monitoring, and pharmaceutical manufacturing.',
      applicationLines: <String>['Industrial scale-up', 'Green chemistry', 'Clinical diagnostics'],
      checkPrompt: 'What should you identify before mixing reagents in a $topic experiment?',
      checkOptions: <String>[
        'Hazards, PPE, and balanced plan',
        'Final color only',
        'Skip safety for speed',
        'Guess products',
      ],
      checkCorrectIndex: 0,
      checkExplanation: 'Laboratory safety and a clear reaction plan come first — always.',
      definitions: <String>[
        '$topic: central concept in $module ($course).',
        'Particulate model: explains macroscopic observations using atoms and molecules.',
      ],
      formulas: <String>['Key stoichiometric and equilibrium relationships for $topic'],
      exampleIdeas: <String>[
        'Micro-scale electron movement demo',
        'Quantitative lab calculation',
        'Industrial case study',
      ],
      commonMistakes: <String>['Unbalanced equations', 'Missing safety step', 'Wrong reaction type'],
      tips: <String>['Build visuals while reasoning', 'Pause and predict each step'],
      summaryLearned: <String>['$topic theory', 'Lab connection', 'Worked examples'],
      summaryApplications: <String>['Real-world chemistry applications'],
      summaryReview: <String>['Prerequisites from $module', 'Safety checklist'],
    );
  }

  static _TopicContent _biologyContent(String topic, String course, String module) {
    return _TopicContent(
      objectives: <String>[
        'Define $topic and place it in the hierarchy of life',
        'Explain the mechanism of $topic with labeled structures',
        'Connect $topic to laboratory observation and clinical or ecological cases',
        'Predict what happens when $topic fails',
      ],
      introSpeech:
          'Welcome to the biology lecture hall. Today we study $topic in $course. '
          'Imagine we are not reading a page — we are zooming into living systems. '
          'I will draw, animate, pause for your predictions, and build every idea while we speak.',
      whySpeech:
          '$topic matters because living systems depend on structure meeting function. '
          'When you understand $topic, you can diagnose patients, design experiments, and explain ecosystems.',
      conceptSpeech:
          'Core model for $topic: name the structures, track the process step by step, '
          'note regulation, then connect molecular change to organism or population outcomes.',
      mainEquation: 'Process map for $topic (structure → function → consequence)',
      conceptLines: <String>['Structures', 'Mechanism steps', 'Regulation', 'Failure modes'],
      visualSpeech:
          'Watch the animation: we zoom in, structures appear, processes run, then we pause — '
          'what happens next? Predict before the next frame.',
      graphFunction: 'linear',
      methodSpeech:
          'Approach for $topic: (1) identify the scale, (2) draw and label, (3) sequence the mechanism, '
          '(4) check with a lab or clinical case.',
      methodLines: <String>['Scale & system', 'Draw & label', 'Sequence steps', 'Apply to a case'],
      mistakesSpeech:
          'Common biology mistakes: mixing DNA/RNA/protein roles, forgetting feedback control, '
          'or jumping levels of organization without saying so.',
      mistakesLines: <String>['Keep scale clear', 'Label every diagram', 'State cause carefully'],
      applicationsSpeech:
          '$topic appears in medicine, biotechnology, agriculture, and conservation research.',
      applicationLines: <String>['Clinical cases', 'Lab techniques', 'Ecology & biotech'],
      checkPrompt: 'Before explaining $topic in depth, what should you do first?',
      checkOptions: <String>[
        'Define the system and draw labeled structures',
        'Jump to treatment options',
        'Memorize one word definition only',
        'Skip diagrams',
      ],
      checkCorrectIndex: 0,
      checkExplanation: 'Clear definitions and labeled structures unlock mechanism and application.',
      definitions: <String>['$topic: key concept in $module ($course).'],
      formulas: <String>['Governing relationships and pathways for $topic'],
      exampleIdeas: <String>['Structure/function demo', 'Process animation', 'Clinical or ecology case'],
      commonMistakes: <String>['Wrong scale', 'Missing labels', 'Confusing similar processes'],
      tips: <String>['Zoom then zoom out', 'Pause and predict'],
      summaryLearned: <String>['$topic structures', 'Mechanism', 'Applications'],
      summaryApplications: <String>['$course applications'],
      summaryReview: <String>['Prerequisites from $module'],
    );
  }

  static _TopicContent _generalContent(
    String topic,
    String course,
    String module,
    LectureTopicCategory category,
  ) {
    return _TopicContent(
      objectives: <String>[
        'Define $topic clearly in $course',
        'Explain why $topic matters in $module',
        'Solve $topic problems with full solutions',
      ],
      introSpeech:
          'Welcome to $course — $module. This entire lecture is about $topic only. '
          'We will not drift to unrelated topics.',
      whySpeech: '$topic connects theory to practice in $course and appears on exams and applications.',
      conceptSpeech:
          'Core idea of $topic: precise definitions first, then notation, then worked examples tied directly to $topic.',
      mainEquation: 'Key relationship for $topic',
      conceptLines: <String>['Definition', 'Notation', 'Method', 'Check'],
      visualSpeech: 'Visualization clarifies $topic — observe how the model behaves before computing.',
      graphFunction: 'linear',
      methodSpeech: 'Problem-solving for $topic: identify givens, select the method from today\'s lesson, verify.',
      methodLines: <String>['Givens & goal', 'Method from $topic', 'Compute', 'Verify'],
      mistakesSpeech: 'The biggest mistake is applying a method from a different topic — stay with $topic tools.',
      mistakesLines: <String>['Match method to topic', 'Show steps', 'Verify answer'],
      applicationsSpeech: '$topic has direct applications in $course and related fields.',
      applicationLines: <String>['Course applications', 'Exam skills', 'Real models'],
      checkPrompt: 'Which step comes first when solving a $topic problem?',
      checkOptions: <String>['Identify givens and goal', 'Write the final answer', 'Pick random formula', 'Skip diagram'],
      checkCorrectIndex: 0,
      checkExplanation: 'Always clarify what is given and what $topic asks you to find.',
      definitions: <String>['$topic: central concept in $module ($course).'],
      formulas: <String>['Primary formulas for $topic — see smart notes'],
      exampleIdeas: <String>['Easy $topic example', 'Medium example', 'Hard exam-style'],
      commonMistakes: <String>['Using wrong topic\'s method', 'Skipping justification'],
      tips: <String>['Stay on $topic', 'Write every step'],
      summaryLearned: <String>['$topic definitions', 'Methods', 'Examples'],
      summaryApplications: <String>['$course applications'],
      summaryReview: <String>['Prerequisites from $module'],
    );
  }
}

class _TopicContent {
  const _TopicContent({
    required this.objectives,
    required this.introSpeech,
    required this.whySpeech,
    required this.conceptSpeech,
    required this.mainEquation,
    required this.conceptLines,
    required this.visualSpeech,
    required this.graphFunction,
    required this.methodSpeech,
    required this.methodLines,
    required this.mistakesSpeech,
    required this.mistakesLines,
    required this.applicationsSpeech,
    required this.applicationLines,
    required this.checkPrompt,
    required this.checkOptions,
    required this.checkCorrectIndex,
    required this.checkExplanation,
    required this.definitions,
    required this.formulas,
    required this.exampleIdeas,
    required this.commonMistakes,
    required this.tips,
    required this.summaryLearned,
    required this.summaryApplications,
    required this.summaryReview,
  });

  final List<String> objectives;
  final String introSpeech;
  final String whySpeech;
  final String conceptSpeech;
  final String mainEquation;
  final List<String> conceptLines;
  final String visualSpeech;
  final String graphFunction;
  final String methodSpeech;
  final List<String> methodLines;
  final String mistakesSpeech;
  final List<String> mistakesLines;
  final String applicationsSpeech;
  final List<String> applicationLines;
  final String checkPrompt;
  final List<String> checkOptions;
  final int checkCorrectIndex;
  final String checkExplanation;
  final List<String> definitions;
  final List<String> formulas;
  final List<String> exampleIdeas;
  final List<String> commonMistakes;
  final List<String> tips;
  final List<String> summaryLearned;
  final List<String> summaryApplications;
  final List<String> summaryReview;
}
