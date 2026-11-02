import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/study_plan.dart';

class LinkedCalendarEvent {
  const LinkedCalendarEvent({
    required this.id,
    required this.calendarName,
    required this.title,
    required this.start,
    required this.end,
    required this.allDay,
  });

  final String id;
  final String calendarName;
  final String title;
  final DateTime start;
  final DateTime end;
  final bool allDay;
}

class CalendarSyncResult {
  const CalendarSyncResult({
    required this.importedEvents,
    required this.exportedCount,
  });

  final List<LinkedCalendarEvent> importedEvents;
  final int exportedCount;
}

class CalendarSyncService {
  static const String _calendarIdKey = 'linked_device_calendar_id';
  static const String _sourcePrefix = 'GradeGlow event:';

  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  tz.TZDateTime _localTime(DateTime value) {
    final DateTime local = value.toLocal();
    return tz.TZDateTime(
      tz.local,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    );
  }

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> requestAccess() async {
    if (!isSupported) return false;
    final Result<bool> current = await _plugin.hasPermissions();
    if (current.data == true) return true;
    final Result<bool> requested = await _plugin.requestPermissions();
    return requested.data == true;
  }

  Future<List<Calendar>> calendars() async {
    if (!await requestAccess()) return <Calendar>[];
    final Result<UnmodifiableListView<Calendar>> result = await _plugin
        .retrieveCalendars();
    return (result.data ?? <Calendar>[]).toList()
      ..sort((Calendar a, Calendar b) {
        if (a.isDefault == true && b.isDefault != true) return -1;
        if (b.isDefault == true && a.isDefault != true) return 1;
        return (a.name ?? '').compareTo(b.name ?? '');
      });
  }

  Future<String?> selectedCalendarId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_calendarIdKey);
  }

  Future<void> selectCalendar(String calendarId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_calendarIdKey, calendarId);
  }

  Future<void> disconnect() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_calendarIdKey);
  }

  Future<CalendarSyncResult> sync({
    required List<ExamDate> gradeGlowEvents,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    if (!await requestAccess()) {
      throw StateError('Calendar permission was not granted.');
    }

    final List<Calendar> available = await calendars();
    final String? selectedId = await selectedCalendarId();
    final Calendar? destination = available
        .where(
          (Calendar calendar) =>
              calendar.id == selectedId && calendar.isReadOnly != true,
        )
        .firstOrNull;
    if (destination?.id == null) {
      throw StateError('Choose a writable calendar before syncing.');
    }

    final Map<String, Event> exportedBySourceId = <String, Event>{};
    final List<LinkedCalendarEvent> imported = <LinkedCalendarEvent>[];

    for (final Calendar calendar in available) {
      if (calendar.id == null) continue;
      final Result<UnmodifiableListView<Event>> result = await _plugin
          .retrieveEvents(
            calendar.id,
            RetrieveEventsParams(startDate: rangeStart, endDate: rangeEnd),
          );
      for (final Event event in result.data ?? <Event>[]) {
        final String description = event.description ?? '';
        if (description.startsWith(_sourcePrefix)) {
          if (calendar.id == destination!.id) {
            exportedBySourceId[description.substring(_sourcePrefix.length)] =
                event;
          }
          continue;
        }
        if (event.start == null || event.end == null) continue;
        imported.add(
          LinkedCalendarEvent(
            id: '${calendar.id}:${event.eventId ?? event.start!.millisecondsSinceEpoch}',
            calendarName: calendar.name ?? 'Device calendar',
            title: (event.title?.trim().isNotEmpty ?? false)
                ? event.title!.trim()
                : 'Calendar event',
            start: event.start!.toLocal(),
            end: event.end!.toLocal(),
            allDay: event.allDay == true,
          ),
        );
      }
    }

    int exportedCount = 0;
    final Set<String> activeIds = <String>{};
    for (final ExamDate exam in gradeGlowEvents) {
      if (exam.id.isEmpty) continue;
      activeIds.add(exam.id);
      final Event? existing = exportedBySourceId[exam.id];
      final Event deviceEvent = Event(
        destination!.id,
        eventId: existing?.eventId,
        title: exam.courseCode.isEmpty
            ? exam.examType
            : '${exam.courseCode} · ${exam.examType}',
        description: '$_sourcePrefix${exam.id}',
        start: _localTime(exam.date),
        end: _localTime(exam.date.add(const Duration(hours: 1))),
      );
      final Result<String>? result = await _plugin.createOrUpdateEvent(
        deviceEvent,
      );
      if (result?.isSuccess == true) exportedCount++;
    }

    for (final MapEntry<String, Event> entry in exportedBySourceId.entries) {
      if (!activeIds.contains(entry.key) && entry.value.eventId != null) {
        await _plugin.deleteEvent(destination!.id, entry.value.eventId);
      }
    }

    imported.sort(
      (LinkedCalendarEvent a, LinkedCalendarEvent b) =>
          a.start.compareTo(b.start),
    );
    return CalendarSyncResult(
      importedEvents: imported,
      exportedCount: exportedCount,
    );
  }
}
