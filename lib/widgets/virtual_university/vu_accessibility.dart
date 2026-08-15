import 'package:flutter/material.dart';

/// Forces [MediaQuery.disableAnimations] for the subtree when reduced motion is preferred.
class VuReduceMotion extends StatelessWidget {
  const VuReduceMotion({super.key, required this.child, this.force = false});

  final Widget child;

  /// When true, animations are disabled even if the platform setting is off.
  final bool force;

  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    final bool reduce = force || data.disableAnimations;
    if (!reduce || data.disableAnimations) return child;
    return MediaQuery(
      data: data.copyWith(disableAnimations: true),
      child: child,
    );
  }
}

/// Marks [child] as a semantics section header for accessibility tree navigation.
class VuSemanticSectionHeader extends StatelessWidget {
  const VuSemanticSectionHeader({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(header: true, label: label, child: child);
  }
}

/// Convenience helpers for Virtual University accessibility wrappers.
abstract final class VuAccessibility {
  static Widget reduceMotion({required Widget child, bool force = false}) {
    return VuReduceMotion(force: force, child: child);
  }

  static Widget sectionHeader({required String label, required Widget child}) {
    return VuSemanticSectionHeader(label: label, child: child);
  }
}
