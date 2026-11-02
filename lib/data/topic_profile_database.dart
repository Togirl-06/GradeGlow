import '../models/topic_profile.dart';
import '../utils/topic_keyword_matcher.dart';

/// Topic database: learning objectives, forbidden cross-topic terms, diagrams, and question banks.
class TopicProfileDatabase {
  TopicProfileDatabase._();

  static TopicProfile resolve({
    required String topicId,
    required String topicName,
    String? subjectId,
    String? courseId,
    String? courseName,
    String? unitName,
  }) {
    final String exactKey = subjectId != null && courseId != null ? '$subjectId|$courseId|$topicId' : '';
    if (exactKey.isNotEmpty && _exact.containsKey(exactKey)) {
      return _exact[exactKey]!.copyWith(
        topicName: topicName,
        courseName: courseName,
        unitName: unitName,
      );
    }

    final TopicKeywordMatcher matcher = TopicKeywordMatcher(
      topicId: topicId,
      topicName: topicName,
      subjectId: subjectId,
      courseId: courseId,
    );

    final _DomainTemplate template = _inferTemplate(matcher, subjectId, courseId, topicId, topicName);
    return TopicProfile(
      subjectId: subjectId,
      courseId: courseId,
      topicId: topicId,
      topicName: topicName,
      courseName: courseName,
      unitName: unitName,
      domain: template.id,
      learningObjectives: template.objectivesFor(topicName, topicId),
      skillsToTest: template.skills,
      forbiddenTerms: template.forbidden,
      questionBankKeys: template.questionKeysFor(matcher, topicId, topicName),
      allowedDiagramIds: template.diagramIds,
      strictScoping: template.strict,
    );
  }

  static _DomainTemplate _inferTemplate(
    TopicKeywordMatcher matcher,
    String? subjectId,
    String? courseId,
    String topicId,
    String topicName,
  ) {
    if (matcher.matchesAny(const <String>['insulin'])) return _insulinAdmin;
    if (matcher.matchesAny(const <String>['binary_tree', 'binary_trees'])) return _binaryTrees;
    if (matcher.matchesAny(const <String>['alcohol']) && courseId == 'organic_chemistry') {
      return _alcoholFunctionalGroup;
    }
    if (matcher.matchesAny(const <String>['mitochondria', 'atp_energy', 'cellular_respiration'])) {
      return _mitochondria;
    }
    if (matcher.isBoneAnatomyTopic || (courseId == 'anatomy' && matcher.matchesAny(const <String>['skeletal', 'bone']))) {
      return _skeletalAnatomy;
    }
    if (matcher.isOrganelleOrCellTopic || courseId == 'cell_biology') return _cellBiology;
    if (matcher.matchesAny(const <String>['dna', 'genetic', 'mendelian', 'replication', 'transcription', 'translation'])) {
      return _genetics;
    }
    if (matcher.matchesAny(const <String>['bacteria', 'virus', 'microbio', 'pathogen'])) return _microbiology;
    if (matcher.matchesAny(const <String>['ecology', 'ecosystem', 'biome', 'food_web'])) return _ecology;
    if (courseId == 'organic_chemistry' || matcher.matchesAny(const <String>['functional_group', 'stereochem', 'synthesis'])) {
      return _organicChemistry;
    }
    if (matcher.matchesAny(const <String>['atomic', 'periodic', 'stoichiometry', 'bonding']) && subjectId == 'chemistry') {
      return _generalChemistry;
    }
    if (matcher.matchesAny(const <String>['circuit', 'ohm', 'voltage', 'electric'])) return _physicsElectricity;
    if (matcher.matchesAny(const <String>['force', 'kinematic', 'newton', 'momentum'])) return _physicsMechanics;
    if (courseId == 'data_structures' || matcher.matchesAny(const <String>['linked_list', 'hash_table', 'stack', 'queue', 'heap'])) {
      return _dataStructures;
    }
    if (courseId == 'algorithms' || matcher.matchesAny(const <String>['sort', 'dynamic_programming', 'graph'])) {
      return _algorithms;
    }
    if (courseId == 'databases' || matcher.matchesAny(const <String>['sql', 'normalization'])) return _databases;
    if (courseId == 'computer_networks' || matcher.matchesAny(const <String>['tcp', 'routing', 'dns', 'http'])) {
      return _networking;
    }
    if (matcher.matchesAny(const <String>['dosage', 'medication', 'pharmacology', 'drug'])) return _pharmacology;
    if (matcher.matchesAny(const <String>['heart', 'cardiac', 'cardiovascular'])) return _cardiovascular;
    if (matcher.matchesAny(const <String>['respiratory', 'lung', 'pulmon'])) return _respiratory;
    if (matcher.matchesAny(const <String>['neuron', 'neuro', 'nervous'])) return _neuroscience;
    if (subjectId == 'nursing' || subjectId == 'medicine') return _clinicalNursing;
    if (subjectId == 'computer_science') return _programmingGeneral;
    if (subjectId == 'biology') return _cellBiology;
    if (subjectId == 'chemistry') return _generalChemistry;
    if (subjectId == 'physics') return _physicsMechanics;
    return _general;
  }

