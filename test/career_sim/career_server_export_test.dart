// The career server (functions/career) re-computes screening, interview,
// offer and pay numbers from its own copy of the catalogue. This test:
//  1. regenerates that catalogue from the app's content and fails if the
//     committed functions/career/catalog.json is out of date (copy
//     build/career_catalog.json over it to refresh);
//  2. writes build/career_parity.json: many inputs exactly as the app would
//     send them, with the numbers the app computes. The functions tests in CI
//     replay these through the server and require identical results.
import 'dart:convert';
import 'dart:io';

import 'package:ai_study_buddy/career_sim/content/catalog.dart';
import 'package:ai_study_buddy/career_sim/engine/career_rules.dart';
import 'package:ai_study_buddy/career_sim/engine/interview_engine.dart';
import 'package:ai_study_buddy/career_sim/engine/market_rules.dart';
import 'package:ai_study_buddy/career_sim/engine/pay_rules.dart';
import 'package:ai_study_buddy/career_sim/engine/text_rubric.dart';
import 'package:ai_study_buddy/career_sim/labs/lab_models.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/content_models.dart';
import 'package:ai_study_buddy/career_sim/model/tasks.dart';
import 'package:ai_study_buddy/career_sim/server/career_server.dart';
import 'package:flutter_test/flutter_test.dart';

String sentencesFor(List<Concept> rubric) {
  final List<String> out = <String>[];
  for (final Concept c in rubric) {
    final String term = c.anyOf.first.replaceAll('*', '');
    out.add('In my last placement I made sure that $term was handled carefully and I checked the result with my supervisor.');
  }
  out.add('As a result the work improved and I learned how to plan the next steps with the team.');
  return out.join(' ');
}

const String weakText = 'I am not sure about that one.';

Resume resumeFor(JobPosting job, int variant) {
  final List<String> kw = job.keywords;
  final List<String> skills = switch (variant) {
    0 => <String>[...kw, ...job.preferredKeywords],
    1 => kw.take((kw.length / 2).ceil()).toList(),
    _ => <String>['Teamwork'],
  };
  return Resume(
    fullName: variant == 2 ? '' : 'Sam Taylor',
    email: variant == 2 ? '' : 'sam@example.com',
    phone: variant == 0 ? '555 0100' : '',
    headline: 'Graduate',
    summary: variant == 0 ? 'Motivated graduate with practical project experience, strong communication and a record of delivering accurate work on time.' : '',
    education: variant == 2
        ? const <ResumeEntry>[]
        : <ResumeEntry>[ResumeEntry(heading: 'BSc ${job.educationFields.isEmpty ? 'Studies' : job.educationFields.first}, State University', detail: '2019 – 2023')],
    experience: switch (variant) {
      0 => <ResumeEntry>[
          const ResumeEntry(heading: 'Assistant, Northside Clinic 2018 – present', detail: 'Built a tracker used by 40 staff; Reduced errors by 20%'),
          const ResumeEntry(heading: 'Volunteer, Food Bank 2016 – 2017', detail: 'Led a team of 6 volunteers'),
        ],
      1 => <ResumeEntry>[const ResumeEntry(heading: 'Intern, City Office 2022', detail: 'Assisted with reports')],
      _ => const <ResumeEntry>[],
    },
    skills: skills,
    projects: variant == 1 ? <ResumeEntry>[const ResumeEntry(heading: 'Capstone project', detail: 'Designed a small app')] : const <ResumeEntry>[],
  );
}

Map<String, dynamic> interviewResult(InterviewRecord r) => <String, dynamic>{
      'communication': r.communication,
      'technical': r.technical,
      'problemSolving': r.problemSolving,
      'readiness': r.readiness,
      'overall': r.overall,
      'lowest': r.lowest,
      'practicalPassed': r.practicalPassed,
    };

