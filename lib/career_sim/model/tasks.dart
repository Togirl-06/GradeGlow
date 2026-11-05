/// Task types used by every department, and the deterministic rule that grades
/// each one. Departments differ in the tasks they define, the professional
/// setting and the screen that presents them; the grading rules are shared.
library;

import '../../services/code_judge_service.dart';
import '../engine/text_rubric.dart';
import 'career_models.dart';

class Fact {
  const Fact(this.label, this.value);
  final String label;
  final String value;
}

abstract class TaskSpec {
  const TaskSpec({
    required this.id,
    required this.title,
    required this.brief,
    this.skills = const <String>[],
    this.passMark = 70,
  });

  final String id;
  final String title;

  /// What the student is asked to do, in the voice of the lecturer/employer.
  final String brief;
  final List<String> skills;
  final int passMark;

  String get kindLabel;
}

// ---------------------------------------------------------------------------
// Code (graded only by the server code judge)

class CodeTaskSpec extends TaskSpec {
  const CodeTaskSpec({
    required super.id,
    required super.title,
    required super.brief,
    required this.problemKey,
    super.skills,
    this.context = const <String>[],
    this.buggyStarter = const <String, String>{},
  }) : super(passMark: 100);

  /// `impl:<id>` or `debug:<id>` — the judge's key.
  final String problemKey;

  /// Workplace context lines (ticket, acceptance criteria).
  final List<String> context;

  /// Broken code the student must fix, by language (python3, javascript).
  /// The judge grades the result against the problem's hidden tests.
  final Map<String, String> buggyStarter;

  bool get isBugFix => buggyStarter.isNotEmpty || problemKey.startsWith('debug:');

  @override
  String get kindLabel => isBugFix ? 'Bug fix' : 'Coding';
}

// ---------------------------------------------------------------------------
// Decision scenario (clinical, HR, management, legal strategy …)

class DecisionOption {
  const DecisionOption(this.text, this.points, this.feedback, {this.critical = false});

  final String text;

  /// 2 = best practice, 1 = acceptable, 0 = wrong.
  final int points;
  final String feedback;

  /// An unsafe or unlawful action. Choosing it fails the task outright.
  final bool critical;
}

class DecisionStep {
  const DecisionStep(this.prompt, this.options, {this.update = ''});

  final String prompt;
  final List<DecisionOption> options;

  /// New information revealed when this step is reached (e.g. new vitals).
  final String update;
}

class DecisionTaskSpec extends TaskSpec {
  const DecisionTaskSpec({
    required super.id,
    required super.title,
    required super.brief,
    required this.setting,
    required this.facts,
    required this.steps,
    super.skills,
    super.passMark,
  });

  final String setting;
  final List<Fact> facts;
  final List<DecisionStep> steps;

  @override
  String get kindLabel => 'Scenario';
}

class DecisionAnswer {
  const DecisionAnswer(this.choices);
  final List<int> choices;
}

// ---------------------------------------------------------------------------
// Diagnostic work-up (medicine): order investigations, diagnose, manage.

class Investigation {
  const Investigation(this.name, this.result, {required this.relevant});
  final String name;
  final String result;
  final bool relevant;
}

class WorkupTaskSpec extends TaskSpec {
  const WorkupTaskSpec({
    required super.id,
    required super.title,
    required super.brief,
    required this.presentation,
    required this.facts,
    required this.investigations,
    required this.maxInvestigations,
    required this.diagnoses,
    required this.correctDiagnosis,
    required this.management,
    super.skills,
    super.passMark,
  });

  final String presentation;
  final List<Fact> facts;
  final List<Investigation> investigations;
  final int maxInvestigations;
  final List<String> diagnoses;
  final int correctDiagnosis;
  final List<DecisionStep> management;

  @override
  String get kindLabel => 'Patient case';
}

class WorkupAnswer {
  const WorkupAnswer({
    required this.ordered,
    required this.diagnosis,
    required this.management,
  });
  final Set<int> ordered;
  final int diagnosis;
  final List<int> management;
}

// ---------------------------------------------------------------------------
// Numeric calculation (engineering, finance, dosage, physics …)

class NumericPart {
  const NumericPart(this.prompt, this.answer, {this.unit = '', this.relTol = 0.01, this.method = ''});

  final String prompt;
  final double answer;
  final String unit;

  /// Relative tolerance (1% default). Exact zero answers use 1e-6 absolute.
  final double relTol;

  /// The method, shown when the part is wrong. Never the number.
  final String method;

