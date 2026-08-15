import 'package:flutter/material.dart';

import '../models/practice_lab.dart';
import '../models/visual_learning_lab.dart';

/// Curated Visual Learning Labs — labeling, drag-drop, simulations per subject.
class VisualLearningCatalog {
  VisualLearningCatalog._();

  static const Set<String> visualSubjects = <String>{
    'biology',
    'chemistry',
    'physics',
    'nursing',
    'medicine',
    'psychology',
    'law',
    'computer_science',
    'engineering',
    'business',
  };

  static bool supportsSubject(String subjectId) => visualSubjects.contains(subjectId);

  static VisualLabEnvironment environmentFor(String subjectId) => switch (subjectId) {
        'biology' => VisualLabEnvironment.biologyResearchLab,
        'chemistry' => VisualLabEnvironment.chemistryLab,
        'physics' => VisualLabEnvironment.physicsLab,
        'nursing' => VisualLabEnvironment.nursingHospital,
        'medicine' => VisualLabEnvironment.medicineTeachingHospital,
        'law' => VisualLabEnvironment.courtroom,
        'computer_science' => VisualLabEnvironment.codingOffice,
        'engineering' => VisualLabEnvironment.engineeringWorkshop,
        'business' => VisualLabEnvironment.businessHeadquarters,
        'psychology' => VisualLabEnvironment.counselingCenter,
        _ => VisualLabEnvironment.classroom,
      };

  static VisualLabEnvironmentConfig configFor(VisualLabEnvironment env) =>
      _environmentConfigs[env] ?? _environmentConfigs[VisualLabEnvironment.classroom]!;

  static VisualLabEnvironmentConfig configForSubject(String subjectId) =>
      configFor(environmentFor(subjectId));

  static List<VisualLabSection> sectionsFor(String subjectId) =>
      _sectionsBySubject[subjectId] ?? const <VisualLabSection>[];

  static int activityCountFor(String subjectId) =>
      sectionsFor(subjectId).fold<int>(0, (int n, VisualLabSection s) => n + s.activities.length);

  static VisualLabActivity? activityById(String id) {
    for (final VisualLabSection section in _allSections) {
      for (final VisualLabActivity activity in section.activities) {
        if (activity.id == id) return activity;
      }
    }
    return null;
  }

  static List<VisualLabSection> get _allSections =>
      _sectionsBySubject.values.expand((List<VisualLabSection> list) => list).toList();

