import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';

// School of Nursing: ward-based training. Tasks are clinical decisions,
// dosage calculations and handovers, scored against nursing standards.

const List<SkillDef> _skills = <SkillDef>[
  SkillDef('nu_assess', 'Patient assessment'),
  SkillDef('nu_meds', 'Medication safety'),
  SkillDef('nu_escalate', 'Recognising deterioration'),
  SkillDef('nu_comm', 'Clinical communication'),
];

const DecisionTaskSpec _highBp = DecisionTaskSpec(
  id: 'high_bp',
  title: 'Bay 3: Mr Okoye — high blood pressure',
  brief: 'You are the student nurse for bay 3. Work through the assessment and decide what to do at each step.',
  setting: 'Ward 4B, 07:40. Mr Daniel Okoye, 64, admitted yesterday with cellulitis. History of hypertension.',
  skills: <String>['nu_assess', 'nu_escalate', 'nu_meds'],
  facts: <Fact>[
    Fact('BP', '186/108 mmHg'),
    Fact('Heart rate', '92 bpm'),
    Fact('Resp rate', '18 /min'),
    Fact('SpO₂', '97% on air'),
    Fact('Temp', '37.4 °C'),
    Fact('Regular meds', 'Amlodipine 10 mg, 08:00'),
  ],
  steps: <DecisionStep>[
    DecisionStep('The automated cuff reads 186/108. What do you do first?', <DecisionOption>[
      DecisionOption('Repeat the reading manually with the correct cuff size after 5 minutes of rest', 2,
          'Confirm an abnormal reading before acting on it: wrong cuff size and recent activity inflate readings.'),
      DecisionOption('Give his amlodipine early to bring it down', 0,
          'Changing the timing of medication without a prescription is outside your role.', critical: true),
      DecisionOption('Document it and recheck at the next scheduled observations', 0,
          'A reading this high must be confirmed now, not in four hours.'),
    ]),
    DecisionStep('Manual repeat: 182/106. What else do you assess?', <DecisionOption>[
      DecisionOption('Ask about headache, visual disturbance, chest pain and confusion', 2,
          'These red-flag symptoms separate urgent hypertension from a hypertensive emergency.'),
      DecisionOption('Nothing else — the number is enough', 0, 'Symptoms change the urgency of escalation.'),
      DecisionOption('Check his pain score only', 1, 'Pain raises BP and is worth checking, but it misses the red flags.'),
    ], update: 'He reports a mild headache, no visual changes, no chest pain. Pain from the cellulitis is 6/10.'),
    DecisionStep('How do you escalate?', <DecisionOption>[
      DecisionOption('Inform the nurse in charge and the doctor now using SBAR, and give his regular 08:00 amlodipine as prescribed', 2,
          'Escalate promptly with a structured handover; regular antihypertensives are given as prescribed unless the doctor says otherwise.'),
      DecisionOption('Wait for the ward round at 10:00', 0, 'Two hours is too long for a confirmed reading this high with a headache.'),
      DecisionOption('Call the rapid response team', 1,
          'Rapid response is for a deteriorating patient; with stable vitals and no red flags, the ward doctor is the right first call.'),
    ]),
    DecisionStep('The doctor asks you to recheck in 1 hour and give PRN analgesia. What do you document?', <DecisionOption>[
      DecisionOption('Both readings, symptoms, who you informed and when, the plan, and the recheck time', 2,
          'Complete documentation lets the next nurse continue the plan safely.'),
      DecisionOption('"BP high, doctor aware"', 0, 'Too vague to act on or defend.'),
      DecisionOption('Only the second reading', 1, 'Missing the symptoms, escalation and plan.'),
    ]),
  ],
);

