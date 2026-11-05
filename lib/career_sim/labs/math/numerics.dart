/// Reference calculations used to mark statistics, linear algebra and
/// applied problems. Answers in the labs are computed with these from the
/// scenario's own data, never typed in by hand.
library;

import 'dart:math' as math;

// ------------------------------------------------------------ statistics

abstract final class Stats {
  static double sum(List<double> xs) => xs.fold<double>(0, (double a, double b) => a + b);
  static double mean(List<double> xs) => sum(xs) / xs.length;

  static double median(List<double> xs) {
    final List<double> s = List<double>.of(xs)..sort();
    final int n = s.length;
    return n.isOdd ? s[n ~/ 2] : (s[n ~/ 2 - 1] + s[n ~/ 2]) / 2;
  }

  /// Most frequent values.
  static List<double> modes(List<double> xs) {
    final Map<double, int> c = <double, int>{};
    for (final double x in xs) {
      c[x] = (c[x] ?? 0) + 1;
    }
    final int top = c.values.reduce(math.max);
    return (c.entries.where((MapEntry<double, int> e) => e.value == top).map((MapEntry<double, int> e) => e.key).toList())..sort();
  }

  /// Sample variance (n − 1).
  static double variance(List<double> xs) {
    final double m = mean(xs);
    return xs.fold<double>(0, (double a, double x) => a + (x - m) * (x - m)) / (xs.length - 1);
  }

  static double populationVariance(List<double> xs) {
    final double m = mean(xs);
    return xs.fold<double>(0, (double a, double x) => a + (x - m) * (x - m)) / xs.length;
  }

  static double sd(List<double> xs) => math.sqrt(variance(xs));

  /// Quartiles by the median-of-halves method (median excluded for odd n).
  static (double, double) quartiles(List<double> xs) {
    final List<double> s = List<double>.of(xs)..sort();
    final int n = s.length;
    final List<double> lower = s.sublist(0, n ~/ 2);
    final List<double> upper = s.sublist(n.isOdd ? n ~/ 2 + 1 : n ~/ 2);
    return (median(lower), median(upper));
  }

  static double correlation(List<double> x, List<double> y) {
    final double mx = mean(x);
    final double my = mean(y);
    double sxy = 0, sxx = 0, syy = 0;
    for (int i = 0; i < x.length; i++) {
      sxy += (x[i] - mx) * (y[i] - my);
      sxx += (x[i] - mx) * (x[i] - mx);
      syy += (y[i] - my) * (y[i] - my);
    }
    return sxy / math.sqrt(sxx * syy);
  }

  /// Least-squares line y = a + b·x → (a, b).
  static (double, double) regression(List<double> x, List<double> y) {
    final double mx = mean(x);
    final double my = mean(y);
    double sxy = 0, sxx = 0;
    for (int i = 0; i < x.length; i++) {
      sxy += (x[i] - mx) * (y[i] - my);
      sxx += (x[i] - mx) * (x[i] - mx);
    }
    final double b = sxy / sxx;
    return (my - b * mx, b);
  }

  /// erf by Abramowitz & Stegun 7.1.26 (error < 1.5e-7).
  static double erf(double x) {
    final double sign = x < 0 ? -1 : 1;
    final double ax = x.abs();
    const double p = 0.3275911;
    const List<double> a = <double>[0.254829592, -0.284496736, 1.421413741, -1.453152027, 1.061405429];
    final double t = 1 / (1 + p * ax);
    final double y = 1 - (((((a[4] * t + a[3]) * t) + a[2]) * t + a[1]) * t + a[0]) * t * math.exp(-ax * ax);
    return sign * y;
  }

  /// Standard normal cumulative probability P(Z ≤ z).
  static double normalCdf(double z) => 0.5 * (1 + erf(z / math.sqrt2));

  static double choose(int n, int k) {
    double r = 1;
    for (int i = 1; i <= k; i++) {
      r = r * (n - k + i) / i;
    }
    return r;
  }

  static double binomialPmf(int n, int k, double p) => choose(n, k) * math.pow(p, k) * math.pow(1 - p, n - k);

  static double binomialCdf(int n, int k, double p) {
    double s = 0;
    for (int i = 0; i <= k; i++) {
      s += binomialPmf(n, i, p);
    }
    return s;
  }

  /// Two-sided 95% critical values of Student's t, df 1–30 (standard tables).
  static const List<double> t975 = <double>[
    12.706, 4.303, 3.182, 2.776, 2.571, 2.447, 2.365, 2.306, 2.262, 2.228, //
    2.201, 2.179, 2.160, 2.145, 2.131, 2.120, 2.110, 2.101, 2.093, 2.086, //
    2.080, 2.074, 2.069, 2.064, 2.060, 2.056, 2.052, 2.048, 2.045, 2.042,
  ];

  static double tCritical95(int df) => t975[df - 1];

  /// Upper 5% critical values of chi-square, df 1–10 (standard tables).
  static const List<double> chi95 = <double>[3.841, 5.991, 7.815, 9.488, 11.070, 12.592, 14.067, 15.507, 16.919, 18.307];

  static double chiSquare(List<double> observed, List<double> expected) {
    double s = 0;
    for (int i = 0; i < observed.length; i++) {
      s += (observed[i] - expected[i]) * (observed[i] - expected[i]) / expected[i];
    }
    return s;
  }

  /// One-sample t statistic.
  static double tOneSample(List<double> xs, double mu0) => (mean(xs) - mu0) / (sd(xs) / math.sqrt(xs.length));

  /// Pooled two-sample t statistic and its degrees of freedom.
  static (double, int) tPooled(List<double> a, List<double> b) {
    final int na = a.length, nb = b.length;
    final double sp2 = ((na - 1) * variance(a) + (nb - 1) * variance(b)) / (na + nb - 2);
    return ((mean(a) - mean(b)) / math.sqrt(sp2 * (1 / na + 1 / nb)), na + nb - 2);
  }
}

