/// Maths lab steps and their graders. Every check is mathematical: lines of
/// working are compared by solution set or by numeric equivalence, numbers
/// by tolerance, ODE solutions by substituting them into the equation.
library;

import 'dart:math' as math;

import '../../model/career_models.dart';
import '../lab_grading.dart';
import '../lab_models.dart';
import 'expr.dart';

// ------------------------------------------------------------ working

enum WorkingMode {
  /// Solve an equation or inequality in one variable.
  solve,

  /// Solve simultaneous equations; every line must hold at the solution.
  system,

  /// Rewrite an expression (expand, factorise, differentiate …); every
  /// line must equal the target expression.
  simplify,

  /// Find an antiderivative; every line's derivative must equal the integrand.
  antiderivative,

  /// Evaluate to a number; every line must have the target value.
  evaluate,
}

enum FinalForm {
  any('any form'),
  solved('“x = …” with numbers only'),
  expanded('expanded, with no brackets'),
  factored('factorised into brackets'),
  number('a single number');

  const FinalForm(this.label);
  final String label;
}

class WorkingStep extends LabStep {
  const WorkingStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.given,
    required this.mode,
    required this.start,
    this.variable = 'x',
    this.range = (-50, 50),
    this.extraneous = const <double>[],
    this.solution = const <String, double>{},
    this.finalForm = FinalForm.any,
    this.minLines = 2,
    this.hints = const <String>[],
    this.model = const <String>[],
    this.tolerance = 1e-6,
    super.skills,
  }) : super(passMark: 80);

  /// The problem as shown to the student.
  final String given;
  final WorkingMode mode;

  /// solve/system: the original relation(s), one per line (`;`-separated for
  /// systems); simplify: the target expression; antiderivative: the
  /// integrand; evaluate: an expression with the target value.
  final String start;
  final String variable;
  final (double, double) range;

  /// Values a correct intermediate line may gain (e.g. after multiplying by
  /// a denominator or squaring); the final answer must reject them.
  final List<double> extraneous;

  /// system: the solution, e.g. {x: 2, y: -1}.
  final Map<String, double> solution;
  final FinalForm finalForm;

  /// Lines of working required in addition to the final answer.
  final int minLines;
  final List<String> hints;

  /// A model solution shown after submitting.
  final List<String> model;

  /// Relative tolerance for evaluate mode (allow rounding with e.g. 0.005).
  final double tolerance;

  @override
  String get kind => 'Show your working';
}

/// One line of the student's working after checking.
class LineCheck {
  const LineCheck(this.text, this.ok, this.message, {this.note = false, this.comment = false});
  final String text;
  final bool ok;
  final String message;

  /// Lines that are kept but not checked (comments, integral notation).
  final bool note;

  /// A # comment: does not count as a line of working.
  final bool comment;
}

abstract final class WorkingChecker {
  static final RegExp _lead = RegExp(r'^(⇒|=>|->|→|∴|so\b|therefore\b|hence\b|then\b|=)\s*', caseSensitive: false);

  static String clean(String line) {
    String s = line.trim();
    while (true) {
      final Match? m = _lead.firstMatch(s);
      if (m == null || m.end == 0) break;
      // "= 3x" (continuing a chain of expressions) — but keep "=" if the line is an equation.
      s = s.substring(m.end).trim();
    }
    return s;
  }

  static bool isNote(String line) {
    final String t = line.trim();
    return t.startsWith('#') || t.startsWith('//') || t.toLowerCase().startsWith('note:');
  }

  /// Checks every line; the last non-note line is the final answer.
  static List<LineCheck> check(WorkingStep s, List<String> lines) {
    final List<LineCheck> out = <LineCheck>[];
    for (final String raw in lines) {
      if (raw.trim().isEmpty) continue;
      if (isNote(raw)) {
        out.add(LineCheck(raw.trim(), true, 'Comment (not checked).', note: true, comment: true));
        continue;
      }
      out.add(_line(s, clean(raw)));
    }
    return out;
  }

