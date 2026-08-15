import 'package:flutter/material.dart';

import '../../models/science_diagram.dart';
import 'anatomy_asset_canvas.dart';

/// Interactive educational diagram — always rendered from SVG assets with tap hotspots.
class ScienceDiagramCanvas extends StatelessWidget {
  const ScienceDiagramCanvas({
    super.key,
    required this.diagram,
    required this.highlightRegionId,
    required this.onRegionTap,
    this.feedbackRegionId,
    this.feedbackCorrect,
    this.pulse = false,
  });

  final ScienceDiagram diagram;
  final String? highlightRegionId;
  final String? feedbackRegionId;
  final bool? feedbackCorrect;
  final bool pulse;
  final ValueChanged<ScienceDiagramRegion> onRegionTap;

  @override
  Widget build(BuildContext context) {
    return AnatomyAssetCanvas(
      diagram: diagram,
      highlightRegionId: highlightRegionId,
      feedbackRegionId: feedbackRegionId,
      feedbackCorrect: feedbackCorrect,
      pulse: pulse,
      onRegionTap: onRegionTap,
    );
  }
}
