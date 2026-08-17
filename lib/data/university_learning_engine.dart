/// Virtual University — lecture + lab architecture (final product spec).
library;

import '../vu_v2/labs/career_practice_labs.dart';

/// Canonical learning loop for every course.
enum UniversityLearningPhase {
  classroom,
  interactiveLecture,
  practice,
  lab,
  assessment,
  simulation,
  debrief,
  mastery,
}

/// Teaching modes the AI Professor can switch between during a lecture.
enum UniversityTeachingMode {
  lecture,
  socratic,
  demonstration,
  data,
  problem,
  discussion,
  experimentPrep,
  review,
}

/// Subject-specific professor behavior.
class UniversityProfessorStyle {
  const UniversityProfessorStyle({
    required this.title,
    required this.openerTone,
    required this.questionStyle,
    required this.feedbackCorrect,
    required this.feedbackPartial,
    required this.feedbackIncorrect,
  });

  final String title;
  final String openerTone;
  final String questionStyle;
  final String feedbackCorrect;
  final String feedbackPartial;
  final String feedbackIncorrect;

  static UniversityProfessorStyle forSubject(String subjectId) {
    final String s = subjectId.toLowerCase();
    if (s.contains('biology') || s == 'biology') {
      return const UniversityProfessorStyle(
        title: 'AI Biology Professor',
        openerTone: 'observational, scientific, and visual',
        questionStyle:
            'Look carefully at the structure I\'m highlighting. What do you think this is?',
        feedbackCorrect: 'Exactly. Now tell me why this structure matters clinically.',
        feedbackPartial:
            'You\'re thinking in the right direction, but there\'s an important distinction...',
        feedbackIncorrect:
            'Let\'s slow down. Your answer suggests a different process — let\'s compare the two.',
      );
    }
    if (s.contains('chem')) {
      return const UniversityProfessorStyle(
        title: 'AI Chemistry Professor',
        openerTone: 'precise, experimental, and calculation-focused',
        questionStyle: 'What variable would you control first in this reaction?',
        feedbackCorrect: 'Correct. That matches the expected stoichiometry.',
        feedbackPartial: 'Close — check your units and significant figures.',
        feedbackIncorrect: 'Review the balanced equation before we continue.',
      );
    }
    if (s.contains('phys')) {
      return const UniversityProfessorStyle(
        title: 'AI Physics Professor',
        openerTone: 'mathematical, conceptual, and experiment-focused',
        questionStyle: 'Predict the outcome before we run the demonstration.',
        feedbackCorrect: 'Good — your prediction matches the model.',
        feedbackPartial: 'Your setup is right; reconsider the sign of the force.',
        feedbackIncorrect: 'Let\'s draw a free-body diagram together.',
      );
    }
    if (s.contains('math')) {
      return const UniversityProfessorStyle(
        title: 'AI Mathematics Professor',
        openerTone: 'step-by-step, patient, and problem-solving focused',
        questionStyle: 'What is the first step you would take to solve this?',
        feedbackCorrect: 'Exactly. Now justify each algebraic move.',
        feedbackPartial: 'Good start — finish simplifying before moving on.',
        feedbackIncorrect: 'Let\'s identify what we know and what we need to find.',
      );
    }
    if (s.contains('law')) {
      return const UniversityProfessorStyle(
        title: 'AI Law Professor',
        openerTone: 'case-based, argumentative, and Socratic',
        questionStyle: 'Which facts in this record are legally relevant?',
        feedbackCorrect: 'Strong issue spotting. Now state the applicable rule.',
        feedbackPartial: 'You identified a fact — now connect it to the legal issue.',
        feedbackIncorrect: 'Separate facts from conclusions before arguing.',
      );
    }
    if (s.contains('nurs') || s.contains('medicine') || s.contains('health')) {
      return const UniversityProfessorStyle(
        title: 'AI Clinical Professor',
        openerTone: 'clinical reasoning and patient-centered',
        questionStyle: 'Given these findings, what would you assess first?',
        feedbackCorrect: 'Exactly. That prioritization protects the patient.',
        feedbackPartial: 'Consider airway, breathing, circulation before that step.',
        feedbackIncorrect:
            'In the emergency department, we reason from anatomy to action — try again.',
      );
    }
    if (s.contains('business') ||
        s.contains('finance') ||
        s.contains('account') ||
        s.contains('market') ||
        s.contains('econ')) {
      return const UniversityProfessorStyle(
        title: 'AI Business Professor',
        openerTone: 'case-study driven and decision-focused',
        questionStyle: 'What evidence in the case supports your recommendation?',
        feedbackCorrect: 'Solid analysis. Now consider the downside risk.',
        feedbackPartial: 'You named a metric — connect it to the strategic choice.',
        feedbackIncorrect: 'Return to the financial statements before deciding.',
      );
    }
    if (s.contains('computer') || s.contains('cs') || s.contains('software')) {
      return const UniversityProfessorStyle(
        title: 'AI CS Professor',
        openerTone: 'technical, practical, and code-oriented',
        questionStyle: 'What would this algorithm do on the input I highlighted?',
        feedbackCorrect: 'Correct. Trace one more iteration to be sure.',
        feedbackPartial: 'Your logic is close — check the boundary condition.',
        feedbackIncorrect: 'Walk through the pseudocode line by line.',
      );
    }
    if (s.contains('psych')) {
      return const UniversityProfessorStyle(
        title: 'AI Psychology Professor',
        openerTone: 'case-based and analytical',
        questionStyle: 'What behavior in this case illustrates the concept?',
        feedbackCorrect: 'Exactly. Now name the mechanism behind it.',
        feedbackPartial: 'You described behavior — link it to the theory.',
        feedbackIncorrect: 'Distinguish correlation from causation here.',
      );
    }
    if (s.contains('engineer')) {
      return const UniversityProfessorStyle(
        title: 'AI Engineering Professor',
        openerTone: 'design and problem-solving focused',
        questionStyle: 'What constraint limits your design choice here?',
        feedbackCorrect: 'Good engineering judgment.',
        feedbackPartial: 'Check safety factor and units.',
        feedbackIncorrect: 'Start with requirements before selecting components.',
      );
    }
    return const UniversityProfessorStyle(
      title: 'AI Professor',
      openerTone: 'clear, rigorous, and interactive',
      questionStyle: 'In your own words, what does this concept mean?',
      feedbackCorrect: 'Exactly. Now apply it to the example on the board.',
      feedbackPartial: 'Close — refine your definition with one more detail.',
      feedbackIncorrect: 'Let\'s rebuild the definition step by step.',
    );
  }
}

