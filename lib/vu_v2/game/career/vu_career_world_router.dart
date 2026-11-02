import 'package:flutter/material.dart';

import '../ui/career_world_game_screen.dart';
import '../ui/nursing_clinical_game_screen.dart';
import 'vu_career_world_pack.dart';
import 'vu_career_worlds.dart';

/// Opens engine career worlds only — never old Labs / playable workplaces.
abstract final class VuCareerWorldRouter {
  static Future<void> open(BuildContext context, VuCareerWorldPack pack) {
    final Widget screen = pack.id == 'nursing'
        ? const NursingClinicalGameScreen()
        : CareerWorldGameScreen(pack: pack);
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  static Future<void> openById(BuildContext context, String id) async {
    final VuCareerWorldPack? pack = VuCareerWorlds.byId(id);
    if (pack == null) return;
    await open(context, pack);
  }
}