  static LineCheck _line(WorkingStep s, String text) {
    try {
      switch (s.mode) {
        case WorkingMode.solve:
          return _solveLine(s, text);
        case WorkingMode.system:
          final Statement st = parseStatement(text);
          for (final Relation r in st.alternatives) {
            final Set<String> extra = r.variables.difference(s.solution.keys.toSet());
            if (extra.isNotEmpty) return LineCheck(text, false, 'Unknown symbol ${extra.first}.');
          }
          // Several relations on one line (x = 2, y = 3) must all hold.
          final bool h = st.alternatives.every((Relation r) => r.holds(s.solution) == true);
          return h
              ? LineCheck(text, true, 'Holds at the solution.')
              : LineCheck(text, false, 'This line is not true at the solution (${_env(s.solution)}). An error was made here.');
        case WorkingMode.simplify:
          final Expr target = parseExpr(s.start);
          final Expr e = parseExpr(text);
          final Set<String> extra = e.variables.difference(target.variables);
          if (extra.isNotEmpty) return LineCheck(text, false, 'Unexpected symbol ${extra.first}.');
          return equivalent(e, target)
              ? LineCheck(text, true, 'Equal to the expression (read as ${e.show()}).')
              : LineCheck(text, false, 'Not equal to the expression: for example at ${_counterexample(e, target)}.');
        case WorkingMode.antiderivative:
          if (text.contains('∫') || text.toLowerCase().contains('int ') || text.contains('dx')) {
            return LineCheck(text, true, 'Integral notation (not checked).', note: true);
          }
          final Expr integrand = parseExpr(s.start);
          final Expr f = parseExpr(text);
          final Set<String> extra = f.variables.difference(<String>{s.variable, 'C'});
          if (extra.isNotEmpty) return LineCheck(text, false, 'Unexpected symbol ${extra.first}.');
          final math.Random r = math.Random(3);
          int ok = 0;
          for (int k = 0; k < 40 && ok < 10; k++) {
            final double x = s.range.$1 + r.nextDouble() * (s.range.$2 - s.range.$1);
            final Map<String, double> env = <String, double>{'C': 1.7};
            final double d = derivativeAt(f, s.variable, x, env);
            final double want = at(integrand, s.variable, x);
            if (!d.isFinite || !want.isFinite) continue;
            if (!close(d, want, rel: 1e-4, abs: 1e-5)) {
              return LineCheck(text, false, 'Differentiating this line does not give the integrand (at ${s.variable} = ${fmtNum(_round(x))} it gives ${fmtNum(_round(d))}, not ${fmtNum(_round(want))}).');
            }
            ok++;
          }
          return ok >= 5 ? LineCheck(text, true, 'Its derivative is the integrand.') : LineCheck(text, false, 'Could not be evaluated on the interval.');
        case WorkingMode.evaluate:
          final Expr e = parseExpr(text);
          if (e.variables.isNotEmpty) return LineCheck(text, false, 'Should be a number by now — ${e.variables.first} is still unknown.');
          final double v = e.eval(const <String, double>{});
          final double want = parseExpr(s.start).eval(const <String, double>{});
          return close(v, want, rel: math.max(s.tolerance, 1e-9), abs: 1e-9)
              ? LineCheck(text, true, 'Value ${fmtNum(_round(v))} is correct.')
              : LineCheck(text, false, 'This has value ${fmtNum(_round(v))}; the working went wrong here.');
      }
    } on ExprParseException catch (e) {
      return LineCheck(text, false, 'Could not read this line: ${e.message}');
    }
  }

  static double _round(double v) => double.parse(v.toStringAsPrecision(6));

  static String _env(Map<String, double> m) => m.entries.map((MapEntry<String, double> e) => '${e.key} = ${fmtNum(e.value)}').join(', ');

  static String _counterexample(Expr a, Expr b) {
    final Set<String> vars = <String>{...a.variables, ...b.variables};
    for (final double x in <double>[2, -1, 3, 0.5, -2.5, 1.5]) {
      final Map<String, double> env = <String, double>{for (final String v in vars) v: x};
      try {
        final double p = a.eval(env);
        final double q = b.eval(env);
        if (p.isFinite && q.isFinite && !close(p, q, rel: 1e-6, abs: 1e-7)) {
          return '${vars.isEmpty ? '' : '${vars.join(' = ')} = ${fmtNum(x)}, '}your line gives ${fmtNum(_round(p))} but it should be ${fmtNum(_round(q))}';
        }
      } on ExprParseException {
        continue;
      }
    }
    return 'some values';
  }