/// Linked practical lab after a lecture.
class UniversityLabLink {
  const UniversityLabLink({
    required this.labId,
    required this.stationId,
    required this.title,
    required this.purpose,
    required this.objectives,
    this.estimatedMinutes = 35,
    this.difficulty = 'Intermediate',
    this.prerequisite,
    this.safetyNotes = const <String>[],
  });

  final String labId;
  final String stationId;
  final String title;
  final String purpose;
  final List<String> objectives;
  final int estimatedMinutes;
  final String difficulty;
  final String? prerequisite;
  final List<String> safetyNotes;
}

/// Resolves lesson → lab and professor style.
abstract final class UniversityLearningEngine {
  static const List<UniversityLearningPhase> loop = <UniversityLearningPhase>[
    UniversityLearningPhase.classroom,
    UniversityLearningPhase.interactiveLecture,
    UniversityLearningPhase.practice,
    UniversityLearningPhase.lab,
    UniversityLearningPhase.assessment,
    UniversityLearningPhase.simulation,
    UniversityLearningPhase.debrief,
    UniversityLearningPhase.mastery,
  ];

  static UniversityLabLink? labForLesson({
    required String subjectId,
    required String lessonTitle,
    String? moduleTitle,
  }) {
    final String blob =
        '${lessonTitle.toLowerCase()} ${moduleTitle?.toLowerCase() ?? ''}';
    final String s = subjectId.toLowerCase();

    if (CareerPracticeLabs.matches(subjectId)) {
      return CareerPracticeLabs.labFor(subjectId, lessonTitle);
    }

    if (s.contains('biology') || s == 'biology') {
      return _biologyLab(blob, lessonTitle);
    }
    if (s.contains('chem')) {
      return _chemistryLab(blob, lessonTitle);
    }
    if (s.contains('phys')) {
      return _physicsLab(blob, lessonTitle);
    }
    if (s.contains('nurs')) {
      return const UniversityLabLink(
        labId: 'nursing_ed',
        stationId: 'practical',
        title: 'ED Triage Escalation Practical',
        purpose: 'Prioritize, assess ABC, escalate — then defend clinical judgment.',
        objectives: <String>[
          'Prioritize life threats',
          'Run ABC assessment',
          'Escalate with reasoning',
        ],
      );
    }
    if (s.contains('medical_lab') || s.contains('mls') || s == 'medical_lab_science') {
      return const UniversityLabLink(
        labId: 'medical_lab_science',
        stationId: 'practical',
        title: 'Critical Value Practical',
        purpose: 'Validate, call criticals, defend hemolysis reasoning.',
        objectives: <String>[
          'Check sample integrity',
          'Notify clinician',
          'Explain hemolysis',
        ],
      );
    }
    if (s.contains('medicine') || s == 'med') {
      return const UniversityLabLink(
        labId: 'medicine',
        stationId: 'practical',
        title: 'Chest Pain Differential Practical',
        purpose: 'Build differential, choose tests, defend diagnosis WHY.',
        objectives: <String>[
          'Name life threats first',
          'Order urgent tests',
          'Defend clinical reasoning',
        ],
      );
    }
    if (s.contains('law')) {
      return const UniversityLabLink(
        labId: 'law_firm',
        stationId: 'practical',
        title: 'Issue-Spotting Case Practical',
        purpose: 'Spot issues, apply negligence elements, defend memo thesis.',
        objectives: <String>[
          'Separate relevant facts',
          'Frame the legal issue',
          'Defend IRAC reasoning',
        ],
        prerequisite: 'Legal foundations lecture',
      );
    }
    if (s.contains('finance')) {
      return const UniversityLabLink(
        labId: 'finance',
        stationId: 'practical',
        title: 'Portfolio Shock Practical',
        purpose: 'Rebalance under rate shock and defend fiduciary process.',
        objectives: <String>[
          'Identify duration risk',
          'Rebalance inside IPS',
          'Document rationale',
        ],
      );
    }
    if (s.contains('account')) {
      return const UniversityLabLink(
        labId: 'accounting',
        stationId: 'practical',
        title: 'Discrepancy Hunt Practical',
        purpose: 'Trace misstatements, correct, remediate controls.',
        objectives: <String>[
          'Classify the error',
          'Post correction',
          'Defend control fixes',
        ],
      );
    }
    if (s.contains('market')) {
      return const UniversityLabLink(
        labId: 'marketing',
        stationId: 'practical',
        title: 'Campaign Pivot Practical',
        purpose: 'Diagnose funnel leak and defend an A/B pivot.',
        objectives: <String>[
          'Locate funnel leak',
          'Design controlled experiment',
          'Defend metrics WHY',
        ],
      );
    }
    if (s.contains('econ')) {
      return const UniversityLabLink(
        labId: 'economics',
        stationId: 'practical',
        title: 'Inflation Policy Practical',
        purpose: 'Choose instruments and defend employment tradeoffs.',
        objectives: <String>[
          'Diagnose inflation type',
          'Pick policy tool',
          'Defend tradeoffs',
        ],
      );
    }
    if (s.contains('business')) {
      return const UniversityLabLink(
        labId: 'business',
        stationId: 'practical',
        title: 'Sales Drop War-Room Practical',
        purpose: 'Evidence → root cause → strategy viva.',
        objectives: <String>[
          'Segment the drop',
          'Name root cause',
          'Defend one primary lever',
        ],
      );
    }
    if (s.contains('pharm')) {
      return const UniversityLabLink(
        labId: 'pharmacy',
        stationId: 'practical',
        title: 'Rx Verification Practical',
        purpose: 'Catch interactions, escalate, counsel safely.',
        objectives: <String>[
          'Verify interaction risk',
          'Contact prescriber',
          'Counsel monitoring',
        ],
      );
    }
    if (s.contains('psych')) {
      return const UniversityLabLink(
        labId: 'psychology',
        stationId: 'practical',
        title: 'Experiment Design Practical',
        purpose: 'Design controls, spot confounds, defend ethics.',
        objectives: <String>[
          'Randomize properly',
          'Kill confounds',
          'Defend consent',
        ],
      );
    }
    if (s.contains('cyber')) {
      return const UniversityLabLink(
        labId: 'cybersecurity',
        stationId: 'practical',
        title: 'SOC Triage Practical',
        purpose: 'Contain account takeover and preserve evidence.',
        objectives: <String>[
          'Severity triage',
          'Contain identity',
          'Preserve logs',
        ],
      );
    }
    if (s.contains('engin') || s.contains('civil') || s.contains('electric')) {
      return const UniversityLabLink(
        labId: 'engineering',
        stationId: 'practical',
        title: 'Bridge Load Practical',
        purpose: 'Load path, buckling risk, safety-factor viva.',
        objectives: <String>[
          'Separate live vs dead load',
          'Spot buckling risk',
          'Defend safety factor',
        ],
      );
    }
    if (s.contains('math')) {
      return UniversityLabLink(
        labId: 'mathematics',
        stationId: 'practical',
        title: 'Model-and-Defend Practical — $lessonTitle',
        purpose: 'Set up, optimize, and defend critical-point reasoning.',
        objectives: <String>[
          'Model the constraint',
          'Optimize correctly',
          'Verify maximum',
        ],
        estimatedMinutes: 25,
        difficulty: 'Introductory',
      );
    }
    if (s.contains('computer') ||
        s.contains('cs') ||
        s.contains('software') ||
        s.contains('data_science') ||
        s.contains('artificial') ||
        s.contains('web_dev') ||
        s.contains('programming')) {
      return const UniversityLabLink(
        labId: 'computer_science',
        stationId: 'practical',
        title: 'Production Incident Practical',
        purpose: 'Triage latency, fix root cause, defend eng review.',
        objectives: <String>[
          'Observe before changing prod',
          'Fix N+1 with tests',
          'Defend roll-forward',
        ],
      );
    }
    // Fallback: still give every mapped faculty a graded practical CTA.
    final UniversityLabLink? fromMajor = _fallbackBySubject(s, lessonTitle);
    return fromMajor;
  }

