// Plays the first scenario of every lab through the real screens:
// intro → environment → briefing → each step rendered in turn → evaluation →
// completion, checking nothing throws and the result is saved.
//
// Grading rules are tested separately (lab_content_test, drawing_test, …);
// here each step is recorded as passed once its view has rendered, so the
// journey itself — navigation, step views, saving and completion — is what is
// exercised, for all labs.
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/labs/ui/step_views.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'labs_flow_test.dart' show k, pumpLab;

/// Settles, but tolerates views with an indefinite loading animation (the
/// anatomy atlas decodes its SVG asynchronously, which never settles in tests).
Future<void> settle(WidgetTester t) async {
  try {
    await t.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
  } on FlutterError {
    await t.pump(const Duration(milliseconds: 500));
  }
}

Future<void> tap(WidgetTester t, Finder f) async {
  expect(f, findsWidgets, reason: '$f');
  await t.ensureVisible(f.first);
  await t.tap(f.first);
  await settle(t);
}

void main() {
  for (final LabSpec lab in LabCatalog.all) {
    testWidgets('journey: ${lab.id}', (WidgetTester t) async {
      final CareerSimStore store = await pumpLab(t, lab.id, repo: MemoryCareerRepository(), major: lab.majorId);
      expect(find.textContaining(lab.title), findsWidgets, reason: 'intro shows the lab');
      await tap(t, k('lab_start'));
      await tap(t, k('to_briefing'));
      await tap(t, k('begin_work'));
      final LabRun run = store.labRun(lab.id)!;
      final LabScenario sc = lab.scenario(run.scenarioId)!;
      expect(sc.level, LabDifficulty.foundation, reason: 'students start at the beginner level');
      for (int i = 0; i < sc.steps.length; i++) {
        final LabStep step = sc.steps[i];
        expect(find.byType(LabStepView), findsOneWidget, reason: '${lab.id}: step ${step.id} should be on screen');
        expect(find.textContaining('ticket ${i + 1} of ${sc.steps.length}: ${step.title}'), findsOneWidget, reason: '${lab.id}: showing ${step.id}');
        expect(t.takeException(), isNull, reason: '${lab.id}: ${step.id} rendered without errors');
        await store.recordLabStep(lab, step, TaskResult(taskId: step.id, score: 100, passed: true));
        await settle(t);
        if (i < sc.steps.length - 1) await tap(t, k('step_next'));
      }
      await tap(t, k('to_evaluation'));
      expect(find.textContaining('Final result'), findsOneWidget);
      await tap(t, k('finish_lab'));
      expect(find.textContaining('Lab passed'), findsOneWidget);
      expect(store.profile.labScenarioPassed(lab.id, sc.id), isTrue, reason: 'the pass is saved');
      expect(t.takeException(), isNull);
    });
  }
}
