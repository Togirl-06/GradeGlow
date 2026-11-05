import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';

// School of Business & Economics: eight specialist units, each with its own
// professional exercise (journal entries, NPV, elasticity, unit economics,
// segmentation, HR casework, FX exposure, operations decisions).

const List<SkillDef> _skills = <SkillDef>[
  SkillDef('bz_acct', 'Financial accounting'),
  SkillDef('bz_fin', 'Corporate finance'),
  SkillDef('bz_econ', 'Economic analysis'),
  SkillDef('bz_strategy', 'Strategy & entrepreneurship'),
  SkillDef('bz_mkt', 'Marketing'),
  SkillDef('bz_people', 'People management'),
  SkillDef('bz_intl', 'International trade'),
  SkillDef('bz_ops', 'Business administration'),
];

const LedgerTaskSpec _ledger = LedgerTaskSpec(
  id: 'ledger',
  title: 'Journalise the first week',
  brief: 'Record each transaction for Bloom Florists as a journal entry: one debit account, one credit account, amount.',
  skills: <String>['bz_acct'],
  accounts: <String>[
    'Cash', 'Accounts receivable', 'Equipment', 'Accounts payable', 'Owner\'s capital', 'Sales revenue',
    'Rent expense', 'Wages expense',
  ],
  transactions: <LedgerTransaction>[
    LedgerTransaction('Owner invests £20,000 cash in the business', 'Cash', 'Owner\'s capital', 20000),
    LedgerTransaction('Buys a refrigerated display on credit for £5,000', 'Equipment', 'Accounts payable', 5000),
    LedgerTransaction('Sells wedding flowers on credit for £3,200', 'Accounts receivable', 'Sales revenue', 3200),
    LedgerTransaction('Pays the month\'s rent of £1,200 in cash', 'Rent expense', 'Cash', 1200),
    LedgerTransaction('Wedding customer pays £2,000 of the amount owed', 'Cash', 'Accounts receivable', 2000),
  ],
);

const NumericTaskSpec _npv = NumericTaskSpec(
  id: 'npv',
  title: 'Appraise the delivery van',
  brief: 'A £10,000 van saves £4,000 a year for three years. The cost of capital is 8%.',
  skills: <String>['bz_fin'],
  givens: <Fact>[
    Fact('Initial investment', '£10,000 at year 0'),
    Fact('Cash inflows', '£4,000 at the end of years 1, 2 and 3'),
    Fact('Discount rate', '8%'),
  ],
  parts: <NumericPart>[
    NumericPart('Present value of the inflows', 10308.39, unit: '£', relTol: 0.002, method: 'Discount each inflow by (1.08)^t and add.'),
    NumericPart('Net present value', 308.39, unit: '£', relTol: 0.01, method: 'PV of inflows − initial investment.'),
    NumericPart('Simple payback period', 2.5, unit: 'years', method: 'Years until cumulative inflows equal the investment.'),
  ],
);

const NumericTaskSpec _elasticity = NumericTaskSpec(
  id: 'elasticity',
  title: 'Price change at the campus café',
  brief: 'Coffee rises from £2.00 to £2.20 and weekly sales fall from 1,000 to 850 cups. Use percentage change from the original values.',
  skills: <String>['bz_econ'],
  givens: <Fact>[
    Fact('Price', '£2.00 → £2.20'),
    Fact('Quantity', '1,000 → 850 cups per week'),
  ],
  parts: <NumericPart>[
    NumericPart('Price elasticity of demand', -1.5, method: '% change in quantity ÷ % change in price.'),
    NumericPart('Weekly revenue before', 2000, unit: '£', method: 'Price × quantity.'),
    NumericPart('Change in weekly revenue', -130, unit: '£', method: 'New revenue − old revenue.'),
  ],
);

