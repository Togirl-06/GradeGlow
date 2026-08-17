import '../../../data/university_learning_engine.dart';
import '../university_practical/university_practical_lab.dart';
import '../workplace_immersion.dart';
import 'university_sim_models.dart';

/// Builds a unique lab from the lecture topic — not a recycled quiz.
abstract final class UniversitySimFactory {
  static SimBriefing fromLesson({
    required UniversityLabLink link,
    required String subjectId,
    required String courseTitle,
    required String topicTitle,
    required int level,
  }) {
    final int lv = level.clamp(1, 5);
    final SimDomain domain = _domain(subjectId, link.labId);
    final WorkplaceKind workplace =
        UniversityPracticalLabScreen.workplaceForCourse(subjectId);
    final WorkplaceSet set = WorkplaceSet.of(workplace);
    final String topic = topicTitle.trim().isEmpty ? link.title : topicTitle;
    final String course = courseTitle.trim().isEmpty ? subjectId : courseTitle;

    return SimBriefing(
      labTitle: link.title,
      courseLine: '$course · $topic',
      role: set.youAre,
      mission: _mission(domain, topic, lv),
      difficulty: UniversitySimLevels.difficulty(lv),
      minutes: UniversitySimLevels.minutes(link, lv),
      equipment: _equipment(domain),
      skills: _skills(domain, topic),
      scenario: _scenario(domain, topic, set, lv),
      domain: domain,
      workplace: workplace,
      level: lv,
      steps: _steps(domain, topic, lv),
      meters: _meters(domain),
      boardTitle: set.placeName,
    );
  }

  static SimDomain _domain(String subjectId, String labId) {
    final String s = '${subjectId}_$labId'.toLowerCase();
    if (s.contains('nurs') ||
        s.contains('medicine') ||
        s.contains('anatomy') ||
        s.contains('biology') ||
        s.contains('pharm') ||
        s.contains('health')) {
      return SimDomain.clinical;
    }
    if (s.contains('chem')) return SimDomain.chemistry;
    if (s.contains('phys')) return SimDomain.physics;
    if (s.contains('account')) return SimDomain.accounting;
    if (s.contains('finance') || s.contains('fin')) return SimDomain.finance;
    if (s.contains('market')) return SimDomain.marketing;
    if (s.contains('econ') || s.contains('business')) return SimDomain.business;
    if (s.contains('law')) return SimDomain.law;
    if (s.contains('engin')) return SimDomain.engineering;
    if (s.contains('computer') || s.contains('cyber') || s.contains('cs')) {
      return SimDomain.computing;
    }
    return SimDomain.general;
  }

  static String _mission(SimDomain d, String topic, int level) {
    switch (d) {
      case SimDomain.clinical:
        return 'Stabilize the case tied to "$topic". Identify the implicated structure, then choose an intervention and recover if the patient declines.';
      case SimDomain.chemistry:
        return 'Run the bench protocol for "$topic": measure, mix, observe, and identify the unknown without losing temperature control.';
      case SimDomain.physics:
        return 'Set up the apparatus for "$topic", collect a measurement, and correct the model when the readout disagrees.';
      case SimDomain.business:
        return 'Walk the company. Find the operational failure around "$topic" and allocate a response before revenue collapses.';
      case SimDomain.finance:
        return 'Build a defensible position on "$topic", then survive a market shock without violating risk limits.';
      case SimDomain.accounting:
        return 'Trace the books for "$topic", locate the discrepancy, and post the correcting entry.';
      case SimDomain.marketing:
        return 'Brief the client on "$topic", lock an audience, fund the campaign, then correct when performance misses.';
      case SimDomain.law:
        return 'Open the file on "$topic": isolate controlling evidence, research the issue, and recommend a holding.';
      case SimDomain.engineering:
        return 'Inspect the site condition for "$topic", apply a load path decision, and recover if the structure enters warning.';
      case SimDomain.computing:
        return 'Triage the incident related to "$topic": isolate the service, contain blast radius, and restore with a verified patch.';
      case SimDomain.general:
        return 'Apply "$topic" inside a live professional station. Decisions change the board; recover if it degrades.';
    }
  }