  bool accepts(double? v) {
    if (v == null || v.isNaN) return false;
    if (answer == 0) return v.abs() < 1e-6;
    return ((v - answer).abs() / answer.abs()) <= relTol;
  }
}

class NumericTaskSpec extends TaskSpec {
  const NumericTaskSpec({
    required super.id,
    required super.title,
    required super.brief,
    required this.givens,
    required this.parts,
    this.diagram = '',
    super.skills,
    super.passMark,
  });

  final List<Fact> givens;
  final List<NumericPart> parts;

  /// Optional diagram id drawn by the department screen.
  final String diagram;

  @override
  String get kindLabel => 'Calculation';
}

class NumericAnswer {
  const NumericAnswer(this.values);
  final List<double?> values;
}

// ---------------------------------------------------------------------------
// Journal entries (accounting)

class LedgerTransaction {
  const LedgerTransaction(this.description, this.debit, this.credit, this.amount);
  final String description;
  final String debit;
  final String credit;
  final double amount;
}

class LedgerTaskSpec extends TaskSpec {
  const LedgerTaskSpec({
    required super.id,
    required super.title,
    required super.brief,
    required this.accounts,
    required this.transactions,
    super.skills,
    super.passMark,
  });

  final List<String> accounts;
  final List<LedgerTransaction> transactions;

  @override
  String get kindLabel => 'Journal entries';
}

class LedgerLineInput {
  const LedgerLineInput({this.debit, this.credit, this.amount});
  final String? debit;
  final String? credit;
  final double? amount;
}

class LedgerAnswer {
  const LedgerAnswer(this.lines);
  final List<LedgerLineInput> lines;
}

// ---------------------------------------------------------------------------
// Classification (code review findings, evidence, segments, edits …)

class ClassifyItem {
  const ClassifyItem(this.text, this.category, this.why);
  final String text;
  final String category;
  final String why;
}

enum ClassifyStyle { plain, codeReview, document }

class ClassifyTaskSpec extends TaskSpec {
  const ClassifyTaskSpec({
    required super.id,
    required super.title,
    required super.brief,
    required this.categories,
    required this.items,
    this.style = ClassifyStyle.plain,
    this.exhibit = '',
    super.skills,
    super.passMark,
  });

  final List<String> categories;
  final List<ClassifyItem> items;
  final ClassifyStyle style;

  /// Material shown above the items (a diff, a contract clause, a memo …).
  final String exhibit;

  @override
  String get kindLabel => style == ClassifyStyle.codeReview ? 'Code review' : 'Analysis';
}

class ClassifyAnswer {
  const ClassifyAnswer(this.picks);
  final List<String?> picks;
}

// ---------------------------------------------------------------------------
// Ordering (procedures, proofs, process steps)

class OrderTaskSpec extends TaskSpec {
  const OrderTaskSpec({
    required super.id,
    required super.title,
    required super.brief,
    required this.steps,
    this.why = '',
    super.skills,
    super.passMark = 80,
  });

  /// In the correct order. The screen shuffles them deterministically.
  final List<String> steps;
  final String why;

  @override
  String get kindLabel => 'Procedure';
}

class OrderAnswer {
  const OrderAnswer(this.order);

  /// Indices into [OrderTaskSpec.steps] in the order the student placed them.
  final List<int> order;
}

// ---------------------------------------------------------------------------
// Written work (memos, briefs, write-ups, care plans)

class WrittenTaskSpec extends TaskSpec {
  const WrittenTaskSpec({
    required super.id,
    required super.title,
    required super.brief,
    required this.rubric,
    this.minWords = 60,
    this.maxWords = 400,
    this.exhibit = '',
    super.skills,
    super.passMark = 65,
  });

  final List<Concept> rubric;
  final int minWords;
  final int maxWords;
  final String exhibit;

  @override
  String get kindLabel => 'Written work';
}

class WrittenAnswer {
  const WrittenAnswer(this.text);
  final String text;
}

// ---------------------------------------------------------------------------
// Labelling a diagram (anatomy, circuits, cells)

class Hotspot {
  const Hotspot(this.x, this.y, this.answer);

  /// 0–1 position on the diagram.
  final double x;
  final double y;
  final String answer;
}

class LabelTaskSpec extends TaskSpec {
  const LabelTaskSpec({
    required super.id,
    required super.title,
    required super.brief,
    required this.diagram,
    required this.hotspots,
    this.distractors = const <String>[],
    super.skills,
    super.passMark = 75,
  });

  final String diagram;
  final List<Hotspot> hotspots;
  final List<String> distractors;

