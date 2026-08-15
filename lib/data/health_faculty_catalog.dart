import '../models/health_faculty_program.dart';
import 'world_curriculum_topics.dart';

/// Virtual University curriculum for Nursing, Medicine, and Psychology.
///
/// Built from [WorldCurriculumTopics] so every course has full world-scale
/// topic coverage (not thin 5-topic stubs).
abstract final class HealthFacultyCatalog {
  static List<HealthCourse> coursesFor(HealthFaculty faculty) =>
      switch (faculty) {
        HealthFaculty.nursing => _courses('nursing', HealthFaculty.nursing),
        HealthFaculty.medicine => _courses('medicine', HealthFaculty.medicine),
        HealthFaculty.psychology => _courses(
          'psychology',
          HealthFaculty.psychology,
        ),
      };

  static List<HealthLessonPath> pathsFor(HealthFaculty faculty) =>
      coursesFor(faculty)
          .expand(
            (HealthCourse course) => course.topics.map(
              (HealthTopic topic) => HealthLessonPath(
                faculty: faculty,
                course: course,
                topic: topic,
              ),
            ),
          )
          .toList();

  static List<HealthLessonPath> search(HealthFaculty faculty, String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return const <HealthLessonPath>[];
    return pathsFor(faculty)
        .where(
          (HealthLessonPath path) =>
              path.course.title.toLowerCase().contains(q) ||
              path.topic.title.toLowerCase().contains(q) ||
              path.topic.summary.toLowerCase().contains(q),
        )
        .toList();
  }

  static List<String> catalogCourseNames(HealthFaculty faculty) =>
      WorldCurriculumTopics.coursesFor(faculty.name);

  static List<HealthCourse> _courses(String subjectId, HealthFaculty faculty) {
    final List<String> names = WorldCurriculumTopics.coursesFor(subjectId);
    return names
        .map((String title) => _courseFromWorld(subjectId, title))
        .toList(growable: false);
  }

  static HealthCourse _courseFromWorld(String subjectId, String title) {
    final String id = '${subjectId}_${WorldCurriculumTopics.slug(title)}';
    final List<String> topicTitles = WorldCurriculumTopics.topicsFor(
      subjectId: subjectId,
      courseName: title,
    );
    return HealthCourse(
      id: id,
      title: title,
      topics: topicTitles
          .map(
            (String topicTitle) => HealthTopic(
              id: '${id}_${WorldCurriculumTopics.slug(topicTitle)}',
              title: topicTitle,
              summary: _summaryFor(title, topicTitle),
            ),
          )
          .toList(growable: false),
    );
  }

  static String _summaryFor(String course, String topic) {
    return 'Master $topic within $course. Learn definitions, mechanisms, '
        'clinical or professional applications, common mistakes, and how to '
        'demonstrate competence on assessments. Work through examples until '
        'you can teach this topic to a peer.';
  }
}
