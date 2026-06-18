import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/flashcard.dart';
import '../models/study_material.dart';
import '../models/study_summary.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import '../services/flashcard_service.dart';
import '../services/material_service.dart';
import '../services/notes_summarizer_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/gamification.dart';
import 'flashcards_screen.dart';
import 'membership_screen.dart';
import 'settings_screen.dart';
import '../models/subscription_plan.dart';
import 'my_courses_screen.dart';
import 'notes_summarizer_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _handleFromEmail(String email) {
    final int at = email.indexOf('@');
    if (at <= 0) return '@student';
    return '@${email.substring(0, at)}';
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void _showAchievements(BuildContext context, UserProfile profile) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Achievements'),
        content: profile.badges.isEmpty
            ? const Text('Study daily to earn streak badges at 7, 30, and 100 days.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: profile.badges
                    .map(
                      (String id) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.military_tech_rounded, color: StudyColors.accent),
                            const SizedBox(width: 10),
                            Text(Gamification.badgeLabel(id)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
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
    final NotesSummarizerService summarizer = context.watch<NotesSummarizerService>();
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final String initial = auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'S';

    return StreamBuilder<UserProfile>(
      stream: userService.watchProfile(),
      builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Could not load profile: ${snapshot.error}'));
        }

        final UserProfile profile = snapshot.data ??
            UserProfile.empty(email: auth.email, displayName: auth.displayName);
        final int level = Gamification.levelFromXp(profile.xp);
        final int xpFloor = Gamification.xpFloorForLevel(level);
        final int xpCeil = Gamification.xpCeilForLevel(level);

        return Scaffold(
          backgroundColor: StudyColors.background(brightness),
          body: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _ProfileHeader(
                initial: initial,
                name: profile.displayName.isNotEmpty ? profile.displayName : 'Student',
                handle: _handleFromEmail(auth.email),
                showVerified: profile.isEduVerified,
                showPremium: profile.verifiedSolver,
                onSettings: () => _openSettings(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: <Widget>[
                    Transform.translate(
                      offset: const Offset(0, -24),
                      child: StreamBuilder<List<StudyMaterial>>(
                        stream: materials.watchMyUploads(limit: 200),
                        builder: (BuildContext context, AsyncSnapshot<List<StudyMaterial>> uploadSnap) {
                          final int uploads = uploadSnap.data?.length ?? 0;
                          return _StatsRow(
                            streakDays: profile.streakDays,
                            points: profile.xp,
                            badges: profile.badges.length,
                            uploads: uploads,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _LevelCard(
                      level: level,
                      title: Gamification.levelTitle(level),
                      xp: profile.xp,
                      xpFloor: xpFloor,
                      xpCeil: xpCeil,
                      progress: Gamification.levelProgress(profile.xp),
                    ),
                    const SizedBox(height: 12),
                    MembershipTeaserCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
                      ),
                      plan: SubscriptionPlan.fromString(profile.plan),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<Course>>(
                      stream: courseService.watchMyCourses(profile.courseIds),
                      builder: (BuildContext context, AsyncSnapshot<List<Course>> courseSnap) {
                        final List<Course> myCourses = courseSnap.data ?? <Course>[];
                        return _ProfileCounts(
                          summarizer: summarizer,
                          flashcards: flashcards,
                          builder: (int notes, int cards) {
                            return _ToolsCard(
                              courseCount: myCourses.length,
                              notesCount: notes,
                              cardsCount: cards,
                              badgesCount: profile.badges.length,
                              textSecondary: textSecondary,
                              onMyCourses: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (_) => const MyCoursesScreen()),
                              ),
                              onNotes: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (_) => const NotesSummarizerScreen()),
                              ),
                              onSaved: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (_) => const FlashcardsScreen()),
                              ),
                              onAchievements: () => _showAchievements(context, profile),
                              onSettings: () => _openSettings(context),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Loads summary/flashcard counts for the menu card.
class _ProfileCounts extends StatelessWidget {
  const _ProfileCounts({
    required this.summarizer,
    required this.flashcards,
    required this.builder,
  });

  final NotesSummarizerService summarizer;
  final FlashcardService flashcards;
  final Widget Function(int notes, int cards) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StudySummary>>(
      stream: summarizer.watchSummaries(),
      builder: (BuildContext context, AsyncSnapshot<List<StudySummary>> notesSnap) {
        final int notes = notesSnap.data?.length ?? 0;
        return StreamBuilder<List<Flashcard>>(
          stream: flashcards.watchFlashcards(),
          builder: (BuildContext context, AsyncSnapshot<List<Flashcard>> fcSnap) {
            final int cards = fcSnap.data?.length ?? 0;
            return builder(notes, cards);
          },
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initial,
    required this.name,
    required this.handle,
    required this.showVerified,
    required this.showPremium,
    required this.onSettings,
  });

  final String initial;
  final String name;
  final String handle;
  final bool showVerified;
  final bool showPremium;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            StudyColors.primaryDark,
            StudyColors.primary,
            Color(0xFF0EA5E9),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: StudyColors.primary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: StudyColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      handle,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 14),
                    ),
                    if (showVerified || showPremium) ...<Widget>[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              showPremium ? Icons.workspace_premium_rounded : Icons.verified_rounded,
                              color: StudyColors.accent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              showPremium ? 'Top contributor' : '.edu verified',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.streakDays,
    required this.points,
    required this.badges,
    required this.uploads,
  });

  final int streakDays;
  final int points;
  final int badges;
  final int uploads;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StudyColors.border(brightness)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: brightness == Brightness.dark ? 0.25 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          _StatCell(
            icon: Icons.local_fire_department_rounded,
            iconColor: StudyColors.accent,
            value: '$streakDays',
            label: 'Day streak',
          ),
          _StatCell(
            icon: Icons.bolt_rounded,
            iconColor: StudyColors.primary,
            value: Gamification.formatCompactCount(points),
            label: 'Points',
          ),
          _StatCell(
            icon: Icons.military_tech_outlined,
            iconColor: const Color(0xFFEC4899),
            value: '$badges',
            label: 'Badges',
          ),
          _StatCell(
            icon: Icons.cloud_upload_outlined,
            iconColor: StudyColors.success,
            value: '$uploads',
            label: 'Uploads',
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.title,
    required this.xp,
    required this.xpFloor,
    required this.xpCeil,
    required this.progress,
  });

  final int level;
  final String title;
  final int xp;
  final int xpFloor;
  final int xpCeil;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: StudyColors.primaryTint(brightness),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.shield_rounded, color: StudyColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Level $level', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                    Text(title, style: TextStyle(color: textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 150),
                child: Text(
                  '${xp - xpFloor} / ${xpCeil - xpFloor} XP',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: StudyColors.primary.withValues(alpha: 0.12),
                color: StudyColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolsCard extends StatelessWidget {
  const _ToolsCard({
    required this.courseCount,
    required this.notesCount,
    required this.cardsCount,
    required this.badgesCount,
    required this.textSecondary,
    required this.onMyCourses,
    required this.onNotes,
    required this.onSaved,
    required this.onAchievements,
    required this.onSettings,
  });

  final int courseCount;
  final int notesCount;
  final int cardsCount;
  final int badgesCount;
  final Color textSecondary;
  final VoidCallback onMyCourses;
  final VoidCallback onNotes;
  final VoidCallback onSaved;
  final VoidCallback onAchievements;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Text('My tools & data', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          _MenuRow(
            icon: Icons.school_outlined,
            iconColor: const Color(0xFF6366F1),
            title: 'My courses',
            trailing: '$courseCount classes',
            onTap: onMyCourses,
          ),
          _MenuRow(
            icon: Icons.note_alt_outlined,
            iconColor: const Color(0xFF0891B2),
            title: 'My notes',
            trailing: '$notesCount summaries',
            onTap: onNotes,
          ),
          _MenuRow(
            icon: Icons.bookmark_outline_rounded,
            iconColor: StudyColors.accentDark,
            title: 'Flashcards',
            trailing: '$cardsCount cards',
            onTap: onSaved,
          ),
          _MenuRow(
            icon: Icons.emoji_events_outlined,
            iconColor: StudyColors.accent,
            title: 'Achievements',
            trailing: '$badgesCount earned',
            onTap: onAchievements,
          ),
          _MenuRow(
            icon: Icons.settings_outlined,
            iconColor: textSecondary,
            title: 'Settings',
            trailing: 'Account',
            onTap: onSettings,
            showDivider: false,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String trailing;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                Text(trailing, style: TextStyle(color: textSecondary, fontSize: 12)),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 58,
            endIndent: 16,
            color: StudyColors.border(Theme.of(context).brightness),
          ),
      ],
    );
  }
}
