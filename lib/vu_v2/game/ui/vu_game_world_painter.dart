import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/isometric_camera.dart';
import '../models/vu_game_models.dart';

/// Stylized life-sim world painter (GradeGlow original — not Sims assets).
class VuGameWorldPainter extends CustomPainter {
  VuGameWorldPainter({
    required this.layout,
    required this.transform,
    required this.player,
    required this.appearance,
    this.highlightInteractableId,
    this.moveTarget,
    this.bubbleText,
    this.npcBubbleId,
    this.timeOfDay = 0.35,
  });

  final VuGameWorldLayout layout;
  final VuGameViewTransform transform;
  final VuGameVec2 player;
  final VuGamePlayerAppearance appearance;
  final String? highlightInteractableId;
  final VuGameVec2? moveTarget;
  final String? bubbleText;
  final String? npcBubbleId;
  final double timeOfDay;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawGround(canvas);

    // Depth sort: farther (smaller x+y) first.
    final List<_DrawItem> items = <_DrawItem>[];
    for (final VuGameZone zone in layout.zones) {
      items.add(_DrawItem(zone.bounds.x + zone.bounds.y, () => _drawZone(canvas, zone)));
    }
    for (final VuGameRect wall in layout.walls) {
      items.add(_DrawItem(wall.x + wall.y + wall.w + wall.h, () => _drawWall(canvas, wall)));
    }
    for (final VuGameInteractable item in layout.interactables) {
      items.add(
        _DrawItem(
          item.position.x + item.position.y,
          () => _drawInteractable(canvas, item, item.id == highlightInteractableId),
        ),
      );
    }
    for (final VuGameNpc npc in layout.npcs) {
      items.add(
        _DrawItem(
          npc.position.x + npc.position.y,
          () => _drawNpc(canvas, npc, npc.id == npcBubbleId),
        ),
      );
    }
    items.add(
      _DrawItem(player.x + player.y, () => _drawPlayer(canvas, player)),
    );
    items.sort((_DrawItem a, _DrawItem b) => a.depth.compareTo(b.depth));
    for (final _DrawItem i in items) {
      i.paint();
    }

