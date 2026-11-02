import 'package:flutter/material.dart';

import '../models/todo_item.dart';
import '../theme/study_theme.dart';
import '../utils/todo_day.dart';

class TodoTimelineRow extends StatelessWidget {
  const TodoTimelineRow({
    super.key,
    required this.item,
    required this.dotColor,
    required this.isFirst,
    required this.isLast,
    required this.onToggle,
  });

  final TodoItem item;
  final Color dotColor;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onToggle;

  static final List<Color> _palette = <Color>[
    StudyColors.success,
    StudyColors.primary,
    Color(0xFFEC4899),
  ];

  static Color dotColorForIndex(int index) => _palette[index % _palette.length];

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              width: 28,
              child: Column(
                children: <Widget>[
                  if (!isFirst)
                    Expanded(
                      child: CustomPaint(
                        painter: _DashedLinePainter(color: StudyColors.border(brightness)),
                      ),
                    ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                  ),
                  if (!isLast)
                    Expanded(
                      child: CustomPaint(
                        painter: _DashedLinePainter(color: StudyColors.border(brightness)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        decoration: item.completed ? TextDecoration.lineThrough : null,
                        color: item.completed ? textSecondary : StudyColors.textPrimary(brightness),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${formatTodoTime(item.scheduledAt)} · ${item.activityType}',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.completed ? StudyColors.primary : Colors.transparent,
                  border: Border.all(
                    color: item.completed ? StudyColors.primary : StudyColors.border(brightness),
                    width: 2,
                  ),
                ),
                child: item.completed
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double dash = 4;
    const double gap = 4;
    double y = 0;
    while (y < size.height) {
      final double end = (y + dash).clamp(0, size.height);
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, end), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => oldDelegate.color != color;
}
