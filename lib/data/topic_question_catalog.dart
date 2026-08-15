import '../models/topic_profile.dart';
import '../data/topic_profile_database.dart';
import '../utils/topic_scope_validator.dart';
import '../utils/topic_keyword_matcher.dart';

/// Topic-specific practice questions keyed to the university catalog.
class TopicQuestionCatalog {
  TopicQuestionCatalog._();

  static List<String> questionsFor({
    required String topicName,
    required String topicId,
    required String courseName,
    required String unitName,
    required String difficulty,
    String? subjectId,
    String? courseId,
    TopicProfile? profile,
  }) {
    final TopicProfile resolved = profile ??
        TopicProfileDatabase.resolve(
          topicId: topicId,
          topicName: topicName,
          subjectId: subjectId,
          courseId: courseId,
          courseName: courseName,
          unitName: unitName,
        );

    final String d = difficulty.toLowerCase();
    final String exactKey = subjectId != null && courseId != null ? '$subjectId|$courseId|$topicId' : '';
    final List<String> exact = exactKey.isEmpty ? const <String>[] : _exact[exactKey] ?? const <String>[];
    final List<String> fromProfile = _fromProfileKeys(resolved, d);
    final List<String> merged = <String>[...exact, ...fromProfile];
    final List<String> scoped = merged.isEmpty
        ? const <String>[]
        : TopicScopeValidator.filterQuestions(_forDifficulty(merged, d), resolved);
    return _padToMinimum(
      scoped,
      difficulty: d,
      topicName: topicName,
      courseName: courseName,
      unitName: unitName,
      profile: resolved,
      minimum: 45,
    );
  }

  static List<String> _padToMinimum(
    List<String> pool, {
    required String difficulty,
    required String topicName,
    required String courseName,
    required String unitName,
    required TopicProfile profile,
    required int minimum,
  }) {
    if (pool.length >= minimum) return pool;
    final List<String> stems = TopicScopeValidator.objectiveStems(profile, difficulty);
    final List<String> out = List<String>.from(pool);
    int round = 1;
    while (out.length < minimum) {
      for (final String stem in stems) {
        final String q = stem
            .replaceAll('{topic}', topicName)
            .replaceAll('{course}', courseName)
            .replaceAll('{unit}', unitName)
            .replaceAll('{n}', '$round');
        if (TopicScopeValidator.isOnTopic(q, profile)) out.add(q);
        if (out.length >= minimum) break;
      }
      round++;
      if (round > 40) break;
    }
    return out;
  }

  static List<String> _fromProfileKeys(TopicProfile profile, String difficulty) {
    final TopicKeywordMatcher matcher = TopicKeywordMatcher(
      topicId: profile.topicId,
      topicName: profile.topicName,
      subjectId: profile.subjectId,
      courseId: profile.courseId,
    );
    final List<String> out = <String>[];
    final Set<String> keys = profile.questionBankKeys.toSet();
    for (final MapEntry<String, List<String>> entry in _keywordBank.entries) {
      final bool keyMatch = keys.contains(entry.key) || (keys.isEmpty && matcher.matches(entry.key));
      if (!keyMatch) continue;
      if (_boneQuestionKeys.contains(entry.key) && matcher.excludesBoneContent) continue;
      if (_boneQuestionKeys.contains(entry.key) && !matcher.isBoneAnatomyTopic) continue;
      out.addAll(_forDifficulty(entry.value, difficulty));
    }
    return TopicScopeValidator.filterQuestions(out, profile);
  }

  static List<String> _forDifficulty(List<String> pool, String difficulty) {
    if (difficulty.contains('adv')) {
      return pool.where((String q) => q.startsWith('[A]')).map((String q) => q.substring(3)).toList();
    }
    if (difficulty.contains('inter')) {
      return pool.where((String q) => q.startsWith('[I]')).map((String q) => q.substring(3)).toList();
    }
    return pool.where((String q) => q.startsWith('[B]')).map((String q) => q.substring(3)).toList();
  }

