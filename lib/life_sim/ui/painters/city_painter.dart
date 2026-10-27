import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../avatar/avatar_profile.dart';
import '../../world/city_map.dart';
import '../../world/world_model.dart';
import 'avatar_painter.dart';
import 'scene_common.dart';

/// Result of tapping the city.
class CityHit {
  const CityHit({this.building, required this.tileX, required this.tileY});
  final Building? building;
  final int tileX;
  final int tileY;
}

/// Isometric 2.5D city renderer.
class CityPainter extends CustomPainter {
  CityPainter({
    required this.playerX,
    required this.playerY,
    required this.look,
    required this.action,
    required this.emotion,
    required this.facingRight,
    required this.t,
    required this.daylight,
    required this.camX,
    required this.camY,
    required this.zoom,
    this.path = const <(int, int)>[],
    this.highlightBuildingId,
    this.openCheck,
  });

  final double playerX;
  final double playerY;
  final AvatarLook look;
  final AvatarAction action;
  final AvatarEmotion emotion;
  final bool facingRight;
  final double t;
  final double daylight;
  final double camX;
  final double camY;
  final double zoom;
  final List<(int, int)> path;
  final String? highlightBuildingId;

  /// Whether a building is currently open (for the door light).
  final bool Function(Building)? openCheck;

  static final CityMap _city = CityMap.instance;

  static double heightOf(Building b) => 54 + (b.id.hashCode.abs() % 5) * 14.0 + (b.employerId != null ? 12 : 0);

  /// Screen transform for a given canvas size.
  static Offset origin(Size size, double camX, double camY, double zoom) {
    final (double, double) c = kIso.project(camX, camY);
    return Offset(size.width / 2 - c.$1 * zoom, size.height * 0.56 - c.$2 * zoom);
  }

  /// Hit-test a tap.
  static CityHit pick(Offset p, Size size, double camX, double camY, double zoom) {
    final Offset o = origin(size, camX, camY, zoom);
    final Offset w = Offset((p.dx - o.dx) / zoom, (p.dy - o.dy) / zoom);
    // Buildings first: they are tall so test the extruded hull, nearest last.
    Building? best;
    double bestDepth = -1;
    for (final Building b in _city.buildings) {
      final double h = heightOf(b);
      final List<Offset> hull = _hull(b, h);
      if (pointInPolygon(w, hull)) {
        final double d = (b.x + b.w + b.y + b.h).toDouble();
        if (d > bestDepth) {
          bestDepth = d;
          best = b;
        }
      }
    }
    final (double, double) tile = kIso.unproject(w.dx, w.dy);
    return CityHit(building: best, tileX: tile.$1.floor(), tileY: tile.$2.floor());
  }