const NumericTaskSpec _unitEcon = NumericTaskSpec(
  id: 'unit_econ',
  title: 'Subscription box unit economics',
  brief: 'A start-up sells a £25 box with £10 of variable cost and £6,000 of fixed costs per month. Customers buy four boxes on average; acquiring one costs £30.',
  skills: <String>['bz_strategy'],
  givens: <Fact>[
    Fact('Price / variable cost', '£25 / £10 per box'),
    Fact('Fixed costs', '£6,000 per month'),
    Fact('Boxes per customer', '4'),
    Fact('Customer acquisition cost', '£30'),
  ],
  parts: <NumericPart>[
    NumericPart('Contribution per box', 15, unit: '£', method: 'Price − variable cost.'),
    NumericPart('Break-even boxes per month', 400, method: 'Fixed costs ÷ contribution per box.'),
    NumericPart('Lifetime contribution per customer', 60, unit: '£', method: 'Contribution × boxes per customer.'),
    NumericPart('LTV : CAC ratio', 2, method: 'Lifetime contribution ÷ acquisition cost.'),
  ],
);

const NumericTaskSpec _fx = NumericTaskSpec(
  id: 'fx',
  title: 'Euro invoice exposure',
  brief: 'A UK importer owes a German supplier €50,000 in 90 days.',
  skills: <String>['bz_intl'],
  givens: <Fact>[
    Fact('Spot today', '£1 = €1.16'),
    Fact('Spot in 90 days (scenario)', '£1 = €1.10'),
  ],
  parts: <NumericPart>[
    NumericPart('Cost in pounds at today\'s rate', 43103.45, unit: '£', relTol: 0.001, method: 'Euros ÷ euros per pound.'),
    NumericPart('Cost in pounds at the 90-day rate', 45454.55, unit: '£', relTol: 0.001, method: 'Euros ÷ new rate.'),
    NumericPart('Extra cost if unhedged', 2351.10, unit: '£', relTol: 0.005, method: 'Difference between the two.'),
  ],
);

const DecisionTaskSpec _grievance = DecisionTaskSpec(
  id: 'grievance',
  title: 'Grievance: a complaint about a manager',
  brief: 'You are the HR advisor. Handle the case at each stage.',
  setting: 'Lumen Retail, store 14. Aisha, a sales assistant, emails HR saying her manager shouts at her in front of customers and changed her shifts after she complained.',
  skills: <String>['bz_people'],
  facts: <Fact>[Fact('Policy', 'Grievance and dignity-at-work policies'), Fact('Employee', '2 years\' service')],
  steps: <DecisionStep>[
    DecisionStep('First response?', <DecisionOption>[
      DecisionOption('Acknowledge in writing, explain the grievance process and offer a meeting within the policy timeframe', 2,
          'A prompt, documented acknowledgement following policy.'),
      DecisionOption('Forward her email to the manager and ask for his side', 0,
          'Shares a confidential complaint with the subject before any process — risks victimisation.', critical: true),
      DecisionOption('Suggest she sorts it out informally with him', 1, 'Informal resolution can be offered, but not imposed for an allegation of bullying.'),
    ]),
    DecisionStep('Her shifts were cut after she complained. What do you do?', <DecisionOption>[
      DecisionOption('Restore her shifts pending investigation and note possible victimisation', 2,
          'Protects her from detriment while the facts are established.'),
      DecisionOption('Leave the rota — it is a management decision', 0, 'Ignores a potential detriment linked to the complaint.'),
    ]),
    DecisionStep('Investigation?', <DecisionOption>[
      DecisionOption('Appoint an impartial investigator, interview Aisha, the manager and witnesses, and keep records', 2,
          'A fair, evidence-based investigation.'),
      DecisionOption('Let the area manager, who is the manager\'s friend, decide', 0, 'Not impartial.'),
      DecisionOption('Only interview Aisha and the manager', 1, 'Witnesses who saw the incidents should be heard.'),
    ]),
  ],
);

