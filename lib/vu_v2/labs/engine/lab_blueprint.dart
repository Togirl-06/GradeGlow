import '../../../data/university_learning_engine.dart';
import '../../curriculum/academic_quality_contract.dart';

enum LabDiscipline {
  anatomy,
  biology,
  chemistry,
  physics,
  mathematics,
  computerScience,
  engineering,
  medicine,
  nursing,
  economics,
  finance,
  accounting,
  business,
  marketing,
  law,
  psychology,
  history,
  geography,
  architecture,
  careerPractice,
}

class LabBlueprint {
  const LabBlueprint({
    required this.discipline,
    required this.title,
    required this.courseTitle,
    required this.unitTitle,
    required this.role,
    required this.mission,
    required this.scenario,
    required this.objectives,
    required this.requiredKnowledge,
    required this.tools,
    required this.materials,
    required this.layers,
    required this.safety,
    required this.hints,
    required this.bottomTools,
    required this.environmentLabel,
    required this.estimatedMinutes,
    required this.level,
  });

  final LabDiscipline discipline;
  final String title;
  final String courseTitle;
  final String unitTitle;
  String get unit => unitTitle;
  final String role;
  final String mission;
  final String scenario;
  final List<String> objectives;
  final List<String> requiredKnowledge;
  final List<String> tools;
  final List<String> materials;
  final List<String> layers;
  final String safety;
  final List<String> hints;
  final List<String> bottomTools;
  final String environmentLabel;
  final int estimatedMinutes;
  final int level;

  LabQualityReport get quality => LabQualityContract.inspectSpec(
        InvestigationSpecLike(
          scenario: scenario,
          objectives: objectives,
          equipment: <String>[...tools, ...materials],
          procedure: requiredKnowledge,
          beats: LabQualityContract.requiredBeats,
        ),
      );
}

abstract final class LabCatalog {
  static String _norm(String raw) =>
      raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

  static bool _has(String haystack, List<String> needles) =>
      needles.any(haystack.contains);

  static LabDiscipline disciplineFor({
    required String subjectId,
    required String topicTitle,
    String labId = '',
  }) {
    final String topic = _norm('$topicTitle $labId');

    // Topic wins when it names a concrete academic object.
    if (_has(topic, const <String>[
          'skelet',
          'heart',
          'muscular',
          'anatomy',
          'cardio',
          'vessel',
          'osseous',
        ]) &&
        !_has(topic, const <String>['patient', 'triage', 'vital', 'nurs'])) {
      return LabDiscipline.anatomy;
    }
    if (_has(topic, const <String>[
          'microscop',
          'organelle',
          'specimen',
          'chloroplast',
          'dna',
        ]) ||
        (topic.contains('cell') && !topic.contains('excel'))) {
      return LabDiscipline.biology;
    }
    if (_has(topic, const <String>['titrat', 'stoich', 'burette', 'reagent', 'molar'])) {
      return LabDiscipline.chemistry;
    }
    if (_has(topic, const <String>[
      'projectile',
      'newton',
      'kinematic',
      'pendulum',
      'gravity',
    ])) {
      return LabDiscipline.physics;
    }
    if (_has(topic, const <String>[
      'derivative',
      'calculus',
      'integral',
      'tangent',
    ])) {
      return LabDiscipline.mathematics;
    }
    if (_has(topic, const <String>[
      'binary search',
      'algorithm',
      'debugger',
      'datastruct',
    ])) {
      return LabDiscipline.computerScience;
    }
    if (_has(topic, const <String>['circuit', 'truss', 'bridge', 'load test'])) {
      return LabDiscipline.engineering;
    }
    if (_has(topic, const <String>['patient', 'triage', 'chest pain', 'vital sign'])) {
      return topic.contains('nurs')
          ? LabDiscipline.nursing
          : LabDiscipline.medicine;
    }
    if (_has(topic, const <String>['portfolio', 'blotter', 'equity', 'rebalance'])) {
      return LabDiscipline.finance;
    }
    if (_has(topic, const <String>['audit', 'ledger', 'invoice', 'trial balance'])) {
      return LabDiscipline.accounting;
    }
    if (_has(topic, const <String>['inflation', 'unemployment', 'gdp', 'policy rate'])) {
      return LabDiscipline.economics;
    }
    if (_has(topic, const <String>['campaign', 'roas', 'cac', 'impressions'])) {
      return LabDiscipline.marketing;
    }
    if (_has(topic, const <String>['complaint', 'statute', 'precedent', 'exhibit'])) {
      return LabDiscipline.law;
    }
    if (_has(topic, const <String>['gis', 'land use', 'climate layer'])) {
      return LabDiscipline.geography;
    }
    if (_has(topic, const <String>['massing', 'floor plan', 'elevation'])) {
      return LabDiscipline.architecture;
    }
    if (_has(topic, const <String>[
      'resume',
      'interview',
      'star stor',
      'public speak',
      'budget',
      'cover letter',
      'negotiation',
      'freelancer',
      'leadership',
    ])) {
      return LabDiscipline.careerPractice;
    }
    return fromSubject(subjectId);
  }

