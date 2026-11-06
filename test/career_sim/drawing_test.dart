import 'package:ai_study_buddy/career_sim/labs/content/eng_mechanical.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_grading.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/labs/work/drawing_step.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'labs_flow_test.dart' show k, pumpLab, tap;

const DrawingStep _plate = DrawingStep(
  id: 'p',
  title: 'Plate',
  instructions: '',
  spec: DrawingSpec(width: 100, height: 50, holes: <HoleSpec>[HoleSpec(20, 25, 10, tol: 'H7'), HoleSpec(80, 25, 10, tol: 'H7')], allowCountNotes: true, title: <String, String>{'Units': 'mm'}),
  model: Drawing(),
);

const List<DrawCircle> _holes = <DrawCircle>[DrawCircle(20, 25, 10), DrawCircle(80, 25, 10)];
const List<DrawDim> _locate = <DrawDim>[
  DrawDim('h', 'L', 'R'),
  DrawDim('v', 'B', 'T'),
  DrawDim('h', 'L', 'c0'),
  DrawDim('h', 'c0', 'c1'), // chain dimension: still located from the datum
  DrawDim('v', 'B', 'c0'),
  DrawDim('v', 'B', 'c1'),
];

void main() {
  group('drawing grader', () {
    test('a complete, toleranced drawing passes', () {
      const Drawing d = Drawing(width: 100, height: 50, circles: _holes, title: <String, String>{'Units': 'mm'}, dims: <DrawDim>[
        ..._locate,
        DrawDim('d', 'c0', '', 'H7'),
        DrawDim('d', 'c1', '', 'H7'),
      ]);
      final TaskResult r = DrawingGrader.grade(_plate, d);
      expect(r.score, 100, reason: r.feedback.join('\n'));
      expect(r.passed, isTrue);
    });

    test('one "2×" note covers equal holes', () {
      const Drawing d = Drawing(width: 100, height: 50, circles: _holes, title: <String, String>{'Units': 'mm'}, dims: <DrawDim>[..._locate, DrawDim('d', 'c0', '', '2× H7')]);
      expect(DrawingGrader.grade(_plate, d).score, 100);
    });

    test('a redundant dimension is a fault', () {
      const Drawing d = Drawing(width: 100, height: 50, circles: _holes, title: <String, String>{'Units': 'mm'}, dims: <DrawDim>[
        ..._locate,
        DrawDim('h', 'L', 'c1'), // closes the chain L–c0–c1
        DrawDim('d', 'c0', '', '2× H7'),
      ]);
      final TaskResult r = DrawingGrader.grade(_plate, d);
      expect(r.score, lessThan(100));
      expect(r.feedback.join('\n'), contains('Redundant dimension'));
    });

    test('an unlocated hole, a missing tolerance and a wrong title are named', () {
      const Drawing d = Drawing(width: 100, height: 50, circles: _holes, title: <String, String>{'Units': 'inch'}, dims: <DrawDim>[
        DrawDim('h', 'L', 'R'),
        DrawDim('v', 'B', 'T'),
        DrawDim('h', 'L', 'c0'),
        DrawDim('v', 'B', 'c0'),
        DrawDim('d', 'c0'),
        DrawDim('d', 'c1', '', 'H7'),
      ]);
      final String fb = DrawingGrader.grade(_plate, d).feedback.join('\n');
      expect(fb, contains('Hole 2 is not located'));
      expect(fb, contains('Hole 1 needs its tolerance H7'));
      expect(fb, contains('Units should be mm, not inch'));
    });

    test('wrong geometry cannot pass however well it is dimensioned', () {
      const Drawing d = Drawing(width: 100, height: 50, circles: <DrawCircle>[DrawCircle(20, 25, 12), DrawCircle(80, 25, 10)], title: <String, String>{'Units': 'mm'}, dims: <DrawDim>[
        ..._locate,
        DrawDim('d', 'c0', '', 'H7'),
        DrawDim('d', 'c1', '', 'H7'),
      ]);
      final TaskResult r = DrawingGrader.grade(_plate, d);
      expect(r.passed, isFalse);
      expect(r.feedback.first, contains('cannot be released'));
    });

    test('an extra hole is caught', () {
      const Drawing d = Drawing(width: 100, height: 50, circles: <DrawCircle>[..._holes, DrawCircle(50, 25, 5)], title: <String, String>{'Units': 'mm'});
      expect(DrawingGrader.grade(_plate, d).feedback.join('\n'), contains('machined by mistake'));
    });

    test('no outline is an incomplete submission', () {
      expect(() => DrawingGrader.grade(_plate, const Drawing()), throwsA(isA<LabGradingException>()));
    });

    test('drawings survive a save and reload', () {
      const Drawing d = Drawing(width: 100, height: 50, circles: _holes, dims: _locate, title: <String, String>{'Units': 'mm'});
      final Drawing back = Drawing.fromJson(Map<String, dynamic>.from(d.toJson()));
      expect(back.dims.length, _locate.length);
      expect(back.circles[1].x, 80);
      expect(back.title['Units'], 'mm');
    });
  });

  test('every CAD drawing scenario: the model passes and an empty sheet fails', () {
    final List<DrawingStep> steps = <DrawingStep>[
      for (final LabSpec l in LabCatalog.all)
        for (final LabScenario s in l.scenarios)
          for (final LabStep st in s.steps)
            if (st is DrawingStep) st,
    ];
    expect(steps.length, greaterThanOrEqualTo(9));
    for (final DrawingStep s in steps) {
      final TaskResult good = DrawingGrader.grade(s, s.model);
      expect(good.passed, isTrue, reason: '${s.id}: ${good.feedback.join(' | ')}');
      final TaskResult bad = DrawingGrader.grade(s, Drawing(width: s.spec.width, height: s.spec.height));
      expect(bad.passed, isFalse, reason: s.id);
    }
    expect(mechCadLab.scenarios.where((LabScenario s) => s.steps.any((LabStep st) => st is DrawingStep)).length, 9);
  });

  testWidgets('CAD lab: draw, dimension, fill the title block and pass', (WidgetTester t) async {
    final CareerSimStore store = await pumpLab(t, mechCadLab.id, repo: MemoryCareerRepository(), major: 'mechanical_engineering');
    await tap(t, k('lab_start'));
    await tap(t, k('to_briefing'));
    await tap(t, k('begin_work'));
    expect(store.labRun(mechCadLab.id)!.scenarioId, 'mcd_bracket_1');

    await t.enterText(k('cad_w'), '120');
    await t.enterText(k('cad_h'), '80');
    await tap(t, k('cad_outline'));
    for (final (String x, String y) in const <(String, String)>[('20', '20'), ('100', '20'), ('20', '60'), ('100', '60')]) {
      await t.enterText(k('cad_hx'), x);
      await t.enterText(k('cad_hy'), y);
      await t.enterText(k('cad_hd'), '10');
      await tap(t, k('cad_add_hole'));
    }
    expect(k('cad_hole_3'), findsOneWidget);

    // Leave the title block empty first: the check names what is missing.
    await tap(t, k('cad_submit'));
    expect(find.textContaining('Scale should be 1:1 (not filled in)'), findsOneWidget);

    await tap(t, k('cad_title_Scale_1:1'));
    await tap(t, k('cad_title_Projection_Third angle'));
    await tap(t, k('cad_title_Units_mm'));
    // A dimension is added through the tool and drawn on the sheet.
    await tap(t, k('cad_kind_h'));
    await tap(t, k('cad_from_L'));
    await tap(t, k('cad_to_R'));
    await tap(t, k('cad_add_dim'));
    expect(find.textContaining('Horizontal 120: left edge → right edge'), findsOneWidget);
    await tap(t, k('cad_submit'));
    expect(store.labRun(mechCadLab.id)!.results['mcd_bracket_1_draw']!.score, 100);
    expect(store.labRun(mechCadLab.id)!.drafts['mcd_bracket_1_draw'], contains('"w":120'), reason: 'the drawing is saved');
  });
}
