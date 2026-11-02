/// Textbook-quality chapter sections for chemistry lessons.
class ChemistryTextbookSection {
  const ChemistryTextbookSection({required this.title, required this.body});

  final String title;
  final String body;
}

class ChemistryTextbookContent {
  ChemistryTextbookContent._();

  static List<ChemistryTextbookSection> build({
    required String topic,
    required String course,
    required String module,
  }) {
    return <ChemistryTextbookSection>[
      ChemistryTextbookSection(
        title: 'Introduction',
        body:
            'This chapter covers $topic in $course ($module). '
            'Chemistry connects the invisible world of atoms and electrons to measurable laboratory phenomena. '
            'Every concept here builds toward predicting structure, reactivity, and real-world applications.',
      ),
      ChemistryTextbookSection(
        title: 'Historical Context',
        body:
            'Scientists developed our understanding of $topic through careful experiment and revised models. '
            'From Dalton\'s atomic theory to modern quantum chemistry, each discovery refined how we explain '
            'bond formation, reaction rates, and molecular behavior.',
      ),
      ChemistryTextbookSection(
        title: 'Definitions & Key Terms',
        body:
            'Define every symbol before using it. For $topic, identify the system (atoms, ions, molecules), '
            'the interaction (bonding, collision, transfer), and measurable quantities (concentration, energy, pH). '
            'Precise vocabulary prevents confusion between similar concepts like intermolecular vs intramolecular forces.',
      ),
      ChemistryTextbookSection(
        title: 'Theory & Laws',
        body:
            'The theoretical framework for $topic explains WHY observations occur, not merely WHAT happens. '
            'Apply conservation laws (mass, charge, energy), periodic trends, and thermodynamic driving forces. '
            'Connect macroscopic lab data to particulate-level models.',
      ),
      ChemistryTextbookSection(
        title: 'Chemical Equations & Stoichiometry',
        body:
            'Write balanced equations with correct state symbols. Identify reaction type relevant to $topic. '
            'Use mole ratios from balanced coefficients. Track limiting reagents, percent yield, and significant figures '
            'in all calculations.',
      ),
      ChemistryTextbookSection(
        title: 'Worked Examples',
        body:
            'Example 1 — Conceptual: Explain the electron movement in a representative $topic process step by step.\n\n'
            'Example 2 — Quantitative: Given laboratory data, calculate the unknown using dimensional analysis.\n\n'
            'Example 3 — Prediction: Use periodic trends and bonding theory to predict products before mixing reagents.',
      ),
      ChemistryTextbookSection(
        title: 'Exceptions & Edge Cases',
        body:
            'Real chemistry includes exceptions. Note where simplified models fail for $topic — '
            'anomalous electron configurations, resonance structures, competing reaction pathways, '
            'and conditions where equilibrium or kinetics dominate differently.',
      ),
      ChemistryTextbookSection(
        title: 'Laboratory Techniques',
        body:
            'Standard procedures linked to $topic: proper PPE, calibrated glassware, controlled heating, '
            'titration technique, spectroscopy sample prep, and waste segregation. '
            'Record observations immediately; never back-fill data.',
      ),
      ChemistryTextbookSection(
        title: 'Real-World & Industrial Applications',
        body:
            '$topic appears in pharmaceuticals, materials science, environmental monitoring, energy storage, '
            'and industrial synthesis. Understanding scale-up, safety, and green chemistry alternatives '
            'connects classroom theory to professional practice.',
      ),
      ChemistryTextbookSection(
        title: 'Common Mistakes',
        body:
            '• Confusing subscripts and coefficients in equations\n'
            '• Ignoring units in calculations\n'
            '• Applying rules from a different topic\n'
            '• Skipping Lewis structures before predicting geometry\n'
            '• Forgetting safety when scaling reactions',
      ),
      ChemistryTextbookSection(
        title: 'Exam Tips',
        body:
            'Show electron movement with curved arrows in organic mechanisms. '
            'State assumptions explicitly. Check answers for physical reasonableness (negative concentrations, impossible pH). '
            'For $topic, practice both multiple-choice conceptual traps and multi-step quantitative problems.',
      ),
      ChemistryTextbookSection(
        title: 'Chapter Summary',
        body:
            'You should now define $topic, explain its theoretical basis, perform related calculations, '
            'predict laboratory outcomes, and connect the concept to applications in $course.',
      ),
      ChemistryTextbookSection(
        title: 'Review Questions',
        body:
            '1. Define the central concept of $topic in one precise paragraph.\n'
            '2. Draw or describe the key particulate-level model.\n'
            '3. Balance a related equation and identify the reaction type.\n'
            '4. Solve a stoichiometry problem with limiting reagent.\n'
            '5. Explain one real-world application and one laboratory safety consideration.',
      ),
    ];
  }
}