const NumericTaskSpec _dosage = NumericTaskSpec(
  id: 'dosage',
  title: 'Medication calculations',
  brief: 'Calculate the doses. A wrong decimal place can kill — work carefully and check against the givens.',
  skills: <String>['nu_meds'],
  givens: <Fact>[
    Fact('Prescription 1', 'Furosemide 30 mg IV; stock 10 mg/mL'),
    Fact('Prescription 2', 'Paracetamol 15 mg/kg oral; child weighs 22 kg'),
    Fact('Prescription 3', '1,000 mL sodium chloride 0.9% over 8 hours'),
  ],
  parts: <NumericPart>[
    NumericPart('Volume of furosemide to draw up', 3, unit: 'mL', method: 'Volume = prescribed dose ÷ stock strength.'),
    NumericPart('Paracetamol dose', 330, unit: 'mg', method: 'Dose = mg/kg × weight.'),
    NumericPart('Infusion rate', 125, unit: 'mL/h', method: 'Rate = total volume ÷ hours.'),
  ],
);

const TrainingModule _m1 = TrainingModule(
  id: 'nu_m1',
  title: 'Vital signs and early warning scores',
  summary: 'Take accurate observations, recognise abnormal values and escalate with a structured handover.',
  skills: <String>['nu_assess', 'nu_escalate'],
  lesson: <LessonSection>[
    LessonSection('Accurate observations',
        'Use the right cuff size, let the patient rest for five minutes, and repeat any abnormal automated reading '
            'manually. A reading you have not confirmed is not a basis for action.'),
    LessonSection('Early warning scores',
        'Respiratory rate, oxygen saturation, blood pressure, pulse, consciousness and temperature each score points. '
            'A rising total — or a single extreme value — triggers escalation. Respiratory rate is the earliest and most '
            'often missed sign of deterioration.'),
    LessonSection('Red flags in hypertension',
        'Headache, visual disturbance, chest pain, breathlessness or confusion with a very high blood pressure may '
            'signal end-organ damage. That changes the urgency from "inform the doctor" to "get help now".'),
    LessonSection('Scope of practice',
        'Nurses give medicines as prescribed. Changing a dose or time, or giving a medicine early, requires a prescriber.'),
  ],
  practice: <TaskSpec>[_highBp],
);

const TrainingModule _m2 = TrainingModule(
  id: 'nu_m2',
  title: 'Medication administration and dosage',
  summary: 'Apply the rights of medication administration and calculate doses accurately.',
  skills: <String>['nu_meds'],
  lesson: <LessonSection>[
    LessonSection('The rights of administration',
        'Right patient, medicine, dose, route, time, documentation — and the patient\'s right to refuse. Check the '
            'identity band against the chart every time.'),
    LessonSection('Dose calculations',
        'What you want ÷ what you have × volume it comes in. For weight-based doses multiply mg/kg by the weight in kg. '
            'For infusions, rate = volume ÷ time. Always estimate first: if the answer is ten times your estimate, stop.',
        example: 'Want 30 mg, have 10 mg in 1 mL → 30 ÷ 10 × 1 = 3 mL'),
    LessonSection('Holding a dose',
        'Some medicines are held when observations are outside safe limits (e.g. a beta-blocker with a heart rate under '
            '50). Holding is a clinical decision you document and report.'),
  ],
  practice: <TaskSpec>[
    _dosage,
    ClassifyTaskSpec(
      id: 'med_round',
      title: 'Morning medication round',
      brief: 'For each patient and prescription, decide what you do.',
      categories: <String>['Give as prescribed', 'Hold and inform the prescriber', 'Do not give — check first'],
      skills: <String>['nu_meds'],
      items: <ClassifyItem>[
        ClassifyItem('Bisoprolol 5 mg; heart rate 46 bpm', 'Hold and inform the prescriber',
            'Beta-blockers slow the heart further; a rate under 50 means hold and report.'),
        ClassifyItem('Paracetamol 1 g; last dose 2 hours ago', 'Do not give — check first',
            'Doses must be at least 4 hours apart; check the chart history.'),
        ClassifyItem('Amlodipine 10 mg; BP 150/90, no symptoms', 'Give as prescribed',
            'Within the expected range for this patient; give the regular dose.'),
        ClassifyItem('Amoxicillin 500 mg; chart shows a penicillin allergy', 'Do not give — check first',
            'Amoxicillin is a penicillin. Never give it against a documented allergy.'),
        ClassifyItem('Enoxaparin 40 mg SC; platelets normal, no bleeding', 'Give as prescribed',
            'No contraindication present.'),
      ],
    ),
  ],
);

