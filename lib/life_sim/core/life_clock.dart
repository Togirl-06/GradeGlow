/// In-game clock for the GradeGlow life simulation.
///
/// Pure Dart (no Flutter imports) so every rule can be unit tested.
class LifeClock {
  LifeClock({this.day = 1, int minuteOfDay = 7 * 60})
      : minuteOfDay = minuteOfDay % minutesPerDay;

  static const int minutesPerDay = 1440;
  static const List<String> weekdayNames = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Day 1 is a Monday.
  int day;
  int minuteOfDay;

  int get hour => minuteOfDay ~/ 60;
  int get minute => minuteOfDay % 60;

  /// 0 = Monday … 6 = Sunday.
  int get weekdayIndex => (day - 1) % 7;
  String get weekdayName => weekdayNames[weekdayIndex];
  bool get isWeekend => weekdayIndex >= 5;

  static bool isWeekendDay(int day) => ((day - 1) % 7) >= 5;

  bool get isNight => hour >= 21 || hour < 6;

  /// 0.0 (midnight) … 1.0 (next midnight).
  double get dayFraction => minuteOfDay / minutesPerDay;

  /// 0 = full dark, 1 = full daylight. Smooth between 5-8am and 17-20pm.
  double get daylight {
    final double h = minuteOfDay / 60.0;
    if (h < 5 || h >= 20) return 0;
    if (h < 8) return (h - 5) / 3;
    if (h < 17) return 1;
    return 1 - (h - 17) / 3;
  }

  String get timeLabel {
    final int h12 = hour % 12 == 0 ? 12 : hour % 12;
    final String mm = minute.toString().padLeft(2, '0');
    final String ap = hour < 12 ? 'AM' : 'PM';
    return '$h12:$mm $ap';
  }

  String get label => '$weekdayName · Day $day · $timeLabel';

  /// Advances the clock and returns how many midnights were crossed.
  int advance(int minutes) {
    if (minutes <= 0) return 0;
    final int total = minuteOfDay + minutes;
    final int rolled = total ~/ minutesPerDay;
    minuteOfDay = total % minutesPerDay;
    day += rolled;
    return rolled;
  }

  /// Minutes from now until the next occurrence of [targetMinuteOfDay].
  int minutesUntil(int targetMinuteOfDay) {
    final int diff = (targetMinuteOfDay - minuteOfDay) % minutesPerDay;
    return diff == 0 ? minutesPerDay : diff;
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'day': day,
        'minuteOfDay': minuteOfDay,
      };

  factory LifeClock.fromJson(Map<String, Object?> json) {
    return LifeClock(
      day: (json['day'] as num?)?.toInt() ?? 1,
      minuteOfDay: (json['minuteOfDay'] as num?)?.toInt() ?? 7 * 60,
    );
  }
}

/// Stable, platform-independent hash used for deterministic "random" outcomes
/// (hiring waitlists, events). Same inputs always give the same result.
int stableHash(String input) {
  int h = 0x811C9DC5;
  for (final int unit in input.codeUnits) {
    h ^= unit;
    h = (h * 0x01000193) & 0x7FFFFFFF;
  }
  return h;
}

/// Deterministic value in [0, 1) for a string seed.
double stableUnit(String seed) => (stableHash(seed) % 10000) / 10000.0;
