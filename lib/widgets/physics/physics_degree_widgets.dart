import 'package:flutter/material.dart';

import '../../theme/physics_degree_theme.dart';

class PhysDegreeProgressRing extends StatelessWidget {
  const PhysDegreeProgressRing({
    super.key,
    required this.progress,
    required this.label,
    this.size = 72,
    this.stroke = 6,
    this.onColoredBackground = false,
  });

  final double progress;
  final String label;
  final double size;
  final double stroke;
  final bool onColoredBackground;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors colors = PhysicsDegreeTheme.of(context);
    final double clamped = progress.clamp(0, 100) / 100;
    final Color ringColor = onColoredBackground ? Colors.white : colors.primary;
    final Color labelColor = onColoredBackground ? Colors.white : colors.textPrimary;
    final Color sublabelColor =
        onColoredBackground ? Colors.white.withValues(alpha: 0.75) : colors.textSecondary;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clamped,
              strokeWidth: stroke,
              backgroundColor: onColoredBackground
                  ? Colors.white.withValues(alpha: 0.2)
                  : colors.border.withValues(alpha: 0.5),
              color: ringColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${progress.round()}%',
                style: TextStyle(
                  color: labelColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: sublabelColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PhysDegreeStatChip extends StatelessWidget {
  const PhysDegreeStatChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors colors = PhysicsDegreeTheme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: colors.cardDecoration(),
        child: Column(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhysDegreeSectionHeader extends StatelessWidget {
  const PhysDegreeSectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors colors = PhysicsDegreeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PhysDegreeMasteryBar extends StatelessWidget {
  const PhysDegreeMasteryBar({super.key, required this.mastery});

  final double mastery;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors colors = PhysicsDegreeTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: (mastery / 100).clamp(0, 1),
        minHeight: 8,
        backgroundColor: colors.border.withValues(alpha: 0.5),
        color: colors.primary,
      ),
    );
  }
}