  // ---- one-variable equations and inequalities

  static Relation _original(WorkingStep s) => parseRelation(s.start);

  /// Solution set of an equation statement (union over "or").
  static List<double>? solutionSet(Statement st, String v, (double, double) range) {
    final List<double> all = <double>[];
    for (final Relation r in st.alternatives) {
      if (!r.isEquation) return null;
      final List<double>? rs = roots(r.difference, v, range.$1, range.$2);
      if (rs == null) return null;
      for (final double x in rs) {
        if (!all.any((double y) => (x - y).abs() < 1e-6 * (1 + y.abs()))) all.add(x);
      }
    }
    all.sort();
    return all;
  }

  static List<double> trueSolutions(WorkingStep s) {
    final Relation o = _original(s);
    final List<double> rs = roots(o.difference, s.variable, s.range.$1, s.range.$2) ?? <double>[];
    // Keep only values where the original is defined (rejects extraneous roots).
    return rs.where((double x) => o.holds(<String, double>{s.variable: x}, tol: 1e-7) == true).toList();
  }

  static LineCheck _solveLine(WorkingStep s, String text) {
    final Relation o = _original(s);
    final Statement st = parseStatement(text, defaultVariable: s.variable);
    final Set<String> extra = st.variables.difference(<String>{s.variable});
    if (extra.isNotEmpty) return LineCheck(text, false, 'Unknown symbol ${extra.first}.');
    if (o.isEquation) {
      final List<double> want = trueSolutions(s);
      final List<double>? got = solutionSet(st, s.variable, s.range);
      if (got == null) {
        return LineCheck(text, false, st.alternatives.any((Relation r) => !r.isEquation)
            ? 'This is an inequality, but the problem is an equation.'
            : 'This line is true for every ${s.variable}, so information was lost — check the step that produced it.');
      }
      final List<double> lost = want.where((double x) => !got.any((double y) => (x - y).abs() < 1e-5 * (1 + x.abs()))).toList();
      if (lost.isNotEmpty) {
        return LineCheck(text, false, 'This line loses the solution ${s.variable} = ${fmtNum(lost.first)}${got.isEmpty ? '' : ' (its solutions are ${showSet(got, s.variable)})'}. '
            'Dividing by an expression that can be zero, or an arithmetic slip, causes this.');
      }
      final List<double> gained = got.where((double x) => !want.any((double y) => (x - y).abs() < 1e-5 * (1 + y.abs()))).toList();
      final List<double> wrongGain = gained.where((double x) => !s.extraneous.any((double e) => (x - e).abs() < 1e-5 * (1 + e.abs()))).toList();
      if (wrongGain.isNotEmpty) {
        return LineCheck(text, false, 'This line has solutions ${showSet(got, s.variable)}, which the original does not — the working went wrong here.');
      }
      if (gained.isNotEmpty) {
        return LineCheck(text, true, 'Valid step, but it introduces ${showSet(gained, s.variable)}, which must be checked against the original and rejected.');
      }
      return LineCheck(text, true, 'Same solutions as the original (read as ${st.show()}).');
    }
    // Inequality: compare truth across the interval.
    final (double lo, double hi) = s.range;
    const int n = 4000;
    final List<bool?> t0 = <bool?>[];
    final List<bool?> t1 = <bool?>[];
    for (int k = 0; k <= n; k++) {
      final Map<String, double> env = <String, double>{s.variable: lo + (hi - lo) * k / n + 1e-7};
      t0.add(o.holds(env, tol: 0));
      t1.add(st.holds(env));
    }
    for (int k = 0; k <= n; k++) {
      if (t0[k] == null || t1[k] == null || t0[k] == t1[k]) continue;
      bool nearEdge = false;
      for (int j = math.max(0, k - 2); j < math.min(n, k + 2); j++) {
        if (t0[j] != t0[j + 1]) nearEdge = true;
      }
      if (nearEdge) continue;
      final double x = lo + (hi - lo) * k / n;
      return LineCheck(text, false,
          'Not equivalent to the original: at ${s.variable} = ${fmtNum(_round(x))} the original is ${t0[k]! ? 'true' : 'false'} but this line is ${t1[k]! ? 'true' : 'false'}. '
          '${o.isInequality ? 'Multiplying or dividing by a negative number reverses the inequality sign.' : ''}');
    }
    return LineCheck(text, true, 'Same solution set as the original.');
  }

