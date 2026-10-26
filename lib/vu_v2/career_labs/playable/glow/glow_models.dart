import 'package:flutter/material.dart';

/// The kind of mechanic a level uses. Used for the catalog and for picking a
/// consistent look in the level map.
enum GlowMechanic {
  simulator,
  sortPuzzle,
  spotPuzzle,
  orderPuzzle,
  matchPuzzle,
  boss,
}

/// What a level reports back when the player finishes it.
class GlowLevelResult {
  const GlowLevelResult({
    required this.stars,
    required this.score,
    this.note = '',
  });

  /// 0 = failed, 1-3 = cleared.
  final int stars;

  /// 0-100, shown on the result card.
  final int score;

  /// One or two sentences of feedback ("what you did, what it cost").
  final String note;

  bool get passed => stars >= 1;
}

typedef GlowFinish = void Function(GlowLevelResult result);

/// Builds the playable body of a level. Call `finish` exactly once when done.
typedef GlowLevelBuilder = Widget Function(
  BuildContext context,
  GlowFinish finish,
);

class GlowLevel {
  const GlowLevel({
    required this.id,
    required this.title,
    required this.tagline,
    required this.emoji,
    required this.mechanic,
    required this.xp,
    required this.builder,
  });

  final String id;
  final String title;
  final String tagline;
  final String emoji;
  final GlowMechanic mechanic;

  /// XP for earning all 3 stars. Fewer stars pay out proportionally.
  final int xp;
  final GlowLevelBuilder builder;

  bool get isBoss => mechanic == GlowMechanic.boss;
}

/// One game lab: an ordered list of levels plus its identity.
class GlowLab {
  const GlowLab({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accent,
    required this.rankTitles,
    required this.levels,
  });

  /// Stable id. Also used as the SharedPreferences key prefix.
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color accent;

  /// One title per 100 XP. The last title is the max rank.
  final List<String> rankTitles;
  final List<GlowLevel> levels;
}
