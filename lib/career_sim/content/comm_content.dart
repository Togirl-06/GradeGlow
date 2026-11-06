import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';

// English & Communication: editing, fact-checking, news and public
// communication, assessed against editorial standards.

const ClassifyTaskSpec _edit = ClassifyTaskSpec(
  id: 'edit',
  title: 'Edit the council briefing',
  brief: 'Classify each sentence from the draft.',
  skills: <String>['co_edit'],
  style: ClassifyStyle.document,
  categories: <String>['Grammar error', 'Ambiguous', 'Jargon / wordy', 'Correct'],
  items: <ClassifyItem>[
    ClassifyItem('The council have decided to close it\'s offices on Friday.', 'Grammar error', '"its" (possessive) not "it\'s".'),
    ClassifyItem('Residents who complained frequently received letters.', 'Ambiguous', '"frequently" can attach to complained or received.'),
    ClassifyItem('We will leverage synergies to operationalise a holistic waste paradigm.', 'Jargon / wordy', 'Say what will actually happen.'),
    ClassifyItem('Bins will be collected on Tuesdays from 3 March.', 'Correct', 'Clear and specific.'),
    ClassifyItem('Each of the libraries have new opening hours.', 'Grammar error', '"Each … has": the subject is singular.'),
  ],
);

const ClassifyTaskSpec _factCheck = ClassifyTaskSpec(
  id: 'fact_check',
  title: 'Fact-check the draft story',
  brief: 'Source: the council\'s published budget says spending on parks rises from £2.0m to £2.3m and library hours are unchanged. Classify each claim in the draft.',
  skills: <String>['co_research'],
  style: ClassifyStyle.document,
  categories: <String>['Supported by the source', 'Contradicted by the source', 'Not in the source — needs another source'],
  items: <ClassifyItem>[
    ClassifyItem('Parks spending rises by 15%.', 'Supported by the source', '£2.0m → £2.3m is a 15% rise.'),
    ClassifyItem('Library opening hours are being cut.', 'Contradicted by the source', 'The budget says they are unchanged.'),
    ClassifyItem('Most residents support the budget.', 'Not in the source — needs another source', 'Needs polling or consultation data.'),
    ClassifyItem('Parks spending will be £2.3m.', 'Supported by the source', 'Matches the published figure.'),
  ],
);

const WrittenTaskSpec _pressRelease = WrittenTaskSpec(
  id: 'press_release',
  title: 'Press release: new library hours',
  brief: 'Harbour City Council extends library opening to 8pm on weekdays from 1 April, funded by a £120,000 grant. Write the press release.',
  skills: <String>['co_write'],
  minWords: 100,
  rubric: <Concept>[
    Concept('lede', 'Lead with the news: who, what, when', <String>['from 1 april', '1 april', '8pm', 'extend*', 'harbour city council']),
    Concept('why', 'Why it matters to residents', <String>['residents', 'students', 'families', 'working', 'access']),
    Concept('funding', 'Funding detail', <String>['£120,000', '120,000', 'grant', 'funded']),
    Concept('quote', 'A quote with attribution', <String>['said', 'says', '"']),
    Concept('contact', 'Notes to editors / contact', <String>['contact', 'notes to editors', 'for more information', 'press office']),
  ],
);

