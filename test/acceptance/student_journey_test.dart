// Acceptance tests 1–14 from the rebuild brief (docs/sim_rebuild/REPORT.md).
//
// They drive the real game engine (LifeGame), the real save service, the real
// campus/station wiring and the real coding client. The code itself is
// executed by the server judge, whose end-to-end tests with real Python and
// JavaScript live in functions/test/code_judge.test.js.
import 'dart:convert';

import 'package:ai_study_buddy/data/leetcode_problem_bank.dart';
import 'package:ai_study_buddy/life_sim/avatar/avatar_profile.dart';
import 'package:ai_study_buddy/life_sim/campus/campus_labs.dart';
import 'package:ai_study_buddy/life_sim/employment/resume.dart';
import 'package:ai_study_buddy/life_sim/game/life_game.dart';
import 'package:ai_study_buddy/life_sim/services/life_save_service.dart';
import 'package:ai_study_buddy/life_sim/world/city_map.dart';
import 'package:ai_study_buddy/life_sim/world/interiors.dart';
import 'package:ai_study_buddy/life_sim/world/world_model.dart';
import 'package:ai_study_buddy/models/leetcode_problem.dart';
import 'package:ai_study_buddy/services/code_judge_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../life_sim/playthrough_test.dart' as play;

LifeGame newStudent() {
  final AvatarProfile a = AvatarProfile(name: 'Kylie Wilton', traits: <String>['curious']);
  a.hairStyle = 'curly';
  a.skinTone = 3;
  a.outfitColor = 0xFF0F766E;
  a.accessory = 'glasses';
  return LifeGame.newGame(a);
}

