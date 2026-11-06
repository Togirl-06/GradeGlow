import 'package:ai_study_buddy/career_sim/labs/content/accounting_labs.dart';
import 'package:ai_study_buddy/career_sim/labs/content/cs_labs.dart';
import 'package:ai_study_buddy/career_sim/labs/content/health_labs.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/labs/ui/lab_screens.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:ai_study_buddy/career_sim/ui/career_dashboard.dart';
import 'package:ai_study_buddy/models/leetcode_problem.dart';
import 'package:ai_study_buddy/services/code_judge_service.dart';
import 'package:ai_study_buddy/services/lab_runner/lab_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Stands in for the browser runner (tested for real in functions/test):
/// statements containing "-- good" return the step's expected rows.
class FakeLabRunner implements LabRunner {
  FakeLabRunner(this.sqlAnswers);
  final Map<String, List<List<Object?>>> sqlAnswers;
  final List<String> calls = <String>[];

  @override
  String get where => 'Test runner';

  @override
  bool get canRunPrograms => true;

  @override
  Future<JudgeResult> judge(LeetcodeProblem problem, String languageId, String code, {required bool submit}) async =>
      JudgeResult.fromJson(<String, dynamic>{'verdict': 'Accepted', 'message': 'ok', 'passed': 3, 'total': 3, 'cases': <Object?>[]});

  @override
  Future<ProgramOutput> runProgram(String languageId, String code, {String stdin = ''}) async {
    calls.add('program:$stdin');
    return ProgramOutput(ok: true, stdout: code.contains('ECHO') ? stdin : 'nope');
  }

  @override
  Future<SqlOutput> runSql({required String setup, required String statements, String? check}) async {
    calls.add('sql:$statements');
    for (final MapEntry<String, List<List<Object?>>> e in sqlAnswers.entries) {
      if (statements.contains(e.key)) {
        final SqlTable t = SqlTable(const <String>['c'], e.value);
        return SqlOutput(ok: true, result: t, check: check == null ? null : t);
      }
    }
    return const SqlOutput(ok: false, error: 'near "SELEC": syntax error');
  }
}

Finder k(String key) => find.byKey(ValueKey<String>(key));

Future<void> tap(WidgetTester t, Finder f) async {
  expect(f, findsWidgets, reason: '$f');
  await t.ensureVisible(f.first);
  await t.tap(f.first);
  await t.pumpAndSettle();
}

Future<void> pickDropdown(WidgetTester t, String key, String value) async {
  await tap(t, k(key));
  await t.tap(find.text(value).last);
  await t.pumpAndSettle();
}

Future<CareerSimStore> pumpLab(WidgetTester t, String labId, {MemoryCareerRepository? repo, LabRunner? runner, String major = 'computer_science'}) async {
  t.view.physicalSize = const Size(1400, 12000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final CareerSimStore store = CareerSimStore(repository: repo ?? MemoryCareerRepository(), runner: runner ?? FakeLabRunner(const <String, List<List<Object?>>>{}));
  await store.ensureLoaded(userId: 'u', majorId: major);
  await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: store, child: MaterialApp(key: UniqueKey(), home: LabIntroScreen(labId: labId))));
  await t.pumpAndSettle();
  return store;
}

/// Intro → environment → briefing → work.
Future<void> enterWork(WidgetTester t) async {
  await tap(t, k('lab_start'));
  expect(find.text('People here'), findsOneWidget);
  await tap(t, k('to_briefing'));
  expect(find.text('What needs to be done'), findsOneWidget);
  await tap(t, k('begin_work'));
}

Future<void> next(WidgetTester t) => tap(t, k('step_next'));

Future<void> finish(WidgetTester t) async {
  await tap(t, k('to_evaluation'));
  expect(find.textContaining('Final result'), findsOneWidget);
  await tap(t, k('finish_lab'));
}

