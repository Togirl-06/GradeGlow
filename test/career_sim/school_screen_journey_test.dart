// The employment journey for every school, driven through the real screens:
// upload a real resume → job board → apply (cover letter and employer
// questions) → screening → book and sit the interview → offer → sign the
// contract → onboarding → workplace assignments → supervisor evaluation →
// first paycheck on the Earnings screen.
//
// Two steps are completed through the store rather than by tapping, because
// they have their own screen tests: the workstation lab or hospital shift
// behind an assignment (every_lab_journey_test, hospital_test), and the
// practical exercise inside an interview, whose task view reports a pass
// here exactly as it would after the student completes it.
import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/engine/pay_rules.dart';
import 'package:ai_study_buddy/career_sim/engine/text_rubric.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_cases.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/career_sim/model/tasks.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:ai_study_buddy/career_sim/ui/career_centre.dart';
import 'package:ai_study_buddy/career_sim/ui/money_find_screens.dart';
import 'package:ai_study_buddy/career_sim/ui/resume_screens.dart';
import 'package:ai_study_buddy/career_sim/ui/task_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'hospital_solver.dart';
import 'labs_flow_test.dart' show FakeLabRunner, k;
import 'market_journey_test.dart' show Case, answerFor, cases, coverLetter, fixture, handoff, passLab;

Future<void> tap(WidgetTester t, String key) async {
  final Finder f = k(key);
  expect(f, findsWidgets, reason: 'missing $key');
  await t.ensureVisible(f.first);
  await t.pumpAndSettle();
  await t.tap(f.first);
  await t.pumpAndSettle();
}

bool shown(String key) => k(key).evaluate().isNotEmpty;

/// One answer that covers every rubric point of every open question the
/// interviewer might ask, written as a behavioural (STAR) story.
String interviewAnswer(InterviewPlan plan) {
  final List<Concept> all = <Concept>[
    for (final InterviewQuestion q in plan.bank)
      if (!q.isChoice && q.practical == null) ...q.rubric,
  ];
  return answerFor(all, behavioural: true);
}