  static List<String> _equipment(SimDomain d) {
    switch (d) {
      case SimDomain.clinical:
        return <String>[
          'Patient chart',
          'Stethoscope',
          'Monitor',
          'Crash cart',
          'Imaging viewer',
        ];
      case SimDomain.chemistry:
        return <String>[
          'Burette',
          'Reagent set',
          'Hot plate',
          'pH probe',
          'Fume hood',
        ];
      case SimDomain.physics:
        return <String>[
          'Power supply',
          'Calipers',
          'Photogate',
          'Mass set',
          'Oscilloscope',
        ];
      case SimDomain.business:
        return <String>['P&L', 'Org chart', 'War-room board', 'Budget', 'News wire'];
      case SimDomain.finance:
        return <String>['Statements', 'Bloomberg tape', 'Risk desk', 'Order ticket'];
      case SimDomain.accounting:
        return <String>['Journal', 'Ledger', 'Bank rec', 'Workpapers'];
      case SimDomain.marketing:
        return <String>['Brief', 'Persona board', 'Media plan', 'Dashboard'];
      case SimDomain.law:
        return <String>['Case file', 'Exhibits', 'Reporter', 'Hearing notes'];
      case SimDomain.engineering:
        return <String>['Drawings', 'Load cell', 'Site radio', 'Safety kit'];
      case SimDomain.computing:
        return <String>['SIEM', 'Runbook', 'Firewall', 'Staging deploy'];
      case SimDomain.general:
        return <String>['Case file', 'Instruments', 'Logbook', 'Supervisor radio'];
    }
  }

  static List<String> _skills(SimDomain d, String topic) {
    return <String>[
      'Procedure under pressure',
      topic,
      'Error recovery',
      'Professional communication',
    ];
  }

  static String _scenario(
    SimDomain d,
    String topic,
    WorkplaceSet set,
    int level,
  ) {
    final String density = level >= 4
        ? 'Several findings are already on the board; some are irrelevant.'
        : level == 1
            ? 'I will walk you through the first move. After that, the station is yours.'
            : 'I will not hand you the answer. Work the station.';
    switch (d) {
      case SimDomain.clinical:
        return 'You are in ${set.placeName}. A patient presents with findings that map to $topic. Identify the implicated structure before you intervene. $density';
      case SimDomain.chemistry:
        return 'Hood light is on. The unknown sample was logged against $topic. Measure first — if temperature runs away, you own the quench. $density';
      case SimDomain.physics:
        return 'Apparatus is live. Today\'s protocol is $topic. Take a measurement, then correct the model when the trace is wrong. $density';
      case SimDomain.business:
        return 'You are ${set.youAre} in ${set.placeName}. The quarter is slipping because of a failure tied to $topic. Diagnose, then allocate. $density';
      case SimDomain.finance:
        return 'Desk is open. The book is exposed on $topic. Size the position, then survive the tape when it gaps. $density';
      case SimDomain.accounting:
        return 'Close is tonight. Something in $topic does not foot. Find it in the records, then post the correction. $density';
      case SimDomain.marketing:
        return 'The client is waiting. The brief is $topic. Interview, lock the audience, then move spend when the dashboard turns red. $density';
      case SimDomain.law:
        return 'You are counsel in ${set.placeName}. The file concerns $topic. Isolate the exhibit that matters, then recommend a holding. $density';
      case SimDomain.engineering:
        return 'Site radio is on. Inspection item: $topic. Check the load path before you sign. $density';
      case SimDomain.computing:
        return 'Pager fired. Symptom cluster matches $topic. Isolate, contain, restore — in that order. $density';
      case SimDomain.general:
        return 'You have entered ${set.placeName}. Apply $topic as a practitioner, not as a quiz-taker. $density';
    }
  }

