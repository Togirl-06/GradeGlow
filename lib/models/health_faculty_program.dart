import 'package:flutter/material.dart';

/// Virtual University health faculties: Nursing, Medicine, Psychology.
enum HealthFaculty {
  nursing(
    'Nursing',
    '🩺',
    Color(0xFF0D9488),
    'Master patient care, clinical judgment, and bedside skills across the lifespan.',
  ),
  medicine(
    'Medicine',
    '🏥',
    Color(0xFFDC2626),
    'Build diagnostic reasoning from anatomy through emergency and surgical practice.',
  ),
  psychology(
    'Psychology',
    '🧠',
    Color(0xFF7C3AED),
    'Understand mind, behavior, development, and clinical mental health practice.',
  );

  const HealthFaculty(this.title, this.emoji, this.color, this.tagline);

  final String title;
  final String emoji;
  final Color color;
  final String tagline;

  static HealthFaculty? fromId(String id) {
    for (final HealthFaculty faculty in values) {
      if (faculty.name == id) return faculty;
    }
    return null;
  }
}

class HealthTopic {
  const HealthTopic({
    required this.id,
    required this.title,
    required this.summary,
  });

  final String id;
  final String title;
  final String summary;
}

class HealthCourse {
  const HealthCourse({
    required this.id,
    required this.title,
    required this.topics,
  });

  final String id;
  final String title;
  final List<HealthTopic> topics;
}

class HealthLessonPath {
  const HealthLessonPath({
    required this.faculty,
    required this.course,
    required this.topic,
  });

  final HealthFaculty faculty;
  final HealthCourse course;
  final HealthTopic topic;

  String get breadcrumb =>
      '${faculty.title} · ${course.title} · ${topic.title}';
}
