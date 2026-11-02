/// XP rewards and streak badge thresholds.
class Gamification {
  static const int xpQuizComplete = 10;
  static const int xpUpload = 50;
  static const int xpFlashcardSession = 8;
  static const int xpTutorMessage = 2;

  /// Uninterrupted focus milestones (minutes without a break).
  static const List<int> focusMilestoneMinutes = <int>[30, 60, 120, 180, 240];

  static int xpForFocusMilestone(int minutes) {
    return switch (minutes) {
      30 => 10,
      60 => 30,
      120 => 45,
      180 => 55,
      240 => 70,
      _ => 10,
    };
  }

  static String focusMilestoneDurationLabel(int minutes) {
    return switch (minutes) {
      30 => '30 min',
      60 => '1 hour',
      120 => '2 hours',
      180 => '3 hours',
      240 => '4 hours',
      _ => '$minutes min',
    };
  }

  /// Uninterrupted focus streak rewards shown on the timer screen.
  static List<MapEntry<int, int>> get focusStreakRewards => focusMilestoneMinutes
      .map((int minutes) => MapEntry<int, int>(minutes, xpForFocusMilestone(minutes)))
      .toList(growable: false);

  static String focusMilestoneLabel(int minutes) {
    if (minutes < 60) return '${minutes}m focus';
    final int hours = minutes ~/ 60;
    final int mins = minutes % 60;
    if (mins == 0) return '${hours}h focus';
    return '${hours}h ${mins}m focus';
  }

  static const int badgeStreak7 = 7;
  static const int badgeStreak30 = 30;
  static const int badgeStreak100 = 100;

  static const String badge7Day = 'streak_7';
  static const String badge30Day = 'streak_30';
  static const String badge100Day = 'streak_100';

  static List<String> badgesForStreak(int streakDays) {
    final List<String> earned = <String>[];
    if (streakDays >= badgeStreak7) earned.add(badge7Day);
    if (streakDays >= badgeStreak30) earned.add(badge30Day);
    if (streakDays >= badgeStreak100) earned.add(badge100Day);
    return earned;
  }

  static String badgeLabel(String id) {
    return switch (id) {
      badge7Day => '7-day streak',
      badge30Day => '30-day streak',
      badge100Day => '100-day streak',
      _ => id,
    };
  }

  /// XP needed to advance each level (must stay above 150).
  static const int xpPerLevel = 200;

  static int levelFromXp(int xp) => (xp ~/ xpPerLevel) + 1;

  static int xpFloorForLevel(int level) => (level - 1) * xpPerLevel;

  static int xpCeilForLevel(int level) => level * xpPerLevel;

  static double levelProgress(int xp) {
    final int level = levelFromXp(xp);
    final int floor = xpFloorForLevel(level);
    final int ceil = xpCeilForLevel(level);
    if (ceil <= floor) return 1;
    return ((xp - floor) / (ceil - floor)).clamp(0.0, 1.0);
  }

  static String levelTitle(int level) {
    if (level >= 10) return 'Scholar';
    if (level >= 7) return 'Expert';
    if (level >= 4) return 'Achiever';
    return 'Learner';
  }

  static String formatCompactCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
