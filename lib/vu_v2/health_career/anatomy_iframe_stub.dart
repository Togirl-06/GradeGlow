import 'package:flutter/material.dart';

/// Non-web: no iframe. Caller uses Flutter fallback viewer.
bool get anatomyThreeJsSupported => false;

Widget buildAnatomyThreeJsView({
  required String viewType,
  required ValueChanged<Map<String, String>> onSelect,
}) {
  return const SizedBox.shrink();
}
