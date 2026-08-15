import 'package:flutter/material.dart';

/// Generic Virtual University subject/course/topic models backed by world curriculum.
class WorldTopic {
  const WorldTopic({
    required this.id,
    required this.title,
    required this.summary,
  });

  final String id;
  final String title;
  final String summary;
}

class WorldCourse {
  const WorldCourse({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.topics,
  });

  final String id;
  final String title;
  final String subjectId;
  final List<WorldTopic> topics;
}

class WorldLessonPath {
  const WorldLessonPath({
    required this.subjectId,
    required this.course,
    required this.topic,
  });

  final String subjectId;
  final WorldCourse course;
  final WorldTopic topic;

  String get breadcrumb => '${course.title} · ${topic.title}';
}

/// Display metadata for world-curriculum subjects without dedicated degree homes.
enum WorldSubjectMeta {
  english(
    'english',
    'English',
    '✍️',
    Color(0xFF2563EB),
    'Composition, literature, rhetoric, and professional communication.',
  ),
  environmentalScience(
    'environmental_science',
    'Environmental Science',
    '🌍',
    Color(0xFF059669),
    'Climate, ecology, conservation, and sustainability.',
  ),
  politicalScience(
    'political_science',
    'Political Science',
    '🏛️',
    Color(0xFF7C3AED),
    'Governments, IR, theory, and public policy.',
  );

  const WorldSubjectMeta(
    this.subjectId,
    this.title,
    this.emoji,
    this.color,
    this.tagline,
  );

  final String subjectId;
  final String title;
  final String emoji;
  final Color color;
  final String tagline;

  static WorldSubjectMeta? fromSubjectId(String id) {
    for (final WorldSubjectMeta m in values) {
      if (m.subjectId == id) return m;
    }
    return null;
  }
}