  static LabDiscipline fromSubject(String subjectId) {
    final String s = _norm(subjectId).replaceAll(' ', '');
    if (s.contains('computerscience') ||
        s == 'cs' ||
        s.contains('softwareeng') ||
        s.contains('programming')) {
      return LabDiscipline.computerScience;
    }
    if (s.contains('nurs')) return LabDiscipline.nursing;
    if (s.contains('architect')) return LabDiscipline.architecture;
    if (s.contains('geograph')) return LabDiscipline.geography;
    if (s.contains('careerpractice')) return LabDiscipline.careerPractice;
    if (s.contains('histor')) return LabDiscipline.history;
    if (s.contains('psych')) return LabDiscipline.psychology;
    if (s.contains('market')) return LabDiscipline.marketing;
    if (s.contains('account')) return LabDiscipline.accounting;
    if (s.contains('financ')) return LabDiscipline.finance;
    if (s.contains('econom')) return LabDiscipline.economics;
    if (s.contains('business')) return LabDiscipline.business;
    if (s.contains('medicin') || s.contains('clinical')) {
      return LabDiscipline.medicine;
    }
    if (s.contains('anatomy')) return LabDiscipline.anatomy;
    if (s.contains('chem')) return LabDiscipline.chemistry;
    if (s.contains('physic')) return LabDiscipline.physics;
    if (s.contains('math')) return LabDiscipline.mathematics;
    if (s.contains('engin')) return LabDiscipline.engineering;
    if (s == 'law' || s.contains('legal')) return LabDiscipline.law;
    if (s.contains('bio')) return LabDiscipline.biology;
    if (s.contains('resume') ||
        s.contains('interview') ||
        s.contains('speak') ||
        s.contains('career') ||
        s.contains('personalfinance') ||
        s.contains('personal_finance') ||
        s.contains('leadership') ||
        s.contains('communication') ||
        s.contains('freelance') ||
        s.contains('time') ||
        s.contains('productivity')) {
      return LabDiscipline.careerPractice;
    }
    return LabDiscipline.careerPractice;
  }

  static LabBlueprint forLesson({
    required String subjectId,
    required String courseTitle,
    required String topicTitle,
    required UniversityLabLink link,
    required int level,
  }) {
    final LabDiscipline d = disciplineFor(
      subjectId: subjectId,
      topicTitle: topicTitle,
      labId: link.labId,
    );
    return _spec(d, courseTitle, topicTitle, link.title, level.clamp(1, 4));
  }

  static LabBlueprint _spec(
    LabDiscipline d,
    String course,
    String topic,
    String title,
    int level,
  ) {
    final _Pack p = _Pack.of(d, topic, course);
    return LabBlueprint(
      discipline: d,
      title: title.trim().isEmpty ? p.title : title,
      courseTitle: course,
      unitTitle: p.unit,
      role: p.role,
      mission: p.mission,
      scenario: p.scenario,
      objectives: p.objectives,
      requiredKnowledge: p.knowledge,
      tools: p.tools,
      materials: p.materials,
      layers: p.layers,
      safety: p.safety,
      hints: p.hints,
      bottomTools: p.bottom,
      environmentLabel: p.environment,
      estimatedMinutes: 28 + level * 4,
      level: level,
    );
  }
}