  /// True when [text] is a final answer of the required form.
  static String? formProblem(WorkingStep s, String text) {
    try {
      switch (s.finalForm) {
        case FinalForm.any:
          return null;
        case FinalForm.number:
          return parseNumeric(text) == null ? 'The final answer should be a single number.' : null;
        case FinalForm.expanded:
          return text.contains('(') ? 'The final answer should be fully expanded (no brackets).' : null;
        case FinalForm.factored:
          final Expr e = parseExpr(text);
          return (e is Bin && (e.op == '*' || e.op == '^') && text.contains('(')) || (e is Neg && text.contains('('))
              ? null
              : 'The final answer should be written as a product of factors, e.g. (x − 2)(x + 3).';
        case FinalForm.solved:
          final Statement st = parseStatement(text, defaultVariable: s.mode == WorkingMode.system ? null : s.variable);
          for (final Relation r in st.alternatives) {
            final int unknowns = r.parts.where((Expr e) => e.variables.isNotEmpty).length;
            final bool bare = r.parts.every((Expr e) => e.variables.isEmpty || e is Var);
            if (unknowns != 1 || !bare) return 'The final answer should state the value(s), e.g. ${s.variable} = 3.';
          }
          return null;
      }
    } on ExprParseException catch (e) {
      return 'Could not read the final answer: ${e.message}';
    }
  }

  /// Whether the final answer is exactly right (not merely a valid step).
  static String? finalProblem(WorkingStep s, String text) {
    try {
      switch (s.mode) {
        case WorkingMode.solve:
          final Relation o = _original(s);
          if (!o.isEquation) return null; // equivalence already checked line by line
          final List<double> want = trueSolutions(s);
          final List<double>? got = solutionSet(parseStatement(text, defaultVariable: s.variable), s.variable, s.range);
          if (got == null || !sameSet(got, want)) {
            final List<double> extraneous = (got ?? <double>[]).where((double x) => !want.any((double y) => (x - y).abs() < 1e-5)).toList();
            if (extraneous.isNotEmpty && sameSet(got!.where((double x) => !extraneous.contains(x)).toList(), want)) {
              return '${showSet(extraneous, s.variable)} does not satisfy the original equation. Substitute it back in and reject it.';
            }
            return 'The final answer should be ${want.isEmpty ? 'that there is no solution' : showSet(want, s.variable)}.';
          }
          return null;
        case WorkingMode.system:
          final Statement st = parseStatement(text);
          final Map<String, double> given = <String, double>{};
          for (final Relation r in st.alternatives) {
            if (r.isEquation && r.parts.first is Var && r.parts.last.variables.isEmpty) {
              given[(r.parts.first as Var).name] = r.parts.last.eval(const <String, double>{});
            }
          }
          for (final MapEntry<String, double> e in s.solution.entries) {
            final double? g = given[e.key];
            if (g == null) return 'State the value of ${e.key} in the final line (e.g. ${s.solution.keys.map((String k) => '$k = …').join(', ')}).';
            if (!close(g, e.value, rel: 1e-6, abs: 1e-6)) return '${e.key} = ${fmtNum(g)} is not right.';
          }
          return null;
        case WorkingMode.simplify:
        case WorkingMode.antiderivative:
        case WorkingMode.evaluate:
          return null;
      }
    } on ExprParseException catch (e) {
      return 'Could not read the final answer: ${e.message}';
    }
  }

