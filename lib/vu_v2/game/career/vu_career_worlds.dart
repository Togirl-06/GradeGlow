import '../models/vu_game_models.dart';
import '../services/vu_game_ai_dialogue.dart';
import 'career_floor_factory.dart';
import 'objective_mission.dart';
import 'vu_career_world_pack.dart';

/// Engine-only Career Worlds. Old Labs / playable workplaces are not used here.
abstract final class VuCareerWorlds {
  static List<VuCareerWorldPack> get all => <VuCareerWorldPack>[
        nursing,
        law,
        computerScience,
        biology,
        chemistry,
        physics,
        engineering,
        medicine,
        business,
        finance,
        accounting,
        marketing,
        economics,
        english,
        math,
      ];

  static VuCareerWorldPack? byId(String id) {
    for (final VuCareerWorldPack w in all) {
      if (w.id == id || w.majorId == id) return w;
    }
    return null;
  }

  static VuCareerWorldPack? forMajor(String majorId) {
    final String m = majorId.toLowerCase();
    if (m.contains('nurs')) return nursing;
    if (m.contains('law')) return law;
    if (m.contains('computer') ||
        m.contains('software') ||
        m == 'cs' ||
        m.startsWith('cs_')) {
      return computerScience;
    }
    if (m.contains('bio')) return biology;
    if (m.contains('chem')) return chemistry;
    if (m.contains('phys')) return physics;
    if (m.contains('engin')) return engineering;
    if (m.contains('medicine') || m == 'med') return medicine;
    if (m.contains('bus')) return business;
    if (m.contains('fin')) return finance;
    if (m.contains('account')) return accounting;
    if (m.contains('market')) return marketing;
    if (m.contains('econ')) return economics;
    if (m.contains('english') || m.contains('writing')) return english;
    if (m.contains('math')) return math;
    return null;
  }

  /// Flagship — routed to NursingClinicalGameScreen (full hospital MVP).
  static final VuCareerWorldPack nursing = VuCareerWorldPack(
    id: 'nursing',
    majorId: 'nursing',
    title: 'Nursing — Virtual Clinical',
    subtitle: 'Walk the hospital. Assess your patient. Decide what happens next.',
    role: 'Student Nurse',
    emoji: '🏥',
    accent: 0xFF10B981,
    welcomeTitle: 'GradeGlow Nursing Clinical',
    welcomeBody:
        'Tap the floor to walk. Interact near people and equipment. '
        'Talk to your charge nurse to begin.',
    completeLabel: 'CLINICAL COMPLETE',
    achievement: 'First Clinical',
    skillKeys: const <String, String>{
      'Patient Assessment': 'patient_care',
      'Decision Making': 'professionalism',
      'Communication': 'communication',
      'Safety': 'clinical_knowledge',
      'Critical Thinking': 'critical_thinking',
    },
    layout: CareerFloorFactory.workplace(
      id: 'nursing_stub',
      title: 'Hospital',
      lobbyName: 'Entrance',
      workName: 'Hallway',
      focusName: 'Patient Room',
      lobbyColor: 0xFF1E3A4A,
      workColor: 0xFF2A3544,
      focusColor: 0xFF2D3B52,
      npcs: const <VuGameNpc>[],
      interactables: const <VuGameInteractable>[],
    ),
    dialogue: VuGameScriptedDialogue(const <String, VuGameDialogueNodeData>{}),
    mission: ObjectiveMission(
      missionId: 'nursing_redirect',
      title: 'Patient Assessment',
      objectives: const <({String id, String label})>[],
    ),
    objectHandlers: const <String, VuObjectHandler>{},
    supervisorNpcId: 'diaz',
    featured: true,
  );

