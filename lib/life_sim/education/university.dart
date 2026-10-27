/// The University: degrees, courses, lectures, study, exams and graduation.
library;

import '../core/stable_random.dart';

class ExamQuestion {
  const ExamQuestion(this.prompt, this.options, this.correct, this.explanation);
  final String prompt;
  final List<String> options;
  final int correct;
  final String explanation;
}

class Course {
  const Course({
    required this.id,
    required this.name,
    required this.skill,
    required this.summary,
    required this.questions,
    this.tuition = 280,
  });

  final String id;
  final String name;
  final String skill;
  final String summary;
  final List<ExamQuestion> questions;
  final double tuition;
}

class Degree {
  const Degree({
    required this.id,
    required this.name,
    required this.shortName,
    required this.emoji,
    required this.awardRank,
    required this.prereqRank,
    required this.careerId,
    required this.courses,
    this.associateAfter,
  });

  final String id;
  final String name;
  final String shortName;
  final String emoji;

  /// Education rank granted (1 associate, 2 bachelor, 3 master, 4 doctorate).
  final int awardRank;

  /// Education rank needed to enrol.
  final int prereqRank;
  final String careerId;
  final List<Course> courses;

  /// After this many passed courses the student also earns an associate degree.
  final int? associateAfter;

  double get totalTuition => courses.fold(0.0, (double s, Course c) => s + c.tuition);
}

/// Everything required before sitting an exam.
class CourseRequirements {
  const CourseRequirements._();
  static const int lecturesRequired = 4;
  static const int studyMinutesRequired = 240;
  static const double examFee = 25;
  static const double passMark = 0.75;
}

class CourseProgress {
  CourseProgress({
    this.enrolled = false,
    this.lectures = 0,
    this.studyMinutes = 0,
    this.passed = false,
    this.attempts = 0,
    this.bestScore = 0,
    this.lastLectureDay = 0,
  });

  bool enrolled;
  int lectures;
  int studyMinutes;
  bool passed;
  int attempts;
  double bestScore;
  int lastLectureDay;

  bool get examReady =>
      enrolled &&
      !passed &&
      lectures >= CourseRequirements.lecturesRequired &&
      studyMinutes >= CourseRequirements.studyMinutesRequired;

  Map<String, Object?> toJson() => <String, Object?>{
        'enrolled': enrolled,
        'lectures': lectures,
        'studyMinutes': studyMinutes,
        'passed': passed,
        'attempts': attempts,
        'bestScore': bestScore,
        'lastLectureDay': lastLectureDay,
      };

  factory CourseProgress.fromJson(Map<String, Object?> j) => CourseProgress(
        enrolled: j['enrolled'] as bool? ?? false,
        lectures: (j['lectures'] as num?)?.toInt() ?? 0,
        studyMinutes: (j['studyMinutes'] as num?)?.toInt() ?? 0,
        passed: j['passed'] as bool? ?? false,
        attempts: (j['attempts'] as num?)?.toInt() ?? 0,
        bestScore: (j['bestScore'] as num?)?.toDouble() ?? 0,
        lastLectureDay: (j['lastLectureDay'] as num?)?.toInt() ?? 0,
      );
}

class ExamResult {
  const ExamResult({required this.score, required this.passed, required this.wrong});
  final double score;
  final bool passed;
  final List<String> wrong;
}

/// The student's record: courses taken and degrees earned.
class UniversityRecord {
  UniversityRecord({
    this.activeDegreeId,
    Map<String, CourseProgress>? courses,
    List<String>? completedDegrees,
    this.associateEarned = const <String>[],
  })  : courses = courses ?? <String, CourseProgress>{},
        completedDegrees = completedDegrees ?? <String>[];

  String? activeDegreeId;
  final Map<String, CourseProgress> courses;
  final List<String> completedDegrees;

  /// Degree ids for which the associate milestone has been awarded.
  List<String> associateEarned;

  CourseProgress progress(String courseId) =>
      courses.putIfAbsent(courseId, () => CourseProgress());

  bool has(String degreeId) => completedDegrees.contains(degreeId);

  Degree? get activeDegree =>
      activeDegreeId == null ? null : UniversityCatalog.degreeById(activeDegreeId!);

  int passedIn(Degree d) =>
      d.courses.where((Course c) => courses[c.id]?.passed ?? false).length;

  Map<String, Object?> toJson() => <String, Object?>{
        'activeDegreeId': activeDegreeId,
        'courses': courses.map((String k, CourseProgress v) => MapEntry<String, Object?>(k, v.toJson())),
        'completedDegrees': completedDegrees,
        'associateEarned': associateEarned,
      };

  factory UniversityRecord.fromJson(Map<String, Object?> j) {
    final Object? c = j['courses'];
    final Object? d = j['completedDegrees'];
    final Object? a = j['associateEarned'];
    return UniversityRecord(
      activeDegreeId: j['activeDegreeId'] as String?,
      courses: c is Map
          ? c.map((Object? k, Object? v) => MapEntry<String, CourseProgress>(
              k.toString(), CourseProgress.fromJson(Map<String, Object?>.from(v as Map))))
          : <String, CourseProgress>{},
      completedDegrees: d is List ? d.map((Object? e) => e.toString()).toList() : <String>[],
      associateEarned: a is List ? a.map((Object? e) => e.toString()).toList() : <String>[],
    );
  }
}

class UniversityEngine {
  const UniversityEngine._();

  /// Grade points (4.0 scale) for a 0..1 exam score.
  static double gradePoints(double score) {
    if (score >= 0.90) return 4.0;
    if (score >= 0.80) return 3.0;
    if (score >= 0.70) return 2.0;
    if (score >= 0.60) return 1.0;
    return 0.0;
  }

