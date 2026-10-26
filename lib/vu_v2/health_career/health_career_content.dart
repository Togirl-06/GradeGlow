import 'package:flutter/material.dart';

import 'health_career_theme.dart';

class HealthProgram {
  const HealthProgram({
    required this.id,
    required this.title,
    required this.blurb,
    required this.facility,
    required this.icon,
    required this.accent,
    required this.hubFocus,
  });

  final String id;
  final String title;
  final String blurb;
  final String facility;
  final IconData icon;
  final Color accent;
  final String hubFocus;
}

abstract final class HealthPrograms {
  static const List<HealthProgram> all = <HealthProgram>[
    HealthProgram(
      id: 'nursing',
      title: 'Nursing',
      blurb: 'Ward assessment, vitals, and care planning.',
      facility: 'Virtual Clinical Ward',
      icon: Icons.favorite_rounded,
      accent: MedCosmic.clinical,
      hubFocus: 'clinical_case',
    ),
    HealthProgram(
      id: 'public_health',
      title: 'Public Health',
      blurb: 'Community metrics, outbreaks, and prevention.',
      facility: 'Community Health Center',
      icon: Icons.public_rounded,
      accent: MedCosmic.teal,
      hubFocus: 'public_health',
    ),
    HealthProgram(
      id: 'nutrition',
      title: 'Nutrition',
      blurb: 'Food diaries, patterns, and educational meal plans.',
      facility: 'Nutrition Clinic',
      icon: Icons.restaurant_rounded,
      accent: MedCosmic.success,
      hubFocus: 'nutrition',
    ),
    HealthProgram(
      id: 'anatomy_physiology',
      title: 'Anatomy and Physiology',
      blurb: 'Explore organs, systems, and structure IDs.',
      facility: 'Anatomy Laboratory',
      icon: Icons.accessibility_new_rounded,
      accent: MedCosmic.purple,
      hubFocus: 'anatomy',
    ),
    HealthProgram(
      id: 'healthcare_management',
      title: 'Healthcare Management',
      blurb: 'Staffing, beds, flow, and quality indicators.',
      facility: 'Hospital Command Center',
      icon: Icons.apartment_rounded,
      accent: MedCosmic.gold,
      hubFocus: 'management',
    ),
    HealthProgram(
      id: 'pharmacy_fundamentals',
      title: 'Pharmacy Fundamentals',
      blurb: 'Labels, dosing math, interactions, and counseling.',
      facility: 'Teaching Pharmacy',
      icon: Icons.local_pharmacy_rounded,
      accent: MedCosmic.warning,
      hubFocus: 'pharmacy',
    ),
    HealthProgram(
      id: 'medicine',
      title: 'Medicine',
      blurb: 'History, differentials, and safe next steps.',
      facility: 'Consultation Suite',
      icon: Icons.medical_services_rounded,
      accent: MedCosmic.electric,
      hubFocus: 'clinical_case',
    ),
    HealthProgram(
      id: 'medical_lab_science',
      title: 'Medical Lab Science',
      blurb: 'Specimens, assays, and critical-value reporting.',
      facility: 'Medical Laboratory',
      icon: Icons.biotech_rounded,
      accent: Color(0xFF22D3EE),
      hubFocus: 'lab',
    ),
  ];

  static HealthProgram byId(String id) {
    final String normalized = normalizeId(id);
    return all.firstWhere(
      (HealthProgram p) => p.id == normalized,
      orElse: () => all.first,
    );
  }

  static String normalizeId(String id) {
    final String s = id.toLowerCase();
    if (s == 'pharmacy' || s.contains('pharmacy')) return 'pharmacy_fundamentals';
    if (s.contains('medical_lab') || s.contains('laboratory')) {
      return 'medical_lab_science';
    }
    if (s.contains('anatomy')) return 'anatomy_physiology';
    if (s.contains('public')) return 'public_health';
    if (s.contains('nutrition') || s.contains('diet')) return 'nutrition';
    if (s.contains('manage')) return 'healthcare_management';
    if (s.contains('medicine') || s == 'md') return 'medicine';
    if (s.contains('nurs')) return 'nursing';
    return s;
  }

  static bool isHealthId(String id) {
    final String n = normalizeId(id);
    return all.any((HealthProgram p) => p.id == n) ||
        id.toLowerCase() == 'health';
  }
}
