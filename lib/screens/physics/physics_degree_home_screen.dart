import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/physics/physics_catalog.dart';
import '../../data/physics_degree_catalog.dart';
import '../../models/physics/physics_program.dart';
import '../../models/physics_degree.dart';
import '../../services/physics_progress_service.dart';
import '../../theme/physics_degree_theme.dart';
import '../../utils/physics_degree_navigation.dart';
import '../../widgets/physics/physics_degree_widgets.dart';
import 'physics_degree_course_screen.dart';
import 'physics_degree_lesson_hub_screen.dart';

/// Physics hub — browse any level, course, or topic freely.
class PhysicsDegreeHomeScreen extends StatefulWidget {
  const PhysicsDegreeHomeScreen({super.key});

  @override
  State<PhysicsDegreeHomeScreen> createState() =>
      _PhysicsDegreeHomeScreenState();
}

class _PhysicsDegreeHomeScreenState extends State<PhysicsDegreeHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  PhysicsLevel? _levelFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PhysicsProgressService>().load();
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
    final PhysicsDegreeColors c = PhysicsDegreeTheme.of(context);
    final PhysicsProgressService progress = context
        .watch<PhysicsProgressService>();
    final PhysicsLessonPath continuePath = progress.currentPath();
    final double overallProgress = progress.degreeMastery;
    final List<PhysicsLessonPath> lessonResults = _isSearching
        ? PhysicsDegreeCatalog.search(_query)
        : const <PhysicsLessonPath>[];
    final List<PhysicsCourseRef> courses = _isSearching
        ? const <PhysicsCourseRef>[]
        : PhysicsDegreeCatalog.coursesForLevel(_levelFilter);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Physics',
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
              hintText: 'Search courses, tracks, topics…',
            ),
          ),
          if (!_isSearching) ...<Widget>[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _LevelChip(
                    label: 'All',
                    selected: _levelFilter == null,
                    onTap: () => setState(() => _levelFilter = null),
                  ),
                  ...PhysicsDegreeCatalog.levels.map(
                    (PhysicsLevel level) => _LevelChip(
                      label: level.label,
                      selected: _levelFilter == level,
                      onTap: () => setState(() => _levelFilter = level),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _ContinueCard(
              path: continuePath,
              mastery: progress.lessonMastery(continuePath.topic.id),
              readiness: progress.readinessLabel(continuePath),
              onContinue: () => _openLesson(context, continuePath),
            ),
            const SizedBox(height: 24),
            const PhysDegreeSectionHeader(
              title: 'Browse Courses',
              subtitle:
                  'Jump to any topic — MIT rigor · NASA wonder · simulator depth',
            ),
            ...courses.map(
              (PhysicsCourseRef ref) => _CourseCard(
                ref: ref,
                mastery: progress.courseMastery(ref.course),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PhysicsDegreeCourseScreen(
                      track: ref.track,
                      course: ref.course,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...<Widget>[
            const SizedBox(height: 20),
            const PhysDegreeSectionHeader(
              title: 'Search Results',
              subtitle: 'Tap any topic to open it directly',
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
                (PhysicsLessonPath path) => _LessonResultCard(
                  path: path,
                  mastery: progress.lessonMastery(path.topic.id),
                  onTap: () => _openLesson(context, path),
                ),
              ),
          ],
          if (progress.earnedBadges.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            const PhysDegreeSectionHeader(title: 'Achievements'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: progress.earnedBadges.map((String id) {
                return Chip(
                  avatar: const Text('🏆', style: TextStyle(fontSize: 14)),
                  label: Text(physicsBadgeLabel(id)),
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

  void _openLesson(BuildContext context, PhysicsLessonPath path) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhysicsDegreeLessonHubScreen(path: path),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors c = PhysicsDegreeTheme.of(context);

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

  final PhysicsProgressService progress;
  final double overallProgress;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors c = PhysicsDegreeTheme.of(context);

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
                  'Physics Faculty',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${PhysicsDegreeCatalog.totalLessons} topics · '
                  '${progress.earnedBadges.length} badges',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  PhysicsCatalog.philosophy,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          PhysDegreeProgressRing(
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

  final PhysicsLessonPath path;
  final double mastery;
  final String readiness;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors c = PhysicsDegreeTheme.of(context);

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
              Text(
                path.track.emoji.isEmpty ? '⚛️' : path.track.emoji,
                style: const TextStyle(fontSize: 28),
              ),
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
                      path.topic.title,
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
          PhysDegreeMasteryBar(mastery: mastery),
          const SizedBox(height: 8),
          Text(
            '${mastery.round()}% · $readiness · ${path.track.level.label}',
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

  final PhysicsCourseRef ref;
  final double mastery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors c = PhysicsDegreeTheme.of(context);

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
                Text(
                  ref.track.emoji.isEmpty ? '🔭' : ref.track.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
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
                        ref.track.level.label,
                        style: TextStyle(
                          color: c.primaryLight.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ref.course.blurb,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.textPrimary.withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${ref.course.topics.length} topics',
                        style: TextStyle(
                          color: c.textPrimary.withValues(alpha: 0.55),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PhysDegreeMasteryBar(mastery: mastery),
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

  final PhysicsLessonPath path;
  final double mastery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PhysicsDegreeColors c = PhysicsDegreeTheme.of(context);

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
                const Text('⚛️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        path.topic.title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${path.track.level.label} · ${path.course.title}',
                        style: TextStyle(
                          color: c.textPrimary.withValues(alpha: 0.65),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      PhysDegreeMasteryBar(mastery: mastery),
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
