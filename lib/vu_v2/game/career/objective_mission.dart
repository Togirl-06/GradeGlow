/// Generic objective checklist mission for any career world.
class ObjectiveMission {
  ObjectiveMission({
    required this.missionId,
    required this.title,
    required this.objectives,
    this.xpComplete = 250,
  });

  final String missionId;
  final String title;
  final List<({String id, String label})> objectives;
  final int xpComplete;

  final Set<String> objectivesDone = <String>{};

  void mark(String id) => objectivesDone.add(id);

  bool has(String id) => objectivesDone.contains(id);

  int get progressCount => objectivesDone.length;

  bool get complete =>
      objectives.every((({String id, String label}) o) => has(o.id));

  List<({String id, String label})> get objectiveLabels => objectives;

  Map<String, int> scoreBreakdown({
    required int mistakeCount,
    required List<String> skillCategories,
  }) {
    final int base = complete ? 88 : (40 + progressCount * 8);
    final int penalty = (mistakeCount * 6).clamp(0, 30);
    final int overall = (base - penalty).clamp(0, 100);
    final Map<String, int> out = <String, int>{'overall': overall};
    for (int i = 0; i < skillCategories.length; i++) {
      final String key = skillCategories[i];
      final int wobble = ((i % 3) - 1) * 4;
      out[key] = (overall + wobble).clamp(0, 100);
    }
    return out;
  }

  int xpReward({required int mistakeCount}) {
    if (!complete) return 80 + progressCount * 15;
    return (xpComplete - mistakeCount * 20).clamp(80, xpComplete);
  }

  void reset() => objectivesDone.clear();
}
