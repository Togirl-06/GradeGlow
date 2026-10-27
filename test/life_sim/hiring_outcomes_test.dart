import 'package:ai_study_buddy/life_sim/avatar/avatar_profile.dart';
import 'package:ai_study_buddy/life_sim/employment/application.dart';
import 'package:ai_study_buddy/life_sim/employment/job_listing.dart';
import 'package:ai_study_buddy/life_sim/game/life_game.dart';
import 'package:ai_study_buddy/life_sim/interview/interview_session.dart';

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
  final LifeGame g = LifeGame.newGame(AvatarProfile());
  final JobListing l = JobBoard.openListings(g.day).firstWhere((JobListing x) => x.rank == 0);

  // ---- second interview ----
  g.applications.insert(
    0,
    ApplicationRecord(
      id: 'a1',
      listingId: l.id,
      submittedDay: 1,
      respondDay: 2,
      matchScore: 60,
      resumeScore: 60,
      willInvite: true,
      status: ApplicationStatus.invited,
      interviewDay: 2,
      interviewHour: l.employer.startHour + 2,
    ),
  );
  final ApplicationRecord a = g.applications.first;
  final InterviewResult r = InterviewResult(
    interviewScore: 70,
    hiringScore: 66,
    offerThreshold: 68,
    decision: HireDecision.secondInterview,
    dimensionAverages: const <String, double>{},
    strengths: const <String>[],
    improvements: const <String>[],
    questionNotes: const <String>[],
    closingLine: '',
  );
  g.finishInterview(a, r);
  check('second interview re-invites', a.status == ApplicationStatus.invited && a.round == 2);
  check('second interview on a future weekday', a.interviewDay! > g.day - 0 && ((a.interviewDay! - 1) % 7) < 5);
  check('invite email with interview action', g.inbox.messages.any((m) => m.subject.startsWith('Final interview')));
  final InterviewSession s2 = g.startInterview(a);
  check('session knows round 2', s2.round == 2);
  check('round-1 session', g.startPracticeInterview(l).round == 1);
  check('persisted', ApplicationRecord.fromJson(a.toJson()).round == 2);

  // ---- more information requested ----
  final LifeGame g2 = LifeGame.newGame(AvatarProfile());
  final ApplicationRecord b = ApplicationRecord(
    id: 'b1',
    listingId: l.id,
    submittedDay: 1,
    respondDay: 2,
    matchScore: 45,
    resumeScore: 40,
    willInvite: false,
    willAskInfo: true,
    feedback: <String>['Your resume scored 40/100 — visit the career assistant to improve it.'],
  );
  g2.applications.insert(0, b);
  g2.advance(24 * 60 * 2);
  check('info requested on response day', b.status == ApplicationStatus.infoRequested);
  check('deadline set', b.infoDeadlineDay != null && b.infoDeadlineDay! > g2.day - 1);
  check('still active', b.isActive);
  check('info email', g2.inbox.messages.any((m) => m.subject.startsWith('More information')));
  final ActionResult up = g2.sendApplicationUpdate(b);
  check('update accepted', up.ok && b.status == ApplicationStatus.pending);
  check('cannot update twice', !g2.sendApplicationUpdate(b).ok);
  g2.advance(24 * 60 * 2);
  check('resolved after update', b.status != ApplicationStatus.pending && b.status != ApplicationStatus.infoRequested);

  // unanswered request expires
  final LifeGame g3 = LifeGame.newGame(AvatarProfile());
  final ApplicationRecord c = ApplicationRecord(
    id: 'c1',
    listingId: l.id,
    submittedDay: 1,
    respondDay: 1,
    matchScore: 45,
    resumeScore: 40,
    willInvite: false,
    willAskInfo: true,
  );
  g3.applications.insert(0, c);
  g3.advance(24 * 60);
  check('requested', c.status == ApplicationStatus.infoRequested);
  g3.advance(24 * 60 * 7);
  check('expired when ignored', c.status == ApplicationStatus.expired);
  check('persisted info', ApplicationRecord.fromJson(b.toJson()).willAskInfo == b.willAskInfo);

  print(failed == 0 ? 'ALL PASSED: $passed passed, 0 failed' : 'FAILED: $failed');
}
