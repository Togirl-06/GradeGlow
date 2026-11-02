// Virtual University Mathematics Degree — curriculum & lesson activity models.

enum MathLessonActivityKind {
  lecture('Lecture', '🎥', 'AI professor · visual whiteboard · interactive'),
  interactiveLesson('Interactive Lesson', '📖', 'Hands-on exploration'),
  guidedPractice('Guided Practice', '✏️', 'Easy → medium → hard with hints'),
  aiTutor('AI Tutor', '🤖', 'Step-by-step help on demand'),
  homework('Homework', '📝', 'Retired — use quiz instead'),
  quiz('Quiz', '🧪', '50 mixed questions'),
  virtualLab('Virtual Lab', '🔬', 'Drag, zoom & visualize'),
  officeHours('Office Hours', '🧑‍🏫', 'Voice & whiteboard tutoring'),
  exam('Exam', '🏆', '30 questions · 18+ to earn certificate');

  const MathLessonActivityKind(this.label, this.emoji, this.subtitle);

  final String label;
  final String emoji;
  final String subtitle;

  /// Weight toward lesson mastery (0–100 total across active activities).
  int get masteryWeight => switch (this) {
        MathLessonActivityKind.lecture => 20,
        MathLessonActivityKind.interactiveLesson => 0,
        MathLessonActivityKind.guidedPractice => 0,
        MathLessonActivityKind.aiTutor => 20,
        MathLessonActivityKind.homework => 0,
        MathLessonActivityKind.quiz => 30,
        MathLessonActivityKind.virtualLab => 0,
        MathLessonActivityKind.officeHours => 0,
        MathLessonActivityKind.exam => 30,
      };

  /// Activities shown in the lesson hub (must all be done for 100% mastery).
  static const List<MathLessonActivityKind> activeLessonFlow =
      <MathLessonActivityKind>[
    MathLessonActivityKind.lecture,
    MathLessonActivityKind.aiTutor,
    MathLessonActivityKind.quiz,
    MathLessonActivityKind.exam,
  ];

  static int get activeFlowWeightTotal => activeLessonFlow.fold<int>(
        0,
        (int sum, MathLessonActivityKind kind) => sum + kind.masteryWeight,
      );
}

class MathematicsDegreeLesson {
  const MathematicsDegreeLesson({required this.id, required this.title});

  final String id;
  final String title;
}

class MathematicsDegreeModule {
  const MathematicsDegreeModule({
    required this.id,
    required this.title,
    required this.lessons,
  });

  final String id;
  final String title;
  final List<MathematicsDegreeLesson> lessons;

  int get lessonCount => lessons.length;
}

class MathematicsDegreeCourse {
  const MathematicsDegreeCourse({
    required this.id,
    required this.title,
    required this.modules,
    this.emoji = '📘',
    this.tagline,
  });

  final String id;
  final String title;
  final List<MathematicsDegreeModule> modules;
  final String emoji;
  final String? tagline;

  int get lessonCount =>
      modules.fold<int>(0, (sum, module) => sum + module.lessonCount);

  int get moduleCount => modules.length;
}

class MathematicsDegreeYear {
  const MathematicsDegreeYear({
    required this.year,
    required this.title,
    required this.courses,
    this.subtitle,
  });

  final int year;
  final String title;
  final List<MathematicsDegreeCourse> courses;
  final String? subtitle;
}

/// Resolved lesson path inside the degree tree.
class MathematicsLessonPath {
  const MathematicsLessonPath({
    required this.year,
    required this.course,
    required this.module,
    required this.lesson,
  });

  final MathematicsDegreeYear year;
  final MathematicsDegreeCourse course;
  final MathematicsDegreeModule module;
  final MathematicsDegreeLesson lesson;

  String get breadcrumb =>
      '${year.title} · ${course.title} · ${module.title}';
}