  static UniversityLabLink? _fallbackBySubject(String s, String lessonTitle) {
    if (s.contains('design') || s.contains('journal') || s.contains('history') ||
        s.contains('socio') || s.contains('philo') || s.contains('public_health') ||
        s.contains('nutrition') || s.contains('entrepreneur')) {
      return UniversityLabLink(
        labId: 'business',
        stationId: 'practical',
        title: 'Applied Decision Practical — $lessonTitle',
        purpose: 'Case → decision → defend WHY (transferable board viva).',
        objectives: const <String>[
          'Frame the problem',
          'Choose a primary lever',
          'Defend reasoning',
        ],
      );
    }
    return null;
  }

  static UniversityLabLink? _biologyLab(String blob, String lessonTitle) {
    if (blob.contains('enzyme')) {
      return const UniversityLabLink(
        labId: 'biology',
        stationId: 'lab_bench',
        title: 'BIOLOGY LAB 04 — Enzyme Activity',
        purpose: 'Investigate how temperature affects enzyme activity.',
        objectives: <String>[
          'Explain enzyme activity',
          'Identify variables',
          'Design an experiment',
          'Collect and interpret data',
          'Explain experimental error',
        ],
        prerequisite: 'Enzymes lecture',
        safetyNotes: <String>['Wear goggles', 'Handle reagents carefully'],
      );
    }
    if (blob.contains('cell') ||
        blob.contains('organelle') ||
        blob.contains('membrane') ||
        blob.contains('transport')) {
      return const UniversityLabLink(
        labId: 'biology',
        stationId: 'cell',
        title: 'Animal Cell Investigation',
        purpose: 'Label organelles and explain each structure\'s function.',
        objectives: <String>[
          'Identify major organelles',
          'Relate structure to function',
          'Annotate observations',
        ],
        prerequisite: 'Cell biology lecture',
      );
    }
    if (blob.contains('genetic') ||
        blob.contains('dna') ||
        blob.contains('punnett') ||
        blob.contains('mendel')) {
      return const UniversityLabLink(
        labId: 'biology',
        stationId: 'genetics',
        title: 'Genetics Laboratory',
        purpose: 'Build DNA pairs and complete Punnett square analysis.',
        objectives: <String>[
          'Pair complementary bases',
          'Predict phenotypes',
          'Explain inheritance patterns',
        ],
      );
    }
    if (blob.contains('microscope') ||
        blob.contains('mitosis') ||
        blob.contains('specimen')) {
      return const UniversityLabLink(
        labId: 'biology',
        stationId: 'microscope',
        title: 'Microscope Laboratory',
        purpose: 'Identify an unknown specimen and document structures.',
        objectives: <String>[
          'Focus the specimen',
          'Identify tissue type',
          'Record observations',
        ],
        safetyNotes: <String>['Handle slides carefully', 'Clean lenses after use'],
      );
    }
    if (blob.contains('ecolog') ||
        blob.contains('population') ||
        blob.contains('ecosystem') ||
        blob.contains('food web')) {
      return const UniversityLabLink(
        labId: 'biology',
        stationId: 'ecology',
        title: 'Ecology Simulation Lab',
        purpose: 'Manipulate environmental variables and interpret population change.',
        objectives: <String>[
          'Set independent variables',
          'Predict population trends',
          'Interpret graphs',
        ],
      );
    }
    if (blob.contains('skeleton') ||
        blob.contains('bone') ||
        blob.contains('scapula') ||
        blob.contains('radius') ||
        blob.contains('ulna') ||
        blob.contains('axial') ||
        blob.contains('appendicular')) {
      return const UniversityLabLink(
        labId: 'biology',
        stationId: 'anatomy_3d',
        title: '3D Skeleton Rotation Lab',
        purpose: 'Rotate the skeleton and label bones from multiple views.',
        objectives: <String>[
          'Orbit anterior, lateral, and posterior views',
          'Identify major bones spatially',
          'Complete drag-and-drop labeling',
        ],
      );
    }
    if (blob.contains('heart') ||
        blob.contains('anatom') ||
        blob.contains('cardiovascular')) {
      return const UniversityLabLink(
        labId: 'biology',
        stationId: 'anatomy',
        title: 'Anatomy Laboratory',
        purpose: 'Label heart structures and explain clinical relationships.',
        objectives: <String>[
          'Identify chambers and vessels',
          'Use directional language',
          'Connect anatomy to function',
        ],
      );
    }
    return UniversityLabLink(
      labId: 'biology',
      stationId: 'cell',
      title: 'Biology Practical — $lessonTitle',
      purpose: 'Apply today\'s lecture in a guided biology laboratory.',
      objectives: <String>[
        'Investigate the concept hands-on',
        'Record observations in your notebook',
        'Interpret results',
      ],
      difficulty: 'Introductory',
    );
  }

