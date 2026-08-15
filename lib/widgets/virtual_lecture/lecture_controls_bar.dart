import 'package:flutter/material.dart';

import '../../theme/mathematics_degree_theme.dart';
import '../../theme/study_theme.dart';

/// Classroom interaction bar matching the AI Professor teaching flow.
class LectureControlsBar extends StatelessWidget {
  const LectureControlsBar({
    super.key,
    required this.playing,
    required this.speedLabel,
    required this.onPlayPause,
    required this.onRestart,
    required this.onSpeed,
    required this.onNotes,
    required this.onRaiseHand,
    this.onConfused,
    this.onQuiz,
    this.onSummary,
    this.onPrevious,
    this.onForward,
    this.canPrevious = false,
    this.canForward = false,
  });

  final bool playing;
  final String speedLabel;
  final VoidCallback onPlayPause;
  final VoidCallback onRestart;
  final VoidCallback onSpeed;
  final VoidCallback onNotes;
  final VoidCallback onRaiseHand;
  final VoidCallback? onConfused;
  final VoidCallback? onQuiz;
  final VoidCallback? onSummary;
  final VoidCallback? onPrevious;
  final VoidCallback? onForward;
  final bool canPrevious;
  final bool canForward;

  @override
  Widget build(BuildContext context) {
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);
    final Color accent = StudyColors.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onConfused,
                    icon: const Icon(Icons.help_outline_rounded, size: 18),
                    label: const Text("I'm Confused"),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onRaiseHand,
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('Ask Question'),
                    style: FilledButton.styleFrom(
                      backgroundColor: accent.withValues(alpha: 0.85),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: accent,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onRaiseHand,
                    child: const SizedBox(
                      width: 52,
                      height: 52,
                      child: Icon(Icons.mic_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPlayPause,
                    icon: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 18,
                    ),
                    label: Text(playing ? 'Pause Lesson' : 'Resume Lesson'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onSummary ?? onNotes,
                    icon: const Icon(Icons.summarize_outlined, size: 18),
                    label: const Text('Lesson Summary'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _Mini(icon: Icons.replay_rounded, label: 'Restart', onTap: onRestart),
                _Mini(
                  icon: Icons.skip_previous_rounded,
                  label: 'Back',
                  onTap: onPrevious,
                  enabled: canPrevious,
                ),
                _Mini(
                  icon: Icons.skip_next_rounded,
                  label: 'Next',
                  onTap: onForward,
                  enabled: canForward,
                ),
                _Mini(icon: Icons.speed_rounded, label: speedLabel, onTap: onSpeed),
                if (onQuiz != null)
                  _Mini(icon: Icons.quiz_outlined, label: 'Practice', onTap: onQuiz),
                _Mini(icon: Icons.note_alt_outlined, label: 'Notes', onTap: onNotes),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);
    final bool active = enabled && onTap != null;
    return InkWell(
      onTap: active ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: active ? c.primary : c.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: active ? c.textSecondary : c.textSecondary.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
