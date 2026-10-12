import 'dart:math' as math;
import 'dart:ui';

/// Shared models for GradeGlow Virtual University interactive worlds.
class VuGameVec2 {
  const VuGameVec2(this.x, this.y);

  final double x;
  final double y;

  Offset toOffset() => Offset(x, y);

  VuGameVec2 operator +(VuGameVec2 o) => VuGameVec2(x + o.x, y + o.y);
  VuGameVec2 operator -(VuGameVec2 o) => VuGameVec2(x - o.x, y - o.y);

  double distanceTo(VuGameVec2 o) {
    final double dx = x - o.x;
    final double dy = y - o.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}

class VuGameRect {
  const VuGameRect(this.x, this.y, this.w, this.h);

  final double x;
  final double y;
  final double w;
  final double h;

  bool contains(VuGameVec2 p) =>
      p.x >= x && p.x <= x + w && p.y >= y && p.y <= y + h;

  bool intersectsCircle(VuGameVec2 center, double radius) {
    final double cx = center.x.clamp(x, x + w);
    final double cy = center.y.clamp(y, y + h);
    final double dx = center.x - cx;
    final double dy = center.y - cy;
    return dx * dx + dy * dy < radius * radius;
  }
}

class VuGamePlayerAppearance {
  const VuGamePlayerAppearance({
    this.displayName = 'Student',
    this.skinTone = 0xFFE8B796,
    this.hairColor = 0xFF2C1810,
    this.outfitColor = 0xFF10B981,
    this.hairStyle = 'short',
  });

  final String displayName;
  final int skinTone;
  final int hairColor;
  final int outfitColor;
  final String hairStyle;
}

class VuGameDialogueChoice {
  const VuGameDialogueChoice({
    required this.id,
    required this.label,
    this.nextNodeId,
    this.actionId,
  });

  final String id;
  final String label;
  final String? nextNodeId;
  final String? actionId;
}

class VuGameDialogueNode {
  const VuGameDialogueNode({
    required this.id,
    required this.speaker,
    required this.text,
    this.choices = const <VuGameDialogueChoice>[],
    this.isEnd = false,
  });

  final String id;
  final String speaker;
  final String text;
  final List<VuGameDialogueChoice> choices;
  final bool isEnd;
}

class VuGameNpc {
  const VuGameNpc({
    required this.id,
    required this.name,
    required this.role,
    required this.position,
    required this.dialogueRootId,
    this.glyph = '🧑‍⚕️',
    this.interactRadius = 48,
  });

  final String id;
  final String name;
  final String role;
  final VuGameVec2 position;
  final String dialogueRootId;
  final String glyph;
  final double interactRadius;
}

class VuGameInteractable {
  const VuGameInteractable({
    required this.id,
    required this.label,
    required this.position,
    required this.actionId,
    this.glyph = '📋',
    this.interactRadius = 40,
    this.zoneId,
  });

  final String id;
  final String label;
  final VuGameVec2 position;
  final String actionId;
  final String glyph;
  final double interactRadius;
  final String? zoneId;
}

class VuGameZone {
  const VuGameZone({
    required this.id,
    required this.name,
    required this.bounds,
    this.floorColor = 0xFF1A2F3A,
  });

  final String id;
  final String name;
  final VuGameRect bounds;
  final int floorColor;
}

class VuGameWorldLayout {
  const VuGameWorldLayout({
    required this.id,
    required this.title,
    required this.zones,
    required this.walls,
    required this.npcs,
    required this.interactables,
    required this.playerSpawn,
    required this.worldSize,
  });

  final String id;
  final String title;
  final List<VuGameZone> zones;
  final List<VuGameRect> walls;
  final List<VuGameNpc> npcs;
  final List<VuGameInteractable> interactables;
  final VuGameVec2 playerSpawn;
  final VuGameVec2 worldSize;
}
