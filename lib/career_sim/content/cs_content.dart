import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';
import 'cs_bugs.dart';

// Department of Computer Science: training, projects, certifications,
// postings, the technical interview and the engineering workplace.

const List<SkillDef> _skills = <SkillDef>[
  SkillDef('cs_prog', 'Programming fundamentals'),
  SkillDef('cs_ds', 'Data structures'),
  SkillDef('cs_algo', 'Algorithms & complexity'),
  SkillDef('cs_debug', 'Debugging & testing'),
  SkillDef('cs_review', 'Code review & collaboration'),
  SkillDef('cs_db', 'Databases & SQL'),
  SkillDef('cs_os', 'Operating systems'),
];

const ClassifyTaskSpec _complexity = ClassifyTaskSpec(
  id: 'complexity',
  title: 'Classify the running time',
  brief: 'For each snippet, choose its worst-case time complexity in terms of n = len(nums).',
  categories: <String>['O(1)', 'O(log n)', 'O(n)', 'O(n log n)', 'O(n²)'],
  style: ClassifyStyle.codeReview,
  skills: <String>['cs_algo'],
  items: <ClassifyItem>[
    ClassifyItem('return nums[0]', 'O(1)', 'Indexing an array is constant time.'),
    ClassifyItem('for x in nums:\n    total += x', 'O(n)', 'One pass over the input is linear.'),
    ClassifyItem('for i in range(n):\n    for j in range(i + 1, n):\n        if nums[i] + nums[j] == t: ...', 'O(n²)',
        'Two nested loops over the input are quadratic.'),
    ClassifyItem('lo, hi = 0, n - 1\nwhile lo <= hi:\n    mid = (lo + hi) // 2\n    ...halve the range', 'O(log n)',
        'Halving the search range each step is logarithmic.'),
    ClassifyItem('nums.sort()\nfor x in nums: ...', 'O(n log n)', 'Sorting dominates: n log n.'),
    ClassifyItem('seen = set()\nfor x in nums:\n    if x in seen: return True\n    seen.add(x)', 'O(n)',
        'Set membership is O(1) on average, so one pass is linear.'),
  ],
);

const TrainingModule _m1 = TrainingModule(
  id: 'cs_m1',
  title: 'Arrays, loops and hash maps',
  summary: 'Iterate over data efficiently and trade memory for speed with a hash map.',
  skills: <String>['cs_prog', 'cs_ds'],
  minutes: 40,
  lesson: <LessonSection>[
    LessonSection(
      'Why this matters at work',
      'Most production code reads a list of records and answers a question about it: which payments are duplicates, '
          'which two invoices add up to a refund, which user has the most logins. The difference between a loop inside a '
          'loop and a single pass with a hash map is the difference between a report that finishes in a second and one '
          'that times out at a million rows.',
    ),
    LessonSection(
      'The brute-force baseline',
      'Start by writing the simplest correct version. Checking every pair of elements takes n × (n − 1) / 2 comparisons, '
          'which is O(n²). It is correct, easy to test, and a useful reference when you optimise.',
      example: 'def pair_sum(nums, target):\n    for i in range(len(nums)):\n        for j in range(i + 1, len(nums)):\n'
          '            if nums[i] + nums[j] == target:\n                return [i, j]',
    ),
    LessonSection(
      'Trading memory for time',
      'A hash map (Python dict, JavaScript Map) stores key → value pairs with average O(1) lookup. While you walk the '
          'list once, remember what you have already seen. For each new element, ask the map whether its complement has '
          'appeared. One pass, O(n) time, O(n) extra memory.',
      example: 'seen = {}\nfor i, x in enumerate(nums):\n    need = target - x\n    if need in seen:\n        ...\n    seen[x] = i',
    ),
    LessonSection(
      'Edge cases an employer will test',
      'Empty input, a single element, duplicates (the same value twice), negative numbers and the largest allowed input. '
          'Write these down before you code; the hidden tests in the Code Bench include them.',
    ),
  ],
  practice: <TaskSpec>[
    CodeTaskSpec(
      id: 'pair_sum',
      title: 'Twin Sum Lookup',
      brief: 'Implement the single-pass version. The judge runs your code against hidden tests, including a large input.',
      problemKey: 'impl:GGO-001',
      skills: <String>['cs_prog', 'cs_ds'],
    ),
    _complexity,
  ],
);

const TrainingModule _m2 = TrainingModule(
  id: 'cs_m2',
  title: 'Stacks and string processing',
  summary: 'Use a stack to validate nested structure — the core of parsers, formatters and linters.',
  skills: <String>['cs_ds', 'cs_prog'],
  minutes: 35,
  lesson: <LessonSection>[
    LessonSection(
      'Last in, first out',
      'A stack supports push, pop and peek in O(1). It models anything that must be closed in the reverse order it was '
          'opened: brackets in code, HTML tags, nested function calls, undo history.',
    ),
    LessonSection(
      'Validating brackets',
      'Push every opening bracket. On a closing bracket, the top of the stack must be the matching opener; otherwise the '
          'text is invalid. At the end, the stack must be empty — leftovers mean something was never closed.',
      example: 'pairs = {")": "(", "]": "[", "}": "{"}\nstack = []\nfor ch in s:\n    if ch in "([{":\n        stack.append(ch)\n'
          '    elif not stack or stack.pop() != pairs[ch]:\n        return False\nreturn not stack',
    ),
    LessonSection(
      'Reading someone else\'s bug',
      'In industry you fix more code than you write. Read the failing case first, predict what the code will do with it, '
          'then find the line where your prediction and the code disagree. Change one thing at a time.',
    ),
  ],
  practice: <TaskSpec>[
    CodeTaskSpec(
      id: 'brackets',
      title: 'Bracket Inspector',
      brief: 'Write the validator from scratch.',
      problemKey: 'impl:GGO-002',
      skills: <String>['cs_ds'],
    ),
    CodeTaskSpec(
      id: 'brackets_debug',
      title: 'Fix the bracket matcher',
      brief: 'A teammate\'s validator accepts "(]" as valid. Find and fix the defect.',
      problemKey: 'impl:GGO-002',
      buggyStarter: bugBracketsIgnoresType,
      skills: <String>['cs_debug'],
    ),
  ],
);

