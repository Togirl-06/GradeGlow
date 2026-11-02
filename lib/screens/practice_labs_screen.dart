import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/virtual_university.dart';
import '../data/health_faculty_catalog.dart';
import '../data/practice_lab_university_catalog.dart';
import '../models/health_faculty_program.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_subject.dart';
import '../models/virtual_university_dashboard.dart';
import '../services/biology_progress_service.dart';
import '../services/business_school_progress_service.dart';
import '../services/physics_progress_service.dart';
import '../services/chemistry_progress_service.dart';
import '../services/health_faculty_progress_service.dart';
import '../services/mathematics_progress_service.dart';
import '../services/openai_service.dart';
import '../services/practice_lab_service.dart';
import '../services/virtual_university_dashboard_service.dart';
import '../theme/university_dashboard_colors.dart';
import '../utils/practice_lab_limits.dart';
import '../widgets/practice_lab/practice_lab_usage_banner.dart';
import '../widgets/virtual_university/vu_accessibility.dart';
import '../navigation/faculty_entry_routes.dart';
import 'curriculum/world_curriculum_home_screen.dart';
import 'english/english_program_screen.dart';
import 'engineering/engineering_program_screen.dart';
import 'biology/biology_degree_home_screen.dart';
import 'business/business_school_screen.dart';
import 'chemistry/chemistry_degree_home_screen.dart';
import 'health/health_course_screen.dart';
import 'health/health_faculty_home_screen.dart';
import 'health/health_lesson_hub_screen.dart';
import 'physics/physics_degree_home_screen.dart';
import 'science/science_school_screen.dart';
import 'mathematics/mathematics_degree_home_screen.dart';
import 'computer_science/cs_program_screen.dart';
import 'virtual_university/vu_campus_dashboard_body.dart';
import 'membership_screen.dart';
import '../models/world_curriculum_program.dart';
import '../services/auth_service.dart';
import '../services/world_curriculum_progress_service.dart';

/// Virtual University — subject browser with search and session stats.
class PracticeLabsScreen extends StatefulWidget {
  const PracticeLabsScreen({super.key});

  @override
  State<PracticeLabsScreen> createState() => _PracticeLabsScreenState();
}

