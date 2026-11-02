import '../models/mathematics_degree.dart';
import 'mathematics_degree/year1_data.dart';
import 'mathematics_degree/year2_data.dart';
import 'mathematics_degree/year3_data.dart';
import 'mathematics_degree/year4_data.dart';

/// Full Virtual University Mathematics curriculum.
class MathematicsDegreeCatalog {
  MathematicsDegreeCatalog._();

  static final List<MathematicsDegreeYear> years = <MathematicsDegreeYear>[
    mathematicsDegreeYear1(),
    mathematicsDegreeYear2(),
    mathematicsDegreeYear3(),
    mathematicsDegreeYear4(),
  ];

  static int get totalLessons {
    var count = 0;
    for (final year in years) {
      for (final course in year.courses) {
        count += course.lessonCount;
      }
    }
    return count;
  }

  static MathematicsDegreeYear? yearByNumber(int year) {
    for (final entry in years) {
      if (entry.year == year) return entry;
    }
    return null;
  }

  static MathematicsDegreeCourse? courseById(String courseId) {
    for (final year in years) {
      for (final course in year.courses) {
        if (course.id == courseId) return course;
      }
    }
    return null;
  }

  static MathematicsLessonPath? resolveLesson(String lessonId) {
    for (final year in years) {
      for (final course in year.courses) {
        for (final module in course.modules) {
          for (final lesson in module.lessons) {
            if (lesson.id == lessonId) {
              return MathematicsLessonPath(
                year: year,
                course: course,
                module: module,
                lesson: lesson,
              );
            }
          }
        }
      }
    }
    return null;
  }

  /// First lesson in catalog order (onboarding default).
  static MathematicsLessonPath get defaultLesson {
    final year = years.first;
    final course = year.courses.first;
    final module = course.modules.first;
    final lesson = module.lessons.first;
    return MathematicsLessonPath(
      year: year,
      course: course,
      module: module,
      lesson: lesson,
    );
  }

  static List<MathematicsLessonPath>? _allLessonPathsCache;

  /// Linear walk through every lesson for progress / continue learning.
  static List<MathematicsLessonPath> get allLessonPaths {
    return _allLessonPathsCache ??= _buildAllLessonPaths();
  }

  static List<MathematicsLessonPath> _buildAllLessonPaths() {
    final paths = <MathematicsLessonPath>[];
    for (final year in years) {
      for (final course in year.courses) {
        for (final module in course.modules) {
          for (final lesson in module.lessons) {
            paths.add(
              MathematicsLessonPath(
                year: year,
                course: course,
                module: module,
                lesson: lesson,
              ),
            );
          }
        }
      }
    }
    return paths;
  }

  static bool isLimitsLesson(MathematicsLessonPath path) {
    return path.course.id == 'calculus_1' &&
        path.lesson.title.toLowerCase().contains('limit');
  }

  static bool isDerivativeLesson(MathematicsLessonPath path) {
    return path.course.id == 'calculus_1' &&
        (path.lesson.title.toLowerCase().contains('derivative') ||
            path.lesson.title == 'Power Rule');
  }

  /// Every course with its track (level) for free browsing.
  static List<MathematicsCourseRef> get allCourses {
    final refs = <MathematicsCourseRef>[];
    for (final year in years) {
      for (final course in year.courses) {
        refs.add(MathematicsCourseRef(year: year, course: course));
      }
    }
    return refs;
  }

  static List<MathematicsCourseRef> coursesForTrack(int? yearNumber) {
    if (yearNumber == null) return allCourses;
    return allCourses.where((MathematicsCourseRef r) => r.year.year == yearNumber).toList();
  }

  static List<MathematicsLessonPath> search(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return const <MathematicsLessonPath>[];
    return allLessonPaths
        .where(
          (MathematicsLessonPath path) =>
              path.lesson.title.toLowerCase().contains(q) ||
              path.course.title.toLowerCase().contains(q) ||
              path.module.title.toLowerCase().contains(q) ||
              path.year.title.toLowerCase().contains(q),
        )
        .toList();
  }
}

/// A course inside a track — no required order between tracks.
class MathematicsCourseRef {
  const MathematicsCourseRef({required this.year, required this.course});

  final MathematicsDegreeYear year;
  final MathematicsDegreeCourse course;
}
