/// Generic, gradable workplace tasks shared by all professions.
///
/// A [WorkScenario] is a short piece of real work (fix a bug, treat a patient,
/// reconcile an account) made of one or more [WorkStage]s. Every stage is
/// graded deterministically so results are fair and testable; free-text stages
/// can optionally be upgraded by an AI judge.
library;

enum StageKind { choice, multi, order, numeric, text, inspect }

/// How useful an inspected item is.
enum InspectValue { essential, neutral, wasteful }

class InspectItem {
  const InspectItem({
    required this.id,
    required this.label,
    required this.reveal,
    this.value = InspectValue.neutral,
    this.minutes = 5,
    this.cost = 0,
  });

  final String id;
  final String label;

  /// What the player learns by doing this (a patient answer, a test result…).
  final String reveal;
  final InspectValue value;
  final int minutes;

  /// Money the action costs the employer (shown for tests; informational).
  final double cost;
}

class RubricItem {
  const RubricItem(this.label, this.anyOf, [this.points = 1]);

  /// What a good answer includes, shown as feedback when missing.
  final String label;

  /// Any of these (lowercase substrings) satisfies the item.
  final List<String> anyOf;
  final double points;
}

class WorkStage {
  const WorkStage({
    required this.id,
    required this.kind,
    required this.prompt,
    this.options = const <String>[],
    this.correct = const <int>[],
    this.explanation = '',
    this.optionNotes = const <int, String>{},
    this.answer,
    this.tolerance = 0,
    this.unit = '',
    this.items = const <InspectItem>[],
    this.rubric = const <RubricItem>[],
    this.modelAnswer = '',
    this.code,
    this.table,
    this.hint,
    this.speaker,
    this.weight = 1,
    this.minWords = 8,
  });

  /// Single-answer multiple choice. [correct] holds one index.
  factory WorkStage.choice({
    required String id,
    required String prompt,
    required List<String> options,
    required int correct,
    required String explanation,
    Map<int, String> notes = const <int, String>{},
    String? code,
    List<List<String>>? table,
    String? hint,
    String? speaker,
    double weight = 1,
  }) =>
      WorkStage(
        id: id,
        kind: StageKind.choice,
        prompt: prompt,
        options: options,
        correct: <int>[correct],
        explanation: explanation,
        optionNotes: notes,
        code: code,
        table: table,
        hint: hint,
        speaker: speaker,
        weight: weight,
      );

  /// "Select all that apply".
  factory WorkStage.multi({
    required String id,
    required String prompt,
    required List<String> options,
    required List<int> correct,
    required String explanation,
    Map<int, String> notes = const <int, String>{},
    String? code,
    List<List<String>>? table,
    String? hint,
    String? speaker,
    double weight = 1,
  }) =>
      WorkStage(
        id: id,
        kind: StageKind.multi,
        prompt: prompt,
        options: options,
        correct: correct,
        explanation: explanation,
        optionNotes: notes,
        code: code,
        table: table,
        hint: hint,
        speaker: speaker,
        weight: weight,
      );

  /// Put [options] in the right order; [correct] lists option indexes in order.
  factory WorkStage.order({
    required String id,
    required String prompt,
    required List<String> options,
    required List<int> correct,
    required String explanation,
    String? hint,
    String? speaker,
    double weight = 1,
  }) =>
      WorkStage(
        id: id,
        kind: StageKind.order,
        prompt: prompt,
        options: options,
        correct: correct,
        explanation: explanation,
        hint: hint,
        speaker: speaker,
        weight: weight,
      );

  factory WorkStage.numeric({
    required String id,
    required String prompt,
    required double answer,
    required String explanation,
    double tolerance = 0.01,
    String unit = '',
    List<List<String>>? table,
    String? hint,
    String? speaker,
    double weight = 1,
  }) =>
      WorkStage(
        id: id,
        kind: StageKind.numeric,
        prompt: prompt,
        answer: answer,
        tolerance: tolerance,
        unit: unit,
        explanation: explanation,
        table: table,
        hint: hint,
        speaker: speaker,
        weight: weight,
      );

