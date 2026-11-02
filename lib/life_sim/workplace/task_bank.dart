/// Registry of every workplace scenario and the daily assignment picker.
library;

import '../core/stable_random.dart';
import 'content/accounting_tasks.dart';
import 'content/business_tasks.dart';
import 'content/doctor_tasks.dart';
import 'content/law_tasks.dart';
import 'content/nursing_tasks.dart';
import 'content/pharmacy_tasks.dart';
import 'content/software_tasks.dart';
import 'work_task.dart';

class WorkTaskBank {
  const WorkTaskBank._();

  /// Tasks each workday must include to count as a full day.
  static const int tasksPerDay = 3;

  static final Map<String, List<WorkScenario>> _static = <String, List<WorkScenario>>{
    'software_engineer': softwareScenarios,
    'nurse': nursingScenarios,
    'doctor': doctorScenarios,
    'lawyer': lawScenarios,
    'accountant': accountingScenarios,
    'business_manager': businessScenarios,
    'pharmacist': pharmacyScenarios,
  };

  static final Map<String, List<ScenarioGenerator>> _generators = <String, List<ScenarioGenerator>>{
    'accountant': accountingGenerators,
    'business_manager': businessGenerators,
    'pharmacist': pharmacyGenerators,
  };

  static List<WorkScenario> staticFor(String careerId) =>
      _static[careerId] ?? const <WorkScenario>[];

  static List<ScenarioGenerator> generatorsFor(String careerId) =>
      _generators[careerId] ?? const <ScenarioGenerator>[];

  /// Looks up a static scenario or rebuilds a generated one (`gen:<id>:<seed>`).
  static WorkScenario? byId(String id) {
    if (id.startsWith('gen:')) {
      final List<String> parts = id.split(':');
      if (parts.length != 3) return null;
      final int? seed = int.tryParse(parts[2]);
      if (seed == null) return null;
      for (final List<ScenarioGenerator> gens in _generators.values) {
        for (final ScenarioGenerator g in gens) {
          if (g.id == parts[1]) return g.build(seed);
        }
      }
      return null;
    }
    for (final List<WorkScenario> list in _static.values) {
      for (final WorkScenario s in list) {
        if (s.id == id) return s;
      }
    }
    return null;
  }

  /// Stations (interactable ids) that scenarios of [careerId] use.
  static Set<String> stationsFor(String careerId) =>
      staticFor(careerId).map((WorkScenario s) => s.station).toSet()
        ..addAll(generatorsFor(careerId).map((ScenarioGenerator g) => g.build(1).station));

  /// Picks today's assignments deterministically. Avoids [recentIds] and
  /// prefers tasks near the rank's difficulty, always mixing in a short task.
  static List<WorkScenario> assignDay({
    required String careerId,
    required int rank,
    required int day,
    List<String> recentIds = const <String>[],
    int count = tasksPerDay,
  }) {
    final StableRandom rng = StableRandom.fromString('assign|$careerId|$rank|$day');
    final int target = (1 + rank ~/ 2).clamp(1, 3);

    final List<WorkScenario> pool = <WorkScenario>[
      ...staticFor(careerId).where((WorkScenario s) => s.fitsRank(rank)),
      for (final ScenarioGenerator g in generatorsFor(careerId))
        if (g.fitsRank(rank)) g.build(rng.nextInt(90000) + 1),
    ];

    // Weight: closer to target difficulty is better; recent tasks are demoted.
    double weight(WorkScenario s) {
      double w = 3.0 - (s.difficulty - target).abs();
      final String base = s.id.startsWith('gen:') ? s.id.split(':')[1] : s.id;
      final bool recent = recentIds.any((String r) => r == s.id || r.startsWith('gen:$base:') || r == base);
      if (recent) w -= 2.5;
      return w + rng.nextDouble() * 1.4;
    }

    final List<MapEntry<WorkScenario, double>> scored = <MapEntry<WorkScenario, double>>[
      for (final WorkScenario s in pool) MapEntry<WorkScenario, double>(s, weight(s)),
    ]..sort((MapEntry<WorkScenario, double> a, MapEntry<WorkScenario, double> b) => b.value.compareTo(a.value));

    final List<WorkScenario> chosen = <WorkScenario>[];
    // First pass: one scenario per station so the day moves around the workplace.
    for (final MapEntry<WorkScenario, double> e in scored) {
      if (chosen.length >= count) break;
      if (chosen.any((WorkScenario c) => c.station == e.key.station)) continue;
      chosen.add(e.key);
    }
    // Second pass: fill any remaining slots regardless of station.
    for (final MapEntry<WorkScenario, double> e in scored) {
      if (chosen.length >= count) break;
      if (chosen.any((WorkScenario c) => c.id == e.key.id)) continue;
      chosen.add(e.key);
    }
    return chosen;
  }
}
