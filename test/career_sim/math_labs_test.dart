import 'package:ai_study_buddy/career_sim/labs/content/math_labs_pure.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_grading.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/labs/math/math_steps.dart';
import 'package:ai_study_buddy/career_sim/labs/math/math_views.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'labs_flow_test.dart' show FakeLabRunner, k, pumpLab, tap;

/// The model answer for a maths step, in the form its grader takes.
Object modelAnswer(LabStep s) => switch (s) {
      WorkingStep() => s.model.join('\n'),
      NumericStep() => _answers(s.questions),
      MatrixStep() => <List<String>>[for (final List<double> r in s.answer) <String>[for (final double v in r) '$v']],
      OdeStep() => s.model,
      GraphStep() => (s.modelParams, _answers(s.questions)),
      _ => throw StateError('not a maths step: ${s.id}'),
    };

Map<String, String> _answers(List<MathQuestion> qs) => <String, String>{
      for (final MathQuestion q in qs) q.id: switch (q) { NumberQuestion() => '${q.answer}', ChoiceQuestion() => '${q.correct}' },
    };

Object wrongAnswer(LabStep s) => switch (s) {
      WorkingStep() => 'x = 123456\nx = 123456\nx = 123456',
      NumericStep() => <String, String>{
          for (final MathQuestion q in s.questions) q.id: switch (q) { NumberQuestion() => '${q.answer + 1000}', ChoiceQuestion() => '${(q.correct + 1) % q.options.length}' },
        },
      MatrixStep() => <List<String>>[for (final List<double> r in s.answer) <String>[for (final double v in r) '${v + 7}']],
      OdeStep() => 'x^7 + 3',
      GraphStep() => (<String, double>{for (final GraphParam p in s.params) p.name: p.max}, <String, String>{for (final MathQuestion q in s.questions) q.id: '99999'}),
      _ => throw StateError(s.id),
    };

