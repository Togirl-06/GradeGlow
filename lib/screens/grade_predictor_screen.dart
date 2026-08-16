import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/study_theme.dart';
import '../utils/gpa_predictor.dart';
import '../widgets/study_surface.dart';

/// Predicted term GPA and course grades from quiz history (web + phone).
class GradePredictorScreen extends StatelessWidget {
  const GradePredictorScreen({super.key, required this.profile});

  final UserProfile profile;

  static String letterGrade(int percent) =>
      GpaPredictor.letterFromPercent(percent);

  @override
  Widget build(BuildContext context) {
    final GpaForecast forecast = GpaPredictor.fromProfile(profile);
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('GPA prediction')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          StudySurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Predicted term GPA',
                  style: TextStyle(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      forecast.hasQuizzes ? forecast.gpaLabel : '—',
                      style: const TextStyle(
                        fontSize: 48,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        forecast.hasQuizzes
                            ? '/ 4.00 · ${forecast.letter} · ${forecast.averagePercent}% avg'
                            : '/ 4.00',
                        style: TextStyle(
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _Chip(label: forecast.trendLabel, color: scheme.primary),
                    _Chip(
                      label: '${forecast.confidence}% confidence',
                      color: textSecondary,
                    ),
                    if (forecast.quizCount > 0)
                      _Chip(
                        label:
                            '${forecast.quizCount} quiz${forecast.quizCount == 1 ? '' : 'zes'}',
                        color: textSecondary,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  forecast.nextStep,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  forecast.summary,
                  style: TextStyle(color: textSecondary, height: 1.4),
                ),
                if (forecast.cumulativeOutlook != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    'Reported GPA ${forecast.reportedGpa.toStringAsFixed(2)} · '
                    'if this term holds, overall moves toward ${forecast.cumulativeOutlook!.toStringAsFixed(2)}.',
                    style: TextStyle(color: textSecondary, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Course breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (forecast.courses.isEmpty)
            StudySurfaceCard(
              child: Text(
                'Take quizzes in your study sets to see per-class GPA estimates.',
                style: TextStyle(color: textSecondary, height: 1.4),
              ),
            )
          else
            ...forecast.courses.map(
              (GpaCourseRow course) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StudySurfaceCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      course.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      course.isWeak
                          ? 'Needs work · ${course.percent}%'
                          : '${course.percent}% quiz avg',
                      style: TextStyle(color: textSecondary),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          course.letter,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: course.isWeak
                                ? StudyColors.danger
                                : StudyColors.success,
                          ),
                        ),
                        Text(
                          course.points.toStringAsFixed(1),
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Predictions use the standard 4.0 letter scale from your quiz performance. They are estimates, not official grades.',
            style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
