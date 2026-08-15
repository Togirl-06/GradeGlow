import 'bio_101_curriculum.dart';
import 'university_course_spec.dart';

/// Registry of university course specs used by [MasterCurriculumRoadmap].
///
/// Currently seeds BIO-101; additional Section 27 courses can be registered here.
abstract final class MasterCurriculumRegistry {
  static final List<UniversityCourseSpec> _all = <UniversityCourseSpec>[
    _bio101(),
  ];

  static List<UniversityCourseSpec> coursesForSubject(String subjectId) {
    final String id = subjectId.trim().toLowerCase();
    return _all
        .where((UniversityCourseSpec c) => c.subjectId == id || _aliases(id, c.subjectId))
        .toList(growable: false);
  }

  static UniversityCourseSpec? course(String subjectId, String courseId) {
    for (final UniversityCourseSpec c in coursesForSubject(subjectId)) {
      if (c.id == courseId) return c;
    }
    return null;
  }

  static UniversityCourseSpec? courseByTitle(String subjectId, String title) {
    final String needle = title.trim().toLowerCase();
    for (final UniversityCourseSpec c in coursesForSubject(subjectId)) {
      if (c.title.toLowerCase() == needle ||
          c.courseCode.toLowerCase() == needle ||
          c.title.toLowerCase().contains(needle)) {
        return c;
      }
    }
    return null;
  }

  static bool _aliases(String query, String subjectId) {
    if (query == subjectId) return true;
    if (query == 'biology' && subjectId == 'biology') return true;
    if (query == 'general_biology' && subjectId == 'biology') return true;
    return false;
  }

  static UniversityCourseSpec _bio101() {
    return UniversityCourseBuilder.build(
      id: 'general_biology',
      subjectId: 'biology',
      courseCode: Bio101Curriculum.courseCode,
      title: Bio101Curriculum.title,
      subtitle: Bio101Curriculum.subtitle,
      emoji: '🧬',
      learningObjectives: const <String>[
        'Explain the characteristics of life and scientific method',
        'Relate chemistry of life to cell structure and function',
        'Apply genetics and inheritance to problem sets',
        'Connect evolution and ecology to laboratory investigation',
      ],
      contentModules: Bio101Curriculum.modules
          .map(
            (Bio101Module m) => UniversityModuleSpec(
              id: m.id,
              title: m.title,
              units: m.units,
            ),
          )
          .toList(growable: false),
    );
  }
}