  static const Map<VisualLabEnvironment, VisualLabEnvironmentConfig> _environmentConfigs =
      <VisualLabEnvironment, VisualLabEnvironmentConfig>{
    VisualLabEnvironment.biologyResearchLab: VisualLabEnvironmentConfig(
      environment: VisualLabEnvironment.biologyResearchLab,
      title: 'AI Research Lab',
      tagline: 'Label cells, organs, and microbes like a real biology lab.',
      emoji: '🧬',
      accent: Color(0xFF66BB6A),
      gradient: <Color>[Color(0xFF1B4332), Color(0xFF2D6A4F)],
    ),
    VisualLabEnvironment.chemistryLab: VisualLabEnvironmentConfig(
      environment: VisualLabEnvironment.chemistryLab,
      title: 'AI Laboratory',
      tagline: 'Identify equipment, build atoms, and run virtual experiments.',
      emoji: '⚗️',
      accent: Color(0xFF42A5F5),
      gradient: <Color>[Color(0xFF0D47A1), Color(0xFF1565C0)],
    ),
    VisualLabEnvironment.physicsLab: VisualLabEnvironmentConfig(
      environment: VisualLabEnvironment.physicsLab,
      title: 'Physics Workshop',
      tagline: 'Forces, circuits, waves, and engineering simulations.',
      emoji: '⚛️',
      accent: Color(0xFFFFB74D),
      gradient: <Color>[Color(0xFF4A148C), Color(0xFF6A1B9A)],
    ),
    VisualLabEnvironment.nursingHospital: VisualLabEnvironmentConfig(
      environment: VisualLabEnvironment.nursingHospital,
      title: 'AI Hospital',
      tagline: 'Assess patients, administer care, and practice clinical skills.',
      emoji: '🏥',
      accent: Color(0xFF22D3EE),
      gradient: <Color>[Color(0xFF0C4A6E), Color(0xFF164E63)],
    ),
    VisualLabEnvironment.medicineTeachingHospital: VisualLabEnvironmentConfig(
      environment: VisualLabEnvironment.medicineTeachingHospital,
      title: 'AI Teaching Hospital',
      tagline: 'Walk ER, ICU, trauma, surgery, and pediatrics with AI staff.',
      emoji: '🩺',
      accent: Color(0xFFEF5350),
      gradient: <Color>[Color(0xFF7F1D1D), Color(0xFF991B1B)],
    ),
    VisualLabEnvironment.courtroom: VisualLabEnvironmentConfig(
      environment: VisualLabEnvironment.courtroom,
      title: 'AI Courtroom',
      tagline: 'Argue cases, examine witnesses, and present evidence.',
      emoji: '⚖️',
      accent: Color(0xFFD4A574),
      gradient: <Color>[Color(0xFF3E2723), Color(0xFF5D4037)],
    ),
    VisualLabEnvironment.codingOffice: VisualLabEnvironmentConfig(
      environment: VisualLabEnvironment.codingOffice,
      title: 'AI Coding Office',
      tagline: 'Tech interviews, debugging, and system design rooms.',
      emoji: '💻',
      accent: Color(0xFF818CF8),
      gradient: <Color>[Color(0xFF0F172A), Color(0xFF1E293B)],
    ),
    VisualLabEnvironment.engineeringWorkshop: VisualLabEnvironmentConfig(
      environment: VisualLabEnvironment.engineeringWorkshop,
      title: 'AI Engineering Workshop',
      tagline: 'Machines, structures, and energy transfer systems.',
      emoji: '⚙️',
      accent: Color(0xFF94A3B8),
      gradient: <Color>[Color(0xFF1E293B), Color(0xFF334155)],
    ),
    VisualLabEnvironment.businessHeadquarters: VisualLabEnvironmentConfig(
      environment: VisualLabEnvironment.businessHeadquarters,
      title: 'AI Company HQ',
      tagline: 'Negotiate deals, pitch investors, and lead teams.',
      emoji: '💼',
      accent: Color(0xFFFBBF24),
      gradient: <Color>[Color(0xFF422006), Color(0xFF713F12)],
    ),
    VisualLabEnvironment.classroom: VisualLabEnvironmentConfig(
      environment: VisualLabEnvironment.classroom,
      title: 'AI Classroom',
      tagline: 'Teach lessons, manage students, and run assessments.',
      emoji: '📚',
      accent: Color(0xFFA78BFA),
      gradient: <Color>[Color(0xFF312E81), Color(0xFF4338CA)],
    ),
    VisualLabEnvironment.counselingCenter: VisualLabEnvironmentConfig(
      environment: VisualLabEnvironment.counselingCenter,
      title: 'AI Counseling Center',
      tagline: 'Practice intake, active listening, and treatment planning.',
      emoji: '🧠',
      accent: Color(0xFFF472B6),
      gradient: <Color>[Color(0xFF831843), Color(0xFF9D174D)],
    ),
  };

  static VisualLabActivity _act({
    required String id,
    required String subjectId,
    required String section,
    required String title,
    required String description,
    required VisualLabActivityType type,
    String? diagramId,
    SimulationStyle? simulationStyle,
    VisualLabAvailability availability = VisualLabAvailability.live,
    bool useTypeEntry = false,
    List<VisualLabScoreCategory> scores = const <VisualLabScoreCategory>[
      VisualLabScoreCategory.accuracy,
      VisualLabScoreCategory.speed,
    ],
  }) {
    final bool clinical = subjectId == 'nursing' || subjectId == 'medicine';
    final List<VisualLabScoreCategory> scoreCats = clinical
        ? <VisualLabScoreCategory>[
            VisualLabScoreCategory.accuracy,
            VisualLabScoreCategory.speed,
            VisualLabScoreCategory.criticalThinking,
            VisualLabScoreCategory.communication,
            VisualLabScoreCategory.clinicalDecisionMaking,
          ]
        : scores;

    return VisualLabActivity(
      id: id,
      subjectId: subjectId,
      sectionTitle: section,
      title: title,
      description: description,
      type: type,
      environment: environmentFor(subjectId),
      diagramId: diagramId,
      simulationStyle: simulationStyle,
      availability: availability,
      scoreCategories: scoreCats,
      useTypeEntry: useTypeEntry,
    );
  }

  static final Map<String, List<VisualLabSection>> _sectionsBySubject = <String, List<VisualLabSection>>{
    'biology': _biologySections,
    'chemistry': _chemistrySections,
    'physics': _physicsSections,
    'nursing': _nursingSections,
    'medicine': _medicineSections,
    'psychology': _psychologySections,
    'law': _lawSections,
    'computer_science': _csSections,
    'engineering': _engineeringSections,
    'business': _businessSections,
  };

