import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:device_calendar/device_calendar.dart';

import '../models/exam_reminder_option.dart';
import '../models/study_plan.dart';
import '../services/exam_notification_service.dart';
import '../services/calendar_sync_service.dart';
import '../services/study_planner_service.dart';
import '../services/subscription_service.dart';
import '../theme/study_theme.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';
import '../widgets/study_calendar.dart';
import '../widgets/study_surface.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  final CalendarSyncService _calendarSync = CalendarSyncService();
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  List<ExamDate> _latestExams = <ExamDate>[];
  List<LinkedCalendarEvent> _linkedEvents = <LinkedCalendarEvent>[];
  bool _syncingCalendar = false;
  String? _linkedCalendarId;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _restoreCalendarLink();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ExamNotificationService.instance.initialize();
      if (mounted) {
        await context.read<StudyPlannerService>().syncExamNotifications();
      }
    });
  }

  Future<void> _restoreCalendarLink() async {
    final String? id = await _calendarSync.selectedCalendarId();
    if (!mounted) return;
    setState(() => _linkedCalendarId = id);
    if (id == null) return;
    try {
      await ExamNotificationService.instance.initialize();
      if (!mounted) return;
      final StudyPlannerService planner = context.read<StudyPlannerService>();
      _latestExams = await planner.watchExams().first;
      await _runCalendarSync();
    } catch (_) {
      // Keep the planner usable if the system calendar is temporarily unavailable.
    }
  }

  Future<void> _syncPlannerChanges(StudyPlannerService planner) async {
    if (_linkedCalendarId == null) return;
    try {
      _latestExams = await planner.watchExams().first;
      await _runCalendarSync();
    } catch (_) {
      // Manual sync remains available from the app bar.
    }
  }

  Future<void> _linkCalendar() async {
    if (_syncingCalendar) return;
    setState(() => _syncingCalendar = true);
    try {
      final List<Calendar> calendars = (await _calendarSync.calendars())
          .where(
            (Calendar calendar) =>
                calendar.id != null && calendar.isReadOnly != true,
          )
          .toList();
      if (!mounted) return;
      if (calendars.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No writable calendar was found. Add a Google or local calendar to your phone first.',
            ),
          ),
        );
        return;
      }

      final Calendar? chosen = await showModalBottomSheet<Calendar>(
        context: context,
        showDragHandle: true,
        builder: (BuildContext context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: Text(
                  'Link a calendar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: calendars.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Calendar calendar = calendars[index];
                    final bool selected = calendar.id == _linkedCalendarId;
                    return ListTile(
                      leading: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.calendar_month_outlined,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(calendar.name ?? 'Calendar'),
                      subtitle: Text(
                        calendar.accountName?.isNotEmpty == true
                            ? calendar.accountName!
                            : 'On this device',
                      ),
                      trailing: calendar.isDefault == true
                          ? const Text(
                              'DEFAULT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : null,
                      onTap: () => Navigator.pop(context, calendar),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
      if (chosen?.id == null || !mounted) return;
      await _calendarSync.selectCalendar(chosen!.id!);
      _linkedCalendarId = chosen.id;
      await _runCalendarSync(showMessage: true);
    } catch (error) {
      if (mounted) StudyMessenger.showError(context, error);
    } finally {
      if (mounted) setState(() => _syncingCalendar = false);
    }
  }

  Future<void> _runCalendarSync({bool showMessage = false}) async {
    final DateTime start = DateTime(
      _focusedMonth.year,
      _focusedMonth.month - 6,
      1,
    );
    final DateTime end = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 7,
      1,
    );
    final CalendarSyncResult result = await _calendarSync.sync(
      gradeGlowEvents: _latestExams,
      rangeStart: start,
      rangeEnd: end,
    );
    if (!mounted) return;
    setState(() => _linkedEvents = result.importedEvents);
    if (showMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Calendar linked · ${result.importedEvents.length} imported · ${result.exportedCount} synced',
          ),
        ),
      );
    }
  }

  static String _dayKey(DateTime d) {
    final DateTime l = d.toLocal();
    return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}';
  }

  static bool _sameDay(DateTime a, DateTime b) {
    final DateTime x = a.toLocal();
    final DateTime y = b.toLocal();
    return x.year == y.year && x.month == y.month && x.day == y.day;
  }

  ({IconData icon, Color color}) _visualFor(String type) {
    final String t = type.toLowerCase();
    if (t.contains('linked calendar')) {
      return (icon: Icons.calendar_month_rounded, color: StudyColors.primary);
    }
    if (t.contains('class') || t.contains('lecture')) {
      return (icon: Icons.school_outlined, color: StudyColors.primary);
    }
    if (t.contains('lab')) {
      return (icon: Icons.science_outlined, color: const Color(0xFF0EA5E9));
    }
    if (t.contains('final') || t.contains('midterm') || t.contains('exam')) {
      return (icon: Icons.event_note_outlined, color: StudyColors.danger);
    }
    if (t.contains('quiz') || t.contains('test')) {
      return (icon: Icons.quiz_outlined, color: StudyColors.warning);
    }
    if (t.contains('assignment') || t.contains('homework')) {
      return (icon: Icons.assignment_outlined, color: const Color(0xFF8B5CF6));
    }
    if (t.contains('presentation')) {
      return (icon: Icons.co_present_outlined, color: const Color(0xFFEC4899));
    }
    if (t.contains('study')) {
      return (icon: Icons.menu_book_outlined, color: StudyColors.success);
    }
    return (icon: Icons.event_outlined, color: StudyColors.primary);
  }

  Future<void> _openAddSheet(StudyPlannerService planner) async {
    final _NewEvent? result = await showModalBottomSheet<_NewEvent>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext ctx) => _AddEventSheet(initialDay: _selectedDay),
    );
    if (result == null || !mounted) return;

    final ExamScheduleResult res = await planner.addExam(
      ExamDate(
        courseCode: result.courseCode,
        examType: result.type,
        date: result.dateTime,
        reminderId: result.reminderId,
      ),
    );
    if (!mounted) return;

    final StringBuffer msg = StringBuffer('${result.type} added.');
    if (!res.permissionGranted) {
      msg.write(' ${res.message ?? "Allow notifications in settings."}');
    } else if (res.approachingAt != null) {
      final DateTime t = res.approachingAt!.toLocal();
      msg.write(' Reminder set for ${DateFormat('MMM d, h:mm a').format(t)}.');
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg.toString())));
    await _syncPlannerChanges(planner);
  }

  @override
  Widget build(BuildContext context) {
    final StudyPlannerService planner = context.watch<StudyPlannerService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study calendar'),
        actions: <Widget>[
          IconButton(
            tooltip: _linkedCalendarId == null
                ? 'Link phone or Google Calendar'
                : 'Sync linked calendar',
            onPressed: _syncingCalendar
                ? null
                : () async {
                    if (_linkedCalendarId == null) {
                      await _linkCalendar();
                    } else {
                      setState(() => _syncingCalendar = true);
                      try {
                        await _runCalendarSync(showMessage: true);
                      } catch (error) {
                        if (mounted) {
                          StudyMessenger.showError(this.context, error);
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _syncingCalendar = false);
                        }
                      }
                    }
                  },
            icon: _syncingCalendar
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _linkedCalendarId == null
                        ? Icons.link_rounded
                        : Icons.sync_rounded,
                  ),
          ),
          IconButton(
            tooltip: 'Generate study plan with AI',
            onPressed: () => _generateWithAi(planner),
            icon: planner.isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<ExamDate>>(
        stream: planner.watchExams(),
        builder:
            (BuildContext context, AsyncSnapshot<List<ExamDate>> examSnap) {
              final List<ExamDate> exams = examSnap.data ?? <ExamDate>[];
              _latestExams = exams;
              return StreamBuilder<List<StudyPlanTask>>(
                stream: planner.watchTasks(),
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<List<StudyPlanTask>> taskSnap,
                    ) {
                      final List<StudyPlanTask> tasks =
                          taskSnap.data ?? <StudyPlanTask>[];
                      return _buildContent(context, planner, exams, tasks);
                    },
              );
            },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    StudyPlannerService planner,
    List<ExamDate> exams,
    List<StudyPlanTask> tasks,
  ) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textPrimary = StudyColors.textPrimary(brightness);
    final Color textSecondary = StudyColors.textSecondary(brightness);

    // Merge user events (exams/classes/tests) and AI study tasks into one list.
    final List<_Event> events = <_Event>[
      for (final ExamDate e in exams)
        _Event(
          at: e.date.toLocal(),
          title: e.courseCode.isEmpty ? e.examType : e.courseCode,
          subtitle: e.examType,
          type: e.examType,
          completed: e.completed,
          examId: e.id,
        ),
      for (final LinkedCalendarEvent e in _linkedEvents)
        _Event(
          at: e.start,
          title: e.title,
          subtitle: e.calendarName,
          type: 'Linked calendar',
          completed: false,
          external: true,
        ),
    ];
    for (int i = 0; i < tasks.length; i++) {
      final StudyPlanTask t = tasks[i];
      events.add(
        _Event(
          at: t.date.toLocal(),
          title: t.title,
          subtitle: t.courseCode.isEmpty ? 'Study session' : t.courseCode,
          type: 'Study session',
          completed: t.completed,
          taskIndex: i,
        ),
      );
    }

    List<_Event> eventsForDay(DateTime day) {
      final List<_Event> list =
          events.where((_Event e) => _sameDay(e.at, day)).toList()
            ..sort((_Event a, _Event b) => a.at.compareTo(b.at));
      return list;
    }

    final Map<String, List<Color>> markersByDay = <String, List<Color>>{};
    for (final _Event e in events) {
      final String key = _dayKey(e.at);
      final Color c = _visualFor(e.type).color;
      final List<Color> list = markersByDay.putIfAbsent(key, () => <Color>[]);
      if (!list.contains(c)) list.add(c);
    }

    final List<_Event> dayEvents = eventsForDay(_selectedDay);
    final List<_Event> monthEvents = events
        .where(
          (_Event event) =>
              event.at.year == _focusedMonth.year &&
              event.at.month == _focusedMonth.month,
        )
        .toList();
    final int completedThisMonth = monthEvents
        .where((_Event event) => event.completed)
        .length;
    final int upcomingThisMonth = monthEvents.length - completedThisMonth;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: <Widget>[
        _PlannerOverview(
          month: _focusedMonth,
          total: monthEvents.length,
          upcoming: upcomingThisMonth,
          completed: completedThisMonth,
        ),
        const SizedBox(height: 14),
        StudySurfaceCard(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: StudyMonthCalendar(
            focusedMonth: _focusedMonth,
            selectedDay: _selectedDay,
            onSelectDay: (DateTime d) => setState(() => _selectedDay = d),
            onFocusMonthChanged: (DateTime m) =>
                setState(() => _focusedMonth = m),
            markerColors: (DateTime day) =>
                markersByDay[_dayKey(day)] ?? const <Color>[],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'DAY AGENDA',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('EEEE, MMMM d').format(_selectedDay),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.25,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                dayEvents.isEmpty
                    ? 'Free day'
                    : '${dayEvents.length} event${dayEvents.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (dayEvents.isEmpty)
          _EmptyDay(
            textSecondary: textSecondary,
            onAdd: () => _openAddSheet(planner),
          )
        else
          ...dayEvents.map(
            (_Event e) => _EventTile(
              event: e,
              visual: _visualFor(e.type),
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onToggle: e.external
                  ? null
                  : () {
                      if (e.examId != null) {
                        planner.toggleExamDone(e.examId!, !e.completed);
                      } else if (e.taskIndex != null) {
                        planner.toggleTask(
                          tasks[e.taskIndex!],
                          e.taskIndex!,
                          tasks,
                        );
                      }
                    },
              onDelete: e.examId == null
                  ? null
                  : () async {
                      await planner.deleteExam(e.examId!);
                      await _syncPlannerChanges(planner);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Removed ${e.title}')),
                      );
                    },
            ),
          ),
      ],
    );
  }

  Future<void> _generateWithAi(StudyPlannerService planner) async {
    final bool isPremium = context.read<SubscriptionService>().isPremium;
    if (!isPremium) {
      await PremiumAccess.showUpgradeDialog(
        context,
        feature: PremiumFeature.studyPlans,
      );
      return;
    }
    try {
      await planner.generatePlan();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI study sessions added to your calendar'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    }
  }
}

