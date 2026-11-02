/// The six professions in GradeGlow Life and their rank ladders.
library;

/// Intern → Junior → Employee → Senior → Team Lead → Manager → Director.
const int kTopRank = 6;

class CareerDef {
  const CareerDef({
    required this.id,
    required this.title,
    required this.emoji,
    required this.degreeId,
    required this.minEducationRank,
    required this.internEducationRank,
    required this.coreSkill,
    required this.salaryMultiplier,
    required this.rankTitles,
    required this.pitch,
    required this.dayInLife,
    required this.employerExpectations,
    required this.interviewKeywords,
    required this.certifications,
    required this.workplaceName,
  });

  final String id;
  final String title;
  final String emoji;

  /// Degree that unlocks this career (see UniversityCatalog).
  final String degreeId;

  /// Education rank (0 high school … 4 doctorate) for regular roles.
  final int minEducationRank;

  /// Entry (intern) roles accept a lower rank.
  final int internEducationRank;
  final String coreSkill;
  final double salaryMultiplier;

  /// Seven titles, index = rank.
  final List<String> rankTitles;
  final String pitch;
  final List<String> dayInLife;

  /// What recruiters in this field look for — shown by the career assistant.
  final List<String> employerExpectations;

  /// Words that signal domain relevance in interview answers and resumes.
  final List<String> interviewKeywords;

  /// Certification ids that strengthen applications.
  final List<String> certifications;

  /// Interior template used for workplaces of this career.
  final String workplaceName;

  String titleForRank(int rank) => rankTitles[rank.clamp(0, kTopRank)];

  int educationRankFor(int rank) => rank == 0 ? internEducationRank : minEducationRank;
}

class CareerCatalog {
  const CareerCatalog._();

