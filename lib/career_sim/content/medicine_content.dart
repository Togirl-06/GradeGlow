import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../model/tasks.dart';

// School of Medicine: patient work-ups (order tests, interpret, diagnose,
// manage), clinical reasoning and cardiac anatomy.

const List<SkillDef> _skills = <SkillDef>[
  SkillDef('md_history', 'History & examination'),
  SkillDef('md_reason', 'Clinical reasoning'),
  SkillDef('md_manage', 'Acute management'),
  SkillDef('md_anatomy', 'Applied anatomy'),
  SkillDef('md_comm', 'Clinical documentation'),
];

const WorkupTaskSpec _chestPain = WorkupTaskSpec(
  id: 'chest_pain',
  title: 'ED cubicle 4: chest pain',
  brief: 'Order up to four investigations, read the results, commit to a working diagnosis and manage the patient.',
  presentation: 'Mr Alan Brooks, 58, smoker, 40 minutes of central crushing chest pain radiating to the left arm, sweaty and nauseated.',
  skills: <String>['md_reason', 'md_manage'],
  facts: <Fact>[
    Fact('BP', '142/88 mmHg'),
    Fact('HR', '98 bpm, regular'),
    Fact('SpO₂', '95% on air'),
    Fact('History', 'Hypertension, type 2 diabetes'),
  ],
  maxInvestigations: 4,
  investigations: <Investigation>[
    Investigation('12-lead ECG', 'ST elevation in II, III and aVF with reciprocal depression in I and aVL.', relevant: true),
    Investigation('High-sensitivity troponin', 'Raised: 860 ng/L.', relevant: true),
    Investigation('Chest X-ray', 'No pneumothorax, normal mediastinum.', relevant: true),
    Investigation('D-dimer', 'Mildly raised (non-specific).', relevant: false),
    Investigation('Abdominal ultrasound', 'Normal.', relevant: false),
    Investigation('Urea & electrolytes', 'Creatinine 88 µmol/L, K⁺ 4.1.', relevant: true),
  ],
  diagnoses: <String>[
    'Inferior ST-elevation myocardial infarction',
    'Pulmonary embolism',
    'Aortic dissection',
    'Gastro-oesophageal reflux',
  ],
  correctDiagnosis: 0,
  management: <DecisionStep>[
    DecisionStep('Immediate treatment?', <DecisionOption>[
      DecisionOption('Aspirin 300 mg, analgesia, and activate the primary PCI pathway', 2,
          'STEMI needs antiplatelet therapy and reperfusion as fast as possible.'),
      DecisionOption('Start a heparin infusion and admit to the ward', 0, 'Delays reperfusion for a STEMI.'),
      DecisionOption('Give thrombolysis immediately although the PCI centre is 15 minutes away', 1,
          'Primary PCI is preferred when it can be delivered within 120 minutes.'),
    ]),
    DecisionStep('Oxygen?', <DecisionOption>[
      DecisionOption('Only if saturations fall below 94%', 2, 'Routine oxygen does not help non-hypoxic MI patients.'),
      DecisionOption('High-flow oxygen for everyone with chest pain', 0, 'Not indicated with SpO₂ 95%.'),
    ]),
  ],
);

