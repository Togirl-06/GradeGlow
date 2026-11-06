import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/engine/pay_rules.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/labs/ui/lab_screens.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:ai_study_buddy/career_sim/ui/career_dashboard.dart';
import 'package:ai_study_buddy/career_sim/ui/money_find_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'labs_flow_test.dart' show FakeLabRunner, k, tap;

CareerSimStore newStore() => CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}));

Future<void> passScenario(CareerSimStore s, LabSpec lab, LabScenario sc, {int score = 100}) async {
  await s.startLab(lab, scenarioId: sc.id, restart: true);
  for (final LabStep st in sc.steps) {
    await s.recordLabStep(lab, st, TaskResult(taskId: st.id, score: score, passed: true));
  }
  await s.finishLab(lab);
}

Future<void> pumpHome(WidgetTester t, CareerSimStore s, Widget home) async {
  t.view.physicalSize = const Size(1200, 4000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: s, child: MaterialApp(home: Scaffold(body: home))));
  await t.pumpAndSettle();
}

void main() {
  test('pay rules', () {
    expect(PayRules.labPay(LabDifficulty.foundation, 100), 60);
    expect(PayRules.labPay(LabDifficulty.advanced, 50), 90);
    expect(PayRules.weeklyPay(52000, 'year'), 1000);
    expect(PayRules.weeklyPay(20, 'hour'), 750);
    expect(PayRules.weeklyPay(4000, 'month'), 923);
    expect(pounds(1234567), '£1,234,567');
    expect(pounds(60), '£60');
  });

  test('passing a lab scenario pays once; a retake earns nothing more', () async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'nursing');
    final LabSpec lab = LabCatalog.forMajor('nursing').first;
    final LabScenario sc = lab.scenarios.first;
    await passScenario(s, lab, sc);
    expect(s.profile.balance, PayRules.labPay(sc.level, 100));
    expect(s.profile.ledger.single.kind, 'lab');
    await passScenario(s, lab, sc);
    expect(s.profile.ledger.length, 1, reason: 'no double pay for the same scenario');
    final CareerProfile back = CareerProfile.fromJson(s.profile.toJson());
    expect(back.balance, s.profile.balance, reason: 'the ledger is saved');
    expect(CareerProfile.fromJson(<String, dynamic>{}).balance, 0, reason: 'old profiles without a ledger still load');
  });

  test('each evaluated assignment pays a week, strong work earns a bonus', () async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'computer_science');
    final JobPosting j = CareerCatalog.posting('cs_intern_northwind')!;
    s.profile.employment.add(Employment(
      id: 'e1', postingId: j.id, deptId: 'cs', workplaceId: 'cs_northwind', employer: j.company.name,
      title: 'Software Engineering Intern', stage: CareerStage.intern, salary: 4000, salaryPeriod: 'month', startDay: 1,
    ));
    s.profile.stage = CareerStage.intern;
    await s.requestAssignment();
    final SupervisorEvaluation ev = await s.submitAssignment(const TaskResult(taskId: 't', score: 100, passed: true),
        'I implemented the change, verified it with tests, and the next step is to monitor it in production.');
    final int week = PayRules.weeklyPay(4000, 'month');
    expect(s.profile.ledger.first.amount, week);
    expect(s.profile.ledger.first.kind, 'salary');
    expect(s.profile.balance, week + (ev.overall >= PayRules.bonusThreshold ? (week * 0.1).round() : 0));
  });

  testWidgets('wallet on the dashboard opens My Earnings, labelled as simulated', (WidgetTester t) async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'nursing');
    final LabSpec lab = LabCatalog.forMajor('nursing').first;
    await passScenario(s, lab, lab.scenarios.first);
    await pumpHome(t, s, const CareerSimDashboard(studentName: 'Ada', majorLabel: 'Nursing'));
    expect(find.text('£60'), findsOneWidget);
    await tap(t, k('dash_wallet'));
    expect(find.widgetWithText(AppBar, 'My Earnings'), findsOneWidget);
    expect(find.text('£60'), findsOneWidget);
    expect(find.textContaining('not real money'), findsOneWidget);
    expect(find.textContaining('Lab work: ${lab.title}'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('Find searches labs, lessons, jobs and screens and opens a result', (WidgetTester t) async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'medicine');
    await pumpHome(t, s, const CareerSimDashboard(studentName: 'Ada', majorLabel: 'Medicine'));
    await tap(t, k('dash_search'));
    await t.enterText(k('find_query'), 'anatomy');
    await t.pumpAndSettle();
    expect(k('find_lab_md_lab_anatomy'), findsOneWidget);
    await t.enterText(k('find_query'), 'earnings');
    await t.pumpAndSettle();
    await tap(t, k('find_screen_money'));
    expect(find.widgetWithText(AppBar, 'My Earnings'), findsOneWidget);
    await t.pageBack();
    await t.pumpAndSettle();
    await t.enterText(k('find_query'), 'zzqqxx');
    await t.pumpAndSettle();
    expect(find.textContaining('Nothing matches'), findsOneWidget);
    final JobPosting open = CareerCatalog.postings.firstWhere((JobPosting j) => PostingSchedule.isOpen(j, s.profile.day));
    expect(search(s, open.title).any((FindResult r) => r.kind == 'Job' && r.id == open.id), isTrue);
    expect(search(s, 'sql').any((FindResult r) => r.kind == 'Lab'), isTrue);
    expect(t.takeException(), isNull);
  });

  testWidgets('labs screen search filters across all majors', (WidgetTester t) async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'nursing');
    await pumpHome(t, s, const PracticalLabsScreen());
    await t.enterText(k('labs_search'), 'CAD');
    await t.pumpAndSettle();
    expect(k('lab_me_lab_cad'), findsOneWidget, reason: 'search reaches labs outside the student\'s field');
    await t.enterText(k('labs_search'), 'zzqqxx');
    await t.pumpAndSettle();
    expect(find.textContaining('No labs match'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