  // ── Exact topic profiles (highest priority) ────────────────────────────────

  static final Map<String, TopicProfile> _exact = <String, TopicProfile>{
    'biology|cell_biology|organelles': TopicProfile(
      subjectId: 'biology',
      courseId: 'cell_biology',
      topicId: 'organelles',
      topicName: 'Organelles',
      domain: 'cell_biology',
      learningObjectives: const <String>[
        'Identify major organelles in eukaryotic cells',
        'Match each organelle to its primary function',
        'Compare animal and plant cell organelles',
        'Explain how organelles work together in the cell',
      ],
      skillsToTest: const <String>['identification', 'matching', 'labeling', 'recall'],
      forbiddenTerms: _anatomyForbidden,
      questionBankKeys: const <String>['organelle', 'cell_membrane'],
      allowedDiagramIds: const <String>['animal_cell', 'plant_cell'],
    ),
    'biology|cell_biology|organelle_function': TopicProfile(
      subjectId: 'biology',
      courseId: 'cell_biology',
      topicId: 'organelle_function',
      topicName: 'Organelle Function',
      domain: 'mitochondria',
      learningObjectives: const <String>[
        'Describe the function of mitochondria in ATP production',
        'Explain why mitochondria are called the powerhouse of the cell',
        'Identify which cells have high mitochondrial density',
        'Outline the role of mitochondria in cellular respiration',
      ],
      skillsToTest: const <String>['recall', 'application', 'labeling', 'analysis'],
      forbiddenTerms: _anatomyForbidden,
      questionBankKeys: const <String>['organelle', 'mitochondria'],
      allowedDiagramIds: const <String>['animal_cell'],
    ),
    'biology|anatomy|skeletal_system': TopicProfile(
      subjectId: 'biology',
      courseId: 'anatomy',
      topicId: 'skeletal_system',
      topicName: 'Skeletal System',
      domain: 'skeletal_anatomy',
      learningObjectives: const <String>[
        'Identify major bones of the axial and appendicular skeleton',
        'Describe functions of the skeletal system',
        'Classify joint types with examples',
        'Relate bone structure to protection and movement',
      ],
      skillsToTest: const <String>['labeling', 'identification', 'matching', 'clinical application'],
      forbiddenTerms: _cellBiologyForbidden,
      questionBankKeys: const <String>['skeletal'],
      allowedDiagramIds: const <String>['skeleton'],
    ),
    'chemistry|organic_chemistry|functional_groups': TopicProfile(
      subjectId: 'chemistry',
      courseId: 'organic_chemistry',
      topicId: 'functional_groups',
      topicName: 'Functional Groups',
      domain: 'organic_chemistry',
      learningObjectives: const <String>[
        'Recognize common organic functional groups by structure',
        'Predict physical properties from functional groups',
        'Name simple compounds containing key functional groups',
        'Identify reactions characteristic of each functional group',
      ],
      skillsToTest: const <String>['structure recognition', 'nomenclature', 'prediction', 'drawing'],
      forbiddenTerms: _organicOffTopic,
      questionBankKeys: const <String>['acid', 'molecule'],
      allowedDiagramIds: const <String>['molecule'],
    ),
    'computer_science|data_structures|binary_trees': TopicProfile(
      subjectId: 'computer_science',
      courseId: 'data_structures',
      topicId: 'binary_trees',
      topicName: 'Binary Trees',
      domain: 'binary_trees',
      learningObjectives: const <String>[
        'Define binary tree terminology: root, leaf, height, depth',
        'Perform inorder, preorder, and postorder traversals',
        'Insert and search nodes in a binary search tree',
        'Analyze time complexity of tree operations',
      ],
      skillsToTest: const <String>['traversal', 'insertion', 'analysis', 'implementation'],
      forbiddenTerms: _csOffTopic,
      questionBankKeys: const <String>['linked_list', 'sort'],
      allowedDiagramIds: const <String>[],
      strictScoping: true,
    ),
    'nursing|pharmacology|insulin_administration': TopicProfile(
      subjectId: 'nursing',
      courseId: 'pharmacology',
      topicId: 'insulin_administration',
      topicName: 'Insulin Administration',
      domain: 'insulin_administration',
      learningObjectives: const <String>[
        'Select appropriate insulin injection sites and angles',
        'Compare absorption rates of subcutaneous injection sites',
        'Describe proper insulin storage and handling',
        'Calculate insulin doses using sliding scales and carb ratios',
      ],
      skillsToTest: const <String>['site selection', 'dosage calculation', 'patient education', 'safety'],
      forbiddenTerms: _insulinOffTopic,
      questionBankKeys: const <String>['dosage', 'diabetes', 'pharmacology'],
      allowedDiagramIds: const <String>['human_organs'],
    ),
  };

