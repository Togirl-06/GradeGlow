import 'package:flutter/material.dart';

/// End-of-lesson report after an AI Professor video lecture.
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
    this.nextLessonTitle,
    this.onContinue,
    this.onQuiz,
    this.onNextLesson,
  });

  final String topicTitle;
  final List<String> learned;
  final String homework;
  final int timeSpentSeconds;
  final int checksCorrect;
  final int checksTotal;
  final int questionsAsked;
  final List<String> weakAreas;
  final String? nextLessonTitle;
  final VoidCallback? onContinue;
  final VoidCallback? onQuiz;
  final VoidCallback? onNextLesson;

  String get _timeLabel {
    final int m = timeSpentSeconds ~/ 60;
    final int s = timeSpentSeconds % 60;
    if (m <= 0) return '${s}s';
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  String get _quizLabel {
    if (checksTotal <= 0) return 'No in-lesson checks';
    final int pct = ((checksCorrect / checksTotal) * 100).round();
    return '$checksCorrect / $checksTotal · $pct%';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text(
        'Private professor session complete',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                topicTitle,
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 14),
              _StatRow(label: 'Time studied', value: _timeLabel),
              _StatRow(label: 'Understanding checks', value: _quizLabel),
              _StatRow(label: 'Questions asked', value: '$questionsAsked'),
              const SizedBox(height: 12),
              if (learned.isNotEmpty) ...<Widget>[
                Text(
                  'Topics mastered',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                ...learned.take(5).map((String s) => Text('• $s')),
                const SizedBox(height: 12),
              ],
              if (weakAreas.isNotEmpty) ...<Widget>[
                Text(
                  'Needs improvement',
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                ...weakAreas.toSet().take(4).map((String s) => Text('• $s')),
                const SizedBox(height: 12),
              ],
              if (homework.trim().isNotEmpty) ...<Widget>[
                Text(
                  'Homework',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(homework, style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 12),
              ],
              if (nextLessonTitle != null) ...<Widget>[
                Text(
                  'Recommended next',
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
      actions: <Widget>[
        if (onQuiz != null)
          TextButton(
            onPressed: onQuiz,
            child: const Text('Take quiz'),
          ),
        if (onNextLesson != null)
          TextButton(
            onPressed: onNextLesson,
            child: const Text('Next lesson'),
          ),
        FilledButton(
          onPressed: onContinue ?? () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
