/// A small computer-algebra core for the maths labs: parses what students
/// type (`2x^2 - 3(x+1)`, `sin x`, `sqrt(2)`, `x < 3 or x > 5`), evaluates
/// it, and decides equivalence numerically. Used to check every line of a
/// student's working, not only the final answer.
library;

import 'dart:math' as math;

class ExprParseException implements Exception {
  ExprParseException(this.message, [this.position = -1]);
  final String message;
  final int position;
  @override
  String toString() => message;
}

// ------------------------------------------------------------ AST

abstract class Expr {
  const Expr();
  double eval(Map<String, double> env);
  Set<String> get variables;

  /// Canonical text, fully bracketed where precedence could be unclear.
  String show();
  @override
  String toString() => show();
}

class Num extends Expr {
  const Num(this.value);
  final double value;
  @override
  double eval(Map<String, double> env) => value;
  @override
  Set<String> get variables => const <String>{};
  @override
  String show() => fmtNum(value);
}

class Var extends Expr {
  const Var(this.name);
  final String name;
  @override
  double eval(Map<String, double> env) {
    final double? v = env[name];
    if (v == null) throw ExprParseException('Unknown symbol "$name".');
    return v;
  }

  @override
  Set<String> get variables => <String>{name};
  @override
  String show() => name;
}

class Neg extends Expr {
  const Neg(this.a);
  final Expr a;
  @override
  double eval(Map<String, double> env) => -a.eval(env);
  @override
  Set<String> get variables => a.variables;
  @override
  String show() => '-${_wrap(a, 3)}';
}

class Bin extends Expr {
  const Bin(this.op, this.a, this.b);
  final String op;
  final Expr a;
  final Expr b;

  @override
  double eval(Map<String, double> env) {
    final double x = a.eval(env);
    final double y = b.eval(env);
    switch (op) {
      case '+':
        return x + y;
      case '-':
        return x - y;
      case '*':
        return x * y;
      case '/':
        return x / y;
      case '^':
        if (x < 0 && y != y.roundToDouble()) {
          // Real odd roots of negatives, e.g. (-8)^(1/3).
          final double inv = 1 / y;
          if ((inv - inv.round()).abs() < 1e-9 && inv.round().isOdd) return -math.pow(-x, y).toDouble();
          return double.nan;
        }
        return math.pow(x, y).toDouble();
    }
    throw StateError(op);
  }

  @override
  Set<String> get variables => <String>{...a.variables, ...b.variables};

  int get precedence => switch (op) { '+' || '-' => 1, '*' || '/' => 2, _ => 4 };

  @override
  String show() {
    final int p = precedence;
    if (op == '^') return '${_wrap(a, 5)}^${_wrap(b, 5)}';
    final String right = (op == '-' || op == '/') ? _wrap(b, p + 1) : _wrap(b, p);
    return '${_wrap(a, p)} $op $right';
  }
}

class Call extends Expr {
  const Call(this.fn, this.a);
  final String fn;
  final Expr a;

  @override
  double eval(Map<String, double> env) {
    final double x = a.eval(env);
    return switch (fn) {
      'sin' => math.sin(x),
      'cos' => math.cos(x),
      'tan' => math.tan(x),
      'asin' => math.asin(x),
      'acos' => math.acos(x),
      'atan' => math.atan(x),
      'sinh' => (math.exp(x) - math.exp(-x)) / 2,
      'cosh' => (math.exp(x) + math.exp(-x)) / 2,
      'tanh' => (math.exp(x) - math.exp(-x)) / (math.exp(x) + math.exp(-x)),
      'exp' => math.exp(x),
      'ln' => x > 0 ? math.log(x) : double.nan,
      'log' => x > 0 ? math.log(x) / math.ln10 : double.nan,
      'sqrt' => x >= 0 ? math.sqrt(x) : double.nan,
      'abs' => x.abs(),
      'fact' => _factorial(x),
      _ => throw StateError(fn),
    };
  }

  @override
  Set<String> get variables => a.variables;

