import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/study_summary.dart';
import '../models/user_profile.dart';
import '../screens/course_summaries_screen.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import '../services/notes_summarizer_service.dart';
import '../services/subscription_service.dart';
import '../services/user_service.dart';
import '../screens/grade_predictor_screen.dart';
import '../screens/membership_screen.dart';
import '../theme/study_theme.dart';
import '../utils/class_study_groups.dart';
import '../utils/course_summary_actions.dart';
import '../utils/progress_analytics.dart';
import '../utils/summary_study_actions.dart';
import '../widgets/program_analytics_section.dart';
import '../widgets/study_set_card.dart';

/// Study library grouped by class (not individual notes).
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _openTopics(
    BuildContext context,
    ClassStudyGroup group,
    List<StudySummary> allSummaries,
  ) {
    if (group.topicCount == 1) {
      CourseSummaryActions.openGeneratedNote(context, group.latestSummary);
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            CourseSummariesScreen(course: group.courseForNavigation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(
      Theme.of(context).brightness,
    );
    final NotesSummarizerService summarizer = context
        .watch<NotesSummarizerService>();
    final UserService users = context.watch<UserService>();
    final CourseService courses = context.watch<CourseService>();
    final AuthService auth = context.watch<AuthService>();
    final bool isPremium = context.watch<SubscriptionService>().isPremium;

    return StreamBuilder<UserProfile>(
      stream: users.watchProfile(),
      builder: (BuildContext context, AsyncSnapshot<UserProfile> profileSnap) {
        final UserProfile profile =
            profileSnap.data ??
            UserProfile.empty(email: auth.email, displayName: auth.displayName);

        return StreamBuilder<List<Course>>(
          stream: courses.watchMyCourses(profile.courseIds),
          builder: (BuildContext context, AsyncSnapshot<List<Course>> coursesSnap) {
            final List<Course> enrolled = coursesSnap.data ?? <Course>[];

            return StreamBuilder<List<StudySummary>>(
              stream: summarizer.watchSummaries(),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<StudySummary>> snapshot,
                  ) {
                    final List<StudySummary> summaries =
                        snapshot.data ?? <StudySummary>[];
                    final List<ClassStudyGroup> groups = groupSummariesByClass(
                      summaries: summaries,
                      enrolledCourses: enrolled,
                    );

                    final int totalCards = groups.fold<int>(
                      0,
                      (int sum, ClassStudyGroup g) => sum + g.mastery.total,
                    );

                    return ListView(
                      padding: EdgeInsets.fromLTRB(
                        kIsWeb ? 24 : 16,
                        kIsWeb ? 16 : 8,
                        kIsWeb ? 24 : 16,
                        24,
                      ),
                      children: <Widget>[
                        _ProgressHero(
                          profile: profile,
                          classCount: groups.length,
                          cardCount: totalCards,
                        ),
                        if (!isPremium) ...<Widget>[
                          const SizedBox(height: 12),
                          _PremiumFocusBanner(
                            onUpgrade: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const MembershipScreen(),
                              ),
                            ),
                          ),
                        ] else ...<Widget>[
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    GradePredictorScreen(profile: profile),
                              ),
                            ),
                            icon: const Icon(Icons.insights_rounded),
                            label: const Text('Grade Predictor'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        ProgramAnalyticsSection(profile: profile),
                        const SizedBox(height: 26),
                        const _ProgressSectionHeader(
                          eyebrow: 'COURSES',
                          title: 'Class progress',
                          subtitle:
                              'Review your materials and keep building mastery.',
                        ),
                        const SizedBox(height: 12),
                        if (groups.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 48),
                            child: Center(
                              child: Text(
                                'No class study sets yet.\nSummarize notes for a course to get started.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          )
                        else
                          ...groups.map((ClassStudyGroup group) {
                            final FocusTopicRecommendation? focus = isPremium
                                ? group.focusRecommendation(
                                    profile: profileSnap.data,
                                  )
                                : null;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: StudySetCard(
                                expandId: group.courseId.isNotEmpty
                                    ? group.courseId
                                    : group.displayTitle,
                                title: group.displayTitle,
                                subtitle: group.displaySubtitle,
                                statsLabel: group.statsLabel,
                                mastery: group.mastery,
                                showFocusRecommendations: false,
                                focusTopic: focus?.topicName,
                                focusReason: focus?.reason,
                                onFocusTap: focus == null
                                    ? null
                                    : () =>
                                          CourseSummaryActions.openGeneratedNote(
                                            context,
                                            focus.summary,
                                          ),
                                onFlashcards: () =>
                                    SummaryStudyActions.openFlashcards(
                                      context,
                                      group.latestSummary,
                                    ),
                                onPractice: () => SummaryStudyActions.openQuiz(
                                  context,
                                  group.latestSummary,
                                ),
                                onNotes: () =>
                                    _openTopics(context, group, summaries),
                                onMenuAction: (String action) {
                                  if (action == 'topics') {
                                    _openTopics(context, group, summaries);
                                  }
                                },
                              ),
                            );
                          }),
                      ],
                    );
                  },
            );
          },
        );
      },
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.profile,
    required this.classCount,
    required this.cardCount,
  });

  final UserProfile profile;
  final int classCount;
  final int cardCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final ProgressSnapshot snapshot = ProgressAnalytics.fromProfile(profile);
    final int studyMinutes = snapshot.weeklyGoals.first.current;
    final String studyTime = studyMinutes >= 60
        ? '${(studyMinutes / 60).toStringAsFixed(1)}h'
        : '${studyMinutes}m';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'PROGRESS',
          style: TextStyle(
            color: scheme.primary,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Your learning, at a glance',
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Track consistency, performance, and what to focus on next.',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: snapshot.averageQuizScore / 100,
                            strokeWidth: 7,
                            strokeCap: StrokeCap.round,
                            color: scheme.primary,
                            backgroundColor: scheme.onPrimaryContainer
                                .withValues(alpha: 0.12),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '${snapshot.averageQuizScore}%',
                              style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'QUIZ AVG',
                              style: TextStyle(
                                color: scheme.onPrimaryContainer.withValues(
                                  alpha: 0.65,
                                ),
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.45,
                              ),
                            ),
                          ],
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
                          'Level ${snapshot.level} · ${snapshot.levelTitle}',
                          style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          snapshot.xpToNext == 0
                              ? 'Your next level is ready.'
                              : '${snapshot.xpToNext} XP until your next level',
                          style: TextStyle(
                            color: scheme.onPrimaryContainer.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: (snapshot.xp % 200) / 200,
                            minHeight: 7,
                            color: scheme.primary,
                            backgroundColor: scheme.onPrimaryContainer
                                .withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ProgressMetric(
                      icon: Icons.timer_outlined,
                      value: studyTime,
                      label: 'This week',
                    ),
                  ),
                  Expanded(
                    child: _ProgressMetric(
                      icon: Icons.local_fire_department_outlined,
                      value: '${profile.streakDays}',
                      label: 'Day streak',
                    ),
                  ),
                  Expanded(
                    child: _ProgressMetric(
                      icon: Icons.school_outlined,
                      value: '$classCount',
                      label: 'Classes',
                    ),
                  ),
                  Expanded(
                    child: _ProgressMetric(
                      icon: Icons.style_outlined,
                      value: '$cardCount',
                      label: 'Cards',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
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
    return Column(
      children: <Widget>[
        Icon(icon, color: scheme.primary, size: 18),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          style: TextStyle(
            color: scheme.onPrimaryContainer,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: scheme.onPrimaryContainer.withValues(alpha: 0.65),
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProgressSectionHeader extends StatelessWidget {
  const _ProgressSectionHeader({
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
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
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

class _PremiumFocusBanner extends StatelessWidget {
  const _PremiumFocusBanner({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudyColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.auto_awesome, color: StudyColors.accentDark),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Upgrade for AI focus topics, Grade Predictor, and advanced analytics.',
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onUpgrade, child: const Text('Upgrade')),
        ],
      ),
    );
  }
}
