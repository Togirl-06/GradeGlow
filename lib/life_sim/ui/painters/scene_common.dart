import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../iso.dart';

const Iso kIso = Iso();

/// Caches laid-out text so painters do not re-measure every frame.
class TextCache {
  TextCache._();
  static final Map<String, TextPainter> _cache = <String, TextPainter>{};

  static TextPainter get(String text, {double size = 12, Color color = Colors.white, FontWeight weight = FontWeight.w800}) {
    final String key = '$text|$size|${color.toARGB32()}|${weight.value}';
    final TextPainter? hit = _cache[key];
    if (hit != null) return hit;
    if (_cache.length > 400) _cache.clear();
    final TextPainter tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color, fontWeight: weight)),
      textDirection: TextDirection.ltr,
    )..layout();
    return _cache[key] = tp;
  }

  /// Draws a rounded label pill centred at [center].
  static void pill(Canvas canvas, Offset center, String text, {double size = 12, Color bg = const Color(0xCC0B1220), Color fg = Colors.white}) {
    final TextPainter tp = get(text, size: size, color: fg);
    final Rect r = Rect.fromCenter(center: center, width: tp.width + 14, height: tp.height + 8);
    canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(r.height / 2)), Paint()..color = bg);
    tp.paint(canvas, Offset(r.left + 7, r.top + 4));
  }
}

Color shade(Color c, double amt) {
  final HSLColor h = HSLColor.fromColor(c);
  return h.withLightness((h.lightness + amt).clamp(0.0, 1.0)).toColor();
}

Color mix(Color a, Color b, double t) => Color.lerp(a, b, t.clamp(0.0, 1.0))!;

/// Diamond path for tile (x, y) at world origin offset.
Path tileDiamond(double x, double y, {double h = 0}) {
  final (double, double) a = kIso.project(x, y);
  final (double, double) b = kIso.project(x + 1, y);
  final (double, double) c = kIso.project(x + 1, y + 1);
  final (double, double) d = kIso.project(x, y + 1);
  return Path()
    ..moveTo(a.$1, a.$2 - h)
    ..lineTo(b.$1, b.$2 - h)
    ..lineTo(c.$1, c.$2 - h)
    ..lineTo(d.$1, d.$2 - h)
    ..close();
}

/// Point-in-polygon (even-odd).
bool pointInPolygon(Offset p, List<Offset> poly) {
  bool inside = false;
  for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final Offset a = poly[i];
    final Offset b = poly[j];
    if ((a.dy > p.dy) != (b.dy > p.dy) && p.dx < (b.dx - a.dx) * (p.dy - a.dy) / (b.dy - a.dy) + a.dx) {
      inside = !inside;
    }
  }
  return inside;
}

/// Sky colour for the given daylight 0..1.
Color skyColor(double daylight) =>
    mix(const Color(0xFF0B1030), const Color(0xFF8EC9F5), daylight);

/// Colour multiplier overlay for night.
Color nightTint(double daylight) {
  final double a = (1 - daylight) * 0.52;
  return Color.fromRGBO(10, 16, 56, a);
}

/// Deterministic 0..1 noise from two ints.
double hash2(int x, int y, [int salt = 0]) {
  int h = x * 374761393 + y * 668265263 + salt * 2147483647;
  h = (h ^ (h >> 13)) * 1274126177;
  h = h ^ (h >> 16);
  return (h & 0xFFFF) / 0xFFFF;
}

double lerpD(double a, double b, double t) => a + (b - a) * t;

double smoothPulse(double t, double speed) => 0.5 + 0.5 * math.sin(t * speed);

/// Draw an emoji centred at [c].
void drawEmoji(Canvas canvas, String emoji, Offset c, double size) {
  final TextPainter tp = TextCache.get(emoji, size: size, color: Colors.white, weight: FontWeight.w400);
  tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
}

typedef PaintFn = void Function(Canvas canvas);

class DepthItem {
  DepthItem(this.depth, this.paint);
  final double depth;
  final PaintFn paint;
}