  @override
  String show() => fn == 'abs' ? '|${a.show()}|' : (fn == 'fact' ? '${_wrap(a, 5)}!' : '$fn(${a.show()})');
}

double _factorial(double x) {
  if (x < 0 || x != x.roundToDouble() || x > 170) return double.nan;
  double r = 1;
  for (int i = 2; i <= x; i++) {
    r *= i;
  }
  return r;
}

String _wrap(Expr e, int minPrec) {
  final int p = switch (e) { Bin() => e.precedence, Neg() => 3, _ => 9 };
  return p < minPrec ? '(${e.show()})' : e.show();
}

String fmtNum(double v) {
  if (v.isNaN) return 'undefined';
  if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
  String s = v.toStringAsFixed(6);
  s = s.replaceFirst(RegExp(r'0+$'), '');
  return s.endsWith('.') ? s.substring(0, s.length - 1) : s;
}

// ------------------------------------------------------------ relations

enum RelOp {
  eq('='),
  lt('<'),
  le('≤'),
  gt('>'),
  ge('≥');

  const RelOp(this.symbol);
  final String symbol;

  bool test(double a, double b, double tol) => switch (this) {
        RelOp.eq => (a - b).abs() <= tol,
        RelOp.lt => a < b - tol,
        RelOp.le => a <= b + tol,
        RelOp.gt => a > b + tol,
        RelOp.ge => a >= b - tol,
      };
}

/// `e0 op0 e1 op1 e2 …` (a chain like `-2 < x ≤ 5` is allowed).
class Relation {
  const Relation(this.parts, this.ops);
  final List<Expr> parts;
  final List<RelOp> ops;

  bool get isEquation => ops.length == 1 && ops.first == RelOp.eq;
  bool get isInequality => ops.isNotEmpty && ops.every((RelOp o) => o != RelOp.eq);

  Set<String> get variables => <String>{for (final Expr e in parts) ...e.variables};

  /// Whether the relation holds at [env]; null when undefined there.
  bool? holds(Map<String, double> env, {double tol = 1e-9}) {
    final List<double> v = <double>[];
    for (final Expr e in parts) {
      final double x = e.eval(env);
      if (!x.isFinite) return null;
      v.add(x);
    }
    for (int i = 0; i < ops.length; i++) {
      final double scale = 1 + v[i].abs() + v[i + 1].abs();
      if (!ops[i].test(v[i], v[i + 1], tol * scale)) return false;
    }
    return true;
  }

  /// lhs − rhs of an equation.
  Expr get difference => Bin('-', parts[0], parts[1]);

  String show() {
    final StringBuffer b = StringBuffer(parts.first.show());
    for (int i = 0; i < ops.length; i++) {
      b.write(' ${ops[i].symbol} ${parts[i + 1].show()}');
    }
    return b.toString();
  }

  @override
  String toString() => show();
}

/// A disjunction of relations: `x < -2 or x > 3`, `x = 1, x = 4`.
class Statement {
  const Statement(this.alternatives);
  final List<Relation> alternatives;

  bool? holds(Map<String, double> env) {
    bool undefined = true;
    for (final Relation r in alternatives) {
      final bool? h = r.holds(env);
      if (h == true) return true;
      if (h == false) undefined = false;
    }
    return undefined ? null : false;
  }

  Set<String> get variables => <String>{for (final Relation r in alternatives) ...r.variables};
  String show() => alternatives.map((Relation r) => r.show()).join(' or ');
}

// ------------------------------------------------------------ parser

const Set<String> functionNames = <String>{
  'asin', 'acos', 'atan', 'sinh', 'cosh', 'tanh', 'sin', 'cos', 'tan', 'exp', 'ln', 'log', 'sqrt', 'abs',
};

class _Tok {
  _Tok(this.kind, this.text, this.pos, [this.value = 0]);
  final String kind; // num, id, fn, op, rel, lp, rp, bar, comma, or, end
  final String text;
  final int pos;
  final double value;
  @override
  String toString() => text;
}

