import '../../engine/text_rubric.dart';
import '../../model/tasks.dart';
import '../lab_models.dart';
import 'gen_med_core.dart';
import 'gen_nurse_core.dart';

// Nursing (GradeGlow Teaching Hospital) and Medicine (Clinical Skills Centre).
// All patients are fictional. Scoring follows published guidance: NEWS2
// (Royal College of Physicians, 2017), WHO hand hygiene (2009) and the
// Resuscitation Council UK anaphylaxis algorithm (2021). Educational
// simulation only — not instructions for unsupervised care.

const Patient amira = Patient(
  id: 'amira',
  name: 'Amira Hassan',
  age: 34,
  sex: 'Female',
  mrn: 'GG-310577',
  dob: '02/09/1991',
  bed: 'Admissions Unit, Bay 2',
  presenting: 'Lower abdominal pain and vomiting for two days',
  history: <String>['Asthma (inhaler as needed)', 'Appendix intact; no previous operations'],
  allergies: <String>['Codeine (vomiting)'],
  medications: <MedOrder>[MedOrder('Salbutamol', '100 micrograms', 'Inhaled', 'PRN', 'As needed')],
  vitals: <Vitals>[Vitals(time: '09:10', rr: 18, spo2: 98, sbp: 118, dbp: 72, hr: 96, temp: 37.6, pain: 6)],
  weightKg: 61,
  notes: <String>['09:05 Arrived from the emergency department with a porter. Notes and cannula in situ.'],
);

const Patient james = Patient(
  id: 'james',
  name: 'James Carter',
  age: 58,
  sex: 'Male',
  mrn: 'GG-208841',
  dob: '21/11/1967',
  bed: 'Surgical Ward 6, Bed 12',
  presenting: 'Day 2 after a bowel resection',
  history: <String>['Colorectal cancer — anterior resection two days ago', 'Hypertension', 'Ex-smoker'],
  allergies: <String>['No known drug allergies'],
  medications: <MedOrder>[
    MedOrder('Paracetamol', '1 g', 'IV', 'QDS', '12:00', lastGiven: '06:00'),
    MedOrder('Enoxaparin', '40 mg', 'Subcutaneous', 'OD', '18:00'),
    MedOrder('Amlodipine', '5 mg', 'Oral', 'OD', '08:00', lastGiven: '08:00'),
  ],
  labs: <Fact>[Fact('WCC (06:00)', '14.8 ×10⁹/L'), Fact('CRP (06:00)', '186 mg/L'), Fact('Lactate', 'Not yet taken')],
  vitals: <Vitals>[
    Vitals(time: '08:00', rr: 18, spo2: 97, sbp: 128, dbp: 78, hr: 84, temp: 37.0, pain: 2),
    Vitals(time: '10:00', rr: 20, spo2: 96, sbp: 120, dbp: 76, hr: 92, temp: 37.9, pain: 3),
    Vitals(time: '12:00', rr: 21, spo2: 95, sbp: 112, dbp: 70, hr: 98, temp: 38.2, pain: 5),
    Vitals(time: '14:00', rr: 24, spo2: 93, sbp: 100, dbp: 62, hr: 112, temp: 38.6, pain: 7),
  ],
  notes: <String>['07:30 Mobilised to chair with assistance. Wound clean.', '11:40 Reports increasing abdominal discomfort.'],
  weightKg: 82,
);

const Patient margaret = Patient(
  id: 'margaret',
  name: 'Margaret Ellis',
  age: 72,
  sex: 'Female',
  mrn: 'GG-104233',
  dob: '14/03/1953',
  bed: 'Medical Ward 4B, Bed 3',
  presenting: 'Fall at home; left hip pain (no fracture on X-ray)',
  history: <String>['Atrial fibrillation', 'Type 2 diabetes', 'Hypertension'],
  allergies: <String>['Penicillin — rash'],
  medications: <MedOrder>[
    MedOrder('Apixaban', '5 mg', 'Oral', 'BD', '08:00', lastGiven: 'Yesterday 20:00'),
    MedOrder('Metformin', '500 mg', 'Oral', 'BD with food', '08:00', notes: 'Eating breakfast normally'),
    MedOrder('Bisoprolol', '2.5 mg', 'Oral', 'OD', '08:00', notes: 'Hold if heart rate below 50'),
    MedOrder('Amoxicillin', '500 mg', 'Oral', 'TDS', '08:00', notes: 'New order — for a urine infection'),
    MedOrder('Enoxaparin', '40 mg', 'Subcutaneous', 'OD', '08:00', notes: 'New order — VTE prophylaxis'),
  ],
  labs: <Fact>[Fact('eGFR', '58 mL/min'), Fact('Glucose (07:00)', '7.8 mmol/L'), Fact('Hb', '118 g/L'), Fact('Potassium', '4.2 mmol/L')],
  vitals: <Vitals>[Vitals(time: '07:30', rr: 16, spo2: 96, sbp: 134, dbp: 80, hr: 48, temp: 36.8, pain: 3)],
  weightKg: 64,
);

