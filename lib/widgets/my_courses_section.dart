import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/course_schedule.dart';
import '../theme/study_theme.dart';
import '../utils/schedule_format.dart';

/// Groups courses by semester string (e.g. "Fall 2025").
Map<String, List<Course>> groupCoursesBySemester(List<Course> courses) {
  final Map<String, List<Course>> grouped = <String, List<Course>>{};
  for (final Course course in courses) {
    final String key = course.semester.trim().isEmpty ? 'Other' : course.semester.trim();
    grouped.putIfAbsent(key, () => <Course>[]).add(course);
  }
  for (final List<Course> list in grouped.values) {
    list.sort((Course a, Course b) => a.code.compareTo(b.code));
  }
  return grouped;
}

List<String> sortedSemesterKeys(Map<String, List<Course>> grouped) {
  final List<String> keys = grouped.keys.toList();
  keys.sort((String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return keys;
}

String semesterBoxTitle(String semester) {
  if (semester == 'Other') return 'My classes';
  return 'My $semester classes';
}

String suggestedCurrentSemester() {
  final DateTime now = DateTime.now();
  final String term = now.month >= 7 ? 'Fall' : 'Spring';
  return '$term ${now.year}';
}

/// All semester labels: tracked + from courses, sorted A→Z.
List<String> mergeSemesterLabels(List<Course> courses, List<String> trackedSemesters) {
  final Set<String> labels = <String>{
    for (final String s in trackedSemesters)
      if (s.trim().isNotEmpty) s.trim(),
    for (final Course c in courses)
      if (c.semester.trim().isNotEmpty) c.semester.trim(),
  };
  if (labels.isEmpty) return <String>[suggestedCurrentSemester()];
  final List<String> sorted = labels.toList()..sort((String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return sorted;
}

List<Course> coursesForSemester(List<Course> courses, String semester) {
  return courses
      .where((Course c) {
        final String s = c.semester.trim().isEmpty ? 'Other' : c.semester.trim();
        final String key = semester == 'Other' ? 'Other' : semester;
        return s == key;
      })
      .toList()
    ..sort((Course a, Course b) => a.code.compareTo(b.code));
}

class MyCoursesSection extends StatelessWidget {
  const MyCoursesSection({
    super.key,
    required this.courses,
    this.trackedSemesters = const <String>[],
    this.onAddCourseForSemester,
    this.onRemoveCourse,
    this.onRemoveSemester,
    this.courseSchedules = const <String, CourseSchedule>{},
    this.onEditSchedule,
    this.onViewSummaryNote,
    this.onAddSummaryNote,
    this.showRemove = false,
    this.embedded = false,
  });

  final List<Course> courses;
  final List<String> trackedSemesters;
  final Map<String, CourseSchedule> courseSchedules;
  final void Function(String semester)? onAddCourseForSemester;
  final void Function(Course course)? onRemoveCourse;
  final void Function(Course course)? onEditSchedule;
  final void Function(Course course)? onViewSummaryNote;
  final void Function(Course course)? onAddSummaryNote;
  final void Function(String semester)? onRemoveSemester;
  final bool showRemove;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final double boxSpacing = embedded ? 10 : 12;
    final List<String> semesters = mergeSemesterLabels(courses, trackedSemesters);

    return Column(
      children: semesters
          .map(
            (String semester) {
              final List<Course> semesterCourses = coursesForSemester(courses, semester);
              return Padding(
                padding: EdgeInsets.only(bottom: semester == semesters.last ? 0 : boxSpacing),
                child: MyCoursesSemesterBox(
                  semesterLabel: semester,
                  courses: semesterCourses,
                  textSecondary: textSecondary,
                  onAddCourse: onAddCourseForSemester != null ? () => onAddCourseForSemester!(semester) : null,
                  showRemove: showRemove,
                  onRemoveCourse: onRemoveCourse,
                  onEditSchedule: onEditSchedule,
                  onViewSummaryNote: onViewSummaryNote,
                  onAddSummaryNote: onAddSummaryNote,
                  courseSchedules: courseSchedules,
                  onRemoveSemester: onRemoveSemester != null ? () => onRemoveSemester!(semester) : null,
                  embedded: embedded,
                ),
              );
            },
          )
          .toList(),
    );
  }
}

class MyCoursesSemesterBox extends StatelessWidget {
  const MyCoursesSemesterBox({
    super.key,
    required this.semesterLabel,
    required this.courses,
    required this.textSecondary,
    this.onAddCourse,
    this.showRemove = false,
    this.onRemoveCourse,
    this.onEditSchedule,
    this.onViewSummaryNote,
    this.onAddSummaryNote,
    this.courseSchedules = const <String, CourseSchedule>{},
    this.onRemoveSemester,
    this.embedded = false,
  });

  final String semesterLabel;
  final List<Course> courses;
  final Color textSecondary;
  final VoidCallback? onAddCourse;
  final bool showRemove;
  final void Function(Course course)? onRemoveCourse;
  final void Function(Course course)? onEditSchedule;
  final void Function(Course course)? onViewSummaryNote;
  final void Function(Course course)? onAddSummaryNote;
  final Map<String, CourseSchedule> courseSchedules;
  final VoidCallback? onRemoveSemester;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final String title = semesterBoxTitle(semesterLabel);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: embedded ? StudyColors.background(brightness) : StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(embedded ? 16 : 24),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: StudyColors.primaryTint(brightness),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.school_outlined, color: StudyColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (courses.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: StudyColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${courses.length}',
                      style: TextStyle(
                        color: StudyColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                if (onRemoveSemester != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: textSecondary,
                    tooltip: 'Remove semester',
                    onPressed: onRemoveSemester,
                  ),
              ],
            ),
          ),
          if (courses.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Text(
                'No classes added yet. Tap below to add CHEM 1211, BIOL 1107, etc.',
                style: TextStyle(color: textSecondary, fontSize: 13, height: 1.35),
              ),
            )
          else
            ...courses.map(
              (Course course) => _CourseRow(
                course: course,
                schedule: courseSchedules[course.id],
                textSecondary: textSecondary,
                showRemove: showRemove,
                onRemove: onRemoveCourse != null ? () => onRemoveCourse!(course) : null,
                onEditSchedule: onEditSchedule != null ? () => onEditSchedule!(course) : null,
                onViewSummaryNote: onViewSummaryNote != null ? () => onViewSummaryNote!(course) : null,
                onAddSummaryNote: onAddSummaryNote != null ? () => onAddSummaryNote!(course) : null,
                showDivider: course != courses.last,
              ),
            ),
          if (onAddCourse != null) ...<Widget>[
            Divider(height: 1, color: StudyColors.border(brightness)),
            InkWell(
              onTap: onAddCourse,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add_circle_outline, color: StudyColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      courses.isEmpty ? 'Add a class' : 'Add another class',
                      style: TextStyle(color: StudyColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({
    required this.course,
    required this.schedule,
    required this.textSecondary,
    required this.showRemove,
    required this.onRemove,
    required this.onEditSchedule,
    this.onViewSummaryNote,
    this.onAddSummaryNote,
    required this.showDivider,
  });

  final Course course;
  final CourseSchedule? schedule;
  final Color textSecondary;
  final bool showRemove;
  final VoidCallback? onRemove;
  final VoidCallback? onEditSchedule;
  final VoidCallback? onViewSummaryNote;
  final VoidCallback? onAddSummaryNote;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final String scheduleLine = formatClassScheduleSummary(schedule);
    final bool hasSchedule = schedule != null && schedule!.weekdays.isNotEmpty;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: StudyColors.accentTint(Theme.of(context).brightness),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  course.code.isNotEmpty ? course.code.split(' ').first : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: StudyColors.accentDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      course.code,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      course.professor.isNotEmpty ? course.professor : course.name,
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                    if (onAddSummaryNote != null) ...<Widget>[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: onAddSummaryNote,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.upload_file_outlined, size: 14, color: StudyColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Add summary note',
                                  style: TextStyle(
                                    color: StudyColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 16, color: textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (onViewSummaryNote != null) ...<Widget>[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: onViewSummaryNote,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.description_outlined, size: 14, color: StudyColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'View summary note',
                                  style: TextStyle(
                                    color: StudyColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 16, color: textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (onEditSchedule != null) ...<Widget>[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: onEditSchedule,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                hasSchedule ? Icons.notifications_active_outlined : Icons.schedule_outlined,
                                size: 14,
                                color: hasSchedule ? StudyColors.primary : textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  scheduleLine,
                                  style: TextStyle(
                                    color: hasSchedule ? StudyColors.primary : textSecondary,
                                    fontSize: 12,
                                    fontWeight: hasSchedule ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 16, color: textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showRemove && onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: textSecondary,
                  tooltip: 'Remove',
                  onPressed: onRemove,
                ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 18,
            endIndent: 18,
            color: StudyColors.border(Theme.of(context).brightness),
          ),
      ],
    );
  }
}
