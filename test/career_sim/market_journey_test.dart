// The full employment journey for every school, starting from a real
// uploaded resume file: upload → profile → apply → screening → interview →
// offer → contract → onboarding → workstation assignments → evaluations →
// paychecks in virtual USD → performance review and raise → app restart.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/engine/interview_engine.dart';
import 'package:ai_study_buddy/career_sim/engine/market_rules.dart';
import 'package:ai_study_buddy/career_sim/engine/pay_rules.dart';
import 'package:ai_study_buddy/career_sim/engine/text_rubric.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_cases.dart';
import 'package:ai_study_buddy/career_sim/hospital/hospital_engine.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/career_sim/model/tasks.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:ai_study_buddy/career_sim/ui/employment_screens.dart';
import 'package:ai_study_buddy/career_sim/ui/job_screens.dart';
import 'package:ai_study_buddy/career_sim/ui/resume_screens.dart';
import 'package:ai_study_buddy/career_sim/ui/workplace_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'hospital_solver.dart';
import 'labs_flow_test.dart' show FakeLabRunner, k;

Uint8List fixture(String name) => File('test/fixtures/resumes/$name').readAsBytesSync();

class Case {
  const Case(this.dept, this.major, this.posting, this.file);
  final String dept;
  final String major;
  final String posting;
  final String file;
}

const List<Case> cases = <Case>[
  Case('cs', 'mobile_app_development', 'mk_flutter_dev', 'jordan_rivera_cs_libreoffice.pdf'),
  Case('nursing', 'nursing', 'mk_nursing_grad', 'amara_okafor_nursing_chrome.pdf'),
  Case('medicine', 'medicine', 'mk_med_grad', 'priya_shah_medicine.docx'),
  Case('law', 'introduction_to_law', 'mk_legal_research', 'sofia_martinez_law.pdf'),
  Case('engineering', 'mechanical_engineering', 'mk_jr_mech', 'ethan_brooks_engineering.pdf'),
  Case('business', 'accounting', 'mk_jr_accountant', 'daniel_chen_business_reportlab.pdf'),
  Case('mathematics', 'mathematics', 'mk_math_research', 'noah_williams_maths.docx'),
  Case('sciences', 'biology', 'mk_lab_research', 'grace_kim_biology.docx'),
  Case('communication', 'english', 'mk_content_writer', 'olivia_turner_english.docx'),
];

/// A candidate answer that covers every rubric point in full sentences.
String answerFor(List<Concept> rubric, {bool behavioural = false}) {
  final List<String> bits = <String>[
    for (final Concept c in rubric) c.anyOf.first.replaceAll('*', ''),
    if (behavioural) ...<String>['when i', 'i decided', 'as a result'],
  ];
  final StringBuffer b = StringBuffer('In my last placement I faced exactly this kind of situation and handled it carefully. ');
  for (final String x in bits) {
    b.write('A key part of my approach is $x, because it makes the work safe and reliable for everyone involved. ');
  }
  b.write('I would explain my reasoning clearly to my supervisor and record what I did.');
  return b.toString();
}

String coverLetter(JobPosting j) =>
    'Dear hiring manager, I am applying for the ${j.title} role at ${j.company.name} because I am excited by your mission and the work your team does. '
    'During my studies I completed a project where I built and tested a real piece of work from start to finish, and I developed strong skills in '
    '${j.keywords.take(3).join(', ')}. I have experience with planning my time, checking my work carefully and writing clear notes so others can follow it. '
    'I am interested in this role because it would let me apply those skills to real problems while learning from experienced colleagues. '
    'I am able to learn quickly, I take feedback well and I care about doing the job properly. Thank you for considering my application; '
    'I look forward to the opportunity to discuss how I can contribute to your team.';

const String handoff = 'I completed the assigned work at the workstation and checked every result against the acceptance criteria before submitting. '
    'I verified the figures twice and compared them with the brief. The next step is for the team to review it; one risk to monitor is '
    'any change in the input data, and I will follow up with my manager tomorrow.';

