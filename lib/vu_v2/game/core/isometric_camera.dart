import 'dart:math' as math;
import 'dart:ui';

import '../models/vu_game_models.dart';

/// Sims-like 2.5D isometric projection for GradeGlow worlds.
class VuGameViewTransform {
  VuGameViewTransform({
    required this.worldSize,
    required this.viewSize,
    this.follow,
  }) {
    // Fit world diamond into view.
    final double worldScreenW = (worldSize.x + worldSize.y) * 0.5;
    final double worldScreenH = (worldSize.x + worldSize.y) * 0.25;
    final double sx = viewSize.width / (worldScreenW + 80);
    final double sy = viewSize.height / (worldScreenH + 120);
    scale = math.min(sx, sy).clamp(0.35, 1.6);

    final Offset focus = follow != null
        ? _project(follow!)
        : _project(VuGameVec2(worldSize.x * 0.5, worldSize.y * 0.55));

    offset = Offset(
      viewSize.width * 0.5 - focus.dx,
      viewSize.height * 0.42 - focus.dy,
    );
  }

  final VuGameVec2 worldSize;
  final Size viewSize;
  final VuGameVec2? follow;
  late final double scale;
  late final Offset offset;

  Offset _project(VuGameVec2 world) {
    final double x = (world.x - world.y) * scale * 0.5;
    final double y = (world.x + world.y) * scale * 0.25;
    return Offset(x, y);
  }

  Offset worldToScreen(VuGameVec2 world) {
    final Offset p = _project(world);
    return Offset(p.dx + offset.dx, p.dy + offset.dy);
  }

  /// Approximate inverse for tap-to-move (good enough for gameplay).
  VuGameVec2 screenToWorld(Offset screen) {
    final double sx = screen.dx - offset.dx;
    final double sy = screen.dy - offset.dy;
    final double a = sx / (scale * 0.5);
    final double b = sy / (scale * 0.25);
    return VuGameVec2((a + b) * 0.5, (b - a) * 0.5);
  }

  double worldToScreenDistance(double worldUnits) => worldUnits * scale * 0.55;

  /// Isometric diamond for an axis-aligned world rect.
  List<Offset> rectToIso(VuGameRect r) {
    return <Offset>[
      worldToScreen(VuGameVec2(r.x, r.y)),
      worldToScreen(VuGameVec2(r.x + r.w, r.y)),
      worldToScreen(VuGameVec2(r.x + r.w, r.y + r.h)),
      worldToScreen(VuGameVec2(r.x, r.y + r.h)),
    ];
  }
}