const Department communication = Department(
  id: 'communication',
  title: 'English & Communication',
  school: 'School of English & Communication',
  emoji: '📰',
  summary: 'Edit, fact-check and write to professional editorial and public-sector standards.',
  majors: <String>['english', 'journalism', 'history', 'philosophy', 'sociology', 'anthropology', 'psychology'],
  skills: <SkillDef>[
    SkillDef('co_edit', 'Editing & style'),
    SkillDef('co_research', 'Research & verification'),
    SkillDef('co_write', 'Professional writing'),
  ],
  units: <DeptUnit>[
    DeptUnit(
      id: 'co_writing',
      title: 'Writing Centre',
      emoji: '✍️',
      setting: 'Editing desks with a house style guide and draft documents from real-world clients.',
      modules: <TrainingModule>[
        TrainingModule(
          id: 'co_m_edit',
          title: 'Editing for clarity',
          summary: 'Fix grammar, remove ambiguity and cut jargon.',
          skills: <String>['co_edit'],
          lesson: <LessonSection>[
            LessonSection('Clarity first', 'One idea per sentence; subject and verb close together; concrete words over abstract ones.'),
            LessonSection('Common errors', 'its/it\'s, subject–verb agreement with "each" and "every", misplaced modifiers.'),
            LessonSection('Plain English', 'Replace jargon with what will happen, to whom, and when.'),
          ],
          practice: <TaskSpec>[_edit],
        ),
      ],
    ),
    DeptUnit(
      id: 'co_newsroom',
      title: 'Media Newsroom',
      emoji: '🗞️',
      setting: 'A working newsroom with a news desk, a fact-check desk and the press office line.',
      modules: <TrainingModule>[
        TrainingModule(
          id: 'co_m_news',
          title: 'Verification and news writing',
          summary: 'Check claims against sources and write news that leads with what matters.',
          skills: <String>['co_research', 'co_write'],
          lesson: <LessonSection>[
            LessonSection('Verification', 'Every factual claim needs a source. If the source says the opposite, the claim goes. If the source is silent, find another or cut it.'),
            LessonSection('The inverted pyramid', 'Lead with who, what, when and why it matters; supporting detail and quotes follow; background last.'),
          ],
          practice: <TaskSpec>[_factCheck, _pressRelease],
        ),
      ],
      projects: <ProjectSpec>[
        ProjectSpec(
          id: 'co_p1',
          title: 'Budget explainer package',
          brief: 'Verify the budget story and publish an explainer for residents.',
          requiresModules: <String>['co_m_news'],
          skills: <String>['co_research', 'co_write'],
          deliverables: <TaskSpec>[_factCheck],
          writeUp: WrittenTaskSpec(
            id: 'explainer',
            title: 'Explainer article',
            brief: 'Write a 150–300 word explainer of what the budget means for residents.',
            minWords: 120,
            rubric: <Concept>[
              Concept('parks', 'Parks figures', <String>['parks', '£2.3m', '2.3m', '15%']),
              Concept('libraries', 'Library hours unchanged', <String>['librar*', 'unchanged', 'no change']),
              Concept('resident', 'What it means for residents', <String>['residents', 'you', 'means']),
              Concept('source', 'Cites the source', <String>['budget', 'according to', 'published']),
            ],
          ),
        ),
      ],
    ),
  ],
  certifications: <Certification>[
    Certification(
      id: 'co_cert_editorial',
      title: 'Editorial Standards Certificate',
      issuer: 'GradeGlow School of English & Communication',
      requiresModules: <String>['co_m_edit', 'co_m_news'],
      tasks: <TaskSpec>[_edit, _factCheck],
    ),
  ],
);

const CompanyProfile _council = CompanyProfile(
  name: 'Harbour City Council',
  industry: 'Local government',
  about: 'A unitary council serving 310,000 residents.',
  team: 'The communications team has six officers, a digital lead and a head of communications.',
  training: 'Mentoring, media-law training and a professional communications qualification.',
  culture: 'Accurate, accessible public information; everything is checked before it is published.',
  success: 'Accurate, on-time releases that residents understand and journalists can use.',
  tools: 'Content management system, social scheduling tool, media monitoring.',
  nextSteps: 'We will confirm within two working days.',
);

