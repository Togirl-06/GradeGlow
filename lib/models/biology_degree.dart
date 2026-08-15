// Virtual University Biology — lesson activity models for active learning.

enum BioLessonActivityKind {
  lecture(
    '1. AI Professor Lecture',
    '🎓',
    'Observe · explain · pause for questions',
  ),
  interactive(
    '2. Interactive Activity',
    '🧩',
    'Label · drag-and-drop · control animations',
  ),
  model3d(
    '3. 3D Exploration',
    '🧬',
    'Rotate · zoom · isolate structures',
  ),
  virtualLab(
    '4. Virtual Experiment',
    '🧪',
    'Lab · microscope · dissection · data',
  ),
  practice(
    '5. Practice Exercises',
    '✏️',
    'Adaptive questions with hints',
  ),
  caseStudies(
    '6. Case Study',
    '🩺',
    'Investigate · diagnose · apply evidence',
  ),
  aiTutor(
    '7. AI Discussion',
    '🤖',
    'Ask naturally · deepen understanding',
  ),
  exam(
    '8. Assessment',
    '🏆',
    'Identify · analyze · demonstrate mastery',
  ),
  reflection(
    '9. Reflection & Notes',
    '📒',
    'Lab notebook · vocabulary · AI feedback',
  ),
  // Optional deep-dives launched from Virtual Experiment when relevant
  microscope(
    'Microscope Investigation',
    '🔬',
    'Focus · stain · compare specimens',
  ),
  dissection(
    'Dissection Simulator',
    '🫀',
    'Cut · identify · label organs',
  ),
  animation(
    'Process Animation',
    '▶️',
    'Play · pause · slow-motion phases',
  ),
  notebook(
    'Biology Notebook',
    '📚',
    'Textbook-quality reference notes',
  ),
  labReport(
    'Lab Report',
    '📋',
    'Formal write-up · AI grading',
  );

  const BioLessonActivityKind(this.label, this.emoji, this.subtitle);

  final String label;
  final String emoji;
  final String subtitle;

  /// Clean title for workspace cards (without step numbers).
  String get shortTitle => label.replaceFirst(RegExp(r'^\d+\.\s*'), '');

  int get xpReward => masteryWeight * 2;

  /// Action bullets shown on the lesson hub card.
  List<String> workspaceBulletsFor(String topic) {
    final String t = topic.toLowerCase();
    return switch (this) {
      BioLessonActivityKind.lecture => <String>[
          'AI professor teaches live',
          'Whiteboard diagrams & checkpoints',
          'Ask questions anytime',
        ],
      BioLessonActivityKind.interactive => <String>[
          'Label structures on the diagram',
          'Drag tags onto organelles',
          'Check answers · earn XP',
        ],
      BioLessonActivityKind.model3d => <String>[
          if (t.contains('heart') || t.contains('cardio')) ...<String>[
            'Rotate heart · cutaway view',
            'Blood flow animation',
            'Healthy vs diseased toggle',
          ] else ...<String>[
            'Rotate · zoom · peel layers',
            'Isolate organelles / organs',
            'Healthy vs damaged compare',
          ],
        ],
      BioLessonActivityKind.virtualLab => <String>[
          if (t.contains('photo')) ...<String>[
            'Change light · CO₂ · water',
            'Watch plant respond live',
            'Graphs update automatically',
          ] else ...<String>[
            'Run controlled experiments',
            'Microscope & dissection tools',
            'Analyze scientific data',
          ],
        ],
      BioLessonActivityKind.practice => <String>[
          'Adaptive practice questions',
          'Hints when you struggle',
          'Explanations after each item',
        ],
      BioLessonActivityKind.caseStudies => <String>[
          'Medical / ecology investigation',
          'Read labs & history',
          'Defend your diagnosis',
        ],
      BioLessonActivityKind.aiTutor => <String>[
          'Natural conversation',
          'Diagrams & follow-ups',
          'Clarify misconceptions',
        ],
      BioLessonActivityKind.exam => <String>[
          'Practical assessment',
          'Identify · analyze · apply',
          'Certificate when you pass',
        ],
      BioLessonActivityKind.reflection => <String>[
          'Digital lab notebook',
          'Vocabulary & conclusions',
          'AI feedback on writing',
        ],
      _ => <String>[subtitle],
    };
  }

  int get masteryWeight => switch (this) {
        BioLessonActivityKind.lecture => 15,
        BioLessonActivityKind.interactive => 15,
        BioLessonActivityKind.model3d => 10,
        BioLessonActivityKind.virtualLab => 15,
        BioLessonActivityKind.practice => 10,
        BioLessonActivityKind.caseStudies => 10,
        BioLessonActivityKind.aiTutor => 10,
        BioLessonActivityKind.exam => 10,
        BioLessonActivityKind.reflection => 5,
        BioLessonActivityKind.microscope => 0,
        BioLessonActivityKind.dissection => 0,
        BioLessonActivityKind.animation => 0,
        BioLessonActivityKind.notebook => 0,
        BioLessonActivityKind.labReport => 0,
      };

  /// Required active-learning pipeline for every biology lesson.
  static const List<BioLessonActivityKind> activeLessonFlow = <BioLessonActivityKind>[
    BioLessonActivityKind.lecture,
    BioLessonActivityKind.interactive,
    BioLessonActivityKind.model3d,
    BioLessonActivityKind.virtualLab,
    BioLessonActivityKind.practice,
    BioLessonActivityKind.caseStudies,
    BioLessonActivityKind.aiTutor,
    BioLessonActivityKind.exam,
    BioLessonActivityKind.reflection,
  ];

  static int get activeFlowWeightTotal => activeLessonFlow.fold<int>(
        0,
        (int sum, BioLessonActivityKind kind) => sum + kind.masteryWeight,
      );
}

class BiologyDegreeLesson {
  const BiologyDegreeLesson({required this.id, required this.title});

  final String id;
  final String title;
}

class BiologyDegreeModule {
  const BiologyDegreeModule({
    required this.id,
    required this.title,
    required this.lessons,
  });

  final String id;
  final String title;
  final List<BiologyDegreeLesson> lessons;

  int get lessonCount => lessons.length;
}

class BiologyDegreeCourse {
  const BiologyDegreeCourse({
    required this.id,
    required this.title,
    required this.modules,
    this.emoji = '🧬',
    this.tagline,
  });

  final String id;
  final String title;
  final List<BiologyDegreeModule> modules;
  final String emoji;
  final String? tagline;

  int get lessonCount =>
      modules.fold<int>(0, (int sum, BiologyDegreeModule m) => sum + m.lessonCount);

  int get moduleCount => modules.length;
}

class BiologyDegreeYear {
  const BiologyDegreeYear({
    required this.year,
    required this.title,
    required this.courses,
    this.subtitle,
  });

  final int year;
  final String title;
  final List<BiologyDegreeCourse> courses;
  final String? subtitle;
}

class BiologyLessonPath {
  const BiologyLessonPath({
    required this.year,
    required this.course,
    required this.module,
    required this.lesson,
  });

  final BiologyDegreeYear year;
  final BiologyDegreeCourse course;
  final BiologyDegreeModule module;
  final BiologyDegreeLesson lesson;

  String get breadcrumb => '${year.title} · ${course.title}';
}

class BiologyCourseRef {
  const BiologyCourseRef({required this.year, required this.course});

  final BiologyDegreeYear year;
  final BiologyDegreeCourse course;
}
