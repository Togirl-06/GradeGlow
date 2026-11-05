/// Published grading rules for lab-only steps. Every result explains what was
/// right or wrong and why.
library;

import 'dart:math' as math;

import '../../services/lab_runner/lab_runner.dart';
import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import 'lab_models.dart';

class LabGradingException implements Exception {
  LabGradingException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// A graded result for [s] from the fraction of marks earned.
TaskResult gradeResult(LabStep s, double fraction, List<String> feedback, {Map<String, int> breakdown = const <String, int>{}, bool forceFail = false}) =>
    _result(s, fraction, feedback, breakdown: breakdown, forceFail: forceFail);

TaskResult _result(LabStep s, double fraction, List<String> feedback, {Map<String, int> breakdown = const <String, int>{}, bool forceFail = false}) {
  final int score = (fraction * 100).round().clamp(0, 100);
  return TaskResult(taskId: s.id, score: score, passed: !forceFail && score >= s.passMark, feedback: feedback, breakdown: breakdown);
}

abstract final class LabGrader {
  static TaskResult program(ProgramStep s, List<ProgramOutput> outputs) {
    if (outputs.length != s.cases.length) throw LabGradingException('Run every test input first.');
    int ok = 0;
    final List<String> fb = <String>[];
    for (int i = 0; i < s.cases.length; i++) {
      final ProgramOutput o = outputs[i];
      if (o.unavailable != null) throw LabGradingException(o.unavailable!);
      if (o.timedOut) {
        fb.add('Input ${i + 1}: stopped after the time limit (infinite loop?).');
      } else if (!o.ok) {
        final List<String> lines = o.stderr.split('\n').where((String l) => l.trim().isNotEmpty).toList();
        fb.add('Input ${i + 1}: the program crashed — ${lines.isEmpty ? 'error' : lines.last}');
      } else if (ProgramStep.normalize(o.stdout) == ProgramStep.normalize(s.cases[i].expected)) {
        ok++;
      } else {
        fb.add('Input ${i + 1}: output differs from what was expected.');
      }
    }
    if (fb.isEmpty) fb.add('Correct output for every input.');
    return _result(s, ok / s.cases.length, fb, breakdown: <String, int>{'inputsCorrect': ok, 'inputs': s.cases.length});
  }

  static TaskResult sql(SqlStep s, SqlOutput o) {
    if (o.unavailable != null) throw LabGradingException(o.unavailable!);
    if (!o.ok) {
      return _result(s, 0, <String>['The database returned an error: ${o.error}']);
    }
    final List<List<Object?>> rows = s.check == null ? o.result.rows : (o.check?.rows ?? <List<Object?>>[]);
    final bool right = s.matches(rows);
    final List<String> fb = <String>[];
    if (right) {
      fb.add(s.check == null ? 'Your query returns exactly the required rows.' : 'The database is in the required state.');
    } else if (rows.length != s.expected.length) {
      fb.add('Expected ${s.expected.length} row(s); ${s.check == null ? 'your query returned' : 'the check found'} ${rows.length}.');
    } else if (s.ordered && (List<String>.from(SqlStep.rowKeys(rows))..sort()).join() == (List<String>.from(SqlStep.rowKeys(s.expected))..sort()).join()) {
      fb.add('The right rows, but not in the required order — check ORDER BY.');
    } else {
      fb.add('The number of rows is right but some values differ — check your conditions and columns.');
    }
    return _result(s, right ? 1 : 0, fb);
  }

  static TaskResult scheduling(SchedulingStep s, List<String> order, double? average) {
    if (order.length != s.processes.length) throw LabGradingException('Dispatch every process on the Gantt chart.');
    if (average == null) throw LabGradingException('Enter the average waiting time.');
    final List<String> right = s.correctOrder();
    final bool orderOk = order.join(',') == right.join(',');
    final double expected = s.averageWaiting(order);
    final bool avgOk = (average - expected).abs() < 0.01;
    final List<String> fb = <String>[
      if (!orderOk)
        'Dispatch order is not what ${s.algorithm == SchedAlgorithm.fcfs ? 'first-come first-served' : 'shortest job first'} would choose at position ${_firstDiff(order, right) + 1}.',
      if (!avgOk) 'The average waiting time does not match your own Gantt chart. Waiting = start time − arrival time.',
      if (orderOk && avgOk) 'Correct schedule and waiting time.',
    ];
    return _result(s, (orderOk ? 0.6 : 0) + (avgOk ? 0.4 : 0), fb);
  }

  static int _firstDiff(List<String> a, List<String> b) {
    for (int i = 0; i < math.min(a.length, b.length); i++) {
      if (a[i] != b[i]) return i;
    }
    return math.min(a.length, b.length);
  }

