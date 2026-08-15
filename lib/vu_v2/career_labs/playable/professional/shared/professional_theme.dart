import 'package:flutter/material.dart';

/// Per-profession accent for professional simulations.
class ProSimTheme {
  const ProSimTheme({
    required this.id,
    required this.title,
    required this.workplace,
    required this.emoji,
    required this.accent,
    required this.tagline,
    required this.bg,
    required this.surface,
  });

  final String id;
  final String title;
  final String workplace;
  final String emoji;
  final Color accent;
  final String tagline;
  final Color bg;
  final Color surface;

  static const ProSimTheme business = ProSimTheme(
    id: 'business',
    title: 'Business HQ',
    workplace: 'Northline Ventures',
    emoji: '💼',
    accent: Color(0xFF38BDF8),
    tagline: 'INVESTIGATE · DECIDE · LEAD',
    bg: Color(0xFF070B14),
    surface: Color(0xFF0E1626),
  );

  static const ProSimTheme finance = ProSimTheme(
    id: 'finance',
    title: 'Markets Desk',
    workplace: 'Apex Capital',
    emoji: '💰',
    accent: Color(0xFFFBBF24),
    tagline: 'RESEARCH · ALLOCATE · MANAGE RISK',
    bg: Color(0xFF070B14),
    surface: Color(0xFF0E1626),
  );

  static const ProSimTheme accounting = ProSimTheme(
    id: 'accounting',
    title: 'Accounting Firm',
    workplace: 'Moss & Fairview LLP',
    emoji: '📊',
    accent: Color(0xFF34D399),
    tagline: 'CLASSIFY · RECONCILE · AUDIT',
    bg: Color(0xFF070B14),
    surface: Color(0xFF0E1626),
  );

  static const ProSimTheme marketing = ProSimTheme(
    id: 'marketing',
    title: 'Marketing Agency',
    workplace: 'Lumen Creative',
    emoji: '📣',
    accent: Color(0xFFF472B6),
    tagline: 'BRIEF · BUILD · OPTIMIZE',
    bg: Color(0xFF070B14),
    surface: Color(0xFF0E1626),
  );

  static const ProSimTheme economics = ProSimTheme(
    id: 'economics',
    title: 'Policy Unit',
    workplace: 'National Policy Institute',
    emoji: '🏛️',
    accent: Color(0xFFA78BFA),
    tagline: 'OBSERVE · MODEL · ADVISE',
    bg: Color(0xFF070B14),
    surface: Color(0xFF0E1626),
  );

  static ProSimTheme forId(String id) {
    switch (id) {
      case 'finance':
        return finance;
      case 'accounting':
        return accounting;
      case 'marketing':
        return marketing;
      case 'economics':
        return economics;
      default:
        return business;
    }
  }
}
