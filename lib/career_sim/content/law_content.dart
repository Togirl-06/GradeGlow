import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';

// School of Law: issue spotting, contract analysis, written advice and
// courtroom advocacy (objections during live testimony).

const List<SkillDef> _skills = <SkillDef>[
  SkillDef('law_analysis', 'Legal analysis (IRAC)'),
  SkillDef('law_contract', 'Contract law'),
  SkillDef('law_evidence', 'Evidence & advocacy'),
  SkillDef('law_writing', 'Legal writing'),
];

const List<String> _grounds = <String>['Leading', 'Hearsay', 'Speculation', 'Relevance', 'Argumentative'];

const CourtroomTaskSpec _haleTrial = CourtroomTaskSpec(
  id: 'hale_trial',
  title: 'R v Hale — examination of PC Dawson',
  brief: 'You act for the defence. Prosecution counsel examines the arresting officer. Object when — and only when — there '
      'are grounds.',
  caseName: 'R v Hale (theft from a shop, Crown Court)',
  role: 'Defence counsel',
  grounds: _grounds,
  skills: <String>['law_evidence'],
  transcript: <TranscriptLine>[
    TranscriptLine('Prosecution', 'Officer, where were you at 14:10 on 3 March?', null,
        'An open question about the witness\'s own observations is proper.'),
    TranscriptLine('Prosecution', 'And you saw the defendant put the watch in his pocket, didn\'t you?', 'Leading',
        'In examination-in-chief counsel may not suggest the answer on a disputed fact.'),
    TranscriptLine('PC Dawson', 'The store manager told me she\'d seen him steal from them before.', 'Hearsay',
        'An out-of-court statement offered for its truth; the manager is not before the court.'),
    TranscriptLine('Prosecution', 'What did you see the defendant do next?', null, 'Open, non-leading question.'),
    TranscriptLine('Prosecution', 'Why do you think he wanted the watch?', 'Speculation',
        'The officer cannot give evidence about the defendant\'s state of mind.'),
    TranscriptLine('Prosecution', 'Is it right that the defendant once received a parking fine in 2015?', 'Relevance',
        'An old parking fine has no bearing on whether he stole the watch.'),
    TranscriptLine('Prosecution', 'Did you search him at the scene?', null, 'Proper question about the officer\'s actions.'),
  ],
);

const ClassifyTaskSpec _issues = ClassifyTaskSpec(
  id: 'issues',
  title: 'Spot the issues: café dispute',
  brief: 'Read the client\'s account and classify each fact by the legal issue it raises.',
  skills: <String>['law_analysis'],
  style: ClassifyStyle.document,
  exhibit: 'Client (Ms Rahman, café owner): "I emailed BrewCo accepting their offer of a coffee machine for £4,000. They '
      'delivered a different model. It broke and scalded my barista. When I complained, their manager posted online that '
      'I serve mouldy food, which is untrue, and bookings fell."',
  categories: <String>['Contract — formation/terms', 'Contract — breach', 'Negligence', 'Defamation'],
  items: <ClassifyItem>[
    ClassifyItem('Email accepting the offer of a machine for £4,000', 'Contract — formation/terms', 'Offer + acceptance + consideration forms the contract.'),
    ClassifyItem('A different model was delivered', 'Contract — breach', 'Goods not matching the description breach the contract.'),
    ClassifyItem('The machine scalded the barista', 'Negligence', 'Personal injury from a defective product raises a duty of care issue.'),
    ClassifyItem('Manager\'s untrue online post about mouldy food', 'Defamation', 'A false published statement harming reputation.'),
    ClassifyItem('Bookings fell after the post', 'Defamation', 'Serious financial loss supports the defamation claim.'),
  ],
);

