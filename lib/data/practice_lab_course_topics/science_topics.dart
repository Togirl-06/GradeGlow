const Map<String, List<String>> biologyCourseTopics = <String, List<String>>{
  'biology|general_biology': <String>[
    'Scientific Method', 'Cell Structure', 'Photosynthesis', 'Cellular Respiration',
    'Evolution', 'Classification', 'Homeostasis', 'Lab Safety',
    'Water & Life', 'Macromolecules', 'Enzymes', 'Membrane Transport',
    'Genetics Intro', 'Ecology Intro', 'Biotechnology', 'Exam Review',
  ],
  'biology|cell_biology': <String>[
    'Cell Membrane Transport', 'Mitosis & Meiosis', 'Organelle Function', 'Signal Transduction',
    'Protein Synthesis', 'Cell Cycle Regulation', 'Apoptosis', 'Microscopy Techniques',
    'Endocytosis & Exocytosis', 'Cytoskeleton', 'Cell Junctions', 'Stem Cells',
    'Cancer Biology', 'Cell Communication', 'ATP & Energy', 'Exam Review',
  ],
  'biology|genetics': <String>[
    'DNA Replication', 'Mendelian Inheritance', 'Gene Expression', 'Mutations',
    'Pedigree Analysis', 'Chromosomal Abnormalities', 'Genetic Engineering', 'Population Genetics',
    'Transcription & Translation', 'Linkage & Mapping', 'Epigenetics', 'CRISPR',
    'Hardy-Weinberg', 'Genetic Disorders', 'Genomics', 'Exam Review',
  ],
  'biology|microbiology': <String>[
    'Bacterial Structure', 'Viral Replication', 'Antibiotics', 'Sterilization',
    'Culture Techniques', 'Host-Pathogen Interactions', 'Immunology Basics', 'Epidemiology',
    'Gram Staining', 'Fungi & Protists', 'Vaccines', 'Biofilms',
    'Food Microbiology', 'Water Quality Testing', 'Emerging Pathogens', 'Exam Review',
  ],
  'biology|anatomy': <String>[
    'Skeletal System', 'Muscular System', 'Cardiovascular Anatomy', 'Nervous System',
    'Digestive Tract', 'Respiratory System', 'Renal Anatomy', 'Regional Anatomy',
    'Integumentary System', 'Endocrine Glands', 'Lymphatic System', 'Reproductive Anatomy',
    'Joint Types', 'Cranial Nerves', 'Body Cavities', 'Exam Review',
  ],
  'biology|physiology': <String>[
    'Cardiac Cycle', 'Neural Signaling', 'Renal Filtration', 'Muscle Contraction',
    'Endocrine Regulation', 'Respiratory Gas Exchange', 'Digestive Absorption', 'Homeostatic Feedback',
    'Blood Pressure Regulation', 'Action Potentials', 'Acid-Base Balance', 'Thermoregulation',
    'Reproductive Physiology', 'Exercise Physiology', 'Sleep Physiology', 'Exam Review',
  ],
  'biology|ecology': <String>[
    'Ecosystems', 'Food Webs', 'Population Dynamics', 'Biomes',
    'Conservation Biology', 'Climate Change Impacts', 'Biodiversity', 'Succession',
    'Carrying Capacity', 'Niche & Competition', 'Keystone Species', 'Invasive Species',
    'Carbon Cycle', 'Water Cycle', 'Restoration Ecology', 'Exam Review',
  ],
};