class _Pack {
  const _Pack({
    required this.title,
    required this.unit,
    required this.role,
    required this.mission,
    required this.scenario,
    required this.objectives,
    required this.knowledge,
    required this.tools,
    required this.materials,
    required this.layers,
    required this.safety,
    required this.hints,
    required this.bottom,
    required this.environment,
  });

  final String title;
  final String unit;
  final String role;
  final String mission;
  final String scenario;
  final List<String> objectives;
  final List<String> knowledge;
  final List<String> tools;
  final List<String> materials;
  final List<String> layers;
  final String safety;
  final List<String> hints;
  final List<String> bottom;
  final String environment;

  static _Pack of(LabDiscipline d, String topic, String course) {
    switch (d) {
      case LabDiscipline.anatomy:
        return _Pack(
          title: 'Trace and inspect $topic',
          unit: 'Gross anatomy',
          role: 'Anatomy student',
          mission:
              'Manipulate the anatomical model. Isolate systems, identify structures, and if this is a heart lab, trace blood flow in order.',
          scenario:
              'You are at the cadaver / atlas station for $course. The model is live. Quiz labels will not appear until you inspect.',
          objectives: const <String>[
            'Orbit and zoom the model',
            'Toggle anatomical layers',
            'Identify named structures by touching them',
            'Trace a pathway when the mission requires it',
          ],
          knowledge: <String>['Anatomical position', topic],
          tools: const <String>['Orbit', 'Zoom', 'Isolate', 'Pin', 'Search'],
          materials: const <String>['3D atlas', 'Layer set', 'Pins'],
          layers: const <String>[
            'Skeletal',
            'Muscular',
            'Cardiovascular',
            'Labels',
          ],
          safety: 'Treat the station as a shared lab. Reset the view when you leave.',
          hints: const <String>[
            'Start with one system on.',
            'Hide everything that is not the structure you are hunting.',
            'Anterior/lateral/posterior are different data, not decoration.',
            'For the heart: vena cava → RA → tricuspid → RV → pulmonary path → LA → mitral → LV → aorta.',
          ],
          bottom: const <String>['rotate', 'zoom', 'isolate', 'reset', 'pin'],
          environment: 'Anatomy theater · interactive atlas',
        );
      case LabDiscipline.biology:
        return _Pack(
          title: 'Unknown cell investigation',
          unit: 'Cell biology',
          role: 'Junior laboratory technician',
          mission:
              'Prepare, focus, and classify an unlabeled specimen. The microscope behaves like a microscope.',
          scenario:
              'A research team sent an unknown smear. You have a compound microscope and a notebook — not an answer key.',
          objectives: const <String>[
            'Load the unknown slide',
            'Focus at 4× before climbing power',
            'Pan the field and pin structures',
            'Hypothesize, test, report',
          ],
          knowledge: <String>[topic, 'Plant vs animal vs prokaryote'],
          tools: const <String>['4×', '10×', '40×', 'Lamp', 'Classify'],
          materials: const <String>['Unknown slide', 'Blank', 'Notebook'],
          layers: const <String>['Field', 'Pins', 'Scale bar'],
          safety: 'Do not drag 40× across an unfocused field.',
          hints: const <String>[
            'Find the specimen at 4×.',
            'Coarse, then fine, then light.',
            'A wall plus chloroplasts is a plant argument.',
            'I will demonstrate 4× → 10× → 40× if you ask for the last hint.',
          ],
          bottom: const <String>['4×', '10×', '40×', 'pin', 'classify'],
          environment: 'Teaching laboratory · microscope',
        );
      case LabDiscipline.chemistry:
        return _Pack(
          title: 'Acid–base titration',
          unit: 'Stoichiometry',
          role: 'Analytical chemistry student',
          mission:
              'Determine the concentration of an unknown monoprotic acid with standardized NaOH.',
          scenario:
              'Unknown acid on the bench. Glassware is empty. Mix-A-plus-B is not a method.',
          objectives: const <String>[
            'Rinse and charge the burette',
            'Control the stopcock near the endpoint',
            'Record titres including overshoots',
            'Calculate M and error',
          ],
          knowledge: <String>[topic, 'Moles = M × V'],
          tools: const <String>['Burette', 'Pipette', 'Flask', 'Stopcock'],
          materials: const <String>['Unknown acid', '0.1000 M NaOH', 'Indicator'],
          layers: const <String>['Bench', 'Meniscus', 'Flask color'],
          safety: 'NaOH is corrosive. Overshoot stays in the notebook.',
          hints: const <String>[
            'Rinse with the solution the glassware will hold.',
            'Clear the tip bubble before the initial volume.',
            'Phenolphthalein is a window, not a moral verdict.',
            'Approach dropwise after the first blush of pink.',
          ],
          bottom: const <String>['rinse', 'fill', 'add drop', 'record', 'reset'],
          environment: 'Quantitative analysis lab',
        );
      case LabDiscipline.physics:
        return _Pack(
          title: 'Mechanics apparatus',
          unit: 'Mechanics',
          role: 'Introductory physics student',
          mission:
              'Manipulate the apparatus, collect noisy data, and extract a model quantity with an error story.',
          scenario:
              'The bench will not give you 9.81 on every drop, or a perfect parabola. You run the experiment.',
          objectives: const <String>[
            'Set parameters on the apparatus',
            'Run repeated trials',
            'Read the generated graph',
            'Calculate and explain residual error',
          ],
          knowledge: <String>[topic, 'g = 2h/t² or projectile kinematics'],
          tools: const <String>['Launcher', 'Photogate', 'Meter stick', 'Graph'],
          materials: const <String>['Mass', 'Track'],
          layers: const <String>['Trajectory', 'Vectors', 'Graph'],
          safety: 'Clear the drop zone.',
          hints: const <String>[
            'Change one variable at a time.',
            'Five trials beat one lucky number.',
            'Timing error is squared in g = 2h/t².',
            'Drag the launch handle; the graph is the data.',
          ],
          bottom: const <String>['run', 'reset', 'measure', 'graph'],
          environment: 'Mechanics bay',
        );
      case LabDiscipline.mathematics:
        return _Pack(
          title: 'Explore the derivative',
          unit: 'Calculus',
          role: 'Mathematics student',
          mission:
              'Move a point on a live function. Watch the tangent. Find where the rate of increase is greatest.',
          scenario:
              'This is not a worksheet. The curve is an instrument.',
          objectives: const <String>[
            'Drag x and read f(x) and f′(x)',
            'Identify sign changes of slope',
            'Locate the maximum rate of increase',
          ],
          knowledge: <String>[topic, 'Definition of derivative as slope of tangent'],
          tools: const <String>['Point', 'Tangent', 'Readout'],
          materials: const <String>['f(x) = x³ − 3x'],
          layers: const <String>['Curve', 'Tangent', 'Grid'],
          safety: 'No physical hazard. Intellectual: do not hunt the answer in a dropdown.',
          hints: const <String>[
            'f′ is the slope of the line glued to the curve.',
            'Maximum increase means largest positive f′.',
            'For this cubic, look near the left of the local max of f.',
            'f′(x) = 3x² − 3; maximum of f′ on the visible interval is at an endpoint or critical point of f′′.',
          ],
          bottom: const <String>['reset', 'mark', 'readout'],
          environment: 'Mathematics studio',
        );
      case LabDiscipline.computerScience:
        return _Pack(
          title: 'Debug the binary search tree',
          unit: 'Data structures',
          role: 'Software intern',
          mission:
              'The insert routine is wrong. Run it, watch the tree, fix the comparison, retest.',
          scenario: 'Production tests fail on ordered inserts. You have a debugger, not a quiz.',
          objectives: const <String>[
            'Run and observe the broken tree',
            'Inspect node comparisons',
            'Patch the comparison',
            'Re-run the test sequence',
          ],
          knowledge: <String>[topic, 'BST invariant: left < node < right'],
          tools: const <String>['Editor', 'Run tests', 'Inspect node'],
          materials: const <String>['Failing insert sequence'],
          layers: const <String>['Tree', 'Call stack', 'Tests'],
          safety: 'Do not ship an unbalanced lie as a balanced tree.',
          hints: const <String>[
            'Watch which child a duplicate or ordered key takes.',
            'The bug is a reversed comparison.',
            'Left must be strictly less.',
            'Toggle the comparator and rerun 5, 3, 7, 2, 4.',
          ],
          bottom: const <String>['run', 'step', 'reset', 'patch'],
          environment: 'Development environment',
        );
      case LabDiscipline.engineering:
        return _Pack(
          title: 'Structural load test',
          unit: 'Statics',
          role: 'Junior structural engineer',
          mission:
              'Place members, apply load, watch where the structure fails, redesign under budget.',
          scenario: 'Span required. Budget and mass are limited. The model will crack where you are weak.',
          objectives: const <String>[
            'Assemble a spanning structure',
            'Apply test load',
            'Read failure location',
            'Redesign',
          ],
          knowledge: <String>[topic, 'Load path', 'Tension vs compression'],
          tools: const <String>['Beam', 'Support', 'Load', 'Budget'],
          materials: const <String>['Steel members', 'Pins'],
          layers: const <String>['Members', 'Stress', 'Supports'],
          safety: 'A failed model on screen is a collapsed bridge in the field. Redesign.',
          hints: const <String>[
            'Triangles are not optional.',
            'Watch the reddest member.',
            'Supports at both abutments.',
            'Add a diagonal under the load.',
          ],
          bottom: const <String>['place', 'load', 'reset'],
          environment: 'Structures lab',
        );
      case LabDiscipline.medicine:
      case LabDiscipline.nursing:
        return _Pack(
          title: 'Clinical assessment — chest discomfort',
          unit: 'Acute care',
          role: d == LabDiscipline.nursing
              ? 'Student nurse'
              : 'Junior clinician',
          mission:
              'You have a patient, not a normal-range trivia card. Assess, prioritize, interpret, call for help.',
          scenario:
              'Bay 3. 54-year-old man holding his chest. The monitor will move if you stall.',
          objectives: const <String>[
            'Inspect and obtain vitals',
            'Place ECG leads on the model',
            'Take a focused history by talking to the patient',
            'Prioritize and document',
          ],
          knowledge: <String>[topic, 'ABC', 'ACS red flags'],
          tools: const <String>['Hands', 'Cuff', 'Stethoscope', 'ECG', 'Chart'],
          materials: const <String>['Monitor', 'Leads'],
          layers: const <String>['Patient', 'Monitor', 'Leads'],
          safety: 'Skipped vitals or ECG will pause the case.',
          hints: const <String>[
            'Look at the patient first.',
            'Numbers change the next ten minutes.',
            'Radiation + diaphoresis is a pattern.',
            'Leads on, then call — not the reverse.',
          ],
          bottom: const <String>['inspect', 'vitals', 'ecg', 'ask', 'record'],
          environment: 'Emergency department bay',
        );
      case LabDiscipline.economics:
        return _Pack(
          title: 'Policy unit',
          unit: 'Macroeconomics',
          role: 'Policy analyst',
          mission:
              'Inflation is 8.2%. Move the instruments. Watch the model. Explain the tradeoff.',
          scenario: 'The dashboard is live. There is no free lunch in this model.',
          objectives: const <String>[
            'Read current indicators',
            'Change a policy lever',
            'Observe second-order effects',
            'Write the tradeoff',
          ],
          knowledge: <String>[topic, 'Phillips / IS–LM intuition'],
          tools: const <String>['Rates', 'Spending', 'Tax'],
          materials: const <String>['Macro dashboard'],
          layers: const <String>['Inflation', 'Unemployment', 'GDP'],
          safety: 'Policy errors hurt households in the model. Own them.',
          hints: const <String>[
            'Raising rates cools inflation with a lag and a job cost.',
            'Spending works the other way.',
            'Watch unemployment when you fight 8.2%.',
            'Write the tradeoff in the notebook — the graph is not the essay.',
          ],
          bottom: const <String>['adjust', 'simulate', 'reset'],
          environment: 'Treasury policy room',
        );
      case LabDiscipline.finance:
        return _Pack(
          title: 'Markets desk — portfolio shock',
          unit: 'Investments',
          role: 'Junior portfolio analyst',
          mission:
              'Allocate \$1,000,000 to a moderate-risk client. Then survive a shock and rebalance.',
          scenario: 'Live blotter. A shock is coming whether you are ready or not.',
          objectives: const <String>[
            'Allocate across asset classes',
            'Read risk/return',
            'Respond to the shock',
            'Justify the rebalance',
          ],
          knowledge: <String>[topic, 'Diversification', 'Duration / beta intuition'],
          tools: const <String>['Allocation', 'Blotter', 'Shock'],
          materials: const <String>['Client IPS'],
          layers: const <String>['Equities', 'Bonds', 'Cash'],
          safety: 'Do not concentrate 100% in one name for a moderate client.',
          hints: const <String>[
            'Moderate ≠ all cash and ≠ all equity.',
            'Watch volatility after you lock weights.',
            'Shock hits equities first in this scenario.',
            'Rebalance toward the IPS, not yesterday’s winners.',
          ],
          bottom: const <String>['allocate', 'shock', 'rebalance'],
          environment: 'Markets desk',
        );
      case LabDiscipline.accounting:
        return _Pack(
          title: 'Audit investigation',
          unit: 'Financial accounting',
          role: 'Staff auditor',
          mission:
              'The statements do not tie. Trace source documents to the ledger and correct the treatment.',
          scenario: 'A \$48,000 discrepancy sits between revenue and cash. Find it.',
          objectives: const <String>[
            'Open source documents',
            'Trace journal lines',
            'Identify the break',
            'Post the correcting idea',
          ],
          knowledge: <String>[topic, 'Debits and credits', 'Revenue recognition'],
          tools: const <String>['Invoice', 'Journal', 'Flag cutoff'],
          materials: const <String>['Invoices', 'Bank rec', 'TB'],
          layers: const <String>['TB', 'Journals', 'Docs'],
          safety: 'Do not overwrite the original entry — document the correction.',
          hints: const <String>[
            'Start at the trial balance difference.',
            'December invoice dated next year is a classic.',
            'Cash in bank rec but revenue in this year.',
            'Cutoff is the issue.',
          ],
          bottom: const <String>['open', 'trace', 'flag'],
          environment: 'Audit war room',
        );
      case LabDiscipline.business:
        return _Pack(
          title: 'Company HQ',
          unit: 'Firm performance',
          role: 'Junior business analyst',
          mission: 'Revenue is down 18%. Disaggregate until you have a mechanism, then choose.',
          scenario: 'The CEO wants a cause by Friday. Company averages are a disguise.',
          objectives: const <String>[
            'Open operational dashboards',
            'Drill region then product',
            'Read complaints against the price date',
            'Commit a strategy and see the projection',
          ],
          knowledge: <String>[topic, 'Disaggregation'],
          tools: const <String>['Dashboards', 'Drill', 'Strategy'],
          materials: const <String>['P&L', 'CRM extract'],
          layers: const <String>['Company', 'Region', 'Product'],
          safety: 'Briefing a percentage without a mechanism is malpractice here.',
          hints: const <String>[
            'Region before product.',
            'Region B is the fire.',
            'Product X and a price change.',
            'Forecast the downside of reversing the price.',
          ],
          bottom: const <String>['open', 'drill', 'decide'],
          environment: 'Company HQ · strategy room',
        );
      case LabDiscipline.marketing:
        return _Pack(
          title: 'Agency campaign',
          unit: 'Marketing analytics',
          role: 'Strategist',
          mission:
              'Position, allocate budget across channels, launch, read CAC/ROAS, optimize.',
          scenario: 'Client wants efficient growth, not vanity impressions.',
          objectives: const <String>[
            'Inspect audience and competitors',
            'Allocate spend',
            'Launch and read the dashboard',
            'Reallocate',
          ],
          knowledge: <String>[topic, 'CAC', 'ROAS'],
          tools: const <String>['Channels', 'Budget', 'Launch'],
          materials: const <String>['Brief', 'Competitors'],
          layers: const <String>['Search', 'Social', 'Email'],
          safety: 'Spending the whole budget on one vanity channel will show in CAC.',
          hints: const <String>[
            'Audience before creative.',
            'ROAS punishes spray-and-pray social in this model.',
            'Leave a test slice in search.',
            'Optimize after the first simulated week, not before launch.',
          ],
          bottom: const <String>['allocate', 'launch', 'optimize'],
          environment: 'Agency war room',
        );
      case LabDiscipline.law:
        return _Pack(
          title: 'Trial preparation',
          unit: 'Private law',
          role: 'Junior associate',
          mission:
              'Work the file on the evidence board. Issue-spot, flag admissibility, argue, hear the other side.',
          scenario: 'Complaint, emails, photo, statute, precedent. Defining consideration is not the job.',
          objectives: const <String>[
            'Open every exhibit',
            'Pin issues on the board',
            'Flag the photograph',
            'Deliver an argument in the hearing box',
          ],
          knowledge: <String>[topic, 'IRAC', 'Integration / parol evidence'],
          tools: const <String>['Exhibits', 'Pins', 'Hearing'],
          materials: const <String>['Complaint', 'Contract', 'Photo', 'Statute'],
          layers: const <String>['Facts', 'Rules', 'Evidence'],
          safety: 'Do not offer a photograph only because it inflames.',
          hints: const <String>[
            'Read the integration clause.',
            'March 3 oral modification is the fight.',
            'Photograph: condition vs prejudice.',
            'Argue the writing; expect the conversation.',
          ],
          bottom: const <String>['open', 'pin', 'argue'],
          environment: 'War room → hearing',
        );
      case LabDiscipline.psychology:
        return _Pack(
          title: 'Memory experiment',
          unit: 'Cognitive methods',
          role: 'Research assistant',
          mission:
              'Run simulated participants, collect reaction data, and decide whether the hypothesis holds.',
          scenario: 'You hypothesized delay hurts recall. The machine will not flatter you.',
          objectives: const <String>[
            'Set IV (delay)',
            'Run a sample',
            'Inspect the distribution',
            'Conclude with uncertainty',
          ],
          knowledge: <String>[topic, 'IV/DV', 'Noise in human data'],
          tools: const <String>['Delay', 'Run', 'Histogram'],
          materials: const <String>['Simulated N'],
          layers: const <String>['Trials', 'Histogram'],
          safety: 'N=3 is not a result.',
          hints: const <String>[
            'Increase N.',
            'Compare short vs long delay means.',
            'Overlap does not kill an effect by itself.',
            'Report effect direction and scatter, not a p-hack.',
          ],
          bottom: const <String>['run', 'reset', 'graph'],
          environment: 'Cognitive lab',
        );
      case LabDiscipline.history:
        return _Pack(
          title: 'Historical investigation',
          unit: 'Historical method',
          role: 'Junior historian',
          mission:
              'Incomplete file. Build a timeline from primary sources and say what the evidence actually supports.',
          scenario: 'Conflicting letters. A map. A speech. Dates are not the assignment.',
          objectives: const <String>[
            'Inspect sources on the map',
            'Place events on the timeline',
            'Note contradictions',
            'Write a supported claim',
          ],
          knowledge: <String>[topic, 'Primary vs secondary', 'Corroboration'],
          tools: const <String>['Map', 'Timeline', 'Sources'],
          materials: const <String>['Letters', 'Dispatch', 'Map'],
          layers: const <String>['Borders', 'Sources', 'Timeline'],
          safety: 'Do not claim more than the documents will carry.',
          hints: const <String>[
            'Who wrote it, when, why.',
            'Two letters disagree on the same morning.',
            'The map is later — treat anachronism.',
            'Your claim must name its sources.',
          ],
          bottom: const <String>['inspect', 'pin time', 'claim'],
          environment: 'Archives studio',
        );
      case LabDiscipline.geography:
        return _Pack(
          title: 'Spatial analysis',
          unit: 'Human–environment',
          role: 'GIS analyst intern',
          mission:
              'Toggle map layers. Compare climate, population, and land use. Answer a spatial question with the map, not a slogan.',
          scenario: 'Why did the drought hit this basin harder? The layers are the data.',
          objectives: const <String>[
            'Pan and zoom the basin',
            'Toggle climate / population / land use',
            'Compare two regions',
            'Write a spatial claim',
          ],
          knowledge: <String>[topic, 'Layer thought', 'Scale'],
          tools: const <String>['Pan', 'Zoom', 'Layers'],
          materials: const <String>['Climate grid', 'Census', 'Land cover'],
          layers: const <String>['Climate', 'Population', 'Land use', 'Hydrology'],
          safety: 'A single layer is propaganda. Use at least two.',
          hints: const <String>[
            'Hydrology first.',
            'Population sits on former wetlands.',
            'Land use intensified demand.',
            'The claim is conjunctive: climate × use.',
          ],
          bottom: const <String>['layer', 'compare', 'record'],
          environment: 'GIS studio',
        );
      case LabDiscipline.architecture:
        return _Pack(
          title: 'Design under constraints',
          unit: 'Building design',
          role: 'Design intern',
          mission:
              'Orbit the massing, inspect floors, change material and sunlight, then meet a brief: shade the south wall without killing winter light.',
          scenario: 'Client brief on the board. The model is the argument.',
          objectives: const <String>[
            'Orbit and section the building',
            'Study sunlight',
            'Change material / overhang',
            'Defend the brief',
          ],
          knowledge: <String>[topic, 'Path of sun', 'Thermal mass intuition'],
          tools: const <String>['Orbit', 'Floor', 'Sun', 'Material'],
          materials: const <String>['Massing model'],
          layers: const <String>['Mass', 'Floors', 'Sun'],
          safety: 'A pretty render that overheats is a failed lab.',
          hints: const <String>[
            'South wants a calculated overhang.',
            'Glass is not free light.',
            'Move the sun slider through a day.',
            'Record before/after heat load on the inspector.',
          ],
          bottom: const <String>['orbit', 'sun', 'material'],
          environment: 'Design studio',
        );
      case LabDiscipline.careerPractice:
        return _Pack(
          title: 'Workplace practice — $topic',
          unit: 'Career and Life Skills',
          role: 'Practitioner on a live desk',
          mission:
              'A real professional task is on the desk. Inspect the artifacts, make a call, and defend it. There is no lecture to recite.',
          scenario:
              'You were hired to do the work, not to answer trivia about the work. The environment will remember what you skip.',
          objectives: const <String>[
            'Inspect the actual artifacts on the desk',
            'Use professional tools in a real sequence',
            'Make a decision the environment can punish or reward',
            'Write why the result holds',
          ],
          knowledge: <String>[topic, 'Outcome language', 'Sequence under pressure'],
          tools: const <String>['Inspect', 'Rewrite', 'Decide', 'Shock'],
          materials: const <String>['Draft', 'Client brief', 'Notebook'],
          layers: const <String>['Brief', 'Artifacts', 'Score'],
          safety: 'A slogan that would fit any job is not a result. Be specific.',
          hints: const <String>[
            'Duties are not achievements — lead with a number.',
            'STAR is Situation, Task, Action, Result in that order.',
            'A shock is a test of the system, not a reason to freeze.',
            'I will walk the next professional move if you spend the last hint.',
          ],
          bottom: const <String>['inspect', 'record', 'decide'],
          environment: 'Workplace desk',
        );
    }
  }
}
