import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';
import 'medicine_career.dart';
import 'medicine_lab1_interview.dart';
import 'medicine_lab2_differential.dart';

/// Medicine diagnostic ward playable entry.
Widget medicinePlayableScreen() {
  return PlayableWorkplaceScreen(
    career: augmentCareerWithVisualLabs(medicineCareer),
    onOpenStage: (BuildContext context, PlayableStage stage) async {
      final bool? visual = await tryRunVisualStage(context, stage);
      if (visual != null) return visual;
      if (!context.mounted) return false;
      final Widget lab;
      switch (stage.id) {
        case 'interview':
          lab = const MedicineLab1InterviewScreen();
        case 'differential':
          lab = const MedicineLab2DifferentialScreen();
        default:
          return false;
      }
      final bool? ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(builder: (_) => lab),
      );
      return ok == true;
    },
  );
}