  // ── Forbidden term lists ───────────────────────────────────────────────────

  static const List<String> _anatomyForbidden = <String>[
    'femur', 'skull', 'bone', 'bones', 'skeleton', 'skeletal', 'osteoporosis', 'osteocyte',
    'heart', 'atrium', 'ventricle', 'aorta', 'cardiac', 'lung', 'lungs', 'respiratory',
    'liver', 'kidney', 'stomach', 'digestive', 'muscle', 'muscular', 'brain', 'neuron',
    'ecology', 'ecosystem', 'evolution', 'periodic table', 'atom', 'circuit', 'sql',
  ];

  static const List<String> _cellBiologyForbidden = <String>[
    'femur', 'skull', 'bone', 'bones', 'skeleton', 'skeletal', 'osteoporosis',
    'heart', 'cardiac', 'lung', 'lungs', 'liver', 'kidney', 'muscle', 'brain anatomy',
    'ecology', 'ecosystem', 'periodic table', 'sql', 'html', 'css', 'networking',
  ];

  static const List<String> _organicOffTopic = <String>[
    'periodic table', 'atomic number', 'nuclear', 'femur', 'mitochondria', 'dna',
    'bone', 'skeleton', 'heart', 'sql', 'circuit', 'newton',
  ];

  static const List<String> _csOffTopic = <String>[
    'sql', 'html', 'css', 'http', 'dns', 'tcp', 'networking', 'subnet',
    'femur', 'heart', 'mitochondria', 'insulin', 'periodic table',
  ];

  static const List<String> _insulinOffTopic = <String>[
    'ecg', 'ekg', 'lung sound', 'brain anatomy', 'femur', 'skull', 'mitochondria',
    'dna', 'binary tree', 'periodic table', 'circuit', 'copd', 'wound stage',
  ];

  // ── Domain templates ───────────────────────────────────────────────────────

  static const _DomainTemplate _mitochondria = _DomainTemplate(
    id: 'mitochondria',
    skills: <String>['recall', 'labeling', 'application', 'analysis'],
    forbidden: _anatomyForbidden,
    diagramIds: <String>['animal_cell'],
    questionKeys: <String>['organelle', 'mitochondria'],
    objectives: <String>[
      'Explain the function of mitochondria in ATP production',
      'Describe the structure of the inner and outer mitochondrial membranes',
      'Identify cells with high mitochondrial density and explain why',
      'Outline the role of mitochondria in cellular respiration',
    ],
  );

  static const _DomainTemplate _cellBiology = _DomainTemplate(
    id: 'cell_biology',
    skills: <String>['identification', 'labeling', 'matching', 'analysis'],
    forbidden: _anatomyForbidden,
    diagramIds: <String>['animal_cell', 'plant_cell'],
    questionKeys: <String>['organelle', 'cell_membrane'],
    objectives: <String>[
      'Identify organelles and describe their functions',
      'Explain membrane transport mechanisms',
      'Compare prokaryotic and eukaryotic cells',
      'Relate cell structure to specialized cell functions',
    ],
  );

  static const _DomainTemplate _skeletalAnatomy = _DomainTemplate(
    id: 'skeletal_anatomy',
    skills: <String>['labeling', 'identification', 'matching'],
    forbidden: _cellBiologyForbidden,
    diagramIds: <String>['skeleton'],
    questionKeys: <String>['skeletal'],
    objectives: <String>[
      'Identify major bones and landmarks',
      'Describe skeletal system functions',
      'Classify joint types with examples',
      'Apply bone anatomy to clinical scenarios',
    ],
  );

