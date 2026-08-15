import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/study_theme.dart';
import '../utils/progress_analytics.dart';
import 'simple_trend_chart.dart';
import 'study_surface.dart';

/// Learning analytics for the Progress tab (app + web).
class ProgramAnalyticsSection extends StatelessWidget {
  const ProgramAnalyticsSection({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final ProgressSnapshot snapshot = ProgressAnalytics.fromProfile(profile);
    final bool hasSubjectScores = snapshot.subjects.any(
      (SubjectScoreRow subject) => subject.percent > 0,
    );
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final bool wide = MediaQuery.sizeOf(context).width >= 680;

    final Widget weeklyChart = _ChartCard(
      title: 'This week',
      subtitle: 'Study activity',
      caption:
          '${(snapshot.weeklyGoals.first.current / 60).toStringAsFixed(1)}h studied · '
          '${snapshot.weeklyGoals[1].current} quizzes · '
          '${profile.studyProgress.normalizedWeekly().tutorSessions} tutor chats',
      textSecondary: textSecondary,
      child: SimpleTrendChart(
        values: <double>[
          snapshot.weeklyGoals.first.current / 60.0,
          snapshot.weeklyGoals[1].current.toDouble(),
          profile.studyProgress.normalizedWeekly().tutorSessions.toDouble(),
        ],
        labels: const <String>['Study', 'Quiz', 'Tutor'],
        maxValue: 10,
      ),
    );

    final Widget subjectChart = _ChartCard(
      title: 'Subject strength',
      subtitle: 'Quiz performance',
      textSecondary: textSecondary,
      child: _SubjectBars(subjects: snapshot.subjects),
    );

    if (wide) {
      return Column(
        children: <Widget>[
          weeklyChart,
          if (hasSubjectScores) ...<Widget>[
            const SizedBox(height: 12),
            subjectChart,
          ],
        ],
      );
    }

    return Column(
      children: <Widget>[
        weeklyChart,
        if (hasSubjectScores) ...<Widget>[
          const SizedBox(height: 12),
          subjectChart,
        ],
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.textSecondary,
    this.caption,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Color textSecondary;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return StudySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: StudyColors.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
          if (caption != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              caption!,
              style: TextStyle(color: textSecondary, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubjectBars extends StatelessWidget {
  const _SubjectBars({required this.subjects});

  final List<SubjectScoreRow> subjects;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final List<SubjectScoreRow> rows = subjects
        .where((SubjectScoreRow s) => s.percent > 0)
        .take(5)
        .toList();

    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Take quizzes to see subject scores.',
          style: TextStyle(color: textSecondary, fontSize: 13),
        ),
      );
    }

    return Column(
      children: rows.map((SubjectScoreRow row) {
        final Color color = row.isWeak
            ? StudyColors.warning
            : StudyColors.primary;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      row.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    '${row.percent}%',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (row.percent / 100).clamp(0.04, 1.0),
                  minHeight: 8,
                  backgroundColor: color.withValues(alpha: 0.12),
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
