class BiologyOrganelle {
  const BiologyOrganelle({
    required this.name,
    required this.function,
    required this.diseases,
    required this.color,
    required this.dx,
    required this.dy,
  });

  final String name;
  final String function;
  final String diseases;
  final ColorValue color;
  final double dx;
  final double dy;
}

/// Simple color holder so this file stays UI-agnostic for layouts that import Flutter Color.
class ColorValue {
  const ColorValue(this.value);
  final int value;
}

class BiologyModelAsset {
  const BiologyModelAsset({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.caption,
  });

  final String id;
  final String title;
  final String assetPath;
  final String caption;
}

class BiologyStudioData {
  BiologyStudioData._();

  static const List<BiologyOrganelle> animalCellOrganelles = <BiologyOrganelle>[
    BiologyOrganelle(
      name: 'Nucleus',
      function: 'Stores DNA; controls gene expression and cell activities.',
      diseases: 'Nuclear envelope defects; some cancers with genomic instability.',
      color: ColorValue(0xFF6366F1),
      dx: 0,
      dy: 0,
    ),
    BiologyOrganelle(
      name: 'Mitochondria',
      function: 'ATP production via cellular respiration.',
      diseases: 'Mitochondrial myopathies; energy metabolism disorders.',
      color: ColorValue(0xFFEF4444),
      dx: -0.55,
      dy: 0.35,
    ),
    BiologyOrganelle(
      name: 'Ribosomes',
      function: 'Protein synthesis (translate mRNA).',
      diseases: 'Ribosomopathies affecting blood and development.',
      color: ColorValue(0xFFF59E0B),
      dx: 0.5,
      dy: -0.4,
    ),
    BiologyOrganelle(
      name: 'Cell membrane',
      function: 'Selective barrier; receptors and transport proteins.',
      diseases: 'Channelopathies; membrane receptor disorders.',
      color: ColorValue(0xFF06B6D4),
      dx: 0.7,
      dy: 0.5,
    ),
    BiologyOrganelle(
      name: 'Endoplasmic reticulum',
      function: 'Protein folding (rough) and lipid synthesis (smooth).',
      diseases: 'ER stress related disease pathways.',
      color: ColorValue(0xFF10B981),
      dx: -0.45,
      dy: -0.45,
    ),
  ];

  static const List<BiologyModelAsset> models = <BiologyModelAsset>[
    BiologyModelAsset(
      id: 'animal_cell',
      title: 'Animal Cell',
      assetPath: 'assets/biology/animal_cell.svg',
      caption: 'Rotate · zoom · tap organelles',
    ),
    BiologyModelAsset(
      id: 'plant_cell',
      title: 'Plant Cell',
      assetPath: 'assets/biology/plant_cell.svg',
      caption: 'Chloroplasts · wall · vacuole',
    ),
    BiologyModelAsset(
      id: 'dna',
      title: 'DNA Double Helix',
      assetPath: 'assets/biology/dna.svg',
      caption: 'Unzip · replicate · mutate',
    ),
    BiologyModelAsset(
      id: 'chromosome',
      title: 'Chromosome',
      assetPath: 'assets/biology/chromosome.svg',
      caption: 'Packaging · genes · division',
    ),
    BiologyModelAsset(
      id: 'bacteria',
      title: 'Bacteria',
      assetPath: 'assets/biology/bacteria.svg',
      caption: 'Prokaryotic structure',
    ),
    BiologyModelAsset(
      id: 'human_body',
      title: 'Human Body',
      assetPath: 'assets/anatomy/human_body.svg',
      caption: 'Peel layers · systems',
    ),
    BiologyModelAsset(
      id: 'skeleton',
      title: 'Skeleton',
      assetPath: 'assets/anatomy/skeleton_real.png',
      caption: 'Bones · joints · landmarks',
    ),
    BiologyModelAsset(
      id: 'heart',
      title: 'Heart',
      assetPath: 'assets/anatomy/heart_real.png',
      caption: 'Chambers · valves · vessels',
    ),
    BiologyModelAsset(
      id: 'neuron',
      title: 'Neuron',
      assetPath: 'assets/anatomy/neuron_real.png',
      caption: 'Dendrites · axon · synapse',
    ),
    BiologyModelAsset(
      id: 'respiratory',
      title: 'Respiratory System',
      assetPath: 'assets/anatomy/respiratory_real.png',
      caption: 'Airways · lungs · gas exchange',
    ),
    BiologyModelAsset(
      id: 'organs',
      title: 'Organs',
      assetPath: 'assets/anatomy/organs_real.png',
      caption: 'Locate major organs',
    ),
  ];

  static BiologyModelAsset modelForTopic(String topic, String courseId) {
    final String t = topic.toLowerCase();
    final String c = courseId.toLowerCase();
    if (t.contains('dna') || t.contains('replication') || t.contains('gene') || c.contains('molecular')) {
      return models.firstWhere((BiologyModelAsset m) => m.id == 'dna');
    }
    if (t.contains('chromosome') || t.contains('mitosis') || t.contains('meiosis')) {
      return models.firstWhere((BiologyModelAsset m) => m.id == 'chromosome');
    }
    if (t.contains('plant') || t.contains('photosynthesis') || t.contains('leaf')) {
      return models.firstWhere((BiologyModelAsset m) => m.id == 'plant_cell');
    }
    if (t.contains('bacteria') || t.contains('prokary') || c.contains('micro')) {
      return models.firstWhere((BiologyModelAsset m) => m.id == 'bacteria');
    }
    if (t.contains('skeleton') || t.contains('bone') || t.contains('skeletal')) {
      return models.firstWhere((BiologyModelAsset m) => m.id == 'skeleton');
    }
    if (t.contains('heart') || t.contains('cardio') || t.contains('cardiac')) {
      return models.firstWhere((BiologyModelAsset m) => m.id == 'heart');
    }
    if (t.contains('neuron') || t.contains('nervous') || t.contains('neural') || t.contains('action potential')) {
      return models.firstWhere((BiologyModelAsset m) => m.id == 'neuron');
    }
    if (t.contains('respir') || t.contains('lung')) {
      return models.firstWhere((BiologyModelAsset m) => m.id == 'respiratory');
    }
    if (t.contains('organ') || t.contains('digest') || t.contains('anatomy') || c.contains('anatomy')) {
      if (t.contains('body') || c.contains('anatomy')) {
        return models.firstWhere((BiologyModelAsset m) => m.id == 'human_body');
      }
      return models.firstWhere((BiologyModelAsset m) => m.id == 'organs');
    }
    return models.firstWhere((BiologyModelAsset m) => m.id == 'animal_cell');
  }
}
