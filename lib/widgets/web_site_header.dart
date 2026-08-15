import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import 'gradeglow_logo.dart';

class WebSiteHeader extends StatelessWidget {
  const WebSiteHeader({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const List<_WebNavItem> _items = <_WebNavItem>[
    _WebNavItem(label: 'Home', index: 0),
    _WebNavItem(label: 'Progress', index: 1),
    _WebNavItem(label: 'Planner', index: 2),
    _WebNavItem(label: 'Tutor', index: 3),
    _WebNavItem(label: 'Profile', index: 4),
  ];

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color border = StudyColors.border(brightness);
    final Color textSecondary = StudyColors.textSecondary(brightness);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: border.withValues(alpha: 0.65)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
            child: Row(
              children: <Widget>[
                const GradeGlowBrandRow(logoSize: 30),
                const Spacer(),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
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
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WebNavItem {
  const _WebNavItem({required this.label, required this.index});

  final String label;
  final int index;
}
