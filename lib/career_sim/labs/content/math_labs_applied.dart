/// Mathematics labs D–F: Statistics, Differential Equations and Applied
/// Mathematics. Statistical answers are computed from each scenario's data
/// with the reference routines in numerics.dart.
library;

import 'dart:math' as math;

import '../lab_models.dart';
import '../math/math_steps.dart';
import '../math/numerics.dart';
import 'math_lab_kit.dart';

const LabDifficulty _b = LabDifficulty.foundation;
const LabDifficulty _i = LabDifficulty.intermediate;
const LabDifficulty _a = LabDifficulty.advanced;

DataTableSpec _column(String name, String unit, List<double> xs, {String id = 'ID', String prefix = '', String caption = ''}) => DataTableSpec(
      <String>[id, '$name${unit.isEmpty ? '' : ' ($unit)'}'],
      <List<Object>>[for (int i = 0; i < xs.length; i++) <Object>['$prefix${(i + 1).toString().padLeft(2, '0')}', xs[i]]],
      caption: caption,
    );

DataTableSpec _pairs(String a, String b, List<double> x, List<double> y, {String caption = ''}) => DataTableSpec(
      <String>['#', a, b],
      <List<Object>>[for (int i = 0; i < x.length; i++) <Object>[i + 1, x[i], y[i]]],
      caption: caption,
    );

// ------------------------------------------------------------ data

const List<double> _scores = <double>[72, 85, 64, 91, 78, 85, 69, 88, 73, 85, 60, 94, 77, 81, 70];
const List<double> _commute = <double>[25, 18, 70, 22, 15, 30, 12, 28, 20, 35, 25];
const List<double> _sales = <double>[120, 135, 128, 150, 142, 118, 160, 131];
const List<double> _battery = <double>[9.8, 10.4, 10.1, 9.5, 10.9, 10.2, 9.9, 10.6, 10.0, 10.3, 9.7, 10.5];
const List<double> _hours = <double>[2, 3, 5, 1, 4, 6, 8, 7, 3, 5];
const List<double> _marks = <double>[55, 60, 70, 48, 65, 75, 88, 80, 58, 72];
const List<double> _fill = <double>[498.2, 501.1, 497.5, 499.0, 496.8, 500.2, 498.5, 497.9, 499.4, 498.0];
const List<double> _methodA = <double>[72, 75, 78, 70, 74, 77, 73, 76];
const List<double> _methodB = <double>[68, 70, 65, 72, 69, 71, 67, 66];
const List<double> _dieObserved = <double>[15, 22, 18, 25, 20, 20];
const List<double> _spend = <double>[2, 4, 5, 7, 8, 10, 11, 13];
const List<double> _revenue = <double>[21, 30, 33, 41, 45, 52, 57, 63];
const List<double> _bpBefore = <double>[142, 150, 138, 160, 155, 148, 162, 145];
const List<double> _bpAfter = <double>[135, 146, 136, 151, 150, 144, 153, 140];
const List<int> _siblingFreq = <int>[6, 14, 10, 7, 3];

List<double> get _siblings => <double>[for (int v = 0; v < _siblingFreq.length; v++) for (int k = 0; k < _siblingFreq[v]; k++) v.toDouble()];

double get _fillT => Stats.tOneSample(_fill, 500);
(double, int) get _pooled => Stats.tPooled(_methodA, _methodB);
List<double> get _bpDiff => <double>[for (int i = 0; i < _bpBefore.length; i++) _bpBefore[i] - _bpAfter[i]];
double get _pairedT => Stats.mean(_bpDiff) / (Stats.sd(_bpDiff) / math.sqrt(_bpDiff.length));

ChoiceQuestion _decision(String id, double stat, double critical, {String test = 'two-sided, 5% level'}) => choice(
      id,
      'Decision ($test)',
      const <String>['Reject H₀', 'Do not reject H₀'],
      stat.abs() > critical ? 0 : 1,
      explain: '|statistic| = ${r4(stat.abs())} ${stat.abs() > critical ? '>' : '≤'} critical value ${r4(critical)}.',
    );

// ------------------------------------------------------------ D. Statistics

