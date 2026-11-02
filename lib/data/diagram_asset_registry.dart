/// Bundled and remote diagram asset paths for every educational illustration.
class DiagramAssetRegistry {
  DiagramAssetRegistry._();

  /// Env key: `DIAGRAM_CDN_BASE_URL` (e.g. https://cdn.example.com/diagrams)
  static const String cdnEnvKey = 'DIAGRAM_CDN_BASE_URL';

  // ── Anatomy (real photographic / textbook plates — not cartoon SVGs) ───────
  static const String organs = 'assets/anatomy/organs_real.png';
  static const String skeleton = 'assets/anatomy/skeleton_real.png';
  static const String respiratory = 'assets/anatomy/respiratory_real.png';
  static const String neuron = 'assets/anatomy/neuron_real.png';
  static const String heart = 'assets/anatomy/heart_real.png';
  static const String humanBody = 'assets/anatomy/organs_labeled.png';

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
    'human_body': humanBody,
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

  /// Curated Wikimedia originals used when CDN is unset but we still want
  /// network-quality anatomy (fallback if a local PNG is missing).
  static const Map<String, String> anatomyNetworkFallback = <String, String>{
    'human_organs':
        'https://upload.wikimedia.org/wikipedia/commons/d/d9/Internal_organs.png',
    'heart_detail':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Diagram_of_the_human_heart_%28cropped%29.svg/1280px-Diagram_of_the_human_heart_%28cropped%29.svg.png',
    'respiratory':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Respiratory_system_complete_en.svg/1280px-Respiratory_system_complete_en.svg.png',
    'skeleton':
        'https://upload.wikimedia.org/wikipedia/commons/e/e2/Human_skeleton_front_numbered.png',
    'neuron':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Neuron_Hand-tuned.svg/1280px-Neuron_Hand-tuned.svg.png',
    'human_body':
        'https://upload.wikimedia.org/wikipedia/commons/a/a8/Human_body_and_internal_organs_with_labels.png',
  };

  static String bundledPath(String diagramId) =>
      bundledByDiagramId[diagramId] ?? animalCell;

  static String? remotePath(String diagramId) =>
      anatomyNetworkFallback.containsKey(diagramId)
          ? null // full URL handled separately
          : '$diagramId.svg';

  static String subjectFolder(String diagramId) {
    final String path = bundledPath(diagramId);
    if (path.contains('/anatomy/')) return 'anatomy';
    if (path.contains('/biology/')) return 'biology';
    if (path.contains('/chemistry/')) return 'chemistry';
    if (path.contains('/physics/')) return 'physics';
    return 'general';
  }
}
