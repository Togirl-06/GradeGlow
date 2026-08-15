import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../vu_v2_lab_models.dart';
import 'vu_v2_lab_game.dart';

/// Persistent progress + game stats across all school lab stations.
class VuV2LabProgressStore extends ChangeNotifier {
  VuV2LabProgressStore();

  static const String _key = 'vu_v2_lab_progress_v2';
  final Set<String> completedStationIds = <String>{};
  final Map<String, String> lastNotesByStation = <String, String>{};
  final Map<String, int> starsByStation = <String, int>{};
  final Map<String, int> highScoreByStation = <String, int>{};
  final Set<String> dayOneSeenSchools = <String>{};
  final Set<String> badges = <String>{};
  /// Highest cleared level number per career school name.
  final Map<String, int> jobLevelCleared = <String, int>{};
  /// Career sim: cleared mission ids per world.
  final Map<String, Set<String>> careerMissionsCleared = <String, Set<String>>{};
  /// Career sim: skill scores 0–100 per world.
  final Map<String, Map<String, int>> careerSkills = <String, Map<String, int>>{};
  /// Career sim: unlocked location ids per world.
  final Map<String, Set<String>> careerLocationsUnlocked = <String, Set<String>>{};
  int xp = 0;
  int streak = 0;
  int bestStreak = 0;
  bool loaded = false;