  static List<Offset> _hull(Building b, double h) {
    Offset pt(double x, double y, [double dz = 0]) {
      final (double, double) s = kIso.project(x, y);
      return Offset(s.$1, s.$2 - dz);
    }

    return <Offset>[
      pt(b.x.toDouble(), (b.y + b.h).toDouble()),
      pt((b.x + b.w).toDouble(), (b.y + b.h).toDouble()),
      pt((b.x + b.w).toDouble(), b.y.toDouble()),
      pt((b.x + b.w).toDouble(), b.y.toDouble(), h),
      pt(b.x.toDouble(), b.y.toDouble(), h),
      pt(b.x.toDouble(), (b.y + b.h).toDouble(), h),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Sky
    canvas.drawRect(Offset.zero & size, Paint()..color = skyColor(daylight));
    _stars(canvas, size);

    final Offset o = origin(size, camX, camY, zoom);
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(zoom);

    final Rect view = Rect.fromLTWH(-o.dx / zoom - 80, -o.dy / zoom - 160, size.width / zoom + 160, size.height / zoom + 320);

    // Ground
    final Paint p = Paint();
    for (int y = 0; y < CityMap.height; y++) {
      for (int x = 0; x < CityMap.width; x++) {
        final (double, double) s = kIso.project(x.toDouble(), y.toDouble());
        if (!view.contains(Offset(s.$1, s.$2))) continue;
        final Tile tile = _city.tiles[y][x];
        if (tile == Tile.building) {
          p.color = const Color(0xFF9CA3AF);
        } else {
          p.color = _groundColor(x, y, tile);
        }
        canvas.drawPath(tileDiamond(x.toDouble(), y.toDouble()), p);
        if (tile == Tile.road) _roadMarks(canvas, x, y);
      }
    }

    // Path markers
    final Paint dot = Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.85);
    for (int i = 1; i < path.length; i++) {
      final (double, double) s = kIso.project(path[i].$1 + 0.5, path[i].$2 + 0.5);
      canvas.drawOval(Rect.fromCenter(center: Offset(s.$1, s.$2), width: 10, height: 5), dot);
    }

    // Depth-sorted objects
    final List<DepthItem> items = <DepthItem>[];
    final List<Rect> windowGlows = <Rect>[];
    for (final Building b in _city.buildings) {
      // Front-left corner keeps wide boxes behind avatars standing at the door.
      items.add(DepthItem((b.x + b.y + b.h).toDouble(), (Canvas c) => _building(c, b, windowGlows)));
    }
    for (int y = 1; y < CityMap.height - 1; y++) {
      for (int x = 1; x < CityMap.width - 1; x++) {
        if (_city.tiles[y][x] != Tile.grass) continue;
        final double n = hash2(x, y, 7);
        if (n > 0.16) continue;
        final (double, double) s = kIso.project(x + 0.5, y + 0.5);
        if (!view.contains(Offset(s.$1, s.$2))) continue;
        items.add(DepthItem(x + y + 1.0, (Canvas c) => _tree(c, x, y, n)));
      }
    }
    // Street lamps at block corners
    for (int cy = 0; cy <= CityMap.rows; cy++) {
      for (int cx = 0; cx <= CityMap.cols; cx++) {
        final int lx = cx * CityMap.cellW + 1;
        final int ly = cy * CityMap.cellH + 1;
        if (lx >= CityMap.width || ly >= CityMap.height) continue;
        items.add(DepthItem(lx + ly + 0.6, (Canvas c) => _lamp(c, lx, ly, windowGlows)));
      }
    }
    items.add(DepthItem(playerX + playerY + 0.6, (Canvas c) => _player(c)));
    items.sort((DepthItem a, DepthItem b) => a.depth.compareTo(b.depth));
    for (final DepthItem it in items) {
      it.paint(canvas);
    }

    // Night tint (in world space so it covers the scene), then glows.
    canvas.restore();
    canvas.drawRect(Offset.zero & size, Paint()..color = nightTint(daylight));
    if (daylight < 0.65) {
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.scale(zoom);
      final double a = (0.65 - daylight) / 0.65;
      for (final Rect r in windowGlows) {
        if (!view.overlaps(r)) continue;
        canvas.drawRect(r, Paint()..color = const Color(0xFFFFD36B).withValues(alpha: 0.9 * a));
      }
      canvas.restore();
    }

    // Labels
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(zoom);
    for (final Building b in _city.buildings) {
      final (double, double) top = kIso.project(b.x + b.w / 2, b.y + b.h / 2);
      final Offset c = Offset(top.$1, top.$2 - heightOf(b) - 20);
      if (!view.contains(c)) continue;
      final bool hl = b.id == highlightBuildingId;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(1 / math.max(zoom, 0.6));
      final bool open = openCheck?.call(b) ?? true;
      TextCache.pill(
        canvas,
        Offset.zero,
        '${b.emoji} ${b.name}${open ? '' : ' · closed'}',
        size: hl ? 14 : 12,
        bg: hl ? const Color(0xEE2563EB) : const Color(0xB30B1220),
      );
      canvas.restore();
    }
    // District banners
    for (final District d in CityMap.districts) {
      final (double, double) s = kIso.project(d.col * CityMap.cellW + CityMap.cellW / 2, d.row * CityMap.cellH + 1.2);
      final Offset c = Offset(s.$1, s.$2 - 4);
      if (!view.contains(c)) continue;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(1 / math.max(zoom, 0.6));
      TextCache.pill(canvas, Offset.zero, '${d.emoji} ${d.name}', size: 11, bg: Color(d.color).withValues(alpha: 0.9), fg: const Color(0xFF111827));
      canvas.restore();
    }
    canvas.restore();
  }

  void _stars(Canvas canvas, Size size) {
    if (daylight > 0.45) return;
    final double a = (0.45 - daylight) / 0.45;
    final Paint p = Paint()..color = Colors.white.withValues(alpha: a * 0.8);
    for (int i = 0; i < 60; i++) {
      final double x = hash2(i, 1, 3) * size.width;
      final double y = hash2(i, 2, 3) * size.height * 0.5;
      final double tw = 0.6 + 0.4 * math.sin(t * 2 + i);
      canvas.drawCircle(Offset(x, y), 0.8 + hash2(i, 3, 3) * 1.1 * tw, p);
    }
  }

