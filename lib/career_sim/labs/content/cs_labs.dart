import '../../engine/text_rubric.dart';
import '../../model/tasks.dart';
import '../lab_models.dart';
import 'gen_cs_core.dart';

// Computer Science labs. Programs, tests and SQL run on the student's device
// (web/code_runner) and are graded by the server judge's own harness.

const String _pyStdin = 'line = input()\n# Write your program here\n';
const String _jsStdin = "const input = require('fs').readFileSync(0, 'utf8').trim();\n// Write your program here\n";

String _fizz(int n) => <String>[
      for (int i = 1; i <= n; i++) i % 15 == 0 ? 'FizzBuzz' : i % 3 == 0 ? 'Fizz' : i % 5 == 0 ? 'Buzz' : '$i',
    ].join('\n');

/// The university database used in the Database Systems lab.
const String universityDb = '''
CREATE TABLE students (id INTEGER PRIMARY KEY, name TEXT NOT NULL, major TEXT NOT NULL, year INTEGER NOT NULL);
CREATE TABLE courses (code TEXT PRIMARY KEY, title TEXT NOT NULL, credits INTEGER NOT NULL);
CREATE TABLE enrollments (
  student_id INTEGER NOT NULL REFERENCES students(id),
  course_code TEXT NOT NULL REFERENCES courses(code),
  grade INTEGER,
  PRIMARY KEY (student_id, course_code)
);
INSERT INTO students VALUES
  (1, 'Ada Okafor', 'Computer Science', 2), (2, 'Ben Hart', 'Law', 1), (3, 'Chen Wei', 'Computer Science', 3),
  (4, 'Dana Ruiz', 'Nursing', 2), (5, 'Eli Novak', 'Computer Science', 1), (6, 'Fatima Bello', 'Accounting', 3),
  (7, 'Grace Lim', 'Law', 1);
INSERT INTO courses VALUES
  ('CS101', 'Programming Fundamentals', 15), ('CS201', 'Data Structures', 15), ('CS210', 'Database Systems', 15),
  ('LAW100', 'Legal Method', 15), ('ACC110', 'Bookkeeping', 10);
INSERT INTO enrollments VALUES
  (1, 'CS101', 78), (1, 'CS201', 85), (1, 'CS210', NULL), (2, 'LAW100', 64), (3, 'CS101', 91), (3, 'CS201', 72),
  (3, 'CS210', 88), (5, 'CS101', 55), (6, 'ACC110', 81), (4, 'CS101', 69);
''';

const List<LabPerson> _csPeople = <LabPerson>[
  LabPerson('Dr Lena Osei', 'Lecturer, Computer Science', 'Run your code often. The tests tell you what is wrong — not the answer.'),
  LabPerson('Tomás Reyes', 'Teaching assistant', 'If you are stuck, read the failing input and predict what your code does with it.'),
];

