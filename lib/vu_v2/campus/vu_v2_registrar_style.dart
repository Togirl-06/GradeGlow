import 'package:flutter/material.dart';

import '../design/vu_v2_theme.dart';

/// Records-office chrome, but it follows GradeGlow light/dark and accent.
abstract final class RegistrarColors {
  static Color get paper => VuV2Colors.navy;
  static Color get panel => VuV2Colors.card;
  static Color get ink => VuV2Colors.ink;
  static Color get mute => VuV2Colors.mute;
  static Color get rule => VuV2Colors.stroke;
  static Color get navy => VuV2Colors.navyElevated;
  static Color get gold => VuV2Colors.gold;
  static Color get danger => VuV2Colors.danger;
}

abstract final class RegistrarType {
  static TextStyle get serifName => TextStyle(
        fontSize: 26,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: RegistrarColors.ink,
      );

  static TextStyle get kicker => TextStyle(
        fontSize: 10,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w800,
        color: VuV2Colors.mint,
      );

  static TextStyle get label => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: RegistrarColors.mute,
      );

  static TextStyle get body => TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w700,
        color: RegistrarColors.ink,
      );
}

class RegistrarScaffold extends StatelessWidget {
  const RegistrarScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showAppBar = true,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              actions: actions,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              foregroundColor: scheme.onSurface,
            )
          : null,
      body: child,
    );
  }
}

class RegistrarCard extends StatelessWidget {
  const RegistrarCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RegistrarColors.panel,
        borderRadius: BorderRadius.circular(VuV2Radii.lg),
        border: Border.all(color: RegistrarColors.rule),
      ),
      child: child,
    );
  }
}

class RegistrarSection extends StatelessWidget {
  const RegistrarSection(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text.toUpperCase(), style: RegistrarType.kicker),
    );
  }
}

class RegistrarRow extends StatelessWidget {
  const RegistrarRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: RegistrarType.label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: RegistrarType.body,
            ),
          ),
        ],
      ),
    );
  }
}
