import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/study_plan.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import '../services/study_planner_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/next_upcoming_event.dart';

/// Dashboard hero card: today's classes and exams (or next scheduled day).
class NextClassExamCard extends StatelessWidget {
  const NextClassExamCard({
    super.key,
    required this.onPrepareExam,
    required this.onPrepareClass,
    required this.onAddSchedule,
  });

  final VoidCallback onPrepareExam;
  final VoidCallback onPrepareClass;
  final VoidCallback onAddSchedule;

  @override
  Widget build(BuildContext context) {
    final UserService users = context.watch<UserService>();
    final AuthService auth = context.watch<AuthService>();
    final CourseService courses = context.watch<CourseService>();
    final StudyPlannerService planner = context.watch<StudyPlannerService>();

    return StreamBuilder<UserProfile>(
      stream: users.watchProfile(),
      builder: (BuildContext context, AsyncSnapshot<UserProfile> profileSnap) {
        final UserProfile profile = profileSnap.data ??
            UserProfile.empty(email: auth.email, displayName: auth.displayName);

        return StreamBuilder<List<Course>>(
          stream: courses.watchMyCourses(profile.courseIds),
          builder: (BuildContext context, AsyncSnapshot<List<Course>> courseSnap) {
            final Map<String, String> codes = <String, String>{
              for (final Course c in courseSnap.data ?? <Course>[]) c.id: c.code,
            };

            return StreamBuilder<List<ExamDate>>(
              stream: planner.watchExams(),
              builder: (BuildContext context, AsyncSnapshot<List<ExamDate>> examSnap) {
                final DashboardScheduleDay? schedule = findDashboardScheduleDay(
                  exams: examSnap.data ?? <ExamDate>[],
                  schedules: profile.courseSchedules,
                  courseCodesById: codes,
                  courseIds: profile.courseIds,
                );

                return _NextClassExamCardBody(
                  schedule: schedule,
                  onPrepareExam: onPrepareExam,
                  onPrepareClass: onPrepareClass,
                  onAddSchedule: onAddSchedule,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _NextClassExamCardBody extends StatelessWidget {
  const _NextClassExamCardBody({
    required this.schedule,
    required this.onPrepareExam,
    required this.onPrepareClass,
    required this.onAddSchedule,
  });

  final DashboardScheduleDay? schedule;
  final VoidCallback onPrepareExam;
  final VoidCallback onPrepareClass;
  final VoidCallback onAddSchedule;

  @override
  Widget build(BuildContext context) {
    final UpcomingEvent? next = schedule?.nextFuture;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[StudyColors.primary, StudyColors.primaryDark],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: StudyColors.primary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -8,
            top: 8,
            bottom: 8,
            child: Transform.rotate(
              angle: 0.12,
              child: Opacity(
                opacity: 0.92,
                child: Container(
                  width: 108,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 100, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Next Class / Exam',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (schedule != null && schedule!.events.isNotEmpty) ...<Widget>[
                  Text(
                    schedule!.dayLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...schedule!.events.map(
                    (UpcomingEvent event) {
                      final bool past = event.isPast;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                event.kind == UpcomingEventKind.exam
                                    ? Icons.quiz_outlined
                                    : Icons.school_outlined,
                                size: 16,
                                color: Colors.white.withValues(alpha: past ? 0.55 : 0.85),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    event.headline,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: past ? 0.7 : 1),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      height: 1.25,
                                    ),
                                  ),
                                  if (past)
                                    Text(
                                      event.statusLabel,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.65),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              event.formattedTime,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: past ? 0.65 : 0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (next != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      'Up next · ${next.statusLabel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: next == null
                        ? null
                        : next.kind == UpcomingEventKind.exam
                            ? onPrepareExam
                            : onPrepareClass,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: StudyColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Prepare Now', style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ] else ...<Widget>[
                  const Text(
                    'Nothing scheduled yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add a class time or exam in your planner.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: onAddSchedule,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: StudyColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Add schedule', style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
