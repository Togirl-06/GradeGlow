import '../models/study_progress.dart';
import '../models/user_profile.dart';

class GpaBand {
  const GpaBand({
    required this.minPercent,
    required this.letter,
    required this.points,
  });

  final int minPercent;
  final String letter;
  final double points;
}

class GpaCourseRow {
  const GpaCourseRow({
    required this.name,
    required this.percent,
    required this.letter,
    required this.points,
    required this.isWeak,
  });

  final String name;
  final int percent;
  final String letter;
  final double points;
  final bool isWeak;
}

class GpaForecast {
  const GpaForecast({
    required this.predictedGpa,
    required this.letter,
    required this.averagePercent,
    required this.quizCount,
    required this.reportedGpa,
    required this.cumulativeOutlook,
    required this.trendDelta,
    required this.trendLabel,
    required this.confidence,
    required this.courses,
    required this.summary,
    required this.nextStep,
  });

  final double predictedGpa;
  final String letter;
  final int averagePercent;
  final int quizCount;
  final double reportedGpa;
  final double? cumulativeOutlook;
  final int trendDelta;
  final String trendLabel;
  final int confidence;
  final List<GpaCourseRow> courses;
  final String summary;
  final String nextStep;

  String get gpaLabel => predictedGpa.toStringAsFixed(2);

  bool get hasQuizzes => quizCount > 0 || courses.any((GpaCourseRow c) => c.percent > 0);
}

/// US 4.0 letter-scale GPA from quiz and course scores.
class GpaPredictor {
  static const List<GpaBand> bands = <GpaBand>[
    GpaBand(minPercent: 93, letter: 'A', points: 4.0),
    GpaBand(minPercent: 90, letter: 'A-', points: 3.7),
    GpaBand(minPercent: 87, letter: 'B+', points: 3.3),
    GpaBand(minPercent: 83, letter: 'B', points: 3.0),
    GpaBand(minPercent: 80, letter: 'B-', points: 2.7),
    GpaBand(minPercent: 77, letter: 'C+', points: 2.3),
    GpaBand(minPercent: 73, letter: 'C', points: 2.0),
    GpaBand(minPercent: 70, letter: 'C-', points: 1.7),
    GpaBand(minPercent: 67, letter: 'D+', points: 1.3),
    GpaBand(minPercent: 63, letter: 'D', points: 1.0),
    GpaBand(minPercent: 60, letter: 'D-', points: 0.7),
    GpaBand(minPercent: 0, letter: 'F', points: 0.0),
  ];

  static GpaBand bandFor(int percent) {
    final int clamped = percent.clamp(0, 100);
    for (final GpaBand band in bands) {
      if (clamped >= band.minPercent) return band;
    }
    return bands.last;
  }

  static double pointsFromPercent(int percent) => bandFor(percent).points;

  static String letterFromPercent(int percent) => bandFor(percent).letter;

  static GpaBand nextBandAbove(int percent) {
    final GpaBand current = bandFor(percent);
    final int i = bands.indexOf(current);
    if (i <= 0) return current;
    return bands[i - 1];
  }

  static GpaForecast fromPercents({
    required List<int> percents,
    Map<String, int>? byCourse,
    double reportedGpa = 0,
  }) {
    final List<int> scores = percents.where((int p) => p >= 0).toList();
    final Map<String, int> courses = Map<String, int>.from(
      byCourse ?? const <String, int>{},
    );
    courses.removeWhere((String _, int v) => v <= 0);

    final int average = _average(
      scores.isNotEmpty ? scores : courses.values.toList(),
    );
    final GpaBand overall = bandFor(average);
    final int quizCount = scores.length;
    final int trendDelta = _trendDelta(scores);
    final String trendLabel = _trendLabel(trendDelta, average, quizCount);
    final int confidence = _confidence(quizCount + courses.length);
    final List<GpaCourseRow> rows = courses.entries
        .map((MapEntry<String, int> e) {
          final GpaBand band = bandFor(e.value);
          return GpaCourseRow(
            name: e.key,
            percent: e.value,
            letter: band.letter,
            points: band.points,
            isWeak: e.value < 80,
          );
        })
        .toList()
      ..sort(
        (GpaCourseRow a, GpaCourseRow b) => a.points.compareTo(b.points),
      );

    final double predicted = overall.points;
    final double? cumulative = reportedGpa > 0 && scores.isNotEmpty
        ? ((reportedGpa + predicted) / 2).clamp(0.0, 4.0)
        : null;

    return GpaForecast(
      predictedGpa: predicted,
      letter: overall.letter,
      averagePercent: average,
      quizCount: quizCount,
      reportedGpa: reportedGpa,
      cumulativeOutlook: cumulative,
      trendDelta: trendDelta,
      trendLabel: trendLabel,
      confidence: confidence,
      courses: rows,
      summary: _summary(
        quizCount: quizCount,
        average: average,
        predicted: predicted,
        letter: overall.letter,
        trendLabel: trendLabel,
        confidence: confidence,
      ),
      nextStep: _nextStep(average, rows, scores.isNotEmpty || courses.isNotEmpty),
    );
  }