  static const _DomainTemplate _genetics = _DomainTemplate(
    id: 'genetics',
    skills: <String>['recall', 'analysis', 'prediction'],
    forbidden: <String>[..._anatomyForbidden, 'circuit', 'sql', 'stoichiometry'],
    diagramIds: <String>['dna', 'chromosome'],
    questionKeys: <String>['dna', 'mendelian', 'mitosis', 'meiosis'],
    objectives: <String>[
      'Describe DNA structure and replication',
      'Apply Mendelian inheritance rules',
      'Explain gene expression from transcription to translation',
      'Predict outcomes of genetic crosses',
    ],
  );

  static const _DomainTemplate _microbiology = _DomainTemplate(
    id: 'microbiology',
    skills: <String>['identification', 'culture', 'clinical reasoning'],
    forbidden: <String>[..._anatomyForbidden, 'binary tree', 'derivative'],
    diagramIds: <String>['bacteria'],
    questionKeys: <String>['bacteria', 'virus'],
    objectives: <String>[
      'Compare prokaryotic and eukaryotic microorganisms',
      'Describe bacterial structure and replication',
      'Interpret culture and staining results',
      'Apply infection control principles',
    ],
  );

  static const _DomainTemplate _ecology = _DomainTemplate(
    id: 'ecology',
    skills: <String>['analysis', 'prediction', 'systems thinking'],
    forbidden: <String>[..._anatomyForbidden, 'organelle', 'mitochondria', 'dna replication'],
    diagramIds: <String>[],
    questionKeys: <String>[],
    objectives: <String>[
      'Analyze energy flow in ecosystems',
      'Predict population dynamics',
      'Evaluate conservation strategies',
      'Interpret food web interactions',
    ],
  );

  static const _DomainTemplate _organicChemistry = _DomainTemplate(
    id: 'organic_chemistry',
    skills: <String>['structure', 'mechanism', 'synthesis', 'nomenclature'],
    forbidden: _organicOffTopic,
    diagramIds: <String>['molecule'],
    questionKeys: <String>['acid', 'molecule', 'stoichiometry'],
    objectives: <String>[
      'Identify functional groups and predict reactivity',
      'Draw and name organic structures',
      'Predict products of organic reactions',
      'Interpret spectroscopy data for structure determination',
    ],
  );

  static const _DomainTemplate _alcoholFunctionalGroup = _DomainTemplate(
    id: 'alcohol_functional_group',
    skills: <String>['nomenclature', 'structure', 'reaction prediction'],
    forbidden: _organicOffTopic,
    diagramIds: <String>['molecule'],
    questionKeys: <String>['acid', 'molecule'],
    objectives: <String>[
      'Identify the hydroxyl functional group in alcohols',
      'Name simple alcohols using IUPAC rules',
      'Draw structures of ethanol and related alcohols',
      'Predict oxidation products of primary and secondary alcohols',
    ],
  );

  static const _DomainTemplate _generalChemistry = _DomainTemplate(
    id: 'general_chemistry',
    skills: <String>['calculation', 'recall', 'application'],
    forbidden: <String>[..._anatomyForbidden, 'binary tree', 'insulin', 'sql'],
    diagramIds: <String>['atom', 'molecule'],
    questionKeys: <String>['atomic', 'stoichiometry', 'acid', 'circuit'],
    objectives: <String>[
      'Apply atomic structure and periodic trends',
      'Balance chemical equations and solve stoichiometry',
      'Explain bonding types and molecular geometry',
      'Calculate concentrations and reaction quantities',
    ],
  );

  static const _DomainTemplate _physicsMechanics = _DomainTemplate(
    id: 'physics_mechanics',
    skills: <String>['problem solving', 'diagrams', 'calculation'],
    forbidden: <String>[..._anatomyForbidden, 'dna', 'sql', 'insulin', 'periodic'],
    diagramIds: <String>['force'],
    questionKeys: <String>['force', 'forces', 'kinematic'],
    objectives: <String>[
      'Apply Newton\'s laws to motion problems',
      'Solve kinematics with uniform acceleration',
      'Analyze work, energy, and momentum',
      'Draw and interpret free-body diagrams',
    ],
  );