const Patient robert = Patient(
  id: 'robert',
  name: 'Robert Mensah',
  age: 61,
  sex: 'Male',
  mrn: 'GG-412906',
  dob: '05/06/1965',
  bed: 'Clinic Room 3',
  presenting: 'Sudden breathlessness and chest pain',
  history: <String>['Knee replacement 4 weeks ago', 'Hypercholesterolaemia'],
  allergies: <String>['No known drug allergies'],
  medications: <MedOrder>[MedOrder('Atorvastatin', '20 mg', 'Oral', 'ON', '22:00')],
  vitals: <Vitals>[Vitals(time: '10:20', rr: 24, spo2: 91, sbp: 128, dbp: 82, hr: 112, temp: 37.2, pain: 5)],
  weightKg: 88,
);

const List<LabPerson> _wardTeam = <LabPerson>[
  LabPerson('Sister Helen Mbeki', 'Nurse in charge', 'Check the record before you act, and tell me early if you are worried.'),
  LabPerson('Dr Kwame Asante', 'Ward doctor (bleep 2241)', 'Use SBAR when you call, and have the observations in front of you.'),
];

final LabSpec nursingAdmissionLab = LabSpec(
  id: 'nu_lab_admission',
  deptId: 'nursing',
  majorId: 'nursing',
  number: 1,
  title: 'Patient Admission',
  environment: LabEnvironment.hospitalWard,
  summary: 'Admit a patient: positive identification against the record, a focused admission interview and the admission note.',
  objectives: const <String>['Identify the patient with three identifiers', 'Take a focused admission history', 'Document the admission'],
  skills: const <String>['nu_assess', 'nu_comm'],
  difficulty: LabDifficulty.foundation,
  minutes: 30,
  patients: const <Patient>[amira],
  scenarios: <LabScenario>[
    LabScenario(
      id: 'admit_amira',
      title: 'Admissions Unit: Amira Hassan',
      people: <LabPerson>[
        LabPerson('Amira Hassan', 'Patient', 'I just want to know what\'s causing this pain.'),
        LabPerson('Sister Helen Mbeki', 'Nurse in charge', 'Bay 2 has just arrived from the emergency department. Admit her, please.'),
      ],
      briefing: Briefing(
        what: 'Admit the patient in Bay 2: confirm her identity, take the admission history and write the admission note.',
        why: 'Wrong-patient errors and missing allergy information are leading causes of preventable harm.',
        information: <String>['The electronic record, wristband and the patient herself are your sources.', 'She has a cannula in place from the emergency department.'],
        tools: <String>['Patient record', 'Bedside monitor', 'Admission documentation'],
        expected: 'Identity confirmed (or the error caught), essential history taken and a complete admission note.',
        requirements: <String>['Never continue care if identifiers do not match.', 'Ask about allergies before any medicine is given.'],
      ),
      steps: <LabStep>[
        IdentityCheckStep(
          id: 'identity',
          title: 'Positive patient identification',
          instructions: 'Compare the wristband and what the patient tells you with the record. Mark any identifier that does not match, then decide.',
          patientId: 'amira',
          wristband: <String, String>{'Name': 'Amira Hassan', 'Date of birth': '02/09/1991', 'MRN': 'GG-310575'},
          stated: <String, String>{'Name': 'Amira Hassan', 'Date of birth': '02/09/1991', 'MRN': 'GG-310577'},
          skills: <String>['nu_assess'],
        ),
        HistoryStep(
          id: 'admission_history',
          title: 'Admission interview and note',
          instructions: 'The wristband has been reprinted and checked. Choose up to 7 questions, then write the admission note.',
          patientId: 'amira',
          maxQuestions: 7,
          skills: <String>['nu_assess', 'nu_comm'],
          questions: <HistoryQuestion>[
            HistoryQuestion('Where is the pain, and when did it start?', 'Low down on the right side. It started two days ago around my belly button and moved.', essential: true),
            HistoryQuestion('How bad is the pain from 0 to 10?', 'About a 6. It\'s worse when I move or cough.', essential: true),
            HistoryQuestion('Do you have any allergies to medicines?', 'Codeine makes me sick — I vomited for a day.', essential: true),
            HistoryQuestion('What medicines do you take?', 'Just my blue inhaler, maybe once a week.', essential: true),
            HistoryQuestion('Could you be pregnant?', 'I don\'t think so — my last period was three weeks ago. I\'m happy to do a test.', essential: true),
            HistoryQuestion('Any other medical problems or operations?', 'Asthma since childhood. No operations.'),
            HistoryQuestion('When did you last eat or drink?', 'A few sips of water at 6 this morning. Nothing to eat since yesterday.'),
            HistoryQuestion('Have you had a fever?', 'I felt hot and shivery last night.'),
            HistoryQuestion('What is your favourite food?', 'Um… pasta?', relevant: false),
            HistoryQuestion('Do you drive to work?', 'I take the bus.', relevant: false),
          ],
          noteRubric: <Concept>[
            Concept('complaint', 'Presenting complaint and pain', <String>['pain', 'abdominal', 'right', 'vomit*']),
            Concept('score', 'Pain score', <String>['6/10', '6 out of 10', 'pain score', 'score of 6']),
            Concept('allergy', 'Allergy recorded with reaction', <String>['codeine', 'allerg*']),
            Concept('meds', 'Current medicines', <String>['salbutamol', 'inhaler']),
            Concept('pregnancy', 'Pregnancy status', <String>['pregnan*', 'period', 'lmp']),
            Concept('plan', 'Plan and escalation', <String>['plan', 'inform*', 'doctor', 'review', 'escalat*', 'monitor*']),
          ],
        ),
      ],
    ),
    ...nuLabAdmissionExtra,
  ],
);