  static UniversityLabLink? _chemistryLab(String blob, String lessonTitle) {
    if (blob.contains('titration') || blob.contains('acid')) {
      return const UniversityLabLink(
        labId: 'chemistry',
        stationId: 'titration',
        title: 'Acid-Base Titration Lab',
        purpose: 'Run the interactive titration bench, then defend endpoint reasoning.',
        objectives: <String>[
          'Fill burette and add indicator',
          'Titrate to pale pink endpoint',
          'Calculate molarity',
          'Defend rinse / stoichiometry WHY',
        ],
        safetyNotes: <String>['Acids and bases — wear PPE'],
      );
    }
    if (blob.contains('molecule') || blob.contains('bond')) {
      return const UniversityLabLink(
        labId: 'chemistry',
        stationId: 'molecules',
        title: 'Molecular Builder Lab',
        purpose: 'Build molecules and check valence on the bench.',
        objectives: <String>[
          'Place atoms',
          'Add bonds',
          'Check valence',
        ],
      );
    }
    return UniversityLabLink(
      labId: 'chemistry',
      stationId: 'reactions',
      title: 'Chemistry Reactions Lab — $lessonTitle',
      purpose: 'Mix, observe, and explain with chemistry — not a quiz dump.',
      objectives: <String>[
        'Combine reactants',
        'Record observations',
        'Write CER explanation',
      ],
    );
  }

