import 'dart:math';

import 'package:flutter/material.dart';

import '../models/science_diagram.dart';
import '../utils/topic_keyword_matcher.dart';
import 'anatomy_assets.dart';
import '../models/topic_profile.dart';
import 'topic_profile_database.dart';
import 'diagram_asset_registry.dart';
import '../utils/diagram_question_prompts.dart';

/// Diagrams and quiz rounds for biology, chemistry, physics, nursing, and medicine.
class ScienceDiagramCatalog {
  ScienceDiagramCatalog._();

  static const Set<String> _diagramSubjects = <String>{
    'biology',
    'chemistry',
    'physics',
    'nursing',
    'medicine',
  };

  static final Map<String, ScienceDiagram> _diagrams = <String, ScienceDiagram>{
    'animal_cell': ScienceDiagram(
      id: 'animal_cell',
      title: 'Animal Cell',
      subtitle: 'Label organelles in a typical animal cell.',
      kind: ScienceDiagramKind.animalCell,
      assetPath: DiagramAssetRegistry.animalCell,
      regions: _animalCellRegions,
    ),
    'plant_cell': ScienceDiagram(
      id: 'plant_cell',
      title: 'Plant Cell',
      subtitle: 'Identify structures unique to plant cells.',
      kind: ScienceDiagramKind.plantCell,
      assetPath: DiagramAssetRegistry.plantCell,
      regions: _plantCellRegions,
    ),
    'atom': ScienceDiagram(
      id: 'atom',
      title: 'Atomic Structure',
      subtitle: 'Label subatomic particles and shells.',
      kind: ScienceDiagramKind.atom,
      assetPath: DiagramAssetRegistry.atom,
      regions: _atomRegions,
    ),
    'molecule': ScienceDiagram(
      id: 'molecule',
      title: 'Water Molecule',
      subtitle: 'Identify atoms and bonds in H₂O.',
      kind: ScienceDiagramKind.molecule,
      aspectRatio: 1.0,
      assetPath: DiagramAssetRegistry.molecule,
      regions: _moleculeRegions,
    ),
    'human_organs': ScienceDiagram(
      id: 'human_organs',
      title: 'Human Organs',
      subtitle: 'Tap each organ on the anatomical illustration.',
      kind: ScienceDiagramKind.humanOrgans,
      aspectRatio: 0.67,
      assetPath: DiagramAssetRegistry.organs,
      regions: _humanOrganRegions,
    ),
    'respiratory': ScienceDiagram(
      id: 'respiratory',
      title: 'Respiratory System',
      subtitle: 'Label nasal cavity, trachea, bronchi, lungs, and diaphragm.',
      kind: ScienceDiagramKind.respiratory,
      aspectRatio: 0.67,
      assetPath: DiagramAssetRegistry.respiratory,
      regions: _respiratoryRegions,
    ),
    'neuron': ScienceDiagram(
      id: 'neuron',
      title: 'Neuron',
      subtitle: 'Label parts of a nerve cell.',
      kind: ScienceDiagramKind.neuron,
      aspectRatio: 1.33,
      assetPath: DiagramAssetRegistry.neuron,
      regions: _neuronRegions,
    ),
    'skeleton': ScienceDiagram(
      id: 'skeleton',
      title: 'Human Skeleton',
      subtitle: 'Identify bones on the skeletal diagram.',
      kind: ScienceDiagramKind.skeleton,
      aspectRatio: 0.67,
      assetPath: DiagramAssetRegistry.skeleton,
      regions: _skeletonRegions,
    ),
    'heart_detail': ScienceDiagram(
      id: 'heart_detail',
      title: 'Heart Anatomy',
      subtitle: 'Label chambers, valves, and great vessels.',
      kind: ScienceDiagramKind.humanOrgans,
      aspectRatio: 1.0,
      assetPath: DiagramAssetRegistry.heart,
      regions: _heartRegions,
    ),
    'dc_circuit': ScienceDiagram(
      id: 'dc_circuit',
      title: 'DC Circuit',
      subtitle: 'Identify components in a simple circuit.',
      kind: ScienceDiagramKind.dcCircuit,
      aspectRatio: 1.0,
      assetPath: DiagramAssetRegistry.circuit,
      regions: _circuitRegions,
    ),
    'wave': ScienceDiagram(
      id: 'wave',
      title: 'Wave Properties',
      subtitle: 'Label amplitude, wavelength, and key points.',
      kind: ScienceDiagramKind.wave,
      aspectRatio: 1.2,
      assetPath: DiagramAssetRegistry.wave,
      regions: _waveRegions,
    ),
    'force': ScienceDiagram(
      id: 'force',
      title: 'Free-Body Diagram',
      subtitle: 'Identify forces acting on an object.',
      kind: ScienceDiagramKind.force,
      aspectRatio: 1.0,
      assetPath: DiagramAssetRegistry.forceDiagram,
      regions: _forceRegions,
    ),
    'dna': ScienceDiagram(
      id: 'dna',
      title: 'DNA Double Helix',
      subtitle: 'Label bases, backbone, and hydrogen bonds.',
      kind: ScienceDiagramKind.dna,
      aspectRatio: 0.85,
      assetPath: DiagramAssetRegistry.dna,
      regions: _dnaRegions,
    ),
    'chromosome': ScienceDiagram(
      id: 'chromosome',
      title: 'Chromosome',
      subtitle: 'Identify centromere, arms, and chromatids.',
      kind: ScienceDiagramKind.chromosome,
      aspectRatio: 1.2,
      assetPath: DiagramAssetRegistry.chromosome,
      regions: _chromosomeRegions,
    ),
    'bacteria': ScienceDiagram(
      id: 'bacteria',
      title: 'Bacterial Cell',
      subtitle: 'Label structures in a prokaryotic cell.',
      kind: ScienceDiagramKind.animalCell,
      assetPath: DiagramAssetRegistry.bacteria,
      regions: _bacteriaRegions,
    ),
  };

