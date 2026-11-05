/// Builders shared by the mathematics labs, so each scenario reads as its
/// problem rather than boilerplate.
library;

import '../lab_models.dart';
import '../math/math_steps.dart';

const List<String> mathsToolsList = <String>[
  'Working editor with a maths keypad — every line is checked',
  'Scientific calculator',
  'Graphing tool',
  'Whiteboard, saved with the lab',
];

const LabPerson mathsTutor = LabPerson('Dr Amara Osei', 'Senior Lecturer in Mathematics',
    'Write one step per line. The marker checks every line, so a slip is found where it happens — not just at the end.');

const LabPerson statsLead = LabPerson('Priya Raman', 'Lead Statistician, Campus Analytics',
    'These are the numbers we actually report on. State your result, then what it means.');

const LabPerson modelLead = LabPerson('Tomás Reyes', 'Applied Mathematics Consultant',
    'Clients bring a problem in words. Turn it into mathematics, solve it, then answer their question in their terms.');

LabScenario scenario(
  String id,
  String title,
  LabDifficulty level, {
  required String what,
  required String why,
  required List<LabStep> steps,
  List<String> information = const <String>[],
  String expected = 'Each task is marked by mathematical checks. Working is marked line by line and the first incorrect step is named.',
  LabPerson person = mathsTutor,
}) =>
    LabScenario(
      id: id,
      title: title,
      level: level,
      people: <LabPerson>[person],
      briefing: Briefing(what: what, why: why, information: information, tools: mathsToolsList, expected: expected),
      steps: steps,
    );

/// Solve an equation or inequality in [variable], showing working.
WorkingStep solve(
  String id,
  String title,
  String given,
  String start, {
  String variable = 'x',
  (double, double) range = (-50, 50),
  List<double> extraneous = const <double>[],
  List<String> hints = const <String>[],
  List<String> model = const <String>[],
  int minLines = 2,
  double tolerance = 1e-6,
  List<String> skills = const <String>[],
  String? instructions,
}) =>
    WorkingStep(
      id: id,
      title: title,
      instructions: instructions ?? 'Solve, one step per line, ending with the value(s) of $variable.',
      given: given,
      mode: WorkingMode.solve,
      start: start,
      variable: variable,
      range: range,
      extraneous: extraneous,
      finalForm: FinalForm.solved,
      minLines: minLines,
      hints: hints,
      model: model,
      tolerance: tolerance,
      skills: skills,
    );

WorkingStep system(
  String id,
  String title,
  String given,
  String start,
  Map<String, double> solution, {
  List<String> hints = const <String>[],
  List<String> model = const <String>[],
  List<String> skills = const <String>[],
  String? instructions,
}) =>
    WorkingStep(
      id: id,
      title: title,
      instructions: instructions ?? 'Solve, one step per line. Finish with every value on the last line, e.g. ${solution.keys.map((String k) => '$k = …').join(', ')}.',
      given: given,
      mode: WorkingMode.system,
      start: start,
      solution: solution,
      finalForm: FinalForm.solved,
      hints: hints,
      model: model,
      skills: skills,
    );

WorkingStep rewrite(
  String id,
  String title,
  String given,
  String target, {
  FinalForm form = FinalForm.any,
  int minLines = 1,
  List<String> hints = const <String>[],
  List<String> model = const <String>[],
  List<String> skills = const <String>[],
  String? instructions,
}) =>
    WorkingStep(
      id: id,
      title: title,
      instructions: instructions ?? 'Work it out one step per line. Every line must equal the expression; the last line is your answer.',
      given: given,
      mode: WorkingMode.simplify,
      start: target,
      finalForm: form,
      minLines: minLines,
      hints: hints,
      model: model,
      skills: skills,
    );

WorkingStep integrate(
  String id,
  String title,
  String given,
  String integrand, {
  (double, double) range = (-2, 2),
  List<String> hints = const <String>[],
  List<String> model = const <String>[],
  List<String> skills = const <String>[],
}) =>
    WorkingStep(
      id: id,
      title: title,
      instructions: 'Integrate one step per line (lines with ∫ are allowed as notes). The last line is the antiderivative, including + C.',
      given: given,
      mode: WorkingMode.antiderivative,
      start: integrand,
      range: range,
      minLines: 1,
      hints: hints,
      model: model,
      skills: skills,
    );

WorkingStep evaluate(
  String id,
  String title,
  String given,
  String value, {
  double tolerance = 1e-6,
  int minLines = 2,
  List<String> hints = const <String>[],
  List<String> model = const <String>[],
  List<String> skills = const <String>[],
  String? instructions,
}) =>
    WorkingStep(
      id: id,
      title: title,
      instructions: instructions ?? 'Show the calculation one step per line. Each line must have the same value; the last line is the number.',
      given: given,
      mode: WorkingMode.evaluate,
      start: value,
      finalForm: FinalForm.number,
      minLines: minLines,
      tolerance: tolerance,
      hints: hints,
      model: model,
      skills: skills,
    );

NumberQuestion numQ(String id, String prompt, double answer, {double tol = 0.01, bool relative = false, String unit = '', String explain = ''}) =>
    NumberQuestion(id, prompt, answer, tolerance: tol, relative: relative, unit: unit, explain: explain);

ChoiceQuestion choice(String id, String prompt, List<String> options, int correct, {String explain = ''}) =>
    ChoiceQuestion(id, prompt, options, correct, explain: explain);

/// Rounds a reference answer for display in explanations.
String r4(double v) => double.parse(v.toStringAsPrecision(6)).toString();