  static String letter(double score) {
    if (score >= 0.90) return 'A';
    if (score >= 0.80) return 'B';
    if (score >= 0.70) return 'C';
    if (score >= 0.60) return 'D';
    return 'F';
  }

  /// Cumulative GPA across passed courses (null until one is passed).
  static double? gpa(UniversityRecord r) {
    double sum = 0;
    int n = 0;
    r.courses.forEach((String _, CourseProgress p) {
      if (p.passed) {
        sum += gradePoints(p.bestScore);
        n++;
      }
    });
    return n == 0 ? null : sum / n;
  }

  static String honors(double? gpa) {
    if (gpa == null) return '';
    if (gpa >= 3.8) return 'with High Distinction';
    if (gpa >= 3.4) return 'with Distinction';
    return '';
  }

  /// Lectures run on weekdays between 9:00 and 17:00.
  static bool lectureOpen(int day, int minuteOfDay) =>
      ((day - 1) % 7) < 5 && minuteOfDay >= 9 * 60 && minuteOfDay < 17 * 60;

  static const int lectureMinutes = 120;
  static const int studySessionMinutes = 60;

  /// Returns an error message or null.
  static String? canEnrolDegree(UniversityRecord r, Degree d, int educationRank) {
    if (r.has(d.id)) return 'You already hold this degree.';
    if (r.activeDegreeId != null && r.activeDegreeId != d.id) {
      return 'Finish or withdraw from your current degree first.';
    }
    if (educationRank < d.prereqRank) {
      return 'This programme requires ${_rankName(d.prereqRank)} first.';
    }
    return null;
  }

  static String _rankName(int r) =>
      <String>['high school', 'an associate degree', "a bachelor's degree", "a master's degree", 'a doctorate'][r.clamp(0, 4)];

  static String? enrolInCourse(UniversityRecord r, Degree d, Course c) {
    if (r.activeDegreeId != d.id) return 'Enrol in ${d.shortName} first.';
    final CourseProgress p = r.progress(c.id);
    if (p.passed) return 'You already passed ${c.name}.';
    if (p.enrolled) return 'You are already enrolled.';
    p.enrolled = true;
    return null;
  }

  /// Attend a lecture. Returns an error or null.
  static String? attendLecture(UniversityRecord r, Course c, int day, int minuteOfDay) {
    final CourseProgress p = r.progress(c.id);
    if (!p.enrolled || p.passed) return 'You are not enrolled in this course.';
    if (!lectureOpen(day, minuteOfDay)) return 'Lectures run on weekdays between 9am and 5pm.';
    if (p.lectures >= CourseRequirements.lecturesRequired) return 'You have attended every lecture for this course.';
    if (p.lastLectureDay == day) return 'You already attended this course\'s lecture today.';
    p.lectures++;
    p.lastLectureDay = day;
    return null;
  }

  static String? study(UniversityRecord r, Course c, {int minutes = studySessionMinutes}) {
    final CourseProgress p = r.progress(c.id);
    if (!p.enrolled || p.passed) return 'You are not enrolled in this course.';
    p.studyMinutes += minutes;
    return null;
  }

  /// Four questions in a stable order per attempt.
  static List<ExamQuestion> examFor(Course c, int attempt) {
    final StableRandom rng = StableRandom.fromString('exam|${c.id}|$attempt');
    return rng.shuffled<ExamQuestion>(c.questions);
  }

  static ExamResult grade(Course c, List<ExamQuestion> asked, List<int?> answers) {
    int right = 0;
    final List<String> wrong = <String>[];
    for (int i = 0; i < asked.length; i++) {
      final int? a = i < answers.length ? answers[i] : null;
      if (a == asked[i].correct) {
        right++;
      } else {
        wrong.add('${asked[i].prompt} → ${asked[i].options[asked[i].correct]}. ${asked[i].explanation}');
      }
    }
    final double score = asked.isEmpty ? 0 : right / asked.length;
    return ExamResult(score: score, passed: score >= CourseRequirements.passMark, wrong: wrong);
  }

  /// Records an exam attempt. Returns the degree if this completed it.
  static ({Degree? completed, bool associate}) recordExam(UniversityRecord r, Degree d, Course c, ExamResult res) {
    final CourseProgress p = r.progress(c.id);
    p.attempts++;
    if (res.score > p.bestScore) p.bestScore = res.score;
    if (!res.passed) {
      // Failing means revising again before the next sit.
      p.studyMinutes = (p.studyMinutes - 120).clamp(0, 100000);
      return (completed: null, associate: false);
    }
    p.passed = true;
    bool assoc = false;
    final int passed = r.passedIn(d);
    if (d.associateAfter != null &&
        passed >= d.associateAfter! &&
        !r.associateEarned.contains(d.id)) {
      r.associateEarned = <String>[...r.associateEarned, d.id];
      assoc = true;
    }
    if (passed >= d.courses.length) {
      r.completedDegrees.add(d.id);
      r.activeDegreeId = null;
      return (completed: d, associate: assoc);
    }
    return (completed: null, associate: assoc);
  }

  /// Skills awarded for finishing a course.
  static Map<String, double> courseSkillGain(Course c, double examScore) =>
      <String, double>{c.skill: 5 + 4 * examScore, 'problem_solving': 1.5, 'communication': 1.0};

  /// Skills awarded for graduating.
  static Map<String, double> graduationGain(Degree d, String coreSkill) => <String, double>{
        coreSkill: 12,
        'communication': 6,
        'problem_solving': 4,
      };

