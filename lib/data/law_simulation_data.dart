import '../models/law_simulation.dart';
import 'law_simulation_cases.dart';

/// Structured case files — hidden truth is fixed; AI follows the case engine.
class LawSimulationData {
  LawSimulationData._();

  static LawPlayerProgress playerProgress = LawPlayerProgress();

  static List<LawInvestigationAction> get standardActions => LawSimulationCases.actions;

  static List<LawCaseFile> get allCases => LawSimulationCases.all;

  static LawCaseFile caseById(String id) => LawSimulationCases.byId(id) ?? LawSimulationCases.all.first;

  static LawCaseFile? caseForSpecialization(String specializationId) =>
      LawSimulationCases.forSpecialization(specializationId);

  static List<LawCaseFile> casesForSpecialization(String specializationId) =>
      LawSimulationCases.forSpecializationAll(specializationId);

  /// One rotating daily challenge across the full library.
  static LawCaseFile dailyCase([DateTime? when]) {
    final int day = (when ?? DateTime.now()).difference(DateTime(2024)).inDays;
    return allCases[day.abs() % allCases.length];
  }

  /// Stable daily courtroom case for a specialization (rotates among that track's cases).
  static LawCaseFile? dailyCaseForSpecialization(String specializationId, [DateTime? when]) {
    final List<LawCaseFile> cases = casesForSpecialization(specializationId);
    if (cases.isEmpty) return null;
    final DateTime d = when ?? DateTime.now();
    final int seed = d.year * 10000 + d.month * 100 + d.day;
    return cases[(seed + specializationId.hashCode).abs() % cases.length];
  }

  /// Cases grouped by specialization for the library UI.
  static Map<String, List<LawCaseFile>> get casesBySpecialization {
    final Map<String, List<LawCaseFile>> map = <String, List<LawCaseFile>>{};
    for (final LawCaseFile file in allCases) {
      final String key = file.displayTrack;
      map.putIfAbsent(key, () => <LawCaseFile>[]).add(file);
    }
    final List<String> keys = map.keys.toList()..sort();
    return <String, List<LawCaseFile>>{
      for (final String k in keys) k: map[k]!,
    };
  }
}
