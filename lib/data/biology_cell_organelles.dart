/// Structured organelle content for the interactive living-cell studio.
class BiologyCellOrganelle {
  const BiologyCellOrganelle({
    required this.id,
    required this.name,
    required this.shortName,
    required this.function,
    required this.contains,
    required this.diseases,
    required this.animationLabel,
    required this.quizPrompt,
    required this.quizChoices,
    required this.quizCorrect,
    required this.color,
    required this.ax,
    required this.ay,
    required this.hitRadius,
  });

  final String id;
  final String name;
  final String shortName;
  final String function;
  final List<String> contains;
  final List<String> diseases;
  final String animationLabel;
  final String quizPrompt;
  final List<String> quizChoices;
  final int quizCorrect;
  final int color;
  /// Normalized position in cell space (0–1).
  final double ax;
  final double ay;
  final double hitRadius;
}

abstract final class BiologyCellOrganelleCatalog {
  static const List<BiologyCellOrganelle> animalCell = <BiologyCellOrganelle>[
    BiologyCellOrganelle(
      id: 'nucleus',
      name: 'Nucleus',
      shortName: 'Nucleus',
      function: 'Stores DNA and controls gene expression and cell activities.',
      contains: <String>['Chromatin', 'Nuclear envelope', 'Nucleolus', 'Nuclear pores'],
      diseases: <String>['Cancer (genomic instability)', 'Laminopathies', 'Progeria'],
      animationLabel: 'DNA Replication',
      quizPrompt: 'What is the primary role of the nucleus?',
      quizChoices: <String>[
        'Store DNA and direct cell activity',
        'Produce most ATP',
        'Digest worn organelles',
        'Package proteins for export',
      ],
      quizCorrect: 0,
      color: 0xFF7C5CFF,
      // Positions match assets/biology/animal_cell.svg (viewBox 480×400).
      ax: 0.475,
      ay: 0.463,
      hitRadius: 0.12,
    ),
    BiologyCellOrganelle(
      id: 'mito',
      name: 'Mitochondrion',
      shortName: 'Mitochondria',
      function: 'Produces ATP through cellular respiration — the powerhouse of the cell.',
      contains: <String>['Outer membrane', 'Inner membrane (cristae)', 'Matrix', 'mtDNA'],
      diseases: <String>['Mitochondrial myopathies', 'Leber hereditary optic neuropathy'],
      animationLabel: 'ATP Production',
      quizPrompt: 'Mitochondria are best known for producing…',
      quizChoices: <String>['ATP', 'mRNA', 'Bile', 'Antibodies'],
      quizCorrect: 0,
      color: 0xFFE45757,
      ax: 0.313,
      ay: 0.613,
      hitRadius: 0.085,
    ),
    BiologyCellOrganelle(
      id: 'rer',
      name: 'Rough Endoplasmic Reticulum',
      shortName: 'Rough ER',
      function: 'Folds and modifies proteins studded with ribosomes.',
      contains: <String>['Cisternae', 'Bound ribosomes', 'Lumen'],
      diseases: <String>['ER stress disorders', 'Protein misfolding disease pathways'],
      animationLabel: 'Protein Folding',
      quizPrompt: 'Rough ER is “rough” because of…',
      quizChoices: <String>[
        'Attached ribosomes',
        'Cristae folds',
        'Lipid droplets',
        'Starch grains',
      ],
      quizCorrect: 0,
      color: 0xFFFFB347,
      ax: 0.646,
      ay: 0.438,
      hitRadius: 0.09,
    ),
    BiologyCellOrganelle(
      id: 'ser',
      name: 'Smooth Endoplasmic Reticulum',
      shortName: 'Smooth ER',
      function: 'Synthesizes lipids and detoxifies compounds.',
      contains: <String>['Tubular membranes', 'Enzymes for lipid synthesis'],
      diseases: <String>['Drug metabolism disorders', 'Lipid storage issues'],
      animationLabel: 'Lipid Synthesis',
      quizPrompt: 'Smooth ER specializes in…',
      quizChoices: <String>[
        'Lipid synthesis & detox',
        'DNA packaging',
        'ATP synthase arrays',
        'Photosynthesis',
      ],
      quizCorrect: 0,
      color: 0xFFFFCC80,
      ax: 0.292,
      ay: 0.438,
      hitRadius: 0.08,
    ),
    BiologyCellOrganelle(
      id: 'golgi',
      name: 'Golgi Apparatus',
      shortName: 'Golgi',
      function: 'Modifies, sorts, and packages proteins into vesicles for transport.',
      contains: <String>['Cis face', 'Medial stacks', 'Trans face', 'Secretory vesicles'],
      diseases: <String>['Congenital disorders of glycosylation', 'Golgi fragmentation in neurodegeneration'],
      animationLabel: 'Vesicle Trafficking',
      quizPrompt: 'Golgi apparatus primarily…',
      quizChoices: <String>[
        'Packages and ships proteins',
        'Stores genetic code',
        'Splits water for O₂',
        'Contracts the cytoskeleton',
      ],
      quizCorrect: 0,
      color: 0xFF9B6DFF,
      ax: 0.733,
      ay: 0.550,
      hitRadius: 0.09,
    ),
    BiologyCellOrganelle(
      id: 'lyso',
      name: 'Lysosome',
      shortName: 'Lysosome',
      function: 'Contains digestive enzymes that break down waste and worn organelles.',
      contains: <String>['Acid hydrolases', 'Membrane proton pumps'],
      diseases: <String>['Lysosomal storage diseases', 'Tay–Sachs disease'],
      animationLabel: 'Digestion Cycle',
      quizPrompt: 'Lysosomes are filled with…',
      quizChoices: <String>[
        'Digestive enzymes',
        'Chlorophyll',
        'Hemoglobin',
        'Keratin filaments',
      ],
      quizCorrect: 0,
      color: 0xFF8D6E63,
      ax: 0.396,
      ay: 0.750,
      hitRadius: 0.06,
    ),
    BiologyCellOrganelle(
      id: 'ribo',
      name: 'Ribosome',
      shortName: 'Ribosomes',
      function: 'Assembles polypeptides by translating mRNA.',
      contains: <String>['Large subunit', 'Small subunit', 'rRNA'],
      diseases: <String>['Ribosomopathies', 'Diamond–Blackfan anemia'],
      animationLabel: 'Translation',
      quizPrompt: 'Ribosomes build…',
      quizChoices: <String>['Proteins', 'ATP only', 'DNA double helix', 'Cellulose walls'],
      quizCorrect: 0,
      color: 0xFF26A69A,
      ax: 0.552,
      ay: 0.655,
      hitRadius: 0.055,
    ),
    BiologyCellOrganelle(
      id: 'membrane',
      name: 'Plasma Membrane',
      shortName: 'Membrane',
      function: 'Selective barrier controlling entry and exit; hosts receptors and channels.',
      contains: <String>['Phospholipid bilayer', 'Cholesterol', 'Proteins', 'Glycocalyx'],
      diseases: <String>['Channelopathies', 'Receptor defects'],
      animationLabel: 'Membrane Dynamics',
      quizPrompt: 'The plasma membrane is mainly a…',
      quizChoices: <String>[
        'Phospholipid bilayer with proteins',
        'Solid cellulose shell',
        'Single protein fiber',
        'Nuclear pore complex only',
      ],
      quizCorrect: 0,
      color: 0xFF42A5F5,
      ax: 0.90,
      ay: 0.40,
      hitRadius: 0.07,
    ),
  ];

  static BiologyCellOrganelle? byId(String id) {
    for (final BiologyCellOrganelle o in animalCell) {
      if (o.id == id) return o;
    }
    return null;
  }
}