  static const _DomainTemplate _physicsElectricity = _DomainTemplate(
    id: 'physics_electricity',
    skills: <String>['circuit analysis', 'calculation', 'conceptual'],
    forbidden: <String>[..._anatomyForbidden, 'dna', 'sql', 'femur', 'mitochondria'],
    diagramIds: <String>['dc_circuit'],
    questionKeys: <String>['circuit'],
    objectives: <String>[
      'Apply Ohm\'s law to series and parallel circuits',
      'Analyze voltage, current, and resistance',
      'Identify circuit components and their roles',
      'Solve mixed circuit problems',
    ],
  );

  static const _DomainTemplate _binaryTrees = _DomainTemplate(
    id: 'binary_trees',
    skills: <String>['traversal', 'insertion', 'complexity analysis'],
    forbidden: _csOffTopic,
    diagramIds: <String>[],
    questionKeys: <String>['linked_list', 'sort'],
    objectives: <String>[
      'Traverse binary trees using inorder, preorder, and postorder',
      'Insert and search in a binary search tree',
      'Calculate height and balance of trees',
      'Analyze time complexity of tree operations',
    ],
  );

  static const _DomainTemplate _dataStructures = _DomainTemplate(
    id: 'data_structures',
    skills: <String>['implementation', 'analysis', 'debugging'],
    forbidden: _csOffTopic,
    diagramIds: <String>[],
    questionKeys: <String>['linked_list', 'sort'],
    objectives: <String>[
      'Choose appropriate data structures for problems',
      'Implement core operations with correct complexity',
      'Compare trade-offs between structures',
      'Debug structure-related algorithm errors',
    ],
  );

  static const _DomainTemplate _algorithms = _DomainTemplate(
    id: 'algorithms',
    skills: <String>['design', 'analysis', 'optimization'],
    forbidden: _csOffTopic,
    diagramIds: <String>[],
    questionKeys: <String>['sort', 'linked_list'],
    objectives: <String>[
      'Design algorithms using divide-and-conquer and DP',
      'Analyze time and space complexity',
      'Apply sorting and searching strategies',
      'Optimize solutions for given constraints',
    ],
  );

  static const _DomainTemplate _databases = _DomainTemplate(
    id: 'databases',
    skills: <String>['query writing', 'design', 'optimization'],
    forbidden: <String>[..._anatomyForbidden, 'binary tree', 'mitochondria', 'html', 'css'],
    diagramIds: <String>[],
    questionKeys: <String>['sql'],
    objectives: <String>[
      'Write SQL queries with joins and aggregates',
      'Normalize schemas to reduce redundancy',
      'Design indexes for query performance',
      'Explain ACID transaction properties',
    ],
  );

  static const _DomainTemplate _networking = _DomainTemplate(
    id: 'networking',
    skills: <String>['protocol knowledge', 'troubleshooting', 'security'],
    forbidden: <String>[..._anatomyForbidden, 'mitochondria', 'binary tree', 'html', 'css', 'sql query'],
    diagramIds: <String>[],
    questionKeys: <String>[],
    objectives: <String>[
      'Explain TCP/IP and OSI layer responsibilities',
      'Configure routing and subnetting',
      'Troubleshoot connectivity issues',
      'Apply network security best practices',
    ],
  );

  static const _DomainTemplate _insulinAdmin = _DomainTemplate(
    id: 'insulin_administration',
    skills: <String>['dosage', 'site selection', 'patient safety'],
    forbidden: _insulinOffTopic,
    diagramIds: <String>['human_organs'],
    questionKeys: <String>['dosage', 'diabetes', 'pharmacology'],
    objectives: <String>[
      'Select correct injection sites and needle angles',
      'Compare insulin absorption by site',
      'Store and handle insulin safely',
      'Calculate insulin doses accurately',
    ],
  );

  static const _DomainTemplate _pharmacology = _DomainTemplate(
    id: 'pharmacology',
    skills: <String>['dosage', 'safety', 'clinical reasoning'],
    forbidden: <String>[..._anatomyForbidden, 'binary tree', 'dna', 'circuit'],
    diagramIds: <String>[],
    questionKeys: <String>['pharmacology', 'dosage'],
    objectives: <String>[
      'Apply the rights of medication administration',
      'Calculate safe medication doses',
      'Identify high-risk drug interactions',
      'Monitor for adverse drug reactions',
    ],
  );

