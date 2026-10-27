import 'package:ai_study_buddy/life_sim/careers/career_catalog.dart';
import 'package:ai_study_buddy/life_sim/education/skills.dart';
import 'package:ai_study_buddy/life_sim/workplace/task_bank.dart';
import 'package:ai_study_buddy/life_sim/workplace/work_task.dart';
import 'package:flutter_test/flutter_test.dart';

/// The answer a perfect player would give.
StageAnswer ideal(WorkStage s) {
  switch (s.kind) {
    case StageKind.choice:
      return StageAnswer(choice: s.correct.first);
    case StageKind.multi:
      return StageAnswer(multi: s.correct.toSet());
    case StageKind.order:
      return StageAnswer(order: List<int>.of(s.correct));
    case StageKind.numeric:
      return StageAnswer(number: s.answer);
    case StageKind.text:
      return StageAnswer(text: s.modelAnswer);
    case StageKind.inspect:
      return StageAnswer(inspected: s.items.where((InspectItem i) => i.value == InspectValue.essential).map((InspectItem i) => i.id).toSet());
  }
}

/// A clearly bad answer for the same stage.
StageAnswer awful(WorkStage s) {
  switch (s.kind) {
    case StageKind.choice:
      final int wrong = List<int>.generate(s.options.length, (int i) => i).firstWhere((int i) => !s.correct.contains(i));
      return StageAnswer(choice: wrong);
    case StageKind.multi:
      final Set<int> wrong = <int>{for (int i = 0; i < s.options.length; i++) if (!s.correct.contains(i)) i};
      return StageAnswer(multi: wrong);
    case StageKind.order:
      return StageAnswer(order: s.correct.reversed.toList());
    case StageKind.numeric:
      return StageAnswer(number: (s.answer ?? 0) + 9999);
    case StageKind.text:
      return StageAnswer(text: 'idk');
    case StageKind.inspect:
      return StageAnswer(inspected: s.items.where((InspectItem i) => i.value == InspectValue.wasteful).map((InspectItem i) => i.id).toSet());
  }
}

List<WorkScenario> everyScenario() {
  final List<WorkScenario> out = <WorkScenario>[];
  for (final CareerDef c in CareerCatalog.all) {
    out.addAll(WorkTaskBank.staticFor(c.id));
    for (final ScenarioGenerator g in WorkTaskBank.generatorsFor(c.id)) {
      for (int seed = 1; seed <= 40; seed++) {
        out.add(g.build(seed * 977));
      }
    }
  }
  return out;
}

