import 'package:flutter/material.dart';

import '../../utils/gpa_predictor.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_roadmap_sync.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_degree_roadmap_screen.dart';

/// Degree progress summary — used on Campus (replaces the old Progress tab).
class VuV2ProgressPanel extends StatelessWidget {
  const VuV2ProgressPanel({
    super.key,
    required this.session,
    required this.progress,
    this.showTitle = true,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final VuV2DegreeRoadmap roadmap =
        VuV2RoadmapSync.forSubjectId(session.majorId);
    final List<String> lessonIds = roadmap.tracks
        .expand((VuV2RoadmapTrack t) => t.courses)
        .expand((VuV2RoadmapCourse c) => c.allLessons)
        .map((VuV2RoadmapLesson l) => l.id)
        .toList();
    final double degreePct = progress.degreeProgress(lessonIds: lessonIds);
    final double avgQuiz = progress.quizScores.isEmpty
        ? 0
        : progress.quizScores.values.reduce((double a, double b) => a + b) /
            progress.quizScores.length;
    final GpaForecast gpaForecast = GpaPredictor.fromPercents(
      percents: progress.quizScores.values
          .map((double v) => v.round())
          .toList(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showTitle) ...<Widget>[
          const VuV2SectionTitle('Progress'),
          const SizedBox(height: 8),
          Text(
            session.majorLabel,
            style: const TextStyle(color: VuV2Colors.mute),
          ),
          const SizedBox(height: 14),
        ],
        VuV2Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'DEGREE COMPLETION',
                style: TextStyle(
                  color: VuV2Colors.orange,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(degreePct * 100).round()}%',
                style: const TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 10),
              VuV2ProgressBar(value: degreePct),
              const SizedBox(height: 8),
              Text(
                '${progress.completedLessonIds.intersection(lessonIds.toSet()).length} / ${lessonIds.length} lessons',
                style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _StatCard(
                label: 'Study time',
                value: '${progress.studyMinutes} min',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Streak',
                value: '${progress.streakDays} days',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _StatCard(
                label: 'Avg quiz',
                value: '${avgQuiz.round()}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Pred. GPA',
                value: progress.gpaLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _StatCard(
          label: 'Attendance',
          value: '${progress.attendanceDays.length} days',
        ),
        const SizedBox(height: 10),
        VuV2Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'GPA PREDICTION',
                style: TextStyle(
                  color: VuV2Colors.orange,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                gpaForecast.hasQuizzes
                    ? '${gpaForecast.gpaLabel} / 4.00 · ${gpaForecast.letter} · ${gpaForecast.trendLabel}'
                    : 'No quiz scores yet',
                style: const TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                gpaForecast.nextStep,
                style: const TextStyle(color: VuV2Colors.mute, fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        VuV2PrimaryButton(
          label: 'Open degree roadmap',
          icon: Icons.map_rounded,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => VuV2DegreeRoadmapScreen(
                  session: session,
                  subjectId: session.majorId,
                  progress: progress,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Standalone scrollable progress view (kept for reuse).
class VuV2ProgressTab extends StatelessWidget {
  const VuV2ProgressTab({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        VuV2ProgressPanel(session: session, progress: progress),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return VuV2Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(color: VuV2Colors.mute, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
