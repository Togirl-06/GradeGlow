import 'package:flutter/material.dart';

import '../theme/study_theme.dart';

/// Minimal bar chart for progress trends (no extra chart package).
class SimpleTrendChart extends StatelessWidget {
  const SimpleTrendChart({
    super.key,
    required this.values,
    required this.labels,
    this.valueSuffix = '',
    this.barColor,
    this.maxValue,
  });

  final List<double> values;
  final List<String> labels;
  final String valueSuffix;
  final Color? barColor;
  final double? maxValue;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color effectiveBarColor = barColor ?? StudyColors.primary;
    final double max = maxValue ?? values.fold<double>(0, (double a, double v) => v > a ? v : a);
    final double top = max <= 0 ? 1 : max * 1.15;

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List<Widget>.generate(values.length, (int i) {
          final double v = values[i];
          final double fraction = (v / top).clamp(0.05, 1.0);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 4, right: i == values.length - 1 ? 0 : 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (v > 0)
                    Text(
                      '${v == v.roundToDouble() ? v.round() : v.toStringAsFixed(1)}$valueSuffix',
                      style: TextStyle(fontSize: 9, color: StudyColors.textSecondary(brightness)),
                    ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: fraction,
                        widthFactor: 0.65,
                        child: Container(
                          decoration: BoxDecoration(
                            color: effectiveBarColor.withValues(alpha: 0.85),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels.length > i ? labels[i] : '',
                    style: TextStyle(fontSize: 9, color: StudyColors.textSecondary(brightness)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