const DecisionTaskSpec _supplierDelay = DecisionTaskSpec(
  id: 'supplier_delay',
  title: 'Operations: supplier delay',
  brief: 'You run operations for a 12-store retailer. Decide how to handle a supplier failure.',
  setting: 'Monday 09:00. The packaging supplier will deliver 5 days late. Stores run out on Thursday.',
  skills: <String>['bz_ops'],
  facts: <Fact>[Fact('Stock cover', '3 days'), Fact('Alternative supplier', 'Available at +18% cost')],
  steps: <DecisionStep>[
    DecisionStep('First action?', <DecisionOption>[
      DecisionOption('Quantify the shortfall by store and inform the operations director today', 2,
          'Know the size of the problem and escalate early.'),
      DecisionOption('Wait to see if the supplier recovers', 0, 'Stores run out before the delay ends.'),
    ]),
    DecisionStep('How do you cover the gap?', <DecisionOption>[
      DecisionOption('Buy two days\' cover from the alternative supplier and rebalance stock between stores', 2,
          'Cost-effective: buy only the gap and use existing stock fully.'),
      DecisionOption('Switch all orders permanently to the alternative supplier', 0, 'An 18% permanent cost rise for a one-off delay.'),
      DecisionOption('Buy five days\' cover from the alternative supplier', 1, 'Works, but overspends compared with rebalancing.'),
    ]),
    DecisionStep('Afterwards?', <DecisionOption>[
      DecisionOption('Review the contract\'s service levels and agree a recovery plan with the supplier', 2,
          'Prevents recurrence and uses the contract.'),
      DecisionOption('Nothing — it was a one-off', 0, 'Misses the lesson.'),
    ]),
  ],
);

const ClassifyTaskSpec _segments = ClassifyTaskSpec(
  id: 'segments',
  title: 'Segment the market',
  brief: 'Classify each customer description by segmentation base.',
  skills: <String>['bz_mkt'],
  categories: <String>['Demographic', 'Geographic', 'Psychographic', 'Behavioural'],
  items: <ClassifyItem>[
    ClassifyItem('Students aged 18–24', 'Demographic', 'Age and occupation are demographic.'),
    ClassifyItem('Customers within 5 miles of a store', 'Geographic', 'Location-based.'),
    ClassifyItem('People who value sustainability and ethical sourcing', 'Psychographic', 'Values and lifestyle.'),
    ClassifyItem('Customers who bought twice in the last month', 'Behavioural', 'Purchase behaviour.'),
    ClassifyItem('Loyalty-card members who only buy on discount days', 'Behavioural', 'Response to promotions is behavioural.'),
  ],
);

const ClassifyTaskSpec _incoterms = ClassifyTaskSpec(
  id: 'incoterms',
  title: 'Who pays the main freight?',
  brief: 'Under each Incoterm, who pays the main international carriage?',
  skills: <String>['bz_intl'],
  categories: <String>['Buyer', 'Seller'],
  items: <ClassifyItem>[
    ClassifyItem('EXW (Ex Works)', 'Buyer', 'The buyer collects from the seller\'s premises and pays all carriage.'),
    ClassifyItem('FOB (Free On Board)', 'Buyer', 'Seller loads on the vessel; the buyer pays the sea freight.'),
    ClassifyItem('CIF (Cost, Insurance and Freight)', 'Seller', 'Seller pays freight and insurance to the destination port.'),
    ClassifyItem('DDP (Delivered Duty Paid)', 'Seller', 'Seller pays everything to the buyer\'s door, including duty.'),
  ],
);

TrainingModule _mod(String id, String title, String summary, List<String> skills, List<LessonSection> lesson, List<TaskSpec> tasks) =>
    TrainingModule(id: id, title: title, summary: summary, skills: skills, lesson: lesson, practice: tasks);

DeptUnit _unit(String id, String title, String emoji, String setting, TrainingModule m, [List<ProjectSpec> projects = const <ProjectSpec>[]]) =>
    DeptUnit(id: id, title: title, emoji: emoji, setting: setting, modules: <TrainingModule>[m], projects: projects);