const TrainingModule _m3 = TrainingModule(
  id: 'cs_m3',
  title: 'Debugging and testing',
  summary: 'Reproduce, isolate, fix and prove — the professional debugging loop.',
  skills: <String>['cs_debug'],
  minutes: 35,
  lesson: <LessonSection>[
    LessonSection(
      'Reproduce before you fix',
      'A bug you cannot reproduce is a bug you cannot prove you fixed. Turn the report into the smallest input that fails, '
          'and keep it as a regression test.',
    ),
    LessonSection(
      'Off-by-one errors in binary search',
      'Binary search is famous for boundary bugs. Decide whether your range is closed [lo, hi] or half-open [lo, hi) and '
          'make every update consistent with that choice. With a closed range, loop while lo <= hi and move to mid + 1 or '
          'mid − 1, never to mid.',
    ),
    LessonSection(
      'Choosing test cases',
      'Good tests cover the normal case, the boundaries (first, last, empty, one element), and the error cases. A test '
          'suite that only checks the happy path will let most production bugs through.',
    ),
  ],
  practice: <TaskSpec>[
    OrderTaskSpec(
      id: 'debug_loop',
      title: 'The debugging loop',
      brief: 'Put the steps of a professional bug fix in order.',
      skills: <String>['cs_debug'],
      steps: <String>[
        'Reproduce the failure with the reported input',
        'Reduce it to the smallest failing case',
        'Form a hypothesis about the faulty line',
        'Change one thing and re-run the failing case',
        'Add the case as a regression test',
        'Run the whole test suite before opening a pull request',
      ],
      why: 'Fixes are only trustworthy when the failure is reproduced first and the fix is proven by a test.',
    ),
    CodeTaskSpec(
      id: 'bsearch_debug',
      title: 'Fix the binary search',
      brief: 'The search misses targets when the range shrinks to one element. Correct the bounds.',
      problemKey: 'impl:GGO-004',
      buggyStarter: bugBinarySearchBounds,
      skills: <String>['cs_debug', 'cs_algo'],
    ),
    ClassifyTaskSpec(
      id: 'edge_cases',
      title: 'Which tests matter?',
      brief: 'A function returns the index of target in a sorted list, or -1. Classify each proposed test.',
      categories: <String>['Boundary case', 'Normal case', 'Error / not found'],
      skills: <String>['cs_debug'],
      items: <ClassifyItem>[
        ClassifyItem('nums = [], target = 3', 'Boundary case', 'An empty list is the smallest boundary.'),
        ClassifyItem('nums = [1, 4, 9, 12], target = 9', 'Normal case', 'A value in the middle of a typical list.'),
        ClassifyItem('nums = [1, 4, 9, 12], target = 1', 'Boundary case', 'The first element is a boundary.'),
        ClassifyItem('nums = [1, 4, 9, 12], target = 5', 'Error / not found', 'Absent values must return -1.'),
        ClassifyItem('nums = [7], target = 7', 'Boundary case', 'A single element is a boundary.'),
      ],
    ),
  ],
);

const TrainingModule _m4 = TrainingModule(
  id: 'cs_m4',
  title: 'Searching, sorting and complexity',
  summary: 'Choose the algorithm whose cost fits the data size.',
  skills: <String>['cs_algo'],
  minutes: 40,
  lesson: <LessonSection>[
    LessonSection(
      'Big-O as a budget',
      'An API with a 200 ms budget can afford about 10⁷ simple operations. With n = 10⁵ records, O(n log n) fits, O(n²) '
          'does not. Estimate before you code.',
    ),
    LessonSection(
      'Binary search on sorted data',
      'When data is sorted, you can discard half of it with each comparison: O(log n). Sorting first costs O(n log n), so '
          'it pays off when you will search many times.',
      example: 'lo, hi = 0, len(nums) - 1\nwhile lo <= hi:\n    mid = (lo + hi) // 2\n    if nums[mid] == target: return mid\n'
          '    if nums[mid] < target: lo = mid + 1\n    else: hi = mid - 1\nreturn -1',
    ),
    LessonSection(
      'Sorting intervals',
      'Many scheduling problems become simple after sorting by start time: overlapping intervals are then adjacent, and a '
          'single pass can merge them.',
    ),
  ],
  practice: <TaskSpec>[
    CodeTaskSpec(
      id: 'shelf_finder',
      title: 'Shelf Finder',
      brief: 'Implement O(log n) search.',
      problemKey: 'impl:GGO-004',
      skills: <String>['cs_algo'],
    ),
    NumericTaskSpec(
      id: 'budget',
      title: 'Will it fit the latency budget?',
      brief: 'Estimate operation counts to choose an algorithm.',
      skills: <String>['cs_algo'],
      givens: <Fact>[
        Fact('Records n', '100,000'),
        Fact('Budget', '10,000,000 simple operations'),
      ],
      parts: <NumericPart>[
        NumericPart('Pairwise comparisons for an O(n²) pair check, n(n−1)/2', 4999950000,
            method: 'Multiply n by n − 1 and divide by 2.'),
        NumericPart('Operations for one pass, O(n)', 100000, method: 'One operation per record.'),
        NumericPart('How many times larger is the O(n²) count than the budget? (n(n−1)/2 ÷ budget)', 499.995,
            relTol: 0.01, method: 'Divide the pair count by the budget.'),
      ],
    ),
  ],
);

