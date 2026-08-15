import 'package:flutter/material.dart';

import '../shared/science_asset_catalog.dart';
import '../shared/science_interactive_image.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Heart anatomy on a real anatomical plate — VIEW / LABEL / ANNOTATE / MEASURE.
class BiologyHeartLab extends StatelessWidget {
  const BiologyHeartLab({
    super.key,
    this.embedded = false,
    this.onComplete,
    this.notebook,
  });

  final bool embedded;
  final VoidCallback? onComplete;
  final ScienceNotebookStore? notebook;

  static const ScienceLabTheme t = ScienceLabTheme.biology;

  @override
  Widget build(BuildContext context) {
    final ScienceNotebookStore nb = notebook ?? ScienceNotebookStore('biology');
    return ScienceInteractiveImageLab(
      theme: t,
      asset: ScienceAssetCatalog.heartPhoto,
      title: 'Human Heart',
      crumbs: const <String>['Biology Lab', 'Anatomy', 'Human Heart'],
      notebook: nb,
      embedded: embedded,
      onComplete: onComplete,
      explainText:
          'Use PHOTO for real anatomy. Switch to DIAGRAM for clearer markers. '
          'LABEL chambers and vessels. ANNOTATE notes on the image.',
      wordBank: const <String>[
        'Aorta',
        'Left atrium',
        'Right atrium',
        'Left ventricle',
        'Right ventricle',
        'Pulmonary artery',
      ],
      hotspots: const <ScienceImageHotspot>[
        ScienceImageHotspot(id: '1', label: 'Aorta', fx: 0.50, fy: 0.18),
        ScienceImageHotspot(id: '2', label: 'Pulmonary artery', fx: 0.38, fy: 0.28),
        ScienceImageHotspot(id: '3', label: 'Left atrium', fx: 0.62, fy: 0.40),
        ScienceImageHotspot(id: '4', label: 'Right atrium', fx: 0.34, fy: 0.45),
        ScienceImageHotspot(id: '5', label: 'Left ventricle', fx: 0.60, fy: 0.62),
        ScienceImageHotspot(id: '6', label: 'Right ventricle', fx: 0.40, fy: 0.68),
      ],
    );
  }
}