final Department business = Department(
  id: 'business',
  title: 'Business & Economics',
  school: 'School of Business & Economics',
  emoji: '📈',
  summary: 'Eight specialist units: accounting, finance, economics, entrepreneurship, marketing, HR, international business and administration.',
  majors: const <String>[
    'business_administration', 'accounting', 'finance', 'economics', 'entrepreneurship', 'marketing',
    'human_resource_management', 'international_business',
  ],
  skills: _skills,
  units: <DeptUnit>[
    _unit('bz_admin', 'Business Administration', '🗂️', 'Operations control room with a supplier dashboard.',
        _mod('bz_m_admin', 'Operations decisions', 'Handle disruptions with data and escalation.', const <String>['bz_ops'],
            const <LessonSection>[
          LessonSection('Quantify, escalate, act', 'Measure the gap, tell the people who need to know, then choose the cheapest action that closes it.'),
          LessonSection('Contracts and service levels', 'Supplier contracts define service levels and remedies. Use them after the crisis.'),
        ], const <TaskSpec>[_supplierDelay])),
    _unit('bz_acct', 'Accounting', '📒', 'Finance office with the general ledger and source documents.',
        _mod('bz_m_acct', 'Double-entry bookkeeping', 'Record transactions so the books always balance.', const <String>['bz_acct'],
            const <LessonSection>[
          LessonSection('Debits and credits', 'Every transaction has equal debits and credits. Assets and expenses increase with a debit; liabilities, equity and revenue increase with a credit.'),
          LessonSection('Reading source documents', 'Ask two questions: what did the business receive, and what did it give up? Cash sales debit Cash; credit sales debit Accounts receivable.'),
        ], const <TaskSpec>[_ledger])),
    _unit('bz_fin', 'Finance', '💰', 'Corporate finance desk with a discounting model.',
        _mod('bz_m_fin', 'Investment appraisal', 'Decide whether an investment creates value.', const <String>['bz_fin'],
            const <LessonSection>[
          LessonSection('Time value of money', 'PV = CF ÷ (1 + r)^t. A pound today is worth more than a pound next year.'),
          LessonSection('NPV and payback', 'Accept projects with positive NPV. Payback is simple and ignores timing beyond the payback point.'),
        ], const <TaskSpec>[_npv])),
    _unit('bz_econ', 'Economics', '📉', 'Economics research unit with sales data from campus outlets.',
        _mod('bz_m_econ', 'Elasticity and pricing', 'Predict how revenue responds to a price change.', const <String>['bz_econ'],
            const <LessonSection>[
          LessonSection('Price elasticity of demand', 'PED = % change in quantity ÷ % change in price. |PED| > 1 is elastic: raising price lowers revenue.'),
        ], const <TaskSpec>[_elasticity])),
    _unit('bz_ent', 'Entrepreneurship', '🚀', 'Start-up incubator with a unit-economics model.',
        _mod('bz_m_ent', 'Unit economics', 'Break-even and customer value for a new venture.', const <String>['bz_strategy'],
            const <LessonSection>[
          LessonSection('Contribution and break-even', 'Contribution = price − variable cost. Break-even units = fixed costs ÷ contribution.'),
          LessonSection('LTV and CAC', 'Lifetime value should be well above acquisition cost; investors often look for at least 3:1.'),
        ], const <TaskSpec>[_unitEcon]),
        <ProjectSpec>[
          ProjectSpec(
            id: 'bz_p1',
            title: 'Business case: campus coffee cart',
            brief: 'Build the numbers and the recommendation for a campus coffee cart.',
            requiresModules: const <String>['bz_m_ent', 'bz_m_fin'],
            skills: const <String>['bz_strategy', 'bz_fin'],
            deliverables: const <TaskSpec>[_unitEcon, _npv],
            writeUp: const WrittenTaskSpec(
              id: 'case_memo',
              title: 'Recommendation memo',
              brief: 'Write the recommendation to the investment committee.',
              minWords: 100,
              rubric: <Concept>[
                Concept('rec', 'Clear recommendation', <String>['recommend*', 'should', 'proceed', 'invest']),
                Concept('numbers', 'Uses the numbers', <String>['npv', 'break even', 'break-even', 'contribution', 'ltv', 'payback']),
                Concept('risk', 'Risks', <String>['risk*', 'sensitiv*', 'assum*', 'uncertain*']),
                Concept('next', 'Next steps', <String>['next step*', 'pilot', 'trial', 'test']),
              ],
            ),
          ),
        ]),
    _unit('bz_mkt', 'Marketing', '📣', 'Marketing studio with customer data and a campaign board.',
        _mod('bz_m_mkt', 'Segmentation and targeting', 'Divide a market into segments you can reach.', const <String>['bz_mkt'],
            const <LessonSection>[
          LessonSection('Bases for segmentation', 'Demographic (age, income), geographic (location), psychographic (values, lifestyle) and behavioural (usage, loyalty, response to offers).'),
        ], const <TaskSpec>[_segments])),
    _unit('bz_hr', 'Human Resources', '👥', 'HR advisory desk with policies and case files.',
        _mod('bz_m_hr', 'Employee relations casework', 'Handle grievances fairly and lawfully.', const <String>['bz_people'],
            const <LessonSection>[
          LessonSection('Fair process', 'Acknowledge promptly, follow the policy, investigate impartially, keep records, and protect the complainant from detriment.'),
        ], const <TaskSpec>[_grievance])),
    _unit('bz_intl', 'International Business', '🌍', 'Trade desk with FX rates and shipping documents.',
        _mod('bz_m_intl', 'Currency risk and Incoterms', 'Quantify FX exposure and allocate shipping responsibilities.', const <String>['bz_intl'],
            const <LessonSection>[
          LessonSection('Transaction exposure', 'A foreign-currency payable costs more if your currency weakens before you pay. Hedging (e.g. a forward contract) fixes the rate.'),
          LessonSection('Incoterms', 'Standard terms that say who pays carriage, insurance and duty, and where risk passes.'),
        ], const <TaskSpec>[_fx, _incoterms])),
  ],
  certifications: const <Certification>[
    Certification(
      id: 'bz_cert_acct',
      title: 'Financial Accounting Certificate',
      issuer: 'GradeGlow School of Business',
      requiresModules: <String>['bz_m_acct'],
      tasks: <TaskSpec>[_ledger, _npv],
    ),
    Certification(
      id: 'bz_cert_analysis',
      title: 'Business Analysis Certificate',
      issuer: 'GradeGlow School of Business',
      requiresModules: <String>['bz_m_econ', 'bz_m_ent'],
      tasks: <TaskSpec>[_elasticity, _unitEcon, _segments],
    ),
  ],
);