  Color _groundColor(int x, int y, Tile tile) {
    switch (tile) {
      case Tile.road:
        return ((x + y) & 1) == 0 ? const Color(0xFF475569) : const Color(0xFF4B5A6F);
      case Tile.plaza:
        final District d = _city.districtAt(x, y);
        return mix(const Color(0xFFE2E8F0), Color(d.color), 0.35 + 0.1 * (((x + y) & 1)));
      case Tile.grass:
        return ((x + y) & 1) == 0 ? const Color(0xFF6BBF6A) : const Color(0xFF63B562);
      case Tile.water:
        return const Color(0xFF38BDF8);
      case Tile.building:
        return const Color(0xFF9CA3AF);
    }
  }

  void _roadMarks(Canvas canvas, int x, int y) {
    final bool horizontal = y % CityMap.cellH == 0 && x % CityMap.cellW != 0;
    final bool vertical = x % CityMap.cellW == 0 && y % CityMap.cellH != 0;
    if (!horizontal && !vertical) return;
    final Paint p = Paint()
      ..color = const Color(0xCCFDE68A)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final (double, double) a = horizontal ? kIso.project(x + 0.3, y + 0.5) : kIso.project(x + 0.5, y + 0.3);
    final (double, double) b = horizontal ? kIso.project(x + 0.7, y + 0.5) : kIso.project(x + 0.5, y + 0.7);
    canvas.drawLine(Offset(a.$1, a.$2), Offset(b.$1, b.$2), p);
  }

  void _tree(Canvas canvas, int x, int y, double n) {
    final (double, double) s = kIso.project(x + 0.5, y + 0.5);
    final double h = 22 + n * 90;
    canvas.drawOval(Rect.fromCenter(center: Offset(s.$1, s.$2), width: 18, height: 8), Paint()..color = const Color(0x33000000));
    canvas.drawRect(Rect.fromLTWH(s.$1 - 2, s.$2 - 12, 4, 12), Paint()..color = const Color(0xFF7C4A21));
    final double sway = math.sin(t * 1.4 + x) * 1.2;
    canvas.drawCircle(Offset(s.$1 + sway, s.$2 - 20 - h * 0.05), 11, Paint()..color = const Color(0xFF2E9E4E));
    canvas.drawCircle(Offset(s.$1 + sway - 4, s.$2 - 16), 8, Paint()..color = const Color(0xFF38B65B));
  }

  void _lamp(Canvas canvas, int x, int y, List<Rect> glows) {
    final (double, double) s = kIso.project(x + 0.5, y + 0.5);
    canvas.drawRect(Rect.fromLTWH(s.$1 - 1.2, s.$2 - 30, 2.4, 30), Paint()..color = const Color(0xFF374151));
    canvas.drawCircle(Offset(s.$1, s.$2 - 32), 3.5, Paint()..color = const Color(0xFFFDE68A));
    if (daylight < 0.65) {
      canvas.drawCircle(Offset(s.$1, s.$2 - 32), 18, Paint()..color = const Color(0x33FFD36B));
    }
  }

  void _building(Canvas canvas, Building b, List<Rect> glows) {
    final double h = heightOf(b);
    final Color base = Color(b.color);
    final Color left = shade(base, -0.06);
    final Color right = shade(base, -0.18);
    final Color roof = shade(base, 0.12);

    Offset pt(double x, double y, [double dz = 0]) {
      final (double, double) s = kIso.project(x, y);
      return Offset(s.$1, s.$2 - dz);
    }

    final double x0 = b.x.toDouble(), y0 = b.y.toDouble();
    final double x1 = (b.x + b.w).toDouble(), y1 = (b.y + b.h).toDouble();

    // Ground shadow
    canvas.drawPath(
      Path()
        ..moveTo(pt(x0, y1).dx, pt(x0, y1).dy)
        ..lineTo(pt(x1, y1).dx, pt(x1, y1).dy)
        ..lineTo(pt(x1 + 0.9, y0 + 0.9).dx, pt(x1 + 0.9, y0 + 0.9).dy)
        ..lineTo(pt(x1, y0).dx, pt(x1, y0).dy)
        ..close(),
      Paint()..color = const Color(0x22000000),
    );

    // Faces
    final Path leftFace = Path()
      ..moveTo(pt(x0, y1).dx, pt(x0, y1).dy)
      ..lineTo(pt(x1, y1).dx, pt(x1, y1).dy)
      ..lineTo(pt(x1, y1, h).dx, pt(x1, y1, h).dy)
      ..lineTo(pt(x0, y1, h).dx, pt(x0, y1, h).dy)
      ..close();
    final Path rightFace = Path()
      ..moveTo(pt(x1, y1).dx, pt(x1, y1).dy)
      ..lineTo(pt(x1, y0).dx, pt(x1, y0).dy)
      ..lineTo(pt(x1, y0, h).dx, pt(x1, y0, h).dy)
      ..lineTo(pt(x1, y1, h).dx, pt(x1, y1, h).dy)
      ..close();
    final Path roofFace = Path()
      ..moveTo(pt(x0, y1, h).dx, pt(x0, y1, h).dy)
      ..lineTo(pt(x1, y1, h).dx, pt(x1, y1, h).dy)
      ..lineTo(pt(x1, y0, h).dx, pt(x1, y0, h).dy)
      ..lineTo(pt(x0, y0, h).dx, pt(x0, y0, h).dy)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = left);
    canvas.drawPath(rightFace, Paint()..color = right);
    canvas.drawPath(roofFace, Paint()..color = roof);
    final Paint edge = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(leftFace, edge);
    canvas.drawPath(rightFace, edge);
    canvas.drawPath(roofFace, edge);

