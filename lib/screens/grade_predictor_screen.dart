import 'package:flutter/material.dart';

import '../models/study_progress.dart';
import '../models/user_profile.dart';
import '../theme/study_theme.dart';
import '../utils/progress_analytics.dart';
import '../widgets/study_surface.dart';

/// Premium: Grade Predictor & exam score calculator from quiz history.
class GradePredictorScreen extends StatelessWidget {
  const GradePredictorScreen({super.key, required this.profile});

  final UserProfile profile;

  static String letterGrade(int percent) {
    if (percent >= 93) return 'A';
    if (percent >= 90) return 'A-';
    if (percent >= 87) return 'B+';
    if (percent >= 83) return 'B';
    if (percent >= 80) return 'B-';
    if (percent >= 77) return 'C+';
    if (percent >= 73) return 'C';
    if (percent >= 70) return 'C-';
    if (percent >= 67) return 'D+';
    if (percent >= 63) return 'D';
    if (percent >= 60) return 'D-';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    final ProgressSnapshot snapshot = ProgressAnalytics.fromProfile(profile);
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final int avg = snapshot.averageQuizScore;
    final String predicted = letterGrade(avg);
    final List<QuizResult> recent = snapshot.recentQuizzes;

    return Scaffold(
      appBar: AppBar(title: const Text('Grade Predictor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          StudySurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Predicted course grade',
                  style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      predicted,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '$avg% avg quiz score',
                        style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recent.isEmpty
                      ? 'Complete a few quizzes to refine this prediction.'
                      : 'Based on your last ${recent.length} quiz ${recent.length == 1 ? 'result' : 'results'}.',
                  style: TextStyle(color: textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Exam score calculator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...snapshot.subjects.map(
            (SubjectScoreRow subject) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StudySurfaceCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    subject.isWeak ? 'Focus area · ${subject.percent}%' : '${subject.percent}% quiz avg',
                    style: TextStyle(color: textSecondary),
                  ),
                  trailing: Text(
                    letterGrade(subject.percent),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: subject.isWeak ? StudyColors.danger : StudyColors.success,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (snapshot.subjects.isEmpty)
            StudySurfaceCard(
              child: Text(
                'Take quizzes in your study sets to see per-subject predictions.',
                style: TextStyle(color: textSecondary, height: 1.4),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Predictions use your quiz performance. They are estimates, not official grades.',
            style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }
}