  static const List<ScienceDiagramRegion> _animalCellRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'nucleus', name: 'Nucleus', color: Color(0xFF7E57C2), center: Offset(0.5, 0.45), size: Size(0.22, 0.2), funFact: 'The nucleus stores DNA and controls cell activities.'),
    ScienceDiagramRegion(id: 'mitochondria', name: 'Mitochondria', color: Color(0xFFE57373), center: Offset(0.32, 0.58), size: Size(0.14, 0.08), funFact: 'Mitochondria are the powerhouse of the cell — they make ATP.'),
    ScienceDiagramRegion(id: 'ribosome', name: 'Ribosomes', color: Color(0xFF4DB6AC), center: Offset(0.68, 0.42), size: Size(0.1, 0.08), funFact: 'Ribosomes assemble proteins from mRNA instructions.'),
    ScienceDiagramRegion(id: 'er', name: 'Endoplasmic Reticulum', color: Color(0xFFFFB74D), center: Offset(0.58, 0.55), size: Size(0.2, 0.14), funFact: 'Rough ER has ribosomes; smooth ER makes lipids.'),
    ScienceDiagramRegion(id: 'golgi', name: 'Golgi Apparatus', color: Color(0xFF9575CD), center: Offset(0.72, 0.62), size: Size(0.14, 0.12), funFact: 'The Golgi packages and ships proteins.'),
    ScienceDiagramRegion(id: 'membrane', name: 'Cell Membrane', color: Color(0xFF64B5F6), center: Offset(0.5, 0.5), size: Size(0.88, 0.78), shape: ScienceRegionShape.ring, funFact: 'The membrane controls what enters and leaves the cell.'),
    ScienceDiagramRegion(id: 'lysosome', name: 'Lysosome', color: Color(0xFFA1887F), center: Offset(0.38, 0.72), size: Size(0.1, 0.09), funFact: 'Lysosomes digest waste with enzymes.'),
  ];

  static const List<ScienceDiagramRegion> _plantCellRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'cell_wall', name: 'Cell Wall', color: Color(0xFF8D6E63), center: Offset(0.5, 0.5), size: Size(0.92, 0.82), shape: ScienceRegionShape.ring, funFact: 'The rigid cell wall supports plant structure.'),
    ScienceDiagramRegion(id: 'chloroplast', name: 'Chloroplast', color: Color(0xFF66BB6A), center: Offset(0.34, 0.55), size: Size(0.18, 0.12), funFact: 'Chloroplasts capture light energy for photosynthesis.'),
    ScienceDiagramRegion(id: 'nucleus', name: 'Nucleus', color: Color(0xFF7E57C2), center: Offset(0.55, 0.42), size: Size(0.2, 0.18), funFact: 'Plant cells also have a nucleus controlling growth.'),
    ScienceDiagramRegion(id: 'vacuole', name: 'Central Vacuole', color: Color(0xFF4FC3F7), center: Offset(0.62, 0.62), size: Size(0.24, 0.22), funFact: 'The large vacuole stores water and maintains turgor pressure.'),
    ScienceDiagramRegion(id: 'mitochondria', name: 'Mitochondria', color: Color(0xFFE57373), center: Offset(0.42, 0.68), size: Size(0.12, 0.07), funFact: 'Plant cells use mitochondria for cellular respiration too.'),
  ];

  static const List<ScienceDiagramRegion> _atomRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'nucleus', name: 'Nucleus', color: Color(0xFFEF5350), center: Offset(0.5, 0.5), size: Size(0.16, 0.16), funFact: 'Protons and neutrons live in the nucleus.'),
    ScienceDiagramRegion(id: 'proton', name: 'Proton', color: Color(0xFFE53935), center: Offset(0.47, 0.48), size: Size(0.06, 0.06), funFact: 'Protons have a +1 charge.'),
    ScienceDiagramRegion(id: 'neutron', name: 'Neutron', color: Color(0xFF8D6E63), center: Offset(0.53, 0.52), size: Size(0.06, 0.06), funFact: 'Neutrons add mass without charge.'),
    ScienceDiagramRegion(id: 'electron', name: 'Electron', color: Color(0xFF42A5F5), center: Offset(0.78, 0.35), size: Size(0.07, 0.07), funFact: 'Electrons orbit in energy levels around the nucleus.'),
    ScienceDiagramRegion(id: 'shell', name: 'Electron Shell', color: Color(0xFF90CAF9), center: Offset(0.5, 0.5), size: Size(0.55, 0.55), shape: ScienceRegionShape.ring, funFact: 'Each shell holds a maximum number of electrons.'),
  ];

  static const List<ScienceDiagramRegion> _moleculeRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'oxygen', name: 'Oxygen Atom', color: Color(0xFFE53935), center: Offset(0.5, 0.32), size: Size(0.14, 0.14), funFact: 'Oxygen is more electronegative and pulls shared electrons closer.'),
    ScienceDiagramRegion(id: 'hydrogen_left', name: 'Hydrogen (left)', color: Color(0xFFEEEEEE), center: Offset(0.32, 0.62), size: Size(0.12, 0.12), funFact: 'Hydrogen bonds to oxygen at an angle near 104.5°.'),
    ScienceDiagramRegion(id: 'hydrogen_right', name: 'Hydrogen (right)', color: Color(0xFFE0E0E0), center: Offset(0.68, 0.62), size: Size(0.12, 0.12), funFact: 'Water is polar because oxygen pulls electrons unevenly.'),
    ScienceDiagramRegion(id: 'bond_left', name: 'Left O–H Bond', color: Color(0xFF81C784), center: Offset(0.4, 0.48), size: Size(0.1, 0.06), funFact: 'Covalent bonds share electron pairs between atoms.'),
    ScienceDiagramRegion(id: 'bond_right', name: 'Right O–H Bond', color: Color(0xFF66BB6A), center: Offset(0.6, 0.48), size: Size(0.1, 0.06), funFact: 'Polar bonds create partial charges (δ+ and δ−).'),
  ];

  static const List<ScienceDiagramRegion> _humanOrganRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'brain', name: 'Brain', color: Color(0xFFE8B4B8), center: Offset(0.5, 0.09), size: Size(0.22, 0.1), difficultyTier: 1, funFact: 'The brain coordinates thought, memory, and movement.'),
    ScienceDiagramRegion(id: 'heart', name: 'Heart', color: Color(0xFFC62828), center: Offset(0.5, 0.38), size: Size(0.2, 0.14), difficultyTier: 1, funFact: 'The heart pumps blood through the circulatory system.'),
    ScienceDiagramRegion(id: 'lungs', name: 'Lungs', color: Color(0xFFEF9A9A), center: Offset(0.5, 0.35), size: Size(0.42, 0.2), difficultyTier: 1, funFact: 'Gas exchange occurs in alveoli inside the lungs.'),
    ScienceDiagramRegion(id: 'liver', name: 'Liver', color: Color(0xFF8D6E63), center: Offset(0.45, 0.5), size: Size(0.28, 0.1), difficultyTier: 2, funFact: 'The liver detoxifies blood and stores glycogen.'),
    ScienceDiagramRegion(id: 'stomach', name: 'Stomach', color: Color(0xFFD4A574), center: Offset(0.55, 0.5), size: Size(0.18, 0.12), difficultyTier: 2, funFact: 'The stomach breaks down food with acid and enzymes.'),
    ScienceDiagramRegion(id: 'kidneys', name: 'Kidneys', color: Color(0xFF7B1FA2), center: Offset(0.5, 0.59), size: Size(0.28, 0.1), difficultyTier: 3, funFact: 'Kidneys filter blood and regulate fluid balance.'),
  ];

  static const List<ScienceDiagramRegion> _respiratoryRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'nasal', name: 'Nasal Cavity', color: Color(0xFFFFCC80), center: Offset(0.5, 0.08), size: Size(0.12, 0.06), difficultyTier: 2, funFact: 'Air is warmed and filtered in the nasal cavity.'),
    ScienceDiagramRegion(id: 'trachea', name: 'Trachea', color: Color(0xFF90CAF9), center: Offset(0.5, 0.2), size: Size(0.06, 0.14), difficultyTier: 1, funFact: 'The trachea is reinforced with cartilage rings.'),
    ScienceDiagramRegion(id: 'bronchi', name: 'Bronchi', color: Color(0xFF64B5F6), center: Offset(0.5, 0.32), size: Size(0.3, 0.08), difficultyTier: 2, funFact: 'Bronchi branch into smaller bronchioles in each lung.'),
    ScienceDiagramRegion(id: 'lungs', name: 'Lungs', color: Color(0xFFEF9A9A), center: Offset(0.5, 0.42), size: Size(0.44, 0.22), difficultyTier: 1, funFact: 'Alveoli provide a huge surface area for gas exchange.'),
    ScienceDiagramRegion(id: 'diaphragm', name: 'Diaphragm', color: Color(0xFFCE93D8), center: Offset(0.5, 0.72), size: Size(0.4, 0.08), difficultyTier: 3, funFact: 'The diaphragm contracts to draw air into the lungs.'),
  ];

  static const List<ScienceDiagramRegion> _neuronRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'dendrites', name: 'Dendrites', color: Color(0xFF4DB6AC), center: Offset(0.16, 0.5), size: Size(0.22, 0.35), difficultyTier: 1, funFact: 'Dendrites receive signals from other neurons.'),
    ScienceDiagramRegion(id: 'cell_body', name: 'Cell Body', color: Color(0xFF7E57C2), center: Offset(0.35, 0.5), size: Size(0.18, 0.28), difficultyTier: 1, funFact: 'The soma integrates incoming signals.'),
    ScienceDiagramRegion(id: 'axon', name: 'Axon', color: Color(0xFFFFB74D), center: Offset(0.62, 0.5), size: Size(0.28, 0.06), difficultyTier: 2, funFact: 'The axon transmits impulses away from the cell body.'),
    ScienceDiagramRegion(id: 'myelin', name: 'Myelin Sheath', color: Color(0xFFE0E0E0), center: Offset(0.62, 0.5), size: Size(0.22, 0.1), difficultyTier: 3, shape: ScienceRegionShape.ring, funFact: 'Myelin speeds up nerve signal conduction.'),
    ScienceDiagramRegion(id: 'terminal', name: 'Axon Terminals', color: Color(0xFF81C784), center: Offset(0.86, 0.5), size: Size(0.14, 0.22), difficultyTier: 2, funFact: 'Terminals release neurotransmitters at the synapse.'),
  ];

  static const List<ScienceDiagramRegion> _skeletonRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'skull', name: 'Skull', color: Color(0xFFECEFF1), center: Offset(0.5, 0.1), size: Size(0.22, 0.12), difficultyTier: 1, funFact: 'The skull protects the brain and forms the face.'),
    ScienceDiagramRegion(id: 'femur', name: 'Femur', color: Color(0xFFCFD8DC), center: Offset(0.5, 0.72), size: Size(0.16, 0.22), difficultyTier: 1, funFact: 'The femur is the longest and strongest bone in the body.'),
    ScienceDiagramRegion(id: 'ribs', name: 'Rib Cage', color: Color(0xFFB0BEC5), center: Offset(0.5, 0.3), size: Size(0.36, 0.14), difficultyTier: 2, funFact: 'Twelve pairs of ribs protect the heart and lungs.'),
    ScienceDiagramRegion(id: 'sternum', name: 'Sternum', color: Color(0xFFD7CCC8), center: Offset(0.5, 0.3), size: Size(0.06, 0.14), difficultyTier: 2, funFact: 'The sternum anchors the rib cage anteriorly.'),
    ScienceDiagramRegion(id: 'spine', name: 'Vertebral Column', color: Color(0xFF90A4AE), center: Offset(0.5, 0.38), size: Size(0.05, 0.35), difficultyTier: 2, funFact: 'The spine protects the spinal cord and supports posture.'),
    ScienceDiagramRegion(id: 'scapula', name: 'Scapula', color: Color(0xFFCFD8DC), center: Offset(0.35, 0.28), size: Size(0.12, 0.1), difficultyTier: 3, funFact: 'The shoulder blade connects the arm to the thorax.'),
    ScienceDiagramRegion(id: 'humerus', name: 'Humerus', color: Color(0xFFE0E0E0), center: Offset(0.32, 0.42), size: Size(0.08, 0.18), difficultyTier: 3, funFact: 'The humerus is the upper-arm bone between shoulder and elbow.'),
    ScienceDiagramRegion(id: 'pelvis', name: 'Pelvis', color: Color(0xFFB0BEC5), center: Offset(0.5, 0.52), size: Size(0.28, 0.1), difficultyTier: 3, funFact: 'The pelvis supports the spine and anchors leg muscles.'),
    ScienceDiagramRegion(id: 'tibia', name: 'Tibia', color: Color(0xFFECEFF1), center: Offset(0.5, 0.9), size: Size(0.12, 0.14), difficultyTier: 3, funFact: 'The tibia (shinbone) bears most of the lower-leg weight.'),
  ];

  static const List<ScienceDiagramRegion> _heartRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'right_atrium', name: 'Right Atrium', color: Color(0xFFC62828), center: Offset(0.35, 0.38), size: Size(0.18, 0.14), difficultyTier: 1, funFact: 'Receives deoxygenated blood from the body.'),
    ScienceDiagramRegion(id: 'left_atrium', name: 'Left Atrium', color: Color(0xFFAD1457), center: Offset(0.65, 0.38), size: Size(0.18, 0.14), difficultyTier: 1, funFact: 'Receives oxygenated blood from the lungs.'),
    ScienceDiagramRegion(id: 'right_ventricle', name: 'Right Ventricle', color: Color(0xFFD32F2F), center: Offset(0.38, 0.58), size: Size(0.2, 0.2), difficultyTier: 1, funFact: 'Pumps blood to the lungs via the pulmonary artery.'),
    ScienceDiagramRegion(id: 'left_ventricle', name: 'Left Ventricle', color: Color(0xFFB71C1C), center: Offset(0.62, 0.58), size: Size(0.2, 0.2), difficultyTier: 1, funFact: 'The thickest chamber — pumps blood to the entire body.'),
    ScienceDiagramRegion(id: 'mitral_valve', name: 'Mitral Valve', color: Color(0xFFFFF59D), center: Offset(0.58, 0.42), size: Size(0.1, 0.08), difficultyTier: 2, funFact: 'Between the left atrium and left ventricle (bicuspid valve).'),
    ScienceDiagramRegion(id: 'tricuspid_valve', name: 'Tricuspid Valve', color: Color(0xFFFFF59D), center: Offset(0.42, 0.42), size: Size(0.1, 0.08), difficultyTier: 2, funFact: 'Between the right atrium and right ventricle.'),
    ScienceDiagramRegion(id: 'pulmonary_artery', name: 'Pulmonary Artery', color: Color(0xFFE57373), center: Offset(0.42, 0.2), size: Size(0.12, 0.1), difficultyTier: 2, funFact: 'Carries deoxygenated blood from the right ventricle to the lungs.'),
    ScienceDiagramRegion(id: 'pulmonary_veins', name: 'Pulmonary Veins', color: Color(0xFF81C784), center: Offset(0.62, 0.2), size: Size(0.12, 0.1), difficultyTier: 2, funFact: 'Return oxygenated blood from the lungs to the left atrium.'),
    ScienceDiagramRegion(id: 'aorta', name: 'Aorta', color: Color(0xFFEF5350), center: Offset(0.55, 0.22), size: Size(0.14, 0.12), difficultyTier: 3, funFact: 'The largest artery — carries oxygenated blood from the heart.'),
  ];

  static const List<ScienceDiagramRegion> _bacteriaRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'cell_wall', name: 'Cell Wall', color: Color(0xFF66BB6A), center: Offset(0.5, 0.5), size: Size(0.7, 0.45), shape: ScienceRegionShape.ring, funFact: 'Provides shape and protection in bacteria.'),
    ScienceDiagramRegion(id: 'cytoplasm', name: 'Cytoplasm', color: Color(0xFF1B5E20), center: Offset(0.5, 0.5), size: Size(0.6, 0.35), funFact: 'Gel-like interior where metabolic reactions occur.'),
    ScienceDiagramRegion(id: 'nucleoid', name: 'Nucleoid', color: Color(0xFF7E57C2), center: Offset(0.5, 0.5), size: Size(0.28, 0.18), funFact: 'Region containing the bacterial chromosome (no membrane).'),
    ScienceDiagramRegion(id: 'ribosome', name: 'Ribosomes', color: Color(0xFF4DB6AC), center: Offset(0.36, 0.43), size: Size(0.08, 0.08), funFact: 'Smaller than eukaryotic ribosomes; site of protein synthesis.'),
    ScienceDiagramRegion(id: 'flagellum', name: 'Flagellum', color: Color(0xFF90CAF9), center: Offset(0.88, 0.5), size: Size(0.18, 0.12), funFact: 'Whip-like structure for motility in some bacteria.'),
  ];

  static const List<ScienceDiagramRegion> _circuitRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'battery', name: 'Battery', color: Color(0xFFFFB74D), center: Offset(0.18, 0.5), size: Size(0.14, 0.22), shape: ScienceRegionShape.rect, funFact: 'The battery provides voltage to drive current.'),
    ScienceDiagramRegion(id: 'switch', name: 'Switch', color: Color(0xFF90A4AE), center: Offset(0.38, 0.28), size: Size(0.12, 0.1), shape: ScienceRegionShape.rect, funFact: 'A closed switch completes the circuit.'),
    ScienceDiagramRegion(id: 'resistor', name: 'Resistor', color: Color(0xFF8D6E63), center: Offset(0.55, 0.5), size: Size(0.16, 0.1), shape: ScienceRegionShape.rect, funFact: 'Resistors limit current flow (V = IR).'),
    ScienceDiagramRegion(id: 'bulb', name: 'Light Bulb', color: Color(0xFFFFF176), center: Offset(0.78, 0.5), size: Size(0.14, 0.18), funFact: 'The bulb converts electrical energy to light and heat.'),
    ScienceDiagramRegion(id: 'wire', name: 'Conducting Wire', color: Color(0xFF78909C), center: Offset(0.5, 0.72), size: Size(0.6, 0.06), funFact: 'Wires provide a low-resistance path for electrons.'),
  ];

  static const List<ScienceDiagramRegion> _waveRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'crest', name: 'Crest', color: Color(0xFF42A5F5), center: Offset(0.35, 0.32), size: Size(0.1, 0.1), funFact: 'The crest is the maximum displacement above equilibrium.'),
    ScienceDiagramRegion(id: 'trough', name: 'Trough', color: Color(0xFF1E88E5), center: Offset(0.65, 0.68), size: Size(0.1, 0.1), funFact: 'The trough is the minimum displacement below equilibrium.'),
    ScienceDiagramRegion(id: 'amplitude', name: 'Amplitude', color: Color(0xFF66BB6A), center: Offset(0.2, 0.5), size: Size(0.08, 0.28), funFact: 'Amplitude measures maximum displacement from rest.'),
    ScienceDiagramRegion(id: 'wavelength', name: 'Wavelength', color: Color(0xFFFFB74D), center: Offset(0.5, 0.88), size: Size(0.35, 0.08), funFact: 'Wavelength (λ) is the distance between consecutive crests.'),
    ScienceDiagramRegion(id: 'equilibrium', name: 'Equilibrium Line', color: Color(0xFFB0BEC5), center: Offset(0.5, 0.5), size: Size(0.9, 0.04), funFact: 'The equilibrium position is where the medium would rest.'),
  ];

  static const List<ScienceDiagramRegion> _forceRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'weight', name: 'Weight (Fg)', color: Color(0xFFEF5350), center: Offset(0.5, 0.72), size: Size(0.1, 0.18), funFact: 'Weight acts downward: Fg = mg.'),
    ScienceDiagramRegion(id: 'normal', name: 'Normal Force', color: Color(0xFF42A5F5), center: Offset(0.5, 0.38), size: Size(0.1, 0.16), funFact: 'The normal force is perpendicular to the surface.'),
    ScienceDiagramRegion(id: 'applied', name: 'Applied Force', color: Color(0xFF66BB6A), center: Offset(0.78, 0.5), size: Size(0.18, 0.08), funFact: 'Applied force is an external push or pull on the object.'),
    ScienceDiagramRegion(id: 'friction', name: 'Friction', color: Color(0xFFFFB74D), center: Offset(0.22, 0.5), size: Size(0.16, 0.08), funFact: 'Friction opposes motion parallel to the contact surface.'),
    ScienceDiagramRegion(id: 'object', name: 'Object', color: Color(0xFF90A4AE), center: Offset(0.5, 0.55), size: Size(0.22, 0.16), shape: ScienceRegionShape.rect, funFact: 'Draw all forces on the object, not the surroundings.'),
  ];

  static const List<ScienceDiagramRegion> _dnaRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'backbone', name: 'Sugar-Phosphate Backbone', color: Color(0xFF5C6BC0), center: Offset(0.28, 0.5), size: Size(0.12, 0.7), funFact: 'The backbone alternates deoxyribose sugar and phosphate groups.'),
    ScienceDiagramRegion(id: 'adenine', name: 'Adenine (A)', color: Color(0xFF66BB6A), center: Offset(0.42, 0.32), size: Size(0.1, 0.1), funFact: 'Adenine pairs with thymine via two hydrogen bonds.'),
    ScienceDiagramRegion(id: 'thymine', name: 'Thymine (T)', color: Color(0xFFEF5350), center: Offset(0.58, 0.32), size: Size(0.1, 0.1), funFact: 'Thymine is unique to DNA (uracil replaces it in RNA).'),
    ScienceDiagramRegion(id: 'guanine', name: 'Guanine (G)', color: Color(0xFF42A5F5), center: Offset(0.42, 0.62), size: Size(0.1, 0.1), funFact: 'Guanine pairs with cytosine via three hydrogen bonds.'),
    ScienceDiagramRegion(id: 'cytosine', name: 'Cytosine (C)', color: Color(0xFFFFB74D), center: Offset(0.58, 0.62), size: Size(0.1, 0.1), funFact: 'C-G pairs are stronger than A-T pairs due to extra hydrogen bond.'),
    ScienceDiagramRegion(id: 'h_bond', name: 'Hydrogen Bond', color: Color(0xFFE1BEE7), center: Offset(0.5, 0.32), size: Size(0.08, 0.06), funFact: 'Hydrogen bonds hold complementary base pairs together.'),
    ScienceDiagramRegion(id: 'helix', name: 'Double Helix', color: Color(0xFF90CAF9), center: Offset(0.72, 0.5), size: Size(0.2, 0.75), shape: ScienceRegionShape.ring, funFact: 'Watson and Crick described DNA as a right-handed double helix.'),
  ];

  static const List<ScienceDiagramRegion> _chromosomeRegions = <ScienceDiagramRegion>[
    ScienceDiagramRegion(id: 'centromere', name: 'Centromere', color: Color(0xFF7E57C2), center: Offset(0.5, 0.42), size: Size(0.08, 0.12), funFact: 'The centromere holds sister chromatids together.'),
    ScienceDiagramRegion(id: 'short_arm', name: 'Short Arm (p)', color: Color(0xFF42A5F5), center: Offset(0.35, 0.35), size: Size(0.22, 0.14), funFact: 'The short arm is labeled p (petit).'),
    ScienceDiagramRegion(id: 'long_arm', name: 'Long Arm (q)', color: Color(0xFF66BB6A), center: Offset(0.65, 0.55), size: Size(0.28, 0.16), funFact: 'The long arm is labeled q (next letter after p).'),
    ScienceDiagramRegion(id: 'chromatid_left', name: 'Sister Chromatid', color: Color(0xFFEF9A9A), center: Offset(0.42, 0.5), size: Size(0.14, 0.5), funFact: 'Sister chromatids are identical copies joined at the centromere.'),
    ScienceDiagramRegion(id: 'chromatid_right', name: 'Sister Chromatid', color: Color(0xFFE57373), center: Offset(0.58, 0.5), size: Size(0.14, 0.5), funFact: 'They separate during anaphase of mitosis.'),
    ScienceDiagramRegion(id: 'telomere', name: 'Telomere', color: Color(0xFFFFB74D), center: Offset(0.78, 0.28), size: Size(0.1, 0.08), funFact: 'Telomeres protect chromosome ends from degradation.'),
  ];

  static bool supportsSubject(String subjectId) => _diagramSubjects.contains(subjectId);

  static ScienceDiagram? diagramById(String id) => _diagrams[id];

  static ScienceDiagramRegion? regionById(ScienceDiagram diagram, String id) {
    for (final ScienceDiagramRegion region in diagram.regions) {
      if (region.id == id) return region;
    }
    return null;
  }

  static String? diagramIdFor({
    required String subjectId,
    required String courseId,
    required String topicId,
    required String topicName,
  }) {
    if (!_diagramSubjects.contains(subjectId)) return null;

    final TopicKeywordMatcher matcher = TopicKeywordMatcher(
      topicId: topicId,
      topicName: topicName,
      subjectId: subjectId,
      courseId: courseId,
    );

    if (_exactTopicDiagram.containsKey(topicId)) {
      final String id = _exactTopicDiagram[topicId]!;
      if (id == 'skeleton' && matcher.excludesBoneContent) {
        return _clampDiagramToProfile(
          _nonBoneFallback(subjectId, courseId, matcher),
          subjectId: subjectId,
          courseId: courseId,
          topicId: topicId,
          topicName: topicName,
        );
      }
      return _clampDiagramToProfile(
        id,
        subjectId: subjectId,
        courseId: courseId,
        topicId: topicId,
        topicName: topicName,
      );
    }

    String? matchRules(Iterable<MapEntry<String, List<String>>> rules) {
      for (final MapEntry<String, List<String>> rule in rules) {
        if (rule.key == 'skeleton' && matcher.excludesBoneContent) continue;
        for (final String keyword in rule.value) {
          if (matcher.matches(keyword)) return rule.key;
        }
      }
      return null;
    }

    final String? explicit = matchRules(<MapEntry<String, List<String>>>[
      const MapEntry<String, List<String>>('plant_cell', <String>['plant_cell', 'plant', 'chloroplast', 'photosynth', 'cell_wall']),
      const MapEntry<String, List<String>>('bacteria', <String>['bacteria', 'bacterial', 'prokaryote', 'microbiology', 'pathogen', 'gram_positive', 'gram_negative']),
      const MapEntry<String, List<String>>('animal_cell', <String>['organelle', 'organelles', 'eukaryotic', 'cell_structure', 'apoptosis', 'protein_synthesis', 'ribosome', 'membrane_transport', 'endocytosis', 'exocytosis']),
      const MapEntry<String, List<String>>('dna', <String>['dna', 'double_helix', 'nucleotide', 'replication', 'transcription', 'translation', 'crispr', 'epigenetic']),
      const MapEntry<String, List<String>>('chromosome', <String>['chromosome', 'karyotype', 'mitosis', 'meiosis', 'cell_cycle', 'cell_division']),
      const MapEntry<String, List<String>>('neuron', <String>['neuron', 'nerve', 'synapse', 'action_potential', 'neuroanatomy', 'cranial', 'nervous_system', 'neural']),
      const MapEntry<String, List<String>>('human_organs', <String>['digestive', 'renal', 'kidney', 'liver', 'stomach', 'abdominal', 'viscera', 'endocrine', 'lymphatic']),
      const MapEntry<String, List<String>>('heart_detail', <String>['heart', 'cardiac', 'chamber', 'aorta', 'ventricle', 'atrium', 'cardiovascular', 'cardiology', 'cardiac_cycle']),
      const MapEntry<String, List<String>>('respiratory', <String>['respiratory', 'lung', 'breath', 'ventilat', 'pulmon', 'copd', 'gas_exchange']),
      const MapEntry<String, List<String>>('skeleton', <String>['skeletal', 'skeleton', 'bone', 'bones', 'musculoskeletal', 'orthopedic', 'fracture', 'skull', 'femur', 'limb_anatomy', 'joint_types', 'vertebral', 'brachial']),
      const MapEntry<String, List<String>>('atom', <String>['atomic', 'atom', 'electron', 'proton', 'periodic', 'quantum', 'nuclear', 'bohr', 'isotope']),
      const MapEntry<String, List<String>>('molecule', <String>['bonding', 'molecule', 'lewis', 'polar', 'ionic', 'covalent', 'functional_group', 'stoichiometry', 'vsepr']),
      const MapEntry<String, List<String>>('dc_circuit', <String>['circuit', 'electric', 'current', 'voltage', 'resistor', 'ohm', 'capacit', 'induct']),
      const MapEntry<String, List<String>>('wave', <String>['wave', 'sound', 'optic', 'frequency', 'interference', 'light', 'electromagnetic']),
      const MapEntry<String, List<String>>('force', <String>['force', 'newton', 'kinematic', 'projectile', 'friction', 'momentum', 'gravitation', 'torque']),
    ]);

    if (explicit != null) {
      return _clampDiagramToProfile(
        explicit,
        subjectId: subjectId,
        courseId: courseId,
        topicId: topicId,
        topicName: topicName,
      );
    }

    final String? courseDefault = _courseDefaultDiagram['$subjectId|$courseId'];
    if (courseDefault != null) {
      if (courseDefault == 'skeleton' && matcher.excludesBoneContent) {
        return _clampDiagramToProfile(
          _nonBoneFallback(subjectId, courseId, matcher),
          subjectId: subjectId,
          courseId: courseId,
          topicId: topicId,
          topicName: topicName,
        );
      }
      return _clampDiagramToProfile(
        courseDefault,
        subjectId: subjectId,
        courseId: courseId,
        topicId: topicId,
        topicName: topicName,
      );
    }

    return _clampDiagramToProfile(
      _nonBoneFallback(subjectId, courseId, matcher),
      subjectId: subjectId,
      courseId: courseId,
      topicId: topicId,
      topicName: topicName,
    );
  }

  static String? _clampDiagramToProfile(
    String? diagramId, {
    required String subjectId,
    required String courseId,
    required String topicId,
    required String topicName,
  }) {
    if (diagramId == null) return null;
    final TopicProfile profile = TopicProfileDatabase.resolve(
      topicId: topicId,
      topicName: topicName,
      subjectId: subjectId,
      courseId: courseId,
    );
    if (profile.allowedDiagramIds.isEmpty) return diagramId;
    if (profile.allowedDiagramIds.contains(diagramId)) return diagramId;
    return profile.allowedDiagramIds.first;
  }

  static String _nonBoneFallback(String subjectId, String courseId, TopicKeywordMatcher matcher) {
    if (matcher.isOrganelleOrCellTopic) return 'animal_cell';
    if (matcher.matchesAny(const <String>['dna', 'genetic', 'mendelian', 'inheritance'])) return 'dna';
    if (matcher.matchesAny(const <String>['mitosis', 'meiosis', 'chromosome', 'cell_division'])) return 'chromosome';
    if (matcher.matchesAny(const <String>['heart', 'cardiac', 'cardiovascular'])) return 'heart_detail';
    if (matcher.matchesAny(const <String>['respiratory', 'lung', 'pulmon'])) return 'respiratory';
    if (matcher.matchesAny(const <String>['neuron', 'nervous', 'neuro'])) return 'neuron';
    if (matcher.isBoneAnatomyTopic) return 'skeleton';
    return switch (subjectId) {
      'biology' => 'animal_cell',
      'chemistry' => 'atom',
      'physics' => 'force',
      'nursing' => 'human_organs',
      'medicine' => 'human_organs',
      _ => 'animal_cell',
    };
  }

  static List<ScienceDiagramRegion> regionsForTopic(
    ScienceDiagram diagram, {
    required String topicId,
    required String topicName,
    String? subjectId,
    String? courseId,
  }) {
    final TopicKeywordMatcher matcher = TopicKeywordMatcher(
      topicId: topicId,
      topicName: topicName,
      subjectId: subjectId,
      courseId: courseId,
    );

    if (diagram.id == 'skeleton' && matcher.excludesBoneContent) {
      return diagram.regions.where((ScienceDiagramRegion r) => false).toList();
    }

    List<String>? regionIds = _topicRegionFilter[topicId];
    if (regionIds == null) {
      for (final MapEntry<String, List<String>> entry in _topicRegionFilter.entries) {
        if (entry.key == 'skeletal' && matcher.excludesBoneContent) continue;
        if (matcher.matches(entry.key)) {
          regionIds = entry.value;
          break;
        }
      }
    }
    if (regionIds == null || regionIds.isEmpty) return diagram.regions;

    final Set<String> allowed = regionIds.toSet();
    final List<ScienceDiagramRegion> filtered =
        diagram.regions.where((ScienceDiagramRegion r) => allowed.contains(r.id)).toList();
    return filtered.length >= 2 ? filtered : diagram.regions;
  }

  static const Map<String, String> _exactTopicDiagram = <String, String>{
    'cell_membrane': 'animal_cell',
    'cell_membrane_transport': 'animal_cell',
    'organelles': 'animal_cell',
    'organelle_function': 'animal_cell',
    'cell_structure': 'animal_cell',
    'cell_communication': 'neuron',
    'signal_transduction': 'neuron',
    'cell_cycle': 'chromosome',
    'cell_division': 'chromosome',
    'mitosis_meiosis': 'chromosome',
    'apoptosis': 'animal_cell',
    'dna_structure': 'dna',
    'replication': 'dna',
    'dna_replication': 'dna',
    'transcription': 'dna',
    'translation': 'dna',
    'transcription_translation': 'dna',
    'mendelian_genetics': 'dna',
    'mendelian_inheritance': 'dna',
    'genetics': 'dna',
    'genetics_intro': 'dna',
    'photosynthesis': 'plant_cell',
    'skeletal_system': 'skeleton',
    'musculoskeletal': 'skeleton',
    'muscular_system': 'skeleton',
    'cardiovascular_anatomy': 'heart_detail',
    'cardiovascular_system': 'heart_detail',
    'cardiac_anatomy': 'heart_detail',
    'cardiology': 'heart_detail',
    'heart_failure': 'heart_detail',
    'cardiac_cycle': 'heart_detail',
    'nervous_system': 'neuron',
    'neuroanatomy': 'neuron',
    'neural_signaling': 'neuron',
    'neurological_exam': 'neuron',
    'neurological_assessment': 'neuron',
    'respiratory_system': 'respiratory',
    'respiratory_gas_exchange': 'respiratory',
    'respiratory_assessment': 'respiratory',
    'pulmonary_physiology': 'respiratory',
    'pulmonology': 'respiratory',
    'copd': 'respiratory',
    'digestive_tract': 'human_organs',
    'renal_anatomy': 'human_organs',
    'atomic_structure': 'atom',
    'periodic_trends': 'atom',
    'chemical_bonding': 'molecule',
    'stoichiometry': 'molecule',
    'lewis_structures': 'molecule',
    'circuits': 'dc_circuit',
    'circuit_analysis': 'dc_circuit',
    'ohms_law': 'dc_circuit',
    'electric_fields': 'dc_circuit',
    'ac_circuits': 'dc_circuit',
    'forces': 'force',
    'newtons_laws': 'force',
    'motion': 'force',
    'kinematics': 'force',
    'work_energy': 'force',
    'momentum': 'force',
    'vital_signs': 'human_organs',
    'head_to_toe_assessment': 'human_organs',
    'cardiovascular_assessment': 'heart_detail',
    'cardiovascular_exam': 'heart_detail',
  };

  static const Map<String, String> _courseDefaultDiagram = <String, String>{
    'biology|cell_biology': 'animal_cell',
    'biology|genetics': 'dna',
    'biology|anatomy': 'human_organs',
    'biology|physiology': 'human_organs',
    'biology|microbiology': 'bacteria',
    'chemistry|general_chemistry': 'atom',
    'chemistry|organic_chemistry': 'molecule',
    'chemistry|biochemistry': 'molecule',
    'physics|mechanics': 'force',
    'physics|electricity_magnetism': 'dc_circuit',
    'physics|thermodynamics': 'wave',
    'physics|modern_physics': 'atom',
    'nursing|health_assessment': 'human_organs',
    'nursing|medical_surgical_nursing': 'heart_detail',
    'medicine|anatomy': 'human_organs',
    'medicine|physiology': 'heart_detail',
    'medicine|internal_medicine': 'heart_detail',
  };

  static const Map<String, List<String>> _topicRegionFilter = <String, List<String>>{
    'cell_membrane': <String>['membrane'],
    'cell_membrane_transport': <String>['membrane'],
    'membrane_transport': <String>['membrane'],
    'organelles': <String>['nucleus', 'mitochondria', 'ribosome', 'er', 'golgi', 'lysosome'],
    'organelle_function': <String>['nucleus', 'mitochondria', 'ribosome', 'er', 'golgi', 'lysosome'],
    'cell_structure': <String>['nucleus', 'mitochondria', 'ribosome', 'er', 'golgi', 'membrane', 'lysosome'],
    'photosynthesis': <String>['chloroplast', 'cell_wall', 'vacuole', 'nucleus'],
    'cell_cycle': <String>['centromere', 'chromatid_left', 'chromatid_right', 'telomere'],
    'cell_division': <String>['centromere', 'chromatid_left', 'chromatid_right', 'short_arm', 'long_arm'],
    'mitosis': <String>['centromere', 'chromatid_left', 'chromatid_right'],
    'meiosis': <String>['centromere', 'chromatid_left', 'chromatid_right', 'telomere'],
    'dna_structure': <String>['backbone', 'adenine', 'thymine', 'guanine', 'cytosine', 'h_bond', 'helix'],
    'replication': <String>['backbone', 'adenine', 'thymine', 'guanine', 'cytosine', 'helix'],
    'dna_replication': <String>['backbone', 'adenine', 'thymine', 'guanine', 'cytosine', 'helix'],
    'transcription': <String>['backbone', 'adenine', 'thymine', 'guanine', 'cytosine'],
    'mendelian': <String>['adenine', 'thymine', 'guanine', 'cytosine', 'helix'],
    'atomic_structure': <String>['nucleus', 'proton', 'neutron', 'electron', 'shell'],
    'periodic_trends': <String>['nucleus', 'electron', 'shell'],
    'chemical_bonding': <String>['oxygen', 'hydrogen_left', 'hydrogen_right', 'bond_left', 'bond_right'],
    'stoichiometry': <String>['oxygen', 'hydrogen_left', 'hydrogen_right', 'bond_left', 'bond_right'],
    'circuits': <String>['battery', 'switch', 'resistor', 'bulb', 'wire'],
    'ohms_law': <String>['battery', 'resistor', 'bulb', 'wire'],
    'forces': <String>['weight', 'normal', 'applied', 'friction', 'object'],
    'kinematics': <String>['weight', 'normal', 'applied', 'object'],
    'skeletal': <String>['skull', 'femur', 'ribs', 'sternum', 'spine', 'scapula', 'humerus', 'pelvis', 'tibia'],
    'respiratory': <String>['nasal', 'trachea', 'bronchi', 'lungs', 'diaphragm'],
    'cardiovascular': <String>['right_atrium', 'left_atrium', 'right_ventricle', 'left_ventricle', 'aorta', 'pulmonary_artery', 'pulmonary_veins', 'mitral_valve', 'tricuspid_valve'],
    'neuron': <String>['dendrites', 'cell_body', 'axon', 'myelin', 'terminal'],
    'digestive': <String>['stomach', 'liver', 'kidneys'],
    'renal': <String>['kidneys'],
  };

  static ScienceDiagram resolveForTopic({
    required String subjectId,
    required String courseId,
    required String topicId,
    required String topicName,
  }) {
    final String id = diagramIdFor(
          subjectId: subjectId,
          courseId: courseId,
          topicId: topicId,
          topicName: topicName,
        ) ??
        'animal_cell';
    return _diagrams[id] ?? _diagrams['animal_cell']!;
  }

  static int roundTargetForDifficulty(String? difficultyLabel) {
    final String d = (difficultyLabel ?? '').toLowerCase();
    if (d.contains('adv')) return 30;
    if (d.contains('inter')) return 22;
    return 14;
  }

  /// Unique questions for a session — one tap + one name match per structure (plus typing at higher levels).
  static int sessionQuestionCount({
    required ScienceDiagram diagram,
    String? difficultyLabel,
    bool preferTypeEntry = false,
    String? topicId,
    String? topicName,
    String? subjectId,
    String? courseId,
  }) {
    return buildRoundDeck(
      diagram: diagram,
      seed: 'count',
      difficultyLabel: difficultyLabel,
      preferTypeEntry: preferTypeEntry,
      topicId: topicId,
      topicName: topicName,
      subjectId: subjectId,
      courseId: courseId,
    ).length;
  }

  static List<ScienceDiagramQuestion> buildRoundDeck({
    required ScienceDiagram diagram,
    required String seed,
    bool preferTypeEntry = false,
    String? difficultyLabel,
    String? topicId,
    String? topicName,
    String? subjectId,
    String? courseId,
  }) {
    final Random random = Random(seed.hashCode);
    final List<ScienceDiagramRegion> topicPool = topicId != null && topicName != null
        ? regionsForTopic(
            diagram,
            topicId: topicId,
            topicName: topicName,
            subjectId: subjectId,
            courseId: courseId,
          )
        : diagram.regions;
    final List<ScienceDiagramRegion> basePool =
        topicPool.isEmpty ? diagram.regions : topicPool;
    final int maxTier = AnatomyAssets.maxTierForDifficulty(difficultyLabel);
    final List<ScienceDiagramRegion> tierPool = basePool
        .where((ScienceDiagramRegion r) => r.difficultyTier <= maxTier)
        .toList();
    final List<ScienceDiagramRegion> activePool = tierPool.length >= 2 ? tierPool : basePool;

    activePool.sort((ScienceDiagramRegion a, ScienceDiagramRegion b) {
      final int tierCmp = a.difficultyTier.compareTo(b.difficultyTier);
      if (tierCmp != 0) return tierCmp;
      return a.name.compareTo(b.name);
    });

    final String difficulty = (difficultyLabel ?? '').toLowerCase();
    final bool includeTypeName = preferTypeEntry || difficulty.contains('inter') || difficulty.contains('adv');
    final List<ScienceDiagramRegion> shuffledPool = List<ScienceDiagramRegion>.from(activePool)..shuffle(random);
    final List<ScienceDiagramQuestion> questions = <ScienceDiagramQuestion>[];

    for (final ScienceDiagramRegion target in shuffledPool) {
      questions.add(
        DiagramQuestionPrompts.uniqueQuestionForRegion(
          target: target,
          diagram: diagram,
          activePool: activePool,
          random: random,
          allowTypeName: includeTypeName,
          buildOptions: uniqueMcqOptions,
        ),
      );
    }

    questions.shuffle(random);
    return questions;
  }

  /// Distinct MCQ choices — never repeats the same label to fill four slots.
  static List<String> uniqueMcqOptions({
    required String correctName,
    required List<ScienceDiagramRegion> pool,
    required String targetRegionId,
    required Random random,
    int maxOptions = 4,
  }) {
    final List<String> options = <String>[correctName];
    final List<ScienceDiagramRegion> others = pool.where((ScienceDiagramRegion r) => r.id != targetRegionId).toList()
      ..shuffle(random);
    for (final ScienceDiagramRegion region in others) {
      if (options.length >= maxOptions) break;
      if (!options.contains(region.name)) options.add(region.name);
    }
    options.shuffle(random);
    return options;
  }
}
