import 'package:flutter/material.dart';

import 'practical_mission.dart';

/// Showcase practicals for every major VU course — case → diagnose → WHY score.
abstract final class UniversityPracticalCatalog {
  static const List<UniversityPracticalMission> all = <UniversityPracticalMission>[
    biology,
    chemistry,
    physics,
    computerScience,
    nursing,
    medicine,
    law,
    business,
    finance,
    accounting,
    marketing,
    economics,
    pharmacy,
    mls,
    psychology,
    mathematics,
    engineering,
    cybersecurity,
  ];

  static UniversityPracticalMission byId(String id) {
    for (final UniversityPracticalMission m in all) {
      if (m.id == id) return m;
    }
    return biology;
  }

  static UniversityPracticalMission? forCourse(String courseId) {
    final String c = courseId.toLowerCase();
    for (final UniversityPracticalMission m in all) {
      if (m.courseId == c) return m;
    }
    if (c.contains('bio')) return biology;
    if (c.contains('chem')) return chemistry;
    if (c.contains('phys')) return physics;
    if (c.contains('computer') || c == 'cs') return computerScience;
    if (c.contains('nurs')) return nursing;
    if (c.contains('med') && !c.contains('lab')) return medicine;
    if (c.contains('law')) return law;
    if (c.contains('bus')) return business;
    if (c.contains('fin')) return finance;
    if (c.contains('account')) return accounting;
    if (c.contains('market')) return marketing;
    if (c.contains('econ')) return economics;
    if (c.contains('pharm')) return pharmacy;
    if (c.contains('mls') || c.contains('lab_science') || c.contains('medical_lab')) {
      return mls;
    }
    if (c.contains('psych')) return psychology;
    if (c.contains('math')) return mathematics;
    if (c.contains('civil') || c.contains('electric') || c.contains('engin')) {
      return engineering;
    }
    if (c.contains('cyber')) return cybersecurity;
    return null;
  }