  static final VuCareerWorldPack law = _pack(
    id: 'law',
    majorId: 'law',
    title: 'Law — Virtual Courtroom',
    subtitle: 'Investigate the case. Interview witnesses. Argue with evidence.',
    role: 'Law Student',
    emoji: '⚖️',
    accent: 0xFFC4A35A,
    welcomeTitle: 'State v. Anderson',
    welcomeBody:
        'Your client is waiting. Review the case file, interview the witness, '
        'then present your argument to the judge.',
    completeLabel: 'CASE COMPLETE',
    achievement: 'First Brief',
    skills: const <String>[
      'Legal Reasoning',
      'Evidence Analysis',
      'Argumentation',
      'Communication',
      'Professionalism',
    ],
    skillKeys: const <String, String>{
      'Legal Reasoning': 'critical_thinking',
      'Evidence Analysis': 'clinical_knowledge',
      'Argumentation': 'professionalism',
      'Communication': 'communication',
      'Professionalism': 'patient_care',
    },
    lobby: 'Law Firm Lobby',
    work: 'Evidence Room',
    focus: 'Courtroom',
    supervisor: (
      id: 'mentor',
      name: 'Partner Hale',
      role: 'Supervising Attorney',
      glyph: '👩‍💼',
    ),
    target: (
      id: 'witness',
      name: 'Jordan Reese',
      role: 'Witness',
      glyph: '🧑',
    ),
    third: (
      id: 'judge',
      name: 'Judge Okonkwo',
      role: 'Judge',
      glyph: '⚖️',
    ),
    objectives: const <({String id, String label})>[
      (id: 'brief', label: 'Receive case brief'),
      (id: 'file', label: 'Review case file'),
      (id: 'evidence', label: 'Inspect evidence'),
      (id: 'interview', label: 'Interview witness'),
      (id: 'inconsistency', label: 'Find an inconsistency'),
      (id: 'argue', label: 'Present argument'),
      (id: 'ruling', label: 'Hear the ruling'),
    ],
    startAction: 'mission_start',
    objectActions: <String, VuObjectHandler>{
      'case_file': const VuObjectHandler(
        toast: 'Police report + timeline loaded into your case file.',
        markObjectives: <String>['file'],
      ),
      'evidence_table': const VuObjectHandler(
        toast: 'Evidence: security footage timestamp does not match the report.',
        markObjectives: <String>['evidence', 'inconsistency'],
      ),
      'witness_seat': const VuObjectHandler(
        toast: 'Witness ready for questions.',
        openDialogueId: 'target_root',
      ),
      'podium': const VuObjectHandler(
        toast: 'You present the timeline conflict to the court.',
        markObjectives: <String>['argue'],
        requireMarks: <String>['inconsistency', 'interview'],
        lockedToast: 'Interview the witness and find the inconsistency first.',
        mistakeIfLocked: true,
      ),
      'bench': const VuObjectHandler(
        toast: 'Objection sustained. Counsel, continue with the timeline.',
        markObjectives: <String>['ruling'],
        requireMarks: <String>['argue'],
        lockedToast: 'Present your argument before the bench rules.',
        mistakeIfLocked: true,
      ),
    },
    supervisorLines: (
      greet:
          'Anderson is charged with burglary. Your job: find what the report missed.',
      brief: 'Start with the case file, then the witness. Don\'t wing the courtroom.',
    ),
    targetLines: (
      greet: 'I was home all night. The report says I was downtown — that\'s wrong.',
      mark: 'interview',
    ),
  );

  static final VuCareerWorldPack computerScience = _pack(
    id: 'computer_science',
    majorId: 'computer_science',
    title: 'CS — Tech Mission Floor',
    subtitle: 'The login system is failing. Inspect logs, debug, deploy the fix.',
    role: 'Junior Developer',
    emoji: '💻',
    accent: 0xFF38BDF8,
    welcomeTitle: 'Production Incident',
    welcomeBody:
        'Campus login is failing for some users. Walk the eng floor, talk to '
        'the on-call engineer, inspect logs, and ship a fix.',
    completeLabel: 'INCIDENT RESOLVED',
    achievement: 'First Deploy',
    skills: const <String>[
      'Problem Solving',
      'Coding',
      'Debugging',
      'System Design',
      'Communication',
    ],
    skillKeys: const <String, String>{
      'Problem Solving': 'critical_thinking',
      'Coding': 'clinical_knowledge',
      'Debugging': 'patient_care',
      'System Design': 'professionalism',
      'Communication': 'communication',
    },
    lobby: 'Startup Lobby',
    work: 'Engineering Floor',
    focus: 'Server Room',
    supervisor: (
      id: 'mentor',
      name: 'Maya Chen',
      role: 'Tech Lead',
      glyph: '👩‍💻',
    ),
    target: (
      id: 'oncall',
      name: 'Dev On-Call',
      role: 'Engineer',
      glyph: '🧑‍💻',
    ),
    third: (
      id: 'pm',
      name: 'Alex Rivera',
      role: 'Product Manager',
      glyph: '🧑‍💼',
    ),
    objectives: const <({String id, String label})>[
      (id: 'brief', label: 'Take the incident brief'),
      (id: 'talk_dev', label: 'Talk to on-call engineer'),
      (id: 'logs', label: 'Inspect auth logs'),
      (id: 'code', label: 'Open failing code path'),
      (id: 'bug', label: 'Identify the bug'),
      (id: 'test', label: 'Run a fix test'),
      (id: 'deploy', label: 'Deploy the fix'),
    ],
    startAction: 'mission_start',
    objectActions: <String, VuObjectHandler>{
      'ticket_board': const VuObjectHandler(
        toast: 'INC-4421: Auth 500s after token refresh for ~12% of users.',
        markObjectives: <String>['brief'],
        requiresMission: false,
      ),
      'log_terminal': const VuObjectHandler(
        toast: 'Logs: NullPointer in TokenStore.refresh() when session is stale.',
        markObjectives: <String>['logs', 'bug'],
      ),
      'dev_workstation': const VuObjectHandler(
        toast: 'Code panel open — null-check missing before refresh.',
        markObjectives: <String>['code'],
        openDialogueId: 'target_root',
      ),
      'test_rig': const VuObjectHandler(
        toast: 'Tests pass with null-safe refresh path.',
        markObjectives: <String>['test'],
        requireMarks: <String>['bug', 'code'],
        lockedToast: 'Find the bug and open the code first.',
        mistakeIfLocked: true,
      ),
      'deploy_console': const VuObjectHandler(
        toast: 'Fix deployed to staging → production. Error rate dropping.',
        markObjectives: <String>['deploy'],
        requireMarks: <String>['test'],
        lockedToast: 'Test before you deploy.',
        mistakeIfLocked: true,
      ),
    },
    supervisorLines: (
      greet:
          'Production is on fire — calmly. Grab the ticket, then pair with on-call.',
      brief: 'Reproduce from logs. Don\'t guess. Ship a guarded fix.',
    ),
    targetLines: (
      greet: 'I saw 500s after midnight deploy. Token refresh looks suspicious.',
      mark: 'talk_dev',
    ),
  );

