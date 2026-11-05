/// Professional work tasks shared across majors, each with deterministic
/// marking rules:
///  * [TriageStep]   – work a queue (tickets, alerts, transactions, CVs …)
///  * [SequenceStep] – order a procedure; safety-critical order is enforced
///  * [DocumentStep] – write a professional document against a rubric
///  * [DialogueStep] – interview / consult / examine a simulated person
///  * [SimulationStep] – drive a formula-based model to meet a specification
library;

import 'dart:math' as math;

import '../../model/career_models.dart';
import '../lab_grading.dart';
import '../lab_models.dart';
import '../math/expr.dart';
import '../math/math_steps.dart';

// ------------------------------------------------------------ triage

class TriageField {
  const TriageField(this.id, this.label, this.options);
  final String id;
  final String label;
  final List<String> options;
}

class TriageItem {
  const TriageItem({
    required this.id,
    required this.title,
    required this.body,
    required this.answers,
    this.meta = const <String, String>{},
    this.why = '',
    this.critical = false,
  });
  final String id;
  final String title;
  final String body;

  /// Shown as labelled facts (From, Time, Amount …).
  final Map<String, String> meta;

  /// field id → correct option; several acceptable options separated by '|'.
  final Map<String, String> answers;

  /// Why the correct decision is correct (shown after submitting).
  final String why;

  /// Getting this item wrong is a serious professional error and fails the task.
  final bool critical;
}

class TriageStep extends LabStep {
  const TriageStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.fields,
    required this.items,
    this.queueName = 'Queue',
    super.skills,
    super.passMark = 75,
  });
  final List<TriageField> fields;
  final List<TriageItem> items;
  final String queueName;

  @override
  String get kind => queueName;
}

abstract final class TriageGrader {
  static bool _ok(String correct, String? given) => given != null && correct.split('|').contains(given);

  /// [decisions]: item id → field id → chosen option.
  static TaskResult grade(TriageStep s, Map<String, Map<String, String>> decisions) {
    int ok = 0, total = 0;
    bool critical = false;
    final List<String> fb = <String>[];
    for (final TriageItem it in s.items) {
      final Map<String, String> d = decisions[it.id] ?? const <String, String>{};
      final List<String> wrong = <String>[];
      for (final TriageField f in s.fields) {
        final String? correct = it.answers[f.id];
        if (correct == null) continue;
        total++;
        if (d[f.id] == null) throw LabGradingException('Decide "${f.label}" for "${it.title}" first.');
        if (_ok(correct, d[f.id])) {
          ok++;
        } else {
          wrong.add('${f.label}: you chose ${d[f.id]}; expected ${correct.replaceAll('|', ' or ')}');
        }
      }
      if (wrong.isEmpty) {
        fb.add('✓ ${it.title}');
      } else {
        if (it.critical) critical = true;
        fb.add('✗ ${it.title} — ${wrong.join('; ')}.${it.why.isEmpty ? '' : ' ${it.why}'}${it.critical ? ' This was a critical item.' : ''}');
      }
    }
    if (critical) fb.insert(0, 'A critical item was handled wrongly. In practice this would cause harm or a serious breach, so the task cannot pass.');
    return gradeResult(s, total == 0 ? 0 : ok / total, fb, breakdown: <String, int>{'correct': ok, 'decisions': total}, forceFail: critical);
  }
}

// ------------------------------------------------------------ sequence

class SequenceStep extends LabStep {
  const SequenceStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.correctOrder,
    this.mustPrecede = const <(int, int)>[],
    super.skills,
    super.passMark = 80,
  });

  /// The procedure in the correct order.
  final List<String> correctOrder;

  /// Pairs (a, b) of indices into [correctOrder]: a must come before b, or
  /// the task fails (e.g. hand hygiene before touching the patient).
  final List<(int, int)> mustPrecede;

  /// The order first shown: a fixed shuffle, so it never starts solved.
  List<int> get startOrder {
    final List<int> idx = List<int>.generate(correctOrder.length, (int i) => i);
    idx.shuffle(math.Random(id.codeUnits.fold<int>(7, (int a, int c) => (a * 31 + c) & 0x3fffffff)));
    bool sorted = true;
    for (int i = 0; i < idx.length; i++) {
      if (idx[i] != i) sorted = false;
    }
    if (sorted && idx.length > 1) {
      final int t = idx[0];
      idx[0] = idx[1];
      idx[1] = t;
    }
    return idx;
  }

  @override
  String get kind => 'Procedure';
}

