import 'package:flutter/material.dart';

import 'visual_assemble_lab_screen.dart';
import 'visual_graph_lab_screen.dart';
import 'visual_interpret_lab_screen.dart';
import 'visual_label_lab_screen.dart';
import 'visual_lab_models.dart';
import 'visual_measure_lab_screen.dart';
import 'visual_observe_lab_screen.dart';
import 'visual_path_trace_screen.dart';
import 'visual_prioritize_lab_screen.dart';

/// Maps a non-practical [VisualLabSpec] to its interactive screen.
Widget buildVisualLabScreen(VisualLabSpec spec) {
  switch (spec.kind) {
    case VisualLabKind.identify:
    case VisualLabKind.label:
    case VisualLabKind.imagingAnnotate:
      return VisualLabelLabScreen(spec: spec);
    case VisualLabKind.assemble:
      return VisualAssembleLabScreen(spec: spec);
    case VisualLabKind.measure:
      return VisualMeasureLabScreen(spec: spec);
    case VisualLabKind.observe:
      return VisualObserveLabScreen(spec: spec);
    case VisualLabKind.graph:
      return VisualGraphLabScreen(spec: spec);
    case VisualLabKind.interpret:
      return VisualInterpretLabScreen(spec: spec);
    case VisualLabKind.prioritize:
      return VisualPrioritizeLabScreen(spec: spec);
    case VisualLabKind.pathTrace:
      return VisualPathTraceScreen(spec: spec);
  }
}
