/// Builders for formula-driven labs (engineering, sciences, economics,
/// finance, operations). A [DesignProblem] is a real model — inputs, output
/// formulas and a worked case. Each problem is set at three levels with
/// progressively tighter specifications, so a lab of five problems gives
/// fifteen scenarios. Every answer is computed from the formulas.
library;

import '../lab_models.dart';
import '../math/math_steps.dart';
import '../work/work_steps.dart';

class DesignProblem {
  const DesignProblem({
    required this.key,
    required this.title,
    required this.brief,
    required this.inputs,
    required this.outputs,
    required this.given,
    required this.ask,
    required this.levels,
    required this.models,
    this.formulas = const <String>[],
    this.interpret,
  });

  final String key;
  final String title;

  /// The client/job description.
  final String brief;
  final List<SimInput> inputs;
  final List<SimOutput> outputs;

  /// Input values for the hand calculation.
  final Map<String, double> given;

  /// Output names the hand calculation asks for.
  final List<String> ask;

  /// Specifications for beginner, intermediate and advanced.
  final List<List<SimConstraint>> levels;

  /// A compliant design for each level (checked by tests).
  final List<Map<String, double>> models;

  /// Formula sheet shown in the briefing.
  final List<String> formulas;

  /// An interpretation question added at the advanced level.
  final ChoiceQuestion? interpret;
}

/// One fault investigation (failure analysis, troubleshooting, diagnosis).
class Investigation {
  const Investigation({
    required this.key,
    required this.title,
    required this.brief,
    required this.evidence,
    required this.cause,
    required this.wrongCauses,
    required this.fix,
    required this.wrongFixes,
    this.calc,
    this.steps = const <String>[],
    this.mustPrecede = const <(int, int)>[],
  });
  final String key;
  final String title;
  final String brief;

  /// (observation, supports the true cause?)
  final List<(String, bool)> evidence;
  final String cause;
  final List<String> wrongCauses;
  final String fix;
  final List<String> wrongFixes;

  /// A supporting calculation: (prompt, answer, unit, explanation).
  final (String, double, String, String)? calc;

  /// Investigation/repair procedure in the correct order (advanced level).
  final List<String> steps;
  final List<(int, int)> mustPrecede;
}

const List<LabDifficulty> levels3 = <LabDifficulty>[LabDifficulty.foundation, LabDifficulty.intermediate, LabDifficulty.advanced];
const List<String> _levelSpec = <String>['Specification A', 'Specification B (tighter)', 'Specification C (client sign-off)'];

double _eval(DesignProblem p, String name, [Map<String, double>? at]) {
  final SimulationStep tmp = SimulationStep(id: '_', title: '', instructions: '', inputs: p.inputs, outputs: p.outputs, constraints: const <SimConstraint>[]);
  try {
    return tmp.evaluate(at ?? p.given)[name] ?? double.nan;
  } on Object {
    return double.nan;
  }
}

double _snap(SimInput i, double v) {
  final double k = ((v - i.min) / i.step).roundToDouble();
  final double s = (i.min + k * i.step).clamp(i.min, i.max).toDouble();
  return double.parse(s.toStringAsFixed(10));
}

bool _sameCase(Map<String, double> a, Map<String, double> b) => a.length == b.length && a.keys.every((String k) => (a[k]! - (b[k] ?? double.nan)).abs() < 1e-9);

bool _usableCase(DesignProblem p, Map<String, double> c) => p.ask.every((String a) {
      final double v = _eval(p, a, c);
      return v.isFinite && v.abs() > 1e-6 && v.abs() * 0.01 < 1000;
    });

/// The worked case for the hand calculation at each level. Level 1 uses the
/// problem's own case; levels 2 and 3 use different points in the design
/// space, so the student calculates afresh rather than repeating numbers.
Map<String, double> workedCase(DesignProblem p, int level) {
  if (level == 0) return p.given;
  final Map<String, double> before = workedCase(p, level - 1);
  final List<double> fractions = level == 1 ? const <double>[0.75, 0.4, 0.6] : const <double>[0.3, 0.85, 0.15];
  final List<Map<String, double>> candidates = <Map<String, double>>[
    for (final double f in fractions) <String, double>{for (final SimInput i in p.inputs) i.name: _snap(i, i.min + f * (i.max - i.min))},
    <String, double>{for (final SimInput i in p.inputs) i.name: i.initial ?? i.min},
  ];
  for (final Map<String, double> c in candidates) {
    if (!_sameCase(c, p.given) && !_sameCase(c, before) && _usableCase(p, c)) return c;
  }
  return p.given;
}

