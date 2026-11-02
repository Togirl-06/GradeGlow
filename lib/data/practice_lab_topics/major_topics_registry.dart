import '../../models/practice_lab_topic.dart';
import 'business_major_topics.dart';
import 'computer_technology_topics.dart';
import 'engineering_major_topics.dart';
import 'extended_major_topics.dart';
import 'health_medical_major_topics.dart';
import 'law_major_topics.dart';
import 'nursing_topics.dart';
import 'science_major_topics.dart';
import 'social_science_major_topics.dart';

/// Central registry — every major maps to its own distinct topic catalog.
class MajorTopicsRegistry {
  MajorTopicsRegistry._();

  static final Map<String, List<PracticeLabTopicArea>> _registry =
      <String, List<PracticeLabTopicArea>>{
    // Health & medical — nursing has full catalog; others are major-specific
    'nursing': nursingTopicAreas,
    ...healthMedicalTopicsByMajor,

    // Computer & technology — each major has unique topics
    ...computerTechnologyTopicsByMajor,

    // Business — each major has unique topics
    ...businessTopicsByMajor,

    // Law & criminal justice
    ...lawTopicsByMajor,

    // Psychology & social sciences
    ...socialScienceTopicsByMajor,

    // Engineering — each discipline has unique topics
    ...engineeringTopicsByMajor,

    // Science
    ...scienceTopicsByMajor,

    // Curated overrides for select extended majors
    ...extendedMajorOverrides,
  };

  static List<PracticeLabTopicArea> topicsFor({
    required String majorId,
    String? majorName,
    String? groupId,
  }) {
    final List<PracticeLabTopicArea>? curated = _registry[majorId];
    if (curated != null && curated.isNotEmpty) return curated;

    return distinctGenericTopicsForMajor(
      majorId: majorId,
      majorName: majorName ?? _formatMajorName(majorId),
      groupId: groupId ?? 'general',
    );
  }

  static bool hasTopics(String majorId) => topicsFor(majorId: majorId).isNotEmpty;

  static String _formatMajorName(String majorId) =>
      majorId.split('_').map((String w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
}
