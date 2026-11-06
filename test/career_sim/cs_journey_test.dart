import 'dart:convert';

import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:ai_study_buddy/career_sim/ui/career_dashboard.dart';
import 'package:ai_study_buddy/services/code_judge_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

/// The 20-step Computer Science journey, driven through the real screens.
/// Code is "executed" by a fake judge that answers like the server; every
/// other score comes from the simulator's own rules.

const String strongAnswer =
    'When I worked on a booking service project last year, the problem was that users needed overlapping bookings merged. '
    'I built and implemented the algorithm in Python using a hash map and sorting, and my part was the core function. '
    'I decided to reproduce each failing test locally and rerun it, then I checked what changed in the recent commits with git log and a diff. '
    'I used logging and a debugger to isolate the smallest failing case, then added a regression test so the fix would pass and stay verified. '
    'As a result the CI pipeline with automated tests and branch protection on review blocked bad merges, and we added monitoring and alerts. '
    'When a teammate disagreed, I listened to their point, measured both options with a benchmark and data, and we agreed on a decision. '
    'I thank reviewers, address each comment one by one, and ask questions to clarify anything unclear because that is the most likely way to learn. '
    'I learned to do this earlier next time, and I would have written tests differently.';

const String writeUp =
    'The problem was that the facilities team needed overlapping room bookings merged and cancelled slots moved to the back. '
    'My approach was to sort the bookings by start time and then make one pass, merging each booking into the previous one when they overlap. '
    'For the queue I used two pointers to move zeros in place while keeping the order of the other values. '
    'The time complexity is O(n log n) for sorting and O(n) for the pointer pass, with constant extra space for the in place step. '
    'I tested it with edge cases such as touching intervals, a single booking and an empty queue, and the judge ran the hidden tests. '
    'One trade-off is that sorting a copy uses more memory instead of sorting in place, which I accepted for clarity.';

const String coverLetter =
    'Dear hiring manager, I am applying for the Software Engineering Intern role at Northwind Pay because I am excited by your '
    'mission to make payments simple for small businesses. During my Computer Science training I completed modules on hash maps, '
    'stacks and debugging, and I built a booking service project for my portfolio that merges overlapping bookings and passed every '
    'hidden test in the judge. I developed skills in Python, data structures and code review, and I am able to write clear pull '
    'request descriptions and regression tests. I am interested in working on the Payments Platform squad because reliable software '
    'matters to the businesses that depend on it. Thank you for considering my application, and I look forward to the opportunity '
    'to discuss how I can contribute to your team.';

