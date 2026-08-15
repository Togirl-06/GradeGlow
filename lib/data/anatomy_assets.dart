
import '../data/diagram_asset_registry.dart';
import '../models/science_diagram.dart';

/// Difficulty tiers and helpers for asset-backed educational diagrams.
class AnatomyAssets {
  AnatomyAssets._();

  static const String organs = DiagramAssetRegistry.organs;
  static const String skeleton = DiagramAssetRegistry.skeleton;
  static const String respiratory = DiagramAssetRegistry.respiratory;
  static const String neuron = DiagramAssetRegistry.neuron;
  static const String heart = DiagramAssetRegistry.heart;
  static const String humanBody = DiagramAssetRegistry.humanBody;

  static String? pathForKind(ScienceDiagramKind kind) => switch (kind) {
        ScienceDiagramKind.humanOrgans => organs,
        ScienceDiagramKind.skeleton => skeleton,
        ScienceDiagramKind.respiratory => respiratory,
        ScienceDiagramKind.neuron => neuron,
        _ => null,
      };

  static bool isAssetBacked(ScienceDiagram diagram) => diagram.assetPath != null;

  /// Max difficulty tier included for each lab level.
  static int maxTierForDifficulty(String? difficultyLabel) {
    final String d = (difficultyLabel ?? '').toLowerCase();
    if (d.contains('advanced')) return 3;
    if (d.contains('intermediate')) return 2;
    return 2;
  }

  static List<ScienceDiagramRegion> regionsForDifficulty(
    ScienceDiagram diagram,
    String? difficultyLabel,
  ) {
    final int maxTier = maxTierForDifficulty(difficultyLabel);
    return diagram.regions.where((ScienceDiagramRegion r) => r.difficultyTier <= maxTier).toList();
  }
}