  static GpaForecast fromProfile(UserProfile profile) {
    final List<QuizResult> chronological = List<QuizResult>.from(
      profile.studyProgress.quizResults,
    )..sort((QuizResult a, QuizResult b) => a.date.compareTo(b.date));
    final List<int> percents = chronological
        .map((QuizResult r) => r.scorePercent)
        .toList();

    final Map<String, List<int>> grouped = <String, List<int>>{};
    for (final QuizResult r in chronological) {
      grouped.putIfAbsent(r.courseCode, () => <int>[]).add(r.scorePercent);
    }
    profile.studyProgress.subjectScores.forEach((String course, int score) {
      grouped.putIfAbsent(course, () => <int>[]).add(score);
    });

    final Map<String, int> byCourse = grouped.map(
      (String k, List<int> v) => MapEntry<String, int>(
        k,
        (v.reduce((int a, int b) => a + b) / v.length).round(),
      ),
    );

    return fromPercents(
      percents: percents,
      byCourse: byCourse,
      reportedGpa: profile.gpa,
    );
  }

  static int _average(List<int> values) {
    if (values.isEmpty) return 0;
    return (values.reduce((int a, int b) => a + b) / values.length).round();
  }

  static int _trendDelta(List<int> chronological) {
    if (chronological.length < 4) return 0;
    final int split = chronological.length - 3;
    final List<int> older = chronological.sublist(0, split);
    final List<int> recent = chronological.sublist(split);
    return _average(recent) - _average(older);
  }

  static String _trendLabel(int delta, int average, int quizCount) {
    if (quizCount == 0) return 'Not enough data';
    if (average < 70) return 'At risk';
    if (delta >= 5) return 'Rising';
    if (delta <= -5) return 'Slipping';
    return 'Holding';
  }

  static int _confidence(int sampleSize) {
    if (sampleSize <= 0) return 0;
    return (25 + sampleSize * 12).clamp(25, 95);
  }

  static String _summary({
    required int quizCount,
    required int average,
    required double predicted,
    required String letter,
    required String trendLabel,
    required int confidence,
  }) {
    if (quizCount == 0) {
      return 'Complete a few quizzes to predict your term GPA.';
    }
    return 'Quiz average $average% maps to a $letter ($predicted/4.00). '
        '$trendLabel · $confidence% confidence from $quizCount quiz${quizCount == 1 ? '' : 'zes'}.';
  }

  static String _nextStep(
    int average,
    List<GpaCourseRow> courses,
    bool hasData,
  ) {
    if (!hasData) {
      return 'Take a quiz in each class so this forecast can lock in.';
    }
    if (average >= 93) {
      return 'You are on track for a 4.00. Keep this average through finals.';
    }
    GpaCourseRow? weak;
    for (final GpaCourseRow course in courses) {
      if (course.isWeak) {
        weak = course;
        break;
      }
    }
    if (weak != null) {
      return 'Lift ${weak.name} toward 80% to raise your term GPA.';
    }
    final GpaBand next = nextBandAbove(average);
    if (next.minPercent <= average) {
      return 'Hold this average through remaining exams to keep your GPA.';
    }
    return 'Average ${next.minPercent}% on remaining work to reach ${next.letter} (${next.points.toStringAsFixed(1)}).';
  }
}
