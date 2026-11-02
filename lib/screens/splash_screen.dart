import 'package:flutter/material.dart';

import '../config/app_branding.dart';
import '../widgets/gradeglow_logo.dart';

/// Minimal launch screen — centered logo, wordmark, and footer tagline (Instagram-style).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: _SplashBrandMark(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 28),
              child: Text(
                AppBranding.tagline,
                style: TextStyle(
                  color: Color(0x610F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBrandMark extends StatelessWidget {
  const _SplashBrandMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const GradeGlowLogo(height: 96),
        const SizedBox(height: 22),
        ShaderMask(
          shaderCallback: _brandGradient,
          blendMode: BlendMode.srcIn,
          child: Text(
            AppBranding.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

Shader _brandGradient(Rect bounds) {
  return const LinearGradient(
    colors: <Color>[
      AppBranding.glowYellow,
      AppBranding.glowOrange,
      AppBranding.glowDeep,
    ],
  ).createShader(bounds);
}