  static List<SimMeter> _meters(SimDomain d) {
    switch (d) {
      case SimDomain.clinical:
        return const <SimMeter>[
          SimMeter(key: 'stability', label: 'Patient stability', value: 58),
          SimMeter(key: 'oxygen', label: 'Oxygenation', value: 64),
          SimMeter(key: 'trust', label: 'Team confidence', value: 70),
        ];
      case SimDomain.chemistry:
        return const <SimMeter>[
          SimMeter(key: 'temp', label: 'Reaction temperature', value: 42, warnAbove: 72),
          SimMeter(key: 'yield', label: 'Yield', value: 30),
          SimMeter(key: 'safety', label: 'Containment', value: 80, warnBelow: 40),
        ];
      case SimDomain.physics:
        return const <SimMeter>[
          SimMeter(key: 'signal', label: 'Signal quality', value: 48),
          SimMeter(key: 'error', label: 'Model error', value: 55, warnAbove: 70),
          SimMeter(key: 'safety', label: 'Interlock', value: 88, warnBelow: 40),
        ];
      case SimDomain.business:
        return const <SimMeter>[
          SimMeter(key: 'revenue', label: 'Revenue', value: 52),
          SimMeter(key: 'morale', label: 'Team morale', value: 60),
          SimMeter(key: 'cash', label: 'Cash runway', value: 57),
        ];
      case SimDomain.finance:
        return const <SimMeter>[
          SimMeter(key: 'pnl', label: 'P&L', value: 50),
          SimMeter(key: 'risk', label: 'Risk utilization', value: 46, warnAbove: 75),
          SimMeter(key: 'liquidity', label: 'Liquidity', value: 62),
        ];
      case SimDomain.accounting:
        return const <SimMeter>[
          SimMeter(key: 'tieout', label: 'Tie-out', value: 38),
          SimMeter(key: 'control', label: 'Control score', value: 55),
          SimMeter(key: 'deadline', label: 'Close clock', value: 70, warnBelow: 30),
        ];
      case SimDomain.marketing:
        return const <SimMeter>[
          SimMeter(key: 'fit', label: 'Audience fit', value: 44),
          SimMeter(key: 'roi', label: 'Campaign ROI', value: 40),
          SimMeter(key: 'brand', label: 'Brand risk', value: 72, warnAbove: 80),
        ];
      case SimDomain.law:
        return const <SimMeter>[
          SimMeter(key: 'case', label: 'Case strength', value: 46),
          SimMeter(key: 'cred', label: 'Credibility', value: 62),
          SimMeter(key: 'clock', label: 'Court clock', value: 68, warnBelow: 30),
        ];
      case SimDomain.engineering:
        return const <SimMeter>[
          SimMeter(key: 'margin', label: 'Safety margin', value: 54, warnBelow: 35),
          SimMeter(key: 'load', label: 'Load path', value: 50),
          SimMeter(key: 'site', label: 'Site discipline', value: 66),
        ];
      case SimDomain.computing:
        return const <SimMeter>[
          SimMeter(key: 'uptime', label: 'Service uptime', value: 41, warnBelow: 35),
          SimMeter(key: 'blast', label: 'Blast radius', value: 62, warnAbove: 70),
          SimMeter(key: 'integrity', label: 'Integrity', value: 58),
        ];
      case SimDomain.general:
        return const <SimMeter>[
          SimMeter(key: 'stability', label: 'Station stability', value: 52),
          SimMeter(key: 'oxygen', label: 'Signal quality', value: 60),
          SimMeter(key: 'trust', label: 'Supervisor confidence', value: 66),
        ];
    }
  }

  static List<SimStep> _steps(SimDomain d, String topic, int level) {
    final bool extra = level >= 4;
    final List<SimStep> core = switch (d) {
      SimDomain.clinical => _clinical(topic),
      SimDomain.chemistry => _chemistry(topic),
      SimDomain.physics => _physics(topic),
      SimDomain.business => _business(topic),
      SimDomain.finance => _finance(topic),
      SimDomain.accounting => _accounting(topic),
      SimDomain.marketing => _marketing(topic),
      SimDomain.law => _law(topic),
      SimDomain.engineering => _engineering(topic),
      SimDomain.computing => _computing(topic),
      SimDomain.general => _clinical(topic),
    };
    if (extra) {
      core.add(_shock(d, topic));
    }
    return core;
  }

  static List<SimHotspot> _spots(List<String> labels, int correctIndex) {
    final List<SimHotspot> out = <SimHotspot>[];
    const List<List<double>> pts = <List<double>>[
      <double>[0.22, 0.32],
      <double>[0.70, 0.28],
      <double>[0.28, 0.68],
      <double>[0.72, 0.70],
      <double>[0.50, 0.48],
    ];
    for (int i = 0; i < labels.length && i < pts.length; i++) {
      out.add(
        SimHotspot(
          id: 'h$i',
          label: labels[i],
          x: pts[i][0],
          y: pts[i][1],
          correct: i == correctIndex,
        ),
      );
    }
    return out;
  }

  static List<SimTool> _tools(List<String> labels, int correctIndex) {
    return <SimTool>[
      for (int i = 0; i < labels.length; i++)
        SimTool(id: 't$i', label: labels[i], correct: i == correctIndex),
    ];
  }

