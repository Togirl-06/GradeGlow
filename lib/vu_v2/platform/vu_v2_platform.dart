import 'package:flutter/material.dart';

import '../career_labs/career_lab_home_screen.dart';
import '../career_labs/career_lab_registry.dart';
import '../career_labs/playable/playable_router.dart';

/// Campus destinations (My Courses, Career, and Simulations removed from product nav).
enum VuV2Dest {
  home,
  learn,
  labs,
  study,
  community,
  profile,
}

extension VuV2DestX on VuV2Dest {
  String get label {
    switch (this) {
      case VuV2Dest.home:
        return 'Home';
      case VuV2Dest.learn:
        return 'Learn';
      case VuV2Dest.labs:
        return 'Labs';
      case VuV2Dest.study:
        return 'Study';
      case VuV2Dest.community:
        return 'Community';
      case VuV2Dest.profile:
        return 'Profile';
    }
  }

  IconData get icon {
    switch (this) {
      case VuV2Dest.home:
        return Icons.home_outlined;
      case VuV2Dest.learn:
        return Icons.menu_book_outlined;
      case VuV2Dest.labs:
        return Icons.science_outlined;
      case VuV2Dest.study:
        return Icons.style_outlined;
      case VuV2Dest.community:
        return Icons.groups_outlined;
      case VuV2Dest.profile:
        return Icons.person_outline_rounded;
    }
  }

  IconData get selectedIcon {
    switch (this) {
      case VuV2Dest.home:
        return Icons.home_rounded;
      case VuV2Dest.learn:
        return Icons.menu_book_rounded;
      case VuV2Dest.labs:
        return Icons.science_rounded;
      case VuV2Dest.study:
        return Icons.style_rounded;
      case VuV2Dest.community:
        return Icons.groups_rounded;
      case VuV2Dest.profile:
        return Icons.person_rounded;
    }
  }
}

abstract final class VuV2LearningLoop {
  static const List<String> steps = <String>[
    'Learn',
    'Practice',
    'Test',
    'Lab',
    'Feedback',
    'Master',
  ];
}

/// Ordered rail / desktop destinations.
const List<VuV2Dest> vuV2NavDestinations = <VuV2Dest>[
  VuV2Dest.home,
  VuV2Dest.learn,
  VuV2Dest.labs,
  VuV2Dest.study,
  VuV2Dest.profile,
];

const List<VuV2Dest> vuV2MoreDestinations = <VuV2Dest>[
  VuV2Dest.study,
  VuV2Dest.profile,
];

void openCareerLab(BuildContext context, CareerLabDef lab) {
  if (!lab.available) return;
  final Widget? playable = playableScreenFor(lab.id);
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => playable ?? CareerLabHomeScreen(labId: lab.id),
    ),
  );
}