  // ── Biology ────────────────────────────────────────────────────────────────
  static final List<VisualLabSection> _biologySections = <VisualLabSection>[
    VisualLabSection(
      title: 'Cell Biology',
      activities: <VisualLabActivity>[
        _act(id: 'bio_label_animal_cell', subjectId: 'biology', section: 'Cell Biology', title: 'Label Animal Cell', description: 'Tap and name every organelle on an animal cell diagram.', type: VisualLabActivityType.labeling, diagramId: 'animal_cell'),
        _act(id: 'bio_label_plant_cell', subjectId: 'biology', section: 'Cell Biology', title: 'Label Plant Cell', description: 'Identify chloroplasts, vacuole, cell wall, and more.', type: VisualLabActivityType.labeling, diagramId: 'plant_cell'),
        _act(id: 'bio_label_mitochondria', subjectId: 'biology', section: 'Cell Biology', title: 'Label Mitochondria', description: 'Find the powerhouse of the cell and related structures.', type: VisualLabActivityType.labeling, diagramId: 'animal_cell'),
        _act(id: 'bio_label_ribosomes', subjectId: 'biology', section: 'Cell Biology', title: 'Label Ribosomes', description: 'Locate ribosomes on ER and in the cytoplasm.', type: VisualLabActivityType.labeling, diagramId: 'animal_cell'),
        _act(id: 'bio_label_membrane', subjectId: 'biology', section: 'Cell Biology', title: 'Label Cell Membrane', description: 'Trace the phospholipid boundary that controls transport.', type: VisualLabActivityType.labeling, diagramId: 'animal_cell'),
        _act(id: 'bio_label_nucleus', subjectId: 'biology', section: 'Cell Biology', title: 'Label Nucleus', description: 'Identify the nucleus and nuclear envelope.', type: VisualLabActivityType.labeling, diagramId: 'animal_cell'),
      ],
    ),
    VisualLabSection(
      title: 'Genetics',
      activities: <VisualLabActivity>[
        _act(id: 'bio_dna_label', subjectId: 'biology', section: 'Genetics', title: 'DNA Structure Labeling', description: 'Label bases, backbone, and double helix features.', type: VisualLabActivityType.interactiveDiagram, diagramId: 'dna'),
        _act(id: 'bio_chromosome_id', subjectId: 'biology', section: 'Genetics', title: 'Chromosome Identification', description: 'Match centromere, arms, and chromatids on a chromosome.', type: VisualLabActivityType.labeling, diagramId: 'chromosome'),
        _act(id: 'bio_gene_mapping', subjectId: 'biology', section: 'Genetics', title: 'Gene Mapping', description: 'Place genes on chromosomes using recombination data.', type: VisualLabActivityType.interactiveDiagram, diagramId: 'chromosome', availability: VisualLabAvailability.aiFallback),
        _act(id: 'bio_punnett', subjectId: 'biology', section: 'Genetics', title: 'Punnett Square Activities', description: 'Predict offspring ratios for monohybrid and dihybrid crosses.', type: VisualLabActivityType.practicalExam),
      ],
    ),
    VisualLabSection(
      title: 'Human Anatomy',
      activities: <VisualLabActivity>[
        _act(id: 'bio_skeletal', subjectId: 'biology', section: 'Human Anatomy', title: 'Label Skeletal System', description: 'Name skull, spine, ribs, and long bones.', type: VisualLabActivityType.labeling, diagramId: 'skeleton', useTypeEntry: true),
        _act(id: 'bio_muscular', subjectId: 'biology', section: 'Human Anatomy', title: 'Label Muscular System', description: 'Identify major muscle groups on the body.', type: VisualLabActivityType.labeling, diagramId: 'human_organs', useTypeEntry: true, availability: VisualLabAvailability.aiFallback),
        _act(id: 'bio_digestive', subjectId: 'biology', section: 'Human Anatomy', title: 'Label Digestive System', description: 'Trace food from mouth to intestines.', type: VisualLabActivityType.labeling, diagramId: 'human_organs', useTypeEntry: true),
        _act(id: 'bio_respiratory', subjectId: 'biology', section: 'Human Anatomy', title: 'Label Respiratory System', description: 'Nasal cavity, trachea, bronchi, lungs, diaphragm.', type: VisualLabActivityType.labeling, diagramId: 'respiratory', useTypeEntry: true),
        _act(id: 'bio_nervous', subjectId: 'biology', section: 'Human Anatomy', title: 'Label Nervous System', description: 'Dendrites, axon, myelin, and synaptic terminals.', type: VisualLabActivityType.labeling, diagramId: 'neuron', useTypeEntry: true),
        _act(id: 'bio_endocrine', subjectId: 'biology', section: 'Human Anatomy', title: 'Label Endocrine System', description: 'Glands and hormone pathways across the body.', type: VisualLabActivityType.labeling, diagramId: 'human_organs', availability: VisualLabAvailability.aiFallback),
      ],
    ),
    VisualLabSection(
      title: 'Microbiology',
      activities: <VisualLabActivity>[
        _act(id: 'bio_bacteria', subjectId: 'biology', section: 'Microbiology', title: 'Identify Bacteria', description: 'Classify cocci, bacilli, and spirilla under the microscope.', type: VisualLabActivityType.imageIdentification),
        _act(id: 'bio_viruses', subjectId: 'biology', section: 'Microbiology', title: 'Identify Viruses', description: 'Recognize viral morphology and host interactions.', type: VisualLabActivityType.imageIdentification),
        _act(id: 'bio_fungi', subjectId: 'biology', section: 'Microbiology', title: 'Identify Fungi', description: 'Spot hyphae, spores, and yeast forms.', type: VisualLabActivityType.imageIdentification),
        _act(id: 'bio_microscope', subjectId: 'biology', section: 'Microbiology', title: 'Microscope Simulations', description: 'Adjust focus and magnification to identify specimens.', type: VisualLabActivityType.imageIdentification, availability: VisualLabAvailability.aiFallback),
      ],
    ),
  ];