void main() {
  final Set<String> knownSkills = Skills.all.map((SkillDef s) => s.id).toSet();

  group('Scenario structure', () {
    test('every career has a healthy library at every rank', () {
      for (final CareerDef c in CareerCatalog.all) {
        for (int rank = 0; rank <= kTopRank; rank++) {
          final List<WorkScenario> day = WorkTaskBank.assignDay(careerId: c.id, rank: rank, day: 3);
          expect(day.length, equals(WorkTaskBank.tasksPerDay), reason: '${c.id} rank $rank');
        }
        expect(WorkTaskBank.staticFor(c.id).length + WorkTaskBank.generatorsFor(c.id).length, greaterThanOrEqualTo(7), reason: c.id);
      }
    });

    test('all scenarios are well-formed', () {
      final Set<String> ids = <String>{};
      for (final WorkScenario s in everyScenario()) {
        expect(ids.add(s.id), isTrue, reason: 'duplicate id ${s.id}');
        expect(CareerCatalog.byId(s.careerId), isNotNull, reason: s.id);
        expect(s.stages.isNotEmpty, isTrue, reason: s.id);
        expect(s.station.isNotEmpty, isTrue, reason: s.id);
        expect(s.minutes, greaterThan(0));
        expect(s.minRank <= s.maxRank, isTrue);
        expect(s.skillGain.isNotEmpty, isTrue, reason: s.id);
        for (final String k in s.skillGain.keys) {
          expect(knownSkills.contains(k), isTrue, reason: '${s.id}: $k');
        }
        final Set<String> stageIds = <String>{};
        for (final WorkStage st in s.stages) {
          expect(stageIds.add(st.id), isTrue, reason: 'dup stage ${st.id}');
          expect(st.prompt.trim().isNotEmpty, isTrue);
          switch (st.kind) {
            case StageKind.choice:
              expect(st.options.length, greaterThanOrEqualTo(2), reason: st.id);
              expect(st.correct.length, equals(1), reason: st.id);
              expect(st.correct.first < st.options.length, isTrue, reason: st.id);
              expect(st.options.toSet().length, equals(st.options.length), reason: 'duplicate options ${st.id}');
            case StageKind.multi:
              expect(st.correct.isNotEmpty && st.correct.every((int i) => i < st.options.length), isTrue, reason: st.id);
              expect(st.correct.length < st.options.length, isTrue, reason: 'multi must have a wrong option ${st.id}');
            case StageKind.order:
              expect(st.correct.toSet().length, equals(st.options.length), reason: st.id);
              expect(st.correct.every((int i) => i >= 0 && i < st.options.length), isTrue, reason: st.id);
            case StageKind.numeric:
              expect(st.answer, isNotNull, reason: st.id);
            case StageKind.text:
              expect(st.rubric.length, greaterThanOrEqualTo(3), reason: st.id);
              expect(st.modelAnswer.length, greaterThan(40), reason: st.id);
            case StageKind.inspect:
              expect(st.items.any((InspectItem i) => i.value == InspectValue.essential), isTrue, reason: st.id);
              expect(st.items.map((InspectItem i) => i.id).toSet().length, equals(st.items.length), reason: st.id);
          }
        }
      }
    });

    test('generated scenarios are reproducible from their id', () {
      for (final CareerDef c in CareerCatalog.all) {
        for (final ScenarioGenerator g in WorkTaskBank.generatorsFor(c.id)) {
          final WorkScenario a = g.build(4242);
          final WorkScenario? b = WorkTaskBank.byId(a.id);
          expect(b, isNotNull);
          expect(b!.stages.map((WorkStage s) => s.prompt).toList(), equals(a.stages.map((WorkStage s) => s.prompt).toList()));
        }
      }
      expect(WorkTaskBank.byId('nope'), isNull);
      expect(WorkTaskBank.byId('gen:ac_journal:abc'), isNull);
    });

    test('daily assignments are deterministic, vary by day and avoid recent tasks', () {
      final List<String> a = WorkTaskBank.assignDay(careerId: 'nurse', rank: 1, day: 10).map((WorkScenario s) => s.id).toList();
      final List<String> b = WorkTaskBank.assignDay(careerId: 'nurse', rank: 1, day: 10).map((WorkScenario s) => s.id).toList();
      expect(a, equals(b));
      final Set<String> seen = <String>{};
      for (int d = 1; d <= 12; d++) {
        seen.addAll(WorkTaskBank.assignDay(careerId: 'nurse', rank: 1, day: d).map((WorkScenario s) => s.id));
      }
      expect(seen.length, greaterThan(5));
      final List<String> next = WorkTaskBank.assignDay(careerId: 'nurse', rank: 1, day: 11, recentIds: a).map((WorkScenario s) => s.id).toList();
      expect(next.where(a.contains).length, lessThan(2));
    });

    test('tasks fit the rank they are assigned to', () {
      for (final CareerDef c in CareerCatalog.all) {
        for (int rank = 0; rank <= kTopRank; rank++) {
          for (final WorkScenario s in WorkTaskBank.assignDay(careerId: c.id, rank: rank, day: 5)) {
            expect(s.fitsRank(rank), isTrue, reason: '${s.id} @ $rank');
          }
        }
      }
    });
  });

  group('Grading', () {
    test('ideal answers earn (near) full marks on EVERY scenario, including rubric-graded text', () async {
      final List<String> weak = <String>[];
      for (final WorkScenario s in everyScenario()) {
        final ScenarioRun run = ScenarioRun(s);
        while (!run.finished) {
          await run.submit(ideal(run.stage!));
        }
        if (run.score < 0.9) weak.add('${s.id}: ${run.score.toStringAsFixed(2)} ${run.results.map((StageResult r) => r.score.toStringAsFixed(2)).toList()}');
      }
      expect(weak, equals(<String>[]));
    });

    test('terrible answers never score well', () async {
      final List<String> bad = <String>[];
      for (final WorkScenario s in everyScenario()) {
        final ScenarioRun run = ScenarioRun(s);
        while (!run.finished) {
          await run.submit(awful(run.stage!));
        }
        if (run.score > 0.4) bad.add('${s.id}: ${run.score.toStringAsFixed(2)}');
      }
      expect(bad, equals(<String>[]));
    });

    test('multi-select penalises over-selection', () {
      final WorkStage st = WorkStage.multi(id: 'm', prompt: 'p', options: <String>['a', 'b', 'c', 'd'], correct: <int>[0, 1], explanation: 'e');
      expect(WorkGrader.grade(st, StageAnswer(multi: <int>{0, 1})).score, equals(1));
      expect(WorkGrader.grade(st, StageAnswer(multi: <int>{0})).score, closeTo(0.5, 0.001));
      expect(WorkGrader.grade(st, StageAnswer(multi: <int>{0, 1, 2, 3})).score, lessThan(0.5));
      expect(WorkGrader.grade(st, StageAnswer(multi: <int>{})).score, equals(0));
    });

    test('ordering gives partial credit by correct pairs', () {
      final WorkStage st = WorkStage.order(id: 'o', prompt: 'p', options: <String>['a', 'b', 'c'], correct: <int>[0, 1, 2], explanation: 'e');
      expect(WorkGrader.grade(st, StageAnswer(order: <int>[0, 1, 2])).score, equals(1));
      expect(WorkGrader.grade(st, StageAnswer(order: <int>[1, 0, 2])).score, closeTo(2 / 3, 0.001));
      expect(WorkGrader.grade(st, StageAnswer(order: <int>[2, 1, 0])).score, equals(0));
      expect(WorkGrader.grade(st, StageAnswer(order: <int>[0, 1])).score, equals(0));
    });

    test('numeric grading: exact, close and wrong', () {
      final WorkStage st = WorkStage.numeric(id: 'n', prompt: 'p', answer: 100, tolerance: 1, explanation: 'e');
      expect(WorkGrader.grade(st, StageAnswer(number: 100.5)).score, equals(1));
      expect(WorkGrader.grade(st, StageAnswer(number: 103)).score, equals(0.4));
      expect(WorkGrader.grade(st, StageAnswer(number: 150)).score, equals(0));
      expect(WorkGrader.grade(st, StageAnswer()).score, equals(0));
    });

    test('text grading: keyword rubric, minimum length and profanity', () {
      final WorkStage st = WorkStage.text(
        id: 't',
        prompt: 'p',
        rubric: const <RubricItem>[RubricItem('apology', <String>['sorry']), RubricItem('fix', <String>['refund'])],
        modelAnswer: 'I am sorry, here is a refund.',
        minWords: 5,
      );
      expect(WorkGrader.gradeText(st, 'I am so sorry and I will give you a full refund today').score, equals(1));
      expect(WorkGrader.gradeText(st, 'I am so sorry about this whole thing today').score, closeTo(0.5, 0.001));
      expect(WorkGrader.gradeText(st, 'sorry refund').score, lessThanOrEqualTo(0.35));
      expect(WorkGrader.gradeText(st, 'I am so sorry you idiot, refund coming today').score, lessThan(0.8));
    });

    test('inspection rewards essentials and punishes wasteful actions', () {
      final WorkStage st = WorkStage.inspect(id: 'i', prompt: 'p', explanation: 'e', items: const <InspectItem>[
        InspectItem(id: 'a', label: 'A', reveal: 'x', value: InspectValue.essential),
        InspectItem(id: 'b', label: 'B', reveal: 'x', value: InspectValue.essential),
        InspectItem(id: 'w', label: 'W', reveal: 'x', value: InspectValue.wasteful),
      ]);
      expect(WorkGrader.grade(st, StageAnswer(inspected: <String>{'a', 'b'})).score, equals(1));
      expect(WorkGrader.grade(st, StageAnswer(inspected: <String>{'a'})).score, equals(0.5));
      expect(WorkGrader.grade(st, StageAnswer(inspected: <String>{'a', 'b', 'w'})).score, closeTo(0.8, 0.001));
    });

    test('generated numeric answers are consistent (reconciliation really reconciles)', () async {
      for (int seed = 1; seed <= 60; seed++) {
        final WorkScenario s = WorkTaskBank.generatorsFor('accountant').firstWhere((ScenarioGenerator g) => g.id == 'ac_bankrec').build(seed);
        final double a = s.stages[0].answer!;
        final double b = s.stages[1].answer!;
        expect(a, equals(b));
      }
    });

    test('a pluggable AI judge is used for text, and falls back when it throws', () async {
      final WorkScenario s = WorkTaskBank.byId('se_present')!;
      final ScenarioRun ok = ScenarioRun(s, judge: _FixedJudge(0.77));
      final StageResult r = await ok.submit(StageAnswer(text: 'anything at all here'));
      expect(r.score, equals(0.77));
      final ScenarioRun fallback = ScenarioRun(s, judge: _ThrowingJudge());
      final StageResult r2 = await fallback.submit(StageAnswer(text: s.stages.first.modelAnswer));
      expect(r2.score, greaterThan(0.8));
    });
  });
}

class _FixedJudge implements WorkTextJudge {
  _FixedJudge(this.v);
  final double v;
  @override
  Future<StageResult> gradeText({required WorkScenario scenario, required WorkStage stage, required String text}) async =>
      StageResult(score: v, feedback: 'ai');
}

class _ThrowingJudge implements WorkTextJudge {
  @override
  Future<StageResult> gradeText({required WorkScenario scenario, required WorkStage stage, required String text}) async =>
      throw StateError('offline');
}
