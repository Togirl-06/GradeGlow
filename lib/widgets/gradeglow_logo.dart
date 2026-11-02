import 'package:flutter/material.dart';

import '../config/app_branding.dart';

/// GradeGlow interlocking-G logo from brand assets.
class GradeGlowLogo extends StatelessWidget {
  const GradeGlowLogo({
    super.key,
    this.height = 120,
    this.width,
    this.fit = BoxFit.contain,
  });

  final double height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final double targetHeight = height;
    final double targetWidth = width ?? targetHeight * AppBranding.logoAspectRatio;

    return SizedBox(
      width: targetWidth,
      height: targetHeight,
      child: Image.asset(
        AppBranding.logoAsset,
        fit: fit,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

/// Compact logo + wordmark for app bars and auth headers.
class GradeGlowBrandRow extends StatelessWidget {
  const GradeGlowBrandRow({
    super.key,
    this.logoSize = 32,
    this.nameStyle,
    this.subtitle,
    this.subtitleStyle,
    this.onDark = false,
  });

  final double logoSize;
  final TextStyle? nameStyle;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool useLightText = onDark || brightness == Brightness.dark;
    final Color titleColor = useLightText ? Colors.white : AppBranding.navy;
    final TextStyle title = nameStyle ??
        TextStyle(
          color: titleColor,
          fontSize: logoSize * 0.72,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          height: 1.1,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GradeGlowLogo(height: logoSize),
        SizedBox(width: logoSize * 0.35),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppBranding.name, style: title),
              if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                SizedBox(height: logoSize * 0.06),
                Text(
                  subtitle!,
                  style: subtitleStyle ??
                      TextStyle(
                        color: useLightText
                            ? Colors.white.withValues(alpha: 0.82)
                            : AppBranding.navy.withValues(alpha: 0.55),
                        fontSize: logoSize * 0.38,
                        height: 1.2,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Home screen greeting with optional compact logo on the right.
class GradeGlowHomeHeader extends StatelessWidget {
  const GradeGlowHomeHeader({
    super.key,
    required this.greeting,
    required this.name,
    this.showLogo = true,
  });

  final String greeting;
  final String name;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = brightness == Brightness.dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final Widget greetingBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          greeting,
          style: TextStyle(
            color: textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
        ),
      ],
    );

    if (!showLogo) {
      return greetingBlock;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: greetingBlock),
        const SizedBox(width: 12),
        const GradeGlowLogo(height: 46),
      ],
    );
  }
}
