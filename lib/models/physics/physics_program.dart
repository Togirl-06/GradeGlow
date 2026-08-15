import 'package:flutter/material.dart';

/// Academic progression — not calendar years.
enum PhysicsLevel {
  foundations,
  undergraduate,
  graduate,
  research,
}

extension PhysicsLevelX on PhysicsLevel {
  String get label => switch (this) {
        PhysicsLevel.foundations => 'Foundations',
        PhysicsLevel.undergraduate => 'Undergraduate',
        PhysicsLevel.graduate => 'Graduate',
        PhysicsLevel.research => 'Research',
      };

  String get subtitle => switch (this) {
        PhysicsLevel.foundations =>
          'Scientific method, math tools, and how physicists think',
        PhysicsLevel.undergraduate =>
          'Classical mechanics through modern physics — the core universe',
        PhysicsLevel.graduate =>
          'Advanced theory, methods, and research-ready depth',
        PhysicsLevel.research =>
          'Specialization tracks from astrophysics to quantum information',
      };

  IconData get icon => switch (this) {
        PhysicsLevel.foundations => Icons.lightbulb_outline_rounded,
        PhysicsLevel.undergraduate => Icons.school_outlined,
        PhysicsLevel.graduate => Icons.biotech_outlined,
        PhysicsLevel.research => Icons.rocket_launch_outlined,
      };

  int get order => switch (this) {
        PhysicsLevel.foundations => 0,
        PhysicsLevel.undergraduate => 1,
        PhysicsLevel.graduate => 2,
        PhysicsLevel.research => 3,
      };
}

/// Core learning modes shown on each physics topic.
enum PhysicsLearningMode {
  lecture,
  virtualLab,
  quiz,
  experimentReport,
  formulaNotebook,
}

extension PhysicsLearningModeX on PhysicsLearningMode {
  String get label => switch (this) {
        PhysicsLearningMode.lecture => 'AI Professor',
        PhysicsLearningMode.virtualLab => '3D Simulation & Lab',
        PhysicsLearningMode.quiz => 'Quiz',
        PhysicsLearningMode.experimentReport => 'Experiment Report',
        PhysicsLearningMode.formulaNotebook => 'Formula Notebook',
      };

  String get subtitle => switch (this) {
        PhysicsLearningMode.lecture =>
          'Full digital textbook chapter — definitions, derivations, voice audio',
        PhysicsLearningMode.virtualLab => 'Run experiments, discover laws — PhET meets NASA',
        PhysicsLearningMode.quiz => 'Multiple-choice review — 15 questions on this topic',
        PhysicsLearningMode.experimentReport => 'University lab report with AI professor grading',
        PhysicsLearningMode.formulaNotebook => 'Every governing equation written for this topic',
      };

  IconData get icon => switch (this) {
        PhysicsLearningMode.lecture => Icons.school_outlined,
        PhysicsLearningMode.virtualLab => Icons.view_in_ar_outlined,
        PhysicsLearningMode.quiz => Icons.quiz_outlined,
        PhysicsLearningMode.experimentReport => Icons.assignment_outlined,
        PhysicsLearningMode.formulaNotebook => Icons.functions_outlined,
      };
}

class PhysicsTrack {
  const PhysicsTrack({
    required this.level,
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.courses,
    this.emoji = '',
  });

  final PhysicsLevel level;
  final String id;
  final String name;
  final String tagline;
  final IconData icon;
  final String emoji;
  final List<PhysicsCourse> courses;
}

class PhysicsCourse {
  const PhysicsCourse({
    required this.id,
    required this.title,
    required this.blurb,
    required this.topics,
    this.labTitle = 'Virtual Laboratory',
    this.simulatorTitle = '3D Physics Simulator',
    this.quizTitle = 'Topic Quiz',
  });

  final String id;
  final String title;
  final String blurb;
  final List<PhysicsTopic> topics;
  final String labTitle;
  final String simulatorTitle;
  final String quizTitle;
}

class PhysicsTopic {
  const PhysicsTopic({
    required this.id,
    required this.title,
    required this.hook,
    required this.summary,
    required this.keyConcepts,
    this.formulas = const <String>[],
    this.realWorld = '',
    this.career = '',
  });

  final String id;
  final String title;
  final String hook;
  final String summary;
  final List<String> keyConcepts;
  final List<String> formulas;
  final String realWorld;
  final String career;
}

extension PhysicsTopicLabX on PhysicsTopic {
  String get simulatorTitle => '$title 3D Simulator';
  String get labTitle => '$title Virtual Lab';
}
