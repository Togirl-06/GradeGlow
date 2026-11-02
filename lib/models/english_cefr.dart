/// CEFR proficiency bands for adaptive English instruction.
enum EnglishCefrLevel {
  a1('A1', 'Beginner', 1),
  a2('A2', 'Elementary', 2),
  b1('B1', 'Intermediate', 3),
  b2('B2', 'Upper Intermediate', 4),
  c1('C1', 'Advanced', 5),
  c2('C2', 'Proficient', 6);

  const EnglishCefrLevel(this.code, this.label, this.rank);

  final String code;
  final String label;
  final int rank;

  static EnglishCefrLevel fromRank(int rank) {
    for (final EnglishCefrLevel l in EnglishCefrLevel.values) {
      if (l.rank == rank) return l;
    }
    return rank <= 2
        ? EnglishCefrLevel.a1
        : rank >= 5
            ? EnglishCefrLevel.c1
            : EnglishCefrLevel.b1;
  }

  EnglishCefrLevel clampShift(int delta) {
    return fromRank((rank + delta).clamp(1, 6));
  }

  bool isWithinBand(EnglishCefrLevel target, {int tolerance = 1}) {
    return (target.rank - rank).abs() <= tolerance;
  }

  /// Beginner / intermediate / advanced groupings from the product spec.
  String get bandLabel {
    if (rank <= 2) return 'Beginner (A1–A2)';
    if (rank <= 4) return 'Intermediate (B1–B2)';
    return 'Advanced (C1–C2)';
  }
}

/// Detailed AI feedback for read-aloud performance.
class EnglishReadingGradeDetail {
  const EnglishReadingGradeDetail({
    required this.overall,
    required this.pronunciation,
    required this.fluency,
    required this.accuracy,
    required this.feedback,
    this.mispronouncedWords = const <String>[],
    this.practiceWords = const <String>[],
    this.correct = false,
  });

  final int overall;
  final int pronunciation;
  final int fluency;
  final int accuracy;
  final String feedback;
  final List<String> mispronouncedWords;
  final List<String> practiceWords;
  final bool correct;
}