const TrainingModule _m1 = TrainingModule(
  id: 'law_m1',
  title: 'Issue spotting and IRAC',
  summary: 'Turn a client\'s story into legal issues and structured advice.',
  skills: <String>['law_analysis', 'law_writing'],
  lesson: <LessonSection>[
    LessonSection('IRAC',
        'Issue: the legal question. Rule: the law that answers it, with authority. Application: apply the rule to these '
            'facts, including the counter-arguments. Conclusion: a clear answer and its likelihood.'),
    LessonSection('Reading client facts',
        'Clients tell stories, not issues. Read once for the story, then again sentence by sentence asking "does this fact '
            'create, prove or defeat a legal claim?"'),
  ],
  practice: <TaskSpec>[
    _issues,
    WrittenTaskSpec(
      id: 'irac_memo',
      title: 'IRAC: the wrong coffee machine',
      brief: 'Write an IRAC analysis of whether BrewCo breached the contract by delivering a different model.',
      skills: <String>['law_analysis', 'law_writing'],
      minWords: 90,
      rubric: <Concept>[
        Concept('issue', 'States the issue', <String>['issue', 'whether']),
        Concept('rule', 'States the rule', <String>['description', 'implied term', 'sale of goods', 'consumer rights act', 'rule', 'law']),
        Concept('apply', 'Applies it to the facts', <String>['here', 'in this case', 'different model', 'brewco delivered', 'on these facts']),
        Concept('counter', 'Considers a counter-argument', <String>['however', 'may argue', 'although', 'counter*']),
        Concept('conclude', 'Concludes', <String>['therefore', 'conclusion', 'likely', 'in conclusion']),
      ],
    ),
  ],
);

const TrainingModule _m2 = TrainingModule(
  id: 'law_m2',
  title: 'Contract formation and terms',
  summary: 'Offer, acceptance, consideration and the terms that bind the parties.',
  skills: <String>['law_contract'],
  lesson: <LessonSection>[
    LessonSection('Offer and invitation to treat',
        'An offer is a definite promise to be bound on specific terms. Price tags and adverts are usually invitations to '
            'treat. Acceptance must mirror the offer; a counter-offer destroys the original offer.'),
    LessonSection('Consideration and intention',
        'Each side must give something of value. Commercial agreements are presumed to be intended to create legal relations.'),
  ],
  practice: <TaskSpec>[
    ClassifyTaskSpec(
      id: 'offer_or_not',
      title: 'Offer or not?',
      brief: 'Classify each communication.',
      categories: <String>['Offer', 'Invitation to treat', 'Counter-offer', 'Acceptance'],
      skills: <String>['law_contract'],
      items: <ClassifyItem>[
        ClassifyItem('A shop window display with a price tag', 'Invitation to treat', 'Displays invite customers to make offers.'),
        ClassifyItem('"I will sell you my van for £6,000 — reply by Friday."', 'Offer', 'Definite terms and a willingness to be bound.'),
        ClassifyItem('"I\'ll take it for £5,500."', 'Counter-offer', 'Changing the price rejects the original offer.'),
        ClassifyItem('"Agreed — £6,000, I\'ll collect Saturday."', 'Acceptance', 'Unconditional agreement to the offer\'s terms.'),
        ClassifyItem('A catalogue listing prices', 'Invitation to treat', 'Catalogues are generally invitations to treat.'),
      ],
    ),
  ],
);

const TrainingModule _m3 = TrainingModule(
  id: 'law_m3',
  title: 'Evidence and objections',
  summary: 'Know when testimony is inadmissible and object at the right moment.',
  skills: <String>['law_evidence'],
  lesson: <LessonSection>[
    LessonSection('Leading questions',
        'In examination-in-chief you may not suggest the answer on a disputed matter ("You saw him take it, didn\'t you?"). '
            'In cross-examination leading is allowed.'),
    LessonSection('Hearsay',
        'A statement made outside court, repeated to prove that it is true, is hearsay and generally inadmissible unless an '
            'exception applies.'),
    LessonSection('Speculation and relevance',
        'Witnesses give evidence of what they perceived, not guesses about others\' thoughts. Evidence must make a fact in '
            'issue more or less likely.'),
    LessonSection('Judgement',
        'Objecting to proper questions loses credibility with the judge and jury. Object only when you have a ground.'),
  ],
  practice: <TaskSpec>[_haleTrial],
);

