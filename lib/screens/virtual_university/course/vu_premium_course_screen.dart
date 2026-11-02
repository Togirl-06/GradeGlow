import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/vu_premium_course.dart';
import '../../../services/vu_notes_service.dart';
import '../../../services/vu_premium_course_progress.dart';
import '../vu_notes_screen.dart';

/// Immersive university classroom for a single course.
class VuPremiumCourseScreen extends StatefulWidget {
  const VuPremiumCourseScreen({super.key, required this.course});

  final VuPremiumCourse course;

  @override
  State<VuPremiumCourseScreen> createState() => _VuPremiumCourseScreenState();
}

class _VuPremiumCourseScreenState extends State<VuPremiumCourseScreen> {
  late final VuPremiumCourseProgress _progress;
  int _tab = 0;

  VuPremiumCourse get course => widget.course;

  @override
  void initState() {
    super.initState();
    _progress = VuPremiumCourseProgress(courseId: course.id);
    unawaited(_progress.ensureLoaded());
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _openItem(VuPremiumLessonItem item) async {
    await _progress.setContinue(item.id);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<VuPremiumCourseProgress>.value(
          value: _progress,
          child: VuPremiumLessonScreen(course: course, item: item),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VuPremiumCourseProgress>.value(
      value: _progress,
      child: Scaffold(
        body: IndexedStack(
          index: _tab,
          children: <Widget>[
            _CourseHomeTab(course: course, onOpenItem: _openItem),
            _ModulesTab(course: course, onOpenItem: _openItem),
            _ProgressTab(course: course),
            _CommunityTab(course: course),
            _AchievementsTab(course: course),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (int i) => setState(() => _tab = i),
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.view_module_outlined),
              selectedIcon: Icon(Icons.view_module_rounded),
              label: 'Modules',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups_rounded),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events_rounded),
              label: 'Awards',
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseHomeTab extends StatelessWidget {
  const _CourseHomeTab({required this.course, required this.onOpenItem});

  final VuPremiumCourse course;
  final Future<void> Function(VuPremiumLessonItem item) onOpenItem;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final VuPremiumCourseProgress progress =
        context.watch<VuPremiumCourseProgress>();
    final double fraction = progress.progressFraction(course.totalLessons);
    final VuPremiumLessonItem? continueItem = () {
      final String? id = progress.continueItemId;
      if (id != null) {
        final VuPremiumLessonItem? found = course.itemById(id);
        if (found != null) return found;
      }
      for (final VuPremiumLessonItem i in course.allItems) {
        if (!progress.isComplete(i.id)) return i;
      }
      return course.allItems.isEmpty ? null : course.allItems.first;
    }();
    final int hours = (course.totalEstimatedMinutes / 60).ceil();

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              course.title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    scheme.primary.withValues(alpha: 0.92),
                    scheme.tertiary.withValues(alpha: 0.75),
                    scheme.surface,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 48),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          course.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              course.facultyLabel,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${course.professorName} · ${course.professorTitle}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11,
                              ),
                            ),
                          ],
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
              Text(
                course.description,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          '${(fraction * 100).round()}% Complete',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        Text(
                          'Module ${_currentModuleIndex(course, progress)} of ${course.modules.length}',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 10,
                        color: scheme.primary,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        _StatChip(
                          label: 'XP',
                          value: '${progress.xp}',
                          icon: Icons.bolt_rounded,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Lessons',
                          value:
                              '${progress.completedItemIds.length}/${course.totalLessons}',
                          icon: Icons.menu_book_rounded,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Grade',
                          value: progress.letterGrade(fraction),
                          icon: Icons.school_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.local_fire_department_rounded,
                      value: '${progress.streakDays}',
                      label: 'Day streak',
                      color: const Color(0xFFFF7A45),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.schedule_rounded,
                      value: '~$hours h',
                      label: 'Est. time',
                      color: scheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.flag_rounded,
                      value: '${(fraction * 5).ceil()}/5',
                      label: 'Weekly goal',
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              if (continueItem != null) ...<Widget>[
                const SizedBox(height: 18),
                const _SectionLabel('Continue Learning'),
                const SizedBox(height: 8),
                _ContinueCard(
                  item: continueItem,
                  professor: course.professorName,
                  onTap: () => unawaited(onOpenItem(continueItem)),
                ),
              ],
              if (course.upcoming.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                const _SectionLabel('Upcoming'),
                const SizedBox(height: 8),
                ...course.upcoming.map(
                  (VuCourseUpcoming u) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(u.kind.icon, color: scheme.primary, size: 20),
                    ),
                    title: Text(
                      u.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(u.whenLabel),
                  ),
                ),
              ],
              if (course.announcements.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                const _SectionLabel('Announcements'),
                const SizedBox(height: 8),
                ...course.announcements.map(
                  (VuCourseAnnouncement a) => _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          a.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a.body,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (course.resources.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                const _SectionLabel('Recommended resources'),
                const SizedBox(height: 8),
                ...course.resources.map(
                  (VuCourseResource r) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(r.icon, color: scheme.primary),
                    title: Text(
                      r.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(r.subtitle),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const VuNotesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.sticky_note_2_outlined),
                label: const Text('Open course notes'),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  int _currentModuleIndex(
    VuPremiumCourse course,
    VuPremiumCourseProgress progress,
  ) {
    for (int i = 0; i < course.modules.length; i++) {
      final VuPremiumModule m = course.modules[i];
      final bool done = m.items.every(
        (VuPremiumLessonItem item) => progress.isComplete(item.id),
      );
      if (!done) return i + 1;
    }
    return course.modules.isEmpty ? 1 : course.modules.length;
  }
}

extension on VuLessonItemKind {
  IconData get icon => switch (this) {
    VuLessonItemKind.lesson => Icons.play_circle_outline_rounded,
    VuLessonItemKind.interactive => Icons.touch_app_outlined,
    VuLessonItemKind.simulation => Icons.science_outlined,
    VuLessonItemKind.quiz => Icons.quiz_outlined,
    VuLessonItemKind.assignment => Icons.assignment_outlined,
    VuLessonItemKind.discussion => Icons.forum_outlined,
    VuLessonItemKind.project => Icons.architecture_outlined,
  };
}

class _ModulesTab extends StatelessWidget {
  const _ModulesTab({required this.course, required this.onOpenItem});

  final VuPremiumCourse course;
  final Future<void> Function(VuPremiumLessonItem item) onOpenItem;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final VuPremiumCourseProgress progress =
        context.watch<VuPremiumCourseProgress>();
    final double fraction = progress.progressFraction(course.totalLessons);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modules',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text(
            '${course.modules.length} modules · ${course.totalLessons} activities',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          ...course.modules.map((VuPremiumModule module) {
            final int done = progress.completedIn(
              module.items.map((VuPremiumLessonItem i) => i.id),
            );
            final bool complete = done >= module.items.length && module.items.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GlassCard(
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: !complete,
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: complete
                          ? Colors.green.withValues(alpha: 0.2)
                          : scheme.primaryContainer,
                      child: Icon(
                        complete ? Icons.check_rounded : Icons.folder_open_rounded,
                        color: complete ? Colors.green : scheme.primary,
                      ),
                    ),
                    title: Text(
                      module.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      module.subtitle.isEmpty
                          ? '$done/${module.items.length} complete'
                          : '${module.subtitle} · $done/${module.items.length}',
                    ),
                    children: module.items
                        .map(
                          (VuPremiumLessonItem item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              progress.isComplete(item.id)
                                  ? Icons.check_circle
                                  : item.icon,
                              color: progress.isComplete(item.id)
                                  ? Colors.green
                                  : scheme.primary,
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '${item.kindLabel} · ${item.estimatedMinutes} min · ${item.xpReward} XP',
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => unawaited(onOpenItem(item)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab({required this.course});

  final VuPremiumCourse course;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final VuPremiumCourseProgress progress =
        context.watch<VuPremiumCourseProgress>();
    final double fraction = progress.progressFraction(course.totalLessons);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CircularProgressIndicator(
                    value: fraction,
                    strokeWidth: 12,
                    color: scheme.primary,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${(fraction * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Course mastery',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniStat(
                  icon: Icons.bolt_rounded,
                  value: '${progress.xp}',
                  label: 'XP earned',
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  icon: Icons.school_rounded,
                  value: progress.letterGrade(fraction),
                  label: 'Current grade',
                  color: scheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  icon: Icons.local_fire_department_rounded,
                  value: '${progress.streakDays}',
                  label: 'Attendance streak',
                  color: const Color(0xFFFF7A45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Module breakdown'),
          const SizedBox(height: 8),
          ...course.modules.map((VuPremiumModule m) {
            final int done = progress.completedIn(
              m.items.map((VuPremiumLessonItem i) => i.id),
            );
            final double p = m.items.isEmpty ? 0 : done / m.items.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          m.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text('${(p * 100).round()}%'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: p,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CommunityTab extends StatefulWidget {
  const _CommunityTab({required this.course});

  final VuPremiumCourse course;

  @override
  State<_CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<_CommunityTab> {
  final List<({String author, String body, int replies})> _posts =
      <({String author, String body, int replies})>[
        (
          author: 'Sam',
          body: 'Anyone have a good way to remember the core definitions?',
          replies: 4,
        ),
        (
          author: 'Jordan',
          body: 'The AI Professor examples in Module 1 clicked for me.',
          replies: 2,
        ),
        (
          author: 'Ava',
          body: 'Study group tonight for the upcoming quiz?',
          replies: 7,
        ),
      ];
  final TextEditingController _composer = TextEditingController();

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text(
            'Discuss ${widget.course.title} with peers. AI helps keep threads on-topic.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _composer,
            decoration: InputDecoration(
              hintText: 'Ask a question or share a tip…',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: () {
                  final String text = _composer.text.trim();
                  if (text.isEmpty) return;
                  setState(() {
                    _posts.insert(0, (author: 'You', body: text, replies: 0));
                    _composer.clear();
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._posts.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      p.author,
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(p.body, style: const TextStyle(height: 1.4)),
                    const SizedBox(height: 8),
                    Text(
                      '${p.replies} replies',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab({required this.course});

  final VuPremiumCourse course;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final VuPremiumCourseProgress progress =
        context.watch<VuPremiumCourseProgress>();
    final int completed = progress.completedItemIds.length;
    final List<({String title, String subtitle, bool earned})> badges =
        <({String title, String subtitle, bool earned})>[
          (
            title: 'First Steps',
            subtitle: 'Complete your first activity',
            earned: completed >= 1,
          ),
          (
            title: 'Quiz Master',
            subtitle: 'Finish 3 quizzes',
            earned: completed >= 6,
          ),
          (
            title: 'Streak Starter',
            subtitle: 'Study 3 days in a row',
            earned: progress.streakDays >= 3,
          ),
          (
            title: 'Module Closer',
            subtitle: 'Complete a full module',
            earned: course.modules.any(
              (VuPremiumModule m) => m.items.every(
                (VuPremiumLessonItem i) => progress.isComplete(i.id),
              ),
            ),
          ),
          (
            title: 'XP Hunter',
            subtitle: 'Earn 200 XP in this course',
            earned: progress.xp >= 200,
          ),
          (
            title: 'Campus Scholar',
            subtitle: 'Reach 50% course mastery',
            earned: progress.progressFraction(course.totalLessons) >= 0.5,
          ),
        ];
    final int earned = badges.where((b) => b.earned).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          _GlassCard(
            child: Column(
              children: <Widget>[
                Icon(Icons.military_tech_rounded, size: 48, color: scheme.primary),
                const SizedBox(height: 10),
                Text(
                  earned == 0
                      ? 'Keep going — your first badge is close.'
                      : 'Nice work! You\'ve earned $earned achievements.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  '$earned earned · ${badges.length - earned} locked',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (BuildContext context, int i) {
              final badge = badges[i];
              return _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      badge.earned
                          ? Icons.emoji_events_rounded
                          : Icons.lock_outline_rounded,
                      color: badge.earned
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    const Spacer(),
                    Text(
                      badge.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      badge.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Lesson classroom: overview + AI tutor + launch into faculty activities.
class VuPremiumLessonScreen extends StatefulWidget {
  const VuPremiumLessonScreen({
    super.key,
    required this.course,
    required this.item,
  });

  final VuPremiumCourse course;
  final VuPremiumLessonItem item;

  @override
  State<VuPremiumLessonScreen> createState() => _VuPremiumLessonScreenState();
}

class _VuPremiumLessonScreenState extends State<VuPremiumLessonScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final TextEditingController _tutor = TextEditingController();
  final List<({bool student, String text})> _chat =
      <({bool student, String text})>[];

  VuPremiumCourse get course => widget.course;
  VuPremiumLessonItem get item => widget.item;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _chat.add((
      student: false,
      text:
          'Welcome. I\'m ${course.professorName}. Today we focus on **${item.title}**. '
          'Ask me to explain again, give an example, or quiz you anytime.',
    ));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _tutor.dispose();
    super.dispose();
  }

  Future<void> _launchPrimary() async {
    final VuPremiumCourseActions actions = course.actions;
    switch (item.kind) {
      case VuLessonItemKind.lesson:
        await actions.onOpenAiProfessor?.call(item);
      case VuLessonItemKind.interactive:
        await actions.onOpenInteractive?.call(item);
      case VuLessonItemKind.simulation:
      case VuLessonItemKind.project:
        await (actions.onOpenSimulation ?? actions.onOpenInteractive)?.call(item);
      case VuLessonItemKind.quiz:
      case VuLessonItemKind.assignment:
        await (actions.onOpenQuiz ?? actions.onOpenPractice)?.call(item);
      case VuLessonItemKind.discussion:
        await actions.onOpenDiscussion?.call(item);
    }
  }

  Future<void> _markComplete() async {
    final VuPremiumCourseProgress? progress = () {
      try {
        return context.read<VuPremiumCourseProgress>();
      } catch (_) {
        return null;
      }
    }();
    await progress?.completeItem(item.id, xpReward: item.xpReward);
    try {
      await VuNotesService.instance.addBookmark(
        title: '${item.title} · ${course.title}',
        lessonId: item.id,
      );
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Completed · +${item.xpReward} XP')),
    );
  }

  void _askTutor() {
    final String q = _tutor.text.trim();
    if (q.isEmpty) return;
    _tutor.clear();
    setState(() {
      _chat.add((student: true, text: q));
      _chat.add((student: false, text: _offlineTutorReply(q)));
    });
  }

  String _offlineTutorReply(String q) {
    final String lower = q.toLowerCase();
    if (lower.contains('example')) {
      return 'Here is another example for **${item.title}**: start from a concrete case, '
          'name the principle, then map each step back to the definition. '
          'Want a harder challenge next?';
    }
    if (lower.contains('simpl') || lower.contains('explain')) {
      return 'In plain language: **${item.title}** is about recognizing the pattern, '
          'choosing the right move, then checking your result. '
          'Which part felt unclear — definition, steps, or application?';
    }
    if (lower.contains('quiz') || lower.contains('challenge')) {
      return 'Quick check: what is the first action you would take when applying '
          '**${item.title}**? Answer in one sentence, then I\'ll coach you.';
    }
    return 'Good question. Relating this to where you are in the course: '
        'focus on the learning goal for **${item.title}**, then ask for an example '
        'or a step-by-step walkthrough.';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Widget>[
            Tab(text: 'Overview'),
            Tab(text: 'Notes'),
            Tab(text: 'Resources'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (BuildContext ctx) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
                ),
                child: SizedBox(
                  height: MediaQuery.sizeOf(ctx).height * 0.55,
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Ask ${course.professorName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _chat.length,
                          itemBuilder: (BuildContext context, int i) {
                            final msg = _chat[i];
                            return Align(
                              alignment: msg.student
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.sizeOf(context).width * 0.85,
                                ),
                                decoration: BoxDecoration(
                                  color: msg.student
                                      ? scheme.primaryContainer
                                      : scheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(msg.text),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _tutor,
                              decoration: const InputDecoration(
                                hintText: 'Explain again, quiz me…',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onSubmitted: (_) => _askTutor(),
                            ),
                          ),
                          IconButton(
                            onPressed: _askTutor,
                            icon: const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Ask AI Tutor'),
      ),
      body: TabBarView(
        controller: _tabs,
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: <Widget>[
              _GlassCard(
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: scheme.primaryContainer,
                      child: Text(
                        course.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            course.professorName,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '${item.kindLabel} · ${item.estimatedMinutes} min',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Learning goals',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Understand the core idea behind ${item.title}.\n'
                '2. Apply it with a worked example.\n'
                '3. Check mastery with practice and feedback.',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.subtitle.isEmpty
                    ? 'Your AI Professor will guide a full lecture with examples, '
                        'diagrams, and checkpoints — not a short summary.'
                    : item.subtitle,
                style: const TextStyle(height: 1.45, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => unawaited(_launchPrimary()),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  item.kind == VuLessonItemKind.lesson
                      ? 'Start AI Professor lecture'
                      : 'Enter ${item.kindLabel.toLowerCase()}',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => unawaited(_markComplete()),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text('Mark complete · +${item.xpReward} XP'),
              ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: <Widget>[
              Text(
                'Capture highlights and reflections for ${item.title}.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () async {
                  await VuNotesService.instance.addNote(
                    title: item.title,
                    body: 'Notes for ${item.title} in ${course.title}',
                    lessonId: item.id,
                  );
                  if (!context.mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const VuNotesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Write / open notes'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  await VuNotesService.instance.addBookmark(
                    title: item.title,
                    lessonId: item.id,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bookmarked')),
                  );
                },
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Bookmark this lesson'),
              ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: <Widget>[
              ...course.resources.map(
                (VuCourseResource r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(r.icon, color: scheme.primary),
                  title: Text(
                    r.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(r.subtitle),
                ),
              ),
              if (course.resources.isEmpty)
                Text(
                  'Resources will appear as you progress through modules.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: scheme.surface.withValues(alpha: 0.65),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 16, color: scheme.primary),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
        color: scheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.item,
    required this.professor,
    required this.onTap,
  });

  final VuPremiumLessonItem item;
  final String professor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$professor · ${item.kindLabel}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill_rounded, color: scheme.primary, size: 40),
            ],
          ),
        ),
      ),
    );
  }
}