final LabSpec mathStatisticsLab = LabSpec(
  id: 'ma_lab_stats',
  deptId: 'mathematics',
  majorId: 'mathematics',
  number: 4,
  title: 'Statistics',
  environment: LabEnvironment.mathsLab,
  summary: 'Work with real datasets: summaries, spread, probability, the normal and binomial distributions, confidence intervals, '
      'correlation, regression and hypothesis tests. Every answer is recomputed from the data shown.',
  objectives: const <String>[
    'Summarise data and identify outliers',
    'Calculate probabilities with standard distributions',
    'Estimate and test with confidence intervals and t, chi-square and paired tests',
  ],
  skills: const <String>['ma_stats'],
  difficulty: LabDifficulty.intermediate,
  minutes: 35,
  scenarios: <LabScenario>[
    scenario('st_b1', 'Exam score summary', _b,
        person: statsLead,
        what: 'Summarise a class’s exam scores for the module report.',
        why: 'Centre and range are the first numbers any report gives.',
        steps: <LabStep>[
          NumericStep(id: 'st_b1_1', title: 'Centre and range', instructions: 'Use the calculator if you like. Give the mean to 2 decimal places.', data: _column('Score', '%', _scores, prefix: 'S'), questions: <MathQuestion>[
            numQ('mean', 'Mean', Stats.mean(_scores), tol: 0.01),
            numQ('median', 'Median', Stats.median(_scores), tol: 0.001),
            numQ('mode', 'Mode', Stats.modes(_scores).first, tol: 0.001),
            numQ('range', 'Range', _scores.reduce(math.max) - _scores.reduce(math.min), tol: 0.001),
          ]),
        ]),
    scenario('st_b2', 'Commute times and outliers', _b,
        person: statsLead,
        what: 'Find the quartiles and IQR of staff commute times and check for outliers (beyond 1.5 × IQR from the quartiles).',
        why: 'Outliers change means; the IQR rule is the standard screen.',
        information: const <String>['Quartiles: median of the lower and upper halves, leaving out the overall median when n is odd.'],
        steps: <LabStep>[
          NumericStep(id: 'st_b2_1', title: 'Quartiles and outliers', instructions: 'Sort the data first.', data: _column('Commute', 'min', _commute, prefix: 'E'), questions: <MathQuestion>[
            numQ('q1', 'Lower quartile Q1', Stats.quartiles(_commute).$1, tol: 0.001),
            numQ('q3', 'Upper quartile Q3', Stats.quartiles(_commute).$2, tol: 0.001),
            numQ('iqr', 'IQR', Stats.quartiles(_commute).$2 - Stats.quartiles(_commute).$1, tol: 0.001),
            choice('out', 'Which value is an outlier?', const <String>['12', '35', '70', 'None'], 2, explain: 'Upper fence = Q3 + 1.5 × IQR = 48.'),
          ]),
        ]),
    scenario('st_b3', 'Variability of daily sales', _b,
        person: statsLead,
        what: 'Find the mean and sample standard deviation of a shop’s daily sales.',
        why: 'Standard deviation is the common unit of variability in every later method.',
        steps: <LabStep>[
          NumericStep(id: 'st_b3_1', title: 'Mean and standard deviation', instructions: 'Use the sample formula (divide by n − 1). 2 decimal places.', data: _column('Sales', '£', _sales, id: 'Day'), questions: <MathQuestion>[
            numQ('mean', 'Mean', Stats.mean(_sales), tol: 0.01),
            numQ('var', 'Sample variance', Stats.variance(_sales), tol: 0.05),
            numQ('sd', 'Sample standard deviation', Stats.sd(_sales), tol: 0.01),
          ]),
        ]),
    scenario('st_b4', 'Two dice', _b,
        what: 'Two fair dice are rolled. Find the probabilities below (fractions are fine).',
        why: 'Counting equally likely outcomes is the foundation of probability.',
        steps: <LabStep>[
          NumericStep(id: 'st_b4_1', title: 'Probabilities', instructions: 'There are 36 equally likely outcomes.', questions: <MathQuestion>[
            numQ('s7', 'P(sum = 7)', 6 / 36, tol: 0.001),
            numQ('s10', 'P(sum ≥ 10)', 6 / 36, tol: 0.001),
            numQ('dbl', 'P(a double)', 6 / 36, tol: 0.001),
            numQ('six', 'P(at least one six)', 11 / 36, tol: 0.001),
          ]),
        ]),
    scenario('st_b5', 'Frequency table', _b,
        what: 'A survey of 40 students recorded their number of siblings. Find the mean, median and mode.',
        why: 'Grouped counts are how most survey data arrives.',
        steps: <LabStep>[
          NumericStep(
            id: 'st_b5_1',
            title: 'Summaries from a frequency table',
            instructions: 'Mean = Σfx / Σf. The median is the average of the 20th and 21st values.',
            data: DataTableSpec(const <String>['Siblings', 'Frequency'], <List<Object>>[for (int v = 0; v < _siblingFreq.length; v++) <Object>[v, _siblingFreq[v]]]),
            questions: <MathQuestion>[
              numQ('mean', 'Mean', Stats.mean(_siblings), tol: 0.001),
              numQ('median', 'Median', Stats.median(_siblings), tol: 0.001),
              numQ('mode', 'Mode', Stats.modes(_siblings).first, tol: 0.001),
            ],
          ),
        ]),
    scenario('st_i1', 'Heights and the normal distribution', _i,
        what: 'Adult heights are normally distributed with mean 170 cm and standard deviation 8 cm.',
        why: 'The normal model underlies quality control, testing and measurement.',
        information: const <String>['Standardise with z = (x − μ)/σ. Answers to 3 decimal places.'],
        steps: <LabStep>[
          NumericStep(id: 'st_i1_1', title: 'Normal probabilities', instructions: 'Use z-values and the standard normal distribution.', questions: <MathQuestion>[
            numQ('z', 'z-score of 186 cm', 2, tol: 0.001),
            numQ('p1', 'P(height < 180)', Stats.normalCdf(1.25), tol: 0.002),
            numQ('p2', 'P(160 < height < 180)', Stats.normalCdf(1.25) - Stats.normalCdf(-1.25), tol: 0.002),
          ]),
        ]),
    scenario('st_i2', 'Confidence interval for battery life', _i,
        person: statsLead,
        what: 'Estimate mean battery life with a 95% confidence interval.',
        why: 'Intervals show how precise an estimate is — a single number does not.',
        information: <String>['t critical value for ${_battery.length - 1} degrees of freedom: ${Stats.tCritical95(_battery.length - 1)}.'],
        steps: <LabStep>[
          NumericStep(id: 'st_i2_1', title: '95% CI', instructions: 'mean ± t × s/√n. 3 decimal places.', data: _column('Life', 'hours', _battery, id: 'Unit'), questions: <MathQuestion>[
            numQ('mean', 'Sample mean', Stats.mean(_battery), tol: 0.002),
            numQ('sd', 'Sample standard deviation', Stats.sd(_battery), tol: 0.002),
            numQ('lo', 'Lower limit', Stats.mean(_battery) - Stats.tCritical95(11) * Stats.sd(_battery) / math.sqrt(12), tol: 0.005),
            numQ('hi', 'Upper limit', Stats.mean(_battery) + Stats.tCritical95(11) * Stats.sd(_battery) / math.sqrt(12), tol: 0.005),
          ]),
        ]),
    scenario('st_i3', 'Study hours and marks', _i,
        what: 'Measure the correlation between hours studied and marks.',
        why: 'Correlation quantifies a linear relationship — not causation.',
        steps: <LabStep>[
          NumericStep(id: 'st_i3_1', title: 'Correlation', instructions: 'Pearson r to 3 decimal places.', data: _pairs('Hours', 'Mark', _hours, _marks), questions: <MathQuestion>[
            numQ('r', 'r', Stats.correlation(_hours, _marks), tol: 0.002),
            choice('desc', 'Describe the relationship', const <String>['Strong positive', 'Weak positive', 'None', 'Strong negative'], 0),
            choice('cause', 'Does this prove studying causes higher marks?', const <String>['Yes', 'No — it is observational'], 1),
          ]),
        ]),
    scenario('st_i4', 'Defects on a production line', _i,
        what: 'Each part has a 5% chance of a defect, independently. A batch has 20 parts.',
        why: 'The binomial distribution counts successes in repeated trials.',
        steps: <LabStep>[
          NumericStep(id: 'st_i4_1', title: 'Binomial probabilities', instructions: 'X ~ B(20, 0.05). 4 decimal places.', questions: <MathQuestion>[
            numQ('p0', 'P(X = 0)', Stats.binomialPmf(20, 0, 0.05), tol: 0.0005),
            numQ('p2', 'P(X ≤ 2)', Stats.binomialCdf(20, 2, 0.05), tol: 0.0005),
            numQ('ex', 'Expected number of defects', 1, tol: 0.001),
          ]),
        ]),
    scenario('st_i5', 'Phones by age group', _i,
        what: 'A survey of 200 people recorded phone type and age group. Find conditional probabilities and judge independence.',
        why: 'Two-way tables are how most survey results are cross-tabulated.',
        steps: <LabStep>[
          const NumericStep(
            id: 'st_i5_1',
            title: 'Conditional probability',
            instructions: 'P(A | B) = P(A and B)/P(B).',
            data: DataTableSpec(<String>['', 'Android', 'iPhone', 'Total'], <List<Object>>[
              <Object>['Under 30', 48, 72, 120],
              <Object>['30 and over', 50, 30, 80],
              <Object>['Total', 98, 102, 200],
            ]),
            questions: <MathQuestion>[
              NumberQuestion('pi', 'P(iPhone)', 102 / 200, tolerance: 0.001),
              NumberQuestion('pic', 'P(iPhone | under 30)', 72 / 120, tolerance: 0.001),
              NumberQuestion('pua', 'P(under 30 | Android)', 48 / 98, tolerance: 0.001),
              ChoiceQuestion('ind', 'Are phone type and age group independent?', <String>['Yes', 'No'], 1, explain: 'P(iPhone | under 30) = 0.6 ≠ P(iPhone) = 0.51.'),
            ],
          ),
        ]),
    scenario('st_a1', 'Is the bottling machine under-filling?', _a,
        person: statsLead,
        what: 'Bottles should hold 500 ml. Test H₀: μ = 500 against H₁: μ ≠ 500 with a one-sample t-test.',
        why: 'Hypothesis tests decide whether a process needs adjusting.',
        information: <String>['Critical value t(0.975, ${_fill.length - 1}) = ${Stats.tCritical95(_fill.length - 1)}.'],
        steps: <LabStep>[
          NumericStep(id: 'st_a1_1', title: 'One-sample t-test', instructions: 't = (x̄ − 500)/(s/√n). 3 decimal places.', data: _column('Volume', 'ml', _fill, id: 'Bottle'), questions: <MathQuestion>[
            numQ('mean', 'Sample mean', Stats.mean(_fill), tol: 0.002),
            numQ('sd', 'Sample standard deviation', Stats.sd(_fill), tol: 0.002),
            numQ('t', 't statistic', _fillT, tol: 0.01),
            _decision('dec', _fillT, Stats.tCritical95(_fill.length - 1)),
          ]),
        ]),
    scenario('st_a2', 'Comparing two teaching methods', _a,
        what: 'Compare test scores from two teaching methods with a pooled two-sample t-test.',
        why: 'Two-sample tests evaluate interventions — the basis of evidence-based decisions.',
        information: <String>['Pooled variance s² = ((n₁−1)s₁² + (n₂−1)s₂²)/(n₁+n₂−2). Critical value t(0.975, ${_pooled.$2}) = ${Stats.tCritical95(_pooled.$2)}.'],
        steps: <LabStep>[
          NumericStep(id: 'st_a2_1', title: 'Two-sample t-test', instructions: '3 decimal places.', data: _pairs('Method A', 'Method B', _methodA, _methodB), questions: <MathQuestion>[
            numQ('ma', 'Mean A', Stats.mean(_methodA), tol: 0.002),
            numQ('mb', 'Mean B', Stats.mean(_methodB), tol: 0.002),
            numQ('t', 't statistic', _pooled.$1, tol: 0.01),
            _decision('dec', _pooled.$1, Stats.tCritical95(_pooled.$2)),
          ]),
        ]),
    scenario('st_a3', 'Is the die fair?', _a,
        what: 'A die was rolled 120 times. Test whether it is fair with a chi-square goodness-of-fit test.',
        why: 'Goodness-of-fit tests check whether data match a model.',
        information: <String>['Critical value χ²(0.95, 5) = ${Stats.chi95[4]}.'],
        steps: <LabStep>[
          NumericStep(
            id: 'st_a3_1',
            title: 'Chi-square test',
            instructions: 'χ² = Σ (O − E)²/E.',
            data: DataTableSpec(const <String>['Face', 'Observed'], <List<Object>>[for (int i = 0; i < 6; i++) <Object>[i + 1, _dieObserved[i]]]),
            questions: <MathQuestion>[
              numQ('e', 'Expected count per face', 20, tol: 0.001),
              numQ('chi', 'χ² statistic', Stats.chiSquare(_dieObserved, List<double>.filled(6, 20)), tol: 0.01),
              numQ('df', 'Degrees of freedom', 5, tol: 0),
              _decision('dec', Stats.chiSquare(_dieObserved, List<double>.filled(6, 20)), Stats.chi95[4], test: 'upper tail, 5% level'),
            ],
          ),
        ]),
    scenario('st_a4', 'Advertising and revenue', _a,
        person: statsLead,
        what: 'Fit a least-squares line predicting revenue from advertising spend, then predict and check a residual.',
        why: 'Regression is the most used predictive model in business and science.',
        steps: <LabStep>[
          NumericStep(id: 'st_a4_1', title: 'Regression line', instructions: 'ŷ = a + bx with b = Sxy/Sxx. 3 decimal places.', data: _pairs('Spend (£k)', 'Revenue (£k)', _spend, _revenue), questions: <MathQuestion>[
            numQ('b', 'Slope b', Stats.regression(_spend, _revenue).$2, tol: 0.005),
            numQ('a', 'Intercept a', Stats.regression(_spend, _revenue).$1, tol: 0.01),
            numQ('pred', 'Predicted revenue at £12k spend', Stats.regression(_spend, _revenue).$1 + 12 * Stats.regression(_spend, _revenue).$2, tol: 0.02),
            numQ('res', 'Residual for the point (7, 41)', 41 - (Stats.regression(_spend, _revenue).$1 + 7 * Stats.regression(_spend, _revenue).$2), tol: 0.02),
          ]),
        ]),
    scenario('st_a5', 'Does the treatment lower blood pressure?', _a,
        what: 'Systolic blood pressure was measured before and after treatment for 8 patients. Run a paired t-test on the differences (before − after).',
        why: 'Paired designs remove patient-to-patient variation.',
        information: <String>['Critical value t(0.975, 7) = ${Stats.tCritical95(7)}. This is educational data, not clinical advice.'],
        steps: <LabStep>[
          NumericStep(id: 'st_a5_1', title: 'Paired t-test', instructions: 't = d̄ / (s_d/√n). 3 decimal places.', data: _pairs('Before', 'After', _bpBefore, _bpAfter), questions: <MathQuestion>[
            numQ('dbar', 'Mean difference d̄', Stats.mean(_bpDiff), tol: 0.002),
            numQ('sd', 'Standard deviation of differences', Stats.sd(_bpDiff), tol: 0.002),
            numQ('t', 't statistic', _pairedT, tol: 0.01),
            _decision('dec', _pairedT, Stats.tCritical95(7)),
          ]),
        ]),
  ],
);

