import 'package:flutter/material.dart';

/// Mockup lecture controls: I'm confused · Ask · Raise hand · Pause · Full slide notes.
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
    this.onResources,
    this.onAudio,
    this.canPrevious = false,
    this.canForward = false,
    this.slideLabel,
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
  final VoidCallback? onResources;
  final VoidCallback? onAudio;
  final bool canPrevious;
  final bool canForward;
  final String? slideLabel;

  static const Color _navy = Color(0xFF0B1220);
  static const Color _teal = Color(0xFF0F766E);
  static const Color _mustard = Color(0xFFD4A017);
  static const Color _panel = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _PillButton(
                    label: "I'm confused",
                    icon: Icons.help_outline_rounded,
                    background: const Color(0xFF1F2937),
                    foreground: Colors.white,
                    onTap: onConfused,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PillButton(
                    label: 'Ask a question',
                    icon: Icons.chat_bubble_outline_rounded,
                    background: _teal,
                    foreground: Colors.white,
                    onTap: onRaiseHand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _PillButton(
                    label: playing ? 'Pause lesson' : 'Resume lesson',
                    icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    background: _navy,
                    foreground: Colors.white,
                    onTap: onPlayPause,
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PillButton(
                    label: 'Full slide notes',
                    icon: Icons.notes_rounded,
                    background: _mustard,
                    foreground: const Color(0xFF1C1917),
                    onTap: onNotes,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: onRestart,
                  child: const Text('Restart', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: canPrevious ? onPrevious : null,
                  child: const Text('Back', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: onSpeed,
                  child: Text(speedLabel, style: const TextStyle(color: Color(0xFF2DD4BF))),
                ),
                TextButton(
                  onPressed: canForward ? onForward : null,
                  child: const Text('Next', style: TextStyle(color: Colors.white70)),
                ),
                if (onQuiz != null)
                  TextButton(
                    onPressed: onQuiz,
                    child: const Text('Practice', style: TextStyle(color: Colors.white54)),
                  ),
                if (onSummary != null)
                  TextButton(
                    onPressed: onSummary,
                    child: const Text('Summary', style: TextStyle(color: Colors.white54)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? Colors.transparent : background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: outlined ? Border.all(color: Colors.white24) : null,
            color: outlined ? background.withValues(alpha: 0.55) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
