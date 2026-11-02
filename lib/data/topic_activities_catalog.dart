import '../models/practice_lab.dart';
import '../models/topic_activity.dart';
import '../utils/topic_keyword_matcher.dart';
import 'practice_lab_course_topics.dart';

/// Maps curriculum topics to multiple interactive activity types.
class TopicActivitiesCatalog {
  TopicActivitiesCatalog._();

  static List<TopicActivity> forTopic({
    required String subjectId,
    required String courseId,
    required String topicId,
    required String topicName,
    required bool codeLab,
    required SimulationStyle defaultStyle,
  }) {
    final Set<TopicActivityKind> seen = <TopicActivityKind>{};
    final List<TopicActivity> out = <TopicActivity>[];

    void add(TopicActivity activity) {
      if (seen.add(activity.kind)) out.add(activity);
    }

    if (PracticeLabCourseTopics.codeLabForCourse(subjectId, courseId) || codeLab) {
      for (final TopicActivity cs in _csBase) {
        add(cs);
      }
    }

    final TopicKeywordMatcher matcher = TopicKeywordMatcher(
      topicId: topicId,
      topicName: topicName,
      subjectId: subjectId,
      courseId: courseId,
    );

    for (final _ActivityRule rule in _rules) {
      if (!rule.matches(matcher)) continue;
      for (final TopicActivity activity in rule.activities) {
        if (activity.diagramId == 'skeleton' && matcher.excludesBoneContent) continue;
        if (activity.title.toLowerCase().contains('bone') && matcher.excludesBoneContent) continue;
        add(activity);
      }
    }

    if (defaultStyle == SimulationStyle.courtroom) {
      add(_courtroom);
    }
    if (defaultStyle == SimulationStyle.counseling) {
      add(_aiRoleplay);
      add(_caseStudy);
    }
    if (defaultStyle == SimulationStyle.codingInterview && !codeLab) {
      add(_aiCodingInterview);
    }
    if (defaultStyle == SimulationStyle.erEmergency || defaultStyle == SimulationStyle.aiPatient) {
      add(_liveSimulation);
      add(_caseStudy);
    }

    if (out.isEmpty) {
      add(_caseStudy);
    }

    return out;
  }

  static int activityCountFor({
    required String subjectId,
    required String courseId,
    required String topicId,
    required String topicName,
    required bool codeLab,
    required SimulationStyle defaultStyle,
  }) =>
      forTopic(
        subjectId: subjectId,
        courseId: courseId,
        topicId: topicId,
        topicName: topicName,
        codeLab: codeLab,
        defaultStyle: defaultStyle,
      ).length;

  // ── Shared activity templates ───────────────────────────────────────────────

  static const TopicActivity _shortAnswer = TopicActivity(
    kind: TopicActivityKind.shortAnswer,
    title: 'Short Answer',
    description: 'Explain concepts in your own words with AI feedback.',
    emoji: '📝',
  );
  static const TopicActivity _fillBlank = TopicActivity(
    kind: TopicActivityKind.fillBlank,
    title: 'Fill in the Blank',
    description: 'Complete key terms and definitions for this topic.',
    emoji: '✍️',
  );

  static const TopicActivity _codeCompletion = TopicActivity(
    kind: TopicActivityKind.codeCompletion,
    title: 'Code Completion',
    description: 'Fill in missing code to solve programming problems.',
    emoji: '💻',
  );
  static const TopicActivity _findBug = TopicActivity(
    kind: TopicActivityKind.puzzleChallenge,
    title: 'Find the Bug',
    description: 'Spot errors in code snippets for this topic.',
    emoji: '🐛',
  );
  static const TopicActivity _outputPrediction = TopicActivity(
    kind: TopicActivityKind.scenarioChallenge,
    title: 'Output Prediction',
    description: 'Predict what code will print or return.',
    emoji: '🔮',
  );
  static const TopicActivity _aiCodingInterview = TopicActivity(
    kind: TopicActivityKind.aiCodingInterview,
    title: 'AI Coding Interview',
    description: 'Live coding interview with an AI technical interviewer.',
    emoji: '🎯',
    simulationStyle: SimulationStyle.codingInterview,
  );
  static const TopicActivity _sqlQueries = TopicActivity(
    kind: TopicActivityKind.shortAnswer,
    title: 'SQL Queries',
    description: 'Write and explain SQL for real database scenarios.',
    emoji: '🗄️',
  );

