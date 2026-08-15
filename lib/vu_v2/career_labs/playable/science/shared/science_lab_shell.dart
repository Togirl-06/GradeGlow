import 'package:flutter/material.dart';

import 'science_lab_theme.dart';

/// Shared chrome for individual science station screens.
class ScienceLabShell extends StatelessWidget {
  const ScienceLabShell({
    super.key,
    required this.theme,
    required this.title,
    required this.brief,
    required this.child,
    this.footer,
    this.badgeLabel = 'LAB',
  });

  final ScienceLabTheme theme;
  final String title;
  final String brief;
  final Widget child;
  final Widget? footer;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          brief,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.62),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.accent.withValues(alpha: 0.45)),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        color: theme.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
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
    );
  }
}

Widget sciencePrimaryButton({
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
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          fontSize: 14,
        ),
      ),
    ),
  );
}

Widget sciencePanel({
  required Color surface,
  required Color accent,
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(14),
}) {
  return Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: accent.withValues(alpha: 0.28)),
    ),
    child: child,
  );
}

Future<void> showScienceResult({
  required BuildContext context,
  required ScienceLabTheme theme,
  required bool passed,
  required String title,
  required String body,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          title,
          style: TextStyle(color: theme.accent, fontWeight: FontWeight.w900),
        ),
        content: Text(body, style: const TextStyle(color: Colors.white, height: 1.45)),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: theme.accent,
              foregroundColor: Colors.black,
            ),
            child: Text(
              passed ? 'CONTINUE' : 'KEEP GOING',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      );
    },
  );
}