class _PracticeLabsScreenState extends State<PracticeLabsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _query = '';
  VuDashboardSnapshot? _dashboard;
  final GlobalKey _browseKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PracticeLabService>().refreshUsage();
      unawaited(_refreshDashboard());
    });
    _searchController.addListener(
      () => setState(() => _query = _searchController.text),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshDashboard() async {
    if (!mounted) return;
    try {
      final VirtualUniversityDashboardService dash = context
          .read<VirtualUniversityDashboardService>();
      final BusinessSchoolProgressService business = context
          .read<BusinessSchoolProgressService>();
      dash.setBusiness(business);
      try {
        final List<PracticeLabRecord> records = await context
            .read<PracticeLabService>()
            .watchHistory()
            .first
            .timeout(const Duration(seconds: 2));
        if (!mounted) return;
        dash.setLabRecords(records);
      } on TimeoutException {
        // Keep prior lab records — do not wipe streak/XP on slow network.
      } catch (_) {
        // Keep prior lab records on history errors.
      }
      final VuDashboardSnapshot snap = await dash.snapshot(
        welcomeName: () {
          try {
            return context.read<AuthService>().displayName;
          } catch (_) {
            return 'Student';
          }
        }(),
      );
      if (!mounted) return;
      setState(() => _dashboard = snap);
    } catch (_) {
      // Dashboard is optional; faculty grid still works.
    }
  }

  List<PracticeLabSubject> get _subjects {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return PracticeLabUniversityCatalog.subjects;
    return PracticeLabUniversityCatalog.subjects
        .where((PracticeLabSubject s) => s.name.toLowerCase().contains(q))
        .toList();
  }

  void _scrollToBrowse() {
    final BuildContext? target = _browseKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _openSubject(PracticeLabSubject subject) async {
    // Do not fake Continue Learning here — real lesson opens record progress.
    if (!mounted) return;

    switch (subject.id) {
      case 'mathematics':
        final MathematicsProgressService progress = context
            .read<MathematicsProgressService>();
        final OpenAiService openAi = context.read<OpenAiService>();
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MultiProvider(
              providers: [
                Provider<OpenAiService>.value(value: openAi),
                ChangeNotifierProvider<MathematicsProgressService>.value(
                  value: progress,
                ),
              ],
              child: const MathematicsDegreeHomeScreen(),
            ),
          ),
        );
      case 'chemistry':
        final ChemistryProgressService progress = context
            .read<ChemistryProgressService>();
        final OpenAiService openAi = context.read<OpenAiService>();
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MultiProvider(
              providers: [
                Provider<OpenAiService>.value(value: openAi),
                ChangeNotifierProvider<ChemistryProgressService>.value(
                  value: progress,
                ),
              ],
              child: const ChemistryDegreeHomeScreen(),
            ),
          ),
        );
      case 'biology':
        final BiologyProgressService progress = context
            .read<BiologyProgressService>();
        final OpenAiService openAi = context.read<OpenAiService>();
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MultiProvider(
              providers: [
                Provider<OpenAiService>.value(value: openAi),
                ChangeNotifierProvider<BiologyProgressService>.value(
                  value: progress,
                ),
              ],
              child: const BiologyDegreeHomeScreen(),
            ),
          ),
        );
      case 'english':
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const EnglishProgramScreen(),
          ),
        );
      case 'environmental_science':
      case 'political_science':
        final WorldSubjectMeta? meta = WorldSubjectMeta.fromSubjectId(
          subject.id,
        );
        if (meta != null) {
          final WorldCurriculumProgressService world = context
              .read<WorldCurriculumProgressService>();
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MultiProvider(
                providers: [
                  ChangeNotifierProvider<WorldCurriculumProgressService>.value(
                    value: world,
                  ),
                ],
                child: WorldCurriculumHomeScreen(meta: meta),
              ),
            ),
          );
        }
      case 'computer_science':
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const CsProgramScreen()),
        );
      case 'engineering':
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const EngineeringProgramScreen(),
          ),
        );
      case 'law':
        await FacultyEntryRoutes.openLaw(context);
      case 'physics':
        final PhysicsProgressService progress = context
            .read<PhysicsProgressService>();
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ChangeNotifierProvider<PhysicsProgressService>.value(
                  value: progress,
                  child: const PhysicsDegreeHomeScreen(),
                ),
          ),
        );
      case 'sciences':
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ScienceSchoolScreen()),
        );
      case 'business':
        final BusinessSchoolProgressService progress = context
            .read<BusinessSchoolProgressService>();
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ChangeNotifierProvider<BusinessSchoolProgressService>.value(
                  value: progress,
                  child: const BusinessSchoolScreen(),
                ),
          ),
        );
      case 'nursing':
      case 'medicine':
      case 'psychology':
        final HealthFaculty faculty = switch (subject.id) {
          'medicine' => HealthFaculty.medicine,
          'psychology' => HealthFaculty.psychology,
          _ => HealthFaculty.nursing,
        };
        final HealthFacultyProgressService health = context
            .read<HealthFacultyProgressService>();
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ChangeNotifierProvider<HealthFacultyProgressService>.value(
                  value: health,
                  child: HealthFacultyHomeScreen(faculty: faculty),
                ),
          ),
        );
      default:
        break;
    }
    if (mounted) unawaited(_refreshDashboard());
  }

  Future<void> _openSearchHit(UniversitySearchHit hit) async {
    final HealthFaculty? faculty = HealthFaculty.fromId(hit.subject.id);
    if (faculty != null &&
        hit.course != null &&
        (hit.kind == UniversitySearchKind.course ||
            hit.kind == UniversitySearchKind.topic ||
            hit.kind == UniversitySearchKind.unit)) {
      final List<HealthCourse> courses =
          HealthFacultyCatalog.coursesFor(faculty);
      final int courseIndex = courses.indexWhere(
        (HealthCourse c) =>
            c.title.toLowerCase() == hit.course!.name.toLowerCase(),
      );
      if (courseIndex >= 0) {
        final HealthCourse course = courses[courseIndex];
        final HealthFacultyProgressService health = context
            .read<HealthFacultyProgressService>();
          if (hit.topic != null) {
            HealthTopic? topic;
            for (final HealthTopic t in course.topics) {
              if (t.title.toLowerCase() == hit.topic!.name.toLowerCase()) {
                topic = t;
                break;
              }
            }
            if (topic != null) {
              final HealthTopic opened = topic;
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ChangeNotifierProvider<HealthFacultyProgressService>.value(
                        value: health,
                        child: HealthLessonHubScreen(
                          path: HealthLessonPath(
                            faculty: faculty,
                            course: course,
                            topic: opened,
                          ),
                        ),
                      ),
                ),
              );
              if (mounted) unawaited(_refreshDashboard());
              return;
            }
          }
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ChangeNotifierProvider<HealthFacultyProgressService>.value(
                  value: health,
                  child: HealthCourseScreen(
                    faculty: faculty,
                    course: course,
                    courseIndex: courseIndex,
                  ),
                ),
          ),
        );
        if (mounted) unawaited(_refreshDashboard());
        return;
      }
    }
    await _openSubject(hit.subject);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _query.trim().isNotEmpty;
    final List<UniversitySearchHit> deepHits = isSearching
        ? PracticeLabUniversityCatalog.search(_query)
        : const <UniversitySearchHit>[];
    final List<PracticeLabSubject> matches = _subjects;
    final List<PracticeLabSubject> subjects = matches
        .where((PracticeLabSubject subject) => subject.id != 'sciences')
        .toList();
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final PracticeLabService labs = context.watch<PracticeLabService>();
    final PracticeLabUsage? usage = labs.usage;
    final UniversityDashboardColors dashboard = UniversityDashboardColors.of(
      context,
    );

    return VuReduceMotion(
      child: Scaffold(
        backgroundColor: dashboard.page,
        appBar: AppBar(
          backgroundColor: dashboard.page,
          surfaceTintColor: Colors.transparent,
          title: Text(
            VirtualUniversity.name,
            style: TextStyle(
              color: dashboard.text,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
        body: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: <Widget>[
            if (_dashboard != null && !isSearching) ...<Widget>[
              VuCampusDashboardBody(
                snapshot: _dashboard!,
                onBrowseFaculties: _scrollToBrowse,
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search subjects, courses, lessons, topics…',
                filled: true,
                fillColor: dashboard.card,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: scheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                ),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: _searchController.clear,
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: dashboard.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
              ),
            ),
            if (usage != null) ...<Widget>[
              const SizedBox(height: 16),
              PracticeLabUsageBanner(
                remaining: usage.remaining,
                limit: PracticeLabLimits.freeSimulationsPerMonth,
                isPremium: usage.isPremium,
              ),
            ],
            if (isSearching && deepHits.isNotEmpty) ...<Widget>[
              const SizedBox(height: 20),
              _UniversitySectionHeader(
                eyebrow: 'SEARCH',
                title: 'Matching lessons & courses',
                subtitle: 'Results across the university catalog.',
                trailing: '${deepHits.length} hits',
              ),
              const SizedBox(height: 10),
              ...deepHits.take(20).map((UniversitySearchHit hit) {
                final String title = switch (hit.kind) {
                  UniversitySearchKind.subject => hit.subject.name,
                  UniversitySearchKind.course => hit.course?.name ?? '',
                  UniversitySearchKind.unit => hit.unit?.name ?? '',
                  UniversitySearchKind.topic => hit.topic?.name ?? '',
                };
                final String subtitle = switch (hit.kind) {
                  UniversitySearchKind.subject => 'Faculty',
                  UniversitySearchKind.course => hit.subject.name,
                  UniversitySearchKind.unit =>
                    '${hit.subject.name} · ${hit.course?.name ?? ''}',
                  UniversitySearchKind.topic =>
                    '${hit.subject.name} · ${hit.course?.name ?? ''}',
                };
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(hit.subject.emoji),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(subtitle),
                  onTap: () => unawaited(_openSearchHit(hit)),
                );
              }),
            ],
            KeyedSubtree(
              key: _browseKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (subjects.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 24),
                    _UniversitySectionHeader(
                      eyebrow: isSearching ? 'FACULTIES' : 'BROWSE CATEGORIES',
                      title: isSearching
                          ? 'Matching programs'
                          : 'Explore every field',
                      subtitle: isSearching
                          ? 'Programs matching “${_query.trim()}”.'
                          : 'Build university-level knowledge through guided courses and practical work.',
                      trailing: '${subjects.length} programs',
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (subjects.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          isSearching
                              ? 'No subjects match "$_query"'
                              : 'No subjects available.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final int columns = constraints.maxWidth >= 1080
                                ? 4
                                : constraints.maxWidth >= 760
                                ? 3
                                : 2;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    mainAxisExtent: columns == 2 ? 208 : 222,
                                  ),
                              itemCount: subjects.length,
                              itemBuilder: (BuildContext context, int index) {
                                final PracticeLabSubject subject =
                                    subjects[index];
                                final bool wired = switch (subject.id) {
                                  'mathematics' ||
                                  'chemistry' ||
                                  'biology' ||
                                  'english' ||
                                  'computer_science' ||
                                  'engineering' ||
                                  'law' ||
                                  'physics' ||
                                  'sciences' ||
                                  'business' ||
                                  'nursing' ||
                                  'medicine' ||
                                  'psychology' ||
                                  'environmental_science' ||
                                  'political_science' => true,
                                  _ => false,
                                };
                                return _SubjectCard(
                                  subject: subject,
                                  onTap: wired
                                      ? () => unawaited(_openSubject(subject))
                                      : null,
                                );
                              },
                            );
                          },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UniversitySectionHeader extends StatelessWidget {
  const _UniversitySectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                eyebrow,
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.3,
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
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            trailing,
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, this.onTap});

  final PracticeLabSubject subject;
  final VoidCallback? onTap;

  Color get _accent {
    if (subject.id == 'sciences' || subject.id == 'biology') {
      return const Color(0xFF20C878);
    }
    if (subject.id == 'business' ||
        subject.id == 'economics' ||
        subject.id == 'finance' ||
        subject.id == 'marketing' ||
        subject.id == 'accounting') {
      return const Color(0xFFFF9A2F);
    }
    return switch (subject.groupId) {
      'science' => const Color(0xFF2EB8FF),
      'computer_technology' => const Color(0xFFA855F7),
      'engineering' => const Color(0xFF11B8C8),
      'health_medical' => const Color(0xFF18C6A3),
      'law_criminal_justice' => const Color(0xFFE69734),
      'humanities' => const Color(0xFF26C889),
      _ => const Color(0xFF8B5CF6),
    };
  }

  @override
  Widget build(BuildContext context) {
    final UniversityDashboardColors dashboard = UniversityDashboardColors.of(
      context,
    );
    return Material(
      color: dashboard.card,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _accent.withValues(alpha: 0.28)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[_accent.withValues(alpha: 0.12), dashboard.card],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _accent.withValues(alpha: .07),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        subject.emoji,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            subject.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: dashboard.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${subject.courses.length} courses · AI learning',
                            style: TextStyle(
                              color: dashboard.mutedText,
                              fontSize: 7.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_outward_rounded,
                        color: _accent,
                        size: 17,
                      ),
                  ],
                ),
                const SizedBox(height: 9),
                Container(
                  height: 62,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: <Color>[
                        _accent.withValues(alpha: 0.28),
                        dashboard.elevatedCard,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        right: 12,
                        top: 6,
                        child: Icon(
                          subject.icon,
                          size: 46,
                          color: _accent.withValues(alpha: 0.75),
                        ),
                      ),
                      Positioned(
                        left: 9,
                        bottom: 9,
                        child: Text(
                          subject.id == 'business' || subject.id == 'sciences'
                              ? 'ENTER SCHOOL'
                              : 'EXPLORE PROGRAM',
                          style: TextStyle(
                            color: _accent,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Featured courses',
                  style: TextStyle(
                    color: dashboard.mutedText,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final int visibleCourses = constraints.maxWidth < 180
                              ? 2
                              : 4;
                          return Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: subject.courses.take(visibleCourses).map((
                              course,
                            ) {
                              return Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 112,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _accent.withValues(alpha: 0.11),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _accent.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Text(
                                  course.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: dashboard.text,
                                    fontSize: 7.2,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