const TrainingModule _m1 = TrainingModule(
  id: 'md_m1',
  title: 'History taking and clinical reasoning',
  summary: 'Structure a history and build a differential diagnosis from the findings.',
  skills: <String>['md_history', 'md_reason'],
  lesson: <LessonSection>[
    LessonSection('The structure of a history',
        'Presenting complaint, history of the presenting complaint (SOCRATES for pain), past medical history, drugs and '
            'allergies, family history, social history, systems review. Allergies are always asked before prescribing.'),
    LessonSection('From findings to a differential',
        'List the most likely diagnoses and the most dangerous ones that must not be missed. Each investigation you order '
            'should change your probability of a diagnosis — if it cannot change management, do not order it.'),
  ],
  practice: <TaskSpec>[
    OrderTaskSpec(
      id: 'history_order',
      title: 'Order the history',
      brief: 'Put the parts of a medical history in the standard order.',
      skills: <String>['md_history'],
      steps: <String>[
        'Presenting complaint',
        'History of the presenting complaint',
        'Past medical history',
        'Drug history and allergies',
        'Family history',
        'Social history',
        'Systems review',
      ],
    ),
    ClassifyTaskSpec(
      id: 'socrates',
      title: 'Is it cardiac?',
      brief: 'Classify each feature of chest pain.',
      categories: <String>['Suggests cardiac ischaemia', 'Suggests another cause'],
      skills: <String>['md_reason'],
      items: <ClassifyItem>[
        ClassifyItem('Central, heavy, radiating to the jaw', 'Suggests cardiac ischaemia', 'Classic ischaemic character and radiation.'),
        ClassifyItem('Sharp, worse on breathing in and lying flat, better sitting forward', 'Suggests another cause', 'Typical of pericarditis.'),
        ClassifyItem('Brought on by exertion, relieved by rest', 'Suggests cardiac ischaemia', 'Exertional pattern of angina.'),
        ClassifyItem('Reproducible by pressing on the chest wall', 'Suggests another cause', 'Musculoskeletal pain is reproducible on palpation.'),
        ClassifyItem('Associated with sweating and nausea', 'Suggests cardiac ischaemia', 'Autonomic features accompany MI.'),
      ],
    ),
  ],
);

const TrainingModule _m2 = TrainingModule(
  id: 'md_m2',
  title: 'Acute chest pain in the emergency department',
  summary: 'Work up a patient with chest pain and start time-critical treatment.',
  skills: <String>['md_reason', 'md_manage'],
  lesson: <LessonSection>[
    LessonSection('First ten minutes',
        'An ECG within 10 minutes of arrival. ST elevation in two contiguous leads with symptoms is a STEMI: call the '
            'reperfusion team. Troponin confirms myocardial injury but must never delay treatment of a STEMI.'),
    LessonSection('Do not miss',
        'Aortic dissection (tearing pain to the back, unequal arm pressures, wide mediastinum), pulmonary embolism '
            '(pleuritic pain, tachycardia, hypoxia, risk factors), tension pneumothorax.'),
    LessonSection('ECG territories',
        'Inferior: II, III, aVF (right coronary artery). Anterior: V1–V4 (left anterior descending). Lateral: I, aVL, V5–V6 (circumflex).'),
  ],
  practice: <TaskSpec>[_chestPain],
);

const LabelTaskSpec _heart = LabelTaskSpec(
  id: 'heart_label',
  title: 'Label the heart',
  brief: 'Identify each numbered structure on the coronal section.',
  diagram: 'heart',
  skills: <String>['md_anatomy'],
  hotspots: <Hotspot>[
    Hotspot(0.30, 0.32, 'Right atrium'),
    Hotspot(0.33, 0.66, 'Right ventricle'),
    Hotspot(0.68, 0.32, 'Left atrium'),
    Hotspot(0.64, 0.68, 'Left ventricle'),
    Hotspot(0.55, 0.10, 'Aorta'),
    Hotspot(0.42, 0.14, 'Pulmonary trunk'),
    Hotspot(0.50, 0.58, 'Interventricular septum'),
  ],
  distractors: <String>['Superior vena cava', 'Coronary sinus'],
);

const TrainingModule _m3 = TrainingModule(
  id: 'md_m3',
  title: 'Cardiac anatomy for clinicians',
  summary: 'Relate the chambers, valves and coronary supply to what you see on an ECG and echo.',
  skills: <String>['md_anatomy'],
  lesson: <LessonSection>[
    LessonSection('Chambers and flow',
        'Deoxygenated blood: venae cavae → right atrium → tricuspid valve → right ventricle → pulmonary valve → pulmonary '
            'trunk. Oxygenated: pulmonary veins → left atrium → mitral valve → left ventricle → aortic valve → aorta.'),
    LessonSection('Why the left ventricle is thicker',
        'It pumps against systemic resistance, about five times the pulmonary pressure. The interventricular septum is '
            'mostly part of the left ventricle and is supplied by the left anterior descending artery.'),
  ],
  practice: <TaskSpec>[
    _heart,
    OrderTaskSpec(
      id: 'blood_flow',
      title: 'Trace a red cell',
      brief: 'Order the structures a red cell passes from the vena cava to the aorta.',
      skills: <String>['md_anatomy'],
      steps: <String>[
        'Right atrium',
        'Tricuspid valve',
        'Right ventricle',
        'Pulmonary trunk',
        'Lungs and pulmonary veins',
        'Left atrium',
        'Mitral valve',
        'Left ventricle',
        'Aorta',
      ],
    ),
  ],
);

