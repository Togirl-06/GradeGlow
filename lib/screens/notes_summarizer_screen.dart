import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/study_summary.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
import '../services/notes_summarizer_service.dart';
import '../services/subscription_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/course_summary_actions.dart';
import '../utils/study_content_input_actions.dart';
import '../utils/study_limits.dart';
import '../widgets/my_courses_section.dart';
import '../widgets/study_input_cards.dart';
import 'my_courses_screen.dart';

class NotesSummarizerScreen extends StatefulWidget {
  const NotesSummarizerScreen({super.key, this.initialCourse});

  /// Opens the add-summary sheet for this course on launch.
  final Course? initialCourse;

  @override
  State<NotesSummarizerScreen> createState() => _NotesSummarizerScreenState();
}

class _NotesSummarizerScreenState extends State<NotesSummarizerScreen> {
  bool _openedInitialCourse = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final SubscriptionService subs = context.read<SubscriptionService>();
      await context.read<UserService>().refreshSummarizeUsage(subs.plan);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_openedInitialCourse || widget.initialCourse == null) return;
    _openedInitialCourse = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CourseSummaryActions.addSummaryNote(context, widget.initialCourse!);
    });
  }

  Future<void> _runInput(
    BuildContext context,
    List<Course> courses,
    Future<StudySummary?> Function(Course course) action,
  ) async {
    final Course? course = await StudyContentInputActions.pickCourse(context, courses);
    if (course == null || !context.mounted) return;
    final StudySummary? summary = await action(course);
    if (!context.mounted || summary == null) return;
    await CourseSummaryActions.openGeneratedNote(context, summary);
  }

  @override
  Widget build(BuildContext context) {
    final NotesSummarizerService summarizer = context.watch<NotesSummarizerService>();
    final UserService users = context.watch<UserService>();
    final bool isPremium = context.watch<SubscriptionService>().isPremium;
    final SummarizeDailyUsage? summarizeUsage = users.summarizeUsage;
    final AuthService auth = context.watch<AuthService>();
    final CourseService courseService = context.watch<CourseService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(title: const Text('Study sets')),
      body: StreamBuilder<UserProfile>(
        stream: users.watchProfile(),
        builder: (BuildContext context, AsyncSnapshot<UserProfile> profileSnap) {
          final UserProfile profile = profileSnap.data ??
              UserProfile.empty(email: auth.email, displayName: auth.displayName);

          return StreamBuilder<List<Course>>(
            stream: courseService.watchMyCourses(profile.courseIds),
            builder: (BuildContext context, AsyncSnapshot<List<Course>> courseSnap) {
              final List<Course> courses = courseSnap.data ?? <Course>[];

              return StreamBuilder<List<StudySummary>>(
                stream: summarizer.watchSummaries(),
                builder: (BuildContext context, AsyncSnapshot<List<StudySummary>> summarySnap) {
                  final List<StudySummary> summaries = summarySnap.data ?? <StudySummary>[];

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      Text(
                        'Upload anything and get interactive notes, flashcards, quizzes, and more',
                        style: TextStyle(color: textSecondary, height: 1.4, fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      StudyInputCards(
                        enabled: !summarizer.isSummarizing,
                        onUpload: () => _runInput(
                          context,
                          courses,
                          (Course c) => StudyContentInputActions.upload(context, course: c),
                        ),
                        onPaste: () async {
                          final Course? course = await StudyContentInputActions.pickCourse(context, courses);
                          if (course == null || !context.mounted) return;
                          await StudyContentInputActions.paste(context, course: course);
                        },
                        onRecord: () async {
                          final Course? course = await StudyContentInputActions.pickCourse(context, courses);
                          if (course == null || !context.mounted) return;
                          await StudyContentInputActions.startRecording(context, course: course);
                        },
                      ),
                      if (!isPremium && summarizeUsage != null) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          summarizeUsage.isAtLimit
                              ? 'Daily limit reached — ${StudyLimits.freeDailySummarizeActions} uploads, pastes & recordings per day on Free'
                              : '${summarizeUsage.remaining} of ${summarizeUsage.limit} uploads, pastes & recordings left today',
                          style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Per course on Free: up to ${StudyLimits.freeStudySetsPerCourse} study sets, '
                          '${StudyLimits.freeFlashcardsPerCourse} flashcards, '
                          '${StudyLimits.freeQuizQuestionsPerCourse} quiz questions',
                          style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
                        ),
                      ],
                      if (summarizer.isSummarizing) ...<Widget>[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(minHeight: 2),
                        const SizedBox(height: 8),
                        Text('Building your study set…', style: TextStyle(color: textSecondary)),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              'My courses',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(builder: (_) => const MyCoursesScreen()),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Manage'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (courses.isEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Add your classes first, then create study sets with Upload, Paste, or Record.',
                              style: TextStyle(color: textSecondary, height: 1.35),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(builder: (_) => const MyCoursesScreen()),
                                );
                              },
                              icon: const Icon(Icons.school_outlined),
                              label: const Text('Add my courses'),
                            ),
                          ],
                        )
                      else
                        MyCoursesSection(
                          courses: courses,
                          trackedSemesters: profile.trackedSemesters,
                          courseSchedules: profile.courseSchedules,
                          embedded: true,
                          onAddSummaryNote: (Course course) => CourseSummaryActions.addSummaryNote(context, course),
                          onViewSummaryNote: (Course course) =>
                              CourseSummaryActions.viewSummaryNote(context, course, summaries),
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