  static final VuCareerWorldPack biology = _science(
    id: 'biology',
    majorId: 'biology',
    title: 'Biology — Research Lab',
    subtitle: 'Identify the unknown cell sample under the microscope.',
    role: 'Research Student',
    emoji: '🧬',
    accent: 0xFF34D399,
    focus: 'Microscopy Bay',
    work: 'Bench Area',
    lobby: 'Specimen Intake',
    achievement: 'First Specimen',
    completeLabel: 'LAB COMPLETE',
    skills: const <String>[
      'Observation',
      'Research',
      'Analysis',
      'Scientific Reasoning',
      'Communication',
    ],
    sampleToast: 'Unknown sample B-17 logged in your notebook.',
    toolToast: 'Microscope focused — nucleus and organelles visible.',
    concludeToast: 'Conclusion: eukaryotic animal cell, likely epithelial.',
  );

  static final VuCareerWorldPack chemistry = _science(
    id: 'chemistry',
    majorId: 'chemistry',
    title: 'Chemistry — Lab Bench',
    subtitle: 'Measure, mix safely, and identify the unknown substance.',
    role: 'Chemistry Student',
    emoji: '⚗️',
    accent: 0xFFA78BFA,
    focus: 'Reaction Station',
    work: 'Measurement Bench',
    lobby: 'Safety Station',
    achievement: 'Safe Experiment',
    completeLabel: 'EXPERIMENT COMPLETE',
    skills: const <String>[
      'Laboratory Skills',
      'Safety',
      'Analysis',
      'Scientific Reasoning',
      'Communication',
    ],
    sampleToast: 'Unknown powder measured — 2.0 g recorded.',
    toolToast: 'Reaction observed: blue → clear with mild heat (safe hood on).',
    concludeToast: 'Identity consistent with copper sulfate hydrate.',
  );

  static final VuCareerWorldPack physics = _science(
    id: 'physics',
    majorId: 'physics',
    title: 'Physics — Experiment World',
    subtitle: 'Change mass and velocity. Predict momentum. Measure the result.',
    role: 'Physics Student',
    emoji: '⚛️',
    accent: 0xFF60A5FA,
    focus: 'Mechanics Track',
    work: 'Instrumentation',
    lobby: 'Lab Entrance',
    achievement: 'First Prediction',
    completeLabel: 'EXPERIMENT COMPLETE',
    skills: const <String>[
      'Problem Solving',
      'Experimental Design',
      'Analysis',
      'Mathematical Reasoning',
      'Communication',
    ],
    sampleToast: 'Variables set: mass 2 kg, velocity 3 m/s.',
    toolToast: 'Measured momentum ≈ 6 kg·m/s — matches your prediction.',
    concludeToast: 'Report filed: p = mv confirmed within error bars.',
  );

  static final VuCareerWorldPack engineering = _pack(
    id: 'engineering',
    majorId: 'engineering',
    title: 'Engineering — Design Studio',
    subtitle: 'The bridge failed the stress test. Find why and redesign it.',
    role: 'Junior Engineer',
    emoji: '⚙️',
    accent: 0xFFF59E0B,
    welcomeTitle: 'Bridge Stress Failure',
    welcomeBody:
        'Inspect the failed span, collect measurements, redesign, and retest.',
    completeLabel: 'DESIGN VERIFIED',
    achievement: 'First Redesign',
    skills: const <String>[
      'Design',
      'Problem Solving',
      'Testing',
      'Technical Reasoning',
      'Communication',
    ],
    skillKeys: const <String, String>{
      'Design': 'professionalism',
      'Problem Solving': 'critical_thinking',
      'Testing': 'clinical_knowledge',
      'Technical Reasoning': 'patient_care',
      'Communication': 'communication',
    },
    lobby: 'Studio Lobby',
    work: 'CAD Floor',
    focus: 'Test Bay',
    supervisor: (
      id: 'mentor',
      name: 'Eng. Ortiz',
      role: 'Project Lead',
      glyph: '👷',
    ),
    target: (
      id: 'tech',
      name: 'Riley',
      role: 'Technician',
      glyph: '🧑‍🔧',
    ),
    third: (
      id: 'client',
      name: 'City Client',
      role: 'Client',
      glyph: '🧑‍💼',
    ),
    objectives: const <({String id, String label})>[
      (id: 'brief', label: 'Receive failure brief'),
      (id: 'inspect', label: 'Inspect failed structure'),
      (id: 'measure', label: 'Collect measurements'),
      (id: 'talk', label: 'Talk to technician'),
      (id: 'redesign', label: 'Apply redesign'),
      (id: 'retest', label: 'Retest under load'),
      (id: 'signoff', label: 'Get lead sign-off'),
    ],
    startAction: 'mission_start',
    objectActions: <String, VuObjectHandler>{
      'blueprint': const VuObjectHandler(
        toast: 'Failure at midspan joint — underspec bolts.',
        markObjectives: <String>['brief', 'inspect'],
      ),
      'calipers': const VuObjectHandler(
        toast: 'Joint gap 3.2 mm over tolerance.',
        markObjectives: <String>['measure'],
      ),
      'cad_station': const VuObjectHandler(
        toast: 'Redesign: upgrade fasteners + add gusset plate.',
        markObjectives: <String>['redesign'],
        requireMarks: <String>['measure', 'talk'],
        lockedToast: 'Measure and talk to the tech first.',
        mistakeIfLocked: true,
      ),
      'load_frame': const VuObjectHandler(
        toast: 'Retest passed at 1.25× design load.',
        markObjectives: <String>['retest', 'signoff'],
        requireMarks: <String>['redesign'],
        lockedToast: 'Redesign before retesting.',
        mistakeIfLocked: true,
      ),
    },
    supervisorLines: (
      greet: 'The span failed overnight. Failures teach — find the root cause.',
      brief: 'Inspect → measure → redesign → retest. No shortcuts.',
    ),
    targetLines: (
      greet: 'Bolts looked wrong at install. I flagged it — check the gap.',
      mark: 'talk',
    ),
  );

