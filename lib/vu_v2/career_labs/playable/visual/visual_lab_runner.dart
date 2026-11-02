import 'package:flutter/material.dart';

import 'visual_lab_catalog.dart';
import 'visual_lab_dispatch.dart';
import 'visual_lab_models.dart';
import 'visual_practical_exam_screen.dart';

/// Routes a [VisualLabSpec] to the interactive screen for its kind.
Future<bool> runVisualLab(BuildContext context, VisualLabSpec spec) async {
  final Widget screen = spec.isPracticalExam
      ? VisualPracticalExamScreen(spec: spec)
      : buildVisualLabScreen(spec);
  final bool? result = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(builder: (_) => screen),
  );
  return result ?? false;
}

/// Lookup by id from the catalog, then run.
Future<bool> runVisualLabById(BuildContext context, String labId) async {
  final VisualLabSpec? spec = VisualLabCatalog.byId(labId);
  if (spec == null) return false;
  return runVisualLab(context, spec);
}