  static TaskResult grade(WorkingStep s, List<String> lines, {int hintsUsed = 0}) {
    final List<LineCheck> checks = check(s, lines);
    final List<LineCheck> math0 = checks.where((LineCheck c) => !c.note).toList();
    if (math0.isEmpty) throw LabGradingException('Write your working, one step per line, with the final answer last.');
    final List<String> fb = <String>[];
    int firstError = -1;
    for (int i = 0; i < checks.length; i++) {
      final LineCheck c = checks[i];
      if (c.note) continue;
      fb.add('Line ${i + 1} ${c.ok ? '✓' : '✗'} ${c.text} — ${c.message}');
      if (!c.ok && firstError < 0) firstError = i;
    }
    final LineCheck last = math0.last;
    final String? finalIssue = last.ok ? finalProblem(s, last.text) : 'The final line is not correct.';
    final String? formIssue = formProblem(s, last.text);
    final int working = checks.where((LineCheck c) => !c.comment).length - 1;
    final bool finalRight = last.ok && finalIssue == null;
    int score;
    if (finalRight && firstError < 0) {
      score = 100;
      if (formIssue != null) score = 75;
      if (working < s.minLines) score = math.min(score, 60);
    } else if (finalRight) {
      score = 55; // right answer, flawed working
    } else {
      final int goodBefore = firstError < 0 ? math0.length - 1 : checks.take(firstError).where((LineCheck c) => !c.note).length;
      score = (50 * goodBefore / math.max(1, math0.length)).round();
    }
    final List<String> head = <String>[];
    if (firstError >= 0) {
      head.add('The first incorrect step is line ${firstError + 1}: ${checks[firstError].message}');
    } else if (!finalRight) {
      head.add(finalIssue ?? 'The final answer is not correct.');
    } else {
      head.add('Every line is valid and the final answer is correct.');
    }
    if (finalRight && firstError >= 0) head.add('Your final answer is right, but the working contains an invalid step.');
    if (!finalRight && firstError < 0 && finalIssue != null && head.first != finalIssue) head.add(finalIssue);
    if (formIssue != null) head.add(formIssue);
    if (working < s.minLines) head.add('Show at least ${s.minLines} lines of working before the final answer (you showed $working).');
    if (hintsUsed > 0) head.add('Hints used: $hintsUsed.');
    return gradeResult(s, score / 100, <String>[...head, ...fb], breakdown: <String, int>{
      'lines': math0.length,
      'firstError': firstError < 0 ? 0 : firstError + 1,
      'finalCorrect': finalRight ? 1 : 0,
      'hints': hintsUsed,
    });
  }
}

// ------------------------------------------------------------ numbers and choices

sealed class MathQuestion {
  const MathQuestion(this.id, this.prompt);
  final String id;
  final String prompt;
}

class NumberQuestion extends MathQuestion {
  const NumberQuestion(super.id, super.prompt, this.answer, {this.tolerance = 0.01, this.relative = false, this.unit = '', this.explain = ''});
  final double answer;

  /// Absolute tolerance, or relative when [relative].
  final double tolerance;
  final bool relative;
  final String unit;

  /// How the answer is worked out, shown after submitting.
  final String explain;

  bool accepts(double v) => relative ? (v - answer).abs() <= tolerance * answer.abs() : (v - answer).abs() <= tolerance + 1e-12;
}

class ChoiceQuestion extends MathQuestion {
  const ChoiceQuestion(super.id, super.prompt, this.options, this.correct, {this.explain = ''});
  final List<String> options;
  final int correct;
  final String explain;
}

/// A table of data shown with the questions (statistics, applied problems).
class DataTableSpec {
  const DataTableSpec(this.columns, this.rows, {this.caption = ''});
  final List<String> columns;
  final List<List<Object>> rows;
  final String caption;

  List<double> column(int i) => <double>[for (final List<Object> r in rows) (r[i] as num).toDouble()];
}