// ------------------------------------------------------------ E. Differential equations

final LabSpec mathDiffEqLab = LabSpec(
  id: 'ma_lab_de',
  deptId: 'mathematics',
  majorId: 'mathematics',
  number: 5,
  title: 'Differential Equations',
  environment: LabEnvironment.mathsLab,
  summary: 'Solve first- and second-order differential equations and use them to model growth, cooling, mixing and vibration. '
      'Your solution is checked by substituting it into the equation; the slope field shows whether it follows the flow.',
  objectives: const <String>[
    'Solve separable and linear first-order equations',
    'Solve constant-coefficient second-order equations',
    'Model and interpret real systems with ODEs, including Euler’s method',
  ],
  skills: const <String>['ma_de'],
  difficulty: LabDifficulty.advanced,
  minutes: 40,
  prerequisites: const <String>['ma_lab_calculus'],
  scenarios: <LabScenario>[
    scenario('de_b1', 'Direct integration', _b,
        what: 'Find the general solution of dy/dx = 6x² − 4.',
        why: 'The simplest ODEs are solved by integrating once.',
        steps: <LabStep>[
          const OdeStep(id: 'de_b1_1', title: 'General solution', instructions: 'Integrate both sides. Use C for the constant.', equation: 'dy/dx = 6x² − 4', rhs: '6x^2 - 4', range: (-2, 2),
              hints: <String>['∫ (6x² − 4) dx = 2x³ − 4x + C.'], model: '2x^3 - 4x + C'),
        ]),
    scenario('de_b2', 'Bacterial growth', _b,
        person: modelLead,
        what: 'A culture grows at a rate proportional to its size: dy/dx = 0.3y (x in hours), with 50 cells at x = 0.',
        why: 'Exponential growth models populations, interest and chain reactions.',
        steps: <LabStep>[
          const OdeStep(id: 'de_b2_1', title: 'Solve the initial value problem', instructions: 'Separate variables and use y(0) = 50.', equation: 'dy/dx = 0.3y', rhs: '0.3y', initial: <double>[0, 50], range: (0, 5),
              hints: <String>['∫ dy/y = ∫ 0.3 dx gives ln y = 0.3x + c.'], model: '50e^(0.3x)'),
          NumericStep(id: 'de_b2_2', title: 'Use the model', instructions: '2 decimal places.', questions: <MathQuestion>[
            numQ('y5', 'Cells after 5 hours', 50 * math.exp(1.5), tol: 0.05),
            numQ('dbl', 'Doubling time (hours)', math.ln2 / 0.3, tol: 0.01),
          ]),
        ]),
    scenario('de_b3', 'Euler’s method by hand', _b,
        what: "Use Euler's method with h = 0.1 on y' = x + y, y(0) = 1, and compare with the exact solution y = 2eˣ − x − 1.",
        why: 'Numerical methods solve equations that have no formula — this is how simulators work.',
        steps: <LabStep>[
          NumericStep(id: 'de_b3_1', title: 'Two Euler steps', instructions: 'yₙ₊₁ = yₙ + h·f(xₙ, yₙ). 4 decimal places.', questions: <MathQuestion>[
            numQ('y1', 'y(0.1) by Euler', euler((double x, double y) => x + y, 0, 1, 0.1, 1), tol: 0.0005),
            numQ('y2', 'y(0.2) by Euler', euler((double x, double y) => x + y, 0, 1, 0.1, 2), tol: 0.0005),
            numQ('ex', 'Exact y(0.2)', 2 * math.exp(0.2) - 1.2, tol: 0.0005),
            numQ('err', 'Error of Euler at 0.2 (exact − Euler)', 2 * math.exp(0.2) - 1.2 - euler((double x, double y) => x + y, 0, 1, 0.1, 2), tol: 0.0005),
          ]),
        ]),
    scenario('de_b4', 'A separable equation', _b,
        what: 'Solve dy/dx = xy with y(0) = 2.',
        why: 'Separation of variables is the first general method.',
        steps: <LabStep>[
          const OdeStep(id: 'de_b4_1', title: 'Separate and integrate', instructions: 'Find y(x) satisfying the initial condition.', equation: 'dy/dx = xy', rhs: 'x*y', initial: <double>[0, 2], range: (0, 1.5),
              hints: <String>['∫ dy/y = ∫ x dx gives ln y = x²/2 + c.'], model: '2e^(x^2/2)'),
        ]),
    scenario('de_b5', 'Reading a slope field', _b,
        what: "Use the slope field of y' = y − x, then find its general solution.",
        why: 'Slope fields show every solution’s behaviour before any algebra.',
        steps: <LabStep>[
          const NumericStep(id: 'de_b5_1', title: 'Slopes', instructions: "Evaluate y' = y − x at the points.", questions: <MathQuestion>[
            NumberQuestion('s1', 'Slope at (1, 3)', 2, tolerance: 0.001),
            NumberQuestion('s2', 'Slope at (2, 2)', 0, tolerance: 0.001),
            ChoiceQuestion('line', 'Which straight line is itself a solution?', <String>['y = x', 'y = x + 1', 'y = 2x'], 1, explain: "On y = x + 1, y' = 1 and y − x = 1."),
          ]),
          const OdeStep(id: 'de_b5_2', title: 'General solution', instructions: 'Use C for the constant. Your curve is drawn on the slope field.', equation: "y' = y − x", rhs: 'y - x', range: (-2, 2),
              hints: <String>["Write y' − y = −x and use the integrating factor e^(−x)."], model: 'x + 1 + Ce^x'),
        ]),
    scenario('de_i1', 'Integrating factor', _i,
        what: "Find the general solution of y' + 2y = eˣ.",
        why: 'Linear first-order equations model circuits, drug levels and heating.',
        steps: <LabStep>[
          const OdeStep(id: 'de_i1_1', title: 'Solve with an integrating factor', instructions: 'Use C for the constant.', equation: "y' + 2y = eˣ", rhs: 'e^x - 2y', range: (-1, 1),
              hints: <String>['Integrating factor e^(2x): (y e^(2x))′ = e^(3x).'], model: 'e^x/3 + Ce^(-2x)'),
        ]),
    scenario('de_i2', 'A cooling cup of tea', _i,
        person: modelLead,
        what: 'Tea at 90 °C cools in a 20 °C room: dy/dx = −0.1(y − 20), x in minutes.',
        why: "Newton's law of cooling is used in forensics, food safety and engineering.",
        steps: <LabStep>[
          const OdeStep(id: 'de_i2_1', title: 'Solve', instructions: 'Use y(0) = 90.', equation: 'dy/dx = −0.1(y − 20)', rhs: '-0.1(y - 20)', initial: <double>[0, 90], range: (0, 30),
              hints: <String>['Let u = y − 20; then du/dx = −0.1u.'], model: '20 + 70e^(-0.1x)'),
          NumericStep(id: 'de_i2_2', title: 'Answer the question', instructions: '2 decimal places.', questions: <MathQuestion>[
            numQ('t10', 'Temperature after 10 minutes', 20 + 70 * math.exp(-1), tol: 0.02, unit: '°C'),
            numQ('t40', 'Minutes until it reaches 40 °C', -10 * math.log(20 / 70), tol: 0.02, unit: 'min'),
          ]),
        ]),
    scenario('de_i3', 'Salt in a mixing tank', _i,
        person: modelLead,
        what: 'A 100 L tank holds 10 kg of dissolved salt. Pure water flows in at 5 L/min and the mixture flows out at 5 L/min.',
        why: 'Mixing models track pollutants, medicines and chemical processes.',
        information: const <String>['Rate out = (salt per litre) × (litres per minute) = y/100 × 5 = y/20.'],
        steps: <LabStep>[
          const OdeStep(id: 'de_i3_1', title: 'Model and solve', instructions: 'y is the salt in kg; y(0) = 10.', equation: 'dy/dx = −y/20', rhs: '-y/20', initial: <double>[0, 10], range: (0, 60), model: '10e^(-x/20)'),
          NumericStep(id: 'de_i3_2', title: 'When is it nearly clean?', instructions: '2 decimal places.', questions: <MathQuestion>[
            numQ('t2', 'Minutes until 2 kg remain', 20 * math.log(5), tol: 0.02, unit: 'min'),
          ]),
        ]),
    scenario('de_i4', 'Logistic population', _i,
        person: modelLead,
        what: 'A population follows dy/dx = 0.5y(1 − y/1000), starting at 100.',
        why: 'Logistic growth adds a carrying capacity to exponential growth.',
        steps: <LabStep>[
          const OdeStep(id: 'de_i4_1', title: 'Solve', instructions: 'Find y(x) with y(0) = 100.', equation: 'dy/dx = 0.5y(1 − y/1000)', rhs: '0.5y(1 - y/1000)', initial: <double>[0, 100], range: (0, 10),
              hints: <String>['The solution has the form K/(1 + A e^(−rx)) with K = 1000.'], model: '1000/(1 + 9e^(-0.5x))'),
          NumericStep(id: 'de_i4_2', title: 'Half capacity', instructions: '3 decimal places.', questions: <MathQuestion>[
            numQ('t', 'Time when the population reaches 500', 2 * math.log(9), tol: 0.005),
          ]),
        ]),
    scenario('de_i5', 'Falling with air resistance', _i,
        what: 'A skydiver’s velocity obeys dy/dx = 9.8 − 0.2y, starting from rest.',
        why: 'Drag models give terminal velocity — used in safety design.',
        steps: <LabStep>[
          const OdeStep(id: 'de_i5_1', title: 'Solve', instructions: 'y(0) = 0.', equation: 'dy/dx = 9.8 − 0.2y', rhs: '9.8 - 0.2y', initial: <double>[0, 0], range: (0, 20), model: '49(1 - e^(-0.2x))'),
          NumericStep(id: 'de_i5_2', title: 'Interpret', instructions: '2 decimal places.', questions: <MathQuestion>[
            numQ('vt', 'Terminal velocity', 49, tol: 0.01, unit: 'm/s'),
            numQ('v5', 'Velocity after 5 s', 49 * (1 - math.exp(-1)), tol: 0.02, unit: 'm/s'),
          ]),
        ]),
    scenario('de_a1', 'Second order: distinct roots', _a,
        what: "Solve y'' − 3y' + 2y = 0.",
        why: 'Constant-coefficient equations model circuits and mechanical systems.',
        steps: <LabStep>[
          solve('de_a1_1', 'Characteristic equation', 'Solve r² − 3r + 2 = 0', 'r^2 - 3r + 2 = 0', variable: 'r', minLines: 1,
              model: <String>['(r - 1)(r - 2) = 0', 'r = 1 or r = 2']),
          const OdeStep(id: 'de_a1_2', title: 'General solution', instructions: 'Use C1 and C2.', equation: "y'' − 3y' + 2y = 0", rhs: '3p - 2y', order: 2, range: (-1, 1), model: 'C1 e^x + C2 e^(2x)'),
        ]),
    scenario('de_a2', 'Repeated roots', _a,
        what: "Solve y'' + 4y' + 4y = 0 with y(0) = 1 and y'(0) = 0.",
        why: 'Repeated roots give critically damped behaviour.',
        steps: <LabStep>[
          const OdeStep(id: 'de_a2_1', title: 'Solve the initial value problem', instructions: 'Find both constants from the conditions.', equation: "y'' + 4y' + 4y = 0", rhs: '-4p - 4y', order: 2,
              initial: <double>[0, 1, 0], range: (0, 2), hints: <String>['r = −2 twice, so y = (C1 + C2 x)e^(−2x).'], model: '(1 + 2x)e^(-2x)'),
        ]),
    scenario('de_a3', 'Simple harmonic motion', _a,
        what: "Solve y'' + 9y = 0 with y(0) = 2 and y'(0) = 3.",
        why: 'Undamped oscillation models springs, pendulums and AC circuits.',
        steps: <LabStep>[
          const OdeStep(id: 'de_a3_1', title: 'Solve', instructions: 'Complex roots ±3i give sines and cosines.', equation: "y'' + 9y = 0", rhs: '-9y', order: 2,
              initial: <double>[0, 2, 3], range: (0, 2), model: '2cos(3x) + sin(3x)'),
        ]),
    scenario('de_a4', 'Undetermined coefficients', _a,
        what: "Find the general solution of y'' + y = x.",
        why: 'Forced systems combine a natural response and a particular response.',
        steps: <LabStep>[
          const OdeStep(id: 'de_a4_1', title: 'Complementary + particular', instructions: 'Use C1 and C2.', equation: "y'' + y = x", rhs: 'x - y', order: 2, range: (-2, 2),
              hints: <String>['Try a particular solution y = Ax + B.'], model: 'C1 cos(x) + C2 sin(x) + x'),
        ]),
    scenario('de_a5', 'Damped spring', _a,
        person: modelLead,
        what: "A spring obeys y'' + 2y' + 5y = 0 with y(0) = 1 and y'(0) = −1.",
        why: 'Damping determines whether a structure settles or oscillates.',
        steps: <LabStep>[
          const OdeStep(id: 'de_a5_1', title: 'Solve', instructions: 'Roots −1 ± 2i.', equation: "y'' + 2y' + 5y = 0", rhs: '-2p - 5y', order: 2,
              initial: <double>[0, 1, -1], range: (0, 3), model: 'e^(-x)cos(2x)'),
          const NumericStep(id: 'de_a5_2', title: 'Classify', instructions: 'Compare the discriminant with zero.', questions: <MathQuestion>[
            NumberQuestion('disc', 'Discriminant b² − 4ac of r² + 2r + 5', -16, tolerance: 0),
            ChoiceQuestion('type', 'The system is', <String>['Overdamped', 'Critically damped', 'Underdamped'], 2),
          ]),
        ]),
  ],
);

