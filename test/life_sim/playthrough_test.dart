import 'dart:convert';

import 'package:ai_study_buddy/life_sim/avatar/avatar_profile.dart';
import 'package:ai_study_buddy/life_sim/careers/career_catalog.dart';
import 'package:ai_study_buddy/life_sim/economy/life_economy.dart';
import 'package:ai_study_buddy/life_sim/education/university.dart';
import 'package:ai_study_buddy/life_sim/employment/application.dart';
import 'package:ai_study_buddy/life_sim/employment/employers.dart';
import 'package:ai_study_buddy/life_sim/employment/job_listing.dart';
import 'package:ai_study_buddy/life_sim/game/life_game.dart';
import 'package:ai_study_buddy/life_sim/interview/interview_questions.dart';
import 'package:ai_study_buddy/life_sim/interview/interview_session.dart';
import 'package:ai_study_buddy/life_sim/workplace/job_state.dart';
import 'package:ai_study_buddy/life_sim/workplace/work_task.dart';
import 'package:flutter_test/flutter_test.dart';

StageAnswer ideal(WorkStage s) {
  switch (s.kind) {
    case StageKind.choice:
      return StageAnswer(choice: s.correct.first);
    case StageKind.multi:
      return StageAnswer(multi: s.correct.toSet());
    case StageKind.order:
      return StageAnswer(order: List<int>.of(s.correct));
    case StageKind.numeric:
      return StageAnswer(number: s.answer);
    case StageKind.text:
      return StageAnswer(text: s.modelAnswer);
    case StageKind.inspect:
      return StageAnswer(inspected: s.items.where((InspectItem i) => i.value == InspectValue.essential).map((InspectItem i) => i.id).toSet());
  }
}

/// Stay fed and rested so the bot behaves like a sensible player.
void care(LifeGame g) {
  if (g.needs.hunger < 45) {
    if (g.economy.count('groceries') < 1) g.buyItem('groceries');
    g.eatHome();
  }
}

void waitUntilHour(LifeGame g, int hour) {
  final int target = hour * 60;
  if (g.minute == target) return;
  g.advance(g.clock.minutesUntil(target));
}

void sleepToMorning(LifeGame g) {
  care(g);
  g.sleep();
  if (g.minute != 7 * 60) {
    g.advance(g.clock.minutesUntil(7 * 60), sleeping: true);
  }
}

void earnDegree(LifeGame g, String degreeId) {
  final Degree d = UniversityCatalog.degreeById(degreeId)!;
  expect(g.enrolDegree(degreeId).ok, true, reason: 'enrol $degreeId');
  for (final Course c in d.courses) {
    final ActionResult e = g.enrolCourse(c.id);
    expect(e.ok, true, reason: e.message);
    int guard = 0;
    while (g.university.progress(c.id).lectures < 4) {
      if (guard++ > 40) throw StateError('could not attend lectures for ${c.id}');
      waitUntilHour(g, 9);
      care(g);
      if (g.needs.energy < 40) {
        sleepToMorning(g);
        waitUntilHour(g, 9);
      }
      final ActionResult r = g.attendLecture(c.id);
      if (!r.ok) {
        // Weekend or already attended today → move on a day.
        sleepToMorning(g);
      }
    }
    while (!g.university.progress(c.id).examReady) {
      care(g);
      if (g.needs.energy < 30) sleepToMorning(g);
      final ActionResult r = g.studyCourse(c.id);
      expect(r.ok, true, reason: r.message);
    }
    // Sit the exam on a weekday morning.
    int tries = 0;
    while (true) {
      waitUntilHour(g, 10);
      final ({List<ExamQuestion>? questions, String? error}) ex = g.beginExam(c.id);
      if (ex.questions != null) {
        final List<ExamQuestion> q = ex.questions!;
        final ({ExamResult result, Degree? graduated}) out =
            g.submitExam(c.id, q, q.map((ExamQuestion x) => x.correct).toList());
        expect(out.result.passed, true);
        break;
      }
      if (tries++ > 8) throw StateError('exam never available for ${c.id}: ${ex.error}');
      sleepToMorning(g);
    }
  }
  expect(g.university.has(degreeId), true);
}

String answerFor(InterviewQuestion q) {
  final String kw = q.keywords.take(10).join(', ');
  return 'For example, in a recent project I led, I focused on $kw. First I analysed the situation, then I '
      'communicated clearly with the team and delivered a measurable result: we improved quality by 20% and met the deadline. '
      'I am passionate about this role and eager to learn, and I would take ownership. Thank you for the opportunity.';
}

