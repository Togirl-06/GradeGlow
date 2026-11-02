import 'package:flutter/material.dart';

/// A tappable labeled region on a science diagram.
class ScienceDiagramRegion {
  const ScienceDiagramRegion({
    required this.id,
    required this.name,
    required this.color,
    required this.center,
    required this.size,
    required this.funFact,
    this.shape = ScienceRegionShape.ellipse,
    this.difficultyTier = 1,
  });

  final String id;
  final String name;
  final Color color;
  final Offset center;
  final Size size;
  final String funFact;
  final ScienceRegionShape shape;
  /// 1 = Beginner, 2 = Intermediate, 3 = Advanced
  final int difficultyTier;

  Rect hitRect(Size canvasSize) {
    final double w = size.width * canvasSize.width;
    final double h = size.height * canvasSize.height;
    final Offset c = Offset(center.dx * canvasSize.width, center.dy * canvasSize.height);
    return Rect.fromCenter(center: c, width: w, height: h);
  }
}

enum ScienceRegionShape { ellipse, rect, ring }

enum ScienceDiagramKind {
  animalCell,
  plantCell,
  atom,
  molecule,
  humanOrgans,
  respiratory,
  neuron,
  skeleton,
  dcCircuit,
  wave,
  force,
  dna,
  chromosome,
}

enum ScienceDiagramQuestionKind { tapTarget, pickName, typeName }

class ScienceDiagram {
  const ScienceDiagram({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.regions,
    this.aspectRatio = 1.2,
    this.assetPath,
  });

  final String id;
  final String title;
  final String subtitle;
  final ScienceDiagramKind kind;
  final List<ScienceDiagramRegion> regions;
  final double aspectRatio;
  /// Bundled SVG/PNG path; all science diagrams use asset-backed illustrations.
  final String? assetPath;

  bool get usesAnatomyAsset => assetPath != null;
}

class ScienceDiagramQuestion {
  const ScienceDiagramQuestion({
    required this.prompt,
    required this.targetRegionId,
    required this.kind,
    this.options = const <String>[],
  });

  final String prompt;
  final String targetRegionId;
  final ScienceDiagramQuestionKind kind;
  final List<String> options;
}

class ScienceDiagramProgress {
  const ScienceDiagramProgress({
    required this.round,
    required this.totalRounds,
    required this.score,
    required this.streak,
    required this.lives,
    required this.xp,
  });

  final int round;
  final int totalRounds;
  final int score;
  final int streak;
  final int lives;
  final int xp;

  double get progress => totalRounds <= 0 ? 0 : round / totalRounds;
  int get level => (xp ~/ 120) + 1;
}