// ------------------------------------------------------------ F. Applied mathematics

double get _boxX => (200 - math.sqrt(200 * 200 - 4 * 12 * 600)) / 24;
double _box(double x) => x * (30 - 2 * x) * (20 - 2 * x);
double get _npv => -10000 + 3000 / 1.08 + 4000 / math.pow(1.08, 2) + 5000 / math.pow(1.08, 3) + 2000 / math.pow(1.08, 4);

final LabSpec mathAppliedLab = LabSpec(
  id: 'ma_lab_applied',
  deptId: 'mathematics',
  majorId: 'mathematics',
  number: 6,
  title: 'Applied Mathematics',
  environment: LabEnvironment.mathsLab,
  summary: 'Client problems from business, finance, engineering, biology and computing. Model the situation, solve it with working, '
      'and answer the client’s question in their units.',
  objectives: const <String>[
    'Translate real problems into equations, systems and functions',
    'Use calculus, logarithms and finance formulas in context',
    'Interpret results and their limits for a client',
  ],
  skills: const <String>['ma_model'],
  difficulty: LabDifficulty.advanced,
  minutes: 40,
  addsToPortfolio: true,
  scenarios: <LabScenario>[
    scenario('ap_b1', 'Break-even for a bakery', _b,
        person: modelLead,
        what: 'A bakery’s fixed costs are £4,800 a month. Each cake sells for £25 and costs £13 to make. Find the break-even quantity.',
        why: 'Break-even analysis is the first question in any business plan.',
        information: const <String>['Let q be cakes sold per month. Revenue 25q; cost 4800 + 13q.'],
        steps: <LabStep>[
          solve('ap_b1_1', 'Break-even quantity', 'Revenue = cost (use q)', '25q = 4800 + 13q', variable: 'q', range: (0, 5000),
              instructions: 'First line: revenue = cost. Then solve for q.', model: <String>['25q = 4800 + 13q', '12q = 4800', 'q = 400']),
          const NumericStep(id: 'ap_b1_2', title: 'Profit forecast', instructions: 'Profit = revenue − cost.', questions: <MathQuestion>[
            NumberQuestion('p600', 'Profit at 600 cakes', 2400, tolerance: 0.5, unit: '£'),
          ]),
        ]),
    scenario('ap_b2', 'Savings with compound interest', _b,
        person: modelLead,
        what: 'A client saves £5,000 at 4% a year compounded monthly for 6 years. Compare with simple interest.',
        why: 'Compounding is the core of every savings and loan product.',
        steps: <LabStep>[
          NumericStep(id: 'ap_b2_1', title: 'Future values', instructions: 'A = P(1 + r/n)^(nt). To the nearest penny.', questions: <MathQuestion>[
            numQ('fv', 'Value with monthly compounding', compound(5000, 0.04, 12, 6), tol: 0.01, unit: '£'),
            numQ('si', 'Value with simple interest', 5000 * (1 + 0.04 * 6), tol: 0.01, unit: '£'),
            numQ('diff', 'Extra earned by compounding', compound(5000, 0.04, 12, 6) - 6200, tol: 0.02, unit: '£'),
          ]),
        ]),
    scenario('ap_b3', 'Stress in a steel rod', _b,
        what: 'A 20 mm diameter rod carries a 15 kN tensile load. Find the stress in MPa.',
        why: 'Stress = force/area is the first check on any structural member.',
        information: const <String>['Area = π r², with r in metres. 1 MPa = 10⁶ Pa.'],
        steps: <LabStep>[
          evaluate('ap_b3_1', 'Compute the stress', 'σ = F/A for F = 15 000 N, d = 20 mm', '15000/(pi*0.01^2)/10^6', tolerance: 1e-3,
              instructions: 'Show the calculation one step per line. Give the final answer in MPa (2 decimal places).',
              model: <String>['15000/(pi*0.01^2)/10^6', '15000/(pi*0.0001)/10^6', '47.75']),
        ]),
    scenario('ap_b4', 'Bacteria in a sample', _b,
        what: 'A sample of 500 bacteria doubles every 20 minutes. When will it reach 64,000?',
        why: 'Doubling-time models are used in microbiology and epidemiology.',
        steps: <LabStep>[
          solve('ap_b4_1', 'Solve for t (minutes)', '500 · 2^(t/20) = 64 000', '500*2^(t/20) = 64000', variable: 't', range: (0, 1000),
              model: <String>['2^(t/20) = 128', 't/20 = 7', 't = 140']),
        ]),
    scenario('ap_b5', 'How fast is the search?', _b,
        what: 'Estimate running costs of algorithms for a software team.',
        why: 'Growth rates decide whether software scales.',
        steps: <LabStep>[
          NumericStep(id: 'ap_b5_1', title: 'Complexity estimates', instructions: 'Use logarithms and ratios.', questions: <MathQuestion>[
            numQ('bs', 'Worst-case comparisons for binary search in 1,000,000 sorted items', (math.log(1000000) / math.ln2).floorToDouble() + 1, tol: 0),
            numQ('sq', 'An O(n²) routine takes 2 s for n = 1000. Estimated time for n = 5000', 50, tol: 0.01, unit: 's'),
            choice('grow', 'Which grows fastest for large n?', const <String>['n log n', 'n²', '1000n'], 1),
          ]),
        ]),
    scenario('ap_i1', 'A car loan', _i,
        person: modelLead,
        what: 'A client borrows £15,000 at 6% a year (0.5% a month) over 4 years. Find the monthly payment and total interest.',
        why: 'Loan maths is regulated: clients must be shown the true cost.',
        steps: <LabStep>[
          NumericStep(id: 'ap_i1_1', title: 'Loan payment', instructions: 'Payment = P·r / (1 − (1 + r)^(−n)), r = 0.005, n = 48.', questions: <MathQuestion>[
            numQ('pay', 'Monthly payment', loanPayment(15000, 0.005, 48), tol: 0.01, unit: '£'),
            numQ('int', 'Total interest paid', 48 * loanPayment(15000, 0.005, 48) - 15000, tol: 0.5, unit: '£'),
          ]),
        ]),
    scenario('ap_i2', 'A ball thrown upwards', _i,
        what: 'A ball is thrown from 1.5 m at 14 m/s: h(t) = 1.5 + 14t − 4.9t².',
        why: 'Projectile models are used in sport science and engineering safety.',
        steps: <LabStep>[
          NumericStep(
            id: 'ap_i2_1',
            title: 'Peak and landing',
            instructions: '3 decimal places. The graph shows h(t).',
            curves: const <String>['1.5 + 14x - 4.9x^2'],
            window: (0, 3.5, 0, 13),
            questions: <MathQuestion>[
              numQ('tp', 'Time of maximum height', 14 / 9.8, tol: 0.002, unit: 's'),
              numQ('hp', 'Maximum height', 11.5, tol: 0.002, unit: 'm'),
              numQ('tl', 'Time it lands', (14 + math.sqrt(196 + 4 * 4.9 * 1.5)) / 9.8, tol: 0.002, unit: 's'),
            ],
          ),
        ]),
    scenario('ap_i3', 'Production planning', _i,
        person: modelLead,
        what: 'A workshop makes chairs (x) and tables (y). Profit 30x + 40y. Constraints: x + 2y ≤ 40 (labour), 3x + 2y ≤ 60 (wood), x, y ≥ 0.',
        why: 'Linear programming allocates limited resources in industry.',
        steps: <LabStep>[
          const NumericStep(
            id: 'ap_i3_1',
            title: 'Find the best corner',
            instructions: 'Check the profit at each corner of the feasible region (the graph shows the two constraint lines).',
            curves: <String>['(40 - x)/2', '(60 - 3x)/2'],
            window: (0, 25, 0, 35),
            questions: <MathQuestion>[
              NumberQuestion('x', 'Chairs', 10, tolerance: 0),
              NumberQuestion('y', 'Tables', 15, tolerance: 0),
              NumberQuestion('p', 'Maximum profit', 900, tolerance: 0.5, unit: '£'),
            ],
          ),
        ]),
    scenario('ap_i4', 'Drug elimination', _i,
        what: 'Concentration falls as C(t) = 20e^(−0.173t) mg/L. When does it fall to 5 mg/L? (3 decimal places.)',
        why: 'Pharmacokinetic models set dosing intervals. Educational example only.',
        steps: <LabStep>[
          solve('ap_i4_1', 'Solve for t (hours)', '20e^(−0.173t) = 5', '20e^(-0.173t) = 5', variable: 't', range: (0, 100), tolerance: 1e-4,
              model: <String>['e^(-0.173t) = 0.25', '-0.173t = ln(0.25)', 't = ln(4)/0.173']),
        ]),
    scenario('ap_i5', 'Beam support reactions', _i,
        what: 'A 6 m simply supported beam carries 12 kN at 2 m from the left support A. Find the reactions at A and B.',
        why: 'Equilibrium of forces and moments is the first calculation in structural design.',
        information: const <String>['Vertical equilibrium: a + b = 12. Moments about A: 6b = 12 × 2. (a and b in kN.)'],
        steps: <LabStep>[
          system('ap_i5_1', 'Solve for the reactions', 'a + b = 12\n6b = 24', 'a + b = 12; 6b = 24', const <String, double>{'a': 8, 'b': 4},
              model: <String>['b = 4', 'a = 12 - 4', 'a = 8', 'a = 8, b = 4']),
          const NumericStep(id: 'ap_i5_2', title: 'Bending moment', instructions: 'The maximum bending moment is under the load: a × 2.', questions: <MathQuestion>[
            NumberQuestion('m', 'Maximum bending moment', 16, tolerance: 0.01, unit: 'kN·m'),
          ]),
        ]),
    scenario('ap_a1', 'Designing an open box', _a,
        person: modelLead,
        what: 'Squares of side x are cut from the corners of a 30 × 20 cm sheet and the sides folded up. Maximise the volume V = x(30 − 2x)(20 − 2x).',
        why: 'Packaging and manufacturing optimise material use this way.',
        steps: <LabStep>[
          solve('ap_a1_1', "Solve V'(x) = 0", "V'(x) = 12x² − 200x + 600 = 0 (only the value that makes a box, 0 < x < 10)", '12x^2 - 200x + 600 = 0', range: (0, 10), tolerance: 1e-3,
              instructions: 'One step per line; the last line is the x that maximises volume (3 decimal places or exact).',
              model: <String>['3x^2 - 50x + 150 = 0', 'x = (50 - sqrt(2500 - 1800))/6', 'x = (50 - sqrt(700))/6']),
          NumericStep(id: 'ap_a1_2', title: 'Maximum volume', instructions: '1 decimal place.', questions: <MathQuestion>[
            numQ('v', 'Maximum volume', _box(_boxX), tol: 0.5, unit: 'cm³'),
          ]),
        ]),
    scenario('ap_a2', 'Should the firm invest?', _a,
        person: modelLead,
        what: 'A project costs £10,000 now and returns £3,000, £4,000, £5,000 and £2,000 over the next four years. Discount at 8%.',
        why: 'Net present value is how companies decide which projects to fund.',
        steps: <LabStep>[
          evaluate('ap_a2_1', 'Net present value', 'NPV = −10000 + Σ CFₜ/1.08ᵗ', '-10000 + 3000/1.08 + 4000/1.08^2 + 5000/1.08^3 + 2000/1.08^4', tolerance: 1e-4,
              instructions: 'Show each discounted cash flow, then the NPV to the nearest penny.',
              model: <String>['-10000 + 3000/1.08 + 4000/1.08^2 + 5000/1.08^3 + 2000/1.08^4', '-10000 + 2777.78 + 3429.36 + 3969.16 + 1470.06', '1646.36']),
          NumericStep(id: 'ap_a2_2', title: 'Recommendation', instructions: 'Accept projects with a positive NPV.', questions: <MathQuestion>[
            choice('dec', 'Recommendation', const <String>['Invest', 'Do not invest'], _npv > 0 ? 0 : 1),
          ]),
        ]),
    scenario('ap_a3', 'Cost of merge sort', _a,
        what: 'Merge sort satisfies T(n) = 2T(n/2) + n with T(1) = 1. Compute T(8) and T(16) and identify the growth rate.',
        why: 'Recurrences predict the running time of divide-and-conquer software.',
        steps: <LabStep>[
          const NumericStep(id: 'ap_a3_1', title: 'Unroll the recurrence', instructions: 'T(2) = 4, T(4) = 12, …', questions: <MathQuestion>[
            NumberQuestion('t8', 'T(8)', 32, tolerance: 0),
            NumberQuestion('t16', 'T(16)', 80, tolerance: 0),
            ChoiceQuestion('o', 'Growth rate', <String>['O(n)', 'O(n log n)', 'O(n²)'], 1, explain: 'T(n) = n log₂ n + n.'),
          ]),
        ]),
    scenario('ap_a4', 'Sustainable fishing', _a,
        person: modelLead,
        what: 'A fish stock grows as dP/dt = 0.4P(1 − P/500) − 30 under a harvest of 30 tonnes a year. Find the equilibrium stock levels.',
        why: 'Harvesting models set fishing quotas.',
        steps: <LabStep>[
          solve('ap_a4_1', 'Equilibria', '0.4P(1 − P/500) − 30 = 0', '0.4P(1 - P/500) - 30 = 0', variable: 'P', range: (0, 600), tolerance: 1e-4,
              model: <String>['0.4P - 0.0008P^2 - 30 = 0', 'P^2 - 500P + 37500 = 0', 'P = (500 ± sqrt(250000 - 150000))/2', 'P = 250 ± 50sqrt(10)']),
          const NumericStep(id: 'ap_a4_2', title: 'Which is stable?', instructions: 'Between the equilibria dP/dt > 0; above the upper one it is negative.', questions: <MathQuestion>[
            ChoiceQuestion('st', 'The stable equilibrium is', <String>['the lower one', 'the upper one'], 1),
          ]),
        ]),
    scenario('ap_a5', 'Charging a capacitor', _a,
        what: 'A capacitor charges as V(t) = 12(1 − e^(−t)) volts (RC = 1 s). When does it reach 9 V? (3 decimal places or exact.)',
        why: 'RC timing sets delays in every electronic device.',
        steps: <LabStep>[
          solve('ap_a5_1', 'Solve for t', '12(1 − e^(−t)) = 9', '12(1 - e^(-t)) = 9', variable: 't', range: (0, 20), tolerance: 1e-4,
              model: <String>['1 - e^(-t) = 0.75', 'e^(-t) = 0.25', '-t = ln(0.25)', 't = -ln(0.25)']),
          NumericStep(id: 'ap_a5_2', title: 'Voltage at 2 s', instructions: '3 decimal places.', questions: <MathQuestion>[
            numQ('v2', 'V(2)', 12 * (1 - math.exp(-2)), tol: 0.002, unit: 'V'),
          ]),
        ]),
  ],
);
