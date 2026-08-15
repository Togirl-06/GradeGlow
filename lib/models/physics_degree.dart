// Virtual University Physics — lesson activity models for degree UI.

import 'physics/physics_program.dart';

enum PhysLessonActivityKind {
  lecture('AI Professor', '🎓', 'Textbook chapter · voice · derivations'),
  virtualLab('3D Simulation & Lab', '🔬', 'Run experiments · discover laws'),
  quiz('Quiz', '🧪', '15-question topic review'),
  experimentReport('Experiment Report', '📋', 'University lab write-up · AI grading'),
  formulaNotebook('Formula Notebook', '📐', 'Every governing equation for this topic');

  const PhysLessonActivityKind(this.label, this.emoji, this.subtitle);

  final String label;
  final String emoji;
  final String subtitle;

  int get masteryWeight => switch (this) {
        PhysLessonActivityKind.lecture => 25,
        PhysLessonActivityKind.virtualLab => 25,
        PhysLessonActivityKind.quiz => 25,
        PhysLessonActivityKind.experimentReport => 15,
        PhysLessonActivityKind.formulaNotebook => 10,
      };

  static const List<PhysLessonActivityKind> activeLessonFlow = <PhysLessonActivityKind>[
    PhysLessonActivityKind.lecture,
    PhysLessonActivityKind.virtualLab,
    PhysLessonActivityKind.quiz,
    PhysLessonActivityKind.experimentReport,
    PhysLessonActivityKind.formulaNotebook,
  ];

  static int get activeFlowWeightTotal => activeLessonFlow.fold<int>(
        0,
        (int sum, PhysLessonActivityKind kind) => sum + kind.masteryWeight,
      );
}

class PhysicsLessonPath {
  const PhysicsLessonPath({
    required this.track,
    required this.course,
    required this.topic,
  });

  final PhysicsTrack track;
  final PhysicsCourse course;
  final PhysicsTopic topic;

  String get breadcrumb => '${track.level.label} · ${course.title}';
}

class PhysicsCourseRef {
  const PhysicsCourseRef({required this.track, required this.course});

  final PhysicsTrack track;
  final PhysicsCourse course;
}