  static List<SimStep> _clinical(String topic) => <SimStep>[
        SimStep(
          id: 'id',
          phase: 'Examine',
          objective:
              'On the anatomical board, mark the structure implicated by $topic — not a nearby look-alike.',
          kind: SimStepKind.locate,
          hotspots: _spots(
            <String>['Primary structure', 'Adjacent organ', 'Incidental finding', 'Normal variant'],
            0,
          ),
          successMeter: 'trust',
          failMeter: 'stability',
          successLog: 'Structure locked on the chart.',
          failAlert: 'You marked the wrong structure. Perfusion is drifting.',
          hint1: 'Start with the organ system from today\'s lecture.',
          hint2: 'The primary structure is the one that would explain the presenting complaint.',
          hint3: 'If two labels look similar, pick the one that sits on the critical path of $topic.',
          solution: 'Select “Primary structure” on the board.',
        ),
        SimStep(
          id: 'dose',
          phase: 'Measure',
          objective: 'Set the intervention dose / rate into the safe window before you push it.',
          kind: SimStepKind.measure,
          measureLabel: 'Delivery',
          measureUnit: '% protocol',
          measureMin: 42,
          measureMax: 58,
          successMeter: 'oxygen',
          failMeter: 'stability',
          successLog: 'Delivery set inside the protocol window.',
          failAlert: 'Blood pressure dropped after an out-of-range delivery.',
          hint1: 'Stay near mid-protocol; extremes are how you harm the patient.',
          hint2: 'The safe window is the middle band of the control.',
          hint3: 'Aim between 42 and 58 on the protocol scale.',
          solution: 'Leave the slider in the 42–58 band, then confirm.',
        ),
        SimStep(
          id: 'act',
          phase: 'Intervene',
          objective: 'Choose the professional action. The cart is live — a wrong push changes vitals.',
          kind: SimStepKind.applyTool,
          tools: _tools(
            <String>[
              'Stabilize airway / circulation',
              'Discharge home',
              'Give an unrelated medication',
              'Ignore the monitor',
            ],
            0,
          ),
          successMeter: 'stability',
          successDelta: 16,
          failMeter: 'stability',
          failDelta: -22,
          successLog: 'Patient response improving.',
          failAlert: 'Patient response detected — stability fell. Recover.',
          hint1: 'Treat the life threat, not the interesting side finding.',
          hint2: 'Airway and circulation come before paperwork.',
          hint3: 'Pick the stabilization action on the cart.',
          solution: 'Use “Stabilize airway / circulation”.',
        ),
      ];

  static List<SimStep> _chemistry(String topic) => <SimStep>[
        SimStep(
          id: 'reagent',
          phase: 'Select',
          objective: 'On the bench diagram, select the reagent class required for $topic.',
          kind: SimStepKind.locate,
          hotspots: _spots(
            <String>['Required reagent', 'Spectator salt', 'Organic solvent waste', 'Indicator only'],
            0,
          ),
          successMeter: 'yield',
          failMeter: 'safety',
          successLog: 'Correct bottle on the bench.',
          failAlert: 'Wrong bottle. Hood alarm ticked.',
          hint1: 'The lecture named one reagent that actually drives the chemistry.',
          hint2: 'Ignore waste and indicators until the stoichiometric reagent is down.',
          hint3: 'Tap the required reagent zone.',
          solution: 'Select “Required reagent”.',
        ),
        SimStep(
          id: 'vol',
          phase: 'Measure',
          objective: 'Deliver titrant into the endpoint window.',
          kind: SimStepKind.measure,
          measureLabel: 'Volume',
          measureUnit: 'mL eq.',
          measureMin: 46,
          measureMax: 62,
          successMeter: 'yield',
          failMeter: 'temp',
          failDelta: 18,
          successLog: 'Volume in range. Color holds.',
          failAlert: 'The reaction temperature is increasing rapidly.',
          hint1: 'Do not flood the flask.',
          hint2: 'Endpoint lives in the middle of the burette travel.',
          hint3: 'Keep the control between 46 and 62.',
          solution: 'Confirm with the volume in the 46–62 window.',
        ),
        SimStep(
          id: 'quench',
          phase: 'Control',
          objective: 'If heat is climbing, quench. Do not add more fuel.',
          kind: SimStepKind.applyTool,
          tools: _tools(
            <String>['Ice bath / quench', 'Increase heat', 'Seal and walk away', 'Add concentrated acid'],
            0,
          ),
          successMeter: 'safety',
          failMeter: 'temp',
          failDelta: 16,
          successLog: 'Temperature under control.',
          failAlert: 'Containment dropped. Pull the quench.',
          hint1: 'Heat is the hazard. Remove it.',
          hint2: 'Quench first; identification second.',
          hint3: 'Use the ice bath.',
          solution: 'Apply “Ice bath / quench”.',
        ),
      ];

