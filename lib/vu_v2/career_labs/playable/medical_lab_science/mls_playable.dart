import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';
import 'mls_career.dart';
import 'mls_lab1_pipeline.dart';
import 'mls_lab2_panel.dart';

/// Medical Lab Science playable workplace entry.
Widget mlsPlayableScreen() {
  return PlayableWorkplaceScreen(
    career: augmentCareerWithVisualLabs(mlsCareer),
    onOpenStage: (BuildContext context, PlayableStage stage) async {
      final bool? visual = await tryRunVisualStage(context, stage);
      if (visual != null) return visual;
      if (!context.mounted) return false;
      final Widget lab;
      switch (stage.id) {
        case 'pipeline':
          lab = const MlsLab1PipelineScreen();
        case 'panel':
          lab = const MlsLab2PanelScreen();
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