String _fmt(double v) {
  final String s = v.abs() >= 100 ? v.toStringAsFixed(1) : v.toStringAsPrecision(4);
  return s.contains('.') ? s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '') : s;
}

ChoiceQuestion pick(String id, String prompt, String correct, List<String> wrong, {String explain = ''}) {
  final List<String> opts = <String>[correct, ...wrong];
  // Rotate deterministically so the right answer is not always first.
  final int r = id.codeUnits.fold<int>(0, (int a, int c) => a + c) % opts.length;
  final List<String> rotated = <String>[...opts.sublist(r), ...opts.sublist(0, r)];
  return ChoiceQuestion(id, prompt, rotated, rotated.indexOf(correct), explain: explain);
}

/// The three scenarios of one design problem.
List<LabScenario> designScenarios(String prefix, DesignProblem p, {LabPerson? person}) => <LabScenario>[
      for (int l = 0; l < 3; l++)
        LabScenario(
          id: '${prefix}_${p.key}_${l + 1}',
          title: '${p.title} — ${_levelSpec[l]}',
          level: levels3[l],
          people: <LabPerson>[if (person != null) person],
          briefing: Briefing(
            what: '${p.brief} ${_levelSpec[l]}: ${p.levels[l].map((SimConstraint c) => c.label).join('; ')}.',
            why: 'Designs that miss their specification fail in service or cost the client money.',
            information: <String>[
              ...p.formulas,
              'Worked case for checking: ${p.inputs.map((SimInput i) => '${i.label} = ${_fmt(workedCase(p, l)[i.name]!)}${i.unit.isEmpty ? '' : ' ${i.unit}'}').join(', ')}.',
            ],
            tools: const <String>['Live design model', 'Scientific calculator and grapher', 'Whiteboard'],
            expected: 'A hand calculation that matches the model, and a design that meets every line of the specification.',
          ),
          steps: <LabStep>[
            NumericStep(
              id: '${prefix}_${p.key}_${l + 1}_calc',
              title: 'Hand calculation',
              instructions: 'Calculate for the worked case before using the model (answers within 1%).',
              questions: <MathQuestion>[
                for (final String a in p.ask)
                  NumberQuestion('c_$a', p.outputs.firstWhere((SimOutput o) => o.name == a).label, _eval(p, a, workedCase(p, l)),
                      tolerance: 0.01, relative: true, unit: p.outputs.firstWhere((SimOutput o) => o.name == a).unit),
              ],
            ),
            SimulationStep(
              id: '${prefix}_${p.key}_${l + 1}_design',
              title: 'Design to ${_levelSpec[l].toLowerCase()}',
              instructions: 'Adjust the inputs until every requirement is met. Outputs update as you move the sliders.',
              inputs: p.inputs,
              outputs: p.outputs,
              constraints: p.levels[l],
              questions: <MathQuestion>[if (l == 2 && p.interpret != null) p.interpret!],
              plot: (p.ask.first, p.inputs.first.name),
              model: p.models[l],
            ),
          ],
        ),
    ];

