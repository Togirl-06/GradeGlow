import 'package:flutter/material.dart';

import 'vu_v2_theme.dart';

class VuV2PrimaryButton extends StatelessWidget {
  const VuV2PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }
    return FilledButton(onPressed: onPressed, child: Text(label));
  }
}

class VuV2ProgressBar extends StatelessWidget {
  const VuV2ProgressBar({super.key, required this.value, this.height = 10});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        color: VuV2Colors.orange,
        backgroundColor: VuV2Colors.stroke,
      ),
    );
  }
}

class VuV2EmptyState extends StatelessWidget {
  const VuV2EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.school_outlined, size: 48, color: VuV2Colors.mute),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: VuV2Colors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: VuV2Colors.mute, height: 1.4),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 18),
              VuV2PrimaryButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

class VuV2SectionTitle extends StatelessWidget {
  const VuV2SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: VuV2Colors.ink,
        fontWeight: FontWeight.w900,
        fontSize: 17,
      ),
    );
  }
}

class VuV2Surface extends StatelessWidget {
  const VuV2Surface({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VuV2Colors.navyElevated,
        borderRadius: BorderRadius.circular(VuV2Radii.lg),
        border: Border.all(color: VuV2Colors.stroke),
      ),
      child: child,
    );
  }
}