final LabSpec nursingVitalsLab = LabSpec(
  id: 'nu_lab_vitals',
  deptId: 'nursing',
  majorId: 'nursing',
  number: 2,
  title: 'Vital Signs and Early Warning',
  environment: LabEnvironment.hospitalWard,
  summary: 'Watch a post-operative patient\'s observations change through the day; score NEWS2 and escalate at the right time.',
  objectives: const <String>['Calculate NEWS2 from a full set of observations', 'Match the clinical response to the score', 'Recognise a red score'],
  skills: const <String>['nu_assess', 'nu_escalate'],
  difficulty: LabDifficulty.intermediate,
  minutes: 25,
  patients: const <Patient>[james],
  scenarios: <LabScenario>[
    LabScenario(
      id: 'obs_james',
      title: 'Surgical Ward 6: Bed 12',
      people: _wardTeam,
      briefing: Briefing(
        what: 'Record and interpret Mr Carter\'s observations at each round and choose the escalation response.',
        why: 'Deterioration after surgery is often visible hours before collapse — if the scores are acted on.',
        information: <String>['SpO₂ scale 1 applies (no target-range prescription).', 'He is breathing room air unless stated.'],
        tools: <String>['Bedside monitor', 'Observation chart', 'Patient record', 'NEWS2 escalation chart'],
        expected: 'Correct NEWS2 totals and responses for every round.',
        requirements: <String>['Under-escalating a deteriorating patient fails the lab.'],
      ),
      steps: <LabStep>[
        VitalsStep(id: 'news_rounds', title: 'Observation rounds', instructions: 'For each round, read the monitor, calculate NEWS2 and choose the response.', patientId: 'james', skills: <String>['nu_escalate', 'nu_assess']),
      ],
    ),
    ...nuLabVitalsExtra,
  ],
);

final LabSpec nursingMedsLab = LabSpec(
  id: 'nu_lab_meds',
  deptId: 'nursing',
  majorId: 'nursing',
  number: 3,
  title: 'Medication Safety',
  environment: LabEnvironment.hospitalWard,
  summary: 'Run a morning medication round from the MAR, checking allergies, observations and duplicate therapy against the record.',
  objectives: const <String>['Apply the rights of medication administration', 'Spot allergy and duplication errors', 'Calculate doses accurately'],
  skills: const <String>['nu_meds'],
  difficulty: LabDifficulty.intermediate,
  minutes: 30,
  patients: const <Patient>[margaret],
  scenarios: <LabScenario>[
    LabScenario(
      id: 'round_margaret',
      title: 'Ward 4B: 08:00 medication round',
      people: _wardTeam,
      briefing: const Briefing(
        what: 'Give, hold or query each of Mrs Ellis\'s 08:00 medicines, then complete two dose calculations.',
        why: 'Most medication harm happens at administration — the last chance to catch a prescribing error.',
        information: <String>['Check the allergy record, the latest observations and the other medicines before each dose.'],
        tools: <String>['Medication administration record (MAR)', 'Patient record', 'Bedside monitor'],
        expected: 'Every dose handled safely and calculations within tolerance.',
        requirements: <String>['Giving a dose that should be held or queried fails the round.'],
      ),
      steps: <LabStep>[
        const MarStep(
          id: 'mar_round',
          title: '08:00 round',
          instructions: 'Open each medicine on the MAR and decide.',
          patientId: 'margaret',
          skills: <String>['nu_meds'],
          correct: <MedDecision>[MedDecision.give, MedDecision.give, MedDecision.hold, MedDecision.query, MedDecision.query],
          why: <String>[
            'Apixaban is due and nothing in the record contraindicates it.',
            'She is eating breakfast; metformin with food is appropriate.',
            'Heart rate is 48 — the order says hold if below 50. Hold and inform the prescriber.',
            'Amoxicillin is a penicillin and she has a documented penicillin allergy. Do not give; query the order.',
            'She is already anticoagulated with apixaban; adding enoxaparin duplicates anticoagulation. Query before giving.',
          ],
        ),
        TaskStep(const NumericTaskSpec(
          id: 'ward_calcs',
          title: 'Dose calculations',
          brief: 'Two orders from the same ward round.',
          skills: <String>['nu_meds'],
          givens: <Fact>[Fact('Order 1', 'Morphine 2 mg IV; stock 10 mg in 1 mL'), Fact('Order 2', '1,000 mL sodium chloride 0.9% over 10 hours')],
          parts: <NumericPart>[
            NumericPart('Volume of morphine', 0.2, unit: 'mL', method: 'Dose wanted ÷ stock strength × volume.'),
            NumericPart('Infusion rate', 100, unit: 'mL/h', method: 'Volume ÷ time.'),
          ],
        )),
      ],
    ),
    ...nuLabMedsExtra,
  ],
);

