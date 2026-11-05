/// Mathematics labs A–C: Algebra, Calculus and Linear Algebra. Every
/// answer is checked mathematically; matrix answers are computed from the
/// scenario's own matrices.
library;

import '../lab_models.dart';
import '../math/math_steps.dart';
import '../math/numerics.dart';
import 'math_lab_kit.dart';

const LabDifficulty _b = LabDifficulty.foundation;
const LabDifficulty _i = LabDifficulty.intermediate;
const LabDifficulty _a = LabDifficulty.advanced;

// ------------------------------------------------------------ A. Algebra

final LabSpec mathAlgebraLab = LabSpec(
  id: 'ma_lab_algebra',
  deptId: 'mathematics',
  majorId: 'mathematics',
  number: 1,
  title: 'Algebra',
  environment: LabEnvironment.mathsLab,
  summary: 'Solve linear, quadratic, polynomial, rational, radical, exponential and absolute-value equations and inequalities. '
      'You enter every step; the marker checks each line keeps the same solutions and names the first one that does not.',
  objectives: const <String>[
    'Solve equations and inequalities with justified steps',
    'Recognise steps that lose or gain solutions',
    'Model word problems as equations and systems',
  ],
  skills: const <String>['ma_algebra'],
  difficulty: LabDifficulty.foundation,
  minutes: 30,
  scenarios: <LabScenario>[
    scenario('alg_b1', 'Linear equation with brackets', _b,
        what: 'Solve 3(x − 2) = 2x + 5, one step per line.',
        why: 'Expanding brackets and collecting terms is the base of every later method.',
        steps: <LabStep>[
          solve('alg_b1_1', 'Solve the equation', 'Solve 3(x − 2) = 2x + 5', '3(x - 2) = 2x + 5',
              hints: <String>['Expand the bracket first: 3(x − 2) = 3x − 6.', 'Subtract 2x from both sides.'],
              model: <String>['3x - 6 = 2x + 5', 'x - 6 = 5', 'x = 11']),
        ]),
    scenario('alg_b2', 'Equation with fractions', _b,
        what: 'Solve (x + 1)/3 − (x − 2)/4 = 1.',
        why: 'Clearing denominators correctly — multiplying every term — is where most slips happen.',
        steps: <LabStep>[
          solve('alg_b2_1', 'Clear the fractions and solve', 'Solve (x + 1)/3 − (x − 2)/4 = 1', '(x + 1)/3 - (x - 2)/4 = 1',
              hints: <String>['The lowest common multiple of 3 and 4 is 12.', 'Multiply every term, including the 1 on the right, by 12.'],
              model: <String>['4(x + 1) - 3(x - 2) = 12', '4x + 4 - 3x + 6 = 12', 'x + 10 = 12', 'x = 2']),
        ]),
    scenario('alg_b3', 'Choosing a phone plan', _b,
        what: 'Plan A costs £12 a month plus 5p a minute. Plan B costs £20 a month with unlimited minutes. Find the break-even usage.',
        why: 'Turning a description into an equation is the core modelling skill.',
        information: const <String>['Let m be the number of minutes used in a month.', 'Plan A: 12 + 0.05m pounds. Plan B: 20 pounds.'],
        steps: <LabStep>[
          solve('alg_b3_1', 'Set up and solve the break-even equation', 'When do the plans cost the same? Use m for minutes.', '12 + 0.05m = 20',
              variable: 'm', range: (0, 1000),
              instructions: 'Write the equation for equal cost as your first line, then solve for m.',
              hints: <String>['Plan A’s cost equals Plan B’s cost: 12 + 0.05m = 20.'],
              model: <String>['12 + 0.05m = 20', '0.05m = 8', 'm = 160']),
          NumericStep(id: 'alg_b3_2', title: 'Advise the customer', instructions: 'Use your model to answer.', questions: <MathQuestion>[
            numQ('a200', 'Cost of Plan A for 200 minutes', 22, unit: '£', explain: '12 + 0.05 × 200 = 22.'),
            numQ('b200', 'Cost of Plan B for 200 minutes', 20, unit: '£'),
            choice('pick', 'A customer uses about 250 minutes a month. Which plan is cheaper?', const <String>['Plan A', 'Plan B'], 1,
                explain: 'Above 160 minutes Plan A costs more than £20.'),
          ]),
        ]),
    scenario('alg_b4', 'Linear inequality', _b,
        what: 'Solve 5 − 2x > 11.',
        why: 'Dividing by a negative number reverses an inequality — the classic error this checker catches.',
        steps: <LabStep>[
          solve('alg_b4_1', 'Solve the inequality', 'Solve 5 − 2x > 11', '5 - 2x > 11', minLines: 1,
              instructions: 'One step per line. The last line should be like x < 4.',
              hints: <String>['Subtract 5 from both sides.', 'You will divide by −2: what happens to the > sign?'],
              model: <String>['-2x > 6', 'x < -3']),
        ]),
    scenario('alg_b5', 'Expand and simplify', _b,
        what: 'Expand and simplify (2x − 1)(x + 4) − x(x − 3).',
        why: 'Fluent expansion makes every later topic faster and safer.',
        steps: <LabStep>[
          rewrite('alg_b5_1', 'Expand and collect like terms', '(2x − 1)(x + 4) − x(x − 3)', 'x^2 + 10x - 4', form: FinalForm.expanded,
              hints: <String>['Expand each product separately first.', 'Careful: −x(x − 3) = −x² + 3x.'],
              model: <String>['2x^2 + 8x - x - 4 - x^2 + 3x', 'x^2 + 10x - 4']),
        ]),
    scenario('alg_i1', 'Quadratic by factorising', _i,
        what: 'Solve x² − 5x − 14 = 0 by factorising.',
        why: 'Factorising shows the structure of a quadratic and gives exact roots.',
        steps: <LabStep>[
          solve('alg_i1_1', 'Factorise and solve', 'Solve x² − 5x − 14 = 0', 'x^2 - 5x - 14 = 0',
              hints: <String>['Find two numbers that multiply to −14 and add to −5.'],
              model: <String>['(x - 7)(x + 2) = 0', 'x - 7 = 0 or x + 2 = 0', 'x = 7 or x = -2']),
        ]),
    scenario('alg_i2', 'Quadratic formula', _i,
        what: 'Solve 2x² + 3x − 4 = 0 using the quadratic formula. Give exact answers or answers to 4 decimal places.',
        why: 'Not every quadratic factorises; the formula always works.',
        steps: <LabStep>[
          solve('alg_i2_1', 'Apply the formula', 'Solve 2x² + 3x − 4 = 0', '2x^2 + 3x - 4 = 0', tolerance: 1e-4,
              hints: <String>['a = 2, b = 3, c = −4. Write that as a # comment.', 'x = (−b ± √(b² − 4ac)) / (2a).'],
              model: <String>['# a = 2, b = 3, c = -4', 'x = (-3 ± sqrt(9 + 32))/4', 'x = (-3 ± sqrt(41))/4', 'x = (-3 + sqrt(41))/4 or x = (-3 - sqrt(41))/4']),
        ]),
    scenario('alg_i3', 'Simultaneous equations by elimination', _i,
        what: 'Solve 3x + 2y = 16 and 5x − 2y = 0.',
        why: 'Elimination is the hand method behind matrix row reduction.',
        steps: <LabStep>[
          system('alg_i3_1', 'Eliminate and solve', '3x + 2y = 16\n5x − 2y = 0', '3x + 2y = 16; 5x - 2y = 0', const <String, double>{'x': 2, 'y': 5},
              hints: <String>['Adding the equations removes y.'],
              model: <String>['8x = 16', 'x = 2', '3(2) + 2y = 16', 'y = 5', 'x = 2, y = 5']),
        ]),
    scenario('alg_i4', 'Cinema ticket prices', _i,
        what: 'Two adult and three child tickets cost £39. One adult and four child tickets cost £37. Find each price.',
        why: 'Systems model any situation with two unknown rates.',
        information: const <String>['Use a for the adult price and c for the child price.'],
        steps: <LabStep>[
          system('alg_i4_1', 'Model and solve', '2a + 3c = 39\na + 4c = 37', '2a + 3c = 39; a + 4c = 37', const <String, double>{'a': 9, 'c': 7},
              hints: <String>['From the second equation, a = 37 − 4c. Substitute it into the first.'],
              model: <String>['a = 37 - 4c', '2(37 - 4c) + 3c = 39', '74 - 5c = 39', 'c = 7', 'a = 9', 'a = 9, c = 7']),
          NumericStep(id: 'alg_i4_2', title: 'Quote a family', instructions: 'Use your prices.', questions: <MathQuestion>[
            numQ('fam', 'Cost for 2 adults and 2 children', 32, unit: '£'),
          ]),
        ]),
    scenario('alg_i5', 'Quadratic inequality', _i,
        what: 'Solve x² − x − 6 ≤ 0.',
        why: 'Sign analysis of a factorised quadratic generalises to rational inequalities.',
        steps: <LabStep>[
          solve('alg_i5_1', 'Factorise and decide the interval', 'Solve x² − x − 6 ≤ 0', 'x^2 - x - 6 <= 0', minLines: 1,
              hints: <String>['Factorise: (x − 3)(x + 2).', 'The parabola opens upward, so it is ≤ 0 between its roots.'],
              model: <String>['(x - 3)(x + 2) <= 0', '-2 <= x <= 3']),
        ]),
    scenario('alg_a1', 'Cubic by the factor theorem', _a,
        what: 'Solve x³ − 6x² + 11x − 6 = 0.',
        why: 'The factor theorem reduces higher-degree polynomials to quadratics.',
        steps: <LabStep>[
          solve('alg_a1_1', 'Find a factor, divide, and solve', 'Solve x³ − 6x² + 11x − 6 = 0', 'x^3 - 6x^2 + 11x - 6 = 0',
              hints: <String>['Try x = 1: 1 − 6 + 11 − 6 = 0, so (x − 1) is a factor.', 'Divide to get a quadratic factor.'],
              model: <String>['(x - 1)(x^2 - 5x + 6) = 0', '(x - 1)(x - 2)(x - 3) = 0', 'x = 1 or x = 2 or x = 3']),
        ]),
    scenario('alg_a2', 'Rational equation with an excluded value', _a,
        what: 'Solve x/(x − 3) = 3/(x − 3) + 2. If there is no solution, write "no solution".',
        why: 'Multiplying by an expression that can be zero can create a value the original equation does not allow.',
        steps: <LabStep>[
          solve('alg_a2_1', 'Solve and check the domain', 'Solve x/(x − 3) = 3/(x − 3) + 2', 'x/(x - 3) = 3/(x - 3) + 2', extraneous: const <double>[3],
              hints: <String>['Multiply every term by (x − 3).', 'Check your answer in the original equation: is it allowed?'],
              model: <String>['x = 3 + 2(x - 3)', 'x = 2x - 3', 'x = 3', '# x = 3 makes the denominators zero, so it is rejected', 'no solution']),
        ]),
    scenario('alg_a3', 'Radical equation', _a,
        what: 'Solve √(x + 3) = x − 3.',
        why: 'Squaring both sides can introduce roots that do not satisfy the original.',
        steps: <LabStep>[
          solve('alg_a3_1', 'Square, solve and check', 'Solve √(x + 3) = x − 3', 'sqrt(x + 3) = x - 3', extraneous: const <double>[1],
              hints: <String>['Square both sides: x + 3 = (x − 3)².', 'Substitute each candidate into the original equation.'],
              model: <String>['x + 3 = (x - 3)^2', 'x + 3 = x^2 - 6x + 9', 'x^2 - 7x + 6 = 0', '(x - 1)(x - 6) = 0', '# x = 1 gives 2 = -2, so it is rejected', 'x = 6']),
        ]),
    scenario('alg_a4', 'Exponential equation', _a,
        what: 'Solve 5^(2x − 1) = 40. Give the exact answer or 4 decimal places.',
        why: 'Logarithms turn exponents into linear equations.',
        steps: <LabStep>[
          solve('alg_a4_1', 'Take logarithms and solve', 'Solve 5^(2x − 1) = 40', '5^(2x - 1) = 40', tolerance: 1e-4, range: (-10, 10),
              hints: <String>['Take ln of both sides: (2x − 1) ln 5 = ln 40.'],
              model: <String>['(2x - 1)ln(5) = ln(40)', '2x - 1 = ln(40)/ln(5)', 'x = (1 + ln(40)/ln(5))/2']),
        ]),
    scenario('alg_a5', 'Absolute-value inequality', _a,
        what: 'Solve |2x − 3| < 7.',
        why: 'Tolerance specifications in engineering and statistics are absolute-value inequalities.',
        steps: <LabStep>[
          solve('alg_a5_1', 'Remove the absolute value and solve', 'Solve |2x − 3| < 7', 'abs(2x - 3) < 7', minLines: 1,
              hints: <String>['|u| < 7 means −7 < u < 7.'],
              model: <String>['-7 < 2x - 3 < 7', '-4 < 2x < 10', '-2 < x < 5']),
        ]),
  ],
);