  static final VuCareerWorldPack medicine = _pack(
    id: 'medicine',
    majorId: 'medicine',
    title: 'Medicine — Diagnostic Ward',
    subtitle: 'History, exam, tests, differential — then choose the next step.',
    role: 'Medical Student',
    emoji: '🩺',
    accent: 0xFFFB7185,
    welcomeTitle: 'Diagnostic Case',
    welcomeBody:
        'Severe headaches for three days. Take history, examine, select tests, '
        'and form a differential. Educational simulation only.',
    completeLabel: 'CASE COMPLETE',
    achievement: 'First Differential',
    skills: const <String>[
      'Clinical Reasoning',
      'History Taking',
      'Diagnosis',
      'Test Selection',
      'Patient Communication',
    ],
    skillKeys: const <String, String>{
      'Clinical Reasoning': 'critical_thinking',
      'History Taking': 'communication',
      'Diagnosis': 'clinical_knowledge',
      'Test Selection': 'patient_care',
      'Patient Communication': 'professionalism',
    },
    lobby: 'ED Triage',
    work: 'Exam Room',
    focus: 'Imaging / Lab',
    supervisor: (
      id: 'mentor',
      name: 'Dr. Singh',
      role: 'Attending',
      glyph: '👨‍⚕️',
    ),
    target: (
      id: 'patient',
      name: 'Sam Okeke',
      role: 'Patient',
      glyph: '🧑',
    ),
    third: (
      id: 'nurse',
      name: 'Nurse Pat',
      role: 'Nurse',
      glyph: '👩‍⚕️',
    ),
    objectives: const <({String id, String label})>[
      (id: 'brief', label: 'Receive case from attending'),
      (id: 'history', label: 'Take history'),
      (id: 'exam', label: 'Perform exam'),
      (id: 'vitals', label: 'Review vitals'),
      (id: 'tests', label: 'Select tests'),
      (id: 'differential', label: 'Form differential'),
      (id: 'plan', label: 'Recommend next step'),
    ],
    startAction: 'mission_start',
    objectActions: <String, VuObjectHandler>{
      'chart': const VuObjectHandler(
        toast: 'Vitals: BP 158/96 · HR 98 · neuro exam pending.',
        markObjectives: <String>['vitals'],
        vitalsLine: 'BP 158/96 · HR 98 · afebrile',
      ),
      'exam_table': const VuObjectHandler(
        toast: 'Exam: photophobia, neck stiffness mild — concerning.',
        markObjectives: <String>['exam'],
        openDialogueId: 'target_root',
      ),
      'order_panel': const VuObjectHandler(
        toast: 'Orders: CT head + labs selected (educational sim).',
        markObjectives: <String>['tests'],
        requireMarks: <String>['history', 'exam'],
        lockedToast: 'History and exam before tests.',
        mistakeIfLocked: true,
      ),
      'diff_board': const VuObjectHandler(
        toast: 'Differential: migraine vs secondary headache — urgent imaging.',
        markObjectives: <String>['differential', 'plan'],
        requireMarks: <String>['tests'],
        lockedToast: 'Select tests before locking the plan.',
        mistakeIfLocked: true,
      ),
    },
    supervisorLines: (
      greet:
          'Sam has had severe headaches for three days. You own the workup — I own safety.',
      brief: 'History first. Never shotgun tests without a hypothesis.',
    ),
    targetLines: (
      greet: 'It\'s the worst headache of my life. Light hurts. Neck feels stiff.',
      mark: 'history',
    ),
  );

  static final VuCareerWorldPack business = _metricsPack(
    id: 'business',
    majorId: 'business',
    title: 'Business — Company HQ',
    subtitle: 'Sales dropped 15%. Investigate, decide, move the metrics.',
    role: 'Manager Trainee',
    emoji: '💼',
    accent: 0xFF22D3EE,
    lobby: 'HQ Lobby',
    work: 'Ops Floor',
    focus: 'Strategy Room',
    achievement: 'First Turnaround',
    completeLabel: 'STRATEGY SET',
    skills: const <String>[
      'Strategy',
      'Leadership',
      'Finance',
      'Decision Making',
      'Communication',
    ],
    greet: 'Revenue slipped. Talk to sales, check the books, then choose a lever.',
    actions: const <String, String>{
      'reports': 'Finance: churn up, CAC flat — retention problem.',
      'customers': 'Top customers cite slow support, not price.',
      'pricing': 'Price cut rejected — would hurt margin without fixing churn.',
      'campaign': 'Retention campaign launched — simulated NPS +6.',
      'hire': 'Support hire approved — queue time projected −30%.',
    },
  );