final LabSpec nursingProceduresLab = LabSpec(
  id: 'nu_lab_procedures',
  deptId: 'nursing',
  majorId: 'nursing',
  number: 4,
  title: 'Clinical Procedures',
  environment: LabEnvironment.hospitalWard,
  summary: 'Infection prevention: WHO hand rub technique and an aseptic wound dressing change, step by step.',
  objectives: const <String>['Perform hand hygiene in the WHO sequence', 'Sequence an aseptic dressing change'],
  skills: const <String>['nu_assess'],
  difficulty: LabDifficulty.foundation,
  minutes: 20,
  patients: const <Patient>[james],
  scenarios: <LabScenario>[
    LabScenario(
      id: 'dressing',
      title: 'Wound care: Bed 12',
      people: _wardTeam,
      briefing: const Briefing(
        what: 'Perform hand hygiene and change Mr Carter\'s abdominal wound dressing aseptically.',
        why: 'Surgical site infections lengthen stays and are largely preventable with technique.',
        information: <String>['The dressing is due to be changed today; the wound was clean this morning.'],
        tools: <String>['Dressing trolley', 'Sterile dressing pack', 'Alcohol hand rub'],
        expected: 'Both procedures performed in the correct order.',
        requirements: <String>['Hand hygiene before and after patient contact.'],
      ),
      steps: <LabStep>[
        TaskStep(const OrderTaskSpec(
          id: 'hand_rub',
          title: 'WHO hand rub technique',
          brief: 'Order the steps of the WHO alcohol hand rub technique.',
          skills: <String>['nu_assess'],
          steps: <String>[
            'Apply a palmful of hand rub into a cupped hand',
            'Rub palm to palm',
            'Right palm over left dorsum with interlaced fingers, and vice versa',
            'Palm to palm with fingers interlaced',
            'Backs of fingers to opposing palms with fingers interlocked',
            'Rotational rubbing of each thumb clasped in the opposite palm',
            'Rotational rubbing of clasped fingertips in the opposite palm',
          ],
          why: 'The WHO sequence covers every surface; skipping thumbs and fingertips is the most common miss.',
        )),
        TaskStep(const OrderTaskSpec(
          id: 'aseptic_dressing',
          title: 'Aseptic dressing change',
          brief: 'Order the steps of the dressing change.',
          skills: <String>['nu_assess'],
          steps: <String>[
            'Confirm identity, explain the procedure and gain consent',
            'Perform hand hygiene and clean the dressing trolley',
            'Open the sterile pack to create a sterile field',
            'Remove the old dressing with clean gloves and dispose of it',
            'Perform hand hygiene and put on sterile gloves',
            'Clean the wound as per protocol and assess it',
            'Apply the new dressing',
            'Dispose of waste, perform hand hygiene and document the wound assessment',
          ],
          why: 'Contaminated items are removed before sterile gloves go on; documentation completes the procedure.',
        )),
      ],
    ),
    ...nuLabProceduresExtra,
  ],
);

