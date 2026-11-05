import 'dart:math' as math;

import 'package:ai_study_buddy/career_sim/labs/math/expr.dart';
import 'package:ai_study_buddy/career_sim/labs/math/math_steps.dart';
import 'package:ai_study_buddy/career_sim/labs/math/numerics.dart';
import 'package:ai_study_buddy/career_sim/model/career_models.dart';
import 'package:flutter_test/flutter_test.dart';

double ev(String s, [Map<String, double> env = const <String, double>{}]) => parseExpr(s).eval(env);

WorkingStep solveStep(String start, {List<double> extraneous = const <double>[], FinalForm form = FinalForm.solved, (double, double) range = (-50, 50)}) =>
    WorkingStep(id: 't', title: 't', instructions: '', given: start, mode: WorkingMode.solve, start: start, extraneous: extraneous, finalForm: form, minLines: 1, range: range);

void main() {
  group('parser', () {
    test('precedence, implicit multiplication and functions', () {
      expect(ev('2x^2 - 3(x+1)', <String, double>{'x': 2}), 2);
      expect(ev('-3^2'), -9);
      expect(ev('2^-1'), 0.5);
      expect(ev('(x+1)(x-1)', <String, double>{'x': 3}), 8);
      expect(ev('sqrt(16) + √(9)'), 7);
      expect(ev('sin(pi/2) + cos 0'), closeTo(2, 1e-12));
      expect(ev('ln(e^2)'), closeTo(2, 1e-12));
      expect(ev('log(1000)'), closeTo(3, 1e-12));
      expect(ev('|3 - 7|'), 4);
      expect(ev('5!'), 120);
      expect(ev('2πr', <String, double>{'r': 1}), closeTo(2 * math.pi, 1e-12));
      expect(ev('3xy', <String, double>{'x': 2, 'y': 5}), 30);
      expect(ev('C1 e^(2x) + C2', <String, double>{'x': 0, 'C1': 3, 'C2': 4}), 7);
      expect(ev('(-8)^(1/3)'), closeTo(-2, 1e-12));
      expect(ev('2 × 3 ÷ 4 − 1'), 0.5);
    });

    test('errors are reported, not thrown as crashes', () {
      expect(() => parseExpr('2 +'), throwsA(isA<ExprParseException>()));
      expect(() => parseExpr('(x + 1'), throwsA(isA<ExprParseException>()));
      expect(() => parseExpr('x # 2'), throwsA(isA<ExprParseException>()));
      expect(parseNumeric('1/3'), closeTo(1 / 3, 1e-15));
      expect(parseNumeric('x + 1'), isNull);
    });

    test('relations, chains, "or" and ±', () {
      final Relation r = parseRelation('-2 < x <= 5');
      expect(r.ops, <RelOp>[RelOp.lt, RelOp.le]);
      expect(r.holds(<String, double>{'x': 5}), isTrue);
      expect(r.holds(<String, double>{'x': -2}), isFalse);
      final Statement s = parseStatement('x = 2 or x = -3');
      expect(s.alternatives.length, 2);
      final Statement bare = parseStatement('x = 2, -3', defaultVariable: 'x');
      expect(bare.holds(<String, double>{'x': -3}), isTrue);
      final Statement pm = parseStatement('x = (5 ± 1)/2');
      expect(pm.holds(<String, double>{'x': 3}), isTrue);
      expect(pm.holds(<String, double>{'x': 2}), isTrue);
      expect(pm.holds(<String, double>{'x': 2.5}), isFalse);
    });

    test('equivalence by sampling', () {
      expect(equivalent(parseExpr('(x+2)(x+3)'), parseExpr('x^2 + 5x + 6')), isTrue);
      expect(equivalent(parseExpr('(x+2)(x+3)'), parseExpr('x^2 + 6x + 6')), isFalse);
      expect(equivalent(parseExpr('sin(2x)'), parseExpr('2sin(x)cos(x)')), isTrue);
      expect(equivalent(parseExpr('(x^2-1)/(x-1)'), parseExpr('x+1')), isTrue);
    });

    test('roots, including double roots and poles', () {
      expect(roots(parseExpr('x^2 - 5x + 6'), 'x', -50, 50), <double>[2, 3]);
      expect(roots(parseExpr('(x-2)^2'), 'x', -50, 50), <double>[2]);
      expect(roots(parseExpr('1/(x-1)'), 'x', -50, 50), isEmpty);
      expect(roots(parseExpr('x - x'), 'x', -50, 50), isNull);
      expect(roots(parseExpr('x^2 + 1'), 'x', -50, 50), isEmpty);
    });
  });

  group('working checker', () {
    test('a correct solution scores 100', () {
      final TaskResult r = WorkingChecker.grade(solveStep('3(x - 2) = 2x + 5'), <String>['3x - 6 = 2x + 5', 'x - 6 = 5', 'x = 11']);
      expect(r.score, 100, reason: r.feedback.join('\n'));
      expect(r.passed, isTrue);
    });

    test('the first wrong line is identified', () {
      final TaskResult r = WorkingChecker.grade(solveStep('3(x - 2) = 2x + 5'), <String>['3x - 2 = 2x + 5', 'x = 7']);
      expect(r.passed, isFalse);
      expect(r.breakdown['firstError'], 1);
      expect(r.feedback.first, contains('line 1'));
    });

    test('right answer with a broken step is flagged', () {
      final TaskResult r = WorkingChecker.grade(solveStep('2x + 4 = 10'), <String>['2x = 14', 'x = 3']);
      expect(r.breakdown['firstError'], 1);
      expect(r.passed, isFalse);
    });

    test('dividing by x loses a root', () {
      final TaskResult r = WorkingChecker.grade(solveStep('x^2 = 3x'), <String>['x = 3']);
      expect(r.passed, isFalse);
      expect(r.feedback.join(' '), contains('loses the solution x = 0'));
      final TaskResult ok = WorkingChecker.grade(solveStep('x^2 = 3x'), <String>['x^2 - 3x = 0', 'x(x - 3) = 0', 'x = 0 or x = 3']);
      expect(ok.score, 100, reason: ok.feedback.join('\n'));
    });

    test('quadratic formula with ±', () {
      final TaskResult r = WorkingChecker.grade(solveStep('x^2 - 4x + 1 = 0'), <String>['x = (4 ± sqrt(16 - 4))/2', 'x = 2 ± sqrt(3)']);
      expect(r.score, 100, reason: r.feedback.join('\n'));
    });

    test('extraneous roots must be rejected at the end', () {
      final WorkingStep s = solveStep('sqrt(x + 3) = x - 3', extraneous: <double>[1]);
      final TaskResult good = WorkingChecker.grade(s, <String>['x + 3 = (x - 3)^2', 'x^2 - 7x + 6 = 0', '(x - 1)(x - 6) = 0', 'x = 6']);
      expect(good.score, 100, reason: good.feedback.join('\n'));
      final TaskResult bad = WorkingChecker.grade(s, <String>['x + 3 = (x - 3)^2', 'x^2 - 7x + 6 = 0', 'x = 1 or x = 6']);
      expect(bad.passed, isFalse);
      expect(bad.feedback.join(' '), contains('x = 1'));
    });

    test('inequality: forgetting to flip the sign is caught', () {
      final WorkingStep s = solveStep('5 - 2x > 11');
      final TaskResult good = WorkingChecker.grade(s, <String>['-2x > 6', 'x < -3']);
      expect(good.score, 100, reason: good.feedback.join('\n'));
      final TaskResult bad = WorkingChecker.grade(s, <String>['-2x > 6', 'x > -3']);
      expect(bad.breakdown['firstError'], 2);
      expect(bad.feedback.join(' '), contains('reverses'));
      final TaskResult chain = WorkingChecker.grade(solveStep('-3 < 2x + 1 <= 7'), <String>['-4 < 2x <= 6', '-2 < x <= 3']);
      expect(chain.score, 100, reason: chain.feedback.join('\n'));
    });

    test('simplify, antiderivative and evaluate modes', () {
      const WorkingStep expand = WorkingStep(id: 'e', title: 'e', instructions: '', given: '', mode: WorkingMode.simplify, start: '(2x - 1)(x + 4)', finalForm: FinalForm.expanded, minLines: 1);
      expect(WorkingChecker.grade(expand, <String>['2x^2 + 8x - x - 4', '2x^2 + 7x - 4']).score, 100);
      expect(WorkingChecker.grade(expand, <String>['2x^2 + 8x - x - 4', '2x^2 + 7x + 4']).passed, isFalse);
      const WorkingStep anti = WorkingStep(id: 'a', title: 'a', instructions: '', given: '', mode: WorkingMode.antiderivative, start: 'x e^x', range: (-2, 2), minLines: 1);
      expect(WorkingChecker.grade(anti, <String>['∫ x e^x dx = x e^x - ∫ e^x dx', 'x e^x - e^x + C']).score, 100);
      expect(WorkingChecker.grade(anti, <String>['x e^x + e^x + C', 'x e^x + e^x + C']).passed, isFalse);
      const WorkingStep evalStep = WorkingStep(id: 'v', title: 'v', instructions: '', given: '', mode: WorkingMode.evaluate, start: '8/3', minLines: 1, finalForm: FinalForm.number);
      expect(WorkingChecker.grade(evalStep, <String>['2^3/3 - 0', '8/3']).score, 100);
    });

    test('systems hold at the solution', () {
      const WorkingStep sys = WorkingStep(
          id: 's', title: 's', instructions: '', given: '', mode: WorkingMode.system, start: '2x + y = 7; x - y = -1', solution: <String, double>{'x': 2, 'y': 3}, finalForm: FinalForm.solved, minLines: 1);
      expect(WorkingChecker.grade(sys, <String>['3x = 6', 'x = 2', 'y = 3', 'x = 2, y = 3']).score, 100);
      expect(WorkingChecker.grade(sys, <String>['3x = 8', 'x = 2, y = 3']).breakdown['firstError'], 1);
    });

    test('working is required', () {
      final WorkingStep s = WorkingStep(id: 't', title: 't', instructions: '', given: '', mode: WorkingMode.solve, start: '2x = 8', finalForm: FinalForm.solved);
      final TaskResult r = WorkingChecker.grade(s, <String>['x = 4']);
      expect(r.passed, isFalse);
      expect(r.feedback.join(' '), contains('Show at least'));
    });
  });

  group('other graders', () {
    test('ODE solutions are checked by substitution', () {
      const OdeStep ivp = OdeStep(id: 'o', title: 'o', instructions: '', equation: "dy/dx = 0.3y", rhs: '0.3y', initial: <double>[0, 50], range: (0, 5));
      expect(OdeGrader.grade(ivp, 'y = 50e^(0.3x)').score, 100);
      expect(OdeGrader.grade(ivp, 'y = 50e^(3x)').passed, isFalse);
      expect(OdeGrader.grade(ivp, 'y = 20e^(0.3x)').score, 60);
      const OdeStep gen2 = OdeStep(id: 'g', title: 'g', instructions: '', equation: "y'' - 3y' + 2y = 0", rhs: '3yp - 2y', order: 2, range: (-1, 1));
      expect(OdeGrader.grade(gen2, 'C1 e^x + C2 e^(2x)').score, 100);
      expect(OdeGrader.grade(gen2, 'C1 e^x').score, lessThan(100));
      const OdeStep shm = OdeStep(id: 'h', title: 'h', instructions: '', equation: "y'' + 9y = 0", rhs: '-9y', order: 2, initial: <double>[0, 2, 3], range: (0, 2));
      expect(OdeGrader.grade(shm, '2cos(3x) + sin(3x)').score, 100);
    });

    test('numbers, choices and matrices', () {
      const NumericStep n = NumericStep(id: 'n', title: 'n', instructions: '', questions: <MathQuestion>[
        NumberQuestion('a', 'Mean', 4.5, tolerance: 0.01),
        ChoiceQuestion('b', 'Decision', <String>['Reject', 'Do not reject'], 0),
      ]);
      expect(NumericGrader.grade(n, <String, String>{'a': '9/2', 'b': '0'}).score, 100);
      expect(NumericGrader.grade(n, <String, String>{'a': '4.4', 'b': '0'}).score, 50);
      final MatrixStep m = MatrixStep(id: 'm', title: 'm', instructions: '', given: const <String, List<List<double>>>{}, answer: Mat.inverse(<List<double>>[<double>[4, 7], <double>[2, 6]]));
      expect(MatrixGrader.grade(m, <List<String>>[<String>['0.6', '-0.7'], <String>['-0.2', '0.4']]).score, 100);
      expect(MatrixGrader.grade(m, <List<String>>[<String>['3/5', '-7/10'], <String>['-1/5', '2/5']]).score, 100);
    });
  });

  group('reference calculations', () {
    test('statistics match textbook values', () {
      final List<double> xs = <double>[2, 4, 4, 4, 5, 5, 7, 9];
      expect(Stats.mean(xs), 5);
      expect(Stats.populationVariance(xs), 4);
      expect(Stats.median(xs), 4.5);
      expect(Stats.modes(xs), <double>[4]);
      expect(Stats.quartiles(<double>[1, 2, 3, 4, 5, 6, 7, 8, 9]), (2.5, 7.5));
      expect(Stats.normalCdf(1.96), closeTo(0.975, 1e-4));
      expect(Stats.normalCdf(-1), closeTo(0.1587, 1e-4));
      expect(Stats.binomialPmf(10, 3, 0.5), closeTo(0.1171875, 1e-12));
      expect(Stats.correlation(<double>[1, 2, 3], <double>[2, 4, 6]), closeTo(1, 1e-12));
    });

    test('matrices', () {
      expect(Mat.det(<List<double>>[<double>[2, 0, 1], <double>[1, 3, 2], <double>[1, 1, 2]]), closeTo(6, 1e-12));
      expect(Mat.mul(<List<double>>[<double>[1, 2], <double>[3, 4]], <List<double>>[<double>[5, 6], <double>[7, 8]]), <List<double>>[<double>[19, 22], <double>[43, 50]]);
      expect(Mat.eigen2(<List<double>>[<double>[4, 1], <double>[2, 3]]), <double>[2, 5]);
      expect(Mat.rank(<List<double>>[<double>[1, 2, 3], <double>[2, 4, 6], <double>[1, 0, 1]]), 2);
    });

    test('calculus and finance helpers', () {
      expect(simpson((double x) => x * x, 0, 3), closeTo(9, 1e-9));
      expect(euler((double x, double y) => y, 0, 1, 0.1, 2), closeTo(1.21, 1e-12));
      expect(compound(1000, 0.05, 1, 2), closeTo(1102.5, 1e-9));
      expect(loanPayment(10000, 0.01, 12), closeTo(888.49, 0.01));
    });
  });
}