const CompanyProfile _carver = CompanyProfile(
  name: 'Carver & Holt',
  industry: 'Audit and accounting firm',
  about: 'A mid-sized firm auditing and keeping the books for 900 small and medium businesses.',
  team: 'Interns join an audit team of a manager, a senior and two associates.',
  training: 'Paid professional qualification (ACA/ACCA) with study leave and a counselling manager.',
  culture: 'Professional scepticism, accuracy and clear working papers.',
  success: 'Accurate entries and reconciliations, documented so a reviewer can follow them.',
  tools: 'Cloud accounting software, audit working-paper software and spreadsheets.',
  nextSteps: 'We confirm decisions within two working days.',
);

const CompanyProfile _lumen = CompanyProfile(
  name: 'Lumen Retail Group',
  industry: 'Retail',
  about: 'A 140-store homewares retailer.',
  team: 'Graduate analysts sit in the Commercial Insight team of eight analysts and a head of insight.',
  training: 'A two-year graduate programme with rotations through finance, operations and marketing.',
  culture: 'Decisions backed by numbers; analysts present directly to directors.',
  success: 'Clear analyses with a recommendation, delivered on time.',
  tools: 'Spreadsheets, a BI dashboard and the sales data warehouse.',
  nextSteps: 'Decisions are confirmed within two working days.',
);

