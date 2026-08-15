import '../../models/practice_lab.dart';
import '../../models/practice_lab_topic.dart';
import 'topic_area_helpers.dart';

final List<PracticeLabTopicArea> preMedMajorTopics = majorTopicAreas(
  majorId: 'pre_med',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'premed_foundations',
      name: 'Pre-Med Foundations',
      emoji: '🩺',
      topics: <PracticeLabTopic>[
        labTopic(id: 'patient_comm', name: 'Patient Communication', description: 'Take a focused history from a patient with vague symptoms.', style: SimulationStyle.diagnosis, aiRole: 'Patient'),
        labTopic(id: 'ethics', name: 'Medical Ethics', description: 'Navigate informed consent and autonomy in a difficult case.', style: SimulationStyle.classroom, aiRole: 'Ethics Committee'),
        labTopic(id: 'mcat_reasoning', name: 'Clinical Reasoning', description: 'Formulate differential diagnosis from lab and history data.', style: SimulationStyle.diagnosis, aiRole: 'Physician Mentor', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> medicalSchoolMajorTopics = majorTopicAreas(
  majorId: 'medical_school',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'clinical_rotations',
      name: 'Clinical Rotations',
      emoji: '🏥',
      topics: <PracticeLabTopic>[
        labTopic(id: 'osce', name: 'OSCE Stations', description: 'Complete a timed OSCE with history, exam, and plan.', style: SimulationStyle.diagnosis, aiRole: 'Standardized Patient'),
        labTopic(id: 'differential', name: 'Differential Diagnosis', description: 'Narrow differential for chest pain with competing diagnoses.', style: SimulationStyle.diagnosis, aiRole: 'Attending Physician', advanced: true),
        labTopic(id: 'handoff', name: 'Clinical Handoffs', description: 'Give SBAR handoff for a deteriorating inpatient.', style: SimulationStyle.erEmergency, aiRole: 'Night Float Resident', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> pharmacyMajorTopics = majorTopicAreas(
  majorId: 'pharmacy',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'pharmacy_practice',
      name: 'Pharmacy Practice',
      emoji: '💊',
      topics: <PracticeLabTopic>[
        labTopic(id: 'med_review', name: 'Medication Review', description: 'Identify drug interactions in a polypharmacy patient.', style: SimulationStyle.diagnosis, aiRole: 'Patient'),
        labTopic(id: 'counseling', name: 'Patient Counseling', description: 'Counsel a patient starting a complex medication regimen.', style: SimulationStyle.counseling, aiRole: 'Anxious Patient'),
        labTopic(id: 'clinical_pharm', name: 'Clinical Pharmacy', description: 'Recommend antibiotic stewardship for resistant infection.', style: SimulationStyle.diagnosis, aiRole: 'Infectious Disease MD', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> physicalTherapyMajorTopics = majorTopicAreas(
  majorId: 'physical_therapy',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'pt_practice',
      name: 'Physical Therapy',
      emoji: '🦵',
      topics: <PracticeLabTopic>[
        labTopic(id: 'eval', name: 'PT Evaluation', description: 'Perform musculoskeletal eval and establish functional goals.', style: SimulationStyle.aiPatient, aiRole: 'Post-Surgical Patient'),
        labTopic(id: 'gait', name: 'Gait Training', description: 'Progress ambulation safely after hip replacement.', style: SimulationStyle.aiPatient, aiRole: 'Elderly Patient', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> publicHealthMajorTopics = majorTopicAreas(
  majorId: 'public_health',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'population_health',
      name: 'Population Health',
      emoji: '🌍',
      topics: <PracticeLabTopic>[
        labTopic(id: 'outbreak', name: 'Outbreak Investigation', description: 'Lead field investigation of a foodborne illness cluster.', style: SimulationStyle.erEmergency, aiRole: 'Epidemiologist'),
        labTopic(id: 'health_policy', name: 'Health Policy', description: 'Advocate for vaccination policy amid community resistance.', style: SimulationStyle.customerScenario, aiRole: 'County Health Director', advanced: true),
      ],
    ),
  ],
);

final List<PracticeLabTopicArea> veterinaryMajorTopics = majorTopicAreas(
  majorId: 'veterinary_medicine',
  areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
    (
      id: 'vet_clinical',
      name: 'Veterinary Clinical',
      emoji: '🐾',
      topics: <PracticeLabTopic>[
        labTopic(id: 'small_animal', name: 'Small Animal Exam', description: 'Diagnose acute illness in a dog with owner communication.', style: SimulationStyle.diagnosis, aiRole: 'Pet Owner'),
        labTopic(id: 'zoonotic', name: 'Zoonotic Disease', description: 'Identify zoonotic risk and counsel a farm client.', style: SimulationStyle.diagnosis, aiRole: 'Livestock Farmer', advanced: true),
      ],
    ),
  ],
);

// Additional health majors with focused topic sets
List<PracticeLabTopicArea> _simpleHealthMajor(String majorId, String fieldLabel, String emoji, List<({String id, String name, String desc})> topics) {
  return majorTopicAreas(
    majorId: majorId,
    areas: <({String id, String name, String emoji, List<PracticeLabTopic> topics})>[
      (
        id: 'clinical_practice',
        name: fieldLabel,
        emoji: emoji,
        topics: topics
            .map(
              (({String id, String name, String desc}) t) => labTopic(
                    id: t.id,
                    name: t.name,
                    description: t.desc,
                    style: SimulationStyle.aiPatient,
                    aiRole: 'Patient',
                  ),
            )
            .toList(),
      ),
    ],
  );
}

final List<PracticeLabTopicArea> physicianAssistantTopics = _simpleHealthMajor('physician_assistant', 'Physician Assistant Practice', '🩹', <({String id, String name, String desc})>[
  (id: 'hpi', name: 'History & Physical', desc: 'Complete H&P for undifferentiated abdominal pain in urgent care.'),
  (id: 'procedures', name: 'Procedures', desc: 'Consent and perform minor procedure with complication management.'),
]);

final List<PracticeLabTopicArea> occupationalTherapyTopics = _simpleHealthMajor('occupational_therapy', 'Occupational Therapy', '🖐️', <({String id, String name, String desc})>[
  (id: 'adl', name: 'ADL Retraining', desc: 'Design ADL interventions after stroke with cognitive deficits.'),
  (id: 'adaptive', name: 'Adaptive Equipment', desc: 'Recommend home modifications for spinal cord injury patient.'),
]);

final List<PracticeLabTopicArea> radiologyTopics = _simpleHealthMajor('radiology', 'Radiology', '📷', <({String id, String name, String desc})>[
  (id: 'image_interp', name: 'Image Interpretation', desc: 'Identify critical findings on CT and communicate urgently.'),
  (id: 'contrast', name: 'Contrast Safety', desc: 'Manage contrast reaction and pre-scan screening.'),
]);

final List<PracticeLabTopicArea> respiratoryTherapyTopics = _simpleHealthMajor('respiratory_therapy', 'Respiratory Therapy', '🫁', <({String id, String name, String desc})>[
  (id: 'ventilator', name: 'Ventilator Management', desc: 'Adjust vent settings for ARDS patient per protocol.'),
  (id: 'airway', name: 'Airway Management', desc: 'Respond to difficult airway in emergency intubation.'),
]);

final List<PracticeLabTopicArea> dentalHygieneTopics = _simpleHealthMajor('dental_hygiene', 'Dental Hygiene', '🦷', <({String id, String name, String desc})>[
  (id: 'periodontal', name: 'Periodontal Assessment', desc: 'Document periodontal charting and patient education plan.'),
  (id: 'prevention', name: 'Preventive Care', desc: 'Counsel patient on oral hygiene for high caries risk.'),
]);

final List<PracticeLabTopicArea> dentistryTopics = _simpleHealthMajor('dentistry', 'Dentistry', '😁', <({String id, String name, String desc})>[
  (id: 'treatment_plan', name: 'Treatment Planning', desc: 'Present comprehensive treatment plan to cost-conscious patient.'),
  (id: 'emergency_dental', name: 'Dental Emergencies', desc: 'Manage avulsed tooth and pain control in ER setting.'),
]);

final List<PracticeLabTopicArea> healthSciencesTopics = _simpleHealthMajor('health_sciences', 'Health Sciences', '🔬', <({String id, String name, String desc})>[
  (id: 'interprofessional', name: 'Interprofessional Teams', desc: 'Coordinate care plan across disciplines in team meeting.'),
  (id: 'health_literacy', name: 'Health Literacy', desc: 'Explain complex diagnosis in plain language to family.'),
]);

final List<PracticeLabTopicArea> kinesiologyTopics = _simpleHealthMajor('kinesiology', 'Kinesiology', '🏃', <({String id, String name, String desc})>[
  (id: 'biomechanics', name: 'Biomechanics Analysis', desc: 'Analyze movement patterns to prevent sports injury.'),
  (id: 'conditioning', name: 'Exercise Prescription', desc: 'Design periodized program for returning athlete.'),
]);

final List<PracticeLabTopicArea> exerciseScienceTopics = _simpleHealthMajor('exercise_science', 'Exercise Science', '💪', <({String id, String name, String desc})>[
  (id: 'fitness_assess', name: 'Fitness Assessment', desc: 'Conduct VO2 max testing and interpret results.'),
  (id: 'special pops', name: 'Special Populations', desc: 'Modify exercise for client with cardiac history.'),
]);

final List<PracticeLabTopicArea> medLabScienceTopics = _simpleHealthMajor('medical_laboratory_science', 'Medical Laboratory Science', '🧫', <({String id, String name, String desc})>[
  (id: 'specimen', name: 'Specimen Processing', desc: 'Troubleshoot hemolyzed sample and recollection protocol.'),
  (id: 'qc', name: 'Quality Control', desc: 'Investigate QC failure on critical chemistry analyzer.'),
]);

final Map<String, List<PracticeLabTopicArea>> healthMedicalTopicsByMajor = <String, List<PracticeLabTopicArea>>{
  'pre_med': preMedMajorTopics,
  'medical_school': medicalSchoolMajorTopics,
  'physician_assistant': physicianAssistantTopics,
  'pharmacy': pharmacyMajorTopics,
  'physical_therapy': physicalTherapyMajorTopics,
  'occupational_therapy': occupationalTherapyTopics,
  'radiology': radiologyTopics,
  'respiratory_therapy': respiratoryTherapyTopics,
  'dental_hygiene': dentalHygieneTopics,
  'dentistry': dentistryTopics,
  'veterinary_medicine': veterinaryMajorTopics,
  'public_health': publicHealthMajorTopics,
  'health_sciences': healthSciencesTopics,
  'kinesiology': kinesiologyTopics,
  'exercise_science': exerciseScienceTopics,
  'medical_laboratory_science': medLabScienceTopics,
};