  List<String> get labelBank {
    final List<String> all = <String>[
      ...hotspots.map((Hotspot h) => h.answer),
      ...distractors,
    ]..sort();
    return all;
  }

  @override
  String get kindLabel => 'Labelling';
}

class LabelAnswer {
  const LabelAnswer(this.labels);
  final List<String?> labels;
}

// ---------------------------------------------------------------------------
// Courtroom (objections during testimony)

class TranscriptLine {
  const TranscriptLine(this.speaker, this.text, this.objection, this.why);
  final String speaker;
  final String text;

  /// Correct ground, or null when the question/answer is proper.
  final String? objection;
  final String why;
}

class CourtroomTaskSpec extends TaskSpec {
  const CourtroomTaskSpec({
    required super.id,
    required super.title,
    required super.brief,
    required this.caseName,
    required this.role,
    required this.grounds,
    required this.transcript,
    super.skills,
    super.passMark,
  });

  final String caseName;
  final String role;
  final List<String> grounds;
  final List<TranscriptLine> transcript;

  @override
  String get kindLabel => 'Courtroom';
}

class CourtroomAnswer {
  const CourtroomAnswer(this.rulings);

  /// Ground chosen per line, or null for "no objection".
  final List<String?> rulings;
}

// ---------------------------------------------------------------------------
// Grading

