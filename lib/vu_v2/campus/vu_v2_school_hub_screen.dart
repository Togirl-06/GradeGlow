import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_roadmap_sync.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';
import '../learn/vu_v2_degree_roadmap_screen.dart';
import '../learn/vu_v2_lesson_learn_hub_screen.dart';
import 'vu_v2_featured_majors.dart';

/// School overview matching the mockup (e.g. School of Nursing).
class VuV2SchoolHubScreen extends StatefulWidget {
  const VuV2SchoolHubScreen({
    super.key,
    required this.session,
    required this.progress,
    required this.major,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final VuFeaturedMajor major;

  @override
  State<VuV2SchoolHubScreen> createState() => _VuV2SchoolHubScreenState();
}

class _VuV2SchoolHubScreenState extends State<VuV2SchoolHubScreen> {
  int _tab = 0;
  int _selectedModule = 0;

  VuV2DegreeRoadmap get _roadmap =>
      VuV2RoadmapSync.forSubjectId(widget.major.id);

  List<VuV2RoadmapCourse> get _courses => _roadmap.tracks
      .expand((VuV2RoadmapTrack t) => t.courses)
      .toList();

  VuV2RoadmapCourse? get _course =>
      _courses.isEmpty ? null : _courses.first;

  List<VuV2RoadmapModule> get _modules {
    final VuV2RoadmapCourse? c = _course;
    if (c == null) return const <VuV2RoadmapModule>[];
    if (c.modules.isNotEmpty) return c.modules;
    return <VuV2RoadmapModule>[
      VuV2RoadmapModule(
        id: '${c.id}_all',
        title: 'Module 1 · Foundations',
        lessons: c.lessons,
      ),
    ];
  }

  double get _pct {
    final VuV2RoadmapCourse? c = _course;
    if (c == null) return 0;
    final List<String> ids =
        c.allLessons.map((VuV2RoadmapLesson l) => l.id).toList();
    return widget.progress.courseProgress(courseId: c.id, lessonIds: ids);
  }

  @override
  Widget build(BuildContext context) {
    final VuFeaturedMajor major = widget.major;
    final List<VuV2RoadmapModule> modules = _modules;
    final VuV2RoadmapModule? selected =
        modules.isEmpty ? null : modules[_selectedModule.clamp(0, modules.length - 1)];

    return Scaffold(
      backgroundColor: VuV2Colors.dashBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
                ),
                Text(
                  'School of ${major.title}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Hero card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: <Color>[
                    major.accent.withValues(alpha: 0.35),
                    VuV2Colors.dashCard,
                    const Color(0xFF1A1030),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: major.accent.withValues(alpha: 0.35)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: major.accent.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: <Color>[major.accent, VuV2Colors.dashPink],
                      ),
                    ),
                    child: Center(
                      child: Text(major.emoji, style: const TextStyle(fontSize: 34)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'School of ${major.title}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: _pct.clamp(0.05, 1),
                            minHeight: 8,
                            backgroundColor: Colors.white12,
                            color: major.accent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(_pct * 100).round()}% complete',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VuV2DegreeRoadmapScreen(
                        session: widget.session,
                        subjectId: major.id,
                        progress: widget.progress,
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: major.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continue Learning',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (final (int i, String label) in <(int, String)>[
                    (0, 'Modules'),
                    (1, 'Career Games'),
                    (2, 'Resources'),
                    (3, 'Grades'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: _tab == i,
                        label: Text(label),
                        onSelected: (_) => setState(() => _tab = i),
                        selectedColor: major.accent,
                        backgroundColor: VuV2Colors.dashCard,
                        labelStyle: TextStyle(
                          color: _tab == i ? Colors.white : VuV2Colors.dashMute,
                          fontWeight: FontWeight.w800,
                        ),
                        side: BorderSide(
                          color: _tab == i
                              ? major.accent
                              : VuV2Colors.dashStroke,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_tab == 0) ...<Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: <Widget>[
                        for (int i = 0; i < modules.length; i++)
                          _ModuleTile(
                            index: i + 1,
                            title: modules[i].title,
                            done: modules[i].lessons.every(
                              (VuV2RoadmapLesson l) =>
                                  widget.progress.completedLessonIds
                                      .contains(l.id),
                            ),
                            selected: i == _selectedModule,
                            accent: major.accent,
                            onTap: () => setState(() => _selectedModule = i),
                          ),
                        if (modules.isEmpty)
                          Text(
                            'Modules unlock after you open this program roadmap.',
                            style: TextStyle(color: VuV2Colors.dashMute),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: _ModuleDetailCard(
                      major: major,
                      module: selected,
                      onStart: selected == null || selected.lessons.isEmpty
                          ? null
                          : () {
                              final VuV2RoadmapLesson lesson =
                                  selected.lessons.first;
                              final VuV2RoadmapCourse? course = _course;
                              if (course == null) return;
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => VuV2LessonLearnHubScreen(
                                    session: widget.session,
                                    progress: widget.progress,
                                    subjectId: major.id,
                                    facultyTitle: 'School of ${major.title}',
                                    facultyEmoji: major.emoji,
                                    trackTitle: course.title,
                                    courseTitle: course.title,
                                    lesson: lesson,
                                    courseLessonIds: course.allLessons
                                        .map((VuV2RoadmapLesson l) => l.id)
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
            ] else if (_tab == 1)
              _CareerGameCard(major: major)
            else if (_tab == 2)
              _InfoBlock(
                title: 'Resources',
                body:
                    'Lecture notes, skill checklists, and reference sheets for '
                    '${major.title} appear here as you complete modules.',
              )
            else
             _InfoBlock(
                title: 'Grades',
                body:
                    'Course progress ${(_pct * 100).round()}%. '
                    'Quiz and clinical scores will show here as you learn.',
              ),
          ],
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.index,
    required this.title,
    required this.done,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final int index;
  final String title;
  final bool done;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? accent.withValues(alpha: 0.18) : VuV2Colors.dashCard,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? accent : VuV2Colors.dashStroke,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  done
                      ? Icons.check_circle
                      : selected
                          ? Icons.play_circle_fill
                          : Icons.radio_button_unchecked,
                  color: done || selected ? accent : VuV2Colors.dashMute,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Module $index · $title',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
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

class _ModuleDetailCard extends StatelessWidget {
  const _ModuleDetailCard({
    required this.major,
    required this.module,
    required this.onStart,
  });

  final VuFeaturedMajor major;
  final VuV2RoadmapModule? module;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VuV2Colors.dashCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VuV2Colors.dashStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: <Color>[
                  major.accent.withValues(alpha: 0.4),
                  const Color(0xFF1E293B),
                ],
              ),
            ),
            child: Center(
              child: Text(major.emoji, style: const TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            module?.title ?? 'Select a module',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            module == null
                ? 'Pick a module from the list.'
                : '~${(module!.lessons.length * 8).clamp(15, 45)} min · '
                    '${module!.lessons.length} lessons',
            style: TextStyle(color: VuV2Colors.dashMute, fontSize: 13),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: VuV2Colors.dashPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Start Learning',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CareerGameCard extends StatelessWidget {
  const _CareerGameCard({required this.major});

  final VuFeaturedMajor major;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: <Color>[
            major.accent.withValues(alpha: 0.25),
            VuV2Colors.dashCard,
          ],
        ),
        border: Border.all(color: major.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'CAREER GAME',
            style: TextStyle(
              color: VuV2Colors.dashMute,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            major.id == 'nursing'
                ? 'Virtual Clinical: Patient Assessment'
                : '${major.title} Career Mission',
            style: TextStyle(
              color: VuV2Colors.dashInk,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the workplace, make decisions, and earn XP. '
            'Interactive career worlds are being rebuilt for GradeGlow.',
            style: TextStyle(color: VuV2Colors.dashMute, height: 1.4),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Career games return with the interactive campus world.',
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: major.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Play Now', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VuV2Colors.dashCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VuV2Colors.dashStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(color: VuV2Colors.dashMute, height: 1.45)),
        ],
      ),
    );
  }
}