const Department law = Department(
  id: 'law',
  title: 'Law',
  school: 'School of Law',
  emoji: '⚖️',
  summary: 'Analyse real-style case files, draft advice and argue in the moot courtroom.',
  majors: <String>['introduction_to_law', 'criminal_justice', 'public_policy', 'political_science', 'international_relations'],
  skills: _skills,
  units: <DeptUnit>[
    DeptUnit(
      id: 'law_library',
      title: 'Legal Research Library',
      emoji: '📚',
      setting: 'Case files, statute books and a drafting desk.',
      modules: <TrainingModule>[_m1, _m2],
    ),
    DeptUnit(
      id: 'law_court',
      title: 'Moot Courtroom',
      emoji: '🏛️',
      setting: 'A full courtroom: bench, witness box, counsel\'s row and a transcript feed.',
      modules: <TrainingModule>[_m3],
      projects: <ProjectSpec>[
        ProjectSpec(
          id: 'law_p1',
          title: 'Mock trial: R v Hale',
          brief: 'Defend Mr Hale: handle the officer\'s evidence-in-chief and deliver a closing speech.',
          requiresModules: <String>['law_m1', 'law_m3'],
          skills: <String>['law_evidence', 'law_analysis', 'law_writing'],
          deliverables: <TaskSpec>[_haleTrial],
          writeUp: WrittenTaskSpec(
            id: 'closing',
            title: 'Closing speech',
            brief: 'Write your closing speech to the jury.',
            minWords: 100,
            rubric: <Concept>[
              Concept('burden', 'Burden and standard of proof', <String>['burden', 'beyond reasonable doubt', 'sure', 'prosecution must prove']),
              Concept('weak', 'Weaknesses in the evidence', <String>['did not see', 'no cctv', 'hearsay', 'inconsistent', 'weakness*', 'doubt']),
              Concept('facts', 'Refers to the testimony', <String>['officer', 'pc dawson', 'search*', 'watch']),
              Concept('ask', 'Asks for the verdict', <String>['not guilty', 'acquit*', 'verdict']),
            ],
          ),
        ),
      ],
    ),
  ],
  certifications: <Certification>[
    Certification(
      id: 'law_cert_advocacy',
      title: 'Advocacy Certificate',
      issuer: 'GradeGlow School of Law',
      requiresModules: <String>['law_m3'],
      tasks: <TaskSpec>[_haleTrial, _issues],
    ),
  ],
);

const CompanyProfile _ashworth = CompanyProfile(
  name: 'Ashworth & Reed LLP',
  industry: 'Law firm (commercial and criminal litigation)',
  about: 'A 120-lawyer firm acting for businesses and individuals in disputes.',
  team: 'Trainees sit in four seats of six months, each supervised by a partner and an associate.',
  training: 'Formal training on drafting, advocacy and client care, plus SQE preparation support.',
  culture: 'Rigorous, client-focused and collegiate; every piece of work is reviewed by your supervisor.',
  success: 'Accurate research, well-structured drafts and sound judgement in court and with clients.',
  tools: 'Case management system, legal research databases and document review platform.',
  nextSteps: 'Graduate recruitment confirms the outcome within two working days.',
);

const List<JobPosting> lawPostings = <JobPosting>[
  JobPosting(
    id: 'law_vac_ashworth',
    deptId: 'law',
    company: _ashworth,
    title: 'Vacation Scheme — Litigation',
    type: JobType.internship,
    stageOnHire: CareerStage.intern,
    description: 'A paid vacation scheme in the litigation department.',
    responsibilities: <String>['Research legal issues', 'Draft memos and letters', 'Attend hearings with counsel'],
    qualifications: <String>['Law student with Trainee status', 'IRAC and contract training'],
    experience: 'None required.',
    requirements: JobRequirements(
      modules: <String>['law_m1', 'law_m2'],
      skills: <String, int>{'law_analysis': 1, 'law_contract': 1},
      projects: 0,
      minStage: CareerStage.trainee,
    ),
    salaryMin: 2400,
    salaryMax: 2600,
    salaryPeriod: 'month',
    location: 'On-site · London',
    openDay: 1,
    deadlineDay: 40,
    interviewPlanId: 'law_iv',
    workplaceId: 'law_ashworth',
  ),
  JobPosting(
    id: 'law_trainee_ashworth',
    deptId: 'law',
    company: _ashworth,
    title: 'Trainee Solicitor',
    type: JobType.graduate,
    stageOnHire: CareerStage.entryLevel,
    description: 'A two-year training contract.',
    responsibilities: <String>['Run files under supervision', 'Draft advice and pleadings', 'Prepare for and attend hearings'],
    qualifications: <String>['Completed vacation scheme', 'Advocacy Certificate', 'Mock trial portfolio'],
    experience: 'A completed vacation scheme.',
    requirements: JobRequirements(
      modules: <String>['law_m1', 'law_m2', 'law_m3'],
      skills: <String, int>{'law_analysis': 2, 'law_evidence': 1, 'law_writing': 1},
      projects: 1,
      minStage: CareerStage.intern,
      certifications: <String>['law_cert_advocacy'],
      completedInternship: true,
    ),
    salaryMin: 46000,
    salaryMax: 52000,
    location: 'On-site · London',
    openDay: 1,
    deadlineDay: 55,
    interviewPlanId: 'law_iv',
    workplaceId: 'law_ashworth',
  ),
];

