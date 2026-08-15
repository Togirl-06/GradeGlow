import 'package:flutter/material.dart';

import 'practice_lab.dart';

/// How students interact with a visual lab activity.
enum VisualLabActivityType {
  labeling,
  dragDrop,
  interactiveDiagram,
  imageIdentification,
  virtualLab,
  model3d,
  aiSimulation,
  practicalExam,
}

/// Immersive profession-specific environment for visual labs.
enum VisualLabEnvironment {
  biologyResearchLab,
  chemistryLab,
  physicsLab,
  nursingHospital,
  medicineTeachingHospital,
  courtroom,
  codingOffice,
  engineeringWorkshop,
  businessHeadquarters,
  classroom,
  counselingCenter,
}

/// Dimensions graded on every visual lab session.
enum VisualLabScoreCategory {
  accuracy,
  speed,
  criticalThinking,
  communication,
  clinicalDecisionMaking,
}

/// Whether the activity is fully interactive or uses AI Q&A fallback.
enum VisualLabAvailability { live, aiFallback }

class VisualLabActivity {
  const VisualLabActivity({
    required this.id,
    required this.subjectId,
    required this.sectionTitle,
    required this.title,
    required this.description,
    required this.type,
    required this.environment,
    this.diagramId,
    this.simulationStyle,
    this.availability = VisualLabAvailability.live,
    this.scoreCategories = const <VisualLabScoreCategory>[
      VisualLabScoreCategory.accuracy,
      VisualLabScoreCategory.speed,
    ],
    this.useTypeEntry = false,
  });

  final String id;
  final String subjectId;
  final String sectionTitle;
  final String title;
  final String description;
  final VisualLabActivityType type;
  final VisualLabEnvironment environment;
  final String? diagramId;
  final SimulationStyle? simulationStyle;
  final VisualLabAvailability availability;
  final List<VisualLabScoreCategory> scoreCategories;
  final bool useTypeEntry;

  bool get isLive => availability == VisualLabAvailability.live;

  String get typeLabel => switch (type) {
        VisualLabActivityType.labeling => 'Labeling',
        VisualLabActivityType.dragDrop => 'Drag & Drop',
        VisualLabActivityType.interactiveDiagram => 'Interactive Diagram',
        VisualLabActivityType.imageIdentification => 'Image ID',
        VisualLabActivityType.virtualLab => 'Virtual Lab',
        VisualLabActivityType.model3d => '3D Model',
        VisualLabActivityType.aiSimulation => 'AI Simulation',
        VisualLabActivityType.practicalExam => 'Practical Exam',
      };

  IconData get typeIcon => switch (type) {
        VisualLabActivityType.labeling => Icons.label_outline_rounded,
        VisualLabActivityType.dragDrop => Icons.drag_indicator_rounded,
        VisualLabActivityType.interactiveDiagram => Icons.account_tree_outlined,
        VisualLabActivityType.imageIdentification => Icons.image_search_rounded,
        VisualLabActivityType.virtualLab => Icons.science_outlined,
        VisualLabActivityType.model3d => Icons.view_in_ar_outlined,
        VisualLabActivityType.aiSimulation => Icons.smart_toy_outlined,
        VisualLabActivityType.practicalExam => Icons.fact_check_outlined,
      };
}

class VisualLabSection {
  const VisualLabSection({required this.title, required this.activities});

  final String title;
  final List<VisualLabActivity> activities;
}

class VisualLabEnvironmentConfig {
  const VisualLabEnvironmentConfig({
    required this.environment,
    required this.title,
    required this.tagline,
    required this.emoji,
    required this.accent,
    required this.gradient,
  });

  final VisualLabEnvironment environment;
  final String title;
  final String tagline;
  final String emoji;
  final Color accent;
  final List<Color> gradient;
}

/// Session score breakdown saved after a visual lab.
class VisualLabScoreBreakdown {
  const VisualLabScoreBreakdown({
    required this.accuracy,
    required this.speed,
    this.criticalThinking,
    this.communication,
    this.clinicalDecisionMaking,
    required this.overall,
  });

  final int accuracy;
  final int speed;
  final int? criticalThinking;
  final int? communication;
  final int? clinicalDecisionMaking;
  final int overall;

  Map<String, int> toMap() => <String, int>{
        'accuracy': accuracy,
        'speed': speed,
        'criticalThinking': ?criticalThinking,
        'communication': ?communication,
        'clinicalDecisionMaking': ?clinicalDecisionMaking,
        'overall': overall,
      };

  factory VisualLabScoreBreakdown.fromSession({
    required int correct,
    required int total,
    required Duration elapsed,
    required List<VisualLabScoreCategory> categories,
    int? bonusPoints,
  }) {
    final int accuracy = total <= 0 ? 0 : ((correct / total) * 100).round();
    final int seconds = elapsed.inSeconds.clamp(1, 9999);
    final int speed = (100 - (seconds ~/ 3).clamp(0, 60)).clamp(40, 100);
    final int base = ((accuracy * 0.7) + (speed * 0.3)).round();
    final int overall = (base + (bonusPoints ?? 0)).clamp(0, 100);

    return VisualLabScoreBreakdown(
      accuracy: accuracy,
      speed: speed,
      criticalThinking: categories.contains(VisualLabScoreCategory.criticalThinking) ? overall : null,
      communication: categories.contains(VisualLabScoreCategory.communication) ? overall : null,
      clinicalDecisionMaking:
          categories.contains(VisualLabScoreCategory.clinicalDecisionMaking) ? overall : null,
      overall: overall,
    );
  }
}