  static const _DomainTemplate _cardiovascular = _DomainTemplate(
    id: 'cardiovascular',
    skills: <String>['assessment', 'pathophysiology', 'intervention'],
    forbidden: <String>[..._cellBiologyForbidden, 'binary tree', 'sql', 'periodic'],
    diagramIds: <String>['heart_detail'],
    questionKeys: <String>['cardiovascular', 'heart_failure'],
    objectives: <String>[
      'Describe cardiac anatomy and the cardiac cycle',
      'Interpret cardiovascular assessment findings',
      'Prioritize interventions for cardiac conditions',
      'Explain hemodynamic principles',
    ],
  );

  static const _DomainTemplate _respiratory = _DomainTemplate(
    id: 'respiratory',
    skills: <String>['assessment', 'pathophysiology', 'intervention'],
    forbidden: <String>[..._cellBiologyForbidden, 'binary tree', 'insulin', 'sql'],
    diagramIds: <String>['respiratory'],
    questionKeys: <String>['respiratory', 'copd'],
    objectives: <String>[
      'Trace the path of air through the respiratory system',
      'Assess breath sounds and oxygenation',
      'Explain gas exchange at the alveolar level',
      'Manage common respiratory conditions',
    ],
  );

  static const _DomainTemplate _neuroscience = _DomainTemplate(
    id: 'neuroscience',
    skills: <String>['identification', 'pathway tracing', 'clinical correlation'],
    forbidden: <String>[..._cellBiologyForbidden, 'sql', 'stoichiometry', 'circuit'],
    diagramIds: <String>['neuron'],
    questionKeys: <String>['neuron'],
    objectives: <String>[
      'Identify parts of neurons and their functions',
      'Explain action potential propagation',
      'Trace neural pathways for reflexes and sensation',
      'Correlate neuroanatomy with clinical findings',
    ],
  );

  static const _DomainTemplate _clinicalNursing = _DomainTemplate(
    id: 'clinical_nursing',
    skills: <String>['assessment', 'prioritization', 'patient safety'],
    forbidden: <String>['binary tree', 'mitochondria', 'dna', 'periodic table', 'sql'],
    diagramIds: <String>['human_organs'],
    questionKeys: <String>['medical_surgical', 'vital_sign'],
    objectives: <String>[
      'Apply nursing process to patient scenarios',
      'Prioritize interventions using ABCs',
      'Document findings accurately',
      'Educate patients using evidence-based guidance',
    ],
    strict: false,
  );

  static const _DomainTemplate _programmingGeneral = _DomainTemplate(
    id: 'programming',
    skills: <String>['coding', 'debugging', 'design'],
    forbidden: _csOffTopic,
    diagramIds: <String>[],
    questionKeys: <String>['linked_list', 'sort'],
    objectives: <String>[
      'Write correct, efficient code for the topic',
      'Debug logic and runtime errors',
      'Analyze algorithmic complexity',
      'Apply best practices for software design',
    ],
  );

  static const _DomainTemplate _general = _DomainTemplate(
    id: 'general',
    skills: <String>['recall', 'application', 'analysis'],
    forbidden: <String>[],
    diagramIds: <String>[],
    questionKeys: <String>[],
    objectives: <String>[
      'Demonstrate understanding of core concepts',
      'Apply knowledge to realistic scenarios',
      'Analyze problems using course principles',
      'Synthesize ideas from the unit',
    ],
    strict: false,
  );
}

class _DomainTemplate {
  const _DomainTemplate({
    required this.id,
    required this.skills,
    required this.forbidden,
    required this.diagramIds,
    required this.questionKeys,
    required this.objectives,
    this.strict = true,
  });

  final String id;
  final List<String> skills;
  final List<String> forbidden;
  final List<String> diagramIds;
  final List<String> questionKeys;
  final List<String> objectives;
  final bool strict;

  List<String> objectivesFor(String topicName, String topicId) {
    return <String>[
      'Master concepts specific to $topicName',
      ...objectives,
    ];
  }

  List<String> questionKeysFor(TopicKeywordMatcher matcher, String topicId, String topicName) {
    final Set<String> keys = questionKeys.toSet();
    for (final String key in questionKeys) {
      if (matcher.matches(key)) keys.add(key);
    }
    if (matcher.matchesAny(const <String>['mitochondria', 'atp'])) keys.add('organelle');
    if (matcher.matchesAny(const <String>['insulin'])) keys.addAll(<String>['dosage', 'diabetes']);
    if (matcher.matchesAny(const <String>['tree', 'binary'])) keys.add('linked_list');
    return keys.toList();
  }
}
