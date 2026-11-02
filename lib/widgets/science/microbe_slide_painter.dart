import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/microbiology_specimen.dart';

class MicrobeSlidePainter extends CustomPainter {
  MicrobeSlidePainter({required this.shape});

  final MicrobeShape shape;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1A237E));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(8, 8, size.width - 16, size.height - 16), const Radius.circular(12)),
      Paint()..color = const Color(0xFFE8F5E9).withValues(alpha: 0.15),
    );

    final Offset center = Offset(size.width * 0.5, size.height * 0.5);
    final Paint microbe = Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.9);

    switch (shape) {
      case MicrobeShape.cocci:
        for (int i = 0; i < 8; i++) {
          final double a = i / 8 * math.pi * 2;
          canvas.drawCircle(center + Offset(math.cos(a) * 30, math.sin(a) * 30), 10, microbe);
        }
      case MicrobeShape.bacilli:
        for (int i = 0; i < 5; i++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width * 0.3 + i * 22, center.dy), width: 18, height: 40), const Radius.circular(6)),
            microbe,
          );
        }
      case MicrobeShape.spirilla:
        final Path spiral = Path();
        for (double t = 0; t <= 1; t += 0.02) {
          final Offset p = Offset(size.width * (0.2 + t * 0.6), center.dy + math.sin(t * math.pi * 6) * 25);
          t == 0 ? spiral.moveTo(p.dx, p.dy) : spiral.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(spiral, microbe..style = PaintingStyle.stroke..strokeWidth = 5);
      case MicrobeShape.icosahedral:
        canvas.drawCircle(center, 45, microbe);
        canvas.drawCircle(center, 45, Paint()..color = Colors.white38..style = PaintingStyle.stroke..strokeWidth = 2);
      case MicrobeShape.helical:
        final Path helix = Path();
        for (double t = 0; t <= 1; t += 0.02) {
          final Offset p = Offset(size.width * (0.25 + t * 0.5), center.dy + math.sin(t * math.pi * 8) * 18);
          t == 0 ? helix.moveTo(p.dx, p.dy) : helix.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(helix, Paint()..color = const Color(0xFFEF5350)..strokeWidth = 8..style = PaintingStyle.stroke);
      case MicrobeShape.bacteriophage:
        canvas.drawPolygon(center + const Offset(0, -20), 6, 35, Paint()..color = const Color(0xFF42A5F5));
        canvas.drawRect(Rect.fromCenter(center: center.translate(0, 25), width: 12, height: 50), Paint()..color = const Color(0xFF78909C));
      case MicrobeShape.hyphae:
        for (int i = 0; i < 6; i++) {
          canvas.drawLine(Offset(20, 30 + i * 18), Offset(size.width - 20, 40 + i * 14), microbe..strokeWidth = 3..style = PaintingStyle.stroke);
        }
      case MicrobeShape.yeast:
        canvas.drawCircle(center.translate(-20, 0), 22, microbe);
        canvas.drawCircle(center.translate(10, -8), 14, microbe..color = const Color(0xFF81C784));
      case MicrobeShape.spore:
        canvas.drawOval(Rect.fromCenter(center: center.translate(0, 15), width: 70, height: 40), Paint()..color = const Color(0xFF8D6E63));
        for (int i = 0; i < 12; i++) {
          final double a = i / 12 * math.pi * 2;
          canvas.drawCircle(center + Offset(math.cos(a) * 8, -25 + math.sin(a) * 4), 3, Paint()..color = Colors.white70);
        }
    }
  }

  @override
  bool shouldRepaint(MicrobeSlidePainter oldDelegate) => oldDelegate.shape != shape;
}

extension on Canvas {
  void drawPolygon(Offset center, int sides, double radius, Paint paint) {
    final Path path = Path();
    for (int i = 0; i < sides; i++) {
      final double a = (i / sides) * math.pi * 2 - math.pi / 2;
      final Offset p = center + Offset(math.cos(a) * radius, math.sin(a) * radius);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    drawPath(path, paint);
  }
}
