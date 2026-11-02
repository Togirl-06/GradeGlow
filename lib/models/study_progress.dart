/// Quiz session result for progress charts and subject scores.
class QuizResult {
  const QuizResult({
    required this.date,
    required this.courseCode,
    required this.scorePercent,
    required this.correct,
    required this.total,
  });

  final DateTime date;
  final String courseCode;
  final int scorePercent;
  final int correct;
  final int total;

  factory QuizResult.fromMap(Map<String, dynamic> data) {
    return QuizResult(
      date: DateTime.tryParse(data['date'] as String? ?? '') ?? DateTime.now(),
      courseCode: data['courseCode'] as String? ?? 'General',
      scorePercent: (data['scorePercent'] as num?)?.toInt() ?? 0,
      correct: (data['correct'] as num?)?.toInt() ?? 0,
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'date': date.toIso8601String(),
        'courseCode': courseCode,
        'scorePercent': scorePercent,
        'correct': correct,
        'total': total,
      };
}

class WeeklyStats {
  const WeeklyStats({
    required this.weekKey,
    this.studyMinutes = 0,
    this.quizzesCompleted = 0,
    this.tutorSessions = 0,
    this.chaptersReviewed = 0,
  });

  final String weekKey;
  final int studyMinutes;
  final int quizzesCompleted;
  final int tutorSessions;
  final int chaptersReviewed;

  factory WeeklyStats.empty() => WeeklyStats(weekKey: StudyProgress.currentWeekKey());

  factory WeeklyStats.fromMap(Map<String, dynamic>? data) {
    if (data == null) return WeeklyStats.empty();
    return WeeklyStats(
      weekKey: data['weekKey'] as String? ?? StudyProgress.currentWeekKey(),
      studyMinutes: (data['studyMinutes'] as num?)?.toInt() ?? 0,
      quizzesCompleted: (data['quizzesCompleted'] as num?)?.toInt() ?? 0,
      tutorSessions: (data['tutorSessions'] as num?)?.toInt() ?? 0,
      chaptersReviewed: (data['chaptersReviewed'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'weekKey': weekKey,
        'studyMinutes': studyMinutes,
        'quizzesCompleted': quizzesCompleted,
        'tutorSessions': tutorSessions,
        'chaptersReviewed': chaptersReviewed,
      };

  WeeklyStats copyWith({
    int? studyMinutes,
    int? quizzesCompleted,
    int? tutorSessions,
    int? chaptersReviewed,
  }) {
    return WeeklyStats(
      weekKey: weekKey,
      studyMinutes: studyMinutes ?? this.studyMinutes,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      tutorSessions: tutorSessions ?? this.tutorSessions,
      chaptersReviewed: chaptersReviewed ?? this.chaptersReviewed,
    );
  }
}

class StudyProgress {
  const StudyProgress({
    this.quizResults = const <QuizResult>[],
    this.weekly = const WeeklyStats(weekKey: ''),
    this.subjectScores = const <String, int>{},
  });

  final List<QuizResult> quizResults;
  final WeeklyStats weekly;
  final Map<String, int> subjectScores;

  static String currentWeekKey() {
    final DateTime now = DateTime.now();
    final DateTime jan1 = DateTime(now.year, 1, 1);
    final int week = ((now.difference(jan1).inDays + jan1.weekday) / 7).ceil();
    return '${now.year}-W${week.toString().padLeft(2, '0')}';
  }

  WeeklyStats normalizedWeekly() {
    final String key = currentWeekKey();
    if (weekly.weekKey == key) return weekly;
    return WeeklyStats(weekKey: key);
  }

  factory StudyProgress.fromMap(Map<String, dynamic>? data) {
    if (data == null) return StudyProgress.empty();
    final List<QuizResult> results = <QuizResult>[];
    final dynamic raw = data['quizResults'];
    if (raw is List) {
      for (final dynamic item in raw) {
        if (item is Map) {
          results.add(QuizResult.fromMap(item.map((dynamic k, dynamic v) => MapEntry(k.toString(), v))));
        }
      }
    }
    final Map<String, int> subjects = <String, int>{};
    final dynamic rawSubjects = data['subjectScores'];
    if (rawSubjects is Map) {
      rawSubjects.forEach((dynamic k, dynamic v) {
        subjects[k.toString()] = (v as num?)?.toInt() ?? 0;
      });
    }
    return StudyProgress(
      quizResults: results,
      weekly: WeeklyStats.fromMap(data['weekly'] as Map<String, dynamic>?),
      subjectScores: subjects,
    );
  }

  factory StudyProgress.empty() => StudyProgress(weekly: WeeklyStats(weekKey: currentWeekKey()));

  Map<String, dynamic> toMap() => <String, dynamic>{
        'quizResults': quizResults.map((QuizResult r) => r.toMap()).toList(),
        'weekly': weekly.toMap(),
        'subjectScores': subjectScores,
      };

  StudyProgress copyWith({
    List<QuizResult>? quizResults,
    WeeklyStats? weekly,
    Map<String, int>? subjectScores,
  }) {
    return StudyProgress(
      quizResults: quizResults ?? this.quizResults,
      weekly: weekly ?? this.weekly,
      subjectScores: subjectScores ?? this.subjectScores,
    );
  }
}