const WorkupTaskSpec _breathless = WorkupTaskSpec(
  id: 'breathless',
  title: 'Medical take: breathless and confused',
  brief: 'Order up to four investigations, diagnose and manage.',
  presentation: 'Mrs June Harper, 81, from a care home: two days of cough, now confused. RR 28, BP 88/54, HR 124, temp 38.9 °C, SpO₂ 90% on air.',
  skills: <String>['md_reason', 'md_manage'],
  facts: <Fact>[Fact('Lactate', 'Pending'), Fact('Allergies', 'None known')],
  maxInvestigations: 4,
  investigations: <Investigation>[
    Investigation('Chest X-ray', 'Right lower lobe consolidation.', relevant: true),
    Investigation('Venous lactate', '4.2 mmol/L.', relevant: true),
    Investigation('Blood cultures', 'Taken; results in 48 h.', relevant: true),
    Investigation('CT head', 'No acute abnormality.', relevant: false),
    Investigation('Thyroid function', 'Normal.', relevant: false),
    Investigation('FBC and CRP', 'WCC 18.2, CRP 240.', relevant: true),
  ],
  diagnoses: <String>[
    'Septic shock from community-acquired pneumonia',
    'Stroke',
    'Acute heart failure',
    'Hypothyroid crisis',
  ],
  correctDiagnosis: 0,
  management: <DecisionStep>[
    DecisionStep('First-hour management?', <DecisionOption>[
      DecisionOption('Oxygen, cultures, IV antibiotics within the hour, 500 mL fluid bolus and reassess, urine output monitoring', 2,
          'The sepsis bundle, delivered fast, saves lives.'),
      DecisionOption('Wait for the culture result before antibiotics', 0,
          'Each hour of delay in septic shock increases mortality.', critical: true),
      DecisionOption('Oral antibiotics and review tomorrow', 0, 'Inadequate for septic shock.'),
    ]),
    DecisionStep('BP stays 84/50 after 2 litres of fluid. Next?', <DecisionOption>[
      DecisionOption('Escalate to critical care for vasopressors', 2, 'Fluid-refractory hypotension needs critical care.'),
      DecisionOption('Keep giving fluid boluses on the ward', 0, 'Risks fluid overload without fixing the shock.'),
    ]),
  ],
);

const Department medicine = Department(
  id: 'medicine',
  title: 'Medicine',
  school: 'School of Medicine',
  emoji: '⚕️',
  summary: 'Clinical skills, emergency work-ups and applied anatomy, assessed on reasoning and safety.',
  majors: <String>['medicine', 'anatomy_physiology', 'pharmacy_fundamentals', 'medical_lab_science', 'healthcare_management'],
  skills: _skills,
  units: <DeptUnit>[
    DeptUnit(
      id: 'md_skills',
      title: 'Clinical Skills Centre',
      emoji: '🩻',
      setting: 'Consultation rooms with simulated patients and a reasoning whiteboard.',
      modules: <TrainingModule>[_m1],
    ),
    DeptUnit(
      id: 'md_ed',
      title: 'Emergency Department',
      emoji: '🚑',
      setting: 'Majors cubicles with monitors, ECG machine and a results viewer.',
      modules: <TrainingModule>[_m2],
      projects: <ProjectSpec>[
        ProjectSpec(
          id: 'md_p1',
          title: 'Case presentation: septic shock',
          brief: 'Work up the case and present it as you would at the morning handover meeting.',
          requiresModules: <String>['md_m1', 'md_m2'],
          skills: <String>['md_reason', 'md_manage', 'md_comm'],
          deliverables: <TaskSpec>[_breathless],
          writeUp: WrittenTaskSpec(
            id: 'presentation',
            title: 'Case presentation',
            brief: 'Present: summary, key findings, diagnosis with reasoning, management and response, and the plan.',
            minWords: 100,
            rubric: <Concept>[
              Concept('summary', 'One-line summary', <String>['year old', 'presented with', 'presenting with', '81']),
              Concept('findings', 'Key findings', <String>['lactate', 'consolidation', 'hypotens*', 'tachycard*', 'crp']),
              Concept('dx', 'Diagnosis with reasoning', <String>['sepsis', 'septic shock', 'pneumonia', 'because', 'consistent with']),
              Concept('mgmt', 'Management given', <String>['antibiotic*', 'fluid*', 'oxygen', 'cultures']),
              Concept('plan', 'Plan and escalation', <String>['critical care', 'icu', 'vasopressor*', 'plan', 'reassess']),
            ],
          ),
        ),
      ],
    ),
    DeptUnit(
      id: 'md_anat',
      title: 'Anatomy Laboratory',
      emoji: '🫀',
      setting: 'Prosection bench with a sectioned heart model.',
      modules: <TrainingModule>[_m3],
    ),
  ],
  certifications: <Certification>[
    Certification(
      id: 'md_cert_acute',
      title: 'Acute Care Certificate',
      issuer: 'GradeGlow School of Medicine',
      requiresModules: <String>['md_m2'],
      tasks: <TaskSpec>[_chestPain, _breathless],
    ),
  ],
);