  static final VuCareerWorldPack finance = _metricsPack(
    id: 'finance',
    majorId: 'finance',
    title: 'Finance — Markets Desk',
    subtitle: 'Simulated markets only. Analyze risk and act on the shock.',
    role: 'Junior Analyst',
    emoji: '💰',
    accent: 0xFF4ADE80,
    lobby: 'Trading Lobby',
    work: 'Markets Desk',
    focus: 'Research Room',
    achievement: 'First Trade Thesis',
    completeLabel: 'THESIS LOCKED',
    skills: const <String>[
      'Analysis',
      'Risk Management',
      'Decision Making',
      'Financial Reasoning',
      'Communication',
    ],
    greet:
        'Educational sim money only. Earnings shock hit Northwind Co. — respond.',
    actions: const <String, String>{
      'statements': 'Northwind: revenue miss, cash still solid.',
      'risk': 'Portfolio beta high in consumer discretionary.',
      'event': 'Simulated market: −4% after earnings.',
      'allocate': 'Trimmed 2% position — risk within band.',
      'client_note': 'Client note sent: thesis updated, no panic sell.',
    },
  );

  static final VuCareerWorldPack accounting = _metricsPack(
    id: 'accounting',
    majorId: 'accounting',
    title: 'Accounting — Firm Floor',
    subtitle: 'Three errors hide in the statements. Find them.',
    role: 'Junior Accountant',
    emoji: '📊',
    accent: 0xFF818CF8,
    lobby: 'Firm Lobby',
    work: 'Audit Floor',
    focus: 'War Room',
    achievement: 'Error Hunter',
    completeLabel: 'AUDIT CLEARED',
    skills: const <String>[
      'Accuracy',
      'Analysis',
      'Financial Reporting',
      'Auditing',
      'Communication',
    ],
    greet: 'Statements look clean. They aren\'t. Find the three errors.',
    actions: const <String, String>{
      'ledger': 'Error 1: revenue booked one period early.',
      'trial': 'Error 2: prepaid rent misclassified as expense.',
      'bank': 'Error 3: uncleared check double-counted.',
      'workpaper': 'Workpapers updated with all three findings.',
      'manager': 'Manager signed off — client memo drafted.',
    },
  );

  static final VuCareerWorldPack marketing = _metricsPack(
    id: 'marketing',
    majorId: 'marketing',
    title: 'Marketing — Agency Floor',
    subtitle: 'Sneaker brand wants campus reach. Build and tune the campaign.',
    role: 'Junior Strategist',
    emoji: '📣',
    accent: 0xFFF472B6,
    lobby: 'Agency Lobby',
    work: 'Creative Studio',
    focus: 'Analytics Room',
    achievement: 'First Campaign',
    completeLabel: 'CAMPAIGN LIVE',
    skills: const <String>[
      'Creativity',
      'Strategy',
      'Communication',
      'Analytics',
      'Decision Making',
    ],
    greet: 'Client: campus sneaker drop. Research → creative → measure.',
    actions: const <String, String>{
      'audience': 'Audience: college students 18–24, sports lifestyle.',
      'brief': 'Brief locked: campus ambassadors + short-form video.',
      'copy': 'Copy drafted: "Made for the walk between classes."',
      'budget': 'Budget split 60% social / 40% campus events.',
      'results': 'Sim results: reach 120k · engagement 4.8% · ROI 1.7×.',
    },
  );

  static final VuCareerWorldPack economics = _metricsPack(
    id: 'economics',
    majorId: 'economics',
    title: 'Economics — Policy Unit',
    subtitle: 'Inflation up, unemployment rising. Recommend a policy tradeoff.',
    role: 'Policy Analyst',
    emoji: '📈',
    accent: 0xFF2DD4BF,
    lobby: 'Research Center',
    work: 'Data Room',
    focus: 'Policy Office',
    achievement: 'First Memo',
    completeLabel: 'MEMO FILED',
    skills: const <String>[
      'Analysis',
      'Policy Reasoning',
      'Data Interpretation',
      'Decision Making',
      'Communication',
    ],
    greet: 'Stagflation pressure. Model the tradeoffs — no free lunch.',
    actions: const <String, String>{
      'dashboard': 'Inflation 6.2% · Unemployment 5.8% · GDP soft.',
      'rates': 'Rate hike cools prices but risks jobs.',
      'spending': 'Targeted transfers help households, may add demand.',
      'memo': 'Memo: modest hike + targeted support — documented tradeoffs.',
      'briefing': 'Advisor briefing delivered. Simulated economy updates.',
    },
  );

