import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/billing_config.dart';
import '../models/course.dart';
import '../models/flashcard.dart';
import '../models/study_material.dart';
import '../models/study_summary.dart';
import '../models/subscription_plan.dart';
import '../models/user_profile.dart';
import '../services/appearance_service.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import '../services/flashcard_service.dart';
import '../services/material_service.dart';
import '../services/notes_summarizer_service.dart';
import '../services/subscription_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/gamification.dart';
import '../utils/study_limits.dart';
import '../vu_v2/vu_v2_app.dart';
import 'flashcards_screen.dart';
import 'membership_screen.dart';
import 'my_courses_screen.dart';
import 'notes_summarizer_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _handleFromEmail(String email) {
    final int at = email.indexOf('@');
    if (at <= 0) return '@student';
    return '@${email.substring(0, at).toLowerCase()}';
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  void _openPlans(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
    );
  }

  void _openCampus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const VuV2App()),
    );
  }

  void _showAchievements(BuildContext context, UserProfile profile) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Achievements'),
        content: profile.badges.isEmpty
            ? const Text(
                'Finish a lecture or pass a quiz to earn your first badge.',
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: profile.badges
                    .map(
                      (String id) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.military_tech_rounded,
                              color: StudyColors.accent,
                            ),
                            const SizedBox(width: 10),
                            Text(Gamification.badgeLabel(id)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService auth = context.watch<AuthService>();
    final UserService userService = context.watch<UserService>();
    final CourseService courseService = context.watch<CourseService>();
    final MaterialService materials = context.watch<MaterialService>();
    final FlashcardService flashcards = context.watch<FlashcardService>();
    final NotesSummarizerService summarizer =
        context.watch<NotesSummarizerService>();
    final SubscriptionService subs = context.watch<SubscriptionService>();
    final AppearanceService appearance = context.watch<AppearanceService>();
    final Brightness brightness = Theme.of(context).brightness;
    final Color accent = appearance.primaryColor;
    final String initial =
        auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'S';

    return StreamBuilder<UserProfile>(
      stream: userService.watchProfile(),
      builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Could not load profile: ${snapshot.error}'),
          );
        }

        final UserProfile profile = snapshot.data ??
            UserProfile.empty(
              email: auth.email,
              displayName: auth.displayName,
            );
        final int level = Gamification.levelFromXp(profile.xp);
        final int xpFloor = Gamification.xpFloorForLevel(level);
        final int xpCeil = Gamification.xpCeilForLevel(level);
        final int xpIntoLevel = profile.xp - xpFloor;
        final int xpSpan = xpCeil - xpFloor;
        final int xpToNext = (xpCeil - profile.xp).clamp(0, xpSpan);
        final bool isPremium = subs.plan.isPaid ||
            SubscriptionPlan.fromString(profile.plan).isPaid;
        final double width = MediaQuery.sizeOf(context).width;
        final bool wide = width >= 900;

        return Scaffold(
          backgroundColor: StudyColors.background(brightness),
          body: ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, wide ? 32 : 100),
            children: <Widget>[
              _ProfileHero(
                initial: initial,
                name: profile.displayName.isNotEmpty
                    ? profile.displayName
                    : 'Student',
                handle: _handleFromEmail(auth.email),
                level: level,
                levelTitle: Gamification.levelTitle(level),
                xpIntoLevel: xpIntoLevel,
                xpSpan: xpSpan,
                xpToNext: xpToNext,
                progress: Gamification.levelProgress(profile.xp),
                accent: accent,
                onSettings: () => _openSettings(context),
              ),
              const SizedBox(height: 18),
              Text(
                'Your progress',
                style: TextStyle(
                  color: StudyColors.textPrimary(brightness),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<StudyMaterial>>(
                stream: materials.watchMyUploads(limit: 200),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<StudyMaterial>> uploadSnap,
                ) {
                  final int uploads = uploadSnap.data?.length ?? 0;
                  return _ProgressGrid(
                    streakDays: profile.streakDays,
                    points: profile.xp,
                    badges: profile.badges.length,
                    uploads: uploads,
                    accent: accent,
                  );
                },
              ),
              const SizedBox(height: 16),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 11,
                      child: _StudySpaceCard(
                        courseService: courseService,
                        summarizer: summarizer,
                        flashcards: flashcards,
                        courseIds: profile.courseIds,
                        badgesCount: profile.badges.length,
                        accent: accent,
                        onCourses: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const MyCoursesScreen(),
                          ),
                        ),
                        onNotes: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const NotesSummarizerScreen(),
                          ),
                        ),
                        onFlashcards: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const FlashcardsScreen(),
                          ),
                        ),
                        onAchievements: () =>
                            _showAchievements(context, profile),
                        onSettings: () => _openSettings(context),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 9,
                      child: Column(
                        children: <Widget>[
                          _WeekStreakCard(
                            streakDays: profile.streakDays,
                            lastStudyDate: profile.lastStudyDate,
                            accent: accent,
                          ),
                          const SizedBox(height: 12),
                          if (!isPremium)
                            _PremiumPromoCard(
                              accent: accent,
                              onSeePlans: () => _openPlans(context),
                            ),
                          if (!isPremium) const SizedBox(height: 12),
                          if (isPremium)
                            _PremiumActiveCard(accent: accent),
                          if (isPremium) const SizedBox(height: 12),
                          _FirstBadgeCard(
                            hasBadge: profile.badges.isNotEmpty,
                            accent: accent,
                            onBrowse: () => _openCampus(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...<Widget>[
                _WeekStreakCard(
                  streakDays: profile.streakDays,
                  lastStudyDate: profile.lastStudyDate,
                  accent: accent,
                ),
                const SizedBox(height: 12),
                _StudySpaceCard(
                  courseService: courseService,
                  summarizer: summarizer,
                  flashcards: flashcards,
                  courseIds: profile.courseIds,
                  badgesCount: profile.badges.length,
                  accent: accent,
                  onCourses: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const MyCoursesScreen(),
                    ),
                  ),
                  onNotes: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const NotesSummarizerScreen(),
                    ),
                  ),
                  onFlashcards: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const FlashcardsScreen(),
                    ),
                  ),
                  onAchievements: () => _showAchievements(context, profile),
                  onSettings: () => _openSettings(context),
                ),
                const SizedBox(height: 12),
                if (!isPremium)
                  _PremiumPromoCard(
                    accent: accent,
                    onSeePlans: () => _openPlans(context),
                  )
                else
                  _PremiumActiveCard(accent: accent),
                const SizedBox(height: 12),
                _FirstBadgeCard(
                  hasBadge: profile.badges.isNotEmpty,
                  accent: accent,
                  onBrowse: () => _openCampus(context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.initial,
    required this.name,
    required this.handle,
    required this.level,
    required this.levelTitle,
    required this.xpIntoLevel,
    required this.xpSpan,
    required this.xpToNext,
    required this.progress,
    required this.accent,
    required this.onSettings,
  });

  final String initial;
  final String name;
  final String handle;
  final int level;
  final String levelTitle;
  final int xpIntoLevel;
  final int xpSpan;
  final int xpToNext;
  final double progress;
  final Color accent;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool dark = brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? <Color>[
                  const Color(0xFF1A1535),
                  const Color(0xFF121A2E),
                  accent.withValues(alpha: 0.35),
                ]
              : <Color>[
                  accent.withValues(alpha: 0.18),
                  StudyColors.surface(brightness),
                  accent.withValues(alpha: 0.08),
                ],
        ),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: onSettings,
              icon: Icon(
                Icons.settings_outlined,
                color: StudyColors.textPrimary(brightness),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.05, 1.0),
                        strokeWidth: 4,
                        backgroundColor: accent.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white,
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: accent,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: StudyColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: StudyColors.surface(brightness),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: TextStyle(
                        color: StudyColors.textPrimary(brightness),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      handle,
                      style: TextStyle(
                        color: StudyColors.textSecondary(brightness),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: dark
                                ? Colors.black.withValues(alpha: 0.35)
                                : accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.shield_rounded,
                                size: 14,
                                color: accent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Level $level • $levelTitle',
                                style: TextStyle(
                                  color: StudyColors.textPrimary(brightness),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$xpIntoLevel / $xpSpan XP • $xpToNext XP to Level ${level + 1}',
                          style: TextStyle(
                            color: StudyColors.textSecondary(brightness),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

class _ProgressGrid extends StatelessWidget {
  const _ProgressGrid({
    required this.streakDays,
    required this.points,
    required this.badges,
    required this.uploads,
    required this.accent,
  });

  final int streakDays;
  final int points;
  final int badges;
  final int uploads;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 640;
        final List<_MetricData> metrics = <_MetricData>[
          _MetricData(
            icon: Icons.local_fire_department_rounded,
            color: StudyColors.accent,
            value: '$streakDays',
            label: 'Day streak',
            hint: streakDays > 0
                ? 'Study today to keep it'
                : 'Study today to start',
          ),
          _MetricData(
            icon: Icons.bolt_rounded,
            color: accent,
            value: Gamification.formatCompactCount(points),
            label: 'Points',
            hint: 'Earned from studying',
          ),
          _MetricData(
            icon: Icons.military_tech_rounded,
            color: const Color(0xFFA855F7),
            value: '$badges',
            label: 'Badges',
            hint: badges == 0
                ? 'Finish a lecture to earn one'
                : 'Keep collecting',
          ),
          _MetricData(
            icon: Icons.cloud_upload_rounded,
            color: StudyColors.success,
            value: '$uploads',
            label: 'Uploads',
            hint: '${StudyLimits.freeDailySummarizeActions} free per day',
          ),
        ];

        if (compact) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: metrics
                .map(
                  (_MetricData m) => SizedBox(
                    width: (constraints.maxWidth - 10) / 2,
                    child: _MetricCard(data: m),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: <Widget>[
            for (int i = 0; i < metrics.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _MetricCard(data: metrics[i])),
            ],
          ],
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.hint,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String hint;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(data.icon, color: data.color, size: 22),
          const SizedBox(height: 12),
          Text(
            data.value,
            style: TextStyle(
              color: StudyColors.textPrimary(brightness),
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            style: TextStyle(
              color: StudyColors.textPrimary(brightness),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.hint,
            style: TextStyle(
              color: StudyColors.textSecondary(brightness),
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStreakCard extends StatelessWidget {
  const _WeekStreakCard({
    required this.streakDays,
    required this.lastStudyDate,
    required this.accent,
  });

  final int streakDays;
  final DateTime? lastStudyDate;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int weekdayIndex = today.weekday % 7; // Sun=0
    final DateTime sunday = today.subtract(Duration(days: weekdayIndex));
    final Set<int> activeDays = <int>{};
    if (streakDays > 0 && lastStudyDate != null) {
      DateTime cursor = DateTime(
        lastStudyDate!.year,
        lastStudyDate!.month,
        lastStudyDate!.day,
      );
      for (int i = 0; i < streakDays; i++) {
        final int idx = cursor.difference(sunday).inDays;
        if (idx >= 0 && idx < 7) activeDays.add(idx);
        cursor = cursor.subtract(const Duration(days: 1));
      }
    } else if (streakDays > 0) {
      activeDays.add(weekdayIndex);
    }

    const List<String> labels = <String>[
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'This week',
                style: TextStyle(
                  color: StudyColors.textPrimary(brightness),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '$streakDays day streak',
                style: TextStyle(
                  color: StudyColors.textSecondary(brightness),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (int i = 0; i < 7; i++)
                Column(
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeDays.contains(i)
                            ? StudyColors.accent
                            : StudyColors.surfaceElevated(brightness),
                        border: Border.all(
                          color: activeDays.contains(i)
                              ? StudyColors.accent
                              : StudyColors.border(brightness),
                        ),
                      ),
                      child: activeDays.contains(i)
                          ? const Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i],
                      style: TextStyle(
                        color: StudyColors.textSecondary(brightness),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            streakDays <= 0
                ? 'Study today to start your streak.'
                : 'Come back tomorrow to make it ${streakDays + 1}.',
            style: TextStyle(
              color: StudyColors.textSecondary(brightness),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudySpaceCard extends StatelessWidget {
  const _StudySpaceCard({
    required this.courseService,
    required this.summarizer,
    required this.flashcards,
    required this.courseIds,
    required this.badgesCount,
    required this.accent,
    required this.onCourses,
    required this.onNotes,
    required this.onFlashcards,
    required this.onAchievements,
    required this.onSettings,
  });

  final CourseService courseService;
  final NotesSummarizerService summarizer;
  final FlashcardService flashcards;
  final List<String> courseIds;
  final int badgesCount;
  final Color accent;
  final VoidCallback onCourses;
  final VoidCallback onNotes;
  final VoidCallback onFlashcards;
  final VoidCallback onAchievements;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'My study space',
            style: TextStyle(
              color: StudyColors.textPrimary(brightness),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Course>>(
            stream: courseService.watchMyCourses(courseIds),
            builder: (
              BuildContext context,
              AsyncSnapshot<List<Course>> courseSnap,
            ) {
              final int courses = courseSnap.data?.length ?? 0;
              return StreamBuilder<List<StudySummary>>(
                stream: summarizer.watchSummaries(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<StudySummary>> notesSnap,
                ) {
                  final int notes = notesSnap.data?.length ?? 0;
                  return StreamBuilder<List<Flashcard>>(
                    stream: flashcards.watchFlashcards(),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<List<Flashcard>> fcSnap,
                    ) {
                      final int cards = fcSnap.data?.length ?? 0;
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.55,
                        children: <Widget>[
                          _SpaceTile(
                            icon: Icons.menu_book_rounded,
                            color: accent,
                            title: 'Courses',
                            subtitle: '$courses classes',
                            onTap: onCourses,
                          ),
                          _SpaceTile(
                            icon: Icons.description_outlined,
                            color: accent,
                            title: 'Notes',
                            subtitle: '$notes summaries',
                            onTap: onNotes,
                          ),
                          _SpaceTile(
                            icon: Icons.style_rounded,
                            color: accent,
                            title: 'Flashcards',
                            subtitle: '$cards cards',
                            onTap: onFlashcards,
                          ),
                          _SpaceTile(
                            icon: Icons.emoji_events_rounded,
                            color: accent,
                            title: 'Achievements',
                            subtitle: '$badgesCount earned',
                            onTap: onAchievements,
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSettings,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.person_outline_rounded,
                      color: StudyColors.textSecondary(brightness),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Account settings',
                        style: TextStyle(
                          color: StudyColors.textPrimary(brightness),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: StudyColors.textSecondary(brightness),
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

class _SpaceTile extends StatelessWidget {
  const _SpaceTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Material(
      color: StudyColors.surfaceElevated(brightness),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: color, size: 22),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: StudyColors.textPrimary(brightness),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: StudyColors.textSecondary(brightness),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumPromoCard extends StatelessWidget {
  const _PremiumPromoCard({
    required this.accent,
    required this.onSeePlans,
  });

  final Color accent;
  final VoidCallback onSeePlans;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent,
            Color.lerp(accent, Colors.black, 0.18)!,
            Color.lerp(accent, const Color(0xFF0F172A), 0.35)!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Try Premium free for 30 days',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlimited AI Tutor, study sets and uploads, plus exam prep tools.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: onSeePlans,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'See plans  >',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'From ${BillingConfig.premiumMonthlyPrice} a month after the trial. Cancel any time.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumActiveCard extends StatelessWidget {
  const _PremiumActiveCard({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.workspace_premium_rounded, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Premium is active on this account',
              style: TextStyle(
                color: StudyColors.textPrimary(brightness),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstBadgeCard extends StatelessWidget {
  const _FirstBadgeCard({
    required this.hasBadge,
    required this.accent,
    required this.onBrowse,
  });

  final bool hasBadge;
  final Color accent;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            hasBadge ? 'Your badges' : 'Your first badge',
            style: TextStyle(
              color: StudyColors.textPrimary(brightness),
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: StudyColors.border(brightness),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Icon(
                Icons.military_tech_outlined,
                size: 32,
                color: hasBadge ? accent : StudyColors.textSecondary(brightness),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              hasBadge ? 'Nice work — keep collecting.' : 'Not earned yet',
              style: TextStyle(
                color: StudyColors.textPrimary(brightness),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              hasBadge
                  ? 'Open Achievements in Study space to review them.'
                  : 'Finish a lecture or pass a quiz and it lands here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: StudyColors.textSecondary(brightness),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
          if (!hasBadge) ...<Widget>[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: onBrowse,
                style: OutlinedButton.styleFrom(
                  foregroundColor: StudyColors.textPrimary(brightness),
                  side: BorderSide(color: StudyColors.border(brightness)),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Browse lectures',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
