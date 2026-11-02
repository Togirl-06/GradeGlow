import 'package:flutter/material.dart';

import '../screens/law/law_program_screen.dart' deferred as law;
import '../screens/physics/physics_program_screen.dart' deferred as physics;

/// Opens heavy faculty homes lazily so Practice Labs stays lightweight.
class FacultyEntryRoutes {
  FacultyEntryRoutes._();

  static Future<void> _loadWithSpinner(BuildContext context, Future<void> Function() load) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await load();
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  static Future<void> openLaw(BuildContext context) async {
    await _loadWithSpinner(context, law.loadLibrary);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => law.LawProgramScreen()),
    );
  }

  static Future<void> openPhysics(BuildContext context) async {
    await _loadWithSpinner(context, physics.loadLibrary);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => physics.PhysicsProgramScreen()),
    );
  }
}
