import 'package:flutter/material.dart';

import 'glow/life_skills/budget_boss_lab.dart';

/// Old Labs playables are retired except Glow game labs.
/// Career worlds use [VuCareerWorldRouter] / game engine.
Widget? playableScreenFor(String labId) {
  return playableScreens[labId]?.call();
}

/// Lab id → playable builder. Only Glow labs are wired here.
final Map<String, Widget Function()> playableScreens =
    <String, Widget Function()>{
  'personal_finance': budgetBossScreen,
};