  static List<SimStep> _physics(String topic) => <SimStep>[
        SimStep(
          id: 'node',
          phase: 'Build',
          objective: 'On the apparatus, tap the node you must instrument for $topic.',
          kind: SimStepKind.locate,
          hotspots: _spots(
            <String>['Measurement node', 'Ground only', 'Open lead', 'Unused terminal'],
            0,
          ),
          successMeter: 'signal',
          failMeter: 'safety',
          successLog: 'Probe seated.',
          failAlert: 'Interlock tripped on a dead terminal.',
          hint1: 'Instrument the path the lecture actually calculates.',
          hint2: 'Ground is necessary; it is not the measurement.',
          hint3: 'Tap the measurement node.',
          solution: 'Select “Measurement node”.',
        ),
        SimStep(
          id: 'volt',
          phase: 'Measure',
          objective: 'Set drive into the linear region of the apparatus.',
          kind: SimStepKind.measure,
          measureLabel: 'Drive',
          measureUnit: '% scale',
          measureMin: 38,
          measureMax: 55,
          successMeter: 'signal',
          failMeter: 'error',
          failDelta: 14,
          successLog: 'Trace is clean.',
          failAlert: 'Model error jumped — drive was out of band.',
          hint1: 'Too much drive saturates the instrument.',
          hint2: 'Stay slightly below mid-scale.',
          hint3: 'Use 38–55.',
          solution: 'Confirm inside 38–55.',
        ),
        SimStep(
          id: 'fix',
          phase: 'Correct',
          objective: 'The readout disagrees with the model. Correct the setup; do not force the formula.',
          kind: SimStepKind.applyTool,
          tools: _tools(
            <String>[
              'Recalibrate / free-body check',
              'Ignore the residual',
              'Max the supply',
              'Remove the sensor',
            ],
            0,
          ),
          successMeter: 'error',
          successDelta: -20,
          failMeter: 'safety',
          failDelta: -20,
          successLog: 'Residual collapsed.',
          failAlert: 'Unexpected result. The experiment is no longer trustworthy.',
          hint1: 'Treat a bad residual as a setup error.',
          hint2: 'Recalibrate before you rewrite the law.',
          hint3: 'Use recalibrate / free-body check.',
          solution: 'Apply “Recalibrate / free-body check”.',
        ),
      ];

  static List<SimStep> _business(String topic) => <SimStep>[
        SimStep(
          id: 'dept',
          phase: 'Diagnose',
          objective: 'On the org board, mark the function that is actually failing for $topic.',
          kind: SimStepKind.locate,
          hotspots: _spots(
            <String>['Failing function', 'A loud but healthy team', 'Facilities', 'An intern pod'],
            0,
          ),
          successMeter: 'morale',
          failMeter: 'revenue',
          successLog: 'Root cause located.',
          failAlert: 'You spent a week in the wrong department. Revenue dipped.',
          hint1: 'The noisiest team is not always the broken one.',
          hint2: 'Follow the metric that moved with $topic.',
          hint3: 'Select the failing function.',
          solution: 'Tap “Failing function”.',
        ),
        SimStep(
          id: 'budget',
          phase: 'Allocate',
          objective: 'Move budget into the repair — not a vanity project.',
          kind: SimStepKind.measure,
          measureLabel: 'Repair share',
          measureUnit: '% of reserve',
          measureMin: 40,
          measureMax: 62,
          successMeter: 'cash',
          failMeter: 'revenue',
          successLog: 'Capital is on the actual problem.',
          failAlert: 'Breaking news: a competitor cut prices 20%. Your mis-allocation shows.',
          hint1: 'Underfunding the repair is how you lose the quarter.',
          hint2: 'Aim near half the reserve.',
          hint3: 'Keep 40–62%.',
          solution: 'Confirm 40–62% on the control.',
        ),
        SimStep(
          id: 'respond',
          phase: 'Respond',
          objective: 'Competitor moved. Choose the professional response.',
          kind: SimStepKind.applyTool,
          tools: _tools(
            <String>[
              'Hold value, fix operations',
              'Panic-match price to zero margin',
              'Freeze hiring and hide',
              'Announce a product that does not exist',
            ],
            0,
          ),
          successMeter: 'revenue',
          failMeter: 'cash',
          successLog: 'The board steadied.',
          failAlert: 'Cash runway shortened. You still have to run the company.',
          hint1: 'Price wars without a cost advantage destroy cash.',
          hint2: 'Fix the failure you already found.',
          hint3: 'Hold value and fix operations.',
          solution: 'Apply “Hold value, fix operations”.',
        ),
      ];