const ClassifyTaskSpec _reviewRefunds = ClassifyTaskSpec(
  id: 'review_refunds',
  title: 'Review PR: refund batching',
  brief: 'Classify each line your reviewer flagged.',
  style: ClassifyStyle.codeReview,
  skills: <String>['cs_review'],
  exhibit: 'def batch_refunds(refunds, size=50):\n'
      '    batches = []\n'
      '    for i in range(0, len(refunds), size):\n'
      '        batches.append(refunds[i:i + size])\n'
      '    total = sum([r["amount"] for r in refunds])  # float cents\n'
      '    print("DEBUG", refunds)\n'
      '    password = "hunter2"\n'
      '    return batches, total',
  categories: <String>['Bug / correctness', 'Security', 'Maintainability', 'No issue'],
  items: <ClassifyItem>[
    ClassifyItem('for i in range(0, len(refunds), size): batches.append(refunds[i:i + size])', 'No issue',
        'Slicing in steps of size is correct and handles the final partial batch.'),
    ClassifyItem('total = sum(... r["amount"] ...)  # float cents', 'Bug / correctness',
        'Money held as floats accumulates rounding error; use integer cents or Decimal.'),
    ClassifyItem('print("DEBUG", refunds)', 'Security',
        'Logging full refund records leaks customer data into logs.'),
    ClassifyItem('password = "hunter2"', 'Security', 'Credentials must never be hard-coded in source.'),
    ClassifyItem('def batch_refunds(refunds, size=50)  — no docstring or tests in the PR', 'Maintainability',
        'Unexplained, untested code is hard to change safely.'),
  ],
);

const TrainingModule _m5 = TrainingModule(
  id: 'cs_m5',
  title: 'Code review and collaboration',
  summary: 'Review a pull request like a professional and describe your own changes clearly.',
  skills: <String>['cs_review'],
  minutes: 30,
  lesson: <LessonSection>[
    LessonSection(
      'What reviewers look for',
      'In order of importance: correctness (does it do what the ticket says, including edge cases), security (secrets, '
          'personal data, injection), maintainability (naming, tests, duplication) and style. Style comments are the least '
          'important and are usually automated.',
    ),
    LessonSection(
      'Writing a pull request description',
      'State what changed, why, how you tested it, and anything risky the reviewer should look at. A reviewer who has to '
          'guess your intent will either block the PR or miss the bug.',
      example: 'What: merge overlapping settlement windows before reconciliation.\nWhy: duplicates caused double counting (PAY-151).\n'
          'Testing: unit tests for touching, nested and disjoint windows; ran the full suite.\nRisk: input must be sorted; the '
          'function now sorts a copy.',
    ),
  ],
  practice: <TaskSpec>[
    _reviewRefunds,
    WrittenTaskSpec(
      id: 'pr_description',
      title: 'Write a pull request description',
      brief: 'You fixed the bracket validator from module 2. Write the PR description your reviewer will read.',
      skills: <String>['cs_review'],
      minWords: 50,
      maxWords: 250,
      rubric: <Concept>[
        Concept('what', 'What changed', <String>['changed', 'fixed', 'updated', 'replaced', 'now', 'added']),
        Concept('why', 'Why it was needed', <String>['because', 'bug', 'failed', 'incorrect', 'invalid', 'so that', 'caused']),
        Concept('test', 'How it was tested', <String>['test*', 'verified', 'ran', 'cases']),
        Concept('risk', 'Risks or what to review', <String>['risk*', 'review*', 'note', 'edge case*', 'watch', 'careful']),
      ],
    ),
  ],
);

const WrittenTaskSpec _writeUpRubricTemplate = WrittenTaskSpec(
  id: 'writeup',
  title: 'Project write-up',
  brief: 'Explain the problem, your approach, its complexity, how you tested it and one trade-off. '
      'Employers read this in your portfolio.',
  minWords: 90,
  maxWords: 400,
  skills: <String>['cs_review'],
  rubric: <Concept>[
    Concept('problem', 'The problem being solved', <String>['problem', 'needed', 'goal', 'requirement*', 'task']),
    Concept('approach', 'Your approach', <String>['approach', 'i used', 'algorithm', 'sort*', 'hash', 'stack', 'pass', 'pointer*']),
    Concept('complexity', 'Time or space complexity', <String>['o(n', 'o(1', 'o(log', 'linear', 'complexity', 'quadratic']),
    Concept('testing', 'How you tested it', <String>['test*', 'edge case*', 'verified', 'judge', 'hidden']),
    Concept('tradeoff', 'A trade-off or limitation', <String>['trade*', 'limitation', 'instead', 'memory', 'could improve', 'alternative']),
  ],
);

