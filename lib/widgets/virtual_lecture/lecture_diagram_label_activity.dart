import 'package:flutter/material.dart';

import '../../data/science_diagram_catalog.dart';
import '../../models/science_diagram.dart';
import '../../vu_v2/career_labs/playable/science/biology/biology_anatomy_3d_lab.dart';
import '../../vu_v2/career_labs/playable/science/shared/science_label_lab.dart';
import '../../vu_v2/career_labs/playable/science/shared/science_lab_theme.dart';
import '../science/anatomy_asset_canvas.dart';
import '../science/science_diagram_canvas.dart';

/// Drag-and-drop diagram labeling during a university lecture.
class LectureDiagramLabelActivity extends StatelessWidget {
  const LectureDiagramLabelActivity({
    super.key,
    required this.diagramId,
    this.regionIds,
    this.title = 'Label the diagram',
  });

  final String diagramId;
  final List<String>? regionIds;
  final String title;

  static Future<bool?> open(
    BuildContext context, {
    required String diagramId,
    List<String>? regionIds,
    String title = 'Label the diagram',
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => LectureDiagramLabelActivity(
          diagramId: diagramId,
          regionIds: regionIds,
          title: title,
        ),
      ),
    );
  }

  List<ScienceLabelHotspot> _hotspots(ScienceDiagram diagram) {
    final List<ScienceDiagramRegion> regions = regionIds == null
        ? diagram.regions
        : diagram.regions
            .where((ScienceDiagramRegion r) => regionIds!.contains(r.id))
            .toList();
    return regions
        .map(
          (ScienceDiagramRegion r) => ScienceLabelHotspot(
            id: r.id,
            correctLabel: r.name,
            fx: r.center.dx,
            fy: r.center.dy,
            hint: r.funFact,
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final ScienceDiagram? diagram = ScienceDiagramCatalog.diagramById(diagramId);
    if (diagram == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text('Diagram not found')),
      );
    }

    final List<ScienceLabelHotspot> hotspots = _hotspots(diagram);
    final List<String> bank = hotspots.map((ScienceLabelHotspot h) => h.correctLabel).toList()
      ..shuffle();

    final Widget diagramChild = diagram.usesAnatomyAsset
        ? AnatomyAssetCanvas(
            diagram: diagram,
            highlightRegionId: null,
            showOverlays: false,
            onRegionTap: (_) {},
          )
        : ScienceDiagramCanvas(
            diagram: diagram,
            highlightRegionId: null,
            showOverlays: false,
            onRegionTap: (_) {},
          );

    return ScienceLabelLab(
      theme: ScienceLabTheme.biology,
      hotspots: hotspots,
      mode: ScienceLabelMode.normal,
      diagramTitle: diagram.title,
      diagramId: diagramId,
      wordBank: bank,
      popOnComplete: true,
      diagramChild: diagramChild,
      onComplete: (_) => Navigator.of(context).pop(true),
    );
  }
}

/// Opens the rotatable 3D-style anatomy laboratory from lecture flow.
class LectureAnatomy3dActivity {
  static Future<bool?> open(
    BuildContext context, {
    String diagramId = 'skeleton',
    List<String>? focusRegionIds,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BiologyAnatomy3dLab(
          diagramId: diagramId,
          focusRegionIds: focusRegionIds,
        ),
      ),
    );
  }
}
