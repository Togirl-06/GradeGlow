import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/study_theme.dart';
import '../utils/gpa_predictor.dart';
import 'study_surface.dart';

/// Compact predicted-GPA summary for Progress (web + phone).
class GpaPredictionCard extends StatelessWidget {
  const GpaPredictionCard({
    super.key,
    required this.profile,
    this.onOpenDetails,
  });

  final UserProfile profile;
  final VoidCallback? onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final GpaForecast forecast = GpaPredictor.fromProfile(profile);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color textSecondary = StudyColors.textSecondary(
      Theme.of(context).brightness,
    );
    final Color accent = forecast.trendLabel == 'At risk' ||
            forecast.trendLabel == 'Slipping'
        ? StudyColors.warning
        : scheme.primary;

    return StudySurfaceCard(
      onTap: onOpenDetails,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'GPA PREDICTION',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  forecast.trendLabel,
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                forecast.hasQuizzes ? forecast.gpaLabel : '—',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 36,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 6),
                child: Text(
                  forecast.hasQuizzes ? '/ 4.00 · ${forecast.letter}' : '/ 4.00',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (onOpenDetails != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: textSecondary,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            forecast.nextStep,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            forecast.hasQuizzes
                ? forecast.summary
                : 'Based on your class quiz scores on a 4.0 letter scale.',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          if (forecast.cumulativeOutlook != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'If this term holds, overall GPA moves toward ${forecast.cumulativeOutlook!.toStringAsFixed(2)} (from ${forecast.reportedGpa.toStringAsFixed(2)} reported).',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