Future<void> passLab(CareerSimStore s, LabSpec lab, LabScenario sc, {bool forWork = false}) async {
  await s.startLab(lab, scenarioId: sc.id, restart: true, forWork: forWork);
  for (final LabStep st in sc.steps) {
    await s.recordLabStep(lab, st, TaskResult(taskId: st.id, score: 100, passed: true));
  }
  await s.finishLab(lab);
}

void main() {
  for (final Case c in cases) {
    test('employment journey: ${c.dept} — ${c.posting} with ${c.file}', () async {
      final MemoryCareerRepository repo = MemoryCareerRepository();
      final CareerSimStore s = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
      await s.ensureLoaded(userId: 'u_${c.dept}', majorId: c.major);
      final JobPosting job = CareerCatalog.posting(c.posting)!;
      expect(job.deptId, c.dept);

      // 1–2. Upload the real resume; check and confirm what was read.
      final ResumeUpload u = await s.uploadResume(c.file, fixture(c.file));
      expect(u.storagePath, 'users/u_${c.dept}/resumes/${u.id}.${u.format}', reason: 'stored privately under the user');
      expect(repo.files[u.storagePath], isNotNull);
      expect(u.parsed.name, isNotEmpty);
      expect(u.parsed.education, isNotEmpty);
      await s.confirmResume(u.id, u.parsed);
      expect(s.profile.resume.fullName, u.parsed.name);
      expect(s.profile.resume.skills, u.parsed.skills);

      // Practical evidence: pass one lab this role works in.
      final WorkplaceDef w = CareerCatalog.workplace(job.workplaceId)!;
      final LabTaskSpec firstTask = w.assignments.map((AssignmentSpec x) => x.task).whereType<LabTaskSpec>().first;
      final LabSpec firstLab = LabCatalog.lab(firstTask.labId)!;
      await passLab(s, firstLab, firstLab.scenario(firstTask.scenarioId)!);

      // 3–5. Apply with the uploaded resume, a cover letter and the employer's questions.
      final JobApplication a = await s.startApplication(job.id);
      expect(a.resumeId, u.id, reason: 'the uploaded resume is selected by default');
      await expectLater(s.submitApplication(a.id), throwsA(isA<CareerActionException>()), reason: 'no cover letter or answers yet');
      await s.saveDraft(a.id, coverLetter: coverLetter(job), portfolioIds: const <String>[], resumeId: u.id, answers: <String, String>{
        for (final ApplicationQuestion q in job.questions) q.id: answerFor(q.rubric),
      });
      await s.submitApplication(a.id);
      expect(a.status, ApplicationStatus.submitted);
      await expectLater(s.startApplication(job.id), throwsA(isA<CareerActionException>()), reason: 'no duplicate applications');

      await s.advanceDay();
      expect(a.status, ApplicationStatus.underReview);
      await s.advanceDay();
      final ScreeningReport sr = a.screening!;
      expect(sr.breakdown.keys, contains('resume match'));
      expect(sr.shortlisted, isTrue, reason: 'score ${sr.score}: ${sr.gaps.join(' | ')}');
      expect(a.status, ApplicationStatus.shortlisted);

      // 6. Interview, built from the job and this candidate's resume.
      await s.scheduleInterview(a.id, a.interviewSlots.first);
      while (!s.interviewAvailable(a)) {
        await s.advanceDay();
      }
      final InterviewPlan plan = s.interviewPlanFor(a)!;
      expect(plan.bank.first.prompt, contains('resume'));
      expect(plan.main, containsAll(job.roleQuestions.map((InterviewQuestion q) => q.id)));
      final InterviewSession iv = InterviewSession(plan: plan, company: job.company, applicationId: a.id, day: s.day);
      int guard = 0;
      while (!iv.questionsDone && guard++ < 40) {
        final InterviewQuestion q = iv.current!;
        if (q.practical != null) {
          iv.answerPractical(TaskResult(taskId: q.practical!.id, score: 100, passed: true), 'Completed the exercise and checked it.');
        } else if (q.isChoice) {
          iv.answerChoice(q.correctOption);
        } else {
          iv.answerOpen(answerFor(q.rubric, behavioural: q.behavioural));
        }
      }
      iv.ask('Who would I work with on the team day to day?');
      iv.ask('What training and mentoring do new starters get?');
      iv.ask('How is success measured in the first 90 days?');
      final InterviewRecord rec = iv.finish();
      await s.recordInterview(a.id, rec);
      expect(a.status, ApplicationStatus.interviewCompleted);

      // 7. Hiring decision and a USD offer.
      await s.advanceDay();
      expect(a.decision!.outcome, HiringOutcome.offer, reason: a.decision!.reasons.join(' | '));
      final JobOffer o = a.offer!;
      expect(o.salary, inInclusiveRange(job.salaryMin, job.salaryMax));
      expect(o.payFrequency, job.payFrequency);
      expect(o.benefits, isNotEmpty);

      // 8. Contract and onboarding.
      await expectLater(s.acceptOffer(a.id, signature: 'Someone Else'), throwsA(isA<CareerActionException>()));
      final Employment e = await s.acceptOffer(a.id, signature: s.profile.resume.fullName);
      expect(e.contract!.terms.join(' '), contains('not real employment'));
      expect(a.status, ApplicationStatus.hired);
      await expectLater(s.requestAssignment(), throwsA(isA<CareerActionException>()), reason: 'onboarding first');
      for (final String id in s.onboardingLeft(e)) {
        await s.completeOnboarding(id);
      }

      // 9–12. Four workstation assignments, evaluated by the supervisor.
      final int salary = e.salary;
      for (int i = 0; i < 4; i++) {
        final AssignmentRecord r = await s.requestAssignment();
        final AssignmentSpec spec = s.specOf(e, r)!;
        final TaskResult result;
        if (spec.task case final HospitalTaskSpec h) {
          // Nursing and medicine work happens in the virtual hospital.
          final HospitalResult hr;
          if (h.caseId == wardShift.id) {
            await s.startShift(restart: true);
            await solveShift(() => s.shiftSim(wardShift.id)!, s.shiftAct);
            hr = await s.finishShift(goodHandover);
          } else {
            await s.startHospitalCase(h.caseId, restart: true);
            await solveCase(() => s.hospitalSim(h.caseId)!, (SimAction a) => s.hospitalAct(h.caseId, a));
            hr = await s.finishHospitalCase(h.caseId);
          }
          expect(hr.passed, isTrue, reason: '${h.caseId}: ${hr.score} ${hr.notes}');
          result = TaskResult(taskId: h.id, score: hr.score, passed: hr.passed);
        } else {
          final LabTaskSpec t = spec.task as LabTaskSpec;
          final LabSpec lab = LabCatalog.lab(t.labId)!;
          await passLab(s, lab, lab.scenario(t.scenarioId)!, forWork: true);
          final LabCompletion done = s.profile.labCompletions.last;
          expect(done.scenarioId, t.scenarioId);
          result = TaskResult(taskId: t.id, score: done.score, passed: done.passed);
        }
        final SupervisorEvaluation ev = await s.submitAssignment(result, handoff);
        expect(ev.overall, greaterThanOrEqualTo(85), reason: ev.comments.join(' | '));
        await s.advanceDay();
      }
      expect(s.profile.ledger.where((MoneyEntry m) => m.kind == 'lab').length, 1, reason: 'stipends stop once employed');

      // 13–14. Paychecks in virtual USD, each period paid once.
      final int periods = 4 ~/ PayRules.weeksPerPeriod(e.payFrequency);
      final List<Paycheck> pay = s.profile.paychecks.where((Paycheck p) => p.employmentId == e.id).toList();
      expect(pay.length, periods);
      expect(pay.map((Paycheck p) => p.id).toSet().length, periods, reason: 'unique paycheck ids');
      final int gross = PayRules.periodGrossCents(salary, e.salaryPeriod, e.payFrequency, hoursPerWeek: e.hoursPerWeek);
      for (final Paycheck p in pay) {
        expect(p.grossCents, gross);
        expect(p.deductionCents, (gross * 0.10).round());
        expect(p.netCents, gross - (gross * 0.10).round());
      }
      final int salaryNet = s.profile.ledger.where((MoneyEntry m) => m.kind == 'salary').fold<int>(0, (int x, MoneyEntry m) => x + m.cents);
      expect(salaryNet, pay.fold<int>(0, (int x, Paycheck p) => x + p.netCents));

      // Performance review after four assignments, with a transparent raise.
      expect(e.reviews.length, 1);
      expect(e.reviews.single.outcome, 'Excellent performance', reason: e.reviews.single.scores.toString());
      expect(e.reviews.single.raisePercent, 5);
      expect(e.salary, greaterThan(salary));

      // 15–16. Close and reopen the app: everything is still there.
      final CareerSimStore again = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
      await again.ensureLoaded(userId: 'u_${c.dept}', majorId: c.major);
      Map<String, dynamic> norm(CareerProfile p) => (jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>)..remove('updatedAtMs');
      expect(norm(again.profile), norm(s.profile));
      expect(again.profile.currentJob!.title, e.title);
      expect(again.profile.paychecks.length, periods);
      expect(again.profile.application(a.id)!.status, ApplicationStatus.hired);
      expect(again.profile.resumeUpload(u.id)!.reviewed, isTrue);

      // Replace and delete the resume.
      await again.deleteResume(u.id);
      expect(repo.files.containsKey(u.storagePath), isFalse);
      expect(again.profile.resumeUploads, isEmpty);
    });
  }

  test('an application without the role\'s skills is rejected with feedback, never randomly', () async {
    final CareerSimStore s = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await s.ensureLoaded(majorId: 'accounting');
    final ResumeUpload u = await s.uploadResume('cv.docx', fixture('olivia_turner_english.docx'));
    await s.confirmResume(u.id, u.parsed);
    final JobPosting job = CareerCatalog.posting('mk_fin_analyst')!;
    final JobApplication a = await s.startApplication(job.id);
    await s.saveDraft(a.id, coverLetter: coverLetter(job), portfolioIds: const <String>[], answers: <String, String>{
      for (final ApplicationQuestion q in job.questions) q.id: 'I would like this job because it sounds good and I think I would be fine at it overall really.',
    });
    await s.submitApplication(a.id);
    await s.advanceDay();
    await s.advanceDay();
    expect(a.status, ApplicationStatus.rejected);
    expect(a.screening!.gaps.join(' '), contains('Resume does not show'));
    expect(a.screening!.gaps.join(' '), contains('No related practical labs'));
  });

  test('negotiation: a reasoned request after a strong interview raises the offer, within the band', () {
    final JobPosting job = CareerCatalog.posting('mk_jr_swdev')!;
    final JobApplication a = JobApplication(id: 'a', postingId: job.id, status: ApplicationStatus.offerReceived, createdDay: 1);
    a.interview = InterviewRecord(applicationId: 'a', day: 1, turns: const <InterviewTurn>[], communication: 85, technical: 85, problemSolving: 85, readiness: 85, candidateQuestions: const <String>[], practicalPassed: true);
    a.offer = MarketRules.offer(job, job.title, job.salaryMin, 1);
    const String msg = 'Thank you so much for the offer, I am excited to join. Based on my research of similar roles in Austin the market range is higher, '
        'and my internship experience and Flutter projects mean I can contribute quickly. Would you consider a salary of 65,000 per year?';
    final (OfferNegotiation n, int salary) = MarketRules.negotiate(job, a, msg, 1);
    expect(n.accepted, isTrue, reason: '${n.score} ${n.reply}');
    expect(salary, greaterThan(a.offer!.salary));
    expect(salary, lessThanOrEqualTo(job.salaryMax));
    final (OfferNegotiation weak, int same) = MarketRules.negotiate(job, a, 'Can I have more money please? I really want more money for this job because I need it, thanks.', 1);
    expect(weak.accepted, isFalse);
    expect(same, a.offer!.salary);
    expect(TextRubric.words(weak.reply).length, greaterThan(5));
  });

  testWidgets('upload, check and save a resume through the screens; listing shows the match', (WidgetTester t) async {
    t.view.physicalSize = const Size(1200, 5000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final CareerSimStore s = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await s.ensureLoaded(majorId: 'mobile_app_development');
    ResumeHubScreen.picker = () async => ('jordan_rivera_cs.docx', fixture('jordan_rivera_cs.docx'));
    addTearDown(() => ResumeHubScreen.picker = pickResumeFile);
    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: s, child: const MaterialApp(home: ResumeHubScreen())));
    await t.pumpAndSettle();
    await t.tap(k('upload_resume'));
    await t.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Professional profile'), findsOneWidget);
    expect(find.text('Jordan Rivera'), findsWidgets);
    expect(find.textContaining('Resume quality:'), findsOneWidget);
    await t.enterText(k('rv_headline'), 'Flutter developer and CS student');
    await t.ensureVisible(k('rv_save'));
    await t.tap(k('rv_save'));
    await t.pumpAndSettle();
    expect(s.profile.resume.fullName, 'Jordan Rivera');
    expect(s.profile.resume.headline, 'Flutter developer and CS student');
    expect(find.textContaining('jordan_rivera_cs.docx'), findsOneWidget);

    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: s, child: const MaterialApp(home: JobDetailScreen(postingId: 'mk_flutter_dev'))));
    await t.pumpAndSettle();
    expect(k('job_match'), findsOneWidget);
    expect(find.textContaining('Resume compatibility:'), findsOneWidget);
    expect(find.text('Positions available'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('contract, onboarding and a workstation assignment through the screens', (WidgetTester t) async {
    t.view.physicalSize = const Size(1200, 6000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final CareerSimStore s = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await s.ensureLoaded(majorId: 'accounting');
    final ResumeUpload u = await s.uploadResume('cv.pdf', fixture('daniel_chen_business_reportlab.pdf'));
    await s.confirmResume(u.id, u.parsed);
    final JobPosting job = CareerCatalog.posting('mk_jr_accountant')!;
    final JobApplication a = JobApplication(id: 'app_x', postingId: job.id, status: ApplicationStatus.offerReceived, createdDay: 1, resumeId: u.id);
    a.offer = MarketRules.offer(job, job.title, job.salaryMin, 1);
    s.profile.applications.add(a);
    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: s, child: MaterialApp(home: ApplicationScreen(applicationId: a.id))));
    await t.pumpAndSettle();
    expect(find.textContaining('Virtual monthly gross'), findsOneWidget);
    await t.tap(k('accept_offer'));
    await t.pumpAndSettle();
    expect(find.text('Simulated employment contract'), findsOneWidget);
    await t.tap(k('contract_agree'));
    await t.enterText(k('contract_signature'), 'Daniel Chen');
    await t.pump();
    await t.ensureVisible(k('sign_contract'));
    await t.tap(k('sign_contract'));
    await t.pumpAndSettle();
    expect(find.byType(WorkplaceScreen), findsOneWidget);
    expect(k('onboarding'), findsOneWidget);
    expect(k('workplace_notice'), findsOneWidget);
    for (final String id in <String>['handbook', 'policy', 'tools', 'manager', 'goals']) {
      await t.ensureVisible(k('onb_$id'));
      await t.tap(k('onb_$id'));
      await t.pumpAndSettle();
      await t.tap(k('onb_done_$id'));
      await t.pumpAndSettle();
    }
    expect(k('onboarding'), findsNothing);
    await t.ensureVisible(k('request_assignment'));
    await t.tap(k('request_assignment'));
    await t.pumpAndSettle();
    await t.tap(k('open_assignment'));
    await t.pumpAndSettle();
    expect(k('work_open_lab'), findsOneWidget);
    expect(find.textContaining('Workstation task'), findsOneWidget);
    expect(t.takeException(), isNull);
    expect(employmentStatus(s).$1, 'Currently working');
  });
}
