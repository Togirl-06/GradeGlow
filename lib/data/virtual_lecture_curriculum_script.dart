import '../models/virtual_lecture.dart';
import '../vu_v2/curriculum/professor_voice.dart';

/// AI Professor scripts. Conversational teaching — not a reading of the textbook.
abstract final class VirtualLectureCurriculumScript {
  static bool prefersCurriculumBank({
    required String faculty,
    required String courseId,
  }) {
    final String f = faculty.toLowerCase();
    final String c = courseId.toLowerCase();
    // Dedicated math banks stay on the math lecture engine.
    if (f == 'mathematics' ||
        c.contains('calculus') ||
        c.contains('algebra') ||
        c.contains('trigon') ||
        c.contains('precalculus') ||
        c.contains('statistics') ||
        c.contains('linear_algebra') ||
        c.contains('differential_equation') ||
        c.contains('discrete_math') ||
        c.contains('numerical')) {
      return false;
    }
    return true;
  }

  static VirtualLectureScript build({
    required String lessonTitle,
    required String courseTitle,
    required String moduleTitle,
    required String courseId,
    required String lessonId,
    required LectureMode mode,
    required String faculty,
  }) {
    return ProfessorVoice.lecture(
      lessonTitle: lessonTitle,
      courseTitle: courseTitle,
      moduleTitle: moduleTitle,
      courseId: courseId,
      lessonId: lessonId,
      mode: mode,
      faculty: faculty,
    );
  }
}
