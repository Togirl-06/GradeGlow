import 'dart:async';
import 'dart:convert';

import '../../models/leetcode_problem.dart';
import '../code_judge_service.dart';
import 'lab_runner_io.dart' if (dart.library.js_interop) 'lab_runner_web.dart' as platform;

/// What a program printed.
class ProgramOutput {
  const ProgramOutput({
    required this.ok,
    this.stdout = '',
    this.stderr = '',
    this.ms = 0,
    this.timedOut = false,
    this.unavailable,
  });

  factory ProgramOutput.fromJson(Map<String, dynamic> j) => ProgramOutput(
        ok: j['ok'] == true,
        stdout: '${j['stdout'] ?? ''}',
        stderr: '${j['stderr'] ?? ''}',
        ms: j['ms'] is num ? (j['ms'] as num).toInt() : 0,
      );

  final bool ok;
  final String stdout;
  final String stderr;
  final int ms;
  final bool timedOut;

  /// Set when code could not run at all (no runner on this platform, offline …).
  final String? unavailable;
}

/// A result table from SQLite.
class SqlTable {
  const SqlTable(this.columns, this.rows);

  factory SqlTable.fromJson(Object? raw) {
    if (raw is! Map) return const SqlTable(<String>[], <List<Object?>>[]);
    final List<String> cols = (raw['columns'] as List<dynamic>? ?? <dynamic>[]).map((dynamic c) => '$c').toList();
    final List<List<Object?>> rows = (raw['rows'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic r) => (r as List<dynamic>).map((dynamic v) => v as Object?).toList())
        .toList();
    return SqlTable(cols, rows);
  }

  final List<String> columns;
  final List<List<Object?>> rows;
}

class SqlOutput {
  const SqlOutput({required this.ok, this.error, this.result = const SqlTable(<String>[], <List<Object?>>[]), this.check, this.changes = 0, this.timedOut = false, this.unavailable});

  factory SqlOutput.fromJson(Map<String, dynamic> j) => SqlOutput(
        ok: j['ok'] == true,
        error: j['error'] as String?,
        result: SqlTable.fromJson(j['result']),
        check: j['check'] == null ? null : SqlTable.fromJson(j['check']),
        changes: j['changes'] is num ? (j['changes'] as num).toInt() : 0,
      );

  final bool ok;
  final String? error;
  final SqlTable result;

  /// Result of the lab's own check query, run after the student's statements.
  final SqlTable? check;
  final int changes;
  final bool timedOut;
  final String? unavailable;
}

/// Runs and grades student code. On the web (and phones) the code executes on
/// the student's device — Python in Pyodide, JavaScript in a worker, SQL in
/// SQLite — and is graded by the server judge's own harness
/// (web/code_runner). Elsewhere it falls back to the server judge.
abstract class LabRunner {
  /// Short description shown in the editor ("Runs in your browser" …).
  String get where;

  /// Whether programs and SQL can run here (not only graded submissions).
  bool get canRunPrograms;

  Future<JudgeResult> judge(LeetcodeProblem problem, String languageId, String code, {required bool submit});
  Future<ProgramOutput> runProgram(String languageId, String code, {String stdin = ''});
  Future<SqlOutput> runSql({required String setup, required String statements, String? check});

  /// The runner for this platform. [fallback] grades code where nothing can
  /// run locally (tests, desktop builds).
  static LabRunner create({CodeJudgeService? fallback}) =>
      platform.createPlatformLabRunner(() => fallback ?? CodeJudgeService());
}

/// The problem in the server judge's JSON shape (same as functions/code_judge/problems.json).
Map<String, Object?> judgeProblemJson(LeetcodeProblem p) => <String, Object?>{
      'id': p.id,
      'title': p.title,
      'difficulty': p.difficulty,
      'kind': p.isDebug ? 'debug' : 'implement',
      'functionName': p.functionName,
      'tags': p.tags,
      'description': p.description,
      'examples': <Map<String, String>>[
        for (final LeetcodeExample e in p.examples) <String, String>{'input': e.input, 'output': e.output},
      ],
      'hiddenTests': <Map<String, String>>[
        for (final LeetcodeHiddenTest t in p.hiddenTests) <String, String>{'input': t.input, 'output': t.output},
      ],
    };

/// Grades with the Cloud Function; programs and SQL are not available.
class ServerLabRunner implements LabRunner {
  ServerLabRunner(this._judge);
  final CodeJudgeService _judge;

  @override
  String get where => 'Graded by the GradeGlow server';

  @override
  bool get canRunPrograms => false;

  @override
  Future<JudgeResult> judge(LeetcodeProblem problem, String languageId, String code, {required bool submit}) =>
      _judge.judge(problem: problem, languageId: languageId, code: code, submit: submit);

  @override
  Future<ProgramOutput> runProgram(String languageId, String code, {String stdin = ''}) async =>
      const ProgramOutput(ok: false, unavailable: 'Running programs needs the web app or the phone app.');

  @override
  Future<SqlOutput> runSql({required String setup, required String statements, String? check}) async =>
      const SqlOutput(ok: false, unavailable: 'The SQL lab needs the web app or the phone app.');
}

/// Shared request/response protocol for the worker (web) and WebView (phones).
abstract class MessageLabRunner implements LabRunner {
  MessageLabRunner(CodeJudgeService Function() fallback) : _fallback = fallback;

  final CodeJudgeService Function() _fallback;
  int _next = 1;
  final Map<int, _Pending> _pending = <int, _Pending>{};

