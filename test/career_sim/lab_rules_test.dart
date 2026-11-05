import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/content/accounting_labs.dart';
import 'package:ai_study_buddy/career_sim/labs/content/cs_labs.dart';
import 'package:ai_study_buddy/career_sim/labs/content/health_labs.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_grading.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/data/science_diagram_catalog.dart';
import 'package:ai_study_buddy/models/science_diagram.dart';
import 'package:ai_study_buddy/services/lab_runner/lab_runner.dart';
import 'package:flutter_test/flutter_test.dart';

T step<T extends LabStep>(LabSpec lab, String id) =>
    lab.scenarios.expand((LabScenario s) => s.steps).firstWhere((LabStep s) => s.id == id) as T;

void main() {
  group('content', () {
    test('every lab is complete and consistent', () {
      expect(LabCatalog.all.length, greaterThanOrEqualTo(17));
      final Set<String> ids = <String>{};
      for (final LabSpec l in LabCatalog.all) {
        expect(ids.add(l.id), isTrue, reason: 'duplicate ${l.id}');
        final Department d = CareerCatalog.department(l.deptId)!;
        final Set<String> skills = d.skills.map((SkillDef s) => s.id).toSet();
        expect(skills.containsAll(l.skills), isTrue, reason: l.id);
        expect(l.objectives, isNotEmpty);
        for (final String pre in l.prerequisites) {
          expect(LabCatalog.lab(pre), isNotNull, reason: '${l.id} prerequisite $pre');
        }
        for (final LabScenario sc in l.scenarios) {
          expect(sc.steps, isNotEmpty, reason: l.id);
          expect(sc.briefing.tools, isNotEmpty);
          for (final LabStep s in sc.steps) {
            expect(skills.containsAll(s.skills), isTrue, reason: '${l.id}/${s.id}');
            if (s is IdentityCheckStep) expect(l.patient(s.patientId), isNotNull);
            if (s is HistoryStep) expect(l.patient(s.patientId), isNotNull);
            if (s is VitalsStep) expect(l.patient(s.patientId)!.vitals, isNotEmpty);
            if (s is MarStep) {
              expect(l.patient(s.patientId)!.medications.length, s.correct.length, reason: s.id);
              expect(s.why.length, s.correct.length);
            }
            if (s is SqlStep) expect(l.database, isNotEmpty);
            if (s is AnatomyIdStep) {
              final ScienceDiagram dg = ScienceDiagramCatalog.diagramById(s.diagramId)!;
              for (final String r in s.regionIds) {
                expect(dg.regions.any((ScienceDiagramRegion x) => x.id == r), isTrue, reason: '${s.diagramId}/$r');
              }
            }
            if (s is JournalStep) {
              for (final List<EntryLine> e in s.expected) {
                final double dr = e.where((EntryLine x) => x.debit).fold<double>(0, (double a, EntryLine x) => a + x.amount);
                final double cr = e.where((EntryLine x) => !x.debit).fold<double>(0, (double a, EntryLine x) => a + x.amount);
                expect(dr, closeTo(cr, 0.001));
                expect(s.accounts, containsAll(e.map((EntryLine x) => x.account)));
              }
            }
          }
        }
      }
    });

    test('the bank reconciliation agrees on both sides', () {
      final ReconciliationStep r = step<ReconciliationStep>(accountingReconciliationLab, 'recon');
      final double bankAdjusted = r.bankBalance +
          r.lines
              .where((ReconLine l) => l.answer == ReconItem.unpresentedCheque || l.answer == ReconItem.outstandingDeposit)
              .fold<double>(0, (double a, ReconLine l) => a + l.amount);
      expect(r.adjustedCashBook, closeTo(bankAdjusted, 0.001));
    });

    test('the trial balance balances and so does the balance sheet', () {
      final StatementsStep s = step<StatementsStep>(accountingStatementsLab, 'statements');
      final double dr = s.trialBalance.where((TbAccount a) => a.debit).fold<double>(0, (double t, TbAccount a) => t + a.balance);
      final double cr = s.trialBalance.where((TbAccount a) => !a.debit).fold<double>(0, (double t, TbAccount a) => t + a.balance);
      expect(dr, cr);
      final Map<String, StatementLine?> m = <String, StatementLine?>{for (final TbAccount a in s.trialBalance) a.name: a.line};
      expect(s.sum(StatementLine.asset, m), s.sum(StatementLine.liability, m) + s.sum(StatementLine.equity, m) + s.netIncome(m));
    });
  });

  group('NEWS2', () {
    test('Mr Carter deteriorates from 0 to 9', () {
      expect(james.vitals.map(News2.total).toList(), <int>[0, 1, 5, 9]);
      expect(james.vitals.map(News2.response).toList(), <int>[0, 1, 2, 3]);
    });

    test('a single red parameter needs an urgent review', () {
      const Vitals v = Vitals(time: 't', rr: 18, spo2: 97, sbp: 120, dbp: 80, hr: 80, temp: 37, alert: false);
      expect(News2.total(v), 3);
      expect(News2.response(v), 2);
    });

    test('under-escalation fails the round', () {
      final VitalsStep s = step<VitalsStep>(nursingVitalsLab, 'news_rounds');
      final TaskResult ok = LabGrader.vitals(s, james, <(int?, int?)>[(0, 0), (1, 1), (5, 2), (9, 3)]);
      expect(ok.score, 100);
      final TaskResult under = LabGrader.vitals(s, james, <(int?, int?)>[(0, 0), (1, 1), (5, 2), (9, 1)]);
      expect(under.passed, isFalse);
    });
  });

  group('computing', () {
    test('FCFS and SJF', () {
      final SchedulingStep f = step<SchedulingStep>(csSystemsLab, 'fcfs');
      expect(f.correctOrder(), <String>['P1', 'P2', 'P3', 'P4']);
      expect(f.averageWaiting(f.correctOrder()), 5.75);
      final SchedulingStep s = step<SchedulingStep>(csSystemsLab, 'sjf');
      expect(s.correctOrder(), <String>['P1', 'P2', 'P4', 'P3']);
      expect(s.averageWaiting(s.correctOrder()), 5.25);
      expect(LabGrader.scheduling(s, <String>['P1', 'P2', 'P4', 'P3'], 5.25).score, 100);
      final TaskResult wrong = LabGrader.scheduling(s, <String>['P1', 'P2', 'P3', 'P4'], 5.75);
      expect(wrong.score, 40, reason: 'the average is right for the wrong order');
    });

    test('FIFO and LRU faults', () {
      expect(step<PagingStep>(csSystemsLab, 'fifo').correctFaults(), 9);
      expect(step<PagingStep>(csSystemsLab, 'lru').correctFaults(), 8);
    });

    test('paging is judged on the student\'s own memory state', () {
      final PagingStep s = step<PagingStep>(csSystemsLab, 'fifo');
      // 7,0,1 → free frames; 2 evicts 7; 0 hit; 3 evicts 0; 0 evicts 1; 4 evicts 2; 2 evicts 3; 3 evicts 0.
      final List<int?> right = <int?>[-1, -1, -1, 7, null, 0, 1, 2, 3, 0];
      expect(LabGrader.paging(s, right).score, 100);
      final List<int?> oneWrong = List<int?>.from(right)..[4] = 7;
      expect(LabGrader.paging(s, oneWrong).score, lessThan(100));
    });

    test('binary search trace', () {
      final SearchTraceStep s = step<SearchTraceStep>(csAlgorithmsLab, 'trace');
      expect(LabGrader.searchTrace(s, <int>[7, 11, 13]).score, 100);
      expect(LabGrader.searchTrace(s, <int>[6, 11, 13]).score, 67);
    });

    test('SQL rows compare by value, with order only when required', () {
      final SqlStep counts = step<SqlStep>(csDatabaseLab, 'course_counts');
      final List<List<Object?>> shuffled = List<List<Object?>>.from(counts.expected.reversed);
      expect(LabGrader.sql(counts, SqlOutput(ok: true, result: SqlTable(const <String>['c', 'n'], shuffled))).passed, isTrue);
      final SqlStep ordered = step<SqlStep>(csDatabaseLab, 'cs_students');
      final TaskResult r = LabGrader.sql(ordered, SqlOutput(ok: true, result: SqlTable(const <String>['name'], ordered.expected.reversed.toList())));
      expect(r.passed, isFalse);
      expect(r.feedback.single, contains('ORDER BY'));
      final SqlStep avg = step<SqlStep>(csDatabaseLab, 'averages');
      expect(avg.matches(<List<Object?>>[<Object?>['Ada Okafor', 81.5], <Object?>['Chen Wei', 83.66666666666667], <Object?>['Eli Novak', 55.0]]), isTrue);
      expect(LabGrader.sql(avg, const SqlOutput(ok: false, error: 'no such column: nme')).feedback.single, contains('no such column'));
    });

    test('program output is compared line by line, ignoring trailing spaces', () {
      final ProgramStep s = step<ProgramStep>(csFundamentalsLab, 'average');
      final List<ProgramOutput> outs = s.cases.map((ProgramCase c) => ProgramOutput(ok: true, stdout: '${c.expected}  \n')).toList();
      expect(LabGrader.program(s, outs).passed, isTrue);
      outs[1] = const ProgramOutput(ok: false, stderr: 'Traceback\nValueError: bad');
      final TaskResult r = LabGrader.program(s, outs);
      expect(r.passed, isFalse);
      expect(r.feedback.single, contains('ValueError'));
      expect(() => LabGrader.program(s, <ProgramOutput>[const ProgramOutput(ok: false, unavailable: 'offline')]), throwsA(isA<LabGradingException>()));
    });
  });

  group('clinical and accounting', () {
    test('continuing care after an identity mismatch fails', () {
      final IdentityCheckStep s = step<IdentityCheckStep>(nursingAdmissionLab, 'identity');
      expect(LabGrader.identity(s, amira, <String>{'MRN'}, false).score, 100);
      final TaskResult unsafe = LabGrader.identity(s, amira, <String>{'MRN'}, true);
      expect(unsafe.passed, isFalse);
    });

    test('giving a dose that must be held fails the medication round', () {
      final MarStep s = step<MarStep>(nursingMedsLab, 'mar_round');
      expect(LabGrader.mar(s, List<MedDecision?>.from(s.correct)).score, 100);
      final List<MedDecision?> unsafe = List<MedDecision?>.from(s.correct)..[3] = MedDecision.give;
      final TaskResult r = LabGrader.mar(s, unsafe);
      expect(r.passed, isFalse);
      expect(r.feedback.join(), contains('penicillin'));
    });

    test('history taking rewards essential questions and penalises irrelevant ones', () {
      final HistoryStep s = step<HistoryStep>(nursingAdmissionLab, 'admission_history');
      const String note = 'Admitted with right-sided abdominal pain and vomiting for two days, pain score 6/10. Allergy: codeine causes vomiting. '
          'Medicines: salbutamol inhaler as needed. Last period three weeks ago; pregnancy test offered. Plan: inform the doctor for review and monitor observations.';
      final TaskResult good = LabGrader.history(s, <int>[0, 1, 2, 3, 4], note);
      expect(good.passed, isTrue, reason: good.feedback.join(' | '));
      final TaskResult poor = LabGrader.history(s, <int>[8, 9, 0], note);
      expect(poor.score, lessThan(good.score));
      expect(poor.feedback.first, contains('Missed an essential question'));
    });

    test('journal entries must balance and match the documents', () {
      final JournalStep s = step<JournalStep>(accountingBookkeepingLab, 'journal');
      expect(LabGrader.journal(s, s.expected).score, 100);
      final List<List<EntryLine>> unbalanced = s.expected.map((List<EntryLine> e) => List<EntryLine>.from(e)).toList()
        ..[0] = <EntryLine>[const EntryLine('Cash', true, 15000), const EntryLine('Owner\'s capital', false, 14000)];
      expect(() => LabGrader.journal(s, unbalanced), throwsA(isA<LabGradingException>()));
      final List<List<EntryLine>> swapped = s.expected.map((List<EntryLine> e) => List<EntryLine>.from(e)).toList()
        ..[2] = <EntryLine>[const EntryLine('Cash', true, 620), const EntryLine('Purchases', false, 620)];
      expect(LabGrader.journal(s, swapped).score, 89);
      expect(bakeryAccounts, containsAll(bakeryNormalDebit.keys));
    });

    test('statements: classification, net income and total assets', () {
      final StatementsStep s = step<StatementsStep>(accountingStatementsLab, 'statements');
      final Map<String, StatementLine?> m = <String, StatementLine?>{for (final TbAccount a in s.trialBalance) a.name: a.line};
      expect(LabGrader.statements(s, m, 7200, 26200).score, 100);
      expect(LabGrader.statements(s, m, 48000, 26200).passed, isTrue, reason: '80 is still a pass');
      expect(LabGrader.statements(s, m, 48000, 0).passed, isFalse);
    });
  });
}
