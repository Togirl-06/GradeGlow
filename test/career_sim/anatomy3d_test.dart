import 'dart:io';

import 'package:ai_study_buddy/career_sim/labs/anatomy3d/anatomy3d.dart';
import 'package:ai_study_buddy/career_sim/labs/anatomy3d/anatomy3d_scenarios.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_grading.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'labs_flow_test.dart' show k, pumpLab, tap;

List<Anatomy3DStep> _steps() => <Anatomy3DStep>[
      for (final LabSpec l in LabCatalog.all)
        for (final LabScenario s in l.scenarios)
          for (final LabStep st in s.steps)
            if (st is Anatomy3DStep) st,
    ];

void main() {
  test('the 3D viewer data and the app agree on every structure', () {
    final String js = File('web/anatomy_3d/structures.js').readAsStringSync();
    final Set<String> jsIds = RegExp(r'"id":"([a-z0-9_]+)"').allMatches(js).map((Match m) => m.group(1)!).toSet();
    expect(jsIds, anatomyStructures.map((AnatomyStructure s) => s.id).toSet());
    expect(anatomyStructures.length, greaterThanOrEqualTo(50));
    expect(anatomySystems.length, 8);
  });

  test('every 3D question names real structures, and the anatomy lab has 3D scenarios at each level', () {
    final List<Anatomy3DStep> steps = _steps();
    expect(steps.length, anatomy3DScenarios.length);
    for (final Anatomy3DStep s in steps) {
      for (final AnatomyQuestion q in s.questions) {
        for (final String a in q.answers) {
          expect(structureById(a), isNotNull, reason: '${s.id}: $a');
        }
      }
      final Map<int, String> right = <int, String>{for (int i = 0; i < s.questions.length; i++) i: s.questions[i].answers.first};
      expect(Anatomy3DGrader.grade(s, right).score, 100);
      final Map<int, String> wrong = <int, String>{for (int i = 0; i < s.questions.length; i++) i: 'patella_l'};
      expect(Anatomy3DGrader.grade(s, wrong).passed, isFalse);
    }
    for (final LabDifficulty d in LabDifficulty.values) {
      expect(anatomy3DScenarios.where((LabScenario s) => s.level == d).length, 2);
    }
  });

  test('a wrong-side answer is explained', () {
    final Anatomy3DStep s = _steps().firstWhere((Anatomy3DStep s) => s.id == 'a3d_sides_3d');
    final Map<int, String> picks = <int, String>{for (int i = 0; i < s.questions.length; i++) i: s.questions[i].answers.first};
    picks[0] = 'kidney_r';
    final TaskResult r = Anatomy3DGrader.grade(s, picks);
    expect(r.feedback.first, contains('Check the side'));
    expect(() => Anatomy3DGrader.grade(s, <int, String>{0: 'kidney_l'}), throwsA(isA<LabGradingException>()));
  });

  test('3D scene tests (node): every structure can be tapped and sides are right', () async {
    final ProcessResult r;
    try {
      r = await Process.run('node', <String>['--test', 'web/anatomy_3d/test/anatomy3d.test.js']);
    } on ProcessException {
      markTestSkipped('node is not installed');
      return;
    }
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
  });

  testWidgets('anatomy lab: identify organs from the list where 3D is unavailable, and pass', (WidgetTester t) async {
    final CareerSimStore store = await pumpLab(t, medicineAnatomyLabId, repo: MemoryCareerRepository(), major: 'medicine');
    await tap(t, k('start_a3d_organs'));
    await tap(t, k('to_briefing'));
    await tap(t, k('begin_work'));
    expect(find.textContaining('choose from the list'), findsOneWidget);
    for (final String id in <String>['heart', 'liver', 'stomach', 'lung_l', 'kidney_r', 'brain']) {
      await tap(t, k('a3d_pick_$id'));
      await tap(t, k('a3d_confirm'));
    }
    expect(find.text('6 of 6 identified'), findsOneWidget);
    await tap(t, k('a3d_submit'));
    expect(store.labRun(medicineAnatomyLabId)!.results['a3d_organs_3d']!.score, 100);
  });
}

const String medicineAnatomyLabId = 'md_lab_anatomy';
