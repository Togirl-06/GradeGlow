/// The school buildings on the GradeGlow campus: who teaches there and how
/// the building's floor is laid out. Pure data (no Flutter).
library;

class SchoolPerson {
  const SchoolPerson(this.id, this.name, this.role, this.persona, this.lines, {this.skin = 2, this.hair = 1, this.outfit = 0xFF6366F1});
  final String id;
  final String name;
  final String role;
  final String persona;
  final List<String> lines;
  final int skin;
  final int hair;
  final int outfit;
}

class SchoolDef {
  const SchoolDef({
    required this.id,
    required this.majors,
    required this.professor,
    required this.student,
    this.floor = 'tile',
  });

  /// Building id (also the key into `labsOfSchool`).
  final String id;

  /// Majors taught in this building (shown on the door sign / plan).
  final List<String> majors;
  final SchoolPerson professor;
  final SchoolPerson student;

  /// Main floor finish for the 3D view: wood | tile | carpet | marble.
  final String floor;
}

const List<SchoolDef> kSchools = <SchoolDef>[
  SchoolDef(
    id: 'school_cs',
    majors: <String>['Computer Science', 'Software Engineering', 'Artificial Intelligence', 'Data Science', 'Cybersecurity', 'Information Technology', 'Web Development', 'Mobile App Development'],
    floor: 'carpet',
    professor: SchoolPerson('prof_cs', 'Prof. Ada Mensah', 'Professor of Computer Science',
        'A sharp, encouraging CS professor who loves algorithms and connects every exercise to real engineering jobs.',
        <String>['Start in the Algorithm Arena: three easy problems a day builds the habit.', 'Tech interviews test how you think out loud, not just the final answer.', 'Ship small projects. A portfolio beats a list of courses.'],
        skin: 4, hair: 0, outfit: 0xFF4F46E5),
    student: SchoolPerson('stu_cs', 'Kai Tanaka', 'CS student', 'A friendly second-year CS student grinding coding problems for an internship.',
        <String>['I just got "Accepted" on a medium problem!', 'Mock interviews at the Career Center really helped me.'],
        skin: 1, hair: 0, outfit: 0xFF0EA5E9),
  ),
  SchoolDef(
    id: 'school_medicine',
    majors: <String>['Medicine', 'Medical Laboratory Science', 'Anatomy & Physiology'],
    professor: SchoolPerson('prof_med', 'Dr. Grace Osei', 'Professor of Medicine',
        'A calm, precise physician-educator who teaches anatomy first, then history-taking, then diagnosis. Always reminds students this is an educational simulation.',
        <String>['Learn the anatomy table first: every diagnosis starts with knowing where things are.', 'Ask open questions, then focused ones. Patients tell you the diagnosis.', 'Simulation builds judgement. Real practice needs accredited training and licensing.'],
        skin: 5, hair: 0, outfit: 0xFFDC2626),
    student: SchoolPerson('stu_med', 'Lucas Moreau', 'Medical student', 'A curious medical student revising the cardiovascular system.',
        <String>['Click the heart on the anatomy table, then quiz yourself.', 'The diagnosis board makes you justify every test you order.'],
        skin: 0, hair: 2, outfit: 0xFF93C5FD),
  ),
  SchoolDef(
    id: 'school_nursing',
    majors: <String>['Nursing', 'Public Health'],
    professor: SchoolPerson('prof_nurse', 'Prof. Amaka Eze', 'Nursing professor',
        'A warm, safety-first nursing educator focused on assessment, communication, prioritisation and documentation.',
        <String>['Introduce yourself and check identity before anything else.', 'Vital signs tell a story: trends matter more than one number.', 'If a patient deteriorates, escalate early and document clearly.'],
        skin: 4, hair: 0, outfit: 0xFF14B8A6),
    student: SchoolPerson('stu_nurse', 'Sofia Rossi', 'Nursing student', 'A nursing student practising patient assessments.',
        <String>['The ward shift is busy: prioritise the sickest patient first.', 'I always do the five rights before giving any medication.'],
        skin: 1, hair: 3, outfit: 0xFF2BB3A4),
  ),
  SchoolDef(
    id: 'school_law',
    majors: <String>['Law', 'Criminal Law', 'Civil Law', 'Constitutional Law', 'Corporate Law', 'Legal Research', 'Trial Advocacy'],
    floor: 'wood',
    professor: SchoolPerson('prof_law', 'Prof. Daniel Whitaker', 'Professor of Law',
        'A rigorous but kind law professor who teaches case reading (facts, issue, rule, reasoning) and courtroom procedure. Notes that simulated work is not legal practice.',
        <String>['Read real decisions in the Case Study Center: facts, issue, holding, reasoning.', 'In the moot courtroom, every argument needs evidence and a rule.', 'A simulated law career does not authorise anyone to practise law.'],
        skin: 2, hair: 5, outfit: 0xFF1F2937),
    student: SchoolPerson('stu_law', 'Nadia Haddad', 'Law student', 'A law student preparing for moot court.',
        <String>['Marbury v. Madison is where judicial review comes from.', 'Objection practice is harder than it looks!'],
        skin: 2, hair: 0, outfit: 0xFF9F1239),
  ),
  SchoolDef(
    id: 'school_engineering',
    majors: <String>['Mechanical Engineering', 'Civil Engineering', 'Electrical Engineering', 'Chemical Engineering', 'Aerospace Engineering', 'Industrial Engineering'],
    professor: SchoolPerson('prof_eng', 'Prof. Marcus Lindqvist', 'Professor of Engineering',
        'A hands-on engineering professor who asks students to calculate, build, test and learn from failures. Safety first in every lab.',
        <String>['Calculate before you build, then test what you built.', 'A failed design test is data. Find out why it failed.', 'Every engineering employer here gives a technical assessment before hiring.'],
        skin: 0, hair: 3, outfit: 0xFFF59E0B),
    student: SchoolPerson('stu_eng', 'Zara Okafor', 'Engineering student', 'A civil engineering student designing a bridge.',
        <String>['My bridge failed the load test, so I am redesigning the truss.', 'The circuit lab is my favourite.'],
        skin: 4, hair: 0, outfit: 0xFFEAB308),
  ),
  SchoolDef(
    id: 'school_business',
    majors: <String>['Business Administration', 'Accounting', 'Finance', 'Economics', 'Entrepreneurship', 'Marketing', 'Human Resources', 'International Business'],
    floor: 'carpet',
    professor: SchoolPerson('prof_biz', 'Prof. Helen Achterberg', 'Professor of Business',
        'A practical business professor who uses real-world cases: falling sales, budgets, hiring and policy decisions.',
        <String>['Sales dropped 30%? Find the cause before choosing a strategy.', 'Accounting is the language of business: learn to read statements.', 'The markets desk uses virtual money only, so experiment freely.'],
        skin: 1, hair: 3, outfit: 0xFF2563EB),
    student: SchoolPerson('stu_biz', 'Diego Rao', 'Business student', 'An entrepreneurship student pitching a startup idea.',
        <String>['I am pitching my startup to investors at the incubator.', 'The economics policy sim showed me why rates go up with inflation.'],
        skin: 3, hair: 1, outfit: 0xFF1D4ED8),
  ),
  SchoolDef(
    id: 'school_math',
    majors: <String>['Mathematics', 'Statistics', 'Applied Mathematics'],
    professor: SchoolPerson('prof_math', 'Prof. Yuki Nakamura', 'Professor of Mathematics',
        'A patient mathematics professor who explains step by step and points to the exact step where a mistake happens.',
        <String>['Show every step: I can only help with the step I can see.', 'Check your answer by substituting it back.', 'Statistics is everywhere: data science, medicine and economics all use it.'],
        skin: 1, hair: 0, outfit: 0xFF0891B2),
    student: SchoolPerson('stu_math', 'Owen Bennett', 'Mathematics student', 'A maths student who loves calculus.',
        <String>['Derivatives finally clicked when I graphed them.', 'The whiteboard shows exactly where my algebra went wrong.'],
        skin: 0, hair: 3, outfit: 0xFF06B6D4),
  ),
  SchoolDef(
    id: 'school_arts',
    majors: <String>['English & Literature', 'Creative Writing', 'Journalism', 'Communication'],
    floor: 'wood',
    professor: SchoolPerson('prof_arts', 'Prof. Elena Vasquez', 'Professor of English',
        'An expressive humanities professor who coaches clear writing, close reading, public speaking and journalistic ethics.',
        <String>['Write a draft first, then revise for clarity.', 'In the newsroom, verify every claim with two sources.', 'Read your essay aloud: you will hear the awkward sentences.'],
        skin: 3, hair: 4, outfit: 0xFFDB2777),
    student: SchoolPerson('stu_arts', 'Felix Novak', 'Journalism student', 'A journalism student chasing a campus story.',
        <String>['My editor sent my article back twice. It is much better now.', 'The writing studio feedback is brutal but fair.'],
        skin: 0, hair: 4, outfit: 0xFFEC4899),
  ),
  SchoolDef(
    id: 'school_biology',
    majors: <String>['Biology', 'Genetics', 'Microbiology', 'Ecology'],
    professor: SchoolPerson('prof_bio', 'Prof. Kofi Asante', 'Professor of Biology',
        'An enthusiastic biologist who teaches cells, genetics, microbes and ecosystems through microscopes and models.',
        <String>['Find the mitochondria in the cell model, then explain what they do.', 'Punnett squares are just organised probability.', 'Wash your hands: infection prevention starts in the lab.'],
        skin: 5, hair: 0, outfit: 0xFF16A34A),
    student: SchoolPerson('stu_bio', 'Priya Sharma', 'Biology student', 'A genetics student.',
        <String>['I saw mitosis on the microscope today!', 'The ecology lab lets you change one species and watch the food chain react.'],
        skin: 3, hair: 0, outfit: 0xFF22C55E),
  ),
  SchoolDef(
    id: 'school_chemistry',
    majors: <String>['Chemistry'],
    professor: SchoolPerson('prof_chem', 'Prof. Irene Kowalski', 'Professor of Chemistry',
        'A careful chemistry professor: simulated experiments only, equations balanced, safety information always shown.',
        <String>['Balance the equation before you mix anything.', 'Goggles and gloves, even in simulation: build the habit.', 'Stoichiometry is just counting atoms carefully.'],
        skin: 0, hair: 2, outfit: 0xFF9333EA),
    student: SchoolPerson('stu_chem', 'Tomás Silva', 'Chemistry student', 'A chemistry student who likes titrations.',
        <String>['The titration turned pink right at the endpoint.', 'Organic reactions make more sense with the 3D molecules.'],
        skin: 2, hair: 1, outfit: 0xFFA855F7),
  ),
  SchoolDef(
    id: 'school_physics',
    majors: <String>['Physics'],
    professor: SchoolPerson('prof_phys', 'Prof. Samuel Adeyemi', 'Professor of Physics',
        'A playful physics professor: change one variable, predict, then observe.',
        <String>['Predict first, then run the experiment.', 'Double the mass and see what happens to the period.', 'Units! Always write your units.'],
        skin: 4, hair: 0, outfit: 0xFF0284C7),
    student: SchoolPerson('stu_phys', 'Mia Fischer', 'Physics student', 'A physics student building circuits.',
        <String>['The projectile lab finally made 45 degrees make sense.', 'Refraction through the lens was beautiful.'],
        skin: 0, hair: 3, outfit: 0xFF38BDF8),
  ),
];

SchoolDef? schoolById(String id) {
  for (final SchoolDef s in kSchools) {
    if (s.id == id) return s;
  }
  return null;
}
