/// Licensed / attributed scientific assets for Virtual University labs.
///
/// Real photographs preferred for anatomy. Diagrams used when photos are
/// unavailable or when an educational schematic is clearer.
/// Never invent fake medical photos.
class ScienceLabAsset {
  const ScienceLabAsset({
    required this.id,
    required this.topic,
    required this.subject,
    required this.kind,
    required this.assetPath,
    required this.source,
    required this.license,
    this.attribution = '',
    this.diagramPath,
    this.notes = '',
  });

  final String id;
  final String topic;
  final String subject; // biology | chemistry | physics
  final ScienceAssetKind kind;
  final String assetPath;
  final String source;
  final String license;
  final String attribution;
  final String? diagramPath;
  final String notes;

  bool get isRaster =>
      assetPath.endsWith('.png') ||
      assetPath.endsWith('.jpg') ||
      assetPath.endsWith('.jpeg') ||
      assetPath.endsWith('.webp');
}

enum ScienceAssetKind {
  photograph,
  atlasIllustration,
  scientificDiagram,
  equipmentDiagram,
  histologyPlaceholder,
}

/// Catalog of bundled science visuals with source metadata.
abstract final class ScienceAssetCatalog {
  static const ScienceLabAsset heartPhoto = ScienceLabAsset(
    id: 'bio_heart_photo',
    topic: 'Human heart',
    subject: 'biology',
    kind: ScienceAssetKind.photograph,
    assetPath: 'assets/anatomy/heart_real.png',
    diagramPath: 'assets/anatomy/heart.svg',
    source: 'GradeGlow anatomy asset pack (educational plate)',
    license: 'Bundled for in-app education; replace with Wikimedia CC plate in production CDN',
    attribution: 'Internal educational anatomy plate — verify license before redistribution',
    notes: 'Prefer PHOTO for observation; DIAGRAM for numbered labeling.',
  );

  static const ScienceLabAsset organsPhoto = ScienceLabAsset(
    id: 'bio_organs_photo',
    topic: 'Internal organs',
    subject: 'biology',
    kind: ScienceAssetKind.photograph,
    assetPath: 'assets/anatomy/organs_real.png',
    diagramPath: 'assets/anatomy/organs.svg',
    source: 'GradeGlow anatomy asset pack',
    license: 'Bundled educational use',
    attribution: 'Internal educational plate',
  );

  static const ScienceLabAsset neuronPhoto = ScienceLabAsset(
    id: 'bio_neuron_photo',
    topic: 'Neuron',
    subject: 'biology',
    kind: ScienceAssetKind.photograph,
    assetPath: 'assets/anatomy/neuron_real.png',
    diagramPath: 'assets/anatomy/neuron.svg',
    source: 'GradeGlow anatomy asset pack',
    license: 'Bundled educational use',
    attribution: 'Internal educational plate',
  );

  static const ScienceLabAsset respiratoryPhoto = ScienceLabAsset(
    id: 'bio_respiratory_photo',
    topic: 'Respiratory system',
    subject: 'biology',
    kind: ScienceAssetKind.photograph,
    assetPath: 'assets/anatomy/respiratory_real.png',
    diagramPath: 'assets/anatomy/respiratory.svg',
    source: 'GradeGlow anatomy asset pack',
    license: 'Bundled educational use',
    attribution: 'Internal educational plate',
  );

  static const ScienceLabAsset animalCell = ScienceLabAsset(
    id: 'bio_animal_cell',
    topic: 'Animal cell',
    subject: 'biology',
    kind: ScienceAssetKind.scientificDiagram,
    assetPath: 'assets/biology/animal_cell.svg',
    source: 'GradeGlow biology diagrams',
    license: 'Bundled educational use',
    notes: 'Accurate educational schematic — not a micrograph.',
  );

  static const ScienceLabAsset plantCell = ScienceLabAsset(
    id: 'bio_plant_cell',
    topic: 'Plant cell',
    subject: 'biology',
    kind: ScienceAssetKind.scientificDiagram,
    assetPath: 'assets/biology/plant_cell.svg',
    source: 'GradeGlow biology diagrams',
    license: 'Bundled educational use',
  );

  static const ScienceLabAsset dna = ScienceLabAsset(
    id: 'bio_dna',
    topic: 'DNA',
    subject: 'biology',
    kind: ScienceAssetKind.scientificDiagram,
    assetPath: 'assets/biology/dna.svg',
    source: 'GradeGlow biology diagrams',
    license: 'Bundled educational use',
  );

  static const ScienceLabAsset chemEquipment = ScienceLabAsset(
    id: 'chem_equipment',
    topic: 'Laboratory glassware',
    subject: 'chemistry',
    kind: ScienceAssetKind.equipmentDiagram,
    assetPath: 'assets/chemistry/laboratory_equipment.svg',
    source: 'GradeGlow chemistry diagrams',
    license: 'Bundled educational use',
  );

  static const ScienceLabAsset molecule = ScienceLabAsset(
    id: 'chem_molecule',
    topic: 'Molecular structure',
    subject: 'chemistry',
    kind: ScienceAssetKind.scientificDiagram,
    assetPath: 'assets/chemistry/molecule.svg',
    source: 'GradeGlow chemistry diagrams',
    license: 'Bundled educational use',
  );

  static const ScienceLabAsset circuit = ScienceLabAsset(
    id: 'phys_circuit',
    topic: 'DC circuit',
    subject: 'physics',
    kind: ScienceAssetKind.equipmentDiagram,
    assetPath: 'assets/physics/circuit.svg',
    source: 'GradeGlow physics diagrams',
    license: 'Bundled educational use',
  );

  static const ScienceLabAsset force = ScienceLabAsset(
    id: 'phys_force',
    topic: 'Force diagram',
    subject: 'physics',
    kind: ScienceAssetKind.scientificDiagram,
    assetPath: 'assets/physics/force_diagram.svg',
    source: 'GradeGlow physics diagrams',
    license: 'Bundled educational use',
  );

  static const ScienceLabAsset wave = ScienceLabAsset(
    id: 'phys_wave',
    topic: 'Wave',
    subject: 'physics',
    kind: ScienceAssetKind.scientificDiagram,
    assetPath: 'assets/physics/wave.svg',
    source: 'GradeGlow physics diagrams',
    license: 'Bundled educational use',
  );

  static const List<ScienceLabAsset> all = <ScienceLabAsset>[
    heartPhoto,
    organsPhoto,
    neuronPhoto,
    respiratoryPhoto,
    animalCell,
    plantCell,
    dna,
    chemEquipment,
    molecule,
    circuit,
    force,
    wave,
  ];

  static ScienceLabAsset? byId(String id) {
    for (final ScienceLabAsset a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}
