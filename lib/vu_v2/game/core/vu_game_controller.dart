import 'dart:math' as math;

import '../models/vu_game_models.dart';

/// Movement, collision, and proximity for a single floor instance.
class VuGameController {
  VuGameController({
    required this.layout,
    this.playerRadius = 14,
    this.moveSpeed = 200,
  }) : player = layout.playerSpawn;

  final VuGameWorldLayout layout;
  final double playerRadius;
  final double moveSpeed;

  VuGameVec2 player;
  VuGameVec2? moveTarget;

  String? zoneAtPlayer() {
    for (final VuGameZone z in layout.zones) {
      if (z.bounds.contains(player)) return z.id;
    }
    return null;
  }

  String? zoneNameAtPlayer() {
    for (final VuGameZone z in layout.zones) {
      if (z.bounds.contains(player)) return z.name;
    }
    return null;
  }

  void setMoveTarget(VuGameVec2 target) {
    moveTarget = _clampToWorld(target);
  }

  void tick(double dtSeconds) {
    final VuGameVec2? target = moveTarget;
    if (target == null) return;

    final double dist = player.distanceTo(target);
    if (dist < 4) {
      player = target;
      moveTarget = null;
      return;
    }

    final double step = moveSpeed * dtSeconds;
    final double t = math.min(1, step / dist);
    final VuGameVec2 next = VuGameVec2(
      player.x + (target.x - player.x) * t,
      player.y + (target.y - player.y) * t,
    );
    if (_collides(next)) {
      // Slide along axes when blocked.
      final VuGameVec2 tryX = VuGameVec2(next.x, player.y);
      final VuGameVec2 tryY = VuGameVec2(player.x, next.y);
      if (!_collides(tryX)) {
        player = tryX;
      } else if (!_collides(tryY)) {
        player = tryY;
      } else {
        moveTarget = null;
      }
    } else {
      player = next;
    }
  }

  VuGameNpc? nearestNpc({double maxDistance = 56}) {
    VuGameNpc? best;
    double bestD = maxDistance;
    for (final VuGameNpc npc in layout.npcs) {
      final double d = player.distanceTo(npc.position);
      if (d <= npc.interactRadius && d < bestD) {
        bestD = d;
        best = npc;
      }
    }
    return best;
  }

  VuGameInteractable? nearestInteractable({double maxDistance = 52}) {
    VuGameInteractable? best;
    double bestD = maxDistance;
    for (final VuGameInteractable item in layout.interactables) {
      final double d = player.distanceTo(item.position);
      if (d <= item.interactRadius && d < bestD) {
        bestD = d;
        best = item;
      }
    }
    return best;
  }

  bool _collides(VuGameVec2 p) {
    if (p.x < playerRadius ||
        p.y < playerRadius ||
        p.x > layout.worldSize.x - playerRadius ||
        p.y > layout.worldSize.y - playerRadius) {
      return true;
    }
    for (final VuGameRect wall in layout.walls) {
      if (wall.intersectsCircle(p, playerRadius)) return true;
    }
    return false;
  }

  VuGameVec2 _clampToWorld(VuGameVec2 p) {
    return VuGameVec2(
      p.x.clamp(playerRadius, layout.worldSize.x - playerRadius),
      p.y.clamp(playerRadius, layout.worldSize.y - playerRadius),
    );
  }
}