const CompanyProfile _riverside = CompanyProfile(
  name: 'Riverside General Hospital',
  industry: 'Acute hospital trust',
  about: 'A district general hospital with acute medicine, cardiology and a 24-hour emergency department.',
  team: 'Foundation doctors join a firm: a consultant, a registrar, a core trainee and two foundation doctors.',
  training: 'Weekly teaching, a named clinical and educational supervisor, and workplace-based assessments.',
  culture: 'Ask for help early; seniors are always available on call.',
  success: 'Safe prescribing, clear documentation and early escalation of unwell patients.',
  tools: 'Electronic patient record, results viewer and electronic prescribing.',
  nextSteps: 'The foundation school confirms allocations within two working days.',
);

const List<JobPosting> medicinePostings = <JobPosting>[
  JobPosting(
    id: 'md_attach_riverside',
    deptId: 'medicine',
    company: _riverside,
    title: 'Clinical Attachment — Acute Medicine',
    type: JobType.internship,
    stageOnHire: CareerStage.intern,
    description: 'A supervised clinical attachment on the acute medical unit.',
    responsibilities: <String>['Clerk new admissions', 'Present cases to seniors', 'Document ward rounds'],
    qualifications: <String>['Medical student with Trainee status', 'History and chest-pain training'],
    experience: 'None required.',
    requirements: JobRequirements(
      modules: <String>['md_m1', 'md_m2'],
      skills: <String, int>{'md_history': 1, 'md_reason': 1},
      projects: 1,
      minStage: CareerStage.trainee,
    ),
    salaryMin: 0,
    salaryMax: 0,
    salaryPeriod: 'month',
    location: 'On-site · Acute Medical Unit',
    openDay: 1,
    deadlineDay: 40,
    interviewPlanId: 'md_iv',
    workplaceId: 'md_amu',
  ),
  JobPosting(
    id: 'md_fy1_riverside',
    deptId: 'medicine',
    company: _riverside,
    title: 'Foundation Year 1 Doctor',
    type: JobType.entryLevel,
    stageOnHire: CareerStage.entryLevel,
    description: 'A four-month FY1 rotation in acute medicine.',
    responsibilities: <String>['Assess and manage ward patients', 'Prescribe safely', 'Escalate deterioration', 'Write discharge summaries'],
    qualifications: <String>['Completed clinical attachment', 'Acute Care Certificate'],
    experience: 'A completed clinical attachment.',
    requirements: JobRequirements(
      modules: <String>['md_m1', 'md_m2', 'md_m3'],
      skills: <String, int>{'md_reason': 2, 'md_manage': 2},
      projects: 1,
      minStage: CareerStage.intern,
      certifications: <String>['md_cert_acute'],
      completedInternship: true,
    ),
    salaryMin: 36600,
    salaryMax: 36600,
    location: 'On-site · Riverside',
    openDay: 1,
    deadlineDay: 55,
    interviewPlanId: 'md_iv',
    workplaceId: 'md_amu',
  ),
];

