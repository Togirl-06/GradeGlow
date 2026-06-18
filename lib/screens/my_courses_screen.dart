import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/course_schedule.dart';
import '../models/study_summary.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/class_notification_service.dart';
import '../services/course_service.dart';
import '../services/exam_notification_service.dart';
import '../services/notes_summarizer_service.dart';
import '../services/user_service.dart';
import '../utils/course_summary_actions.dart';
import '../theme/study_theme.dart';
import '../widgets/class_schedule_fields.dart';
import '../widgets/my_courses_section.dart';
import '../utils/study_messenger.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  bool _addingCourse = false;
  bool _syncedClassReminders = false;

  Future<void> _syncClassReminders(UserProfile profile, List<Course> courses) async {
    if (_syncedClassReminders || profile.courseSchedules.isEmpty) return;
    _syncedClassReminders = true;
    try {
      await ExamNotificationService.instance.initialize();
      final Map<String, String> codes = <String, String>{
        for (final Course c in courses) c.id: c.code,
      };
      await ClassNotificationService.instance.rescheduleAll(profile.courseSchedules, codes);
    } catch (_) {}
  }

  Future<void> _showAddSemesterDialog() async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => const _AddSemesterDialog(),
    );
    if (result == null || result.isEmpty || !mounted) return;

    await context.read<UserService>().addTrackedSemester(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added $result')));
  }

  Future<void> _showAddClassSheet(String semester, String school) async {
    final _AddClassResult? result = await showModalBottomSheet<_AddClassResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => _AddClassSheet(semester: semester),
    );

    if (result == null || !mounted) return;

    setState(() => _addingCourse = true);
    try {
      final CourseService courses = context.read<CourseService>();
      final UserService users = context.read<UserService>();
      final Course course = await courses.addCourse(
        code: result.code,
        professor: result.professor,
        semester: semester,
        school: school,
      );
      await users.addCourseToProfile(course.id);
      await users.addTrackedSemester(semester);

      if (result.weekdays.isNotEmpty) {
        final CourseSchedule schedule = buildScheduleFromFields(
          courseId: course.id,
          weekdays: result.weekdays,
          time: result.time,
          reminderId: result.reminderId,
        );
        final ClassScheduleResult reminderResult = await users.setCourseSchedule(
          schedule: schedule,
          courseCode: course.code,
        );
        if (!mounted) return;
        if (reminderResult.message != null && reminderResult.scheduledCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(reminderResult.message!)));
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${course.code} to $semester')),
      );
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    } finally {
      if (mounted) setState(() => _addingCourse = false);
    }
  }

  Future<void> _confirmRemoveSemester(String semester, List<Course> courses) async {
    final List<Course> inSemester = coursesForSemester(courses, semester);
    if (inSemester.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remove all classes in this semester first.')),
      );
      return;
    }

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Remove semester?'),
        content: Text('Remove "$semester" from your list?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: StudyColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<UserService>().removeTrackedSemester(semester);
  }

  Future<void> _showEditScheduleSheet(Course course, CourseSchedule? existing) async {
    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => _EditClassScheduleSheet(
        course: course,
        existing: existing,
      ),
    );
    if (saved != true || !mounted) return;
  }

  Future<void> _openSummaryNote(Course course, List<StudySummary> summaries) {
    return CourseSummaryActions.viewSummaryNote(context, course, summaries);
  }

  Future<void> _addSummaryNote(Course course) {
    return CourseSummaryActions.addSummaryNote(context, course);
  }

  @override
  Widget build(BuildContext context) {
    final UserService users = context.watch<UserService>();
    final AuthService auth = context.watch<AuthService>();
    final CourseService courseService = context.watch<CourseService>();
    final NotesSummarizerService summarizer = context.watch<NotesSummarizerService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(title: const Text('My courses')),
      body: StreamBuilder<UserProfile>(
        stream: users.watchProfile(),
        builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
          final UserProfile profile = snapshot.data ??
              UserProfile.empty(email: auth.email, displayName: auth.displayName);

          return StreamBuilder<List<Course>>(
            stream: courseService.watchMyCourses(profile.courseIds),
            builder: (BuildContext context, AsyncSnapshot<List<Course>> courseSnap) {
              final List<Course> myCourses = courseSnap.data ?? <Course>[];
              final String school = profile.school;
              _syncClassReminders(profile, myCourses);

              return StreamBuilder<List<StudySummary>>(
                stream: summarizer.watchSummaries(),
                builder: (BuildContext context, AsyncSnapshot<List<StudySummary>> summarySnap) {
                  final List<StudySummary> summaries = summarySnap.data ?? <StudySummary>[];

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: <Widget>[
                      Text(
                        'Organize classes by semester. Tap a semester box to add CHEM 1211, BIOL 1107, and more.',
                        style: TextStyle(color: textSecondary, height: 1.35),
                      ),
                      const SizedBox(height: 16),
                      if (_addingCourse)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: LinearProgressIndicator(),
                        ),
                      MyCoursesSection(
                        courses: myCourses,
                        trackedSemesters: profile.trackedSemesters,
                        courseSchedules: profile.courseSchedules,
                        showRemove: true,
                        onAddCourseForSemester: (String semester) => _showAddClassSheet(semester, school),
                        onRemoveCourse: (Course c) => users.removeCourseFromProfile(c.id),
                        onEditSchedule: (Course c) => _showEditScheduleSheet(c, profile.courseSchedules[c.id]),
                        onAddSummaryNote: _addSummaryNote,
                        onViewSummaryNote: (Course c) => _openSummaryNote(c, summaries),
                        onRemoveSemester: (String semester) => _confirmRemoveSemester(semester, myCourses),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _showAddSemesterDialog,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text('Add semester'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AddClassResult {
  const _AddClassResult({
    required this.code,
    required this.professor,
    required this.weekdays,
    required this.time,
    required this.reminderId,
  });

  final String code;
  final String professor;
  final Set<int> weekdays;
  final TimeOfDay time;
  final String reminderId;
}

class _AddSemesterDialog extends StatefulWidget {
  const _AddSemesterDialog();

  @override
  State<_AddSemesterDialog> createState() => _AddSemesterDialogState();
}

class _AddSemesterDialogState extends State<_AddSemesterDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: suggestedCurrentSemester());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _alternateSemester(String current) {
    if (current.toLowerCase().startsWith('fall')) {
      return 'Spring ${DateTime.now().year}';
    }
    return 'Fall ${DateTime.now().year}';
  }

  @override
  Widget build(BuildContext context) {
    final String current = suggestedCurrentSemester();
    return AlertDialog(
      title: const Text('Add semester'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Semester name',
              hintText: 'Spring 2026',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: <Widget>[
              ActionChip(
                label: Text(current),
                onPressed: () => setState(() => _controller.text = current),
              ),
              ActionChip(
                label: Text(_alternateSemester(current)),
                onPressed: () => setState(() => _controller.text = _alternateSemester(current)),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Add semester'),
        ),
      ],
    );
  }
}

class _AddClassSheet extends StatefulWidget {
  const _AddClassSheet({required this.semester});

  final String semester;

  @override
  State<_AddClassSheet> createState() => _AddClassSheetState();
}

class _AddClassSheetState extends State<_AddClassSheet> {
  late final TextEditingController _codeController = TextEditingController();
  late final TextEditingController _professorController = TextEditingController();
  Set<int> _weekdays = <int>{1, 3, 5};
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  String _reminderId = '30m';

  @override
  void dispose() {
    _codeController.dispose();
    _professorController.dispose();
    super.dispose();
  }

  void _submit() {
    final String code = _codeController.text.trim();
    final String professor = _professorController.text.trim();
    if (code.isEmpty || professor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter course code and professor.')),
      );
      return;
    }
    Navigator.pop(
      context,
      _AddClassResult(
        code: code,
        professor: professor,
        weekdays: _weekdays,
        time: _time,
        reminderId: _reminderId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Add class — ${widget.semester}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Course code',
              hintText: 'CHEM 1211',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _professorController,
            decoration: const InputDecoration(labelText: 'Professor'),
          ),
          const SizedBox(height: 20),
          ClassScheduleFields(
            selectedWeekdays: _weekdays,
            onWeekdaysChanged: (Set<int> days) => setState(() => _weekdays = days),
            time: _time,
            onTimeChanged: (TimeOfDay t) => setState(() => _time = t),
            reminderId: _reminderId,
            onReminderChanged: (String id) => setState(() => _reminderId = id),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _submit, child: const Text('Add class')),
        ],
      ),
    );
  }
}

class _EditClassScheduleSheet extends StatefulWidget {
  const _EditClassScheduleSheet({required this.course, this.existing});

  final Course course;
  final CourseSchedule? existing;

  @override
  State<_EditClassScheduleSheet> createState() => _EditClassScheduleSheetState();
}

class _EditClassScheduleSheetState extends State<_EditClassScheduleSheet> {
  late Set<int> _weekdays = widget.existing != null ? widget.existing!.weekdays.toSet() : <int>{1, 3, 5};
  late TimeOfDay _time = widget.existing != null
      ? TimeOfDay(hour: widget.existing!.hour, minute: widget.existing!.minute)
      : const TimeOfDay(hour: 10, minute: 0);
  late String _reminderId = widget.existing?.reminderId ?? '30m';
  bool _saving = false;

  Future<void> _save() async {
    if (_weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one class day.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final CourseSchedule schedule = buildScheduleFromFields(
        courseId: widget.course.id,
        weekdays: _weekdays,
        time: _time,
        reminderId: _reminderId,
      );
      final ClassScheduleResult result = await context.read<UserService>().setCourseSchedule(
        schedule: schedule,
        courseCode: widget.course.code,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      if (result.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message!)));
      }
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '${widget.course.code} — class time',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ClassScheduleFields(
            selectedWeekdays: _weekdays,
            onWeekdaysChanged: (Set<int> days) => setState(() => _weekdays = days),
            time: _time,
            onTimeChanged: (TimeOfDay t) => setState(() => _time = t),
            reminderId: _reminderId,
            onReminderChanged: (String id) => setState(() => _reminderId = id),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save class time & reminders'),
          ),
        ],
      ),
    );
  }
}