  static UniversityLabLink? _physicsLab(String blob, String lessonTitle) {
    if (blob.contains('projectile') ||
        blob.contains('launch') ||
        blob.contains('energy')) {
      return const UniversityLabLink(
        labId: 'physics',
        stationId: 'energy',
        title: 'Projectile Motion Lab',
        purpose: 'Launch, predict range, and defend kinematics on the rig.',
        objectives: <String>[
          'Set launch parameters',
          'Predict range and height',
          'Compare to measurement',
          'Defend component reasoning',
        ],
      );
    }
    if (blob.contains('circuit') || blob.contains('electric')) {
      return const UniversityLabLink(
        labId: 'physics',
        stationId: 'electricity',
        title: 'Circuit Lab',
        purpose: 'Build a working circuit and troubleshoot like a physicist.',
        objectives: <String>[
          'Place components',
          'Wire the circuit',
          'Light the bulb',
        ],
      );
    }
    if (blob.contains('wave')) {
      return const UniversityLabLink(
        labId: 'physics',
        stationId: 'waves',
        title: 'Waves Lab',
        purpose: 'Control amplitude/frequency and measure wavelength.',
        objectives: <String>[
          'Set A & f',
          'Measure λ',
          'Label crest/trough',
        ],
      );
    }
    return UniversityLabLink(
      labId: 'physics',
      stationId: 'motion',
      title: 'Physics Motion Lab — $lessonTitle',
      purpose: 'Tune variables, RUN the sim, explain the graphs.',
      objectives: <String>[
        'Set force/mass/friction',
        'RUN and read graphs',
        'Explain the result',
      ],
    );
  }
}
