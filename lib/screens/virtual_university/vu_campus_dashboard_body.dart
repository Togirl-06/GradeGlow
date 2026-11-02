import 'package:flutter/material.dart';

import '../../models/virtual_university_dashboard.dart';
import '../../widgets/virtual_university/vu_accessibility.dart';
import 'vu_notes_screen.dart';
import 'vu_study_tools_screen.dart';

/// Campus dashboard sections shown above the faculty browser.
class VuCampusDashboardBody extends StatelessWidget {
  const VuCampusDashboardBody({
    super.key,
    required this.snapshot,
    required this.onBrowseFaculties,
  });

  final VuDashboardSnapshot snapshot;
  final VoidCallback onBrowseFaculties;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        VuSemanticSectionHeader(
          label: 'Welcome',
          child: Text(
            'Welcome back, ${snapshot.welcomeName}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your digital campus is ready. Browse faculties below to start learning.',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            height: 1.4,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        _StatsRow(snapshot: snapshot),
        const SizedBox(height: 12),
        _OverallProgressCard(
          progress: snapshot.overallProgress,
          xp: snapshot.totalXp,
        ),
        if (snapshot.recentlyCompleted.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          const _SectionTitle(title: 'Recently Completed'),
          const SizedBox(height: 6),
          ...snapshot.recentlyCompleted
              .take(3)
              .map(
                (VuContinueItem e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(e.lessonTitle),
                  subtitle: Text('${e.subjectName} · ${e.courseTitle}'),
                ),
              ),
        ],
        if (snapshot.certificates.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          const _SectionTitle(title: 'Certificates Earned'),
          const SizedBox(height: 8),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.certificates.length.clamp(0, 12),
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int i) {
                final VuCertificateItem cert = snapshot.certificates[i];
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.outlineVariant),
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.45,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.workspace_premium, color: scheme.primary),
                      const Spacer(),
                      Text(
                        cert.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        cert.subjectName,
                        style: TextStyle(
                          fontSize: 10,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        if (snapshot.achievements.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          const _SectionTitle(title: 'Achievements'),
          const SizedBox(height: 8),
          ...snapshot.achievements
              .take(5)
              .map(
                (VuAchievementItem a) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.emoji_events_outlined,
                    color: scheme.tertiary,
                  ),
                  title: Text(
                    a.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(a.subtitle),
                ),
              ),
        ],
        const SizedBox(height: 16),
        const _SectionTitle(title: 'Campus Tools'),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const VuNotesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.sticky_note_2_outlined),
                label: const Text('Notes'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const VuStudyToolsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_fix_high_outlined),
                label: const Text('Study Tools'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onBrowseFaculties,
          child: const Text('Browse all faculties'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return VuSemanticSectionHeader(
      label: title,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.snapshot});
  final VuDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    Widget tile(IconData icon, String value, String label, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: <Widget>[
        tile(
          Icons.local_fire_department_rounded,
          '${snapshot.streakDays}',
          'Streak',
          const Color(0xFFFF7A45),
        ),
        const SizedBox(width: 8),
        tile(
          Icons.flag_rounded,
          '${snapshot.weeklyCompleted}/${snapshot.weeklyGoal}',
          'Weekly',
          scheme.tertiary,
        ),
        const SizedBox(width: 8),
        tile(
          Icons.schedule_rounded,
          '${snapshot.dailyStudyMinutes}m',
          'Today',
          scheme.primary,
        ),
      ],
    );
  }
}

class _OverallProgressCard extends StatelessWidget {
  const _OverallProgressCard({required this.progress, required this.xp});
  final double progress;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: scheme.primaryContainer.withValues(alpha: 0.55),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'Overall Progress',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text(
                '$xp XP',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(99),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).round()}% campus mastery',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