  static List<SimStep> _finance(String topic) => <SimStep>[
        SimStep(
          id: 'line',
          phase: 'Read',
          objective: 'On the statement, mark the line that actually prices $topic risk.',
          kind: SimStepKind.locate,
          hotspots: _spots(
            <String>['Risk-bearing line', 'Cosmetic footnote', 'Prior-year noise', 'Tax boilerplate'],
            0,
          ),
          successMeter: 'liquidity',
          failMeter: 'risk',
          failDelta: 16,
          successLog: 'Risk line isolated.',
          failAlert: 'You modeled the wrong line. Utilization jumped.',
          hint1: 'Ignore decorative notes until the economic line is marked.',
          hint2: 'The risk-bearing line is the one that moves with the book.',
          hint3: 'Select “Risk-bearing line”.',
          solution: 'Tap the risk-bearing line.',
        ),
        SimStep(
          id: 'size',
          phase: 'Size',
          objective: 'Size the position inside mandate. Hero sizing is how books blow up.',
          kind: SimStepKind.measure,
          measureLabel: 'Gross book',
          measureUnit: '% NAV',
          measureMin: 28,
          measureMax: 48,
          successMeter: 'pnl',
          failMeter: 'risk',
          failDelta: 18,
          successLog: 'Size is inside mandate.',
          failAlert: 'Tape gapped. Oversize inventory is now a problem.',
          hint1: 'Stay conservative on a live desk.',
          hint2: 'Mandate lives in the lower half of the slider.',
          hint3: '28–48% NAV.',
          solution: 'Confirm inside 28–48.',
        ),
        SimStep(
          id: 'shock',
          phase: 'Shock',
          objective: 'Market shock. Hedge or cut — do not double down.',
          kind: SimStepKind.applyTool,
          tools: _tools(
            <String>[
              'Hedge / reduce risk',
              'Double the position',
              'Turn off the monitors',
              'Pledge unencumbered cash as more collateral blindly',
            ],
            0,
          ),
          successMeter: 'pnl',
          failMeter: 'liquidity',
          successLog: 'Book survived the gap.',
          failAlert: 'Portfolio lost money. Liquidity is the next fight.',
          hint1: 'Shock is not a dare.',
          hint2: 'Cut or hedge first.',
          hint3: 'Hedge / reduce risk.',
          solution: 'Apply “Hedge / reduce risk”.',
        ),
      ];

  static List<SimStep> _accounting(String topic) => <SimStep>[
        SimStep(
          id: 'tx',
          phase: 'Trace',
          objective: 'On the journal, mark the entry that does not belong with $topic.',
          kind: SimStepKind.locate,
          hotspots: _spots(
            <String>['Misposted entry', 'Routine accrual', 'Opening balance', 'Memo only'],
            0,
          ),
          successMeter: 'tieout',
          failMeter: 'deadline',
          successLog: 'Exception isolated.',
          failAlert: 'You queried a clean accrual. The clock ran.',
          hint1: 'Look for the entry that breaks the account relationship.',
          hint2: 'Memos do not post. Accruals that reverse are usually fine.',
          hint3: 'Select the misposted entry.',
          solution: 'Tap “Misposted entry”.',
        ),
        SimStep(
          id: 'amt',
          phase: 'Post',
          objective: 'Post the correcting amount in the materiality window.',
          kind: SimStepKind.measure,
          measureLabel: 'Correction',
          measureUnit: 'bps of materiality',
          measureMin: 35,
          measureMax: 55,
          successMeter: 'control',
          failMeter: 'tieout',
          successLog: 'Correction accepted.',
          failAlert: 'Over/under posting. The rec still fails.',
          hint1: 'Do not over-correct.',
          hint2: 'Stay near half of materiality.',
          hint3: '35–55.',
          solution: 'Confirm 35–55.',
        ),
        SimStep(
          id: 'rec',
          phase: 'Close',
          objective: 'Finish the file like an auditor is watching.',
          kind: SimStepKind.applyTool,
          tools: _tools(
            <String>[
              'Re-tie and document',
              'Force-balance with a plug',
              'Delete the exception',
              'Sign off without workpapers',
            ],
            0,
          ),
          successMeter: 'tieout',
          failMeter: 'control',
          successLog: 'Statements now foot.',
          failAlert: 'Control score dropped. You still have to close.',
          hint1: 'Plugs are how restatements start.',
          hint2: 'Document the rec.',
          hint3: 'Re-tie and document.',
          solution: 'Apply “Re-tie and document”.',
        ),
      ];

