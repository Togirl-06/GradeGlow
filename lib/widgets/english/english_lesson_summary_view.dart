import 'package:flutter/material.dart';

import '../../models/english_lesson.dart';
import '../../theme/study_theme.dart';
import '../study_surface.dart';

class EnglishLessonSummaryView extends StatelessWidget {
  const EnglishLessonSummaryView({
    super.key,
    required this.result,
    required this.lessonTitle,
    required this.onDone,
    this.onRetry,
  });

  final EnglishLessonResult result;
  final String lessonTitle;
  final VoidCallback onDone;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        StudySurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Icon(
                result.perfectLesson ? Icons.emoji_events_rounded : Icons.task_alt_rounded,
                size: 48,
                color: result.perfectLesson ? StudyColors.accent : StudyColors.success,
              ),
              const SizedBox(height: 10),
              Text(
                'Session complete',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                lessonTitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.bolt_rounded, color: StudyColors.accent, size: 28),
                  const SizedBox(width: 6),
                  Text(
                    '+${result.xpEarned} XP',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: StudyColors.accentDark,
                        ),
                  ),
                ],
              ),
              if (result.bonusXp > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Includes +${result.bonusXp} bonus',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StudySurfaceCard(
          child: Column(
            children: <Widget>[
              _Row(label: 'Accuracy', value: '${(result.accuracy * 100).round()}%'),
              _Row(label: 'Mistakes', value: '${result.mistakes.length}'),
              _Row(label: 'Best streak', value: '${result.maxStreak}'),
              _Row(
                label: 'Grammar',
                value: result.grammarMastered ? 'Mastered' : 'Review soon',
              ),
            ],
          ),
        ),
        if (result.wordsLearned.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          StudySurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Words practiced',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: result.wordsLearned
                      .take(8)
                      .map(
                        (String w) => Chip(
                          label: Text(w),
                          backgroundColor: StudyColors.primaryTint(brightness),
                          labelStyle: TextStyle(color: StudyColors.primary),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
        if (result.reviewTopics.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          StudySurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Review next',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                ...result.reviewTopics.map(
                  (String t) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.refresh_rounded, size: 18, color: textSecondary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(t)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        StudySurfaceCard(
          child: Row(
            children: <Widget>[
              Icon(Icons.arrow_forward_rounded, color: StudyColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Next: ${result.nextSkill}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: onDone,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Back to English'),
        ),
        if (onRetry != null) ...<Widget>[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Practice again'),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary =
        StudyColors.textSecondary(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Text(label, style: TextStyle(color: textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
