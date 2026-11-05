import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Schematic diagrams for tasks (heart, cell, beam, circuit, gears, aerofoil).
/// Numbered markers are drawn on top for labelling tasks.
class TechDiagram extends StatelessWidget {
  const TechDiagram({super.key, required this.id, this.markers = const <Offset>[], this.labels = const <String?>[]});

  final String id;

  /// Marker positions as 0–1 fractions of the diagram.
  final List<Offset> markers;
  final List<String?> labels;

  static const Set<String> known = <String>{'heart', 'cell', 'beam', 'circuit', 'gears', 'airfoil'};

  @override
  Widget build(BuildContext context) {
    if (!known.contains(id)) return const SizedBox.shrink();
    final ColorScheme cs = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(
          painter: _DiagramPainter(id, markers, labels, cs.onSurface, cs.primary),
        ),
      ),
    );
  }
}

class _DiagramPainter extends CustomPainter {
  _DiagramPainter(this.id, this.markers, this.labels, this.ink, this.accent);

  final String id;
  final List<Offset> markers;
  final List<String?> labels;
  final Color ink;
  final Color accent;

  Paint get _line => Paint()
    ..color = ink.withValues(alpha: 0.8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  Paint _fill(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  void _text(Canvas c, String s, Offset at, {double size = 12, Color? color}) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: color ?? ink, fontSize: size, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    switch (id) {
      case 'heart':
        final Paint red = _fill(const Color(0xFFE57373).withValues(alpha: 0.55));
        final Paint blue = _fill(const Color(0xFF64B5F6).withValues(alpha: 0.55));
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.42, h * 0.02, w * 0.08, h * 0.22), const Radius.circular(8)), blue);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.52, h * 0.0, w * 0.1, h * 0.2), const Radius.circular(8)), red);
        canvas.drawOval(Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.26, h * 0.28), blue);
        canvas.drawOval(Rect.fromLTWH(w * 0.56, h * 0.18, w * 0.26, h * 0.28), red);
        final Path rv = Path()
          ..moveTo(w * 0.2, h * 0.46)
          ..quadraticBezierTo(w * 0.22, h * 0.9, w * 0.48, h * 0.95)
          ..lineTo(w * 0.48, h * 0.46)
          ..close();
        canvas.drawPath(rv, blue);
        final Path lv = Path()
          ..moveTo(w * 0.52, h * 0.46)
          ..lineTo(w * 0.52, h * 0.95)
          ..quadraticBezierTo(w * 0.8, h * 0.9, w * 0.8, h * 0.46)
          ..close();
        canvas.drawPath(lv, red);
        canvas.drawRect(Rect.fromLTWH(w * 0.48, h * 0.46, w * 0.04, h * 0.49), _fill(ink.withValues(alpha: 0.35)));
        canvas.drawLine(Offset(w * 0.18, h * 0.46), Offset(w * 0.82, h * 0.46), _line);
      case 'cell':
        canvas.drawOval(Rect.fromLTWH(w * 0.05, h * 0.06, w * 0.9, h * 0.88), _line..strokeWidth = 3);
        canvas.drawOval(Rect.fromLTWH(w * 0.38, h * 0.32, w * 0.24, h * 0.32), _fill(const Color(0xFF9575CD).withValues(alpha: 0.5)));
        canvas.drawCircle(Offset(w * 0.5, h * 0.48), w * 0.03, _fill(const Color(0xFF5E35B1)));
        canvas.drawOval(Rect.fromLTWH(w * 0.17, h * 0.24, w * 0.14, h * 0.12), _fill(const Color(0xFFFFB74D).withValues(alpha: 0.7)));
        for (int i = 0; i < 4; i++) {
          canvas.drawArc(Rect.fromLTWH(w * (0.64 + i * 0.015), h * (0.2 + i * 0.05), w * 0.18, h * 0.12), 3.4, 2.4, false, _line..strokeWidth = 2);
        }
        for (int i = 0; i < 4; i++) {
          canvas.drawArc(Rect.fromLTWH(w * 0.64, h * (0.64 + i * 0.035), w * 0.16, h * 0.1), 0.3, 2.5, false, _line..strokeWidth = 2);
        }
      case 'beam':
        final double y = h * 0.5;
        canvas.drawRect(Rect.fromLTWH(w * 0.1, y - 8, w * 0.8, 16), _fill(ink.withValues(alpha: 0.25)));
        final Path a = Path()
          ..moveTo(w * 0.1, y + 8)
          ..lineTo(w * 0.07, y + 30)
          ..lineTo(w * 0.13, y + 30)
          ..close();
        canvas.drawPath(a, _line);
        canvas.drawCircle(Offset(w * 0.9, y + 18), 10, _line);
        final double px = w * 0.1 + w * 0.8 * (2 / 6);
        canvas.drawLine(Offset(px, y - 60), Offset(px, y - 10), _line..strokeWidth = 3);
        canvas.drawPath(Path()
          ..moveTo(px - 7, y - 22)
          ..lineTo(px + 7, y - 22)
          ..lineTo(px, y - 9)
          ..close(), _fill(accent));
        _text(canvas, '30 kN', Offset(px, y - 72));
        _text(canvas, 'A', Offset(w * 0.1, y + 44));
        _text(canvas, 'B', Offset(w * 0.9, y + 44));
        _text(canvas, '2 m', Offset((w * 0.1 + px) / 2, y + 60), size: 11);
        _text(canvas, '4 m', Offset((px + w * 0.9) / 2, y + 60), size: 11);
      case 'circuit':
        final Rect r = Rect.fromLTWH(w * 0.15, h * 0.2, w * 0.7, h * 0.6);
        canvas.drawRect(r, _line);
        canvas.drawRect(Rect.fromCenter(center: Offset(r.center.dx, r.top), width: 70, height: 18), _fill(accent.withValues(alpha: 0.3)));
        _text(canvas, 'R1 4 Ω', Offset(r.center.dx, r.top - 20));
        canvas.drawRect(Rect.fromCenter(center: Offset(r.right, r.center.dy), width: 18, height: 60), _fill(accent.withValues(alpha: 0.3)));
        _text(canvas, 'R2 6 Ω', Offset(r.right + 38, r.center.dy));
        canvas.drawLine(Offset(r.left - 14, r.center.dy - 6), Offset(r.left + 14, r.center.dy - 6), _line..strokeWidth = 3);
        canvas.drawLine(Offset(r.left - 8, r.center.dy + 6), Offset(r.left + 8, r.center.dy + 6), _line..strokeWidth = 3);
        _text(canvas, '12 V', Offset(r.left - 36, r.center.dy));
      case 'gears':
        void gear(Offset c, double rad, int teeth, Color col) {
          canvas.drawCircle(c, rad, _fill(col));
          for (int i = 0; i < teeth; i++) {
            final double t = i * 2 * math.pi / teeth;
            canvas.drawLine(c + Offset(math.cos(t), math.sin(t)) * rad, c + Offset(math.cos(t), math.sin(t)) * (rad + 8), _line);
          }
        }
        gear(Offset(w * 0.3, h * 0.5), h * 0.14, 20, accent.withValues(alpha: 0.35));
        gear(Offset(w * 0.3 + h * 0.14 + h * 0.4 + 6, h * 0.5), h * 0.4, 60, ink.withValues(alpha: 0.15));
        _text(canvas, '20 T', Offset(w * 0.3, h * 0.5));
        _text(canvas, '60 T', Offset(w * 0.3 + h * 0.54 + 6, h * 0.5));
      case 'airfoil':
        final Path p = Path()
          ..moveTo(w * 0.15, h * 0.55)
          ..quadraticBezierTo(w * 0.35, h * 0.25, w * 0.85, h * 0.5)
          ..quadraticBezierTo(w * 0.4, h * 0.62, w * 0.15, h * 0.55)
          ..close();
        canvas.drawPath(p, _fill(accent.withValues(alpha: 0.35)));
        canvas.drawPath(p, _line);
        canvas.drawLine(Offset(w * 0.45, h * 0.42), Offset(w * 0.45, h * 0.12), _line..strokeWidth = 3);
        _text(canvas, 'Lift', Offset(w * 0.45, h * 0.07));
        for (int i = 0; i < 3; i++) {
          canvas.drawLine(Offset(w * 0.02, h * (0.4 + i * 0.1)), Offset(w * 0.12, h * (0.4 + i * 0.1)), _line..strokeWidth = 1.5);
        }
      default:
        break;
    }
    for (int i = 0; i < markers.length; i++) {
      final Offset c = Offset(markers[i].dx * w, markers[i].dy * h);
      final bool done = i < labels.length && labels[i] != null;
      canvas.drawCircle(c, 13, _fill(done ? const Color(0xFF22C55E) : accent));
      _text(canvas, '${i + 1}', c, color: Colors.white, size: 12);
    }
  }

  @override
  bool shouldRepaint(covariant _DiagramPainter old) =>
      old.id != id || old.markers != markers || old.labels != labels || old.ink != ink;
}