final LabSpec nursingEmergencyLab = LabSpec(
  id: 'nu_lab_emergency',
  deptId: 'nursing',
  majorId: 'nursing',
  number: 5,
  title: 'Emergency Nursing: The Deteriorating Patient',
  environment: LabEnvironment.hospitalWard,
  summary: 'Mr Carter\'s condition worsens while you are with him. Prioritise, act and escalate with a structured SBAR call.',
  objectives: const <String>['Recognise sepsis after surgery', 'Prioritise immediate actions', 'Escalate using SBAR'],
  skills: const <String>['nu_escalate', 'nu_comm'],
  difficulty: LabDifficulty.advanced,
  minutes: 30,
  prerequisites: const <String>['nu_lab_vitals'],
  patients: const <Patient>[james],
  scenarios: <LabScenario>[
    LabScenario(
      id: 'sepsis_james',
      title: '14:00, Bed 12',
      people: _wardTeam,
      briefing: const Briefing(
        what: 'Respond to Mr Carter\'s 14:00 observations and call the outreach team.',
        why: 'In sepsis, every hour of delay to treatment increases mortality.',
        information: <String>['Open the observation chart for the trend since 08:00.', 'Bloods this morning showed raised inflammatory markers.'],
        tools: <String>['Bedside monitor', 'Patient record', 'Phone to the outreach team'],
        expected: 'Safe immediate actions and a complete SBAR call.',
        requirements: <String>['Escalate immediately; do not wait for the ward round.'],
      ),
      steps: <LabStep>[
        TaskStep(const DecisionTaskSpec(
          id: 'sepsis_actions',
          title: 'Immediate actions',
          brief: 'Decide at each point.',
          setting: '14:00 — RR 24, SpO₂ 93% on air, BP 100/62, HR 112, temperature 38.6 °C. He looks flushed and anxious.',
          skills: <String>['nu_escalate'],
          facts: <Fact>[Fact('NEWS2', 'Calculate from the monitor'), Fact('Surgery', 'Bowel resection, day 2')],
          steps: <DecisionStep>[
            DecisionStep('What do you do first?', <DecisionOption>[
              DecisionOption('Call for help: alert the nurse in charge and the outreach team now', 2, 'A score of 7 or more needs an emergency response immediately.'),
              DecisionOption('Give paracetamol for the fever and recheck in an hour', 0, 'Treating the number delays escalation of possible sepsis.', critical: true),
              DecisionOption('Document the observations and tell the next shift', 0, 'Delay can be fatal.', critical: true),
            ]),
            DecisionStep('While waiting for the team?', <DecisionOption>[
              DecisionOption('Start oxygen to target saturations, stay with him and repeat observations', 2, 'Support breathing and monitor closely.'),
              DecisionOption('Leave to fetch the drug trolley from another ward', 0, 'Never leave a deteriorating patient alone.'),
              DecisionOption('Sit him flat to rest', 1, 'Sitting him up usually helps breathing.'),
            ], update: 'The outreach nurse is 5 minutes away.'),
            DecisionStep('The doctor prescribes cultures and IV antibiotics. In which order?', <DecisionOption>[
              DecisionOption('Take blood cultures first, then give antibiotics without delay', 2, 'Cultures before antibiotics, as long as this does not delay treatment.'),
              DecisionOption('Give antibiotics now; take cultures tomorrow', 1, 'Cultures after antibiotics may be falsely negative.'),
            ]),
          ],
        )),
        TaskStep(const WrittenTaskSpec(
          id: 'sbar_call',
          title: 'SBAR call to outreach',
          brief: 'Write exactly what you will say on the phone.',
          minWords: 60,
          maxWords: 220,
          skills: <String>['nu_comm'],
          rubric: <Concept>[
            Concept('s', 'Situation: who you are, who the patient is, your concern', <String>['calling about', 'i am', 'concerned', 'my name']),
            Concept('b', 'Background: surgery and day', <String>['bowel', 'resection', 'day 2', 'surgery', 'post op']),
            Concept('a', 'Assessment with observations and score', <String>['24', '93', '100', '112', '38', 'news', 'sepsis']),
            Concept('r', 'Recommendation with a timescale', <String>['please review', 'come now', 'within', 'minutes', 'now']),
          ],
        )),
      ],
    ),
    ...nuLabEmergencyExtra,
  ],
);

