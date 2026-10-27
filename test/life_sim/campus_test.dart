import 'package:ai_study_buddy/life_sim/campus/campus_labs.dart';
import 'package:ai_study_buddy/life_sim/campus/campus_schools.dart';
import 'package:ai_study_buddy/life_sim/campus/lab_info.dart';
import 'package:ai_study_buddy/life_sim/campus/real_cases.dart';
import 'package:ai_study_buddy/life_sim/world/city_map.dart';
import 'package:ai_study_buddy/life_sim/world/interiors.dart';
import 'package:ai_study_buddy/life_sim/world/world_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every school has its own building on the map', () {
    expect(CityMap.schoolIds.toSet(), kSchools.map((SchoolDef s) => s.id).toSet());
    for (final SchoolDef s in kSchools) {
      expect(CityMap.instance.buildingById(s.id), isNotNull, reason: s.id);
    }
  });

  test('every school building has a station for each of its labs, a lecture room and a professor', () {
    for (final SchoolDef s in kSchools) {
      final Interior it = Interiors.of(s.id);
      final Set<String> placed = <String>{
        for (final Interactable i in it.interactables)
          if (i.type == ActionType.openLab) i.arg ?? '',
      };
      final List<LabInfo> labs = labsOfSchool(s.id);
      expect(labs.length, inInclusiveRange(2, 8), reason: s.id);
      for (final LabInfo l in labs) {
        expect(placed.contains(l.id), true, reason: '${s.id} missing ${l.id}');
      }
      expect(it.interactables.any((Interactable i) => i.type == ActionType.lectureHall), true, reason: s.id);
      expect(it.npcs.any((NpcDef n) => n.id == s.professor.id), true, reason: s.id);
    }
  });

  test('every lab station opens a real screen', () {
    final Set<String> ids = <String>{};
    for (final LabInfo l in kCampusLabs) {
      expect(ids.add(l.id), true, reason: 'duplicate ${l.id}');
      expect(CampusLabs.byId(l.id), isNotNull, reason: l.id);
    }
    expect(CampusLabs.all.length, kCampusLabs.length);
  });

  test('the apartment has separate rooms joined by doorways', () {
    final Interior it = Interiors.of('apartment_block');
    expect(it.zones.map((InteriorZone z) => z.name), containsAll(<String>['Bedroom', 'Bathroom', 'Study', 'Living room', 'Kitchen']));
    expect(it.blocked(4, 1), true); // wall between bedroom and bathroom
    expect(it.blocked(2, 4), false); // bedroom doorway
    expect(it.zoneAt(1, 1)?.name, 'Bedroom');
  });

  test('real cases are well formed', () {
    expect(RealCases.all.length, greaterThanOrEqualTo(8));
    for (final RealCase c in RealCases.all) {
      expect(c.predictAnswer, inInclusiveRange(0, c.predictOptions.length - 1), reason: c.id);
      expect(c.questions, isNotEmpty, reason: c.id);
      for (final CaseQuestion q in c.questions) {
        expect(q.answer, inInclusiveRange(0, q.options.length - 1), reason: '${c.id}: ${q.prompt}');
      }
    }
  });
}
