import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_roadmap_sync.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_faculty_screen.dart';
import 'vu_v2_featured_majors.dart';
import 'vu_v2_school_hub_screen.dart';

/// Virtual University dashboard — matches GradeGlow VU mockup.
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
    final VuV2DegreeRoadmap roadmap =
        VuV2RoadmapSync.forSubjectId(session.majorId);
    final List<String> lessonIds = roadmap.tracks
        .expand((VuV2RoadmapTrack t) => t.courses)
        .expand((VuV2RoadmapCourse c) => c.allLessons)
        .map((VuV2RoadmapLesson l) => l.id)
        .toList();
    final double degreePct = progress.degreeProgress(lessonIds: lessonIds);
    final int coursesTotal = roadmap.tracks
        .expand((VuV2RoadmapTrack t) => t.courses)
        .length
        .clamp(1, 99);
    final int coursesDone = roadmap.tracks
        .expand((VuV2RoadmapTrack t) => t.courses)
        .where((VuV2RoadmapCourse c) {
          final List<String> ids =
              c.allLessons.map((VuV2RoadmapLesson l) => l.id).toList();
          if (ids.isEmpty) return false;
          return ids.every(progress.completedLessonIds.contains);
        })
        .length;
    final int achievements = progress.earnedCertificateIds.length +
        (progress.completedLessonIds.length ~/ 5);
    final bool wide = MediaQuery.sizeOf(context).width >= 960;

    return Container(
      color: VuV2Colors.dashBg,
      child: ListView(
        padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 8, wide ? 28 : 16, 36),
        children: <Widget>[
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 7, child: _HeroCard(session: session)),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: _ProgressCard(
                    overall: degreePct,
                    coursesDone: coursesDone,
                    coursesTotal: coursesTotal.clamp(1, 6),
                    careerGamesDone: 0,
                    careerGamesTotal: 6,
                    achievements: achievements.clamp(0, 20),
                    achievementsTotal: 20,
                  ),
                ),
              ],
            )
          else ...<Widget>[
            _HeroCard(session: session),
            const SizedBox(height: 14),
            _ProgressCard(
              overall: degreePct,
              coursesDone: coursesDone,
              coursesTotal: coursesTotal.clamp(1, 6),
              careerGamesDone: 0,
              careerGamesTotal: 6,
              achievements: achievements.clamp(0, 20),
              achievementsTotal: 20,
            ),
          ],
          const SizedBox(height: 22),
          Text(
            'Choose Your Major',
            style: TextStyle(
              color: VuV2Colors.dashInk,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: VuFeaturedMajors.all.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 12),
              itemBuilder: (BuildContext context, int i) {
                final VuFeaturedMajor m = VuFeaturedMajors.all[i];
                final bool selected = session.majorId == m.id ||
                    session.majorId.contains(m.id);
                return _MajorCard(
                  major: m,
                  selected: selected,
                  onTap: () async {
                    await session.completeOnboarding(
                      name: session.displayName,
                      goals: session.goals,
                      majorId: m.id,
                      majorLabel: m.title,
                      weeklyMinutes: session.weeklyMinutes,
                    );
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VuV2SchoolHubScreen(
                          session: session,
                          progress: progress,
                          major: m,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          if (wide)
            Row(
              children: <Widget>[
                Expanded(child: _ExploreCampusCard(session: session, progress: progress)),
                const SizedBox(width: 16),
                Expanded(child: _ContinueStrip(session: session, progress: progress)),
              ],
            )
          else ...<Widget>[
            _ExploreCampusCard(session: session, progress: progress),
            const SizedBox(height: 14),
            _ContinueStrip(session: session, progress: progress),
          ],
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.session});

  final VuV2Session session;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF1A1040),
            Color(0xFF0E1424),
            Color(0xFF12253A),
          ],
        ),
        border: Border.all(color: VuV2Colors.dashPurple.withValues(alpha: 0.35)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: VuV2Colors.dashPurple.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -20,
            top: -10,
            child: CustomPaint(
              size: const Size(220, 220),
              painter: _CampusSkylinePainter(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'GradeGlow Virtual University',
                  style: TextStyle(
                    color: VuV2Colors.dashPurple,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Explore. Learn. Practice.\nBuild your future.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    height: 1.15,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VuV2FacultyScreen(
                          session: session,
                          embedded: false,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: VuV2Colors.dashPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Explore Campus',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusSkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint glow = Paint()
      ..color = VuV2Colors.dashPurple.withValues(alpha: 0.15);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.4), 70, glow);

    final Paint bldg = Paint()..color = const Color(0xFF24304A);
    final Paint lit = Paint()..color = VuV2Colors.dashCyan.withValues(alpha: 0.55);
    final Paint pink = Paint()..color = VuV2Colors.dashPink.withValues(alpha: 0.45);

    void tower(double x, double w, double h, double top) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, w, h),
          const Radius.circular(6),
        ),
        bldg,
      );
      for (double y = top + 12; y < top + h - 10; y += 14) {
        for (double wx = x + 6; wx < x + w - 8; wx += 10) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(wx, y, 5, 7),
              const Radius.circular(1),
            ),
            (wx + y) % 3 == 0 ? pink : lit,
          );
        }
      }
    }

    tower(40, 36, 120, 70);
    tower(90, 48, 150, 40);
    tower(150, 32, 100, 90);
    tower(20, 28, 80, 110);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.overall,
    required this.coursesDone,
    required this.coursesTotal,
    required this.careerGamesDone,
    required this.careerGamesTotal,
    required this.achievements,
    required this.achievementsTotal,
  });

  final double overall;
  final int coursesDone;
  final int coursesTotal;
  final int careerGamesDone;
  final int careerGamesTotal;
  final int achievements;
  final int achievementsTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VuV2Colors.dashCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: VuV2Colors.dashStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'My Progress',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              SizedBox(
                width: 88,
                height: 88,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: overall.clamp(0.0, 1.0),
                    color: VuV2Colors.dashPurple,
                  ),
                  child: Center(
                    child: Text(
                      '${(overall * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Overall Completion',
                      style: TextStyle(
                        color: VuV2Colors.dashMute,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatLine(
                      label: 'Courses',
                      value: '$coursesDone/$coursesTotal',
                      color: VuV2Colors.dashCyan,
                    ),
                    _StatLine(
                      label: 'Career Games',
                      value: '$careerGamesDone/$careerGamesTotal',
                      color: VuV2Colors.dashPink,
                    ),
                    _StatLine(
                      label: 'Achievements',
                      value: '$achievements/$achievementsTotal',
                      color: VuV2Colors.dashGold,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: VuV2Colors.dashMute, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

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
        ..color = Colors.white12,
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
      oldDelegate.progress != progress;
}

class _MajorCard extends StatelessWidget {
  const _MajorCard({
    required this.major,
    required this.selected,
    required this.onTap,
  });

  final VuFeaturedMajor major;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: Material(
        color: VuV2Colors.dashCard,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? major.accent
                    : VuV2Colors.dashStroke,
                width: selected ? 1.6 : 1,
              ),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: major.accent.withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        major.accent.withValues(alpha: 0.55),
                        major.accent.withValues(alpha: 0.1),
                      ],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: major.accent.withValues(alpha: 0.45),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Icon(major.icon, color: major.accent, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  major.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreCampusCard extends StatelessWidget {
  const _ExploreCampusCard({
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        border: Border.all(color: VuV2Colors.dashStroke),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomPaint(painter: _CampusSkylinePainter()),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Explore Campus',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Walk the schools · meet faculty · open your path',
                  style: TextStyle(color: VuV2Colors.dashMute, fontSize: 12),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VuV2FacultyScreen(session: session),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: VuV2Colors.dashPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Go to Campus',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueStrip extends StatelessWidget {
  const _ContinueStrip({
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    final VuFeaturedMajor major = VuFeaturedMajors.all.firstWhere(
      (VuFeaturedMajor m) =>
          session.majorId == m.id || session.majorId.contains(m.id),
      orElse: () => VuFeaturedMajors.all.first,
    );
    return Container(
      height: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: VuV2Colors.dashCard,
        border: Border.all(color: major.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'CONTINUE · ${major.title.toUpperCase()}',
            style: TextStyle(
              color: major.accent,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            session.continueTitle ?? 'Open School of ${major.title}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VuV2SchoolHubScreen(
                      session: session,
                      progress: progress,
                      major: major,
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: VuV2Colors.dashPink,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Continue Learning',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
