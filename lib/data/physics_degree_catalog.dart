import '../models/physics/physics_program.dart';
import '../models/physics_degree.dart';
import 'physics/physics_catalog.dart';

/// Index over [PhysicsCatalog] for degree-style navigation.
class PhysicsDegreeCatalog {
  PhysicsDegreeCatalog._();

  static List<PhysicsLevel> get levels => PhysicsCatalog.levels;

  static int get totalLessons => PhysicsCatalog.topicCount;

  static PhysicsLessonPath get defaultLesson {
    final PhysicsTrack track = PhysicsCatalog.tracks.first;
    final PhysicsCourse course = track.courses.first;
    final PhysicsTopic topic = course.topics.first;
    return PhysicsLessonPath(track: track, course: course, topic: topic);
  }

  static List<PhysicsLessonPath>? _pathsCache;

  static List<PhysicsLessonPath> get allLessonPaths {
    return _pathsCache ??= _buildAllPaths();
  }

  static List<PhysicsLessonPath> _buildAllPaths() {
    final List<PhysicsLessonPath> paths = <PhysicsLessonPath>[];
    for (final PhysicsTrack track in PhysicsCatalog.tracks) {
      for (final PhysicsCourse course in track.courses) {
        for (final PhysicsTopic topic in course.topics) {
          paths.add(
            PhysicsLessonPath(track: track, course: course, topic: topic),
          );
        }
      }
    }
    return paths;
  }

  static PhysicsLessonPath? resolveTopic(String topicId) {
    for (final PhysicsLessonPath path in allLessonPaths) {
      if (path.topic.id == topicId) return path;
    }
    return null;
  }

  static List<PhysicsCourseRef> get allCourses {
    final List<PhysicsCourseRef> refs = <PhysicsCourseRef>[];
    for (final PhysicsTrack track in PhysicsCatalog.tracks) {
      for (final PhysicsCourse course in track.courses) {
        refs.add(PhysicsCourseRef(track: track, course: course));
      }
    }
    return refs;
  }

  static List<PhysicsCourseRef> coursesForLevel(PhysicsLevel? level) {
    if (level == null) return allCourses;
    return allCourses.where((PhysicsCourseRef r) => r.track.level == level).toList();
  }

  static List<PhysicsLessonPath> search(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return const <PhysicsLessonPath>[];
    return allLessonPaths
        .where(
          (PhysicsLessonPath path) =>
              path.topic.title.toLowerCase().contains(q) ||
              path.course.title.toLowerCase().contains(q) ||
              path.track.name.toLowerCase().contains(q) ||
              path.track.level.label.toLowerCase().contains(q),
        )
        .toList();
  }
}
