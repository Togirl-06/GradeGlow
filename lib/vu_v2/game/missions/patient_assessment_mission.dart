/// Structured mission state for Nursing: Patient Assessment.
class PatientAssessmentMission {
  PatientAssessmentMission();

  static const String missionId = 'nursing_game_patient_assessment';
  static const String title = 'Patient Assessment';

  final Set<String> objectivesDone = <String>{};

  bool get enteredRoom => objectivesDone.contains('enter_room');
  bool get talkedPatient => objectivesDone.contains('talk_patient');
  bool get checkedVitals => objectivesDone.contains('vitals');
  bool get reviewedChart => objectivesDone.contains('chart');
  bool get identifiedConcern => objectivesDone.contains('concern');
  bool get notifiedStaff => objectivesDone.contains('notify');
  bool get documented => objectivesDone.contains('document');

  bool get complete =>
      enteredRoom &&
      talkedPatient &&
      checkedVitals &&
      reviewedChart &&
      identifiedConcern &&
      notifiedStaff &&
      documented;

  void mark(String id) => objectivesDone.add(id);

  int get progressCount => objectivesDone.length;

  static const List<({String id, String label})> objectiveLabels =
      <({String id, String label})>[
    (id: 'enter_room', label: 'Enter patient room'),
    (id: 'talk_patient', label: 'Talk to patient'),
    (id: 'vitals', label: 'Check vital signs'),
    (id: 'chart', label: 'Review medical history'),
    (id: 'concern', label: 'Identify concerning symptoms'),
    (id: 'notify', label: 'Notify appropriate staff'),
    (id: 'document', label: 'Complete assessment documentation'),
  ];

  /// Skill scores 0–100 for results screen.
  Map<String, int> scoreBreakdown({required int mistakeCount}) {
    final int base = complete ? 88 : (40 + progressCount * 8);
    final int penalty = (mistakeCount * 6).clamp(0, 30);
    final int overall = (base - penalty).clamp(0, 100);
    return <String, int>{
      'Patient Assessment': overall,
      'Decision Making': (overall - 4 + (notifiedStaff ? 8 : -10)).clamp(0, 100),
      'Communication': (talkedPatient ? 92 : 55),
      'Safety': (checkedVitals && notifiedStaff ? 90 : 62),
      'Critical Thinking': (identifiedConcern ? 88 : 58),
      'overall': overall,
    };
  }

  int xpReward({required int mistakeCount}) {
    if (!complete) return 80 + progressCount * 15;
    return 250 - mistakeCount * 20;
  }
}