const TrainingModule _m3 = TrainingModule(
  id: 'nu_m3',
  title: 'Deterioration and SBAR handover',
  summary: 'Recognise sepsis and communicate clearly with Situation–Background–Assessment–Recommendation.',
  skills: <String>['nu_escalate', 'nu_comm'],
  lesson: <LessonSection>[
    LessonSection('SBAR',
        'Situation: who you are, who the patient is, what is happening now. Background: the relevant history. '
            'Assessment: your observations and what you think is going on. Recommendation: what you need and by when.'),
    LessonSection('Sepsis',
        'Infection plus signs of organ dysfunction: raised respiratory rate, low blood pressure, new confusion, low urine '
            'output. Time to antibiotics matters — escalate immediately.'),
  ],
  practice: <TaskSpec>[
    OrderTaskSpec(
      id: 'sepsis_steps',
      title: 'Suspected sepsis: first hour',
      brief: 'Order the nursing actions for a patient who meets sepsis criteria on the ward.',
      skills: <String>['nu_escalate'],
      steps: <String>[
        'Recognise the trigger and call the doctor/outreach team immediately',
        'Give oxygen to target saturations as per protocol',
        'Take blood cultures before antibiotics (as prescribed)',
        'Give the prescribed IV antibiotics',
        'Start prescribed IV fluids and monitor response',
        'Monitor urine output and repeat observations',
      ],
      why: 'Escalate first, then the Sepsis Six with cultures before antibiotics.',
    ),
    WrittenTaskSpec(
      id: 'sbar_handover',
      title: 'Phone the doctor: SBAR',
      brief: 'Mrs Patel, 78, day 2 post hip repair: RR 26, BP 92/58, HR 118, temp 38.6 °C, newly confused. Write your SBAR '
          'call to the on-call doctor.',
      skills: <String>['nu_comm', 'nu_escalate'],
      minWords: 60,
      maxWords: 220,
      rubric: <Concept>[
        Concept('situation', 'Situation: who you are and the concern', <String>['calling about', 'i am', 'concerned', 'situation', 'my name']),
        Concept('background', 'Background: surgery and history', <String>['hip', 'post op', 'surgery', 'day 2', 'background']),
        Concept('assessment', 'Assessment with the observations', <String>['26', '92', '118', '38', 'confus*', 'sepsis', 'news']),
        Concept('recommend', 'A clear request and timescale', <String>['please review', 'review her', 'come and see', 'within', 'now', 'minutes', 'recommend*']),
      ],
    ),
  ],
);