  /// Education rank implied by degrees held (0..4).
  static int educationRankOf(UniversityRecord r, {int baseline = 0}) {
    int rank = baseline;
    for (final String id in r.completedDegrees) {
      final Degree? d = UniversityCatalog.degreeById(id);
      if (d != null && d.awardRank > rank) rank = d.awardRank;
    }
    for (final String id in r.associateEarned) {
      if (rank < 1 && UniversityCatalog.degreeById(id) != null) rank = 1;
    }
    return rank;
  }

  static void withdraw(UniversityRecord r) {
    r.activeDegreeId = null;
  }
}

class UniversityCatalog {
  const UniversityCatalog._();

  static Degree? degreeById(String id) {
    for (final Degree d in degrees) {
      if (d.id == id) return d;
    }
    return null;
  }

  static Degree? degreeForCareer(String careerId) {
    for (final Degree d in degrees) {
      if (d.careerId == careerId) return d;
    }
    return null;
  }

  static Course? courseById(String id) {
    for (final Degree d in degrees) {
      for (final Course c in d.courses) {
        if (c.id == id) return c;
      }
    }
    return null;
  }

  static Degree? degreeOfCourse(String courseId) {
    for (final Degree d in degrees) {
      if (d.courses.any((Course c) => c.id == courseId)) return d;
    }
    return null;
  }

