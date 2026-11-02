import '../models/english_lesson.dart';

/// Adjusts learner CEFR band and filters activities by performance.
class EnglishAdaptiveService {
  const EnglishAdaptiveService();

  /// Update level after a lesson based on accuracy and streak.
  EnglishCefrLevel adjustAfterLesson({
    required EnglishCefrLevel current,
    required double accuracy,
    required int maxStreak,
    required int stepsAttempted,
  }) {
    if (stepsAttempted < 4) return current;

    if (accuracy >= 0.92 && maxStreak >= 5) {
      return current.clampShift(1);
    }
    if (accuracy >= 0.85 && maxStreak >= 3) {
      return current; // hold — mastering current band
    }
    if (accuracy < 0.55) {
      return current.clampShift(-1);
    }
    if (accuracy < 0.68) {
      return current.clampShift(-1);
    }
    return current;
  }

  /// Pick activities whose CEFR is near the learner's level.
  List<EnglishActivity> filterByLevel(
    List<EnglishActivity> pool,
    EnglishCefrLevel learnerLevel, {
    int tolerance = 1,
  }) {
    final List<EnglishActivity> matched = pool
        .where((EnglishActivity a) {
          final EnglishCefrLevel? itemLevel = a.cefrLevel;
          if (itemLevel == null) return true;
          return learnerLevel.isWithinBand(itemLevel, tolerance: tolerance);
        })
        .toList();
    return matched.isEmpty ? pool : matched;
  }

  /// Interleave activity kinds so sessions are not repetitive.
  List<EnglishActivity> diversifyKinds(List<EnglishActivity> items) {
    if (items.length <= 3) return items;

    final Map<EnglishActivityKind, List<EnglishActivity>> buckets =
        <EnglishActivityKind, List<EnglishActivity>>{};
    for (final EnglishActivity a in items) {
      buckets.putIfAbsent(a.kind, () => <EnglishActivity>[]).add(a);
    }

    final List<EnglishActivityKind> kinds = buckets.keys.toList();
    final List<EnglishActivity> out = <EnglishActivity>[];
    int pass = 0;
    while (out.length < items.length) {
      bool added = false;
      for (int i = 0; i < kinds.length; i++) {
        final EnglishActivityKind kind =
            kinds[(pass + i) % kinds.length];
        final List<EnglishActivity>? bucket = buckets[kind];
        if (bucket == null || bucket.isEmpty) continue;
        out.add(bucket.removeAt(0));
        added = true;
        if (out.length >= items.length) break;
      }
      if (!added) break;
      pass++;
    }
    return out;
  }

  int targetExtrasForLevel(EnglishCefrLevel level) {
    return switch (level.rank) {
      <= 2 => 8,
      <= 4 => 10,
      _ => 12,
    };
  }
}
