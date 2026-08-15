/// Graded outcome from a university practical lab.
class UniversityLabResult {
  const UniversityLabResult({
    required this.accuracy,
    required this.identifyCorrect,
    required this.identifyAttempts,
    required this.viewsVisited,
    required this.labelDrillComplete,
    required this.coachingNotes,
    required this.xpEarned,
    this.secondsElapsed = 0,
    this.badgeId,
    this.clinicalSolved = false,
    this.clinicalReasoningScore = 0,
    this.hintsUsed = 0,
    this.recommendedReview,
  });

  final double accuracy;
  final int identifyCorrect;
  final int identifyAttempts;
  final int viewsVisited;
  final bool labelDrillComplete;
  final List<String> coachingNotes;
  final int xpEarned;
  final int secondsElapsed;
  final String? badgeId;
  /// Unique: solved the embedded clinical case (not just labels).
  final bool clinicalSolved;
  /// 0–1 clinical reasoning score from the viva question.
  final double clinicalReasoningScore;
  final int hintsUsed;
  final String? recommendedReview;

  bool get passed => accuracy >= 0.6;

  String get scoreLabel => '${(accuracy * 100).round()}%';

  String get resultStatus {
    if (!passed) return 'Needs retry';
    if (clinicalSolved || accuracy >= 0.85) return 'Successful';
    return 'Complete';
  }

  String get reasoningGrade {
    final double r =
        clinicalReasoningScore > 0 ? clinicalReasoningScore : accuracy;
    if (r >= 0.85) return 'Excellent';
    if (r >= 0.70) return 'Strong';
    if (r >= 0.55) return 'Developing';
    return 'Needs work';
  }

  String get decisionQuality {
    if (clinicalSolved && accuracy >= 0.80) return 'Excellent';
    if (passed && accuracy >= 0.75) return 'Good';
    if (passed) return 'Adequate';
    return 'Inconsistent';
  }

  String get efficiencyLabel {
    if (secondsElapsed <= 0) return 'Good';
    if (secondsElapsed < 180) return 'Fast';
    if (secondsElapsed < 480) return 'Good';
    return 'Thorough';
  }

  int get conceptMasteryPercent => (accuracy * 100).round().clamp(0, 100);
}