    // Windows on both faces
    final int floors = math.max(2, (h / 22).floor() - 1);
    final bool lit = daylight < 0.65;
    for (int f = 0; f < floors; f++) {
      final double dz = 22.0 + f * 20;
      for (int i = 0; i < b.w; i++) {
        final double u = i + 0.5;
        final bool isDoorCol = (b.x + i) == b.doorX && f == 0;
        if (isDoorCol) continue;
        final Offset c = pt(x0 + u, y1, dz);
        final bool on = hash2(b.x + i, f, b.id.hashCode) > 0.35;
        final Rect r = Rect.fromCenter(center: c, width: 9, height: 11);
        canvas.drawRect(r, Paint()..color = on && lit ? const Color(0xFFFFE08A) : const Color(0xFFBFDBFE).withValues(alpha: 0.85));
        if (on && lit) glows.add(r);
      }
      for (int j = 0; j < b.h; j++) {
        final Offset c = pt(x1, y0 + j + 0.5, dz);
        final bool on = hash2(j, f, b.id.hashCode + 5) > 0.4;
        final Rect r = Rect.fromCenter(center: c, width: 9, height: 11);
        canvas.drawRect(r, Paint()..color = on && lit ? const Color(0xFFFFE08A) : const Color(0xFF93C5FD).withValues(alpha: 0.75));
        if (on && lit) glows.add(r);
      }
    }

    // Door
    final Offset door = pt(b.doorX + 0.5, y1);
    final Rect dr = Rect.fromLTWH(door.dx - 8, door.dy - 22, 16, 22);
    final bool open = openCheck?.call(b) ?? true;
    canvas.drawRRect(RRect.fromRectAndCorners(dr, topLeft: const Radius.circular(8), topRight: const Radius.circular(8)), Paint()..color = open ? const Color(0xFF7C3A12) : const Color(0xFF3F3F46));
    canvas.drawCircle(Offset(dr.right - 4, dr.center.dy + 2), 1.4, Paint()..color = const Color(0xFFFDE047));
    final Rect awn = Rect.fromLTWH(door.dx - 13, door.dy - 28, 26, 6);
    canvas.drawRect(awn, Paint()..color = open ? const Color(0xFFEF4444) : const Color(0xFF71717A));
    if (open && daylight < 0.65) glows.add(dr);

    // Roof decoration emoji
    final Offset rc = pt(x0 + b.w / 2, y0 + b.h / 2, h + 2);
    drawEmoji(canvas, b.emoji, rc, 24);

    if (b.id == highlightBuildingId) {
      canvas.drawPath(
        leftFace,
        Paint()
          ..color = const Color(0xFFFDE047)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  void _player(Canvas canvas) {
    final (double, double) s = kIso.project(playerX + 0.5, playerY + 0.5);
    canvas.save();
    canvas.translate(s.$1, s.$2 + 6);
    const double h = 70;
    canvas.translate(-h * 0.3, -h);
    AvatarPainter(look: look, action: action, emotion: emotion, t: t, facingRight: facingRight).paint(canvas, const Size(h * 0.6, h));
    canvas.restore();
  }

  @override
  bool shouldRepaint(CityPainter old) => true;
}