const InterviewPlan lawInterview = InterviewPlan(
  id: 'law_iv',
  interviewer: 'Eleanor Reed',
  interviewerRole: 'Partner, Litigation',
  opening: 'Thank you for coming. I\'ll give you a short case-study, ask about your judgement, and then take your questions.',
  main: <String>['law_q1', 'law_case', 'law_q2', 'law_q3', 'law_q4'],
  bank: <InterviewQuestion>[
    InterviewQuestion(
      id: 'law_q1',
      prompt: 'Why litigation, and why this firm?',
      competency: Competency.communication,
      minWords: 30,
      rubric: <Concept>[
        Concept('motive', 'Motivation', <String>['because', 'enjoy', 'interested', 'motivat*', 'advocacy']),
        Concept('firm', 'Knows the firm', <String>['ashworth', 'commercial', 'criminal', 'disputes', 'seats']),
      ],
    ),
    InterviewQuestion(
      id: 'law_case',
      prompt: 'Case study: read Ms Rahman\'s account and identify the issues.',
      competency: Competency.technical,
      practical: _issues,
    ),
    InterviewQuestion(
      id: 'law_q2',
      prompt: 'A client asks you to "lose" an email that harms their case. What do you do?',
      competency: Competency.readiness,
      minWords: 30,
      probeId: 'law_q2p',
      rubric: <Concept>[
        Concept('refuse', 'Refuses', <String>['refuse', 'cannot', 'can\'t', 'will not', 'won\'t']),
        Concept('duty', 'Duty to the court / disclosure', <String>['disclos*', 'duty to the court', 'professional conduct', 'sra', 'obligation*']),
        Concept('escalate', 'Raises with supervisor', <String>['supervisor', 'partner', 'escalat*', 'inform']),
      ],
    ),
    InterviewQuestion(
      id: 'law_q2p',
      prompt: 'What if the client insists?',
      competency: Competency.readiness,
      minWords: 20,
      rubric: <Concept>[
        Concept('withdraw', 'Cease acting', <String>['stop acting', 'cease acting', 'withdraw', 'no longer act']),
      ],
    ),
    InterviewQuestion(
      id: 'law_q3',
      prompt: 'In examination-in-chief, which question is leading?',
      competency: Competency.technical,
      options: <String>[
        'What happened next?',
        'You saw the defendant take the watch, didn\'t you?',
        'Where were you standing?',
        'Describe the man you saw.',
      ],
      correctOption: 1,
    ),
    InterviewQuestion(
      id: 'law_q4',
      prompt: 'Tell me about a time you had to explain something complex to a non-specialist.',
      competency: Competency.communication,
      behavioural: true,
      minWords: 40,
      rubric: <Concept>[
        Concept('plain', 'Used plain language', <String>['plain', 'simple', 'example', 'analogy', 'jargon']),
        Concept('check', 'Checked understanding', <String>['checked', 'asked', 'understood', 'questions']),
      ],
    ),
  ],
);