// ------------------------------------------------------------ B. Calculus

final LabSpec mathCalculusLab = LabSpec(
  id: 'ma_lab_calculus',
  deptId: 'mathematics',
  majorId: 'mathematics',
  number: 2,
  title: 'Calculus',
  environment: LabEnvironment.mathsLab,
  summary: 'Limits, derivatives, tangents, optimisation, integrals, areas and volumes. Graphs respond as you move the sliders; '
      'derivatives and integrals are checked line by line, and antiderivatives by differentiating your answer.',
  objectives: const <String>[
    'Evaluate limits and differentiate with the power, product and chain rules',
    'Use derivatives for tangents, rates and optimisation',
    'Integrate and apply integrals to areas and volumes',
  ],
  skills: const <String>['ma_calc'],
  difficulty: LabDifficulty.intermediate,
  minutes: 35,
  prerequisites: const <String>['ma_lab_algebra'],
  scenarios: <LabScenario>[
    scenario('calc_b1', 'A limit with a hole', _b,
        what: 'Find lim x→3 of (x² − 9)/(x − 3) and explain the graph.',
        why: 'Limits describe what a function approaches even where it is undefined.',
        steps: <LabStep>[
          const NumericStep(
            id: 'calc_b1_1',
            title: 'Read the graph',
            instructions: 'Trace the curve near x = 3 (tap or drag on the graph).',
            curves: <String>['(x^2 - 9)/(x - 3)'],
            window: (0, 6, 0, 10),
            questions: <MathQuestion>[
              NumberQuestion('lim', 'The limit as x → 3', 6, tolerance: 0.001),
              ChoiceQuestion('f3', 'The value f(3) is', <String>['6', '0', 'undefined (0/0)'], 2, explain: 'Substituting x = 3 gives 0/0: the function has a hole there.'),
            ],
          ),
          rewrite('calc_b1_2', 'Simplify for x ≠ 3', '(x² − 9)/(x − 3)', 'x + 3',
              hints: <String>['x² − 9 is a difference of two squares.'],
              model: <String>['(x - 3)(x + 3)/(x - 3)', 'x + 3']),
        ]),
    scenario('calc_b2', 'Power rule', _b,
        what: "Differentiate f(x) = 4x³ − 5x² + 7x − 2. Write only expressions (you may start a line with f'(x) =).",
        why: 'The power rule is used in every application of derivatives.',
        steps: <LabStep>[
          rewrite('calc_b2_1', "Find f'(x)", "f(x) = 4x³ − 5x² + 7x − 2", '12x^2 - 10x + 7', form: FinalForm.expanded,
              hints: <String>['d/dx xⁿ = n xⁿ⁻¹; constants differentiate to 0.'],
              model: <String>['3*4x^2 - 2*5x + 7', '12x^2 - 10x + 7']),
        ]),
    scenario('calc_b3', 'Tangent line on the graph', _b,
        what: 'Find the tangent to y = x² at (2, 4) by adjusting its slope until it touches the curve.',
        why: 'The derivative is the slope of the tangent — here you see it.',
        steps: <LabStep>[
          const GraphStep(
            id: 'calc_b3_1',
            title: 'Adjust the slope',
            instructions: 'The blue line passes through (2, 4). Move m until the line just touches y = x² (grey) at (2, 4) and passes through the orange points.',
            curve: 'm(x - 2) + 4',
            params: <GraphParam>[GraphParam('m', -10, 10, step: 0.5, initial: 0)],
            window: (-1, 5, -5, 15),
            fixedCurves: <String>['x^2'],
            targets: <(double, double)>[(1, 0), (3, 8)],
            modelParams: <String, double>{'m': 4},
            questions: <MathQuestion>[NumberQuestion('c', 'The tangent’s y-intercept', -4, tolerance: 0.001)],
          ),
        ]),
    scenario('calc_b4', 'Velocity of a falling object', _b,
        what: 'A stone falls s(t) = 4.9t² metres in t seconds. Find its velocity at t = 3 and its average velocity over the first 3 s.',
        why: 'Instantaneous and average rates of change are different questions.',
        steps: <LabStep>[
          const NumericStep(
            id: 'calc_b4_1',
            title: 'Rates of change',
            instructions: 'Differentiate for the instantaneous rate; use (s(3) − s(0))/3 for the average.',
            curves: <String>['4.9x^2'],
            window: (0, 4, 0, 80),
            questions: <MathQuestion>[
              NumberQuestion('v3', 'Velocity at t = 3', 29.4, tolerance: 0.01, unit: 'm/s', explain: "s'(t) = 9.8t, so s'(3) = 29.4."),
              NumberQuestion('avg', 'Average velocity from 0 to 3 s', 14.7, tolerance: 0.01, unit: 'm/s', explain: '44.1/3 = 14.7.'),
            ],
          ),
        ]),
    scenario('calc_b5', 'First antiderivative', _b,
        what: 'Find ∫ (6x² − 4x + 3) dx.',
        why: 'Integration reverses differentiation; the + C matters.',
        steps: <LabStep>[
          integrate('calc_b5_1', 'Integrate term by term', '∫ (6x² − 4x + 3) dx', '6x^2 - 4x + 3',
              hints: <String>['∫ xⁿ dx = xⁿ⁺¹/(n + 1) + C.'],
              model: <String>['6x^3/3 - 4x^2/2 + 3x + C', '2x^3 - 2x^2 + 3x + C']),
        ]),
    scenario('calc_i1', 'Product rule', _i,
        what: 'Differentiate x² sin x.',
        why: 'Products of functions appear in physics, economics and engineering models.',
        steps: <LabStep>[
          rewrite('calc_i1_1', 'Apply the product rule', 'd/dx [x² sin x]', '2x sin(x) + x^2 cos(x)',
              hints: <String>["(uv)' = u'v + uv'."],
              model: <String>['(2x)(sin(x)) + (x^2)(cos(x))', '2x sin(x) + x^2 cos(x)']),
        ]),
    scenario('calc_i2', 'Chain rule', _i,
        what: 'Differentiate (3x² + 1)⁵.',
        why: 'The chain rule handles any function of a function.',
        steps: <LabStep>[
          rewrite('calc_i2_1', 'Apply the chain rule', 'd/dx (3x² + 1)⁵', '30x(3x^2 + 1)^4',
              hints: <String>['Differentiate the outside, keep the inside, multiply by the derivative of the inside (6x).'],
              model: <String>['5(3x^2 + 1)^4 * 6x', '30x(3x^2 + 1)^4']),
        ]),
    scenario('calc_i3', 'Fencing a field by a river', _i,
        what: 'A farmer has 120 m of fence for three sides of a rectangle; the river forms the fourth side. Maximise the area.',
        why: 'Optimisation is the most used application of derivatives in industry.',
        information: const <String>['Let x be the length of each side perpendicular to the river. Area A(x) = x(120 − 2x) = 120x − 2x².'],
        person: modelLead,
        steps: <LabStep>[
          solve('calc_i3_1', "Solve A'(x) = 0", "Differentiate A(x) = 120x − 2x² and solve A'(x) = 0", '120 - 4x = 0', range: (0, 60),
              instructions: "Write A'(x) = 0 as an equation on the first line, then solve.",
              hints: <String>["A'(x) = 120 − 4x."],
              model: <String>['120 - 4x = 0', '4x = 120', 'x = 30']),
          const NumericStep(
            id: 'calc_i3_2',
            title: 'Report to the farmer',
            instructions: 'Use the graph of A(x) to confirm it is a maximum.',
            curves: <String>['x(120 - 2x)'],
            window: (0, 60, 0, 2000),
            questions: <MathQuestion>[
              NumberQuestion('side', 'Length parallel to the river', 60, tolerance: 0.01, unit: 'm'),
              NumberQuestion('area', 'Maximum area', 1800, tolerance: 0.5, unit: 'm²'),
            ],
          ),
        ]),
    scenario('calc_i4', 'Definite integral', _i,
        what: 'Evaluate ∫₀² (x² + 1) dx exactly.',
        why: 'Definite integrals give totals: area, distance, accumulated quantity.',
        steps: <LabStep>[
          evaluate('calc_i4_1', 'Evaluate', '∫₀² (x² + 1) dx', '14/3',
              hints: <String>['Antiderivative: x³/3 + x. Evaluate at 2, subtract the value at 0.'],
              model: <String>['(2^3/3 + 2) - (0 + 0)', '8/3 + 2', '14/3']),
        ]),
    scenario('calc_i5', 'Stationary points', _i,
        what: 'Find and classify the stationary points of f(x) = x³ − 3x² − 9x + 5.',
        why: 'Maxima and minima locate peaks and troughs in any model.',
        steps: <LabStep>[
          solve('calc_i5_1', "Solve f'(x) = 0", "f(x) = x³ − 3x² − 9x + 5: write f'(x) = 0 as an equation, then solve", '3x^2 - 6x - 9 = 0',
              hints: <String>["f'(x) = 3x² − 6x − 9. Divide by 3."],
              model: <String>['3x^2 - 6x - 9 = 0', 'x^2 - 2x - 3 = 0', '(x - 3)(x + 1) = 0', 'x = 3 or x = -1']),
          const NumericStep(id: 'calc_i5_2', title: 'Classify', instructions: "Use f''(x) = 6x − 6.", curves: <String>['x^3 - 3x^2 - 9x + 5'], window: (-3, 5, -30, 20), questions: <MathQuestion>[
            NumberQuestion('ymax', 'f(−1)', 10, tolerance: 0.001),
            NumberQuestion('ymin', 'f(3)', -22, tolerance: 0.001),
            ChoiceQuestion('kind', 'The point at x = −1 is a', <String>['maximum', 'minimum', 'point of inflection'], 0, explain: "f''(−1) = −12 < 0."),
          ]),
        ]),
    scenario('calc_a1', 'Integration by parts', _a,
        what: 'Find ∫ x eˣ dx.',
        why: 'Integration by parts is how products of functions are integrated.',
        steps: <LabStep>[
          integrate('calc_a1_1', 'Integrate by parts', '∫ x eˣ dx', 'x e^x',
              hints: <String>['Let u = x and dv = eˣ dx.', '∫ u dv = uv − ∫ v du.'],
              model: <String>['∫ x e^x dx = x e^x - ∫ e^x dx', 'x e^x - e^x + C']),
        ]),
    scenario('calc_a2', 'Implicit differentiation', _a,
        what: 'For the circle x² + y² = 25, find dy/dx and the tangent at (3, 4).',
        why: 'Implicit differentiation handles curves that are not functions of x.',
        steps: <LabStep>[
          rewrite('calc_a2_1', 'Find dy/dx', 'x² + y² = 25: find dy/dx in terms of x and y', '-x/y',
              instructions: 'Write expressions for dy/dx (you may start a line with dy/dx =). Every line must equal dy/dx.',
              hints: <String>['Differentiate both sides: 2x + 2y·dy/dx = 0.'],
              model: <String>['-2x/(2y)', '-x/y']),
          const NumericStep(id: 'calc_a2_2', title: 'Tangent at (3, 4)', instructions: 'Use your derivative.', questions: <MathQuestion>[
            NumberQuestion('m', 'Slope at (3, 4)', -0.75, tolerance: 0.001),
            NumberQuestion('c', 'y-intercept of the tangent', 6.25, tolerance: 0.001, explain: 'y − 4 = −0.75(x − 3), so y = −0.75x + 6.25.'),
          ]),
        ]),
    scenario('calc_a3', 'Area between curves', _a,
        what: 'Find the area enclosed by y = x and y = x².',
        why: 'Areas between curves measure differences accumulated over an interval.',
        steps: <LabStep>[
          const NumericStep(id: 'calc_a3_1', title: 'Find the limits', instructions: 'Find where the curves meet.', curves: <String>['x', 'x^2'], window: (-0.5, 1.5, -0.5, 1.5), questions: <MathQuestion>[
            NumberQuestion('lo', 'Smaller x where they meet', 0, tolerance: 0.001),
            NumberQuestion('hi', 'Larger x where they meet', 1, tolerance: 0.001),
          ]),
          evaluate('calc_a3_2', 'Integrate (top − bottom)', '∫₀¹ (x − x²) dx', '1/6',
              hints: <String>['On [0, 1], y = x is above y = x².'],
              model: <String>['(1^2/2 - 1^3/3) - (0 - 0)', '1/2 - 1/3', '1/6']),
        ]),
    scenario('calc_a4', 'Continuity of a piecewise function', _a,
        what: 'f(x) = kx + 1 for x < 2, and x² − k for x ≥ 2. Find k so f is continuous.',
        why: 'Engineers join different models at boundaries; the join must be continuous.',
        steps: <LabStep>[
          solve('calc_a4_1', 'Match the pieces at x = 2', 'Make the two pieces meet at x = 2 (use k)', '2k + 1 = 4 - k', variable: 'k',
              instructions: 'First line: the equation that makes the pieces equal at x = 2. Then solve for k.',
              hints: <String>['Left piece at 2: 2k + 1. Right piece at 2: 4 − k.'],
              model: <String>['2k + 1 = 4 - k', '3k = 3', 'k = 1']),
        ]),
    scenario('calc_a5', 'Volume of revolution', _a,
        what: 'Rotate y = √x for 0 ≤ x ≤ 4 about the x-axis. Find the volume (exact, or to 2 decimal places).',
        why: 'Volumes of revolution model tanks, nozzles and machined parts.',
        steps: <LabStep>[
          evaluate('calc_a5_1', 'Set up and evaluate V = π∫ y² dx', 'V = π ∫₀⁴ (√x)² dx', '8pi', tolerance: 1e-3,
              hints: <String>['(√x)² = x, so V = π ∫₀⁴ x dx.'],
              model: <String>['pi * (4^2/2 - 0)', 'pi * 8', '8pi']),
        ]),
  ],
);

