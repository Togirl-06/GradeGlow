import 'package:flutter/material.dart';

/// Campus destinations.
enum VuV2Dest {
  home,
  learn,
  labs,
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
      case VuV2Dest.community:
        return 'Community';
      case VuV2Dest.profile:
        return 'Progress';
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
      case VuV2Dest.community:
        return Icons.groups_outlined;
      case VuV2Dest.profile:
        return Icons.insights_outlined;
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
      case VuV2Dest.community:
        return Icons.groups_rounded;
      case VuV2Dest.profile:
        return Icons.insights_rounded;
    }
  }
}

abstract final class VuV2LearningLoop {
  static const List<String> steps = <String>[
    'Learn',
    'Practice',
    'Test',
    'Feedback',
    'Master',
  ];
}

/// Ordered rail / desktop destinations.
const List<VuV2Dest> vuV2NavDestinations = <VuV2Dest>[
  VuV2Dest.home,
  VuV2Dest.learn,
  VuV2Dest.labs,
  VuV2Dest.profile,
];

const List<VuV2Dest> vuV2MoreDestinations = <VuV2Dest>[
  VuV2Dest.profile,
];