final LabSpec csFundamentalsLab = LabSpec(
  id: 'cs_lab_fundamentals',
  deptId: 'cs',
  majorId: 'computer_science',
  number: 1,
  title: 'Programming Fundamentals',
  environment: LabEnvironment.computingLab,
  summary: 'Write complete programs in Python or JavaScript, run them, read the output, fix errors and pass automated tests.',
  objectives: const <String>[
    'Read input and print formatted output',
    'Use conditionals and loops',
    'Write a function that passes hidden test cases',
  ],
  skills: const <String>['cs_prog', 'cs_debug'],
  difficulty: LabDifficulty.foundation,
  minutes: 45,
  scenarios: <LabScenario>[
    LabScenario(
      id: 'grades_tool',
      title: 'Student records helper',
      people: _csPeople,
      briefing: const Briefing(
        what: 'The registry office needs two small command-line tools and one reusable function.',
        why: 'Staff currently calculate averages and lists by hand, which causes errors in published results.',
        information: <String>[
          'Each tool reads its input from standard input and prints to standard output.',
          'Output must match exactly — spacing and capital letters count.',
        ],
        tools: <String>['Code editor (Python 3 or JavaScript)', 'Console to run programs with your own input', 'Automated tests'],
        expected: 'Programs that print the right output for every test input, and a function that passes the hidden tests.',
        requirements: <String>['Do not hard-code answers for the sample inputs — hidden inputs are used too.'],
      ),
      steps: <LabStep>[
        const ProgramStep(
          id: 'average',
          title: 'Average and result',
          instructions: 'Input: three marks on one line, separated by spaces (e.g. "70 80 90").\n'
              'Print the average to one decimal place on the first line, then PASS if the average is at least 50, otherwise FAIL.',
          skills: <String>['cs_prog'],
          starter: <String, String>{'python3': _pyStdin, 'javascript': _jsStdin},
          cases: <ProgramCase>[
            ProgramCase('70 80 90', '80.0\nPASS'),
            ProgramCase('40 50 45', '45.0\nFAIL'),
            ProgramCase('50 50 50', '50.0\nPASS'),
            ProgramCase('100 0 49', '49.7\nFAIL'),
          ],
        ),
        ProgramStep(
          id: 'fizzbuzz',
          title: 'Timetable labels (FizzBuzz)',
          instructions: 'Input: one whole number n. Print the numbers 1 to n, one per line, but print Fizz for multiples of 3, '
              'Buzz for multiples of 5 and FizzBuzz for multiples of both.',
          skills: const <String>['cs_prog'],
          starter: const <String, String>{'python3': _pyStdin, 'javascript': _jsStdin},
          cases: <ProgramCase>[ProgramCase('5', _fizz(5)), ProgramCase('15', _fizz(15)), ProgramCase('1', _fizz(1))],
        ),
        TaskStep(const CodeTaskSpec(
          id: 'pair_sum',
          title: 'Twin Sum Lookup',
          brief: 'Write the function. Run the sample tests, then submit for the hidden tests.',
          problemKey: 'impl:GGO-001',
          skills: <String>['cs_prog', 'cs_ds'],
        )),
      ],
    ),
    ...csLabFundamentalsExtra,
  ],
);

final LabSpec csAlgorithmsLab = LabSpec(
  id: 'cs_lab_dsa',
  deptId: 'cs',
  majorId: 'computer_science',
  number: 2,
  title: 'Data Structures and Algorithms',
  environment: LabEnvironment.computingLab,
  summary: 'Trace an algorithm step by step, then implement stack, search and sliding-window solutions against hidden tests.',
  objectives: const <String>['Trace binary search by hand', 'Use a stack for nested structure', 'Use a hash set for a sliding window'],
  skills: const <String>['cs_ds', 'cs_algo'],
  difficulty: LabDifficulty.intermediate,
  minutes: 60,
  prerequisites: const <String>['cs_lab_fundamentals'],
  scenarios: <LabScenario>[
    LabScenario(
      id: 'library_search',
      title: 'Library catalogue engine',
      people: _csPeople,
      briefing: const Briefing(
        what: 'Prove you understand the search the library uses, then implement three core routines.',
        why: 'The library catalogue has 200,000 records; a linear scan is too slow for the self-service kiosks.',
        information: <String>['Shelf numbers are sorted ascending.', 'The judge measures correctness on large inputs.'],
        tools: <String>['Interactive array tracer', 'Code editor and judge'],
        expected: 'A correct trace and three accepted solutions.',
      ),
      steps: <LabStep>[
        const SearchTraceStep(
          id: 'trace',
          title: 'Trace binary search',
          instructions: 'Find shelf 61. At each iteration tap the index binary search probes (mid = (lo + hi) // 2).',
          values: <int>[3, 8, 12, 17, 21, 26, 30, 34, 39, 44, 48, 53, 57, 61, 66],
          target: 61,
          skills: <String>['cs_algo'],
        ),
        TaskStep(const CodeTaskSpec(id: 'find_index', title: 'Shelf Finder', brief: 'Implement O(log n) search.', problemKey: 'impl:GGO-004', skills: <String>['cs_algo'])),
        TaskStep(const CodeTaskSpec(id: 'brackets', title: 'Bracket Inspector', brief: 'Use a stack.', problemKey: 'impl:GGO-002', skills: <String>['cs_ds'])),
        TaskStep(const CodeTaskSpec(id: 'unique_run', title: 'Longest unique run', brief: 'Use a sliding window.', problemKey: 'impl:GGO-102', skills: <String>['cs_ds', 'cs_algo'])),
      ],
    ),
    ...csLabDsaExtra,
  ],
);

