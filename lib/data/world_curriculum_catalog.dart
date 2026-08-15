import '../models/world_curriculum_program.dart';
import 'world_curriculum_topics.dart';

/// Builds Virtual University course/topic trees from [WorldCurriculumTopics]
/// for any subject id (English overlays, Environmental Science, Political Science, etc.).
abstract final class WorldCurriculumCatalog {
  static List<WorldCourse> coursesFor(String subjectId) {
    final List<String> names = WorldCurriculumTopics.coursesFor(subjectId);
    return names
        .map((String title) => course(subjectId, title))
        .toList(growable: false);
  }

  static WorldCourse course(String subjectId, String title) {
    final String id = '${subjectId}_${WorldCurriculumTopics.slug(title)}';
    final List<String> topicTitles = WorldCurriculumTopics.topicsFor(
      subjectId: subjectId,
      courseName: title,
    );
    return WorldCourse(
      id: id,
      title: title,
      subjectId: subjectId,
      topics: topicTitles
          .map(
            (String t) => WorldTopic(
              id: '${id}_${WorldCurriculumTopics.slug(t)}',
              title: t,
              summary:
                  'Study $t in $title. Cover core concepts, worked examples, '
                  'real-world applications, common errors, and a mastery check.',
            ),
          )
          .toList(growable: false),
    );
  }

  static List<WorldLessonPath> pathsFor(String subjectId) =>
      coursesFor(subjectId)
          .expand(
            (WorldCourse c) => c.topics.map(
              (WorldTopic t) =>
                  WorldLessonPath(subjectId: subjectId, course: c, topic: t),
            ),
          )
          .toList();

  static List<WorldLessonPath> search(String subjectId, String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return const <WorldLessonPath>[];
    return pathsFor(subjectId)
        .where(
          (WorldLessonPath p) =>
              p.course.title.toLowerCase().contains(q) ||
              p.topic.title.toLowerCase().contains(q) ||
              p.topic.summary.toLowerCase().contains(q),
        )
        .toList();
  }

  static int topicCount(String subjectId) => pathsFor(subjectId).length;
}