  static const Set<String> _boneQuestionKeys = <String>{'skeletal'};

  /// [B]=Beginner [I]=Intermediate [A]=Advanced
  static const Map<String, List<String>> _keywordBank = <String, List<String>>{
    'linear_equation': <String>[
      '[B]Solve for x: 2x + 6 = 14. Show each step.',
      '[B]Is (3, 1) a solution to y = 2x - 5? Explain.',
      r'[I]A taxi charges $2 plus $1.50 per mile. Write and solve an equation for a $17 fare.',
      '[I]Solve the system: x + y = 10 and 2x - y = 2.',
      '[A]Create a word problem that requires a system of linear equations and solve it.',
    ],
    'limit': <String>[
      '[B]What does it mean for lim x→2 f(x) = 5?',
      '[B]Estimate lim x→0 (sin x)/x using a table of values.',
      '[I]Evaluate lim x→3 (x² - 9)/(x - 3) without plugging in x = 3.',
      '[A]Prove using ε-δ or algebraic manipulation that lim x→0 (1 - cos x)/x = 0.',
    ],
    'derivative': <String>[
      '[B]Find f′(x) if f(x) = 3x² + 2x.',
      '[I]Use the chain rule on f(x) = (3x + 1)⁴.',
      '[A]Find all critical points of f(x) = x³ - 3x² + 2 and classify them.',
    ],
    'integral': <String>[
      '[B]Evaluate ∫(2x + 3) dx.',
      '[I]Evaluate ∫ x·e^(x²) dx using substitution.',
      '[A]Set up (do not evaluate) an integral for the area between y = x² and y = 2x.',
    ],
    'cell_membrane': <String>[
      '[B]What is the main function of the phospholipid bilayer?',
      '[B]Distinguish passive diffusion from facilitated diffusion.',
      '[B]Is the membrane fluid mosaic model static or dynamic — explain briefly.',
      '[I]How do channel proteins differ from carrier proteins?',
      '[I]Compare hypertonic, hypotonic, and isotonic effects on animal cells.',
      '[A]Explain how osmotic pressure affects red blood cells in hypotonic vs hypertonic solutions.',
    ],
    'organelle': <String>[
      '[B]Match each organelle to its function: nucleus, mitochondria, ribosome, Golgi.',
      '[B]Which organelle is responsible for cellular respiration?',
      '[I]Why do plant cells have chloroplasts and central vacuoles but animal cells do not?',
      '[I]Compare rough ER vs smooth ER structure and function.',
      '[A]Trace the path of a secreted protein from ribosome to cell membrane.',
      '[A]Explain how a defect in lysosomal enzymes leads to storage diseases.',
    ],
    'mitochondria': <String>[
      '[B]What is the function of mitochondria in the cell?',
      '[B]Why are mitochondria called the powerhouse of the cell?',
      '[B]Which cells contain many mitochondria and why?',
      '[I]How is ATP produced in the mitochondria during cellular respiration?',
      '[I]Describe the structure of the inner mitochondrial membrane and its role in ATP synthesis.',
      '[A]Explain how mitochondrial dysfunction can affect muscle and nerve cells.',
      '[A]Compare aerobic respiration in mitochondria to glycolysis in the cytoplasm.',
    ],
    'mitosis': <String>[
      '[B]Order the phases of mitosis and state what happens in each.',
      '[I]How many chromosomes are in a human cell after mitosis vs after meiosis I?',
      '[A]Compare errors in mitosis vs meiosis and their consequences for the organism.',
    ],
    'meiosis': <String>[
      '[B]Why is crossing over important in meiosis?',
      '[I]Calculate gamete combinations for an organism with n = 3 chromosomes.',
      '[A]Explain how nondisjunction leads to conditions like Down syndrome.',
    ],
    'dna': <String>[
      '[B]What are the complementary base-pairing rules in DNA?',
      '[I]Describe the role of DNA polymerase during replication.',
      '[A]Explain how a point mutation vs frameshift mutation can alter protein function.',
    ],
    'mendelian': <String>[
      '[B]In peas, tall (T) is dominant over short (t). Cross Tt × Tt — what phenotypic ratio?',
      '[I]Solve a dihybrid cross for seed shape and color with independent assortment.',
      '[A]Explain why pedigree analysis alone cannot prove autosomal dominant inheritance.',
    ],
    'bacteria': <String>[
      '[B]How do Gram-positive and Gram-negative cell walls differ?',
      '[I]Describe the steps of binary fission in bacteria.',
      '[A]Explain how horizontal gene transfer contributes to antibiotic resistance.',
    ],
    'virus': <String>[
      '[B]Why are viruses considered obligate intracellular parasites?',
      '[I]Compare lytic and lysogenic viral replication cycles.',
      '[A]Design a public-health strategy to limit spread of an RNA virus with high mutation rate.',
    ],
    'atomic': <String>[
      '[B]How do protons, neutrons, and electrons determine an element\'s identity and mass?',
      '[I]Write the electron configuration for sulfur (Z = 16).',
      '[A]Explain periodic trends in electronegativity across a period and down a group.',
    ],
    'stoichiometry': <String>[
      '[B]Balance: _Fe + _O₂ → _Fe₂O₃',
      '[I]How many grams of CO₂ form from burning 12 g of carbon completely?',
      '[A]Identify the limiting reactant when 5 mol H₂ reacts with 3 mol N₂ (N₂ + 3H₂ → 2NH₃).',
    ],
    'acid': <String>[
      '[B]Define Brønsted-Lowry acid and base.',
      '[I]Calculate pH of a 0.01 M HCl solution.',
      '[A]Prepare a buffer strategy to maintain pH ≈ 4.5 — which weak acid/conjugate pair would you choose?',
    ],
    'circuit': <String>[
      '[B]In a series circuit with two identical resistors and one battery, how is voltage divided?',
      '[I]Apply Ohm\'s law to find current when R = 12 Ω and V = 24 V.',
      '[A]Analyze a mixed series-parallel circuit and find equivalent resistance.',
    ],
    'force': <String>[
      '[B]State Newton\'s three laws in your own words with one example each.',
      '[I]Draw a free-body diagram for a block sliding down a frictionless incline.',
      '[A]Solve an inclined-plane problem with kinetic friction and find acceleration.',
    ],
    'forces': <String>[
      '[B]What is net force and how does it relate to acceleration?',
      '[I]A 5 kg block is pulled with 20 N at constant velocity — what is friction?',
      '[A]Analyze forces on an object in circular motion at constant speed.',
    ],
    'kinematic': <String>[
      '[B]A car goes from 0 to 20 m/s in 5 s. What is its average acceleration?',
      '[I]Derive the kinematic equation v² = v₀² + 2aΔx from definitions.',
      '[A]Solve projectile motion for range given launch speed and angle.',
    ],
    'vital_sign': <String>[
      '[B]List the five vital signs and normal adult ranges.',
      '[I]A patient has BP 180/110, HR 118, RR 24 — prioritize your assessment steps.',
      '[A]Interpret trending vitals in a post-op patient developing sepsis.',
    ],
    'dosage': <String>[
      '[B]Convert 0.5 g to milligrams.',
      '[I]Calculate mL/hr for an IV order: 1000 mL over 8 hours.',
      '[A]Verify safe pediatric dose using weight-based mg/kg and available concentration.',
    ],
    'pharmacology': <String>[
      '[B]What is the difference between trade name and generic name?',
      '[I]Explain therapeutic index and why it matters for drug safety.',
      '[A]Analyze a case of polypharmacy and identify high-risk interactions.',
    ],
    'heart_failure': <String>[
      '[B]List classic signs and symptoms of left-sided heart failure.',
      '[B]What daily weights and symptoms should a HF patient monitor at home?',
      '[I]Explain why diuretics are used in HF management and what you monitor.',
      '[I]A patient with HF has crackles and JVD — list your first four actions.',
      '[A]Prioritize nursing interventions for acute decompensated heart failure.',
      '[A]Compare HFrEF vs HFpEF management priorities.',
    ],
    'diabetes': <String>[
      '[B]What are normal fasting blood glucose and HbA1c targets for most adults?',
      '[B]List symptoms of hypoglycemia and immediate treatment steps.',
      '[I]Calculate insulin correction dose using a sample sliding scale.',
      '[I]A patient has glucose 42 mg/dL and is awake — what do you do first?',
      '[A]Develop a teaching plan for a newly diagnosed type 2 diabetes patient.',
      '[A]Analyze DKA vs HHS presentation differences.',
    ],
    'sepsis': <String>[
      '[B]List the components of a sepsis screening bundle.',
      '[I]A patient is febrile, hypotensive, and lactate 4.2 — prioritize care.',
      '[A]Explain hour-1 sepsis bundle interventions and rationale.',
    ],
    'copd': <String>[
      '[B]Differentiate COPD from asthma in presentation.',
      '[I]Interpret ABG results in a COPD exacerbation.',
      '[A]Prioritize nursing care for a patient on BiPAP with COPD.',
    ],
    'wound': <String>[
      '[B]Describe stages of pressure injury.',
      '[I]Document a wound assessment using length, width, depth, drainage, odor.',
      '[A]Choose dressing type for a stage III pressure ulcer with moderate drainage.',
    ],
    'medical_surgical': <String>[
      '[B]What are the ABCs of primary assessment?',
      '[I]Prioritize care for a post-op patient with declining SpO₂ and restlessness.',
      '[A]Develop a nursing care plan for a complex med-surg admission.',
    ],
    'sql': <String>[
      '[B]Write a SELECT statement to list all customers from the Customers table.',
      '[I]Write a query joining Orders and Customers to show customer names with order totals.',
      '[A]Optimize a slow query — what indexes or rewrites would you consider?',
    ],
    'sort': <String>[
      '[B]What is the time complexity of bubble sort in the worst case?',
      '[I]Trace merge sort on the array [38, 27, 43, 3].',
      '[A]Choose between quicksort and mergesort for nearly sorted data and justify.',
    ],
    'linked_list': <String>[
      '[B]What are the advantages of a linked list over an array?',
      '[I]Implement reverse a singly linked list — describe the pointer updates.',
      '[A]Detect a cycle in a linked list in O(n) time and O(1) space.',
    ],
    'skeletal': <String>[
      '[B]Name the bones that form the appendicular skeleton vs axial skeleton.',
      '[I]Which landmark is used for intramuscular injection in the deltoid?',
      '[A]Relate clavicle fracture patterns to common mechanisms of injury.',
    ],
    'respiratory': <String>[
      '[B]Trace the path of air from nostrils to alveoli.',
      '[I]Explain how COPD affects gas exchange at the alveolar level.',
      '[A]Interpret ABG results showing respiratory acidosis.',
    ],
    'neuron': <String>[
      '[B]What is the function of dendrites vs axon?',
      '[I]Explain how myelin increases conduction velocity.',
      '[A]Describe excitatory vs inhibitory postsynaptic potentials.',
    ],
    'cardiovascular': <String>[
      '[B]Label the flow of blood through the heart chambers.',
      '[I]Explain the cardiac cycle events in systole and diastole.',
      '[A]Differentiate stable angina, NSTEMI, and STEMI presentations.',
    ],
  };

