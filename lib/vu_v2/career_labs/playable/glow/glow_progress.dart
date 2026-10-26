import 'package:shared_preferences/shared_preferences.dart';

/// Stars, XP and daily streak for one [GlowLab], kept in SharedPreferences.
class GlowProgress {
  GlowProgress(this.labId);

  final String labId;

  String get _p => 'glow_${labId}_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Map<String, int>> loadStars(Iterable<String> levelIds) async {
    final SharedPreferences p = await _prefs;
    final Map<String, int> out = <String, int>{};
    for (final String id in levelIds) {
      out[id] = p.getInt('${_p}stars_$id') ?? 0;
    }
    return out;
  }

  /// Keeps the best result only.
  Future<void> saveStars(String levelId, int stars) async {
    final SharedPreferences p = await _prefs;
    final int old = p.getInt('${_p}stars_$levelId') ?? 0;
    if (stars > old) {
      await p.setInt('${_p}stars_$levelId', stars);
    }
  }

  Future<int> getXp() async {
    final SharedPreferences p = await _prefs;
    return p.getInt('${_p}xp') ?? 0;
  }

  Future<void> addXp(int amount) async {
    if (amount <= 0) return;
    final SharedPreferences p = await _prefs;
    final int xp = p.getInt('${_p}xp') ?? 0;
    await p.setInt('${_p}xp', xp + amount);
  }

  Future<int> getStreak() async {
    final SharedPreferences p = await _prefs;
    final String? last = p.getString('${_p}streak_day');
    final int streak = p.getInt('${_p}streak') ?? 0;
    if (last == null) return 0;
    final DateTime? lastDay = DateTime.tryParse(last);
    if (lastDay == null) return 0;
    final int gap = _dayOnly(DateTime.now()).difference(lastDay).inDays;
    // A streak survives today and yesterday; older than that it has lapsed.
    return gap <= 1 ? streak : 0;
  }

  /// Call after the player finishes any level. Returns the new streak.
  Future<int> touchStreak() async {
    final SharedPreferences p = await _prefs;
    final DateTime today = _dayOnly(DateTime.now());
    final String? last = p.getString('${_p}streak_day');
    int streak = p.getInt('${_p}streak') ?? 0;
    final DateTime? lastDay = last == null ? null : DateTime.tryParse(last);
    if (lastDay == null) {
      streak = 1;
    } else {
      final int gap = today.difference(lastDay).inDays;
      if (gap == 1) {
        streak += 1;
      } else if (gap > 1) {
        streak = 1;
      } else if (streak == 0) {
        streak = 1;
      }
    }
    await p.setString('${_p}streak_day', today.toIso8601String());
    await p.setInt('${_p}streak', streak);
    return streak;
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
