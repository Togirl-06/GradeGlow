import 'package:ai_study_buddy/life_sim/world/city_map.dart';
import 'package:ai_study_buddy/life_sim/world/interiors.dart';
import 'package:ai_study_buddy/life_sim/world/npc_motion.dart';
import 'package:ai_study_buddy/life_sim/world/world_model.dart';

int passed = 0, failed = 0;
void check(String name, bool ok) {
  if (ok) {
    passed++;
  } else {
    failed++;
    print('FAIL: $name');
  }
}

void main() {
  int npcs = 0, movers = 0;
  for (final Building b in CityMap.instance.buildings) {
    final Interior it = Interiors.of(b.id);
    for (final NpcDef n in it.npcs) {
      npcs++;
      bool moved = false;
      bool inBounds = true;
      bool onFree = true;
      for (double s = 0; s < 120; s += 0.25) {
        // Tuesday 10:00 -> working radius; Tuesday 12:30 -> break radius.
        for (final int minute in <int>[600, 750]) {
          final NpcState st = NpcMotion.stateAt(it, n, s, 2, minute);
          if (st.x < 0 || st.y < 0 || st.x > it.width - 1 || st.y > it.height - 1) inBounds = false;
          final int rx = st.x.round(), ry = st.y.round();
          if (!(rx == n.x && ry == n.y) && it.blocked(rx, ry)) onFree = false;
          if (st.walking) moved = true;
        }
      }
      if (moved) movers++;
      check('${b.id}/${n.id} in bounds', inBounds);
      check('${b.id}/${n.id} never inside furniture', onFree);
      // Resting NPCs stay put.
      final NpcState r = NpcMotion.stateAt(it, n, 33, 2, 22 * 60);
      check('${b.id}/${n.id} rests at post', r.x == n.x && r.y == n.y && !r.walking);
      // Deterministic.
      final NpcState a = NpcMotion.stateAt(it, n, 17.3, 2, 600);
      final NpcState c = NpcMotion.stateAt(it, n, 17.3, 2, 600);
      check('${b.id}/${n.id} deterministic', a.x == c.x && a.y == c.y);
    }
  }
  check('some NPCs exist', npcs >= 20);
  check('most NPCs walk around', movers >= npcs * 0.6);
  final NpcDef n0 = Interiors.of('university').npcs.first;
  check('weekend off duty', NpcMotion.activityAt(n0, 6, 600) == NpcActivity.resting);
  check('lunch break', NpcMotion.activityAt(n0, 2, 12 * 60 + 10) == NpcActivity.onBreak);
  check('working hours', NpcMotion.activityAt(n0, 2, 10 * 60) == NpcActivity.working);
  print('NPCs: $npcs, walking: $movers');
  print(failed == 0 ? 'ALL PASSED: $passed passed, 0 failed' : 'FAILED: $failed');
}