const List<JobPosting> commPostings = <JobPosting>[
  JobPosting(
    id: 'co_intern_council',
    deptId: 'communication',
    company: _council,
    title: 'Communications Intern',
    type: JobType.internship,
    stageOnHire: CareerStage.intern,
    description: 'A placement in the council press office.',
    responsibilities: <String>['Draft releases and web copy', 'Fact-check content', 'Monitor media coverage'],
    qualifications: <String>['Student with Trainee status', 'Editing and news training'],
    experience: 'None required.',
    requirements: JobRequirements(
      modules: <String>['co_m_edit', 'co_m_news'],
      skills: <String, int>{'co_edit': 1, 'co_write': 1},
      projects: 1,
      minStage: CareerStage.trainee,
    ),
    salaryMin: 2400,
    salaryMax: 2650,
    salaryPeriod: 'month',
    location: 'Hybrid · Harbour City',
    openDay: 1,
    deadlineDay: 40,
    interviewPlanId: 'co_iv',
    workplaceId: 'co_council',
  ),
  JobPosting(
    id: 'co_officer_council',
    deptId: 'communication',
    company: _council,
    title: 'Communications Officer',
    type: JobType.entryLevel,
    stageOnHire: CareerStage.entryLevel,
    description: 'A permanent role in the press office.',
    responsibilities: <String>['Handle media enquiries', 'Run campaigns', 'Write releases and web content'],
    qualifications: <String>['Completed placement', 'Editorial Standards Certificate'],
    experience: 'A completed communications placement.',
    requirements: JobRequirements(
      modules: <String>['co_m_edit', 'co_m_news'],
      skills: <String, int>{'co_edit': 2, 'co_write': 2, 'co_research': 1},
      projects: 1,
      minStage: CareerStage.intern,
      certifications: <String>['co_cert_editorial'],
      completedInternship: true,
    ),
    salaryMin: 34500,
    salaryMax: 39500,
    location: 'Hybrid · Harbour City',
    openDay: 1,
    deadlineDay: 55,
    interviewPlanId: 'co_iv',
    workplaceId: 'co_council',
  ),
];

const InterviewPlan commInterview = InterviewPlan(
  id: 'co_iv',
  interviewer: 'Joanna Price',
  interviewerRole: 'Head of Communications',
  opening: 'Hello. I\'ll set you an editing exercise and ask how you\'d handle the press.',
  main: <String>['co_q1', 'co_editx', 'co_q2', 'co_q3'],
  bank: <InterviewQuestion>[
    InterviewQuestion(
      id: 'co_q1',
      prompt: 'Tell me about a piece of writing you are proud of and who it was for.',
      competency: Competency.communication,
      behavioural: true,
      minWords: 35,
      rubric: <Concept>[
        Concept('audience', 'Audience', <String>['audience', 'readers', 'for', 'residents', 'students']),
        Concept('impact', 'Impact', <String>['feedback', 'published', 'read', 'impact', 'response']),
      ],
    ),
    InterviewQuestion(
      id: 'co_editx',
      prompt: 'Exercise: edit this draft.',
      competency: Competency.technical,
      practical: _edit,
    ),
    InterviewQuestion(
      id: 'co_q2',
      prompt: 'A journalist rings with a claim you can\'t verify and a 30-minute deadline. What do you do?',
      competency: Competency.problemSolving,
      minWords: 30,
      probeId: 'co_q2p',
      rubric: <Concept>[
        Concept('verify', 'Doesn\'t confirm what isn\'t verified', <String>['verify', 'check', 'not confirm', 'can\'t confirm', 'cannot confirm']),
        Concept('respond', 'Responds within the deadline', <String>['holding statement', 'call back', 'within', 'deadline', 'get back']),
        Concept('escalate', 'Involves the right people', <String>['head of', 'service', 'manager', 'escalat*', 'legal']),
      ],
    ),
    InterviewQuestion(
      id: 'co_q2p',
      prompt: 'What goes in a holding statement?',
      competency: Competency.technical,
      minWords: 15,
      rubric: <Concept>[
        Concept('aware', 'Acknowledges and states what is known', <String>['aware', 'looking into', 'known', 'confirm']),
        Concept('update', 'Promises an update', <String>['update', 'more information', 'as soon as']),
      ],
    ),
    InterviewQuestion(
      id: 'co_q3',
      prompt: 'Which belongs in the first paragraph of a press release?',
      competency: Competency.technical,
      options: <String>['Background history', 'Who, what, when and why it matters', 'Contact details', 'A long quote'],
      correctOption: 1,
    ),
  ],
);

