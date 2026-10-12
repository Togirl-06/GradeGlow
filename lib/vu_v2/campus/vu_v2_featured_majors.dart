import 'package:flutter/material.dart';

import '../design/vu_v2_theme.dart';

class VuFeaturedMajor {
  const VuFeaturedMajor({
    required this.id,
    required this.title,
    required this.emoji,
    required this.accent,
    required this.icon,
  });

  final String id;
  final String title;
  final String emoji;
  final Color accent;
  final IconData icon;
}

/// Majors shown on the Virtual University dashboard (mockup row).
abstract final class VuFeaturedMajors {
  /// Accent colors follow the live theme (not compile-time constants).
  static List<VuFeaturedMajor> get all => <VuFeaturedMajor>[
        VuFeaturedMajor(
          id: 'nursing',
          title: 'Nursing',
          emoji: '🏥',
          accent: VuV2Colors.dashPurple,
          icon: Icons.favorite_rounded,
        ),
        VuFeaturedMajor(
          id: 'law',
          title: 'Law',
          emoji: '⚖️',
          accent: VuV2Colors.dashGold,
          icon: Icons.balance_rounded,
        ),
        VuFeaturedMajor(
          id: 'computer_science',
          title: 'Computer Science',
          emoji: '💻',
          accent: VuV2Colors.dashCyan,
          icon: Icons.laptop_chromebook_rounded,
        ),
        VuFeaturedMajor(
          id: 'business',
          title: 'Business',
          emoji: '📊',
          accent: VuV2Colors.dashPink,
          icon: Icons.bar_chart_rounded,
        ),
        VuFeaturedMajor(
          id: 'biology',
          title: 'Biology',
          emoji: '🧬',
          accent: VuV2Colors.dashGreen,
          icon: Icons.biotech_rounded,
        ),
      ];
}
