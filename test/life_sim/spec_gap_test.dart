import 'package:ai_study_buddy/life_sim/avatar/avatar_profile.dart';
import 'package:ai_study_buddy/life_sim/core/needs.dart';
import 'package:ai_study_buddy/life_sim/education/university.dart';
import 'package:ai_study_buddy/life_sim/game/life_game.dart';
import 'package:ai_study_buddy/life_sim/social/relationships.dart';
import 'package:ai_study_buddy/life_sim/world/interiors.dart';
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
  // Needs: hygiene + stress
  final PlayerNeeds n = PlayerNeeds();
  n.tick(600);
  check('hygiene decays awake', n.hygiene < 80);
  check('json roundtrip hygiene/stress', PlayerNeeds.fromJson(n.toJson()).hygiene == n.hygiene);
  check('old saves default', PlayerNeeds.fromJson(<String, Object?>{'energy': 50}).stress == 15);
  n.stress = 90;
  n.tick(480, sleeping: true);
  check('sleep relieves stress', n.stress < 60);

  final LifeGame g = LifeGame.newGame(AvatarProfile());
  g.relaxHome(shower: true);
  check('shower restores hygiene', g.needs.hygiene > 90);
  g.needs.stress = 50;
  g.relaxPark();
  check('park lowers stress', g.needs.stress < 40);

  // Relationships
  final Relationships r = Relationships();
  final double a = r.talk('x', 1);
  final double b = r.talk('x', 1);
  check('first talk bigger', a > b);
  check('talk 5x same day caps', r.talk('x', 1) <= 0.5 && r.talk('x', 1) == 0 || r.of('x').level < 8);
  for (int d = 2; d < 20; d++) {
    r.talk('x', d);
  }
  check('daily chats become friends', r.of('x').level >= 60 && Relationships.title(r.of('x').level) == 'Close friend');
  final NpcDef npc = Interiors.of('university').npcs.first;
  final LifeGame g2 = LifeGame.newGame(AvatarProfile());
  g2.talkToNpc(npc);
  check('game talk saves', LifeGame.fromJson(g2.toJson()).relationships.of(npc.id).level > 0);

  // GPA
  check('grade points', UniversityEngine.gradePoints(0.95) == 4.0 && UniversityEngine.gradePoints(0.75) == 2.0);
  final UniversityRecord rec = UniversityRecord();
  check('no gpa yet', UniversityEngine.gpa(rec) == null);
  rec.progress('c1')
    ..passed = true
    ..bestScore = 0.95;
  rec.progress('c2')
    ..passed = true
    ..bestScore = 0.85;
  check('gpa mean', UniversityEngine.gpa(rec) == 3.5);
  check('honors', UniversityEngine.honors(3.5) == 'with Distinction' && UniversityEngine.honors(3.9).contains('High') && UniversityEngine.honors(2.0).isEmpty);

  // Ceremony
  final LifeGame g3 = LifeGame.newGame(AvatarProfile(name: 'Ada'));
  check('no ceremony without degree', !g3.attendCeremony().ok);
  g3.pendingCeremonies.add('deg_cs');
  g3.university.progress('x')
    ..passed = true
    ..bestScore = 0.92;
  final ActionResult res = g3.attendCeremony();
  check('ceremony ok', res.ok && g3.certificates.length == 1 && g3.pendingCeremonies.isEmpty);
  check('certificate honors', g3.certificates.first.honors == 'with High Distinction' || g3.certificates.first.honors == 'with Distinction');
  final LifeGame g4 = LifeGame.fromJson(g3.toJson());
  check('certificate persists', g4.certificates.length == 1 && g4.certificates.first.holder == 'Ada');
  check('stage exists', Interiors.of('university').interactables.any((Interactable i) => i.type == ActionType.graduation));

  print(failed == 0 ? 'ALL PASSED: $passed passed, 0 failed' : 'FAILED: $failed');
}