List<_Tok> _lex(String src) {
  String s = src
      .replaceAll('−', '-')
      .replaceAll('–', '-')
      .replaceAll('×', '*')
      .replaceAll('·', '*')
      .replaceAll('÷', '/')
      .replaceAll('²', '^2')
      .replaceAll('³', '^3')
      .replaceAll('√', 'sqrt')
      .replaceAll('π', 'pi')
      .replaceAll('<=', '≤')
      .replaceAll('>=', '≥')
      .replaceAll('=<', '≤')
      .replaceAll('=>', '≥')
      .replaceAll('**', '^')
      .replaceAll('[', '(')
      .replaceAll(']', ')')
      .replaceAll('{', '(')
      .replaceAll('}', ')');
  final List<_Tok> out = <_Tok>[];
  int i = 0;
  bool isLetter(String c) => RegExp(r'[A-Za-z]').hasMatch(c);
  bool isDigit(String c) => RegExp(r'[0-9]').hasMatch(c);
  while (i < s.length) {
    final String c = s[i];
    if (c.trim().isEmpty) {
      i++;
      continue;
    }
    if (isDigit(c) || (c == '.' && i + 1 < s.length && isDigit(s[i + 1]))) {
      final int st = i;
      while (i < s.length && (isDigit(s[i]) || s[i] == '.')) {
        i++;
      }
      // Thousands separators like 1,000 are not allowed (comma separates answers).
      final String t = s.substring(st, i);
      final double? v = double.tryParse(t);
      if (v == null) throw ExprParseException('"$t" is not a number.', st);
      out.add(_Tok('num', t, st, v));
      continue;
    }
    if (isLetter(c)) {
      final int st = i;
      while (i < s.length && isLetter(s[i])) {
        i++;
      }
      final String word = s.substring(st, i);
      if (word == 'or' || word == 'and') {
        out.add(_Tok('or', word, st));
        continue;
      }
      // Split a run of letters into function names, constants and single-letter variables.
      int k = 0;
      while (k < word.length) {
        final String rest = word.substring(k);
        String? fn;
        for (final String f in functionNames) {
          if (rest.startsWith(f) && (fn == null || f.length > fn.length)) fn = f;
        }
        if (fn != null) {
          out.add(_Tok('fn', fn, st + k));
          k += fn.length;
          continue;
        }
        if (rest.startsWith('pi')) {
          out.add(_Tok('num', 'π', st + k, math.pi));
          k += 2;
          continue;
        }
        String name = word[k];
        k++;
        // Subscript digits belong to the name: C1, C2.
        if (k == word.length) {
          int j = i;
          while (j < s.length && isDigit(s[j]) && name.toUpperCase() == name) {
            j++;
          }
          if (j > i) {
            name += s.substring(i, j);
            i = j;
          }
        }
        if (name == 'e') {
          out.add(_Tok('num', 'e', st + k - 1, math.e));
        } else {
          out.add(_Tok('id', name, st + k - 1));
        }
      }
      continue;
    }
    if ('+-*/^!'.contains(c)) {
      out.add(_Tok('op', c, i));
      i++;
      continue;
    }
    if ('=<>≤≥'.contains(c)) {
      out.add(_Tok('rel', c, i));
      i++;
      continue;
    }
    if (c == '(') {
      out.add(_Tok('lp', c, i));
      i++;
      continue;
    }
    if (c == ')') {
      out.add(_Tok('rp', c, i));
      i++;
      continue;
    }
    if (c == '|') {
      out.add(_Tok('bar', c, i));
      i++;
      continue;
    }
    if (c == ',' || c == ';') {
      out.add(_Tok('comma', c, i));
      i++;
      continue;
    }
    throw ExprParseException('Unexpected "$c".', i);
  }
  out.add(_Tok('end', '', s.length));
  return out;
}

class _Parser {
  _Parser(String src) : t = _lex(src);
  final List<_Tok> t;
  int i = 0;
  int _barDepth = 0;

  _Tok get peek => t[i];
  _Tok next() => t[i++];