// ------------------------------------------------------------ matrices

typedef Matrix = List<List<double>>;

abstract final class Mat {
  static Matrix mul(Matrix a, Matrix b) => _clean(<List<double>>[
        for (int i = 0; i < a.length; i++)
          <double>[
            for (int j = 0; j < b.first.length; j++)
              <double>[for (int k = 0; k < b.length; k++) a[i][k] * b[k][j]].fold<double>(0, (double s, double v) => s + v),
          ],
      ]);

  static Matrix add(Matrix a, Matrix b, [double sb = 1]) => <List<double>>[
        for (int i = 0; i < a.length; i++) <double>[for (int j = 0; j < a[i].length; j++) a[i][j] + sb * b[i][j]],
      ];

  static Matrix scale(Matrix a, double k) => <List<double>>[
        for (final List<double> r in a) <double>[for (final double v in r) k * v],
      ];

  static Matrix transpose(Matrix a) => <List<double>>[
        for (int j = 0; j < a.first.length; j++) <double>[for (int i = 0; i < a.length; i++) a[i][j]],
      ];

  static double det(Matrix a) {
    final int n = a.length;
    if (n == 1) return a[0][0];
    if (n == 2) return a[0][0] * a[1][1] - a[0][1] * a[1][0];
    double d = 0;
    for (int j = 0; j < n; j++) {
      final Matrix minor = <List<double>>[
        for (int i = 1; i < n; i++) <double>[for (int k = 0; k < n; k++) if (k != j) a[i][k]],
      ];
      d += (j.isEven ? 1 : -1) * a[0][j] * det(minor);
    }
    return d;
  }

  /// Inverse by Gauss–Jordan elimination.
  static Matrix inverse(Matrix a) {
    final int n = a.length;
    final Matrix m = <List<double>>[
      for (int i = 0; i < n; i++) <double>[...a[i], for (int j = 0; j < n; j++) i == j ? 1.0 : 0.0],
    ];
    for (int c = 0; c < n; c++) {
      int p = c;
      for (int r = c + 1; r < n; r++) {
        if (m[r][c].abs() > m[p][c].abs()) p = r;
      }
      if (m[p][c].abs() < 1e-12) throw ArgumentError('Matrix is singular.');
      final List<double> t = m[c];
      m[c] = m[p];
      m[p] = t;
      final double piv = m[c][c];
      m[c] = <double>[for (final double v in m[c]) v / piv];
      for (int r = 0; r < n; r++) {
        if (r == c) continue;
        final double f = m[r][c];
        m[r] = <double>[for (int k = 0; k < 2 * n; k++) m[r][k] - f * m[c][k]];
      }
    }
    return _clean(<List<double>>[for (final List<double> r in m) r.sublist(n)]);
  }

  /// Reduced row echelon form.
  static Matrix rref(Matrix a) {
    final Matrix m = <List<double>>[for (final List<double> r in a) List<double>.of(r)];
    int lead = 0;
    final int rows = m.length, cols = m.first.length;
    for (int r = 0; r < rows && lead < cols; r++) {
      int i = r;
      while (m[i][lead].abs() < 1e-12) {
        i++;
        if (i == rows) {
          i = r;
          lead++;
          if (lead == cols) return _clean(m);
        }
      }
      final List<double> t = m[i];
      m[i] = m[r];
      m[r] = t;
      final double lv = m[r][lead];
      m[r] = <double>[for (final double v in m[r]) v / lv];
      for (int k = 0; k < rows; k++) {
        if (k == r) continue;
        final double f = m[k][lead];
        m[k] = <double>[for (int c = 0; c < cols; c++) m[k][c] - f * m[r][c]];
      }
      lead++;
    }
    return _clean(m);
  }

  static Matrix _clean(Matrix m) => <List<double>>[
        for (final List<double> r in m) <double>[for (final double v in r) v.abs() < 1e-10 ? 0 : v],
      ];

  static int rank(Matrix a) => rref(a).where((List<double> r) => r.any((double v) => v.abs() > 1e-9)).length;

  /// Real eigenvalues of a 2×2 matrix, ascending.
  static List<double> eigen2(Matrix a) {
    final double tr = a[0][0] + a[1][1];
    final double d = det(a);
    final double disc = tr * tr - 4 * d;
    if (disc < 0) return <double>[];
    final double s = math.sqrt(disc);
    return <double>[(tr - s) / 2, (tr + s) / 2];
  }

  static Matrix solve(Matrix a, List<double> b) => mul(inverse(a), <List<double>>[for (final double v in b) <double>[v]]);
}

// ------------------------------------------------------------ calculus

/// Composite Simpson's rule.
double simpson(double Function(double) f, double a, double b, {int n = 2000}) {
  final double h = (b - a) / n;
  double s = f(a) + f(b);
  for (int i = 1; i < n; i++) {
    s += (i.isOdd ? 4 : 2) * f(a + i * h);
  }
  return s * h / 3;
}

/// Euler's method for y' = f(x, y); returns y after [steps] steps of size [h].
double euler(double Function(double, double) f, double x0, double y0, double h, int steps) {
  double x = x0, y = y0;
  for (int i = 0; i < steps; i++) {
    y += h * f(x, y);
    x += h;
  }
  return y;
}

/// Future value with compound interest.
double compound(double p, double rate, int perYear, double years) => p * math.pow(1 + rate / perYear, perYear * years);

/// Level loan payment per period.
double loanPayment(double principal, double ratePerPeriod, int periods) =>
    principal * ratePerPeriod / (1 - math.pow(1 + ratePerPeriod, -periods));