final LabSpec csDatabaseLab = LabSpec(
  id: 'cs_lab_database',
  deptId: 'cs',
  majorId: 'computer_science',
  number: 3,
  title: 'Database Systems',
  environment: LabEnvironment.computingLab,
  summary: 'Query, change and design a real SQLite database: filters, joins, aggregates, inserts, updates, a new table and a broken query.',
  objectives: const <String>[
    'Write SELECT queries with WHERE, ORDER BY, JOIN and GROUP BY',
    'Change data safely with INSERT and UPDATE',
    'Design a table with keys and constraints',
    'Debug a query that returns the wrong rows',
  ],
  skills: const <String>['cs_db'],
  difficulty: LabDifficulty.intermediate,
  minutes: 60,
  database: universityDb,
  databaseTables: const <String>['students(id, name, major, year)', 'courses(code, title, credits)', 'enrollments(student_id, course_code, grade)'],
  scenarios: <LabScenario>[
    LabScenario(
      id: 'registry',
      title: 'University registry database',
      people: <LabPerson>[
        LabPerson('Priya Shah', 'Registry systems manager', 'Every change you make runs against a fresh copy of the registry, so experiment freely.'),
      ],
      briefing: Briefing(
        what: 'Answer the registry\'s data requests and make three changes to the database.',
        why: 'Course leaders need accurate enrolment numbers before the timetable is fixed.',
        information: <String>[
          'Tables: students, courses, enrollments (a NULL grade means not yet graded).',
          'Each run starts from the registry\'s original data.',
        ],
        tools: <String>['SQL workbench (SQLite)', 'Schema viewer'],
        expected: 'Each query returns exactly the required rows; each change leaves the database in the required state.',
        requirements: <String>['Change only the rows the request describes.'],
      ),
      steps: <LabStep>[
        SqlStep(
          id: 'cs_students',
          title: 'Filter and sort',
          instructions: 'List the names of Computer Science students, ordered by year (lowest first) and then by name.',
          ordered: true,
          expected: <List<Object?>>[<Object?>['Eli Novak'], <Object?>['Ada Okafor'], <Object?>['Chen Wei']],
          skills: <String>['cs_db'],
        ),
        SqlStep(
          id: 'course_counts',
          title: 'Join and count',
          instructions: 'For each course that has at least one enrolment, show the course code and the number of students enrolled.',
          expected: <List<Object?>>[
            <Object?>['ACC110', 1], <Object?>['CS101', 4], <Object?>['CS201', 2], <Object?>['CS210', 2], <Object?>['LAW100', 1],
          ],
          skills: <String>['cs_db'],
        ),
        SqlStep(
          id: 'averages',
          title: 'Aggregate across tables',
          instructions: 'Show each Computer Science student\'s name and their average grade, ignoring courses that are not graded yet.',
          expected: <List<Object?>>[<Object?>['Ada Okafor', 81.5], <Object?>['Chen Wei', 83.6667], <Object?>['Eli Novak', 55]],
          skills: <String>['cs_db'],
        ),
        SqlStep(
          id: 'enrol',
          title: 'Insert a record',
          instructions: 'Enrol Dana Ruiz (student id 4) in CS201. She has no grade yet.',
          check: 'SELECT student_id, course_code, grade FROM enrollments WHERE student_id = 4 ORDER BY course_code',
          ordered: true,
          expected: <List<Object?>>[<Object?>[4, 'CS101', 69], <Object?>[4, 'CS201', null]],
          skills: <String>['cs_db'],
        ),
        SqlStep(
          id: 'grade',
          title: 'Update a record',
          instructions: 'Ada Okafor\'s CS210 grade has been released: 90. Record it without changing any other grade.',
          check: 'SELECT student_id, course_code, grade FROM enrollments WHERE grade IS NOT NULL ORDER BY student_id, course_code',
          ordered: true,
          expected: <List<Object?>>[
            <Object?>[1, 'CS101', 78], <Object?>[1, 'CS201', 85], <Object?>[1, 'CS210', 90], <Object?>[2, 'LAW100', 64],
            <Object?>[3, 'CS101', 91], <Object?>[3, 'CS201', 72], <Object?>[3, 'CS210', 88], <Object?>[4, 'CS101', 69],
            <Object?>[5, 'CS101', 55], <Object?>[6, 'ACC110', 81],
          ],
          skills: <String>['cs_db'],
        ),
        SqlStep(
          id: 'advisors',
          title: 'Design a table',
          instructions: 'Create a table advisors with: id (integer primary key), name (text, required), and student_id (integer) referencing students.',
          check: "SELECT lower(name), upper(type), \"notnull\", pk FROM pragma_table_info('advisors') ORDER BY cid",
          ordered: true,
          expected: <List<Object?>>[<Object?>['id', 'INTEGER', 0, 1], <Object?>['name', 'TEXT', 1, 0], <Object?>['student_id', 'INTEGER', 0, 0]],
          skills: <String>['cs_db'],
        ),
        SqlStep(
          id: 'no_enrolments',
          title: 'Debug a query',
          instructions: 'This query should list students with no enrolments, but it returns nothing. Fix it.',
          starter: 'SELECT s.name\nFROM students s\nJOIN enrollments e ON e.student_id = s.id\nWHERE e.course_code IS NULL;',
          expected: <List<Object?>>[<Object?>['Grace Lim']],
          skills: <String>['cs_db', 'cs_debug'],
        ),
      ],
    ),
    ...csLabDatabaseExtra,
  ],
);

