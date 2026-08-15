import 'package:flutter/material.dart';

import '../../config/virtual_university.dart';
import '../../theme/practice_lab_game_theme.dart';

/// Pre-session briefing shown before a practice lab begins.
class PracticeLabIntroPanel extends StatelessWidget {
  const PracticeLabIntroPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.objectives,
    required this.sessionFacts,
    required this.onStart,
    this.leadingEmoji = '🎓',
    this.startLabel = 'Start session',
  });

  final String title;
  final String subtitle;
  final List<String> objectives;
  final List<String> sessionFacts;
  final VoidCallback onStart;
  final String leadingEmoji;
  final String startLabel;

  @override
  Widget build(BuildContext context) {
    final PracticeLabColors lab = context.practiceLab;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Spacer(),
            Text(leadingEmoji, style: const TextStyle(fontSize: 48), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              VirtualUniversity.tagline,
              textAlign: TextAlign.center,
              style: TextStyle(color: lab.primary, fontWeight: FontWeight.w800, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: lab.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 22),
            _SectionLabel('Learning objectives', scheme.primary),
            const SizedBox(height: 8),
            ...objectives.map(
              (String obj) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.check_circle_rounded, size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(obj, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionLabel('This session', scheme.primary),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sessionFacts
                  .map(
                    (String fact) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: lab.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: lab.border),
                      ),
                      child: Text(
                        fact,
                        style: TextStyle(color: lab.textSecondary, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(startLabel, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            Text(
              'Learn → Practice → Feedback → Master',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: lab.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.accent);

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6),
    );
  }
}