abstract final class SequenceGrader {
  /// [order]: indices into correctOrder in the student's order.
  static TaskResult grade(SequenceStep s, List<int> order) {
    final int n = s.correctOrder.length;
    if (order.length != n || order.toSet().length != n) throw LabGradingException('Place every step exactly once.');
    int inPlace = 0;
    for (int i = 0; i < n; i++) {
      if (order[i] == i) inPlace++;
    }
    // Pairs in the right relative order (Kendall agreement).
    int agree = 0, pairs = 0;
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        pairs++;
        if (order[i] < order[j]) agree++;
      }
    }
    final List<String> fb = <String>[];
    bool unsafe = false;
    for (final (int a, int b) in s.mustPrecede) {
      if (order.indexOf(a) > order.indexOf(b)) {
        unsafe = true;
        fb.add('Unsafe order: "${s.correctOrder[a]}" must come before "${s.correctOrder[b]}".');
      }
    }
    final int first = List<int>.generate(n, (int i) => i).firstWhere((int i) => order[i] != i, orElse: () => -1);
    if (first < 0) {
      fb.add('Every step is in the correct order.');
    } else {
      fb.add('Position ${first + 1} should be "${s.correctOrder[first]}" — you placed "${s.correctOrder[order[first]]}" there.');
      fb.add('$inPlace of $n steps are in exactly the right position.');
      fb.add('Correct order: ${[for (int i = 0; i < n; i++) '${i + 1}. ${s.correctOrder[i]}'].join('  ')}');
    }
    final double fraction = 0.5 * inPlace / n + 0.5 * (pairs == 0 ? 1 : agree / pairs);
    return gradeResult(s, fraction, fb, breakdown: <String, int>{'inPlace': inPlace, 'steps': n}, forceFail: unsafe);
  }
}

// ------------------------------------------------------------ documents

/// One rubric line: met when any pattern matches the section text.
class RubricItem {
  const RubricItem(this.label, this.patterns, {this.weight = 1, this.advice = ''});
  final String label;

  /// Case-insensitive regular expressions; any match satisfies the item.
  final List<String> patterns;
  final int weight;
  final String advice;

  bool met(String text) => patterns.any((String p) => RegExp(p, caseSensitive: false).hasMatch(text));
}

class DocSection {
  const DocSection(this.id, this.heading, {this.guidance = '', this.minWords = 30, this.rubric = const <RubricItem>[]});
  final String id;
  final String heading;
  final String guidance;
  final int minWords;
  final List<RubricItem> rubric;
}

class DocumentStep extends LabStep {
  const DocumentStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.docType,
    required this.sections,
    this.sources = const <String>[],
    this.allowedCitations = const <String>[],
    this.forbidden = const <RubricItem>[],
    this.model = const <String, String>{},
    super.skills,
    super.passMark = 70,
  });

  /// e.g. "Legal memorandum", "Incident report".
  final String docType;
  final List<DocSection> sections;

  /// Reference material shown beside the editor.
  final List<String> sources;

  /// Case names that may be cited (law): any other "X v Y" citation is
  /// flagged as unverified.
  final List<String> allowedCitations;

  /// Content that must not appear (e.g. a promise of an outcome to a client).
  final List<RubricItem> forbidden;

  /// A model answer per section (for tests and shown after submitting).
  final Map<String, String> model;

  @override
  String get kind => docType;
}

abstract final class DocumentGrader {
  static final RegExp _citation = RegExp(r"\b([A-Z][A-Za-z'&.\-]*(?:\s+[A-Z&][A-Za-z'&.\-]*)*)\s+v\.?\s+([A-Z][A-Za-z'&.\-]+(?:\s+[A-Za-z'&.\-]+){0,4})");
  static const Set<String> _filler = <String>{'r', 'ltd', 'co', 'plc', '&', 'and', 'the', 'in', 'see', 'of', 'llp', 'inc', 'limited'};

  static int words(String t) => RegExp(r"[A-Za-z0-9'’]+").allMatches(t).length;

  static List<String> _significant(String s) =>
      s.toLowerCase().split(RegExp(r"[^a-z0-9']+")).where((String w) => w.isNotEmpty && !_filler.contains(w)).toList();

  /// Citations in [text] that are not in [allowed]: a citation is recognised
  /// when an allowed authority contains the claimant's last significant word
  /// and the defendant's first significant word.
  static List<String> unverifiedCitations(String text, List<String> allowed) {
    final List<String> bad = <String>[];
    final List<String> al = allowed.map((String a) => a.toLowerCase()).toList();
    for (final Match m in _citation.allMatches(text)) {
      final List<String> claimant = _significant(m.group(1)!);
      final List<String> defendant = _significant(m.group(2)!);
      final String? c = claimant.isEmpty ? null : claimant.last;
      final String? d = defendant.isEmpty ? null : defendant.first;
      final bool known = al.any((String a) => (c == null || a.contains(c)) && (d == null || a.contains(d)));
      if (!known) bad.add(m.group(0)!.trim());
    }
    return bad;
  }

