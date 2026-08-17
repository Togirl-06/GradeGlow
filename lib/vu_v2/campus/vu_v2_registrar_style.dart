import 'package:flutter/material.dart';

/// Adult records-office look — not a game card.
abstract final class RegistrarColors {
  static const Color paper = Color(0xFFF7F4EE);
  static const Color panel = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1A2332);
  static const Color mute = Color(0xFF5C6570);
  static const Color rule = Color(0xFFD8D0C4);
  static const Color navy = Color(0xFF17324D);
  static const Color gold = Color(0xFF8A6A32);
  static const Color danger = Color(0xFF8B2E2E);
}

abstract final class RegistrarType {
  static const TextStyle serifName = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w600,
    color: RegistrarColors.ink,
  );

  static const TextStyle kicker = TextStyle(
    fontSize: 10,
    letterSpacing: 1.6,
    fontWeight: FontWeight.w700,
    color: RegistrarColors.gold,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w700,
    color: RegistrarColors.mute,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.45,
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
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: RegistrarColors.paper,
        appBarTheme: const AppBarTheme(
          backgroundColor: RegistrarColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        sliderTheme: SliderTheme.of(context).copyWith(
          activeTrackColor: RegistrarColors.navy,
          thumbColor: RegistrarColors.navy,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
            return s.contains(WidgetState.selected)
                ? RegistrarColors.navy
                : RegistrarColors.mute;
          }),
        ),
      ),
      child: Scaffold(
        backgroundColor: RegistrarColors.paper,
        appBar: showAppBar
            ? AppBar(
                title: Text(title),
                actions: actions,
              )
            : null,
        body: child,
      ),
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
      child: Text(
        text.toUpperCase(),
        style: RegistrarType.kicker.copyWith(color: RegistrarColors.navy),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 128,
            child: Text(label, style: RegistrarType.label),
          ),
          Expanded(
            child: Text(
              value,
              style: RegistrarType.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