  /// [decisions]: per reference, null for "hit", or the page the student evicted
  /// (-1 = fault with a free frame).
  static TaskResult paging(PagingStep s, List<int?> decisions) {
    if (decisions.length != s.references.length) throw LabGradingException('Decide every memory reference.');
    final Map<int, int> loaded = <int, int>{};
    final Map<int, int> used = <int, int>{};
    int right = 0;
    final List<String> fb = <String>[];
    for (int t = 0; t < s.references.length; t++) {
      final int r = s.references[t];
      final int? d = decisions[t];
      final bool hit = loaded.containsKey(r);
      bool ok;
      if (hit) {
        ok = d == null;
        if (!ok) fb.add('Reference ${t + 1} (page $r): page $r was already in memory — a hit.');
        used[r] = t;
      } else {
        final int? expectedVictim = loaded.length < s.frames ? -1 : s.victim(loaded, used);
        ok = d == expectedVictim;
        if (!ok) {
          fb.add(d == null
              ? 'Reference ${t + 1} (page $r): page $r was not in memory — a fault.'
              : 'Reference ${t + 1} (page $r): ${expectedVictim == -1 ? 'a frame was still free' : '${s.algorithm == PagingAlgorithm.fifo ? 'FIFO evicts the page loaded earliest' : 'LRU evicts the page used least recently'}'}.');
        }
        // Apply the student's own choice so later decisions are judged on their memory state.
        if (d != null && d >= 0 && loaded.containsKey(d)) {
          loaded.remove(d);
          used.remove(d);
        } else if (loaded.length >= s.frames) {
          final int v = s.victim(loaded, used);
          loaded.remove(v);
          used.remove(v);
        }
        loaded[r] = t;
        used[r] = t;
      }
      if (ok) right++;
    }
    if (fb.isEmpty) fb.add('Every hit, fault and replacement was correct (${s.correctFaults()} faults).');
    return _result(s, right / s.references.length, fb.take(5).toList());
  }

  /// [mids]: the index the student probed at each iteration.
  static TaskResult searchTrace(SearchTraceStep s, List<int> mids) {
    int lo = 0;
    int hi = s.values.length - 1;
    int right = 0;
    int steps = 0;
    final List<String> fb = <String>[];
    for (final int m in mids) {
      if (lo > hi) break;
      steps++;
      final int expected = (lo + hi) ~/ 2;
      if (m == expected) {
        right++;
      } else {
        fb.add('Iteration $steps: with lo = $lo and hi = $hi, mid = (lo + hi) // 2.');
      }
      final int probe = expected;
      if (s.values[probe] == s.target) break;
      if (s.values[probe] < s.target) {
        lo = probe + 1;
      } else {
        hi = probe - 1;
      }
    }
    if (steps == 0) throw LabGradingException('Make at least one probe.');
    if (fb.isEmpty) fb.add('Every probe was correct.');
    return _result(s, right / steps, fb);
  }

  static TaskResult identity(IdentityCheckStep s, Patient p, Set<String> mismatches, bool proceed) {
    final Set<String> actual = <String>{
      for (final String f in IdentityCheckStep.fields)
        if (s.wristband[f] != IdentityCheckStep.recordValue(p, f) || s.stated[f] != IdentityCheckStep.recordValue(p, f)) f,
    };
    final bool fieldsOk = actual.length == mismatches.length && actual.containsAll(mismatches);
    final bool decisionOk = proceed == actual.isEmpty;
    final List<String> fb = <String>[
      if (!fieldsOk) 'Compare each identifier on the wristband and from the patient with the record — ${actual.isEmpty ? 'all three matched' : 'mismatch in: ${actual.join(', ')}'}.',
      if (!decisionOk && actual.isNotEmpty) 'Unsafe: never continue care when identifiers do not match. Stop and resolve the identity first.',
      if (!decisionOk && actual.isEmpty) 'All identifiers matched; care could proceed.',
      if (fieldsOk && decisionOk) 'Positive identification done correctly.',
    ];
    return _result(s, (fieldsOk ? 0.5 : 0) + (decisionOk ? 0.5 : 0), fb, forceFail: !decisionOk && actual.isNotEmpty);
  }