  static const Map<String, List<String>> _exact = <String, List<String>>{
    'mathematics|college_algebra|linear_equations': <String>[
      '[B]Solve 3x - 7 = 11 and check your solution.',
      '[B]Graph y = -2x + 4. What is the slope and y-intercept?',
      '[I]Write an equation for a line through (2, 5) and (6, 13).',
      '[I]Solve: 4(x - 1) = 2(x + 3).',
      r'[A]A phone plan costs $25 plus $0.10 per text. Another costs $40 flat. When is each cheaper?',
    ],
    'biology|cell_biology|organelles': <String>[
      '[B]Which organelle produces ATP? Which packages proteins for export?',
      '[B]What structure is found in plant cells but not animal cells?',
      '[I]Compare rough ER vs smooth ER structure and function.',
      '[A]Explain how a defect in lysosomal enzymes leads to storage diseases.',
    ],
    'biology|cell_biology|cell_membrane': <String>[
      '[B]What molecules pass easily through the lipid bilayer?',
      '[I]Compare osmosis, diffusion, and active transport with examples.',
      '[A]Predict what happens to a plant cell in a hypertonic salt solution.',
    ],
    'biology|genetics|dna_structure': <String>[
      '[B]Identify the sugar, phosphate, and bases in a DNA nucleotide.',
      '[I]Explain complementary base pairing and hydrogen bonding in the helix.',
      '[A]How does DNA packaging in nucleosomes affect gene accessibility?',
    ],
    'biology|genetics|replication': <String>[
      '[B]What is the role of helicase during DNA replication?',
      '[I]Explain leading vs lagging strand synthesis.',
      '[A]How do proofreading and mismatch repair maintain fidelity?',
    ],
    'biology|genetics|mendelian_genetics': <String>[
      '[B]Define dominant, recessive, genotype, and phenotype.',
      '[I]Cross Aa × Aa — what genotype and phenotype ratios result?',
      '[A]Explain incomplete dominance with a worked example.',
    ],
    'nursing|pharmacology|dosage_calculations': <String>[
      '[B]The order is 500 mg PO. Available: 250 mg tablets. How many tablets?',
      '[I]IV order: 250 mL over 2 hours. What is the pump rate in mL/hr?',
      '[A]Weight-based order: 5 mg/kg for a 72 kg patient — calculate total dose.',
    ],
    'nursing|health_assessment|vital_signs': <String>[
      '[B]Document normal ranges for temperature, pulse, respiration, and BP.',
      '[I]A patient is tachycardic and hypotensive — list your first three actions.',
      '[A]Interpret orthostatic vital sign changes and clinical significance.',
    ],
    'computer_science|data_structures|linked_lists': <String>[
      '[B]What is stored in a singly linked list node?',
      '[I]Find the middle element of a linked list in one pass — explain.',
      '[A]Merge two sorted linked lists in O(n) time.',
    ],
    'computer_science|algorithms|sorting': <String>[
      '[B]Which sorting algorithm is stable? Define stability.',
      '[I]Compare best/average/worst case for merge sort vs quicksort.',
      '[A]When would counting sort outperform comparison sorts?',
    ],
    'chemistry|general_chemistry|atomic_structure': <String>[
      '[B]How many protons, neutrons, and electrons are in a neutral ¹²C atom?',
      '[I]Write quantum numbers for the outermost electron of sodium.',
      '[A]Relate atomic radius trends to effective nuclear charge.',
    ],
    'physics|mechanics|forces': <String>[
      '[B]If net force on an object is zero, what can you say about its motion?',
      '[I]A 10 kg box is pushed with 50 N on a frictionless floor — find acceleration.',
      '[A]Solve an Atwood machine problem with two unequal masses.',
    ],
    'physics|electricity_magnetism|circuits': <String>[
      '[B]What happens to total resistance when resistors are added in series?',
      '[I]Calculate current through a 100 Ω resistor with 9 V applied.',
      '[A]Analyze a circuit with two batteries and three resistors — find branch currents.',
    ],
  };
}
