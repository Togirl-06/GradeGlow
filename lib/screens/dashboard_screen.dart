import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_summary.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/notes_summarizer_service.dart';
import '../services/subscription_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/gamification.dart';
import '../utils/summary_study_actions.dart';
import '../widgets/next_class_exam_card.dart';
import '../widgets/gradeglow_logo.dart';
import '../widgets/study_surface.dart';

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
    required this.onHomeworkScan,
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
  final VoidCallback onHomeworkScan;

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
    final SubscriptionService subs = context.watch<SubscriptionService>();
    final NotesSummarizerService summarizer = context.watch<NotesSummarizerService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return ListView(
      padding: EdgeInsets.fromLTRB(kIsWeb ? 24 : 16, kIsWeb ? 24 : 8, kIsWeb ? 24 : 16, 16),
      children: <Widget>[
        GradeGlowHomeHeader(
          greeting: _greeting(),
          name: auth.displayName,
          showLogo: !kIsWeb,
        ),
        const SizedBox(height: 16),
        StreamBuilder<UserProfile>(
          stream: userService.watchProfile(),
          builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
            final UserProfile profile = snapshot.data ??
                UserProfile.empty(email: auth.email, displayName: auth.displayName);
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[StudyColors.primaryDark, StudyColors.primary],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Study streak', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.local_fire_department_rounded, color: StudyColors.accent, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '${profile.streakDays} day${profile.streakDays == 1 ? '' : 's'} in a row',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  if (profile.school.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      '${profile.school} · ${profile.major} · ${profile.year}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.bolt, color: StudyColors.accent, size: 18),
                      const SizedBox(width: 6),
                      Text('${profile.xp} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      if (profile.badges.isNotEmpty) ...<Widget>[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            profile.badges.map(Gamification.badgeLabel).join(' · '),
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
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
                (snapshot.data ?? UserProfile.empty(email: '')).topWeakTopics(limit: 5);
            if (weak.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Review these topics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    TextButton(onPressed: onWeaknessReview, child: const Text('See all')),
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
                                const Icon(Icons.warning_amber_rounded, color: StudyColors.warning, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600))),
                                Text('×${e.value}', style: TextStyle(color: textSecondary)),
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
        const SizedBox(height: 20),
        const Text('Study tools', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        StreamBuilder<List<StudySummary>>(
          stream: summarizer.watchSummaries(),
          builder: (BuildContext context, AsyncSnapshot<List<StudySummary>> summarySnap) {
            final StudySummary? latest = SummaryStudyActions.latestSummary(summarySnap.data ?? <StudySummary>[]);
            final int quizCount = latest?.quizQuestions.length ?? 0;
            final int cardCount = latest?.flashcards.length ?? 0;
            final String quizLabel = quizCount > 0 ? 'Quiz ($quizCount)' : 'Quiz';
            final String cardsLabel = cardCount > 0 ? 'Cards ($cardCount)' : 'Flashcards';

            return Row(
              children: <Widget>[
                Expanded(
                  child: _QuickAction(
                    icon: Icons.quiz_outlined,
                    label: quizLabel,
                    onTap: latest == null
                        ? () => SummaryStudyActions.promptNoSummaries(context)
                        : () => SummaryStudyActions.openQuiz(context, latest),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.style_outlined,
                    label: cardsLabel,
                    onTap: latest == null
                        ? () => SummaryStudyActions.promptNoSummaries(context)
                        : () => SummaryStudyActions.openFlashcards(context, latest),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(icon: Icons.smart_toy_outlined, label: 'AI Tutor', onTap: onAskAi),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _QuickAction(
                icon: Icons.document_scanner_outlined,
                label: 'Assignments',
                premiumOnly: !subs.isPremium,
                onTap: onHomeworkScan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Productivity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(child: _QuickAction(icon: Icons.summarize_outlined, label: 'Summarize', onTap: onSummarize)),
            const SizedBox(width: 10),
            Expanded(child: _QuickAction(icon: Icons.calendar_month_outlined, label: 'Planner', onTap: onPlanner)),
            const SizedBox(width: 10),
            Expanded(child: _QuickAction(icon: Icons.timer_outlined, label: 'Pomodoro', onTap: onPomodoro)),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.premiumOnly = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool premiumOnly;

  @override
  Widget build(BuildContext context) {
    return StudySurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 18),
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Icon(icon, color: StudyColors.primary, size: 28),
              if (premiumOnly)
                const Positioned(
                  right: -8,
                  top: -6,
                  child: Icon(Icons.workspace_premium, color: StudyColors.accent, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