const ProjectSpec _p1 = ProjectSpec(
  id: 'cs_p1',
  title: 'Booking service core',
  brief: 'The facilities team needs the core of a booking service: merge overlapping room bookings and push cancelled '
      'slots (0) to the back of the queue without losing order. Both functions are graded by hidden tests.',
  requiresModules: <String>['cs_m1', 'cs_m2'],
  skills: <String>['cs_algo', 'cs_ds', 'cs_prog'],
  deliverables: <TaskSpec>[
    CodeTaskSpec(id: 'merge', title: 'Merge bookings', brief: 'Merge overlapping or touching bookings.', problemKey: 'impl:GGO-103'),
    CodeTaskSpec(id: 'zeros', title: 'Cancelled slots to the back', brief: 'Rearrange in place.', problemKey: 'impl:GGO-007'),
  ],
  writeUp: _writeUpRubricTemplate,
);

const ProjectSpec _p2 = ProjectSpec(
  id: 'cs_p2',
  title: 'Signal analytics module',
  brief: 'An IoT client wants two analytics: the best run of consecutive readings, and the longest stretch of unique '
      'signals. Ship both and document the design.',
  requiresModules: <String>['cs_m4'],
  skills: <String>['cs_algo', 'cs_ds'],
  deliverables: <TaskSpec>[
    CodeTaskSpec(id: 'streak', title: 'Best streak', brief: 'Largest sum of a consecutive run.', problemKey: 'impl:GGO-101'),
    CodeTaskSpec(id: 'unique', title: 'Unique run', brief: 'Longest run without repeats.', problemKey: 'impl:GGO-102'),
  ],
  writeUp: _writeUpRubricTemplate,
);

const Certification _certAlgo = Certification(
  id: 'cs_cert_algo',
  title: 'Algorithms Practitioner Certificate',
  issuer: 'GradeGlow Department of Computer Science',
  requiresModules: <String>['cs_m4'],
  tasks: <TaskSpec>[
    CodeTaskSpec(id: 'warmer', title: 'Warmer days', brief: 'Monotonic stack.', problemKey: 'impl:GGO-109'),
    CodeTaskSpec(id: 'coins', title: 'Fewest coins', brief: 'Dynamic programming.', problemKey: 'impl:GGO-105'),
    _complexity,
  ],
);

const Certification _certPractice = Certification(
  id: 'cs_cert_practice',
  title: 'Professional Software Practice Certificate',
  issuer: 'GradeGlow Department of Computer Science',
  requiresModules: <String>['cs_m3', 'cs_m5'],
  tasks: <TaskSpec>[
    CodeTaskSpec(
      id: 'kadane',
      title: 'Fix the best-streak function',
      brief: 'It returns 0 when every day is negative. Fix it.',
      problemKey: 'impl:GGO-101',
      buggyStarter: bugStreakAllNegative,
    ),
    _reviewRefunds,
    WrittenTaskSpec(
      id: 'incident',
      title: 'Incident summary',
      brief: 'Production returned wrong search results for 40 minutes because of an off-by-one bound. Write the incident '
          'summary for the engineering channel.',
      minWords: 70,
      rubric: <Concept>[
        Concept('impact', 'Impact and duration', <String>['minutes', 'users', 'customers', 'impact*', 'affected']),
        Concept('cause', 'Root cause', <String>['cause*', 'off by one', 'bound*', 'because']),
        Concept('fix', 'Fix applied', <String>['fix*', 'patched', 'deployed', 'rolled back', 'corrected']),
        Concept('prevent', 'Prevention', <String>['test*', 'prevent*', 'monitor*', 'alert*', 'regression']),
      ],
    ),
  ],
);

const Department computerScience = Department(
  id: 'cs',
  title: 'Computer Science',
  school: 'School of Computing',
  emoji: '💻',
  summary: 'Write and debug real code graded by a sandboxed judge, review pull requests and ship projects to your portfolio.',
  majors: <String>[
    'computer_science', 'software_engineering', 'artificial_intelligence', 'data_science', 'cybersecurity',
    'information_technology', 'web_development', 'mobile_app_development',
  ],
  skills: _skills,
  units: <DeptUnit>[
    DeptUnit(
      id: 'cs_studio',
      title: 'Software Foundations Studio',
      emoji: '⌨️',
      setting: 'Teaching lab with pair-programming benches, a shared CI board and the Code Bench judge.',
      modules: <TrainingModule>[_m1, _m2, _m3],
      projects: <ProjectSpec>[_p1],
    ),
    DeptUnit(
      id: 'cs_systems',
      title: 'Algorithms & Engineering Practice Lab',
      emoji: '🧮',
      setting: 'Upper-level lab: performance budgets, code review rotations and team pull requests.',
      modules: <TrainingModule>[_m4, _m5],
      projects: <ProjectSpec>[_p2],
    ),
  ],
  certifications: <Certification>[_certAlgo, _certPractice],
);

// ---------------------------------------------------------------- postings

