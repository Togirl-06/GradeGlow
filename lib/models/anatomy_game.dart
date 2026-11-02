import 'package:flutter/material.dart';

/// A tappable organ / region on the anatomy diagram.
class AnatomyRegion {
  const AnatomyRegion({
    required this.id,
    required this.name,
    required this.system,
    required this.color,
    required this.center,
    required this.size,
    required this.funFact,
  });

  final String id;
  final String name;
  final String system;
  final Color color;
  /// Normalized center (0–1) on the diagram canvas.
  final Offset center;
  /// Normalized width/height of hit box.
  final Size size;
  final String funFact;

  Rect hitRect(Size canvasSize) {
    final double w = size.width * canvasSize.width;
    final double h = size.height * canvasSize.height;
    final Offset c = Offset(center.dx * canvasSize.width, center.dy * canvasSize.height);
    return Rect.fromCenter(center: c, width: w, height: h);
  }
}

enum AnatomyQuestionKind { tapTarget, pickName }

/// One round in the anatomy game.
class AnatomyQuestion {
  const AnatomyQuestion({
    required this.prompt,
    required this.targetRegionId,
    required this.kind,
    this.options = const <String>[],
  });

  final String prompt;
  final String targetRegionId;
  final AnatomyQuestionKind kind;
  final List<String> options;
}

class AnatomyGameProgress {
  const AnatomyGameProgress({
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
