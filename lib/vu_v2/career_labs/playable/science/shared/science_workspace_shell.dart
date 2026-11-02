import 'package:flutter/material.dart';

import 'science_lab_theme.dart';

/// Light instrument workspace (matches the mockup activity screens).
class ScienceWorkspaceShell extends StatelessWidget {
  const ScienceWorkspaceShell({
    super.key,
    required this.theme,
    required this.crumbs,
    required this.body,
    this.tools,
    this.footer,
    this.dark = false,
  });

  final ScienceLabTheme theme;
  final List<String> crumbs;
  final Widget body;
  final Widget? tools;
  final Widget? footer;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color bg = dark ? const Color(0xFF0B1020) : const Color(0xFFE8EEF5);
    final Color bar = dark ? const Color(0xFF121A2A) : Colors.white;
    final Color ink = dark ? Colors.white : const Color(0xFF0F172A);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: bar,
                border: Border(
                  bottom: BorderSide(color: theme.accent.withValues(alpha: 0.35)),
                ),
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: Icon(Icons.arrow_back, color: ink),
                  ),
                  Expanded(
                    child: Text(
                      crumbs.join('  ›  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ink.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(Icons.help_outline, color: theme.accent, size: 20),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  return SizedBox(
                    width: c.maxWidth,
                    height: c.maxHeight,
                    child: body,
                  );
                },
              ),
            ),
            if (tools != null)
              Container(
                color: bar,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: tools,
              ),
            if (footer != null)
              Container(
                color: bar,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

class ScienceSideCard extends StatelessWidget {
  const ScienceSideCard({
    super.key,
    required this.title,
    required this.child,
    this.accent = const Color(0xFF38BDF8),
    this.dark = false,
  });

  final String title;
  final Widget child;
  final Color accent;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF151C2C) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(
                color: dark ? Colors.white70 : const Color(0xFF0F172A),
                fontSize: 13,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