const Department nursing = Department(
  id: 'nursing',
  title: 'Nursing',
  school: 'School of Nursing & Midwifery',
  emoji: '🩺',
  summary: 'Train on a simulated adult ward: observations, medication rounds, deterioration and handovers.',
  majors: <String>['nursing', 'public_health', 'nutrition'],
  skills: _skills,
  units: <DeptUnit>[
    DeptUnit(
      id: 'nu_ward',
      title: 'Ward 4B — Adult Medical',
      emoji: '🛏️',
      setting: '24-bed adult medical ward: observation charts, medication trolley, early-warning chart and handover sheet.',
      modules: <TrainingModule>[_m1, _m2],
      projects: <ProjectSpec>[
        ProjectSpec(
          id: 'nu_p1',
          title: 'Care plan: hypertension and cellulitis',
          brief: 'Produce a 24-hour nursing care plan for Mr Okoye, including the medication calculations it relies on.',
          requiresModules: <String>['nu_m1', 'nu_m2'],
          skills: <String>['nu_assess', 'nu_meds', 'nu_comm'],
          deliverables: <TaskSpec>[_dosage],
          writeUp: WrittenTaskSpec(
            id: 'care_plan',
            title: 'Care plan',
            brief: 'Write the care plan: problems, goals, interventions, monitoring and when to escalate.',
            minWords: 100,
            rubric: <Concept>[
              Concept('problem', 'Nursing problems identified', <String>['problem*', 'risk of', 'hypertension', 'cellulitis', 'pain']),
              Concept('goal', 'Measurable goals', <String>['goal*', 'target', 'below', 'within', 'by']),
              Concept('intervene', 'Interventions', <String>['administer', 'give', 'elevate', 'monitor', 'educat*', 'analgesia']),
              Concept('obs', 'Monitoring frequency', <String>['hourly', 'every', 'observations', '4 hour*', 'recheck']),
              Concept('escalate', 'Escalation criteria', <String>['escalat*', 'inform', 'doctor', 'if bp', 'red flag*']),
            ],
          ),
        ),
      ],
    ),
    DeptUnit(
      id: 'nu_sim',
      title: 'Clinical Simulation Suite',
      emoji: '🚨',
      setting: 'High-fidelity simulation room: a deteriorating patient, a phone to the on-call team and a sepsis trolley.',
      modules: <TrainingModule>[_m3],
    ),
  ],
  certifications: <Certification>[
    Certification(
      id: 'nu_cert_meds',
      title: 'Medication Safety Certificate',
      issuer: 'GradeGlow School of Nursing',
      requiresModules: <String>['nu_m2'],
      tasks: <TaskSpec>[_dosage],
      passMark: 100,
    ),
    Certification(
      id: 'nu_cert_acute',
      title: 'Acute Deterioration Certificate',
      issuer: 'GradeGlow School of Nursing',
      requiresModules: <String>['nu_m3'],
      tasks: <TaskSpec>[_highBp],
    ),
  ],
);

const CompanyProfile _stAidans = CompanyProfile(
  name: 'St Aidan\'s University Hospital',
  industry: 'Acute hospital',
  about: 'An 800-bed teaching hospital with a major emergency department.',
  team: 'Ward 4B has 24 beds, a ward manager, two sisters, eight registered nurses per day shift and healthcare assistants.',
  training: 'A preceptorship programme for newly qualified nurses: a named preceptor, protected learning time and competency sign-off.',
  culture: 'Speak up for safety; every concern is welcome and incidents are reviewed without blame.',
  success: 'Safe medication rounds, timely escalation and clear handovers within your first months.',
  tools: 'Electronic observations with early-warning scoring, electronic prescribing and a handover sheet.',
  nextSteps: 'The ward manager confirms the outcome within two working days.',
);

