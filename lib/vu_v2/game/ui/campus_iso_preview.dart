import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Decorative isometric campus strip for Labs / dashboard (life-sim vibe).
class CampusIsoPreview extends StatelessWidget {
  const CampusIsoPreview({
    super.key,
    this.height = 148,
    this.onExplore,
  });

  final double height;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomPaint(painter: _CampusPainter()),
            Positioned(
              left: 14,
              bottom: 12,
              right: 14,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'GradeGlow Campus',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        shadows: <Shadow>[
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (onExplore != null)
                    FilledButton(
                      onPressed: onExplore,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F766E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Explore',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          const <Color>[
            Color(0xFF7EC8F0),
            Color(0xFFB8E0F5),
            Color(0xFF9CCC65),
          ],
          const <double>[0, 0.45, 1],
        ),
    );

    void building(Offset c, double w, double h, Color roof, Color wall) {
      final Path body = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: w, height: h),
            const Radius.circular(6),
          ),
        );
      canvas.drawPath(body, Paint()..color = wall);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(c.dx - w * 0.5, c.dy - h * 0.55, w, h * 0.22),
          const Radius.circular(4),
        ),
        Paint()..color = roof,
      );
      // Windows.
      for (int i = 0; i < 3; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              c.dx - w * 0.32 + i * w * 0.22,
              c.dy - h * 0.1,
              w * 0.12,
              h * 0.18,
            ),
            const Radius.circular(2),
          ),
          Paint()..color = const Color(0xFFBBDEFB),
        );
      }
    }

    building(
      Offset(size.width * 0.22, size.height * 0.55),
      70,
      54,
      const Color(0xFF8D6E63),
      const Color(0xFFECEFF1),
    );
    building(
      Offset(size.width * 0.48, size.height * 0.48),
      90,
      70,
      const Color(0xFFC62828),
      const Color(0xFFFFCCBC),
    );
    building(
      Offset(size.width * 0.78, size.height * 0.58),
      64,
      48,
      const Color(0xFF455A64),
      const Color(0xFFCFD8DC),
    );

    // Trees.
    for (final double x in <double>[0.12, 0.35, 0.62, 0.9]) {
      final Offset t = Offset(size.width * x, size.height * 0.72);
      canvas.drawCircle(t, 14, Paint()..color = const Color(0xFF66BB6A));
      canvas.drawCircle(
        t - const Offset(8, 4),
        10,
        Paint()..color = const Color(0xFF43A047),
      );
      canvas.drawRect(
        Rect.fromCenter(center: t + const Offset(0, 12), width: 5, height: 12),
        Paint()..color = const Color(0xFF6D4C41),
      );
    }

    // Avatar dots.
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.78),
      6,
      Paint()..color = const Color(0xFF10B981),
    );
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.72),
      5,
      Paint()..color = const Color(0xFFE8B796),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
