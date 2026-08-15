import 'package:flutter/material.dart';

import '../../data/anatomy_game_data.dart';
import '../../models/anatomy_game.dart';
import '../../models/science_diagram.dart';
import '../science/anatomy_asset_canvas.dart';

/// Interactive organ diagram using the bundled anatomy SVG (no placeholder shapes).
class AnatomyBodyDiagram extends StatelessWidget {
  const AnatomyBodyDiagram({
    super.key,
    required this.highlightRegionId,
    required this.onRegionTap,
    this.feedbackRegionId,
    this.feedbackCorrect,
    this.pulse = false,
  });

  final String? highlightRegionId;
  final String? feedbackRegionId;
  final bool? feedbackCorrect;
  final bool pulse;
  final ValueChanged<AnatomyRegion> onRegionTap;

  @override
  Widget build(BuildContext context) {
    return AnatomyAssetCanvas(
      diagram: AnatomyGameData.diagram,
      highlightRegionId: highlightRegionId,
      feedbackRegionId: feedbackRegionId,
      feedbackCorrect: feedbackCorrect,
      pulse: pulse,
      onRegionTap: (ScienceDiagramRegion region) {
        final AnatomyRegion? anatomy = AnatomyGameData.regionById(region.id);
        if (anatomy != null) onRegionTap(anatomy);
      },
    );
  }
}