void main() {
  test('server catalogue is up to date', () {
    final String generated = const JsonEncoder.withIndent('  ').convert(CareerServerCatalog.export());
    Directory('build').createSync(recursive: true);
    File('build/career_catalog.json').writeAsStringSync('$generated\n');
    final File committed = File('functions/career/catalog.json');
    expect(committed.existsSync(), isTrue, reason: 'copy build/career_catalog.json to functions/career/catalog.json');
    expect(committed.readAsStringSync().trim(), generated.trim(),
        reason: 'functions/career/catalog.json is out of date: copy build/career_catalog.json over it');
  });

  test('parity cases for the server rules', () {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final List<Map<String, dynamic>> screening = <Map<String, dynamic>>[];
    final List<Map<String, dynamic>> interviews = <Map<String, dynamic>>[];
    final List<Map<String, dynamic>> decisions = <Map<String, dynamic>>[];
    final List<Map<String, dynamic>> negotiations = <Map<String, dynamic>>[];
    final List<Map<String, dynamic>> pay = <Map<String, dynamic>>[];
    int n = 0;
    for (final JobPosting job in CareerCatalog.postings) {
      final InterviewPlan? base = CareerCatalog.interviewPlan(job.interviewPlanId);
      for (int v = 0; v < 3; v++) {
        n++;
        final CareerProfile p = CareerProfile(stage: CareerStage.values[(v * 2 + n) % CareerStage.values.length], resume: resumeFor(job, v));
        p.completedModules.addAll(<String>[if (v == 0) ...CareerCatalog.department(job.deptId)?.modules.take(2).map((TrainingModule m) => m.id) ?? <String>[]]);
        final JobApplication a = JobApplication(
          id: 'app_$n',
          postingId: job.id,
          status: ApplicationStatus.submitted,
          createdDay: 1,
          submittedDay: v == 2 ? job.deadlineDay + 5 : job.openDay + 1,
          coverLetter: v == 0 ? 'Dear ${job.company.name}, I am applying for the ${job.title} role. ${sentencesFor(CareerRules.coverLetterRubric(job))} Thank you, I look forward to discussing the opportunity.' : (v == 1 ? 'I want the ${job.title} job at ${job.company.name} because it is interesting to me and I would like to learn.' : ''),
          answers: <String, String>{for (final ApplicationQuestion q in job.questions) q.id: v == 0 ? sentencesFor(q.rubric) : weakText},
        );
        if (job.keywords.isNotEmpty) {
          final ScreeningReport r = MarketRules.screen(p, job, a, a.submittedDay!);
          screening.add(<String, dynamic>{
            'postingId': job.id,
            'input': CareerServerPayloads.screen(p, job, a, r, a.submittedDay!),
            'expect': <String, dynamic>{'score': r.score, 'eligible': r.eligible, 'shortlisted': r.shortlisted},
          });
        }
        if (base == null) continue;
        final InterviewPlan plan = job.keywords.isEmpty ? base : MarketRules.interviewPlan(p, a, job, base);
        final InterviewSession iv = InterviewSession(plan: plan, company: job.company, applicationId: a.id, day: 5);
        int turn = 0;
        while (!iv.questionsDone && turn < 60) {
          final InterviewQuestion q = iv.current!;
          final bool good = v == 0 || (v == 1 && turn.isEven);
          turn++;
          if (q.practical != null) {
            iv.answerPractical(TaskResult(taskId: q.practical!.id, score: good ? 92 : 41, passed: good), 'Done.');
          } else if (q.isChoice) {
            iv.answerChoice(good ? q.correctOption : (q.correctOption + 1) % q.options.length);
          } else {
            iv.answerOpen(good ? sentencesFor(<Concept>[...q.rubric, if (q.behavioural) ...InterviewSession.starRubric]) : weakText);
          }
        }
        for (final String cq in <String>[
          if (v != 2) 'Who would I work with on the team?',
          if (v == 0) 'What training do new starters get?',
          if (v == 0) 'How is success measured in the first 90 days?',
          if (v == 1) 'What is the salary?',
        ]) {
          iv.ask(cq);
        }
        final InterviewRecord rec = iv.finish();
        interviews.add(<String, dynamic>{
          'postingId': job.id,
          'applicationId': a.id,
          'input': CareerServerPayloads.interview(a, rec, plan),
          'expect': interviewResult(rec),
        });
        // Decision and offer from these numbers.
        final int screenScore = <int>[82, 64, 40][v];
        final TaskResult? asmt = v == 1 ? TaskResult(taskId: 'x', score: 77, passed: true) : null;
        final JobApplication d = JobApplication(id: a.id, postingId: job.id, status: ApplicationStatus.interviewCompleted, createdDay: 1)
          ..screening = ScreeningReport(score: screenScore, eligible: true, shortlisted: true, strengths: const <String>[], gaps: const <String>[], breakdown: const <String, int>{})
          ..interview = rec
          ..assessment = asmt;
        final HiringDecision h = CareerRules.decide(job, d);
        decisions.add(<String, dynamic>{
          'postingId': job.id,
          'screening': screenScore,
          'interview': interviewResult(rec),
          if (asmt != null) 'assessment': <String, dynamic>{'score': asmt.score, 'passed': asmt.passed},
          'expect': <String, dynamic>{'outcome': h.outcome.name, 'overall': h.overall, 'offerSalary': CareerRules.offerSalary(job, h.overall)},
        });
      }
      // Negotiation at three interview levels.
      for (final int overall in <int>[60, 80, 95]) {
        final int salary = CareerRules.offerSalary(job, overall);
        final String message = overall == 60
            ? 'Can I have more money please, I would like more.'
            : 'Thank you for the offer, I am excited to join. Based on my project experience and skills, and market research on similar roles and the average range, '
                'would you consider a salary of a little more per year? I would be delighted to accept and I look forward to starting.';
        final JobApplication a = JobApplication(id: 'neg', postingId: job.id, status: ApplicationStatus.offerReceived, createdDay: 1)
          ..offer = MarketRules.offer(job, job.title, salary, 3)
          ..interview = InterviewRecord(applicationId: 'neg', day: 2, turns: const <InterviewTurn>[], communication: overall, technical: overall, problemSolving: overall, readiness: overall, candidateQuestions: const <String>[], practicalPassed: true, feedback: const <String>[]);
        final (OfferNegotiation neg, int newSalary) = MarketRules.negotiate(job, a, message, 3);
        negotiations.add(<String, dynamic>{
          'postingId': job.id,
          'salary': salary,
          'interviewOverall': a.interview!.overall,
          'message': message,
          'expect': <String, dynamic>{'score': neg.score, 'accepted': neg.accepted, 'salary': newSalary},
        });
        final Employment e = Employment(
          id: 'e_${job.id}_$overall',
          postingId: job.id,
          deptId: job.deptId,
          workplaceId: job.workplaceId,
          employer: job.company.name,
          title: job.title,
          stage: job.stageOnHire,
          salary: newSalary,
          salaryPeriod: job.salaryPeriod,
          startDay: 1,
          payFrequency: job.payFrequency,
          hoursPerWeek: job.hoursPerWeek,
        );
        final Paycheck c = PayRules.paycheck(e, 2, 9);
        pay.add(<String, dynamic>{
          'employment': <String, dynamic>{'id': e.id, 'salary': e.salary, 'salaryPeriod': e.salaryPeriod, 'payFrequency': e.payFrequency, 'hoursPerWeek': e.hoursPerWeek},
          'period': 2,
          'expect': <String, dynamic>{'id': c.id, 'grossCents': c.grossCents, 'deductionCents': c.deductionCents, 'netCents': c.netCents},
          'raised': <String, int>{
            for (final double f in <double>[1.02, 1.05, 1.12]) '$f': PayRules.raised(e.salary, e.salaryPeriod, f),
          },
        });
      }
    }
    final Map<String, dynamic> out = <String, dynamic>{
      'nowMs': nowMs,
      'thisYear': DateTime.now().year,
      'screening': screening,
      'interviews': interviews,
      'decisions': decisions,
      'negotiations': negotiations,
      'pay': pay,
      'stipends': <Map<String, dynamic>>[
        for (final LabDifficulty l in LabDifficulty.values)
          for (final int s in <int>[0, 55, 70, 99, 100]) <String, dynamic>{'level': l.name, 'score': s, 'expect': PayRules.stipend(l, s)},
      ],
    };
    expect(screening.length, greaterThan(100));
    expect(interviews.length, greaterThan(100));
    // The cases must exercise both sides of every decision.
    expect(screening.where((Map<String, dynamic> m) => (m['expect'] as Map<String, dynamic>)['shortlisted'] == true), isNotEmpty);
    expect(screening.where((Map<String, dynamic> m) => (m['expect'] as Map<String, dynamic>)['shortlisted'] == false), isNotEmpty);
    expect(decisions.map((Map<String, dynamic> m) => (m['expect'] as Map<String, dynamic>)['outcome']).toSet(), containsAll(<String>['offer', 'reject']));
    expect(negotiations.where((Map<String, dynamic> m) => (m['expect'] as Map<String, dynamic>)['accepted'] == true), isNotEmpty);
    Directory('build').createSync(recursive: true);
    File('build/career_parity.json').writeAsStringSync(jsonEncode(out));
  });
}