  static const List<TopicActivity> _csBase = <TopicActivity>[
    _codeCompletion,
    _findBug,
    _outputPrediction,
    _aiCodingInterview,
  ];

  static const TopicActivity _courtroom = TopicActivity(
    kind: TopicActivityKind.courtroomSimulation,
    title: 'Courtroom Simulation',
    description: 'Practice objections, cross-examination, and legal reasoning.',
    emoji: '⚖️',
    simulationStyle: SimulationStyle.courtroom,
  );
  static const TopicActivity _aiRoleplay = TopicActivity(
    kind: TopicActivityKind.aiRoleplay,
    title: 'AI Roleplay',
    description: 'Interact with an AI character in a realistic scenario.',
    emoji: '👤',
    simulationStyle: SimulationStyle.counseling,
  );
  static const TopicActivity _caseStudy = TopicActivity(
    kind: TopicActivityKind.caseStudy,
    title: 'Case Study',
    description: 'Analyze a realistic case and recommend next steps.',
    emoji: '📊',
  );
  static const TopicActivity _liveSimulation = TopicActivity(
    kind: TopicActivityKind.liveSimulation,
    title: 'Live Simulation',
    description: 'Step into an immersive clinical or emergency scenario.',
    emoji: '🏥',
    simulationStyle: SimulationStyle.erEmergency,
  );

  // ── Shared diagram / visual activities ─────────────────────────────────────