  static TaskResult history(HistoryStep s, List<int> asked, String note) {
    if (asked.isEmpty) throw LabGradingException('Ask the patient at least one question.');
    if (note.trim().isEmpty) throw LabGradingException('Write your documentation before submitting.');
    final int essential = s.questions.where((HistoryQuestion q) => q.essential).length;
    final List<HistoryQuestion> chosen = asked.map((int i) => s.questions[i]).toList();
    final int gotEssential = chosen.where((HistoryQuestion q) => q.essential).length;
    final int irrelevant = chosen.where((HistoryQuestion q) => !q.relevant).length;
    final double history = (essential == 0 ? 1 : gotEssential / essential) - 0.1 * irrelevant;
    final TextAssessment t = TextRubric.assess(note, s.noteRubric, minWords: 40, maxWords: 350);
    final List<String> fb = <String>[
      for (final HistoryQuestion q in s.questions.where((HistoryQuestion q) => q.essential && !chosen.contains(q))) 'Missed an essential question: "${q.question}"',
      if (irrelevant > 0) '$irrelevant question(s) were not relevant to this presentation.',
      for (final Concept c in t.misses) 'Documentation does not cover: ${c.label}.',
      ...t.notes,
    ];
    if (fb.isEmpty) fb.add('Focused history and complete documentation.');
    final double total = 0.5 * history.clamp(0, 1) + 0.5 * (t.score / 100);
    return _result(s, total, fb, breakdown: <String, int>{'history': (history.clamp(0, 1) * 100).round(), 'documentation': t.score});
  }

  /// [answers]: per observation set, (NEWS2 total entered, response index chosen).
  static TaskResult vitals(VitalsStep s, Patient p, List<(int?, int?)> answers) {
    if (answers.length != p.vitals.length || answers.any(((int?, int?) a) => a.$1 == null || a.$2 == null)) {
      throw LabGradingException('Score and respond to every set of observations.');
    }
    int points = 0;
    bool missedEmergency = false;
    final List<String> fb = <String>[];
    for (int i = 0; i < p.vitals.length; i++) {
      final Vitals v = p.vitals[i];
      final int total = News2.total(v);
      final int resp = News2.response(v);
      if (answers[i].$1 == total) {
        points++;
      } else {
        fb.add('${v.time}: NEWS2 is not ${answers[i].$1} — recheck each parameter against the chart.');
      }
      if (answers[i].$2 == resp) {
        points++;
      } else {
        fb.add('${v.time}: the response does not match the escalation chart for this score.');
        if (resp >= 2 && answers[i].$2! < resp) missedEmergency = true;
      }
    }
    if (missedEmergency) fb.insert(0, 'Under-escalation of a deteriorating patient fails this lab.');
    if (fb.isEmpty) fb.add('Every score and response was correct.');
    return _result(s, points / (2 * p.vitals.length), fb, forceFail: missedEmergency);
  }

  static TaskResult mar(MarStep s, List<MedDecision?> decisions) {
    if (decisions.length != s.correct.length || decisions.contains(null)) throw LabGradingException('Make a decision for every medication.');
    int right = 0;
    bool unsafe = false;
    final List<String> fb = <String>[];
    for (int i = 0; i < s.correct.length; i++) {
      if (decisions[i] == s.correct[i]) {
        right++;
      } else {
        if (decisions[i] == MedDecision.give) unsafe = true;
        fb.add('Medication ${i + 1}: ${s.why[i]}');
      }
    }
    if (unsafe) fb.insert(0, 'A dose was given that should not have been — unsafe medication decisions fail this round.');
    if (fb.isEmpty) fb.add('Every medication handled safely.');
    return _result(s, right / s.correct.length, fb, forceFail: unsafe);
  }

  static String _key(EntryLine l) => '${l.account}|${l.debit}|${l.amount.toStringAsFixed(2)}';

  static TaskResult journal(JournalStep s, List<List<EntryLine>> entries) {
    if (entries.length != s.documents.length) throw LabGradingException('Record an entry for every document.');
    int right = 0;
    final List<String> fb = <String>[];
    for (int i = 0; i < s.documents.length; i++) {
      final List<EntryLine> e = entries[i];
      if (e.isEmpty) throw LabGradingException('Document ${s.documents[i].ref} has no entry.');
      final double dr = e.where((EntryLine l) => l.debit).fold<double>(0, (double a, EntryLine l) => a + l.amount);
      final double cr = e.where((EntryLine l) => !l.debit).fold<double>(0, (double a, EntryLine l) => a + l.amount);
      if ((dr - cr).abs() > 0.004) throw LabGradingException('Entry for ${s.documents[i].ref} does not balance (debits ${dr.toStringAsFixed(2)}, credits ${cr.toStringAsFixed(2)}).');
      final List<String> got = e.map(_key).toList()..sort();
      final List<String> want = s.expected[i].map(_key).toList()..sort();
      if (got.join(';') == want.join(';')) {
        right++;
      } else {
        fb.add('${s.documents[i].ref}: the accounts or amounts are not right. Ask what was received and what was given up.');
      }
    }
    if (fb.isEmpty) fb.add('Every entry is correct; the trial balance agrees.');
    return _result(s, right / s.documents.length, fb);
  }

