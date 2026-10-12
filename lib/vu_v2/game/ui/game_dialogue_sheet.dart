import 'package:flutter/material.dart';

import '../services/vu_game_ai_dialogue.dart';

class GameDialogueSheet extends StatelessWidget {
  const GameDialogueSheet({
    super.key,
    required this.node,
    required this.accent,
    required this.onChoice,
    required this.onClose,
  });

  final VuGameDialogueNodeData node;
  final Color accent;
  final void Function(VuGameDialogueChoiceData choice) onChoice;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0E1628),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                node.speaker.toUpperCase(),
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                node.text,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.45,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              if (node.choices.isEmpty)
                FilledButton(
                  onPressed: onClose,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
                )
              else
                ...node.choices.map(
                  (VuGameDialogueChoiceData c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      onPressed: () => onChoice(c),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: accent.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(c.label, style: const TextStyle(fontWeight: FontWeight.w600)),
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
