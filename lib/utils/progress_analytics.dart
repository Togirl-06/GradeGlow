import 'dart:math' show max;

import '../models/study_progress.dart';
import '../models/user_profile.dart';
import '../utils/gamification.dart';

class SubjectScoreRow {
  const SubjectScoreRow({required this.name, required this.percent, this.isWeak = false});

  final String name;
  final int percent;
  final bool isWeak;
}

class WeeklyGoalRow {
  const WeeklyGoalRow({
    required this.label,
    required this.current,
    required this.target,
  });

  final String label;
  final int current;
  final int target;

  double get progress => target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);
}

class ProgressSnapshot {
  const ProgressSnapshot({
    required this.averageQuizScore,
    required this.recentQuizzes,
    required this.subjects,
    required this.level,
    required this.xp,
    required this.xpToNext,
    required this.levelTitle,
    required this.weeklyGoals,
    required this.quizTrend,
    required this.studyHoursTrend,
    required this.tutorTrend,
    required this.insights,
  });

  final int averageQuizScore;
  final List<QuizResult> recentQuizzes;
  final List<SubjectScoreRow> subjects;
  final int level;
  final int xp;
  final int xpToNext;
  final String levelTitle;
  final List<WeeklyGoalRow> weeklyGoals;
  final List<int> quizTrend;
  final List<double> studyHoursTrend;
  final List<int> tutorTrend;
  final List<String> insights;
}

class ProgressAnalytics {
  static const int _goalStudyMinutes = 600;
  static const int _goalQuizzes = 5;
  static const int _goalChapters = 3;

  static ProgressSnapshot fromProfile(UserProfile profile) {
    final StudyProgress progress = profile.studyProgress;
    final WeeklyStats week = progress.normalizedWeekly();
    final List<QuizResult> sorted = List<QuizResult>.from(progress.quizResults)
      ..sort((QuizResult a, QuizResult b) => b.date.compareTo(a.date));

    final int avg = _averageScore(sorted);
    final List<SubjectScoreRow> subjects = _subjectRows(progress, profile);
    final int level = Gamification.levelFromXp(profile.xp);
    final int ceil = Gamification.xpCeilForLevel(level);

    return ProgressSnapshot(
      averageQuizScore: avg,
      recentQuizzes: sorted.take(5).toList(),
      subjects: subjects,
      level: level,
      xp: profile.xp,
      xpToNext: (ceil - profile.xp).clamp(0, Gamification.xpPerLevel),
      levelTitle: Gamification.levelTitle(level),
      weeklyGoals: <WeeklyGoalRow>[
        WeeklyGoalRow(
          label: 'Study 10 hours this week',
          current: week.studyMinutes,
          target: _goalStudyMinutes,
        ),
        WeeklyGoalRow(
          label: 'Complete 5 quizzes',
          current: week.quizzesCompleted,
          target: _goalQuizzes,
        ),
        WeeklyGoalRow(
          label: 'Review 3 chapters',
          current: week.chaptersReviewed,
          target: _goalChapters,
        ),
      ],
      quizTrend: _quizTrend(sorted),
      studyHoursTrend: _weeklyHoursTrend(week),
      tutorTrend: _weeklyTutorTrend(week),
      insights: _insights(profile, sorted, subjects, avg),
    );
  }

  static int _averageScore(List<QuizResult> results) {
    if (results.isEmpty) return 0;
    final int sum = results.fold<int>(0, (int a, QuizResult r) => a + r.scorePercent);
    return (sum / results.length).round();
  }

  static List<SubjectScoreRow> _subjectRows(StudyProgress progress, UserProfile profile) {
    final Map<String, List<int>> byCourse = <String, List<int>>{};
    for (final QuizResult r in progress.quizResults) {
      byCourse.putIfAbsent(r.courseCode, () => <int>[]).add(r.scorePercent);
    }
    progress.subjectScores.forEach((String course, int score) {
      byCourse.putIfAbsent(course, () => <int>[]).add(score);
    });

    if (byCourse.isEmpty && profile.weakTopics.isNotEmpty) {
      for (final MapEntry<String, int> e in profile.topWeakTopics(limit: 4)) {
        byCourse[e.key] = <int>[max(40, 100 - e.value * 8)];
      }
    }

    if (byCourse.isEmpty) {
      return <SubjectScoreRow>[
        const SubjectScoreRow(name: 'Add quizzes to see subjects', percent: 0),
      ];
    }

    final List<MapEntry<String, int>> averaged = byCourse.entries
        .map(
          (MapEntry<String, List<int>> e) => MapEntry<String, int>(
            e.key,
            (e.value.reduce((int a, int b) => a + b) / e.value.length).round(),
          ),
        )
        .toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value));

    final int weakThreshold = 65;
    return averaged
        .map(
          (MapEntry<String, int> e) => SubjectScoreRow(
            name: e.key,
            percent: e.value,
            isWeak: e.value < weakThreshold,
          ),
        )
        .toList();
  }

  static List<int> _quizTrend(List<QuizResult> sorted) {
    final List<QuizResult> chronological = List<QuizResult>.from(sorted.reversed).take(6).toList();
    if (chronological.isEmpty) return <int>[0, 0, 0, 0, 0, 0];
    return chronological.map((QuizResult r) => r.scorePercent).toList();
  }

  static List<double> _weeklyHoursTrend(WeeklyStats week) {
    final double hours = week.studyMinutes / 60.0;
    return <double>[hours * 0.4, hours * 0.55, hours * 0.7, hours * 0.85, hours];
  }

  static List<int> _weeklyTutorTrend(WeeklyStats week) {
    final int n = week.tutorSessions;
    return <int>[
      (n * 0.3).round(),
      (n * 0.5).round(),
      (n * 0.65).round(),
      (n * 0.8).round(),
      n,
    ];
  }

  static List<String> _insights(
    UserProfile profile,
    List<QuizResult> recent,
    List<SubjectScoreRow> subjects,
    int avg,
  ) {
    final List<String> lines = <String>[];

    if (recent.length >= 2) {
      final int latest = recent.first.scorePercent;
      final int prior = recent[1].scorePercent;
      final int delta = latest - prior;
      if (delta > 0) {
        lines.add('Your latest quiz score improved by $delta% — keep that momentum.');
      } else if (delta < 0) {
        lines.add('Scores dipped ${delta.abs()}% on your last quiz. Review weak topics today.');
      }
    }

    SubjectScoreRow? weak;
    for (final SubjectScoreRow s in subjects) {
      if (s.isWeak) {
        weak = s;
        break;
      }
    }
    if (weak != null) {
      lines.add('You struggle most with ${weak.name} (${weak.percent}%). Practice it 2× this week.');
    }

    if (profile.weakTopics.isNotEmpty) {
      final String topic = profile.weakTopics.entries.first.key;
      lines.add('Review "$topic" — it appears often in your missed questions.');
    }

    if (avg >= 80) {
      lines.add('Strong overall average ($avg%). Challenge yourself with harder quizzes.');
    } else if (avg > 0 && avg < 70) {
      lines.add('Average quiz score is $avg%. Focus on one subject per study session.');
    }

    if (lines.isEmpty) {
      lines.add('Complete a quiz and chat with the AI tutor to unlock personalized insights.');
    }

    return lines.take(4).toList();
  }
}
