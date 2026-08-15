import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';
import 'pharmacy_career.dart';
import 'pharmacy_lab1_verify.dart';
import 'pharmacy_lab2_counsel.dart';

/// Pharmacy dispensary playable workplace entry.
Widget pharmacyPlayableScreen() {
  return PlayableWorkplaceScreen(
    career: augmentCareerWithVisualLabs(pharmacyCareer),
    onOpenStage: (BuildContext context, PlayableStage stage) async {
      final bool? visual = await tryRunVisualStage(context, stage);
      if (visual != null) return visual;
      if (!context.mounted) return false;
      final Widget lab;
      switch (stage.id) {
        case 'verify':
          lab = const PharmacyLab1VerifyScreen();
        case 'counsel':
          lab = const PharmacyLab2CounselScreen();
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