  bool _isOp(String c) => peek.kind == 'op' && peek.text == c;

  void expectEnd() {
    if (peek.kind != 'end') throw ExprParseException('Unexpected "${peek.text}".', peek.pos);
  }

  Expr expr() {
    Expr a = term();
    while (_isOp('+') || _isOp('-')) {
      final String op = next().text;
      a = Bin(op, a, term());
    }
    return a;
  }

  bool get _startsFactor =>
      peek.kind == 'num' || peek.kind == 'id' || peek.kind == 'fn' || peek.kind == 'lp' || (peek.kind == 'bar' && _barDepth == 0);

  Expr term() {
    Expr a = unary();
    while (true) {
      if (_isOp('*') || _isOp('/')) {
        final String op = next().text;
        a = Bin(op, a, unary());
      } else if (_startsFactor) {
        a = Bin('*', a, power());
      } else {
        return a;
      }
    }
  }

  Expr unary() {
    if (_isOp('-')) {
      next();
      final Expr u = unary();
      return u is Num ? Num(-u.value) : Neg(u);
    }
    if (_isOp('+')) {
      next();
      return unary();
    }
    return power();
  }

  Expr power() {
    Expr base = postfix();
    if (_isOp('^')) {
      next();
      return Bin('^', base, unary());
    }
    return base;
  }

  Expr postfix() {
    Expr a = primary();
    while (_isOp('!')) {
      next();
      a = Call('fact', a);
    }
    return a;
  }

  Expr primary() {
    final _Tok k = peek;
    switch (k.kind) {
      case 'num':
        next();
        return Num(k.value);
      case 'id':
        next();
        return Var(k.text);
      case 'fn':
        next();
        // sin^2 x style is not supported; sin x and sin(x) are.
        if (peek.kind == 'lp') {
          next();
          final Expr inner = expr();
          _close();
          return Call(k.text, inner);
        }
        return Call(k.text, power());
      case 'lp':
        next();
        final Expr inner = expr();
        _close();
        return inner;
      case 'bar':
        next();
        _barDepth++;
        final Expr inner = expr();
        _barDepth--;
        if (peek.kind != 'bar') throw ExprParseException('Missing closing |.', peek.pos);
        next();
        return Call('abs', inner);
      case 'end':
        throw ExprParseException('The expression ends too early.', k.pos);
      default:
        throw ExprParseException('Unexpected "${k.text}".', k.pos);
    }
  }

  void _close() {
    if (peek.kind != 'rp') throw ExprParseException('Missing closing bracket.', peek.pos);
    next();
  }

  RelOp _relop() {
    final String a = next().text;
    if (a == '=') return RelOp.eq;
    if (a == '≤') return RelOp.le;
    if (a == '≥') return RelOp.ge;
    if (peek.kind == 'rel' && peek.text == '=') {
      next();
      return a == '<' ? RelOp.le : RelOp.ge;
    }
    return a == '<' ? RelOp.lt : RelOp.gt;
  }

  List<Relation> relation({Expr? lhsDefault}) {
    final List<Expr> parts = <Expr>[expr()];
    final List<RelOp> ops = <RelOp>[];
    while (peek.kind == 'rel') {
      ops.add(_relop());
      parts.add(expr());
    }
    if (ops.isEmpty && lhsDefault != null) return <Relation>[Relation(<Expr>[lhsDefault, parts.first], const <RelOp>[RelOp.eq])];
    return <Relation>[Relation(parts, ops)];
  }
}

/// Parses an expression such as `3x^2 - 2(x + 1)`.
Expr parseExpr(String src) {
  if (src.trim().isEmpty) throw ExprParseException('Enter an expression.');
  final _Parser p = _Parser(src);
  final Expr e = p.expr();
  p.expectEnd();
  return e;
}

/// Parses `2x + 3 = 11`, `x ≤ 4`, `-1 < x < 5`.
Relation parseRelation(String src) {
  final Statement s = parseStatement(src);
  if (s.alternatives.length != 1) throw ExprParseException('Write a single equation or inequality on this line.');
  return s.alternatives.first;
}