  // ── Chemistry ──────────────────────────────────────────────────────────────
  static final List<VisualLabSection> _chemistrySections = <VisualLabSection>[
    VisualLabSection(
      title: 'Laboratory Equipment',
      activities: <VisualLabActivity>[
        _act(id: 'chem_beaker', subjectId: 'chemistry', section: 'Laboratory Equipment', title: 'Identify Beaker', description: 'Drag labels onto the correct glassware.', type: VisualLabActivityType.dragDrop, diagramId: 'chem_equipment'),
        _act(id: 'chem_flask', subjectId: 'chemistry', section: 'Laboratory Equipment', title: 'Identify Flask', description: 'Match Erlenmeyer and volumetric flasks.', type: VisualLabActivityType.dragDrop, diagramId: 'chem_equipment'),
        _act(id: 'chem_pipette', subjectId: 'chemistry', section: 'Laboratory Equipment', title: 'Identify Pipette', description: 'Place pipette labels on the bench diagram.', type: VisualLabActivityType.dragDrop, diagramId: 'chem_equipment'),
        _act(id: 'chem_burette', subjectId: 'chemistry', section: 'Laboratory Equipment', title: 'Identify Burette', description: 'Label precision titration glassware.', type: VisualLabActivityType.dragDrop, diagramId: 'chem_equipment'),
        _act(id: 'chem_test_tube', subjectId: 'chemistry', section: 'Laboratory Equipment', title: 'Identify Test Tube', description: 'Sort common test tubes and racks.', type: VisualLabActivityType.dragDrop, diagramId: 'chem_equipment'),
      ],
    ),
    VisualLabSection(
      title: 'Atomic Structure',
      activities: <VisualLabActivity>[
        _act(id: 'chem_proton', subjectId: 'chemistry', section: 'Atomic Structure', title: 'Label Proton', description: 'Find positively charged particles in the nucleus.', type: VisualLabActivityType.labeling, diagramId: 'atom'),
        _act(id: 'chem_neutron', subjectId: 'chemistry', section: 'Atomic Structure', title: 'Label Neutron', description: 'Locate neutral particles adding atomic mass.', type: VisualLabActivityType.labeling, diagramId: 'atom'),
        _act(id: 'chem_electron', subjectId: 'chemistry', section: 'Atomic Structure', title: 'Label Electron', description: 'Identify electrons in energy shells.', type: VisualLabActivityType.labeling, diagramId: 'atom'),
        _act(id: 'chem_build_atoms', subjectId: 'chemistry', section: 'Atomic Structure', title: 'Build Atoms', description: 'Assemble atoms with correct proton/electron counts.', type: VisualLabActivityType.interactiveDiagram, diagramId: 'atom', availability: VisualLabAvailability.aiFallback),
      ],
    ),
    VisualLabSection(
      title: 'Chemical Bonding',
      activities: <VisualLabActivity>[
        _act(id: 'chem_build_molecules', subjectId: 'chemistry', section: 'Chemical Bonding', title: 'Build Molecules', description: 'Connect atoms to form stable molecules.', type: VisualLabActivityType.interactiveDiagram, diagramId: 'molecule'),
        _act(id: 'chem_ionic', subjectId: 'chemistry', section: 'Chemical Bonding', title: 'Ionic Bond Simulation', description: 'Transfer electrons between metals and nonmetals.', type: VisualLabActivityType.virtualLab, availability: VisualLabAvailability.aiFallback),
        _act(id: 'chem_covalent', subjectId: 'chemistry', section: 'Chemical Bonding', title: 'Covalent Bond Simulation', description: 'Share electron pairs between atoms.', type: VisualLabActivityType.labeling, diagramId: 'molecule'),
      ],
    ),
    VisualLabSection(
      title: 'Organic Chemistry',
      activities: <VisualLabActivity>[
        _act(id: 'chem_functional', subjectId: 'chemistry', section: 'Organic Chemistry', title: 'Identify Functional Groups', description: 'Spot alcohols, aldehydes, ketones, and more.', type: VisualLabActivityType.imageIdentification, availability: VisualLabAvailability.aiFallback),
        _act(id: 'chem_hydrocarbons', subjectId: 'chemistry', section: 'Organic Chemistry', title: 'Label Hydrocarbons', description: 'Name alkane, alkene, and alkyne chains.', type: VisualLabActivityType.labeling, diagramId: 'molecule', availability: VisualLabAvailability.aiFallback),
        _act(id: 'chem_draw', subjectId: 'chemistry', section: 'Organic Chemistry', title: 'Draw Molecules', description: 'Sketch Lewis structures from formulas.', type: VisualLabActivityType.practicalExam, availability: VisualLabAvailability.aiFallback),
      ],
    ),
    VisualLabSection(
      title: 'Virtual Chemistry Lab',
      activities: <VisualLabActivity>[
        _act(id: 'chem_mix', subjectId: 'chemistry', section: 'Virtual Chemistry Lab', title: 'Mix Chemicals', description: 'Combine reagents and observe reactions safely.', type: VisualLabActivityType.virtualLab),
        _act(id: 'chem_ph', subjectId: 'chemistry', section: 'Virtual Chemistry Lab', title: 'Measure pH', description: 'Use indicators and meters to find acidity.', type: VisualLabActivityType.virtualLab),
        _act(id: 'chem_experiments', subjectId: 'chemistry', section: 'Virtual Chemistry Lab', title: 'Run Experiments', description: 'Follow protocols with AI explaining outcomes.', type: VisualLabActivityType.virtualLab),
      ],
    ),
  ];