const CompanyProfile _northwind = CompanyProfile(
  name: 'Northwind Pay',
  industry: 'Payments technology',
  about: 'Northwind Pay processes card and bank payments for 4,000 small businesses.',
  team: 'You would join the Payments Platform squad: five engineers, a product manager and a QA analyst. Interns are '
      'paired with a senior engineer who reviews every pull request.',
  training: 'Interns get a two-day onboarding, a named mentor, weekly 1:1s and a code-review rotation from week two.',
  culture: 'Small pull requests, blameless incident reviews and written design notes before big changes.',
  success: 'By the end of the internship we expect three merged tickets that pass review and tests, delivered on time, '
      'with clear handoff notes.',
  tools: 'Python and JavaScript services, Git with pull requests, a CI pipeline that runs all tests, and an issue tracker.',
  nextSteps: 'We make a decision within two working days of the interview and send the offer in writing.',
);

const CompanyProfile _helix = CompanyProfile(
  name: 'Helix Health Systems',
  industry: 'Healthcare software',
  about: 'Helix builds scheduling and records software used by 60 clinics.',
  team: 'Graduates rotate through two product teams of six, each with a tech lead and a clinical product owner.',
  training: 'A structured 12-month graduate programme with a mentor, quarterly reviews and paid certification time.',
  culture: 'Patient safety first: every change touching clinical data needs two reviewers and an automated test.',
  success: 'Graduates are expected to own small features end to end within their first three months.',
  tools: 'Python services, TypeScript front ends, Git, CI with mandatory tests, and feature flags.',
  nextSteps: 'Interview feedback within two working days; offers are made by the graduate programme lead.',
);

const CompanyProfile _orbit = CompanyProfile(
  name: 'Orbit Logistics',
  industry: 'Freight and logistics',
  about: 'Orbit routes 30,000 parcels a day across three regional hubs.',
  team: 'Junior developers join the Routing team: four engineers and a data analyst, led by a staff engineer.',
  training: 'On-the-job mentoring, monthly tech talks and a learning budget.',
  culture: 'Pragmatic and data-driven: we measure everything we ship.',
  success: 'Ship routing fixes safely and reduce on-call incidents in your area.',
  tools: 'Python, JavaScript, PostgreSQL, Git and a CI pipeline.',
  nextSteps: 'We decide within two working days after the technical interview.',
);

const List<JobPosting> csPostings = <JobPosting>[
  JobPosting(
    id: 'cs_intern_northwind',
    deptId: 'cs',
    company: _northwind,
    title: 'Software Engineering Intern',
    type: JobType.internship,
    stageOnHire: CareerStage.intern,
    description: 'A 12-week paid internship on the Payments Platform squad. You will ship real tickets, review code and '
        'take part in stand-ups.',
    responsibilities: <String>[
      'Implement small backend features from tickets',
      'Fix defects reported by QA and support',
      'Review teammates\' pull requests',
      'Write handoff notes for each change',
    ],
    qualifications: <String>[
      'Computer Science (or related) student with Trainee status',
      'Training in arrays/hash maps, stacks and debugging',
      'At least one portfolio project',
    ],
    experience: 'No professional experience required.',
    requirements: JobRequirements(
      modules: <String>['cs_m1', 'cs_m2', 'cs_m3'],
      skills: <String, int>{'cs_prog': 1, 'cs_ds': 1, 'cs_debug': 1},
      projects: 1,
      minStage: CareerStage.trainee,
    ),
    salaryMin: 3800,
    salaryMax: 4600,
    salaryPeriod: 'month',
    location: 'Hybrid · Leeds',
    openDay: 1,
    deadlineDay: 40,
    interviewPlanId: 'cs_tech',
    workplaceId: 'cs_northwind',
  ),
  JobPosting(
    id: 'cs_entry_northwind',
    deptId: 'cs',
    company: _northwind,
    title: 'Associate Software Engineer',
    type: JobType.entryLevel,
    stageOnHire: CareerStage.entryLevel,
    description: 'A permanent role on the Payments Platform squad for engineers who have completed an internship.',
    responsibilities: <String>[
      'Own tickets from design to deployment',
      'Fix production defects and write regression tests',
      'Review code and mentor interns',
    ],
    qualifications: <String>['Completed software internship', 'All CS training modules', 'Two portfolio projects'],
    experience: 'A completed internship in software engineering.',
    requirements: JobRequirements(
      modules: <String>['cs_m1', 'cs_m2', 'cs_m3', 'cs_m4', 'cs_m5'],
      skills: <String, int>{'cs_prog': 2, 'cs_ds': 2, 'cs_debug': 2, 'cs_review': 1},
      projects: 2,
      minStage: CareerStage.intern,
      completedInternship: true,
    ),
    salaryMin: 52000,
    salaryMax: 62000,
    location: 'Hybrid · Leeds',
    openDay: 1,
    deadlineDay: 55,
    interviewPlanId: 'cs_tech',
    workplaceId: 'cs_northwind',
  ),
  JobPosting(
    id: 'cs_grad_helix',
    deptId: 'cs',
    company: _helix,
    title: 'Graduate Software Engineer',
    type: JobType.graduate,
    stageOnHire: CareerStage.entryLevel,
    description: 'Join a 12-month graduate programme building clinical scheduling software.',
    responsibilities: <String>[
      'Build and test features in a regulated codebase',
      'Pair with senior engineers on clinical data changes',
      'Present your work at programme reviews',
    ],
    qualifications: <String>['All CS training modules', 'Two portfolio projects', 'Algorithms Practitioner Certificate'],
    experience: 'Internship preferred.',
    requirements: JobRequirements(
      modules: <String>['cs_m1', 'cs_m2', 'cs_m3', 'cs_m4', 'cs_m5'],
      skills: <String, int>{'cs_algo': 2, 'cs_ds': 2, 'cs_review': 1},
      projects: 2,
      minStage: CareerStage.trainee,
      certifications: <String>['cs_cert_algo'],
    ),
    salaryMin: 48000,
    salaryMax: 58000,
    location: 'On-site · Manchester',
    openDay: 1,
    deadlineDay: 50,
    interviewPlanId: 'cs_tech',
    workplaceId: 'cs_helix',
    shortlistMark: 72,
  ),
  JobPosting(
    id: 'cs_junior_orbit',
    deptId: 'cs',
    company: _orbit,
    title: 'Junior Software Developer',
    type: JobType.junior,
    stageOnHire: CareerStage.entryLevel,
    description: 'Work on the parcel routing engine and its internal tools.',
    responsibilities: <String>['Fix routing defects', 'Write data-processing jobs', 'Join the on-call rota after six months'],
    qualifications: <String>['Completed internship', 'Strong debugging skills'],
    experience: 'A completed internship or equivalent.',
    requirements: JobRequirements(
      modules: <String>['cs_m1', 'cs_m3', 'cs_m4'],
      skills: <String, int>{'cs_debug': 2, 'cs_algo': 1},
      projects: 1,
      minStage: CareerStage.intern,
      completedInternship: true,
    ),
    salaryMin: 50000,
    salaryMax: 60000,
    location: 'Remote · UK',
    openDay: 1,
    deadlineDay: 45,
    interviewPlanId: 'cs_tech',
    workplaceId: 'cs_orbit',
  ),
];

