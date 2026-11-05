import 'package:ai_study_buddy/career_sim/labs/content/law_labs.dart';
import 'package:ai_study_buddy/career_sim/labs/content/law_matters.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/labs/math/math_steps.dart';
import 'package:ai_study_buddy/career_sim/labs/math/math_views.dart';
import 'package:ai_study_buddy/career_sim/labs/work/work_steps.dart';
import 'package:ai_study_buddy/career_sim/labs/work/work_views.dart';
import 'package:ai_study_buddy/career_sim/labs/workplace.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'labs_flow_test.dart' show k, pumpLab, tap;

Map<String, String> correctAnswers(List<MathQuestion> qs) => <String, String>{
      for (final MathQuestion q in qs) q.id: switch (q) { NumberQuestion() => '${q.answer}', ChoiceQuestion() => '${q.correct}' },
    };

Map<String, String> wrongAnswers(List<MathQuestion> qs) => <String, String>{
      for (final MathQuestion q in qs) q.id: switch (q) { NumberQuestion() => '${q.answer + 1000}', ChoiceQuestion() => '${(q.correct + 1) % q.options.length}' },
    };

bool isWorkStep(LabStep s) => s is TriageStep || s is SequenceStep || s is DocumentStep || s is DialogueStep || s is SimulationStep;
bool isMathStep(LabStep s) => s is WorkingStep || s is NumericStep || s is MatrixStep || s is OdeStep || s is GraphStep;

TaskResult gradeModel(LabStep s) => switch (s) {
      TriageStep() => gradeWorkStep(s, <String, Map<String, String>>{
          for (final TriageItem i in s.items) i.id: <String, String>{for (final MapEntry<String, String> e in i.answers.entries) e.key: e.value.split('|').first},
        }),
      SequenceStep() => gradeWorkStep(s, List<int>.generate(s.correctOrder.length, (int i) => i)),
      DocumentStep() => gradeWorkStep(s, s.model),
      DialogueStep() => gradeWorkStep(s, (
          <String>[for (final DialogueOption o in s.options) if (o.value == DialogueValue.essential || o.value == DialogueValue.useful) o.id],
          correctAnswers(s.conclusions),
        )),
      SimulationStep() => gradeWorkStep(s, (s.model, correctAnswers(s.questions))),
      WorkingStep() => gradeMathStep(s, s.model.join('\n')),
      NumericStep() => gradeMathStep(s, correctAnswers(s.questions)),
      MatrixStep() => gradeMathStep(s, <List<String>>[for (final List<double> r in s.answer) <String>[for (final double v in r) '$v']]),
      OdeStep() => gradeMathStep(s, s.model),
      GraphStep() => gradeMathStep(s, (s.modelParams, correctAnswers(s.questions))),
      _ => throw StateError(s.id),
    };

TaskResult gradeWrong(LabStep s) => switch (s) {
      TriageStep() => gradeWorkStep(s, <String, Map<String, String>>{
          for (final TriageItem i in s.items)
            i.id: <String, String>{
              for (final TriageField f in s.fields)
                if (i.answers[f.id] != null) f.id: f.options.firstWhere((String o) => !i.answers[f.id]!.split('|').contains(o)),
            },
        }),
      SequenceStep() => gradeWorkStep(s, List<int>.generate(s.correctOrder.length, (int i) => s.correctOrder.length - 1 - i)),
      DocumentStep() => gradeWorkStep(s, <String, String>{for (final DocSection d in s.sections) d.id: 'Not sure.'}),
      DialogueStep() => gradeWorkStep(s, (
          <String>[for (final DialogueOption o in s.options) if (o.value == DialogueValue.poor || o.value == DialogueValue.unsafe || o.value == DialogueValue.neutral) o.id],
          wrongAnswers(s.conclusions),
        )),
      SimulationStep() => gradeWorkStep(s, (<String, double>{for (final SimInput i in s.inputs) i.name: i.max}, wrongAnswers(s.questions))),
      _ => throw StateError(s.id),
    };

