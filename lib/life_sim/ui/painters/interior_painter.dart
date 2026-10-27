import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../avatar/avatar_profile.dart';
import '../../world/world_model.dart';
import 'avatar_painter.dart';
import 'scene_common.dart';

class InteriorHit {
  const InteriorHit({this.item, this.npc, this.exit = false, required this.tileX, required this.tileY});
  final Interactable? item;
  final NpcDef? npc;
  final bool exit;
  final int tileX;
  final int tileY;
}

/// Isometric room renderer (floor, back walls, props, NPCs, the player).
class InteriorPainter extends CustomPainter {
  InteriorPainter({
    required this.interior,
    required this.playerX,
    required this.playerY,
    required this.look,
    required this.action,
    required this.emotion,
    required this.facingRight,
    required this.t,
    required this.daylight,
    this.path = const <(int, int)>[],
    this.nearItemId,
    this.talkingNpcId,
    this.accent,
    this.roomName = '',
  });

  final Interior interior;
  final double playerX;
  final double playerY;
  final AvatarLook look;
  final AvatarAction action;
  final AvatarEmotion emotion;
  final bool facingRight;
  final double t;
  final double daylight;
  final List<(int, int)> path;
  final String? nearItemId;
  final String? talkingNpcId;
  final Color? accent;
  final String roomName;

  static const double wallH = 96;

  static double zoomFor(Size size, Interior it) {
    final double w = (it.width + it.height) * kIso.tileW / 2 + 60;
    final double h = (it.width + it.height) * kIso.tileH / 2 + wallH + 70;
    return math.min(size.width / w, size.height / h).clamp(0.35, 1.6);
  }

  static Offset origin(Size size, Interior it) {
    final double z = zoomFor(size, it);
    final double top = -wallH * z;
    final double total = ((it.width + it.height) * kIso.tileH / 2) * z - top;
    return Offset(size.width / 2 + (it.height - it.width) * kIso.tileW / 4 * z, (size.height - total) / 2 - top + 6);
  }

  static double _boxH(Interactable i) => 16 + (i.id.hashCode.abs() % 4) * 5.0;

  static InteriorHit pick(Offset p, Size size, Interior it) {
    final double z = zoomFor(size, it);
    final Offset o = origin(size, it);
    final Offset w = Offset((p.dx - o.dx) / z, (p.dy - o.dy) / z);
    for (final NpcDef n in it.npcs) {
      final (double, double) s = kIso.project(n.x + 0.5, n.y + 0.5);
      if (Rect.fromLTRB(s.$1 - 20, s.$2 - 78, s.$1 + 20, s.$2 + 6).contains(w)) {
        return InteriorHit(npc: n, tileX: n.x, tileY: n.y);
      }
    }
    for (final Interactable i in it.interactables) {
      final double bh = _boxH(i);
      final (double, double) a = kIso.project(i.x + 0.1, i.y + 0.9);
      final (double, double) b = kIso.project(i.x + 0.9, i.y + 0.9);
      final (double, double) c = kIso.project(i.x + 0.9, i.y + 0.1);
      final (double, double) d = kIso.project(i.x + 0.1, i.y + 0.1);
      final List<Offset> hull = <Offset>[
        Offset(a.$1, a.$2),
        Offset(b.$1, b.$2),
        Offset(c.$1, c.$2),
        Offset(c.$1, c.$2 - bh - 22),
        Offset(d.$1, d.$2 - bh - 22),
        Offset(a.$1, a.$2 - bh - 22),
      ];
      if (pointInPolygon(w, hull)) return InteriorHit(item: i, tileX: i.x, tileY: i.y);
    }
    final (double, double) tile = kIso.unproject(w.dx, w.dy);
    final int tx = tile.$1.floor();
    final int ty = tile.$2.floor();
    return InteriorHit(exit: tx == it.exitX && ty >= it.exitY, tileX: tx, tileY: ty);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Color wall = Color(interior.wallColor);
    canvas.drawRect(Offset.zero & size, Paint()..color = mix(const Color(0xFF111827), shade(wall, -0.25), 0.8));
    final double z = zoomFor(size, interior);
    final Offset o = origin(size, interior);
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(z);

    final int W = interior.width;
    final int H = interior.height;
    final Color floor = Color(interior.floorColor);

    // Floor
    for (int y = 0; y < H; y++) {
      for (int x = 0; x < W; x++) {
        canvas.drawPath(tileDiamond(x.toDouble(), y.toDouble()), Paint()..color = ((x + y) & 1) == 0 ? floor : shade(floor, -0.045));
      }
    }
    // Exit mat
    canvas.drawPath(tileDiamond(interior.exitX.toDouble(), interior.exitY.toDouble()), Paint()..color = const Color(0xFF7C3AED).withValues(alpha: 0.55));

    // Back walls
    _wall(canvas, 0, 0, W.toDouble(), 0, wall, shade(wall, 0.06), isY: true);
    _wall(canvas, 0, 0, 0, H.toDouble(), shade(wall, -0.12), shade(wall, -0.06), isY: false);
    _wallDecor(canvas, W, H);

    // Path
    final Paint dot = Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.9);
    for (int i = 1; i < path.length; i++) {
      final (double, double) s = kIso.project(path[i].$1 + 0.5, path[i].$2 + 0.5);
      canvas.drawOval(Rect.fromCenter(center: Offset(s.$1, s.$2), width: 10, height: 5), dot);
    }