  static final VuCareerWorldPack english = _pack(
    id: 'english',
    majorId: 'english',
    title: 'English — Writing Studio',
    subtitle: 'Interview, draft, edit with an AI editor — not a multiple-choice quiz.',
    role: 'Writing Student',
    emoji: '✍️',
    accent: 0xFFFBBF24,
    welcomeTitle: 'Campus Feature Story',
    welcomeBody:
        'Interview your subject, draft the piece, take editor notes, then polish.',
    completeLabel: 'STORY FILED',
    achievement: 'First Byline',
    skills: const <String>[
      'Writing',
      'Communication',
      'Critical Thinking',
      'Editing',
      'Professionalism',
    ],
    skillKeys: const <String, String>{
      'Writing': 'clinical_knowledge',
      'Communication': 'communication',
      'Critical Thinking': 'critical_thinking',
      'Editing': 'patient_care',
      'Professionalism': 'professionalism',
    },
    lobby: 'Studio Entrance',
    work: 'Newsroom',
    focus: 'Edit Bay',
    supervisor: (
      id: 'mentor',
      name: 'Editor Quinn',
      role: 'Editor',
      glyph: '👩‍🏫',
    ),
    target: (
      id: 'subject',
      name: 'Casey Ng',
      role: 'Interview Subject',
      glyph: '🧑',
    ),
    third: (
      id: 'client',
      name: 'Campus Mag',
      role: 'Client',
      glyph: '📰',
    ),
    objectives: const <({String id, String label})>[
      (id: 'brief', label: 'Take the assignment'),
      (id: 'interview', label: 'Interview subject'),
      (id: 'draft', label: 'Write the draft'),
      (id: 'notes', label: 'Receive editor notes'),
      (id: 'revise', label: 'Revise the piece'),
      (id: 'present', label: 'Present to client'),
      (id: 'file', label: 'File final story'),
    ],
    startAction: 'mission_start',
    objectActions: <String, VuObjectHandler>{
      'assignment': const VuObjectHandler(
        toast: 'Assignment: 600-word feature on campus makerspace.',
        markObjectives: <String>['brief'],
        requiresMission: false,
      ),
      'interview_chair': const VuObjectHandler(
        toast: 'Great quotes captured — makerspace access story.',
        markObjectives: <String>['interview'],
        openDialogueId: 'target_root',
      ),
      'draft_desk': const VuObjectHandler(
        toast: 'Draft written. Strong lede, soft ending.',
        markObjectives: <String>['draft'],
        requireMarks: <String>['interview'],
        lockedToast: 'Interview before you draft.',
        mistakeIfLocked: true,
      ),
      'edit_panel': const VuObjectHandler(
        toast: 'Editor: tighten graf 3, sharpen the ending.',
        markObjectives: <String>['notes', 'revise'],
        requireMarks: <String>['draft'],
        lockedToast: 'Draft first.',
        mistakeIfLocked: true,
      ),
      'submit': const VuObjectHandler(
        toast: 'Story filed. Client approves for next issue.',
        markObjectives: <String>['present', 'file'],
        requireMarks: <String>['revise'],
        lockedToast: 'Revise before filing.',
        mistakeIfLocked: true,
      ),
    },
    supervisorLines: (
      greet: 'You\'re on the makerspace feature. Interview first — polish later.',
      brief: 'Clarity beats clever. Show me a draft with a pulse.',
    ),
    targetLines: (
      greet: 'The makerspace changed my major. I can show you the project wall.',
      mark: 'interview',
    ),
  );

  static final VuCareerWorldPack math = _pack(
    id: 'math',
    majorId: 'mathematics',
    title: 'Math — Problem Lab',
    subtitle: 'Manipulate the model. Defend each step — process matters.',
    role: 'Math Analyst',
    emoji: '➗',
    accent: 0xFF94A3B8,
    welcomeTitle: 'Shipping Cost Model',
    welcomeBody:
        'Build the cost model on the interactive board. Mistakes get explained.',
    completeLabel: 'MODEL DEFENDED',
    achievement: 'First Proof Walk',
    skills: const <String>[
      'Problem Solving',
      'Mathematical Reasoning',
      'Accuracy',
      'Process',
      'Communication',
    ],
    skillKeys: const <String, String>{
      'Problem Solving': 'critical_thinking',
      'Mathematical Reasoning': 'clinical_knowledge',
      'Accuracy': 'patient_care',
      'Process': 'professionalism',
      'Communication': 'communication',
    },
    lobby: 'Classroom',
    work: 'Problem Lab',
    focus: 'Interactive Board',
    supervisor: (
      id: 'mentor',
      name: 'Prof. Adeyemi',
      role: 'Professor',
      glyph: '👩‍🏫',
    ),
    target: (
      id: 'peer',
      name: 'Study Partner',
      role: 'Peer',
      glyph: '🧑‍🎓',
    ),
    third: (
      id: 'client',
      name: 'Ops Lead',
      role: 'Stakeholder',
      glyph: '🧑‍💼',
    ),
    objectives: const <({String id, String label})>[
      (id: 'brief', label: 'Receive the problem'),
      (id: 'graph', label: 'Plot the relationship'),
      (id: 'equation', label: 'Set up the equation'),
      (id: 'solve', label: 'Solve step-by-step'),
      (id: 'check', label: 'Check the result'),
      (id: 'explain', label: 'Explain a wrong step'),
      (id: 'defend', label: 'Defend the model'),
    ],
    startAction: 'mission_start',
    objectActions: <String, VuObjectHandler>{
      'prompt': const VuObjectHandler(
        toast: 'Minimize shipping cost C = 4x + 9/x for x > 0.',
        markObjectives: <String>['brief'],
        requiresMission: false,
      ),
      'graph_board': const VuObjectHandler(
        toast: 'Graph shows a clear minimum near x = 1.5.',
        markObjectives: <String>['graph'],
      ),
      'equation_pad': const VuObjectHandler(
        toast: 'Derivative set: C\' = 4 − 9/x² = 0 → x = 1.5.',
        markObjectives: <String>['equation', 'solve'],
      ),
      'check_tool': const VuObjectHandler(
        toast: 'Second derivative positive — minimum confirmed.',
        markObjectives: <String>['check', 'explain'],
        requireMarks: <String>['solve'],
        lockedToast: 'Solve before checking.',
        mistakeIfLocked: true,
      ),
      'defend_desk': const VuObjectHandler(
        toast: 'Model defended to Ops: ship 1.5 units per batch.',
        markObjectives: <String>['defend'],
        requireMarks: <String>['check'],
        lockedToast: 'Verify first.',
        mistakeIfLocked: true,
        openDialogueId: 'mentor_root',
      ),
    },
    supervisorLines: (
      greet: 'Show your process. A right answer with a wrong step still fails.',
      brief: 'Graph → equation → solve → check. Narrate each move.',
    ),
    targetLines: (
      greet: 'I tried x=3 first — cost was higher. The graph helps.',
      mark: 'graph',
    ),
  );