class NumericStep extends LabStep {
  const NumericStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.questions,
    this.data,
    this.curves = const <String>[],
    this.window,
    this.hints = const <String>[],
    super.skills,
    super.passMark = 80,
  });

  final List<MathQuestion> questions;
  final DataTableSpec? data;

  /// Expressions in x drawn on a graph above the questions.
  final List<String> curves;
  final (double, double, double, double)? window;
  final List<String> hints;

  @override
  String get kind => data != null ? 'Data analysis' : 'Calculation';
}

abstract final class NumericGrader {
  /// [answers]: question id → typed text (numbers) or option index (choices).
  static TaskResult grade(NumericStep s, Map<String, String> answers) {
    int ok = 0;
    final List<String> fb = <String>[];
    for (final MathQuestion q in s.questions) {
      final String raw = (answers[q.id] ?? '').trim();
      if (raw.isEmpty) throw LabGradingException('Answer every question first ("${q.prompt}").');
      switch (q) {
        case NumberQuestion():
          final double? v = parseNumeric(raw);
          if (v == null) {
            fb.add('✗ ${q.prompt}: "$raw" is not a number.');
          } else if (q.accepts(v)) {
            ok++;
            fb.add('✓ ${q.prompt}: ${fmtNum(v)}${q.unit.isEmpty ? '' : ' ${q.unit}'}.');
          } else {
            fb.add('✗ ${q.prompt}: you gave ${fmtNum(v)}; the answer is ${fmtNum(double.parse(q.answer.toStringAsPrecision(6)))}${q.unit.isEmpty ? '' : ' ${q.unit}'}.${q.explain.isEmpty ? '' : ' ${q.explain}'}');
          }
        case ChoiceQuestion():
          final int? i = int.tryParse(raw);
          if (i == q.correct) {
            ok++;
            fb.add('✓ ${q.prompt}: ${q.options[i!]}.');
          } else {
            fb.add('✗ ${q.prompt}: the answer is "${q.options[q.correct]}".${q.explain.isEmpty ? '' : ' ${q.explain}'}');
          }
      }
    }
    return gradeResult(s, ok / s.questions.length, fb, breakdown: <String, int>{'correct': ok, 'questions': s.questions.length});
  }
}

// ------------------------------------------------------------ graphs

class GraphParam {
  const GraphParam(this.name, this.min, this.max, {this.step = 0.5, this.initial = 0, this.label = ''});
  final String name;
  final double min;
  final double max;
  final double step;
  final double initial;
  final String label;
}

/// Move sliders until the curve meets the targets, then answer questions.
class GraphStep extends LabStep {
  const GraphStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.curve,
    required this.params,
    required this.window,
    this.targets = const <(double, double)>[],
    this.fixedCurves = const <String>[],
    this.questions = const <MathQuestion>[],
    this.targetTolerance = 0.05,
    super.skills,
  }) : super(passMark: 80);

  /// Expression in x and the parameter names.
  final String curve;
  final List<GraphParam> params;
  final (double, double, double, double) window;

  /// Points the student's curve must pass through.
  final List<(double, double)> targets;

  /// Reference curves drawn in grey (e.g. data or a second function).
  final List<String> fixedCurves;
  final List<MathQuestion> questions;
  final double targetTolerance;

  @override
  String get kind => 'Graphing';
}

abstract final class GraphGrader {
  static TaskResult grade(GraphStep s, Map<String, double> params, Map<String, String> answers) {
    final Expr e = parseExpr(s.curve);
    int ok = 0;
    int total = 0;
    final List<String> fb = <String>[];
    for (final (double x, double y) in s.targets) {
      total++;
      final double v = at(e, 'x', x, params);
      if (v.isFinite && (v - y).abs() <= s.targetTolerance * math.max(1, y.abs())) {
        ok++;
        fb.add('✓ The curve passes through (${fmtNum(x)}, ${fmtNum(y)}).');
      } else {
        fb.add('✗ At x = ${fmtNum(x)} your curve is at y = ${v.isFinite ? fmtNum(double.parse(v.toStringAsPrecision(4))) : 'undefined'}, not ${fmtNum(y)}.');
      }
    }
    if (s.questions.isNotEmpty) {
      final NumericStep inner = NumericStep(id: s.id, title: s.title, instructions: '', questions: s.questions);
      final TaskResult r = NumericGrader.grade(inner, answers);
      ok += r.breakdown['correct'] ?? 0;
      total += s.questions.length;
      fb.addAll(r.feedback);
    }
    fb.insert(0, 'Your parameters: ${params.entries.map((MapEntry<String, double> e) => '${e.key} = ${fmtNum(e.value)}').join(', ')}.');
    return gradeResult(s, total == 0 ? 0 : ok / total, fb, breakdown: <String, int>{'correct': ok, 'items': total});
  }
}

