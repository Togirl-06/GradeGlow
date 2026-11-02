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
    this.highlightRegionIds = const <String>{},
    this.enabledRegionIds,
    this.showOverlays = true,
    this.dimNonHighlighted = false,
    this.feedbackRegionId,
    this.feedbackCorrect,
    this.pulse = false,
    this.showSpokenLabels = false,
    this.autoFocus = false,
    this.spokenLabel,
  });

  final ScienceDiagram diagram;
  final String? highlightRegionId;
  final Set<String> highlightRegionIds;
  final Set<String>? enabledRegionIds;
  final bool showOverlays;
  final bool dimNonHighlighted;
  final String? feedbackRegionId;
  final bool? feedbackCorrect;
  final bool pulse;
  final bool showSpokenLabels;
  final bool autoFocus;
  final String? spokenLabel;
  final ValueChanged<ScienceDiagramRegion> onRegionTap;

  @override
  Widget build(BuildContext context) {
    return AnatomyAssetCanvas(
      diagram: diagram,
      highlightRegionId: highlightRegionId,
      highlightRegionIds: highlightRegionIds,
      enabledRegionIds: enabledRegionIds,
      showOverlays: showOverlays,
      dimNonHighlighted: dimNonHighlighted,
      feedbackRegionId: feedbackRegionId,
      feedbackCorrect: feedbackCorrect,
      pulse: pulse,
      showSpokenLabels: showSpokenLabels,
      autoFocus: autoFocus,
      spokenLabel: spokenLabel,
      onRegionTap: onRegionTap,
    );
  }
}