const List<JobPosting> nursingPostings = <JobPosting>[
  JobPosting(
    id: 'nu_place_staidans',
    deptId: 'nursing',
    company: _stAidans,
    title: 'Student Nurse Practice Placement',
    type: JobType.internship,
    stageOnHire: CareerStage.intern,
    description: 'A supervised placement on Ward 4B working shifts alongside a practice assessor.',
    responsibilities: <String>['Take and record observations', 'Assist with medication rounds under supervision', 'Escalate concerns', 'Give handovers'],
    qualifications: <String>['Nursing student with Trainee status', 'Vital signs and medication training'],
    experience: 'None required.',
    requirements: JobRequirements(
      modules: <String>['nu_m1', 'nu_m2'],
      skills: <String, int>{'nu_assess': 1, 'nu_meds': 1},
      projects: 1,
      minStage: CareerStage.trainee,
    ),
    salaryMin: 2050,
    salaryMax: 2300,
    salaryPeriod: 'month',
    location: 'On-site · Ward 4B',
    openDay: 1,
    deadlineDay: 40,
    interviewPlanId: 'nu_iv',
    workplaceId: 'nu_ward4b',
  ),
  JobPosting(
    id: 'nu_rn_staidans',
    deptId: 'nursing',
    company: _stAidans,
    title: 'Newly Qualified Staff Nurse (Band 5)',
    type: JobType.entryLevel,
    stageOnHire: CareerStage.entryLevel,
    description: 'Permanent staff nurse post on Ward 4B with a preceptorship.',
    responsibilities: <String>['Lead care for a bay of patients', 'Administer medicines', 'Escalate deterioration', 'Supervise students'],
    qualifications: <String>['Completed practice placement', 'Medication Safety Certificate'],
    experience: 'A completed nursing placement.',
    requirements: JobRequirements(
      modules: <String>['nu_m1', 'nu_m2', 'nu_m3'],
      skills: <String, int>{'nu_assess': 2, 'nu_meds': 2, 'nu_escalate': 1},
      projects: 1,
      minStage: CareerStage.intern,
      certifications: <String>['nu_cert_meds'],
      completedInternship: true,
    ),
    salaryMin: 38000,
    salaryMax: 46500,
    location: 'On-site · Ward 4B',
    openDay: 1,
    deadlineDay: 55,
    interviewPlanId: 'nu_iv',
    workplaceId: 'nu_ward4b',
  ),
];

const InterviewPlan nursingInterview = InterviewPlan(
  id: 'nu_iv',
  interviewer: 'Sister Helen Mbeki',
  interviewerRole: 'Ward Manager, Ward 4B',
  opening: 'Welcome. I\'ll ask about patient care, give you a short clinical scenario and a calculation, and then it\'s your turn to ask questions.',
  main: <String>['nu_q1', 'nu_q2', 'nu_scn', 'nu_calc', 'nu_q3', 'nu_q4'],
  bank: <InterviewQuestion>[
    InterviewQuestion(
      id: 'nu_q1',
      prompt: 'Why nursing, and why this ward?',
      competency: Competency.communication,
      minWords: 30,
      rubric: <Concept>[
        Concept('motive', 'Personal motivation', <String>['because', 'i want*', 'care about', 'passion*', 'motivat*']),
        Concept('ward', 'Knows the ward/hospital', <String>['medical', 'ward', 'hospital', 'teaching', 'acute']),
      ],
    ),
    InterviewQuestion(
      id: 'nu_q2',
      prompt: 'A patient refuses their evening medication. What do you do?',
      competency: Competency.technical,
      minWords: 30,
      probeId: 'nu_q2p',
      rubric: <Concept>[
        Concept('reason', 'Explores the reason', <String>['ask why', 'reason', 'understand', 'concern*', 'explore']),
        Concept('respect', 'Respects the right to refuse', <String>['right to refuse', 'respect*', 'capacity', 'consent', 'choice']),
        Concept('doc', 'Documents and informs', <String>['document*', 'record*', 'inform*', 'prescriber', 'doctor', 'nurse in charge']),
      ],
    ),
    InterviewQuestion(
      id: 'nu_q2p',
      prompt: 'What if the patient seems confused when refusing?',
      competency: Competency.technical,
      minWords: 20,
      rubric: <Concept>[
        Concept('capacity', 'Capacity assessment', <String>['capacity', 'assess*', 'confus*', 'delirium']),
        Concept('escalate', 'Escalates', <String>['doctor', 'escalat*', 'inform*', 'senior']),
      ],
    ),
    InterviewQuestion(
      id: 'nu_scn',
      prompt: 'Scenario: you are looking after Mr Okoye in bay 3. Work through the decisions.',
      competency: Competency.problemSolving,
      practical: _highBp,
    ),
    InterviewQuestion(
      id: 'nu_calc',
      prompt: 'Calculation: work out these doses.',
      competency: Competency.technical,
      practical: _dosage,
    ),
    InterviewQuestion(
      id: 'nu_q3',
      prompt: 'Tell me about a time you had to raise a concern about patient safety.',
      competency: Competency.readiness,
      behavioural: true,
      minWords: 40,
      rubric: <Concept>[
        Concept('concern', 'The concern', <String>['concern*', 'unsafe', 'risk', 'noticed']),
        Concept('raised', 'Raised it appropriately', <String>['reported', 'told', 'escalat*', 'raised', 'mentor', 'nurse in charge']),
      ],
    ),
    InterviewQuestion(
      id: 'nu_q4',
      prompt: 'Your shift has six patients and two need observations at the same time as the medication round. How do you prioritise?',
      competency: Competency.problemSolving,
      minWords: 30,
      rubric: <Concept>[
        Concept('acuity', 'Prioritises by acuity', <String>['sickest', 'acuity', 'most unwell', 'priorit*', 'news', 'early warning']),
        Concept('time', 'Time-critical meds', <String>['time critical', 'time-critical', 'insulin', 'antibiotic*', 'on time']),
        Concept('delegate', 'Delegates / asks for help', <String>['delegate*', 'healthcare assistant', 'ask for help', 'colleague*']),
      ],
    ),
  ],
);

