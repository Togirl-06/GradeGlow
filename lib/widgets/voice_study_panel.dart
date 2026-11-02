import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import 'study_surface.dart';
import 'voice_note_recorder_bar.dart';

/// Hands-free status panel for verbal study modes (flashcards, quiz):
/// shows a speaking / listening indicator, a live transcript, and the
/// recognized spoken answer.
class VoiceStudyPanel extends StatelessWidget {
  const VoiceStudyPanel({
    super.key,
    required this.speaking,
    required this.listening,
    required this.level,
    required this.partial,
    required this.heardAnswer,
    required this.onStopListening,
    required this.onReplay,
  });

  final bool speaking;
  final bool listening;
  final double level;
  final String partial;
  final String heardAnswer;
  final VoidCallback onStopListening;

  /// Re-runs the question → listen → answer cycle. Null while busy.
  final VoidCallback? onReplay;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final String status = speaking
        ? 'Speaking…'
        : listening
            ? 'Listening — say your answer'
            : 'Hands-free mode';

    return StudySurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                speaking ? Icons.volume_up_rounded : Icons.mic_rounded,
                size: 18,
                color: StudyColors.primary,
              ),
              const SizedBox(width: 8),
              Text(status, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (listening)
                TextButton(onPressed: onStopListening, child: const Text('Done'))
              else if (onReplay != null)
                TextButton(onPressed: onReplay, child: const Text('Repeat')),
            ],
          ),
          if (listening) ...<Widget>[
            const SizedBox(height: 8),
            VoiceNoteWaveform(level: level.clamp(0.1, 1.0), barCount: 24, height: 32),
          ],
          if (partial.trim().isNotEmpty && listening) ...<Widget>[
            const SizedBox(height: 8),
            Text(partial, style: TextStyle(color: textSecondary, height: 1.35)),
          ],
          if (!listening && heardAnswer.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text('You said:', style: TextStyle(color: textSecondary, fontSize: 12)),
            const SizedBox(height: 2),
            Text(heardAnswer, style: const TextStyle(fontSize: 15, height: 1.35)),
          ],
        ],
      ),
    );
  }
}
