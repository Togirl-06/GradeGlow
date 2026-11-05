import 'dart:convert';

import 'package:ai_study_buddy/data/leetcode_problem_bank.dart';
import 'package:ai_study_buddy/models/leetcode_problem.dart';
import 'package:ai_study_buddy/services/code_judge_service.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:ai_study_buddy/career_sim/model/tasks.dart';
import 'package:ai_study_buddy/career_sim/store/career_repository.dart';
import 'package:ai_study_buddy/career_sim/store/career_sim_store.dart';
import 'package:ai_study_buddy/career_sim/ui/task_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

Map<String, Object?> _verdict(String v, {int passed = 0, int total = 3}) => <String, Object?>{
      'result': <String, Object?>{
        'verdict': v,
        'message': '$passed of $total test cases passed.',
        'passed': passed,
        'total': total,
        'runtimeMs': 1.5,
        'memoryKb': 9000,
        'cases': <Map<String, Object?>>[
          <String, Object?>{'index': 1, 'hidden': false, 'passed': v == 'Accepted', 'ms': 0.5, 'input': 'nums = [1]', 'expected': '1', 'output': v == 'Accepted' ? '1' : '0'},
        ],
      },
    };

CodeJudgeService _service(Map<String, Object?> reply, {List<Map<String, dynamic>>? sent, String? token = 'tok'}) {
  return CodeJudgeService(
    idToken: () async => token,
    client: MockClient((http.Request r) async {
      sent?.add(<String, dynamic>{'auth': r.headers['authorization'], 'body': jsonDecode(r.body)});
      return http.Response(jsonEncode(reply), 200, headers: <String, String>{'content-type': 'application/json'});
    }),
  );
}

void main() {
  final LeetcodeProblem problem = LeetcodeProblemBank.allCuratedProblems.first;

  test('sends problem key, language, code and mode with the ID token', () async {
    final List<Map<String, dynamic>> sent = <Map<String, dynamic>>[];
    final JudgeResult r = await _service(_verdict('Accepted', passed: 3), sent: sent)
        .judge(problem: problem, languageId: 'python3', code: 'x = 1', submit: true);
    expect(r.accepted, isTrue);
    expect(r.passed, 3);
    expect(sent.single['auth'], 'Bearer tok');
    final Map<String, dynamic> data = sent.single['body']['data'] as Map<String, dynamic>;
    expect(data['problemKey'], CodeJudgeService.problemKey(problem));
    expect(data['language'], 'python3');
    expect(data['mode'], 'submit');
  });

  test('never accepts locally: unsupported language, signed out, network failure', () async {
    JudgeResult r = await _service(_verdict('Accepted')).judge(problem: problem, languageId: 'java', code: 'class S {}', submit: true);
    expect(r.accepted, isFalse);
    expect(r.verdict, 'Not Gradable');
    r = await _service(_verdict('Accepted'), token: null).judge(problem: problem, languageId: 'python3', code: 'x', submit: true);
    expect(r.verdict, 'Sign In Required');
    final CodeJudgeService broken = CodeJudgeService(
      idToken: () async => 'tok',
      client: MockClient((http.Request r) async => throw Exception('offline')),
    );
    r = await broken.judge(problem: problem, languageId: 'python3', code: 'x', submit: true);
    expect(r.verdict, 'Network Error');
    expect(r.accepted, isFalse);
  });

  test('server errors are surfaced, not turned into results', () async {
    final JudgeResult r = await _service(<String, Object?>{
      'error': <String, Object?>{'status': 'RESOURCE_EXHAUSTED', 'message': 'Too many runs.'},
    }).judge(problem: problem, languageId: 'javascript', code: 'x', submit: false);
    expect(r.accepted, isFalse);
    expect(r.message, 'Too many runs.');
  });

  const CodeTaskSpec spec = CodeTaskSpec(
    id: 'pair',
    title: 'Twin Sum Lookup',
    brief: 'Implement it.',
    problemKey: 'impl:GGO-001',
  );

  Future<List<TaskResult>> pumpTask(WidgetTester tester, CodeJudgeService judge) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final List<TaskResult> graded = <TaskResult>[];
    final CareerSimStore store = CareerSimStore(repository: MemoryCareerRepository(), judge: judge);
    await tester.pumpWidget(ChangeNotifierProvider<CareerSimStore>.value(
      value: store,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TaskView(spec: spec, onGraded: (TaskResult r) async => graded.add(r)),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return graded;
  }

  testWidgets('Submit shows the server verdict (Wrong Answer is not Accepted)', (WidgetTester tester) async {
    final List<TaskResult> graded = await pumpTask(tester, _service(_verdict('Wrong Answer', passed: 1)));
    await tester.tap(find.byKey(const ValueKey<String>('code_submit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Wrong Answer'), findsWidgets);
    expect(graded.single.passed, isFalse);
    expect(graded.single.verdict, 'Wrong Answer');
  });

  testWidgets('Submit passes only when the server says Accepted', (WidgetTester tester) async {
    final List<TaskResult> graded = await pumpTask(tester, _service(_verdict('Accepted', passed: 3)));
    await tester.tap(find.byKey(const ValueKey<String>('code_submit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Accepted'), findsWidgets);
    expect(graded.single.passed, isTrue);
    expect(graded.single.score, 100);
  });

  testWidgets('Run never records a grade; a missing runner records nothing', (WidgetTester tester) async {
    final List<TaskResult> graded = await pumpTask(tester, _service(_verdict('Accepted', passed: 3)));
    await tester.tap(find.byKey(const ValueKey<String>('code_run')));
    await tester.pumpAndSettle();
    expect(graded, isEmpty);
  });
}