const List<JobPosting> businessPostings = <JobPosting>[
  JobPosting(
    id: 'bz_intern_carver',
    deptId: 'business',
    company: _carver,
    title: 'Audit & Accounting Intern',
    type: JobType.internship,
    stageOnHire: CareerStage.intern,
    description: 'A summer internship preparing books and audit working papers.',
    responsibilities: <String>['Post journal entries', 'Prepare reconciliations', 'Support audit testing'],
    qualifications: <String>['Business student with Trainee status', 'Bookkeeping training'],
    experience: 'None required.',
    requirements: JobRequirements(
      modules: <String>['bz_m_acct', 'bz_m_fin'],
      skills: <String, int>{'bz_acct': 1, 'bz_fin': 1},
      projects: 0,
      minStage: CareerStage.trainee,
    ),
    salaryMin: 2000,
    salaryMax: 2300,
    salaryPeriod: 'month',
    location: 'Hybrid · Birmingham',
    openDay: 1,
    deadlineDay: 40,
    interviewPlanId: 'bz_iv',
    workplaceId: 'bz_carver',
  ),
  JobPosting(
    id: 'bz_grad_carver',
    deptId: 'business',
    company: _carver,
    title: 'Graduate Accountant',
    type: JobType.graduate,
    stageOnHire: CareerStage.entryLevel,
    description: 'A training contract towards chartered accountancy.',
    responsibilities: <String>['Prepare accounts', 'Perform audit tests', 'Write working papers'],
    qualifications: <String>['Completed internship', 'Financial Accounting Certificate'],
    experience: 'A completed accounting internship.',
    requirements: JobRequirements(
      modules: <String>['bz_m_acct', 'bz_m_fin', 'bz_m_econ'],
      skills: <String, int>{'bz_acct': 2, 'bz_fin': 1},
      projects: 0,
      minStage: CareerStage.intern,
      certifications: <String>['bz_cert_acct'],
      completedInternship: true,
    ),
    salaryMin: 28000,
    salaryMax: 32000,
    location: 'Hybrid · Birmingham',
    openDay: 1,
    deadlineDay: 55,
    interviewPlanId: 'bz_iv',
    workplaceId: 'bz_carver',
  ),
  JobPosting(
    id: 'bz_analyst_lumen',
    deptId: 'business',
    company: _lumen,
    title: 'Graduate Business Analyst',
    type: JobType.graduate,
    stageOnHire: CareerStage.entryLevel,
    description: 'Analyse pricing, promotions and new ventures for the commercial team.',
    responsibilities: <String>['Build business cases', 'Analyse pricing and demand', 'Present recommendations'],
    qualifications: <String>['Business Analysis Certificate', 'Business case portfolio'],
    experience: 'Internship preferred.',
    requirements: JobRequirements(
      modules: <String>['bz_m_econ', 'bz_m_ent', 'bz_m_fin', 'bz_m_mkt'],
      skills: <String, int>{'bz_econ': 1, 'bz_strategy': 1, 'bz_fin': 1},
      projects: 1,
      minStage: CareerStage.trainee,
      certifications: <String>['bz_cert_analysis'],
    ),
    salaryMin: 30000,
    salaryMax: 35000,
    location: 'On-site · Leeds',
    openDay: 1,
    deadlineDay: 50,
    interviewPlanId: 'bz_iv',
    workplaceId: 'bz_lumen',
    shortlistMark: 70,
  ),
];