  static const TopicActivity _labelAnimalCell = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Label the Animal Cell',
    description: 'Tap organelles on the animal cell illustration.',
    emoji: '🖼️',
    diagramId: 'animal_cell',
  );
  static const TopicActivity _labelPlantCell = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Label the Plant Cell',
    description: 'Identify structures unique to plant cells.',
    emoji: '🌿',
    diagramId: 'plant_cell',
  );
  static const TopicActivity _dragOrganelles = TopicActivity(
    kind: TopicActivityKind.dragDrop,
    title: 'Drag Organelles to Location',
    description: 'Drag each organelle label to the correct cell region.',
    emoji: '🎯',
    diagramId: 'animal_cell',
    isLive: true,
  );
  static const TopicActivity _matchOrganelles = TopicActivity(
    kind: TopicActivityKind.matching,
    title: 'Match Organelles to Functions',
    description: 'Pair each organelle with its primary function.',
    emoji: '🔗',
    diagramId: 'animal_cell',
  );
  static const TopicActivity _labelBones = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Label Bones',
    description: 'Identify bones on the skeletal diagram.',
    emoji: '🦴',
    diagramId: 'skeleton',
  );
  static const TopicActivity _labelOrgans = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Label Organs',
    description: 'Tap organs on the anatomical illustration.',
    emoji: '🫀',
    diagramId: 'human_organs',
  );
  static const TopicActivity _labelHeart = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Label Heart',
    description: 'Label chambers, valves, and great vessels.',
    emoji: '❤️',
    diagramId: 'heart_detail',
  );
  static const TopicActivity _labelRespiratory = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Label Respiratory System',
    description: 'Identify airways, lungs, and diaphragm.',
    emoji: '🫁',
    diagramId: 'respiratory',
  );
  static const TopicActivity _labelNeuron = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Label Neuron',
    description: 'Identify dendrites, axon, and synaptic terminals.',
    emoji: '🧠',
    diagramId: 'neuron',
  );
  static const TopicActivity _matchOrgans = TopicActivity(
    kind: TopicActivityKind.matching,
    title: 'Match Organs to Functions',
    description: 'Connect each organ to its physiological role.',
    emoji: '🔗',
    diagramId: 'human_organs',
  );
  static const TopicActivity _punnett = TopicActivity(
    kind: TopicActivityKind.punnettSquare,
    title: 'Punnett Squares',
    description: 'Solve inheritance problems with interactive Punnett grids.',
    emoji: '🧬',
    visualActivityId: 'bio_punnett',
  );
  static const TopicActivity _labelDna = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'DNA Labeling',
    description: 'Label bases, backbone, and hydrogen bonds.',
    emoji: '🧬',
    diagramId: 'dna',
  );
  static const TopicActivity _labelChromosome = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Chromosome Identification',
    description: 'Identify centromere, arms, and chromatids.',
    emoji: '🔬',
    diagramId: 'chromosome',
  );
  static const TopicActivity _inheritance = TopicActivity(
    kind: TopicActivityKind.shortAnswer,
    title: 'Inheritance Questions',
    description: 'Work through pedigree and inheritance scenarios.',
    emoji: '📋',
  );
  static const TopicActivity _labelAtom = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Label Atom',
    description: 'Identify protons, neutrons, electrons, and shells.',
    emoji: '⚛️',
    diagramId: 'atom',
  );
  static const TopicActivity _periodicQuiz = TopicActivity(
    kind: TopicActivityKind.multipleChoice,
    title: 'Periodic Table Quiz',
    description: 'Test trends, groups, and element properties.',
    emoji: '📊',
  );
  static const TopicActivity _buildAtom = TopicActivity(
    kind: TopicActivityKind.virtualLab,
    title: 'Build an Atom',
    description: 'Assemble subatomic particles for target elements.',
    emoji: '🔧',
    isLive: false,
  );
  static const TopicActivity _bondTypes = TopicActivity(
    kind: TopicActivityKind.matching,
    title: 'Identify Bond Types',
    description: 'Classify ionic, covalent, and polar bonds.',
    emoji: '🔗',
    diagramId: 'molecule',
  );
  static const TopicActivity _moleculeBuilder = TopicActivity(
    kind: TopicActivityKind.virtualLab,
    title: 'Molecule Builder',
    description: 'Build and name molecules in the virtual lab.',
    emoji: '⚗️',
    visualActivityId: 'chem_mix',
  );
  static const TopicActivity _lewisStructures = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Lewis Structures',
    description: 'Draw and identify Lewis dot structures.',
    emoji: '✏️',
    diagramId: 'molecule',
  );
  static const TopicActivity _labEquipment = TopicActivity(
    kind: TopicActivityKind.dragDrop,
    title: 'Identify Lab Equipment',
    description: 'Drag labels onto beakers, flasks, and lab tools.',
    emoji: '🧪',
    visualActivityId: 'chem_equipment',
  );
  static const TopicActivity _virtualExperiment = TopicActivity(
    kind: TopicActivityKind.virtualLab,
    title: 'Virtual Experiment',
    description: 'Run a safe virtual chemistry experiment.',
    emoji: '🔬',
    visualActivityId: 'chem_experiments',
  );
  static const TopicActivity _forceDiagram = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Force Diagram',
    description: 'Identify forces on a free-body diagram.',
    emoji: '➡️',
    diagramId: 'force',
  );
  static const TopicActivity _circuitBuilder = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Circuit Builder',
    description: 'Identify battery, resistor, switch, and bulb.',
    emoji: '🔌',
    diagramId: 'dc_circuit',
  );
  static const TopicActivity _waveLabel = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'Wave Properties',
    description: 'Label amplitude, wavelength, crest, and trough.',
    emoji: '〰️',
    diagramId: 'wave',
  );
  static const TopicActivity _virtualHospital = TopicActivity(
    kind: TopicActivityKind.liveSimulation,
    title: 'Virtual Hospital',
    description: 'Navigate hospital wings and patient scenarios.',
    emoji: '🏥',
    visualActivityId: 'nurse_virtual_hospital',
  );
  static const TopicActivity _dosageCalc = TopicActivity(
    kind: TopicActivityKind.shortAnswer,
    title: 'Dosage Calculations',
    description: 'Calculate safe medication doses step by step.',
    emoji: '💊',
  );
  static const TopicActivity _medMatching = TopicActivity(
    kind: TopicActivityKind.matching,
    title: 'Medication Matching',
    description: 'Match drug classes to indications and effects.',
    emoji: '💉',
  );
  static const TopicActivity _vitalSigns = TopicActivity(
    kind: TopicActivityKind.caseStudy,
    title: 'Vital Signs',
    description: 'Interpret and document patient vital signs.',
    emoji: '🩺',
  );
  static const TopicActivity _headToToe = TopicActivity(
    kind: TopicActivityKind.practicalExam,
    title: 'Head-to-Toe Assessment',
    description: 'Complete a systematic nursing assessment.',
    emoji: '📋',
  );
  static const TopicActivity _prioritization = TopicActivity(
    kind: TopicActivityKind.scenarioChallenge,
    title: 'Prioritization Questions',
    description: 'Rank nursing actions for complex patient cases.',
    emoji: '🎯',
  );
  static const TopicActivity _ecg = TopicActivity(
    kind: TopicActivityKind.imageIdentification,
    title: 'ECG Interpretation',
    description: 'Identify rhythms and cardiac abnormalities.',
    emoji: '📈',
    isLive: false,
  );
  static const TopicActivity _foodChain = TopicActivity(
    kind: TopicActivityKind.matching,
    title: 'Food Chains',
    description: 'Order producers, consumers, and decomposers.',
    emoji: '🌿',
    isLive: false,
  );
  static const TopicActivity _ecosystem = TopicActivity(
    kind: TopicActivityKind.caseStudy,
    title: 'Ecosystems',
    description: 'Analyze ecosystem interactions and energy flow.',
    emoji: '🌍',
  );
  static const TopicActivity _functionalGroups = TopicActivity(
    kind: TopicActivityKind.imageIdentification,
    title: 'Functional Group ID',
    description: 'Recognize alcohols, carbonyls, amines, and more.',
    emoji: '🔍',
    isLive: false,
  );
  static const TopicActivity _microbiology = TopicActivity(
    kind: TopicActivityKind.imageIdentification,
    title: 'Species Identification',
    description: 'Identify bacteria, viruses, or fungi under the microscope.',
    emoji: '🔬',
    visualActivityId: 'bio_bacteria',
  );
  static const TopicActivity _erTrauma = TopicActivity(
    kind: TopicActivityKind.liveSimulation,
    title: 'Trauma Cases',
    description: 'Triage and manage emergency trauma patients.',
    emoji: '🚑',
    simulationStyle: SimulationStyle.erEmergency,
  );
  static const TopicActivity _radiology = TopicActivity(
    kind: TopicActivityKind.imageIdentification,
    title: 'X-ray Interpretation',
    description: 'Identify fractures and pathology on imaging.',
    emoji: '🩻',
    isLive: false,
  );
  static const TopicActivity _marketingCampaign = TopicActivity(
    kind: TopicActivityKind.scenarioChallenge,
    title: 'Build Marketing Campaign',
    description: 'Design a campaign for a target audience.',
    emoji: '📣',
  );
  static const TopicActivity _journalEntries = TopicActivity(
    kind: TopicActivityKind.fillBlank,
    title: 'Journal Entries',
    description: 'Record debits and credits for business transactions.',
    emoji: '🧾',
  );
  static const TopicActivity _patientInterview = TopicActivity(
    kind: TopicActivityKind.aiRoleplay,
    title: 'Patient Interviews',
    description: 'Conduct a therapeutic interview with an AI client.',
    emoji: '🗣️',
    simulationStyle: SimulationStyle.counseling,
  );
  static const TopicActivity _classroomScenario = TopicActivity(
    kind: TopicActivityKind.scenarioChallenge,
    title: 'Classroom Scenarios',
    description: 'Handle student behavior and classroom challenges.',
    emoji: '🏫',
    simulationStyle: SimulationStyle.classroom,
  );
  static const TopicActivity _sortingViz = TopicActivity(
    kind: TopicActivityKind.puzzleChallenge,
    title: 'Sorting Visualization',
    description: 'Trace sorting algorithms step by step.',
    emoji: '📊',
  );
  static const TopicActivity _graphTraversal = TopicActivity(
    kind: TopicActivityKind.puzzleChallenge,
    title: 'Graph Traversal',
    description: 'Apply BFS and DFS to graph problems.',
    emoji: '🕸️',
  );
  static const TopicActivity _erDiagram = TopicActivity(
    kind: TopicActivityKind.labelDiagram,
    title: 'ER Diagrams',
    description: 'Design entities and relationships for databases.',
    emoji: '🗂️',
    isLive: false,
  );

  // ── Keyword rules ──────────────────────────────────────────────────────────

  static const List<_ActivityRule> _rules = <_ActivityRule>[
    _ActivityRule(<String>['organelle', 'cell_structure', 'cell biology'], <TopicActivity>[
      _labelAnimalCell,
      _labelPlantCell,
      _dragOrganelles,
      _matchOrganelles,
    ]),
    _ActivityRule(<String>['cell_membrane', 'membrane_transport', 'membrane'], <TopicActivity>[
      _labelAnimalCell,
      _matchOrganelles,
    ]),
    _ActivityRule(<String>['skeletal', 'bone', 'musculoskeletal', 'joint'], <TopicActivity>[
      _labelBones,
    ]),
    _ActivityRule(<String>['muscular', 'muscle'], <TopicActivity>[
      _labelOrgans,
    ]),
    _ActivityRule(<String>['digestive', 'renal', 'abdominal', 'viscera'], <TopicActivity>[
      _labelOrgans,
      _matchOrgans,
    ]),
    _ActivityRule(<String>['cardiovascular', 'cardiac', 'heart'], <TopicActivity>[
      _labelHeart,
      _labelOrgans,
    ]),
    _ActivityRule(<String>['respir', 'lung', 'pulmon'], <TopicActivity>[
      _labelRespiratory,
    ]),
    _ActivityRule(<String>['neuron', 'nervous', 'neuro', 'brain', 'cranial'], <TopicActivity>[
      _labelNeuron,
    ]),
    _ActivityRule(<String>['dna', 'replication', 'transcription', 'translation', 'genetic'], <TopicActivity>[
      _labelDna,
      _inheritance,
    ]),
    _ActivityRule(<String>['mendelian', 'inheritance', 'punnett', 'pedigree'], <TopicActivity>[
      _punnett,
      _inheritance,
      _labelDna,
    ]),
    _ActivityRule(<String>['chromosome', 'mitosis', 'meiosis', 'cell_division', 'cell cycle'], <TopicActivity>[
      _labelChromosome,
      _punnett,
    ]),
    _ActivityRule(<String>['ecology', 'ecosystem', 'food_web', 'biome', 'conservation'], <TopicActivity>[
      _foodChain,
      _ecosystem,
    ]),
    _ActivityRule(<String>['bacteria', 'virus', 'microbio', 'pathogen', 'fungi'], <TopicActivity>[
      _microbiology,
    ]),
    _ActivityRule(<String>['atomic', 'atom', 'electron', 'periodic', 'isotope'], <TopicActivity>[
      _labelAtom,
      _periodicQuiz,
      _buildAtom,
    ]),
    _ActivityRule(<String>['bond', 'molecule', 'lewis', 'ionic', 'covalent', 'vsepr'], <TopicActivity>[
      _bondTypes,
      _lewisStructures,
      _moleculeBuilder,
    ]),
    _ActivityRule(<String>['organic', 'functional_group', 'stereochem', 'synthesis', 'reaction'], <TopicActivity>[
      _functionalGroups,
      _moleculeBuilder,
      _lewisStructures,
    ]),
    _ActivityRule(<String>['lab', 'equipment', 'safety', 'titration', 'steril'], <TopicActivity>[
      _labEquipment,
      _virtualExperiment,
    ]),
    _ActivityRule(<String>['stoichiometry', 'equilibrium', 'acid', 'ph'], <TopicActivity>[
      _virtualExperiment,
      _moleculeBuilder,
    ]),
    _ActivityRule(<String>['force', 'newton', 'kinematic', 'motion', 'projectile', 'momentum'], <TopicActivity>[
      _forceDiagram,
    ]),
    _ActivityRule(<String>['circuit', 'electric', 'voltage', 'current', 'resistance', 'ohm'], <TopicActivity>[
      _circuitBuilder,
    ]),
    _ActivityRule(<String>['wave', 'sound', 'frequency', 'wavelength', 'optic', 'light'], <TopicActivity>[
      _waveLabel,
    ]),
    _ActivityRule(<String>['heat', 'thermo', 'entropy', 'temperature'], <TopicActivity>[
      _waveLabel,
      _forceDiagram,
    ]),
    _ActivityRule(<String>['vital_sign', 'assessment', 'head_to_toe'], <TopicActivity>[
      _vitalSigns,
      _headToToe,
      _virtualHospital,
    ]),
    _ActivityRule(<String>['pharmacology', 'dosage', 'medication', 'drug', 'iv_'], <TopicActivity>[
      _dosageCalc,
      _medMatching,
    ]),
    _ActivityRule(<String>[
      'med_surg',
      'medical_surgical',
      'heart_failure',
      'copd',
      'diabetes',
      'sepsis',
      'post_op',
      'wound',
      'ostomy',
      'renal_failure',
      'stroke',
      'transfusion',
      'chest_tube',
    ], <TopicActivity>[
      _caseStudy,
      _prioritization,
      _virtualHospital,
    ]),
    _ActivityRule(<String>['pediatric', 'growth', 'vaccine', 'childhood'], <TopicActivity>[
      _caseStudy,
      _vitalSigns,
    ]),
    _ActivityRule(<String>['obstetric', 'pregnancy', 'labor', 'postpartum', 'fetal'], <TopicActivity>[
      _caseStudy,
      _vitalSigns,
    ]),
    _ActivityRule(<String>['critical_care', 'icu', 'ventilator', 'ecg', 'shock'], <TopicActivity>[
      _ecg,
      _liveSimulation,
      _prioritization,
    ]),
    _ActivityRule(<String>['emergency', 'trauma', 'cpr', 'resuscitation', 'triage'], <TopicActivity>[
      _erTrauma,
      _liveSimulation,
    ]),
    _ActivityRule(<String>['radiology', 'x_ray', 'x-ray', 'ct_scan', 'mri', 'ultrasound', 'fracture'], <TopicActivity>[
      _radiology,
      _labelBones,
    ]),
    _ActivityRule(<String>['pathology', 'histology', 'tissue', 'disease_ident'], <TopicActivity>[
      _caseStudy,
      _imageIdentification,
    ]),
    _ActivityRule(<String>['surgery', 'surgical', 'instrument', 'sterile'], <TopicActivity>[
      _caseStudy,
      _practicalExam,
    ]),
    _ActivityRule(<String>['linked_list', 'stack', 'queue', 'tree', 'graph', 'hash'], <TopicActivity>[
      _sortingViz,
      _graphTraversal,
      _codeCompletion,
    ]),
    _ActivityRule(<String>['sort', 'search', 'algorithm', 'recursion', 'dynamic_program'], <TopicActivity>[
      _sortingViz,
      _aiCodingInterview,
    ]),
    _ActivityRule(<String>['sql', 'database', 'normalization', 'er_diagram'], <TopicActivity>[
      _sqlQueries,
      _erDiagram,
    ]),
    _ActivityRule(<String>['criminal', 'evidence', 'cross_exam', 'objection', 'constitutional'], <TopicActivity>[
      _courtroom,
      _caseStudy,
    ]),
    _ActivityRule(<String>['marketing', 'brand', 'consumer', 'social_media'], <TopicActivity>[
      _marketingCampaign,
      _caseStudy,
    ]),
    _ActivityRule(<String>['finance', 'investment', 'budget', 'stock', 'financial_statement'], <TopicActivity>[
      _caseStudy,
      _shortAnswer,
    ]),
    _ActivityRule(<String>['accounting', 'journal', 'trial_balance', 'tax'], <TopicActivity>[
      _journalEntries,
      _fillBlank,
    ]),
    _ActivityRule(<String>['clinical_psych', 'diagnosis', 'therapy', 'mental_health', 'anxiety', 'depression'], <TopicActivity>[
      _patientInterview,
      _caseStudy,
      _aiRoleplay,
    ]),
    _ActivityRule(<String>['cognitive', 'memory', 'attention', 'decision'], <TopicActivity>[
      _puzzleChallenge,
      _shortAnswer,
    ]),
    _ActivityRule(<String>['classroom', 'lesson_plan', 'parent_conference', 'student_behavior'], <TopicActivity>[
      _classroomScenario,
      _aiRoleplay,
    ]),
    _ActivityRule(<String>['infection', 'ppe', 'patient_safety', 'hygiene'], <TopicActivity>[
      _caseStudy,
      _prioritization,
    ]),
  ];

  static const TopicActivity _imageIdentification = TopicActivity(
    kind: TopicActivityKind.imageIdentification,
    title: 'Image Identification',
    description: 'Identify structures or pathology from images.',
    emoji: '🖼️',
    isLive: false,
  );
  static const TopicActivity _practicalExam = TopicActivity(
    kind: TopicActivityKind.practicalExam,
    title: 'Practical Exam',
    description: 'Hands-on practical assessment for this topic.',
    emoji: '🎖️',
  );
  static const TopicActivity _puzzleChallenge = TopicActivity(
    kind: TopicActivityKind.puzzleChallenge,
    title: 'Puzzle Challenge',
    description: 'Solve interactive puzzles to reinforce concepts.',
    emoji: '🧩',
  );
}

class _ActivityRule {
  const _ActivityRule(this.keywords, this.activities);

  final List<String> keywords;
  final List<TopicActivity> activities;

  bool matches(TopicKeywordMatcher matcher) => matcher.matchesAny(keywords);
}
