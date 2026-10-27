import 'package:ai_study_buddy/life_sim/game/life_game.dart';
import 'package:ai_study_buddy/life_sim/world/city_map.dart';
import 'package:ai_study_buddy/life_sim/world/interiors.dart';
import 'package:ai_study_buddy/life_sim/world/world_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('walking the BFS path to every building costs time and arrives', () {
    for (final Building b in CityMap.instance.buildings) {
      final LifeGame g = LifeGame();
      g.clock.minuteOfDay = 12 * 60;
      final int before = g.absMinute;
      final List<(int, int)> path = g.pathToBuilding(b.id);
      expect(path.isNotEmpty, true, reason: b.id);
      for (int i = 1; i < path.length; i++) {
        expect(g.stepOutdoors(path[i].$1, path[i].$2), true, reason: '${b.id} step $i');
      }
      expect(g.cityX, b.doorX);
      expect(g.cityY, b.doorY);
      expect(g.absMinute >= before + (path.length - 1) ~/ 4, true);
    }
  });

  test('cannot walk into walls, diagonals, or buildings closed at night', () {
    final LifeGame g = LifeGame();
    final Building uni = CityMap.instance.buildingById('university')!;
    expect(g.stepOutdoors(g.cityX + 1, g.cityY + 1), false);
    g.cityX = uni.doorX;
    g.cityY = uni.doorY;
    expect(g.stepOutdoors(uni.doorX, uni.doorY - 1), false); // building tile
    g.clock.minuteOfDay = 23 * 60;
    expect(g.enter(uni).ok, false);
    g.clock.minuteOfDay = 10 * 60; // day 1 is Monday
    expect(g.enter(uni).ok, true);
    expect(g.buildingId, 'university');
    final Interior it = Interiors.of('university');
    expect(g.stepIndoors(it.exitX, it.exitY - 1), true);
    expect(g.leave().ok, true);
    expect(g.isIndoors, false);
  });

  test('home is always enterable', () {
    final LifeGame g = LifeGame();
    g.clock.minuteOfDay = 3 * 60;
    expect(g.enter(CityMap.instance.buildingById('apartment_block')!).ok, true);
  });
}
