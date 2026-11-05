import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/career_sim/model/tasks.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:ai_study_buddy/career_sim/ui/career_centre.dart';
import 'package:ai_study_buddy/career_sim/ui/department_screens.dart';
import 'package:ai_study_buddy/career_sim/ui/job_screens.dart';
import 'package:ai_study_buddy/career_sim/ui/task_views.dart';
import 'package:ai_study_buddy/career_sim/ui/workplace_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Finder k(String key) => find.byKey(ValueKey<String>(key));

Future<CareerSimStore> pump(WidgetTester t, Widget home, {String major = 'computer_science'}) async {
  t.view.physicalSize = const Size(1400, 9000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final CareerSimStore store = CareerSimStore(repository: MemoryCareerRepository());
  await store.ensureLoaded(majorId: major);
  await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(value: store, child: MaterialApp(home: home)));
  await t.pumpAndSettle();
  return store;
}

Future<void> tap(WidgetTester t, Finder f) async {
  expect(f, findsWidgets);
  await t.ensureVisible(f.first);
  await t.tap(f.first);
  await t.pumpAndSettle();
}

Future<void> pickDropdown(WidgetTester t, String key, String value) async {
  await tap(t, k(key));
  await t.tap(find.text(value).last);
  await t.pumpAndSettle();
}

int best(DecisionStep s) {
  int b = 0;
  for (int i = 0; i < s.options.length; i++) {
    if (s.options[i].points > s.options[b].points) b = i;
  }
  return b;
}

/// Answers a task correctly through its screen controls.
Future<void> answerCorrectly(WidgetTester t, TaskSpec s) async {
  if (s is DecisionTaskSpec) {
    for (int i = 0; i < s.steps.length; i++) {
      await tap(t, k('opt_${i}_${best(s.steps[i])}'));
    }
  } else if (s is NumericTaskSpec) {
    for (int i = 0; i < s.parts.length; i++) {
      await t.enterText(k('num_$i'), '${s.parts[i].answer}');
    }
  } else if (s is LedgerTaskSpec) {
    for (int i = 0; i < s.transactions.length; i++) {
      await pickDropdown(t, 'dr_$i', s.transactions[i].debit);
      await pickDropdown(t, 'cr_$i', s.transactions[i].credit);
      await t.enterText(k('amt_$i'), '${s.transactions[i].amount}');
    }
  } else if (s is ClassifyTaskSpec) {
    for (int i = 0; i < s.items.length; i++) {
      await tap(t, k('cls_${i}_${s.categories.indexOf(s.items[i].category)}'));
    }
  } else if (s is OrderTaskSpec) {
    final List<int> order = scrambledOrder(s.steps.length);
    for (int pass = 0; pass < order.length; pass++) {
      for (int p = 0; p < order.length - 1; p++) {
        if (order[p] > order[p + 1]) {
          await tap(t, k('ord_down_$p'));
          final int x = order[p];
          order[p] = order[p + 1];
          order[p + 1] = x;
        }
      }
    }
  } else if (s is LabelTaskSpec) {
    for (int i = 0; i < s.hotspots.length; i++) {
      await pickDropdown(t, 'lbl_$i', s.hotspots[i].answer);
    }
  } else if (s is CourtroomTaskSpec) {
    for (int i = 0; i < s.transcript.length; i++) {
      final String? g = s.transcript[i].objection;
      await tap(t, k(g == null ? 'court_${i}_none' : 'court_${i}_${s.grounds.indexOf(g)}'));
    }
  } else if (s is WorkupTaskSpec) {
    for (int i = 0; i < s.investigations.length; i++) {
      if (s.investigations[i].relevant) await tap(t, k('inv_$i'));
    }
    await tap(t, k('order_tests'));
    await tap(t, k('dx_${s.correctDiagnosis}'));
    for (int m = 0; m < s.management.length; m++) {
      await tap(t, k('mg_${m}_${best(s.management[m])}'));
    }
  } else {
    fail('no UI driver for ${s.runtimeType}');
  }
}

