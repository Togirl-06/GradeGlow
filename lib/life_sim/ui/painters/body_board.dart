import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../education/lectures.dart';

/// A simple front-view body diagram. Organs named in [highlighted] glow and are
/// labelled while the professor speaks about them.
class BodyBoardPainter extends CustomPainter {
  BodyBoardPainter({required this.highlighted, required this.t});
  final Set<String> highlighted;
  final double t;

  // Organ shapes in a 100 x 200 design space: (cx, cy, w, h)
  static const Map<String, List<double>> _geo = <String, List<double>>{
    'skull': <double>[50, 18, 26, 28],
    'brain': <double>[50, 16, 18, 14],
    'spine': <double>[50, 84, 5, 78],
    'ribs': <double>[50, 62, 34, 30],
    'lungs': <double>[50, 60, 30, 22],
    'heart': <double>[54, 66, 10, 12],
    'liver': <double>[42, 84, 16, 9],
    'stomach': <double>[58, 84, 11, 10],
    'kidneys': <double>[50, 94, 24, 7],
    'intestines': <double>[50, 104, 20, 14],
    'bladder': <double>[50, 120, 9, 8],
    'femur': <double>[41, 150, 7, 44],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final double s = math.min(size.width / 100, size.height / 200);
    final double ox = (size.width - 100 * s) / 2;
    final double oy = (size.height - 200 * s) / 2;
    Offset p(double x, double y) => Offset(ox + x * s, oy + y * s);
    Rect r(List<double> g) => Rect.fromCenter(center: p(g[0], g[1]), width: g[2] * s, height: g[3] * s);

    final Paint skin = Paint()..color = const Color(0xFF223052);
    final Paint line = Paint()
      ..color = const Color(0xFF4B5F96)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * s / 2;
    // Silhouette.
    canvas.drawOval(r(<double>[50, 18, 24, 28]), skin);
    final RRect torso = RRect.fromRectAndRadius(r(<double>[50, 82, 38, 70]), Radius.circular(10 * s));
    canvas.drawRRect(torso, skin);
    canvas.drawRRect(torso, line);
    for (final double dx in <double>[-1, 1]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: p(50 + dx * 26, 76), width: 9 * s, height: 62 * s), Radius.circular(5 * s)), skin);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: p(50 + dx * 9, 158), width: 14 * s, height: 86 * s), Radius.circular(6 * s)), skin);
    }

    final double pulse = 0.55 + 0.45 * math.sin(t * 5);
    void organ(String id, Color base, {bool oval = true}) {
      final List<double>? g = _geo[id];
      if (g == null) return;
      final bool on = highlighted.contains(id);
      final Rect rect = r(g);
      final Paint fill = Paint()..color = on ? base : base.withValues(alpha: 0.28);
      if (on) {
        canvas.drawOval(rect.inflate(5 * s), Paint()..color = base.withValues(alpha: 0.30 * pulse)..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * s));
      }
      if (id == 'spine') {
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(2 * s)), fill);
      } else if (id == 'femur') {
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(3 * s)), fill);
        canvas.drawRRect(RRect.fromRectAndRadius(r(<double>[59, 150, 7, 44]), Radius.circular(3 * s)), fill);
      } else if (oval) {
        canvas.drawOval(rect, fill);
      }
      if (on) {
        canvas.drawOval(rect.inflate(1.5 * s), Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.6);
        final TextPainter tp = TextPainter(
          text: TextSpan(text: kOrgans[id] ?? id, style: TextStyle(color: Colors.white, fontSize: 11 + s * 0.4, fontWeight: FontWeight.w900, shadows: const <Shadow>[Shadow(blurRadius: 4, color: Colors.black)])),
          textDirection: TextDirection.ltr,
        )..layout();
        final Offset c = rect.center;
        final bool left = c.dx < ox + 50 * s;
        final Offset anchor = left ? Offset(ox + 2 * s, c.dy) : Offset(ox + 98 * s - tp.width, c.dy);
        canvas.drawLine(Offset(left ? anchor.dx + tp.width : anchor.dx, c.dy), c, Paint()..color = Colors.white70..strokeWidth = 1);
        tp.paint(canvas, Offset(anchor.dx, c.dy - tp.height / 2));
      }
    }

    organ('ribs', const Color(0xFFE5E7EB));
    organ('spine', const Color(0xFFD1D5DB));
    organ('femur', const Color(0xFFE5E7EB));
    organ('skull', const Color(0xFFE5E7EB));
    organ('brain', const Color(0xFFF9A8D4));
    organ('lungs', const Color(0xFF60A5FA));
    organ('liver', const Color(0xFFB45309));
    organ('stomach', const Color(0xFFFB923C));
    organ('kidneys', const Color(0xFFB91C1C));
    organ('intestines', const Color(0xFFFBBF24));
    organ('bladder', const Color(0xFFFDE047));
    organ('heart', const Color(0xFFEF4444));
  }

  @override
  bool shouldRepaint(BodyBoardPainter old) => true;
}
