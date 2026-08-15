// Virtual University Chemistry Degree — curriculum & lesson activity models.

enum ChemLessonActivityKind {
  lecture('AI Professor Lecture', '🎓', 'Live teaching · animations · checkpoints'),
  textbook('AI Textbook', '📚', 'Complete textbook chapter — no summaries'),
  moleculeStudio('3D Molecules', '🧬', 'Rotate · click atoms · bond views'),
  periodicTable('Periodic Table', '⚗️', 'Interactive element profiles'),
  virtualLab('Virtual Laboratory', '🔬', 'Perform experiments safely'),
  equationBuilder('Equation Builder', '⚖️', 'Balance & classify reactions'),
  aiTutor('AI Tutor', '🤖', 'Ask anything · interrupt anytime'),
  quiz('Quiz', '🧪', 'Adaptive practice'),
  exam('Exam', '🏆', 'University-level assessment'),
  labReport('Lab Report', '📋', 'AI-graded write-up');

  const ChemLessonActivityKind(this.label, this.emoji, this.subtitle);

  final String label;
  final String emoji;
  final String subtitle;

  int get masteryWeight => switch (this) {
        ChemLessonActivityKind.lecture => 20,
        ChemLessonActivityKind.textbook => 10,
        ChemLessonActivityKind.moleculeStudio => 5,
        ChemLessonActivityKind.periodicTable => 0,
        ChemLessonActivityKind.virtualLab => 15,
        ChemLessonActivityKind.equationBuilder => 0,
        ChemLessonActivityKind.aiTutor => 15,
        ChemLessonActivityKind.quiz => 20,
        ChemLessonActivityKind.exam => 15,
        ChemLessonActivityKind.labReport => 0,
      };

  static const List<ChemLessonActivityKind> activeLessonFlow = <ChemLessonActivityKind>[
    ChemLessonActivityKind.lecture,
    ChemLessonActivityKind.textbook,
    ChemLessonActivityKind.virtualLab,
    ChemLessonActivityKind.aiTutor,
    ChemLessonActivityKind.quiz,
    ChemLessonActivityKind.exam,
  ];

  static int get activeFlowWeightTotal => activeLessonFlow.fold<int>(
        0,
        (int sum, ChemLessonActivityKind kind) => sum + kind.masteryWeight,
      );
}

class ChemistryDegreeLesson {
  const ChemistryDegreeLesson({required this.id, required this.title});

  final String id;
  final String title;
}

class ChemistryDegreeModule {
  const ChemistryDegreeModule({
    required this.id,
    required this.title,
    required this.lessons,
  });

  final String id;
  final String title;
  final List<ChemistryDegreeLesson> lessons;

  int get lessonCount => lessons.length;
}

class ChemistryDegreeCourse {
  const ChemistryDegreeCourse({
    required this.id,
    required this.title,
    required this.modules,
    this.emoji = '⚗️',
    this.tagline,
  });

  final String id;
  final String title;
  final List<ChemistryDegreeModule> modules;
  final String emoji;
  final String? tagline;

  int get lessonCount =>
      modules.fold<int>(0, (int sum, ChemistryDegreeModule m) => sum + m.lessonCount);

  int get moduleCount => modules.length;
}

class ChemistryDegreeYear {
  const ChemistryDegreeYear({
    required this.year,
    required this.title,
    required this.courses,
    this.subtitle,
  });

  final int year;
  final String title;
  final List<ChemistryDegreeCourse> courses;
  final String? subtitle;
}

class ChemistryLessonPath {
  const ChemistryLessonPath({
    required this.year,
    required this.course,
    required this.module,
    required this.lesson,
  });

  final ChemistryDegreeYear year;
  final ChemistryDegreeCourse course;
  final ChemistryDegreeModule module;
  final ChemistryDegreeLesson lesson;

  String get breadcrumb => '${year.title} · ${course.title}';
}

class ChemistryCourseRef {
  const ChemistryCourseRef({required this.year, required this.course});

  final ChemistryDegreeYear year;
  final ChemistryDegreeCourse course;
}