final LabSpec nursingShiftLab = LabSpec(
  id: 'nu_lab_shift',
  deptId: 'nursing',
  majorId: 'nursing',
  number: 6,
  title: 'Full Hospital Shift',
  environment: LabEnvironment.hospitalWard,
  summary: 'Three patients, one morning: prioritise, run the medication round, act on observations and hand over.',
  objectives: const <String>['Prioritise by acuity', 'Combine medication, observation and documentation skills', 'Give a safe handover'],
  skills: const <String>['nu_assess', 'nu_meds', 'nu_escalate', 'nu_comm'],
  difficulty: LabDifficulty.advanced,
  minutes: 60,
  prerequisites: const <String>['nu_lab_vitals', 'nu_lab_meds'],
  patients: const <Patient>[james, margaret, amira],
  scenarios: <LabScenario>[
    LabScenario(
      id: 'morning_shift',
      title: 'Morning shift',
      people: _wardTeam,
      briefing: const Briefing(
        what: 'You are allocated Mr Carter, Mrs Ellis and Ms Hassan. Prioritise, deliver their care and hand over at the end of the shift.',
        why: 'Real shifts are about judgement across several patients at once.',
        information: <String>['Open each patient\'s record before deciding.'],
        tools: <String>['Patient records', 'MAR', 'Bedside monitor', 'Handover sheet'],
        expected: 'Safe prioritisation, medicines and escalation, and a structured handover.',
        requirements: <String>['Safety errors fail the shift.'],
      ),
      steps: <LabStep>[
        TaskStep(const OrderTaskSpec(
          id: 'priorities',
          title: 'Prioritise your patients',
          brief: 'At 14:00, order the tasks from most to least urgent.',
          skills: <String>['nu_escalate'],
          steps: <String>[
            'Mr Carter: NEWS2 of 9 — emergency escalation',
            'Mrs Ellis: medication queries outstanding (allergy and anticoagulant)',
            'Ms Hassan: pain reassessment after analgesia',
            'Update the whiteboard and discharge paperwork for tomorrow',
          ],
          why: 'Life-threatening deterioration first, then safety-critical medicine issues, then comfort, then administration.',
        )),
        const MarStep(
          id: 'shift_mar',
          title: 'Mrs Ellis — 08:00 medicines',
          instructions: 'Decide each dose from the MAR and the record.',
          patientId: 'margaret',
          skills: <String>['nu_meds'],
          correct: <MedDecision>[MedDecision.give, MedDecision.give, MedDecision.hold, MedDecision.query, MedDecision.query],
          why: <String>[
            'Apixaban is due.',
            'Eating normally — give with food.',
            'Heart rate 48: hold as ordered and inform the prescriber.',
            'Penicillin allergy: do not give amoxicillin.',
            'Duplicate anticoagulation with apixaban.',
          ],
        ),
        const VitalsStep(id: 'shift_obs', title: 'Mr Carter — observation rounds', instructions: 'Score and respond to each round.', patientId: 'james', skills: <String>['nu_escalate']),
        TaskStep(const WrittenTaskSpec(
          id: 'handover',
          title: 'End-of-shift handover',
          brief: 'Write the handover for the late shift covering all three patients.',
          minWords: 100,
          skills: <String>['nu_comm'],
          rubric: <Concept>[
            Concept('carter', 'Mr Carter: deterioration and actions taken', <String>['carter', 'sepsis', 'outreach', 'news']),
            Concept('ellis', 'Mrs Ellis: held and queried medicines', <String>['ellis', 'bisoprolol', 'amoxicillin', 'enoxaparin', 'queried', 'held']),
            Concept('hassan', 'Ms Hassan: pain and plan', <String>['hassan', 'pain']),
            Concept('outstanding', 'Outstanding tasks', <String>['outstanding', 'due', 'follow up', 'pending', 'awaiting']),
          ],
        )),
      ],
    ),
    ...nuLabShiftExtra,
  ],
);

// ------------------------------------------------------------ medicine

const List<LabPerson> _clinicTeam = <LabPerson>[
  LabPerson('Dr Samuel Adeyemi', 'Consultant, clinical skills lead', 'Take a focused history before you order anything. Every test needs a reason.'),
];

final LabSpec medicineAnatomyLab = LabSpec(
  id: 'md_lab_anatomy',
  deptId: 'medicine',
  majorId: 'medicine',
  number: 1,
  title: 'Human Anatomy',
  environment: LabEnvironment.clinicRoom,
  summary: 'Explore the organs, skeleton and respiratory system on the anatomy atlas, then pass an identification test.',
  objectives: const <String>['Locate the major organs', 'Name the principal bones', 'Trace the airway'],
  skills: const <String>['md_anatomy'],
  difficulty: LabDifficulty.foundation,
  minutes: 30,
  scenarios: <LabScenario>[
    LabScenario(
      id: 'atlas_test',
      title: 'Anatomy identification test',
      people: _clinicTeam,
      briefing: Briefing(
        what: 'Study the atlas, then identify each highlighted structure.',
        why: 'Every examination, image and procedure depends on knowing where structures are.',
        information: <String>['Tap any structure in the atlas to read its function and clinical relevance.'],
        tools: <String>['Anatomy atlas'],
        expected: 'At least 80% of structures identified in each system.',
      ),
      steps: <LabStep>[
        AnatomyIdStep(id: 'organs', title: 'Major organs', instructions: 'Name each highlighted organ.', diagramId: 'human_organs', regionIds: <String>['brain', 'heart', 'lungs', 'liver', 'stomach', 'kidneys'], skills: <String>['md_anatomy']),
        AnatomyIdStep(id: 'skeleton', title: 'Skeleton', instructions: 'Name each highlighted bone.', diagramId: 'skeleton', regionIds: <String>['skull', 'sternum', 'clavicle', 'humerus', 'pelvis', 'femur', 'tibia'], skills: <String>['md_anatomy']),
        AnatomyIdStep(id: 'airway', title: 'Respiratory system', instructions: 'Name each highlighted structure.', diagramId: 'respiratory', regionIds: <String>['nasal', 'trachea', 'bronchi', 'lungs', 'diaphragm'], skills: <String>['md_anatomy']),
      ],
    ),
    ...mdLabAnatomyExtra,
  ],
);

