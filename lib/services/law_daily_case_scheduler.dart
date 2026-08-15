import '../data/law/law_catalog.dart';
import '../data/law_simulation_data.dart';
import '../models/law/law_program.dart';
import '../models/law_simulation.dart';

/// Picks today's immersive court case — weekday specialty rotation + per-track daily case.
class LawDailyCaseScheduler {
  LawDailyCaseScheduler._();

  /// Weekday → featured specialization for Law School home / global daily.
  static const List<String> weekdaySpecializationIds = <String>[
    'criminal_law', // Monday
    'contracts', // Tuesday
    'family_law', // Wednesday
    'constitutional_law', // Thursday
    'corporate_law', // Friday
    'ip_law', // Saturday
    'environmental_law', // Sunday
  ];

  static String weekdaySpecializationId([DateTime? when]) {
    final DateTime d = when ?? DateTime.now();
    return weekdaySpecializationIds[d.weekday - 1];
  }

  static LawCaseFile weekdayFeaturedCase([DateTime? when]) {
    final String specId = weekdaySpecializationId(when);
    return LawSimulationData.dailyCaseForSpecialization(specId) ?? LawSimulationData.dailyCase(when);
  }

  /// One court case per specialization per day (rotates among that track's case files).
  static LawCaseFile? caseForSpecialization(String specializationId, [DateTime? when]) {
    final LawCaseFile? daily = LawSimulationData.dailyCaseForSpecialization(specializationId, when);
    if (daily != null) return daily;

    // Fallback: rotate catalog lessons' simulation ids if present.
    final LawSpecialization? spec = LawCatalog.byId(specializationId);
    if (spec == null) return null;
    final List<String> ids = <String>[
      for (final LawCourse c in spec.courses)
        for (final LawLesson l in c.lessons)
          if (l.simulationCaseId != null) l.simulationCaseId!,
    ];
    if (ids.isEmpty) return null;
    final DateTime d = when ?? DateTime.now();
    final int seed = d.year * 10000 + d.month * 100 + d.day;
    final String id = ids[(seed + specializationId.hashCode).abs() % ids.length];
    return LawSimulationData.caseById(id);
  }
}
