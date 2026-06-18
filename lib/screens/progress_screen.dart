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
import '../screens/membership_screen.dart';
import '../theme/study_theme.dart';
import '../utils/class_study_groups.dart';
import '../utils/course_summary_actions.dart';
import '../utils/summary_study_actions.dart';
import '../widgets/study_set_card.dart';

/// Study library grouped by class (not individual notes).
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _openTopics(BuildContext context, ClassStudyGroup group, List<StudySummary> allSummaries) {
    if (group.topicCount == 1) {
      CourseSummaryActions.openGeneratedNote(context, group.latestSummary);
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CourseSummariesScreen(course: group.courseForNavigation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final NotesSummarizerService summarizer = context.watch<NotesSummarizerService>();
    final UserService users = context.watch<UserService>();
    final CourseService courses = context.watch<CourseService>();
    final AuthService auth = context.watch<AuthService>();
    final bool isPremium = context.watch<SubscriptionService>().isPremium;

    return StreamBuilder<UserProfile>(
      stream: users.watchProfile(),
      builder: (BuildContext context, AsyncSnapshot<UserProfile> profileSnap) {
        final UserProfile profile =
            profileSnap.data ?? UserProfile.empty(email: auth.email, displayName: auth.displayName);

        return StreamBuilder<List<Course>>(
          stream: courses.watchMyCourses(profile.courseIds),
          builder: (BuildContext context, AsyncSnapshot<List<Course>> coursesSnap) {
            final List<Course> enrolled = coursesSnap.data ?? <Course>[];

            return StreamBuilder<List<StudySummary>>(
              stream: summarizer.watchSummaries(),
              builder: (BuildContext context, AsyncSnapshot<List<StudySummary>> snapshot) {
                final List<StudySummary> summaries = snapshot.data ?? <StudySummary>[];
                final List<ClassStudyGroup> groups = groupSummariesByClass(
                  summaries: summaries,
                  enrolledCourses: enrolled,
                );

                final int totalCards = groups.fold<int>(
                  0,
                  (int sum, ClassStudyGroup g) => sum + g.mastery.total,
                );

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: <Widget>[
                    _LibraryHeader(classCount: groups.length, cardCount: totalCards),
                    if (!isPremium) ...<Widget>[
                      const SizedBox(height: 12),
                      _PremiumFocusBanner(
                        onUpgrade: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    if (groups.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Center(
                          child: Text(
                            'No class study sets yet.\nSummarize notes for a course to get started.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textSecondary, height: 1.5),
                          ),
                        ),
                      )
                    else
                      ...groups.map((ClassStudyGroup group) {
                        final FocusTopicRecommendation? focus =
                            isPremium ? group.focusRecommendation(profile: profileSnap.data) : null;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: StudySetCard(
                            title: group.displayTitle,
                            subtitle: group.displaySubtitle,
                            statsLabel: group.statsLabel,
                            mastery: group.mastery,
                            showFocusRecommendations: isPremium,
                            focusTopic: focus?.topicName,
                            focusReason: focus?.reason,
                            onFocusTap: focus == null
                                ? null
                                : () => CourseSummaryActions.openGeneratedNote(context, focus.summary),
                            onFlashcards: () => SummaryStudyActions.openFlashcards(context, group.latestSummary),
                            onPractice: () => SummaryStudyActions.openQuiz(context, group.latestSummary),
                            onNotes: () => _openTopics(context, group, summaries),
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

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({required this.classCount, required this.cardCount});

  final int classCount;
  final int cardCount;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textPrimary = StudyColors.textPrimary(brightness);
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final String classLabel = classCount == 1 ? '1 class' : '$classCount classes';
    final String cardLabel = cardCount == 1 ? '1 card' : '$cardCount cards';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            StudyColors.primary.withValues(alpha: brightness == Brightness.dark ? 0.22 : 0.12),
            StudyColors.accent.withValues(alpha: brightness == Brightness.dark ? 0.14 : 0.08),
          ],
        ),
        border: Border.all(color: StudyColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: StudyColors.primaryTint(brightness),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.school_rounded, color: StudyColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Your class progress',
                  style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '$classLabel · $cardLabel ready to study',
                  style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
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
              style: TextStyle(fontSize: 13, height: 1.35, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(onPressed: onUpgrade, child: const Text('Upgrade')),
        ],
      ),
    );
  }
}