void main() {
  for (final Department d in CareerCatalog.departments) {
    testWidgets('${d.title}: every module, project and certification screen opens', (WidgetTester t) async {
      await pump(t, DepartmentScreen(deptId: d.id), major: d.majors.first);
      for (final TrainingModule m in d.modules) {
        await tap(t, k('module_${m.id}'));
        expect(find.text(m.title), findsWidgets);
        for (final TaskSpec s in m.practice) {
          await tap(t, k('practice_${s.id}'));
          expect(find.text(s.title), findsWidgets);
          await t.pageBack();
          await t.pumpAndSettle();
        }
        await t.pageBack();
        await t.pumpAndSettle();
      }
      for (final ProjectSpec p in d.projects) {
        await tap(t, k('project_${p.id}'));
        await tap(t, k('publish_project'));
        expect(find.byType(SnackBar), findsWidgets, reason: 'refusal must be explained');
        await t.pageBack();
        await t.pumpAndSettle();
      }
      for (final Certification c in d.certifications) {
        await tap(t, k('cert_${c.id}'));
        await tap(t, k('claim_cert'));
        expect(find.byType(SnackBar), findsWidgets);
        await t.pageBack();
        await t.pumpAndSettle();
      }
      expect(t.takeException(), isNull);
    });
  }

  // One graded submission through the UI for every non-code task in the
  // simulator's training modules.
  final List<(Department, TrainingModule, TaskSpec)> tasks = <(Department, TrainingModule, TaskSpec)>[
    for (final Department d in CareerCatalog.departments)
      for (final TrainingModule m in d.modules)
        for (final TaskSpec s in m.practice)
          if (s is! CodeTaskSpec && s is! WrittenTaskSpec) (d, m, s),
  ];
  for (final (Department, TrainingModule, TaskSpec) x in tasks) {
    final (Department d, TrainingModule m, TaskSpec s) = x;
    testWidgets('${d.id}/${m.id}/${s.id}: correct answers pass through the screen and are saved', (WidgetTester t) async {
      final CareerSimStore store = await pump(t, ModuleScreen(deptId: d.id, moduleId: m.id), major: d.majors.first);
      await tap(t, k('practice_${s.id}'));
      await answerCorrectly(t, s);
      await tap(t, k('task_submit'));
      expect(find.text('Passed'), findsOneWidget);
      expect(store.profile.taskResults[CareerSimStore.moduleTaskKey(m, s)]!.passed, isTrue);
    });
  }

  testWidgets('submitting an incomplete answer is refused with a message', (WidgetTester t) async {
    final CareerSimStore store = await pump(t, const ModuleScreen(deptId: 'nursing', moduleId: 'nu_m1'), major: 'nursing');
    await tap(t, k('practice_high_bp'));
    await tap(t, k('task_submit'));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(store.profile.taskResults, isEmpty);
  });

  testWidgets('job board, every posting and the Career Centre open', (WidgetTester t) async {
    await pump(t, const JobBoardScreen());
    await tap(t, k('filter_all'));
    for (final JobPosting j in CareerCatalog.postings) {
      await tap(t, k('posting_${j.id}'));
      expect(find.text(j.title), findsWidgets);
      expect(find.text('Requirements'), findsOneWidget);
      await t.pageBack();
      await t.pumpAndSettle();
    }
    expect(t.takeException(), isNull);
  });

  testWidgets('Career Centre: resume validation, cover letter save and trainee refusal', (WidgetTester t) async {
    final CareerSimStore store = await pump(t, const CareerCentreScreen());
    await tap(t, k('request_trainee'));
    expect(store.profile.stage, CareerStage.student);
    await tap(t, k('open_resume'));
    await t.enterText(k('cv_name'), 'Kai');
    await t.enterText(k('cv_email'), 'not an email');
    await tap(t, k('cv_save'));
    expect(store.profile.resume.email, isEmpty);
    await t.enterText(k('cv_email'), 'kai@example.com');
    await tap(t, k('cv_save'));
    expect(store.profile.resume.email, 'kai@example.com');
    await t.pageBack();
    await t.pumpAndSettle();
    await tap(t, k('open_cover_letter'));
    await t.enterText(k('cl_text'), 'Too short.');
    await tap(t, k('cl_save'));
    expect(store.coverLetterFor(''), isNull);
    await t.enterText(k('cl_text'), List<String>.filled(60, 'motivated').join(' '));
    await tap(t, k('cl_save'));
    expect(store.coverLetterFor(''), isNotNull);
  });

  testWidgets('workplace without a job explains how to get one', (WidgetTester t) async {
    await pump(t, const WorkplaceScreen());
    expect(find.textContaining('not employed'), findsOneWidget);
  });
}
