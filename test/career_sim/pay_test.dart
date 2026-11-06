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
  test('pay rules (virtual USD)', () {
    expect(PayRules.stipend(LabDifficulty.foundation, 100), 7500);
    expect(PayRules.stipend(LabDifficulty.advanced, 50), 11250);
    expect(PayRules.weeklyGrossCents(52000, 'year'), 100000);
    expect(PayRules.weeklyGrossCents(20, 'hour', hoursPerWeek: 40), 80000);
    // The spec's example: $62,000 a year paid monthly = $5,166.67 gross, $516.67 deductions, $4,650.00 net.
    final int gross = PayRules.periodGrossCents(62000, 'year', 'monthly');
    expect(usd(gross), r'$5,166.67');
    expect(usd(PayRules.deductionsCents(gross)), r'$516.67');
    expect(usd(gross - PayRules.deductionsCents(gross)), r'$4,650.00');
    expect(PayRules.periodGrossCents(62000, 'year', 'biweekly'), 238462);
    expect(PayRules.annual(18, 'hour', hoursPerWeek: 36), 33696);
    expect(usdWhole(1234567), r'$1,234,567');
  });

  test('passing a lab scenario pays a training stipend once', () async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'nursing');
    final LabSpec lab = LabCatalog.forMajor('nursing').first;
    final LabScenario sc = lab.scenarios.first;
    await passScenario(s, lab, sc);
    expect(s.profile.balanceCents, PayRules.stipend(sc.level, 100));
    expect(s.profile.ledger.single.kind, 'lab');
    await passScenario(s, lab, sc);
    expect(s.profile.ledger.length, 1, reason: 'no double pay for the same scenario');
    final CareerProfile back = CareerProfile.fromJson(s.profile.toJson());
    expect(back.balanceCents, s.profile.balanceCents, reason: 'the ledger is saved');
    expect(CareerProfile.fromJson(<String, dynamic>{}).balanceCents, 0, reason: 'old profiles without a ledger still load');
  });

  test('approved work weeks are paid per pay period, exactly once', () async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'computer_science');
    final JobPosting j = CareerCatalog.posting('cs_intern_northwind')!;
    s.profile.employment.add(Employment(
      id: 'e1', postingId: j.id, deptId: 'cs', workplaceId: 'cs_northwind', employer: j.company.name,
      title: 'Software Engineering Intern', stage: CareerStage.intern, salary: 52000, salaryPeriod: 'year', startDay: 1, payFrequency: 'biweekly',
    ));
    s.profile.stage = CareerStage.intern;
    const String note = 'I implemented the change, verified it with tests, and the next step is to monitor it in production with the team.';
    await s.requestAssignment();
    await s.submitAssignment(const TaskResult(taskId: 't', score: 100, passed: true), note);
    expect(s.profile.paychecks, isEmpty, reason: 'biweekly: one approved week is not a full period');
    await s.requestAssignment();
    await s.submitAssignment(const TaskResult(taskId: 't', score: 100, passed: true), note);
    expect(s.profile.paychecks.length, 1);
    final Paycheck c = s.profile.paychecks.single;
    expect(c.grossCents, 200000);
    expect(c.deductionCents, 20000);
    expect(c.netCents, 180000);
    expect(c.hours, 80);
    expect(s.profile.balanceCents, 180000);
    expect(s.profile.ledger.single.paycheckId, c.id);
  });

  testWidgets('wallet on the dashboard opens My Earnings, labelled as virtual', (WidgetTester t) async {
    final CareerSimStore s = newStore();
    await s.ensureLoaded(majorId: 'nursing');
    final LabSpec lab = LabCatalog.forMajor('nursing').first;
    await passScenario(s, lab, lab.scenarios.first);
    await pumpHome(t, s, const CareerSimDashboard(studentName: 'Ada', majorLabel: 'Nursing'));
    expect(find.text(r'$75.00'), findsOneWidget);
    await tap(t, k('dash_wallet'));
    expect(find.widgetWithText(AppBar, 'My Earnings'), findsOneWidget);
    expect(find.text(r'$75.00'), findsOneWidget);
    expect(find.textContaining('not actual employment or cash payments'), findsOneWidget);
    expect(find.textContaining('Training stipend: ${lab.title}'), findsOneWidget);
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
