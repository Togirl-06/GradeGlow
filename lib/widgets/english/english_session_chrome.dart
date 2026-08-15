import 'package:flutter/material.dart';

import '../../models/english_lesson.dart';
import '../../theme/study_theme.dart';

/// GradeGlow English session styling — AI tutor feel, not Duolingo clone.
abstract final class EnglishLessonTheme {
  static Color background(Brightness b) => StudyColors.background(b);

  static Color surface(Brightness b) => StudyColors.surface(b);

  static Color textSecondary(Brightness b) => StudyColors.textSecondary(b);

  static BorderRadius get radius => BorderRadius.circular(18);

  static ButtonStyle primaryButton(Brightness b) => FilledButton.styleFrom(
        backgroundColor: StudyColors.primary,
        foregroundColor: Colors.white,
        // Avoid Size.fromHeight — it sets infinite width and breaks Row layouts.
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      );

  static BoxDecoration heroGradient(Brightness b) => BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: b == Brightness.dark
              ? <Color>[
                  StudyColors.primary.withValues(alpha: 0.35),
                  const Color(0xFF1C2840),
                ]
              : <Color>[
                  StudyColors.primary,
                  StudyColors.primaryLight,
                ],
        ),
      );

  static BoxDecoration feedbackDecoration(
    Brightness b, {
    required bool correct,
  }) {
    final Color tint = correct ? StudyColors.success : StudyColors.danger;
    return BoxDecoration(
      color: tint.withValues(alpha: b == Brightness.dark ? 0.18 : 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: tint.withValues(alpha: 0.35)),
    );
  }

  static Color feedbackText({required bool correct}) =>
      correct ? StudyColors.success : StudyColors.danger;

  static String activityKindLabel(String kind) => kind;
}

/// Compact AI professor header used during live sessions.
class EnglishProfessorChip extends StatelessWidget {
  const EnglishProfessorChip({
    super.key,
    this.speaking = false,
    this.stepLabel,
  });

  final bool speaking;
  final String? stepLabel;

  @override
  Widget build(BuildContext context) {
    final Brightness b = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: StudyColors.primaryTint(b),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: StudyColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(
            radius: 14,
            backgroundColor: StudyColors.primary.withValues(alpha: 0.15),
            child: Icon(
              Icons.record_voice_over_rounded,
              size: 16,
              color: StudyColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'AI Professor',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: StudyColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (speaking) ...<Widget>[
            const SizedBox(width: 8),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: StudyColors.primary,
              ),
            ),
          ],
          if (stepLabel != null) ...<Widget>[
            const SizedBox(width: 8),
            Text(
              '· $stepLabel',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: EnglishLessonTheme.textSecondary(b),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Session top bar: close, segmented progress, XP.
class EnglishSessionHeader extends StatelessWidget {
  const EnglishSessionHeader({
    super.key,
    required this.progress,
    required this.xp,
    required this.current,
    required this.total,
    this.onClose,
  });

  final double progress;
  final int xp;
  final int current;
  final int total;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final Brightness b = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: onClose ?? () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: StudyColors.border(b),
                    color: StudyColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Step $current of $total',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: EnglishLessonTheme.textSecondary(b),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: StudyColors.accentTint(b),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.bolt_rounded, size: 16, color: StudyColors.accent),
                const SizedBox(width: 4),
                Text(
                  '$xp',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: StudyColors.accentDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Easy / Medium / Challenge badge for the current step.
class EnglishDifficultyChip extends StatelessWidget {
  const EnglishDifficultyChip({super.key, required this.level});

  final EnglishActivityDifficulty level;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (level) {
      EnglishActivityDifficulty.easy => StudyColors.success,
      EnglishActivityDifficulty.medium => StudyColors.primary,
      EnglishActivityDifficulty.hard => StudyColors.accent,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        level.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