  static TaskResult grade(DocumentStep s, Map<String, String> text) {
    int got = 0, max = 0;
    final List<String> fb = <String>[];
    bool fail = false;
    for (final DocSection sec in s.sections) {
      final String t = (text[sec.id] ?? '').trim();
      if (t.isEmpty) throw LabGradingException('Write the "${sec.heading}" section first.');
      final int w = words(t);
      max += 1;
      if (w >= sec.minWords) {
        got += 1;
      } else {
        fb.add('✗ ${sec.heading}: $w words — at least ${sec.minWords} expected for this section.');
      }
      for (final RubricItem r in sec.rubric) {
        max += r.weight;
        if (r.met(t)) {
          got += r.weight;
          fb.add('✓ ${sec.heading}: ${r.label}');
        } else {
          fb.add('✗ ${sec.heading}: ${r.label}${r.advice.isEmpty ? '' : ' — ${r.advice}'}');
        }
      }
    }
    final String all = text.values.join('\n');
    if (s.allowedCitations.isNotEmpty) {
      final List<String> bad = unverifiedCitations(all, s.allowedCitations);
      if (bad.isNotEmpty) {
        fail = true;
        fb.insert(0, 'Unverified authority cited: ${bad.join('; ')}. Cite only cases in your research file — citing authority you have not verified is a serious professional error.');
      }
    }
    for (final RubricItem f in s.forbidden) {
      if (f.met(all)) {
        fail = true;
        fb.insert(0, 'Not acceptable: ${f.label}.${f.advice.isEmpty ? '' : ' ${f.advice}'}');
      }
    }
    return gradeResult(s, max == 0 ? 0 : got / max, fb, breakdown: <String, int>{'points': got, 'max': max}, forceFail: fail);
  }
}

// ------------------------------------------------------------ dialogue

enum DialogueValue { essential, useful, neutral, poor, unsafe }

class DialogueOption {
  const DialogueOption(this.id, this.say, this.reply, {this.value = DialogueValue.neutral, this.note = ''});
  final String id;

  /// What the student says or does.
  final String say;

  /// How the other person responds.
  final String reply;
  final DialogueValue value;

  /// Explanation shown after submitting.
  final String note;
}

class DialogueStep extends LabStep {
  const DialogueStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.person,
    required this.opening,
    required this.options,
    required this.conclusions,
    this.maxTurns = 8,
    super.skills,
    super.passMark = 70,
  });

  /// e.g. "Mrs Patel, client".
  final String person;
  final String opening;
  final List<DialogueOption> options;
  final int maxTurns;

  /// Questions answered after the conversation (diagnosis, advice, decision).
  final List<MathQuestion> conclusions;

  List<String> get essentialIds => <String>[for (final DialogueOption o in options) if (o.value == DialogueValue.essential) o.id];

  @override
  String get kind => 'Conversation';
}

abstract final class DialogueGrader {
  static TaskResult grade(DialogueStep s, List<String> asked, Map<String, String> conclusions) {
    if (asked.isEmpty) throw LabGradingException('Talk to ${s.person} first.');
    final Map<String, DialogueOption> byId = <String, DialogueOption>{for (final DialogueOption o in s.options) o.id: o};
    final List<String> fb = <String>[];
    final List<DialogueOption> missed = <DialogueOption>[for (final String id in s.essentialIds) if (!asked.contains(id)) byId[id]!];
    final List<DialogueOption> chosen = <DialogueOption>[for (final String id in asked) if (byId[id] != null) byId[id]!];
    final int essentials = s.essentialIds.length;
    final double gather = essentials == 0 ? 1 : (essentials - missed.length) / essentials;
    final int poor = chosen.where((DialogueOption o) => o.value == DialogueValue.poor).length;
    final bool unsafe = chosen.any((DialogueOption o) => o.value == DialogueValue.unsafe);
    for (final DialogueOption o in missed) {
      fb.add('✗ Not asked/done: "${o.say}"${o.note.isEmpty ? '' : ' — ${o.note}'}');
    }
    for (final DialogueOption o in chosen.where((DialogueOption o) => o.value == DialogueValue.poor || o.value == DialogueValue.unsafe)) {
      fb.add('${o.value == DialogueValue.unsafe ? '✗ Unacceptable' : '✗ Unhelpful'}: "${o.say}"${o.note.isEmpty ? '' : ' — ${o.note}'}');
    }
    if (missed.isEmpty) fb.add('✓ You covered everything essential.');
    double concl = 1;
    if (s.conclusions.isNotEmpty) {
      final TaskResult r = NumericGrader.grade(NumericStep(id: s.id, title: s.title, instructions: '', questions: s.conclusions), conclusions);
      concl = (r.breakdown['correct'] ?? 0) / s.conclusions.length;
      fb.addAll(r.feedback);
    }
    final double fraction = math.max(0, 0.55 * gather + 0.45 * concl - 0.1 * poor);
    if (unsafe) fb.insert(0, 'An unacceptable action was taken during the conversation, so the task cannot pass.');
    return gradeResult(s, fraction, fb, breakdown: <String, int>{'essentialAsked': essentials - missed.length, 'essential': essentials, 'turns': asked.length}, forceFail: unsafe);
  }
}

