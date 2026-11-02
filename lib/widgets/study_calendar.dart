import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/study_theme.dart';

/// A compact, theme-aware month calendar used by the study planner.
///
/// It is intentionally dependency-free: the parent owns the focused month and
/// selected day, supplies event marker colors per day, and reacts to taps.
class StudyMonthCalendar extends StatelessWidget {
  const StudyMonthCalendar({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.onSelectDay,
    required this.onFocusMonthChanged,
    required this.markerColors,
    this.today,
  });

  /// Any day inside the month that is currently shown.
  final DateTime focusedMonth;

  /// The day whose agenda is displayed below the grid.
  final DateTime selectedDay;

  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<DateTime> onFocusMonthChanged;

  /// Up to three marker colors drawn as dots under a given day.
  final List<Color> Function(DateTime day) markerColors;

  final DateTime? today;

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _monthStep(int months) {
    return DateTime(focusedMonth.year, focusedMonth.month + months, 1);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textPrimary = StudyColors.textPrimary(brightness);
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final Color primary = StudyColors.primary;
    final Color surface = Theme.of(context).colorScheme.surfaceContainer;
    final DateTime now = today ?? DateTime.now();

    final DateTime firstOfMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month,
      1,
    );
    // Sunday-first grid. DateTime.weekday: Mon=1..Sun=7 -> Sun=0..Sat=6.
    final int leadingBlanks = firstOfMonth.weekday % 7;
    final int daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;
    final int totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    DateFormat('MMMM yyyy').format(firstOfMonth),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            _CalendarControl(
              tooltip: 'Today',
              icon: Icons.calendar_today_rounded,
              color: primary,
              background: primary.withValues(alpha: 0.12),
              onPressed: () {
                onFocusMonthChanged(DateTime(now.year, now.month, 1));
                onSelectDay(DateTime(now.year, now.month, now.day));
              },
            ),
            const SizedBox(width: 6),
            _CalendarControl(
              tooltip: 'Previous month',
              icon: Icons.chevron_left_rounded,
              color: textSecondary,
              background: surface,
              onPressed: () => onFocusMonthChanged(_monthStep(-1)),
            ),
            const SizedBox(width: 6),
            _CalendarControl(
              tooltip: 'Next month',
              icon: Icons.chevron_right_rounded,
              color: textSecondary,
              background: surface,
              onPressed: () => onFocusMonthChanged(_monthStep(1)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <String>['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (String label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            mainAxisExtent: 32,
          ),
          itemBuilder: (BuildContext context, int index) {
            final int dayNum = index - leadingBlanks + 1;
            if (dayNum < 1 || dayNum > daysInMonth) {
              return const SizedBox.shrink();
            }
            final DateTime day = DateTime(
              focusedMonth.year,
              focusedMonth.month,
              dayNum,
            );
            final bool isSelected = _sameDay(day, selectedDay);
            final bool isToday = _sameDay(day, now);
            final List<Color> markers = markerColors(day);

            return _DayCell(
              day: day,
              isSelected: isSelected,
              isToday: isToday,
              markers: markers,
              primary: primary,
              surface: surface,
              textPrimary: textPrimary,
              onTap: () => onSelectDay(day),
            );
          },
        ),
      ],
        ),
      ),
    );
  }
}

class _CalendarControl extends StatelessWidget {
  const _CalendarControl({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.background,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(icon, color: color, size: 16),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.markers,
    required this.primary,
    required this.surface,
    required this.textPrimary,
    required this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final List<Color> markers;
  final Color primary;
  final Color surface;
  final Color textPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = isSelected
        ? primary
        : (isToday ? primary.withValues(alpha: 0.12) : Colors.transparent);
    final Color numberColor = isSelected
        ? Colors.white
        : (isToday ? primary : textPrimary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: markers.isNotEmpty && !isSelected && !isToday
                ? surface.withValues(alpha: 0.72)
                : background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${day.day}',
                style: TextStyle(
                  color: numberColor,
                  fontSize: 12,
                  height: 1,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w900
                      : FontWeight.w600,
                ),
              ),
              if (markers.isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: markers
                      .take(3)
                      .map(
                        (Color color) => Container(
                          width: 3.5,
                          height: 3.5,
                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