    if (moveTarget != null) {
      _drawWalkRing(canvas, moveTarget!);
    }
  }

  void _drawSky(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          const <Color>[
            Color(0xFF7EC8F0),
            Color(0xFFB8E0F5),
            Color(0xFFE8F6D8),
            Color(0xFFD4E8C2),
          ],
          const <double>[0, 0.35, 0.72, 1],
        ),
    );
    // Soft sun.
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.12),
      36,
      Paint()..color = const Color(0xFFFFF2A8).withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.12),
      52,
      Paint()..color = const Color(0xFFFFF2A8).withValues(alpha: 0.25),
    );
  }

  void _drawGround(Canvas canvas) {
    final List<Offset> pts = transform.rectToIso(
      VuGameRect(0, 0, layout.worldSize.x, layout.worldSize.y),
    );
    final Path grass = Path()..addPolygon(pts, true);
    canvas.drawPath(
      grass,
      Paint()..color = const Color(0xFF7CB342).withValues(alpha: 0.55),
    );
    // Path tiles hint.
    for (int i = 0; i < 8; i++) {
      final double t = i / 7;
      final VuGameVec2 a = VuGameVec2(
        layout.worldSize.x * 0.08 + layout.worldSize.x * 0.7 * t,
        layout.worldSize.y * 0.75,
      );
      _drawIsoTile(
        canvas,
        a,
        28,
        const Color(0xFFC4A574).withValues(alpha: 0.35),
      );
    }
  }

  void _drawZone(Canvas canvas, VuGameZone zone) {
    final List<Offset> pts = transform.rectToIso(zone.bounds);
    final Path path = Path()..addPolygon(pts, true);
    final Color base = Color(zone.floorColor);
    // Lifted floor: brighten for life-sim look.
    final Color floor = Color.lerp(base, const Color(0xFFE8D5B5), 0.45)!;
    canvas.drawPath(path, Paint()..color = floor);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    // Soft side face for depth.
    if (pts.length >= 4) {
      final Path side = Path()
        ..moveTo(pts[2].dx, pts[2].dy)
        ..lineTo(pts[3].dx, pts[3].dy)
        ..lineTo(pts[3].dx, pts[3].dy + 10)
        ..lineTo(pts[2].dx, pts[2].dy + 10)
        ..close();
      canvas.drawPath(
        side,
        Paint()..color = Color.lerp(floor, Colors.black, 0.25)!.withValues(alpha: 0.55),
      );
    }
    final Offset labelAt = transform.worldToScreen(
      VuGameVec2(zone.bounds.x + 12, zone.bounds.y + 12),
    );
    final TextPainter label = TextPainter(
      text: TextSpan(
        text: zone.name,
        style: TextStyle(
          color: const Color(0xFF1A2E1A).withValues(alpha: 0.55),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, labelAt);
  }

  void _drawWall(Canvas canvas, VuGameRect wall) {
    final List<Offset> top = transform.rectToIso(wall);
    final Path roof = Path()..addPolygon(top, true);
    canvas.drawPath(roof, Paint()..color = const Color(0xFF8B7355));
    // Vertical extrusion.
    for (int i = 0; i < top.length; i++) {
      final Offset a = top[i];
      final Offset b = top[(i + 1) % top.length];
      final Path face = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(b.dx, b.dy + 14)
        ..lineTo(a.dx, a.dy + 14)
        ..close();
      canvas.drawPath(
        face,
        Paint()
          ..color = i.isEven
              ? const Color(0xFF6D5640)
              : const Color(0xFF5A4634),
      );
    }
    canvas.drawPath(
      roof,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF3E2F22).withValues(alpha: 0.5),
    );
  }

  void _drawInteractable(Canvas canvas, VuGameInteractable item, bool hot) {
    final Offset c = transform.worldToScreen(item.position);
    final double r = transform.worldToScreenDistance(18);
    // Furniture block.
    final RRect body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: r * 1.8, height: r * 1.2),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      body.shift(const Offset(0, 4)),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.drawRRect(
      body,
      Paint()..color = hot ? const Color(0xFFB8F0D0) : const Color(0xFFF3E5C8),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = hot ? 2.4 : 1.2
        ..color = hot ? const Color(0xFF10B981) : const Color(0xFF8B7355),
    );
    _drawEmoji(canvas, item.glyph, c - Offset(r * 0.35, r * 0.55), r * 0.95);
    if (hot) {
      _drawSparkle(canvas, c - Offset(0, r + 8), const Color(0xFF34D399));
    }
  }

  void _drawNpc(Canvas canvas, VuGameNpc npc, bool showBubble) {
    final Offset c = transform.worldToScreen(npc.position);
    _drawSimBody(
      canvas,
      c,
      outfit: const Color(0xFF5B7C99),
      skin: const Color(0xFFE0B090),
      hair: const Color(0xFF2C1810),
    );
    final TextPainter name = TextPainter(
      text: TextSpan(
        text: npc.name,
        style: const TextStyle(
          color: Color(0xFF1A2E1A),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          shadows: <Shadow>[
            Shadow(color: Colors.white70, blurRadius: 3),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    name.paint(canvas, c + Offset(-name.width * 0.5, 22));
    if (showBubble && bubbleText != null) {
      _drawSpeechBubble(canvas, c - const Offset(0, 48), bubbleText!);
    } else {
      // Idle role chip.
      _drawMiniBubble(canvas, c - const Offset(0, 40), npc.glyph);
    }
  }

  void _drawPlayer(Canvas canvas, VuGameVec2 pos) {
    final Offset c = transform.worldToScreen(pos);
    _drawSimBody(
      canvas,
      c,
      outfit: Color(appearance.outfitColor),
      skin: Color(appearance.skinTone),
      hair: Color(appearance.hairColor),
    );
    // GradeGlow focus crystal (original — not a Sims plumbob).
    _drawFocusCrystal(canvas, c - const Offset(0, 46));
    if (bubbleText != null && npcBubbleId == null) {
      _drawSpeechBubble(canvas, c - const Offset(0, 68), bubbleText!);
    }
  }

  void _drawSimBody(
    Canvas canvas,
    Offset c, {
    required Color outfit,
    required Color skin,
    required Color hair,
  }) {
    final double s = transform.worldToScreenDistance(14);
    // Shadow ellipse.
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, s * 0.9), width: s * 1.6, height: s * 0.55),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );
    // Legs.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(-s * 0.25, s * 0.35), width: s * 0.35, height: s * 0.7),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF3D4F66),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(s * 0.25, s * 0.35), width: s * 0.35, height: s * 0.7),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF3D4F66),
    );
    // Torso.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * 1.15, height: s * 1.15),
        const Radius.circular(8),
      ),
      Paint()..color = outfit,
    );
    // Head.
    canvas.drawCircle(c - Offset(0, s * 0.85), s * 0.55, Paint()..color = skin);
    // Hair.
    canvas.drawCircle(c - Offset(0, s * 1.15), s * 0.42, Paint()..color = hair);
    canvas.drawOval(
      Rect.fromCenter(center: c - Offset(0, s * 1.0), width: s * 1.05, height: s * 0.55),
      Paint()..color = hair,
    );
  }

  void _drawFocusCrystal(Canvas canvas, Offset c) {
    final Path diamond = Path()
      ..moveTo(c.dx, c.dy - 10)
      ..lineTo(c.dx + 7, c.dy)
      ..lineTo(c.dx, c.dy + 10)
      ..lineTo(c.dx - 7, c.dy)
      ..close();
    canvas.drawPath(
      diamond,
      Paint()
        ..shader = ui.Gradient.linear(
          c - const Offset(0, 10),
          c + const Offset(0, 10),
          const <Color>[Color(0xFF6EE7B7), Color(0xFF10B981), Color(0xFF047857)],
        ),
    );
    canvas.drawPath(
      diamond,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      c,
      14,
      Paint()..color = const Color(0xFF34D399).withValues(alpha: 0.18),
    );
  }

  void _drawSpeechBubble(Canvas canvas, Offset c, String text) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text.length > 42 ? '${text.substring(0, 40)}…' : text,
        style: const TextStyle(
          color: Color(0xFF1A2E1A),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: 150);
    final RRect bubble = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: c,
        width: tp.width + 18,
        height: tp.height + 14,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(bubble, Paint()..color = Colors.white);
    canvas.drawRRect(
      bubble,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF10B981),
    );
    // Tail.
    final Path tail = Path()
      ..moveTo(c.dx - 6, c.dy + tp.height * 0.5 + 4)
      ..lineTo(c.dx, c.dy + tp.height * 0.5 + 14)
      ..lineTo(c.dx + 6, c.dy + tp.height * 0.5 + 4)
      ..close();
    canvas.drawPath(tail, Paint()..color = Colors.white);
    tp.paint(canvas, Offset(c.dx - tp.width * 0.5, c.dy - tp.height * 0.5));
  }

  void _drawMiniBubble(Canvas canvas, Offset c, String glyph) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 26, height: 22),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    _drawEmoji(canvas, glyph, c - const Offset(8, 9), 14);
  }

  void _drawWalkRing(Canvas canvas, VuGameVec2 pos) {
    final Offset c = transform.worldToScreen(pos);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 28, height: 14),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFF10B981),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 18, height: 9),
      Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.25),
    );
  }

  void _drawIsoTile(Canvas canvas, VuGameVec2 center, double size, Color color) {
    final List<Offset> pts = <Offset>[
      transform.worldToScreen(VuGameVec2(center.x, center.y - size * 0.5)),
      transform.worldToScreen(VuGameVec2(center.x + size * 0.5, center.y)),
      transform.worldToScreen(VuGameVec2(center.x, center.y + size * 0.5)),
      transform.worldToScreen(VuGameVec2(center.x - size * 0.5, center.y)),
    ];
    canvas.drawPath(Path()..addPolygon(pts, true), Paint()..color = color);
  }

  void _drawSparkle(Canvas canvas, Offset c, Color color) {
    canvas.drawCircle(c, 5, Paint()..color = color);
    canvas.drawCircle(c, 10, Paint()..color = color.withValues(alpha: 0.25));
  }

  void _drawEmoji(Canvas canvas, String glyph, Offset at, double size) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: glyph, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(covariant VuGameWorldPainter oldDelegate) =>
      oldDelegate.player.x != player.x ||
      oldDelegate.player.y != player.y ||
      oldDelegate.highlightInteractableId != highlightInteractableId ||
      oldDelegate.moveTarget?.x != moveTarget?.x ||
      oldDelegate.bubbleText != bubbleText ||
      oldDelegate.npcBubbleId != npcBubbleId;
}

class _DrawItem {
  _DrawItem(this.depth, this.paint);
  final double depth;
  final VoidCallback paint;
}
