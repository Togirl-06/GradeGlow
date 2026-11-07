import 'package:ai_study_buddy/career_sim/content/job_market.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_catalog.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/career_sim/model/tasks.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every scenario of a job\'s labs becomes workplace work', () {
    for (final RoleFamily f in roleFamilies) {
      final WorkplaceDef w = marketWorkplaces.firstWhere((WorkplaceDef x) => x.id == 'mk_${f.id}');
      final Set<String> given = <String>{
        for (final AssignmentSpec a in w.assignments)
          if (a.task case final LabTaskSpec t) '${t.labId}/${t.scenarioId}',
      };
      for (final String id in f.labs) {
        final LabSpec? l = LabCatalog.lab(id);
        if (l == null) continue;
        for (final LabScenario s in l.scenarios) {
          expect(given, contains('${l.id}/${s.id}'), reason: '${w.id} is missing ${l.id}/${s.id}');
        }
      }
      expect(w.assignments.map((AssignmentSpec a) => a.id).toSet().length, w.assignments.length, reason: w.id);
    }
  });

  test('work starts with easier tasks and harder ones come later', () {
    for (final WorkplaceDef w in marketWorkplaces) {
      final List<LabTaskSpec> lab = <LabTaskSpec>[for (final AssignmentSpec a in w.assignments) if (a.task case final LabTaskSpec t) t];
      if (lab.isEmpty) continue;
      final LabSpec l = LabCatalog.lab(lab.first.labId)!;
      final LabScenario first = l.scenarios.firstWhere((LabScenario s) => s.id == lab.first.scenarioId);
      final int easiest = l.scenarios.map((LabScenario s) => s.level.index).reduce((int a, int b) => a < b ? a : b);
      expect(first.level.index, easiest, reason: w.id);
    }
  });

  test('an employee gets every task once before any task repeats', () {
    for (final WorkplaceDef w in marketWorkplaces) {
      final List<AssignmentSpec> pool = w.assignments.where((AssignmentSpec s) => !s.leadership).toList();
      final List<AssignmentRecord> done = <AssignmentRecord>[];
      for (int i = 0; i < pool.length * 2; i++) {
        final AssignmentSpec s = CareerSimStore.nextAssignment(pool, done);
        if (i < pool.length) {
          expect(done.any((AssignmentRecord r) => r.assignmentId == s.id), isFalse, reason: '${w.id}: repeated ${s.id} at $i');
        } else {
          // The repeat cycle starts with the task done longest ago.
          expect(s.id, pool[i - pool.length].id, reason: '${w.id} at $i');
        }
        done.add(AssignmentRecord(assignmentId: s.id, issuedDay: i, dueDay: i + 2));
      }
    }
  });

  test('a task that is no longer offered never blocks new work', () {
    final WorkplaceDef w = marketWorkplaces.first;
    final List<AssignmentSpec> pool = w.assignments.where((AssignmentSpec s) => !s.leadership).toList();
    final List<AssignmentRecord> done = <AssignmentRecord>[
      AssignmentRecord(assignmentId: 'retired_task', issuedDay: 1, dueDay: 2),
      AssignmentRecord(assignmentId: pool.first.id, issuedDay: 2, dueDay: 3),
    ];
    expect(CareerSimStore.nextAssignment(pool, done).id, pool[1].id);
  });
}