  // ---- builders -----------------------------------------------------------

  static VuCareerWorldPack _science({
    required String id,
    required String majorId,
    required String title,
    required String subtitle,
    required String role,
    required String emoji,
    required int accent,
    required String lobby,
    required String work,
    required String focus,
    required String achievement,
    required String completeLabel,
    required List<String> skills,
    required String sampleToast,
    required String toolToast,
    required String concludeToast,
  }) {
    return _pack(
      id: id,
      majorId: majorId,
      title: title,
      subtitle: subtitle,
      role: role,
      emoji: emoji,
      accent: accent,
      welcomeTitle: title,
      welcomeBody:
          'Walk the lab. Collect the sample, use the equipment, record, conclude.',
      completeLabel: completeLabel,
      achievement: achievement,
      skills: skills,
      skillKeys: <String, String>{
        for (final String s in skills)
          s: s.toLowerCase().contains('comm')
              ? 'communication'
              : s.toLowerCase().contains('safe')
                  ? 'patient_care'
                  : s.toLowerCase().contains('observ') ||
                          s.toLowerCase().contains('lab')
                      ? 'clinical_knowledge'
                      : s.toLowerCase().contains('reason') ||
                              s.toLowerCase().contains('problem')
                          ? 'critical_thinking'
                          : 'professionalism',
      },
      lobby: lobby,
      work: work,
      focus: focus,
      supervisor: (
        id: 'mentor',
        name: 'Prof. Lane',
        role: 'Professor',
        glyph: '👩‍🔬',
      ),
      target: (
        id: 'assistant',
        name: 'Lab Assistant',
        role: 'Assistant',
        glyph: '🧑‍🔬',
      ),
      third: (
        id: 'scientist',
        name: 'Dr. Mora',
        role: 'Scientist',
        glyph: '🧬',
      ),
      objectives: const <({String id, String label})>[
        (id: 'brief', label: 'Receive lab brief'),
        (id: 'sample', label: 'Collect / log sample'),
        (id: 'tool', label: 'Use primary equipment'),
        (id: 'observe', label: 'Record observation'),
        (id: 'talk', label: 'Consult assistant'),
        (id: 'analyze', label: 'Analyze result'),
        (id: 'conclude', label: 'Write conclusion'),
      ],
      startAction: 'mission_start',
      objectActions: <String, VuObjectHandler>{
        'sample': VuObjectHandler(
          toast: sampleToast,
          markObjectives: const <String>['sample'],
        ),
        'tool': VuObjectHandler(
          toast: toolToast,
          markObjectives: const <String>['tool', 'observe'],
          requireMarks: const <String>['sample'],
          lockedToast: 'Log the sample first.',
          mistakeIfLocked: true,
        ),
        'notebook': const VuObjectHandler(
          toast: 'Observation recorded in lab notebook.',
          markObjectives: <String>['analyze'],
          requireMarks: <String>['observe'],
          lockedToast: 'Observe with the tool first.',
          mistakeIfLocked: true,
        ),
        'conclude': VuObjectHandler(
          toast: concludeToast,
          markObjectives: const <String>['conclude'],
          requireMarks: const <String>['analyze', 'talk'],
          lockedToast: 'Analyze and consult before concluding.',
          mistakeIfLocked: true,
        ),
      },
      supervisorLines: (
        greet: 'Suit up. Safety first. Your unknown is waiting.',
        brief: 'Collect → measure → observe → conclude. No skipping.',
      ),
      targetLines: (
        greet: 'Hood is clear. I can spot-check your procedure.',
        mark: 'talk',
      ),
    );
  }

  static VuCareerWorldPack _metricsPack({
    required String id,
    required String majorId,
    required String title,
    required String subtitle,
    required String role,
    required String emoji,
    required int accent,
    required String lobby,
    required String work,
    required String focus,
    required String achievement,
    required String completeLabel,
    required List<String> skills,
    required String greet,
    required Map<String, String> actions,
  }) {
    final List<String> keys = actions.keys.toList();
    return _pack(
      id: id,
      majorId: majorId,
      title: title,
      subtitle: subtitle,
      role: role,
      emoji: emoji,
      accent: accent,
      welcomeTitle: title,
      welcomeBody: greet,
      completeLabel: completeLabel,
      achievement: achievement,
      skills: skills,
      skillKeys: <String, String>{
        for (int i = 0; i < skills.length; i++)
          skills[i]: <String>[
            'critical_thinking',
            'communication',
            'clinical_knowledge',
            'patient_care',
            'professionalism',
          ][i % 5],
      },
      lobby: lobby,
      work: work,
      focus: focus,
      supervisor: (
        id: 'mentor',
        name: 'Director Cho',
        role: 'Director',
        glyph: '🧑‍💼',
      ),
      target: (
        id: 'colleague',
        name: 'Colleague',
        role: 'Teammate',
        glyph: '🧑',
      ),
      third: (
        id: 'stakeholder',
        name: 'Stakeholder',
        role: 'Stakeholder',
        glyph: '👔',
      ),
      objectives: <({String id, String label})>[
        (id: 'brief', label: 'Take the brief'),
        for (final String k in keys) (id: k, label: 'Complete: $k'),
        (id: 'talk', label: 'Talk to colleague'),
      ],
      startAction: 'mission_start',
      objectActions: <String, VuObjectHandler>{
        for (final MapEntry<String, String> e in actions.entries)
          e.key: VuObjectHandler(
            toast: e.value,
            markObjectives: <String>[e.key],
          ),
      },
      supervisorLines: (greet: greet, brief: 'Investigate, then decide. Metrics move.'),
      targetLines: (
        greet: 'I have context if you need a second opinion.',
        mark: 'talk',
      ),
    );
  }