  static const List<Degree> degrees = <Degree>[
    Degree(
      id: 'deg_cs',
      name: 'BSc Computer Science',
      shortName: 'Computer Science',
      emoji: '💻',
      awardRank: 2,
      prereqRank: 0,
      careerId: 'software_engineer',
      associateAfter: 3,
      courses: <Course>[
        Course(
          id: 'cs101',
          name: 'CS101 Programming Fundamentals',
          skill: 'programming',
          summary: 'Variables, loops, functions and debugging.',
          questions: <ExamQuestion>[
            ExamQuestion('What does a loop do?', <String>['Repeats a block of code', 'Deletes variables', 'Stops the program forever', 'Compiles the code'], 0, 'Loops repeat instructions until a condition is met.'),
            ExamQuestion('What is a function?', <String>['A named, reusable block of code', 'A type of virus', 'A computer screen', 'A variable that never changes'], 0, 'Functions package logic so it can be reused.'),
            ExamQuestion('What is a bug?', <String>['An error in a program', 'A keyboard key', 'A kind of file', 'A fast computer'], 0, 'Bugs are mistakes that cause unexpected behaviour.'),
            ExamQuestion('Which expression is TRUE if x is 5?', <String>['x >= 5', 'x < 5', 'x > 5', 'x == 6'], 0, '5 >= 5 is true because the values are equal.'),
          ],
        ),
        Course(
          id: 'cs102',
          name: 'CS102 Data Structures',
          skill: 'programming',
          summary: 'Arrays, lists, stacks, queues, maps and trees.',
          questions: <ExamQuestion>[
            ExamQuestion('A stack removes items in which order?', <String>['Last in, first out', 'First in, first out', 'Random order', 'Alphabetical order'], 0, 'Stacks are LIFO.'),
            ExamQuestion('A queue removes items in which order?', <String>['First in, first out', 'Last in, first out', 'Largest first', 'Random'], 0, 'Queues are FIFO.'),
            ExamQuestion('Which structure gives fast lookup by key on average?', <String>['Hash map', 'Unsorted list', 'Stack', 'Queue'], 0, 'Hash maps provide O(1) average lookups.'),
            ExamQuestion('Accessing array element 7 by index takes about…', <String>['Constant time', 'Time proportional to 7 squared', 'Time proportional to array size', 'It is impossible'], 0, 'Array indexing is O(1).'),
          ],
        ),
        Course(
          id: 'cs103',
          name: 'CS103 Computer Systems',
          skill: 'programming',
          summary: 'Binary, memory, the CPU and operating systems.',
          questions: <ExamQuestion>[
            ExamQuestion('Binary 101 equals which decimal number?', <String>['5', '3', '6', '10'], 0, '1×4 + 0×2 + 1×1 = 5.'),
            ExamQuestion('RAM is…', <String>['Fast temporary working memory', 'Permanent storage', 'A network cable', 'The monitor'], 0, 'RAM holds data in use; it is cleared when power is lost.'),
            ExamQuestion('What does an operating system do?', <String>['Manages hardware and runs programs', 'Draws images only', 'Replaces the CPU', 'Stores your passwords online'], 0, 'The OS manages memory, processes and devices.'),
            ExamQuestion('One byte is…', <String>['8 bits', '2 bits', '16 bits', '1 bit'], 0, 'A byte is eight bits.'),
          ],
        ),
        Course(
          id: 'cs201',
          name: 'CS201 Algorithms',
          skill: 'programming',
          summary: 'Complexity, searching, sorting and recursion.',
          questions: <ExamQuestion>[
            ExamQuestion('Binary search requires the list to be…', <String>['Sorted', 'Empty', 'Reversed', 'Of even length'], 0, 'It halves a sorted range each step.'),
            ExamQuestion('Binary search on n items takes about…', <String>['log n steps', 'n squared steps', 'n factorial steps', 'one step'], 0, 'Halving repeatedly gives O(log n).'),
            ExamQuestion('A recursive function must have…', <String>['A base case', 'No parameters', 'A global variable', 'A loop'], 0, 'Without a base case recursion never stops.'),
            ExamQuestion('Which has the best worst-case time for sorting?', <String>['Merge sort O(n log n)', 'Bubble sort O(n²)', 'Selection sort O(n²)', 'Insertion sort O(n²)'], 0, 'Merge sort is O(n log n) in the worst case.'),
          ],
        ),
        Course(
          id: 'cs202',
          name: 'CS202 Databases & Software Engineering',
          skill: 'programming',
          summary: 'SQL, version control, testing and teamwork.',
          questions: <ExamQuestion>[
            ExamQuestion('Which SQL keyword retrieves rows?', <String>['SELECT', 'DROPPED', 'PUSH', 'FETCHALL'], 0, 'SELECT queries data.'),
            ExamQuestion('Why use version control like git?', <String>['Track changes and collaborate safely', 'Make the code run faster', 'Hide bugs', 'Avoid writing tests'], 0, 'It records history and supports teamwork.'),
            ExamQuestion('A unit test checks…', <String>['One small piece of code in isolation', 'The whole company', 'The colour scheme', 'Network speed'], 0, 'Unit tests verify small units.'),
            ExamQuestion('Why review code before merging?', <String>['Catch bugs and share knowledge', 'To slow the team down', 'To increase file size', 'To punish developers'], 0, 'Reviews improve quality and learning.'),
          ],
        ),
      ],
    ),
    Degree(
      id: 'deg_nursing',
      name: 'Bachelor of Science in Nursing',
      shortName: 'Nursing',
      emoji: '🩺',
      awardRank: 2,
      prereqRank: 0,
      careerId: 'nurse',
      courses: <Course>[
        Course(
          id: 'nu101',
          name: 'NUR101 Anatomy & Physiology',
          skill: 'clinical',
          summary: 'Body systems and how they work.',
          questions: <ExamQuestion>[
            ExamQuestion('Which organ pumps blood around the body?', <String>['Heart', 'Liver', 'Kidney', 'Stomach'], 0, 'The heart is the pump of the circulatory system.'),
            ExamQuestion('Gas exchange happens in the…', <String>['Alveoli of the lungs', 'Stomach', 'Spleen', 'Bladder'], 0, 'Oxygen and CO₂ cross at the alveoli.'),
            ExamQuestion('Which part of the brain controls balance and coordination?', <String>['Cerebellum', 'Cornea', 'Pancreas', 'Aorta'], 0, 'The cerebellum coordinates movement.'),
            ExamQuestion('Normal adult resting heart rate is about…', <String>['60–100 beats/min', '10–20 beats/min', '200–250 beats/min', '0–5 beats/min'], 0, 'Resting adult pulse is typically 60–100.'),
          ],
        ),
        Course(
          id: 'nu102',
          name: 'NUR102 Fundamentals of Nursing',
          skill: 'clinical',
          summary: 'Vital signs, hygiene and infection control.',
          questions: <ExamQuestion>[
            ExamQuestion('The most important way to prevent infection spreading is…', <String>['Hand hygiene', 'Wearing jewellery', 'Opening all windows', 'Using the same gloves for everyone'], 0, 'Hand hygiene prevents cross-infection.'),
            ExamQuestion('Which is a vital sign?', <String>['Respiratory rate', 'Shoe size', 'Favourite colour', 'Eye colour'], 0, 'Vitals: temperature, pulse, respiration, blood pressure, SpO₂.'),
            ExamQuestion('A patient at risk of pressure sores should…', <String>['Be repositioned regularly', 'Stay in one position', 'Avoid food and water', 'Be left alone'], 0, 'Regular repositioning relieves pressure.'),
            ExamQuestion('Before any procedure you should…', <String>['Identify the patient and explain what you will do', 'Start immediately', 'Ask a visitor to sign', 'Guess their name'], 0, 'Patient identity and informed cooperation come first.'),
          ],
        ),
        Course(
          id: 'nu103',
          name: 'NUR201 Pharmacology',
          skill: 'clinical',
          summary: 'Drug classes, routes and the five rights.',
          questions: <ExamQuestion>[
            ExamQuestion('The five rights include right patient, drug, dose, time and…', <String>['Route', 'Colour', 'Price', 'Doctor'], 0, 'The fifth right is the correct route.'),
            ExamQuestion('Before giving a medicine you must check…', <String>['Allergies', 'The patient\'s hobbies', 'The weather', 'The ward colour'], 0, 'Allergy checks prevent harm.'),
            ExamQuestion('IV means a drug is given…', <String>['Into a vein', 'By mouth', 'Under the tongue', 'On the skin'], 0, 'Intravenous = into a vein.'),
            ExamQuestion('A calculation gives 2.4 mL but you feel unsure. You…', <String>['Re-check or ask a colleague to double-check', 'Give it anyway', 'Round up', 'Skip documenting'], 0, 'Independent double-checks prevent errors.'),
          ],
        ),
        Course(
          id: 'nu104',
          name: 'NUR202 Medical-Surgical Nursing',
          skill: 'clinical',
          summary: 'Caring for adults before and after surgery.',
          questions: <ExamQuestion>[
            ExamQuestion('After surgery, a rising pulse with falling blood pressure may indicate…', <String>['Bleeding or sepsis — escalate quickly', 'The patient is relaxed', 'Nothing important', 'A good recovery'], 0, 'These are warning signs of deterioration.'),
            ExamQuestion('Early mobilisation after surgery helps prevent…', <String>['Blood clots and chest infections', 'Hunger', 'Boredom only', 'Hair loss'], 0, 'Moving reduces clot and chest complications.'),
            ExamQuestion('Pain should be assessed…', <String>['Regularly using a scale and acted on', 'Never', 'Only if asked twice', 'Only by visitors'], 0, 'Pain is the fifth vital sign in many settings.'),
            ExamQuestion('Surgical wound care aims to…', <String>['Prevent infection and promote healing', 'Keep the wound open', 'Hide it from the doctor', 'Dry it with dirty cloths'], 0, 'Aseptic technique protects the wound.'),
          ],
        ),
        Course(
          id: 'nu105',
          name: 'NUR203 Communication & Ethics',
          skill: 'clinical',
          summary: 'Consent, confidentiality and compassionate care.',
          questions: <ExamQuestion>[
            ExamQuestion('Patient information may be shared…', <String>['Only with those involved in their care', 'With any visitor', 'On social media', 'With friends'], 0, 'Confidentiality is a core duty.'),
            ExamQuestion('SBAR stands for…', <String>['Situation, Background, Assessment, Recommendation', 'Safe, Better, Accurate, Rapid', 'Sleep, Breathe, Act, React', 'Scan, Bill, Admit, Release'], 0, 'SBAR structures clinical handover.'),
            ExamQuestion('A competent patient refuses a treatment. You should…', <String>['Respect the decision and ensure they are informed', 'Force the treatment', 'Ignore them', 'Ask their neighbour'], 0, 'Competent adults can refuse care.'),
            ExamQuestion('Best response to an anxious patient is…', <String>['Listen, acknowledge feelings and explain clearly', 'Say "calm down"', 'Avoid them', 'Change the subject'], 0, 'Empathic listening reduces anxiety.'),
          ],
        ),
      ],
    ),
    Degree(
      id: 'deg_accounting',
      name: 'Bachelor of Accounting',
      shortName: 'Accounting',
      emoji: '🧮',
      awardRank: 2,
      prereqRank: 0,
      careerId: 'accountant',
      associateAfter: 3,
      courses: <Course>[
        Course(
          id: 'ac101',
          name: 'ACC101 Financial Accounting',
          skill: 'accounting',
          summary: 'The accounting equation and double-entry bookkeeping.',
          questions: <ExamQuestion>[
            ExamQuestion('The accounting equation is…', <String>['Assets = Liabilities + Equity', 'Assets = Revenue − Tax', 'Equity = Assets + Liabilities', 'Profit = Cash'], 0, 'Everything the business owns is funded by debt or owners.'),
            ExamQuestion('A debit increases which account?', <String>['An asset', 'A liability', 'Equity', 'Revenue'], 0, 'Debits increase assets and expenses.'),
            ExamQuestion('In double entry every transaction…', <String>['Has equal debits and credits', 'Has only debits', 'Has only credits', 'Is optional'], 0, 'Debits must equal credits.'),
            ExamQuestion('Which is a liability?', <String>['Accounts payable', 'Cash', 'Equipment', 'Inventory'], 0, 'Accounts payable is money owed.'),
          ],
        ),
        Course(
          id: 'ac102',
          name: 'ACC102 Managerial Accounting',
          skill: 'accounting',
          summary: 'Costs, budgets and decision-making.',
          questions: <ExamQuestion>[
            ExamQuestion('A fixed cost…', <String>['Does not change with output in the short run', 'Doubles with every sale', 'Is always zero', 'Is only paid by customers'], 0, 'Rent is a common fixed cost.'),
            ExamQuestion('Break-even happens when…', <String>['Revenue equals total costs', 'Cash is zero', 'Profit is maximal', 'Assets equal debts'], 0, 'At break-even profit is zero.'),
            ExamQuestion('A budget is…', <String>['A plan for income and spending', 'A tax return', 'A bank loan', 'A bank statement'], 0, 'Budgets guide spending and control.'),
            ExamQuestion('A variance compares…', <String>['Actual results to the budget', 'Two customers', 'Two banks', 'Two years of tax'], 0, 'Variances flag deviations from plan.'),
          ],
        ),
        Course(
          id: 'ac103',
          name: 'ACC103 Business Math & Spreadsheets',
          skill: 'accounting',
          summary: 'Percentages, interest and spreadsheet skills.',
          questions: <ExamQuestion>[
            ExamQuestion('20% of \$250 is…', <String>['\$50', '\$25', '\$20', '\$500'], 0, '250 × 0.2 = 50.'),
            ExamQuestion('Simple interest on \$1,000 at 5% for 2 years is…', <String>['\$100', '\$50', '\$10', '\$1,100'], 0, '1000 × 0.05 × 2 = 100.'),
            ExamQuestion('The spreadsheet function to add a range is…', <String>['SUM', 'ADDFILE', 'TOTALIZE', 'PLUSALL'], 0, 'SUM adds numbers.'),
            ExamQuestion('A cell reference that does not change when copied is…', <String>['Absolute (e.g. \$A\$1)', 'Relative', 'Circular', 'Empty'], 0, 'Dollar signs lock a reference.'),
          ],
        ),
        Course(
          id: 'ac201',
          name: 'ACC201 Taxation Basics',
          skill: 'accounting',
          summary: 'Income tax, deductions and payroll withholding.',
          questions: <ExamQuestion>[
            ExamQuestion('Income tax withheld from pay is…', <String>['Sent to the tax authority by the employer', 'Kept by the employee', 'Optional', 'Paid by customers'], 0, 'Employers withhold and remit tax.'),
            ExamQuestion('A tax deduction…', <String>['Reduces taxable income', 'Increases tax directly', 'Is the same as a refund', 'Is illegal'], 0, 'Deductions lower the income that is taxed.'),
            ExamQuestion('Keeping accurate records matters because…', <String>['It supports tax returns and audits', 'It looks nice', 'It is never checked', 'Banks demand paper only'], 0, 'Records prove what you report.'),
            ExamQuestion('Tax avoidance vs evasion: evasion is…', <String>['Illegal underreporting', 'Legal planning', 'Filing on time', 'Paying early'], 0, 'Evasion breaks the law.'),
          ],
        ),
        Course(
          id: 'ac202',
          name: 'ACC202 Auditing & Ethics',
          skill: 'accounting',
          summary: 'Internal controls, evidence and professional integrity.',
          questions: <ExamQuestion>[
            ExamQuestion('Segregation of duties means…', <String>['Different people handle authorising, recording and custody', 'One person does everything', 'Staff swap desks', 'Auditors run payroll'], 0, 'It reduces fraud risk.'),
            ExamQuestion('Audit evidence should be…', <String>['Sufficient and reliable', 'Verbal only', 'Provided by the person audited, unchecked', 'Optional'], 0, 'Auditors need adequate, trustworthy evidence.'),
            ExamQuestion('A manager asks you to backdate an invoice. You…', <String>['Decline and escalate if needed', 'Do it quietly', 'Delete the record', 'Ask a friend to do it'], 0, 'Integrity is non-negotiable.'),
            ExamQuestion('Independence for an auditor means…', <String>['Being free from conflicts that bias judgement', 'Working alone always', 'Never meeting clients', 'Only auditing friends'], 0, 'Objectivity underpins trust.'),
          ],
        ),
      ],
    ),
    Degree(
      id: 'deg_business',
      name: 'Bachelor of Business Administration',
      shortName: 'Business',
      emoji: '📊',
      awardRank: 2,
      prereqRank: 0,
      careerId: 'business_manager',
      associateAfter: 3,
      courses: <Course>[
        Course(
          id: 'bu101',
          name: 'BUS101 Principles of Management',
          skill: 'management',
          summary: 'Planning, organising, leading and controlling.',
          questions: <ExamQuestion>[
            ExamQuestion('Which is NOT a classic management function?', <String>['Gossiping', 'Planning', 'Organising', 'Controlling'], 0, 'The functions are plan, organise, lead and control.'),
            ExamQuestion('A SMART goal is…', <String>['Specific, Measurable, Achievable, Relevant, Time-bound', 'Simple, Mild, Average, Rare, Tiny', 'Secret, Meaningful, Aggressive, Rapid, True', 'Short-term only'], 0, 'SMART goals are clear and checkable.'),
            ExamQuestion('Delegation means…', <String>['Assigning responsibility with authority to others', 'Doing everything yourself', 'Ignoring tasks', 'Firing people'], 0, 'Good delegation develops people and saves time.'),
            ExamQuestion('Span of control is…', <String>['The number of people a manager supervises directly', 'A type of budget', 'A sales region', 'A software tool'], 0, 'It affects management layers and workload.'),
          ],
        ),
        Course(
          id: 'bu102',
          name: 'BUS102 Marketing',
          skill: 'management',
          summary: 'Customers, segments and the marketing mix.',
          questions: <ExamQuestion>[
            ExamQuestion('The 4 Ps are product, price, place and…', <String>['Promotion', 'Profit', 'People only', 'Paper'], 0, 'Promotion completes the classic mix.'),
            ExamQuestion('Market segmentation divides customers by…', <String>['Shared needs or characteristics', 'Alphabetical names', 'Shoe size only', 'Random choice'], 0, 'Segments allow targeted offers.'),
            ExamQuestion('A brand is…', <String>['The perception customers have of a company', 'Only a logo', 'A tax', 'A warehouse'], 0, 'Brand lives in customers\' minds.'),
            ExamQuestion('Customer retention is usually…', <String>['Cheaper than winning new customers', 'Impossible', 'More expensive than acquisition', 'Irrelevant'], 0, 'Keeping customers costs less than finding new ones.'),
          ],
        ),
        Course(
          id: 'bu103',
          name: 'BUS103 Business Finance',
          skill: 'management',
          summary: 'Cash flow, margins and investment decisions.',
          questions: <ExamQuestion>[
            ExamQuestion('Gross margin is…', <String>['(Revenue − COGS) ÷ Revenue', 'Revenue ÷ Costs', 'Profit ÷ Assets', 'Tax ÷ Revenue'], 0, 'Gross margin shows profit after direct costs.'),
            ExamQuestion('Positive profit but no cash can happen because…', <String>['Customers have not paid yet', 'Profit is fake', 'Banks hide money', 'It cannot happen'], 0, 'Profit is not cash.'),
            ExamQuestion('ROI measures…', <String>['Return relative to the amount invested', 'Number of staff', 'Office size', 'Social media reach'], 0, 'ROI = gain ÷ cost.'),
            ExamQuestion('Money today is worth more than money tomorrow because of…', <String>['Time value of money', 'Superstition', 'Printing costs', 'Weather'], 0, 'You can invest money received earlier.'),
          ],
        ),
        Course(
          id: 'bu201',
          name: 'BUS201 Operations & Supply',
          skill: 'management',
          summary: 'Processes, quality and logistics.',
          questions: <ExamQuestion>[
            ExamQuestion('A bottleneck is…', <String>['The slowest step that limits output', 'A bottle shop', 'A manager', 'A spreadsheet'], 0, 'Improving the bottleneck raises throughput.'),
            ExamQuestion('Just-in-time inventory aims to…', <String>['Hold minimal stock, delivered when needed', 'Hoard goods', 'Hide inventory', 'Ignore suppliers'], 0, 'JIT reduces holding costs.'),
            ExamQuestion('Quality control checks…', <String>['That products meet standards', 'Employees\' hobbies', 'Only prices', 'Tax forms'], 0, 'QC catches defects.'),
            ExamQuestion('A supplier delay threatens your deadline. First you…', <String>['Communicate early and find alternatives', 'Hide it', 'Blame customers', 'Wait silently'], 0, 'Early, honest communication limits damage.'),
          ],
        ),
        Course(
          id: 'bu202',
          name: 'BUS202 Leadership & Organisational Behaviour',
          skill: 'management',
          summary: 'Motivation, teams and conflict.',
          questions: <ExamQuestion>[
            ExamQuestion('A good way to motivate a team is…', <String>['Clear goals, feedback and recognition', 'Threats only', 'No communication', 'Constantly changing goals'], 0, 'People respond to purpose, feedback and recognition.'),
            ExamQuestion('Healthy conflict resolution begins with…', <String>['Listening to each side', 'Taking sides', 'Ignoring it', 'Public blame'], 0, 'Understanding precedes solving.'),
            ExamQuestion('Psychological safety means…', <String>['People can speak up without fear of punishment', 'No rules', 'No deadlines', 'No feedback'], 0, 'It drives learning and honesty.'),
            ExamQuestion('Leaders earn trust mainly by…', <String>['Keeping promises and being transparent', 'Being loud', 'Being unreachable', 'Changing their story'], 0, 'Consistency builds trust.'),
          ],
        ),
      ],
    ),
    Degree(
      id: 'deg_law',
      name: 'Juris Doctor (Law)',
      shortName: 'Law',
      emoji: '⚖️',
      awardRank: 3,
      prereqRank: 2,
      careerId: 'lawyer',
      courses: <Course>[
        Course(
          id: 'lw101',
          name: 'LAW101 Contracts',
          skill: 'legal',
          tuition: 400,
          summary: 'Offer, acceptance, consideration and remedies.',
          questions: <ExamQuestion>[
            ExamQuestion('A valid contract generally needs offer, acceptance and…', <String>['Consideration', 'Notarised signature', 'A witness', 'A lawyer'], 0, 'Consideration is something of value exchanged.'),
            ExamQuestion('Breach of contract means…', <String>['Failing to perform without lawful excuse', 'Signing a contract', 'Reading a contract', 'Copying a contract'], 0, 'Breach is non-performance of obligations.'),
            ExamQuestion('A usual remedy for breach is…', <String>['Damages', 'Imprisonment', 'Loss of citizenship', 'Public apology only'], 0, 'Money damages compensate the loss.'),
            ExamQuestion('A penalty clause is generally…', <String>['Unenforceable if disproportionate', 'Always enforceable', 'Required in every contract', 'Criminal'], 0, 'Courts strike grossly disproportionate penalties.'),
          ],
        ),
        Course(
          id: 'lw102',
          name: 'LAW102 Criminal Law & Procedure',
          skill: 'legal',
          tuition: 400,
          summary: 'Elements of offences, burden of proof and fair trial.',
          questions: <ExamQuestion>[
            ExamQuestion('In criminal cases the burden of proof is on…', <String>['The prosecution', 'The defendant', 'The judge', 'The witness'], 0, 'The state must prove guilt.'),
            ExamQuestion('The standard of proof is…', <String>['Beyond reasonable doubt', 'More likely than not', 'Possible', 'Whatever the jury feels'], 0, 'Criminal convictions require the highest standard.'),
            ExamQuestion('Most offences require a guilty act and…', <String>['A guilty mind (mens rea)', 'A confession', 'A victim statement', 'A police officer'], 0, 'Actus reus + mens rea.'),
            ExamQuestion('The right to silence means…', <String>['You need not incriminate yourself', 'You must talk', 'The police may lie', 'Lawyers may not speak'], 0, 'It protects against self-incrimination.'),
          ],
        ),
        Course(
          id: 'lw103',
          name: 'LAW201 Torts',
          skill: 'legal',
          tuition: 400,
          summary: 'Negligence, duty of care and civil wrongs.',
          questions: <ExamQuestion>[
            ExamQuestion('Negligence requires duty, breach, causation and…', <String>['Damage', 'A trial', 'An apology', 'A contract'], 0, 'You need loss caused by the breach.'),
            ExamQuestion('The "reasonable person" test measures…', <String>['What a sensible person would have done', 'What the defendant wanted', 'What the judge prefers', 'Nothing'], 0, 'It is an objective standard.'),
            ExamQuestion('A tort is…', <String>['A civil wrong causing harm', 'A pastry', 'A criminal court', 'A type of contract'], 0, 'Tort law compensates civil wrongs.'),
            ExamQuestion('Contributory negligence reduces damages when…', <String>['The claimant was partly at fault', 'The defendant is rich', 'There is no evidence', 'The case is old'], 0, 'Shared fault reduces compensation.'),
          ],
        ),
        Course(
          id: 'lw104',
          name: 'LAW202 Legal Writing & Professional Ethics',
          skill: 'legal',
          tuition: 400,
          summary: 'Briefs, citation, confidentiality and conflicts.',
          questions: <ExamQuestion>[
            ExamQuestion('Client confidentiality means…', <String>['You do not disclose their information without consent or legal duty', 'You post their story', 'You tell the press', 'You share it with other clients'], 0, 'It is a fundamental duty.'),
            ExamQuestion('A conflict of interest arises when…', <String>['Duties to two clients or your own interests clash', 'You like your client', 'You win', 'You have a busy diary'], 0, 'Conflicts must be disclosed and managed.'),
            ExamQuestion('A good legal argument uses…', <String>['Facts, rules and reasoning (IRAC)', 'Insults', 'Rumour', 'Volume'], 0, 'Issue, Rule, Application, Conclusion.'),
            ExamQuestion('Duty to the court means you must not…', <String>['Knowingly mislead the court', 'Argue hard', 'Cross-examine', 'Request time'], 0, 'Advocacy has ethical limits.'),
          ],
        ),
      ],
    ),
    Degree(
      id: 'deg_medicine',
      name: 'Doctor of Medicine (MD)',
      shortName: 'Medicine',
      emoji: '⚕️',
      awardRank: 4,
      prereqRank: 2,
      careerId: 'doctor',
      courses: <Course>[
        Course(
          id: 'md101',
          name: 'MED101 Human Physiology & Pathology',
          skill: 'medicine',
          tuition: 450,
          summary: 'How organs work and how disease disrupts them.',
          questions: <ExamQuestion>[
            ExamQuestion('Insulin is produced by the…', <String>['Pancreas', 'Liver', 'Thyroid', 'Spleen'], 0, 'Beta cells in the pancreas make insulin.'),
            ExamQuestion('Hypertension means…', <String>['High blood pressure', 'Low blood sugar', 'High temperature', 'Low pulse'], 0, 'Persistently raised arterial pressure.'),
            ExamQuestion('Inflammation classically causes…', <String>['Redness, heat, swelling, pain', 'Cold, pale skin', 'Hair growth', 'Sleep'], 0, 'Rubor, calor, tumor, dolor.'),
            ExamQuestion('The kidneys mainly…', <String>['Filter blood and make urine', 'Make bile', 'Pump blood', 'Digest protein'], 0, 'Kidneys regulate fluid, electrolytes and waste.'),
          ],
        ),
        Course(
          id: 'md102',
          name: 'MED102 Clinical Skills & History Taking',
          skill: 'medicine',
          tuition: 450,
          summary: 'Interviewing, examining and documenting.',
          questions: <ExamQuestion>[
            ExamQuestion('A good history starts with…', <String>['Open questions about the main complaint', 'A test order', 'A prescription', 'Silence'], 0, 'Open questions let the patient tell their story.'),
            ExamQuestion('"SOCRATES" is a mnemonic for assessing…', <String>['Pain', 'Vision', 'Hearing', 'Nutrition'], 0, 'Site, Onset, Character, Radiation, Associations, Time, Exacerbating/relieving, Severity.'),
            ExamQuestion('Before examining a patient you should…', <String>['Introduce yourself, gain consent, wash hands', 'Start touching immediately', 'Take a photo', 'Ask them to leave'], 0, 'Consent and hygiene come first.'),
            ExamQuestion('Safety-netting advice tells patients…', <String>['When to seek help if symptoms worsen', 'To avoid doctors', 'To self-medicate', 'To stop treatment'], 0, 'It prevents delayed care.'),
          ],
        ),
        Course(
          id: 'md103',
          name: 'MED201 Pharmacology & Therapeutics',
          skill: 'medicine',
          tuition: 450,
          summary: 'Mechanisms, interactions and safe prescribing.',
          questions: <ExamQuestion>[
            ExamQuestion('Before prescribing you check…', <String>['Allergies, other medicines and kidney/liver function', 'The patient\'s favourite colour', 'Weather', 'Their phone model'], 0, 'Safe prescribing prevents harm.'),
            ExamQuestion('Antibiotics are effective against…', <String>['Bacteria', 'Viruses like the cold', 'Allergies', 'Fractures'], 0, 'They do not treat viral infections.'),
            ExamQuestion('Antibiotic resistance is made worse by…', <String>['Overuse and incomplete courses', 'Hand washing', 'Vaccination', 'Rest'], 0, 'Misuse selects resistant bacteria.'),
            ExamQuestion('A drug\'s half-life is…', <String>['Time for its concentration to fall by half', 'Half the dose', 'The time it takes to buy', 'The time to swallow'], 0, 'It guides dosing frequency.'),
          ],
        ),
        Course(
          id: 'md104',
          name: 'MED202 Internal Medicine',
          skill: 'medicine',
          tuition: 450,
          summary: 'Diagnostic reasoning in common adult illnesses.',
          questions: <ExamQuestion>[
            ExamQuestion('Crushing chest pain spreading to the arm suggests…', <String>['Acute coronary syndrome — treat as an emergency', 'Indigestion only', 'A pulled hair', 'Allergies'], 0, 'Think cardiac first.'),
            ExamQuestion('A differential diagnosis is…', <String>['A ranked list of possible causes', 'A final cure', 'A drug', 'A test result'], 0, 'It structures reasoning and testing.'),
            ExamQuestion('Order a test when…', <String>['The result will change management', 'Always, to be safe', 'The patient asks for every test', 'You are bored'], 0, 'Tests have costs and false positives.'),
            ExamQuestion('Very high glucose, ketones and acidosis indicates…', <String>['Diabetic ketoacidosis', 'A cold', 'Anaemia', 'Sunburn'], 0, 'DKA is a medical emergency.'),
          ],
        ),
        Course(
          id: 'md105',
          name: 'MED203 Medical Ethics & Communication',
          skill: 'medicine',
          tuition: 450,
          summary: 'Consent, capacity, bad news and professionalism.',
          questions: <ExamQuestion>[
            ExamQuestion('Valid consent requires…', <String>['Capacity, information and voluntariness', 'A relative\'s signature', 'Speed', 'Payment'], 0, 'Patients must understand and choose freely.'),
            ExamQuestion('A competent patient refuses surgery. You…', <String>['Respect it, document and keep offering care', 'Operate anyway', 'Discharge without advice', 'Ignore them'], 0, 'Autonomy is respected.'),
            ExamQuestion('Breaking bad news well includes…', <String>['Private setting, honesty, empathy and a plan', 'Doing it in a corridor', 'Using jargon', 'Avoiding questions'], 0, 'Compassion and clarity matter.'),
            ExamQuestion('When you make a mistake, you should…', <String>['Be open, apologise and report it', 'Hide it', 'Blame a nurse', 'Delete notes'], 0, 'A duty of candour exists.'),
          ],
        ),
      ],
    ),
  ];
}