  factory WorkStage.text({
    required String id,
    required String prompt,
    required List<RubricItem> rubric,
    required String modelAnswer,
    String explanation = '',
    String? hint,
    String? speaker,
    int minWords = 8,
    double weight = 1,
  }) =>
      WorkStage(
        id: id,
        kind: StageKind.text,
        prompt: prompt,
        rubric: rubric,
        modelAnswer: modelAnswer,
        explanation: explanation,
        hint: hint,
        speaker: speaker,
        minWords: minWords,
        weight: weight,
      );

  factory WorkStage.inspect({
    required String id,
    required String prompt,
    required List<InspectItem> items,
    required String explanation,
    String? hint,
    String? speaker,
    double weight = 1,
  }) =>
      WorkStage(
        id: id,
        kind: StageKind.inspect,
        prompt: prompt,
        items: items,
        explanation: explanation,
        hint: hint,
        speaker: speaker,
        weight: weight,
      );

  final String id;
  final StageKind kind;
  final String prompt;
  final List<String> options;
  final List<int> correct;
  final String explanation;

  /// Extra feedback for a specific wrong option.
  final Map<int, String> optionNotes;
  final double? answer;
  final double tolerance;
  final String unit;
  final List<InspectItem> items;
  final List<RubricItem> rubric;
  final String modelAnswer;

  /// Monospaced snippet (source code, an order form, a ledger line…).
  final String? code;

  /// Rows of text for a small table (first row is the header).
  final List<List<String>>? table;
  final String? hint;

  /// NPC who speaks the prompt.
  final String? speaker;
  final double weight;
  final int minWords;
}

class StageAnswer {
  StageAnswer({
    this.choice,
    Set<int>? multi,
    List<int>? order,
    this.number,
    this.text = '',
    Set<String>? inspected,
  })  : multi = multi ?? <int>{},
        order = order ?? <int>[],
        inspected = inspected ?? <String>{};

  int? choice;
  Set<int> multi;
  List<int> order;
  double? number;
  String text;
  Set<String> inspected;
}

class StageResult {
  const StageResult({
    required this.score,
    required this.feedback,
    this.details = const <String>[],
  });

  /// 0..1
  final double score;
  final String feedback;
  final List<String> details;

  bool get good => score >= 0.7;
}

class WorkScenario {
  const WorkScenario({
    required this.id,
    required this.careerId,
    required this.title,
    required this.brief,
    required this.assignedBy,
    required this.stages,
    this.minRank = 0,
    this.maxRank = 6,
    this.minutes = 60,
    this.skillGain = const <String, double>{},
    this.difficulty = 1,
    this.station = '',
    this.educationalNote,
  });

  final String id;
  final String careerId;
  final String title;

  /// How the manager hands this over to you.
  final String brief;
  final String assignedBy;
  final List<WorkStage> stages;
  final int minRank;
  final int maxRank;

  /// Game minutes consumed.
  final int minutes;
  final Map<String, double> skillGain;

  /// 1..3
  final int difficulty;

  /// Interactable id (in the workplace interior) where this task is done.
  final String station;

  /// e.g. "Educational simulation — not real medical advice."
  final String? educationalNote;

  bool fitsRank(int rank) => rank >= minRank && rank <= maxRank;
}

/// Grades one stage. Pure and deterministic.
class WorkGrader {
  const WorkGrader._();

  static int wordCount(String s) =>
      s.trim().isEmpty ? 0 : s.trim().split(RegExp(r'\s+')).length;

  static StageResult grade(WorkStage s, StageAnswer a) {
    switch (s.kind) {
      case StageKind.choice:
        return _choice(s, a);
      case StageKind.multi:
        return _multi(s, a);
      case StageKind.order:
        return _order(s, a);
      case StageKind.numeric:
        return _numeric(s, a);
      case StageKind.text:
        return gradeText(s, a.text);
      case StageKind.inspect:
        return _inspect(s, a);
    }
  }

  static StageResult _choice(WorkStage s, StageAnswer a) {
    final int? c = a.choice;
    if (c == null) {
      return StageResult(score: 0, feedback: 'No option chosen. ${s.explanation}');
    }
    if (s.correct.contains(c)) {
      return StageResult(score: 1, feedback: 'Correct. ${s.explanation}');
    }
    final String note = s.optionNotes[c] ?? '';
    return StageResult(
      score: 0,
      feedback: 'Not quite. ${note.isEmpty ? '' : '$note '}'
          'Best answer: ${s.options[s.correct.first]}. ${s.explanation}',
    );
  }