CodeJudgeService acceptingJudge(List<String> calls) => CodeJudgeService(
      idToken: () async => 'token',
      client: MockClient((http.Request r) async {
        final Map<String, dynamic> body = jsonDecode(r.body) as Map<String, dynamic>;
        calls.add('${body['problemKey'] ?? body['key'] ?? ''}');
        return http.Response(
          jsonEncode(<String, Object?>{
            'result': <String, Object?>{
              'verdict': 'Accepted',
              'message': 'All test cases passed.',
              'passed': 5,
              'total': 5,
              'runtimeMs': 2.0,
              'memoryKb': 9000,
              'cases': <Object?>[],
            },
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }),
    );

Finder k(String key) => find.byKey(ValueKey<String>(key));

Future<void> tapKey(WidgetTester t, String key) async {
  final Finder f = k(key);
  expect(f, findsWidgets, reason: 'missing $key');
  await t.ensureVisible(f.first);
  await t.tap(f.first);
  await t.pumpAndSettle();
}

Future<void> back(WidgetTester t) async {
  await t.pageBack();
  await t.pumpAndSettle();
}

const String someCode = 'class Solution:\n    def solve(self, *args):\n        return my_answer(*args)\n';

Future<void> writeCode(WidgetTester t) async {
  await t.enterText(k('code_editor'), someCode);
  await t.pumpAndSettle();
}

Future<void> submitCode(WidgetTester t) async {
  await writeCode(t);
  await tapKey(t, 'code_run');
  await tapKey(t, 'code_submit');
  expect(find.textContaining('Accepted'), findsWidgets);
}

void main() {
  testWidgets('CS journey: learn → practise → project → apply → interview → hired → work → evaluated, then restored',
      (WidgetTester t) async {
    t.view.physicalSize = const Size(1400, 16000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);

    final MemoryCareerRepository repo = MemoryCareerRepository();
    final List<String> judged = <String>[];
    final CareerSimStore store = CareerSimStore(repository: repo, judge: acceptingJudge(judged));
    await store.ensureLoaded(userId: 'student-1', majorId: 'computer_science', displayName: 'Ada Student');

    await t.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(
      value: store,
      child: const MaterialApp(home: Scaffold(body: CareerSimDashboard(studentName: 'Ada Student', majorLabel: 'Computer Science'))),
    ));
    await t.pumpAndSettle();
    expect(find.text('Career Simulator'), findsOneWidget);

    // 1. Enter the department.
    await tapKey(t, 'dash_department');
    expect(find.textContaining('Software Foundations Studio'), findsOneWidget);

    // 2. Learn a concept.
    await tapKey(t, 'module_cs_m1');
    await tapKey(t, 'mark_studied');
    expect(store.profile.studiedLessons, contains('cs_m1'));

    // 3–4. Coding exercise: write, run and submit code to the judge.
    await tapKey(t, 'practice_pair_sum');
    await t.enterText(k('code_editor'), 'class Solution:\n    def pairSum(self, nums, target):\n        seen = {}\n        return []\n');
    await submitCode(t);
    await back(t);
    await tapKey(t, 'practice_complexity');
    for (final List<int> pick in <List<int>>[<int>[0, 0], <int>[1, 2], <int>[2, 4], <int>[3, 1], <int>[4, 3], <int>[5, 2]]) {
      await tapKey(t, 'cls_${pick[0]}_${pick[1]}');
    }
    await tapKey(t, 'task_submit');
    expect(find.text('Passed'), findsOneWidget);
    await back(t);
    await back(t);
    expect(store.profile.completedModules, contains('cs_m1'));

    await tapKey(t, 'module_cs_m2');
    await tapKey(t, 'mark_studied');
    await tapKey(t, 'practice_brackets');
    await submitCode(t);
    await back(t);
    await tapKey(t, 'practice_brackets_debug');
    await submitCode(t);
    await back(t);
    await back(t);
    expect(store.profile.completedModules, containsAll(<String>['cs_m1', 'cs_m2']));

    // 5–6. Practical project → portfolio.
    await tapKey(t, 'project_cs_p1');
    await tapKey(t, 'deliverable_merge');
    await submitCode(t);
    await back(t);
    await tapKey(t, 'deliverable_zeros');
    await submitCode(t);
    await back(t);
    await tapKey(t, 'deliverable_writeup');
    await t.enterText(k('written_answer'), writeUp);
    await tapKey(t, 'task_submit');
    expect(find.text('Passed'), findsOneWidget);
    await back(t);
    await tapKey(t, 'publish_project');
    expect(store.profile.portfolio.single.id, 'cs_p1');
    await back(t);
    await back(t);

    // 7. Career Centre: resume and trainee status.
    await tapKey(t, 'nav_career');
    await tapKey(t, 'open_resume');
    await t.enterText(k('cv_email'), 'ada@example.com');
    await t.enterText(k('cv_headline'), 'Computer Science student — backend and algorithms');
    await t.enterText(k('cv_summary'),
        'I am a computer science student who builds reliable backend code for real users. I shipped a booking service project whose hidden tests all pass, and I enjoy debugging and careful code review.');
    await t.enterText(k('cv_edu_title'), 'BSc Computer Science');
    await t.enterText(k('cv_edu_detail'), 'GradeGlow University, 2024–2028');
    await tapKey(t, 'cv_add_edu');
    for (final String s in <String>['Python', 'Hash maps', 'Debugging']) {
      await t.enterText(k('cv_skill'), s);
      await tapKey(t, 'cv_add_skill');
    }
    await tapKey(t, 'cv_project_cs_p1');
    await tapKey(t, 'cv_save');
    expect(store.profile.resume.email, 'ada@example.com');
    await back(t);
    await tapKey(t, 'request_trainee');
    expect(store.profile.stage, CareerStage.trainee);

    // 8–9. Find an internship and apply.
    await tapKey(t, 'open_jobs');
    await tapKey(t, 'posting_cs_intern_northwind');
    expect(find.text('Responsibilities'), findsOneWidget);
    await tapKey(t, 'start_application');
    await t.enterText(k('cover_letter_field'), coverLetter);
    await tapKey(t, 'submit_application');
    final JobApplication app = store.profile.applications.single;
    expect(app.status, ApplicationStatus.submitted);

    // 10–11. Employer review → interview invitation.
    await tapKey(t, 'next_day');
    expect(store.profile.application(app.id)!.status, ApplicationStatus.underReview);
    await tapKey(t, 'next_day');
    expect(store.profile.application(app.id)!.status, ApplicationStatus.shortlisted, reason: '${store.profile.application(app.id)!.screening?.gaps}');
    final int slot = store.profile.application(app.id)!.interviewSlots.first;
    await tapKey(t, 'slot_$slot');
    await tapKey(t, 'next_day');
    expect(store.interviewAvailable(store.profile.application(app.id)!), isTrue);

    // 12. Interactive technical interview (adaptive questions, live coding, candidate questions).
    await tapKey(t, 'start_interview');
    for (int i = 0; i < 20 && k('iv_ask').evaluate().isEmpty; i++) {
      if (k('iv_send').evaluate().isNotEmpty) {
        await t.enterText(k('iv_answer'), strongAnswer);
        await tapKey(t, 'iv_send');
      } else if (k('code_submit').evaluate().isNotEmpty) {
        await writeCode(t);
        await tapKey(t, 'code_submit');
      } else if (find.widgetWithText(OutlinedButton, 'O(n²)').evaluate().isNotEmpty) {
        await t.tap(find.widgetWithText(OutlinedButton, 'O(n)'));
        await t.pumpAndSettle();
      } else if (find.widgetWithText(OutlinedButton, 'O(n log n)').evaluate().isNotEmpty) {
        await t.tap(find.widgetWithText(OutlinedButton, 'O(1)'));
        await t.pumpAndSettle();
      } else if (find.widgetWithText(OutlinedButton, 'if a[mid] < t: lo = mid').evaluate().isNotEmpty) {
        await t.tap(find.widgetWithText(OutlinedButton, 'if a[mid] < t: lo = mid'));
        await t.pumpAndSettle();
      } else {
        fail('Unexpected interview state');
      }
    }
    await tapKey(t, 'iv_suggest_0');
    await tapKey(t, 'iv_suggest_1');
    await tapKey(t, 'iv_suggest_2');
    await tapKey(t, 'iv_finish');
    final InterviewRecord rec = store.profile.application(app.id)!.interview!;
    expect(rec.practicalPassed, isTrue, reason: rec.turns.map((InterviewTurn x) => '${x.questionId}:${x.score}').join(' '));
    expect(rec.turns.any((InterviewTurn x) => x.isFollowUp), isTrue, reason: 'the interviewer should adapt');
    expect(rec.overall, greaterThanOrEqualTo(80));
    await tapKey(t, 'interview_done');

    // 13–14. Hiring decision by defined criteria → offer.
    await tapKey(t, 'next_day');
    final JobApplication decided = store.profile.application(app.id)!;
    expect(decided.decision!.outcome, HiringOutcome.offer, reason: '${decided.decision!.reasons}');
    expect(decided.status, ApplicationStatus.offerReceived);
    expect(find.textContaining('Offer: Software Engineering Intern'), findsOneWidget);

    // 15–16. Accept → sign the contract → onboarding → workplace.
    await tapKey(t, 'accept_offer');
    expect(find.text('Simulated employment contract'), findsOneWidget);
    await tapKey(t, 'contract_agree');
    await t.enterText(k('contract_signature'), store.profile.resume.fullName);
    await t.pump();
    await tapKey(t, 'sign_contract');
    expect(store.profile.stage, CareerStage.intern);
    expect(store.profile.currentJob!.contract!.signedName, store.profile.resume.fullName);
    expect(find.textContaining('Payments Platform squad'), findsWidgets);
    for (final String id in <String>['handbook', 'policy', 'tools', 'manager', 'goals']) {
      await tapKey(t, 'onb_$id');
      await tapKey(t, 'onb_done_$id');
    }
    expect(store.onboardingLeft(store.profile.currentJob!), isEmpty);

    // 17–19. Assignment → submit → supervisor evaluation.
    await tapKey(t, 'request_assignment');
    await tapKey(t, 'open_assignment');
    await writeCode(t);
    await tapKey(t, 'code_submit');
    await t.enterText(k('handoff_note'),
        'I implemented the duplicate check with a set and verified it with tests on large batches. Next, QA should monitor the settlement run and follow up on any remaining edge cases.');
    await tapKey(t, 'submit_assignment');
    expect(k('evaluation_card'), findsOneWidget);
    final SupervisorEvaluation ev = store.profile.currentJob!.evaluated.single.evaluation!;
    expect(ev.rating, 'Exceeds expectations');
    await tapKey(t, 'back_to_work');

    // 20. Feedback and progress update.
    expect(store.profile.currentJob!.performance, ev.overall);
    expect(store.profile.skillPoints['cs_ds'], greaterThan(0));
    expect(judged, isNotEmpty);

    // Save and restore: a fresh session loads the same record.
    final CareerSimStore restored = CareerSimStore(repository: repo);
    await restored.ensureLoaded(userId: 'student-1');
    expect(restored.profile.toJson(), store.profile.toJson());
    expect(restored.profile.currentJob!.employer, 'Northwind Pay');
  });
}
