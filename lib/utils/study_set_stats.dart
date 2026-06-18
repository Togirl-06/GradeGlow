import '../models/study_summary.dart';

/// Mastery bucket counts for a study set (Quizlet-style).
class StudySetMastery {
  const StudySetMastery({
    required this.unfamiliar,
    required this.learning,
    required this.familiar,
    required this.mastered,
  });

  final int unfamiliar;
  final int learning;
  final int familiar;
  final int mastered;

  int get total => unfamiliar + learning + familiar + mastered;

  int get masteryPercent {
    if (total == 0) return 0;
    return ((mastered / total) * 100).round();
  }

  static StudySetMastery fromSummary(StudySummary summary) {
    return fromSummaries(<StudySummary>[summary]);
  }

  static StudySetMastery fromSummaries(List<StudySummary> summaries) {
    int unfamiliar = 0;
    for (final StudySummary summary in summaries) {
      unfamiliar += summary.flashcards.length;
    }
    return StudySetMastery(
      unfamiliar: unfamiliar,
      learning: 0,
      familiar: 0,
      mastered: 0,
    );
  }
}