  static StageResult _multi(WorkStage s, StageAnswer a) {
    final Set<int> right = s.correct.toSet();
    final Set<int> picked = a.multi;
    final int hits = picked.intersection(right).length;
    final int wrong = picked.difference(right).length;
    final int missed = right.difference(picked).length;
    final double score = right.isEmpty ? 1 : ((hits - wrong * 0.75) / right.length).clamp(0, 1).toDouble();
    final List<String> details = <String>[
      for (final int i in picked.difference(right))
        'Incorrect pick: “${s.options[i]}”. ${s.optionNotes[i] ?? ''}'.trim(),
      for (final int i in right.difference(picked)) 'Missed: “${s.options[i]}”.',
    ];
    final String head = (wrong == 0 && missed == 0)
        ? 'Perfect — you found everything.'
        : 'You got $hits of ${right.length} correct'
            '${wrong > 0 ? ' and flagged $wrong that do not apply' : ''}.';
    return StageResult(score: score, feedback: '$head ${s.explanation}', details: details);
  }

  static StageResult _order(WorkStage s, StageAnswer a) {
    final List<int> user = a.order;
    final List<int> target = s.correct;
    if (user.length != target.length) {
      return StageResult(score: 0, feedback: 'Put every step in order first. ${s.explanation}');
    }
    // Fraction of correctly ordered pairs (normalised Kendall tau).
    final Map<int, int> pos = <int, int>{for (int i = 0; i < user.length; i++) user[i]: i};
    int agree = 0;
    int total = 0;
    for (int i = 0; i < target.length; i++) {
      for (int j = i + 1; j < target.length; j++) {
        total++;
        if ((pos[target[i]] ?? 0) < (pos[target[j]] ?? 0)) agree++;
      }
    }
    final double score = total == 0 ? 1 : agree / total;
    final String correctText = target.map((int i) => s.options[i]).join(' → ');
    return StageResult(
      score: score,
      feedback: score >= 0.999
          ? 'Exactly right. ${s.explanation}'
          : 'Order matters here. Correct order: $correctText. ${s.explanation}',
    );
  }

