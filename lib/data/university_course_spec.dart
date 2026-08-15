/// Canonical university course structure: Course → Modules → Units (lectures).
library;

/// Full spec for one university course (Section 27 / master registry).
class UniversityCourseSpec {
  const UniversityCourseSpec({
    required this.id,
    required this.subjectId,
    required this.courseCode,
    required this.title,
    required this.subtitle,
    required this.modules,
    this.learningObjectives = const <String>[],
    this.labEnvironmentId = 'general',
    this.emoji = '📚',
    this.priority = true,
  });

  final String id;
  final String subjectId;
  final String courseCode;
  final String title;
  final String subtitle;
  final List<UniversityModuleSpec> modules;
  final List<String> learningObjectives;
  final String labEnvironmentId;
  final String emoji;
  final bool priority;

  String get topicKey => '$subjectId|$id';

  int get lessonCount =>
      modules.fold<int>(0, (int n, UniversityModuleSpec m) => n + m.units.length);

  List<String> get allUnitTitles =>
      modules.expand((UniversityModuleSpec m) => m.units).toList(growable: false);

  List<String> get resolvedObjectives {
    if (learningObjectives.isNotEmpty) return learningObjectives;
    return <String>[
      'Explain core concepts with university-level rigor',
      'Apply ideas in guided practice and laboratory work',
      'Demonstrate mastery on quizzes and examinations',
    ];
  }
}

enum UniversityModuleKind {
  content,
  practical,
  assignment,
  assessment,
  project,
}

class UniversityModuleSpec {
  const UniversityModuleSpec({
    required this.id,
    required this.title,
    required this.units,
    this.kind = UniversityModuleKind.content,
  });

  final String id;
  final String title;
  final List<String> units;
  final UniversityModuleKind kind;
}

/// Builds courses with standard practical + assessment modules appended.
abstract final class UniversityCourseBuilder {
  static String slug(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  static UniversityCourseSpec build({
    required String id,
    required String subjectId,
    required String courseCode,
    required String title,
    required String subtitle,
    required List<UniversityModuleSpec> contentModules,
    List<String> learningObjectives = const <String>[],
    String labEnvironmentId = 'general',
    String emoji = '📚',
  }) {
    final List<UniversityModuleSpec> modules = <UniversityModuleSpec>[
      ...contentModules,
      const UniversityModuleSpec(
        id: 'practical',
        title: 'Practical Laboratory Work',
        kind: UniversityModuleKind.practical,
        units: <String>[
          'Lab Safety and Equipment Orientation',
          'Guided Virtual Laboratory Session',
          'Independent Experimental Design',
        ],
      ),
      const UniversityModuleSpec(
        id: 'assignments',
        title: 'Assignments',
        kind: UniversityModuleKind.assignment,
        units: <String>[
          'Problem Set 1 — Core Concepts',
          'Problem Set 2 — Applications',
          'Written Case Analysis',
        ],
      ),
      const UniversityModuleSpec(
        id: 'assessments',
        title: 'Quizzes and Examinations',
        kind: UniversityModuleKind.assessment,
        units: <String>[
          'Module Knowledge Quiz',
          'Midterm Examination',
          'Comprehensive Final Exam',
        ],
      ),
      const UniversityModuleSpec(
        id: 'capstone',
        title: 'Capstone Project',
        kind: UniversityModuleKind.project,
        units: <String>['Integrated Capstone Project'],
      ),
    ];
    return UniversityCourseSpec(
      id: id,
      subjectId: subjectId,
      courseCode: courseCode,
      title: title,
      subtitle: subtitle,
      modules: modules,
      learningObjectives: learningObjectives,
      labEnvironmentId: labEnvironmentId,
      emoji: emoji,
    );
  }

  static UniversityModuleSpec mod(String title, List<String> units) {
    return UniversityModuleSpec(
      id: slug(title),
      title: title,
      units: units,
    );
  }
}