void main() {
  group('every maths scenario', () {
    for (final LabSpec lab in LabCatalog.mathLabs) {
      test('${lab.id}: 15 distinct scenarios, 5 per level', () {
        expect(lab.scenarios, hasLength(15));
        for (final LabDifficulty level in LabDifficulty.values) {
          expect(lab.atLevel(level), hasLength(5), reason: level.label);
        }
        expect(lab.scenarios.map((LabScenario s) => s.briefing.what).toSet(), hasLength(15), reason: 'scenarios must be different assignments');
      });

      for (final LabScenario sc in lab.scenarios) {
        test('${lab.id}/${sc.id}: model answers score 100, wrong answers fail', () {
          expect(sc.steps, isNotEmpty);
          for (final LabStep s in sc.steps) {
            final TaskResult good = gradeMathStep(s, modelAnswer(s));
            expect(good.score, 100, reason: '${s.id}:\n${good.feedback.join('\n')}');
            expect(good.passed, isTrue, reason: s.id);
            final TaskResult bad = gradeMathStep(s, wrongAnswer(s));
            expect(bad.passed, isFalse, reason: '${s.id}:\n${bad.feedback.join('\n')}');
            expect(bad.feedback, isNotEmpty, reason: s.id);
          }
        });
      }
    }
  });

  test('unanswered questions are refused, not marked wrong', () {
    final NumericStep s = mathCalculusLab.scenario('calc_b4')!.steps.first as NumericStep;
    expect(() => NumericGrader.grade(s, const <String, String>{}), throwsA(isA<LabGradingException>()));
  });

  test('levels unlock after two passes and progress is saved', () async {
    final MemoryCareerRepository repo = MemoryCareerRepository();
    final CareerSimStore store = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await store.ensureLoaded(userId: 'u', majorId: 'mathematics');
    final LabSpec lab = mathAlgebraLab;
    final LabScenario hard = lab.scenario('alg_i1')!;
    expect(store.labScenarioUnlocked(lab, hard), isFalse);
    await expectLater(store.startLab(lab, scenarioId: hard.id), throwsA(isA<CareerActionException>()));

    Future<void> pass(String id) async {
      await store.startLab(lab, scenarioId: id, restart: true);
      final LabScenario sc = lab.scenario(id)!;
      for (final LabStep s in sc.steps) {
        await store.recordLabStep(lab, s, gradeMathStep(s, modelAnswer(s)));
      }
      await store.setLabPhase(lab, LabPhase.evaluation);
      final LabCompletion c = await store.finishLab(lab);
      expect(c.passed, isTrue);
    }

    await pass('alg_b1');
    expect(store.nextLabScenario(lab)?.id, 'alg_b2');
    expect(store.labScenarioUnlocked(lab, hard), isFalse);
    await pass('alg_b3');
    expect(store.labScenarioUnlocked(lab, hard), isTrue);
    expect(store.labScenarioUnlocked(lab, lab.scenario('alg_a1')!), isFalse);

    final CareerSimStore reloaded = CareerSimStore(repository: repo, runner: FakeLabRunner(const <String, List<List<Object?>>>{}));
    await reloaded.ensureLoaded(userId: 'u', majorId: 'mathematics');
    expect(reloaded.profile.labScenarioPassed(lab.id, 'alg_b1'), isTrue);
    expect(reloaded.profile.labScenarioPassed(lab.id, 'alg_b3'), isTrue);
    expect(reloaded.labScenarioUnlocked(lab, hard), isTrue);
    expect(reloaded.profile.skillPoints['ma_algebra'] ?? 0, greaterThan(0));
  });

  testWidgets('Algebra lab: tools, line-by-line marking, revision, saved result, next challenge', (WidgetTester t) async {
    final MemoryCareerRepository repo = MemoryCareerRepository();
    final CareerSimStore store = await pumpLab(t, mathAlgebraLab.id, repo: repo, major: 'mathematics');
    expect(k('scenario_alg_b1'), findsOneWidget);
    expect(k('start_alg_i1'), findsNothing, reason: 'intermediate scenarios are locked at first');

    await tap(t, k('lab_start'));
    // The calculator in the environment really evaluates.
    await tap(t, k('tool_calculator'));
    await t.enterText(k('calc_input'), '2^10 + sqrt(16)');
    await tap(t, k('calc_go'));
    expect(find.text('2^10 + sqrt(16) = 1028'), findsOneWidget);
    await tap(t, k('to_briefing'));
    await tap(t, k('begin_work'));

    // A slip on the first line is found there.
    await t.enterText(k('working_input'), '3x - 2 = 2x + 5\nx = 7');
    await tap(t, k('working_submit'));
    expect(find.textContaining('The first incorrect step is line 1'), findsOneWidget);
    expect(store.labRun(mathAlgebraLab.id)!.results['alg_b1_1']!.passed, isFalse);

    // The result is shown above the task and the editor is ready to revise and resubmit.
    expect(k('task_result'), findsOneWidget);
    await t.enterText(k('working_input'), '3x - 6 = 2x + 5\nx - 6 = 5\nx = 11');
    await tap(t, k('working_submit'));
    expect(find.textContaining('Every line is valid'), findsOneWidget);
    expect(store.labRun(mathAlgebraLab.id)!.results['alg_b1_1']!.score, 100);
    expect(store.labRun(mathAlgebraLab.id)!.drafts['alg_b1_1'], contains('x = 11'), reason: 'working is saved as it is typed');

    await tap(t, k('to_evaluation'));
    expect(find.textContaining('Final result: 100/100'), findsOneWidget);
    await tap(t, k('finish_lab'));
    expect(find.textContaining('Lab passed'), findsOneWidget);
    expect(find.textContaining('Next challenge: Equation with fractions'), findsOneWidget);

    await tap(t, k('next_scenario'));
    expect(store.labRun(mathAlgebraLab.id)!.scenarioId, 'alg_b2');
    expect(store.profile.labScenarioPassed(mathAlgebraLab.id, 'alg_b1'), isTrue);
  });
}