  Future<void> ensureLoaded() async {
    if (loaded) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_key);
    raw ??= prefs.getString('vu_v2_lab_progress_v1');
    if (raw != null && raw.isNotEmpty) {
      try {
        final Object? decoded = jsonDecode(raw);
        if (decoded is Map) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
          xp = data['xp'] as int? ?? 0;
          streak = data['streak'] as int? ?? 0;
          bestStreak = data['bestStreak'] as int? ?? 0;
          final Object? done = data['completed'];
          if (done is List) {
            completedStationIds
              ..clear()
              ..addAll(done.map((Object? e) => '$e'));
          }
          final Object? notes = data['notes'];
          if (notes is Map) {
            lastNotesByStation
              ..clear()
              ..addAll(
                notes.map(
                  (Object? k, Object? v) => MapEntry<String, String>('$k', '$v'),
                ),
              );
          }
          final Object? stars = data['stars'];
          if (stars is Map) {
            starsByStation
              ..clear()
              ..addAll(
                stars.map(
                  (Object? k, Object? v) => MapEntry<String, int>(
                    '$k',
                    int.tryParse('$v') ?? 0,
                  ),
                ),
              );
          }
          final Object? highs = data['highScores'];
          if (highs is Map) {
            highScoreByStation
              ..clear()
              ..addAll(
                highs.map(
                  (Object? k, Object? v) => MapEntry<String, int>(
                    '$k',
                    int.tryParse('$v') ?? 0,
                  ),
                ),
              );
          }
          final Object? dayOne = data['dayOne'];
          if (dayOne is List) {
            dayOneSeenSchools
              ..clear()
              ..addAll(dayOne.map((Object? e) => '$e'));
          }
          final Object? badgeList = data['badges'];
          if (badgeList is List) {
            badges
              ..clear()
              ..addAll(badgeList.map((Object? e) => '$e'));
          }
          final Object? jobs = data['jobLevels'];
          if (jobs is Map) {
            jobLevelCleared
              ..clear()
              ..addAll(
                jobs.map(
                  (Object? k, Object? v) => MapEntry<String, int>(
                    '$k',
                    int.tryParse('$v') ?? 0,
                  ),
                ),
              );
          }
          final Object? cm = data['careerMissions'];
          if (cm is Map) {
            careerMissionsCleared
              ..clear()
              ..addAll(
                cm.map(
                  (Object? k, Object? v) => MapEntry<String, Set<String>>(
                    '$k',
                    v is List
                        ? v.map((Object? e) => '$e').toSet()
                        : <String>{},
                  ),
                ),
              );
          }
          final Object? cs = data['careerSkills'];
          if (cs is Map) {
            careerSkills
              ..clear()
              ..addAll(
                cs.map(
                  (Object? k, Object? v) => MapEntry<String, Map<String, int>>(
                    '$k',
                    v is Map
                        ? v.map(
                            (Object? sk, Object? sv) => MapEntry<String, int>(
                              '$sk',
                              int.tryParse('$sv') ?? 50,
                            ),
                          )
                        : <String, int>{},
                  ),
                ),
              );
          }
          final Object? cl = data['careerLocations'];
          if (cl is Map) {
            careerLocationsUnlocked
              ..clear()
              ..addAll(
                cl.map(
                  (Object? k, Object? v) => MapEntry<String, Set<String>>(
                    '$k',
                    v is List
                        ? v.map((Object? e) => '$e').toSet()
                        : <String>{},
                  ),
                ),
              );
          }
        }
      } catch (_) {}
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(<String, dynamic>{
        'xp': xp,
        'streak': streak,
        'bestStreak': bestStreak,
        'completed': completedStationIds.toList(),
        'notes': lastNotesByStation,
        'stars': starsByStation,
        'highScores': highScoreByStation,
        'dayOne': dayOneSeenSchools.toList(),
        'badges': badges.toList(),
        'jobLevels': jobLevelCleared,
        'careerMissions': careerMissionsCleared.map(
          (String k, Set<String> v) => MapEntry<String, List<String>>(k, v.toList()),
        ),
        'careerSkills': careerSkills,
        'careerLocations': careerLocationsUnlocked.map(
          (String k, Set<String> v) => MapEntry<String, List<String>>(k, v.toList()),
        ),
      }),
    );
    notifyListeners();
  }

  int unlockedJobLevel(String careerId) {
    final int cleared = jobLevelCleared[careerId] ?? 0;
    return cleared + 1;
  }

  Future<List<String>> completeJobLevel({
    required String careerId,
    required String levelId,
    required int levelNumber,
    required bool won,
    required int xpGain,
    required int maxLevel,
  }) async {
    final List<String> unlocked = <String>[];
    xp += xpGain;
    if (!won) {
      streak = 0;
      await _save();
      return unlocked;
    }
    streak += 1;
    bestStreak = bestStreak < streak ? streak : bestStreak;
    final int prev = jobLevelCleared[careerId] ?? 0;
    if (levelNumber > prev) {
      jobLevelCleared[careerId] = levelNumber;
    }
    completedStationIds.add(levelId);
    void unlock(String badge) {
      if (badges.add(badge)) unlocked.add(badge);
    }
    if (badges.isEmpty) unlock('first_clear');
    if (streak >= 3) unlock('streak_3');
    if (levelNumber >= maxLevel) unlock('facility_sweep');
    if (xp >= 500) unlock('high_roller');
    await _save();
    return unlocked;
  }

  int careerLevelFor(String worldId) {
    final int cleared = careerMissionsCleared[worldId]?.length ?? 0;
    return 1 + cleared;
  }

  int skillAvgFor(String worldId) {
    final Map<String, int>? m = careerSkills[worldId];
    if (m == null || m.isEmpty) return 50;
    return (m.values.reduce((int a, int b) => a + b) / m.length).round();
  }

  bool isMissionCleared(String worldId, String missionId) =>
      careerMissionsCleared[worldId]?.contains(missionId) ?? false;

  bool isLocationUnlocked({
    required String worldId,
    required int unlockCareerLevel,
    required String locationId,
  }) {
    if (unlockCareerLevel <= careerLevelFor(worldId)) return true;
    return careerLocationsUnlocked[worldId]?.contains(locationId) ?? false;
  }

  /// Persist a career-sim mission result. Returns newly unlocked badge ids.
  Future<List<String>> completeCareerMission({
    required String worldId,
    required String missionId,
    required int missionIndex,
    required bool won,
    required int xpGain,
    required Map<String, int> skillScores,
    String? badgeId,
    List<String> locationsToUnlock = const <String>[],
  }) async {
    final List<String> unlocked = <String>[];
    xp += xpGain;
    careerSkills[worldId] = <String, int>{
      ...?careerSkills[worldId],
      ...skillScores,
    };
    for (final String loc in locationsToUnlock) {
      careerLocationsUnlocked
          .putIfAbsent(worldId, () => <String>{})
          .add(loc);
    }
    if (!won) {
      streak = 0;
      await _save();
      return unlocked;
    }
    streak += 1;
    bestStreak = math.max(bestStreak, streak);
    careerMissionsCleared.putIfAbsent(worldId, () => <String>{}).add(missionId);
    final int prev = jobLevelCleared[worldId] ?? 0;
    if (missionIndex > prev) {
      jobLevelCleared[worldId] = missionIndex;
    }
    completedStationIds.add('${worldId}_$missionId');
    void unlock(String badge) {
      if (badges.add(badge)) unlocked.add(badge);
    }
    if (badges.isEmpty) unlock('first_clear');
    if (badgeId != null) unlock(badgeId);
    if (streak >= 3) unlock('streak_3');
    if (streak >= 5) unlock('streak_5');
    if (missionIndex >= 6) unlock('under_pressure');
    if (xp >= 500) unlock('high_roller');
    await _save();
    return unlocked;
  }

  bool sawDayOne(VuV2LabSchool school) =>
      dayOneSeenSchools.contains(school.name);

  bool sawDayOneLabel(String id) => dayOneSeenSchools.contains(id);

  Future<void> markDayOne(VuV2LabSchool school) async {
    dayOneSeenSchools.add(school.name);
    await _save();
  }

  Future<void> markDayOneLabel(String id) async {
    dayOneSeenSchools.add(id);
    await _save();
  }

  /// Returns newly unlocked badge ids for celebration UI.
  Future<List<String>> completeStation(
    String id, {
    required String notes,
    required int xpGain,
    required int rubricTotal,
    required int runScore,
    required int comboPeak,
    required VuV2LabSchoolDef school,
  }) async {
    final bool firstEver = completedStationIds.isEmpty;
    final bool firstThis = !completedStationIds.contains(id);
    completedStationIds.add(id);
    lastNotesByStation[id] = notes;
    xp += xpGain;

    final int stars = VuV2LabGame.starsForRubric(rubricTotal);
    starsByStation[id] = math.max(starsByStation[id] ?? 0, stars);
    highScoreByStation[id] =
        math.max(highScoreByStation[id] ?? 0, runScore);

    if (firstThis) {
      streak += 1;
    }
    bestStreak = math.max(bestStreak, streak);

    final List<String> unlocked = <String>[];
    void unlock(String badge) {
      if (badges.add(badge)) {
        unlocked.add(badge);
      }
    }

    if (firstEver) unlock('first_clear');
    if (stars >= 3) unlock('triple_star');
    if (streak >= 3) unlock('streak_3');
    if (streak >= 5) unlock('streak_5');
    if (comboPeak >= 4) unlock('combo_4');
    if (xp >= 500) unlock('high_roller');
    if (completedIn(school) >= school.experiments.length) {
      unlock('facility_sweep');
    }

    await _save();
    return unlocked;
  }

  Future<void> breakStreak() async {
    streak = 0;
    await _save();
  }

  int completedIn(VuV2LabSchoolDef school) {
    int n = 0;
    for (int i = 0; i < school.experiments.length; i++) {
      if (completedStationIds.contains(school.experiments[i].id)) {
        n++;
      }
    }
    return n;
  }

  int starsIn(VuV2LabSchoolDef school) {
    int n = 0;
    for (final VuV2LabExperiment e in school.experiments) {
      n += starsByStation[e.id] ?? 0;
    }
    return n;
  }
}
