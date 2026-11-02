import 'package:flutter/material.dart';

import '../../../game/ui/nursing_clinical_game_screen.dart';
import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';
import 'nursing_career.dart';
import 'nursing_lab1_shift.dart';
import 'nursing_lab2_assessment.dart';

/// Riverside Med — walkable clinical floor (primary) + classic workplace hub.
Widget nursingPlayableScreen() {
  return const NursingClinicalGameScreen();
}

/// Legacy immersive hub (floor map + staged labs) — still used from in-game menu if needed.
Widget nursingPlayableWorkplaceHub() {
  return PlayableWorkplaceScreen(
    career: augmentCareerWithVisualLabs(nursingCareer),
    onOpenStage: (BuildContext context, PlayableStage stage) async {
      final bool? visual = await tryRunVisualStage(context, stage);
      if (visual != null) return visual;
      if (!context.mounted) return false;
      final Widget lab;
      switch (stage.id) {
        case 'shift':
          lab = const NursingLab1ShiftScreen();
        case 'assessment':
          lab = const NursingLab2AssessmentScreen();
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
