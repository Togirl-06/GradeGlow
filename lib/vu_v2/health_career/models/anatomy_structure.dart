/// Selectable anatomical structure for the AnatomyViewer.
class AnatomyStructure {
  const AnatomyStructure({
    required this.id,
    required this.name,
    required this.system,
    required this.functionNote,
    required this.locationNote,
    required this.educationNotes,
    required this.hotspot,
    this.assetKey = 'body',
  });

  final String id;
  final String name;
  final String system;
  final String functionNote;
  final String locationNote;
  final String educationNotes;
  /// Normalized rect on fallback viewer (0–1): left, top, width, height.
  final (double, double, double, double) hotspot;
  /// Key into [MedAssetRegistry] mesh/image map.
  final String assetKey;
}

abstract final class AnatomyCatalog {
  static const List<AnatomyStructure> structures = <AnatomyStructure>[
    AnatomyStructure(
      id: 'heart',
      name: 'Heart',
      system: 'Circulatory',
      functionNote: 'Pumps blood through pulmonary and systemic circuits.',
      locationNote: 'Mediastinum, mostly left of midline behind the sternum.',
      educationNotes:
          'Four chambers and valves keep unidirectional flow. Coronary arteries '
          'supply myocardium. Educational model — not a diagnostic image.',
      hotspot: (0.42, 0.28, 0.16, 0.14),
      assetKey: 'heart',
    ),
    AnatomyStructure(
      id: 'lungs',
      name: 'Lungs',
      system: 'Respiratory',
      functionNote: 'Gas exchange between air and blood.',
      locationNote: 'Pleural cavities on either side of the mediastinum.',
      educationNotes:
          'Right lung has three lobes; left has two. Alveoli are the exchange surface.',
      hotspot: (0.28, 0.22, 0.44, 0.22),
      assetKey: 'respiratory',
    ),
    AnatomyStructure(
      id: 'brain',
      name: 'Brain',
      system: 'Nervous',
      functionNote: 'Central processing for sensation, movement, and cognition.',
      locationNote: 'Cranial cavity, protected by skull and meninges.',
      educationNotes:
          'Cerebrum, cerebellum, and brainstem form major regions. Clinical mapping is simplified here.',
      hotspot: (0.38, 0.02, 0.24, 0.12),
      assetKey: 'neuron',
    ),
    AnatomyStructure(
      id: 'liver',
      name: 'Liver',
      system: 'Digestive / Metabolic',
      functionNote: 'Metabolism, detoxification, and bile production.',
      locationNote: 'Right upper quadrant, under the diaphragm.',
      educationNotes:
          'Largest internal organ. Portal circulation delivers nutrients from gut.',
      hotspot: (0.48, 0.40, 0.22, 0.12),
      assetKey: 'organs',
    ),
    AnatomyStructure(
      id: 'kidneys',
      name: 'Kidneys',
      system: 'Urinary',
      functionNote: 'Filter blood, regulate fluid and electrolytes.',
      locationNote: 'Retroperitoneal, flanking the vertebral column.',
      educationNotes:
          'Nephrons filter plasma; urine drains via ureters to the bladder.',
      hotspot: (0.30, 0.42, 0.40, 0.10),
      assetKey: 'organs',
    ),
    AnatomyStructure(
      id: 'stomach',
      name: 'Stomach',
      system: 'Digestive',
      functionNote: 'Mechanical and chemical digestion of food.',
      locationNote: 'Left upper quadrant, continuous with esophagus and duodenum.',
      educationNotes:
          'Acid and enzymes begin protein digestion. Sphincters control transit.',
      hotspot: (0.34, 0.40, 0.18, 0.10),
      assetKey: 'organs',
    ),
    AnatomyStructure(
      id: 'intestines',
      name: 'Intestines',
      system: 'Digestive',
      functionNote: 'Nutrient absorption and waste formation.',
      locationNote: 'Abdominopelvic cavity, small then large bowel.',
      educationNotes:
          'Small intestine absorbs nutrients; large intestine recovers water.',
      hotspot: (0.32, 0.48, 0.36, 0.18),
      assetKey: 'organs',
    ),
    AnatomyStructure(
      id: 'skeleton',
      name: 'Skeleton',
      system: 'Musculoskeletal',
      functionNote: 'Support, protection, and levers for movement.',
      locationNote: 'Throughout the body; axial and appendicular divisions.',
      educationNotes:
          'Bones store minerals and house marrow. Landmarks guide clinical exams.',
      hotspot: (0.20, 0.08, 0.60, 0.80),
      assetKey: 'skeleton',
    ),
  ];

  static AnatomyStructure? byId(String id) {
    for (final AnatomyStructure s in structures) {
      if (s.id == id) return s;
    }
    return null;
  }
}