  /// Time allowed for loading Python (first use downloads it).
  static const Duration loadLimit = Duration(seconds: 90);

  /// Time allowed for the student's code once it starts — the server's limit.
  static const Duration runLimit = Duration(seconds: 6);

  /// Sends one JSON request to the runner.
  void send(String json);

  /// Kills a stuck runner; the next request starts a fresh one.
  void reset();

  @override
  bool get canRunPrograms => true;

  /// Called with every JSON message from the runner.
  void receive(String json) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } catch (_) {
      return;
    }
    if (decoded is! Map) return;
    final Object? id = decoded['id'];
    if (id is! num) return;
    final _Pending? p = _pending[id.toInt()];
    if (p == null) return;
    if (decoded['phase'] == 'running') {
      p.timer?.cancel();
      p.timer = Timer(runLimit, () => _timeout(id.toInt()));
      return;
    }
    _pending.remove(id.toInt());
    p.timer?.cancel();
    p.completer.complete(Map<String, dynamic>.from(decoded));
  }

  void _timeout(int id) {
    final _Pending? p = _pending.remove(id);
    if (p == null) return;
    p.completer.complete(<String, dynamic>{'timedOut': true});
    // Everything queued behind the stuck run is lost with the runner.
    for (final _Pending other in _pending.values) {
      other.timer?.cancel();
      other.completer.complete(<String, dynamic>{'timedOut': true, 'aborted': true});
    }
    _pending.clear();
    reset();
  }

  void _loadFailed(int id) {
    final _Pending? p = _pending.remove(id);
    p?.completer.complete(<String, dynamic>{'unavailable': true});
  }

  Future<Map<String, dynamic>> request(Map<String, Object?> msg) {
    final int id = _next++;
    final _Pending p = _Pending();
    p.timer = Timer(loadLimit, () => _loadFailed(id));
    _pending[id] = p;
    try {
      send(jsonEncode(<String, Object?>{...msg, 'id': id}));
    } catch (e) {
      _pending.remove(id);
      p.timer?.cancel();
      return Future<Map<String, dynamic>>.value(<String, dynamic>{'unavailable': true, 'error': '$e'});
    }
    return p.completer.future;
  }

  @override
  Future<JudgeResult> judge(LeetcodeProblem problem, String languageId, String code, {required bool submit}) async {
    if (!CodeJudgeService.isGraded(languageId)) {
      return JudgeResult.notGraded('Not Gradable', 'This language is not graded yet. Switch to Python 3 or JavaScript.');
    }
    if (code.trim().isEmpty) return JudgeResult.notGraded('Compile Error', 'Write a solution first.');
    final Map<String, dynamic> r = await request(<String, Object?>{
      'op': 'judge',
      'problem': judgeProblemJson(problem),
      'language': languageId,
      'code': code,
      'includeHidden': submit,
    });
    if (r['timedOut'] == true) {
      return JudgeResult.fromJson(<String, dynamic>{
        'verdict': 'Time Limit Exceeded',
        'message': 'Your program ran longer than ${runLimit.inSeconds} seconds for all test cases together.',
        'passed': 0,
        'total': 0,
        'cases': <Object?>[],
      });
    }
    if (r['ok'] == true && r['result'] is Map) {
      return JudgeResult.fromJson(Map<String, dynamic>.from(r['result'] as Map<dynamic, dynamic>));
    }
    if (r['unavailable'] == true) {
      // Could not load the runner (offline …): try the server judge.
      return _fallback().judge(problem: problem, languageId: languageId, code: code, submit: submit);
    }
    return JudgeResult.notGraded('Runner Unavailable', '${r['error'] ?? 'The code runner failed.'}');
  }

  @override
  Future<ProgramOutput> runProgram(String languageId, String code, {String stdin = ''}) async {
    if (code.trim().isEmpty) return const ProgramOutput(ok: false, stderr: 'Write some code first.');
    final Map<String, dynamic> r =
        await request(<String, Object?>{'op': 'program', 'language': languageId, 'code': code, 'stdin': stdin});
    if (r['timedOut'] == true) {
      return ProgramOutput(ok: false, timedOut: true, stderr: 'Stopped: the program ran longer than ${runLimit.inSeconds} seconds.');
    }
    if (r['ok'] == true && r['result'] is Map) return ProgramOutput.fromJson(Map<String, dynamic>.from(r['result'] as Map<dynamic, dynamic>));
    return ProgramOutput(ok: false, unavailable: '${r['error'] ?? 'The code runner could not start. Check your internet connection.'}');
  }

  @override
  Future<SqlOutput> runSql({required String setup, required String statements, String? check}) async {
    if (statements.trim().isEmpty) return const SqlOutput(ok: false, error: 'Write a SQL statement first.');
    final Map<String, dynamic> r = await request(<String, Object?>{
      'op': 'sql',
      'setup': setup,
      'statements': statements,
      if (check != null) 'check': check,
    });
    if (r['timedOut'] == true) return const SqlOutput(ok: false, timedOut: true, error: 'Stopped: the query ran too long.');
    if (r['ok'] == true && r['result'] is Map) return SqlOutput.fromJson(Map<String, dynamic>.from(r['result'] as Map<dynamic, dynamic>));
    return SqlOutput(ok: false, unavailable: '${r['error'] ?? 'The SQL runner could not start.'}');
  }
}

class _Pending {
  final Completer<Map<String, dynamic>> completer = Completer<Map<String, dynamic>>();
  Timer? timer;
}