// ------------------------------------------------------------ C. Linear algebra

const List<List<double>> _eigA = <List<double>>[<double>[4, 1], <double>[2, 3]];
const List<List<double>> _eigP = <List<double>>[<double>[1, 1], <double>[-2, 1]];
const List<List<double>> _rot = <List<double>>[<double>[0, -1], <double>[1, 0]];
const List<List<double>> _tri = <List<double>>[<double>[1, 3, 1], <double>[0, 0, 2]];
const List<List<double>> _rrefM = <List<double>>[<double>[1, 2, -1], <double>[2, 4, 1], <double>[3, 6, 0]];
const List<List<double>> _inv3 = <List<double>>[<double>[2, 0, 1], <double>[1, 3, 2], <double>[1, 1, 2]];
const List<List<double>> _markov = <List<double>>[<double>[0.8, 0.3], <double>[0.2, 0.7]];

final LabSpec mathLinearAlgebraLab = LabSpec(
  id: 'ma_lab_linalg',
  deptId: 'mathematics',
  majorId: 'mathematics',
  number: 3,
  title: 'Linear Algebra',
  environment: LabEnvironment.mathsLab,
  summary: 'Vectors, matrix arithmetic, determinants, inverses, systems, transformations, row reduction, eigenvalues and Markov chains. '
      'Enter results in matrix grids; each entry is checked, and fractions are accepted.',
  objectives: const <String>[
    'Compute with vectors and matrices accurately',
    'Use determinants, inverses and row reduction to solve systems',
    'Find eigenvalues and eigenvectors and use them',
  ],
  skills: const <String>['ma_linalg'],
  difficulty: LabDifficulty.intermediate,
  minutes: 35,
  scenarios: <LabScenario>[
    scenario('lin_b1', 'Vector arithmetic', _b,
        what: 'For u = (3, −1, 2) and v = (1, 4, −2), find 2u − v and |u|.',
        why: 'Vectors describe forces, velocities and data points.',
        steps: <LabStep>[
          MatrixStep(id: 'lin_b1_1', title: 'Compute 2u − v', instructions: 'Enter the components of 2u − v.', given: const <String, List<List<double>>>{
            'u': <List<double>>[<double>[3, -1, 2]],
            'v': <List<double>>[<double>[1, 4, -2]],
          }, answer: Mat.add(Mat.scale(const <List<double>>[<double>[3, -1, 2]], 2), const <List<double>>[<double>[1, 4, -2]], -1), answerLabel: '2u − v'),
          const NumericStep(id: 'lin_b1_2', title: 'Length of u', instructions: '|u| = √(u₁² + u₂² + u₃²).', questions: <MathQuestion>[
            NumberQuestion('len', '|u| (exact like sqrt(14), or 3 d.p.)', 3.7416573867739413, tolerance: 0.001),
          ]),
        ]),
    scenario('lin_b2', 'Dot product and angle', _b,
        what: 'For a = (2, 1) and b = (1, 3), find a·b and the angle between them.',
        why: 'The dot product measures alignment — used in physics work and in similarity search.',
        steps: <LabStep>[
          const NumericStep(id: 'lin_b2_1', title: 'Dot product and angle', instructions: 'cos θ = a·b / (|a||b|).', questions: <MathQuestion>[
            NumberQuestion('dot', 'a·b', 5, tolerance: 0.001),
            NumberQuestion('mag', '|a||b|', 7.0710678, tolerance: 0.001),
            NumberQuestion('ang', 'Angle θ in degrees', 45, tolerance: 0.1),
          ]),
        ]),
    scenario('lin_b3', 'Matrix multiplication', _b,
        what: 'Compute AB for A = [[1, 2], [3, 4]] and B = [[2, 0], [1, −1]].',
        why: 'Matrix products compose transformations and combine data tables.',
        steps: <LabStep>[
          MatrixStep(
            id: 'lin_b3_1',
            title: 'Compute AB',
            instructions: 'Each entry is a row of A times a column of B.',
            given: const <String, List<List<double>>>{
              'A': <List<double>>[<double>[1, 2], <double>[3, 4]],
              'B': <List<double>>[<double>[2, 0], <double>[1, -1]],
            },
            answer: Mat.mul(const <List<double>>[<double>[1, 2], <double>[3, 4]], const <List<double>>[<double>[2, 0], <double>[1, -1]]),
            answerLabel: 'AB',
            hints: const <String>['Top-left entry: 1×2 + 2×1 = 4.'],
          ),
        ]),
    scenario('lin_b4', 'Determinants and invertibility', _b,
        what: 'Find det A and det B for A = [[3, 5], [2, 4]] and B = [[2, 6], [1, 3]]. Which can be inverted?',
        why: 'A zero determinant means a system has no unique solution.',
        steps: <LabStep>[
          NumericStep(id: 'lin_b4_1', title: 'Determinants', instructions: 'det [[a, b], [c, d]] = ad − bc.', questions: <MathQuestion>[
            numQ('da', 'det A', Mat.det(const <List<double>>[<double>[3, 5], <double>[2, 4]]), tol: 0.001),
            numQ('db', 'det B', Mat.det(const <List<double>>[<double>[2, 6], <double>[1, 3]]), tol: 0.001),
            choice('inv', 'Which matrices have an inverse?', const <String>['A only', 'B only', 'Both', 'Neither'], 0, explain: 'Only a non-zero determinant allows an inverse.'),
          ]),
        ]),
    scenario('lin_b5', 'Non-square products', _b,
        what: 'A is 2×3 and B is 3×2. Compute AB and state the size of BA.',
        why: 'Checking dimensions before multiplying prevents most matrix errors.',
        steps: <LabStep>[
          MatrixStep(
            id: 'lin_b5_1',
            title: 'Compute AB (2×2)',
            instructions: 'Multiply rows of A by columns of B.',
            given: const <String, List<List<double>>>{
              'A': <List<double>>[<double>[1, 0, 2], <double>[-1, 3, 1]],
              'B': <List<double>>[<double>[3, 1], <double>[2, 1], <double>[1, 0]],
            },
            answer: Mat.mul(const <List<double>>[<double>[1, 0, 2], <double>[-1, 3, 1]], const <List<double>>[<double>[3, 1], <double>[2, 1], <double>[1, 0]]),
            answerLabel: 'AB',
          ),
          const NumericStep(id: 'lin_b5_2', title: 'Size of BA', instructions: '(3×2)(2×3).', questions: <MathQuestion>[
            NumberQuestion('r', 'Rows of BA', 3, tolerance: 0),
            NumberQuestion('c', 'Columns of BA', 3, tolerance: 0),
          ]),
        ]),
    scenario('lin_i1', '3×3 determinant by cofactors', _i,
        what: 'Find det [[2, −1, 0], [1, 3, 2], [0, 1, 4]], showing the cofactor expansion along the first row.',
        why: 'Cofactor expansion is the general definition behind every determinant shortcut.',
        steps: <LabStep>[
          evaluate('lin_i1_1', 'Expand and evaluate', 'det [[2, −1, 0], [1, 3, 2], [0, 1, 4]]',
              '${Mat.det(const <List<double>>[<double>[2, -1, 0], <double>[1, 3, 2], <double>[0, 1, 4]])}',
              hints: <String>['2·det[[3, 2], [1, 4]] − (−1)·det[[1, 2], [0, 4]] + 0·(…)'],
              model: <String>['2(3*4 - 2*1) - (-1)(1*4 - 2*0) + 0', '2(10) + 4', '24']),
        ]),
    scenario('lin_i2', 'Inverse of a 2×2 matrix', _i,
        what: 'Find the inverse of M = [[4, 7], [2, 6]].',
        why: 'Inverses solve linear systems and undo transformations.',
        steps: <LabStep>[
          MatrixStep(
            id: 'lin_i2_1',
            title: 'Compute M⁻¹',
            instructions: 'M⁻¹ = (1/det M)·[[d, −b], [−c, a]].',
            given: const <String, List<List<double>>>{'M': <List<double>>[<double>[4, 7], <double>[2, 6]]},
            answer: Mat.inverse(const <List<double>>[<double>[4, 7], <double>[2, 6]]),
            answerLabel: 'M⁻¹',
            hints: const <String>['det M = 24 − 14 = 10.'],
          ),
        ]),
    scenario('lin_i3', 'Three equations, three unknowns', _i,
        what: 'Solve x + y + z = 6, 2x − y + z = 3, x + 2y − z = 2.',
        why: 'Larger systems are solved by systematic elimination.',
        steps: <LabStep>[
          system('lin_i3_1', 'Eliminate step by step', 'x + y + z = 6\n2x − y + z = 3\nx + 2y − z = 2', 'x + y + z = 6; 2x - y + z = 3; x + 2y - z = 2',
              const <String, double>{'x': 1, 'y': 2, 'z': 3},
              hints: <String>['Use the first equation to write z in terms of x and y.'],
              model: <String>['z = 6 - x - y', 'x - 2y = -3', '2x + 3y = 8', 'x = 2y - 3', '7y - 6 = 8', 'y = 2', 'x = 1', 'z = 3', 'x = 1, y = 2, z = 3']),
        ]),
    scenario('lin_i4', 'Rotating a shape', _i,
        what: 'Rotate the triangle with vertices (1, 0), (3, 0), (1, 2) by 90° anticlockwise using R = [[0, −1], [1, 0]].',
        why: 'Graphics, robotics and CAD all move objects with matrices.',
        steps: <LabStep>[
          MatrixStep(
            id: 'lin_i4_1',
            title: 'Compute R·P',
            instructions: 'P holds the vertices as columns. Each column of R·P is a new vertex.',
            given: const <String, List<List<double>>>{'R': _rot, 'P': _tri},
            answer: Mat.mul(_rot, _tri),
            answerLabel: 'R·P',
          ),
        ]),
    scenario('lin_i5', 'Row reduction and rank', _i,
        what: 'Reduce M = [[1, 2, −1], [2, 4, 1], [3, 6, 0]] to reduced row echelon form and find its rank.',
        why: 'Rank tells you how many independent equations or features you really have.',
        steps: <LabStep>[
          MatrixStep(
            id: 'lin_i5_1',
            title: 'RREF of M',
            instructions: 'Leading entries 1, zeros above and below each leading 1.',
            given: const <String, List<List<double>>>{'M': _rrefM},
            answer: Mat.rref(_rrefM),
            answerLabel: 'RREF(M)',
            hints: const <String>['R2 − 2R1 and R3 − 3R1 first.'],
          ),
          NumericStep(id: 'lin_i5_2', title: 'Rank', instructions: 'Count the non-zero rows.', questions: <MathQuestion>[
            numQ('rank', 'rank(M)', Mat.rank(_rrefM).toDouble(), tol: 0),
          ]),
        ]),
    scenario('lin_a1', 'Eigenvalues', _a,
        what: 'Find the eigenvalues of A = [[4, 1], [2, 3]]. Write λ as L.',
        why: 'Eigenvalues give growth rates, vibration frequencies and principal components.',
        steps: <LabStep>[
          solve('lin_a1_1', 'Solve det(A − λI) = 0', 'det([[4 − L, 1], [2, 3 − L]]) = 0', '(4 - L)(3 - L) - 2 = 0', variable: 'L',
              hints: <String>['det = (4 − L)(3 − L) − 1·2.'],
              model: <String>['12 - 7L + L^2 - 2 = 0', 'L^2 - 7L + 10 = 0', '(L - 2)(L - 5) = 0', 'L = 2 or L = 5']),
        ]),
    scenario('lin_a2', 'Eigenvectors', _a,
        what: 'For A = [[4, 1], [2, 3]] (eigenvalues 2 and 5), find eigenvectors.',
        why: 'Eigenvectors are the directions a transformation only stretches.',
        steps: <LabStep>[
          const MatrixStep(
            id: 'lin_a2_1',
            title: 'Eigenvector matrix P',
            instructions: 'Column 1: eigenvector for λ = 2; column 2: for λ = 5. Scale each so its first entry is 1.',
            given: <String, List<List<double>>>{'A': _eigA},
            answer: _eigP,
            answerLabel: 'P',
            hints: <String>['For λ = 2 solve (A − 2I)v = 0: 2v₁ + v₂ = 0.'],
          ),
        ]),
    scenario('lin_a3', 'Inverse of a 3×3 matrix', _a,
        what: 'Find the inverse of N = [[2, 0, 1], [1, 3, 2], [1, 1, 2]].',
        why: 'Gauss–Jordan elimination is how software inverts matrices.',
        steps: <LabStep>[
          MatrixStep(
            id: 'lin_a3_1',
            title: 'Compute N⁻¹',
            instructions: 'Row-reduce [N | I] to [I | N⁻¹]. Fractions are fine.',
            given: const <String, List<List<double>>>{'N': _inv3},
            answer: Mat.inverse(_inv3),
            answerLabel: 'N⁻¹',
            hints: <String>['det N = ${Mat.det(_inv3).round()}, so the entries are sixths.'],
          ),
        ]),
    scenario('lin_a4', 'Diagonalisation', _a,
        what: 'With P from the eigenvectors of A = [[4, 1], [2, 3]], compute D = P⁻¹AP and A³.',
        why: 'Diagonalising makes powers of a matrix easy — used for long-run behaviour of systems.',
        steps: <LabStep>[
          MatrixStep(
            id: 'lin_a4_1',
            title: 'Compute D = P⁻¹AP',
            instructions: 'D should be diagonal, with the eigenvalues on the diagonal.',
            given: const <String, List<List<double>>>{'A': _eigA, 'P': _eigP},
            answer: Mat.mul(Mat.inverse(_eigP), Mat.mul(_eigA, _eigP)),
            answerLabel: 'D',
          ),
          MatrixStep(
            id: 'lin_a4_2',
            title: 'Compute A³',
            instructions: 'A³ = P D³ P⁻¹, or multiply directly.',
            given: const <String, List<List<double>>>{'A': _eigA},
            answer: Mat.mul(_eigA, Mat.mul(_eigA, _eigA)),
            answerLabel: 'A³',
          ),
        ]),
    scenario('lin_a5', 'Market share as a Markov chain', _a,
        what: 'Each year 80% of brand A’s customers stay and 20% switch to B; 70% of B’s stay and 30% switch to A. Find the long-run shares.',
        why: 'Markov chains model customer loyalty, page ranking and machine reliability.',
        information: const <String>['Transition matrix (columns: from A, from B): [[0.8, 0.3], [0.2, 0.7]].', 'Let a and b be the long-run shares.'],
        person: modelLead,
        steps: <LabStep>[
          system('lin_a5_1', 'Steady state', '0.8a + 0.3b = a\na + b = 1', '0.8a + 0.3b = a; a + b = 1', const <String, double>{'a': 0.6, 'b': 0.4},
              hints: <String>['The first equation simplifies to 0.3b = 0.2a.'],
              model: <String>['0.3b = 0.2a', 'b = 2a/3', 'a + 2a/3 = 1', 'a = 0.6', 'b = 0.4', 'a = 0.6, b = 0.4']),
          NumericStep(id: 'lin_a5_2', title: 'Two years from now', instructions: 'Start with every customer at A: x₀ = (1, 0). Compute x₂ = T²x₀.', questions: <MathQuestion>[
            numQ('a2', 'Brand A’s share after 2 years', Mat.mul(_markov, Mat.mul(_markov, const <List<double>>[<double>[1], <double>[0]]))[0][0], tol: 0.001),
          ]),
        ]),
  ],
);
