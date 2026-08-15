/// Topic-aware interactive activity content for Biology lessons.
class BiologyLabelTarget {
  const BiologyLabelTarget({
    required this.id,
    required this.label,
    required this.hint,
    /// Relative position on the diagram (0–1 from top-left).
    this.ax,
    this.ay,
    /// Callout end offset from the hot spot (fraction of diagram size).
    this.calloutDx,
    this.calloutDy,
  });

  final String id;
  final String label;
  final String hint;
  final double? ax;
  final double? ay;
  final double? calloutDx;
  final double? calloutDy;

  double get posX => ax ?? 0.50;
  double get posY => ay ?? 0.50;
  double get lineDx => calloutDx ?? 0.22;
  double get lineDy => calloutDy ?? -0.18;
}

class BiologyDragItem {
  const BiologyDragItem({
    required this.id,
    required this.label,
    required this.matchId,
  });

  final String id;
  final String label;
  final String matchId;
}

class BiologyDragSlot {
  const BiologyDragSlot({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}

class BiologyInteractivePack {
  const BiologyInteractivePack({
    required this.title,
    required this.intro,
    required this.labels,
    required this.dragItems,
    required this.dragSlots,
    required this.animationPhases,
  });

  final String title;
  final String intro;
  final List<BiologyLabelTarget> labels;
  final List<BiologyDragItem> dragItems;
  final List<BiologyDragSlot> dragSlots;
  final List<String> animationPhases;
}

class BiologyInteractiveCatalog {
  BiologyInteractiveCatalog._();

  static BiologyInteractivePack forPath({
    required String topic,
    required String courseId,
  }) {
    final String t = topic.toLowerCase();
    final String c = courseId.toLowerCase();

    if (t.contains('heart') || t.contains('cardio') || t.contains('cardiac')) {
      return const BiologyInteractivePack(
        title: 'Human Heart',
        intro: 'Label chambers and vessels on the heart diagram.',
        labels: <BiologyLabelTarget>[
          BiologyLabelTarget(
            id: 'ra',
            label: 'Right atrium',
            hint: 'Receives deoxygenated blood',
            ax: 0.28,
            ay: 0.32,
            calloutDx: -0.2,
            calloutDy: -0.18,
          ),
          BiologyLabelTarget(
            id: 'rv',
            label: 'Right ventricle',
            hint: 'Pumps to lungs',
            ax: 0.32,
            ay: 0.62,
            calloutDx: -0.22,
            calloutDy: 0.16,
          ),
          BiologyLabelTarget(
            id: 'la',
            label: 'Left atrium',
            hint: 'Receives oxygenated blood',
            ax: 0.68,
            ay: 0.32,
            calloutDx: 0.2,
            calloutDy: -0.18,
          ),
          BiologyLabelTarget(
            id: 'lv',
            label: 'Left ventricle',
            hint: 'Pumps to body',
            ax: 0.66,
            ay: 0.64,
            calloutDx: 0.22,
            calloutDy: 0.16,
          ),
          BiologyLabelTarget(
            id: 'aorta',
            label: 'Aorta',
            hint: 'Largest artery',
            ax: 0.52,
            ay: 0.14,
            calloutDx: 0.18,
            calloutDy: -0.12,
          ),
          BiologyLabelTarget(
            id: 'av',
            label: 'Atrioventricular valves',
            hint: 'Prevent backflow into atria',
            ax: 0.5,
            ay: 0.48,
            calloutDx: 0,
            calloutDy: 0.22,
          ),
        ],
        dragItems: <BiologyDragItem>[
          BiologyDragItem(id: 'i1', label: 'Pumps blood to body', matchId: 'lv'),
          BiologyDragItem(id: 'i2', label: 'Receives from vena cava', matchId: 'ra'),
          BiologyDragItem(id: 'i3', label: 'Carries oxygenated blood out', matchId: 'aorta'),
          BiologyDragItem(id: 'i4', label: 'Pumps to pulmonary circuit', matchId: 'rv'),
        ],
        dragSlots: <BiologyDragSlot>[
          BiologyDragSlot(id: 'lv', title: 'Left ventricle'),
          BiologyDragSlot(id: 'ra', title: 'Right atrium'),
          BiologyDragSlot(id: 'aorta', title: 'Aorta'),
          BiologyDragSlot(id: 'rv', title: 'Right ventricle'),
        ],
        animationPhases: <String>[
          'Atria fill with blood',
          'Atria contract · AV valves open',
          'Ventricles fill',
          'Ventricles contract · semilunar valves open',
          'Blood exits to lungs / body',
        ],
      );
    }

    if (t.contains('leaf') || t.contains('photo') || t.contains('plant tissue') || t.contains('stomata')) {
      return const BiologyInteractivePack(
        title: 'Leaf Anatomy',
        intro: 'Label leaf tissues on the cross-section diagram.',
        labels: <BiologyLabelTarget>[
          BiologyLabelTarget(
            id: 'cuticle',
            label: 'Cuticle',
            hint: 'Waxy waterproof layer',
            ax: 0.5,
            ay: 0.12,
            calloutDx: 0.28,
            calloutDy: -0.08,
          ),
          BiologyLabelTarget(
            id: 'mesophyll',
            label: 'Mesophyll',
            hint: 'Photosynthetic cells',
            ax: 0.48,
            ay: 0.42,
            calloutDx: -0.28,
            calloutDy: 0,
          ),
          BiologyLabelTarget(
            id: 'xylem',
            label: 'Xylem',
            hint: 'Water transport',
            ax: 0.45,
            ay: 0.55,
            calloutDx: 0.3,
            calloutDy: -0.05,
          ),
          BiologyLabelTarget(
            id: 'phloem',
            label: 'Phloem',
            hint: 'Sugar transport',
            ax: 0.55,
            ay: 0.58,
            calloutDx: 0.28,
            calloutDy: 0.12,
          ),
          BiologyLabelTarget(
            id: 'stomata',
            label: 'Stomata',
            hint: 'Gas exchange pores',
            ax: 0.5,
            ay: 0.86,
            calloutDx: -0.26,
            calloutDy: 0.08,
          ),
        ],
        dragItems: <BiologyDragItem>[
          BiologyDragItem(id: 'd1', label: 'Lets CO₂ in / O₂ out', matchId: 'stomata'),
          BiologyDragItem(id: 'd2', label: 'Carries water upward', matchId: 'xylem'),
          BiologyDragItem(id: 'd3', label: 'Moves sugars', matchId: 'phloem'),
          BiologyDragItem(id: 'd4', label: 'Main site of photosynthesis', matchId: 'mesophyll'),
        ],
        dragSlots: <BiologyDragSlot>[
          BiologyDragSlot(id: 'stomata', title: 'Stomata'),
          BiologyDragSlot(id: 'xylem', title: 'Xylem'),
          BiologyDragSlot(id: 'phloem', title: 'Phloem'),
          BiologyDragSlot(id: 'mesophyll', title: 'Mesophyll'),
        ],
        animationPhases: <String>[
          'Light strikes chloroplasts',
          'Water splits · O₂ released',
          'ATP / NADPH generated',
          'CO₂ fixed into sugar',
          'Sugars move via phloem',
        ],
      );
    }

    if (t.contains('dna') || t.contains('replication') || t.contains('gene') || c.contains('molecular') || c.contains('genetics')) {
      return const BiologyInteractivePack(
        title: 'DNA & Central Dogma',
        intro: 'Label bases on the helix, then sequence the information flow.',
        labels: <BiologyLabelTarget>[
          BiologyLabelTarget(
            id: 'a',
            label: 'Adenine (A)',
            hint: 'Pairs with T',
            ax: 0.35,
            ay: 0.28,
            calloutDx: -0.24,
            calloutDy: -0.12,
          ),
          BiologyLabelTarget(
            id: 't',
            label: 'Thymine (T)',
            hint: 'Pairs with A',
            ax: 0.62,
            ay: 0.28,
            calloutDx: 0.24,
            calloutDy: -0.12,
          ),
          BiologyLabelTarget(
            id: 'g',
            label: 'Guanine (G)',
            hint: 'Pairs with C',
            ax: 0.38,
            ay: 0.55,
            calloutDx: -0.24,
            calloutDy: 0.1,
          ),
          BiologyLabelTarget(
            id: 'c',
            label: 'Cytosine (C)',
            hint: 'Pairs with G',
            ax: 0.65,
            ay: 0.55,
            calloutDx: 0.24,
            calloutDy: 0.1,
          ),
          BiologyLabelTarget(
            id: 'backbone',
            label: 'Sugar-phosphate backbone',
            hint: 'Structural rails',
            ax: 0.22,
            ay: 0.72,
            calloutDx: -0.16,
            calloutDy: 0.14,
          ),
        ],
        dragItems: <BiologyDragItem>[
          BiologyDragItem(id: 'p1', label: 'DNA', matchId: 'dna'),
          BiologyDragItem(id: 'p2', label: 'Transcription', matchId: 'transcription'),
          BiologyDragItem(id: 'p3', label: 'mRNA', matchId: 'mrna'),
          BiologyDragItem(id: 'p4', label: 'Translation', matchId: 'translation'),
          BiologyDragItem(id: 'p5', label: 'Protein', matchId: 'protein'),
        ],
        dragSlots: <BiologyDragSlot>[
          BiologyDragSlot(id: 'dna', title: '1. Template'),
          BiologyDragSlot(id: 'transcription', title: '2. Process in nucleus'),
          BiologyDragSlot(id: 'mrna', title: '3. Messenger'),
          BiologyDragSlot(id: 'translation', title: '4. Process at ribosome'),
          BiologyDragSlot(id: 'protein', title: '5. Product'),
        ],
        animationPhases: <String>[
          'Helix unwinds',
          'Complementary bases pair',
          'mRNA is synthesized',
          'Ribosome reads codons',
          'Polypeptide folds into protein',
        ],
      );
    }

    if (t.contains('mitosis') || t.contains('meiosis') || t.contains('cell cycle')) {
      return const BiologyInteractivePack(
        title: 'Cell Division',
        intro: 'Label phases on the division diagram.',
        labels: <BiologyLabelTarget>[
          BiologyLabelTarget(
            id: 'pro',
            label: 'Prophase',
            hint: 'Chromosomes condense',
            ax: 0.18,
            ay: 0.45,
            calloutDx: -0.12,
            calloutDy: -0.22,
          ),
          BiologyLabelTarget(
            id: 'meta',
            label: 'Metaphase',
            hint: 'Align at equator',
            ax: 0.38,
            ay: 0.45,
            calloutDx: 0,
            calloutDy: -0.24,
          ),
          BiologyLabelTarget(
            id: 'ana',
            label: 'Anaphase',
            hint: 'Sister chromatids separate',
            ax: 0.58,
            ay: 0.45,
            calloutDx: 0,
            calloutDy: 0.24,
          ),
          BiologyLabelTarget(
            id: 'telo',
            label: 'Telophase',
            hint: 'Nuclei reform',
            ax: 0.78,
            ay: 0.4,
            calloutDx: 0.12,
            calloutDy: -0.2,
          ),
          BiologyLabelTarget(
            id: 'cyto',
            label: 'Cytokinesis',
            hint: 'Cytoplasm divides',
            ax: 0.82,
            ay: 0.65,
            calloutDx: 0.1,
            calloutDy: 0.18,
          ),
        ],
        dragItems: <BiologyDragItem>[
          BiologyDragItem(id: 'e1', label: 'Chromosomes condense', matchId: 'pro'),
          BiologyDragItem(id: 'e2', label: 'Line up at metaphase plate', matchId: 'meta'),
          BiologyDragItem(id: 'e3', label: 'Chromatids pull apart', matchId: 'ana'),
          BiologyDragItem(id: 'e4', label: 'Two nuclei form', matchId: 'telo'),
        ],
        dragSlots: <BiologyDragSlot>[
          BiologyDragSlot(id: 'pro', title: 'Prophase'),
          BiologyDragSlot(id: 'meta', title: 'Metaphase'),
          BiologyDragSlot(id: 'ana', title: 'Anaphase'),
          BiologyDragSlot(id: 'telo', title: 'Telophase'),
        ],
        animationPhases: <String>[
          'Prophase — condensation begins',
          'Metaphase — alignment',
          'Anaphase — separation',
          'Telophase — nuclei reform',
          'Cytokinesis — two cells',
        ],
      );
    }

    // Default: animal cell — positions map roughly to the SVG organelle layout.
    return BiologyInteractivePack(
      title: topic.contains('Cell') || t.contains('cell') || t.contains('organelle')
          ? 'Animal Cell'
          : 'Structures of $topic',
      intro: 'Drag each label onto the matching structure on the cell diagram.',
      labels: const <BiologyLabelTarget>[
        BiologyLabelTarget(
          id: 'nucleus',
          label: 'Nucleus',
          hint: 'Large central structure that stores DNA',
          ax: 0.50,
          ay: 0.48,
          calloutDx: -0.28,
          calloutDy: -0.22,
        ),
        BiologyLabelTarget(
          id: 'mito',
          label: 'Mitochondria',
          hint: 'Bean-shaped powerhouses',
          ax: 0.28,
          ay: 0.62,
          calloutDx: -0.22,
          calloutDy: 0.16,
        ),
        BiologyLabelTarget(
          id: 'ribo',
          label: 'Ribosomes',
          hint: 'Tiny dots on rough ER / cytoplasm',
          ax: 0.62,
          ay: 0.34,
          calloutDx: 0.26,
          calloutDy: -0.16,
        ),
        BiologyLabelTarget(
          id: 'golgi',
          label: 'Golgi apparatus',
          hint: 'Stacked membrane cisternae',
          ax: 0.72,
          ay: 0.55,
          calloutDx: 0.22,
          calloutDy: 0.18,
        ),
        BiologyLabelTarget(
          id: 'rer',
          label: 'Rough ER',
          hint: 'Network beside the nucleus with ribosomes',
          ax: 0.38,
          ay: 0.36,
          calloutDx: -0.26,
          calloutDy: -0.08,
        ),
        BiologyLabelTarget(
          id: 'ser',
          label: 'Smooth ER',
          hint: 'Smooth membrane network (lipid synthesis)',
          ax: 0.70,
          ay: 0.38,
          calloutDx: 0.22,
          calloutDy: -0.12,
        ),
        BiologyLabelTarget(
          id: 'lyso',
          label: 'Lysosomes',
          hint: 'Small digestive vesicles',
          ax: 0.42,
          ay: 0.72,
          calloutDx: -0.18,
          calloutDy: 0.18,
        ),
      ],
      dragItems: const <BiologyDragItem>[
        BiologyDragItem(id: 'f1', label: 'Makes ATP', matchId: 'mito'),
        BiologyDragItem(id: 'f2', label: 'Contains DNA', matchId: 'nucleus'),
        BiologyDragItem(id: 'f3', label: 'Builds proteins', matchId: 'ribo'),
        BiologyDragItem(id: 'f4', label: 'Packages & ships proteins', matchId: 'golgi'),
        BiologyDragItem(id: 'f5', label: 'Breaks down wastes', matchId: 'lyso'),
      ],
      dragSlots: const <BiologyDragSlot>[
        BiologyDragSlot(id: 'mito', title: 'Mitochondria'),
        BiologyDragSlot(id: 'nucleus', title: 'Nucleus'),
        BiologyDragSlot(id: 'ribo', title: 'Ribosomes'),
        BiologyDragSlot(id: 'golgi', title: 'Golgi apparatus'),
        BiologyDragSlot(id: 'lyso', title: 'Lysosomes'),
      ],
      animationPhases: const <String>[
        'Zoom into the living cell',
        'Nucleus directs gene expression',
        'Ribosomes assemble polypeptides',
        'Mitochondria generate ATP',
        'Membrane controls what enters / exits',
      ],
    );
  }
}
