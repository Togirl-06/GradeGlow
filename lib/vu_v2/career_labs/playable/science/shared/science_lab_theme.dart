import 'package:flutter/material.dart';

/// Premium dark lab palette with a subject accent.
class ScienceLabTheme {
  const ScienceLabTheme({
    required this.accent,
    required this.bg,
    required this.surface,
    required this.danger,
    required this.emoji,
    required this.title,
  });

  final Color accent;
  final Color bg;
  final Color surface;
  final Color danger;
  final String emoji;
  final String title;

  static const ScienceLabTheme biology = ScienceLabTheme(
    accent: Color(0xFF4ADE80),
    bg: Color(0xFF06140A),
    surface: Color(0xFF0C2214),
    danger: Color(0xFFF87171),
    emoji: '🔬',
    title: 'Biology Lab',
  );

  static const ScienceLabTheme chemistry = ScienceLabTheme(
    accent: Color(0xFF38BDF8),
    bg: Color(0xFF061018),
    surface: Color(0xFF0C1A28),
    danger: Color(0xFFF87171),
    emoji: '🧪',
    title: 'Chemistry Lab',
  );

  static const ScienceLabTheme physics = ScienceLabTheme(
    accent: Color(0xFFA78BFA),
    bg: Color(0xFF0A0618),
    surface: Color(0xFF140C28),
    danger: Color(0xFFF87171),
    emoji: '⚛️',
    title: 'Physics Lab',
  );

  static ScienceLabTheme forSubject(String subjectId) {
    switch (subjectId.toLowerCase()) {
      case 'chemistry':
        return chemistry;
      case 'physics':
        return physics;
      case 'biology':
      default:
        return biology;
    }
  }
}
