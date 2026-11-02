import 'package:shared_preferences/shared_preferences.dart';

import '../data/law_simulation_data.dart';
import '../models/law_simulation.dart';

/// Remembers which courtroom cases the student has already opened so "Next"
/// can advance through the library without repeats until the pool is exhausted.
class LawCaseHistoryService {
  LawCaseHistoryService._();

  static final LawCaseHistoryService instance = LawCaseHistoryService._();

  static const String _keyPlayed = 'law_case_played_ids_v1';

  final Set<String> _played = <String>{};
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _played
      ..clear()
      ..addAll(prefs.getStringList(_keyPlayed) ?? <String>[]);
    _loaded = true;
  }

  bool hasPlayed(String caseId) => _played.contains(caseId);

  int get playedCount => _played.length;

  Future<void> markPlayed(String caseId) async {
    await ensureLoaded();
    if (_played.contains(caseId)) return;
    _played.add(caseId);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyPlayed, _played.toList());
  }

  Future<void> _resetCycle() async {
    _played.clear();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyPlayed, <String>[]);
  }

  /// Next unplayed case in library order. Prefers same specialization when possible.
  /// When every case has been played, starts a fresh cycle (still skips [currentCaseId]).
  Future<LawCaseFile?> nextCase({
    String? currentCaseId,
    String? preferSpecializationId,
  }) async {
    await ensureLoaded();
    final List<LawCaseFile> all = LawSimulationData.allCases;
    if (all.isEmpty) return null;

    LawCaseFile? pick(Iterable<LawCaseFile> pool) {
      for (final LawCaseFile c in pool) {
        if (c.id == currentCaseId) continue;
        if (_played.contains(c.id)) continue;
        return c;
      }
      return null;
    }

    if (preferSpecializationId != null) {
      final LawCaseFile? sameTrack = pick(
        all.where((LawCaseFile c) => c.specializationId == preferSpecializationId),
      );
      if (sameTrack != null) return sameTrack;
    }

    final LawCaseFile? any = pick(all);
    if (any != null) return any;

    // Full library exhausted — new cycle, still avoid repeating the current case immediately.
    await _resetCycle();
    if (currentCaseId != null) {
      _played.add(currentCaseId);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyPlayed, _played.toList());
    }
    if (preferSpecializationId != null) {
      final LawCaseFile? sameTrack = pick(
        all.where((LawCaseFile c) => c.specializationId == preferSpecializationId),
      );
      if (sameTrack != null) return sameTrack;
    }
    return pick(all);
  }

  int remainingUnplayed({String? excludeCaseId}) {
    final int total = LawSimulationData.allCases.length;
    final int played = _played.length +
        (excludeCaseId != null && !_played.contains(excludeCaseId) ? 1 : 0);
    final int left = total - played;
    return left < 0 ? 0 : left;
  }
}
