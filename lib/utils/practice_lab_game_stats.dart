import '../models/practice_lab.dart';

/// Player progression derived from completed practice-lab sessions.
class PracticeLabGameStats {
  const PracticeLabGameStats({
    required this.level,
    required this.xp,
    required this.xpForNextLevel,
    required this.labsCompleted,
    required this.averageScore,
    required this.streakDays,
    required this.weeklyLabs,
    required this.weeklyGoal,
    required this.rankLabel,
  });

  factory PracticeLabGameStats.fromRecords(List<PracticeLabRecord> records) {
    final int labs = records.length;
    final int totalXp = records.fold<int>(0, (int sum, PracticeLabRecord r) => sum + _xpForScore(r.score));
    final int level = _levelFromXp(totalXp);
    final int xpFloor = _xpFloorForLevel(level);
    final int xpCeil = _xpFloorForLevel(level + 1);
    final int avg = labs == 0 ? 0 : (records.fold<int>(0, (int s, PracticeLabRecord r) => s + r.score) / labs).round();

    final DateTime now = DateTime.now();
    final int weekly = records.where((PracticeLabRecord r) {
      final Duration diff = now.difference(r.completedAt);
      return diff.inDays < 7;
    }).length;

    return PracticeLabGameStats(
      level: level,
      xp: totalXp - xpFloor,
      xpForNextLevel: xpCeil - xpFloor,
      labsCompleted: labs,
      averageScore: avg,
      streakDays: _estimateStreak(records),
      weeklyLabs: weekly,
      weeklyGoal: 20,
      rankLabel: labs >= 100 ? 'Top 3%' : labs >= 50 ? 'Top 10%' : labs >= 20 ? 'Rising' : 'Rookie',
    );
  }

  final int level;
  final int xp;
  final int xpForNextLevel;
  final int labsCompleted;
  final int averageScore;
  final int streakDays;
  final int weeklyLabs;
  final int weeklyGoal;
  final String rankLabel;

  double get levelProgress => xpForNextLevel <= 0 ? 0 : (xp / xpForNextLevel).clamp(0.0, 1.0);
  double get weeklyProgress => (weeklyLabs / weeklyGoal).clamp(0.0, 1.0);
  int get totalXp => _xpFloorForLevel(level) + xp;

  static int _xpForScore(int score) => 40 + (score * 1.6).round();

  static int _levelFromXp(int xp) {
    int level = 1;
    while (_xpFloorForLevel(level + 1) <= xp) {
      level++;
    }
    return level;
  }

  static int _xpFloorForLevel(int level) => (level - 1) * (level - 1) * 120 + (level - 1) * 80;

  static int _estimateStreak(List<PracticeLabRecord> records) {
    if (records.isEmpty) return 0;
    final List<DateTime> days = records
        .map((PracticeLabRecord r) => DateTime(r.completedAt.year, r.completedAt.month, r.completedAt.day))
        .toSet()
        .toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));
    int streak = 1;
    for (int i = 1; i < days.length; i++) {
      if (days[i - 1].difference(days[i]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