/// The three scenarios of one investigation: identify the cause; then also
/// calculate; then also order the corrective procedure and choose the fix.
List<LabScenario> investigationScenarios(String prefix, Investigation v, {LabPerson? person, String queue = 'Evidence log'}) => <LabScenario>[
      for (int l = 0; l < 3; l++)
        LabScenario(
          id: '${prefix}_${v.key}_${l + 1}',
          title: '${v.title}${<String>['', ' — with calculation', ' — full investigation'][l]}',
          level: levels3[l],
          people: <LabPerson>[if (person != null) person],
          briefing: Briefing(
            what: '${v.brief}${<String>['', ' The evidence has been logged; quantify it and confirm the cause.', ' The cause is being confirmed; decide the correction and plan the work.'][l]}',
            why: 'Finding the real cause prevents the next failure.',
            information: <String>[
              'Treat every observation as evidence: does it support or contradict each explanation?',
              if (l > 0) ...<String>['Evidence log:', for (int k = 0; k < v.evidence.length; k++) 'Observation ${k + 1}: ${v.evidence[k].$1}'],
            ],
            tools: const <String>['Evidence log', 'Calculator', 'Whiteboard'],
            expected: 'A cause supported by the evidence${l > 0 ? ', a calculation that confirms it' : ''}${l > 1 ? ', and a safe corrective procedure' : ''}.',
          ),
          steps: <LabStep>[
            // Level 1 reviews the evidence; later levels build on it instead of repeating it
            // (unless there is no calculation to do at level 2).
            if (l == 0 || (l == 1 && v.calc == null))
            TriageStep(
              id: '${prefix}_${v.key}_${l + 1}_ev',
              title: 'Review the evidence',
              instructions: 'Decide whether each observation supports the most likely explanation.',
              queueName: queue,
              fields: const <TriageField>[TriageField('sup', 'Supports the likely cause?', <String>['Supports', 'Does not support'])],
              items: <TriageItem>[
                for (int k = 0; k < v.evidence.length; k++)
                  TriageItem(id: 'e$k', title: 'Observation ${k + 1}', body: v.evidence[k].$1, answers: <String, String>{'sup': v.evidence[k].$2 ? 'Supports' : 'Does not support'}),
              ],
            ),
            NumericStep(
              id: '${prefix}_${v.key}_${l + 1}_cause',
              title: <String>['Identify the cause', 'Confirm the cause', 'Choose the correction'][l],
              instructions: 'Use the evidence${l > 0 && v.calc != null ? ' and your calculation' : ''}.',
              questions: <MathQuestion>[
                if (l == 1 && v.calc != null) NumberQuestion('calc', v.calc!.$1, v.calc!.$2, tolerance: 0.02, relative: true, unit: v.calc!.$3, explain: v.calc!.$4),
                if (l < 2) pick('cause_${v.key}', 'Most likely cause', v.cause, v.wrongCauses),
                if (l == 2 || (l == 1 && v.calc == null)) pick('fix_${v.key}', 'Recommended correction', v.fix, v.wrongFixes),
              ],
            ),
            if (l == 2 && v.steps.isNotEmpty)
              SequenceStep(
                id: '${prefix}_${v.key}_${l + 1}_proc',
                title: 'Plan the corrective procedure',
                instructions: 'Put the steps in a safe, logical order.',
                correctOrder: v.steps,
                mustPrecede: v.mustPrecede,
              ),
          ],
        ),
    ];

LabSpec designLab({
  required String id,
  required String deptId,
  required String majorId,
  required int number,
  required String title,
  required LabEnvironment environment,
  required String summary,
  required List<String> objectives,
  required List<String> skills,
  required List<LabScenario> scenarios,
  List<String> reference = const <String>[],
  int minutes = 30,
  LabDifficulty difficulty = LabDifficulty.intermediate,
  bool portfolio = false,
}) =>
    LabSpec(
      id: id,
      deptId: deptId,
      majorId: majorId,
      number: number,
      title: title,
      environment: environment,
      summary: summary,
      objectives: objectives,
      skills: skills,
      difficulty: difficulty,
      minutes: minutes,
      scenarios: scenarios,
      reference: reference,
      addsToPortfolio: portfolio,
    );

/// Five design problems → fifteen scenarios ordered beginner → advanced.
List<LabScenario> fromProblems(String prefix, List<DesignProblem> ps, {LabPerson? person}) {
  final List<LabScenario> all = <LabScenario>[for (final DesignProblem p in ps) ...designScenarios(prefix, p, person: person)];
  all.sort((LabScenario a, LabScenario b) => a.level.index.compareTo(b.level.index));
  return all;
}

List<LabScenario> fromInvestigations(String prefix, List<Investigation> vs, {LabPerson? person, String queue = 'Evidence log'}) {
  final List<LabScenario> all = <LabScenario>[for (final Investigation v in vs) ...investigationScenarios(prefix, v, person: person, queue: queue)];
  all.sort((LabScenario a, LabScenario b) => a.level.index.compareTo(b.level.index));
  return all;
}

// Short constraint constructors.
SimConstraint atMost(String o, double v, String label) => SimConstraint(o, '<=', v, label);
SimConstraint atLeast(String o, double v, String label) => SimConstraint(o, '>=', v, label);

/// Specifications that tighten cumulatively: A, A + B, A + B + C.
List<List<SimConstraint>> cum(List<SimConstraint> a, List<SimConstraint> b, List<SimConstraint> c) => <List<SimConstraint>>[
      a,
      <SimConstraint>[...a, ...b],
      <SimConstraint>[...a, ...b, ...c],
    ];

/// One compliant design that satisfies all three levels.
List<Map<String, double>> same(Map<String, double> m) => <Map<String, double>>[m, m, m];

SimConstraint le(String o, double v, String label) => SimConstraint(o, '<=', v, label);
SimConstraint ge(String o, double v, String label) => SimConstraint(o, '>=', v, label);
