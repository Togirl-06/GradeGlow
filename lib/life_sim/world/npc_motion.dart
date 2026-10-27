import '../core/stable_random.dart';
import 'city_map.dart' show bfs;
import 'world_model.dart';

/// What an NPC is doing at a given game time.
enum NpcActivity { working, onBreak, resting }

/// Where an NPC is, and what it looks like it is doing, at a moment in time.
class NpcState {
  const NpcState(this.x, this.y, this.walking, this.facingRight, this.activity);
  final double x;
  final double y;
  final bool walking;
  final bool facingRight;
  final NpcActivity activity;
}

/// Deterministic NPC schedules and wandering inside interiors.
///
/// Schedule: weekdays 9–12 and 13–17 NPCs are at work (pace near their post),
/// 12–13 they take a break (wander the room), otherwise they rest at their post.
/// Motion depends only on (building, npc, seconds), so it needs no stored state
/// and is easy to test.
class NpcMotion {
  const NpcMotion._();

  static NpcActivity activityAt(NpcDef n, int day, int minuteOfDay) {
    final bool weekday = ((day - 1) % 7) < 5;
    final bool shopRole = n.role.toLowerCase().contains('barista') ||
        n.role.toLowerCase().contains('local') ||
        n.role.toLowerCase().contains('clerk');
    if (!weekday && !shopRole) return NpcActivity.resting;
    if (minuteOfDay >= 12 * 60 && minuteOfDay < 13 * 60) return NpcActivity.onBreak;
    if (minuteOfDay >= 9 * 60 && minuteOfDay < 17 * 60) return NpcActivity.working;
    return NpcActivity.resting;
  }

  static int _radius(NpcActivity a) => switch (a) {
        NpcActivity.working => 2,
        NpcActivity.onBreak => 4,
        NpcActivity.resting => 0,
      };

  static String activityLabel(NpcActivity a) => switch (a) {
        NpcActivity.working => 'working',
        NpcActivity.onBreak => 'on a break',
        NpcActivity.resting => 'off duty',
      };

  static final Map<String, _Route> _cache = <String, _Route>{};

  static NpcState stateAt(Interior it, NpcDef n, double seconds, int day, int minuteOfDay) {
    final NpcActivity act = activityAt(n, day, minuteOfDay);
    final int r = _radius(act);
    if (r == 0) return NpcState(n.x.toDouble(), n.y.toDouble(), false, true, act);
    final _Route route = _cache.putIfAbsent('${it.buildingId}|${n.id}|$r', () => _Route.build(it, n, r));
    return route.at(seconds, act);
  }

  /// All NPC states for a room.
  static Map<String, NpcState> statesFor(Interior it, double seconds, int day, int minuteOfDay) => <String, NpcState>{
        for (final NpcDef n in it.npcs) n.id: stateAt(it, n, seconds, day, minuteOfDay),
      };
}

class _Route {
  _Route(this.points, this.legEnds, this.pauseEnds, this.total, this.fallback);

  final List<(int, int)> points; // full tile path, looped
  final List<double> legEnds; // time when each leg of walking ends
  final List<double> pauseEnds;
  final double total;
  final (int, int) fallback;

  static const double secondsPerTile = 0.75;

  factory _Route.build(Interior it, NpcDef n, int radius) {
    final StableRandom rng = StableRandom.fromString('${it.buildingId}:${n.id}:$radius');
    bool ok(int x, int y) => (x == n.x && y == n.y) || !it.blocked(x, y);
    final List<(int, int)> candidates = <(int, int)>[];
    for (int dy = -radius; dy <= radius; dy++) {
      for (int dx = -radius; dx <= radius; dx++) {
        final int x = n.x + dx;
        final int y = n.y + dy;
        if ((dx != 0 || dy != 0) && ok(x, y) && !(x == it.exitX && y >= it.exitY)) candidates.add((x, y));
      }
    }
    if (candidates.isEmpty) return _Route(<(int, int)>[(n.x, n.y)], <double>[], <double>[], 1, (n.x, n.y));
    final List<(int, int)> stops = <(int, int)>[(n.x, n.y)];
    final int count = 2 + rng.nextInt(2);
    for (int i = 0; i < count; i++) {
      stops.add(candidates[rng.nextInt(candidates.length)]);
    }
    stops.add((n.x, n.y));
    final List<(int, int)> points = <(int, int)>[];
    final List<double> legEnds = <double>[];
    final List<double> pauseEnds = <double>[];
    double time = 0;
    for (int i = 0; i + 1 < stops.length; i++) {
      final List<(int, int)> p = bfs(it.width, it.height, stops[i].$1, stops[i].$2, stops[i + 1].$1, stops[i + 1].$2, ok);
      if (p.length < 2) continue;
      points.addAll(p);
      time += (p.length - 1) * secondsPerTile;
      legEnds.add(time);
      time += 3 + rng.nextInt(4);
      pauseEnds.add(time);
    }
    if (points.isEmpty) return _Route(<(int, int)>[(n.x, n.y)], <double>[], <double>[], 1, (n.x, n.y));
    return _Route(points, legEnds, pauseEnds, time, (n.x, n.y));
  }

  NpcState at(double seconds, NpcActivity act) {
    if (legEnds.isEmpty) return NpcState(fallback.$1.toDouble(), fallback.$2.toDouble(), false, true, act);
    final double t = seconds % total;
    double legStart = 0;
    int pointOffset = 0;
    for (int i = 0; i < legEnds.length; i++) {
      final double end = legEnds[i];
      // Number of tiles in this leg = (end - legStart) / secondsPerTile + 1 points.
      final int steps = ((end - legStart) / secondsPerTile).round();
      if (t < end) {
        final double f = (t - legStart) / secondsPerTile;
        final int k = f.floor().clamp(0, steps - 1);
        final double frac = f - k;
        final (int, int) a = points[pointOffset + k];
        final (int, int) b = points[pointOffset + k + 1];
        return NpcState(a.$1 + (b.$1 - a.$1) * frac, a.$2 + (b.$2 - a.$2) * frac, true, b.$1 >= a.$1, act);
      }
      if (t < pauseEnds[i]) {
        final (int, int) last = points[pointOffset + steps];
        return NpcState(last.$1.toDouble(), last.$2.toDouble(), false, true, act);
      }
      pointOffset += steps + 1;
      legStart = pauseEnds[i];
    }
    final (int, int) home = points.first;
    return NpcState(home.$1.toDouble(), home.$2.toDouble(), false, true, act);
  }
}