class _PlannerOverview extends StatelessWidget {
  const _PlannerOverview({
    required this.month,
    required this.total,
    required this.upcoming,
    required this.completed,
  });

  final DateTime month;
  final int total;
  final int upcoming;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: scheme.onPrimary,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${DateFormat('MMMM').format(month)} overview',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  total == 0
                      ? 'Your month is open and ready to plan.'
                      : '$upcoming upcoming · $completed completed',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.72),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$total',
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// In-memory row combining user events and AI study tasks for the calendar.
class _Event {
  const _Event({
    required this.at,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.completed,
    this.external = false,
    this.examId,
    this.taskIndex,
  });

  final DateTime at;
  final String title;
  final String subtitle;
  final String type;
  final bool completed;
  final bool external;
  final String? examId;
  final int? taskIndex;
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.visual,
    required this.textPrimary,
    required this.textSecondary,
    required this.onToggle,
    required this.onDelete,
  });

  final _Event event;
  final ({IconData icon, Color color}) visual;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback? onToggle;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final bool done = event.completed;
    return StudySurfaceCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: visual.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(visual.icon, color: visual.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: done ? textSecondary : textPrimary,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.subtitle} · ${DateFormat('h:mm a').format(event.at)}',
                  style: TextStyle(color: textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          if (event.external)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.link_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            )
          else
            IconButton(
              tooltip: done ? 'Mark upcoming' : 'Mark done',
              onPressed: onToggle,
              icon: Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? StudyColors.success : visual.color,
              ),
            ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: StudyColors.danger),
            ),
        ],
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.textSecondary, required this.onAdd});

  final Color textSecondary;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wb_sunny_outlined,
              color: scheme.onPrimaryContainer,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Your day is clear',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Add a class, deadline, or focused study block.',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            tooltip: 'Add an event',
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

