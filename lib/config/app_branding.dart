import 'package:flutter/material.dart';

/// User-facing app name and shared branding constants.
class AppBranding {
  AppBranding._();

  static const String name = 'GradeGlow';
  static const String tagline =
      'World-class education for anyone, anywhere — powered by AI professors.';
  static const String mission =
      'Grade Glow Virtual University exists to provide affordable, high-quality '
      'education to anyone in the world, regardless of their financial situation, '
      'location, or background.';
  static const String logoAsset = 'assets/images/gradeglow_logo.png';

  /// Interlocking-G mark is wider than tall — don't force a square box.
  static const double logoAspectRatio = 1.5;

  /// Logo palette — warm orange gradient mark.
  static const Color navy = Color(0xFF0F172A);
  static const Color glowOrange = Color(0xFFF97316);
  static const Color glowYellow = Color(0xFFFBBF24);
  static const Color glowDeep = Color(0xFFEA580C);
}
