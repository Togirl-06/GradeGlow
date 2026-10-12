import 'package:flutter/material.dart';

/// Old Labs playables are retired. Use [VuCareerWorldRouter] / game engine.
Widget? playableScreenFor(String labId) => null;

/// Intentionally empty — do not wire old workplaces back in.
final Map<String, Widget Function()> playableScreens =
    <String, Widget Function()>{};