// ------------------------------------------------------------ matrices

class MatrixStep extends LabStep {
  const MatrixStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.given,
    required this.answer,
    this.answerLabel = 'Result',
    this.hints = const <String>[],
    super.skills,
  }) : super(passMark: 100);

  /// Named matrices shown to the student.
  final Map<String, List<List<double>>> given;
  final List<List<double>> answer;
  final String answerLabel;
  final List<String> hints;

  @override
  String get kind => 'Matrix calculation';
}

abstract final class MatrixGrader {
  static TaskResult grade(MatrixStep s, List<List<String>> cells) {
    int ok = 0;
    int total = 0;
    final List<String> wrong = <String>[];
    for (int i = 0; i < s.answer.length; i++) {
      for (int j = 0; j < s.answer[i].length; j++) {
        total++;
        final String raw = i < cells.length && j < cells[i].length ? cells[i][j].trim() : '';
        if (raw.isEmpty) throw LabGradingException('Fill every cell of the ${s.answerLabel.toLowerCase()} first.');
        final double? v = parseNumeric(raw);
        if (v != null && close(v, s.answer[i][j], rel: 1e-3, abs: 1e-3)) {
          ok++;
        } else {
          wrong.add('row ${i + 1}, column ${j + 1}');
        }
      }
    }
    final List<String> fb = <String>[
      if (wrong.isEmpty) 'Every entry is correct.' else 'Incorrect entries: ${wrong.join('; ')}.',
      if (wrong.isNotEmpty) 'Recompute those entries — each is a row of the first matrix combined with a column of the second (for products), or follow the method in the hints.',
    ];
    return gradeResult(s, ok / total, fb, breakdown: <String, int>{'correct': ok, 'cells': total});
  }
}

// ------------------------------------------------------------ differential equations

class OdeStep extends LabStep {
  const OdeStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.equation,
    required this.rhs,
    this.order = 1,
    this.initial,
    this.range = (0, 2),
    this.hints = const <String>[],
    this.model = '',
    super.skills,
  }) : super(passMark: 80);

  /// The equation as shown, e.g. "dy/dx = 0.3y".
  final String equation;

  /// y' = rhs(x, y) for order 1; y'' = rhs(x, y, yp) for order 2 (yp is y').
  final String rhs;
  final int order;

  /// (x0, y0) or (x0, y0, y'0); null for a general solution with constants
  /// C (order 1) or C1 and C2 (order 2).
  final List<double>? initial;
  final (double, double) range;
  final List<String> hints;
  final String model;

  bool get general => initial == null;

  List<String> get constants => order == 1 ? const <String>['C'] : const <String>['C1', 'C2'];

  @override
  String get kind => 'Differential equation';
}

abstract final class OdeGrader {
  static String _strip(String s) => s.trim().replaceFirst(RegExp(r'^y\s*(\(\s*x\s*\))?\s*='), '').trim();

  /// Largest relative residual of the ODE on the interval.
  static double residual(OdeStep s, Expr y, Map<String, double> consts) {
    final Expr rhs = parseExpr(s.rhs);
    double worst = 0;
    for (int k = 0; k <= 12; k++) {
      final double x = s.range.$1 + (s.range.$2 - s.range.$1) * (0.03 + 0.94 * k / 12);
      final double yv = at(y, 'x', x, consts);
      final double d1 = derivativeAt(y, 'x', x, consts);
      if (!yv.isFinite || !d1.isFinite) return double.infinity;
      final Map<String, double> env = <String, double>{'x': x, 'y': yv, 'yp': d1};
      final double lhs = s.order == 1 ? d1 : secondDerivativeAt(y, 'x', x, consts);
      final double want = rhs.eval(env);
      final double r = (lhs - want).abs() / (1 + want.abs() + lhs.abs());
      worst = math.max(worst, r);
    }
    return worst;
  }

