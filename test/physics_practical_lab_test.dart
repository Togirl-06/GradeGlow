import 'package:flutter_test/flutter_test.dart';
import 'package:ai_study_buddy/data/physics/physics_practical_lab_catalog.dart';

void main() {
  test('practical lab catalog has 11 experiments', () {
    expect(PhysicsPracticalLabCatalog.all.length, 11);
    expect(PhysicsPracticalLabCatalog.all.first.title, 'Gravity Drop');
  });

  test('each practical resolves to a topic', () {
    for (final PhysicsPracticalLab p in PhysicsPracticalLabCatalog.all) {
      expect(p.track, isNotNull, reason: p.id);
      expect(p.course, isNotNull, reason: p.id);
      expect(p.topic, isNotNull, reason: p.id);
    }
  });
}