final LabSpec csSystemsLab = LabSpec(
  id: 'cs_lab_os',
  deptId: 'cs',
  majorId: 'computer_science',
  number: 4,
  title: 'Operating Systems and Computer Architecture',
  environment: LabEnvironment.computingLab,
  summary: 'Run a CPU scheduler and a page-replacement simulator by hand, and translate a virtual address.',
  objectives: const <String>[
    'Schedule processes with FCFS and SJF and compute waiting times',
    'Run FIFO and LRU page replacement',
    'Split a logical address into page number and offset',
  ],
  skills: const <String>['cs_os'],
  difficulty: LabDifficulty.intermediate,
  minutes: 50,
  scenarios: <LabScenario>[
    LabScenario(
      id: 'kernel_sim',
      title: 'Kernel simulator',
      people: _csPeople,
      briefing: const Briefing(
        what: 'Act as the operating system: dispatch processes, manage page frames and translate an address.',
        why: 'Scheduling and memory decisions decide whether a server feels fast or freezes under load.',
        information: <String>['All processes are CPU-bound; scheduling is non-preemptive.', 'Memory has 3 page frames.'],
        tools: <String>['Gantt chart builder', 'Page-frame simulator'],
        expected: 'Correct dispatch orders, waiting times, page faults and address split.',
      ),
      steps: <LabStep>[
        const SchedulingStep(
          id: 'fcfs',
          title: 'First-come, first-served',
          instructions: 'Dispatch the processes in FCFS order, then enter the average waiting time.',
          algorithm: SchedAlgorithm.fcfs,
          processes: <SchedProcess>[SchedProcess('P1', 0, 5), SchedProcess('P2', 1, 3), SchedProcess('P3', 2, 8), SchedProcess('P4', 3, 6)],
          skills: <String>['cs_os'],
        ),
        const SchedulingStep(
          id: 'sjf',
          title: 'Shortest job first',
          instructions: 'Same processes, non-preemptive SJF: when the CPU is free, pick the shortest job that has arrived.',
          algorithm: SchedAlgorithm.sjf,
          processes: <SchedProcess>[SchedProcess('P1', 0, 5), SchedProcess('P2', 1, 3), SchedProcess('P3', 2, 8), SchedProcess('P4', 3, 6)],
          skills: <String>['cs_os'],
        ),
        const PagingStep(
          id: 'fifo',
          title: 'FIFO page replacement',
          instructions: 'For each reference decide hit or fault; on a fault with full memory, choose which page to evict.',
          references: <int>[7, 0, 1, 2, 0, 3, 0, 4, 2, 3],
          frames: 3,
          algorithm: PagingAlgorithm.fifo,
          skills: <String>['cs_os'],
        ),
        const PagingStep(
          id: 'lru',
          title: 'LRU page replacement',
          instructions: 'The same reference string with least-recently-used replacement.',
          references: <int>[7, 0, 1, 2, 0, 3, 0, 4, 2, 3],
          frames: 3,
          algorithm: PagingAlgorithm.lru,
          skills: <String>['cs_os'],
        ),
        TaskStep(const NumericTaskSpec(
          id: 'address',
          title: 'Address translation',
          brief: 'Pages are 4 KB (4096 bytes). Translate logical address 20,500.',
          skills: <String>['cs_os'],
          givens: <Fact>[Fact('Page size', '4096 bytes'), Fact('Logical address', '20500')],
          parts: <NumericPart>[
            NumericPart('Page number', 5, method: 'Integer-divide the address by the page size.'),
            NumericPart('Offset within the page', 20, method: 'The remainder of that division.'),
          ],
        )),
      ],
    ),
    ...csLabOsExtra,
  ],
);