// ------------------------------------------------------------ simulation

class SimInput {
  const SimInput(this.name, this.label, this.min, this.max, {this.step = 1, this.initial, this.unit = ''});

  /// Variable name used in the formulas (a single letter, or a capital and digits).
  final String name;
  final String label;
  final double min;
  final double max;
  final double step;
  final double? initial;
  final String unit;
}

class SimOutput {
  const SimOutput(this.name, this.label, this.formula, {this.unit = '', this.decimals = 2});
  final String name;
  final String label;

  /// Expression in input names and earlier outputs' names.
  final String formula;
  final String unit;
  final int decimals;
}

class SimConstraint {
  const SimConstraint(this.output, this.op, this.value, this.label);
  final String output;

  /// '<=', '>=', '<', '>', '=' (within 1%).
  final String op;
  final double value;
  final String label;

  bool met(double v) => switch (op) {
        '<=' => v <= value + 1e-9 * math.max(1, value.abs()),
        '>=' => v >= value - 1e-9 * math.max(1, value.abs()),
        '<' => v < value,
        '>' => v > value,
        _ => (v - value).abs() <= 0.01 * math.max(1, value.abs()),
      };
}

class SimulationStep extends LabStep {
  const SimulationStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.inputs,
    required this.outputs,
    required this.constraints,
    this.questions = const <MathQuestion>[],
    this.plot,
    this.model = const <String, double>{},
    super.skills,
    super.passMark = 75,
  });
  final List<SimInput> inputs;
  final List<SimOutput> outputs;
  final List<SimConstraint> constraints;
  final List<MathQuestion> questions;

  /// (output name, input name): draw that output against that input.
  final (String, String)? plot;

  /// Input values of a model answer.
  final Map<String, double> model;

  @override
  String get kind => 'Simulation';

  /// Evaluates every output for [values]; NaN where undefined.
  static final Map<String, Expr> _parsed = <String, Expr>{};

  Map<String, double> evaluate(Map<String, double> values) {
    final Map<String, double> env = Map<String, double>.of(values);
    for (final SimOutput o in outputs) {
      double v;
      try {
        v = (_parsed[o.formula] ??= parseExpr(o.formula)).eval(env);
      } on ExprParseException {
        v = double.nan;
      }
      env[o.name] = v;
    }
    return env;
  }

  Map<String, double> get initialValues => <String, double>{for (final SimInput i in inputs) i.name: i.initial ?? i.min};
}

abstract final class SimulationGrader {
  static TaskResult grade(SimulationStep s, Map<String, double> values, Map<String, String> answers) {
    final Map<String, double> env = s.evaluate(values);
    int ok = 0, total = 0;
    final List<String> fb = <String>[
      'Your settings: ${s.inputs.map((SimInput i) => '${i.label} = ${fmtNum(values[i.name] ?? double.nan)}${i.unit.isEmpty ? '' : ' ${i.unit}'}').join(', ')}.',
    ];
    for (final SimConstraint c in s.constraints) {
      total++;
      final double v = env[c.output] ?? double.nan;
      final SimOutput? o = s.outputs.where((SimOutput o) => o.name == c.output).firstOrNull;
      final String shown = v.isFinite ? fmtNum(double.parse(v.toStringAsFixed(o?.decimals ?? 2))) : 'undefined';
      if (v.isFinite && c.met(v)) {
        ok++;
        fb.add('✓ ${c.label} (${o?.label ?? c.output} = $shown${o?.unit.isEmpty ?? true ? '' : ' ${o!.unit}'})');
      } else {
        fb.add('✗ ${c.label} — ${o?.label ?? c.output} is $shown${o?.unit.isEmpty ?? true ? '' : ' ${o!.unit}'}.');
      }
    }
    if (s.questions.isNotEmpty) {
      final TaskResult r = NumericGrader.grade(NumericStep(id: s.id, title: s.title, instructions: '', questions: s.questions), answers);
      ok += r.breakdown['correct'] ?? 0;
      total += s.questions.length;
      fb.addAll(r.feedback);
    }
    return gradeResult(s, total == 0 ? 0 : ok / total, fb, breakdown: <String, int>{'met': ok, 'items': total});
  }
}
