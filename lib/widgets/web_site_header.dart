import 'package:flutter/material.dart';

import '../config/app_branding.dart';
import '../theme/study_theme.dart';
import 'gradeglow_logo.dart';

/// Shared max content width for GradeGlow web pages.
abstract final class WebSiteLayout {
  static const double maxWidth = 1120;
  static const double wideMaxWidth = 1280;

  static Widget constrained({
    required Widget child,
    double maxWidth = WebSiteLayout.maxWidth,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 28),
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Sticky top navigation for the public marketing site.
class WebMarketingHeader extends StatelessWidget {
  const WebMarketingHeader({
    super.key,
    this.onHome,
    this.onSchools,
    this.onHowItWorks,
    this.onSignIn,
    this.onGetStarted,
  });

  final VoidCallback? onHome;
  final VoidCallback? onSchools;
  final VoidCallback? onHowItWorks;
  final VoidCallback? onSignIn;
  final VoidCallback? onGetStarted;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color border = StudyColors.border(brightness);
    final Color muted = StudyColors.textSecondary(brightness);
    final bool narrow = MediaQuery.sizeOf(context).width < 820;

    return Material(
      color: StudyColors.surface(brightness).withValues(alpha: 0.96),
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: border.withValues(alpha: 0.55)),
          ),
        ),
        child: WebSiteLayout.constrained(
          maxWidth: WebSiteLayout.wideMaxWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: onHome,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: GradeGlowBrandRow(logoSize: 34),
                  ),
                ),
                const Spacer(),
                if (!narrow) ...<Widget>[
                  _NavLink(label: 'Schools', onTap: onSchools, color: muted),
                  _NavLink(
                    label: 'How it works',
                    onTap: onHowItWorks,
                    color: muted,
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton(
                  onPressed: onSignIn,
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: muted,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                FilledButton(
                  onPressed: onGetStarted ?? onSignIn,
                  style: FilledButton.styleFrom(
                    backgroundColor: StudyColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Authenticated web app navigation — site-style top bar (not mobile tabs).
class WebSiteHeader extends StatelessWidget {
  const WebSiteHeader({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    this.onOpenCampus,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback? onOpenCampus;

  static const List<_WebNavItem> _items = <_WebNavItem>[
    _WebNavItem(label: 'Dashboard', index: 0),
    _WebNavItem(label: 'Progress', index: 1),
    _WebNavItem(label: 'Planner', index: 2),
    _WebNavItem(label: 'AI Tutor', index: 3),
    _WebNavItem(label: 'Account', index: 4),
  ];

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color border = StudyColors.border(brightness);
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final bool narrow = MediaQuery.sizeOf(context).width < 900;

    return Material(
      color: StudyColors.surface(brightness).withValues(alpha: 0.97),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: border.withValues(alpha: 0.55)),
          ),
        ),
        child: WebSiteLayout.constrained(
          maxWidth: WebSiteLayout.wideMaxWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: () => onChanged(0),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: GradeGlowBrandRow(logoSize: 30),
                  ),
                ),
                const Spacer(),
                if (!narrow)
                  Wrap(
                    spacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: _items.map((_WebNavItem item) {
                      final bool selected = currentIndex == item.index;
                      return TextButton(
                        onPressed: () => onChanged(item.index),
                        style: TextButton.styleFrom(
                          foregroundColor: selected
                              ? StudyColors.primary
                              : textSecondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  PopupMenuButton<int>(
                    tooltip: 'Menu',
                    onSelected: onChanged,
                    itemBuilder: (BuildContext context) => _items
                        .map(
                          (_WebNavItem item) => PopupMenuItem<int>(
                            value: item.index,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.menu_rounded, color: textSecondary),
                    ),
                  ),
                if (onOpenCampus != null) ...<Widget>[
                  const SizedBox(width: 10),
                  FilledButton.tonal(
                    onPressed: onOpenCampus,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Campus',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WebSiteFooter extends StatelessWidget {
  const WebSiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color muted = StudyColors.textSecondary(brightness);
    final Color border = StudyColors.border(brightness);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? AppBranding.navy
            : const Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: border.withValues(alpha: 0.5))),
      ),
      child: WebSiteLayout.constrained(
        maxWidth: WebSiteLayout.wideMaxWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 36, 0, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const GradeGlowBrandRow(logoSize: 28),
              const SizedBox(height: 12),
              Text(
                AppBranding.mission,
                style: TextStyle(color: muted, height: 1.45, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Text(
                '© ${DateTime.now().year} ${AppBranding.name}. Affordable education for everyone.',
                style: TextStyle(
                  color: muted.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

class _WebNavItem {
  const _WebNavItem({required this.label, required this.index});

  final String label;
  final int index;
}
