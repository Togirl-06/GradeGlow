import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/chemistry_degree_catalog.dart';
import '../../models/chemistry_degree.dart';
import '../../services/chemistry_progress_service.dart';
import '../../theme/chemistry_degree_theme.dart';
import '../../utils/chemistry_degree_navigation.dart';
import '../../widgets/chemistry/chemistry_degree_widgets.dart';
import 'chemistry_course_screen.dart';
import 'chemistry_lesson_hub_screen.dart';

/// Chemistry hub — browse any track, course, or lesson freely.
class ChemistryDegreeHomeScreen extends StatefulWidget {
  const ChemistryDegreeHomeScreen({super.key});

  @override
  State<ChemistryDegreeHomeScreen> createState() =>
      _ChemistryDegreeHomeScreenState();
}

class _ChemistryDegreeHomeScreenState extends State<ChemistryDegreeHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int? _trackYear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChemistryProgressService>().load();
    });
    _searchController.addListener(
      () => setState(() => _query = _searchController.text),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isSearching => _query.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);
    final ChemistryProgressService progress = context
        .watch<ChemistryProgressService>();
    final ChemistryLessonPath continuePath = progress.currentPath();
    final double overallProgress = progress.degreeMastery;
    final List<ChemistryLessonPath> lessonResults = _isSearching
        ? ChemistryDegreeCatalog.search(_query)
        : const <ChemistryLessonPath>[];
    final List<ChemistryCourseRef> courses = _isSearching
        ? const <ChemistryCourseRef>[]
        : ChemistryDegreeCatalog.coursesForTrack(_trackYear);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chemistry',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: <Widget>[
          _HeroWelcome(progress: progress, overallProgress: overallProgress),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search courses, modules, lessons…',
            ),
          ),
          if (!_isSearching) ...<Widget>[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _TrackChip(
                    label: 'All',
                    selected: _trackYear == null,
                    onTap: () => setState(() => _trackYear = null),
                  ),
                  ...ChemistryDegreeCatalog.years.map(
                    (ChemistryDegreeYear year) => _TrackChip(
                      label: year.title,
                      selected: _trackYear == year.year,
                      onTap: () => setState(() => _trackYear = year.year),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _ContinueCard(
              path: continuePath,
              mastery: progress.lessonMastery(continuePath.lesson.id),
              readiness: progress.readinessLabel(continuePath),
              onContinue: () => _openLesson(context, continuePath),
            ),
            const SizedBox(height: 24),
            const ChemDegreeSectionHeader(
              title: 'Browse Courses',
              subtitle: 'Jump to any topic — no required order',
            ),
            ...courses.map(
              (ChemistryCourseRef ref) => _CourseCard(
                ref: ref,
                mastery: progress.courseMastery(ref.course),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChemistryCourseScreen(
                      year: ref.year,
                      course: ref.course,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...<Widget>[
            const SizedBox(height: 20),
            const ChemDegreeSectionHeader(
              title: 'Search Results',
              subtitle: 'Tap any lesson to open it directly',
            ),
            if (lessonResults.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'No matches for "$_query"',
                  style: TextStyle(color: c.textPrimary.withValues(alpha: 0.7)),
                ),
              )
            else
              ...lessonResults.map(
                (ChemistryLessonPath path) => _LessonResultCard(
                  path: path,
                  mastery: progress.lessonMastery(path.lesson.id),
                  onTap: () => _openLesson(context, path),
                ),
              ),
          ],
          if (progress.earnedBadges.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            const ChemDegreeSectionHeader(title: 'Achievements'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: progress.earnedBadges.map((String id) {
                return Chip(
                  avatar: const Text('🏆', style: TextStyle(fontSize: 14)),
                  label: Text(badgeLabel(id)),
                  backgroundColor: c.surfaceElevated,
                  labelStyle: TextStyle(
                    color: c.primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(color: c.primary.withValues(alpha: 0.35)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _openLesson(BuildContext context, ChemistryLessonPath path) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChemistryLessonHubScreen(path: path),
      ),
    );
  }
}

class _TrackChip extends StatelessWidget {
  const _TrackChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          color: selected ? Colors.white : c.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        selectedColor: c.primary,
        backgroundColor: c.surfaceElevated,
        side: BorderSide(color: selected ? c.primary : c.border),
        showCheckmark: false,
      ),
    );
  }
}

class _HeroWelcome extends StatelessWidget {
  const _HeroWelcome({required this.progress, required this.overallProgress});

  final ChemistryProgressService progress;
  final double overallProgress;

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: c.heroGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Chemistry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${ChemistryDegreeCatalog.totalLessons} lessons · '
                  '${progress.earnedBadges.length} badges',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ChemDegreeProgressRing(
            progress: overallProgress,
            label: 'Overall',
            size: 84,
            onColoredBackground: true,
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.path,
    required this.mastery,
    required this.readiness,
    required this.onContinue,
  });

  final ChemistryLessonPath path;
  final double mastery;
  final String readiness;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: c.cardDecoration(
        borderColor: c.primary.withValues(alpha: 0.45),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(path.course.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Continue',
                      style: TextStyle(
                        color: c.primaryLight.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      path.course.title,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      '${path.module.title}: ${path.lesson.title}',
                      style: TextStyle(
                        color: c.textPrimary.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ChemDegreeMasteryBar(mastery: mastery),
          const SizedBox(height: 8),
          Text(
            '${mastery.round()}% · $readiness · ${path.year.title}',
            style: TextStyle(
              color: c.textPrimary.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue →',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.ref,
    required this.mastery,
    required this.onTap,
  });

  final ChemistryCourseRef ref;
  final double mastery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: c.cardDecoration(),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Text(ref.course.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        ref.course.title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ref.year.title,
                        style: TextStyle(
                          color: c.primaryLight.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (ref.course.tagline != null)
                        Text(
                          ref.course.tagline!,
                          style: TextStyle(
                            color: c.textPrimary.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '${ref.course.lessonCount} topics',
                        style: TextStyle(
                          color: c.textPrimary.withValues(alpha: 0.55),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ChemDegreeMasteryBar(mastery: mastery),
                    ],
                  ),
                ),
                Text(
                  '${mastery.round()}%',
                  style: TextStyle(
                    color: c.primary,
                    fontWeight: FontWeight.w900,
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

class _LessonResultCard extends StatelessWidget {
  const _LessonResultCard({
    required this.path,
    required this.mastery,
    required this.onTap,
  });

  final ChemistryLessonPath path;
  final double mastery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: c.cardDecoration(),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Text(path.course.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        path.lesson.title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${path.year.title} · ${path.course.title} · ${path.module.title}',
                        style: TextStyle(
                          color: c.textPrimary.withValues(alpha: 0.65),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ChemDegreeMasteryBar(mastery: mastery),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: c.textPrimary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