  static StageResult _numeric(WorkStage s, StageAnswer a) {
    final double? n = a.number;
    final double ans = s.answer ?? 0;
    if (n == null) return StageResult(score: 0, feedback: 'No number entered. ${s.explanation}');
    final double diff = (n - ans).abs();
    final String shown = '${_fmt(ans)}${s.unit.isEmpty ? '' : ' ${s.unit}'}';
    if (diff <= s.tolerance + 1e-9) {
      return StageResult(score: 1, feedback: 'Correct: $shown. ${s.explanation}');
    }
    if (diff <= s.tolerance * 4 + 1e-9 && s.tolerance > 0) {
      return StageResult(score: 0.4, feedback: 'Close, but the answer is $shown. ${s.explanation}');
    }
    return StageResult(score: 0, feedback: 'Not correct — the answer is $shown. ${s.explanation}');
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  /// Rubric grading for free text (also the fallback for AI grading).
  static StageResult gradeText(WorkStage s, String text) {
    final String low = ' ${text.toLowerCase()} ';
    final int wc = wordCount(text);
    if (wc == 0) {
      return StageResult(score: 0, feedback: 'You wrote nothing. A model answer: ${s.modelAnswer}');
    }
    double got = 0;
    double total = 0;
    final List<String> missing = <String>[];
    final List<String> hit = <String>[];
    for (final RubricItem r in s.rubric) {
      total += r.points;
      if (r.anyOf.any((String k) => low.contains(k))) {
        got += r.points;
        hit.add(r.label);
      } else {
        missing.add(r.label);
      }
    }
    double score = total == 0 ? 0.5 : got / total;
    if (wc < s.minWords) score = score.clamp(0, 0.35).toDouble();
    if (RegExp(r'\b(damn|crap|shit|fuck|idiot|stupid)\b').hasMatch(low)) {
      score = (score - 0.3).clamp(0, 1).toDouble();
    }
    final String head = score >= 0.8
        ? 'Strong response.'
        : score >= 0.5
            ? 'Decent, but incomplete.'
            : 'This needs more substance.';
    return StageResult(
      score: score,
      feedback: '$head ${missing.isEmpty ? '' : 'Missing: ${missing.join('; ')}. '}'
          '${wc < s.minWords ? 'Write at least ${s.minWords} words. ' : ''}'
          'Model answer: ${s.modelAnswer}',
      details: <String>[for (final String h in hit) '✓ $h', for (final String m in missing) '✗ $m'],
    );
  }

  static StageResult _inspect(WorkStage s, StageAnswer a) {
    final List<InspectItem> essential =
        s.items.where((InspectItem i) => i.value == InspectValue.essential).toList();
    final List<InspectItem> wasteful =
        s.items.where((InspectItem i) => i.value == InspectValue.wasteful).toList();
    final int got = essential.where((InspectItem i) => a.inspected.contains(i.id)).length;
    final int waste = wasteful.where((InspectItem i) => a.inspected.contains(i.id)).length;
    final double base = essential.isEmpty ? 1 : got / essential.length;
    final double score = (base - waste * 0.2).clamp(0, 1).toDouble();
    final List<String> details = <String>[
      for (final InspectItem i in essential)
        if (!a.inspected.contains(i.id)) 'Missed: ${i.label}',
      for (final InspectItem i in wasteful)
        if (a.inspected.contains(i.id)) 'Unnecessary: ${i.label}',
    ];
    return StageResult(
      score: score,
      feedback: (got == essential.length && waste == 0)
          ? 'Thorough and efficient. ${s.explanation}'
          : 'You covered $got of ${essential.length} essentials'
              '${waste > 0 ? ' and did $waste unnecessary thing(s)' : ''}. ${s.explanation}',
      details: details,
    );
  }
}

/// Optional upgrade point: an AI grader for free-text stages.
abstract class WorkTextJudge {
  Future<StageResult> gradeText({
    required WorkScenario scenario,
    required WorkStage stage,
    required String text,
  });
}

/// A scenario being played: tracks stage progress and the combined score.
class ScenarioRun {
  ScenarioRun(this.scenario, {WorkTextJudge? judge}) : _judge = judge;

  final WorkScenario scenario;
  final WorkTextJudge? _judge;
  final List<StageResult> results = <StageResult>[];
  int index = 0;

  bool get finished => index >= scenario.stages.length;
  WorkStage? get stage => finished ? null : scenario.stages[index];

  /// Grades the current stage and advances.
  Future<StageResult> submit(StageAnswer answer) async {
    final WorkStage s = scenario.stages[index];
    StageResult r;
    if (s.kind == StageKind.text && _judge != null) {
      try {
        r = await _judge.gradeText(scenario: scenario, stage: s, text: answer.text);
      } catch (_) {
        r = WorkGrader.gradeText(s, answer.text);
      }
    } else {
      r = WorkGrader.grade(s, answer);
    }
    results.add(r);
    index++;
    return r;
  }

  /// Weighted 0..1 score.
  double get score {
    double sum = 0;
    double w = 0;
    for (int i = 0; i < results.length; i++) {
      final double weight = scenario.stages[i].weight;
      sum += results[i].score * weight;
      w += weight;
    }
    return w == 0 ? 0 : sum / w;
  }

  String get ratingLabel {
    final double s = score;
    if (s >= 0.9) return 'Outstanding';
    if (s >= 0.75) return 'Good work';
    if (s >= 0.55) return 'Acceptable';
    if (s >= 0.35) return 'Needs improvement';
    return 'Poor';
  }
}

/// Builds a fresh, numerically different scenario from a seed (accounting,
/// business KPIs…). Keeps long careers from repeating the same exercise.
class ScenarioGenerator {
  const ScenarioGenerator({
    required this.id,
    required this.careerId,
    required this.build,
    this.minRank = 0,
    this.maxRank = 6,
  });

  final String id;
  final String careerId;
  final int minRank;
  final int maxRank;
  final WorkScenario Function(int seed) build;

  bool fitsRank(int rank) => rank >= minRank && rank <= maxRank;
}