  static List<SimStep> _marketing(String topic) => <SimStep>[
        SimStep(
          id: 'aud',
          phase: 'Audience',
          objective: 'On the persona board, mark the audience actually implied by $topic.',
          kind: SimStepKind.locate,
          hotspots: _spots(
            <String>['True audience', 'Vanity segment', 'Internal staff', 'A celebrity who will not buy'],
            0,
          ),
          successMeter: 'fit',
          failMeter: 'brand',
          failDelta: 12,
          successLog: 'Audience locked.',
          failAlert: 'You briefed the wrong room. Brand risk ticked up.',
          hint1: 'Buyers, not spectators.',
          hint2: 'Ignore celebrity gravity.',
          hint3: 'Select “True audience”.',
          solution: 'Tap “True audience”.',
        ),
        SimStep(
          id: 'spend',
          phase: 'Budget',
          objective: 'Fund the campaign without lighting the whole budget on day one.',
          kind: SimStepKind.measure,
          measureLabel: 'Day-1 spend',
          measureUnit: '% budget',
          measureMin: 22,
          measureMax: 40,
          successMeter: 'roi',
          failMeter: 'brand',
          successLog: 'Test budget is live.',
          failAlert: 'Dashboard is red. You spent before you learned.',
          hint1: 'Learn, then scale.',
          hint2: 'A first-day burst should stay under half.',
          hint3: '22–40%.',
          solution: 'Confirm 22–40.',
        ),
        SimStep(
          id: 'pivot',
          phase: 'Adjust',
          objective: 'Performance missed. Adjust the strategy; do not shout louder at the wrong people.',
          kind: SimStepKind.applyTool,
          tools: _tools(
            <String>[
              'Refit audience and creative',
              'Triple spend on the same ads',
              'Blame the intern publicly',
              'Kill tracking so the board looks calm',
            ],
            0,
          ),
          successMeter: 'roi',
          failMeter: 'fit',
          successLog: 'The campaign recovered.',
          failAlert: 'ROI fell again. The client is still in the room.',
          hint1: 'If fit is wrong, more spend makes it worse.',
          hint2: 'Change who you talk to and what you say.',
          hint3: 'Refit audience and creative.',
          solution: 'Apply “Refit audience and creative”.',
        ),
      ];

  static List<SimStep> _law(String topic) => <SimStep>[
        SimStep(
          id: 'ex',
          phase: 'Evidence',
          objective: 'On the exhibit table, mark the evidence that actually controls $topic.',
          kind: SimStepKind.locate,
          hotspots: _spots(
            <String>['Controlling exhibit', 'Prejudicial color', 'Inadmissible rumor', 'A sympathetic photo'],
            0,
          ),
          successMeter: 'case',
          failMeter: 'cred',
          successLog: 'Record is clean.',
          failAlert: 'You argued color. The court is unimpressed.',
          hint1: 'Facts that change the legal issue, not the mood.',
          hint2: 'Rumor is not the record.',
          hint3: 'Select the controlling exhibit.',
          solution: 'Tap “Controlling exhibit”.',
        ),
        SimStep(
          id: 'issue',
          phase: 'Research',
          objective: 'Scope the research — enough to see the issue, not a wandering treatise.',
          kind: SimStepKind.measure,
          measureLabel: 'Authority depth',
          measureUnit: '% of file hours',
          measureMin: 35,
          measureMax: 58,
          successMeter: 'case',
          failMeter: 'clock',
          successLog: 'Issue is framed.',
          failAlert: 'You over-researched dicta. The clock is the next opponent.',
          hint1: 'Binders are not a strategy.',
          hint2: 'Cover the elements, then stop.',
          hint3: '35–58%.',
          solution: 'Confirm 35–58.',
        ),
        SimStep(
          id: 'hold',
          phase: 'Recommend',
          objective: 'Recommend a holding. Weak theory will not survive a hearing.',
          kind: SimStepKind.applyTool,
          tools: _tools(
            <String>[
              'Apply the rule to the controlling facts',
              'Appeal to sympathy only',
              'Hide the bad fact',
              'Refuse to take a position',
            ],
            0,
          ),
          successMeter: 'cred',
          failMeter: 'case',
          successLog: 'Recommendation will travel.',
          failAlert: 'The argument lost force. Rebuild on the record.',
          hint1: 'Rule plus facts. Nothing else.',
          hint2: 'Do not bury the bad fact; distinguish it.',
          hint3: 'Apply the rule to the controlling facts.',
          solution: 'Apply “Apply the rule to the controlling facts”.',
        ),
      ];

