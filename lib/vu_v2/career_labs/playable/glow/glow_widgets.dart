import 'package:flutter/material.dart';

/// Shared dark "game" palette for every Glow lab (matches the campus cards).
abstract final class GlowColors {
  static const Color bg = Color(0xFF0B1020);
  static const Color surface = Color(0xFF151B2E);
  static const Color surfaceHi = Color(0xFF1E2640);
  static const Color stroke = Color(0xFF2A3354);
  static const Color ink = Color(0xFFF1F5F9);
  static const Color mute = Color(0xFF94A3B8);
  static const Color good = Color(0xFF22C55E);
  static const Color bad = Color(0xFFEF4444);
  static const Color gold = Color(0xFFFBBF24);
}

/// "$1,250" / "-$35". Whole dollars only.
String glowMoney(int value) {
  final String digits = value.abs().toString();
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final int fromEnd = digits.length - i;
    out.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) out.write(',');
  }
  return '${value < 0 ? '-' : ''}\$${out.toString()}';
}

class GlowPanel extends StatelessWidget {
  const GlowPanel({
    super.key,
    required this.child,
    this.accent,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: GlowColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent == null
              ? GlowColors.stroke
              : accent!.withValues(alpha: 0.7),
        ),
      ),
      child: child,
    );
  }
}

class GlowMeter extends StatelessWidget {
  const GlowMeter({
    super.key,
    required this.label,
    required this.valueText,
    required this.fraction,
    required this.color,
  });

  final String label;
  final String valueText;

  /// 0.0 - 1.0
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(color: GlowColors.mute, fontSize: 12),
            ),
            const Spacer(),
            Text(
              valueText,
              style: const TextStyle(
                color: GlowColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0).toDouble(),
            minHeight: 8,
            backgroundColor: GlowColors.surfaceHi,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class GlowButton extends StatelessWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = const Color(0xFFA855F7),
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: GlowColors.surfaceHi,
          disabledForegroundColor: GlowColors.mute,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
    );
  }
}

class GlowStars extends StatelessWidget {
  const GlowStars({super.key, required this.stars, this.size = 22});

  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(3, (int i) {
        final bool on = i < stars;
        return Icon(
          on ? Icons.star_rounded : Icons.star_outline_rounded,
          color: on ? GlowColors.gold : GlowColors.mute,
          size: size,
        );
      }),
    );
  }
}

/// A labelled money slider that moves in fixed steps.
class GlowSliderRow extends StatelessWidget {
  const GlowSliderRow({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.accent,
    required this.onChanged,
  });

  final String emoji;
  final String label;
  final double value;
  final double min;
  final double max;
  final int step;
  final Color accent;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final int divisions = ((max - min) / step).round();
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              '$emoji  $label',
              style: const TextStyle(color: GlowColors.ink, fontSize: 14),
            ),
            const Spacer(),
            Text(
              glowMoney(value.round()),
              style: TextStyle(
                color: accent,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: accent,
            thumbColor: accent,
            inactiveTrackColor: GlowColors.surfaceHi,
            overlayColor: accent.withValues(alpha: 0.18),
          ),
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            divisions: divisions < 1 ? null : divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
