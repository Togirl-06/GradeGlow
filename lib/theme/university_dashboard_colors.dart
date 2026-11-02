import 'package:flutter/material.dart';

/// Theme-derived colors shared by Virtual University school dashboards.
///
/// Program accents remain discipline-specific, while every neutral surface and
/// text color follows the app's selected light/dark theme and seed color.
class UniversityDashboardColors {
  const UniversityDashboardColors._({
    required this.page,
    required this.card,
    required this.elevatedCard,
    required this.border,
    required this.text,
    required this.mutedText,
    required this.subtleText,
    required this.track,
  });

  factory UniversityDashboardColors.of(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return UniversityDashboardColors._(
      page: Theme.of(context).scaffoldBackgroundColor,
      card: scheme.surfaceContainerLow,
      elevatedCard: scheme.surfaceContainer,
      border: scheme.outlineVariant,
      text: scheme.onSurface,
      mutedText: scheme.onSurfaceVariant,
      subtleText: scheme.onSurfaceVariant.withValues(alpha: 0.78),
      track: scheme.surfaceContainerHighest,
    );
  }

  final Color page;
  final Color card;
  final Color elevatedCard;
  final Color border;
  final Color text;
  final Color mutedText;
  final Color subtleText;
  final Color track;
}
