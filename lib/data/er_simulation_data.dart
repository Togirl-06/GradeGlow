import 'package:flutter/material.dart';

import '../models/er_simulation.dart';

class ErSimulationData {
  ErSimulationData._();

  static const Color screenBg = Color(0xFF070D18);
  static const Color panelBg = Color(0xFF121A2B);
  static const Color panelBorder = Color(0xFF243049);

  static const List<ErSimulationAction> actions = <ErSimulationAction>[
    ErSimulationAction(id: 'ask', label: 'Ask Questions', icon: Icons.chat_bubble_outline_rounded, color: Color(0xFF7C3AED)),
    ErSimulationAction(id: 'vitals', label: 'Check Vitals', icon: Icons.monitor_heart_outlined, color: Color(0xFF10B981)),
    ErSimulationAction(id: 'tests', label: 'Order Tests', icon: Icons.science_outlined, color: Color(0xFFF59E0B)),
    ErSimulationAction(id: 'meds', label: 'Administer\nMedication', icon: Icons.medication_outlined, color: Color(0xFFEC4899)),
    ErSimulationAction(id: 'specialist', label: 'Call Specialist', icon: Icons.support_agent_outlined, color: Color(0xFF3B82F6)),
    ErSimulationAction(id: 'chart', label: 'View Patient\nChart', icon: Icons.description_outlined, color: Color(0xFF14B8A6)),
  ];

  static ErSimulationCase caseForLabId(String labId) {
    return switch (labId) {
      'er_stroke' => _strokeCase,
      'er_asthma' => _asthmaCase,
      'er_diabetic' => _diabeticCase,
      'er_trauma' => _traumaCase,
      _ => _chestPainCase,
    };
  }

  static const ErSimulationCase _chestPainCase = ErSimulationCase(
    id: 'chest_pain',
    caseNumber: 3,
    title: 'Chest Pain',
    patientName: 'Sarah Williams',
    patientAge: 54,
    openingLine:
        "I've been having this pressure in my chest for about an hour...",
    vitals: ErVitals(
      heartRate: 120,
      bloodPressure: '170/95',
      respiratoryRate: 24,
      spo2: 88,
      temperature: 37.2,
    ),
    questions: <ErQuestion>[
      ErQuestion(
        prompt: 'Can you describe the pain?',
        response:
            "It's a tight pressure in the center of my chest. It started about an hour ago while I was walking upstairs...",
      ),
      ErQuestion(
        prompt: 'When did the pain start?',
        response: 'About an hour ago. It came on suddenly while I was climbing stairs.',
      ),
      ErQuestion(
        prompt: 'Do you have any medical conditions?',
        response: 'I have high blood pressure and my doctor mentioned cholesterol last year.',
      ),
      ErQuestion(
        prompt: 'Are you taking any medications?',
        response: 'I take lisinopril for blood pressure, but I missed it yesterday.',
      ),
      ErQuestion(
        prompt: 'Do you have any allergies?',
        response: 'No known drug allergies.',
      ),
    ],
    statusLines: <String>[
      'Possible cardiac issues',
      'Low oxygen saturation',
      'Elevated blood pressure',
    ],
    objectives: <ErObjective>[
      ErObjective(label: 'Stabilize the patient', target: 1),
      ErObjective(label: 'Identify possible heart attack', target: 1),
      ErObjective(label: 'Order appropriate tests', target: 1),
    ],
    tip: 'Ask the patient more questions to gather a complete history before ordering tests.',
    starsRequired: 3,
  );

