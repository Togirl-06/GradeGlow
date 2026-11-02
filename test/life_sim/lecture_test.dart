import 'package:ai_study_buddy/life_sim/avatar/avatar_profile.dart';
import 'package:ai_study_buddy/life_sim/education/lectures.dart';
import 'package:ai_study_buddy/life_sim/education/university.dart';
import 'package:ai_study_buddy/life_sim/game/life_game.dart';

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
  // Every course has 4 valid lectures with a knowledge check.
  int courses = 0;
  for (final Degree d in UniversityCatalog.degrees) {
    for (final Course c in d.courses) {
      courses++;
      for (int n = 1; n <= LectureLibrary.lectureCount; n++) {
        final Lecture l = LectureLibrary.forCourse(c, n);
        check('${c.id}#$n has lines', l.lines.length >= 3);
        check('${c.id}#$n has check', l.check.isNotEmpty);
        check('${c.id}#$n check valid', l.check.every((ExamQuestion q) => q.correct >= 0 && q.correct < q.options.length && q.options.length >= 2));
        // Rotated checks keep the right answer text.
        for (final ExamQuestion q in l.check) {
          final ExamQuestion? orig = c.questions.where((ExamQuestion o) => o.prompt == q.prompt).firstOrNull;
          if (orig != null) check('${c.id}#$n rotation keeps answer', orig.options[orig.correct] == q.options[q.correct]);
        }
        check('${c.id}#$n scoring', LectureLibrary.scoreCheck(l, l.check.map((ExamQuestion q) => q.correct).toList()) == 1 && LectureLibrary.scoreCheck(l, <int?>[]) == 0);
      }
    }
  }
  check('covers all courses', courses >= 25);

  // Spec example: saying "heart" highlights the heart; "skull" the skull.
  check('heart word', LectureLibrary.organsIn('The heart pumps blood throughout the body.').contains('heart'));
  check('skull word', LectureLibrary.organsIn('The skull protects the brain.').toSet().containsAll(<String>['skull', 'brain']));
  check('no organ no highlight', LectureLibrary.organsIn('Welcome to class.').isEmpty);
  final Course anat = UniversityCatalog.courseById('nu101')!;
  final Lecture l1 = LectureLibrary.forCourse(anat, 1);
  check('scripted anatomy uses body board', l1.board == LectureBoard.body);
  check('line highlights skull', LectureLibrary.highlightsFor(l1, l1.lines[1]).contains('skull'));
  final Lecture l2 = LectureLibrary.forCourse(anat, 2);
  check('cardio lecture highlights heart', l2.lines.any((LectureLine x) => LectureLibrary.highlightsFor(l2, x).contains('heart')));
  check('concept board for CS', LectureLibrary.forCourse(UniversityCatalog.courseById('cs101')!, 1).board == LectureBoard.concepts);
  final Lecture cs = LectureLibrary.forCourse(UniversityCatalog.courseById('cs101')!, 1);
  check('terms mentioned get highlighted', cs.terms.isNotEmpty && cs.lines.any((LectureLine x) => LectureLibrary.highlightsFor(cs, x).isNotEmpty));
  check('offline professor answer uses material', LectureLibrary.offlineAnswer(anat, 'What pumps blood around the body?').contains('heart') || LectureLibrary.offlineAnswer(anat, 'What pumps blood around the body?').toLowerCase().contains('heart'));
  check('offline fallback answers anything', LectureLibrary.offlineAnswer(anat, 'zzz').isNotEmpty);

  // Game integration: knowledge check bonus
  final LifeGame g = LifeGame.newGame(AvatarProfile());
  g.economy.cash = 5000;
  final Degree nurse = UniversityCatalog.degrees.firstWhere((Degree d) => d.id == 'deg_nursing');
  check('enrol', g.enrolDegree(nurse.id).ok);
  check('enrol course', g.enrolCourse('nu101').ok);
  // Move to a weekday morning
  while (!UniversityEngine.lectureOpen(g.day, g.minute)) {
    g.advance(60);
  }
  check('lecture not blocked', g.lectureBlock('nu101') == null);
  final int before = g.university.progress('nu101').studyMinutes;
  final ActionResult r = g.attendLecture('nu101', checkScore: 1);
  check('attend ok', r.ok);
  check('bonus study minutes', g.university.progress('nu101').studyMinutes == before + 30);
  check('blocked same day', g.lectureBlock('nu101') != null);
  check('lecture count', g.university.progress('nu101').lectures == 1);
  check('next lecture is #2', LectureLibrary.forCourse(anat, g.university.progress('nu101').lectures + 1).number == 2);

  print(failed == 0 ? 'ALL PASSED: $passed passed, 0 failed' : 'FAILED: $failed');
}
