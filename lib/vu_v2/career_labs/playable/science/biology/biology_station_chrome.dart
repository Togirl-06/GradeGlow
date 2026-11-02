import 'package:flutter/material.dart';

import '../shared/science_lab_theme.dart';

/// Compact station chrome for Biology labs (ScienceLabTheme-based).
class BiologyStationScaffold extends StatelessWidget {
  const BiologyStationScaffold({
    super.key,
    required this.title,
    required this.brief,
    required this.child,
    this.footer,
    this.badgeLabel = 'BIOLOGY',
  });

  final String title;
  final String brief;
  final Widget child;
  final Widget? footer;
  final String badgeLabel;

  static const ScienceLabTheme theme = ScienceLabTheme.biology;

  @override
  Widget build(BuildContext context) {
    final ScienceLabTheme t = theme;
    return Scaffold(
      backgroundColor: t.bg,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: t.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: t.accent.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        color: t.accent,
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

Widget bioPrimaryButton({
  required String label,
  required VoidCallback? onPressed,
}) {
  const ScienceLabTheme t = ScienceLabTheme.biology;
  return SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: t.accent,
        foregroundColor: Colors.black,
        disabledBackgroundColor: t.accent.withValues(alpha: 0.25),
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

Widget bioPanel({required Widget child}) {
  const ScienceLabTheme t = ScienceLabTheme.biology;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: t.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: t.accent.withValues(alpha: 0.28)),
    ),
    child: child,
  );
}

Future<void> showBioResult({
  required BuildContext context,
  required bool passed,
  required String title,
  required String body,
}) {
  const ScienceLabTheme t = ScienceLabTheme.biology;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return AlertDialog(
        backgroundColor: t.surface,
        title: Text(
          title,
          style: TextStyle(color: t.accent, fontWeight: FontWeight.w900),
        ),
        content: Text(
          body,
          style: const TextStyle(color: Colors.white, height: 1.45),
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: t.accent,
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