/// Parses relations joined by "or", commas or semicolons. Bare values are
/// read as `lhsDefault = value` (so `x = 2, -3` means x = 2 or x = −3).
Statement parseStatement(String src, {String? defaultVariable}) {
  final String s = src.trim().replaceAll('+/-', '±').replaceAll('+-', '±');
  if (s.isEmpty) throw ExprParseException('Enter an answer.');
  final int pm = '±'.allMatches(s).length;
  if (pm > 1) throw ExprParseException('Use ± at most once per line.');
  if (pm == 1) {
    final Statement plus = parseStatement(s.replaceFirst('±', '+'), defaultVariable: defaultVariable);
    final Statement minus = parseStatement(s.replaceFirst('±', '-'), defaultVariable: defaultVariable);
    return Statement(<Relation>[...plus.alternatives, ...minus.alternatives]);
  }
  final _Parser p = _Parser(s);
  final List<Relation> alts = <Relation>[];
  final Expr? def = defaultVariable == null ? null : Var(defaultVariable);
  alts.addAll(p.relation(lhsDefault: def));
  while (p.peek.kind == 'comma' || p.peek.kind == 'or') {
    p.next();
    alts.addAll(p.relation(lhsDefault: def));
  }
  p.expectEnd();
  return Statement(alts);
}

/// A plain number, allowing arithmetic (`1/3`, `2*pi`, `sqrt(2)`).
double? parseNumeric(String src) {
  try {
    final Expr e = parseExpr(src.replaceAll(',', ''));
    if (e.variables.isNotEmpty) return null;
    final double v = e.eval(const <String, double>{});
    return v.isFinite ? v : null;
  } on ExprParseException {
    return null;
  }
}

// ------------------------------------------------------------ numerics

bool close(double a, double b, {double rel = 1e-6, double abs = 1e-9}) => (a - b).abs() <= abs + rel * math.max(a.abs(), b.abs());

/// Evaluates [e] at [x] for variable [v]; NaN when undefined.
double at(Expr e, String v, double x, [Map<String, double> extra = const <String, double>{}]) {
  try {
    return e.eval(<String, double>{...extra, v: x});
  } on ExprParseException {
    return double.nan;
  }
}

/// Whether two expressions agree at many sample points of their variables.
bool equivalent(Expr a, Expr b, {Map<String, (double, double)> ranges = const <String, (double, double)>{}, int seed = 7, double rel = 1e-6}) {
  final Set<String> vars = <String>{...a.variables, ...b.variables};
  final math.Random r = math.Random(seed);
  int valid = 0;
  for (int k = 0; k < 60 && valid < 14; k++) {
    final Map<String, double> env = <String, double>{
      for (final String v in vars) v: _sample(r, ranges[v] ?? (-3.0, 3.0)),
    };
    final double x;
    final double y;
    try {
      x = a.eval(env);
      y = b.eval(env);
    } on ExprParseException {
      return false;
    }
    if (!x.isFinite && !y.isFinite) continue;
    if (x.isFinite != y.isFinite) {
      // One side is undefined where the other is not (a removed or added discontinuity): skip
      // isolated points but count them.
      continue;
    }
    if (!close(x, y, rel: rel, abs: 1e-7)) return false;
    valid++;
  }
  return valid >= 8;
}

double _sample(math.Random r, (double, double) range) {
  final double v = range.$1 + r.nextDouble() * (range.$2 - range.$1);
  return v;
}

/// Numerical derivative d/dv of [e] at [x].
double derivativeAt(Expr e, String v, double x, [Map<String, double> extra = const <String, double>{}]) {
  final double h = 1e-5 * math.max(1, x.abs());
  return (at(e, v, x + h, extra) - at(e, v, x - h, extra)) / (2 * h);
}

double secondDerivativeAt(Expr e, String v, double x, [Map<String, double> extra = const <String, double>{}]) {
  final double h = 1e-3 * math.max(1, x.abs());
  return (at(e, v, x + h, extra) - 2 * at(e, v, x, extra) + at(e, v, x - h, extra)) / (h * h);
}