class TaskGradingException implements Exception {
  TaskGradingException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract final class TaskGrader {
  static TaskResult _result(TaskSpec spec, double fraction, List<String> feedback,
      {Map<String, int> breakdown = const <String, int>{}, bool forceFail = false, int day = 0}) {
    final int score = (fraction * 100).round().clamp(0, 100);
    return TaskResult(
      taskId: spec.id,
      score: score,
      passed: !forceFail && score >= spec.passMark,
      feedback: feedback,
      breakdown: breakdown,
      day: day,
    );
  }

  static void _expectLength(int got, int want, String what) {
    if (got != want) {
      throw TaskGradingException('Answer every $what before submitting ($got of $want).');
    }
  }

  /// Grades a non-code task. Throws [TaskGradingException] for incomplete answers.
  static TaskResult grade(TaskSpec spec, Object answer, {int day = 0}) {
    if (spec is DecisionTaskSpec && answer is DecisionAnswer) {
      return _decision(spec, spec.steps, answer.choices, day);
    }
    if (spec is WorkupTaskSpec && answer is WorkupAnswer) return _workup(spec, answer, day);
    if (spec is NumericTaskSpec && answer is NumericAnswer) return _numeric(spec, answer, day);
    if (spec is LedgerTaskSpec && answer is LedgerAnswer) return _ledger(spec, answer, day);
    if (spec is ClassifyTaskSpec && answer is ClassifyAnswer) return _classify(spec, answer, day);
    if (spec is OrderTaskSpec && answer is OrderAnswer) return _order(spec, answer, day);
    if (spec is WrittenTaskSpec && answer is WrittenAnswer) return _written(spec, answer, day);
    if (spec is LabelTaskSpec && answer is LabelAnswer) return _label(spec, answer, day);
    if (spec is CourtroomTaskSpec && answer is CourtroomAnswer) return _court(spec, answer, day);
    throw TaskGradingException('This answer does not match the task type.');
  }

  /// Code is only graded by the server. Accepted is the only passing verdict.
  static TaskResult? fromJudge(CodeTaskSpec spec, JudgeResult r, {int day = 0}) {
    if (r.notGraded) return null;
    final int score = r.accepted
        ? 100
        : (r.total == 0 ? 0 : ((r.passed / r.total) * 60).round());
    return TaskResult(
      taskId: spec.id,
      score: score,
      passed: r.accepted,
      verdict: r.verdict,
      feedback: <String>[
        'Judge verdict: ${r.verdict} (${r.passed}/${r.total} tests).',
        if (!r.accepted && r.message.isNotEmpty) r.message,
      ],
      breakdown: <String, int>{'testsPassed': r.passed, 'testsTotal': r.total},
      day: day,
    );
  }

  static TaskResult _decision(TaskSpec spec, List<DecisionStep> steps, List<int> choices, int day) {
    _expectLength(choices.length, steps.length, 'decision');
    int got = 0;
    int max = 0;
    bool critical = false;
    final List<String> feedback = <String>[];
    for (int i = 0; i < steps.length; i++) {
      final DecisionStep s = steps[i];
      final int c = choices[i];
      if (c < 0 || c >= s.options.length) {
        throw TaskGradingException('Choose an option for step ${i + 1}.');
      }
      final DecisionOption o = s.options[c];
      final int best = s.options.fold<int>(0, (int m, DecisionOption x) => x.points > m ? x.points : m);
      max += best;
      got += o.points;
      if (o.critical) {
        critical = true;
        feedback.add('Step ${i + 1}: unsafe decision — ${o.feedback}');
      } else if (o.points < best) {
        feedback.add('Step ${i + 1}: ${o.feedback}');
      }
    }
    if (critical) feedback.insert(0, 'A critical safety error fails this task regardless of the other decisions.');
    if (feedback.isEmpty) feedback.add('Every decision matched best practice.');
    return _result(spec, max == 0 ? 0 : got / max, feedback, forceFail: critical, day: day);
  }

  static TaskResult _workup(WorkupTaskSpec spec, WorkupAnswer a, int day) {
    if (a.ordered.isEmpty) throw TaskGradingException('Order at least one investigation.');
    if (a.ordered.length > spec.maxInvestigations) {
      throw TaskGradingException('Order at most ${spec.maxInvestigations} investigations.');
    }
    final int relevantTotal = spec.investigations.where((Investigation i) => i.relevant).length;
    final int irrelevantTotal = spec.investigations.length - relevantTotal;
    int rel = 0;
    int irr = 0;
    for (final int i in a.ordered) {
      if (i < 0 || i >= spec.investigations.length) continue;
      if (spec.investigations[i].relevant) {
        rel++;
      } else {
        irr++;
      }
    }
    final double invScore = ((relevantTotal == 0 ? 1 : rel / relevantTotal) -
            (irrelevantTotal == 0 ? 0 : 0.5 * irr / irrelevantTotal))
        .clamp(0, 1)
        .toDouble();
    final bool dxRight = a.diagnosis == spec.correctDiagnosis;
    final TaskResult mgmt = _decision(spec, spec.management, a.management, day);
    final List<String> feedback = <String>[
      if (rel < relevantTotal) 'Work-up missed ${relevantTotal - rel} key investigation(s).',
      if (irr > 0) '$irr investigation(s) did not change management — order with a reason.',
      dxRight ? 'Working diagnosis correct.' : 'Working diagnosis incorrect — revisit the key findings.',
      ...mgmt.feedback.where((String f) => f != 'Every decision matched best practice.'),
    ];
    final double total = 0.25 * invScore + 0.40 * (dxRight ? 1 : 0) + 0.35 * (mgmt.score / 100);
    final bool critical = mgmt.feedback.any((String f) => f.contains('unsafe decision'));
    return _result(spec, total, feedback,
        breakdown: <String, int>{
          'investigations': (invScore * 100).round(),
          'diagnosis': dxRight ? 100 : 0,
          'management': mgmt.score,
        },
        forceFail: critical || !dxRight,
        day: day);
  }

  static TaskResult _numeric(NumericTaskSpec spec, NumericAnswer a, int day) {
    _expectLength(a.values.length, spec.parts.length, 'part');
    if (a.values.any((double? v) => v == null)) {
      throw TaskGradingException('Enter a number for every part.');
    }
    int right = 0;
    final List<String> feedback = <String>[];
    for (int i = 0; i < spec.parts.length; i++) {
      final NumericPart p = spec.parts[i];
      if (p.accepts(a.values[i])) {
        right++;
      } else {
        feedback.add('Part ${String.fromCharCode(97 + i)} is outside tolerance.'
            '${p.method.isEmpty ? '' : ' Method: ${p.method}'}');
      }
    }
    if (feedback.isEmpty) feedback.add('All parts correct within tolerance.');
    return _result(spec, right / spec.parts.length, feedback, day: day);
  }

  static TaskResult _ledger(LedgerTaskSpec spec, LedgerAnswer a, int day) {
    _expectLength(a.lines.length, spec.transactions.length, 'transaction');
    double got = 0;
    final List<String> feedback = <String>[];
    for (int i = 0; i < spec.transactions.length; i++) {
      final LedgerTransaction t = spec.transactions[i];
      final LedgerLineInput l = a.lines[i];
      if (l.debit == null || l.credit == null || l.amount == null) {
        throw TaskGradingException('Complete the debit, credit and amount for entry ${i + 1}.');
      }
      final bool d = l.debit == t.debit;
      final bool c = l.credit == t.credit;
      final bool m = (l.amount! - t.amount).abs() < 0.005;
      got += (d ? 1 : 0) + (c ? 1 : 0) + (m ? 1 : 0);
      if (!d) feedback.add('Entry ${i + 1}: wrong account debited.');
      if (!c) feedback.add('Entry ${i + 1}: wrong account credited.');
      if (!m) feedback.add('Entry ${i + 1}: amount does not match the source document.');
    }
    if (feedback.isEmpty) feedback.add('Every entry is correct and the journal balances.');
    return _result(spec, got / (3 * spec.transactions.length), feedback, day: day);
  }

  static TaskResult _classify(ClassifyTaskSpec spec, ClassifyAnswer a, int day) {
    _expectLength(a.picks.length, spec.items.length, 'item');
    if (a.picks.any((String? p) => p == null)) throw TaskGradingException('Classify every item.');
    int right = 0;
    final List<String> feedback = <String>[];
    for (int i = 0; i < spec.items.length; i++) {
      if (a.picks[i] == spec.items[i].category) {
        right++;
      } else {
        feedback.add('Item ${i + 1}: ${spec.items[i].why}');
      }
    }
    if (feedback.isEmpty) feedback.add('Every item classified correctly.');
    return _result(spec, right / spec.items.length, feedback, day: day);
  }

  static TaskResult _order(OrderTaskSpec spec, OrderAnswer a, int day) {
    final int n = spec.steps.length;
    _expectLength(a.order.length, n, 'step');
    if (a.order.toSet().length != n || a.order.any((int i) => i < 0 || i >= n)) {
      throw TaskGradingException('Place every step exactly once.');
    }
    int good = 0;
    int pairs = 0;
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        pairs++;
        if (a.order[i] < a.order[j]) good++;
      }
    }
    final List<String> feedback = <String>[];
    int firstWrong = -1;
    for (int i = 0; i < n; i++) {
      if (a.order[i] != i) {
        firstWrong = i;
        break;
      }
    }
    if (firstWrong >= 0) {
      feedback.add('The sequence goes wrong at position ${firstWrong + 1}.');
      if (spec.why.isNotEmpty) feedback.add(spec.why);
    } else {
      feedback.add('Correct sequence.');
    }
    return _result(spec, pairs == 0 ? 1 : good / pairs, feedback, day: day);
  }

  static TaskResult _written(WrittenTaskSpec spec, WrittenAnswer a, int day) {
    if (a.text.trim().isEmpty) throw TaskGradingException('Write your answer first.');
    final TextAssessment t =
        TextRubric.assess(a.text, spec.rubric, minWords: spec.minWords, maxWords: spec.maxWords);
    final List<String> feedback = <String>[
      ...t.notes,
      for (final Concept c in t.misses) 'Not addressed: ${c.label}.',
      if (t.misses.isEmpty) 'Every rubric point is addressed.',
    ];
    return TaskResult(
      taskId: spec.id,
      score: t.score,
      passed: t.score >= spec.passMark,
      feedback: feedback,
      breakdown: <String, int>{
        'coverage': (t.coverage * 100).round(),
        'structure': (t.structure * 100).round(),
        'words': t.words,
      },
      day: day,
    );
  }

  static TaskResult _label(LabelTaskSpec spec, LabelAnswer a, int day) {
    _expectLength(a.labels.length, spec.hotspots.length, 'marker');
    if (a.labels.any((String? l) => l == null)) throw TaskGradingException('Label every marker.');
    int right = 0;
    final List<String> feedback = <String>[];
    for (int i = 0; i < spec.hotspots.length; i++) {
      if (a.labels[i] == spec.hotspots[i].answer) {
        right++;
      } else {
        feedback.add('Marker ${i + 1} is labelled incorrectly.');
      }
    }
    if (feedback.isEmpty) feedback.add('All structures identified.');
    return _result(spec, right / spec.hotspots.length, feedback, day: day);
  }

  static TaskResult _court(CourtroomTaskSpec spec, CourtroomAnswer a, int day) {
    _expectLength(a.rulings.length, spec.transcript.length, 'line of testimony');
    int right = 0;
    final List<String> feedback = <String>[];
    for (int i = 0; i < spec.transcript.length; i++) {
      final TranscriptLine l = spec.transcript[i];
      final String? r = a.rulings[i];
      if (r == l.objection) {
        right++;
      } else if (l.objection == null) {
        feedback.add('Line ${i + 1}: no objection was warranted — ${l.why}');
      } else if (r == null) {
        feedback.add('Line ${i + 1}: you missed an objection — ${l.why}');
      } else {
        feedback.add('Line ${i + 1}: wrong ground — ${l.why}');
      }
    }
    if (feedback.isEmpty) feedback.add('Every objection was correct and timely.');
    return _result(spec, right / spec.transcript.length, feedback, day: day);
  }
}