const List<AssignmentSpec> _coAssignments = <AssignmentSpec>[
  AssignmentSpec(id: 'co_a1', title: 'Edit · services briefing', ticket: 'Edit the draft before it goes to the leader.',
      acceptance: <String>['Every sentence classified correctly'], task: _edit, deadlineDays: 1),
  AssignmentSpec(id: 'co_a2', title: 'Release · library hours', ticket: 'Write the press release for the new library hours.',
      acceptance: <String>['News-led, accurate, quoted, contact details'], task: _pressRelease),
  AssignmentSpec(id: 'co_a3', title: 'Verify · local paper\'s budget story', ticket: 'Check the paper\'s claims against the budget.',
      acceptance: <String>['Every claim classified correctly'], task: _factCheck, deadlineDays: 1),
  AssignmentSpec(
    id: 'co_a4',
    title: 'Social · bin collection change',
    ticket: 'Write the web notice for residents about the new bin day.',
    acceptance: <String>['Plain English, date, what to do, where to find out more'],
    task: WrittenTaskSpec(
      id: 'bin_notice',
      title: 'Web notice',
      brief: 'Bins move from Monday to Tuesday from 3 March. Garden waste is unaffected. Write the notice.',
      minWords: 60,
      maxWords: 200,
      rubric: <Concept>[
        Concept('change', 'The change', <String>['tuesday', 'from 3 march', '3 march']),
        Concept('unaffected', 'What is unaffected', <String>['garden waste', 'unaffected', 'not change']),
        Concept('action', 'What residents should do', <String>['put your bin', 'leave your bin', 'please', 'by 7am']),
        Concept('more', 'Where to find out more', <String>['website', 'call', 'find out more', 'visit']),
      ],
    ),
  ),
  AssignmentSpec(
    id: 'co_lead1',
    title: 'Lead the campaign plan',
    ticket: 'Plan the recycling campaign with two officers.',
    acceptance: <String>['Audience, messages, channels, timeline, measurement'],
    leadership: true,
    deadlineDays: 3,
    task: WrittenTaskSpec(
      id: 'campaign_plan',
      title: 'Campaign plan',
      brief: 'Write the plan.',
      minWords: 90,
      rubric: <Concept>[
        Concept('aud', 'Audience', <String>['audience', 'residents', 'target']),
        Concept('msg', 'Key messages', <String>['message*']),
        Concept('channel', 'Channels', <String>['channel*', 'social', 'website', 'press', 'leaflet*']),
        Concept('measure', 'Measurement', <String>['measure*', 'kpi*', 'evaluat*', 'track*']),
      ],
    ),
  ),
];

const List<WorkplaceDef> commWorkplaces = <WorkplaceDef>[
  WorkplaceDef(
    id: 'co_council',
    deptId: 'communication',
    name: 'Harbour City Council — Press Office',
    environment: 'Morning media briefing; enquiries logged with deadlines; every release approved by the head of communications.',
    supervisor: 'Joanna Price',
    supervisorRole: 'Head of Communications',
    tools: <String>['Content management system', 'Media enquiry log', 'House style guide'],
    assignments: _coAssignments,
    titles: <CareerStage, String>{
      CareerStage.intern: 'Communications Intern',
      CareerStage.entryLevel: 'Communications Officer',
      CareerStage.junior: 'Communications Officer II',
      CareerStage.experienced: 'Senior Communications Officer',
      CareerStage.senior: 'Communications Manager',
      CareerStage.lead: 'Head of Communications',
    },
    returnOfferPostingId: 'co_officer_council',
  ),
];
