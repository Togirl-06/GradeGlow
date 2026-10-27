import 'package:ai_study_buddy/life_sim/careers/career_catalog.dart';
import 'package:ai_study_buddy/life_sim/employment/employers.dart';
import 'package:ai_study_buddy/life_sim/workplace/task_bank.dart';
import 'package:ai_study_buddy/life_sim/world/city_map.dart';
import 'package:ai_study_buddy/life_sim/world/interiors.dart';
import 'package:ai_study_buddy/life_sim/world/world_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final CityMap city = CityMap.instance;

  test('10 districts, each with at least one building', () {
    expect(CityMap.districts.length, 10);
    for (final District d in CityMap.districts) {
      expect(city.buildings.where((Building b) => b.districtId == d.id).isNotEmpty, true, reason: d.id);
    }
  });

  test('building ids unique, doors walkable and reachable from spawn', () {
    final Set<String> ids = <String>{};
    final Building spawn = city.buildings.first;
    for (final Building b in city.buildings) {
      expect(ids.add(b.id), true, reason: b.id);
      expect(city.walkable(b.doorX, b.doorY), true, reason: b.id);
      final List<(int, int)> p = city.path(spawn.doorX, spawn.doorY, b.doorX, b.doorY);
      expect(p.isNotEmpty, true, reason: '${b.id} unreachable');
    }
  });

  test('every employer building exists and matches its employer', () {
    for (final Employer e in EmployerCatalog.all) {
      final Building? b = city.buildingById(e.buildingId);
      expect(b, isNotNull, reason: e.id);
      expect(b!.employerId, e.id);
    }
  });

  test('interiors: no overlaps, everything reachable, exit open', () {
    for (final Building b in city.buildings) {
      final Interior it = Interiors.of(b.id);
      final Set<String> cells = <String>{};
      for (final Interactable i in it.interactables) {
        expect(cells.add('${i.x},${i.y}'), true, reason: '${b.id} overlap at ${i.x},${i.y}');
        expect(i.x >= 0 && i.y >= 0 && i.x < it.width && i.y < it.height, true);
      }
      for (final NpcDef n in it.npcs) {
        expect(cells.add('${n.x},${n.y}'), true, reason: '${b.id} npc overlap ${n.id}');
      }
      expect(cells.contains('${it.exitX},${it.exitY}'), false, reason: '${b.id} exit blocked');
      for (final Interactable i in it.interactables) {
        final bool reach = <(int, int)>[(1, 0), (-1, 0), (0, 1), (0, -1)].any(((int, int) d) {
          final int x = i.x + d.$1, y = i.y + d.$2;
          return !it.blocked(x, y) && bfs(it.width, it.height, it.exitX, it.exitY, x, y, (int a, int c) => !it.blocked(a, c)).isNotEmpty;
        });
        expect(reach, true, reason: '${b.id}/${i.id} unreachable');
      }
      for (final NpcDef n in it.npcs) {
        final bool reach = <(int, int)>[(1, 0), (-1, 0), (0, 1), (0, -1)].any(((int, int) d) {
          final int x = n.x + d.$1, y = n.y + d.$2;
          return !it.blocked(x, y) && bfs(it.width, it.height, it.exitX, it.exitY, x, y, (int a, int c) => !it.blocked(a, c)).isNotEmpty;
        });
        expect(reach, true, reason: '${b.id}/${n.id} unreachable npc');
      }
    }
  });

  test('every career station id with tasks has a world station in some hiring employer', () {
    for (final CareerDef c in CareerCatalog.all) {
      final Set<String> need = WorkTaskBank.stationsFor(c.id);
      for (final String s in need) {
        bool found = false;
        for (final Employer e in EmployerCatalog.all.where((Employer e) => e.hires.contains(c.id))) {
          final Interior it = Interiors.of(e.buildingId);
          if (it.interactables.any((Interactable i) => i.type == ActionType.workStation && i.arg == s)) found = true;
        }
        expect(found, true, reason: '${c.id} station $s missing');
      }
    }
  });

  test('key services exist somewhere in the world', () {
    final Set<ActionType> have = <ActionType>{};
    for (final Building b in city.buildings) {
      for (final Interactable i in Interiors.of(b.id).interactables) {
        have.add(i.type);
      }
    }
    for (final ActionType t in <ActionType>[
      ActionType.sleep, ActionType.eatHome, ActionType.laptop, ActionType.wardrobe, ActionType.decorate,
      ActionType.payBills, ActionType.shop, ActionType.bank, ActionType.jobBoard, ActionType.resumeDesk,
      ActionType.interviewPractice, ActionType.hrDesk, ActionType.clockIn, ActionType.workStation,
      ActionType.enrolDesk, ActionType.lectureHall, ActionType.examHall, ActionType.studyDesk,
      ActionType.certDesk, ActionType.watchMovie, ActionType.workout, ActionType.relaxPark,
      ActionType.companyRegistry, ActionType.observeCourt, ActionType.breakRoom,
    ]) {
      expect(have.contains(t), true, reason: '$t');
    }
  });
}