// ---------------------------------------------------------------- interview

const InterviewPlan csInterview = InterviewPlan(
  id: 'cs_tech',
  interviewer: 'Priya Natarajan',
  interviewerRole: 'Engineering Manager',
  opening: 'Thanks for coming in. We\'ll talk about your experience, do a short live coding exercise and a debugging '
      'question, and leave time for your questions.',
  maxQuestions: 8,
  main: <String>['cs_b1', 'cs_t1', 'cs_code', 'cs_t2', 'cs_dbg', 'cs_b2', 'cs_r1'],
  bank: <InterviewQuestion>[
    InterviewQuestion(
      id: 'cs_b1',
      prompt: 'Tell me about a project you built. What problem did it solve and what was your part?',
      competency: Competency.communication,
      behavioural: true,
      minWords: 40,
      probeId: 'cs_b1p',
      rubric: <Concept>[
        Concept('problem', 'The problem', <String>['problem', 'needed', 'goal', 'users', 'client']),
        Concept('tech', 'Technical approach', <String>['algorithm', 'sort*', 'hash', 'stack', 'function', 'api', 'python', 'javascript', 'data structure']),
        Concept('own', 'Your own contribution', <String>['i wrote', 'i built', 'i implemented', 'i designed', 'my part', 'i was responsible']),
      ],
    ),
    InterviewQuestion(
      id: 'cs_b1p',
      prompt: 'Be specific: which part did you personally write, and how did you know it worked?',
      competency: Competency.communication,
      minWords: 25,
      rubric: <Concept>[
        Concept('own', 'Personal contribution', <String>['i wrote', 'i built', 'i implemented', 'my code', 'i added']),
        Concept('verify', 'Evidence it worked', <String>['test*', 'judge', 'verified', 'cases', 'passed']),
      ],
    ),
    InterviewQuestion(
      id: 'cs_t1',
      prompt: 'What is the average time complexity of looking up a key in a hash map?',
      competency: Competency.technical,
      options: <String>['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
      correctOption: 0,
      stretchId: 'cs_t1s',
    ),
    InterviewQuestion(
      id: 'cs_t1s',
      prompt: 'And in the worst case, when many keys collide in one bucket, with chaining?',
      competency: Competency.technical,
      options: <String>['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
      correctOption: 2,
    ),
    InterviewQuestion(
      id: 'cs_code',
      prompt: 'Live coding: we store transaction IDs in a list. Write a function that returns true if any ID appears twice. '
          'Run it, then submit when you are confident.',
      competency: Competency.problemSolving,
      practical: CodeTaskSpec(
        id: 'iv_dupes',
        title: 'Duplicate transaction IDs',
        brief: 'Return true if any value appears at least twice.',
        problemKey: 'impl:GG-0006',
      ),
    ),
    InterviewQuestion(
      id: 'cs_t2',
      prompt: 'A test that passed yesterday fails today in CI. Walk me through how you would find the cause.',
      competency: Competency.problemSolving,
      minWords: 35,
      probeId: 'cs_t2p',
      stretchId: 'cs_t2s',
      rubric: <Concept>[
        Concept('reproduce', 'Reproduce it locally', <String>['reproduce', 'run it locally', 'rerun', 're-run', 'run the test']),
        Concept('diff', 'Look at what changed', <String>['what changed', 'diff', 'commit*', 'git log', 'recent change*', 'bisect']),
        Concept('isolate', 'Isolate the cause', <String>['isolate', 'narrow', 'smallest', 'log*', 'debugger', 'breakpoint', 'print']),
        Concept('fix', 'Fix and prove it', <String>['fix', 'regression test', 'add a test', 'verify', 'pass']),
      ],
    ),
    InterviewQuestion(
      id: 'cs_t2p',
      prompt: 'What would you look at first — the test, or the code that changed? Why?',
      competency: Competency.problemSolving,
      minWords: 20,
      rubric: <Concept>[
        Concept('diff', 'Recent changes', <String>['what changed', 'diff', 'commit*', 'recent']),
        Concept('reason', 'A reason', <String>['because', 'since', 'most likely', 'so that']),
      ],
    ),
    InterviewQuestion(
      id: 'cs_t2s',
      prompt: 'How would you stop this kind of regression reaching production again?',
      competency: Competency.technical,
      minWords: 20,
      rubric: <Concept>[
        Concept('ci', 'Automated tests in CI', <String>['ci', 'pipeline', 'automated test*', 'required check*']),
        Concept('review', 'Review or gating', <String>['review*', 'block* merge', 'branch protection', 'approval']),
        Concept('monitor', 'Monitoring', <String>['monitor*', 'alert*', 'feature flag*', 'canary']),
      ],
    ),
    InterviewQuestion(
      id: 'cs_dbg',
      prompt: 'This binary search sometimes loops forever:\n\nlo, hi = 0, len(a) - 1\nwhile lo <= hi:\n    mid = (lo + hi) // 2\n'
          '    if a[mid] < t: lo = mid\n    elif a[mid] > t: hi = mid - 1\n    else: return mid\n\nWhich line is the bug?',
      competency: Competency.technical,
      options: <String>[
        'while lo <= hi:',
        'mid = (lo + hi) // 2',
        'if a[mid] < t: lo = mid',
        'elif a[mid] > t: hi = mid - 1',
      ],
      correctOption: 2,
    ),
    InterviewQuestion(
      id: 'cs_b2',
      prompt: 'Tell me about a time you disagreed with a teammate about a technical decision. What happened?',
      competency: Competency.readiness,
      behavioural: true,
      minWords: 40,
      probeId: 'cs_b2p',
      rubric: <Concept>[
        Concept('listen', 'Listened to the other view', <String>['listened', 'understand* their', 'their point', 'asked why', 'perspective']),
        Concept('evidence', 'Used evidence, not opinion', <String>['data', 'benchmark*', 'test*', 'evidence', 'measured', 'prototype']),
        Concept('agree', 'Reached a decision', <String>['agreed', 'compromise', 'decided', 'consensus', 'went with']),
      ],
    ),
    InterviewQuestion(
      id: 'cs_b2p',
      prompt: 'Looking back, what would you do differently?',
      competency: Competency.readiness,
      minWords: 20,
      rubric: <Concept>[
        Concept('reflect', 'Reflection', <String>['differently', 'next time', 'would have', 'learned', 'earlier']),
      ],
    ),
    InterviewQuestion(
      id: 'cs_r1',
      prompt: 'A senior engineer leaves twelve comments on your pull request. How do you respond?',
      competency: Competency.readiness,
      minWords: 25,
      rubric: <Concept>[
        Concept('open', 'Treats feedback as useful', <String>['thank*', 'learn*', 'appreciate', 'useful', 'opportunity']),
        Concept('act', 'Works through it systematically', <String>['each comment', 'address*', 'fix*', 'update*', 'one by one', 'resolve*']),
        Concept('clarify', 'Asks when unclear', <String>['ask*', 'clarif*', 'discuss', 'question*']),
      ],
    ),
  ],
);

// ---------------------------------------------------------------- workplace

const List<AssignmentSpec> _csAssignments = <AssignmentSpec>[
  AssignmentSpec(
    id: 'cs_a1',
    title: 'PAY-112 · Flag duplicate transaction IDs',
    ticket: 'Support reports double charges. Before settlement we need a check that returns true when any transaction ID '
        'appears more than once in a batch.',
    acceptance: <String>['All hidden tests pass in the judge', 'Linear time on a 10⁵-item batch', 'Handoff note for QA'],
    task: CodeTaskSpec(id: 'dupes', title: 'Duplicate check', brief: 'Implement hasEchoValue.', problemKey: 'impl:GG-0006'),
  ),
  AssignmentSpec(
    id: 'cs_a2',
    title: 'PAY-130 · Receipt template validator rejects valid input',
    ticket: 'Receipt templates use nested placeholders. The validator lets templates with unclosed brackets through. Fix it.',
    acceptance: <String>['Debugged code passes all hidden tests', 'Handoff note explains the root cause'],
    task: CodeTaskSpec(
      id: 'brackets',
      title: 'Fix the validator',
      brief: 'Templates with an unclosed "(" pass validation. Fix bracketsOk.',
      problemKey: 'impl:GGO-002',
      buggyStarter: bugBracketsLeftover,
    ),
  ),
  AssignmentSpec(
    id: 'cs_a3',
    title: 'Review PR #418 · refund batching',
    ticket: 'Please review this PR before it merges. Classify every flagged line so the author knows what to fix.',
    acceptance: <String>['Every flagged line classified correctly', 'Handoff note summarising the review'],
    task: _reviewRefunds,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'cs_a4',
    title: 'PAY-151 · Merge overlapping settlement windows',
    ticket: 'Settlement windows overlap after a timezone change and are counted twice. Merge overlapping or touching '
        'windows before reconciliation.',
    acceptance: <String>['All hidden tests pass', 'Sorted output', 'Handoff note with test cases'],
    task: CodeTaskSpec(id: 'merge', title: 'Merge windows', brief: 'Merge intervals.', problemKey: 'impl:GGO-103'),
    deadlineDays: 3,
  ),
  AssignmentSpec(
    id: 'cs_a5',
    title: 'INC-77 · Ledger search returns the wrong row',
    ticket: 'Incident: the ledger lookup returns -1 for rows that exist. Fix the binary search bounds.',
    acceptance: <String>['All hidden tests pass', 'Incident note: cause, fix, prevention'],
    task: CodeTaskSpec(
      id: 'bsearch',
      title: 'Fix the search',
      brief: 'Fix findIndex.',
      problemKey: 'impl:GGO-004',
      buggyStarter: bugBinarySearchBounds,
    ),
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'cs_a6',
    title: 'PAY-170 · Move failed retries to the back',
    ticket: 'The retry queue must keep successful jobs in order and move failed slots (0) to the back, in place.',
    acceptance: <String>['All hidden tests pass', 'In-place, O(n)'],
    task: CodeTaskSpec(id: 'zeros', title: 'Retries to the back', brief: 'In-place partition.', problemKey: 'impl:GGO-007'),
  ),
  AssignmentSpec(
    id: 'cs_a7',
    title: 'PAY-188 · Longest burst of unique merchants',
    ticket: 'Fraud wants the longest stretch of consecutive transactions with no repeated merchant code.',
    acceptance: <String>['All hidden tests pass', 'Linear time'],
    task: CodeTaskSpec(id: 'unique', title: 'Unique run', brief: 'Sliding window.', problemKey: 'impl:GGO-102'),
    deadlineDays: 3,
  ),
  AssignmentSpec(
    id: 'cs_a8',
    title: 'PAY-201 · Daily balance swing',
    ticket: 'Finance wants the best single buy-then-sell swing in a series of daily balances.',
    acceptance: <String>['All hidden tests pass'],
    task: CodeTaskSpec(id: 'trade', title: 'Best swing', brief: 'One pass.', problemKey: 'impl:GGO-003'),
  ),
  AssignmentSpec(
    id: 'cs_lead1',
    title: 'Plan onboarding for two new interns',
    ticket: 'You are taking on two interns next week. Write the onboarding plan you will share with the team.',
    acceptance: <String>['Covers environment setup, first tickets, mentoring and how progress is reviewed'],
    leadership: true,
    deadlineDays: 3,
    task: WrittenTaskSpec(
      id: 'onboarding',
      title: 'Intern onboarding plan',
      brief: 'Write the plan.',
      minWords: 100,
      rubric: <Concept>[
        Concept('setup', 'Environment and access set-up', <String>['setup', 'set up', 'access', 'laptop', 'environment', 'accounts']),
        Concept('tickets', 'First tickets sized for success', <String>['first ticket*', 'starter', 'small', 'good first']),
        Concept('mentor', 'Mentoring and pairing', <String>['mentor*', 'pair*', 'buddy', '1:1', 'one to one']),
        Concept('review', 'How progress is reviewed', <String>['review*', 'feedback', 'check in', 'goals', 'evaluat*']),
      ],
    ),
  ),
];

const Map<CareerStage, String> _csTitles = <CareerStage, String>{
  CareerStage.intern: 'Software Engineering Intern',
  CareerStage.entryLevel: 'Associate Software Engineer',
  CareerStage.junior: 'Software Engineer I',
  CareerStage.experienced: 'Software Engineer II',
  CareerStage.senior: 'Senior Software Engineer',
  CareerStage.lead: 'Engineering Team Lead',
};

const List<WorkplaceDef> csWorkplaces = <WorkplaceDef>[
  WorkplaceDef(
    id: 'cs_northwind',
    deptId: 'cs',
    name: 'Northwind Pay — Payments Platform squad',
    environment: 'Open-plan engineering floor; daily stand-up at 9:30; tickets on the squad board; every change goes '
        'through a pull request and CI.',
    supervisor: 'Daniel Okafor',
    supervisorRole: 'Senior Engineer, intern supervisor',
    tools: <String>['Code Bench (sandboxed judge)', 'Git & pull requests', 'CI pipeline', 'Issue tracker'],
    assignments: _csAssignments,
    titles: _csTitles,
    returnOfferPostingId: 'cs_entry_northwind',
  ),
  WorkplaceDef(
    id: 'cs_helix',
    deptId: 'cs',
    name: 'Helix Health Systems — Scheduling team',
    environment: 'Regulated codebase: two reviewers on clinical-data changes, mandatory tests, weekly demo to clinicians.',
    supervisor: 'Grace Lindqvist',
    supervisorRole: 'Tech Lead',
    tools: <String>['Code Bench (sandboxed judge)', 'Git & pull requests', 'CI pipeline', 'Feature flags'],
    assignments: _csAssignments,
    titles: _csTitles,
  ),
  WorkplaceDef(
    id: 'cs_orbit',
    deptId: 'cs',
    name: 'Orbit Logistics — Routing team',
    environment: 'Remote-first team; tickets prioritised by on-call impact; metrics dashboard for every service.',
    supervisor: 'Marcus Webb',
    supervisorRole: 'Staff Engineer',
    tools: <String>['Code Bench (sandboxed judge)', 'Git & pull requests', 'CI pipeline', 'Metrics dashboard'],
    assignments: _csAssignments,
    titles: _csTitles,
  ),
];
