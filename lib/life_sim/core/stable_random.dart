/// Deterministic helpers so game outcomes are reproducible and testable on
/// every platform (Dart's `Random(seed)` is not guaranteed identical on web).
library;

/// FNV-1a 32-bit hash of [input].
int stableHash(String input) {
  int h = 0x811C9DC5;
  for (final int c in input.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

/// Small xorshift32 generator.
class StableRandom {
  StableRandom(int seed) : _s = (seed == 0 ? 0x9E3779B9 : seed) & 0xFFFFFFFF;

  factory StableRandom.fromString(String seed) => StableRandom(stableHash(seed));

  int _s;

  int nextInt(int max) {
    if (max <= 1) return 0;
    _s ^= (_s << 13) & 0xFFFFFFFF;
    _s ^= _s >> 17;
    _s ^= (_s << 5) & 0xFFFFFFFF;
    _s &= 0xFFFFFFFF;
    return _s % max;
  }

  /// 0.0 <= value < 1.0
  double nextDouble() => nextInt(1000000) / 1000000.0;

  bool chance(double p) => nextDouble() < p;

  T pick<T>(List<T> items) => items[nextInt(items.length)];

  /// Returns a new shuffled copy (Fisher–Yates).
  List<T> shuffled<T>(Iterable<T> items) {
    final List<T> out = items.toList();
    for (int i = out.length - 1; i > 0; i--) {
      final int j = nextInt(i + 1);
      final T t = out[i];
      out[i] = out[j];
      out[j] = t;
    }
    return out;
  }

  /// Picks [n] distinct items.
  List<T> sample<T>(Iterable<T> items, int n) {
    final List<T> s = shuffled<T>(items);
    return s.length <= n ? s : s.sublist(0, n);
  }
}
