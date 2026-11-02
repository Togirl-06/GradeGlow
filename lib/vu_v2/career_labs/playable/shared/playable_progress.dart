import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences wrapper for playable career workplaces.
class PlayableProgress {
  PlayableProgress(this.careerId);

  final String careerId;

  String get _prefix => 'playable_${careerId}_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> getSawHire() async {
    final SharedPreferences p = await _prefs;
    return p.getBool('${_prefix}saw_hire') ?? false;
  }

  Future<void> setSawHire(bool value) async {
    final SharedPreferences p = await _prefs;
    await p.setBool('${_prefix}saw_hire', value);
  }

  Future<String> getLocation({String fallback = ''}) async {
    final SharedPreferences p = await _prefs;
    return p.getString('${_prefix}location') ?? fallback;
  }

  Future<void> setLocation(String locationId) async {
    final SharedPreferences p = await _prefs;
    await p.setString('${_prefix}location', locationId);
  }

  Future<bool> isStageDone(String stageId) async {
    final SharedPreferences p = await _prefs;
    return p.getBool('${_prefix}stage_$stageId') ?? false;
  }

  Future<void> setStageDone(String stageId, {bool done = true}) async {
    final SharedPreferences p = await _prefs;
    await p.setBool('${_prefix}stage_$stageId', done);
  }

  Future<int> getScore(String key) async {
    final SharedPreferences p = await _prefs;
    return p.getInt('${_prefix}score_$key') ?? 0;
  }

  Future<void> setScore(String key, int value) async {
    final SharedPreferences p = await _prefs;
    await p.setInt('${_prefix}score_$key', value);
  }

  /// Load stage-done flags for a list of stage ids.
  Future<Map<String, bool>> loadStageFlags(Iterable<String> stageIds) async {
    final SharedPreferences p = await _prefs;
    final Map<String, bool> out = <String, bool>{};
    for (final String id in stageIds) {
      out[id] = p.getBool('${_prefix}stage_$id') ?? false;
    }
    return out;
  }
}