  static const UniversityPracticalMission biology = UniversityPracticalMission(
    id: 'bio_clinical_viva',
    courseId: 'biology',
    emoji: '🦴',
    title: 'Clinical Viva · Posterior shoulder',
    role: 'Anatomy practical student',
    briefingTitle: 'ED CHART',
    briefingBody:
        '22yo fall onto posterior shoulder. Pain with abduction. '
        'You must pick the correct clinical VIEW, the injured bone, and defend WHY.',
    uniqueHook: 'Graded clinical reasoning on a 3D body — not label flashcards.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'VIEW',
        prompt: 'Which view best inspects the scapula after posterior trauma?',
        options: <String>['Anterior only', 'Posterior', 'Feet-up', 'Ignore views'],
        correctIndex: 1,
        coachCorrect: 'Posterior view exposes the scapula on the thorax.',
        coachWrong: 'Scapula is a posterior landmark — rotate behind the patient.',
      ),
      PracticalStep(
        phaseLabel: 'DIAGNOSE',
        prompt: 'Which bone is most implicated by this case?',
        options: <String>['Femur', 'Scapula', 'Tibia', 'Patella'],
        correctIndex: 1,
        coachCorrect: 'Shoulder-blade impact → scapula.',
        coachWrong: 'Think shoulder blade, not lower limb.',
      ),
    ],
    vivaPrompt: 'WHY does scapula location change the differential?',
    vivaOptions: <String>[
      'Memorize lists; views are optional',
      'Posterior pain after fall implicates scapula / clavicle / humerus',
      'Only the femur matters',
      'Guess radius every time',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'clinical_anatomist',
    accent: Color(0xFF3DDBAD),
  );

  static const UniversityPracticalMission chemistry = UniversityPracticalMission(
    id: 'chem_titration_viva',
    courseId: 'chemistry',
    emoji: '⚗️',
    title: 'Titration Board Practical',
    role: 'Analytical chemistry student',
    briefingTitle: 'LAB BRIEF',
    briefingBody:
        'Unknown weak acid. You have NaOH, phenolphthalein, and a burette. '
        'Run a board-style practical: procedure → endpoint → calculation reasoning.',
    uniqueHook: 'Judges procedure + WHY the endpoint works — not a pH quiz dump.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'SETUP',
        prompt: 'Before dripping base, what must you do first?',
        options: <String>[
          'Guess molarity',
          'Rinse & fill burette, record initial volume, add indicator',
          'Boil the acid for fun',
          'Skip volumes',
        ],
        correctIndex: 1,
        coachCorrect: 'Accurate initial volume + indicator is non-negotiable.',
        coachWrong: 'Board labs grade setup before any titration drop.',
      ),
      PracticalStep(
        phaseLabel: 'ENDPOINT',
        prompt: 'Phenolphthalein endpoint for acid–base looks like…',
        options: <String>[
          'Deep purple forever',
          'Persistent pale pink',
          'Bright green',
          'No color change ever',
        ],
        correctIndex: 1,
        coachCorrect: 'Pale persistent pink = endpoint.',
        coachWrong: 'Overshooting to deep color inflates volume.',
      ),
      PracticalStep(
        phaseLabel: 'CALC',
        prompt: 'Moles of base at endpoint equal…',
        options: <String>[
          'Random number',
          'Moles of acid neutralized (stoichiometry)',
          'Only the burette mass',
          'Room temperature',
        ],
        correctIndex: 1,
        coachCorrect: 'n_base = n_acid at neutralization (1:1 here).',
        coachWrong: 'Titration links stoichiometric moles — not vibes.',
      ),
    ],
    vivaPrompt: 'WHY rinse the burette with titrant before filling?',
    vivaOptions: <String>[
      'Because glass looks nicer wet',
      'Residual water would dilute NaOH and bias volume high',
      'To heat the solution',
      'Indicators require rinse water',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'titration_analyst',
    accent: Color(0xFF60A5FA),
  );

  static const UniversityPracticalMission physics = UniversityPracticalMission(
    id: 'phys_projectile_viva',
    courseId: 'physics',
    emoji: '🚀',
    title: 'Projectile Rescue Practical',
    role: 'Physics lab student',
    briefingTitle: 'FIELD BRIEF',
    briefingBody:
        'Drone package must clear a wall. Choose launch angle/speed reasoning, '
        'predict range, then defend energy/kinematics WHY.',
    uniqueHook: 'Mission physics with viva — not watching a video of a ball.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'MODEL',
        prompt: 'Ignoring air, horizontal velocity during flight…',
        options: <String>[
          'Increases',
          'Stays constant',
          'Becomes zero instantly',
          'Depends on mass only',
        ],
        correctIndex: 1,
        coachCorrect: 'No horizontal force → vx constant.',
        coachWrong: 'Gravity only changes vertical velocity.',
      ),
      PracticalStep(
        phaseLabel: 'PREDICT',
        prompt: 'For fixed speed, max range on flat ground is near…',
        options: <String>['0°', '45°', '90°', '180°'],
        correctIndex: 1,
        coachCorrect: 'Ideal max range ≈ 45°.',
        coachWrong: 'Extreme angles trade height vs horizontal reach.',
      ),
      PracticalStep(
        phaseLabel: 'ENERGY',
        prompt: 'At the apex, kinetic energy is…',
        options: <String>[
          'Zero always',
          'Minimum but usually not zero (vx remains)',
          'Maximum',
          'Infinite',
        ],
        correctIndex: 1,
        coachCorrect: 'vy = 0 at apex; vx may remain → KE min ≠ 0.',
        coachWrong: 'Don’t confuse vertical stop with total stop.',
      ),
    ],
    vivaPrompt: 'WHY separate motion into horizontal and vertical components?',
    vivaOptions: <String>[
      'Because textbooks like tables',
      'Independent forces: gravity vertical only, so components solve cleanly',
      'Mass cancels always',
      'Angles are decorative',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'projectile_analyst',
    accent: Color(0xFFFBBF24),
  );

  static const UniversityPracticalMission computerScience = UniversityPracticalMission(
    id: 'cs_incident_viva',
    courseId: 'computer_science',
    emoji: '💻',
    title: 'Production Incident Practical',
    role: 'Junior software engineer',
    briefingTitle: 'PAGER',
    briefingBody:
        'Checkout API p95 latency spiked after deploy. Triage logs, isolate root cause, '
        'ship a safe fix, then defend your reasoning in eng review.',
    uniqueHook: 'Real on-call judgment — not trivia about sorting algorithms.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'TRIAGE',
        prompt: 'First safe move on a latency spike post-deploy?',
        options: <String>[
          'Delete the database',
          'Check dashboards/logs and compare to previous release',
          'Rewrite the company in Rust tonight',
          'Ignore alerts',
        ],
        correctIndex: 1,
        coachCorrect: 'Observe before changing production further.',
        coachWrong: 'Blind rewrites make outages worse.',
      ),
      PracticalStep(
        phaseLabel: 'ROOT CAUSE',
        prompt: 'N+1 DB queries after a feature flag — best fix?',
        options: <String>[
          'Add more CPUs forever',
          'Batch/eager-load and add a regression test',
          'Turn off monitoring',
          'Blame the frontend only',
        ],
        correctIndex: 1,
        coachCorrect: 'Fix the query pattern + lock with a test.',
        coachWrong: 'Hardware ≠ algorithm/IO design.',
      ),
    ],
    vivaPrompt: 'WHY roll forward with a fix instead of forever rollback?',
    vivaOptions: <String>[
      'Rollbacks are illegal',
      'If the feature is needed, a tested fix restores value while protecting latency',
      'Never look at metrics',
      'Always ship Friday nights',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'incident_responder',
    accent: Color(0xFF34D399),
  );

  static const UniversityPracticalMission nursing = UniversityPracticalMission(
    id: 'nursing_triage_viva',
    courseId: 'nursing',
    emoji: '🏥',
    title: 'ED Triage Escalation Practical',
    role: 'Student nurse',
    briefingTitle: 'SHIFT BRIEF',
    briefingBody:
        'Three arrivals at once. Prioritize, assess airway/breathing/circulation, '
        'escalate correctly — then viva your clinical judgment.',
    uniqueHook: 'Priority + escalation reasoning — not a vital-signs flashcard.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'PRIORITIZE',
        prompt: 'Who is seen first?',
        options: <String>[
          'Ankle sprain laughing',
          'Silent adult with stridor and blue lips',
          'Paperwork refill',
          'Whoever arrived first always',
        ],
        correctIndex: 1,
        coachCorrect: 'Airway/breathing threats outrank stable pain.',
        coachWrong: 'Silent hypoxia beats noisy stable complaints.',
      ),
      PracticalStep(
        phaseLabel: 'ASSESS',
        prompt: 'After airway, next immediate check?',
        options: <String>[
          'Family history form',
          'Breathing effort, SpO2, then circulation',
          'Insurance card',
          'Discharge teaching',
        ],
        correctIndex: 1,
        coachCorrect: 'ABC sequence saves lives.',
        coachWrong: 'Admin waits; physiology does not.',
      ),
    ],
    vivaPrompt: 'WHY escalate a dropping SpO2 despite “looks okay”?',
    vivaOptions: <String>[
      'Nurses never escalate',
      'Compensating patients can crash — early escalation prevents arrest',
      'Oxygen numbers are decorative',
      'Wait until unconscious',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'ed_triage_nurse',
    accent: Color(0xFFF472B6),
  );

  static const UniversityPracticalMission medicine = UniversityPracticalMission(
    id: 'med_differential_viva',
    courseId: 'medicine',
    emoji: '🩺',
    title: 'Chest Pain Differential Practical',
    role: 'Medical student',
    briefingTitle: 'WARD CASE',
    briefingBody:
        '58yo crushing chest pain radiating to left arm, diaphoresis. '
        'Build differential, choose first tests, defend diagnosis reasoning.',
    uniqueHook: 'Differential + next-test judgment — not memorizing ICD codes.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'DIFFERENTIAL',
        prompt: 'Top life-threat to rule out first?',
        options: <String>[
          'Mild anxiety only',
          'Acute coronary syndrome / MI',
          'Hangnail',
          'Cerumen impaction',
        ],
        correctIndex: 1,
        coachCorrect: 'Classic ACS presentation — don’t under-triage.',
        coachWrong: 'Chest pain + autonomic signs → cardiac until proven otherwise.',
      ),
      PracticalStep(
        phaseLabel: 'TESTS',
        prompt: 'Immediate first investigations?',
        options: <String>[
          'Routine dental X-ray',
          'ECG + troponin / ACLS pathway',
          'Wait 6 hours doing nothing',
          'Only a personality quiz',
        ],
        correctIndex: 1,
        coachCorrect: 'ECG + biomarkers guide acute management.',
        coachWrong: 'Time is myocardium.',
      ),
    ],
    vivaPrompt: 'WHY keep aortic dissection on the differential?',
    vivaOptions: <String>[
      'It never presents with chest pain',
      'Missed dissection is catastrophic; tearing pain/unequal pulses need urgent imaging',
      'Only MI exists',
      'Skip history',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'diagnostic_clerk',
    accent: Color(0xFFFB7185),
  );

  static const UniversityPracticalMission law = UniversityPracticalMission(
    id: 'law_issue_spot_viva',
    courseId: 'law',
    emoji: '⚖️',
    title: 'Issue-Spotting Case Practical',
    role: 'Junior associate',
    briefingTitle: 'CASE FILE',
    briefingBody:
        'Client hit by delivery scooter in crosswalk. Spot issues, separate facts, '
        'apply duty/breach/causation/damages — then defend your memo thesis.',
    uniqueHook: 'IRAC judgment under time — not multiple-choice vocabulary.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'FACTS',
        prompt: 'Which fact is most legally relevant?',
        options: <String>[
          'Scooter color preference',
          'Plaintiff in marked crosswalk with walk signal',
          'Weather on another continent',
          'Defendant’s favorite lunch',
        ],
        correctIndex: 1,
        coachCorrect: 'Location + signal speak to duty and breach.',
        coachWrong: 'Irrelevant color doesn’t move negligence elements.',
      ),
      PracticalStep(
        phaseLabel: 'ISSUE',
        prompt: 'Core issue frame?',
        options: <String>[
          'Is lunch tasty?',
          'Did defendant breach a duty of care causing plaintiff’s injuries?',
          'Who has better shoes?',
          'Ignore causation',
        ],
        correctIndex: 1,
        coachCorrect: 'Negligence elements drive the memo.',
        coachWrong: 'Issue statements must track the cause of action.',
      ),
    ],
    vivaPrompt: 'WHY separate facts from conclusions in the memo?',
    vivaOptions: <String>[
      'Judges hate organization',
      'Clean facts let rules apply transparently; conclusions without facts fail scrutiny',
      'Never cite rules',
      'Padding wins cases',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'issue_spotter',
    accent: Color(0xFFA78BFA),
  );

  static const UniversityPracticalMission business = UniversityPracticalMission(
    id: 'biz_sales_drop_viva',
    courseId: 'business',
    emoji: '💼',
    title: 'Sales Drop War-Room Practical',
    role: 'Junior business analyst',
    briefingTitle: 'CEO BRIEF',
    briefingBody:
        'Sales −20% QoQ. Dig dashboards, pin root cause, choose a strategy, '
        'defend tradeoffs to the executive team.',
    uniqueHook: 'Evidence → root cause → strategy viva — not a business buzzword quiz.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'EVIDENCE',
        prompt: 'Best first cut of the data?',
        options: <String>[
          'Ignore cohorts',
          'Segment by product, channel, and new vs returning customers',
          'Only look at the logo',
          'Fire everyone immediately',
        ],
        correctIndex: 1,
        coachCorrect: 'Segmentation reveals where the drop lives.',
        coachWrong: 'Aggregate panic hides the real driver.',
      ),
      PracticalStep(
        phaseLabel: 'ROOT CAUSE',
        prompt: 'Conversion flat, churn up after price hike — root cause?',
        options: <String>[
          'Office plant died',
          'Price/value mismatch driving churn',
          'Always the weather',
          'Need more meetings only',
        ],
        correctIndex: 1,
        coachCorrect: 'Link metric pattern to a testable cause.',
        coachWrong: 'Don’t invent causes without metric fingerprints.',
      ),
    ],
    vivaPrompt: 'WHY run a controlled strategy next quarter instead of 10 changes?',
    vivaOptions: <String>[
      'Chaos is strategy',
      'One primary lever preserves causal learning and board accountability',
      'Never measure again',
      'Copy competitors blindly',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'warroom_analyst',
    accent: Color(0xFF38BDF8),
  );

  static const UniversityPracticalMission finance = UniversityPracticalMission(
    id: 'fin_portfolio_viva',
    courseId: 'finance',
    emoji: '💰',
    title: 'Portfolio Shock Practical',
    role: 'Junior financial analyst',
    briefingTitle: 'DESK BRIEF',
    briefingBody:
        'Client portfolio faces a rate spike. Rebalance with risk constraints, '
        'then defend allocation logic under pressure.',
    uniqueHook: 'Risk-aware allocation viva — not memorizing ticker symbols.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'SHOCK',
        prompt: 'Sudden rate hike usually hurts…',
        options: <String>[
          'Cash only',
          'Long-duration bonds most',
          'Nothing ever',
          'Only gold jewelry',
        ],
        correctIndex: 1,
        coachCorrect: 'Duration risk bites when rates rise.',
        coachWrong: 'Bond prices and rates move inversely.',
      ),
      PracticalStep(
        phaseLabel: 'ACTION',
        prompt: 'Risk-aware response within IPS?',
        options: <String>[
          'All-in meme stocks',
          'Shorten duration / rebalance to policy bands',
          'Hide the statement',
          'Ignore client risk tolerance',
        ],
        correctIndex: 1,
        coachCorrect: 'Stay inside IPS while reducing rate sensitivity.',
        coachWrong: 'Gambling violates fiduciary process.',
      ),
    ],
    vivaPrompt: 'WHY document the rebalance rationale?',
    vivaOptions: <String>[
      'Paperwork is optional',
      'Fiduciary process + audit trail protects client and firm',
      'Never revisit risk',
      'Tips from social media suffice',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'desk_analyst',
    accent: Color(0xFFF5D76E),
  );

  static const UniversityPracticalMission accounting = UniversityPracticalMission(
    id: 'acct_audit_viva',
    courseId: 'accounting',
    emoji: '📊',
    title: 'Discrepancy Hunt Practical',
    role: 'Junior accountant',
    briefingTitle: 'AUDIT TICKET',
    briefingBody:
        'Trial balance won’t tie. Trace entries, classify the error type, '
        'propose correction, defend controls WHY.',
    uniqueHook: 'Audit judgment trail — not debit/credit flashcards alone.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'TRACE',
        prompt: 'Revenue booked twice — error type?',
        options: <String>[
          'Perfect entry',
          'Duplication / overstatement of revenue',
          'Always a tax joke',
          'Ignore materiality',
        ],
        correctIndex: 1,
        coachCorrect: 'Duplicate billing overstates revenue.',
        coachWrong: 'Name the misstatement precisely.',
      ),
      PracticalStep(
        phaseLabel: 'CORRECT',
        prompt: 'Proper next step?',
        options: <String>[
          'Delete the GL forever',
          'Post correcting entry + document control gap',
          'Hide in suspense forever',
          'Change the fiscal year secretly',
        ],
        correctIndex: 1,
        coachCorrect: 'Correct + remediate controls.',
        coachWrong: 'Cover-ups fail audits.',
      ),
    ],
    vivaPrompt: 'WHY care about internal controls after fixing the entry?',
    vivaOptions: <String>[
      'Controls are decoration',
      'Without control fix, the same error recurs and audit risk stays high',
      'Never talk to management',
      'Materiality is infinite',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'audit_hunter',
    accent: Color(0xFF2DD4BF),
  );

  static const UniversityPracticalMission marketing = UniversityPracticalMission(
    id: 'mkt_campaign_viva',
    courseId: 'marketing',
    emoji: '📣',
    title: 'Campaign Pivot Practical',
    role: 'Junior strategist',
    briefingTitle: 'CLIENT BRIEF',
    briefingBody:
        'CAC up, ROAS down. Diagnose funnel leak, retarget creative/channel mix, '
        'defend the pivot with metrics.',
    uniqueHook: 'Funnel diagnosis + creative viva — not logo trivia.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'FUNNEL',
        prompt: 'CTR fine, checkout conversion crashed — leak is…',
        options: <String>[
          'Awareness only',
          'Bottom-funnel / checkout experience or offer',
          'Billboard font',
          'Always brand color',
        ],
        correctIndex: 1,
        coachCorrect: 'Healthy CTR + weak conversion → post-click.',
        coachWrong: 'Don’t fix the wrong funnel stage.',
      ),
      PracticalStep(
        phaseLabel: 'PIVOT',
        prompt: 'Best next experiment?',
        options: <String>[
          'Spend 10× blindly',
          'A/B checkout friction + offer clarity with holdout',
          'Delete analytics',
          'Change brand name weekly',
        ],
        correctIndex: 1,
        coachCorrect: 'Test the suspected leak with controls.',
        coachWrong: 'Budget without hypothesis wastes cash.',
      ),
    ],
    vivaPrompt: 'WHY hold out a control group?',
    vivaOptions: <String>[
      'Science is optional in ads',
      'Without a baseline you cannot know if the pivot caused the lift',
      'Always trust vibes',
      'Never look at CAC',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'campaign_strategist',
    accent: Color(0xFFFB923C),
  );

  static const UniversityPracticalMission economics = UniversityPracticalMission(
    id: 'econ_inflation_viva',
    courseId: 'economics',
    emoji: '📈',
    title: 'Inflation Policy Practical',
    role: 'Policy analyst',
    briefingTitle: 'POLICY UNIT',
    briefingBody:
        'Inflation running hot. Choose instruments, anticipate tradeoffs, '
        'defend your recommendation to the committee.',
    uniqueHook: 'Policy tradeoff viva — not definition matching.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'DIAGNOSE',
        prompt: 'Demand-pull inflation signal?',
        options: <String>[
          'Only one store’s price tag',
          'Broad price rises with tight labor / hot demand',
          'A single coupon',
          'Always deflation',
        ],
        correctIndex: 1,
        coachCorrect: 'Broad + demand pressure → demand-pull story.',
        coachWrong: 'One price isn’t macro inflation.',
      ),
      PracticalStep(
        phaseLabel: 'TOOL',
        prompt: 'Classic demand-cooling tool?',
        options: <String>[
          'Print more flyers',
          'Tighter monetary policy (higher policy rates)',
          'Ban thermometers',
          'Ignore expectations',
        ],
        correctIndex: 1,
        coachCorrect: 'Higher rates cool demand.',
        coachWrong: 'Policy must match the inflation type.',
      ),
    ],
    vivaPrompt: 'WHY discuss unemployment tradeoffs when fighting inflation?',
    vivaOptions: <String>[
      'Tradeoffs don’t exist',
      'Disinflation can slow activity — honest policy weighs employment costs',
      'Never model expectations',
      'Only print money',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'policy_analyst',
    accent: Color(0xFF4ADE80),
  );

  static const UniversityPracticalMission pharmacy = UniversityPracticalMission(
    id: 'pharm_verify_viva',
    courseId: 'pharmacy',
    emoji: '💊',
    title: 'Rx Verification Practical',
    role: 'Pharmacy student',
    briefingTitle: 'VERIFY QUEUE',
    briefingBody:
        'New warfarin Rx with interacting antibiotic. Verify, counsel, '
        'escalate safely — then viva clinical judgment.',
    uniqueHook: 'Safety verification + counseling WHY — not pill-color quizzes.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'VERIFY',
        prompt: 'Biggest red flag?',
        options: <String>[
          'Bottle is plastic',
          'Drug–drug interaction raising bleed risk',
          'Patient likes grapes',
          'Label font size',
        ],
        correctIndex: 1,
        coachCorrect: 'Interactions can be life-threatening.',
        coachWrong: 'Safety > cosmetics.',
      ),
      PracticalStep(
        phaseLabel: 'ACT',
        prompt: 'Correct action?',
        options: <String>[
          'Dispense silently',
          'Hold, contact prescriber, document, counsel if proceeding',
          'Double the warfarin yourself',
          'Ignore labs',
        ],
        correctIndex: 1,
        coachCorrect: 'Interprofessional verification protects patients.',
        coachWrong: 'Silent dispense of a known interaction is unsafe.',
      ),
    ],
    vivaPrompt: 'WHY counsel on bleeding signs even after prescriber confirms?',
    vivaOptions: <String>[
      'Counseling is optional fluff',
      'Patients need actionable monitoring because residual risk remains',
      'Never talk to patients',
      'Only counsel vitamins',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'rx_guardian',
    accent: Color(0xFF22D3EE),
  );

  static const UniversityPracticalMission mls = UniversityPracticalMission(
    id: 'mls_panel_viva',
    courseId: 'medical_lab_science',
    emoji: '🔬',
    title: 'Lab Panel Critical Value Practical',
    role: 'MLS student',
    briefingTitle: 'BENCH ALERT',
    briefingBody:
        'Critical potassium result. Validate analytic integrity, call critical, '
        'defend pre-analytical vs analytic reasoning.',
    uniqueHook: 'Critical-value judgment — not memorizing reference ranges only.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'VALIDATE',
        prompt: 'Before calling critical K+, check…',
        options: <String>[
          'Nothing',
          'Hemolysis / sample integrity and analyzer flags',
          'Lobby music',
          'Delete the result',
        ],
        correctIndex: 1,
        coachCorrect: 'Pre-analytical artifacts fake criticals.',
        coachWrong: 'Never call until integrity is checked.',
      ),
      PracticalStep(
        phaseLabel: 'REPORT',
        prompt: 'True critical after validation — next?',
        options: <String>[
          'Wait until tomorrow',
          'Immediate clinician notification + documentation',
          'Post on social media',
          'Change the reference range secretly',
        ],
        correctIndex: 1,
        coachCorrect: 'Criticals require timely closed-loop communication.',
        coachWrong: 'Delay kills.',
      ),
    ],
    vivaPrompt: 'WHY does hemolysis falsely elevate potassium?',
    vivaOptions: <String>[
      'It doesn’t',
      'RBCs release intracellular K+ into serum when lysed',
      'Potassium hates cold rooms only',
      'Printers cause it',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'critical_value_pro',
    accent: Color(0xFF818CF8),
  );

  static const UniversityPracticalMission psychology = UniversityPracticalMission(
    id: 'psych_design_viva',
    courseId: 'psychology',
    emoji: '🧠',
    title: 'Experiment Design Practical',
    role: 'Research assistant',
    briefingTitle: 'LAB PROTOCOL',
    briefingBody:
        'Does sleep deprivation impair working memory? Design controls, '
        'spot confounds, defend ethics and inference.',
    uniqueHook: 'Methods viva — not pop-psych personality quizzes.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'DESIGN',
        prompt: 'Strongest basic design?',
        options: <String>[
          'Ask one friend once',
          'Randomize sleep-deprived vs control; same memory task',
          'Only survey zodiac signs',
          'Skip consent',
        ],
        correctIndex: 1,
        coachCorrect: 'Randomized control isolates the IV.',
        coachWrong: 'Anecdotes ≠ inference.',
      ),
      PracticalStep(
        phaseLabel: 'CONFOUND',
        prompt: 'Testing deprived group at 3am and controls at noon confounds…',
        options: <String>[
          'Nothing',
          'Circadian / time-of-day with the IV',
          'Font choice only',
          'IRB logos',
        ],
        correctIndex: 1,
        coachCorrect: 'Match testing conditions across groups.',
        coachWrong: 'Time-of-day can fake “sleep” effects.',
      ),
    ],
    vivaPrompt: 'WHY is informed consent non-negotiable here?',
    vivaOptions: <String>[
      'Ethics slow science',
      'Participants must understand risks/benefits to choose freely',
      'Never debrief',
      'Hide hypotheses always from IRB',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'methods_ra',
    accent: Color(0xFFE879F9),
  );

  static const UniversityPracticalMission mathematics = UniversityPracticalMission(
    id: 'math_model_viva',
    courseId: 'mathematics',
    emoji: '∑',
    title: 'Model-and-Defend Practical',
    role: 'Math workshop student',
    briefingTitle: 'PROBLEM SET',
    briefingBody:
        'Optimize fencing for a rectangular garden against a wall. '
        'Set variables, differentiate, defend the critical-point reasoning.',
    uniqueHook: 'Setup + justification viva — not answer-key clicking.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'SETUP',
        prompt: 'With one side against a wall, perimeter constraint uses…',
        options: <String>[
          '4 equal sides always',
          'Three fenced sides: 2 widths + length',
          'Ignore the wall',
          'Only diagonals',
        ],
        correctIndex: 1,
        coachCorrect: 'Wall removes one side from fencing cost.',
        coachWrong: 'Model the actual constraint.',
      ),
      PracticalStep(
        phaseLabel: 'OPTIMIZE',
        prompt: 'To maximize area A(x), set…',
        options: <String>[
          'A(x) = 0',
          "A'(x) = 0 and verify it is a maximum",
          'Random guess',
          'Only integrate',
        ],
        correctIndex: 1,
        coachCorrect: 'Critical points from derivative; verify max.',
        coachWrong: 'Calculus tools match the objective.',
      ),
    ],
    vivaPrompt: 'WHY verify the critical point is a maximum?',
    vivaOptions: <String>[
      'Derivatives always maximize',
      'Critical points can be minima or inflection — second test/endpoint check needed',
      'Never check endpoints',
      'Units don’t matter',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'model_defender',
    accent: Color(0xFF67E8F9),
  );

  static const UniversityPracticalMission engineering = UniversityPracticalMission(
    id: 'eng_bridge_viva',
    courseId: 'engineering',
    emoji: '🌉',
    title: 'Bridge Load Practical',
    role: 'Engineering student',
    briefingTitle: 'DESIGN REVIEW',
    briefingBody:
        'Pedestrian bridge must meet load factor with material limits. '
        'Choose topology tradeoffs, spot failure mode, defend safety factor.',
    uniqueHook: 'Safety-factor viva — not pretty CAD screenshots.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'LOAD',
        prompt: 'Live load means…',
        options: <String>[
          'Paint weight only',
          'Transient occupancy / traffic forces',
          'Always zero',
          'Only wind in space',
        ],
        correctIndex: 1,
        coachCorrect: 'Live loads are variable use loads.',
        coachWrong: 'Dead vs live must stay distinct.',
      ),
      PracticalStep(
        phaseLabel: 'FAILURE',
        prompt: 'Slender compression member risk?',
        options: <String>[
          'Only melting',
          'Buckling',
          'Always tension yield first',
          'Ignore geometry',
        ],
        correctIndex: 1,
        coachCorrect: 'Buckling governs slender compression.',
        coachWrong: 'Geometry + load path matter.',
      ),
    ],
    vivaPrompt: 'WHY keep a safety factor above 1.0?',
    vivaOptions: <String>[
      'Codes hate safety',
      'Uncertainty in loads/materials/models — margin prevents catastrophic failure',
      'Overdesign is illegal',
      'Never inspect',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'structural_defender',
    accent: Color(0xFF94A3B8),
  );

  static const UniversityPracticalMission cybersecurity = UniversityPracticalMission(
    id: 'cyber_soc_viva',
    courseId: 'cybersecurity',
    emoji: '🛡️',
    title: 'SOC Triage Practical',
    role: 'SOC analyst',
    briefingTitle: 'ALERT QUEUE',
    briefingBody:
        'Impossible-travel login + new admin creation. Triage severity, '
        'contain, preserve evidence, defend response order.',
    uniqueHook: 'Incident response judgment — not port-number trivia.',
    steps: <PracticalStep>[
      PracticalStep(
        phaseLabel: 'SEVERITY',
        prompt: 'Impossible travel + new admin — severity?',
        options: <String>[
          'Ignore as marketing',
          'High — possible account takeover',
          'Informational spam',
          'Only physical badge issue',
        ],
        correctIndex: 1,
        coachCorrect: 'Credential + privilege anomalies are high severity.',
        coachWrong: 'Don’t under-rank privilege escalation.',
      ),
      PracticalStep(
        phaseLabel: 'CONTAIN',
        prompt: 'First containment move?',
        options: <String>[
          'Wipe all laptops company-wide blindly',
          'Disable/session-revoke the account and freeze risky admin changes',
          'Tweet the password',
          'Delete logs',
        ],
        correctIndex: 1,
        coachCorrect: 'Contain identity, preserve evidence.',
        coachWrong: 'Destroying logs destroys the case.',
      ),
    ],
    vivaPrompt: 'WHY preserve logs before rebuilding hosts?',
    vivaOptions: <String>[
      'Logs are clutter',
      'Forensics and lessons-learned require intact evidence',
      'Always rebuild first',
      'Never notify stakeholders',
    ],
    vivaCorrectIndex: 1,
    badgeId: 'soc_triager',
    accent: Color(0xFF4ADE80),
  );
}