  // ── Physics ────────────────────────────────────────────────────────────────
  static final List<VisualLabSection> _physicsSections = <VisualLabSection>[
    VisualLabSection(
      title: 'Mechanics',
      activities: <VisualLabActivity>[
        _act(id: 'phys_force_diagrams', subjectId: 'physics', section: 'Mechanics', title: 'Force Diagrams', description: 'Draw and identify forces on objects.', type: VisualLabActivityType.labeling, diagramId: 'force'),
        _act(id: 'phys_free_body', subjectId: 'physics', section: 'Mechanics', title: 'Free Body Diagrams', description: 'Isolate bodies and label all acting forces.', type: VisualLabActivityType.labeling, diagramId: 'force'),
        _act(id: 'phys_motion_graphs', subjectId: 'physics', section: 'Mechanics', title: 'Motion Graphs', description: 'Interpret position, velocity, and acceleration curves.', type: VisualLabActivityType.interactiveDiagram, availability: VisualLabAvailability.aiFallback),
        _act(id: 'phys_projectile', subjectId: 'physics', section: 'Mechanics', title: 'Projectile Motion', description: 'Predict trajectories with launch angle and speed.', type: VisualLabActivityType.virtualLab, availability: VisualLabAvailability.aiFallback),
      ],
    ),
    VisualLabSection(
      title: 'Electricity',
      activities: <VisualLabActivity>[
        _act(id: 'phys_circuits', subjectId: 'physics', section: 'Electricity', title: 'Build Circuits', description: 'Wire batteries, resistors, and bulbs correctly.', type: VisualLabActivityType.interactiveDiagram, diagramId: 'dc_circuit'),
        _act(id: 'phys_components', subjectId: 'physics', section: 'Electricity', title: 'Connect Components', description: 'Place components in series and parallel.', type: VisualLabActivityType.dragDrop, diagramId: 'dc_circuit', availability: VisualLabAvailability.aiFallback),
        _act(id: 'phys_current', subjectId: 'physics', section: 'Electricity', title: 'Identify Current Flow', description: 'Trace conventional current through the circuit.', type: VisualLabActivityType.labeling, diagramId: 'dc_circuit'),
      ],
    ),
    VisualLabSection(
      title: 'Magnetism',
      activities: <VisualLabActivity>[
        _act(id: 'phys_magnetic_field', subjectId: 'physics', section: 'Magnetism', title: 'Magnetic Field Mapping', description: 'Plot field lines around magnets and coils.', type: VisualLabActivityType.interactiveDiagram, availability: VisualLabAvailability.aiFallback),
        _act(id: 'phys_em', subjectId: 'physics', section: 'Magnetism', title: 'Electromagnetic Simulations', description: 'See how changing current affects magnetic fields.', type: VisualLabActivityType.virtualLab, availability: VisualLabAvailability.aiFallback),
      ],
    ),
    VisualLabSection(
      title: 'Engineering Physics',
      activities: <VisualLabActivity>[
        _act(id: 'phys_machines', subjectId: 'physics', section: 'Engineering Physics', title: 'Machine Simulations', description: 'Analyze levers, pulleys, and mechanical advantage.', type: VisualLabActivityType.virtualLab, availability: VisualLabAvailability.aiFallback),
        _act(id: 'phys_energy', subjectId: 'physics', section: 'Engineering Physics', title: 'Energy Transfer Systems', description: 'Track energy through real-world systems.', type: VisualLabActivityType.interactiveDiagram, availability: VisualLabAvailability.aiFallback),
        _act(id: 'phys_structural', subjectId: 'physics', section: 'Engineering Physics', title: 'Structural Analysis', description: 'Evaluate loads, stress, and beam deflection.', type: VisualLabActivityType.practicalExam, availability: VisualLabAvailability.aiFallback),
      ],
    ),
  ];

