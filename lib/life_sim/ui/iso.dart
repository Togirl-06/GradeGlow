/// Isometric projection helpers (pure Dart so they can be unit tested).
library;

class Iso {
  const Iso({this.tileW = 64, this.tileH = 32});
  final double tileW;
  final double tileH;

  /// Tile corner (x, y) → screen offset from the world origin.
  (double, double) project(double x, double y) => ((x - y) * tileW / 2, (x + y) * tileH / 2);

  /// Screen offset from the world origin → fractional tile coordinates.
  (double, double) unproject(double sx, double sy) {
    final double a = sx / (tileW / 2); // x - y
    final double b = sy / (tileH / 2); // x + y
    return ((a + b) / 2, (b - a) / 2);
  }

  /// Painter's-algorithm depth: larger draws later (in front).
  double depth(double x, double y) => x + y;
}