const InterviewPlan medicineInterview = InterviewPlan(
  id: 'md_iv',
  interviewer: 'Dr Samuel Adeyemi',
  interviewerRole: 'Consultant Physician',
  opening: 'Good morning. We\'ll cover a clinical case, some prioritisation, and your questions.',
  main: <String>['md_q1', 'md_case', 'md_q2', 'md_q3', 'md_q4'],
  bank: <InterviewQuestion>[
    InterviewQuestion(
      id: 'md_q1',
      prompt: 'Why acute medicine?',
      competency: Competency.communication,
      minWords: 30,
      rubric: <Concept>[
        Concept('motive', 'Motivation', <String>['because', 'enjoy', 'interested', 'motivat*']),
        Concept('acute', 'Understands the specialty', <String>['acute', 'undifferentiated', 'unwell', 'variety', 'emergency']),
      ],
    ),
    InterviewQuestion(
      id: 'md_case',
      prompt: 'Case: a breathless, confused patient from a care home. Work her up.',
      competency: Competency.problemSolving,
      practical: _breathless,
    ),
    InterviewQuestion(
      id: 'md_q2',
      prompt: 'You are bleeped about three patients at once: chest pain, a fall with no injury, and a request to rewrite a drug chart. Who do you see first and why?',
      competency: Competency.problemSolving,
      minWords: 30,
      probeId: 'md_q2p',
      rubric: <Concept>[
        Concept('chest', 'Chest pain first', <String>['chest pain first', 'see the chest pain', 'chest pain patient first', 'chest pain because']),
        Concept('ecg', 'Delegates an ECG / gathers info by phone', <String>['ecg', 'ask the nurse', 'observations', 'obs']),
        Concept('defer', 'Defers the routine task', <String>['drug chart later', 'later', 'routine', 'can wait']),
      ],
    ),
    InterviewQuestion(
      id: 'md_q2p',
      prompt: 'What would you ask the nurse on the phone before you arrive?',
      competency: Competency.problemSolving,
      minWords: 20,
      rubric: <Concept>[
        Concept('obs', 'Observations', <String>['observations', 'obs', 'blood pressure', 'saturation*', 'heart rate']),
        Concept('ecg', 'ECG', <String>['ecg']),
      ],
    ),
    InterviewQuestion(
      id: 'md_q3',
      prompt: 'Which leads show ST elevation in an inferior MI?',
      competency: Competency.technical,
      options: <String>['V1–V4', 'II, III, aVF', 'I, aVL, V5–V6', 'aVR only'],
      correctOption: 1,
    ),
    InterviewQuestion(
      id: 'md_q4',
      prompt: 'Tell me about a mistake you made and what you learned.',
      competency: Competency.readiness,
      behavioural: true,
      minWords: 40,
      rubric: <Concept>[
        Concept('own', 'Owns the mistake', <String>['i made', 'my mistake', 'i forgot', 'i missed', 'i should have']),
        Concept('fix', 'Acted to fix it', <String>['told', 'reported', 'corrected', 'apologis*', 'apologiz*']),
        Concept('learn', 'Learning', <String>['learned', 'learnt', 'now i', 'since then', 'changed']),
      ],
    ),
  ],
);

