import 'package:flutter/material.dart';

/// Non-web builds: no 3D iframe; the game keeps the isometric painter.
bool get world3dSupported => false;

Widget buildWorld3dView({required void Function(Map<String, dynamic> event) onEvent}) => const SizedBox.shrink();

void world3dSend(Map<String, Object?> message) {}

void world3dDetach(void Function(Map<String, dynamic> event) onEvent) {}