/// Real roots of f(v) = 0 on [lo, hi]; null when f is zero everywhere
/// (an identity such as 0 = 0).
List<double>? roots(Expr f, String v, double lo, double hi) {
  const int n = 6000;
  final double step = (hi - lo) / n;
  final List<double> xs = <double>[for (int k = 0; k <= n; k++) lo + k * step];
  final List<double> ys = <double>[for (final double x in xs) at(f, v, x)];
  // An identity (0 = 0 after rearranging) is zero, up to rounding, everywhere.
  final int zeros = ys.where((double y) => y.isFinite && y.abs() <= 1e-9).length;
  final int finite = ys.where((double y) => y.isFinite).length;
  if (finite > 0 && zeros > finite * 0.9) return null;
  final List<double> found = <double>[];
  void add(double r) {
    if (r < lo - 1e-9 || r > hi + 1e-9) return;
    final double fr = at(f, v, r);
    if (!fr.isFinite) return;
    final double local = <double>[at(f, v, r - 1e-3), at(f, v, r + 1e-3), 1].where((double y) => y.isFinite).fold<double>(0, (double m, double y) => math.max(m, y.abs()));
    if (fr.abs() > 1e-6 * (1 + local)) return;
    final double rr = _snap(r);
    if (!found.any((double q) => (q - rr).abs() < 1e-6 * (1 + q.abs()))) found.add(rr);
  }

  for (int k = 0; k < n; k++) {
    final double a = ys[k];
    final double b = ys[k + 1];
    if (!a.isFinite || !b.isFinite) continue;
    if (a == 0) {
      add(xs[k]);
      continue;
    }
    if ((a < 0) != (b < 0) && b != 0) {
      double l = xs[k];
      double h = xs[k + 1];
      double fl = a;
      for (int it = 0; it < 80; it++) {
        final double m = (l + h) / 2;
        final double fm = at(f, v, m);
        if (!fm.isFinite) break;
        if ((fm < 0) == (fl < 0)) {
          l = m;
          fl = fm;
        } else {
          h = m;
        }
      }
      add((l + h) / 2);
    }
  }
  // Touching roots (double roots): local minima of |f| near zero.
  for (int k = 1; k < n; k++) {
    final double a = ys[k - 1].abs();
    final double b = ys[k].abs();
    final double c = ys[k + 1].abs();
    if (!(a.isFinite && b.isFinite && c.isFinite)) continue;
    if (b <= a && b <= c && (ys[k - 1] < 0) == (ys[k + 1] < 0)) {
      double l = xs[k - 1];
      double h = xs[k + 1];
      for (int it = 0; it < 100; it++) {
        final double m1 = l + (h - l) / 3;
        final double m2 = h - (h - l) / 3;
        if (at(f, v, m1).abs() < at(f, v, m2).abs()) {
          h = m2;
        } else {
          l = m1;
        }
      }
      final double m = (l + h) / 2;
      final double fm = at(f, v, m);
      final double local = math.max(ys[k - 1].abs(), ys[k + 1].abs());
      if (fm.isFinite && fm.abs() <= 1e-9 * (1 + local)) add(m);
    }
  }
  found.sort();
  return found;
}

/// Rounds values that are within floating error of a simple fraction.
double _snap(double r) {
  for (final int d in <int>[1, 2, 3, 4, 5, 6, 8, 10, 12]) {
    final double n = (r * d).roundToDouble();
    if ((r * d - n).abs() < 1e-7) return n / d;
  }
  return r;
}

bool sameSet(List<double> a, List<double> b, {double tol = 1e-5}) {
  if (a.length != b.length) return false;
  for (final double x in a) {
    if (!b.any((double y) => (x - y).abs() <= tol * (1 + y.abs()))) return false;
  }
  return true;
}

String showSet(List<double> xs, String v) => xs.isEmpty ? 'no solution' : xs.map((double x) => '$v = ${fmtNum(x)}').join(' or ');