  static const List<CareerDef> all = <CareerDef>[
    CareerDef(
      id: 'software_engineer',
      title: 'Software Engineer',
      emoji: '💻',
      degreeId: 'deg_cs',
      minEducationRank: 2,
      internEducationRank: 1,
      coreSkill: 'programming',
      salaryMultiplier: 1.15,
      rankTitles: <String>[
        'Engineering Intern',
        'Junior Software Engineer',
        'Software Engineer',
        'Senior Software Engineer',
        'Tech Lead',
        'Engineering Manager',
        'Director of Engineering',
      ],
      pitch: 'Build products, fix bugs, review code and ship on deadline.',
      dayInLife: <String>[
        'Daily stand-up with your team',
        'Pick up tickets from your manager',
        'Write and debug code',
        'Review pull requests',
        'Present finished work',
      ],
      employerExpectations: <String>[
        'Solid programming fundamentals (data structures, debugging)',
        'A degree in computer science or a related field',
        'Projects you can explain: what you built, why, and the result',
        'Clear communication with non-engineers',
        'Teamwork: code review, ownership and reliability',
      ],
      interviewKeywords: <String>[
        'code', 'bug', 'test', 'algorithm', 'debug', 'deploy', 'review', 'team',
        'software', 'api', 'database', 'performance', 'git', 'sprint', 'users',
      ],
      certifications: <String>['cert_cloud'],
      workplaceName: 'Tech office',
    ),
    CareerDef(
      id: 'nurse',
      title: 'Nurse',
      emoji: '🩺',
      degreeId: 'deg_nursing',
      minEducationRank: 2,
      internEducationRank: 2,
      coreSkill: 'clinical',
      salaryMultiplier: 1.0,
      rankTitles: <String>[
        'Student Nurse (Intern)',
        'Junior Staff Nurse',
        'Registered Nurse',
        'Senior Nurse',
        'Charge Nurse',
        'Nurse Manager',
        'Director of Nursing',
      ],
      pitch: 'Assess patients, give care safely and speak up for them.',
      dayInLife: <String>[
        'Shift handover and assignments',
        'Check vital signs and review charts',
        'Administer simulated medication safely',
        'Document everything',
        'Escalate to doctors and handle emergencies',
      ],
      employerExpectations: <String>[
        'A nursing degree and a licence-ready clinical mindset',
        'Patient safety first: the five rights of medication',
        'Calm, compassionate communication',
        'Accurate, timely documentation',
        'Knowing when to escalate (SBAR) rather than guess',
      ],
      interviewKeywords: <String>[
        'patient', 'care', 'safety', 'vital', 'medication', 'compassion', 'team',
        'document', 'escalate', 'family', 'shift', 'clinical', 'hospital', 'emergency',
      ],
      certifications: <String>['cert_bls'],
      workplaceName: 'Hospital ward',
    ),
    CareerDef(
      id: 'pharmacist',
      title: 'Pharmacist',
      emoji: '💊',
      degreeId: 'deg_pharmacy',
      minEducationRank: 2,
      internEducationRank: 2,
      coreSkill: 'pharmacy',
      salaryMultiplier: 1.3,
      rankTitles: <String>[
        'Pre-registration Pharmacist (Intern)',
        'Junior Pharmacist',
        'Pharmacist',
        'Senior Pharmacist',
        'Lead Pharmacist',
        'Head of Pharmacy',
        'Chief Pharmacist',
      ],
      pitch: 'Dispense medicines safely, catch errors and advise patients.',
      dayInLife: <String>[
        'Screen and dispense prescriptions',
        'Check doses, allergies and interactions',
        'Counsel patients in plain language',
        'Manage stock and controlled medicines',
        'Work with doctors and nurses to keep patients safe',
      ],
      employerExpectations: <String>[
        'A pharmacy degree and meticulous attention to detail',
        'Safety first: query anything that looks wrong',
        'Clear, kind patient counselling',
        'Honest records and reporting of errors',
        'Respectful teamwork with prescribers',
      ],
      interviewKeywords: <String>[
        'patient', 'safety', 'dose', 'allerg', 'interaction', 'check', 'counsel',
        'prescriber', 'medicine', 'accuracy', 'record', 'team', 'stock', 'error',
      ],
      certifications: <String>['cert_dispensing'],
      workplaceName: 'Hospital pharmacy',
    ),
    CareerDef(
      id: 'doctor',
      title: 'Doctor',
      emoji: '⚕️',
      degreeId: 'deg_medicine',
      minEducationRank: 4,
      internEducationRank: 4,
      coreSkill: 'medicine',
      salaryMultiplier: 1.9,
      rankTitles: <String>[
        'Resident Doctor (Intern)',
        'Junior Doctor',
        'Doctor',
        'Senior Doctor',
        'Chief Resident',
        'Department Head',
        'Chief Medical Officer',
      ],
      pitch: 'Listen, examine, test, diagnose and plan treatment.',
      dayInLife: <String>[
        'Ward rounds and clinic list',
        'Take histories and examine patients',
        'Order and interpret tests',
        'Make differential diagnoses',
        'Explain treatment plans clearly',
      ],
      employerExpectations: <String>[
        'A medical doctorate and strong clinical reasoning',
        'Systematic history-taking and examination',
        'Sensible use of tests: neither too few nor wasteful',
        'Honest, empathetic communication with patients',
        'Humility: knowing limits and asking for help',
      ],
      interviewKeywords: <String>[
        'patient', 'diagnosis', 'history', 'examine', 'differential', 'test', 'treatment',
        'ethics', 'consent', 'team', 'evidence', 'safety', 'clinic', 'empathy',
      ],
      certifications: <String>['cert_bls'],
      workplaceName: 'Hospital clinic',
    ),
    CareerDef(
      id: 'lawyer',
      title: 'Lawyer',
      emoji: '⚖️',
      degreeId: 'deg_law',
      minEducationRank: 3,
      internEducationRank: 2,
      coreSkill: 'legal',
      salaryMultiplier: 1.5,
      rankTitles: <String>[
        'Law Clerk (Intern)',
        'Junior Associate',
        'Associate',
        'Senior Associate',
        'Principal Lawyer',
        'Partner',
        'Managing Partner',
      ],
      pitch: 'Advise clients, research the law and argue cases in court.',
      dayInLife: <String>[
        'Meet clients and take instructions',
        'Review case files and spot key facts',
        'Research the relevant law',
        'Prepare arguments',
        'Examine witnesses and present in court',
      ],
      employerExpectations: <String>[
        'A law degree and sharp legal reasoning',
        'Careful reading: facts win cases',
        'Persuasive but honest advocacy',
        'Professional ethics and client confidentiality',
        'Composure under pressure from opposing counsel',
      ],
      interviewKeywords: <String>[
        'client', 'law', 'case', 'evidence', 'argument', 'ethics', 'court', 'research',
        'confidential', 'precedent', 'negotiate', 'witness', 'deadline', 'advice',
      ],
      certifications: <String>['cert_paralegal'],
      workplaceName: 'Law firm & courthouse',
    ),
    CareerDef(
      id: 'accountant',
      title: 'Accountant',
      emoji: '🧮',
      degreeId: 'deg_accounting',
      minEducationRank: 2,
      internEducationRank: 1,
      coreSkill: 'accounting',
      salaryMultiplier: 1.0,
      rankTitles: <String>[
        'Accounting Intern',
        'Junior Accountant',
        'Accountant',
        'Senior Accountant',
        'Accounting Team Lead',
        'Finance Manager',
        'Finance Director',
      ],
      pitch: 'Record, reconcile, report and audit the numbers.',
      dayInLife: <String>[
        'Post journal entries',
        'Reconcile bank and ledger accounts',
        'Spot errors in statements',
        'Prepare monthly financial reports',
        'Support audits',
      ],
      employerExpectations: <String>[
        'Accuracy and attention to detail',
        'Understanding of double-entry bookkeeping',
        'Comfort with spreadsheets and reconciliation',
        'Integrity: flagging problems early',
        'Explaining numbers to non-accountants',
      ],
      interviewKeywords: <String>[
        'accuracy', 'reconcile', 'ledger', 'audit', 'report', 'compliance', 'detail',
        'deadline', 'budget', 'spreadsheet', 'tax', 'integrity', 'balance', 'controls',
      ],
      certifications: <String>['cert_bookkeeping'],
      workplaceName: 'Accounting firm',
    ),
    CareerDef(
      id: 'business_manager',
      title: 'Business Manager',
      emoji: '📊',
      degreeId: 'deg_business',
      minEducationRank: 2,
      internEducationRank: 1,
      coreSkill: 'management',
      salaryMultiplier: 1.1,
      rankTitles: <String>[
        'Management Intern',
        'Junior Business Analyst',
        'Business Analyst',
        'Senior Business Analyst',
        'Team Lead',
        'Business Manager',
        'Director of Operations',
      ],
      pitch: 'Lead people, steer strategy and keep customers and cash healthy.',
      dayInLife: <String>[
        'Management meeting',
        'Assign work to the right people',
        'Handle customer complaints',
        'Review KPIs and company performance',
        'Make budget and strategy decisions',
      ],
      employerExpectations: <String>[
        'Leadership and clear delegation',
        'Data-driven decisions (KPIs, margins, churn)',
        'Customer empathy and calm complaint handling',
        'Financial awareness: cash is oxygen',
        'Owning outcomes, good or bad',
      ],
      interviewKeywords: <String>[
        'team', 'lead', 'customer', 'strategy', 'budget', 'kpi', 'goal', 'priorit',
        'delegate', 'revenue', 'stakeholder', 'results', 'process', 'improve', 'growth',
      ],
      certifications: <String>['cert_pm'],
      workplaceName: 'Corporate office',
    ),
  ];