Future<void> runCareer(String careerId) async {
  final CareerDef career = CareerCatalog.require(careerId);
  final LifeGame g = LifeGame.newGame(AvatarProfile(name: 'Bot ${career.title}', traits: <String>['curious']));
  g.economy.cash = 30000; // tuition & life costs are not the focus of this test
  g.buyItem('business_suit');

  // 1. Education (prerequisite bachelor for law / medicine).
  final Degree own = UniversityCatalog.degreeForCareer(careerId)!;
  if (own.prereqRank > 0) earnDegree(g, 'deg_business');
  earnDegree(g, own.id);
  expect(g.educationRank >= own.awardRank, true);

  // 2. Pick the easiest employer + intern listing.
  final List<Employer> hiring = EmployerCatalog.all.where((Employer e) => e.hires.contains(careerId)).toList()
    ..sort((Employer a, Employer b) => a.hiringBar.compareTo(b.hiringBar));
  final JobListing listing = JobBoard.openListings(g.day, careerId: careerId).firstWhere((JobListing l) => l.employer.id == hiring.first.id && l.rank == 0);
  expect(g.reviewResume(target: listing).score > 0, true);

  // 3. Apply, wait for the invitation.
  expect(g.apply(listing).ok, true);
  ApplicationRecord app = g.applications.first;
  int guard = 0;
  while (app.status == ApplicationStatus.pending) {
    sleepToMorning(g);
    if (guard++ > 6) throw StateError('no response');
  }
  expect(app.status, ApplicationStatus.invited, reason: app.feedback.join('; '));

  // 4. Interview on the day, at the employer building.
  while (g.day < app.interviewDay!) {
    sleepToMorning(g);
  }
  g.buildingId = listing.employer.buildingId;
  g.advance(((app.interviewHour! * 60) - g.minute).clamp(0, 1440));
  expect(g.interviewBlock(app), isNull);
  final InterviewSession session = g.startInterview(app);
  int turns = 0;
  while (!session.finished) {
    final InterviewQuestion q = session.currentQuestion!;
    await session.submit(answerFor(q));
    if (turns++ > 40) throw StateError('interview did not end');
  }
  final InterviewResult res = session.result(applicationId: app.id);
  g.finishInterview(app, res);
  app = g.applicationById(app.id)!;
  guard = 0;
  while (app.status == ApplicationStatus.waitlisted) {
    sleepToMorning(g);
    app = g.applicationById(app.id)!;
    if (guard++ > 10) throw StateError('waitlist never resolved');
  }
  expect(app.status, ApplicationStatus.offer, reason: 'score ${res.interviewScore.round()} decision ${res.decision}');

  // 5. Contract.
  expect(g.acceptOffer(app).ok, true);
  expect(g.job, isNotNull);
  g.buildingId = null;

  // 6. Work until promoted (or 45 days).
  final double cashBefore = g.economy.cash;
  bool promoted = false;
  int workdays = 0;
  for (int i = 0; i < 60 && !promoted; i++) {
    final JobRecord? j = g.job;
    expect(j, isNotNull, reason: 'lost the job on day ${g.day}');
    if (!JobEngine.isShiftDay(j!, g.day)) {
      sleepToMorning(g);
      continue;
    }
    waitUntilHour(g, j.contract.startHour);
    g.buildingId = j.employer.buildingId;
    final ({ActionResult result, List<WorkScenario> tasks}) ci = g.clockIn();
    expect(ci.result.ok, true, reason: ci.result.message);
    for (final WorkScenario s in ci.tasks) {
      care(g);
      final ScenarioRun run = ScenarioRun(s);
      while (!run.finished) {
        await run.submit(ideal(run.stage!));
      }
      final TaskOutcome? o = g.completeTask(s, run.score);
      expect(o, isNotNull, reason: g.taskBlock(s));
    }
    workdays++;
    g.buildingId = null;
    if (g.promotionStatus()?.eligible ?? false) {
      expect(g.promote().ok, true);
      promoted = true;
    }
    sleepToMorning(g);
  }
  expect(promoted, true, reason: '${career.title}: workdays=$workdays perf=${g.job?.performance.round()} ${g.promotionStatus()?.unmet}');
  expect(g.job!.rank, 1);
  // Keep sleeping through days until the first payday lands.
  for (int i = 0; i < 20 && !g.economy.ledger.any((LedgerEntry e) => e.category == 'income'); i++) {
    sleepToMorning(g);
  }
  expect(g.economy.cash > cashBefore - 3000, true);
  expect(g.economy.ledger.any((LedgerEntry e) => e.category == 'income'), true, reason: 'no salary received');
  expect((g.experience[careerId] ?? 0) > 0, true);

  // 7. Save → load is lossless.
  final String a = jsonEncode(g.toJson());
  final LifeGame h = LifeGame.fromJson(jsonDecode(a) as Map<String, Object?>);
  expect(jsonEncode(h.toJson()), a);
}


void main() {
  for (final CareerDef c in CareerCatalog.all) {
    test('full playthrough: ${c.title}', () async {
      await runCareer(c.id);
    });
  }
}
