import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/course_schedule.dart';
import '../services/expand_state_store.dart';
import '../theme/study_theme.dart';
import '../utils/schedule_format.dart';

/// Groups courses by semester string (e.g. "Fall 2025").
Map<String, List<Course>> groupCoursesBySemester(List<Course> courses) {
  final Map<String, List<Course>> grouped = <String, List<Course>>{};
  for (final Course course in courses) {
    final String key = course.semester.trim().isEmpty
        ? 'Other'
        : course.semester.trim();
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
List<String> mergeSemesterLabels(
  List<Course> courses,
  List<String> trackedSemesters,
) {
  final Set<String> labels = <String>{
    for (final String s in trackedSemesters)
      if (s.trim().isNotEmpty) s.trim(),
    for (final Course c in courses)
      if (c.semester.trim().isNotEmpty) c.semester.trim(),
  };
  if (labels.isEmpty) return <String>[suggestedCurrentSemester()];
  final List<String> sorted = labels.toList()
    ..sort((String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return sorted;
}

List<Course> coursesForSemester(List<Course> courses, String semester) {
  return courses.where((Course c) {
    final String s = c.semester.trim().isEmpty ? 'Other' : c.semester.trim();
    final String key = semester == 'Other' ? 'Other' : semester;
    return s == key;
  }).toList()..sort((Course a, Course b) => a.code.compareTo(b.code));
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
    final Color textSecondary = StudyColors.textSecondary(
      Theme.of(context).brightness,
    );
    final double boxSpacing = embedded ? 10 : 12;
    final List<String> semesters = mergeSemesterLabels(
      courses,
      trackedSemesters,
    );

    return Column(
      children: semesters.map((String semester) {
        final List<Course> semesterCourses = coursesForSemester(
          courses,
          semester,
        );
        return Padding(
          padding: EdgeInsets.only(
            bottom: semester == semesters.last ? 0 : boxSpacing,
          ),
          child: MyCoursesSemesterBox(
            semesterLabel: semester,
            courses: semesterCourses,
            textSecondary: textSecondary,
            onAddCourse: onAddCourseForSemester != null
                ? () => onAddCourseForSemester!(semester)
                : null,
            showRemove: showRemove,
            onRemoveCourse: onRemoveCourse,
            onEditSchedule: onEditSchedule,
            onViewSummaryNote: onViewSummaryNote,
            onAddSummaryNote: onAddSummaryNote,
            courseSchedules: courseSchedules,
            onRemoveSemester: onRemoveSemester != null
                ? () => onRemoveSemester!(semester)
                : null,
            embedded: embedded,
          ),
        );
      }).toList(),
    );
  }
}

class MyCoursesSemesterBox extends StatefulWidget {
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
  State<MyCoursesSemesterBox> createState() => _MyCoursesSemesterBoxState();
}

class _MyCoursesSemesterBoxState extends State<MyCoursesSemesterBox> {
  bool _expanded = true;
  bool _loaded = false;

  String get _storageKey => 'semester.${widget.semesterLabel}';

  @override
  void initState() {
    super.initState();
    _loadExpanded();
  }

  @override
  void didUpdateWidget(MyCoursesSemesterBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.semesterLabel != widget.semesterLabel) {
      _loadExpanded();
    }
  }

  Future<void> _loadExpanded() async {
    final bool expanded = await ExpandStateStore.instance.isExpanded(
      _storageKey,
    );
    if (!mounted) return;
    setState(() {
      _expanded = expanded;
      _loaded = true;
    });
  }

  Future<void> _toggleExpanded() async {
    final bool next = !_expanded;
    setState(() => _expanded = next);
    await ExpandStateStore.instance.setExpanded(_storageKey, next);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String title = semesterBoxTitle(widget.semesterLabel);
    final double radius = widget.embedded ? 20 : 24;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.embedded
            ? scheme.surfaceContainerLow
            : StudyColors.surface(brightness),
        borderRadius: BorderRadius.circular(radius),
        border: widget.embedded
            ? null
            : Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(radius),
                bottom: _expanded ? Radius.zero : Radius.circular(radius),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 16, 8, _expanded ? 12 : 16),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.folder_copy_outlined,
                        color: scheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.courses.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: StudyColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.courses.length}',
                          style: TextStyle(
                            color: StudyColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (widget.onRemoveSemester != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        color: widget.textSecondary,
                        tooltip: 'Remove semester',
                        onPressed: widget.onRemoveSemester,
                      ),
                    IconButton(
                      icon: Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 24,
                      ),
                      color: scheme.primary,
                      tooltip: _expanded ? 'Collapse semester' : 'Expand semester',
                      onPressed: _toggleExpanded,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeOutCubic,
            duration: const Duration(milliseconds: 220),
            crossFadeState: (!_loaded || _expanded)
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.courses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    child: Text(
                      'No classes added yet. Tap below to add CHEM 1211, BIOL 1107, etc.',
                      style: TextStyle(
                        color: widget.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  )
                else
                  ...widget.courses.map(
                    (Course course) => _CourseRow(
                      course: course,
                      schedule: widget.courseSchedules[course.id],
                      textSecondary: widget.textSecondary,
                      showRemove: widget.showRemove,
                      onRemove: widget.onRemoveCourse != null
                          ? () => widget.onRemoveCourse!(course)
                          : null,
                      onEditSchedule: widget.onEditSchedule != null
                          ? () => widget.onEditSchedule!(course)
                          : null,
                      onViewSummaryNote: widget.onViewSummaryNote != null
                          ? () => widget.onViewSummaryNote!(course)
                          : null,
                      onAddSummaryNote: widget.onAddSummaryNote != null
                          ? () => widget.onAddSummaryNote!(course)
                          : null,
                      showDivider: course != widget.courses.last,
                    ),
                  ),
                if (widget.onAddCourse != null) ...<Widget>[
                  Divider(height: 1, color: StudyColors.border(brightness)),
                  InkWell(
                    onTap: widget.onAddCourse,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(radius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add_circle_outline,
                            color: StudyColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.courses.isEmpty
                                ? 'Add a class'
                                : 'Add another class',
                            style: TextStyle(
                              color: StudyColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _CourseRow extends StatefulWidget {
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
  State<_CourseRow> createState() => _CourseRowState();
}

class _CourseRowState extends State<_CourseRow> {
  bool _expanded = true;
  bool _loaded = false;

  String get _storageKey {
    final String id = widget.course.id.trim().isNotEmpty
        ? widget.course.id.trim()
        : widget.course.code.trim();
    return 'my_course.$id';
  }

  bool get _hasDetails =>
      widget.onAddSummaryNote != null ||
      widget.onViewSummaryNote != null ||
      widget.onEditSchedule != null;

  @override
  void initState() {
    super.initState();
    _loadExpanded();
  }

  @override
  void didUpdateWidget(_CourseRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.course.id != widget.course.id ||
        oldWidget.course.code != widget.course.code) {
      _loadExpanded();
    }
  }

  Future<void> _loadExpanded() async {
    final bool expanded = await ExpandStateStore.instance.isExpanded(
      _storageKey,
    );
    if (!mounted) return;
    setState(() {
      _expanded = expanded;
      _loaded = true;
    });
  }

  Future<void> _toggleExpanded() async {
    final bool next = !_expanded;
    setState(() => _expanded = next);
    await ExpandStateStore.instance.setExpanded(_storageKey, next);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String scheduleLine = formatClassScheduleSummary(widget.schedule);
    final bool hasSchedule =
        widget.schedule != null && widget.schedule!.weekdays.isNotEmpty;
    final bool showBody = !_loaded || _expanded;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(width: 8),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.course.code.isNotEmpty
                      ? widget.course.code.split(' ').first
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    color: scheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap: _hasDetails ? _toggleExpanded : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    widget.course.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.course.professor.isNotEmpty
                                        ? widget.course.professor
                                        : widget.course.name,
                                    style: TextStyle(
                                      color: widget.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_hasDetails)
                              Icon(
                                showBody
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                                color: scheme.primary,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      firstCurve: Curves.easeOutCubic,
                      secondCurve: Curves.easeOutCubic,
                      sizeCurve: Curves.easeOutCubic,
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: showBody
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (widget.onAddSummaryNote != null) ...<Widget>[
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: widget.onAddSummaryNote,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.upload_file_outlined,
                                      size: 14,
                                      color: StudyColors.primary,
                                    ),
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
                                    Icon(
                                      Icons.chevron_right,
                                      size: 16,
                                      color: widget.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (widget.onViewSummaryNote != null) ...<Widget>[
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: widget.onViewSummaryNote,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.description_outlined,
                                      size: 14,
                                      color: StudyColors.primary,
                                    ),
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
                                    Icon(
                                      Icons.chevron_right,
                                      size: 16,
                                      color: widget.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (widget.onEditSchedule != null) ...<Widget>[
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: widget.onEditSchedule,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      hasSchedule
                                          ? Icons.notifications_active_outlined
                                          : Icons.schedule_outlined,
                                      size: 14,
                                      color: hasSchedule
                                          ? StudyColors.primary
                                          : widget.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        scheduleLine,
                                        style: TextStyle(
                                          color: hasSchedule
                                              ? StudyColors.primary
                                              : widget.textSecondary,
                                          fontSize: 12,
                                          fontWeight: hasSchedule
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 16,
                                      color: widget.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      secondChild: const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
              if (widget.showRemove && widget.onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: widget.textSecondary,
                  tooltip: 'Remove',
                  onPressed: widget.onRemove,
                ),
            ],
          ),
        ),
        if (widget.showDivider)
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