const List<AssignmentSpec> _mdAssignments = <AssignmentSpec>[
  AssignmentSpec(
    id: 'md_a1',
    title: 'Take · Bed 7 chest pain',
    ticket: 'Registrar: "New chest pain in bed 7 — see him and tell me what you think."',
    acceptance: <String>['Correct working diagnosis', 'Time-critical treatment started'],
    task: _chestPain,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'md_a2',
    title: 'Take · Care-home admission',
    ticket: 'An 81-year-old with suspected sepsis needs clerking and a plan.',
    acceptance: <String>['Sepsis bundle within the hour', 'Escalation when fluid-refractory'],
    task: _breathless,
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'md_a3',
    title: 'Ward · Prescribing check',
    ticket: 'Pharmacy flagged four prescriptions. Decide what to do with each.',
    acceptance: <String>['Every prescription handled safely'],
    task: ClassifyTaskSpec(
      id: 'rx_check',
      title: 'Prescribing check',
      brief: 'Classify each prescription.',
      categories: <String>['Safe to continue', 'Stop or change now'],
      items: <ClassifyItem>[
        ClassifyItem('Ibuprofen 400 mg TDS; eGFR 22, on ACE inhibitor', 'Stop or change now', 'NSAIDs worsen renal failure, especially with ACE inhibitors.'),
        ClassifyItem('Simvastatin 40 mg with clarithromycin started today', 'Stop or change now', 'Clarithromycin greatly raises simvastatin levels (myopathy risk).'),
        ClassifyItem('Paracetamol 1 g QDS; 72 kg, normal LFTs', 'Safe to continue', 'Within the maximum daily dose.'),
        ClassifyItem('Enoxaparin prophylaxis; platelets 210, no bleeding', 'Safe to continue', 'No contraindication.'),
      ],
    ),
    deadlineDays: 1,
  ),
  AssignmentSpec(
    id: 'md_a4',
    title: 'Ward · Discharge summary',
    ticket: 'Mr Brooks is going home after PCI. Write his discharge summary for the GP.',
    acceptance: <String>['Diagnosis, procedure, medicines, follow-up and safety-netting'],
    task: WrittenTaskSpec(
      id: 'discharge',
      title: 'Discharge summary',
      brief: 'Write the summary.',
      minWords: 80,
      rubric: <Concept>[
        Concept('dx', 'Diagnosis', <String>['stemi', 'myocardial infarction', 'inferior']),
        Concept('proc', 'Procedure', <String>['pci', 'stent*', 'angiogra*']),
        Concept('meds', 'Medicines started', <String>['aspirin', 'ticagrelor', 'clopidogrel', 'statin', 'beta blocker', 'bisoprolol', 'ramipril']),
        Concept('follow', 'Follow-up', <String>['follow up', 'clinic', 'rehab*', 'gp to']),
        Concept('safety', 'Safety-netting', <String>['return if', 'call 999', 'seek help', 'if chest pain']),
      ],
    ),
  ),
  AssignmentSpec(
    id: 'md_a5',
    title: 'Teaching · Anatomy for the ECG',
    ticket: 'Prepare the anatomy slide for Friday teaching.',
    acceptance: <String>['All structures identified'],
    task: _heart,
  ),
  AssignmentSpec(
    id: 'md_lead1',
    title: 'Lead the evening handover',
    ticket: 'You are the senior on the evening shift. Write the handover plan for the night team.',
    acceptance: <String>['Prioritised sick list, jobs with owners, escalation thresholds'],
    leadership: true,
    deadlineDays: 1,
    task: WrittenTaskSpec(
      id: 'handover_plan',
      title: 'Night handover',
      brief: 'Write the handover.',
      minWords: 90,
      rubric: <Concept>[
        Concept('sick', 'Sickest patients first', <String>['sickest', 'most unwell', 'priorit*', 'unwell']),
        Concept('jobs', 'Outstanding jobs with owners', <String>['job*', 'task*', 'owner', 'responsible', 'to do']),
        Concept('thresh', 'Escalation thresholds', <String>['escalat*', 'if', 'call', 'registrar', 'threshold*']),
        Concept('ceiling', 'Ceilings of care', <String>['ceiling*', 'dnacpr', 'resus*', 'treatment escalation']),
      ],
    ),
  ),
];

const List<WorkplaceDef> medicineWorkplaces = <WorkplaceDef>[
  WorkplaceDef(
    id: 'md_amu',
    deptId: 'medicine',
    name: 'Riverside General — Acute Medical Unit',
    environment: 'Post-take ward round at 08:00, board round at 13:00, evening handover at 20:30; results and prescribing on the EPR.',
    supervisor: 'Dr Samuel Adeyemi',
    supervisorRole: 'Consultant Physician, clinical supervisor',
    tools: <String>['Electronic patient record', 'Results viewer', 'Electronic prescribing'],
    assignments: _mdAssignments,
    titles: <CareerStage, String>{
      CareerStage.intern: 'Medical Student (attachment)',
      CareerStage.entryLevel: 'Foundation Year 1 Doctor',
      CareerStage.junior: 'Foundation Year 2 Doctor',
      CareerStage.experienced: 'Core Medical Trainee',
      CareerStage.senior: 'Medical Registrar',
      CareerStage.lead: 'Consultant Physician',
    },
    returnOfferPostingId: 'md_fy1_riverside',
  ),
];
