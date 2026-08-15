import 'package:flutter/material.dart';

import '../../models/physics/physics_program.dart';
import '../../models/physics_degree.dart';
import '../../services/physics_progress_service.dart';
import '../../screens/physics/physics_routes.dart';

PhysLessonActivityKind? activityKindForMode(PhysicsLearningMode mode) {
  return switch (mode) {
    PhysicsLearningMode.lecture => PhysLessonActivityKind.lecture,
    PhysicsLearningMode.virtualLab => PhysLessonActivityKind.virtualLab,
    PhysicsLearningMode.quiz => PhysLessonActivityKind.quiz,
    PhysicsLearningMode.experimentReport => PhysLessonActivityKind.experimentReport,
    PhysicsLearningMode.formulaNotebook => PhysLessonActivityKind.formulaNotebook,
  };
}

PhysicsLearningMode modeForActivity(PhysLessonActivityKind kind) {
  return switch (kind) {
    PhysLessonActivityKind.lecture => PhysicsLearningMode.lecture,
    PhysLessonActivityKind.virtualLab => PhysicsLearningMode.virtualLab,
    PhysLessonActivityKind.quiz => PhysicsLearningMode.quiz,
    PhysLessonActivityKind.experimentReport => PhysicsLearningMode.experimentReport,
    PhysLessonActivityKind.formulaNotebook => PhysicsLearningMode.formulaNotebook,
  };
}

Future<void> launchPhysLessonActivity(
  BuildContext context,
  PhysicsLessonPath path,
  PhysLessonActivityKind kind,
  PhysicsProgressService progress,
) async {
  try {
    await PhysicsRoutes.openMode(
      context,
      track: path.track,
      course: path.course,
      topic: path.topic,
      mode: modeForActivity(kind),
    );
  } catch (e, stack) {
    debugPrint('Physics activity launch failed ($kind): $e\n$stack');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${kind.label}. Please try again.')),
      );
    }
    return;
  }

  if (!context.mounted) return;

  try {
    await progress.completeActivity(path.topic.id, kind);
  } catch (e) {
    debugPrint('Physics activity completion failed: $e');
  }
}

String physicsBadgeLabel(String badgeId) {
  return switch (badgeId) {
    'newton_master' => 'Newton Master',
    'phys_explorer' => 'Physics Explorer',
    'phys_catalog_quarter' => '25% Explored',
    'phys_catalog_half' => 'Half the Catalog',
    _ when badgeId.endsWith('_master') => 'Topic Master',
    _ => badgeId.replaceAll('_', ' '),
  };
}