const InterviewPlan businessInterview = InterviewPlan(
  id: 'bz_iv',
  interviewer: 'Rachel Holt',
  interviewerRole: 'Audit Manager',
  opening: 'Thanks for joining. There\'s a short accounting exercise, an appraisal question and some situational questions.',
  main: <String>['bz_q1', 'bz_ledger', 'bz_q2', 'bz_npv', 'bz_q3', 'bz_q4'],
  bank: <InterviewQuestion>[
    InterviewQuestion(
      id: 'bz_q1',
      prompt: 'Why this firm and this role?',
      competency: Competency.communication,
      minWords: 30,
      rubric: <Concept>[
        Concept('motive', 'Motivation', <String>['because', 'interested', 'motivat*', 'enjoy']),
        Concept('role', 'Understands the role', <String>['audit', 'accounts', 'analys*', 'clients', 'qualification']),
      ],
    ),
    InterviewQuestion(
      id: 'bz_ledger',
      prompt: 'Accounting exercise: journalise these transactions.',
      competency: Competency.technical,
      practical: _ledger,
    ),
    InterviewQuestion(
      id: 'bz_q2',
      prompt: 'The trial balance does not balance by £900. How do you find the error?',
      competency: Competency.problemSolving,
      minWords: 30,
      probeId: 'bz_q2p',
      rubric: <Concept>[
        Concept('half', 'Look for a £450 one-sided/reversed entry', <String>['450', 'half', 'divide by 2', 'wrong side']),
        Concept('nine', 'Divisible by 9 → transposition', <String>['divisible by 9', 'transpos*', 'nine']),
        Concept('trace', 'Trace postings to the ledger', <String>['trace', 'check postings', 'ledger', 'recompute', 'reconcil*']),
      ],
    ),
    InterviewQuestion(
      id: 'bz_q2p',
      prompt: 'Why does the difference being divisible by nine matter?',
      competency: Competency.technical,
      minWords: 15,
      rubric: <Concept>[
        Concept('transpose', 'Transposition errors', <String>['transpos*', 'digits swapped', 'swapped']),
      ],
    ),
    InterviewQuestion(
      id: 'bz_npv',
      prompt: 'Appraisal: should the client buy this van?',
      competency: Competency.problemSolving,
      practical: _npv,
    ),
    InterviewQuestion(
      id: 'bz_q3',
      prompt: 'A client\'s finance director asks you to "not look too closely" at year-end stock. What do you do?',
      competency: Competency.readiness,
      minWords: 30,
      rubric: <Concept>[
        Concept('refuse', 'Maintains independence', <String>['independen*', 'scepticism', 'skepticism', 'cannot', 'refuse']),
        Concept('escalate', 'Escalates to the manager', <String>['manager', 'partner', 'escalat*', 'inform']),
        Concept('document', 'Documents it', <String>['document*', 'record*', 'working paper*']),
      ],
    ),
    InterviewQuestion(
      id: 'bz_q4',
      prompt: 'Which is an asset account?',
      competency: Competency.technical,
      options: <String>['Accounts payable', 'Sales revenue', 'Accounts receivable', 'Owner\'s capital'],
      correctOption: 2,
    ),
  ],
);

const List<AssignmentSpec> _carverAssignments = <AssignmentSpec>[
  AssignmentSpec(
    id: 'bz_a1',
    title: 'Client: Bloom Florists — first-week journal',
    ticket: 'Post the opening week\'s transactions from the client\'s documents.',
    acceptance: <String>['Every entry correct', 'Handoff note for the reviewer'],
    task: _ledger,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'bz_a2',
    title: 'Client: Hart Bakery — van appraisal',
    ticket: 'The client wants to know if the delivery van pays for itself.',
    acceptance: <String>['NPV and payback within tolerance'],
    task: _npv,
  ),
  AssignmentSpec(
    id: 'bz_a3',
    title: 'Client: Rhine Imports — FX exposure',
    ticket: 'Quantify the euro invoice exposure for the client meeting.',
    acceptance: <String>['Exposure within tolerance'],
    task: _fx,
  ),
  AssignmentSpec(
    id: 'bz_a4',
    title: 'Client: Coastline Café — pricing',
    ticket: 'They raised prices; analyse the effect on revenue.',
    acceptance: <String>['Elasticity and revenue correct'],
    task: _elasticity,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'bz_a5',
    title: 'Client: Boxly — break-even',
    ticket: 'The start-up client needs its break-even and LTV:CAC for investors.',
    acceptance: <String>['All values within tolerance'],
    task: _unitEcon,
  ),
  AssignmentSpec(
    id: 'bz_lead1',
    title: 'Plan the year-end audit',
    ticket: 'You are the senior on the Bloom Florists audit. Write the audit plan for the team.',
    acceptance: <String>['Risk areas, team allocation, timetable, review'],
    leadership: true,
    deadlineDays: 3,
    task: WrittenTaskSpec(
      id: 'audit_plan',
      title: 'Audit plan',
      brief: 'Write the plan.',
      minWords: 90,
      rubric: <Concept>[
        Concept('risk', 'Risk areas', <String>['risk*', 'material*', 'stock', 'revenue']),
        Concept('team', 'Team allocation', <String>['allocat*', 'associate*', 'team', 'assign*']),
        Concept('time', 'Timetable', <String>['timetable', 'deadline*', 'week*', 'by']),
        Concept('review', 'Review process', <String>['review*', 'sign off', 'manager']),
      ],
    ),
  ),
];