  // ── Nursing ────────────────────────────────────────────────────────────────
  static final List<VisualLabSection> _nursingSections = <VisualLabSection>[
    VisualLabSection(
      title: 'Anatomy Labeling',
      activities: <VisualLabActivity>[
        _act(id: 'nurse_bones', subjectId: 'nursing', section: 'Anatomy Labeling', title: 'Label Bones', description: 'Click bones and type their anatomical names.', type: VisualLabActivityType.labeling, diagramId: 'skeleton', useTypeEntry: true),
        _act(id: 'nurse_muscles', subjectId: 'nursing', section: 'Anatomy Labeling', title: 'Label Muscles', description: 'Identify major muscle groups for assessment.', type: VisualLabActivityType.labeling, diagramId: 'human_organs', useTypeEntry: true, availability: VisualLabAvailability.aiFallback),
        _act(id: 'nurse_organs', subjectId: 'nursing', section: 'Anatomy Labeling', title: 'Label Organs', description: 'Heart, lungs, liver, kidneys, and stomach.', type: VisualLabActivityType.labeling, diagramId: 'human_organs', useTypeEntry: true),
        _act(id: 'nurse_vessels', subjectId: 'nursing', section: 'Anatomy Labeling', title: 'Label Blood Vessels', description: 'Major arteries and veins for vascular access.', type: VisualLabActivityType.labeling, diagramId: 'human_organs', availability: VisualLabAvailability.aiFallback),
      ],
    ),
    VisualLabSection(
      title: 'Medication Administration',
      activities: <VisualLabActivity>[
        _act(id: 'nurse_injection', subjectId: 'nursing', section: 'Medication Administration', title: 'Correct Injection Site', description: 'Select safe IM and subcutaneous landmarks.', type: VisualLabActivityType.practicalExam, availability: VisualLabAvailability.aiFallback),
        _act(id: 'nurse_iv', subjectId: 'nursing', section: 'Medication Administration', title: 'IV Placement', description: 'Choose veins and angles for peripheral IVs.', type: VisualLabActivityType.practicalExam, availability: VisualLabAvailability.aiFallback),
        _act(id: 'nurse_dosage', subjectId: 'nursing', section: 'Medication Administration', title: 'Dosage Calculation', description: 'Calculate safe medication doses step by step.', type: VisualLabActivityType.practicalExam, availability: VisualLabAvailability.aiFallback),
      ],
    ),
    VisualLabSection(
      title: 'Patient Assessment',
      activities: <VisualLabActivity>[
        _act(id: 'nurse_heart_sounds', subjectId: 'nursing', section: 'Patient Assessment', title: 'Heart Sound Identification', description: 'Distinguish murmurs, gallops, and normal S1/S2.', type: VisualLabActivityType.imageIdentification, availability: VisualLabAvailability.aiFallback),
        _act(id: 'nurse_lung_sounds', subjectId: 'nursing', section: 'Patient Assessment', title: 'Lung Sound Identification', description: 'Identify wheezes, crackles, and diminished breath sounds.', type: VisualLabActivityType.imageIdentification, availability: VisualLabAvailability.aiFallback),
        _act(id: 'nurse_vitals', subjectId: 'nursing', section: 'Patient Assessment', title: 'Vital Signs Analysis', description: 'Interpret BP, HR, RR, SpO₂, and temperature trends.', type: VisualLabActivityType.practicalExam, availability: VisualLabAvailability.aiFallback),
      ],
    ),
    VisualLabSection(
      title: 'Virtual Hospital',
      activities: <VisualLabActivity>[
        _act(
          id: 'nurse_virtual_hospital',
          subjectId: 'nursing',
          section: 'Virtual Hospital',
          title: 'AI Hospital',
          description: 'Assess AI patients in ER, ICU, and med-surg rooms. Conditions change in real time.',
          type: VisualLabActivityType.aiSimulation,
          simulationStyle: SimulationStyle.erEmergency,
        ),
      ],
    ),
  ];

