import '../vu_v2/data/vu_v2_roadmap_models.dart';
import 'master_curriculum_registry.dart';
import 'university_course_spec.dart';

/// Converts [MasterCurriculumRegistry] specs into V2 roadmap trees.
abstract final class MasterCurriculumRoadmap {
  static bool hasCourses(String subjectId) =>
      MasterCurriculumRegistry.coursesForSubject(subjectId).isNotEmpty;

  static VuV2RoadmapTrack trackForSubject(String subjectId) {
    final List<UniversityCourseSpec> courses =
        MasterCurriculumRegistry.coursesForSubject(subjectId);
    return VuV2RoadmapTrack(
      id: '${subjectId}_university_core',
      title: 'University Core Curriculum',
      subtitle:
          '${courses.length} courses · ${courses.fold<int>(0, (int n, UniversityCourseSpec c) => n + c.lessonCount)} lessons',
      courses: courses.map(_toRoadmapCourse).toList(growable: false),
    );
  }

  static VuV2DegreeRoadmap roadmapForSubject({
    required String subjectId,
    required String title,
    required String emoji,
    String? tagline,
    List<VuV2RoadmapTrack>? additionalTracks,
  }) {
    final VuV2RoadmapTrack core = trackForSubject(subjectId);
    final List<VuV2RoadmapTrack> tracks = <VuV2RoadmapTrack>[
      core,
      ...?additionalTracks,
    ];
    final int lessons =
        tracks.fold<int>(0, (int n, VuV2RoadmapTrack t) => n + t.lessonCount);
    return VuV2DegreeRoadmap(
      subjectId: subjectId,
      title: title,
      emoji: emoji,
      tagline: tagline ?? 'University-grade lecture · lab · assessment loop',
      sourceLabel:
          'Master Curriculum · ${core.courses.length} priority courses · $lessons lessons',
      tracks: tracks,
    );
  }

  static VuV2RoadmapCourse _toRoadmapCourse(UniversityCourseSpec spec) {
    return VuV2RoadmapCourse(
      id: spec.id,
      title: spec.title,
      subtitle: spec.subtitle,
      emoji: spec.emoji,
      learningObjectives: spec.resolvedObjectives,
      modules: spec.modules
          .map(
            (UniversityModuleSpec m) => VuV2RoadmapModule(
              id: m.id,
              title: m.title,
              lessons: m.units
                  .asMap()
                  .entries
                  .map(
                    (MapEntry<int, String> e) => VuV2RoadmapLesson(
                      id: '${spec.id}_${m.id}_${e.key}',
                      title: e.value,
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
    );
  }

  static List<String> courseNamesFor(String subjectId) =>
      MasterCurriculumRegistry.coursesForSubject(subjectId)
          .map((UniversityCourseSpec c) => c.title)
          .toList(growable: false);

  static List<String> topicsFor({
    required String subjectId,
    required String courseName,
  }) {
    final UniversityCourseSpec? spec =
        MasterCurriculumRegistry.courseByTitle(subjectId, courseName);
    if (spec != null) return spec.allUnitTitles;
    final UniversityCourseSpec? byId =
        MasterCurriculumRegistry.course(subjectId, UniversityCourseBuilder.slug(courseName));
    return byId?.allUnitTitles ?? const <String>[];
  }
}