final LabSpec medicineAssessmentLab = LabSpec(
  id: 'md_lab_assessment',
  deptId: 'medicine',
  majorId: 'medicine',
  number: 2,
  title: 'Patient Assessment',
  environment: LabEnvironment.clinicRoom,
  summary: 'A breathless patient: take the history, review the observations, order investigations, diagnose, manage and document.',
  objectives: const <String>['Take a focused history', 'Choose investigations that change management', 'Commit to a diagnosis and document it'],
  skills: const <String>['md_history', 'md_reason', 'md_manage', 'md_comm'],
  difficulty: LabDifficulty.intermediate,
  minutes: 45,
  patients: const <Patient>[robert],
  scenarios: <LabScenario>[
    LabScenario(
      id: 'robert_pe',
      title: 'Clinic Room 3: Robert Mensah',
      people: const <LabPerson>[
        LabPerson('Robert Mensah', 'Patient', 'It came on suddenly this morning. I can\'t catch my breath.'),
        ..._clinicTeam,
      ],
      briefing: const Briefing(
        what: 'Assess Mr Mensah from history to management plan, then write the clinical note.',
        why: 'Breathlessness with chest pain has several dangerous causes; the history narrows them quickly.',
        information: <String>['Observations are on the monitor and in the record.', 'He walked in with his wife.'],
        tools: <String>['Patient record', 'Bedside monitor', 'Investigations panel', 'Clinical notes'],
        expected: 'Essential history, a focused work-up, the correct working diagnosis and a safe plan.',
        requirements: <String>['Do not discharge a patient with unexplained hypoxia.'],
      ),
      steps: <LabStep>[
        const HistoryStep(
          id: 'history',
          title: 'History',
          instructions: 'Ask up to 6 questions. Then summarise the history in a sentence or two.',
          patientId: 'robert',
          maxQuestions: 6,
          skills: <String>['md_history'],
          questions: <HistoryQuestion>[
            HistoryQuestion('When did it start, and how quickly?', 'This morning, out of nowhere, when I stood up from the sofa.', essential: true),
            HistoryQuestion('Describe the chest pain. Is it worse when you breathe in?', 'Sharp, on the right side, and much worse when I take a deep breath.', essential: true),
            HistoryQuestion('Have you had any recent surgery, travel or immobility?', 'I had my left knee replaced four weeks ago and I\'ve been sitting a lot.', essential: true),
            HistoryQuestion('Any calf pain or swelling?', 'Now you mention it, my left calf has been sore and puffy for a few days.', essential: true),
            HistoryQuestion('Any cough or coughing up blood?', 'A little cough. I saw a streak of blood this morning.'),
            HistoryQuestion('Any heart problems in the family?', 'My father had angina in his seventies.'),
            HistoryQuestion('How is your mood generally?', 'Fine, thanks.', relevant: false),
            HistoryQuestion('Do you have any pets?', 'A dog called Bruno.', relevant: false),
          ],
          noteRubric: <Concept>[
            Concept('onset', 'Sudden onset', <String>['sudden*', 'this morning', 'abrupt*']),
            Concept('pleuritic', 'Pleuritic chest pain', <String>['pleuritic', 'worse on breathing', 'deep breath', 'inspiration']),
            Concept('risk', 'Risk factors: recent surgery and immobility', <String>['knee replacement', 'surgery', 'immobil*', 'four weeks']),
            Concept('dvt', 'Calf symptoms', <String>['calf', 'swelling', 'dvt']),
          ],
        ),
        TaskStep(const WorkupTaskSpec(
          id: 'workup',
          title: 'Investigations, diagnosis and management',
          brief: 'Order up to four investigations, read the results, diagnose and manage.',
          presentation: 'Mr Mensah, 61: sudden pleuritic chest pain and breathlessness four weeks after knee replacement, with a swollen left calf.',
          skills: <String>['md_reason', 'md_manage'],
          facts: <Fact>[Fact('RR', '24 /min'), Fact('SpO₂', '91% on air'), Fact('HR', '112 bpm'), Fact('BP', '128/82 mmHg')],
          maxInvestigations: 4,
          investigations: <Investigation>[
            Investigation('CT pulmonary angiogram', 'Filling defects in the right lower lobe pulmonary arteries.', relevant: true),
            Investigation('12-lead ECG', 'Sinus tachycardia, no ST elevation.', relevant: true),
            Investigation('Chest X-ray', 'No consolidation, no pneumothorax.', relevant: true),
            Investigation('Leg ultrasound (left)', 'Thrombus in the left popliteal vein.', relevant: true),
            Investigation('Thyroid function', 'Normal.', relevant: false),
            Investigation('Abdominal ultrasound', 'Normal.', relevant: false),
          ],
          diagnoses: <String>['Pulmonary embolism', 'Community-acquired pneumonia', 'Acute myocardial infarction', 'Spontaneous pneumothorax'],
          correctDiagnosis: 0,
          management: <DecisionStep>[
            DecisionStep('Management now?', <DecisionOption>[
              DecisionOption('Oxygen to target saturations and start anticoagulation', 2, 'Standard treatment for a haemodynamically stable PE.'),
              DecisionOption('Thrombolysis immediately', 0, 'Reserved for PE with shock or haemodynamic compromise; his blood pressure is normal.'),
              DecisionOption('Analgesia and discharge home', 0, 'Unsafe: hypoxic patient with a confirmed PE.', critical: true),
            ]),
          ],
        )),
        TaskStep(const WrittenTaskSpec(
          id: 'clinic_note',
          title: 'Clinical note',
          brief: 'Write the note: history, examination/observations, results, diagnosis and plan.',
          minWords: 80,
          skills: <String>['md_comm'],
          rubric: <Concept>[
            Concept('hx', 'History', <String>['pleuritic', 'sudden', 'knee', 'calf']),
            Concept('obs', 'Observations', <String>['91', 'hypox*', 'tachycard*', '112']),
            Concept('results', 'Results', <String>['ctpa', 'filling defect*', 'ultrasound', 'thrombus']),
            Concept('dx', 'Diagnosis', <String>['pulmonary embolism', ' pe ', 'pe.', 'embolus']),
            Concept('plan', 'Plan', <String>['anticoagula*', 'oxygen', 'admit', 'review', 'plan']),
          ],
        )),
      ],
    ),
    ...mdLabAssessmentExtra,
  ],
);

