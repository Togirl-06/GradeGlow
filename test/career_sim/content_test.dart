import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/career_sim/model/tasks.dart';
import 'package:ai_study_buddy/career_sim/ui/diagrams.dart';
import 'package:ai_study_buddy/models/leetcode_problem.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every task in a department, with where it is used.
Map<String, TaskSpec> _tasksOf(Department d) => <String, TaskSpec>{
      for (final TrainingModule m in d.modules)
        for (final TaskSpec t in m.practice) '${m.id}/${t.id}': t,
      for (final ProjectSpec p in d.projects) ...<String, TaskSpec>{
        for (final TaskSpec t in p.deliverables) 'project:${p.id}/${t.id}': t,
        'project:${p.id}/${p.writeUp.id}': p.writeUp,
      },
    };

void main() {
  test('the guide\'s schools all have a department', () {
    final Set<String> ids = CareerCatalog.departments.map((Department d) => d.id).toSet();
    expect(ids, containsAll(<String>['cs', 'medicine', 'nursing', 'law', 'engineering', 'business', 'mathematics', 'communication', 'sciences']));
    final Department eng = CareerCatalog.department('engineering')!;
    expect(eng.units.length, 6);
    final Department biz = CareerCatalog.department('business')!;
    expect(biz.units.length, 8);
  });

  test('departments are distinct, not reskins: no task is shared between departments', () {
    final Map<String, String> owner = <String, String>{};
    for (final Department d in CareerCatalog.departments) {
      for (final TaskSpec t in _tasksOf(d).values) {
        final String sig = '${t.runtimeType}:${t.title}';
        expect(owner[sig] == null || owner[sig] == d.id, isTrue, reason: '$sig appears in ${owner[sig]} and ${d.id}');
        owner[sig] = d.id;
      }
    }
  });

  test('every department has training, a project, a certification, postings, an interview and a workplace', () {
    for (final Department d in CareerCatalog.departments) {
      expect(d.modules, isNotEmpty, reason: d.id);
      expect(d.projects, isNotEmpty, reason: d.id);
      expect(d.certifications, isNotEmpty, reason: d.id);
      final List<JobPosting> jobs = CareerCatalog.postingsFor(d.id);
      expect(jobs.any((JobPosting j) => j.type == JobType.internship), isTrue, reason: d.id);
      expect(jobs.any((JobPosting j) => j.stageOnHire == CareerStage.entryLevel), isTrue, reason: d.id);
      for (final JobPosting j in jobs) {
        expect(CareerCatalog.interviewPlan(j.interviewPlanId), isNotNull, reason: j.id);
        expect(CareerCatalog.workplace(j.workplaceId), isNotNull, reason: j.id);
      }
    }
  });

  test('postings reference real modules, skills and certifications', () {
    for (final JobPosting j in CareerCatalog.postings) {
      final Department d = CareerCatalog.department(j.deptId)!;
      for (final String m in j.requirements.modules) {
        expect(d.modules.any((TrainingModule x) => x.id == m), isTrue, reason: '${j.id} → $m');
      }
      for (final String s in j.requirements.skills.keys) {
        expect(d.skills.any((SkillDef x) => x.id == s), isTrue, reason: '${j.id} → $s');
      }
      for (final String c in j.requirements.certifications) {
        expect(d.certifications.any((Certification x) => x.id == c), isTrue, reason: '${j.id} → $c');
      }
      expect(j.company.name, isNotEmpty);
      expect(j.responsibilities, isNotEmpty);
      expect(j.qualifications, isNotEmpty);
      expect(j.salaryMax, greaterThanOrEqualTo(j.salaryMin));
      expect(j.deadlineDay, greaterThan(j.openDay));
    }
  });

  test('every task\'s skills belong to its department', () {
    for (final Department d in CareerCatalog.departments) {
      final Set<String> skills = d.skills.map((SkillDef s) => s.id).toSet();
      for (final MapEntry<String, TaskSpec> e in _tasksOf(d).entries) {
        for (final String s in e.value.skills) {
          expect(skills.contains(s), isTrue, reason: '${d.id} ${e.key} → $s');
        }
      }
      for (final TrainingModule m in d.modules) {
        for (final String s in m.skills) {
          expect(skills.contains(s), isTrue, reason: '${m.id} → $s');
        }
      }
    }
  });

  test('every code task is gradable by the server judge', () {
    final List<CodeTaskSpec> code = CareerCatalog.allCodeTasks();
    expect(code, isNotEmpty);
    for (final CodeTaskSpec t in code) {
      final LeetcodeProblem? p = CareerCatalog.problem(t.problemKey);
      expect(p, isNotNull, reason: t.problemKey);
      expect(p!.hasRealTests, isTrue, reason: t.problemKey);
      expect(p.starterCode['python3'], isNotNull, reason: t.problemKey);
    }
  });

  test('task content is well formed', () {
    for (final Department d in CareerCatalog.departments) {
      for (final TaskSpec t in _tasksOf(d).values) {
        if (t is DecisionTaskSpec) {
          for (final DecisionStep s in t.steps) {
            expect(s.options.any((DecisionOption o) => o.points == 2), isTrue, reason: '${t.id}: ${s.prompt}');
          }
        } else if (t is ClassifyTaskSpec) {
          for (final ClassifyItem i in t.items) {
            expect(t.categories, contains(i.category), reason: '${t.id}: ${i.text}');
          }
        } else if (t is LedgerTaskSpec) {
          for (final LedgerTransaction x in t.transactions) {
            expect(t.accounts, containsAll(<String>[x.debit, x.credit]), reason: t.id);
          }
        } else if (t is LabelTaskSpec) {
          expect(TechDiagram.known, contains(t.diagram), reason: t.id);
          expect(t.labelBank.toSet().length, t.labelBank.length, reason: '${t.id}: duplicate labels');
        } else if (t is CourtroomTaskSpec) {
          for (final TranscriptLine l in t.transcript) {
            if (l.objection != null) expect(t.grounds, contains(l.objection), reason: t.id);
          }
        } else if (t is WorkupTaskSpec) {
          expect(t.correctDiagnosis, lessThan(t.diagnoses.length));
          expect(t.investigations.where((Investigation i) => i.relevant).length, lessThanOrEqualTo(t.maxInvestigations));
        }
      }
    }
  });

  test('interview plans are consistent', () {
    for (final InterviewPlan p in CareerCatalog.interviewPlans) {
      for (final String id in p.main) {
        expect(p.question(id), isNotNull, reason: '${p.id} → $id');
      }
      for (final InterviewQuestion q in p.bank) {
        if (q.probeId != null) expect(p.question(q.probeId!), isNotNull, reason: '${q.id} probe');
        if (q.stretchId != null) expect(p.question(q.stretchId!), isNotNull, reason: '${q.id} stretch');
        if (q.isChoice) expect(q.correctOption, inInclusiveRange(0, q.options.length - 1), reason: q.id);
        if (!q.isChoice && q.practical == null) expect(q.rubric, isNotEmpty, reason: q.id);
      }
      expect(p.bank.any((InterviewQuestion q) => q.practical != null), isTrue, reason: '${p.id} needs a practical');
    }
  });

  test('workplaces have assignments, a leadership assignment and titles', () {
    for (final WorkplaceDef w in CareerCatalog.workplaces) {
      expect(w.assignments.where((AssignmentSpec a) => !a.leadership).length, greaterThanOrEqualTo(w.internshipLength), reason: w.id);
      expect(w.assignments.any((AssignmentSpec a) => a.leadership && a.id.contains('lead')), isTrue, reason: w.id);
      expect(w.assignments.map((AssignmentSpec a) => a.id).toSet().length, w.assignments.length, reason: w.id);
      if (w.returnOfferPostingId != null) expect(CareerCatalog.posting(w.returnOfferPostingId!), isNotNull, reason: w.id);
    }
  });

  test('every school major maps to a department', () {
    for (final String major in <String>['computer_science', 'nursing', 'medicine', 'introduction_to_law', 'civil_engineering', 'accounting', 'mathematics', 'english', 'biology', 'chemistry', 'physics']) {
      expect(CareerCatalog.forMajor(major), isNotNull, reason: major);
    }
  });
}