  static TaskResult grade(OdeStep s, String answer) {
    if (answer.trim().isEmpty) throw LabGradingException('Enter your solution y(x).');
    final Expr y;
    try {
      y = parseExpr(_strip(answer));
    } on ExprParseException catch (e) {
      return gradeResult(s, 0, <String>['Could not read your solution: ${e.message}']);
    }
    final Set<String> allowed = <String>{'x', if (s.general) ...s.constants};
    final Set<String> extra = y.variables.difference(allowed);
    if (extra.isNotEmpty) {
      return gradeResult(s, 0, <String>[
        'Unexpected symbol ${extra.first}.',
        if (s.general) 'Use ${s.constants.join(' and ')} for the arbitrary constant${s.constants.length > 1 ? 's' : ''}.' else 'This is an initial value problem: the answer should contain no unknown constants.',
      ]);
    }
    final List<String> fb = <String>[];
    double score = 0;
    final double tol = s.order == 1 ? 1e-4 : 2e-3;
    if (s.general) {
      final List<Map<String, double>> sets = <Map<String, double>>[
        <String, double>{'C': 1.3, 'C1': 1.3, 'C2': -0.7},
        <String, double>{'C': -2.1, 'C1': -0.4, 'C2': 2.2},
        <String, double>{'C': 0.6, 'C1': 2.5, 'C2': 0.9},
      ];
      final bool satisfies = sets.every((Map<String, double> c) => residual(s, y, c) < tol);
      if (satisfies) {
        score += 0.7;
        fb.add('✓ Substituting your solution into ${s.equation} makes both sides equal for any value of the constant${s.constants.length > 1 ? 's' : ''}.');
      } else {
        fb.add('✗ Your function does not satisfy ${s.equation}: substitute it and its derivative${s.order == 2 ? 's' : ''} into the equation to see the mismatch.');
      }
      final List<String> missing = s.constants.where((String c) => !y.variables.contains(c)).toList();
      if (missing.isEmpty) {
        score += 0.3;
        fb.add('✓ The general solution has ${s.constants.length} arbitrary constant${s.constants.length > 1 ? 's' : ''}, as an order-${s.order} equation needs.');
      } else {
        fb.add('✗ A general solution of an order-${s.order} equation needs ${s.constants.length} arbitrary constant${s.constants.length > 1 ? 's' : ''} (${s.constants.join(', ')}); ${missing.join(', ')} is missing.');
      }
    } else {
      final double r = residual(s, y, const <String, double>{});
      if (r < tol) {
        score += 0.6;
        fb.add('✓ Your function satisfies ${s.equation}.');
      } else {
        fb.add('✗ Your function does not satisfy ${s.equation}.');
      }
      final List<double> ic = s.initial!;
      final double y0 = at(y, 'x', ic[0]);
      bool icOk = y0.isFinite && close(y0, ic[1], rel: 1e-4, abs: 1e-4);
      String icText = 'y(${fmtNum(ic[0])}) = ${fmtNum(ic[1])}';
      if (s.order == 2 && ic.length > 2) {
        final double d0 = derivativeAt(y, 'x', ic[0]);
        icOk = icOk && close(d0, ic[2], rel: 1e-3, abs: 1e-3);
        icText += ' and y\'(${fmtNum(ic[0])}) = ${fmtNum(ic[2])}';
      }
      if (icOk) {
        score += 0.4;
        fb.add('✓ It meets the initial condition${s.order == 2 ? 's' : ''} $icText.');
      } else {
        fb.add('✗ It does not meet $icText (your y(${fmtNum(ic[0])}) = ${y0.isFinite ? fmtNum(double.parse(y0.toStringAsPrecision(6))) : 'undefined'}). Use the condition${s.order == 2 ? 's' : ''} to find the constant${s.order == 2 ? 's' : ''}.');
      }
    }
    return gradeResult(s, score, fb);
  }
}