const List<AssignmentSpec> _lumenAssignments = <AssignmentSpec>[
  AssignmentSpec(
    id: 'bz_l1',
    title: 'Pricing review · café concessions',
    ticket: 'Assess last month\'s coffee price rise.',
    acceptance: <String>['Elasticity and revenue correct'],
    task: _elasticity,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'bz_l2',
    title: 'Segmentation · loyalty relaunch',
    ticket: 'Classify the customer groups proposed for the loyalty relaunch.',
    acceptance: <String>['Every segment classified correctly'],
    task: _segments,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'bz_l3',
    title: 'Supplier disruption',
    ticket: 'Packaging is late. Recommend the response.',
    acceptance: <String>['Sound decisions'],
    task: _supplierDelay,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'bz_l4',
    title: 'Venture case · subscription boxes',
    ticket: 'Run the unit economics for the new subscription venture.',
    acceptance: <String>['All values within tolerance'],
    task: _unitEcon,
  ),
  AssignmentSpec(
    id: 'bz_l5',
    title: 'Store 14 grievance',
    ticket: 'HR is short-staffed; handle the grievance with the HR business partner.',
    acceptance: <String>['Fair, lawful process'],
    task: _grievance,
  ),
  AssignmentSpec(
    id: 'bz_lead2',
    title: 'Lead the quarterly insight review',
    ticket: 'Plan the quarterly insight review with three analysts.',
    acceptance: <String>['Objectives, allocation, timeline, quality review'],
    leadership: true,
    deadlineDays: 3,
    task: WrittenTaskSpec(
      id: 'insight_plan',
      title: 'Review plan',
      brief: 'Write the plan.',
      minWords: 90,
      rubric: <Concept>[
        Concept('obj', 'Objectives', <String>['objective*', 'question*', 'purpose']),
        Concept('alloc', 'Allocation', <String>['allocat*', 'analyst*', 'assign*']),
        Concept('time', 'Timeline', <String>['timeline', 'deadline*', 'week*']),
        Concept('qa', 'Quality review', <String>['review*', 'check*', 'peer']),
      ],
    ),
  ),
];

const List<WorkplaceDef> businessWorkplaces = <WorkplaceDef>[
  WorkplaceDef(
    id: 'bz_carver',
    deptId: 'business',
    name: 'Carver & Holt — Audit & Accounts team',
    environment: 'Client files arrive by portal; every working paper is reviewed by a senior before sign-off.',
    supervisor: 'Rachel Holt',
    supervisorRole: 'Audit Manager',
    tools: <String>['Cloud accounting software', 'Working-paper software', 'Spreadsheets'],
    assignments: _carverAssignments,
    titles: <CareerStage, String>{
      CareerStage.intern: 'Audit & Accounting Intern',
      CareerStage.entryLevel: 'Graduate Accountant',
      CareerStage.junior: 'Audit Associate',
      CareerStage.experienced: 'Audit Senior',
      CareerStage.senior: 'Assistant Manager',
      CareerStage.lead: 'Audit Manager',
    },
    returnOfferPostingId: 'bz_grad_carver',
  ),
  WorkplaceDef(
    id: 'bz_lumen',
    deptId: 'business',
    name: 'Lumen Retail — Commercial Insight',
    environment: 'Head office insight team; weekly trading meeting; analyses presented to directors.',
    supervisor: 'Owen Price',
    supervisorRole: 'Head of Commercial Insight',
    tools: <String>['Spreadsheets', 'BI dashboard', 'Sales data warehouse'],
    assignments: _lumenAssignments,
    titles: <CareerStage, String>{
      CareerStage.entryLevel: 'Graduate Business Analyst',
      CareerStage.junior: 'Business Analyst',
      CareerStage.experienced: 'Senior Analyst',
      CareerStage.senior: 'Insight Manager',
      CareerStage.lead: 'Head of Insight',
    },
  ),
];
