import 'package:flutter/material.dart';

import '../shared/science_asset_catalog.dart';
import '../shared/science_interactive_image.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';

/// Animal cell — interactive diagram (VIEW / LABEL / ANNOTATE / MEASURE).
class BiologyCellDiagramLab extends StatelessWidget {
  const BiologyCellDiagramLab({
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
      asset: ScienceAssetCatalog.animalCell,
      title: 'Animal Cell',
      crumbs: const <String>['Biology Lab', 'Cell Lab', 'Animal Cell'],
      notebook: nb,
      embedded: embedded,
      onComplete: onComplete,
      explainText:
          'Label organelles from the word bank. Annotate notes on the image. '
          'No reveal — check labels and retry.',
      wordBank: const <String>[
        'nucleus',
        'membrane',
        'cytoplasm',
        'mitochondria',
        'ribosome',
        'lysosome',
      ],
      hotspots: const <ScienceImageHotspot>[
        ScienceImageHotspot(id: '1', label: 'nucleus', fx: 0.48, fy: 0.42),
        ScienceImageHotspot(id: '2', label: 'membrane', fx: 0.88, fy: 0.55),
        ScienceImageHotspot(id: '3', label: 'cytoplasm', fx: 0.62, fy: 0.68),
        ScienceImageHotspot(id: '4', label: 'mitochondria', fx: 0.28, fy: 0.58),
        ScienceImageHotspot(id: '5', label: 'ribosome', fx: 0.35, fy: 0.32),
      ],
    );
  }
}