void main() {
  test('every lab has a workplace and every scenario has steps', () {
    for (final LabSpec lab in LabCatalog.all) {
      expect(workplaceFor(lab).employer, isNot(contains('GradeGlow Partner')), reason: '${lab.id} (${lab.majorId}) needs a workplace');
      for (final LabScenario sc in lab.scenarios) {
        expect(sc.steps, isNotEmpty, reason: sc.id);
      }
    }
  });

  group('model answers pass and wrong answers fail', () {
    for (final LabSpec lab in LabCatalog.all) {
      final List<LabStep> steps = <LabStep>[for (final LabScenario sc in lab.scenarios) ...sc.steps.where(isWorkStep)];
      if (steps.isEmpty) continue;
      test(lab.id, () {
        for (final LabStep s in steps) {
          final TaskResult good = gradeModel(s);
          expect(good.score, 100, reason: '${s.id}:\n${good.feedback.join('\n')}');
          final TaskResult bad = gradeWrong(s);
          expect(bad.passed, isFalse, reason: '${s.id}:\n${bad.feedback.join('\n')}');
        }
      });
    }
  });

  group('law', () {
    test('only real authorities from the file may be cited', () {
      final DocumentStep d = lawResearchLab.scenarios.first.steps.last as DocumentStep;
      final Map<String, String> answer = Map<String, String>.of(d.model);
      answer['law'] = '${answer['law']} See also Smith v Jones [2021] UKSC 99, which says the same.';
      final TaskResult r = gradeWorkStep(d, answer);
      expect(r.passed, isFalse);
      expect(r.feedback.first, contains('Unverified authority'));
      expect(DocumentGrader.unverifiedCitations('As held in Carlill v Carbolic Smoke Ball Co, and in R v Barton and Booth', <String>[
        'Carlill v Carbolic Smoke Ball Co [1893] 1 QB 256',
        'R v Barton and Booth [2020] EWCA Crim 575',
      ]), isEmpty);
    });

    test('guaranteeing an outcome fails the document', () {
      final DocumentStep d = lawDraftingLab.scenarios.first.steps.first as DocumentStep;
      final Map<String, String> answer = Map<String, String>.of(d.model);
      answer[answer.keys.first] = '${answer[answer.keys.first]} I guarantee you will win.';
      expect(gradeWorkStep(d, answer).passed, isFalse);
    });

    test('leading your own witness draws a sustained objection and loses marks', () {
      final DialogueStep court = lawCourtroomLab.scenarios.first.steps.first as DialogueStep;
      final List<String> open = <String>[for (final DialogueOption o in court.options) if (o.value == DialogueValue.essential) o.id];
      final List<String> leading = <String>[for (final DialogueOption o in court.options) if (o.id.startsWith('lead')) o.id];
      expect(leading, isNotEmpty);
      expect(court.options.firstWhere((DialogueOption o) => o.id == leading.first).reply, contains('Sustained'));
      final TaskResult clean = gradeWorkStep(court, (open, correctAnswers(court.conclusions)));
      final TaskResult led = gradeWorkStep(court, (<String>[...open, ...leading], correctAnswers(court.conclusions)));
      expect(led.score, lessThan(clean.score));
    });

    test('the fifteen matters are distinct and cite only listed authorities', () {
      expect(lawMatters.map((LegalMatter m) => m.issue).toSet(), hasLength(15));
      for (final LegalMatter m in lawMatters) {
        expect(RegExp(m.issuePattern, caseSensitive: false).hasMatch(m.issue), isTrue, reason: m.id);
        expect(RegExp(m.conclusionPattern, caseSensitive: false).hasMatch(m.conclusion), isTrue, reason: m.id);
        expect(m.relevant.isNotEmpty || m.legislation.isNotEmpty, isTrue, reason: m.id);
      }
    });
  });

  test('supervisor review reflects the actual result', () {
    final LabSpec lab = lawResearchLab;
    final LabScenario sc = lab.scenarios.first;
    final Map<String, TaskResult> results = <String, TaskResult>{for (final LabStep s in sc.steps) s.id: gradeModel(s)};
    expect(performanceRating(100, true), 'Exceeds expectations');
    expect(supervisorReview(lab, sc, results, 100, true), contains(workplaceFor(lab).supervisor.name));
    expect(performanceRating(40, false), 'Below expectations');
  });

  testWidgets('Law shift: inbox, research file, document, supervisor review, work log', (WidgetTester t) async {
    final CareerSimStore store = await pumpLab(t, lawResearchLab.id, major: 'introduction_to_law');
    final LabScenario sc = lawResearchLab.scenarios.first;
    await tap(t, k('lab_start'));
    expect(k('shift_card'), findsOneWidget);
    expect(find.textContaining('Ashford & Lane Solicitors'), findsWidgets);
    await tap(t, k('to_briefing'));
    expect(k('inbox_email'), findsOneWidget);
    await tap(t, k('begin_work'));

    final ChoiceQuestion issue = (sc.steps[0] as NumericStep).questions.first as ChoiceQuestion;
    await tap(t, k('q_issue_${issue.correct}'));
    await tap(t, k('numeric_submit'));
    await tap(t, k('step_next'));

    final TriageStep triage = sc.steps[1] as TriageStep;
    for (final TriageItem i in triage.items) {
      await tap(t, k('tri_${i.id}_rel_${i.answers['rel']}'));
    }
    await tap(t, k('triage_submit'));
    expect(store.labRun(lawResearchLab.id)!.results[triage.id]!.score, 100);
    await tap(t, k('step_next'));

    final DocumentStep doc = sc.steps[2] as DocumentStep;
    for (final DocSection sec in doc.sections) {
      await t.enterText(k('doc_${sec.id}'), doc.model[sec.id]!);
      await t.pumpAndSettle();
    }
    expect(store.labRun(lawResearchLab.id)!.drafts['${doc.id}/issue'], isNotEmpty, reason: 'documents are saved as they are typed');
    await tap(t, k('document_submit'));
    expect(store.labRun(lawResearchLab.id)!.results[doc.id]!.passed, isTrue);

    await tap(t, k('to_evaluation'));
    expect(k('supervisor_review'), findsOneWidget);
    expect(find.textContaining('Exceeds expectations'), findsOneWidget);
    await tap(t, k('finish_lab'));
    expect(find.textContaining('Work experience log'), findsOneWidget);
    expect(store.profile.labScenarioPassed(lawResearchLab.id, sc.id), isTrue);
  });
}
