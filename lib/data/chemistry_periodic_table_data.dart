/// Interactive periodic table element profiles.
class ChemElement {
  const ChemElement({
    required this.symbol,
    required this.name,
    required this.atomicNumber,
    required this.atomicMass,
    required this.group,
    required this.period,
    required this.category,
    required this.electronConfig,
    required this.oxidationStates,
    required this.electronegativity,
    required this.atomicRadiusPm,
    required this.uses,
    required this.industrialUses,
    required this.biologicalImportance,
    required this.hazards,
    required this.compounds,
    required this.facts,
    required this.discovery,
  });

  final String symbol;
  final String name;
  final int atomicNumber;
  final double atomicMass;
  final int group;
  final int period;
  final String category;
  final String electronConfig;
  final String oxidationStates;
  final String electronegativity;
  final int atomicRadiusPm;
  final String uses;
  final String industrialUses;
  final String biologicalImportance;
  final String hazards;
  final String compounds;
  final String facts;
  final String discovery;
}

class ChemistryPeriodicTableData {
  ChemistryPeriodicTableData._();

  static const List<ChemElement> elements = <ChemElement>[
    ChemElement(
      symbol: 'H',
      name: 'Hydrogen',
      atomicNumber: 1,
      atomicMass: 1.008,
      group: 1,
      period: 1,
      category: 'Nonmetal',
      electronConfig: '1s¹',
      oxidationStates: '+1, −1',
      electronegativity: '2.20',
      atomicRadiusPm: 53,
      uses: 'Fuel cells, ammonia synthesis, rocket propellant',
      industrialUses: 'Haber process, petroleum refining, hydrogenation',
      biologicalImportance: 'Essential in water and all organic molecules',
      hazards: 'Highly flammable gas; explosive mixtures with air',
      compounds: 'H₂O, HCl, NH₃, CH₄',
      facts: 'Most abundant element in the universe',
      discovery: '1766 — Henry Cavendish',
    ),
    ChemElement(
      symbol: 'C',
      name: 'Carbon',
      atomicNumber: 6,
      atomicMass: 12.011,
      group: 14,
      period: 2,
      category: 'Nonmetal',
      electronConfig: '[He] 2s² 2p²',
      oxidationStates: '−4 to +4',
      electronegativity: '2.55',
      atomicRadiusPm: 77,
      uses: 'All organic chemistry, materials, fuels',
      industrialUses: 'Steel production, polymers, activated carbon filters',
      biologicalImportance: 'Backbone of proteins, DNA, carbohydrates, lipids',
      hazards: 'Dust explosion risk for fine carbon powders',
      compounds: 'CO₂, CO, CH₄, diamond, graphite',
      facts: 'Forms more compounds than any other element',
      discovery: 'Known since antiquity',
    ),
    ChemElement(
      symbol: 'N',
      name: 'Nitrogen',
      atomicNumber: 7,
      atomicMass: 14.007,
      group: 15,
      period: 2,
      category: 'Nonmetal',
      electronConfig: '[He] 2s² 2p³',
      oxidationStates: '−3 to +5',
      electronegativity: '3.04',
      atomicRadiusPm: 71,
      uses: 'Inert atmosphere, fertilizers, explosives',
      industrialUses: 'Haber-Bosch ammonia, cryogenic cooling',
      biologicalImportance: 'Amino acids, nucleic acids, nitrogen cycle',
      hazards: 'Liquid N₂ causes severe cold burns; asphyxiation in confined spaces',
      compounds: 'NH₃, NO₃⁻, N₂O, HNO₃',
      facts: 'N₂ is triple-bonded and very stable',
      discovery: '1772 — Daniel Rutherford',
    ),
    ChemElement(
      symbol: 'O',
      name: 'Oxygen',
      atomicNumber: 8,
      atomicMass: 15.999,
      group: 16,
      period: 2,
      category: 'Nonmetal',
      electronConfig: '[He] 2s² 2p⁴',
      oxidationStates: '−2 (common), −1 in peroxides',
      electronegativity: '3.44',
      atomicRadiusPm: 66,
      uses: 'Respiration support, combustion, steelmaking',
      industrialUses: 'O₂ enrichment, wastewater treatment, welding',
      biologicalImportance: 'Cellular respiration, ozone layer',
      hazards: 'Strong oxidizer; accelerates combustion',
      compounds: 'H₂O, O₂, O₃, CO₂, oxides',
      facts: 'Most abundant element in Earth\'s crust by mass',
      discovery: '1774 — Joseph Priestley / Carl Scheele',
    ),
    ChemElement(
      symbol: 'Na',
      name: 'Sodium',
      atomicNumber: 11,
      atomicMass: 22.990,
      group: 1,
      period: 3,
      category: 'Alkali metal',
      electronConfig: '[Ne] 3s¹',
      oxidationStates: '+1',
      electronegativity: '0.93',
      atomicRadiusPm: 186,
      uses: 'Street lighting (Na vapor), heat transfer in reactors',
      industrialUses: 'Chlor-alkali process, soap manufacture, metallurgy',
      biologicalImportance: 'Nerve impulses, fluid balance (Na⁺)',
      hazards: 'Reacts violently with water; stored under oil',
      compounds: 'NaCl, NaOH, Na₂CO₃',
      facts: 'Soft metal — cut with a knife',
      discovery: '1807 — Humphry Davy',
    ),
    ChemElement(
      symbol: 'Cl',
      name: 'Chlorine',
      atomicNumber: 17,
      atomicMass: 35.45,
      group: 17,
      period: 3,
      category: 'Halogen',
      electronConfig: '[Ne] 3s² 3p⁵',
      oxidationStates: '−1, +1, +3, +5, +7',
      electronegativity: '3.16',
      atomicRadiusPm: 102,
      uses: 'Water disinfection, PVC production, bleaching',
      industrialUses: 'Chlor-alkali, solvents, pesticides',
      biologicalImportance: 'Essential electrolyte (Cl⁻) in small amounts',
      hazards: 'Toxic green gas; strong oxidizer and irritant',
      compounds: 'NaCl, HCl, Cl₂, chlorinated organics',
      facts: 'Discovered as a yellow-green gas',
      discovery: '1774 — Carl Wilhelm Scheele',
    ),
    ChemElement(
      symbol: 'Fe',
      name: 'Iron',
      atomicNumber: 26,
      atomicMass: 55.845,
      group: 8,
      period: 4,
      category: 'Transition metal',
      electronConfig: '[Ar] 3d⁶ 4s²',
      oxidationStates: '+2, +3 (common)',
      electronegativity: '1.83',
      atomicRadiusPm: 126,
      uses: 'Structural steel, magnets, catalysts',
      industrialUses: 'Blast furnaces, stainless steel, hemoglobin research models',
      biologicalImportance: 'Hemoglobin oxygen transport',
      hazards: 'Rust (corrosion); fine iron powder can ignite',
      compounds: 'Fe₂O₃, FeCl₃, FeSO₄',
      facts: 'Most used metal by mass globally',
      discovery: 'Known since ~3500 BCE',
    ),
    ChemElement(
      symbol: 'Cu',
      name: 'Copper',
      atomicNumber: 29,
      atomicMass: 63.546,
      group: 11,
      period: 4,
      category: 'Transition metal',
      electronConfig: '[Ar] 3d¹⁰ 4s¹',
      oxidationStates: '+1, +2',
      electronegativity: '1.90',
      atomicRadiusPm: 128,
      uses: 'Electrical wiring, plumbing, alloys (brass, bronze)',
      industrialUses: 'Electronics, heat exchangers, coinage',
      biologicalImportance: 'Enzyme cofactor (cytochrome oxidase)',
      hazards: 'Copper salts toxic in excess',
      compounds: 'CuO, CuSO₄, CuCl₂',
      facts: 'Excellent electrical and thermal conductor',
      discovery: 'Known since antiquity',
    ),
  ];

  static ChemElement? bySymbol(String symbol) {
    final String s = symbol.trim();
    for (final ChemElement e in elements) {
      if (e.symbol.toLowerCase() == s.toLowerCase()) return e;
    }
    return null;
  }
}