  static TaskResult reconciliation(ReconciliationStep s, List<ReconItem?> picks, double? adjusted) {
    if (picks.length != s.lines.length || picks.contains(null)) throw LabGradingException('Classify every line.');
    if (adjusted == null) throw LabGradingException('Enter the adjusted cash book balance.');
    int right = 0;
    final List<String> fb = <String>[];
    for (int i = 0; i < s.lines.length; i++) {
      if (picks[i] == s.lines[i].answer) {
        right++;
      } else {
        fb.add('${s.lines[i].source}: "${s.lines[i].description}" is not "${picks[i]!.label}".');
      }
    }
    final bool balOk = (adjusted - s.adjustedCashBook).abs() < 0.005;
    if (!balOk) fb.add('The adjusted cash book balance is wrong: add items that appear only on the bank statement.');
    if (fb.isEmpty) fb.add('Reconciled: the adjusted cash book agrees with the adjusted bank balance.');
    return _result(s, 0.7 * right / s.lines.length + (balOk ? 0.3 : 0), fb);
  }

  static TaskResult statements(StatementsStep s, Map<String, StatementLine?> mapping, double? netIncome, double? totalAssets) {
    if (s.trialBalance.any((TbAccount a) => mapping[a.name] == null)) throw LabGradingException('Place every account in a statement.');
    if (netIncome == null || totalAssets == null) throw LabGradingException('Enter net income and total assets.');
    int right = 0;
    final List<String> fb = <String>[];
    for (final TbAccount a in s.trialBalance) {
      if (mapping[a.name] == a.line) {
        right++;
      } else {
        fb.add('${a.name} belongs in: ${a.line.label}.');
      }
    }
    final Map<String, StatementLine?> correct = <String, StatementLine?>{for (final TbAccount a in s.trialBalance) a.name: a.line};
    final bool niOk = (netIncome - s.netIncome(correct)).abs() < 0.005;
    final bool taOk = (totalAssets - s.sum(StatementLine.asset, correct)).abs() < 0.005;
    if (!niOk) fb.add('Net income is wrong: revenue minus expenses.');
    if (!taOk) fb.add('Total assets are wrong: add every asset balance.');
    if (fb.isEmpty) fb.add('Statements are correct and the balance sheet balances.');
    return _result(s, 0.6 * right / s.trialBalance.length + (niOk ? 0.2 : 0) + (taOk ? 0.2 : 0), fb);
  }

  /// A scenario's score: the average of its steps; passed when every step passed.
  /// Scenarios passed at a level needed to unlock the next level.
  static const int unlockAfter = 2;

  /// Beginner scenarios are always open. Intermediate opens once
  /// [unlockAfter] beginner scenarios are passed (or all of them, if fewer
  /// exist); advanced likewise needs intermediate passes.
  static bool scenarioUnlocked(LabSpec lab, LabScenario sc, bool Function(String scenarioId) passed) {
    if (sc.level == LabDifficulty.foundation) return true;
    final LabDifficulty below = LabDifficulty.values[sc.level.index - 1];
    final List<LabScenario> lower = lab.atLevel(below);
    if (lower.isEmpty) return true;
    final int need = lower.length < unlockAfter ? lower.length : unlockAfter;
    return lower.where((LabScenario s) => passed(s.id)).length >= need;
  }

  /// The scenario to offer next: the first unlocked one not yet passed,
  /// easiest level first; null when every scenario is passed.
  static LabScenario? nextScenario(LabSpec lab, bool Function(String scenarioId) passed) {
    for (final LabDifficulty level in LabDifficulty.values) {
      for (final LabScenario s in lab.atLevel(level)) {
        if (!passed(s.id) && scenarioUnlocked(lab, s, passed)) return s;
      }
    }
    return null;
  }

  static (int, bool) scenario(LabScenario sc, Map<String, TaskResult> results) {
    if (sc.steps.isEmpty) return (0, false);
    int sum = 0;
    bool all = true;
    for (final LabStep st in sc.steps) {
      final TaskResult? r = results[st.id];
      sum += r?.score ?? 0;
      if (r == null || !r.passed) all = false;
    }
    return ((sum / sc.steps.length).round(), all);
  }
}

abstract final class AnatomyGrader {
  /// [names]: the name given for each region id; [correctNames]: the region's real name.
  static TaskResult grade(AnatomyIdStep s, Map<String, String> correctNames, Map<String, String?> names) {
    if (s.regionIds.any((String id) => names[id] == null)) throw LabGradingException('Name every highlighted structure.');
    int right = 0;
    final List<String> fb = <String>[];
    for (final String id in s.regionIds) {
      if (names[id] == correctNames[id]) {
        right++;
      } else {
        fb.add('"${names[id]}" is not the highlighted structure (${correctNames[id]}).');
      }
    }
    if (fb.isEmpty) fb.add('All structures identified.');
    return _result(s, right / s.regionIds.length, fb);
  }
}