/// Data returned by the add-event bottom sheet.
class _NewEvent {
  const _NewEvent({
    required this.courseCode,
    required this.type,
    required this.dateTime,
    required this.reminderId,
  });

  final String courseCode;
  final String type;
  final DateTime dateTime;
  final String reminderId;
}

class _AddEventSheet extends StatefulWidget {
  const _AddEventSheet({required this.initialDay});

  final DateTime initialDay;

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final TextEditingController _titleController = TextEditingController();
  String _type = ExamTypeOption.choices.first.label;
  String _reminderId = '30m';
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    final DateTime d = widget.initialDay;
    _date = DateTime(d.year, d.month, d.day);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(
      Theme.of(context).brightness,
    );
    final DateTime combined = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Add to calendar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Title or course (e.g. BIO 101)',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: ExamTypeOption.choices
                .map(
                  (ExamTypeOption t) => DropdownMenuItem<String>(
                    value: t.label,
                    child: Text(t.label),
                  ),
                )
                .toList(),
            onChanged: (String? v) {
              if (v != null) setState(() => _type = v);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(DateFormat('MMM d, yyyy').format(combined)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time_outlined, size: 18),
                  label: Text(DateFormat('h:mm a').format(combined)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _reminderId,
            decoration: const InputDecoration(labelText: 'Remind me'),
            items: ExamReminderOption.choices
                .map(
                  (ExamReminderOption o) => DropdownMenuItem<String>(
                    value: o.id,
                    child: Text(o.label),
                  ),
                )
                .toList(),
            onChanged: (String? v) {
              if (v != null) setState(() => _reminderId = v);
            },
          ),
          const SizedBox(height: 6),
          Text(
            'You\'ll also be notified when it starts.',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final String title = _titleController.text.trim();
                Navigator.of(context).pop(
                  _NewEvent(
                    courseCode: title.isEmpty ? _type : title,
                    type: _type,
                    dateTime: combined,
                    reminderId: _reminderId,
                  ),
                );
              },
              child: const Text('Add to calendar'),
            ),
          ),
        ],
      ),
    );
  }
}
