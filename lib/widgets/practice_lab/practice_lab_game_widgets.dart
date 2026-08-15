import 'package:flutter/material.dart';

import '../../theme/practice_lab_game_theme.dart';
import '../../utils/practice_lab_game_stats.dart';

class PracticeLabGameDashboardHeader extends StatelessWidget {
  const PracticeLabGameDashboardHeader({super.key, required this.stats});

  final PracticeLabGameStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Virtual University',
          style: TextStyle(
            color: PracticeLabGameTheme.textPrimary(context),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(child: _XpProgressCard(stats: stats)),
            const SizedBox(width: 12),
            _WeeklyGoalRing(stats: stats),
          ],
        ),
      ],
    );
  }
}

class _XpProgressCard extends StatelessWidget {
  const _XpProgressCard({required this.stats});

  final PracticeLabGameStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PracticeLabGameTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PracticeLabGameTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PracticeLabGameTheme.xp(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('LEVEL ${stats.level}', style: TextStyle(color: PracticeLabGameTheme.xp(context), fontWeight: FontWeight.w900, fontSize: 11)),
              ),
              const Spacer(),
              Text('${stats.totalXp} XP', style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: stats.levelProgress,
              minHeight: 10,
              backgroundColor: PracticeLabGameTheme.surfaceElevated(context),
              color: PracticeLabGameTheme.xp(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${stats.xp} / ${stats.xpForNextLevel} XP to Level ${stats.level + 1}',
            style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _WeeklyGoalRing extends StatelessWidget {
  const _WeeklyGoalRing({required this.stats});

  final PracticeLabGameStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PracticeLabGameTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PracticeLabGameTheme.border(context)),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  value: stats.weeklyProgress,
                  strokeWidth: 6,
                  backgroundColor: PracticeLabGameTheme.surfaceElevated(context),
                  color: PracticeLabGameTheme.success(context),
                ),
                Text('${(stats.weeklyProgress * 100).round()}%', style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text('Weekly Goal', style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 9, fontWeight: FontWeight.w700)),
          Text('${stats.weeklyLabs}/${stats.weeklyGoal}', style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class PracticeLabDifficultyFilters extends StatelessWidget {
  const PracticeLabDifficultyFilters({super.key, required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final PracticeLabColors lab = context.practiceLab;
    final List<({String? id, String label, Color? color})> options = <({String? id, String label, Color? color})>[
      (id: null, label: 'All Levels', color: null),
      (id: 'beginner', label: 'Beginner', color: lab.success),
      (id: 'intermediate', label: 'Intermediate', color: lab.warning),
      (id: 'advanced', label: 'Advanced', color: lab.danger),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((({String? id, String label, Color? color}) opt) {
        final bool active = selected == opt.id;
        final Color accent = opt.color ?? PracticeLabGameTheme.textSecondary(context);
        return ChoiceChip(
          label: Text(opt.label),
          selected: active,
          onSelected: (_) => onChanged(opt.id),
          labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: active ? accent : PracticeLabGameTheme.textSecondary(context)),
          selectedColor: accent.withValues(alpha: 0.15),
          backgroundColor: PracticeLabGameTheme.surface(context),
          side: BorderSide(color: active ? accent : PracticeLabGameTheme.border(context)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        );
      }).toList(),
    );
  }
}

class PracticeLabGameStatsPanel extends StatelessWidget {
  const PracticeLabGameStatsPanel({super.key, required this.stats});

  final PracticeLabGameStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PracticeLabGameTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PracticeLabGameTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('YOUR STATS', style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          _StatRow(icon: Icons.science_outlined, color: PracticeLabGameTheme.xp(context), label: 'Labs Completed', value: '${stats.labsCompleted}'),
          _StatRow(icon: Icons.grade_rounded, color: PracticeLabGameTheme.success(context), label: 'Average Score', value: '${stats.averageScore}%'),
          _StatRow(icon: Icons.local_fire_department_rounded, color: PracticeLabGameTheme.streak(context), label: 'Current Streak', value: '${stats.streakDays} days'),
          _StatRow(icon: Icons.diamond_outlined, color: PracticeLabGameTheme.warning(context), label: 'Total XP', value: '${stats.totalXp}'),
          _StatRow(icon: Icons.emoji_events_outlined, color: PracticeLabGameTheme.warning(context), label: 'Rank', value: stats.rankLabel),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.icon, required this.color, required this.label, required this.value});

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 11, fontWeight: FontWeight.w600))),
          Text(value, style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }
}

/// In-session game HUD — mission, quest steps, timer, session XP.
class PracticeLabSessionGameHud extends StatelessWidget {
  const PracticeLabSessionGameHud({
    super.key,
    required this.missionTitle,
    required this.questSteps,
    required this.completedSteps,
    required this.sessionXp,
    required this.liveScore,
    required this.elapsed,
    required this.accent,
  });

  final String missionTitle;
  final List<String> questSteps;
  final Set<int> completedSteps;
  final int sessionXp;
  final int liveScore;
  final Duration elapsed;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final String mm = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String ss = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PracticeLabGameTheme.surface(context).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: <BoxShadow>[BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.flag_rounded, size: 14, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text('MISSION: $missionTitle', style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.4)),
              ),
              _HudPill(label: '+$sessionXp XP', color: PracticeLabGameTheme.xp(context)),
              const SizedBox(width: 6),
              _HudPill(label: '$liveScore%', color: accent),
              const SizedBox(width: 6),
              _HudPill(label: '$mm:$ss', color: PracticeLabGameTheme.textSecondary(context)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: List<Widget>.generate(questSteps.length, (int i) {
              final bool done = completedSteps.contains(i);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: done ? accent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: done ? accent : PracticeLabGameTheme.border(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 12, color: done ? accent : PracticeLabGameTheme.textSecondary(context)),
                    const SizedBox(width: 4),
                    Text(questSteps[i], style: TextStyle(color: done ? accent : PracticeLabGameTheme.textSecondary(context), fontSize: 10, fontWeight: FontWeight.w800)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}