final LabSpec medicineEmergencyLab = LabSpec(
  id: 'md_lab_emergency',
  deptId: 'medicine',
  majorId: 'medicine',
  number: 3,
  title: 'Emergency Medicine: Anaphylaxis',
  environment: LabEnvironment.clinicRoom,
  summary: 'A patient collapses minutes after a first dose of antibiotic. Recognise anaphylaxis and follow the protocol.',
  objectives: const <String>['Recognise anaphylaxis', 'Give the first-line treatment correctly', 'Escalate and reassess'],
  skills: const <String>['md_manage'],
  difficulty: LabDifficulty.advanced,
  minutes: 20,
  scenarios: <LabScenario>[
    LabScenario(
      id: 'anaphylaxis',
      title: 'Day unit: Bay 4',
      people: _clinicTeam,
      briefing: const Briefing(
        what: 'Manage the emergency until the resuscitation team arrives.',
        why: 'Intramuscular adrenaline given early is the treatment that saves lives in anaphylaxis.',
        information: <String>['Adult, 70 kg; IV co-amoxiclav started 5 minutes ago.'],
        tools: <String>['Anaphylaxis kit', 'Oxygen', 'Phone to the resuscitation team'],
        expected: 'Protocol-correct decisions in the right order.',
        requirements: <String>['Educational simulation of the Resuscitation Council UK algorithm.'],
      ),
      steps: <LabStep>[
        TaskStep(const DecisionTaskSpec(
          id: 'anaphylaxis_actions',
          title: 'Anaphylaxis',
          brief: 'Decide at each point.',
          setting: 'Widespread hives, swollen lips, wheeze, RR 28, SpO₂ 90%, BP 78/40, HR 128. She says her throat feels tight.',
          skills: <String>['md_manage'],
          facts: <Fact>[Fact('Trigger', 'IV co-amoxiclav'), Fact('Weight', '70 kg')],
          steps: <DecisionStep>[
            DecisionStep('First action?', <DecisionOption>[
              DecisionOption('Stop the infusion, call for help and give IM adrenaline 0.5 mg (0.5 mL of 1 mg/mL) into the anterolateral thigh', 2, 'IM adrenaline is the first-line treatment for anaphylaxis.'),
              DecisionOption('Give an oral antihistamine and observe', 0, 'Antihistamines do not treat airway or circulation problems in anaphylaxis.', critical: true),
              DecisionOption('Give IV adrenaline 1 mg as a bolus', 0, 'A cardiac-arrest dose given IV to a patient with a pulse can cause fatal arrhythmias.', critical: true),
            ]),
            DecisionStep('Positioning and support?', <DecisionOption>[
              DecisionOption('Lie her flat with legs raised (or sitting if breathing is easier), high-flow oxygen, IV fluid bolus', 2, 'Supports circulation and oxygenation.'),
              DecisionOption('Stand her up to walk to the resuscitation room', 0, 'Standing can cause cardiac arrest in anaphylaxis.', critical: true),
            ]),
            DecisionStep('Five minutes later there is no improvement. Next?', <DecisionOption>[
              DecisionOption('Repeat IM adrenaline and escalate to critical care', 2, 'Repeat after 5 minutes if there is no improvement; refractory cases need critical care.'),
              DecisionOption('Wait another 30 minutes for the first dose to work', 0, 'Delay increases the risk of death.'),
            ]),
          ],
        )),
      ],
    ),
    ...mdLabEmergencyExtra,
  ],
);

final List<LabSpec> nursingLabs = <LabSpec>[
  nursingAdmissionLab,
  nursingVitalsLab,
  nursingMedsLab,
  nursingProceduresLab,
  nursingEmergencyLab,
  nursingShiftLab,
];

final List<LabSpec> medicineLabs = <LabSpec>[medicineAnatomyLab, medicineAssessmentLab, medicineEmergencyLab];
