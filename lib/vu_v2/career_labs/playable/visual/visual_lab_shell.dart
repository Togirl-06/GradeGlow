import 'package:flutter/material.dart';

import '../shared/playable_cinematic.dart';
import 'visual_lab_models.dart';

/// Shared chrome for all visual lab screens.
class VisualLabShell extends StatelessWidget {
  const VisualLabShell({
    super.key,
    required this.spec,
    required this.child,
    this.footer,
    this.badgeLabel = 'VISUAL LAB',
  });

  final VisualLabSpec spec;
  final Widget child;
  final Widget? footer;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: spec.bg,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PlayableSceneBackdrop(
            accent: spec.accent,
            bg: spec.bg,
            surface: spec.surface,
            roomId: spec.id,
            intensity: 0.85,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              spec.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              spec.brief,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PlayableLiveBadge(accent: spec.accent, label: badgeLabel),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: child),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: footer!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget visualPrimaryButton({
  required Color accent,
  required String label,
  required VoidCallback? onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.black,
        disabledBackgroundColor: accent.withValues(alpha: 0.25),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          fontSize: 14,
        ),
      ),
    ),
  );
}

Future<void> showVisualLabResult({
  required BuildContext context,
  required VisualLabSpec spec,
  required bool passed,
  required String body,
}) {
  return showPlayableCinematic(
    context: context,
    accent: spec.accent,
    bg: spec.bg,
    surface: spec.surface,
    eyebrow: passed ? 'Lab complete' : 'Try again',
    title: passed ? 'Nice work.' : 'Not quite.',
    body: body,
    cta: passed ? 'CONTINUE' : 'KEEP GOING',
  );
}

bool keywordsMatch(String text, List<String> keywords, {int minHits = 1}) {
  final String lower = text.toLowerCase();
  int hits = 0;
  for (final String k in keywords) {
    if (lower.contains(k.toLowerCase())) hits++;
  }
  return hits >= minHits;
}