const List<AssignmentSpec> _nuAssignments = <AssignmentSpec>[
  AssignmentSpec(
    id: 'nu_a1',
    title: 'Day shift · Bay 3 hypertension review',
    ticket: 'Sister Mbeki: "Mr Okoye\'s early obs were high. Reassess him and handle it."',
    acceptance: <String>['Safe decisions throughout', 'Handoff note for the next shift'],
    task: _highBp,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'nu_a2',
    title: 'Medication round · Bays 1–4',
    ticket: 'Complete the morning round. Flag anything you would not give.',
    acceptance: <String>['Every prescription handled correctly'],
    task: ClassifyTaskSpec(
      id: 'round2',
      title: 'Medication round',
      brief: 'Decide for each prescription.',
      categories: <String>['Give as prescribed', 'Hold and inform the prescriber', 'Do not give — check first'],
      items: <ClassifyItem>[
        ClassifyItem('Digoxin 125 mcg; apex rate 52, nausea and yellow-tinged vision', 'Hold and inform the prescriber',
            'Nausea and visual change with a slow pulse suggest digoxin toxicity.'),
        ClassifyItem('Metformin 500 mg with breakfast; eating normally', 'Give as prescribed', 'No contraindication.'),
        ClassifyItem('Insulin 8 units; patient is nil by mouth for theatre, glucose 5.1', 'Do not give — check first',
            'Giving insulin to a fasting patient risks hypoglycaemia; check the plan.'),
        ClassifyItem('Morphine 10 mg oral; RR 9, very drowsy', 'Hold and inform the prescriber',
            'Respiratory depression — hold opioids and escalate.'),
      ],
    ),
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'nu_a3',
    title: 'Evening · Infusion and dose calculations',
    ticket: 'Pharmacy has queried three doses. Recalculate them.',
    acceptance: <String>['All calculations within tolerance'],
    task: NumericTaskSpec(
      id: 'calc2',
      title: 'Dose checks',
      brief: 'Calculate each value.',
      givens: <Fact>[
        Fact('Prescription 1', 'Gentamicin 5 mg/kg IV; patient 68 kg'),
        Fact('Prescription 2', 'Morphine 2.5 mg SC; stock 10 mg/mL'),
        Fact('Prescription 3', '500 mL over 4 hours via a 20 drops/mL giving set'),
      ],
      parts: <NumericPart>[
        NumericPart('Gentamicin dose', 340, unit: 'mg', method: 'mg/kg × weight.'),
        NumericPart('Morphine volume', 0.25, unit: 'mL', method: 'Dose ÷ stock strength.'),
        NumericPart('Drip rate', 41.67, unit: 'drops/min', relTol: 0.02, method: 'Volume × drop factor ÷ minutes.'),
      ],
    ),
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'nu_a4',
    title: 'Night · Deteriorating patient call',
    ticket: 'Mrs Patel has triggered on the early-warning score. Call the on-call doctor.',
    acceptance: <String>['Structured SBAR with observations and a clear request'],
    task: WrittenTaskSpec(
      id: 'sbar2',
      title: 'SBAR call',
      brief: 'Mrs Patel, 78, day 2 post hip repair: RR 26, BP 92/58, HR 118, temp 38.6 °C, newly confused. Write your SBAR call.',
      minWords: 60,
      maxWords: 220,
      rubric: <Concept>[
        Concept('situation', 'Situation', <String>['calling about', 'i am', 'concerned', 'situation']),
        Concept('background', 'Background', <String>['hip', 'post op', 'surgery', 'day 2']),
        Concept('assessment', 'Assessment', <String>['26', '92', '118', '38', 'confus*', 'sepsis']),
        Concept('recommend', 'Recommendation', <String>['please review', 'come and see', 'within', 'now', 'minutes']),
      ],
    ),
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'nu_a5',
    title: 'Sepsis bundle',
    ticket: 'Bed 12 meets sepsis criteria. Run the first hour.',
    acceptance: <String>['Correct order of actions'],
    task: OrderTaskSpec(
      id: 'sepsis2',
      title: 'Sepsis first hour',
      brief: 'Order the actions.',
      steps: <String>[
        'Escalate to the doctor/outreach team immediately',
        'Give oxygen to target saturations',
        'Take blood cultures',
        'Give prescribed IV antibiotics',
        'Give prescribed IV fluids',
        'Monitor urine output and repeat observations',
      ],
      why: 'Escalate, then cultures before antibiotics.',
    ),
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'nu_lead1',
    title: 'Coordinate the shift',
    ticket: 'You are nurse in charge today. Plan the allocation of two nurses, one HCA and one student across 12 patients.',
    acceptance: <String>['Allocation by acuity, delegation within competence, breaks covered, escalation plan'],
    leadership: true,
    deadlineDays: 1,
    task: WrittenTaskSpec(
      id: 'allocation',
      title: 'Shift allocation plan',
      brief: 'Write the plan.',
      minWords: 90,
      rubric: <Concept>[
        Concept('acuity', 'Allocation by acuity', <String>['acuity', 'sickest', 'most unwell', 'dependency', 'news']),
        Concept('competence', 'Delegation within competence', <String>['competen*', 'supervis*', 'student', 'healthcare assistant', 'hca']),
        Concept('breaks', 'Breaks and cover', <String>['break*', 'cover']),
        Concept('escalate', 'Escalation plan', <String>['escalat*', 'outreach', 'doctor', 'bleep']),
      ],
    ),
  ),
];

const List<WorkplaceDef> nursingWorkplaces = <WorkplaceDef>[
  WorkplaceDef(
    id: 'nu_ward4b',
    deptId: 'nursing',
    name: 'St Aidan\'s — Ward 4B Adult Medical',
    environment: 'Twelve-hour shifts; safety huddle at 07:30 and 19:30; observations on the electronic chart; medication '
        'rounds at 08:00, 12:00, 18:00 and 22:00.',
    supervisor: 'Sister Helen Mbeki',
    supervisorRole: 'Ward Manager',
    tools: <String>['Electronic observations & early warning', 'Electronic prescribing', 'Handover sheet'],
    assignments: _nuAssignments,
    titles: <CareerStage, String>{
      CareerStage.intern: 'Student Nurse (placement)',
      CareerStage.entryLevel: 'Staff Nurse (preceptorship)',
      CareerStage.junior: 'Staff Nurse',
      CareerStage.experienced: 'Senior Staff Nurse',
      CareerStage.senior: 'Ward Sister / Charge Nurse',
      CareerStage.lead: 'Ward Manager',
    },
    returnOfferPostingId: 'nu_rn_staidans',
  ),
];
