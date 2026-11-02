/// Unit name → topic names for a course.
class PracticeLabHierarchySeed {
  const PracticeLabHierarchySeed({required this.unit, required this.topics});

  final String unit;
  final List<String> topics;
}

/// Curated Subject → Course → Unit → Topic hierarchy.
/// AI generates unique labs per topic at runtime (Beginner / Intermediate / Advanced).
class PracticeLabHierarchyData {
  PracticeLabHierarchyData._();

  static List<PracticeLabHierarchySeed> forCourse(String subjectId, String courseId) {
    return _data['$subjectId|$courseId'] ?? const <PracticeLabHierarchySeed>[];
  }

  static const Map<String, List<PracticeLabHierarchySeed>> _data = <String, List<PracticeLabHierarchySeed>>{
    // ── Mathematics ──────────────────────────────────────────────────────────
    'mathematics|college_algebra': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Foundations', topics: <String>['Real Numbers', 'Algebraic Expressions']),
      PracticeLabHierarchySeed(unit: 'Equations', topics: <String>['Linear Equations', 'Inequalities', 'Systems of Equations']),
      PracticeLabHierarchySeed(unit: 'Functions', topics: <String>['Functions', 'Polynomial Functions', 'Rational Functions', 'Exponential Functions', 'Logarithmic Functions']),
      PracticeLabHierarchySeed(unit: 'Matrices', topics: <String>['Matrices']),
    ],
    'mathematics|precalculus': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Functions & Trigonometry', topics: <String>['Functions', 'Trigonometry']),
      PracticeLabHierarchySeed(unit: 'Advanced Topics', topics: <String>['Polar Coordinates', 'Parametric Equations', 'Complex Numbers', 'Conic Sections', 'Sequences & Series']),
    ],
    'mathematics|calculus_i': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Limits & Continuity', topics: <String>['Limits', 'Continuity']),
      PracticeLabHierarchySeed(unit: 'Derivatives', topics: <String>['Derivatives', 'Chain Rule', 'Implicit Differentiation']),
      PracticeLabHierarchySeed(unit: 'Applications', topics: <String>['Related Rates', 'Optimization', 'Curve Sketching']),
    ],
    'mathematics|calculus_ii': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Integration', topics: <String>['Integration', 'Substitution', 'Integration by Parts', 'Trigonometric Integrals', 'Improper Integrals']),
      PracticeLabHierarchySeed(unit: 'Applications', topics: <String>['Applications of Integration']),
      PracticeLabHierarchySeed(unit: 'Series', topics: <String>['Sequences', 'Series', 'Taylor Series']),
    ],
    'mathematics|calculus_iii': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Vectors & 3D', topics: <String>['Vectors', '3D Geometry']),
      PracticeLabHierarchySeed(unit: 'Multivariable Calculus', topics: <String>['Partial Derivatives', 'Multiple Integrals']),
      PracticeLabHierarchySeed(unit: 'Vector Calculus', topics: <String>['Vector Fields', 'Line Integrals', 'Surface Integrals']),
    ],

    // ── Computer Science ─────────────────────────────────────────────────────
    'computer_science|programming_fundamentals': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Basics', topics: <String>['Variables', 'Data Types', 'Loops', 'Functions']),
      PracticeLabHierarchySeed(unit: 'Data & OOP', topics: <String>['Arrays', 'OOP', 'File Handling', 'Error Handling']),
    ],
    'computer_science|data_structures': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Linear Structures', topics: <String>['Arrays', 'Linked Lists', 'Stacks', 'Queues']),
      PracticeLabHierarchySeed(unit: 'Trees & Hashing', topics: <String>['Trees', 'AVL Trees', 'Red-Black Trees', 'Hash Tables']),
      PracticeLabHierarchySeed(unit: 'Graphs', topics: <String>['Graphs']),
    ],
    'computer_science|algorithms': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Core Algorithms', topics: <String>['Sorting', 'Searching', 'Recursion']),
      PracticeLabHierarchySeed(unit: 'Advanced Strategies', topics: <String>['Divide & Conquer', 'Dynamic Programming', 'Greedy Algorithms', 'Graph Algorithms']),
    ],
    'computer_science|databases': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Database Design', topics: <String>['SQL', 'ER Diagrams', 'Normalization']),
      PracticeLabHierarchySeed(unit: 'Operations', topics: <String>['Joins', 'Transactions', 'Indexing']),
    ],
    'computer_science|operating_systems': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Processes', topics: <String>['Processes', 'Threads', 'Scheduling']),
      PracticeLabHierarchySeed(unit: 'Memory & Storage', topics: <String>['Memory Management', 'Virtual Memory', 'File Systems']),
    ],
    'computer_science|computer_networks': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Network Foundations', topics: <String>['OSI Model', 'TCP/IP', 'Routing']),
      PracticeLabHierarchySeed(unit: 'Applications & Security', topics: <String>['DNS', 'HTTP', 'Network Security']),
    ],

    // ── Biology ──────────────────────────────────────────────────────────────
    'biology|general_biology': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Core Biology', topics: <String>['Cell Structure', 'Cell Division', 'Genetics', 'Evolution', 'Ecology', 'Energy Flow']),
    ],
    'biology|cell_biology': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Cell Biology', topics: <String>['Cell Membrane', 'Organelles', 'Cell Communication', 'Cell Cycle', 'Apoptosis']),
    ],
    'biology|genetics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Molecular Genetics', topics: <String>['DNA Structure', 'Replication', 'Transcription', 'Translation']),
      PracticeLabHierarchySeed(unit: 'Classical & Population', topics: <String>['Mendelian Genetics', 'Population Genetics']),
    ],
    'biology|microbiology': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Microorganisms', topics: <String>['Bacteria', 'Viruses', 'Fungi', 'Parasites', 'Immunology']),
    ],

    // ── Chemistry ────────────────────────────────────────────────────────────
    'chemistry|general_chemistry': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'General Chemistry', topics: <String>['Atomic Structure', 'Chemical Bonding', 'Stoichiometry', 'Solutions', 'Thermochemistry', 'Equilibrium']),
    ],
    'chemistry|organic_chemistry': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Organic Chemistry', topics: <String>['Hydrocarbons', 'Functional Groups', 'Reactions', 'Stereochemistry', 'Spectroscopy']),
    ],
    'chemistry|biochemistry': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Biochemistry', topics: <String>['Proteins', 'Lipids', 'Carbohydrates', 'Enzymes', 'Metabolism']),
    ],

    // ── Physics ──────────────────────────────────────────────────────────────
    'physics|mechanics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Mechanics', topics: <String>['Motion', 'Forces', 'Energy', 'Momentum', 'Rotational Motion']),
    ],
    'physics|electricity_magnetism': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'E&M', topics: <String>['Electric Fields', 'Circuits', 'Capacitance', 'Magnetism', 'Electromagnetic Induction']),
    ],
    'physics|thermodynamics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Thermodynamics', topics: <String>['Heat', 'Entropy', 'Laws of Thermodynamics']),
    ],
    'physics|modern_physics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Modern Physics', topics: <String>['Relativity', 'Quantum Mechanics', 'Nuclear Physics']),
    ],

    // ── Nursing ──────────────────────────────────────────────────────────────
    'nursing|fundamentals': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Nursing Fundamentals', topics: <String>['Infection Control', 'Patient Safety', 'Documentation', 'Hygiene', 'Communication']),
    ],
    'nursing|pharmacology': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Pharmacology', topics: <String>['Drug Classifications', 'Dosage Calculations', 'Medication Administration', 'IV Therapy', 'Drug Interactions']),
    ],
    'nursing|health_assessment': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Assessment', topics: <String>['Vital Signs', 'Head-to-Toe Assessment', 'Neurological Assessment', 'Respiratory Assessment', 'Cardiovascular Assessment']),
    ],
    'nursing|pediatrics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Pediatrics', topics: <String>['Growth & Development', 'Pediatric Assessment', 'Childhood Illnesses', 'Immunizations']),
    ],
    'nursing|medical_surgical_nursing': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Med-Surg', topics: <String>['Diabetes', 'Heart Failure', 'COPD', 'Renal Failure', 'Cancer Care']),
    ],
    'nursing|critical_care': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Critical Care', topics: <String>['Shock', 'Sepsis', 'Ventilator Management', 'Cardiac Emergencies']),
    ],

    // ── Medicine ─────────────────────────────────────────────────────────────
    'medicine|anatomy': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Body Systems', topics: <String>['Musculoskeletal', 'Nervous System', 'Cardiovascular System', 'Respiratory System']),
    ],
    'medicine|physiology': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Physiology', topics: <String>['Homeostasis', 'Cardiovascular Function', 'Endocrine Function']),
    ],
    'medicine|pathology': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Pathology', topics: <String>['Inflammation', 'Neoplasia', 'Infectious Diseases']),
    ],
    'medicine|internal_medicine': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Internal Medicine', topics: <String>['Cardiology', 'Endocrinology', 'Gastroenterology', 'Pulmonology']),
    ],
    'medicine|surgery': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Surgery', topics: <String>['Surgical Principles', 'Trauma', 'Postoperative Care']),
    ],
    'medicine|emergency_medicine': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Emergency Medicine', topics: <String>['Trauma', 'Cardiac Arrest', 'Stroke', 'Toxicology']),
    ],

    // ── Psychology ───────────────────────────────────────────────────────────
    'psychology|general_psychology': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'General Psychology', topics: <String>['Learning', 'Memory', 'Motivation', 'Personality']),
    ],
    'psychology|cognitive_psychology': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Cognitive Psychology', topics: <String>['Perception', 'Attention', 'Decision Making']),
    ],
    'psychology|clinical_psychology': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Clinical Psychology', topics: <String>['Anxiety', 'Depression', 'PTSD', 'Therapy']),
    ],
    'psychology|abnormal_psychology': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Abnormal Psychology', topics: <String>['Mood Disorders', 'Personality Disorders', 'Schizophrenia']),
    ],

    // ── Business ─────────────────────────────────────────────────────────────
    'business|accounting': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Accounting', topics: <String>['Financial Statements', 'Journal Entries', 'Auditing', 'Taxation']),
    ],
    'business|finance': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Finance', topics: <String>['Investments', 'Valuation', 'Risk Management', 'Corporate Finance']),
    ],
    'business|marketing': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Marketing', topics: <String>['Branding', 'Consumer Behavior', 'Digital Marketing', 'Market Research']),
    ],
    'business|management': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Management', topics: <String>['Leadership', 'Strategy', 'Organizational Behavior']),
    ],
    'business|entrepreneurship': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Entrepreneurship', topics: <String>['Startup Formation', 'Funding', 'Business Models']),
    ],
    'business|business_law': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Business Law', topics: <String>['Contracts', 'Employment Law', 'Corporate Law']),
    ],

    // ── Law ──────────────────────────────────────────────────────────────────
    'law|criminal_law': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Criminal Law', topics: <String>['Crimes Against Persons', 'Property Crimes', 'Defenses']),
    ],
    'law|constitutional_law': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Constitutional Law', topics: <String>['Civil Rights', 'Due Process', 'Equal Protection']),
    ],
    'law|contract_law': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Contract Law', topics: <String>['Formation', 'Breach', 'Remedies']),
    ],
    'law|torts': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Torts', topics: <String>['Negligence', 'Liability', 'Damages']),
    ],
    'law|civil_procedure': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Civil Procedure', topics: <String>['Pleadings', 'Discovery', 'Trial Process']),
    ],
    'law|evidence': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Evidence', topics: <String>['Witnesses', 'Hearsay', 'Expert Testimony']),
    ],

    // ── Engineering ──────────────────────────────────────────────────────────
    'engineering|statics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Statics', topics: <String>['Equilibrium', 'Trusses', 'Frames']),
    ],
    'engineering|dynamics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Dynamics', topics: <String>['Kinematics', 'Kinetics']),
    ],
    'engineering|thermodynamics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Thermodynamics', topics: <String>['Energy Systems', 'Heat Transfer']),
    ],
    'engineering|fluid_mechanics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Fluid Mechanics', topics: <String>['Fluid Properties', 'Flow Analysis']),
    ],
    'engineering|circuits': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Circuits', topics: <String>['DC Circuits', 'AC Circuits', 'Electronics']),
    ],
    'engineering|materials_science': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Materials Science', topics: <String>['Metals', 'Polymers', 'Composites']),
    ],

    // ── English ──────────────────────────────────────────────────────────────
    'english|composition': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Composition', topics: <String>['Essays', 'Research Papers', 'Argumentative Writing']),
    ],
    'english|literature': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Literature', topics: <String>['Poetry', 'Drama', 'Fiction']),
    ],
    'english|creative_writing': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Creative Writing', topics: <String>['Storytelling', 'Character Development', 'World Building']),
    ],
    'english|technical_writing': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Technical Writing', topics: <String>['Reports', 'Documentation', 'Proposals']),
    ],

    // ── Economics ────────────────────────────────────────────────────────────
    'economics|microeconomics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Microeconomics', topics: <String>['Supply & Demand', 'Consumer Theory', 'Market Structures']),
    ],
    'economics|macroeconomics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Macroeconomics', topics: <String>['GDP', 'Inflation', 'Monetary Policy']),
    ],
    'economics|econometrics': <PracticeLabHierarchySeed>[
      PracticeLabHierarchySeed(unit: 'Econometrics', topics: <String>['Regression', 'Forecasting', 'Statistical Modeling']),
    ],
  };
}
