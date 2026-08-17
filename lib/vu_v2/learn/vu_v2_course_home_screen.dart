import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/bio_101_curriculum.dart';
import '../../data/diagram_misconception_catalog.dart';
import '../../data/diagram_misconception_store.dart';
import '../../data/university_learning_engine.dart';
import '../campus/vu_v2_adaptive_review_drill_screen.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_session.dart';
import '../data/vu_v2_mixed_quiz.dart';
import '../data/vu_v2_topic_content.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_assessment_screen.dart';
import 'vu_v2_lesson_activity_router.dart';
import 'vu_v2_lesson_learn_hub_screen.dart';
import 'vu_v2_module_intro_screen.dart';
import 'vu_v2_semester_exam_screen.dart';

/// Course dashboard matching the BIO-101 mockup (Overview · Lectures · …).
class VuV2CourseHomeScreen extends StatefulWidget {
  const VuV2CourseHomeScreen({
    super.key,
    required this.session,
    required this.progress,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.course,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final VuV2RoadmapCourse course;

  @override
  State<VuV2CourseHomeScreen> createState() => _VuV2CourseHomeScreenState();
}

class _VuV2CourseHomeScreenState extends State<VuV2CourseHomeScreen> {
  int _tab = 0;

  static const List<({IconData icon, String label})> _tabs =
      <({IconData icon, String label})>[
    (icon: Icons.dashboard_outlined, label: 'Overview'),
    (icon: Icons.smart_display_outlined, label: 'Lectures'),
    (icon: Icons.menu_book_outlined, label: 'Textbook'),
    (icon: Icons.science_outlined, label: 'Labs'),
    (icon: Icons.checklist_rtl_rounded, label: 'Quizzes'),
    (icon: Icons.grade_outlined, label: 'Grades'),
  ];

  VuV2Session get session => widget.session;
  VuV2ProgressStore get progress => widget.progress;
  VuV2RoadmapCourse get course => widget.course;

  List<VuV2RoadmapLesson> get _lessons => course.allLessons;

  List<String> get _lessonIds =>
      _lessons.map((VuV2RoadmapLesson l) => l.id).toList();

  double get _pct => progress.courseProgress(
        courseId: course.id,
        lessonIds: _lessonIds,
      );

  List<VuV2RoadmapModule> get _modules => course.modules.isNotEmpty
      ? course.modules
      : <VuV2RoadmapModule>[
          VuV2RoadmapModule(
            id: '${course.id}_all',
            title: 'Module 1 · Course lessons',
            lessons: course.lessons,
          ),
        ];

  String get _courseCode {
    if (course.id == 'general_biology') return Bio101Curriculum.courseCode;
    final String raw = course.id
        .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-')
        .toUpperCase();
    if (raw.length >= 6) return raw.substring(0, 7);
    return raw.isEmpty ? 'COURSE' : raw;
  }

  String get _professorName {
    final String intro = course.resolvedProfessorIntro;
    final RegExpMatch? m =
        RegExp(r'(Dr\.?\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)').firstMatch(intro);
    if (m != null) return m.group(1)!;
    return 'AI Professor';
  }

  @override
  Widget build(BuildContext context) {
    final int done =
        _lessonIds.where(progress.completedLessonIds.contains).length;
    final bool wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(
        backgroundColor: VuV2Colors.navy,
        title: Text(course.title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          _CourseHero(
            emoji: widget.facultyEmoji,
            code: '$_courseCode · ${course.resolvedMinutes ~/ 15} credits',
            title: course.title,
            blurb: course.subtitle ??
                'AI-led lectures, diagrams, labs, and quizzes built around this course.',
            professor: _professorName,
            done: done,
            total: _lessonIds.length,
            pct: _pct,
          ),
          const SizedBox(height: 14),
          _CourseTabBar(
            tabs: _tabs,
            index: _tab,
            onChanged: (int i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 16),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 3, child: _tabBody()),
                const SizedBox(width: 14),
                SizedBox(width: 280, child: _sidebar()),
              ],
            )
          else ...<Widget>[
            _tabBody(),
            const SizedBox(height: 14),
            _sidebar(),
          ],
        ],
      ),
    );
  }

  Widget _tabBody() {
    switch (_tab) {
      case 1:
        return _ModulesPanel(
          modules: _modules,
          session: session,
          progress: progress,
          subjectId: widget.subjectId,
          facultyTitle: widget.facultyTitle,
          facultyEmoji: widget.facultyEmoji,
          trackTitle: widget.trackTitle,
          course: course,
          lessonIds: _lessonIds,
        );
      case 2:
        return _ComingPanel(
          title: 'Textbook',
          body:
              'Chapter readings and figure callouts for ${course.title} open here.',
        );
      case 3:
        return _LabsPanel(
          subjectId: widget.subjectId,
          courseTitle: course.title,
          lessons: _lessons,
          modules: _modules,
          completedLessons: widget.progress.completedLessonIds.length,
        );
      case 4:
        return _QuizzesPanel(
          modules: _modules,
          course: course,
          subjectId: widget.subjectId,
          facultyTitle: widget.facultyTitle,
          facultyEmoji: widget.facultyEmoji,
          trackTitle: widget.trackTitle,
          progress: progress,
          session: session,
          lessons: _lessons,
        );
      case 5:
        return VuV2Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Grades',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Course progress ${(_pct * 100).round()}%\n'
                'Lessons complete: '
                '${_lessonIds.where(progress.completedLessonIds.contains).length}'
                ' / ${_lessonIds.length}',
                style: const TextStyle(color: VuV2Colors.mute, height: 1.5),
              ),
            ],
          ),
        );
      case 0:
      default:
        return _OverviewPanel(
          objectives: course.id == 'general_biology'
              ? Bio101Curriculum.learningObjectives
              : course.resolvedObjectives,
          modules: _modules,
          session: session,
          progress: progress,
          subjectId: widget.subjectId,
          facultyTitle: widget.facultyTitle,
          facultyEmoji: widget.facultyEmoji,
          trackTitle: widget.trackTitle,
          course: course,
          lessonIds: _lessonIds,
        );
    }
  }

  Widget _sidebar() {
    return Column(
      children: <Widget>[
        VuV2Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Course Info',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _infoRow('Difficulty', course.resolvedDifficulty),
              _infoRow('Credits', '${course.resolvedMinutes ~/ 15}'),
              _infoRow('Prerequisites', 'None'),
              _infoRow('Total Lessons', '${_lessonIds.length}'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        VuV2Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Your Professor',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: VuV2Colors.mint.withValues(alpha: 0.25),
                    child: Text(
                      widget.facultyEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _professorName,
                          style: const TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Professor of ${widget.facultyTitle}',
                          style: const TextStyle(
                            color: VuV2Colors.mute,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                course.resolvedProfessorIntro,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: VuV2Colors.mute,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              VuV2PrimaryButton(
                label: course.id == 'general_biology'
                    ? 'Start BIO-101 AI Professor'
                    : 'Start First Lesson',
                trailingArrow: true,
                onPressed: _lessons.isEmpty
                    ? null
                    : () {
                        final VuV2RoadmapLesson lesson = _lessons.first;
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => VuV2LessonLearnHubScreen(
                              session: session,
                              progress: progress,
                              subjectId: widget.subjectId,
                              facultyTitle: widget.facultyTitle,
                              facultyEmoji: widget.facultyEmoji,
                              trackTitle: widget.trackTitle,
                              courseTitle: course.title,
                              lesson: lesson,
                              courseLessonIds: _lessonIds,
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

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label, style: const TextStyle(color: VuV2Colors.mute)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseHero extends StatelessWidget {
  const _CourseHero({
    required this.emoji,
    required this.code,
    required this.title,
    required this.blurb,
    required this.professor,
    required this.done,
    required this.total,
    required this.pct,
  });

  final String emoji;
  final String code;
  final String title;
  final String blurb;
  final String professor;
  final int done;
  final int total;
  final double pct;

  @override
  Widget build(BuildContext context) {
    return VuV2Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: VuV2Colors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      code,
                      style: const TextStyle(
                        color: VuV2Colors.mint,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            blurb,
            style: const TextStyle(color: VuV2Colors.mute, height: 1.45),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 14,
                backgroundColor: VuV2Colors.mint.withValues(alpha: 0.2),
                child: const Icon(Icons.person, size: 16, color: VuV2Colors.mint),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Professor  $professor',
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '$done/$total lessons · ${(pct * 100).round()}%',
                style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          VuV2ProgressBar(value: pct, height: 6),
        ],
      ),
    );
  }
}

class _CourseTabBar extends StatelessWidget {
  const _CourseTabBar({
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  final List<({IconData icon, String label})> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<Widget>.generate(tabs.length, (int i) {
          final bool on = i == index;
          final tab = tabs[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: on ? VuV2Colors.mint : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      tab.icon,
                      size: 18,
                      color: on ? VuV2Colors.mint : VuV2Colors.mute,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab.label,
                      style: TextStyle(
                        color: on ? VuV2Colors.mint : VuV2Colors.mute,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OverviewPanel extends StatelessWidget {
  const _OverviewPanel({
    required this.objectives,
    required this.modules,
    required this.session,
    required this.progress,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.course,
    required this.lessonIds,
  });

  final List<String> objectives;
  final List<VuV2RoadmapModule> modules;
  final VuV2Session session;
  final VuV2ProgressStore progress;
  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final VuV2RoadmapCourse course;
  final List<String> lessonIds;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        VuV2Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Learning Objectives',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              ...List<Widget>.generate(objectives.take(5).length, (int i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: VuV2Colors.mint,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Color(0xFF04110C),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          objectives[i],
                          style: const TextStyle(
                            color: VuV2Colors.ink,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        if (progress.topDiagramMisconceptions.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Adaptive Review Queue',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The AI Professor re-teaches these pairs — or fix them now in a 2-minute drill.',
                  style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
                ),
                const SizedBox(height: 12),
                ...progress.topDiagramMisconceptions.map((String id) {
                  final DiagramMisconceptionDef? def =
                      DiagramMisconceptionCatalog.byId(id);
                  final int count = progress.diagramMisconceptions[id] ?? 0;
                  if (def == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => VuV2AdaptiveReviewDrillScreen.open(
                          context,
                          progress: progress,
                          focusMisconceptionId: id,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                count >= DiagramMisconceptionStore.reviewThreshold
                                    ? Icons.replay_circle_filled
                                    : Icons.warning_amber_rounded,
                                color: count >=
                                        DiagramMisconceptionStore.reviewThreshold
                                    ? VuV2Colors.mint
                                    : const Color(0xFFEAB308),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${def.labelA} vs ${def.labelB} · $count miss${count == 1 ? '' : 'es'}',
                                  style: const TextStyle(
                                    color: VuV2Colors.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: VuV2Colors.mute,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                VuV2PrimaryButton(
                  label: 'Start adaptive review',
                  trailingArrow: true,
                  onPressed: () => VuV2AdaptiveReviewDrillScreen.open(
                    context,
                    progress: progress,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        _ModulesPanel(
          modules: modules,
          session: session,
          progress: progress,
          subjectId: subjectId,
          facultyTitle: facultyTitle,
          facultyEmoji: facultyEmoji,
          trackTitle: trackTitle,
          course: course,
          lessonIds: lessonIds,
          compact: true,
        ),
      ],
    );
  }
}

class _ModulesPanel extends StatelessWidget {
  const _ModulesPanel({
    required this.modules,
    required this.session,
    required this.progress,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.course,
    required this.lessonIds,
    this.compact = false,
  });

  final List<VuV2RoadmapModule> modules;
  final VuV2Session session;
  final VuV2ProgressStore progress;
  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final VuV2RoadmapCourse course;
  final List<String> lessonIds;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return VuV2Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Course Modules',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          ...modules.map((VuV2RoadmapModule m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => VuV2ModuleIntroScreen(
                            session: session,
                            progress: progress,
                            subjectId: subjectId,
                            facultyTitle: facultyTitle,
                            facultyEmoji: facultyEmoji,
                            trackTitle: trackTitle,
                            course: course,
                            module: m,
                            courseLessonIds: lessonIds,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      m.title,
                      style: const TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List<Widget>.generate(m.lessons.length, (int i) {
                    final VuV2RoadmapLesson lesson = m.lessons[i];
                    final bool done =
                        progress.completedLessonIds.contains(lesson.id);
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => VuV2LessonLearnHubScreen(
                              session: session,
                              progress: progress,
                              subjectId: subjectId,
                              facultyTitle: facultyTitle,
                              facultyEmoji: facultyEmoji,
                              trackTitle: trackTitle,
                              courseTitle: course.title,
                              lesson: lesson,
                              courseLessonIds: lessonIds,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: done
                                    ? VuV2Colors.mint.withValues(alpha: 0.2)
                                    : VuV2Colors.navyElevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: VuV2Colors.stroke),
                              ),
                              child: Text(
                                done ? '✓' : '${i + 1}',
                                style: TextStyle(
                                  color: done ? VuV2Colors.mint : VuV2Colors.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                lesson.title,
                                style: const TextStyle(
                                  color: VuV2Colors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              _mins(lesson),
                              style: const TextStyle(
                                color: VuV2Colors.mute,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (!compact)
                    TextButton.icon(
                      onPressed: () {
                        final pack = VuV2TopicContent.forLesson(
                          subjectId: subjectId,
                          facultyTitle: facultyTitle,
                          facultyEmoji: facultyEmoji,
                          trackTitle: trackTitle,
                          courseTitle: course.title,
                          topicTitle: '${m.title} quiz',
                          interactive: true,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => VuV2AssessmentScreen(
                              title: '${m.title} quiz',
                              subtitle: '${course.title} · pass ≥70%',
                              questions: VuV2MixedQuiz.enrich(pack.topicQuiz),
                              onCompleted: (double pct) {
                                progress.recordQuiz('${m.id}_quiz', pct);
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.quiz_outlined, size: 18),
                      label: const Text('Module quiz'),
                      style: TextButton.styleFrom(
                        foregroundColor: VuV2Colors.mint,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _mins(VuV2RoadmapLesson lesson) {
    final String t = lesson.title.toLowerCase();
    if (t.contains('lab') || t.contains('experiment')) return '25 min';
    if (t.contains('quiz')) return '10 min';
    if (t.contains('reading') || t.contains('notes')) return '20 min';
    if (t.contains('diagram')) return '15 min';
    return '12 min';
  }
}

class _QuizzesPanel extends StatelessWidget {
  const _QuizzesPanel({
    required this.modules,
    required this.course,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.progress,
    required this.session,
    required this.lessons,
  });

  final List<VuV2RoadmapModule> modules;
  final VuV2RoadmapCourse course;
  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final VuV2ProgressStore progress;
  final VuV2Session session;
  final List<VuV2RoadmapLesson> lessons;

  @override
  Widget build(BuildContext context) {
    return VuV2Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Quizzes & Exam',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          ...modules.map(
            (VuV2RoadmapModule m) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.quiz_outlined, color: VuV2Colors.mint),
              title: Text(
                '${m.title} quiz',
                style: const TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                final pack = VuV2TopicContent.forLesson(
                  subjectId: subjectId,
                  facultyTitle: facultyTitle,
                  facultyEmoji: facultyEmoji,
                  trackTitle: trackTitle,
                  courseTitle: course.title,
                  topicTitle: '${m.title} quiz',
                  interactive: true,
                );
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VuV2AssessmentScreen(
                      title: '${m.title} quiz',
                      subtitle: '${course.title} · pass ≥70%',
                      questions: VuV2MixedQuiz.enrich(pack.topicQuiz),
                      onCompleted: (double pct) {
                        progress.recordQuiz('${m.id}_quiz', pct);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          VuV2PrimaryButton(
            label: 'Course exam',
            icon: Icons.timer_outlined,
            onPressed: () {
              final exam = VuV2TopicContent.courseExam(
                subjectId: subjectId,
                facultyTitle: facultyTitle,
                courseTitle: course.title,
                lessonTitles:
                    lessons.map((VuV2RoadmapLesson l) => l.title).toList(),
              );
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VuV2SemesterExamScreen(
                    progress: progress,
                    title: '${course.title} exam',
                    subtitle: '$trackTitle · timed · pass ≥70%',
                    questions: VuV2MixedQuiz.enrich(exam.questions),
                    studentName: session.displayName,
                    courseId: course.id,
                    courseTitle: course.title,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LabsPanel extends StatelessWidget {
  const _LabsPanel({
    required this.subjectId,
    required this.courseTitle,
    required this.lessons,
    required this.modules,
    required this.completedLessons,
  });

  final String subjectId;
  final String courseTitle;
  final List<VuV2RoadmapLesson> lessons;
  final List<VuV2RoadmapModule> modules;
  final int completedLessons;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> lessonModules = <String, String>{};
    for (final VuV2RoadmapModule m in modules) {
      for (final VuV2RoadmapLesson l in m.lessons) {
        lessonModules[l.id] = m.title;
      }
    }

    final List<({VuV2RoadmapLesson lesson, UniversityLabLink link})> linked =
        <({VuV2RoadmapLesson lesson, UniversityLabLink link})>[];
    for (final VuV2RoadmapLesson lesson in lessons) {
      final UniversityLabLink? link = UniversityLearningEngine.labForLesson(
        subjectId: subjectId,
        lessonTitle: lesson.title,
        moduleTitle: lessonModules[lesson.id],
      );
      if (link != null) {
        linked.add((lesson: lesson, link: link));
      }
    }

    if (linked.isEmpty) {
      return const _ComingPanel(
        title: 'Labs',
        body: 'Practical laboratories for this course will appear here as lectures unlock.',
      );
    }

    return VuV2Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Course laboratories',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Each lab connects to a lecture. Complete the lesson, then enter the virtual laboratory.',
            style: TextStyle(color: VuV2Colors.mute, height: 1.45),
          ),
          const SizedBox(height: 14),
          ...linked.map((({VuV2RoadmapLesson lesson, UniversityLabLink link}) e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: VuV2Colors.stroke),
                ),
                tileColor: VuV2Colors.card,
                leading: const Icon(Icons.science_outlined, color: VuV2Colors.mint),
                title: Text(
                  e.link.title,
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  'After: ${e.lesson.title}\n~${e.link.estimatedMinutes} min · ${e.link.difficulty}',
                  style: const TextStyle(color: VuV2Colors.mute, height: 1.35),
                ),
                trailing: FilledButton(
                  onPressed: () {
                    unawaited(
                      VuV2LessonActivityRouter.openLinkedLab(
                        context: context,
                        link: e.link,
                        subjectId: subjectId,
                        courseTitle: courseTitle,
                        topicTitle: e.lesson.title,
                        labLevel: VuV2LessonActivityRouter.levelFor(
                          completedLessons,
                        ),
                      ),
                    );
                  },
                  child: const Text('ENTER LAB'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ComingPanel extends StatelessWidget {
  const _ComingPanel({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return VuV2Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: VuV2Colors.mute, height: 1.45)),
        ],
      ),
    );
  }
}