const List<AssignmentSpec> _lawAssignments = <AssignmentSpec>[
  AssignmentSpec(
    id: 'law_a1',
    title: 'New matter · Rahman v BrewCo — issues list',
    ticket: 'Partner: "Read the client\'s account and give me the issues by close of play."',
    acceptance: <String>['Every fact classified to the correct issue'],
    task: _issues,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'law_a2',
    title: 'Advice memo · breach of contract',
    ticket: 'Draft an IRAC memo on breach for the partner to review.',
    acceptance: <String>['Issue, rule, application, counter-argument, conclusion'],
    task: WrittenTaskSpec(
      id: 'memo2',
      title: 'Advice memo',
      brief: 'Advise Ms Rahman on breach by BrewCo.',
      minWords: 90,
      rubric: <Concept>[
        Concept('issue', 'Issue', <String>['issue', 'whether']),
        Concept('rule', 'Rule', <String>['description', 'implied term', 'sale of goods', 'consumer rights act', 'law']),
        Concept('apply', 'Application', <String>['here', 'in this case', 'different model', 'on these facts']),
        Concept('counter', 'Counter-argument', <String>['however', 'may argue', 'although']),
        Concept('conclude', 'Conclusion', <String>['therefore', 'likely', 'in conclusion']),
      ],
    ),
    deadlineDays: 2,
  ),
  AssignmentSpec(
    id: 'law_a3',
    title: 'Contract review · supplier terms',
    ticket: 'Classify the communications in the supplier negotiation file.',
    acceptance: <String>['Every communication classified correctly'],
    task: ClassifyTaskSpec(
      id: 'supplier',
      title: 'Negotiation file',
      brief: 'Classify each communication.',
      categories: <String>['Offer', 'Invitation to treat', 'Counter-offer', 'Acceptance'],
      items: <ClassifyItem>[
        ClassifyItem('Supplier price list emailed to all customers', 'Invitation to treat', 'A general price list invites offers.'),
        ClassifyItem('"We will supply 200 units at £12 each, delivery 1 June."', 'Offer', 'Definite terms.'),
        ClassifyItem('"We accept, but delivery must be 15 May."', 'Counter-offer', 'A changed term is a counter-offer.'),
        ClassifyItem('"Confirmed: 200 units at £12, delivery 15 May."', 'Acceptance', 'Unconditional acceptance of the counter-offer.'),
      ],
    ),
  ),
  AssignmentSpec(
    id: 'law_a4',
    title: 'Hearing · R v Hale',
    ticket: 'You are second chair at Mr Hale\'s trial. Handle objections during the officer\'s evidence.',
    acceptance: <String>['Correct, timely objections'],
    task: _haleTrial,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'law_a5',
    title: 'Client letter · next steps',
    ticket: 'Write to Ms Rahman explaining her options in plain English.',
    acceptance: <String>['Plain English, options, risks, costs and next steps'],
    task: WrittenTaskSpec(
      id: 'client_letter',
      title: 'Client letter',
      brief: 'Write the letter.',
      minWords: 90,
      rubric: <Concept>[
        Concept('options', 'Options', <String>['option*', 'you could', 'choices', 'alternatively']),
        Concept('risk', 'Risks', <String>['risk*', 'chance*', 'likely', 'uncertain']),
        Concept('cost', 'Costs', <String>['cost*', 'fees', 'expense']),
        Concept('next', 'Next steps', <String>['next step*', 'please', 'deadline', 'we will']),
      ],
    ),
    deadlineDays: 2,
  ),
  AssignmentSpec(
    id: 'law_lead1',
    title: 'Supervise the paralegal team',
    ticket: 'You are running disclosure with three paralegals. Write the work plan.',
    acceptance: <String>['Allocation, review process, deadlines, privilege checks'],
    leadership: true,
    deadlineDays: 2,
    task: WrittenTaskSpec(
      id: 'disclosure_plan',
      title: 'Disclosure work plan',
      brief: 'Write the plan.',
      minWords: 90,
      rubric: <Concept>[
        Concept('alloc', 'Allocation of work', <String>['allocat*', 'each paralegal', 'assign*', 'divide']),
        Concept('review', 'Quality review', <String>['review*', 'second check', 'sample', 'quality']),
        Concept('deadline', 'Deadlines', <String>['deadline*', 'by', 'timetable']),
        Concept('privilege', 'Privilege checks', <String>['privilege*', 'confidential*']),
      ],
    ),
  ),
];

const List<WorkplaceDef> lawWorkplaces = <WorkplaceDef>[
  WorkplaceDef(
    id: 'law_ashworth',
    deptId: 'law',
    name: 'Ashworth & Reed LLP — Litigation department',
    environment: 'Open-plan floor near the partners\' offices; matters tracked in the case-management system; hearings at the Crown and County Courts.',
    supervisor: 'Eleanor Reed',
    supervisorRole: 'Partner, supervising solicitor',
    tools: <String>['Case-management system', 'Legal research databases', 'Court bundle builder'],
    assignments: _lawAssignments,
    titles: <CareerStage, String>{
      CareerStage.intern: 'Vacation Scheme Student',
      CareerStage.entryLevel: 'Trainee Solicitor',
      CareerStage.junior: 'Newly Qualified Solicitor',
      CareerStage.experienced: 'Associate',
      CareerStage.senior: 'Senior Associate',
      CareerStage.lead: 'Partner',
    },
    returnOfferPostingId: 'law_trainee_ashworth',
  ),
];
