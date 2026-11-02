import 'package:flutter/material.dart';

/// Fictional patient used across clinical scenarios (no real PHI).
class PatientProfile {
  const PatientProfile({
    required this.id,
    required this.displayName,
    required this.ageYears,
    required this.sexLabel,
    required this.skinTone,
    required this.chiefComplaint,
    required this.historySummary,
    required this.allergies,
    required this.medications,
    required this.vitals,
    required this.appearanceNotes,
    this.dialogueHooks = const <String, String>{},
  });

  final String id;
  final String displayName;
  final int ageYears;
  final String sexLabel;
  final Color skinTone;
  final String chiefComplaint;
  final String historySummary;
  final List<String> allergies;
  final List<String> medications;
  final PatientVitals vitals;
  final String appearanceNotes;
  /// Prompt key → patient reply (scenario-bound; not free AI invention).
  final Map<String, String> dialogueHooks;
}

class PatientVitals {
  const PatientVitals({
    required this.hr,
    required this.rr,
    required this.systolic,
    required this.diastolic,
    required this.tempC,
    required this.spo2,
    required this.painScore,
  });

  final int hr;
  final int rr;
  final int systolic;
  final int diastolic;
  final double tempC;
  final int spo2;
  final int painScore;

  String get bpLabel => '$systolic/$diastolic mmHg';
  String get tempLabel => '${tempC.toStringAsFixed(1)} °C';
}

/// Reusable educational patients (fictional).
abstract final class PatientCatalog {
  static const PatientProfile mariaLopez = PatientProfile(
    id: 'pt_maria_lopez',
    displayName: 'Maria Lopez',
    ageYears: 58,
    sexLabel: 'Female',
    skinTone: Color(0xFFC68642),
    chiefComplaint: 'Shortness of breath and productive cough for 3 days',
    historySummary:
        'Hypertension, type 2 diabetes. Former smoker (quit 8 years ago). '
        'Lives with spouse. Vaccinations up to date except current flu season.',
    allergies: <String>['Penicillin (rash)'],
    medications: <String>['Lisinopril 10 mg daily', 'Metformin 500 mg BID'],
    vitals: PatientVitals(
      hr: 104,
      rr: 24,
      systolic: 148,
      diastolic: 92,
      tempC: 38.4,
      spo2: 91,
      painScore: 3,
    ),
    appearanceNotes:
        'Sitting upright, mild accessory muscle use, speaking in short sentences.',
    dialogueHooks: <String, String>{
      'onset':
          'It started three nights ago after I felt chilled. The cough got worse yesterday.',
      'severity':
          'Walking to the bathroom makes me winded. Resting helps a little.',
      'sputum': 'Yellowish, not bloody.',
      'chest_pain': 'No sharp chest pain — just tightness when I cough.',
      'fever': 'I felt hot last night and this morning.',
    },
  );

  static const PatientProfile jamalReed = PatientProfile(
    id: 'pt_jamal_reed',
    displayName: 'Jamal Reed',
    ageYears: 34,
    sexLabel: 'Male',
    skinTone: Color(0xFF8D5524),
    chiefComplaint: 'Crushing epigastric pain after large meal',
    historySummary:
        'GERD. No cardiac history. Works night shifts. Occasional NSAID use.',
    allergies: <String>['NKDA'],
    medications: <String>['Omeprazole 20 mg PRN'],
    vitals: PatientVitals(
      hr: 88,
      rr: 16,
      systolic: 128,
      diastolic: 78,
      tempC: 36.8,
      spo2: 98,
      painScore: 6,
    ),
    appearanceNotes: 'Holding upper abdomen, alert, no distress at rest.',
    dialogueHooks: <String, String>{
      'onset': 'Started an hour after dinner — spicy food.',
      'radiation': 'Mostly upper belly, not into my arm or jaw.',
      'relieving': 'Sitting forward helps a bit. Antacid barely touched it.',
    },
  );

  static const PatientProfile elenaPark = PatientProfile(
    id: 'pt_elena_park',
    displayName: 'Elena Park',
    ageYears: 62,
    sexLabel: 'Female',
    skinTone: Color(0xFFE0AC69),
    chiefComplaint: 'Lightheaded and weak after abdominal surgery yesterday',
    historySummary:
        'POD#1 laparoscopic colectomy. Hypertension. On prophylactic heparin. '
        'Dressing dry at shift start; now pale and diaphoretic.',
    allergies: <String>['Sulfa (rash)'],
    medications: <String>[
      'Metoprolol 25 mg BID',
      'Heparin SQ prophylaxis',
      'PRN ondansetron',
    ],
    vitals: PatientVitals(
      hr: 118,
      rr: 22,
      systolic: 92,
      diastolic: 58,
      tempC: 36.6,
      spo2: 95,
      painScore: 5,
    ),
    appearanceNotes:
        'Pale, clammy, lying flat. Abdominal dressing with new serosanguinous soak.',
    dialogueHooks: <String, String>{
      'onset':
          'I felt fine this morning, then got dizzy when I sat up. Now I feel faint.',
      'pain': 'Incision hurts maybe a 5. Worse when I move.',
      'dizziness':
          'Room spun when I stood. My nurse said my blood pressure was soft.',
      'bleeding': 'I noticed the bandage looking darker a little while ago.',
    },
  );

  static const PatientProfile devonBlake = PatientProfile(
    id: 'pt_devon_blake',
    displayName: 'Devon Blake',
    ageYears: 41,
    sexLabel: 'Male',
    skinTone: Color(0xFF5C3317),
    chiefComplaint: 'New diabetes diagnosis — thirsty, frequent urination',
    historySummary:
        'Newly diagnosed type 2 diabetes. BMI 34. No prior hospitalizations. '
        'Admitted for hyperglycemia education and med titration.',
    allergies: <String>['NKDA'],
    medications: <String>['Metformin 500 mg daily (started yesterday)'],
    vitals: PatientVitals(
      hr: 82,
      rr: 16,
      systolic: 134,
      diastolic: 84,
      tempC: 36.9,
      spo2: 98,
      painScore: 0,
    ),
    appearanceNotes: 'Alert, ambulatory, mild fatigue. No respiratory distress.',
    dialogueHooks: <String, String>{
      'onset': 'Thirst and peeing a lot for about two weeks. Got worse last few days.',
      'thirst': 'I finish water bottles constantly. Still feel dry.',
      'meds': 'Just started metformin yesterday. Still figuring out the schedule.',
      'diet': 'I eat a lot of takeout — rice, fried food. Ready to change though.',
    },
  );

  static const List<PatientProfile> all = <PatientProfile>[
    mariaLopez,
    jamalReed,
    elenaPark,
    devonBlake,
  ];

  static PatientProfile byId(String id) => all.firstWhere(
        (PatientProfile p) => p.id == id,
        orElse: () => mariaLopez,
      );
}
