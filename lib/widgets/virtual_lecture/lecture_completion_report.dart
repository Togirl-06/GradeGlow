import 'package:flutter/material.dart';

/// End-of-class dashboard after an AI Professor lecture.
class LectureCompletionReport extends StatelessWidget {
  const LectureCompletionReport({
    super.key,
    required this.topicTitle,
    required this.learned,
    required this.homework,
    required this.timeSpentSeconds,
    required this.checksCorrect,
    required this.checksTotal,
    required this.questionsAsked,
    required this.weakAreas,
    this.adaptiveReviewSegments = 0,
    this.courseTitle,
    this.courseCode,
    this.professorLabel = 'AI Professor',
    this.masteryPercent,
    this.nextLessonTitle,
    this.onContinue,
    this.onQuiz,
    this.onNextLesson,
    this.onLab,
    this.labTitle,
    this.clinicalCaseTitle,
    this.onFixMisconceptions,
    this.preferLabCta = false,
  });

  final String topicTitle;
  final List<String> learned;
  final String homework;
  final int timeSpentSeconds;
  final int checksCorrect;
  final int checksTotal;
  final int questionsAsked;
  final List<String> weakAreas;
  final int adaptiveReviewSegments;
  final String? courseTitle;
  final String? courseCode;
  final String professorLabel;
  final int? masteryPercent;
  final String? nextLessonTitle;
  final VoidCallback? onContinue;
  final VoidCallback? onQuiz;
  final VoidCallback? onNextLesson;
  final VoidCallback? onLab;
  final String? labTitle;
  final String? clinicalCaseTitle;
  final VoidCallback? onFixMisconceptions;
  final bool preferLabCta;

  String get _courseHeader {
    final String? code = courseCode?.trim();
    if (code != null && code.isNotEmpty) return code.toUpperCase();
    final String? title = courseTitle?.trim();
    if (title != null && title.isNotEmpty) return title.toUpperCase();
    return 'LECTURE COMPLETE';
  }

  int get _mastery {
    if (masteryPercent != null) return masteryPercent!.clamp(0, 100);
    if (checksTotal <= 0) return 70;
    final int fromChecks =
        ((checksCorrect / checksTotal) * 100).round().clamp(0, 100);
    // Soft blend: checks dominate, small floor for finishing the lecture.
    return ((fromChecks * 0.85) + 15).round().clamp(0, 100);
  }

  String get _checkLabel {
    if (checksTotal <= 0) return '—';
    return '$checksCorrect/$checksTotal';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(
        _courseHeader,
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.4),
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Today\'s Lecture: $topicTitle',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Professor: $professorLabel',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              if (onLab != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  'You\'ve learned the structure. Now let\'s see whether you can use it.',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _StatusRow(
                label: 'Lecture',
                value: 'Complete',
                valueIcon: Icons.check_circle_rounded,
                valueColor: const Color(0xFF1B7F4E),
              ),
              _StatusRow(
                label: 'Knowledge Check',
                value: _checkLabel,
              ),
              _StatusRow(
                label: 'Practical Lab',
                value: onLab != null ? 'Ready' : 'Next',
                valueIcon: onLab != null
                    ? Icons.science_outlined
                    : Icons.lock_outline_rounded,
                valueColor: onLab != null ? const Color(0xFF1B7F4E) : null,
                muted: onLab == null,
                subtitle: labTitle,
              ),
              _StatusRow(
                label: 'Clinical Case',
                value: clinicalCaseTitle != null ? 'Ready' : 'Next',
                valueIcon: clinicalCaseTitle != null
                    ? Icons.medical_services_outlined
                    : Icons.lock_outline_rounded,
                valueColor:
                    clinicalCaseTitle != null ? const Color(0xFF1B7F4E) : null,
                muted: clinicalCaseTitle == null,
                subtitle: clinicalCaseTitle,
              ),
              _StatusRow(
                label: 'Mastery',
                value: '$_mastery%',
                valueColor: scheme.primary,
              ),
              if (adaptiveReviewSegments > 0)
                _StatusRow(
                  label: 'Adaptive review',
                  value: '$adaptiveReviewSegments segment${adaptiveReviewSegments == 1 ? '' : 's'}',
                  valueIcon: Icons.replay_circle_filled_outlined,
                  valueColor: const Color(0xFF0F766E),
                ),
              if (weakAreas.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  'Review focus',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  weakAreas.take(4).join(' · '),
                  style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
                ),
              ],
              if (learned.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                Text(
                  'Three takeaways',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                ...learned.take(3).map((String s) => Text('• $s')),
              ],
              if (nextLessonTitle != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  'Next class',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(nextLessonTitle!),
              ],
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: <Widget>[
        if (onFixMisconceptions != null &&
            (weakAreas.isNotEmpty || adaptiveReviewSegments > 0))
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onFixMisconceptions!();
            },
            icon: const Icon(Icons.psychology_alt_outlined, size: 18),
            label: const Text('Fix misconceptions'),
          ),
        if (onQuiz != null)
          TextButton(
            onPressed: onQuiz,
            child: const Text('Knowledge quiz'),
          ),
        if (onNextLesson != null)
          TextButton(
            onPressed: onNextLesson,
            child: const Text('Next lesson'),
          ),
        TextButton(
          onPressed: onContinue ?? () => Navigator.of(context).pop(),
          child: Text(preferLabCta ? 'Campus' : 'Back to dashboard'),
        ),
        if (onLab != null)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onLab!();
            },
            icon: Icon(
              preferLabCta
                  ? Icons.medical_services_outlined
                  : Icons.science_outlined,
              size: 18,
            ),
            label: Text(
              preferLabCta ? 'ENTER CLINICAL VIVA' : 'ENTER LAB',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    this.valueIcon,
    this.valueColor,
    this.muted = false,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData? valueIcon;
  final Color? valueColor;
  final bool muted;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final Color ink = muted
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : (valueColor ?? Theme.of(context).colorScheme.onSurface);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (valueIcon != null) ...<Widget>[
                Icon(valueIcon, size: 16, color: ink),
                const SizedBox(width: 4),
              ],
              Text(
                muted ? '🔒 $value' : value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
            ],
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
