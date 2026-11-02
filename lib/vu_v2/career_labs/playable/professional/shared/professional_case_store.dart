import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistent case notebook + progression for professional sims.
class ProCaseStore {
  ProCaseStore(this.careerId);

  final String careerId;

  String get _p => 'pro_case_${careerId}_';

  final List<String> notes = <String>[];
  final List<String> evidence = <String>[];
  final List<String> decisions = <String>[];
  final List<Map<String, dynamic>> reflections = <Map<String, dynamic>>[];
  final Set<String> completedMissionIds = <String>{};
  final Set<String> unlockedDepts = <String>{};
  final Map<String, double> meters = <String, double>{};
  final Map<String, int> skillXp = <String, int>{};

  int xp = 0;
  int coins = 0;
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final SharedPreferences p = await SharedPreferences.getInstance();
    notes
      ..clear()
      ..addAll(p.getStringList('${_p}notes') ?? const <String>[]);
    evidence
      ..clear()
      ..addAll(p.getStringList('${_p}evidence') ?? const <String>[]);
    decisions
      ..clear()
      ..addAll(p.getStringList('${_p}decisions') ?? const <String>[]);
    completedMissionIds
      ..clear()
      ..addAll((p.getStringList('${_p}done') ?? const <String>[]).toSet());
    unlockedDepts
      ..clear()
      ..addAll((p.getStringList('${_p}depts') ?? const <String>[]).toSet());
    xp = p.getInt('${_p}xp') ?? 0;
    coins = p.getInt('${_p}coins') ?? 0;
    final String? m = p.getString('${_p}meters');
    if (m != null) {
      final Map<String, dynamic> map =
          jsonDecode(m) as Map<String, dynamic>;
      meters
        ..clear()
        ..addAll(map.map((String k, dynamic v) => MapEntry(k, (v as num).toDouble())));
    }
    final String? s = p.getString('${_p}skills');
    if (s != null) {
      final Map<String, dynamic> map =
          jsonDecode(s) as Map<String, dynamic>;
      skillXp
        ..clear()
        ..addAll(map.map((String k, dynamic v) => MapEntry(k, (v as num).toInt())));
    }
    final String? r = p.getString('${_p}reflections');
    if (r != null) {
      reflections
        ..clear()
        ..addAll((jsonDecode(r) as List<dynamic>)
            .cast<Map<String, dynamic>>());
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setStringList('${_p}notes', notes);
    await p.setStringList('${_p}evidence', evidence);
    await p.setStringList('${_p}decisions', decisions);
    await p.setStringList('${_p}done', completedMissionIds.toList());
    await p.setStringList('${_p}depts', unlockedDepts.toList());
    await p.setInt('${_p}xp', xp);
    await p.setInt('${_p}coins', coins);
    await p.setString('${_p}meters', jsonEncode(meters));
    await p.setString('${_p}skills', jsonEncode(skillXp));
    await p.setString('${_p}reflections', jsonEncode(reflections));
  }

  Future<void> addNote(String note) async {
    await ensureLoaded();
    notes.insert(0, note);
    await _save();
  }

  Future<void> addEvidence(String item) async {
    await ensureLoaded();
    if (!evidence.contains(item)) evidence.add(item);
    await _save();
  }

  Future<void> addDecision(String decision) async {
    await ensureLoaded();
    decisions.insert(0, decision);
    await _save();
  }

  Future<void> setMeter(String key, double value) async {
    await ensureLoaded();
    meters[key] = value;
    await _save();
  }

  Future<void> applyMeters(Map<String, double> delta) async {
    await ensureLoaded();
    delta.forEach((String k, double v) {
      meters[k] = ((meters[k] ?? 50) + v).clamp(0, 100);
    });
    await _save();
  }

  Future<void> awardXp(int amount, {int coinsGain = 0, String? skill}) async {
    await ensureLoaded();
    xp += amount;
    coins += coinsGain;
    if (skill != null) {
      skillXp[skill] = (skillXp[skill] ?? 0) + amount;
    }
    await _save();
  }

  Future<void> completeMission(String id) async {
    await ensureLoaded();
    completedMissionIds.add(id);
    await _save();
  }

  Future<void> unlockDept(String id) async {
    await ensureLoaded();
    unlockedDepts.add(id);
    await _save();
  }

  Future<void> addReflection({
    required String missionId,
    required String text,
  }) async {
    await ensureLoaded();
    reflections.insert(0, <String, dynamic>{
      'missionId': missionId,
      'text': text,
      'at': DateTime.now().toIso8601String(),
    });
    await _save();
  }
}
