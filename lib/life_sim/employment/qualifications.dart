/// Immutable snapshot of what a player brings to a job application.
library;

import '../education/skills.dart';

class PlayerQualifications {
  PlayerQualifications({
    required this.educationRank,
    required this.skills,
    this.experienceDays = const <String, int>{},
    this.professionalism = 0,
    this.traits = const <String>[],
    this.degreeIds = const <String>[],
    this.name = 'Student',
  });

  final String name;
  final int educationRank;
  final SkillSet skills;

  /// careerId → workdays actually worked.
  final Map<String, int> experienceDays;

  /// 0..10 from owned clothing.
  final double professionalism;
  final List<String> traits;
  final List<String> degreeIds;

  int daysIn(String careerId) => experienceDays[careerId] ?? 0;
  bool hasTrait(String t) => traits.contains(t);
  Set<String> get certifications => skills.certifications;
}
