/// Bundled and remote diagram asset paths for every educational illustration.
class DiagramAssetRegistry {
  DiagramAssetRegistry._();

  /// Env key: `DIAGRAM_CDN_BASE_URL` (e.g. https://cdn.example.com/diagrams)
  static const String cdnEnvKey = 'DIAGRAM_CDN_BASE_URL';

  // ── Anatomy ────────────────────────────────────────────────────────────────
  static const String organs = 'assets/anatomy/organs.svg';
  static const String skeleton = 'assets/anatomy/skeleton.svg';
  static const String respiratory = 'assets/anatomy/respiratory.svg';
  static const String neuron = 'assets/anatomy/neuron.svg';
  static const String heart = 'assets/anatomy/heart.svg';
  static const String humanBody = 'assets/anatomy/human_body.svg';

  // ── Biology ────────────────────────────────────────────────────────────────
  static const String animalCell = 'assets/biology/animal_cell.svg';
  static const String plantCell = 'assets/biology/plant_cell.svg';
  static const String dna = 'assets/biology/dna.svg';
  static const String chromosome = 'assets/biology/chromosome.svg';
  static const String bacteria = 'assets/biology/bacteria.svg';

  // ── Chemistry ──────────────────────────────────────────────────────────────
  static const String atom = 'assets/chemistry/atom.svg';
  static const String molecule = 'assets/chemistry/molecule.svg';
  static const String labEquipment = 'assets/chemistry/laboratory_equipment.svg';

  // ── Physics ────────────────────────────────────────────────────────────────
  static const String circuit = 'assets/physics/circuit.svg';
  static const String forceDiagram = 'assets/physics/force_diagram.svg';
  static const String wave = 'assets/physics/wave.svg';

  static const Map<String, String> bundledByDiagramId = <String, String>{
    'human_organs': organs,
    'skeleton': skeleton,
    'respiratory': respiratory,
    'neuron': neuron,
    'heart_detail': heart,
    'animal_cell': animalCell,
    'plant_cell': plantCell,
    'dna': dna,
    'chromosome': chromosome,
    'bacteria': bacteria,
    'atom': atom,
    'molecule': molecule,
    'chem_equipment': labEquipment,
    'dc_circuit': circuit,
    'force': forceDiagram,
    'wave': wave,
  };

  static String bundledPath(String diagramId) =>
      bundledByDiagramId[diagramId] ?? animalCell;

  static String? remotePath(String diagramId) => '$diagramId.svg';

  static String subjectFolder(String diagramId) {
    final String path = bundledPath(diagramId);
    if (path.contains('/anatomy/')) return 'anatomy';
    if (path.contains('/biology/')) return 'biology';
    if (path.contains('/chemistry/')) return 'chemistry';
    if (path.contains('/physics/')) return 'physics';
    return 'general';
  }
}