  static CareerDef? byId(String id) {
    for (final CareerDef c in all) {
      if (c.id == id) return c;
    }
    return null;
  }

  static CareerDef require(String id) {
    final CareerDef? c = byId(id);
    if (c == null) throw ArgumentError('Unknown career: $id');
    return c;
  }

  /// Base gross monthly salary by rank before career/employer multipliers.
  static const List<double> baseMonthlySalary = <double>[
    1800, 2600, 3400, 4600, 5800, 7400, 10000,
  ];

  static double monthlySalary(CareerDef career, int rank, {double employerFactor = 1.0}) {
    final double v = baseMonthlySalary[rank.clamp(0, kTopRank)] *
        career.salaryMultiplier *
        employerFactor;
    return (v / 10).round() * 10.0;
  }

  /// Requirements to be promoted INTO [toRank] (1..6).
  static PromotionRequirement promotionRequirement(CareerDef career, int toRank) {
    final int r = toRank.clamp(1, kTopRank);
    const List<int> workdays = <int>[8, 15, 25, 30, 40, 50];
    const List<int> perf = <int>[55, 60, 65, 70, 75, 80];
    const List<int> core = <int>[15, 25, 40, 55, 70, 85];
    final Map<String, int> skills = <String, int>{career.coreSkill: core[r - 1]};
    if (r >= 3) skills['communication'] = 20 + (r - 3) * 10;
    if (r >= 4) skills['teamwork'] = 25 + (r - 4) * 10;
    if (r >= 5 && career.coreSkill != 'management') skills['management'] = 15 + (r - 5) * 20;
    return PromotionRequirement(
      toRank: r,
      workdays: workdays[r - 1],
      performance: perf[r - 1].toDouble(),
      skills: skills,
    );
  }
}

class PromotionRequirement {
  const PromotionRequirement({
    required this.toRank,
    required this.workdays,
    required this.performance,
    required this.skills,
  });

  final int toRank;

  /// Workdays completed at the current rank.
  final int workdays;

  /// Rolling performance rating 0..100.
  final double performance;
  final Map<String, int> skills;
}
