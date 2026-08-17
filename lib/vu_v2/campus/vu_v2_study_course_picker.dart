import 'package:flutter/material.dart';

import '../data/vu_v2_degree_catalog.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_roadmap_sync.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

class VuV2StudyCourseRef {
  const VuV2StudyCourseRef({
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.course,
  });

  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final VuV2RoadmapCourse course;

  String get categoryLabel {
    final String base = facultyTitle.trim().isEmpty ? 'Courses' : facultyTitle.trim();
    final String upper = base.toUpperCase();
    if (upper.endsWith('COURSES') || upper.endsWith('COURSE')) return upper;
    // "Computer Science" → "COMPUTER SCIENCE COURSES"
    if (base.toLowerCase().endsWith('science') ||
        base.toLowerCase().endsWith('studies') ||
        base.toLowerCase().endsWith('engineering') ||
        base.toLowerCase().endsWith('administration') ||
        base.toLowerCase().endsWith('nursing') ||
        base.toLowerCase().endsWith('medicine') ||
        base.toLowerCase().endsWith('mathematics') ||
        base.toLowerCase().endsWith('physics') ||
        base.toLowerCase().endsWith('chemistry') ||
        base.toLowerCase().endsWith('biology') ||
        base.toLowerCase().endsWith('psychology') ||
        base.toLowerCase().endsWith('finance') ||
        base.toLowerCase().endsWith('accounting') ||
        base.toLowerCase().endsWith('marketing') ||
        base.toLowerCase().endsWith('economics')) {
      return '$upper COURSES';
    }
    return '$upper COURSES';
  }
}

/// Courses from major + enrolled + a few more programs.
List<VuV2StudyCourseRef> vuV2StudyCoursesFor({
  required VuV2Session session,
  required VuV2ProgressStore progress,
  int extraProgramLimit = 24,
}) {
  final List<VuV2StudyCourseRef> out = <VuV2StudyCourseRef>[];
  final Set<String> seen = <String>{};

  void addRoadmap(String subjectId) {
    final VuV2DegreeRoadmap roadmap = VuV2RoadmapSync.forSubjectId(subjectId);
    for (final VuV2RoadmapTrack track in roadmap.tracks) {
      for (final VuV2RoadmapCourse course in track.courses) {
        final String key = '$subjectId::${course.id}';
        if (!seen.add(key)) continue;
        if (course.lessonCount == 0) continue;
        out.add(
          VuV2StudyCourseRef(
            subjectId: subjectId,
            facultyTitle: roadmap.title,
            facultyEmoji: roadmap.emoji,
            trackTitle: track.title,
            course: course,
          ),
        );
      }
    }
  }

  addRoadmap(session.majorId);
  for (final String id in progress.enrolledDegreeIds) {
    if (id != session.majorId) addRoadmap(id);
  }
  for (final VuV2DegreeDef d in VuV2DegreeCatalog.degrees.take(extraProgramLimit)) {
    if (d.roadmapSubjectId != session.majorId &&
        !progress.enrolledDegreeIds.contains(d.roadmapSubjectId)) {
      addRoadmap(d.roadmapSubjectId);
    }
  }
  return out;
}

/// Group courses under faculty headers (order preserved).
Map<String, List<VuV2StudyCourseRef>> vuV2GroupCoursesByCategory(
  List<VuV2StudyCourseRef> courses,
) {
  final Map<String, List<VuV2StudyCourseRef>> groups =
      <String, List<VuV2StudyCourseRef>>{};
  for (final VuV2StudyCourseRef c in courses) {
    groups.putIfAbsent(c.categoryLabel, () => <VuV2StudyCourseRef>[]).add(c);
  }
  return groups;
}

/// Shared “choose a course” screen for Study Center tools.
class VuV2StudyCoursePickerScreen extends StatelessWidget {
  const VuV2StudyCoursePickerScreen({
    super.key,
    required this.session,
    required this.progress,
    required this.title,
    required this.subtitle,
    required this.onCourseSelected,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final String title;
  final String subtitle;
  final void Function(BuildContext context, VuV2StudyCourseRef course)
      onCourseSelected;

  @override
  Widget build(BuildContext context) {
    final List<VuV2StudyCourseRef> courses = vuV2StudyCoursesFor(
      session: session,
      progress: progress,
    );
    final Map<String, List<VuV2StudyCourseRef>> groups =
        vuV2GroupCoursesByCategory(courses);

    final List<Widget> tiles = <Widget>[
      Text(
        'Choose a course',
        style: TextStyle(
          color: VuV2Colors.ink,
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: TextStyle(color: VuV2Colors.mute, height: 1.4),
      ),
      const SizedBox(height: 8),
    ];

    if (courses.isEmpty) {
      tiles.add(
        const VuV2EmptyState(
          title: 'No courses available',
          subtitle: 'Enroll in a program from Lecture Halls, then come back.',
        ),
      );
    } else {
      var first = true;
      for (final MapEntry<String, List<VuV2StudyCourseRef>> e in groups.entries) {
        tiles.add(
          Padding(
            padding: EdgeInsets.only(top: first ? 8 : 18, bottom: 10),
            child: Row(
              children: <Widget>[
                Text(
                  e.value.first.facultyEmoji,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.key,
                    style: TextStyle(
                      color: VuV2Colors.orange,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Text(
                  '${e.value.length}',
                  style: TextStyle(
                    color: VuV2Colors.mute,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
        first = false;
        for (final VuV2StudyCourseRef c in e.value) {
          tiles.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: VuV2Colors.navyElevated,
                borderRadius: BorderRadius.circular(VuV2Radii.lg),
                child: ListTile(
                  onTap: () => onCourseSelected(context, c),
                  leading: Text(
                    c.course.emoji ?? c.facultyEmoji,
                    style: TextStyle(fontSize: 22),
                  ),
                  title: Text(
                    c.course.title,
                    style: TextStyle(
                      color: VuV2Colors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    '${c.course.lessonCount} topics'
                    '${c.trackTitle.isNotEmpty ? ' · ${c.trackTitle}' : ''}',
                    style: TextStyle(color: VuV2Colors.mute, fontSize: 12),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: VuV2Colors.mute,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(title: Text(title), backgroundColor: VuV2Colors.navy),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: tiles,
      ),
    );
  }
}
