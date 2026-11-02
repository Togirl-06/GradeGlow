import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/appearance_service.dart';
import '../../utils/gpa_predictor.dart';
import '../../widgets/accent_color_picker_sheet.dart';
import '../data/vu_v2_lesson_flow.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_roadmap_sync.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_degree_roadmap_screen.dart';

/// Game-style Progress — courses with lessons, quizzes, labs, and exams.
class VuV2ProgressTab extends StatelessWidget {
  const VuV2ProgressTab({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  int get _xp => progress.lessonXp + 120;
  int get _level => 1 + (_xp ~/ 1000);
  int get _xpInto => _xp % 1000;

  @override
  Widget build(BuildContext context) {
    context.watch<AppearanceService>();
    VuV2Colors.syncTo(Theme.of(context));

    final VuV2DegreeRoadmap roadmap =
        VuV2RoadmapSync.forSubjectId(session.majorId);
    final List<VuV2RoadmapCourse> courses = roadmap.tracks
        .expand((VuV2RoadmapTrack t) => t.courses)
        .toList();

    final _Totals totals = _Totals.from(progress, courses);
    final double avgQuiz = progress.quizScores.isEmpty
        ? 0
        : progress.quizScores.values.reduce((double a, double b) => a + b) /
            progress.quizScores.length;
    final GpaForecast gpa = GpaPredictor.fromPercents(
      percents: progress.quizScores.values.map((double v) => v.round()).toList(),
    );

    return Container(
      color: VuV2Colors.navy,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        children: <Widget>[
          Text(
            'Progress',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 28,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${session.majorLabel} · keep leveling up',
            style: TextStyle(color: VuV2Colors.mute, height: 1.35),
          ),
          const SizedBox(height: 16),
          _LevelHero(
            level: _level,
            xp: _xpInto,
            xpMax: 1000,
            totalXp: _xp,
            streak: progress.streakDays,
            gpa: progress.quizScores.isEmpty ? '—' : progress.gpaLabel,
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _MeterCard(
                  label: 'Lessons',
                  value: '${totals.lessonsDone}/${totals.lessonsTotal}',
                  progress: totals.lessonPct,
                  color: VuV2Colors.mint,
                  icon: Icons.menu_book_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MeterCard(
                  label: 'Quizzes',
                  value: '${totals.quizzesDone}/${totals.quizzesTotal}',
                  progress: totals.quizPct,
                  color: VuV2Colors.dashCyan,
                  icon: Icons.quiz_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _MeterCard(
                  label: 'Labs',
                  value: '${totals.labsDone}/${totals.labsTotal}',
                  progress: totals.labPct,
                  color: VuV2Colors.dashGreen,
                  icon: Icons.science_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MeterCard(
                  label: 'Exams',
                  value: '${totals.examsDone}/${totals.examsTotal}',
                  progress: totals.examPct,
                  color: VuV2Colors.dashPink,
                  icon: Icons.timer_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VuV2Colors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: VuV2Colors.stroke),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _MiniStat(
                    label: 'Avg quiz',
                    value: progress.quizScores.isEmpty
                        ? '—'
                        : '${avgQuiz.round()}%',
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'Pred. GPA',
                    value: gpa.hasQuizzes ? gpa.gpaLabel : '—',
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'Study time',
                    value: '${progress.studyMinutes}m',
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'Certs',
                    value: '${progress.earnedCertificateIds.length}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              Text(
                'Your courses',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              TextButton(
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
                child: Text(
                  'Roadmap',
                  style: TextStyle(
                    color: VuV2Colors.mint,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (courses.isEmpty)
            Text(
              'Enroll in a program to track course progress here.',
              style: TextStyle(color: VuV2Colors.mute),
            )
          else
            ...courses.map(
              (VuV2RoadmapCourse c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CourseProgressCard(course: c, progress: progress),
              ),
            ),
          const SizedBox(height: 10),
          _AppearanceCard(onChanged: () {}),
        ],
      ),
    );
  }
}

class _Totals {
  const _Totals({
    required this.lessonsDone,
    required this.lessonsTotal,
    required this.quizzesDone,
    required this.quizzesTotal,
    required this.labsDone,
    required this.labsTotal,
    required this.examsDone,
    required this.examsTotal,
  });

  final int lessonsDone;
  final int lessonsTotal;
  final int quizzesDone;
  final int quizzesTotal;
  final int labsDone;
  final int labsTotal;
  final int examsDone;
  final int examsTotal;

  double get lessonPct =>
      lessonsTotal == 0 ? 0 : lessonsDone / lessonsTotal;
  double get quizPct => quizzesTotal == 0 ? 0 : quizzesDone / quizzesTotal;
  double get labPct => labsTotal == 0 ? 0 : labsDone / labsTotal;
  double get examPct => examsTotal == 0 ? 0 : examsDone / examsTotal;

  factory _Totals.from(
    VuV2ProgressStore progress,
    List<VuV2RoadmapCourse> courses,
  ) {
    int lessonsDone = 0;
    int lessonsTotal = 0;
    int quizzesDone = 0;
    int quizzesTotal = 0;
    int labsDone = 0;
    int labsTotal = 0;
    int examsDone = 0;
    int examsTotal = 0;

    for (final VuV2RoadmapCourse c in courses) {
      final _CourseStats s = _CourseStats.of(c, progress);
      lessonsDone += s.lessonsDone;
      lessonsTotal += s.lessonsTotal;
      quizzesDone += s.quizzesDone;
      quizzesTotal += s.quizzesTotal;
      labsDone += s.labsDone;
      labsTotal += s.labsTotal;
      examsDone += s.examsDone;
      examsTotal += s.examsTotal;
    }

    return _Totals(
      lessonsDone: lessonsDone,
      lessonsTotal: math.max(lessonsTotal, 1),
      quizzesDone: quizzesDone,
      quizzesTotal: math.max(quizzesTotal, 1),
      labsDone: labsDone,
      labsTotal: math.max(labsTotal, 1),
      examsDone: examsDone,
      examsTotal: math.max(examsTotal, 1),
    );
  }
}

class _CourseStats {
  const _CourseStats({
    required this.lessonsDone,
    required this.lessonsTotal,
    required this.quizzesDone,
    required this.quizzesTotal,
    required this.labsDone,
    required this.labsTotal,
    required this.examsDone,
    required this.examsTotal,
  });

  final int lessonsDone;
  final int lessonsTotal;
  final int quizzesDone;
  final int quizzesTotal;
  final int labsDone;
  final int labsTotal;
  final int examsDone;
  final int examsTotal;

  factory _CourseStats.of(VuV2RoadmapCourse course, VuV2ProgressStore progress) {
    final List<VuV2RoadmapLesson> lessons = course.allLessons;
    int quizzesDone = 0;
    int labsDone = 0;
    int examsDone = 0;
    for (final VuV2RoadmapLesson lesson in lessons) {
      final bool quizDone = progress.isStepComplete(
            lesson.id,
            VuV2LessonStep.knowledgeCheck,
          ) ||
          progress.quizScores.keys.any(
            (String k) => k.contains(lesson.id) || k.endsWith(lesson.id),
          );
      if (quizDone) quizzesDone++;
      if (progress.isStepComplete(lesson.id, VuV2LessonStep.realWorldLab)) {
        labsDone++;
      }
      final bool examDone = progress.isStepComplete(
            lesson.id,
            VuV2LessonStep.challengeMode,
          ) ||
          progress.quizScores.keys.any(
            (String k) =>
                k.toLowerCase().contains('exam') && k.contains(course.id),
          );
      if (examDone) examsDone++;
    }
    // Course-level exam score
    if (progress.quizScores.keys.any(
      (String k) =>
          k.toLowerCase().contains('exam') &&
          (k.contains(course.id) || k.contains(course.title.toLowerCase())),
    )) {
      examsDone = math.max(examsDone, 1);
    }

    final int lessonsDone =
        lessons.where((VuV2RoadmapLesson l) => progress.completedLessonIds.contains(l.id)).length;

    return _CourseStats(
      lessonsDone: lessonsDone,
      lessonsTotal: math.max(lessons.length, 1),
      quizzesDone: quizzesDone,
      quizzesTotal: math.max(lessons.length, 1),
      labsDone: labsDone,
      labsTotal: math.max(lessons.length, 1),
      examsDone: examsDone.clamp(0, 1),
      examsTotal: 1,
    );
  }
}

class _LevelHero extends StatelessWidget {
  const _LevelHero({
    required this.level,
    required this.xp,
    required this.xpMax,
    required this.totalXp,
    required this.streak,
    required this.gpa,
  });

  final int level;
  final int xp;
  final int xpMax;
  final int totalXp;
  final int streak;
  final String gpa;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            VuV2Colors.mint.withValues(alpha: 0.22),
            VuV2Colors.card,
            VuV2Colors.navyElevated,
          ],
        ),
        border: Border.all(color: VuV2Colors.mint.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 84,
            height: 84,
            child: CustomPaint(
              painter: _RingPainter(
                progress: (xp / xpMax).clamp(0.0, 1.0),
                color: VuV2Colors.mint,
                track: VuV2Colors.stroke,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'LV',
                      style: TextStyle(
                        color: VuV2Colors.mute,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '$level',
                      style: TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Player progress',
                  style: TextStyle(
                    color: VuV2Colors.mint,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$xp / $xpMax XP to next level',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (xp / xpMax).clamp(0.04, 1),
                    minHeight: 8,
                    backgroundColor: VuV2Colors.stroke,
                    color: VuV2Colors.mint,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    _Chip(icon: Icons.local_fire_department, label: '$streak day streak'),
                    const SizedBox(width: 8),
                    _Chip(icon: Icons.star_rounded, label: '$totalXp XP'),
                    const SizedBox(width: 8),
                    _Chip(icon: Icons.school_rounded, label: 'GPA $gpa'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: VuV2Colors.navy.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: VuV2Colors.stroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 13, color: VuV2Colors.gold),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeterCard extends StatelessWidget {
  const _MeterCard({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VuV2Colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VuV2Colors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: VuV2Colors.mute,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: VuV2Colors.stroke,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: VuV2Colors.mute, fontSize: 11),
        ),
      ],
    );
  }
}

class _CourseProgressCard extends StatelessWidget {
  const _CourseProgressCard({
    required this.course,
    required this.progress,
  });

  final VuV2RoadmapCourse course;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    final _CourseStats s = _CourseStats.of(course, progress);
    final double overall = <double>[
      s.lessonsDone / s.lessonsTotal,
      s.quizzesDone / s.quizzesTotal,
      s.labsDone / s.labsTotal,
      s.examsDone / s.examsTotal,
    ].reduce((double a, double b) => a + b) /
        4;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VuV2Colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VuV2Colors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  course.title,
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${(overall * 100).round()}%',
                style: TextStyle(
                  color: VuV2Colors.mint,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: overall.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: VuV2Colors.stroke,
              color: VuV2Colors.mint,
            ),
          ),
          const SizedBox(height: 12),
          _TrackRow(
            label: 'Lessons',
            done: s.lessonsDone,
            total: s.lessonsTotal,
            color: VuV2Colors.mint,
          ),
          _TrackRow(
            label: 'Quizzes',
            done: s.quizzesDone,
            total: s.quizzesTotal,
            color: VuV2Colors.dashCyan,
          ),
          _TrackRow(
            label: 'Labs',
            done: s.labsDone,
            total: s.labsTotal,
            color: VuV2Colors.dashGreen,
          ),
          _TrackRow(
            label: 'Exams',
            done: s.examsDone,
            total: s.examsTotal,
            color: VuV2Colors.dashPink,
          ),
        ],
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.label,
    required this.done,
    required this.total,
    required this.color,
  });

  final String label;
  final int done;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double pct = total == 0 ? 0 : done / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(
                color: VuV2Colors.mute,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: VuV2Colors.stroke,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$done/$total',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: VuV2Colors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({required this.onChanged});

  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final AppearanceService appearance = context.watch<AppearanceService>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VuV2Colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VuV2Colors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Appearance',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Same theme and accent as the main GradeGlow app.',
            style: TextStyle(color: VuV2Colors.mute, fontSize: 12),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Dark mode',
              style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700),
            ),
            value: isDark,
            activeThumbColor: VuV2Colors.mint,
            onChanged: (bool v) {
              appearance.setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
              onChanged();
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'App color',
              style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'Updates campus buttons and progress bars',
              style: TextStyle(color: VuV2Colors.mute, fontSize: 12),
            ),
            trailing: CircleAvatar(
              radius: 14,
              backgroundColor: appearance.primaryColor,
            ),
            onTap: () async {
              await AccentColorPickerSheet.show(context);
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2 - 6;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = track,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Compact panel kept for reuse on home widgets.
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
    return VuV2ProgressTab(session: session, progress: progress);
  }
}
