import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/leetcode_problem.dart';

/// One test case as reported by the server judge.
class JudgeCase {
  const JudgeCase({
    required this.index,
    required this.hidden,
    required this.passed,
    required this.ms,
    this.input,
    this.expected,
    this.output,
    this.error,
  });

  factory JudgeCase.fromJson(Map<String, dynamic> j) => JudgeCase(
        index: (j['index'] as num?)?.toInt() ?? 0,
        hidden: j['hidden'] == true,
        passed: j['passed'] == true,
        ms: (j['ms'] as num?)?.toDouble() ?? 0,
        input: j['input'] as String?,
        expected: j['expected'] as String?,
        output: j['output'] as String?,
        error: j['error'] as String?,
      );

  final int index;
  final bool hidden;
  final bool passed;
  final double ms;

  /// Null for hidden cases, except the first failing one.
  final String? input;
  final String? expected;
  final String? output;
  final String? error;
}

/// The server's verdict for a Run or Submit. Only the server decides [accepted].
class JudgeResult {
  const JudgeResult({
    required this.verdict,
    required this.message,
    this.cases = const <JudgeCase>[],
    this.passed = 0,
    this.total = 0,
    this.runtimeMs,
    this.memoryKb,
    this.stderr = '',
  });

  factory JudgeResult.fromJson(Map<String, dynamic> j) => JudgeResult(
        verdict: j['verdict'] as String? ?? 'Runtime Error',
        message: j['message'] as String? ?? '',
        cases: <JudgeCase>[
          for (final dynamic c in (j['cases'] as List<dynamic>? ?? <dynamic>[]))
            JudgeCase.fromJson(Map<String, dynamic>.from(c as Map<dynamic, dynamic>)),
        ],
        passed: (j['passed'] as num?)?.toInt() ?? 0,
        total: (j['total'] as num?)?.toInt() ?? 0,
        runtimeMs: (j['runtimeMs'] as num?)?.toDouble(),
        memoryKb: (j['memoryKb'] as num?)?.toInt(),
        stderr: j['stderr'] as String? ?? '',
      );

  /// A result produced locally when the server could not be asked. Never accepted.
  factory JudgeResult.notGraded(String verdict, String message) =>
      JudgeResult(verdict: verdict, message: message);

  final String verdict;
  final String message;
  final List<JudgeCase> cases;
  final int passed;
  final int total;
  final double? runtimeMs;
  final int? memoryKb;
  final String stderr;

  bool get accepted => verdict == 'Accepted';

  /// True when nothing was graded (runner down, signed out, language unsupported…).
  bool get notGraded => const <String>{
        'Runner Unavailable',
        'Not Gradable',
        'Sign In Required',
        'Network Error',
      }.contains(verdict);
}

/// Sends code to the `codeJudge` Cloud Function, which runs it in an isolated
/// sandbox against the problem's sample (Run) or full hidden (Submit) tests.
class CodeJudgeService {
  CodeJudgeService({
    http.Client? client,
    Future<String?> Function()? idToken,
    Uri? endpoint,
  })  : _client = client ?? http.Client(),
        _idToken = idToken ?? _firebaseIdToken,
        _endpoint = endpoint ?? defaultEndpoint;

  static final Uri defaultEndpoint =
      Uri.parse('https://us-central1-ai-studybuddy-1fad1.cloudfunctions.net/codeJudge');

  /// Languages the server executes. Everything else is shown as "not graded yet".
  static const Set<String> gradedLanguages = <String>{'python3', 'python', 'javascript'};

  static bool isGraded(String languageId) => gradedLanguages.contains(languageId);

  static String problemKey(LeetcodeProblem p) => '${p.isDebug ? 'debug' : 'impl'}:${p.id}';

  final http.Client _client;
  final Future<String?> Function() _idToken;
  final Uri _endpoint;

  static Future<String?> _firebaseIdToken() async {
    try {
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (_) {
      return null;
    }
  }

  Future<JudgeResult> judge({
    required LeetcodeProblem problem,
    required String languageId,
    required String code,
    required bool submit,
  }) async {
    if (!isGraded(languageId)) {
      return JudgeResult.notGraded(
        'Not Gradable',
        'This language is not graded yet. Switch to Python 3 or JavaScript to run tests.',
      );
    }
    if (code.trim().isEmpty) {
      return JudgeResult.notGraded('Compile Error', 'Write a solution first.');
    }
    final String? token = await _idToken();
    if (token == null) {
      return JudgeResult.notGraded('Sign In Required', 'Sign in to run and submit code.');
    }
    try {
      final http.Response res = await _client
          .post(
            _endpoint,
            headers: <String, String>{
              'content-type': 'application/json',
              'authorization': 'Bearer $token',
            },
            body: jsonEncode(<String, Object?>{
              'data': <String, Object?>{
                'problemKey': problemKey(problem),
                'language': languageId,
                'code': code,
                'mode': submit ? 'submit' : 'run',
              },
            }),
          )
          .timeout(const Duration(seconds: 70));
      final Object? body = res.body.isEmpty ? null : jsonDecode(res.body);
      if (body is Map && body['result'] is Map) {
        return JudgeResult.fromJson(Map<String, dynamic>.from(body['result'] as Map<dynamic, dynamic>));
      }
      if (body is Map && body['error'] is Map) {
        final Map<dynamic, dynamic> e = body['error'] as Map<dynamic, dynamic>;
        final String status = '${e['status'] ?? ''}';
        if (status == 'RESOURCE_EXHAUSTED') {
          return JudgeResult.notGraded('Network Error', '${e['message'] ?? 'Too many runs. Wait a minute.'}');
        }
        return JudgeResult.notGraded('Runner Unavailable', '${e['message'] ?? 'The judge returned an error.'}');
      }
      return JudgeResult.notGraded('Runner Unavailable', 'The judge returned an unexpected response (${res.statusCode}).');
    } on TimeoutException {
      return JudgeResult.notGraded('Network Error', 'The judge did not answer in time. Try again.');
    } catch (_) {
      return JudgeResult.notGraded('Network Error', 'Could not reach the judge. Check your connection.');
    }
  }
}
