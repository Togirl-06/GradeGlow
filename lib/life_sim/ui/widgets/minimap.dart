import 'package:flutter/material.dart';

import '../../world/city_map.dart';
import '../../world/world_model.dart';
import '../life_widgets.dart';

/// Compact city overview — districts as tiles, player as a glowing dot.
class LifeMinimap extends StatelessWidget {
  const LifeMinimap({
    super.key,
    required this.playerX,
    required this.playerY,
    this.onTap,
    this.size = 112,
  });

  final double playerX;
  final double playerY;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: size,
          height: size * 0.72,
          decoration: BoxDecoration(
            color: LifeColors.panel.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: LifeColors.line),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: CustomPaint(
              painter: _MiniPainter(playerX: playerX, playerY: playerY),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniPainter extends CustomPainter {
  _MiniPainter({required this.playerX, required this.playerY});

  final double playerX;
  final double playerY;

  @override
  void paint(Canvas canvas, Size size) {
    final CityMap map = CityMap.instance;
    final double cellW = size.width / CityMap.cols;
    final double cellH = size.height / CityMap.rows;

    for (final District d in CityMap.districts) {
      final Rect r = Rect.fromLTWH(d.col * cellW, d.row * cellH, cellW - 1.5, cellH - 1.5);
      final Paint fill = Paint()..color = Color(d.color).withValues(alpha: 0.55);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), fill);
    }

    // Building dots.
    final Paint bPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (final Building b in map.buildings) {
      final double bx = (b.doorX / CityMap.width) * size.width;
      final double by = (b.doorY / CityMap.height) * size.height;
      canvas.drawCircle(Offset(bx, by), 1.6, bPaint);
    }

    // Player.
    final double px = (playerX / CityMap.width) * size.width;
    final double py = (playerY / CityMap.height) * size.height;
    canvas.drawCircle(Offset(px, py), 5, Paint()..color = const Color(0xFFF97316));
    canvas.drawCircle(Offset(px, py), 3.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _MiniPainter old) =>
      old.playerX != playerX || old.playerY != playerY;
}