final LabSpec csProjectLab = LabSpec(
  id: 'cs_lab_project',
  deptId: 'cs',
  majorId: 'computer_science',
  number: 5,
  title: 'Software Project: Course Registration Core',
  environment: LabEnvironment.computingLab,
  summary: 'Build and document the core of a course-registration system; the finished project goes into your portfolio.',
  objectives: const <String>['Implement features to a specification', 'Pass hidden tests', 'Write a design note for reviewers'],
  skills: const <String>['cs_prog', 'cs_algo', 'cs_review'],
  difficulty: LabDifficulty.advanced,
  minutes: 90,
  prerequisites: const <String>['cs_lab_dsa'],
  addsToPortfolio: true,
  scenarios: <LabScenario>[
    LabScenario(
      id: 'registration',
      title: 'Registration service',
      people: const <LabPerson>[
        LabPerson('Marcus Webb', 'Product owner, Registry', 'Clashing timetable slots must be merged before students choose modules.'),
        ..._csPeople,
      ],
      briefing: const Briefing(
        what: 'Implement timetable-slot merging and the waitlist compaction routine, then write the design note.',
        why: 'Students are double-booked when overlapping lecture slots are treated as separate.',
        information: <String>['Slots are [start, end] pairs in minutes.', 'Waitlist positions that were cancelled are stored as 0.'],
        tools: <String>['Code editor and judge'],
        expected: 'Both features accepted by the judge and a design note that a reviewer can approve.',
      ),
      steps: <LabStep>[
        TaskStep(const CodeTaskSpec(id: 'merge_slots', title: 'Merge clashing slots', brief: 'Merge overlapping or touching slots.', problemKey: 'impl:GGO-103', skills: <String>['cs_algo'])),
        TaskStep(const CodeTaskSpec(id: 'compact', title: 'Compact the waitlist', brief: 'Move cancelled (0) positions to the back in place.', problemKey: 'impl:GGO-007', skills: <String>['cs_prog'])),
        TaskStep(const WrittenTaskSpec(
          id: 'design_note',
          title: 'Design note',
          brief: 'Explain the problem, your approach, complexity, how you tested it and one trade-off.',
          minWords: 90,
          skills: <String>['cs_review'],
          rubric: <Concept>[
            Concept('problem', 'The problem', <String>['problem', 'needed', 'requirement*', 'clash*', 'double booked']),
            Concept('approach', 'Your approach', <String>['approach', 'sort*', 'pass', 'pointer*', 'merge']),
            Concept('complexity', 'Complexity', <String>['o(n', 'linear', 'complexity']),
            Concept('testing', 'Testing', <String>['test*', 'edge case*', 'judge', 'hidden']),
            Concept('tradeoff', 'A trade-off', <String>['trade*', 'instead', 'memory', 'limitation', 'alternative']),
          ],
        )),
      ],
    ),
    ...csLabProjectExtra,
  ],
);

final List<LabSpec> csLabs = <LabSpec>[csFundamentalsLab, csAlgorithmsLab, csDatabaseLab, csSystemsLab, csProjectLab];