void main() {
  testWidgets('Database lab: tools work, every SQL task graded, result saved', (WidgetTester t) async {
    final Map<String, List<List<Object?>>> answers = <String, List<List<Object?>>>{
      for (final LabStep s in csDatabaseLab.scenarios.first.steps) '-- ${s.id}': (s as SqlStep).expected,
    };
    final FakeLabRunner runner = FakeLabRunner(answers);
    final CareerSimStore store = await pumpLab(t, csDatabaseLab.id, runner: runner);
    expect(find.text('Learning objectives'), findsOneWidget);
    await tap(t, k('lab_start'));
    // The SQL workbench in the environment runs real queries (through the runner).
    await tap(t, k('tool_sql'));
    await t.enterText(k('workbench_sql'), 'SELEC * FROM students');
    await tap(t, k('workbench_run'));
    expect(k('workbench_error'), findsOneWidget);
    await tap(t, k('to_briefing'));
    await tap(t, k('begin_work'));
    final List<LabStep> steps = csDatabaseLab.scenarios.first.steps;
    for (int i = 0; i < steps.length; i++) {
      if (i == 0) {
        await t.enterText(k('sql_editor'), 'SELEC wrong');
        await tap(t, k('sql_submit'));
        expect(store.labRun(csDatabaseLab.id)!.results[steps[0].id]!.passed, isFalse);
        expect(find.textContaining('syntax error'), findsWidgets);
      }
      await t.enterText(k('sql_editor'), 'SELECT 1; -- ${steps[i].id}');
      await tap(t, k('sql_run'));
      await tap(t, k('sql_submit'));
      expect(store.labRun(csDatabaseLab.id)!.results[steps[i].id]!.passed, isTrue, reason: steps[i].id);
      if (i < steps.length - 1) await next(t);
    }
    await finish(t);
    expect(find.textContaining('Lab passed'), findsOneWidget);
    expect(store.profile.labPassed(csDatabaseLab.id), isTrue);
    expect(store.profile.skillPoints['cs_db'], greaterThan(0));
    expect(runner.calls.where((String c) => c.startsWith('sql:')).length, greaterThan(steps.length));
  });

  testWidgets('Programming lab: run with input, submit runs every test case', (WidgetTester t) async {
    final FakeLabRunner runner = FakeLabRunner(const <String, List<List<Object?>>>{});
    final CareerSimStore store = await pumpLab(t, csFundamentalsLab.id, runner: runner);
    await enterWork(t);
    await t.enterText(k('program_code'), 'print("hi")');
    await tap(t, k('program_run'));
    expect(k('program_output'), findsOneWidget);
    await tap(t, k('program_submit'));
    expect(store.labRun(csFundamentalsLab.id)!.results['average']!.passed, isFalse);
    // Draft saved: a fresh session restores the code.
    expect(store.labRun(csFundamentalsLab.id)!.drafts['average'], contains('print("hi")'));
    expect(runner.calls.where((String c) => c.startsWith('program:')).length, 1 + 4);
  });

  testWidgets('OS lab: Gantt chart, page replacement and trace; leave and resume', (WidgetTester t) async {
    final MemoryCareerRepository repo = MemoryCareerRepository();
    final CareerSimStore store = await pumpLab(t, csSystemsLab.id, repo: repo);
    await enterWork(t);
    for (final String p in <String>['P1', 'P2', 'P3', 'P4']) {
      await tap(t, k('dispatch_$p'));
    }
    expect(find.text('P4\n16–22'), findsOneWidget);
    await t.enterText(k('avg_wait'), '5.75');
    await tap(t, k('sched_submit'));
    expect(store.labRun(csSystemsLab.id)!.results['fcfs']!.score, 100);
    await next(t);

    // Leave the lab, then come back in a new session: progress is restored.
    final CareerSimStore again = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await again.ensureLoaded(userId: 'u');
    expect(again.labRun(csSystemsLab.id)!.stepIndex, 1);
    expect(again.labRun(csSystemsLab.id)!.results['fcfs']!.passed, isTrue);
    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: again, child: MaterialApp(key: UniqueKey(), home: LabIntroScreen(labId: csSystemsLab.id))));
    await t.pumpAndSettle();
    expect(find.textContaining('In progress · 1/5 steps'), findsOneWidget);
    await tap(t, k('lab_continue'));
    expect(find.text('Shortest job first'), findsOneWidget);
    for (final String p in <String>['P1', 'P2', 'P4', 'P3']) {
      await tap(t, k('dispatch_$p'));
    }
    await t.enterText(k('avg_wait'), '5.25');
    await tap(t, k('sched_submit'));
    await next(t);

    // FIFO by hand.
    for (final String b in <String>['page_fault_free', 'page_fault_free', 'page_fault_free', 'page_evict_7', 'page_hit', 'page_evict_0', 'page_evict_1', 'page_evict_2', 'page_evict_3', 'page_evict_0']) {
      await tap(t, k(b));
    }
    await tap(t, k('paging_submit'));
    expect(again.labRun(csSystemsLab.id)!.results['fifo']!.score, 100);
    await next(t);
    // LRU: 7,0,1 free; 2 evicts 7; 0 hit; 3 evicts 1; 0 hit; 4 evicts 2; 2 evicts 3; 3 evicts 0.
    for (final String b in <String>['page_fault_free', 'page_fault_free', 'page_fault_free', 'page_evict_7', 'page_hit', 'page_evict_1', 'page_hit', 'page_evict_2', 'page_evict_3', 'page_evict_0']) {
      await tap(t, k(b));
    }
    await tap(t, k('paging_submit'));
    expect(again.labRun(csSystemsLab.id)!.results['lru']!.score, 100);
    await next(t);
    await t.enterText(k('num_0'), '5');
    await t.enterText(k('num_1'), '20');
    await tap(t, k('task_submit'));
    await finish(t);
    expect(again.profile.labPassed(csSystemsLab.id), isTrue);
  });

  testWidgets('Algorithms lab: binary search trace', (WidgetTester t) async {
    final CareerSimStore store = await pumpLab(t, csAlgorithmsLab.id);
    await enterWork(t);
    for (final int i in <int>[7, 11, 13]) {
      await tap(t, k('cell_$i'));
    }
    await tap(t, k('trace_submit'));
    expect(store.labRun(csAlgorithmsLab.id)!.results['trace']!.score, 100);
  });

  testWidgets('Nursing admission: identity check catches the wrong MRN; interview and note', (WidgetTester t) async {
    final CareerSimStore store = await pumpLab(t, nursingAdmissionLab.id, major: 'nursing');
    await tap(t, k('lab_start'));
    await tap(t, k('tool_patient_amira'));
    expect(find.textContaining('MRN GG-310577'), findsWidgets);
    await tap(t, k('to_briefing'));
    await tap(t, k('begin_work'));
    await tap(t, k('identity_stop'));
    expect(find.byType(SnackBar), findsOneWidget, reason: 'must check before deciding');
    await tap(t, k('check_wristband'));
    await tap(t, k('ask_identity'));
    await tap(t, k('mismatch_MRN'));
    await tap(t, k('identity_stop'));
    expect(store.labRun(nursingAdmissionLab.id)!.results['identity']!.score, 100);
    await next(t);
    for (final int i in <int>[0, 1, 2, 3, 4, 6]) {
      await tap(t, k('ask_$i'));
    }
    expect(find.textContaining('Codeine makes me sick'), findsOneWidget);
    await t.enterText(k('history_note'),
        'Admitted with right-sided abdominal pain and vomiting for two days, pain score 6/10. Allergy: codeine causes vomiting. '
        'Medicines: salbutamol inhaler as needed. Last period three weeks ago and a pregnancy test was offered. Plan: inform the doctor for review and monitor observations.');
    await tap(t, k('history_submit'));
    expect(store.labRun(nursingAdmissionLab.id)!.results['admission_history']!.passed, isTrue);
    await finish(t);
    expect(store.profile.labPassed(nursingAdmissionLab.id), isTrue);
  });

  testWidgets('Nursing vitals and medication safety through the monitor and MAR', (WidgetTester t) async {
    final CareerSimStore store = await pumpLab(t, nursingVitalsLab.id, major: 'nursing');
    await enterWork(t);
    for (final Vitals v in james.vitals) {
      expect(k('bedside_monitor'), findsOneWidget);
      await t.enterText(k('news_total'), '${News2.total(v)}');
      await tap(t, k('news_resp_${News2.response(v)}'));
      await tap(t, k('news_record'));
    }
    await tap(t, k('vitals_submit'));
    expect(store.labRun(nursingVitalsLab.id)!.results['news_rounds']!.score, 100);

    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: store, child: MaterialApp(key: UniqueKey(), home: LabIntroScreen(labId: nursingMedsLab.id))));
    await t.pumpAndSettle();
    await enterWork(t);
    final MarStep mar = nursingMedsLab.scenarios.first.steps.first as MarStep;
    for (int i = 0; i < mar.correct.length; i++) {
      await tap(t, k('mar_${i}_${mar.correct[i].name}'));
    }
    await tap(t, k('mar_submit'));
    expect(store.labRun(nursingMedsLab.id)!.results['mar_round']!.score, 100);
  });

  testWidgets('Accounting: journal posts to the ledger; reconciliation; statements', (WidgetTester t) async {
    final CareerSimStore store = await pumpLab(t, accountingBookkeepingLab.id, major: 'accounting');
    await enterWork(t);
    final JournalStep j = accountingBookkeepingLab.scenarios.first.steps.first as JournalStep;
    for (int d = 0; d < j.documents.length; d++) {
      await tap(t, k('doc_$d'));
      for (final EntryLine l in j.expected[d]) {
        await pickDropdown(t, 'acct_$d', l.account);
        await tap(t, k(l.debit ? 'side_dr' : 'side_cr'));
        await t.enterText(k('line_amount'), l.amount.toStringAsFixed(0));
        await tap(t, k('add_line'));
      }
    }
    expect(find.textContaining('Dr £29,670.00'), findsNothing);
    expect(find.textContaining('Ledger and trial balance'), findsOneWidget);
    await tap(t, k('journal_submit'));
    expect(store.labRun(accountingBookkeepingLab.id)!.results['journal']!.score, 100);
    await finish(t);

    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: store, child: MaterialApp(key: UniqueKey(), home: LabIntroScreen(labId: accountingReconciliationLab.id))));
    await t.pumpAndSettle();
    await enterWork(t);
    final ReconciliationStep r = accountingReconciliationLab.scenarios.first.steps.first as ReconciliationStep;
    for (int i = 0; i < r.lines.length; i++) {
      await tap(t, k('recon_${i}_${r.lines[i].answer.name}'));
    }
    await t.enterText(k('recon_adjusted'), '3220');
    await tap(t, k('recon_submit'));
    expect(store.labRun(accountingReconciliationLab.id)!.results['recon']!.score, 100);

    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: store, child: MaterialApp(key: UniqueKey(), home: LabIntroScreen(labId: accountingStatementsLab.id))));
    await t.pumpAndSettle();
    await enterWork(t);
    final StatementsStep s = accountingStatementsLab.scenarios.first.steps.first as StatementsStep;
    for (int i = 0; i < s.trialBalance.length; i++) {
      await pickDropdown(t, 'stmt_$i', s.trialBalance[i].line.label);
    }
    expect(find.textContaining('assets £26200.00'), findsOneWidget);
    await t.enterText(k('stmt_ni'), '7200');
    await t.enterText(k('stmt_ta'), '26200');
    await tap(t, k('stmt_submit'));
    expect(store.labRun(accountingStatementsLab.id)!.results['statements']!.score, 100);
  });

  testWidgets('Dashboard navigation reaches every section', (WidgetTester t) async {
    t.view.physicalSize = const Size(1400, 9000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final CareerSimStore store = CareerSimStore(repository: MemoryCareerRepository(), runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await store.ensureLoaded(majorId: 'nursing');
    bool courses = false;
    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(
      value: store,
      child: MaterialApp(home: Scaffold(body: CareerSimDashboard(studentName: 'Ada', majorLabel: 'Nursing', onOpenCourses: () => courses = true))),
    ));
    await t.pumpAndSettle();
    await tap(t, k('nav_courses'));
    expect(courses, isTrue);
    for (final (String key, String title) in <(String, String)>[
      ('nav_schools', 'Departments'),
      ('nav_labs', 'Practical Labs'),
      ('nav_assessments', 'Assessments'),
      ('nav_career', 'Career Centre'),
      ('nav_applications', 'Applications'),
      ('nav_workplace', 'Workplace'),
      ('nav_portfolio', 'My Portfolio'),
      ('nav_progress', 'Progress'),
      ('nav_money', 'My Earnings'),
      ('dash_all_jobs', 'Job Board'),
      ('dash_search', 'Find'),
    ]) {
      await tap(t, k(key));
      expect(find.widgetWithText(AppBar, title), findsOneWidget, reason: key);
      await t.pageBack();
      await t.pumpAndSettle();
    }
    expect(k('dash_next_lab'), findsOneWidget);
    await tap(t, k('dash_next_lab'));
    expect(find.text('Learning objectives'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  test('profile with lab runs round-trips through JSON', () {
    final CareerProfile p = CareerProfile();
    p.labRuns['x'] = LabRun(labId: 'x', scenarioId: 's', startedDay: 2, stepIndex: 1, drafts: <String, String>{'a': 'b'})
      ..results['a'] = const TaskResult(taskId: 'a', score: 50, passed: false);
    p.labCompletions.add(const LabCompletion(labId: 'x', scenarioId: 's', score: 90, passed: true, day: 3));
    expect(CareerProfile.fromJson(p.toJson()).toJson(), p.toJson());
  });
}