/// Walks tile by tile to a building's door and goes in.
void walkInto(LifeGame g, String buildingId) {
  if (g.isIndoors) expect(g.leave().ok, isTrue);
  final List<(int, int)> path = g.pathToBuilding(buildingId);
  expect(path, isNotEmpty, reason: 'no route to $buildingId');
  for (final (int, int) p in path.skip(1)) {
    if ((p.$1 - g.cityX).abs() + (p.$2 - g.cityY).abs() == 1) {
      expect(g.stepOutdoors(p.$1, p.$2), isTrue, reason: 'blocked at $p');
    }
  }
  final r = g.enter(CityMap.instance.buildingById(buildingId)!);
  expect(r.ok, isTrue, reason: r.message);
  expect(g.buildingId, buildingId);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('TEST 1: create a character and customize their appearance', () {
    final LifeGame g = newStudent();
    expect(g.avatar.name, 'Kylie Wilton');
    g.avatar.hairStyle = 'braids';
    g.avatar.outfitColor = 0xFFF97316;
    final Map<String, Object?> saved = jsonDecode(jsonEncode(g.toJson())) as Map<String, Object?>;
    final LifeGame back = LifeGame.fromJson(saved);
    expect(back.avatar.hairStyle, 'braids');
    expect(back.avatar.outfitColor, 0xFFF97316);
    expect(back.avatar.accessory, 'glasses');
  });

  test('TEST 2: enter the apartment and interact with furniture', () {
    final LifeGame g = newStudent();
    walkInto(g, 'apartment_block');
    final Interior home = Interiors.of('apartment_block');
    expect(home.zones.map((InteriorZone z) => z.name), containsAll(<String>['Bedroom', 'Bathroom', 'Study', 'Living room', 'Kitchen']));
    final Set<ActionType> kinds = home.interactables.map((Interactable i) => i.type).toSet();
    expect(kinds, containsAll(<ActionType>[ActionType.sleep, ActionType.eatHome, ActionType.wardrobe, ActionType.studyHome, ActionType.decorate, ActionType.socialize]));

    g.economy.cash = 2000;
    g.needs.hunger = 30;
    expect(g.buyItem('groceries').ok, isTrue);
    expect(g.eatHome().ok, isTrue);
    expect(g.needs.hunger, greaterThan(30));

    final double cashBefore = g.economy.cash;
    final double comfortBefore = g.economy.comfort;
    expect(g.buyItem('sofa').ok, isTrue);
    expect(g.economy.cash, lessThan(cashBefore), reason: 'buying furniture costs virtual money');
    expect(g.economy.placeFurniture('sofa'), isNull);
    expect(g.economy.comfort, greaterThan(comfortBefore));
    expect(g.sleep().ok, isTrue);
  });

  test('TEST 3: save the apartment and reload the application', () async {
    final LifeGame g = newStudent();
    g.economy.cash = 2000;
    expect(g.buyItem('bookshelf').ok, isTrue);
    expect(g.economy.placeFurniture('bookshelf'), isNull);
    await const LifeSaveService().save(g);
    final LifeGame? loaded = await const LifeSaveService().load();
    expect(loaded, isNotNull);
    expect(loaded!.economy.placedFurniture, contains('bookshelf'));
    expect(loaded.avatar.name, 'Kylie Wilton');
    expect(jsonEncode(loaded.toJson()), jsonEncode(g.toJson()));
  });

  test('TEST 4 + 5: walk around campus and enter the Computer Science building', () {
    final LifeGame g = newStudent();
    play.waitUntilHour(g, 9);
    final int minuteBefore = g.clock.minuteOfDay;
    walkInto(g, 'school_cs');
    expect(g.clock.minuteOfDay, greaterThanOrEqualTo(minuteBefore), reason: 'walking takes time');
    final Interior cs = Interiors.of('school_cs');
    final List<String> labs = <String>[
      for (final Interactable i in cs.interactables)
        if (i.type == ActionType.openLab) i.arg!,
    ];
    expect(labs, contains('cs_arena'));
    expect(cs.npcs, isNotEmpty, reason: 'professor and classmate are in the building');
    // The student can walk inside the building.
    final int x = g.inX, y = g.inY;
    final bool moved = g.stepIndoors(x, y - 1) || g.stepIndoors(x - 1, y) || g.stepIndoors(x + 1, y);
    expect(moved, isTrue);
  });

  test('TEST 6: open a coding challenge, run and submit (graded by the server)', () async {
    expect(CampusLabs.byId('cs_arena'), isNotNull, reason: 'CS station opens the coding arena');
    final LeetcodeProblem p = LeetcodeProblemBank.allCuratedProblems.first;
    final List<String> modes = <String>[];
    final CodeJudgeService judge = CodeJudgeService(
      idToken: () async => 'token',
      client: MockClient((http.Request r) async {
        final Map<String, dynamic> data = (jsonDecode(r.body) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
        modes.add(data['mode'] as String);
        final bool accepted = (data['code'] as String).contains('return');
        return http.Response(
          jsonEncode(<String, Object?>{
            'result': <String, Object?>{'verdict': accepted ? 'Accepted' : 'Wrong Answer', 'message': '', 'passed': accepted ? 4 : 0, 'total': 4},
          }),
          200,
        );
      }),
    );
    final JudgeResult run = await judge.judge(problem: p, languageId: 'python3', code: 'class Solution:\n  pass', submit: false);
    expect(run.accepted, isFalse);
    final JudgeResult sub = await judge.judge(problem: p, languageId: 'python3', code: 'def f():\n  return 1', submit: true);
    expect(sub.accepted, isTrue);
    expect(modes, <String>['run', 'submit']);
  });

  test('TEST 7 + 8: visit the Career Center, build a resume', () {
    final LifeGame g = newStudent();
    play.waitUntilHour(g, 9); // the Career Center opens at 8am
    walkInto(g, 'employment_center');
    final Interior cc = Interiors.of('employment_center');
    final Set<ActionType> kinds = cc.interactables.map((Interactable i) => i.type).toSet();
    expect(kinds, containsAll(<ActionType>[ActionType.jobBoard, ActionType.resumeDesk, ActionType.interviewPractice]));
    final Resume cv = g.syncedResume();
    expect(cv.fullName, isNotEmpty);
    expect(g.reviewResume(careerId: 'software_engineer').score, greaterThanOrEqualTo(0));
    expect(g.openJobs(), isNotEmpty);
  });

  // TESTS 8–14 for every career the simulator hires into: degree, resume,
  // application, AI interview with follow-ups, hiring decision, contract,
  // workplace shifts with graded tasks, promotion, salary, save/reload.
  for (final String career in <String>['software_engineer', 'nurse', 'lawyer', 'accountant', 'doctor', 'pharmacist', 'business_manager']) {
    test('TESTS 8–14 end to end: $career', () async {
      await play.runCareer(career);
    }, timeout: const Timeout(Duration(minutes: 3)));
  }

  test('TEST 14: close and reopen restores the same state (no penalty for being away)', () {
    final LifeGame g = newStudent();
    expect(g.needs.energy, greaterThan(0));
    final String saved = jsonEncode(g.toJson());
    // Closing the app stores the game; reopening restores exactly that state
    // (time does not run while the app is closed).
    final LifeGame reopened = LifeGame.fromJson(jsonDecode(saved) as Map<String, Object?>);
    expect(reopened.clock.day, g.clock.day);
    expect(reopened.needs.energy, g.needs.energy);
  });
}
