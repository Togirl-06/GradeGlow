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
    final Course? course = await StudyContentInputActions.pickCourse(
      context,
      courses,
    );
    if (course == null || !context.mounted) return;
    final StudySummary? summary = await action(course);
    if (!context.mounted || summary == null) return;
    await CourseSummaryActions.openGeneratedNote(context, summary);
  }

  @override
  Widget build(BuildContext context) {
    final NotesSummarizerService summarizer = context
        .watch<NotesSummarizerService>();
    final UserService users = context.watch<UserService>();
    final bool isPremium = context.watch<SubscriptionService>().isPremium;
    final SummarizeDailyUsage? summarizeUsage = users.summarizeUsage;
    final AuthService auth = context.watch<AuthService>();
    final CourseService courseService = context.watch<CourseService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Summarize')),
      body: StreamBuilder<UserProfile>(
        stream: users.watchProfile(),
        builder: (BuildContext context, AsyncSnapshot<UserProfile> profileSnap) {
          final UserProfile profile =
              profileSnap.data ??
              UserProfile.empty(
                email: auth.email,
                displayName: auth.displayName,
              );

          return StreamBuilder<List<Course>>(
            stream: courseService.watchMyCourses(profile.courseIds),
            builder: (BuildContext context, AsyncSnapshot<List<Course>> courseSnap) {
              final List<Course> courses = courseSnap.data ?? <Course>[];

              return StreamBuilder<List<StudySummary>>(
                stream: summarizer.watchSummaries(),
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<List<StudySummary>> summarySnap,
                    ) {
                      final List<StudySummary> summaries =
                          summarySnap.data ?? <StudySummary>[];

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        children: <Widget>[
                          _SummarizeHero(
                            courseCount: courses.length,
                            summaryCount: summaries.length,
                          ),
                          const SizedBox(height: 26),
                          const _SummarizeSectionHeader(
                            eyebrow: 'CREATE',
                            title: 'Add learning material',
                            subtitle:
                                'Choose a source and GradeGlow will build the study set.',
                          ),
                          const SizedBox(height: 12),
                          StudyInputCards(
                            enabled: !summarizer.isSummarizing,
                            onUpload: () => _runInput(
                              context,
                              courses,
                              (Course c) => StudyContentInputActions.upload(
                                context,
                                course: c,
                              ),
                            ),
                            onPaste: () async {
                              final Course? course =
                                  await StudyContentInputActions.pickCourse(
                                    context,
                                    courses,
                                  );
                              if (course == null || !context.mounted) return;
                              await StudyContentInputActions.paste(
                                context,
                                course: course,
                              );
                            },
                            onRecord: () async {
                              final Course? course =
                                  await StudyContentInputActions.pickCourse(
                                    context,
                                    courses,
                                  );
                              if (course == null || !context.mounted) return;
                              await StudyContentInputActions.startRecording(
                                context,
                                course: course,
                              );
                            },
                          ),
                          if (!isPremium && summarizeUsage != null) ...<Widget>[
                            const SizedBox(height: 12),
                            _UsageCard(
                              usage: summarizeUsage,
                              detail:
                                  'Free includes ${StudyLimits.freeStudySetsPerCourse} study sets, '
                                  '${StudyLimits.freeFlashcardsPerCourse} cards and '
                                  '${StudyLimits.freeQuizQuestionsPerCourse} quiz questions per course.',
                            ),
                          ],
                          if (summarizer.isSummarizing) ...<Widget>[
                            const SizedBox(height: 12),
                            const _BuildingStudySetCard(),
                          ],
                          const SizedBox(height: 28),
                          Row(
                            children: <Widget>[
                              const Expanded(
                                child: _SummarizeSectionHeader(
                                  eyebrow: 'LIBRARY',
                                  title: 'Your courses',
                                  subtitle:
                                      'Keep every generated study set organized.',
                                ),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => const MyCoursesScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.tune_rounded, size: 17),
                                label: const Text('Manage'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (courses.isEmpty)
                            _EmptyCourseLibrary(
                              onAdd: () {
                                Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => const MyCoursesScreen(),
                                  ),
                                );
                              },
                            )
                          else
                            MyCoursesSection(
                              courses: courses,
                              trackedSemesters: profile.trackedSemesters,
                              courseSchedules: profile.courseSchedules,
                              embedded: true,
                              onAddSummaryNote: (Course course) =>
                                  CourseSummaryActions.addSummaryNote(
                                    context,
                                    course,
                                  ),
                              onViewSummaryNote: (Course course) =>
                                  CourseSummaryActions.viewSummaryNote(
                                    context,
                                    course,
                                    summaries,
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

class _SummarizeHero extends StatelessWidget {
  const _SummarizeHero({required this.courseCount, required this.summaryCount});

  final int courseCount;
  final int summaryCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: scheme.onPrimary,
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Turn any material into\na complete study system',
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: 24,
              height: 1.08,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.65,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your source once. Get structured notes, flashcards, practice questions, and explanations.',
            style: TextStyle(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.72),
              fontSize: 11,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              const _HeroCapability(
                icon: Icons.article_outlined,
                label: 'Smart notes',
              ),
              const _HeroCapability(
                icon: Icons.style_outlined,
                label: 'Flashcards',
              ),
              const _HeroCapability(
                icon: Icons.quiz_outlined,
                label: 'Practice quiz',
              ),
              _HeroCapability(
                icon: Icons.folder_copy_outlined,
                label: '$summaryCount sets · $courseCount courses',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCapability extends StatelessWidget {
  const _HeroCapability({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.onPrimaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: scheme.onPrimaryContainer, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarizeSectionHeader extends StatelessWidget {
  const _SummarizeSectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          eyebrow,
          style: TextStyle(
            color: scheme.primary,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 10.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.usage, required this.detail});

  final SummarizeDailyUsage usage;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double progress = usage.limit == 0
        ? 0
        : (usage.count / usage.limit).clamp(0, 1);
    final Color accent = usage.isAtLimit ? scheme.error : scheme.primary;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.bolt_rounded, color: accent, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  usage.isAtLimit
                      ? 'Daily creation limit reached'
                      : '${usage.remaining} creations remaining today',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${usage.count}/${usage.limit}',
                style: TextStyle(
                  color: accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              color: accent,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            detail,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 8.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildingStudySetCard extends StatelessWidget {
  const _BuildingStudySetCard();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Building your study set',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Organizing concepts and generating practice material…',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCourseLibrary extends StatelessWidget {
  const _EmptyCourseLibrary({required this.onAdd});

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
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.school_outlined,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Build your course library',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Add classes to organize every generated study set.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onAdd,
            tooltip: 'Add courses',
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
