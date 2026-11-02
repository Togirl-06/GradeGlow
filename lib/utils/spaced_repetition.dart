/// SM-2 spaced repetition (quality 0–5).
class Sm2State {
  const Sm2State({
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
  });

  final double easeFactor;
  final int intervalDays;
  final int repetitions;
}

class Sm2Result {
  const Sm2Result({
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.nextReviewAt,
  });

  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final DateTime nextReviewAt;
}

/// Updates schedule from user rating. Maps UI: Again=1, Hard=3, Good=4, Easy=5.
Sm2Result applySm2(Sm2State state, int quality) {
  final int q = quality.clamp(0, 5);
  double ease = state.easeFactor;
  int reps = state.repetitions;
  int interval = state.intervalDays;

  ease = ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
  if (ease < 1.3) ease = 1.3;

  if (q < 3) {
    reps = 0;
    interval = 1;
  } else {
    if (reps == 0) {
      interval = 1;
    } else if (reps == 1) {
      interval = 6;
    } else {
      interval = (interval * ease).round().clamp(1, 365);
    }
    reps += 1;
  }

  final DateTime next = DateTime.now().add(Duration(days: interval));
  return Sm2Result(
    easeFactor: ease,
    intervalDays: interval,
    repetitions: reps,
    nextReviewAt: next,
  );
}
