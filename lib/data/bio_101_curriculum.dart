/// BIO 101 — General Biology I (Cell Biology & Genetics) university curriculum.
abstract final class Bio101Curriculum {
  static const String courseCode = 'BIO-101';
  static const String title = 'General Biology I — Cell Biology & Genetics';
  static const String subtitle =
      'Foundations of life, chemistry of life, cells, genetics, evolution, and ecology.';

  static const List<Bio101Module> modules = <Bio101Module>[
    Bio101Module(
      id: 'm1',
      title: 'Module 1 — Foundations of Biology',
      units: <String>[
        'What Is Biology?',
        'The Characteristics of Life',
        'Scientific Method',
        'Experimental Design',
        'Data and Scientific Reasoning',
      ],
    ),
    Bio101Module(
      id: 'm2',
      title: 'Module 2 — Chemistry of Life',
      units: <String>[
        'Atoms and Elements',
        'Chemical Bonds',
        'Water',
        'Acids and Bases',
        'Organic Molecules',
        'Carbohydrates',
        'Lipids',
        'Proteins',
        'Nucleic Acids',
      ],
    ),
    Bio101Module(
      id: 'm3',
      title: 'Module 3 — Cell Biology',
      units: <String>[
        'Cell Theory',
        'Prokaryotic vs Eukaryotic Cells',
        'Cell Membrane',
        'Transport',
        'Organelles',
        'Energy and ATP',
        'Cellular Respiration',
        'Photosynthesis',
        'Cell Communication',
      ],
    ),
    Bio101Module(
      id: 'm4',
      title: 'Module 4 — Genetics',
      units: <String>[
        'DNA',
        'DNA Replication',
        'Gene Expression',
        'RNA',
        'Protein Synthesis',
        'Mendelian Genetics',
        'Punnett Squares',
        'Mutations',
        'Genetic Engineering',
      ],
    ),
    Bio101Module(
      id: 'm5',
      title: 'Module 5 — Evolution',
      units: <String>[
        'Natural Selection',
        'Adaptation',
        'Population Genetics',
        'Speciation',
        'Evidence for Evolution',
      ],
    ),
    Bio101Module(
      id: 'm6',
      title: 'Module 6 — Ecology',
      units: <String>[
        'Populations',
        'Communities',
        'Ecosystems',
        'Food Webs',
        'Energy Flow',
        'Biogeochemical Cycles',
        'Population Growth',
        'Human Impact',
      ],
    ),
  ];

  static List<String> get allLessonTitles => modules
      .expand((Bio101Module m) => m.units)
      .toList(growable: false);

  static List<String> get learningObjectives => const <String>[
        'Apply the scientific method to biological questions',
        'Describe the chemistry of living systems',
        'Explain cell structure, transport, and energy pathways',
        'Predict inheritance patterns using Mendelian genetics',
        'Interpret evolutionary and ecological relationships',
      ];
}

class Bio101Module {
  const Bio101Module({
    required this.id,
    required this.title,
    required this.units,
  });

  final String id;
  final String title;
  final List<String> units;
}
