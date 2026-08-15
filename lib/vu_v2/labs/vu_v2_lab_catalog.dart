import 'vu_v2_lab_models.dart';

abstract final class VuV2LabCatalog {
  /// Product surface: Computer Science only. Other schools removed from Labs UI.
  static List<VuV2LabSchoolDef> get schools => <VuV2LabSchoolDef>[computerScience];

  static VuV2LabSchoolDef get computerScience => _legacySchools.firstWhere(
        (VuV2LabSchoolDef s) => s.school == VuV2LabSchool.computerScience,
      );

  /// Legacy definitions kept for offline references; not shown in Labs hub.
  static const List<VuV2LabSchoolDef> _legacySchools = <VuV2LabSchoolDef>[
    VuV2LabSchoolDef(
      school: VuV2LabSchool.physics,
      title: 'Physics Research Bay',
      emoji: '⚛️',
      blurb: 'Live gravity, circuits, projectiles, and wave benches.',
      subjectIds: <String>['physics'],
      experiments: <VuV2LabExperiment>[
        VuV2LabExperiment(
          id: 'phys_gravity',
          title: 'Gravity drop',
          emoji: '🌍',
          blurb: 'Drop masses under adjustable gravity.',
          objectives: <String>[
            'Relate g to fall time',
            'Compare Earth vs Moon g',
            'Predict impact speed qualitatively',
          ],
          instructions: <String>[
            'Set gravity with the slider.',
            'Tap Drop to release the mass.',
            'Watch fall time change — then reset and try another g.',
          ],
          professorIntro:
              'Welcome to the Gravity Bay. Adjust g and drop the mass — '
              'notice how fall time shrinks as gravity rises. Ask me anytime '
              'what you observe.',
          notesSeed:
              'g (Earth) ≈ 9.8 m/s². On the Moon, g ≈ 1.6 m/s². '
              'Without air resistance, all masses fall at the same rate.',
          simulationKind: VuV2LabSimulationKind.physicsGravity,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'If gravity increases, fall time usually…',
              choices: <String>['Increases', 'Decreases', 'Stays identical always', 'Becomes random'],
              correctIndex: 1,
              explain: 'Stronger g means faster acceleration — shorter fall time.',
            ),
            VuV2LabQuizItem(
              prompt: 'Ignoring air resistance, heavier masses fall…',
              choices: <String>['Much faster', 'Much slower', 'At the same rate', 'Only sideways'],
              correctIndex: 2,
              explain: 'Galileo’s insight: acceleration is independent of mass.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'phys_circuit',
          title: 'Simple circuit',
          emoji: '💡',
          blurb: 'Close the loop and light the bulb.',
          objectives: <String>[
            'Identify an open vs closed circuit',
            'Toggle switches purposefully',
            'State why the bulb needs a complete path',
          ],
          instructions: <String>[
            'Tap each switch to open or close it.',
            'The bulb lights only when both switches complete the loop.',
            'Reset to restore the default open circuit.',
          ],
          professorIntro:
              'Circuits Lab. Electricity needs a closed path. Toggle the '
              'switches and watch the bulb — I will nudge you when the loop closes.',
          notesSeed:
              'Current flows only in a closed circuit. Switches break or '
              'complete the path. Series: both switches must be closed.',
          simulationKind: VuV2LabSimulationKind.physicsCircuit,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'A bulb stays dark when…',
              choices: <String>[
                'The loop is open',
                'Voltage exists anywhere',
                'Wires are copper',
                'The switch is labeled ON incorrectly',
              ],
              correctIndex: 0,
              explain: 'An open path stops continuous current.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'phys_projectile',
          title: 'Projectile motion',
          emoji: '🎯',
          blurb: 'Launch with angle and speed controls.',
          objectives: <String>[
            'See how angle affects range',
            'Relate launch speed to distance',
            'Find a “sweet spot” near 45° (idealized)',
          ],
          instructions: <String>[
            'Set launch angle and speed.',
            'Tap Launch and watch the arc.',
            'Reset and compare another angle.',
          ],
          professorIntro:
              'Range Bay. Ideal projectiles peak near 45° without air drag. '
              'Tune angle and speed — then tell me what changed.',
          notesSeed:
              'Horizontal velocity stays constant (no drag). Vertical motion '
              'is accelerated by gravity. Range depends on both v and θ.',
          simulationKind: VuV2LabSimulationKind.physicsProjectile,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'On flat ground with no air, max range is near…',
              choices: <String>['0°', '30°', '45°', '90°'],
              correctIndex: 2,
              explain: 'Idealized theory peaks around 45°.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'phys_waves',
          title: 'Wave desk',
          emoji: '🌊',
          blurb: 'Tune amplitude and frequency on a live waveform.',
          objectives: <String>[
            'Separate amplitude from frequency',
            'Predict how the graph changes',
            'Log one controlled variable change',
          ],
          instructions: <String>[
            'Slide amplitude — watch crest height.',
            'Slide frequency — watch oscillations tighten.',
            'Change only one slider at a time and note the result.',
          ],
          professorIntro:
              'Waves Bay. Amplitude is height; frequency is how often. '
              'Isolate one variable — that is experimental discipline.',
          notesSeed:
              'A = amplitude (energy related). f = frequency (oscillations per time). '
              'Wavelength shortens when frequency rises at fixed wave speed.',
          simulationKind: VuV2LabSimulationKind.physicsWaves,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'Raising frequency while keeping wave speed fixed usually…',
              choices: <String>[
                'Shortens wavelength',
                'Deletes energy forever',
                'Stops oscillation',
                'Only changes color of the UI',
              ],
              correctIndex: 0,
              explain: 'v = fλ — if v is fixed, higher f means smaller λ.',
            ),
          ],
        ),
      ],
    ),
    VuV2LabSchoolDef(
      school: VuV2LabSchool.chemistry,
      title: 'Chemistry Synthesis Lab',
      emoji: '⚗️',
      blurb: 'Reactions, pH, molecules, and titration benches.',
      subjectIds: <String>['chemistry'],
      experiments: <VuV2LabExperiment>[
        VuV2LabExperiment(
          id: 'chem_reaction',
          title: 'Chemical reactions',
          emoji: '🧪',
          blurb: 'Combine reagents and watch products form.',
          objectives: <String>[
            'Mix two reagents deliberately',
            'Observe a visual product cue',
            'Reset and vary ratios',
          ],
          instructions: <String>[
            'Add Reagent A, then Reagent B.',
            'Watch color / bubbles as the product forms.',
            'Reset to clear the beaker.',
          ],
          professorIntro:
              'Reaction Bench. Stoichiometry is a story of proportions. '
              'Add reagents and describe what you see — I will help interpret it.',
          notesSeed:
              'Reactants → products. Limiting reagent caps yield. '
              'Color change and gas are common observation cues.',
          simulationKind: VuV2LabSimulationKind.chemistryReaction,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'The limiting reagent…',
              choices: <String>[
                'Runs out first and caps product',
                'Is always water',
                'Is leftover after reaction',
                'Cannot be identified',
              ],
              correctIndex: 0,
              explain: 'Whichever reactant is consumed first limits yield.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'chem_ph',
          title: 'pH experiments',
          emoji: '📟',
          blurb: 'Slide from acid to base and read the scale.',
          objectives: <String>[
            'Locate acids vs bases on the pH scale',
            'Relate indicator color to pH',
            'Aim for neutral (~7)',
          ],
          instructions: <String>[
            'Drag the pH slider.',
            'Watch indicator color shift.',
            'Reset returns to neutral water.',
          ],
          professorIntro:
              'pH Station. Acids are below 7; bases above. Move the slider '
              'and match the color story to the number.',
          notesSeed:
              'pH 7 ≈ neutral. Each unit is a tenfold [H⁺] change. '
              'Indicators help visualize regions of the scale.',
          simulationKind: VuV2LabSimulationKind.chemistryPh,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'A solution with pH 3 is…',
              choices: <String>['Acidic', 'Neutral', 'Basic', 'Pure water'],
              correctIndex: 0,
              explain: 'pH < 7 means acidic.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'chem_molecule',
          title: 'Molecule builder',
          emoji: '🔬',
          blurb: 'Assemble atoms into a target molecule.',
          objectives: <String>[
            'Place atoms to match a formula',
            'Count bonds / atoms carefully',
            'Reset and rebuild cleanly',
          ],
          instructions: <String>[
            'Tap atoms to add them to the workspace.',
            'Match the target formula shown.',
            'Reset clears the build.',
          ],
          professorIntro:
              'Builder Bay. Formulas are recipes. Build toward the target — '
              'ask me if atom counts look off.',
          notesSeed:
              'Chemical formulas count atoms (H₂O = 2 H + 1 O). '
              'Structure matters in advanced bonding — start with counts.',
          simulationKind: VuV2LabSimulationKind.chemistryMolecule,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'H₂O contains how many hydrogen atoms?',
              choices: <String>['1', '2', '3', '8'],
              correctIndex: 1,
              explain: 'The subscript 2 applies to hydrogen.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'chem_titration',
          title: 'Titration bench',
          emoji: '🧴',
          blurb: 'Add base toward the endpoint and catch the color flip.',
          objectives: <String>[
            'Approach the endpoint carefully',
            'Record approximate equivalence volume',
            'Explain overshoot risk',
          ],
          instructions: <String>[
            'Increase base volume with the slider.',
            'Watch indicator color near ~25 mL.',
            'Stop near the endpoint and log the volume.',
          ],
          professorIntro:
              'Titration Suite. Go slow near the endpoint — overshoot teaches '
              'why dropwise technique matters in real labs.',
          notesSeed:
              'Equivalence ≈ indicator endpoint for a well-chosen indicator. '
              'Record burette volume. Overshoot biases concentration high/low.',
          simulationKind: VuV2LabSimulationKind.chemistryTitration,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'Why add base slowly near the endpoint?',
              choices: <String>[
                'To avoid overshooting the color change',
                'Because chemistry only works slowly',
                'To heat the flask',
                'To invent new elements',
              ],
              correctIndex: 0,
              explain: 'Near equivalence, tiny volumes flip the indicator.',
            ),
          ],
        ),
      ],
    ),
    VuV2LabSchoolDef(
      school: VuV2LabSchool.biology,
      title: 'Biology Discovery Suite',
      emoji: '🧬',
      blurb: 'Anatomy, cells, DNA, and ecology benches.',
      subjectIds: <String>['biology'],
      experiments: <VuV2LabExperiment>[
        VuV2LabExperiment(
          id: 'bio_anatomy',
          title: 'Human anatomy',
          emoji: '🫀',
          blurb: 'Identify organs on a virtual body map.',
          objectives: <String>[
            'Locate major organs',
            'Connect organ to function',
            'Quiz yourself after exploring',
          ],
          instructions: <String>[
            'Tap highlighted regions on the body.',
            'Read the organ label and function.',
            'Reset clears your selections.',
          ],
          professorIntro:
              'Anatomy Suite. Tap each region — I will confirm the organ and '
              'its job. Curiosity beats memorization alone.',
          notesSeed:
              'Heart pumps blood; lungs exchange gases; brain coordinates; '
              'liver processes nutrients and detoxifies.',
          simulationKind: VuV2LabSimulationKind.biologyAnatomy,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'Which organ primarily pumps blood?',
              choices: <String>['Liver', 'Heart', 'Kidney', 'Stomach'],
              correctIndex: 1,
              explain: 'The heart is the circulatory pump.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'bio_cell',
          title: 'Cell exploration',
          emoji: '🦠',
          blurb: 'Tour organelles inside a cell.',
          objectives: <String>[
            'Name key organelles',
            'Match organelle to role',
            'Contrast nucleus vs mitochondria',
          ],
          instructions: <String>[
            'Tap organelles in the cell diagram.',
            'Read each role aloud or in notes.',
            'Reset clears highlights.',
          ],
          professorIntro:
              'Cell Bay. Each organelle has a specialty. Tap around — then '
              'summarize the nucleus vs mitochondria for me.',
          notesSeed:
              'Nucleus stores DNA. Mitochondria make ATP. Membrane controls '
              'what enters and leaves.',
          simulationKind: VuV2LabSimulationKind.biologyCell,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'Mitochondria are best known for…',
              choices: <String>['Storing DNA', 'Making ATP', 'Photosynthesis only', 'Building ribosomes'],
              correctIndex: 1,
              explain: 'They are the cell’s powerhouses (ATP).',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'bio_dna',
          title: 'DNA simulations',
          emoji: '🧩',
          blurb: 'Pair bases and build a complementary strand.',
          objectives: <String>[
            'Apply base-pairing rules',
            'Build a complementary sequence',
            'Reset and try a new strand',
          ],
          instructions: <String>[
            'Tap the correct complementary base for each position.',
            'A pairs with T; C pairs with G.',
            'Reset starts a new template.',
          ],
          professorIntro:
              'Genetics Bench. Base pairs are strict: A–T and C–G. Fill the '
              'complement — I celebrate clean pairing.',
          notesSeed:
              'DNA is antiparallel double helix. A↔T, C↔G. Sequence encodes genes.',
          simulationKind: VuV2LabSimulationKind.biologyDna,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'Adenine pairs with…',
              choices: <String>['Guanine', 'Cytosine', 'Thymine', 'Uracil in DNA'],
              correctIndex: 2,
              explain: 'In DNA, A pairs with T.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'bio_ecology',
          title: 'Ecology bay',
          emoji: '🌿',
          blurb: 'Advance seasons and watch predator–prey balance shift.',
          objectives: <String>[
            'Observe population feedback',
            'Predict next-season trend',
            'Log one causal story',
          ],
          instructions: <String>[
            'Advance a season and watch prey vs predators.',
            'Run several seasons before concluding.',
            'Write the feedback loop in your notebook.',
          ],
          professorIntro:
              'Ecology Suite. More prey feeds predators; more predators cut prey. '
              'Watch the oscillation — then explain it without jargon overload.',
          notesSeed:
              'Predator–prey systems show delayed feedback. Carrying capacity and '
              'hunting pressure shape the curves.',
          simulationKind: VuV2LabSimulationKind.biologyEcology,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'If predators rise sharply, prey usually…',
              choices: <String>[
                'Decline after pressure increases',
                'Instantly become predators',
                'Ignore all feedback',
                'Stop reproducing forever for no reason',
              ],
              correctIndex: 0,
              explain: 'Higher predation pressure reduces prey numbers.',
            ),
          ],
        ),
      ],
    ),
    VuV2LabSchoolDef(
      school: VuV2LabSchool.computerScience,
      title: 'Computer Science Lab',
      emoji: '💻',
      blurb: 'Algorithm Arena — interview-style coding problems with a full Code Bench.',
      subjectIds: <String>[
        'computer_science',
        'software_engineering',
        'artificial_intelligence',
        'data_science',
        'cybersecurity',
        'information_technology',
      ],
      experiments: <VuV2LabExperiment>[
        VuV2LabExperiment(
          id: 'cs_arena_all',
          title: 'Algorithm Arena',
          emoji: '🏟️',
          blurb: 'Browse hundreds of coding problems. Run tests. Submit.',
          objectives: <String>[
            'Pick a problem by difficulty or topic',
            'Implement a correct solution',
            'Pass sample tests, then submit',
          ],
          instructions: <String>[
            'Open the problem list and choose a challenge.',
            'Read examples and constraints carefully.',
            'Code in the Code Bench, Run, then Submit.',
          ],
          professorIntro:
              'Welcome to Algorithm Arena. Treat each problem like an interview: '
              'clarify, plan, code, test, then submit.',
          notesSeed:
              'Track patterns you see: two pointers, hashing, BFS/DFS, DP…',
          simulationKind: VuV2LabSimulationKind.csChallenge,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'Before coding an interview problem, you should…',
              choices: <String>[
                'Restate inputs and desired output',
                'Memorize syntax only',
                'Skip examples',
                'Guess randomly forever',
              ],
              correctIndex: 0,
              explain: 'Clarify the contract before coding.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'cs_arena_easy',
          title: 'Easy problem set',
          emoji: '🟢',
          blurb: 'Warm-up problems — build confidence and patterns.',
          objectives: <String>[
            'Solve Easy problems cleanly',
            'Practice clear code structure',
            'Build a notes habit',
          ],
          instructions: <String>[
            'Filter to Easy and pick a problem.',
            'Implement, Run samples, Submit.',
            'Write approach notes after each solve.',
          ],
          professorIntro:
              'Easy set unlocked. Speed is not the goal — clarity is.',
          notesSeed: 'Easy patterns I want to master:\n',
          simulationKind: VuV2LabSimulationKind.csEditor,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'A good Easy-problem habit is…',
              choices: <String>[
                'Verify with the given examples first',
                'Never run tests',
                'Ignore constraints',
                'Skip the description',
              ],
              correctIndex: 0,
              explain: 'Examples catch misunderstandings early.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'cs_arena_medium',
          title: 'Medium problem set',
          emoji: '🟡',
          blurb: 'Core interview difficulty — data structures and algorithms.',
          objectives: <String>[
            'Choose the right structure',
            'Explain time/space tradeoffs',
            'Handle edge cases',
          ],
          instructions: <String>[
            'Open Medium problems in Algorithm Arena.',
            'Outline approach in Notes before coding.',
            'Submit only after samples pass.',
          ],
          professorIntro:
              'Medium Arena. Ask me for a hint if you stall — not for the full answer.',
          notesSeed: 'Medium approach journal:\n',
          simulationKind: VuV2LabSimulationKind.csChallenge,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'If sample tests pass but Submit fails…',
              choices: <String>[
                'Re-check constraints and edge cases',
                'Delete the solution',
                'Ignore hidden tests forever',
                'Change languages randomly',
              ],
              correctIndex: 0,
              explain: 'Hidden tests often cover edges and constraints.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'cs_arena_hard',
          title: 'Hard problem set',
          emoji: '🔴',
          blurb: 'Tough challenges for deep problem-solving stamina.',
          objectives: <String>[
            'Break hard prompts into subproblems',
            'Optimize after a correct baseline',
            'Stay calm under complexity',
          ],
          instructions: <String>[
            'Filter Hard problems.',
            'Start with a correct (even slow) idea.',
            'Optimize and Submit.',
          ],
          professorIntro:
              'Hard set. Correct first, fast second. I am here for strategy hints.',
          notesSeed: 'Hard problem decompositions:\n',
          simulationKind: VuV2LabSimulationKind.csChallenge,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'On Hard problems, a strong first move is…',
              choices: <String>[
                'Decompose into smaller solvable pieces',
                'Type random code',
                'Skip reading the prompt',
                'Avoid examples',
              ],
              correctIndex: 0,
              explain: 'Decomposition turns Hard into a sequence of Mediums.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'cs_arena_debug',
          title: 'Debug desk',
          emoji: '🐛',
          blurb: 'Buggy starter code — find the flaw and make tests pass.',
          objectives: <String>[
            'Spot logic bugs quickly',
            'Fix without a full rewrite',
            'Confirm with Run + Submit',
          ],
          instructions: <String>[
            'Open a Debug challenge.',
            'Compare failing output to examples.',
            'Patch the bug, then Submit.',
          ],
          professorIntro:
              'Debug Desk. The bug is a clue — read the failing case before editing.',
          notesSeed: 'Bugs I keep seeing:\n',
          simulationKind: VuV2LabSimulationKind.csDebug,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'A classic loop bug is…',
              choices: <String>[
                'Off-by-one',
                'Too many comments',
                'Using spaces',
                'Naming variables',
              ],
              correctIndex: 0,
              explain: 'Off-by-one mistakes are extremely common in loops.',
            ),
          ],
        ),
      ],
    ),
    VuV2LabSchoolDef(
      school: VuV2LabSchool.nursing,
      title: 'Emergency Department',
      emoji: '🏥',
      blurb:
          'Enter Riverside Med as a Student Nurse. Walk the floor. '
          'Work shifts. Not a quiz.',
      subjectIds: <String>['nursing'],
      experiments: <VuV2LabExperiment>[
        VuV2LabExperiment(
          id: 'nurse_ed_world',
          title: 'Enter the ED',
          emoji: '🚪',
          blurb: 'Clock in. Receive your role. Work real missions on the floor.',
          objectives: <String>[
            'Report to Charge Nurse Diaz',
            'Move between hospital locations',
            'Complete shift missions with consequences',
          ],
          instructions: <String>[
            'Enter the hospital map.',
            'Read the assignment board at the nurses\' station.',
            'Start your shift — this is a job, not a quiz.',
          ],
          professorIntro:
              'You are a Student Nurse at Riverside Med. Patients first. '
              'I evaluate your judgment after each shift.',
          notesSeed:
              'ABCs, allergies, two identifiers, escalate early, reassess.',
          simulationKind: VuV2LabSimulationKind.nursingPatient,
          quiz: <VuV2LabQuizItem>[],
        ),
        VuV2LabExperiment(
          id: 'nurse_shift_board',
          title: 'Assignment board',
          emoji: '📋',
          blurb: 'Same career world — nurses\' station mission board.',
          objectives: <String>[
            'See unlocked missions',
            'Replay cleared shifts',
            'Track skills and badges',
          ],
          instructions: <String>[
            'Opens the ED career floor.',
          ],
          professorIntro: 'Your board is waiting at the nurses\' station.',
          notesSeed: 'Clear missions in order. Crisis and boss unlock later.',
          simulationKind: VuV2LabSimulationKind.nursingScenario,
          quiz: <VuV2LabQuizItem>[],
        ),
        VuV2LabExperiment(
          id: 'nurse_career_profile',
          title: 'Career wards',
          emoji: '⭐',
          blurb: 'XP, skills, badges, unlockable wards (ICU / OR / Pharmacy).',
          objectives: <String>[
            'Review clinical skills',
            'See locked wards',
            'Plan next mission',
          ],
          instructions: <String>[
            'Opens the ED career floor.',
          ],
          professorIntro: 'Level up by surviving shifts — not memorizing answers.',
          notesSeed: 'ICU unlocks after strong early missions.',
          simulationKind: VuV2LabSimulationKind.nursingEquipment,
          quiz: <VuV2LabQuizItem>[],
        ),
      ],
    ),
    VuV2LabSchoolDef(
      school: VuV2LabSchool.business,
      title: 'Business Lab',
      emoji: '📈',
      blurb: 'Run a company from an executive command center.',
      subjectIds: <String>['business', 'business_administration'],
      experiments: <VuV2LabExperiment>[
        VuV2LabExperiment(
          id: 'biz_sim_center',
          title: 'Business Simulation Center',
          emoji: '🏢',
          blurb: 'CEO dashboard, departments, crises, and board.',
          objectives: <String>[
            'Lead a live simulated company',
            'Make department decisions with consequences',
            'Survive crises and present to the board',
          ],
          instructions: <String>[
            'Open the Simulation Center HQ.',
            'Review KPIs and the current challenge.',
            'Enter a department and decide.',
          ],
          professorIntro:
              'Welcome to headquarters. You are the CEO. Every lever moves '
              'cash, morale, reputation, and share — explain the trade-offs.',
          notesSeed:
              'Revenue ≠ profit. Runway matters. Reputation compounds quietly.',
          simulationKind: VuV2LabSimulationKind.businessCompany,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'Cutting all training may…',
              choices: <String>[
                'Hurt morale and quality over time',
                'Always increase profit forever',
                'Remove all risk',
                'Eliminate competition',
              ],
              correctIndex: 0,
              explain: 'Short-term savings can create long-term damage.',
            ),
          ],
        ),
      ],
    ),
    VuV2LabSchoolDef(
      school: VuV2LabSchool.psychology,
      title: 'Cognitive Science Lab',
      emoji: '🧠',
      blurb: 'Memory, attention, and bias desks — RA-grade cognition floor.',
      subjectIds: <String>['psychology'],
      experiments: <VuV2LabExperiment>[
        VuV2LabExperiment(
          id: 'psych_memory',
          title: 'Memory span',
          emoji: '🧩',
          blurb: 'Test short-term recall under load.',
          objectives: <String>[
            'Experience working-memory limits',
            'Use chunking strategies',
            'Reflect on encoding',
          ],
          instructions: <String>[
            'Memorize the sequence briefly shown.',
            'Enter what you recall.',
            'Reset for a new sequence.',
          ],
          professorIntro:
              'Cognitive Lab. Working memory is limited — chunking helps. '
              'Try the span task, then tell me your strategy.',
          notesSeed:
              'Miller’s ~7±2 is a classic heuristic. Chunking expands effective span.',
          simulationKind: VuV2LabSimulationKind.psychologyMemory,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'Chunking helps memory by…',
              choices: <String>[
                'Grouping items into meaningful units',
                'Deleting all information',
                'Avoiding attention',
                'Ignoring patterns',
              ],
              correctIndex: 0,
              explain: 'Meaningful groups reduce load on working memory.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'psych_attention',
          title: 'Attention vigilance',
          emoji: '👁️',
          blurb: 'Hit targets — avoid false alarms under sustained attention.',
          objectives: <String>[
            'Practice signal detection',
            'Balance hits vs false alarms',
            'Note fatigue effects',
          ],
          instructions: <String>[
            'Flash the display.',
            'Respond only when TARGET appears.',
            'Track hits and false alarms in notes.',
          ],
          professorIntro:
              'Attention Desk. Vigilance tasks punish impulsive clicks. '
              'Restraint is a skill — log when false alarms spike.',
          notesSeed:
              'Signal detection: hits, misses, false alarms, correct rejections. '
              'Criterion shifts with fatigue and expectation.',
          simulationKind: VuV2LabSimulationKind.psychologyAttention,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'Responding when no target is present is a…',
              choices: <String>[
                'False alarm',
                'Perfect hit',
                'Base rate',
                'Confound that always helps',
              ],
              correctIndex: 0,
              explain: 'False alarms are responses to non-signals.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'psych_bias',
          title: 'Bias desk',
          emoji: '⚖️',
          blurb: 'Catch base-rate neglect before it warps a conclusion.',
          objectives: <String>[
            'Spot base-rate neglect',
            'Prefer Bayesian-minded updates',
            'Write a careful judgment',
          ],
          instructions: <String>[
            'Read the rare-disease case.',
            'Choose the most careful analytic move.',
            'Defend your choice in the notebook.',
          ],
          professorIntro:
              'Bias Bay. Vivid stories seduce. Base rates stabilize. '
              'Pick the analyst habit you would defend in lab meeting.',
          notesSeed:
              'Base rate + likelihood → posterior intuition. Anecdotes are not '
              'substitutes for prevalence.',
          simulationKind: VuV2LabSimulationKind.psychologyBias,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'Base-rate neglect means…',
              choices: <String>[
                'Ignoring how common an event is beforehand',
                'Always using Bayes correctly',
                'Never collecting data',
                'Only studying memory',
              ],
              correctIndex: 0,
              explain: 'People overweight case details and underweight prevalence.',
            ),
          ],
        ),
      ],
    ),
    VuV2LabSchoolDef(
      school: VuV2LabSchool.mathematics,
      title: 'Mathematics Modeling Studio',
      emoji: '📐',
      blurb: 'Linear, quadratic, and probability benches — math as a lab.',
      subjectIds: <String>['mathematics'],
      experiments: <VuV2LabExperiment>[
        VuV2LabExperiment(
          id: 'math_graph',
          title: 'Function explorer',
          emoji: '📉',
          blurb: 'Slide parameters and watch the curve.',
          objectives: <String>[
            'See slope and intercept effects',
            'Predict before sliding',
            'Connect algebra to geometry',
          ],
          instructions: <String>[
            'Adjust slope (m) and intercept (b).',
            'Watch y = mx + b redraw.',
            'Reset returns to y = x.',
          ],
          professorIntro:
              'Math Studio. Graphs make algebra visible. Change m and b — '
              'predict the shift before you slide.',
          notesSeed:
              'm controls steepness/direction. b shifts the line vertically.',
          simulationKind: VuV2LabSimulationKind.mathGraph,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'Increasing b in y = mx + b…',
              choices: <String>[
                'Shifts the line up',
                'Always rotates it steeper',
                'Deletes the line',
                'Changes only x units',
              ],
              correctIndex: 0,
              explain: 'b is the vertical intercept shift.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'math_quadratic',
          title: 'Parabola lab',
          emoji: '📈',
          blurb: 'Tune a, b, c and watch roots via the discriminant.',
          objectives: <String>[
            'Link a to opening direction',
            'Use Δ to predict real roots',
            'Explain a parameter change in words',
          ],
          instructions: <String>[
            'Slide a, b, and c.',
            'Watch the parabola and discriminant readout.',
            'Log when Δ crosses zero.',
          ],
          professorIntro:
              'Quadratic Bay. The discriminant is a decision tool — not a memorization tax. '
              'Change coefficients and narrate what the graph does.',
          notesSeed:
              'Δ = b² − 4ac. Δ>0 two real roots; Δ=0 one; Δ<0 none (over reals). '
              'Sign of a controls up vs down.',
          simulationKind: VuV2LabSimulationKind.mathQuadratic,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'If Δ < 0 for a quadratic over the reals…',
              choices: <String>[
                'There are no real roots',
                'There are always two real roots',
                'The parabola disappears',
                'a must be zero',
              ],
              correctIndex: 0,
              explain: 'Negative discriminant means no real solutions.',
            ),
          ],
        ),
        VuV2LabExperiment(
          id: 'math_probability',
          title: 'Probability coin desk',
          emoji: '🪙',
          blurb: 'Flip toward 0.5 and feel the law of large numbers.',
          objectives: <String>[
            'Contrast small-sample noise vs long-run rate',
            'Run bulk trials',
            'Write what “expected value” means here',
          ],
          instructions: <String>[
            'Flip once and watch empirical p jump.',
            'Flip ×50 and watch it stabilize.',
            'Reset and compare a new run.',
          ],
          professorIntro:
              'Probability Desk. Short runs lie; long runs confess. '
              'Use both — then write the moral in your notebook.',
          notesSeed:
              'For a fair coin, E[p] → 0.5 as n grows. Variance of the mean shrinks with n.',
          simulationKind: VuV2LabSimulationKind.mathProbability,
          quiz: <VuV2LabQuizItem>[
            VuV2LabQuizItem(
              prompt: 'As trial count grows for a fair coin, empirical p usually…',
              choices: <String>[
                'Drifts closer to 0.5',
                'Must hit exactly 1',
                'Becomes undefined',
                'Deletes randomness forever',
              ],
              correctIndex: 0,
              explain: 'Law of large numbers: averages settle near expectation.',
            ),
          ],
        ),
      ],
    ),
  ];

  static VuV2LabSchoolDef? forSubjectId(String subjectId) {
    final String s = subjectId.toLowerCase();
    for (final VuV2LabSchoolDef school in _legacySchools) {
      for (final String id in school.subjectIds) {
        if (s == id || s.contains(id) || id.contains(s)) return school;
      }
      final String name = school.school.name.toLowerCase();
      if (s.contains(name) || name.contains(s)) return school;
    }
    if (s.contains('computer') || s.contains('cs') || s.contains('software')) {
      return computerScience;
    }
    return computerScience;
  }

  /// Pick the best experiment for a lesson topic (keyword match + faculty school).
  static VuV2LabExperiment? resolveForTopic(String subjectId, String topicTitle) {
    final VuV2LabSchoolDef? school = forSubjectId(subjectId);
    if (school == null || school.experiments.isEmpty) return null;

    final String hay = topicTitle.toLowerCase();
    final List<String> tokens = hay
        .split(RegExp(r'[^a-z0-9]+'))
        .where((String t) => t.length > 3)
        .toList();

    VuV2LabExperiment? best;
    int bestScore = -1;
    for (final VuV2LabExperiment exp in school.experiments) {
      final String blob =
          '${exp.title} ${exp.blurb} ${exp.id} ${exp.simulationKind.name}'
              .toLowerCase();
      int score = 0;
      for (final String t in tokens) {
        if (blob.contains(t)) score += 2;
      }
      // Soft biases by common clinical / CS / business keywords.
      if (hay.contains('patient') || hay.contains('vital') || hay.contains('nurs')) {
        if (blob.contains('patient') || blob.contains('scenario') || blob.contains('nurs')) {
          score += 3;
        }
      }
      if (hay.contains('debug') || hay.contains('bug') || hay.contains('code')) {
        if (blob.contains('debug') || blob.contains('editor') || blob.contains('arena')) {
          score += 3;
        }
      }
      if (hay.contains('market') || hay.contains('finance') || hay.contains('company')) {
        if (blob.contains('market') || blob.contains('financ') || blob.contains('company')) {
          score += 3;
        }
      }
      if (hay.contains('court') || hay.contains('law') || hay.contains('case')) {
        if (blob.contains('scenario') || blob.contains('patient') || blob.contains('bias')) {
          score += 2;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = exp;
      }
    }
    return best ?? school.experiments.first;
  }

  static VuV2LabSchoolDef schoolForTopic(String subjectId) {
    return forSubjectId(subjectId) ??
        schools.firstWhere((s) => s.school == VuV2LabSchool.computerScience);
  }
}
