import 'package:ai_study_buddy/vu_v2/game/core/vu_game_controller.dart';
import 'package:ai_study_buddy/vu_v2/game/nursing/nursing_floor_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('layout exposes nursing NPCs and interactables', () {
    final layout = NursingFloorLayout.build();
    expect(layout.npcs.any((n) => n.id == 'diaz'), isTrue);
    expect(layout.interactables.any((i) => i.actionId == 'check_monitor'), isTrue);
  });

  test('tick moves player toward target', () {
    final layout = NursingFloorLayout.build();
    final VuGameController c = VuGameController(layout: layout);
    final double startX = c.player.x;
    c.setMoveTarget(layout.npcs.firstWhere((n) => n.id == 'diaz').position);
    for (int i = 0; i < 60; i++) {
      c.tick(1 / 30);
    }
    expect(c.player.x - startX, greaterThan(10));
  });
}