  // ── Medicine ───────────────────────────────────────────────────────────────
  static final List<VisualLabSection> _medicineSections = <VisualLabSection>[
    VisualLabSection(
      title: 'Human Anatomy',
      activities: <VisualLabActivity>[
        _act(id: 'med_heart', subjectId: 'medicine', section: 'Human Anatomy', title: 'Label Heart Structures', description: 'Chambers, valves, and great vessels.', type: VisualLabActivityType.labeling, diagramId: 'heart_detail', useTypeEntry: true),
        _act(id: 'med_brain', subjectId: 'medicine', section: 'Human Anatomy', title: 'Label Brain Structures', description: 'Lobes, cerebellum, brainstem landmarks.', type: VisualLabActivityType.labeling, diagramId: 'neuron', useTypeEntry: true, availability: VisualLabAvailability.aiFallback),
        _act(id: 'med_bones', subjectId: 'medicine', section: 'Human Anatomy', title: 'Label Bones', description: 'Orthopedic landmarks for exam and imaging.', type: VisualLabActivityType.labeling, diagramId: 'skeleton', useTypeEntry: true),
        _act(id: 'med_muscles', subjectId: 'medicine', section: 'Human Anatomy', title: 'Label Muscles', description: 'Palpable muscles for neuro exam.', type: VisualLabActivityType.labeling, diagramId: 'human_organs', availability: VisualLabAvailability.aiFallback),
        _act(id: 'med_organs', subjectId: 'medicine', section: 'Human Anatomy', title: 'Label Organs', description: 'Abdominal and thoracic organ positions.', type: VisualLabActivityType.labeling, diagramId: 'human_organs', useTypeEntry: true),
      ],
    ),
    VisualLabSection(
      title: 'Radiology',
      activities: <VisualLabActivity>[
        _act(id: 'med_xray', subjectId: 'medicine', section: 'Radiology', title: 'X-ray Interpretation', description: 'Read chest and extremity films for pathology.', type: VisualLabActivityType.imageIdentification, availability: VisualLabAvailability.aiFallback),
        _act(id: 'med_ct', subjectId: 'medicine', section: 'Radiology', title: 'CT Scan Interpretation', description: 'Identify acute findings on CT slices.', type: VisualLabActivityType.imageIdentification, availability: VisualLabAvailability.aiFallback),
        _act(id: 'med_mri', subjectId: 'medicine', section: 'Radiology', title: 'MRI Interpretation', description: 'Correlate soft-tissue anatomy on MRI.', type: VisualLabActivityType.imageIdentification, availability: VisualLabAvailability.aiFallback),
      ],
    ),
    VisualLabSection(
      title: 'Pathology',
      activities: <VisualLabActivity>[
        _act(id: 'med_diseases', subjectId: 'medicine', section: 'Pathology', title: 'Identify Diseases', description: 'Match histology and clinical presentations.', type: VisualLabActivityType.imageIdentification, availability: VisualLabAvailability.aiFallback),
        _act(id: 'med_tissue', subjectId: 'medicine', section: 'Pathology', title: 'Analyze Tissue Samples', description: 'Microscopy-based tissue diagnosis drills.', type: VisualLabActivityType.virtualLab, availability: VisualLabAvailability.aiFallback),
        _act(id: 'med_cases', subjectId: 'medicine', section: 'Pathology', title: 'Clinical Case Studies', description: 'Work through differential diagnosis cases.', type: VisualLabActivityType.practicalExam, availability: VisualLabAvailability.aiFallback),
      ],
    ),
    VisualLabSection(
      title: 'Surgery',
      activities: <VisualLabActivity>[
        _act(id: 'med_surgery_sim', subjectId: 'medicine', section: 'Surgery', title: 'Surgical Procedure Simulations', description: 'Step through sterile technique and key steps.', type: VisualLabActivityType.aiSimulation, availability: VisualLabAvailability.aiFallback),
        _act(id: 'med_instruments', subjectId: 'medicine', section: 'Surgery', title: 'Instrument Identification', description: 'Name scalpels, forceps, retractors, and clamps.', type: VisualLabActivityType.imageIdentification, availability: VisualLabAvailability.aiFallback),
        _act(id: 'med_surgical_plan', subjectId: 'medicine', section: 'Surgery', title: 'Surgical Planning', description: 'Plan approach, consent, and perioperative care.', type: VisualLabActivityType.practicalExam, availability: VisualLabAvailability.aiFallback),
      ],
    ),
    VisualLabSection(
      title: 'AI Teaching Hospital',
      activities: <VisualLabActivity>[
        _act(
          id: 'med_teaching_hospital',
          subjectId: 'medicine',
          section: 'AI Teaching Hospital',
          title: 'Walk the Hospital',
          description: 'ER, ICU, trauma, surgery, and pediatrics — AI doctors and patients interact live.',
          type: VisualLabActivityType.aiSimulation,
          simulationStyle: SimulationStyle.erEmergency,
        ),
      ],
    ),
  ];

