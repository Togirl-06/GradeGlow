import 'package:flutter/material.dart';

/// The six learning modes every engineering course follows.
enum EngineeringLearningMode {
  lecture,
  concepts,
  virtualLab,
  simulator,
  designReview,
  capstone,
}

extension EngineeringLearningModeX on EngineeringLearningMode {
  String get label => switch (this) {
        EngineeringLearningMode.lecture => 'AI Professor',
        EngineeringLearningMode.concepts => 'Interactive Concepts',
        EngineeringLearningMode.virtualLab => 'Virtual Lab',
        EngineeringLearningMode.simulator => 'Engineering Simulator',
        EngineeringLearningMode.designReview => 'AI Design Review',
        EngineeringLearningMode.capstone => 'Capstone Project',
      };

  String get subtitle => switch (this) {
        EngineeringLearningMode.lecture => 'Full digital textbook chapter with voice audio',
        EngineeringLearningMode.concepts => 'Manipulate variables and watch systems respond',
        EngineeringLearningMode.virtualLab => 'Run experiments and learn from failure',
        EngineeringLearningMode.simulator => 'Design under real constraints, then test',
        EngineeringLearningMode.designReview => 'Senior-engineer critique of your design',
        EngineeringLearningMode.capstone => 'Build, document, and present like industry',
      };

  IconData get icon => switch (this) {
        EngineeringLearningMode.lecture => Icons.school_outlined,
        EngineeringLearningMode.concepts => Icons.tune_rounded,
        EngineeringLearningMode.virtualLab => Icons.science_outlined,
        EngineeringLearningMode.simulator => Icons.precision_manufacturing_outlined,
        EngineeringLearningMode.designReview => Icons.rate_review_outlined,
        EngineeringLearningMode.capstone => Icons.emoji_events_outlined,
      };

  String get philosophyStep => switch (this) {
        EngineeringLearningMode.lecture => 'Learn',
        EngineeringLearningMode.concepts => 'Understand',
        EngineeringLearningMode.virtualLab => 'Simulate',
        EngineeringLearningMode.simulator => 'Design → Build → Test',
        EngineeringLearningMode.designReview => 'Fail → Improve',
        EngineeringLearningMode.capstone => 'Present',
      };
}

class EngineeringMajor {
  const EngineeringMajor({
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.courses,
    required this.gameplay,
    this.emoji = '',
  });

  final String id;
  final String name;
  final String tagline;
  final IconData icon;
  final String emoji;
  final List<EngineeringCourse> courses;
  final List<String> gameplay;
}

class EngineeringCourse {
  const EngineeringCourse({
    required this.id,
    required this.title,
    required this.blurb,
    required this.topics,
    required this.labTitle,
    required this.labDescription,
    required this.simulatorTitle,
    required this.simulatorBrief,
    required this.capstoneTitle,
    required this.capstoneStages,
    this.conceptControls = const <EngineeringControlSpec>[],
  });

  final String id;
  final String title;
  final String blurb;
  final List<String> topics;
  final String labTitle;
  final String labDescription;
  final String simulatorTitle;
  final String simulatorBrief;
  final String capstoneTitle;
  final List<String> capstoneStages;
  final List<EngineeringControlSpec> conceptControls;
}

/// Slider / dial used in interactive concept and lab screens.
class EngineeringControlSpec {
  const EngineeringControlSpec({
    required this.id,
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    required this.initial,
    this.step = 1,
  });

  final String id;
  final String label;
  final String unit;
  final double min;
  final double max;
  final double initial;
  final double step;
}
