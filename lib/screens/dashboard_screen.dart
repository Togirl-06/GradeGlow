import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_summary.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/notes_summarizer_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/gamification.dart';
import '../utils/summary_study_actions.dart';
import '../widgets/next_class_exam_card.dart';
import '../widgets/gradeglow_logo.dart';
import '../widgets/study_surface.dart';

/// Derives an accent that stays in the same color family as the user's chosen
/// theme color, so the whole home page recolors when they change their accent.
///
/// [hueShift] rotates around the color wheel to keep tiles distinguishable while
/// still harmonizing with the primary color the user picked.
Color _familyAccent(
  Brightness brightness, {
  double hueShift = 0,
  double saturation = 0.62,
}) {
  final HSLColor base = HSLColor.fromColor(StudyColors.primary);
  final double lightness = brightness == Brightness.dark ? 0.66 : 0.5;
  return HSLColor.fromAHSL(
    1,
    (base.hue + hueShift) % 360,
    saturation.clamp(0.0, 1.0),
    lightness,
  ).toColor();
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onProgress,
    required this.onUpload,
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
  final VoidCallback onUpload;
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
    final NotesSummarizerService summarizer = context
        .watch<NotesSummarizerService>();
    final Color textSecondary = StudyColors.textSecondary(
      Theme.of(context).brightness,
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(
        kIsWeb ? 24 : 16,
        kIsWeb ? 24 : 8,
        kIsWeb ? 24 : 16,
        16,
      ),
      children: <Widget>[
        StreamBuilder<UserProfile>(
          stream: userService.watchProfile(),
          builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
            final UserProfile profile =
                snapshot.data ??
                UserProfile.empty(
                  email: auth.email,
                  displayName: auth.displayName,
                );
            return _HomeHero(
              greeting: _greeting(),
              name: auth.displayName,
              profile: profile,
              showLogo: !kIsWeb,
              onProgress: onProgress,
            );
          },
        ),
        const SizedBox(height: 22),
        const _SectionHeader(
          eyebrow: 'TODAY',
          title: 'Your next move',
          subtitle: 'Stay ahead of classes, tests, and deadlines.',
        ),
        const SizedBox(height: 12),
        NextClassExamCard(
          onPrepareExam: onPlanner,
          onPrepareClass: onFlashcards,
          onAddSchedule: onPlanner,
        ),
        const SizedBox(height: 12),
        StreamBuilder<UserProfile>(
          stream: userService.watchProfile(),
          builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
            final List<MapEntry<String, int>> weak =
                (snapshot.data ?? UserProfile.empty(email: '')).topWeakTopics(
                  limit: 5,
                );
            if (weak.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Review these topics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: onWeaknessReview,
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StudySurfaceCard(
                  onTap: onWeaknessReview,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: weak
                        .map(
                          (MapEntry<String, int> e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: StudyColors.warning,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '×${e.value}',
                                  style: TextStyle(color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        const _SectionHeader(
          eyebrow: 'CAMPUS',
          title: 'Start learning today',
          subtitle:
              'One tap into your university — programs, labs, and AI professors.',
        ),
        const SizedBox(height: 12),
        _VirtualUniversityPortal(onEnter: onPracticeLabs),
        const SizedBox(height: 12),
        _AiTutorQuickLane(onAskAi: onAskAi),
        const SizedBox(height: 24),
        const _SectionHeader(
          eyebrow: 'TOOLKIT',
          title: 'Study your way',
          subtitle: 'Everything you need for focused, active learning.',
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<StudySummary>>(
          stream: summarizer.watchSummaries(),
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<StudySummary>> summarySnap,
              ) {
                final StudySummary? latest = SummaryStudyActions.latestSummary(
                  summarySnap.data ?? <StudySummary>[],
                );
                final int quizCount = latest?.quizQuestions.length ?? 0;
                final int cardCount = latest?.flashcards.length ?? 0;
                final String quizLabel = quizCount > 0
                    ? 'Quiz ($quizCount)'
                    : 'Quiz';
                final String cardsLabel = cardCount > 0
                    ? 'Cards ($cardCount)'
                    : 'Flashcards';
                final Brightness brightness = Theme.of(context).brightness;

                return _ToolGrid(
                  tools: <_ToolData>[
                    _ToolData(
                      icon: Icons.quiz_rounded,
                      label: quizLabel,
                      caption: 'Test your knowledge',
                      color: _familyAccent(brightness, hueShift: -40),
                      onTap: latest == null
                          ? () => SummaryStudyActions.promptNoSummaries(context)
                          : () => SummaryStudyActions.openQuiz(context, latest),
                    ),
                    _ToolData(
                      icon: Icons.style_rounded,
                      label: cardsLabel,
                      caption: 'Review key ideas',
                      color: _familyAccent(brightness, hueShift: -20),
                      onTap: latest == null
                          ? () => SummaryStudyActions.promptNoSummaries(context)
                          : () => SummaryStudyActions.openFlashcards(
                              context,
                              latest,
                            ),
                    ),
                    _ToolData(
                      icon: Icons.document_scanner_rounded,
                      label: 'Add material',
                      caption: 'Upload notes or files',
                      color: _familyAccent(brightness, hueShift: 20),
                      onTap: onUpload,
                    ),
                    _ToolData(
                      icon: Icons.summarize_rounded,
                      label: 'Summarize',
                      caption: 'Turn notes into clarity',
                      color: _familyAccent(brightness, hueShift: 40),
                      onTap: onSummarize,
                    ),
                    _ToolData(
                      icon: Icons.calendar_month_rounded,
                      label: 'Planner',
                      caption: 'Organize every deadline',
                      color: _familyAccent(brightness, hueShift: 60),
                      onTap: onPlanner,
                    ),
                    _ToolData(
                      icon: Icons.timer_rounded,
                      label: 'Focus timer',
                      caption: 'Study without distractions',
                      color: _familyAccent(brightness, hueShift: 80),
                      onTap: onPomodoro,
                    ),
                  ],
                );
              },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.greeting,
    required this.name,
    required this.profile,
    required this.showLogo,
    required this.onProgress,
  });

  final String greeting;
  final String name;
  final UserProfile profile;
  final bool showLogo;
  final VoidCallback onProgress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int level = Gamification.levelFromXp(profile.xp);
    final int nextLevelXp = Gamification.xpCeilForLevel(level);
    final String firstName = name.trim().isEmpty
        ? 'Scholar'
        : name.trim().split(RegExp(r'\s+')).first;
    final String academicLine = <String>[
      profile.school,
      profile.major,
      profile.year,
    ].where((String value) => value.isNotEmpty).join(' · ');

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
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
                      greeting,
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to learn, $firstName?',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 25,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.55,
                      ),
                    ),
                    if (academicLine.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 7),
                      Text(
                        academicLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showLogo) ...<Widget>[
                const SizedBox(width: 12),
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: GradeGlowLogo(height: 32)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'LEVEL $level',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .55,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Gamification.levelTitle(level),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${profile.xp} / $nextLevelXp XP',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: Gamification.levelProgress(profile.xp),
              minHeight: 8,
              color: scheme.primary,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: _HeroStat(
                  icon: Icons.local_fire_department_rounded,
                  value: '${profile.streakDays}',
                  label: 'Day streak',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroStat(
                  icon: Icons.bolt_rounded,
                  value: '${profile.xp}',
                  label: 'Total XP',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroStat(
                  icon: Icons.workspace_premium_rounded,
                  value: '${profile.badges.length}',
                  label: 'Badges',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: onProgress,
              icon: const Icon(Icons.insights_rounded, size: 18),
              label: const Text(
                'View progress',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: scheme.primary, size: 19),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          eyebrow,
          style: TextStyle(
            color: scheme.primary,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: -.35,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

/// Full-width campus entry — stacked layout with a clear CTA (not a side card).
class _VirtualUniversityPortal extends StatelessWidget {
  const _VirtualUniversityPortal({required this.onEnter});

  final VoidCallback onEnter;

  static const List<(String, String)> _previewPrograms =
      <(String, String)>[
    ('💻', 'Tech'),
    ('⚙️', 'Engineering'),
    ('💼', 'Business'),
    ('🩺', 'Health'),
    ('🔬', 'Sciences'),
    ('🎨', 'Arts'),
    ('📚', 'Humanities'),
    ('⚖️', 'Law'),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Brightness brightness = Theme.of(context).brightness;
    final Color accent = StudyColors.primary;
    final bool dark = brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEnter,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                accent.withValues(alpha: dark ? .38 : .22),
                scheme.surfaceContainerHighest.withValues(alpha: dark ? .95 : 1),
              ],
            ),
            border: Border.all(
              color: accent.withValues(alpha: dark ? .35 : .22),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'GRADE GLOW VU',
                            style: TextStyle(
                              color: accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.school_rounded,
                          color: accent.withValues(alpha: .85),
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '10 schools.\nWorld-class learning.',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Affordable education for anyone — AI professors, '
                      'interactive lessons, career-focused programs.',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onEnter,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Browse schools',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: .45),
              ),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  itemCount: _previewPrograms.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final (String emoji, String name) = _previewPrograms[index];
                    return Material(
                      color: scheme.surface.withValues(alpha: dark ? .35 : .7),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: onEnter,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                name,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact AI tutor lane — visually separate from the campus portal.
class _AiTutorQuickLane extends StatelessWidget {
  const _AiTutorQuickLane({required this.onAskAi});

  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accent = _familyAccent(
      Theme.of(context).brightness,
      hueShift: 28,
    );

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onAskAi,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundColor: accent.withValues(alpha: .18),
                child: Icon(Icons.auto_awesome_rounded, color: accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Stuck on something?',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Ask your AI tutor for a clear explanation',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onAskAi,
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: const Text(
                  'Ask',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolData {
  const _ToolData({
    required this.icon,
    required this.label,
    required this.caption,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String caption;
  final Color color;
  final VoidCallback onTap;
}

class _ToolGrid extends StatelessWidget {
  const _ToolGrid({required this.tools});

  final List<_ToolData> tools;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 760 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tools.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 102,
          ),
          itemBuilder: (BuildContext context, int index) {
            return _ToolCard(data: tools[index]);
          },
        );
      },
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.data});

  final _ToolData data;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: data.onTap,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.color, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 8.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