  static const ErSimulationCase _strokeCase = ErSimulationCase(
    id: 'stroke',
    caseNumber: 4,
    title: 'Suspected Stroke',
    patientName: 'James Carter',
    patientAge: 67,
    openingLine: 'My face feels numb and my speech is slurring...',
    vitals: ErVitals(heartRate: 98, bloodPressure: '188/102', respiratoryRate: 18, spo2: 94, temperature: 36.8),
    questions: <ErQuestion>[
      ErQuestion(prompt: 'When did symptoms start?', response: 'About 30 minutes ago, suddenly.'),
      ErQuestion(prompt: 'Can you smile for me?', response: 'The left side of my face feels weak.'),
    ],
    statusLines: <String>['Neurologic deficit suspected', 'Hypertensive urgency'],
    objectives: <ErObjective>[
      ErObjective(label: 'Perform FAST assessment', target: 1),
      ErObjective(label: 'Activate stroke protocol', target: 1),
    ],
    tip: 'Time is brain — confirm last known well time immediately.',
    starsRequired: 3,
  );

  static const ErSimulationCase _asthmaCase = ErSimulationCase(
    id: 'asthma',
    caseNumber: 2,
    title: 'Asthma Attack',
    patientName: 'Emily Chen',
    patientAge: 22,
    openingLine: "I can't catch my breath and my inhaler isn't helping...",
    vitals: ErVitals(heartRate: 112, bloodPressure: '132/84', respiratoryRate: 32, spo2: 89, temperature: 37.0),
    questions: <ErQuestion>[
      ErQuestion(prompt: 'How many puffs did you take?', response: 'Four puffs about ten minutes ago.'),
    ],
    statusLines: <String>['Respiratory distress', 'Wheezing reported'],
    objectives: <ErObjective>[ErObjective(label: 'Improve oxygen saturation', target: 1)],
    tip: 'Assess work of breathing and peak flow if available.',
    starsRequired: 2,
  );

  static const ErSimulationCase _diabeticCase = ErSimulationCase(
    id: 'diabetic',
    caseNumber: 5,
    title: 'Diabetic Emergency',
    patientName: 'Marcus Lee',
    patientAge: 41,
    openingLine: "I'm dizzy and confused. I haven't eaten since morning...",
    vitals: ErVitals(heartRate: 108, bloodPressure: '118/76', respiratoryRate: 20, spo2: 97, temperature: 36.9),
    questions: <ErQuestion>[
      ErQuestion(prompt: 'Do you take insulin?', response: 'Yes, I took my morning dose but skipped lunch.'),
    ],
    statusLines: <String>['Altered mental status', 'Possible hypoglycemia'],
    objectives: <ErObjective>[ErObjective(label: 'Check blood glucose', target: 1)],
    tip: 'Obtain a fingerstick glucose before treating.',
    starsRequired: 2,
  );

  static const ErSimulationCase _traumaCase = ErSimulationCase(
    id: 'trauma',
    caseNumber: 6,
    title: 'Trauma Patient',
    patientName: 'Alex Rivera',
    patientAge: 29,
    openingLine: 'I was in a motorcycle accident. My chest and leg hurt badly...',
    vitals: ErVitals(heartRate: 128, bloodPressure: '92/58', respiratoryRate: 26, spo2: 91, temperature: 36.5),
    questions: <ErQuestion>[
      ErQuestion(prompt: 'Any loss of consciousness?', response: 'I think I blacked out for a few seconds.'),
    ],
    statusLines: <String>['Hypotension', 'Suspected internal bleeding'],
    objectives: <ErObjective>[ErObjective(label: 'Complete primary survey', target: 1)],
    tip: 'Follow ABCDE and prepare for massive transfusion protocol if needed.',
    starsRequired: 3,
  );

  static const List<Map<String, dynamic>> careerMap = <Map<String, dynamic>>[
    <String, dynamic>{'id': 1, 'title': 'Case 1', 'stars': 3, 'unlocked': true},
    <String, dynamic>{'id': 2, 'title': 'Case 2', 'stars': 2, 'unlocked': true},
    <String, dynamic>{'id': 3, 'title': 'Case 3', 'stars': 0, 'unlocked': true, 'current': true},
    <String, dynamic>{'id': 4, 'title': 'Case 4', 'stars': 0, 'unlocked': false},
    <String, dynamic>{'id': 5, 'title': 'Case 5', 'stars': 0, 'unlocked': false},
  ];
}
