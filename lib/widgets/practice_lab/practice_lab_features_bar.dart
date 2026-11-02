import 'package:flutter/material.dart';

import '../../theme/leetcode_theme.dart';
import '../../theme/study_theme.dart';
import '../study_surface.dart';

/// Banner listing core practice-lab capabilities included in every session.
class PracticeLabFeaturesBar extends StatelessWidget {
  const PracticeLabFeaturesBar({super.key, this.compact = false, this.leetcode = false});

  final bool compact;
  final bool leetcode;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = leetcode
        ? LeetCodeTheme.textSecondary
        : StudyColors.textSecondary(Theme.of(context).brightness);
    final Color accent = leetcode ? LeetCodeTheme.accent : StudyColors.primary;
    final List<({IconData icon, String label})> features = leetcode
        ? <({IconData icon, String label})>[
            (icon: Icons.speed_outlined, label: 'Real-time scoring'),
            (icon: Icons.lightbulb_outline, label: 'Hints'),
            (icon: Icons.trending_up, label: 'Skill tracking'),
            (icon: Icons.code_rounded, label: 'Code editor'),
          ]
        : <({IconData icon, String label})>[
            (icon: Icons.record_voice_over_outlined, label: 'Live AI character'),
            (icon: Icons.mic_outlined, label: 'Voice conversation'),
            (icon: Icons.speed_outlined, label: 'Real-time scoring'),
            (icon: Icons.lightbulb_outline, label: 'Hints'),
            (icon: Icons.trending_up, label: 'Skill tracking'),
          ];

    final Widget chips = Wrap(
      spacing: 8,
      runSpacing: 6,
      children: features
          .map(
            (({IconData icon, String label}) f) => _Chip(icon: f.icon, label: f.label, accent: accent, leetcode: leetcode),
          )
          .toList(),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Every lab includes', style: TextStyle(fontWeight: FontWeight.w800, color: accent, fontSize: 13)),
          const SizedBox(height: 8),
          chips,
        ],
      );
    }

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Every lab includes', style: TextStyle(fontWeight: FontWeight.w800, color: accent)),
        const SizedBox(height: 10),
        chips,
        const SizedBox(height: 6),
        Text(
          'Unlimited unique AI scenarios per topic',
          style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );

    if (leetcode) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LeetCodeTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: LeetCodeTheme.border),
        ),
        child: content,
      );
    }

    return StudySurfaceCard(padding: const EdgeInsets.all(14), child: content);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.accent, required this.leetcode});

  final IconData icon;
  final String label;
  final Color accent;
  final bool leetcode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: leetcode ? LeetCodeTheme.surfaceElevated : accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: leetcode ? Border.all(color: LeetCodeTheme.border) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent)),
        ],
      ),
    );
  }
}
