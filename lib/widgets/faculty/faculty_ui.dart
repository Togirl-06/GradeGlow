import 'package:flutter/material.dart';

import '../../theme/faculty_palette.dart';

/// Rich faculty UI — heroes, cards, headers, and scaffolds for every subject.
class FacultyScaffold extends StatelessWidget {
  const FacultyScaffold({
    super.key,
    required this.palette,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
  });

  final FacultyPalette palette;
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: palette.background,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette.appBarGradient ?? palette.heroGradient,
            ),
          ),
        ),
        foregroundColor: palette.appBarForeground,
        title: subtitle == null
            ? Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(subtitle!, style: TextStyle(fontSize: 11, color: palette.appBarForeground.withValues(alpha: 0.75))),
                ],
              ),
        actions: actions,
      ),
      body: Stack(
        children: <Widget>[
          _FacultyBackdrop(palette: palette),
          body,
        ],
      ),
    );
  }
}

class _FacultyBackdrop extends StatelessWidget {
  const _FacultyBackdrop({required this.palette});
  final FacultyPalette palette;

  @override
  Widget build(BuildContext context) {
    final Color glow = palette.glowColor ?? palette.accent.withValues(alpha: 0.2);
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: <Color>[glow, Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[palette.primary.withValues(alpha: 0.08), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FacultyHeroCard extends StatelessWidget {
  const FacultyHeroCard({
    super.key,
    required this.palette,
    required this.title,
    this.tagline,
    this.body,
    this.stats,
    this.trailing,
  });

  final FacultyPalette palette;
  final String title;
  final String? tagline;
  final String? body;
  final List<String>? stats;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(palette.cardRadius + 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.heroGradient,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (tagline != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        tagline!,
                        style: TextStyle(
                          color: palette.accent.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          if (body != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              body!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.45,
                fontSize: 14,
              ),
            ),
          ],
          if (stats != null && stats!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats!.map((String s) => FacultyStatChip(label: s, palette: palette, onDark: true)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class FacultySectionHeader extends StatelessWidget {
  const FacultySectionHeader({
    super.key,
    required this.palette,
    required this.label,
    this.icon,
    this.trailing,
  });

  final FacultyPalette palette;
  final String label;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: <Widget>[
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[palette.primary, palette.accent],
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: palette.primary),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                fontSize: 11,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class FacultyStatChip extends StatelessWidget {
  const FacultyStatChip({
    super.key,
    required this.label,
    required this.palette,
    this.onDark = false,
  });

  final String label;
  final FacultyPalette palette;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withValues(alpha: 0.16) : palette.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: onDark ? Colors.white.withValues(alpha: 0.35) : palette.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: onDark ? Colors.white : palette.primary,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class FacultyNavCard extends StatelessWidget {
  const FacultyNavCard({
    super.key,
    required this.palette,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.detail,
    this.icon,
    this.trailing,
    this.badge,
    this.accentStrip = true,
  });

  final FacultyPalette palette;
  final String title;
  final String? subtitle;
  final String? detail;
  final IconData? icon;
  final Widget? trailing;
  final String? badge;
  final VoidCallback onTap;
  final bool accentStrip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: palette.surface,
        elevation: 0,
        shadowColor: palette.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(palette.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(palette.cardRadius),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(palette.cardRadius),
              border: Border.all(color: palette.border.withValues(alpha: 0.85)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(palette.cardRadius),
              child: Row(
                children: <Widget>[
                  if (accentStrip)
                    Container(
                      width: 5,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[palette.primary, palette.accent],
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                      child: Row(
                        children: <Widget>[
                          if (icon != null)
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    palette.primary.withValues(alpha: 0.18),
                                    palette.accent.withValues(alpha: 0.12),
                                  ],
                                ),
                              ),
                              child: Icon(icon, color: palette.primary, size: 24),
                            ),
                          if (icon != null) const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: palette.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (badge != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: palette.accent.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          badge!,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: palette.primaryDark,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (subtitle != null) ...<Widget>[
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle!,
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                                if (detail != null && detail!.isNotEmpty) ...<Widget>[
                                  const SizedBox(height: 6),
                                  Text(
                                    detail!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: palette.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          trailing ??
                              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: palette.primary.withValues(alpha: 0.65)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FacultyModeCard extends StatelessWidget {
  const FacultyModeCard({
    super.key,
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.detail,
    this.index,
  });

  final FacultyPalette palette;
  final String title;
  final String subtitle;
  final String? detail;
  final IconData icon;
  final VoidCallback onTap;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: palette.surfaceElevated,
        borderRadius: BorderRadius.circular(palette.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(palette.cardRadius),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(palette.cardRadius),
              border: Border.all(color: palette.border),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  palette.primary.withValues(alpha: 0.06),
                  palette.surface,
                ],
                stops: const <double>[0, 0.35],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: palette.primary,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: palette.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 26),
                      ),
                      if (index != null)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: palette.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: palette.surface, width: 2),
                            ),
                            child: Text(
                              '$index',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black87),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: palette.textPrimary)),
                        const SizedBox(height: 3),
                        Text(subtitle, style: TextStyle(color: palette.textSecondary, fontSize: 12, height: 1.3)),
                        if (detail != null && detail!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 5),
                          Text(
                            detail!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: palette.primary, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.play_circle_filled_rounded, color: palette.primary, size: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FacultyConceptChip extends StatelessWidget {
  const FacultyConceptChip({super.key, required this.label, required this.palette});

  final String label;
  final FacultyPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[palette.primary.withValues(alpha: 0.12), palette.accent.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.primary.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: palette.primaryDark),
      ),
    );
  }
}

class FacultyInfoPanel extends StatelessWidget {
  const FacultyInfoPanel({
    super.key,
    required this.palette,
    required this.text,
    this.title,
    this.icon,
  });

  final FacultyPalette palette;
  final String text;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(palette.cardRadius),
        border: Border.all(color: palette.primary.withValues(alpha: 0.2)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: palette.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: palette.primary, size: 20),
            ),
          if (icon != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null)
                  Text(title!, style: TextStyle(fontWeight: FontWeight.w900, color: palette.textPrimary)),
                if (title != null) const SizedBox(height: 6),
                Text(text, style: TextStyle(color: palette.textSecondary, height: 1.45, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FacultyTopicIntro extends StatelessWidget {
  const FacultyTopicIntro({
    super.key,
    required this.palette,
    required this.hook,
    required this.summary,
    this.concepts,
  });

  final FacultyPalette palette;
  final String hook;
  final String summary;
  final List<String>? concepts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(palette.cardRadius),
            color: palette.surface,
            border: Border.all(color: palette.border),
            boxShadow: <BoxShadow>[
              BoxShadow(color: palette.primary.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                hook,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(summary, style: TextStyle(color: palette.textSecondary, height: 1.45, fontSize: 14)),
            ],
          ),
        ),
        if (concepts != null && concepts!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: concepts!.map((String c) => FacultyConceptChip(label: c, palette: palette)).toList(),
          ),
        ],
      ],
    );
  }
}