void main() {
  for (final Case c in cases) {
    testWidgets('through the screens: ${c.dept} — resume to first paycheck (${c.posting})', (WidgetTester t) async {
      t.view.physicalSize = const Size(1400, 9000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final CareerSimStore s = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
      await s.ensureLoaded(userId: 'ui_${c.dept}', majorId: c.major);
      final JobPosting job = CareerCatalog.posting(c.posting)!;
      Widget app(Widget home) => ChangeNotifierProvider<CareerSimStore>.value(value: s, child: MaterialApp(home: home));

      // 1. Upload the real resume file and save the checked profile.
      ResumeHubScreen.picker = () async => (c.file, fixture(c.file));
      addTearDown(() => ResumeHubScreen.picker = pickResumeFile);
      await t.pumpWidget(app(const ResumeHubScreen()));
      await t.pumpAndSettle();
      await tap(t, 'upload_resume');
      await tap(t, 'rv_save');
      expect(s.profile.resume.fullName, isNotEmpty);
      expect(s.profile.resumeUploads.single.reviewed, isTrue);

      // Practical evidence for screening: one lab this role uses.
      final WorkplaceDef w = CareerCatalog.workplace(job.workplaceId)!;
      final LabTaskSpec first = w.assignments.map((AssignmentSpec x) => x.task).whereType<LabTaskSpec>().first;
      final LabSpec firstLab = LabCatalog.lab(first.labId)!;
      await passLab(s, firstLab, firstLab.scenario(first.scenarioId)!);

      // 2. Career Center → Job Opportunities → Apply.
      await t.pumpWidget(app(const CareerCentreScreen(initialTab: 1)));
      await t.pumpAndSettle();
      if (!shown('apply_${job.id}')) await tap(t, 'filter_all');
      await tap(t, 'apply_${job.id}');
      final JobApplication a = s.profile.applications.single;
      await t.enterText(k('cover_letter_field'), coverLetter(job));
      for (final ApplicationQuestion q in job.questions) {
        await t.ensureVisible(k('answer_${q.id}'));
        await t.enterText(k('answer_${q.id}'), answerFor(q.rubric));
      }
      await t.pumpAndSettle();
      await tap(t, 'submit_application');
      expect(a.status, ApplicationStatus.submitted);

      // 3. Employer review, then book an interview slot.
      await tap(t, 'next_day');
      await tap(t, 'next_day');
      expect(a.status, ApplicationStatus.shortlisted, reason: '${a.screening?.score}: ${a.screening?.gaps.join(' | ')}');
      await tap(t, 'slot_${a.interviewSlots.first}');
      for (int i = 0; i < 6 && !s.interviewAvailable(a); i++) {
        await tap(t, 'next_day');
      }
      expect(s.interviewAvailable(a), isTrue);

      // 4. The interview, answered on screen.
      final InterviewPlan plan = s.interviewPlanFor(a)!;
      final String answer = interviewAnswer(plan);
      await tap(t, 'start_interview');
      final Set<String> chosen = <String>{};
      for (int i = 0; i < 40 && !shown('iv_ask'); i++) {
        final Finder practical = find.byWidgetPredicate((Widget x) => x is TaskView && (x.key is ValueKey<String>) && (x.key! as ValueKey<String>).value.startsWith('practical_'));
        if (practical.evaluate().isNotEmpty) {
          final TaskView v = t.widget<TaskView>(practical.first);
          await v.onGraded(TaskResult(taskId: v.spec.id, score: 100, passed: true));
          await t.pumpAndSettle();
        } else if (shown('iv_send')) {
          await t.enterText(k('iv_answer'), answer);
          await tap(t, 'iv_send');
        } else if (shown('iv_opt_0')) {
          final InterviewQuestion q = plan.bank.firstWhere(
            (InterviewQuestion q) => q.isChoice && !chosen.contains(q.id) && q.options.every((String o) => find.text(o).evaluate().isNotEmpty),
          );
          chosen.add(q.id);
          await tap(t, 'iv_opt_${q.correctOption}');
        } else {
          fail('Unexpected interview state');
        }
      }
      for (int i = 0; i < 3; i++) {
        await tap(t, 'iv_suggest_$i');
      }
      await tap(t, 'iv_finish');
      expect(a.interview, isNotNull);
      expect(a.interview!.overall, greaterThanOrEqualTo(70), reason: a.interview!.turns.map((InterviewTurn x) => '${x.questionId}:${x.score}').join(' '));
      await tap(t, 'interview_done');

      // 5. Offer → accept → sign the contract.
      await tap(t, 'next_day');
      expect(a.status, ApplicationStatus.offerReceived, reason: a.decision?.reasons.join(' | '));
      await tap(t, 'accept_offer');
      expect(find.text('Simulated employment contract'), findsOneWidget);
      await tap(t, 'contract_agree');
      await t.enterText(k('contract_signature'), s.profile.resume.fullName);
      await t.pump();
      await tap(t, 'sign_contract');
      final Employment e = s.profile.currentJob!;
      expect(a.status, ApplicationStatus.hired);

      // 6. Onboarding checklist in the workplace.
      for (final String id in <String>['handbook', 'policy', 'tools', 'manager', 'goals']) {
        await tap(t, 'onb_$id');
        await tap(t, 'onb_done_$id');
      }
      expect(s.onboardingLeft(e), isEmpty);

      // 7. Assignments until the first paycheck arrives.
      bool paid = false;
      for (int n = 0; n < 5 && !paid; n++) {
        await tap(t, 'request_assignment');
        await tap(t, 'open_assignment');
        final AssignmentSpec spec = s.specOf(e, e.open!)!;
        if (spec.task case final HospitalTaskSpec h) {
          if (h.caseId == wardShift.id) {
            await s.startShift(restart: true);
            await solveShift(() => s.shiftSim(wardShift.id)!, s.shiftAct);
            await s.finishShift(goodHandover);
          } else {
            await s.startHospitalCase(h.caseId, restart: true);
            await solveCase(() => s.hospitalSim(h.caseId)!, (SimAction x) => s.hospitalAct(h.caseId, x));
            await s.finishHospitalCase(h.caseId);
          }
          await t.pumpAndSettle();
          await tap(t, 'work_attach_hospital');
        } else {
          final LabTaskSpec lt = spec.task as LabTaskSpec;
          final LabSpec lab = LabCatalog.lab(lt.labId)!;
          await passLab(s, lab, lab.scenario(lt.scenarioId)!, forWork: true);
          await t.pumpAndSettle();
          await tap(t, 'work_attach_result');
        }
        await t.enterText(k('handoff_note'), handoff);
        await t.pumpAndSettle();
        await tap(t, 'submit_assignment');
        expect(k('evaluation_card'), findsOneWidget);
        expect(e.evaluated.last.evaluation!.overall, greaterThanOrEqualTo(70), reason: e.evaluated.last.evaluation!.comments.join(' | '));
        paid = shown('pay_salary');
        if (!paid) expect(k('pay_pending'), findsOneWidget);
        await tap(t, 'back_to_work');
      }
      expect(paid, isTrue, reason: 'a paycheck within five approved weeks (${e.payFrequency})');
      final Paycheck p = s.profile.paychecks.single;
      expect(p.netCents, greaterThan(0));

      // 8. The Earnings screen shows the paycheck in dollars.
      await t.pumpWidget(app(const MoneyScreen()));
      await t.pumpAndSettle();
      expect(find.textContaining(usd(p.netCents)), findsWidgets);
      expect(find.textContaining(usd(p.grossCents)), findsWidgets);
      expect(t.takeException(), isNull);
    });
  }
}
