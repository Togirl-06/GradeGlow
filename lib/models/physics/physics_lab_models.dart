import 'package:flutter/material.dart';

/// Type of interactive 3D-style simulation for a topic.
enum PhysicsSimulationKind {
  motionTracking,
  acceleration,
  forceThrust,
  energyCoaster,
  projectile,
  gravityPlanet,
  collision,
  circuit,
  optics,
  rocket,
  wave,
  generic,
}

extension PhysicsSimulationKindX on PhysicsSimulationKind {
  String get label => switch (this) {
        PhysicsSimulationKind.motionTracking => 'Motion Tracking',
        PhysicsSimulationKind.acceleration => 'Acceleration Test',
        PhysicsSimulationKind.forceThrust => 'Force & Thrust',
        PhysicsSimulationKind.energyCoaster => 'Energy Coaster',
        PhysicsSimulationKind.projectile => 'Projectile Motion',
        PhysicsSimulationKind.gravityPlanet => 'Gravity & Orbits',
        PhysicsSimulationKind.collision => 'Collision Lab',
        PhysicsSimulationKind.circuit => 'Circuit Builder',
        PhysicsSimulationKind.optics => 'Optics Bench',
        PhysicsSimulationKind.rocket => 'Aerospace Simulator',
        PhysicsSimulationKind.wave => 'Wave Lab',
        PhysicsSimulationKind.generic => 'Physics Explorer',
      };
}

/// University lab room the student can enter.
class PhysicsLabRoom {
  const PhysicsLabRoom({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.equipment,
    required this.experimentTitle,
    required this.experimentSteps,
    required this.icon,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<String> equipment;
  final String experimentTitle;
  final List<String> experimentSteps;
  final IconData icon;
}

/// Challenge mission inside a simulation.
class PhysicsLabMission {
  const PhysicsLabMission({
    required this.prompt,
    required this.targetDescription,
    required this.hint,
  });

  final String prompt;
  final String targetDescription;
  final String hint;
}

/// Mission evaluation result.
class PhysicsMissionResult {
  const PhysicsMissionResult({
    required this.passed,
    required this.feedback,
    required this.scorePercent,
  });

  final bool passed;
  final String feedback;
  final int scorePercent;
}

/// One point for height/velocity graphs.
class PhysicsGraphPoint {
  const PhysicsGraphPoint({required this.t, required this.y, this.vy});

  final double t;
  final double y;
  final double? vy;
}

/// Data series for mini charts.
class PhysicsGraphSeries {
  const PhysicsGraphSeries({
    required this.label,
    required this.xLabel,
    required this.yLabel,
    required this.points,
  });

  final String label;
  final String xLabel;
  final String yLabel;
  final List<PhysicsGraphPoint> points;
}

/// Difficulty tier for virtual experiments.
enum PhysicsLabDifficulty { beginner, intermediate, advanced }

extension PhysicsLabDifficultyX on PhysicsLabDifficulty {
  String get label => switch (this) {
        PhysicsLabDifficulty.beginner => 'Beginner',
        PhysicsLabDifficulty.intermediate => 'Intermediate',
        PhysicsLabDifficulty.advanced => 'Advanced',
      };
}

/// Pre-filled experiment report sections for one physics topic.
class PhysicsExperimentReportTemplate {
  const PhysicsExperimentReportTemplate({
    required this.title,
    required this.objective,
    required this.hypothesis,
    required this.procedureSteps,
    required this.dataTable,
    required this.calculationHint,
    required this.conclusionHint,
    this.aiInsight = '',
  });

  final String title;
  final String objective;
  final String hypothesis;
  final List<String> procedureSteps;
  final String dataTable;
  final String calculationHint;
  final String conclusionHint;
  final String aiInsight;
}