  // ── Other professions (environment previews + AI fallback) ─────────────────
  static final List<VisualLabSection> _psychologySections = <VisualLabSection>[
    VisualLabSection(
      title: 'Counseling Skills',
      activities: <VisualLabActivity>[
        _act(id: 'psych_intake', subjectId: 'psychology', section: 'Counseling Skills', title: 'Client Intake Session', description: 'Conduct a structured intake with an AI client.', type: VisualLabActivityType.aiSimulation, simulationStyle: SimulationStyle.counseling),
        _act(id: 'psych_crisis', subjectId: 'psychology', section: 'Counseling Skills', title: 'Crisis Intervention', description: 'De-escalate and safety-plan with a distressed client.', type: VisualLabActivityType.aiSimulation, simulationStyle: SimulationStyle.counseling, availability: VisualLabAvailability.aiFallback),
      ],
    ),
  ];

  static final List<VisualLabSection> _lawSections = <VisualLabSection>[
    VisualLabSection(
      title: 'Trial Practice',
      activities: <VisualLabActivity>[
        _act(id: 'law_trial', subjectId: 'law', section: 'Trial Practice', title: 'Live Courtroom Case', description: 'Examine witnesses and argue before the judge.', type: VisualLabActivityType.aiSimulation, simulationStyle: SimulationStyle.courtroom),
        _act(id: 'law_evidence', subjectId: 'law', section: 'Trial Practice', title: 'Evidence Presentation', description: 'Lay foundation and introduce exhibits.', type: VisualLabActivityType.practicalExam, availability: VisualLabAvailability.aiFallback),
      ],
    ),
  ];

  static final List<VisualLabSection> _csSections = <VisualLabSection>[
    VisualLabSection(
      title: 'Tech Interview Room',
      activities: <VisualLabActivity>[
        _act(id: 'cs_interview', subjectId: 'computer_science', section: 'Tech Interview Room', title: 'Coding Interview', description: 'Solve problems with a live AI interviewer.', type: VisualLabActivityType.aiSimulation, simulationStyle: SimulationStyle.codingInterview),
        _act(id: 'cs_debug', subjectId: 'computer_science', section: 'Tech Interview Room', title: 'Debugging Session', description: 'Find and fix bugs under time pressure.', type: VisualLabActivityType.practicalExam, simulationStyle: SimulationStyle.debugging, availability: VisualLabAvailability.aiFallback),
        _act(id: 'cs_system_design', subjectId: 'computer_science', section: 'Tech Interview Room', title: 'System Design Room', description: 'Architect scalable systems on a whiteboard.', type: VisualLabActivityType.aiSimulation, simulationStyle: SimulationStyle.systemDesign, availability: VisualLabAvailability.aiFallback),
      ],
    ),
  ];

  static final List<VisualLabSection> _engineeringSections = <VisualLabSection>[
    VisualLabSection(
      title: 'Workshop',
      activities: <VisualLabActivity>[
        _act(id: 'eng_structures', subjectId: 'engineering', section: 'Workshop', title: 'Structural Analysis Lab', description: 'Evaluate beams, loads, and safety factors.', type: VisualLabActivityType.virtualLab, availability: VisualLabAvailability.aiFallback),
        _act(id: 'eng_machines', subjectId: 'engineering', section: 'Workshop', title: 'Machine Simulations', description: 'Prototype mechanisms and test performance.', type: VisualLabActivityType.virtualLab, availability: VisualLabAvailability.aiFallback),
      ],
    ),
  ];

  static final List<VisualLabSection> _businessSections = <VisualLabSection>[
    VisualLabSection(
      title: 'Headquarters',
      activities: <VisualLabActivity>[
        _act(id: 'biz_pitch', subjectId: 'business', section: 'Headquarters', title: 'Investor Pitch', description: 'Present your startup to AI investors.', type: VisualLabActivityType.aiSimulation, simulationStyle: SimulationStyle.customerScenario),
        _act(id: 'biz_negotiation', subjectId: 'business', section: 'Headquarters', title: 'Deal Negotiation', description: 'Negotiate terms with an AI executive team.', type: VisualLabActivityType.aiSimulation, availability: VisualLabAvailability.aiFallback),
      ],
    ),
  ];
}
