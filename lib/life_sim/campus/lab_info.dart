/// Learning stations ("labs") that live inside each school building.
///
/// Pure data (no Flutter): the world layer places these as interactables and
/// the campus lab registry (`campus_labs.dart`) maps each id to the real
/// GradeGlow activity screen that opens.
library;

class LabInfo {
  const LabInfo(this.id, this.schoolId, this.name, this.emoji, this.hint, this.skill);
  final String id;

  /// Building id of the school this station is in.
  final String schoolId;
  final String name;
  final String emoji;
  final String hint;

  /// Skill that practising here improves (feeds job requirements).
  final String skill;
}

const List<LabInfo> kCampusLabs = <LabInfo>[
  LabInfo('cs_arena', 'school_cs', 'Algorithm Arena', '🧩', 'Solve Easy · Medium · Hard coding problems with test cases.', 'programming'),
  LabInfo('cs_software', 'school_cs', 'Software Company Floor', '🧑‍💻', 'Tickets, code review and deploys at a software company.', 'programming'),
  LabInfo('cs_ai', 'school_cs', 'AI Research Lab', '🤖', 'Train and evaluate machine-learning models.', 'programming'),
  LabInfo('cs_data', 'school_cs', 'Data Analytics Center', '📊', 'Clean data, write SQL and build dashboards.', 'programming'),
  LabInfo('cs_cyber', 'school_cs', 'Cyber Defense Center', '🛡️', 'Investigate alerts and phishing in a sandbox.', 'programming'),
  LabInfo('cs_it', 'school_cs', 'IT Support Desk', '🖥️', 'Resolve support tickets: accounts, printers, networks.', 'problem_solving'),
  LabInfo('cs_web', 'school_cs', 'Web & Mobile Studio', '🌐', 'Build websites and apps for virtual clients.', 'programming'),
  LabInfo('cs_career', 'school_cs', 'Tech Career Simulation', '🏢', 'Interview, get hired and work your first sprint.', 'programming'),
  LabInfo('med_anatomy', 'school_medicine', '3D Anatomy Table', '🫀', 'Rotate the body, select organs, bones and systems.', 'medicine'),
  LabInfo('med_history', 'school_medicine', 'Patient History Room', '🗣️', 'Take a history: the patient answers what you ask.', 'medicine'),
  LabInfo('med_diagnosis', 'school_medicine', 'Diagnosis Board', '🧠', 'Order tests, read results, build a differential.', 'medicine'),
  LabInfo('med_clinic', 'school_medicine', 'Virtual Patient Clinic', '🩺', 'Full consultation with a simulated patient.', 'medicine'),
  LabInfo('med_labsci', 'school_medicine', 'Diagnostic Laboratory', '🧪', 'Blood tests, imaging and lab science cases.', 'medicine'),
  LabInfo('med_pharmacy', 'school_medicine', 'Pharmacy & Counselling', '🧾', 'Verify prescriptions and counsel patients on medicines.', 'medicine'),
  LabInfo('med_career', 'school_medicine', 'Hospital Rotation', '🏥', 'Work a simulated medical rotation.', 'medicine'),
  LabInfo('nurse_ward', 'school_nursing', 'Patient Care Ward', '🛏️', 'Run a ward shift: prioritise and care for patients.', 'clinical'),
  LabInfo('nurse_assess', 'school_nursing', 'Patient Assessment Lab', '🌡️', 'Vital signs, pain, history and observations.', 'clinical'),
  LabInfo('nurse_case', 'school_nursing', 'Clinical Case Simulator', '🚑', 'A deteriorating patient: spot warning signs, respond.', 'clinical'),
  LabInfo('nurse_anatomy', 'school_nursing', 'Anatomy & Skeleton Models', '🦴', 'Learn organs and bones in 3D.', 'clinical'),
  LabInfo('nurse_public', 'school_nursing', 'Community & Public Health', '🧑‍⚕️', 'Outbreaks, prevention and community care.', 'clinical'),
  LabInfo('nurse_meds', 'school_nursing', 'Medication Safety Lab', '💊', 'Verify orders: right patient, drug, dose, route and time.', 'clinical'),
  LabInfo('nurse_career', 'school_nursing', 'Clinical Placement', '🏥', 'Work a full simulated nursing shift.', 'clinical'),
  LabInfo('law_real_cases', 'school_law', 'Real Case Study Center', '📜', 'Landmark published decisions: facts, issue, holding, why.', 'legal'),
  LabInfo('law_school', 'school_law', 'Law Library & Lessons', '📚', 'Lessons, objections, negotiation and exams.', 'legal'),
  LabInfo('law_client', 'school_law', 'Client Interview Room', '🤝', 'A client explains their problem: gather the facts.', 'legal'),
  LabInfo('law_firm', 'school_law', 'Law Firm Desk', '🗂️', 'Assignments from a senior attorney.', 'legal'),
  LabInfo('law_court', 'school_law', 'Moot Courtroom', '⚖️', 'Argue a case in front of the judge.', 'legal'),
  LabInfo('eng_mech', 'school_engineering', 'Mechanical Workshop', '⚙️', 'Machines, engines and the MechWorks factory.', 'problem_solving'),
  LabInfo('eng_civil', 'school_engineering', 'Civil Construction Site', '🌉', 'Loads, materials, foundations and bridges.', 'problem_solving'),
  LabInfo('eng_elec', 'school_engineering', 'Electrical Lab', '🔌', 'Circuits, faults and power systems.', 'problem_solving'),
  LabInfo('eng_chem', 'school_engineering', 'Chemical Process Plant', '🏭', 'Process flows, temperature and pressure.', 'problem_solving'),
  LabInfo('eng_aero', 'school_engineering', 'Aerospace Hangar', '✈️', 'Aerodynamics, engines and flight tests.', 'problem_solving'),
  LabInfo('eng_industrial', 'school_engineering', 'Industrial Factory Floor', '📦', 'Schedules, quality and efficiency.', 'management'),
  LabInfo('eng_career', 'school_engineering', 'Engineering Firm', '🏗️', 'Get hired and deliver a client project.', 'problem_solving'),
  LabInfo('biz_hq', 'school_business', 'Corporate HQ', '🏢', 'Run a company: strategy, people, results.', 'management'),
  LabInfo('biz_accounting', 'school_business', 'Accounting Firm', '🧮', 'Journal entries, reconciliations, audits.', 'accounting'),
  LabInfo('biz_finance', 'school_business', 'Markets Desk', '💹', 'Valuation and portfolios with virtual money.', 'finance'),
  LabInfo('biz_marketing', 'school_business', 'Marketing Agency', '📣', 'Audiences, campaigns and budgets.', 'communication'),
  LabInfo('biz_hr', 'school_business', 'HR Department', '🧑‍💼', 'Screen resumes, interview and onboard.', 'management'),
  LabInfo('biz_startup', 'school_business', 'Startup Incubator', '🚀', 'Idea, customers, prototype, pitch.', 'management'),
  LabInfo('econ_policy', 'school_business', 'Economic Policy Center', '📈', 'Inflation, unemployment and policy choices.', 'finance'),
  LabInfo('biz_school', 'school_business', 'Business Lecture Rooms', '🎓', 'Courses for every business major.', 'management'),
  LabInfo('math_whiteboard', 'school_math', 'Interactive Whiteboard', '🧑‍🏫', 'Algebra, calculus, statistics, geometry lessons.', 'problem_solving'),
  LabInfo('math_applied', 'school_math', 'Applied Math Lab', '📐', 'Model real problems with mathematics.', 'problem_solving'),
  LabInfo('math_career', 'school_math', 'Quant Career Simulation', '📊', 'Use math on the job.', 'problem_solving'),
  LabInfo('arts_writing', 'school_arts', 'Writing Studio', '✍️', 'Grammar, essays and literature with AI feedback.', 'communication'),
  LabInfo('arts_psych', 'school_arts', 'Psychology Lab', '🧠', 'Case studies, behaviour and research ethics.', 'communication'),
  LabInfo('arts_newsroom', 'school_arts', 'Newsroom', '📰', 'Research, verify and publish stories.', 'communication'),
  LabInfo('bio_lab', 'school_biology', 'Biology Lab', '🔬', 'Cells, genetics, microscopy and ecology.', 'problem_solving'),
  LabInfo('bio_anatomy', 'school_biology', 'Anatomy Models', '🧠', 'Explore organs and systems in 3D.', 'medicine'),
  LabInfo('bio_career', 'school_biology', 'Research Career', '🧫', 'Work as a lab scientist.', 'problem_solving'),
  LabInfo('chem_bench', 'school_chemistry', 'Chemistry Bench', '⚗️', 'Reactions, titrations and molecules (simulated).', 'problem_solving'),
  LabInfo('chem_lessons', 'school_chemistry', 'Chemistry Lessons', '🧪', 'Periodic table, bonding, stoichiometry.', 'problem_solving'),
  LabInfo('chem_career', 'school_chemistry', 'Chemist Career', '🏭', 'Work in a virtual chemistry lab.', 'problem_solving'),
  LabInfo('phys_lab', 'school_physics', 'Physics Lab', '🧲', 'Change variables and watch systems respond.', 'problem_solving'),
  LabInfo('phys_practical', 'school_physics', 'Practical Experiments', '🔭', 'Mechanics, circuits, waves, heat.', 'problem_solving'),
  LabInfo('phys_career', 'school_physics', 'Physicist Career', '⚛️', 'Apply physics on the job.', 'problem_solving'),
];

LabInfo? labInfo(String id) {
  for (final LabInfo l in kCampusLabs) {
    if (l.id == id) return l;
  }
  return null;
}

List<LabInfo> labsOfSchool(String schoolId) => <LabInfo>[
      for (final LabInfo l in kCampusLabs)
        if (l.schoolId == schoolId) l,
    ];
