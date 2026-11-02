import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_summary.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/notes_summarizer_service.dart';
import '../services/user_service.dart';
import '../utils/gamification.dart';
import '../utils/summary_study_actions.dart';
import '../widgets/gradeglow_logo.dart';
import '../widgets/next_class_exam_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onProgress,
    required this.onAskAi,
    required this.onQuiz,
    required this.onFlashcards,
    required this.onWeaknessReview,
    required this.onSummarize,
    required this.onPlanner,
    required this.onPomodoro,
    required this.onPracticeLabs,
  });

  final VoidCallback onProgress;
  final VoidCallback onAskAi;
  final void Function([String? materialId]) onQuiz;
  final VoidCallback onFlashcards;
  final VoidCallback onWeaknessReview;
  final VoidCallback onSummarize;
  final VoidCallback onPlanner;
  final VoidCallback onPomodoro;
  final VoidCallback onPracticeLabs;

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = context.watch<AuthService>();
    final UserService userService = context.watch<UserService>();
    final NotesSummarizerService summarizer =
        context.watch<NotesSummarizerService>();
    final bool web = kIsWeb;
    final double pad = web ? 36 : 16;

    return StreamBuilder<UserProfile>(
      stream: userService.watchProfile(),
      builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
        final UserProfile profile = snapshot.data ??
            UserProfile.empty(
              email: auth.email,
              displayName: auth.displayName,
            );
        final List<MapEntry<String, int>> weak =
            profile.topWeakTopics(limit: 4);

        return ListView(
          padding: EdgeInsets.fromLTRB(pad, web ? 28 : 8, pad, web ? 56 : 24),
          children: <Widget>[
            _WelcomeHeader(
              greeting: _greeting(),
              name: auth.displayName,
              profile: profile,
              showLogo: !web,
              onProgress: onProgress,
              onEnterCampus: onPracticeLabs,
            ),
            SizedBox(height: web ? 40 : 28),

            if (web && MediaQuery.sizeOf(context).width >= 960)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _SectionLabel(label: 'Today'),
                        const SizedBox(height: 12),
                        NextClassExamCard(
                          onPrepareExam: onPlanner,
                          onPrepareClass: onFlashcards,
                          onAddSchedule: onPlanner,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _SectionLabel(label: 'Focus'),
                        const SizedBox(height: 12),
                        _FocusPanel(
                          weak: weak,
                          onReview: onWeaknessReview,
                          onAskAi: onAskAi,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else ...<Widget>[
              const _SectionLabel(label: 'Today'),
              const SizedBox(height: 12),
              NextClassExamCard(
                onPrepareExam: onPlanner,
                onPrepareClass: onFlashcards,
                onAddSchedule: onPlanner,
              ),
              if (weak.isNotEmpty) ...<Widget>[
                SizedBox(height: web ? 28 : 22),
                const _SectionLabel(label: 'Focus'),
                const SizedBox(height: 12),
                _FocusPanel(
                  weak: weak,
                  onReview: onWeaknessReview,
                  onAskAi: onAskAi,
                ),
              ] else ...<Widget>[
                SizedBox(height: web ? 20 : 16),
                _AskTutorRow(onAskAi: onAskAi),
              ],
            ],

            SizedBox(height: web ? 40 : 28),

            const _SectionLabel(label: 'Study tools'),
            const SizedBox(height: 12),
            StreamBuilder<List<StudySummary>>(
              stream: summarizer.watchSummaries(),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<StudySummary>> summarySnap,
              ) {
                final StudySummary? latest = SummaryStudyActions.latestSummary(
                  summarySnap.data ?? <StudySummary>[],
                );
                return _ToolsList(
                  tools: <_ToolItem>[
                    _ToolItem(
                      icon: Icons.school_outlined,
                      title: 'Campus',
                      subtitle: 'Schools, programs, and AI lectures',
                      onTap: onPracticeLabs,
                    ),
                    _ToolItem(
                      icon: Icons.auto_awesome_outlined,
                      title: 'AI Tutor',
                      subtitle: 'Ask for a clear explanation',
                      onTap: onAskAi,
                    ),
                    _ToolItem(
                      icon: Icons.quiz_outlined,
                      title: 'Quiz',
                      subtitle: 'Check what you know',
                      onTap: latest == null
                          ? () => SummaryStudyActions.promptNoSummaries(context)
                          : () => SummaryStudyActions.openQuiz(context, latest),
                    ),
                    _ToolItem(
                      icon: Icons.style_outlined,
                      title: 'Flashcards',
                      subtitle: 'Review key ideas',
                      onTap: latest == null
                          ? () => SummaryStudyActions.promptNoSummaries(context)
                          : () => SummaryStudyActions.openFlashcards(
                                context,
                                latest,
                              ),
                    ),
                    _ToolItem(
                      icon: Icons.notes_outlined,
                      title: 'Summarize',
                      subtitle: 'Turn notes into clarity',
                      onTap: onSummarize,
                    ),
                    _ToolItem(
                      icon: Icons.calendar_today_outlined,
                      title: 'Planner',
                      subtitle: 'Classes and deadlines',
                      onTap: onPlanner,
                    ),
                    _ToolItem(
                      icon: Icons.timer_outlined,
                      title: 'Focus timer',
                      subtitle: 'Distraction-free study',
                      onTap: onPomodoro,
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.greeting,
    required this.name,
    required this.profile,
    required this.showLogo,
    required this.onProgress,
    required this.onEnterCampus,
  });

  final String greeting;
  final String name;
  final UserProfile profile;
  final bool showLogo;
  final VoidCallback onProgress;
  final VoidCallback onEnterCampus;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool web = kIsWeb;
    final int level = Gamification.levelFromXp(profile.xp);
    final String firstName = name.trim().isEmpty
        ? 'Scholar'
        : name.trim().split(RegExp(r'\s+')).first;
    final String academicLine = <String>[
      profile.school,
      profile.major,
      profile.year,
    ].where((String v) => v.isNotEmpty).join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$greeting, $firstName',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: web ? 32 : 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    academicLine.isNotEmpty
                        ? academicLine
                        : 'Continue learning on campus or pick up a study tool below.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (showLogo)
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: GradeGlowLogo(height: 28),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            FilledButton(
              onPressed: onEnterCampus,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Enter campus',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: onProgress,
              child: const Text('View progress'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: <Widget>[
            _MetaChip(
              icon: Icons.local_fire_department_outlined,
              text: '${profile.streakDays} day streak',
            ),
            _MetaChip(
              icon: Icons.bolt_outlined,
              text: '${profile.xp} XP · Level $level',
            ),
            if (profile.badges.isNotEmpty)
              _MetaChip(
                icon: Icons.workspace_premium_outlined,
                text: '${profile.badges.length} badges',
              ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: Gamification.levelProgress(profile.xp),
            minHeight: 4,
            color: scheme.primary,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 15, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FocusPanel extends StatelessWidget {
  const _FocusPanel({
    required this.weak,
    required this.onReview,
    required this.onAskAi,
  });

  final List<MapEntry<String, int>> weak;
  final VoidCallback onReview;
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (weak.isEmpty)
              Text(
                'No weak topics yet. Keep studying to unlock focus suggestions.',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              )
            else ...<Widget>[
              ...weak.map((MapEntry<String, int> e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          e.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '${e.value} misses',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: onReview,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Review all'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: onAskAi,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Ask tutor'),
                  ),
                ],
              ),
            ],
            if (weak.isEmpty) ...<Widget>[
              const SizedBox(height: 12),
              _AskTutorRow(onAskAi: onAskAi),
            ],
          ],
        ),
      ),
    );
  }
}

class _AskTutorRow extends StatelessWidget {
  const _AskTutorRow({required this.onAskAi});

  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onAskAi,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            Icon(Icons.auto_awesome_outlined, size: 18, color: scheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ask the AI tutor',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  const _ToolItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _ToolsList extends StatelessWidget {
  const _ToolsList({required this.tools});

  final List<_ToolItem> tools;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool wide = MediaQuery.sizeOf(context).width >= 760;

    if (wide) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          const int cols = 3;
          final double gap = 12;
          final double itemW = (c.maxWidth - gap * (cols - 1)) / cols;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: tools.map((_ToolItem t) {
              return SizedBox(
                width: itemW,
                child: _ToolTile(item: t),
              );
            }).toList(),
          );
        },
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < tools.length; i++) ...<Widget>[
            _ToolTile(item: tools[i], dense: true),
            if (i < tools.length - 1)
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.item, this.dense = false});

  final _ToolItem item;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Material(
      color: dense ? Colors.transparent : scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(dense ? 0 : 12),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(dense ? 0 : 12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 14 : 16,
            vertical: dense ? 14 : 16,
          ),
          decoration: dense
              ? null
              : BoxDecoration(
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
          child: Row(
            children: <Widget>[
              Icon(item.icon, size: 22, color: scheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