  static VuCareerWorldPack _pack({
    required String id,
    required String majorId,
    required String title,
    required String subtitle,
    required String role,
    required String emoji,
    required int accent,
    required String welcomeTitle,
    required String welcomeBody,
    required String completeLabel,
    required String achievement,
    required List<String> skills,
    required Map<String, String> skillKeys,
    required String lobby,
    required String work,
    required String focus,
    required ({String id, String name, String role, String glyph}) supervisor,
    required ({String id, String name, String role, String glyph}) target,
    required ({String id, String name, String role, String glyph}) third,
    required List<({String id, String label})> objectives,
    required String startAction,
    required Map<String, VuObjectHandler> objectActions,
    required ({String greet, String brief}) supervisorLines,
    required ({String greet, String mark}) targetLines,
  }) {
    final List<MapEntry<String, VuObjectHandler>> entries =
        objectActions.entries.toList();
    final List<VuGameInteractable> items = <VuGameInteractable>[
      for (int i = 0; i < entries.length; i++)
        VuGameInteractable(
          id: entries[i].key,
          label: entries[i].key.replaceAll('_', ' '),
          position: VuGameVec2(
            180.0 + (i % 3) * 220,
            i < 3 ? 140.0 : 360.0,
          ),
          actionId: entries[i].key,
          glyph: i.isEven ? '📋' : '🖥️',
        ),
    ];

    return VuCareerWorldPack(
      id: id,
      majorId: majorId,
      title: title,
      subtitle: subtitle,
      role: role,
      emoji: emoji,
      accent: accent,
      welcomeTitle: welcomeTitle,
      welcomeBody: welcomeBody,
      completeLabel: completeLabel,
      achievement: achievement,
      skillKeys: skillKeys,
      layout: CareerFloorFactory.workplace(
        id: '${id}_floor',
        title: title,
        lobbyName: lobby,
        workName: work,
        focusName: focus,
        lobbyColor: 0xFF1E293B,
        workColor: accent & 0x00FFFFFF | 0x22000000,
        focusColor: 0xFF0F172A,
        npcs: <VuGameNpc>[
          VuGameNpc(
            id: supervisor.id,
            name: supervisor.name,
            role: supervisor.role,
            position: const VuGameVec2(200, 480),
            dialogueRootId: 'mentor_root',
            glyph: supervisor.glyph,
          ),
          VuGameNpc(
            id: target.id,
            name: target.name,
            role: target.role,
            position: const VuGameVec2(620, 160),
            dialogueRootId: 'target_root',
            glyph: target.glyph,
          ),
          VuGameNpc(
            id: third.id,
            name: third.name,
            role: third.role,
            position: const VuGameVec2(760, 400),
            dialogueRootId: 'third_root',
            glyph: third.glyph,
          ),
        ],
        interactables: items,
      ),
      dialogue: VuGameScriptedDialogue(<String, VuGameDialogueNodeData>{
        'mentor_root': VuGameDialogueNodeData(
          id: 'mentor_root',
          speaker: supervisor.name,
          text: supervisorLines.greet,
          choices: <VuGameDialogueChoiceData>[
            VuGameDialogueChoiceData(
              id: 'start',
              label: 'Start mission',
              actionId: startAction,
              nextNodeId: 'mentor_brief',
            ),
            const VuGameDialogueChoiceData(
              id: 'help',
              label: 'Any tips?',
              nextNodeId: 'mentor_brief',
            ),
          ],
        ),
        'mentor_brief': VuGameDialogueNodeData(
          id: 'mentor_brief',
          speaker: supervisor.name,
          text: supervisorLines.brief,
        ),
        'target_root': VuGameDialogueNodeData(
          id: 'target_root',
          speaker: target.name,
          text: targetLines.greet,
          choices: <VuGameDialogueChoiceData>[
            VuGameDialogueChoiceData(
              id: 'ack',
              label: 'Thanks — noted',
              actionId: 'mark_${targetLines.mark}',
            ),
          ],
        ),
        'third_root': VuGameDialogueNodeData(
          id: 'third_root',
          speaker: third.name,
          text: 'I\'m watching your process. Make decisions you can defend.',
        ),
      }),
      mission: ObjectiveMission(
        missionId: '${id}_mission_1',
        title: title.split('—').last.trim().isEmpty ? title : title.split('—').last.trim(),
        objectives: objectives,
      ),
      objectHandlers: objectActions,
      supervisorNpcId: supervisor.id,
    );
  }
}