const Map<String, List<String>> chemistryCourseTopics = <String, List<String>>{
  'chemistry|general_chemistry': <String>[
    'Atomic Structure', 'Periodic Trends', 'Chemical Bonding', 'Stoichiometry',
    'Gas Laws', 'Acids & Bases', 'Thermochemistry', 'Equilibrium',
    'Molarity & Dilutions', 'Redox Reactions', 'Electrochemistry Intro', 'Colligative Properties',
    'Lewis Structures', 'VSEPR Theory', 'Kinetics Intro', 'Exam Review',
  ],
  'chemistry|organic_chemistry': <String>[
    'Functional Groups', 'Reaction Mechanisms', 'Stereochemistry', 'Synthesis Planning',
    'Alkene Reactions', 'Aromatic Chemistry', 'Carbonyl Chemistry', 'Spectroscopy',
    'SN1 & SN2 Reactions', 'E1 & E2 Reactions', 'Alcohol Reactions', 'Carboxylic Acids',
    'Amine Chemistry', 'Retrosynthesis', 'NMR Interpretation', 'Exam Review',
  ],
  'chemistry|biochemistry': <String>[
    'Amino Acids', 'Enzyme Kinetics', 'Metabolic Pathways', 'Carbohydrate Structure',
    'Lipid Metabolism', 'Protein Folding', 'DNA & RNA', 'Clinical Biochemistry',
    'Glycolysis', 'Citric Acid Cycle', 'Oxidative Phosphorylation', 'Gluconeogenesis',
    'Hormone Signaling', 'Membrane Proteins', 'Vitamins & Cofactors', 'Exam Review',
  ],
  'chemistry|analytical_chemistry': <String>[
    'Titration Methods', 'Chromatography', 'Spectrophotometry', 'Calibration Curves',
    'Mass Spectrometry', 'Electrochemistry', 'Sample Preparation', 'Quality Control',
    'Gravimetric Analysis', 'Complexometric Titrations', 'HPLC', 'GC-MS',
    'Detection Limits', 'Method Validation', 'Environmental Analysis', 'Exam Review',
  ],
  'chemistry|physical_chemistry': <String>[
    'Thermodynamics', 'Kinetics', 'Quantum Chemistry', 'Statistical Mechanics',
    'Electrochemistry', 'Surface Chemistry', 'Phase Diagrams', 'Molecular Spectroscopy',
    'Enthalpy & Entropy', 'Rate Laws', 'Catalysis', 'Partition Functions',
    'Molecular Orbitals', 'Spectroscopic Selection Rules', 'Colloids', 'Exam Review',
  ],
};

const Map<String, List<String>> physicsCourseTopics = <String, List<String>>{
  'physics|mechanics': <String>[
    'Kinematics', 'Newton\'s Laws', 'Work & Energy', 'Momentum',
    'Rotational Motion', 'Gravitation', 'Oscillations', 'Fluid Statics',
    'Projectile Motion', 'Friction', 'Collisions', 'Torque',
    'Simple Harmonic Motion', 'Pendulums', 'Buoyancy', 'Exam Review',
  ],
  'physics|electricity_magnetism': <String>[
    'Coulomb\'s Law', 'Electric Fields', 'Ohm\'s Law', 'Capacitance',
    'Magnetic Fields', 'Faraday\'s Law', 'AC Circuits', 'Maxwell\'s Equations',
    'Gauss\'s Law', 'RC Circuits', 'Inductance', 'Transformers',
    'Lorentz Force', 'Electromagnetic Waves', 'Circuit Analysis', 'Exam Review',
  ],
  'physics|thermodynamics': <String>[
    'Heat Transfer', 'Laws of Thermodynamics', 'Entropy', 'Heat Engines',
    'Kinetic Theory', 'Phase Transitions', 'Free Energy', 'Statistical Thermodynamics',
    'Carnot Cycle', 'Heat Pumps', 'Enthalpy', 'Reversible Processes',
    'Boltzmann Distribution', 'Blackbody Radiation', 'Thermal Expansion', 'Exam Review',
  ],
  'physics|modern_physics': <String>[
    'Special Relativity', 'Photoelectric Effect', 'Bohr Model', 'Wave-Particle Duality',
    'Quantum Tunneling', 'Nuclear Physics', 'Particle Physics', 'Cosmology Basics',
    'de Broglie Wavelength', 'Heisenberg Uncertainty', 'Radioactive Decay', 'Fission & Fusion',
    'Standard Model', 'Dark Matter', 'Hubble\'s Law', 'Exam Review',
  ],
};
