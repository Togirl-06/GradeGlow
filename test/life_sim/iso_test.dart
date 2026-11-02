import 'package:ai_study_buddy/life_sim/ui/iso.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('project/unproject round-trips and depth increases toward the viewer', () {
    const Iso iso = Iso();
    for (final (double, double) p in <(double, double)>[(0, 0), (3, 7), (12.5, 4.25), (60, 20)]) {
      final (double, double) s = iso.project(p.$1, p.$2);
      final (double, double) b = iso.unproject(s.$1, s.$2);
      expect((b.$1 - p.$1).abs() < 1e-9 && (b.$2 - p.$2).abs() < 1e-9, true);
    }
    expect(iso.depth(5, 5) > iso.depth(4, 5), true);
    final (double, double) a = iso.project(1, 0);
    expect(a.$1 > 0 && a.$2 > 0, true); // +x goes down-right
    final (double, double) c = iso.project(0, 1);
    expect(c.$1 < 0 && c.$2 > 0, true); // +y goes down-left
  });
}
