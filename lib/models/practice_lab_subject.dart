import 'package:flutter/material.dart';

import '../data/practice_lab_course_topics.dart';
import 'practice_lab.dart';
import 'practice_lab_topic.dart';
import 'practice_lab_unit.dart';

/// Top-level academic subject (e.g. Nursing, Computer Science).
class PracticeLabSubject {
  const PracticeLabSubject({
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
    required this.groupId,
    required this.courses,
  });

  final String id;
  final String name;
  final String emoji;
  final IconData icon;
  final String groupId;
  final List<PracticeLabCourse> courses;

  int get topicCount => courses.fold<int>(0, (int n, PracticeLabCourse c) => n + c.topicCount);

  PracticeLabCategory toCategory() => PracticeLabCategory(
        id: id,
        name: name,
        emoji: emoji,
        icon: icon,
        groupId: groupId,
        labs: const <PracticeLabType>[],
      );

  /// Every topic in this subject with its owning course and unit (for activity routing).
  List<PracticeLabSubjectTopicEntry> get topicEntries {
    final List<PracticeLabSubjectTopicEntry> out = <PracticeLabSubjectTopicEntry>[];
    for (final PracticeLabCourse course in courses) {
      for (final PracticeLabUnit unit in course.units) {
        for (final PracticeLabTopic topic in unit.topics) {
          out.add(PracticeLabSubjectTopicEntry(course: course, unit: unit, topic: topic));
        }
      }
    }
    return out;
  }
}

/// Locates a topic within the subject hierarchy.
class PracticeLabSubjectTopicEntry {
  const PracticeLabSubjectTopicEntry({
    required this.course,
    required this.unit,
    required this.topic,
  });

  final PracticeLabCourse course;
  final PracticeLabUnit unit;
  final PracticeLabTopic topic;

  String get unitKey => '${course.id}|${unit.id}';
}

/// Course within a subject (e.g. Pharmacology under Nursing).
class PracticeLabCourse {
  const PracticeLabCourse({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.groupId,
  });

  final String id;
  final String name;
  final String subjectId;
  final String groupId;

  List<PracticeLabUnit> get units => PracticeLabCourseTopics.buildUnits(
        subjectId: subjectId,
        courseId: id,
        courseName: name,
        groupId: groupId,
      );

  int get unitCount => units.length;

  int get topicCount => units.fold<int>(0, (int n, PracticeLabUnit u) => n + u.topics.length);

  /// All topics flattened (e.g. for LeetCode topic browser).
  List<PracticeLabTopic> get allTopics =>
      units.expand((PracticeLabUnit u) => u.topics).toList();
}
