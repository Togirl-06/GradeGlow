import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_roadmap_sync.dart';
import '../data/vu_v2_scope.dart';
import '../data/vu_v2_session.dart';
import '../data/vu_v2_topic_content.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_assessment_screen.dart';
import 'vu_v2_course_home_screen.dart';
import 'vu_v2_lesson_learn_hub_screen.dart';

/// Browse a synced college / university degree roadmap for one faculty.
class VuV2DegreeRoadmapScreen extends StatefulWidget {
  const VuV2DegreeRoadmapScreen({
    super.key,
    required this.session,
    required this.subjectId,
    this.progress,
  });

  final VuV2Session session;
  final String subjectId;
  final VuV2ProgressStore? progress;

  @override
  State<VuV2DegreeRoadmapScreen> createState() =>
      _VuV2DegreeRoadmapScreenState();
}

class _VuV2DegreeRoadmapScreenState extends State<VuV2DegreeRoadmapScreen> {
  late final VuV2DegreeRoadmap _roadmap =
      VuV2RoadmapSync.forSubjectId(widget.subjectId);
  String? _expandedTrackId;

  @override
  void initState() {
    super.initState();
    if (_roadmap.tracks.isNotEmpty) {
      _expandedTrackId = _roadmap.tracks.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final VuV2DegreeRoadmap roadmap = _roadmap;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                roadmap.title,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      VuV2Colors.orange,
                      VuV2Colors.orangeDeep,
                      VuV2Colors.navy,
                    ],
                    stops: const <double>[0, 0.45, 1],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(roadmap.emoji, style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text(
                          roadmap.tagline ?? 'University degree roadmap',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                VuV2Surface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'SYNCED WITH COLLEGE / UNI ROADMAPS',
                        style: TextStyle(
                          color: VuV2Colors.orange,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        roadmap.sourceLabel,
                        style: TextStyle(
                          color: VuV2Colors.ink,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          _StatChip(
                            label: '${roadmap.trackCount}',
                            caption: 'paths',
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: '${roadmap.courseCount}',
                            caption: 'courses',
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: '${roadmap.lessonCount}',
                            caption: 'lessons',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (roadmap.firstLesson != null)
                  VuV2PrimaryButton(
                    label: 'Start first lesson',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => _openLesson(
                      trackTitle: roadmap.tracks.first.title,
                      course: roadmap.firstCourse!,
                      lesson: roadmap.firstLesson!,
                    ),
                  ),
                const SizedBox(height: 22),
                const VuV2SectionTitle('Degree roadmap'),
                const SizedBox(height: 10),
                if (roadmap.tracks.isEmpty)
                  const VuV2EmptyState(
                    title: 'No courses in this roadmap yet',
                    subtitle: 'Try another program from Lecture Halls.',
                  )
                else
                  ...roadmap.tracks.map(_trackCard),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackCard(VuV2RoadmapTrack track) {
    final bool open = _expandedTrackId == track.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: VuV2Surface(
        padding: EdgeInsets.zero,
        child: Column(
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.circular(VuV2Radii.lg),
              onTap: () => setState(() {
                _expandedTrackId = open ? null : track.id;
              }),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            track.title,
                            style: TextStyle(
                              color: VuV2Colors.ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          if (track.subtitle != null) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              track.subtitle!,
                              style: TextStyle(
                                color: VuV2Colors.mute,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            '${track.courseCount} courses · ${track.lessonCount} lessons',
                            style: TextStyle(
                              color: VuV2Colors.orange,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      open
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: VuV2Colors.mute,
                    ),
                  ],
                ),
              ),
            ),
            if (open)
              ...track.courses.map(
                (VuV2RoadmapCourse course) => _courseTile(track, course),
              ),
          ],
        ),
      ),
    );
  }

  VuV2ProgressStore? get _progress =>
      widget.progress ?? VuV2Scope.maybeOf(context)?.progress;

  Widget _courseTile(VuV2RoadmapTrack track, VuV2RoadmapCourse course) {
    return Material(
      color: VuV2Colors.navy.withValues(alpha: 0.35),
      child: InkWell(
        onTap: () {
          final VuV2ProgressStore store = _progress ?? VuV2ProgressStore();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => VuV2CourseHomeScreen(
                session: widget.session,
                progress: store,
                subjectId: _roadmap.subjectId,
                facultyTitle: _roadmap.title,
                facultyEmoji: _roadmap.emoji,
                trackTitle: track.title,
                course: course,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: <Widget>[
              if (course.emoji != null) ...<Widget>[
                Text(course.emoji!, style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
              ] else ...<Widget>[
                Icon(Icons.menu_book_outlined, color: VuV2Colors.orange),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      course.title,
                      style: TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      course.subtitle ?? '${course.lessonCount} lessons',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: VuV2Colors.mute,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: VuV2Colors.mute),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLesson({
    required String trackTitle,
    required VuV2RoadmapCourse course,
    required VuV2RoadmapLesson lesson,
  }) async {
    await widget.session.setContinue(
      title: lesson.title,
      subtitle: '${_roadmap.title} · ${course.title}',
      progress: 0.12,
    );
    if (!mounted) return;
    await _openVuV2Lesson(
      context: context,
      session: widget.session,
      progress: _progress,
      subjectId: _roadmap.subjectId,
      facultyTitle: _roadmap.title,
      facultyEmoji: _roadmap.emoji,
      trackTitle: trackTitle,
      courseTitle: course.title,
      lesson: lesson,
    );
  }
}

/// Modules / lessons inside one synced course.
class VuV2CourseRoadmapScreen extends StatelessWidget {
  const VuV2CourseRoadmapScreen({
    super.key,
    required this.session,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.course,
  });

  final VuV2Session session;
  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final VuV2RoadmapCourse course;

  @override
  Widget build(BuildContext context) {
    final bool hasModules = course.modules.isNotEmpty;
    final List<VuV2RoadmapLesson> allLessons = course.allLessons;

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            '$facultyTitle · $trackTitle',
            style: TextStyle(color: VuV2Colors.mute),
          ),
          if (course.subtitle != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              course.subtitle!,
              style: TextStyle(color: VuV2Colors.mute, height: 1.4),
            ),
          ],
          const SizedBox(height: 14),
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'COURSE PATH',
                  style: TextStyle(
                    color: VuV2Colors.orange,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${allLessons.length} topics with rich textbook notes + '
                  'end-of-topic quizzes. Finish with the course final exam.',
                  style: TextStyle(color: VuV2Colors.ink, height: 1.4),
                ),
                const SizedBox(height: 12),
                VuV2PrimaryButton(
                  label: 'Course final exam',
                  icon: Icons.assignment_turned_in_outlined,
                  onPressed: () => _openExam(context, allLessons),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (hasModules)
            ...course.modules.map((VuV2RoadmapModule module) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      module.title,
                      style: TextStyle(
                        color: VuV2Colors.orange,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...module.lessons.map(
                      (VuV2RoadmapLesson lesson) => _LessonRow(
                        lesson: lesson,
                        subjectId: subjectId,
                        onTap: () => _open(context, lesson),
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            ...course.lessons.map(
              (VuV2RoadmapLesson lesson) => _LessonRow(
                lesson: lesson,
                subjectId: subjectId,
                onTap: () => _open(context, lesson),
              ),
            ),
          const SizedBox(height: 8),
          VuV2PrimaryButton(
            label: 'Take course final exam',
            icon: Icons.school_rounded,
            onPressed: () => _openExam(context, allLessons),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, VuV2RoadmapLesson lesson) async {
    await session.setContinue(
      title: lesson.title,
      subtitle: '$facultyTitle · ${course.title}',
      progress: 0.18,
    );
    if (!context.mounted) return;
    await _openVuV2Lesson(
      context: context,
      session: session,
      progress: VuV2Scope.maybeOf(context)?.progress,
      subjectId: subjectId,
      facultyTitle: facultyTitle,
      facultyEmoji: facultyEmoji,
      trackTitle: trackTitle,
      courseTitle: course.title,
      lesson: lesson,
    );
  }

  Future<void> _openExam(
    BuildContext context,
    List<VuV2RoadmapLesson> lessons,
  ) async {
    final exam = VuV2TopicContent.courseExam(
      subjectId: subjectId,
      facultyTitle: facultyTitle,
      courseTitle: course.title,
      lessonTitles: lessons.map((VuV2RoadmapLesson l) => l.title).toList(),
      count: 20,
    );
    final bool? passed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => VuV2AssessmentScreen(
          title: '${course.title} final exam',
          subtitle:
              '$facultyTitle · ${exam.questionCount} questions · pass ≥${exam.passPercent}%',
          questions: exam.questions,
          passPercent: exam.passPercent,
          isExam: true,
        ),
      ),
    );
    if (!context.mounted) return;
    if (passed == true) {
      await session.setContinue(
        title: '${course.title} · exam passed',
        subtitle: facultyTitle,
        progress: 1,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course final exam passed. Well done.')),
      );
    }
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson,
    required this.onTap,
    this.subjectId = '',
  });

  final VuV2RoadmapLesson lesson;
  final VoidCallback onTap;
  final String subjectId;

  String get _subtitle {
    if (lesson.subtitle != null && lesson.subtitle!.trim().isNotEmpty) {
      return lesson.subtitle!;
    }
    return 'Choose Notes or AI Tutor · private professor';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: VuV2Colors.navyElevated,
        borderRadius: BorderRadius.circular(VuV2Radii.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(VuV2Radii.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Icon(Icons.school_outlined, color: VuV2Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        lesson.title,
                        style: TextStyle(
                          color: VuV2Colors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: VuV2Colors.mute,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.play_circle_outline, color: VuV2Colors.mute),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.caption});

  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: VuV2Colors.navy.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(VuV2Radii.md),
        ),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: VuV2Colors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            Text(
              caption,
              style: TextStyle(color: VuV2Colors.mute, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the learn hub: Notes · AI Tutor · Quiz.
Future<void> _openVuV2Lesson({
  required BuildContext context,
  required VuV2Session session,
  VuV2ProgressStore? progress,
  required String subjectId,
  required String facultyTitle,
  required String facultyEmoji,
  required String trackTitle,
  required String courseTitle,
  required VuV2RoadmapLesson lesson,
}) async {
  final VuV2ProgressStore? store =
      progress ?? VuV2Scope.maybeOf(context)?.progress;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => VuV2LessonLearnHubScreen(
        session: session,
        progress: store,
        subjectId: subjectId,
        facultyTitle: facultyTitle,
        facultyEmoji: facultyEmoji,
        trackTitle: trackTitle,
        courseTitle: courseTitle,
        lesson: lesson,
      ),
    ),
  );
}