  static List<SimStep> _engineering(String topic) => <SimStep>[
        SimStep(
          id: 'member',
          phase: 'Inspect',
          objective: 'On the drawing, mark the member that is actually loaded for $topic.',
          kind: SimStepKind.locate,
          hotspots: _spots(
            <String>['Primary member', 'Architectural cladding', 'Temporary brace leftover', 'A railing'],
            0,
          ),
          successMeter: 'load',
          failMeter: 'margin',
          successLog: 'Member identified.',
          failAlert: 'You inspected cosmetics. Safety margin slipped.',
          hint1: 'Follow the load path, not the finish.',
          hint2: 'Railings are not the structure.',
          hint3: 'Select the primary member.',
          solution: 'Tap “Primary member”.',
        ),
        SimStep(
          id: 'factor',
          phase: 'Factor',
          objective: 'Set the factor of safety into the code window.',
          kind: SimStepKind.measure,
          measureLabel: 'FoS',
          measureUnit: '% of code',
          measureMin: 48,
          measureMax: 68,
          successMeter: 'margin',
          failMeter: 'site',
          successLog: 'Factor accepted.',
          failAlert: 'The experiment produced unexpected results — you are outside code.',
          hint1: 'Code is a band, not a dare.',
          hint2: 'Stay a little above the midpoint.',
          hint3: '48–68%.',
          solution: 'Confirm 48–68.',
        ),
        SimStep(
          id: 'fix',
          phase: 'Recover',
          objective: 'If the member is in warning, unload and shore. Do not hope.',
          kind: SimStepKind.applyTool,
          tools: _tools(
            <String>[
              'Shore and unload',
              'Add more live load to “test” it',
              'Paint over the crack',
              'Send the crew home without a brief',
            ],
            0,
          ),
          successMeter: 'site',
          failMeter: 'margin',
          successLog: 'Site is back under control.',
          failAlert: 'Margin collapsed. People are still on the deck.',
          hint1: 'Warning is a stop, not a suggestion.',
          hint2: 'Shore first.',
          hint3: 'Shore and unload.',
          solution: 'Apply “Shore and unload”.',
        ),
      ];

  static List<SimStep> _computing(String topic) => <SimStep>[
        SimStep(
          id: 'svc',
          phase: 'Isolate',
          objective: 'On the service map, mark the component actually implicated by $topic.',
          kind: SimStepKind.locate,
          hotspots: _spots(
            <String>['Failing service', 'A noisy but healthy replica', 'Docs site', 'A laptop on guest wifi'],
            0,
          ),
          successMeter: 'integrity',
          failMeter: 'uptime',
          successLog: 'Blast radius shrinking.',
          failAlert: 'You rebooted the wrong box. Uptime fell.',
          hint1: 'Correlate symptoms to the dependency graph.',
          hint2: 'Guest wifi is not production.',
          hint3: 'Select the failing service.',
          solution: 'Tap “Failing service”.',
        ),
        SimStep(
          id: 'canary',
          phase: 'Contain',
          objective: 'Canary the fix. Full-fleet deploys during an incident are how outages become legends.',
          kind: SimStepKind.measure,
          measureLabel: 'Canary share',
          measureUnit: '% fleet',
          measureMin: 8,
          measureMax: 22,
          successMeter: 'uptime',
          failMeter: 'blast',
          failDelta: 14,
          successLog: 'Canary is quiet.',
          failAlert: 'You shipped too wide. Blast radius grew.',
          hint1: 'Small, then watch.',
          hint2: 'Keep canary in the teens.',
          hint3: '8–22%.',
          solution: 'Confirm 8–22.',
        ),
        SimStep(
          id: 'restore',
          phase: 'Restore',
          objective: 'Restore with a verified patch. Do not wipe logs to look calm.',
          kind: SimStepKind.applyTool,
          tools: _tools(
            <String>[
              'Verified patch + watch',
              'rm -rf the logs',
              'Disable auth so users can “just work”',
              'Page everyone in the company',
            ],
            0,
          ),
          successMeter: 'integrity',
          failMeter: 'blast',
          successLog: 'Service recovered.',
          failAlert: 'Integrity took a hit. You are still on the incident.',
          hint1: 'Evidence and a real patch.',
          hint2: 'Do not turn off auth.',
          hint3: 'Verified patch + watch.',
          solution: 'Apply “Verified patch + watch”.',
        ),
      ];

  static SimStep _shock(SimDomain d, String topic) {
    final List<SimMeter> m = _meters(d);
    final String ok = m.first.key;
    final String bad = m.length > 1 ? m[1].key : m.first.key;
    return SimStep(
      id: 'lv4',
      phase: 'Complication',
      objective:
          'A second signal just appeared. Decide what actually matters for $topic — then act.',
      kind: SimStepKind.applyTool,
      tools: _tools(
        <String>[
          'Treat the primary failure first',
          'Chase the new alarm blindly',
          'Stop and wait for someone else',
          'Reset the whole station',
        ],
        0,
      ),
      successMeter: ok,
      failMeter: bad,
      successLog: 'You kept the primary problem in front.',
      failAlert: 'The secondary alarm ate the clock. The original problem is worse.',
      hint1: 'New alarms are often downstream of the first mistake.',
      hint2: 'Primary failure still leads.',
      hint3: 'Treat the primary failure first.',
      solution: 'Apply “Treat the primary failure first”.',
    );
  }
}