    final List<DepthItem> items = <DepthItem>[];
    for (final Interactable i in interior.interactables) {
      items.add(DepthItem(i.x + i.y + 0.5, (Canvas c) => _item(c, i)));
    }
    for (final NpcDef n in interior.npcs) {
      items.add(DepthItem(n.x + n.y + 0.55, (Canvas c) => _npc(c, n)));
    }
    items.add(DepthItem(playerX + playerY + 0.6, (Canvas c) => _player(c)));
    items.sort((DepthItem a, DepthItem b) => a.depth.compareTo(b.depth));
    for (final DepthItem d in items) {
      d.paint(canvas);
    }

    // Exit label
    final (double, double) e = kIso.project(interior.exitX + 0.5, interior.exitY + 0.9);
    canvas.save();
    canvas.translate(e.$1, e.$2 + 10);
    TextCache.pill(canvas, Offset.zero, '🚪 Exit', size: 12, bg: const Color(0xCC6D28D9));
    canvas.restore();
    canvas.restore();

    // Warm interior light + gentle night tint through windows
    canvas.drawRect(Offset.zero & size, Paint()..color = Color.fromRGBO(20, 24, 70, (1 - daylight) * 0.18));

    if (roomName.isNotEmpty) {
      TextCache.pill(canvas, Offset(size.width / 2, 26), roomName, size: 15, bg: (accent ?? const Color(0xFF2563EB)).withValues(alpha: 0.92));
    }
  }

  void _wall(Canvas canvas, double x0, double y0, double x1, double y1, Color c, Color top, {required bool isY}) {
    final (double, double) a = kIso.project(x0, y0);
    final (double, double) b = kIso.project(x1, y1);
    final Path p = Path()
      ..moveTo(a.$1, a.$2)
      ..lineTo(b.$1, b.$2)
      ..lineTo(b.$1, b.$2 - wallH)
      ..lineTo(a.$1, a.$2 - wallH)
      ..close();
    canvas.drawPath(p, Paint()..color = c);
    canvas.drawPath(
      Path()
        ..moveTo(a.$1, a.$2 - wallH)
        ..lineTo(b.$1, b.$2 - wallH)
        ..lineTo(b.$1, b.$2 - wallH - 6)
        ..lineTo(a.$1, a.$2 - wallH - 6)
        ..close(),
      Paint()..color = top,
    );
    // Skirting
    canvas.drawPath(
      Path()
        ..moveTo(a.$1, a.$2)
        ..lineTo(b.$1, b.$2)
        ..lineTo(b.$1, b.$2 - 7)
        ..lineTo(a.$1, a.$2 - 7)
        ..close(),
      Paint()..color = shade(c, -0.12),
    );
  }

  void _wallDecor(Canvas canvas, int W, int H) {
    final Paint glass = Paint()..color = mix(const Color(0xFF0B1030), const Color(0xFFBFE3FF), daylight);
    final Paint frame = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    // Windows along the back-right wall (y = 0), spanning x ± 0.45.
    for (int x = 1; x < W - 1; x += 3) {
      Offset q(double dx, double z) {
        final (double, double) s = kIso.project(x + 0.5 + dx, 0);
        return Offset(s.$1, s.$2 - z);
      }

      final Path w = Path()
        ..moveTo(q(-0.45, 42).dx, q(-0.45, 42).dy)
        ..lineTo(q(0.45, 42).dx, q(0.45, 42).dy)
        ..lineTo(q(0.45, 78).dx, q(0.45, 78).dy)
        ..lineTo(q(-0.45, 78).dx, q(-0.45, 78).dy)
        ..close();
      canvas.drawPath(w, glass);
      canvas.drawPath(w, frame);
      canvas.drawLine(q(0, 42), q(0, 78), frame);
    }
    // Framed pictures along the back-left wall (x = 0).
    for (int y = 1; y < H - 1; y += 3) {
      Offset q(double dy, double z) {
        final (double, double) s = kIso.project(0, y + 0.5 + dy);
        return Offset(s.$1, s.$2 - z);
      }

      final Path f = Path()
        ..moveTo(q(-0.4, 46).dx, q(-0.4, 46).dy)
        ..lineTo(q(0.4, 46).dx, q(0.4, 46).dy)
        ..lineTo(q(0.4, 76).dx, q(0.4, 76).dy)
        ..lineTo(q(-0.4, 76).dx, q(-0.4, 76).dy)
        ..close();
      canvas.drawPath(f, Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.9));
      canvas.drawPath(f, Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);
    }
  }

  void _item(Canvas canvas, Interactable i) {
    final double bh = _boxH(i);
    final Color base = HSLColor.fromAHSL(1, (i.id.hashCode.abs() % 360).toDouble(), 0.35, 0.58).toColor();
    Offset pt(double x, double y, [double dz = 0]) {
      final (double, double) s = kIso.project(i.x + x, i.y + y);
      return Offset(s.$1, s.$2 - dz);
    }

    const double m = 0.1;
    final Path left = Path()
      ..moveTo(pt(m, 1 - m).dx, pt(m, 1 - m).dy)
      ..lineTo(pt(1 - m, 1 - m).dx, pt(1 - m, 1 - m).dy)
      ..lineTo(pt(1 - m, 1 - m, bh).dx, pt(1 - m, 1 - m, bh).dy)
      ..lineTo(pt(m, 1 - m, bh).dx, pt(m, 1 - m, bh).dy)
      ..close();
    final Path right = Path()
      ..moveTo(pt(1 - m, 1 - m).dx, pt(1 - m, 1 - m).dy)
      ..lineTo(pt(1 - m, m).dx, pt(1 - m, m).dy)
      ..lineTo(pt(1 - m, m, bh).dx, pt(1 - m, m, bh).dy)
      ..lineTo(pt(1 - m, 1 - m, bh).dx, pt(1 - m, 1 - m, bh).dy)
      ..close();
    final Path top = Path()
      ..moveTo(pt(m, 1 - m, bh).dx, pt(m, 1 - m, bh).dy)
      ..lineTo(pt(1 - m, 1 - m, bh).dx, pt(1 - m, 1 - m, bh).dy)
      ..lineTo(pt(1 - m, m, bh).dx, pt(1 - m, m, bh).dy)
      ..lineTo(pt(m, m, bh).dx, pt(m, m, bh).dy)
      ..close();
    final Offset shadow = pt(0.5, 0.5);
    canvas.drawOval(Rect.fromCenter(center: shadow, width: 44, height: 18), Paint()..color = const Color(0x33000000));
    canvas.drawPath(left, Paint()..color = shade(base, -0.06));
    canvas.drawPath(right, Paint()..color = shade(base, -0.18));
    canvas.drawPath(top, Paint()..color = shade(base, 0.1));

    final bool near = i.id == nearItemId;
    final double bob = near ? math.sin(t * 5) * 2.5 : 0;
    drawEmoji(canvas, i.emoji, pt(0.5, 0.5, bh + 20 + bob), 26);
    if (near) {
      canvas.drawPath(top, Paint()
        ..color = const Color(0xFFFDE047)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);
      canvas.save();
      canvas.translate(pt(0.5, 0.5, bh + 54).dx, pt(0.5, 0.5, bh + 54).dy);
      TextCache.pill(canvas, Offset.zero, i.name, size: 12, bg: const Color(0xEE2563EB));
      canvas.restore();
    }
  }

  void _npc(Canvas canvas, NpcDef n) {
    final (double, double) s = kIso.project(n.x + 0.5, n.y + 0.5);
    canvas.save();
    canvas.translate(s.$1, s.$2 + 5);
    const double h = 66;
    canvas.translate(-h * 0.3, -h);
    final bool talking = n.id == talkingNpcId;
    AvatarPainter(
      look: AvatarLook.fromNpc(n),
      action: talking ? AvatarAction.talk : AvatarAction.idle,
      emotion: AvatarEmotion.happy,
      t: t + n.id.hashCode % 7,
      facingRight: playerX >= n.x,
    ).paint(canvas, const Size(h * 0.6, h));
    canvas.restore();
    canvas.save();
    canvas.translate(s.$1, s.$2 - h - 12 - math.sin(t * 3 + n.x) * 2);
    TextCache.pill(canvas, Offset.zero, '💬 ${n.name}', size: 10.5, bg: const Color(0xB30B1220));
    canvas.restore();
  }

  void _player(Canvas canvas) {
    final (double, double) s = kIso.project(playerX + 0.5, playerY + 0.5);
    canvas.save();
    canvas.translate(s.$1, s.$2 + 5);
    const double h = 72;
    canvas.translate(-h * 0.3, -h);
    AvatarPainter(look: look, action: action, emotion: emotion, t: t, facingRight: facingRight).paint(canvas, const Size(h * 0.6, h));
    canvas.restore();
  }

  @override
  bool shouldRepaint(InteriorPainter old) => true;
}
