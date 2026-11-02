import 'package:flutter/material.dart';

import '../theme/study_theme.dart';

class StudyBottomNav extends StatelessWidget {
  const StudyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const List<_NavTab> _tabs = <_NavTab>[
    _NavTab(icon: Icons.home_rounded, label: 'Home'),
    _NavTab(icon: Icons.insights_rounded, label: 'Progress'),
    _NavTab(icon: Icons.checklist_rounded, label: 'Planner'),
    _NavTab(icon: Icons.smart_toy_outlined, label: 'Tutor'),
    _NavTab(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color barColor = StudyColors.surface(brightness);
    final Color border = StudyColors.border(brightness);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: barColor,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List<Widget>.generate(_tabs.length, (int index) {
              final _NavTab tab = _tabs[index];
              return _NavItem(
                icon: tab.icon,
                label: tab.label,
                selected: currentIndex == index,
                onTap: () => onChanged(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color unselectedColor = StudyColors.textSecondary(brightness);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? StudyColors.primaryTint(brightness)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: selected ? StudyColors.primary : unselectedColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? StudyColors.primary : unselectedColor,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
