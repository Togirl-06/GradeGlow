import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_roadmap_sync.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../labs/major_wow_router.dart';
import '../labs/vu_v2_labs_hub.dart';
import 'vu_v2_simulations_hub.dart';
import '../learn/vu_v2_degree_roadmap_screen.dart';
import '../learn/vu_v2_faculty_screen.dart';
import 'vu_v2_adaptive_review_drill_screen.dart';
import 'vu_v2_study_center_screen.dart';

/// Campus Home dashboard — mint/teal mockup look.
class VuV2CampusHome extends StatelessWidget {
  const VuV2CampusHome({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    final String hourLabel = () {
      final int h = DateTime.now().hour;
      if (h < 12) return 'Good morning';
      if (h < 17) return 'Good afternoon';
      return 'Good evening';
    }();

    final VuV2DegreeRoadmap roadmap =
        VuV2RoadmapSync.forSubjectId(session.majorId);
    final List<String> lessonIds = roadmap.tracks
        .expand((VuV2RoadmapTrack t) => t.courses)
        .expand((VuV2RoadmapCourse c) => c.allLessons)
        .map((VuV2RoadmapLesson l) => l.id)
        .toList();
    final double degreePct = progress.degreeProgress(lessonIds: lessonIds);
    final int done =
        progress.completedLessonIds.intersection(lessonIds.toSet()).length;
    final double avgQuiz = progress.quizScores.isEmpty
        ? 0
        : progress.quizScores.values.reduce((double a, double b) => a + b) /
            progress.quizScores.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$hourLabel,',
                    style: const TextStyle(
                      color: VuV2Colors.mute,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    session.displayName,
                    style: const TextStyle(
                      color: VuV2Colors.ink,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: VuV2Colors.mint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: VuV2Colors.mint.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                progress.isPremium ? 'PREMIUM' : 'FREE',
                style: const TextStyle(
                  color: VuV2Colors.mint,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${session.majorLabel} · ${session.weeklyMinutes} min / week',
          style: const TextStyle(color: VuV2Colors.mute, height: 1.35),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                VuV2Colors.card,
                VuV2Colors.mint.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(VuV2Radii.lg),
            border: Border.all(color: VuV2Colors.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'CONTINUE LEARNING',
                style: TextStyle(
                  color: VuV2Colors.mint,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                session.continueTitle ?? 'Start Orientation',
                style: const TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                session.continueSubtitle ?? session.majorLabel,
                style: const TextStyle(color: VuV2Colors.mute),
              ),
              const SizedBox(height: 14),
              VuV2ProgressBar(value: session.continueProgress, height: 7),
              const SizedBox(height: 16),
              VuV2PrimaryButton(
                label: _continueLabel(session),
                trailingArrow: true,
                onPressed: () => _openContinue(context, session, progress),
              ),
              if (progress.dueAdaptiveReviews > 0 ||
                  progress.topDiagramMisconceptions.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => VuV2AdaptiveReviewDrillScreen.open(
                    context,
                    progress: progress,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VuV2Colors.mint,
                    side: const BorderSide(color: VuV2Colors.mint),
                    minimumSize: const Size.fromHeight(44),
                  ),
                  icon: const Icon(Icons.psychology_alt_outlined, size: 18),
                  label: Text(
                    progress.dueAdaptiveReviews > 0
                        ? 'Fix ${progress.dueAdaptiveReviews} confusion${progress.dueAdaptiveReviews == 1 ? '' : 's'} (2 min)'
                        : 'Adaptive review drill',
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 92,
                child: _MiniStat(
                  label: 'Degree',
                  value: '${(degreePct * 100).round()}%',
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 92,
                child: _MiniStat(
                  label: 'Lessons',
                  value: '$done/${lessonIds.length}',
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 92,
                child: _MiniStat(
                  label: 'Streak',
                  value: '${progress.streakDays}d',
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 92,
                child: _MiniStat(
                  label: 'Mastery',
                  value: '${progress.masteryClearStreak}',
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 92,
                child: _MiniStat(
                  label: 'Quiz avg',
                  value: '${avgQuiz.round()}%',
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 92,
                child: _MiniStat(
                  label: 'GPA',
                  value: progress.gpaLabel,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Quick access',
          style: TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _QuickTile(
                icon: Icons.menu_book_rounded,
                label: 'Learn',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VuV2FacultyScreen(
                        session: session,
                        progress: progress,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickTile(
                icon: Icons.science_rounded,
                label: 'Labs',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        appBar: AppBar(
                          title: const Text('Virtual Labs'),
                          backgroundColor: VuV2Colors.navy,
                        ),
                        backgroundColor: VuV2Colors.navy,
                        body: VuV2LabsHub(
                          session: session,
                          progress: progress,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _QuickTile(
                icon: Icons.play_circle_outline_rounded,
                label: 'Simulations',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        appBar: AppBar(
                          title: const Text('Simulations'),
                          backgroundColor: VuV2Colors.navy,
                        ),
                        backgroundColor: VuV2Colors.navy,
                        body: VuV2SimulationsHub(
                          session: session,
                          progress: progress,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickTile(
                icon: Icons.style_rounded,
                label: 'Study',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VuV2StudyCenterScreen(
                        session: session,
                        progress: progress,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          "Today's schedule · ${session.majorLabel}",
          style: const TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 10),
        VuV2Surface(
          child: Column(
            children: <Widget>[
              _ScheduleRow(
                time: '09:00',
                title: 'Lecture',
                subtitle: 'AI Professor · ${session.majorLabel}',
                icon: Icons.smart_display_outlined,
                onTap: () => MajorWowRouter.openContinue(
                  context,
                  session: session,
                  progress: progress,
                ),
              ),
              const Divider(color: VuV2Colors.stroke, height: 22),
              _ScheduleRow(
                time: '11:00',
                title: 'Lab',
                subtitle: MajorWowRouter.labsHeroTitle(session.majorId),
                icon: Icons.science_outlined,
                onTap: () => MajorWowRouter.openShowcaseForMajor(
                  context,
                  session.majorId,
                  session: session,
                  progress: progress,
                ),
              ),
              const Divider(color: VuV2Colors.stroke, height: 22),
              _ScheduleRow(
                time: '14:00',
                title: 'Career practical',
                subtitle: MajorWowRouter.continueLabel(session.majorId)
                    .replaceFirst('Enter ', ''),
                icon: Icons.work_outline_rounded,
                onTap: () => MajorWowRouter.openShowcaseForMajor(
                  context,
                  session.majorId,
                  session: session,
                  progress: progress,
                ),
              ),
              const Divider(color: VuV2Colors.stroke, height: 22),
              _ScheduleRow(
                time: '16:00',
                title: 'Adaptive review',
                subtitle: progress.dueAdaptiveReviews > 0
                    ? 'Fix ${progress.dueAdaptiveReviews} open confusion(s)'
                    : 'Mastery drill for weak spots',
                icon: Icons.psychology_alt_outlined,
                onTap: () => VuV2AdaptiveReviewDrillScreen.open(
                  context,
                  progress: progress,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        VuV2Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Learning path',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                progress.completedLessonIds.isEmpty
                    ? 'Start Orientation in your major. Your AI professor is ready.'
                    : 'Keep the loop: lecture → lab → quiz → mastery.',
                style: const TextStyle(color: VuV2Colors.mute, height: 1.45),
              ),
              const SizedBox(height: 14),
              VuV2PrimaryButton(
                label: 'Open degree roadmap',
                trailingArrow: true,
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
          ),
        ),
      ],
    );
  }

  static String _continueLabel(VuV2Session session) =>
      MajorWowRouter.continueLabel(session.majorId);

  static void _openContinue(
    BuildContext context,
    VuV2Session session,
    VuV2ProgressStore progress,
  ) {
    MajorWowRouter.openContinue(
      context,
      session: session,
      progress: progress,
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: VuV2Colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VuV2Colors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: VuV2Colors.mute,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VuV2Colors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: VuV2Colors.stroke),
          ),
          child: Column(
            children: <Widget>[
              Icon(icon, color: VuV2Colors.mint),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String time;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: const TextStyle(
                color: VuV2Colors.mint,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: VuV2Colors.mint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: VuV2Colors.mint, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right_rounded, color: VuV2Colors.mute),
        ],
      ),
    );
  }
}
