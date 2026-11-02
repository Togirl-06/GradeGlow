import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/practice_lab_game_theme.dart';
import '../data/practice_lab_scene_config.dart';
import '../data/practice_lab_topics_catalog.dart';
import '../data/practice_lab_scenarios.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_topic.dart';
import '../services/practice_lab_service.dart';
import '../theme/leetcode_theme.dart';
import '../theme/study_theme.dart';
import '../utils/practice_lab_helpers.dart';
import '../utils/practice_lab_limits.dart';
import '../screens/membership_screen.dart';
import '../widgets/practice_lab/practice_lab_features_bar.dart';
import '../widgets/practice_lab/practice_labs_hub_widgets.dart';
import 'anatomy_game_screen.dart';
import 'er_career_map_screen.dart';
import 'er_simulation_screen.dart';
import 'leetcode_practice_topic_screen.dart';
import 'practice_lab_session_screen.dart';
import 'practice_lab_topic_area_screen.dart';

/// AI Practice Labs hub for one major — topic areas with unlimited AI scenarios.
class PracticeLabCategoryScreen extends StatefulWidget {
  const PracticeLabCategoryScreen({super.key, required this.category});

  final PracticeLabCategory category;

  @override
  State<PracticeLabCategoryScreen> createState() => _PracticeLabCategoryScreenState();
}

class _PracticeLabCategoryScreenState extends State<PracticeLabCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  PracticeLabCategory get category => widget.category;

  List<PracticeLabTopicArea> get _areas =>
      PracticeLabTopicsCatalog.areasFor(category.id, groupId: category.groupId, majorName: category.name);

  PracticeLabMajorCatalog get _legacyCatalog => PracticeLabScenarios.resolveForMajor(
        majorId: category.id,
        groupId: category.groupId,
        majorName: category.name,
      );

  PracticeLabGroupStyle get _style => PracticeLabGroupStyle.forGroup(category.groupId ?? '');

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _query = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PracticeLabTopicArea> get _filteredAreas {
    final String trimmed = _query.trim().toLowerCase();
    if (trimmed.isEmpty) return _areas;
    return _areas
        .where(
          (PracticeLabTopicArea area) =>
              area.name.toLowerCase().contains(trimmed) ||
              area.topics.any(
                (PracticeLabTopic topic) =>
                    topic.name.toLowerCase().contains(trimmed) ||
                    topic.description.toLowerCase().contains(trimmed),
              ),
        )
        .toList();
  }

  bool get _isCs => isComputerScienceMajor(category.id, groupId: category.groupId);

  PracticeLabSceneConfig? get _venueConfig =>
      _isCs ? null : PracticeLabSceneConfig.forGroup(category.groupId);

  String get _description {
    if (_isCs) {
      return 'Coding problems with an AI interviewer, voice chat, hints, and live scoring.';
    }
    final PracticeLabSceneConfig? venue = _venueConfig;
    if (venue != null) {
      return venue.tagline;
    }
    return 'Unlimited AI practice labs across every ${category.name} topic. Each session generates a unique scenario with live grading.';
  }

  void _openArea(PracticeLabTopicArea area) {
    final Widget screen = _isCs
        ? LeetcodePracticeTopicScreen(major: category, area: area)
        : PracticeLabTopicAreaScreen(major: category, area: area);
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _openLegacyLab(PracticeLabType lab) {
    final Widget screen = switch (lab.style) {
      SimulationStyle.anatomyGame => AnatomyGameScreen(category: category, lab: lab),
      SimulationStyle.erEmergency => ErSimulationScreen(category: category, lab: lab),
      _ => PracticeLabSessionScreen(category: category, lab: lab),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final PracticeLabUsage? usage = context.watch<PracticeLabService>().usage;
    final int totalLabs = PracticeLabTopicsCatalog.totalLabCountFor(
      category.id,
      groupId: category.groupId,
      majorName: category.name,
    );
    final List<PracticeLabTopicArea> areas = _filteredAreas;
    final List<PracticeLabType> featuredLabs = <PracticeLabType>[
      ..._legacyCatalog.coreLabs.where(
        (PracticeLabType lab) =>
            lab.style == SimulationStyle.erEmergency || lab.style == SimulationStyle.anatomyGame,
      ),
    ];
    final String areaLabel = _isCs ? 'problem sets' : 'topic areas';
    final String topicsLabel = _isCs ? 'problems' : 'topics';

    final Widget body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: <Widget>[
        PracticeLabMajorHero(
          category: category,
          description: _description,
          venueTitle: _venueConfig?.venueTitle,
          totalLabs: totalLabs,
          areaCount: _areas.length,
          areaLabel: areaLabel,
          dark: _isCs,
        ),
        if (category.id == 'nursing') ...<Widget>[
          const SizedBox(height: 14),
          PracticeLabPromoTile(
            title: 'Career Quest Map',
            subtitle: 'Explore nursing career paths through interactive scenarios',
            icon: Icons.map_rounded,
            style: _style,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ErCareerMapScreen()),
            ),
          ),
        ],
        if (usage != null && !usage.isPremium) ...<Widget>[
          const SizedBox(height: 14),
          PracticeLabUsageBanner(
            remaining: usage.remaining,
            limit: PracticeLabLimits.freeSimulationsPerMonth,
            dark: _isCs,
            onUpgrade: usage.isAtLimit
                ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
                    )
                : null,
          ),
        ],
        const SizedBox(height: 16),
        PracticeLabFeaturesBar(compact: true, leetcode: _isCs),
        const SizedBox(height: 16),
        PracticeLabsFeatureCarousel(),
        const SizedBox(height: 16),
        PracticeLabStyledSearch(
          controller: _searchController,
          hintText: _isCs ? 'Search problem sets…' : 'Search topic areas…',
          dark: _isCs,
          onClear: _query.trim().isNotEmpty ? _searchController.clear : null,
        ),
        const SizedBox(height: 18),
        if (areas.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _isCs ? LeetCodeTheme.surface : StudyColors.surface(brightness),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _isCs ? LeetCodeTheme.border : StudyColors.border(brightness)),
            ),
            child: Text(
              'No topic areas match "$_query".',
              style: TextStyle(color: textSecondary),
            ),
          )
        else
          ...areas.map(
            (PracticeLabTopicArea area) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PracticeLabTopicAreaTile(
                area: area,
                style: _style,
                topicsLabel: topicsLabel,
                dark: _isCs,
                onTap: () => _openArea(area),
              ),
            ),
          ),
        if (featuredLabs.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          _SectionHeader(title: 'Featured simulations', dark: _isCs),
          const SizedBox(height: 10),
          ...featuredLabs.map(
            (PracticeLabType lab) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PracticeLabFeaturedTile(
                title: lab.title,
                subtitle: lab.subtitle,
                icon: category.icon,
                style: _style,
                dark: _isCs,
                onTap: () => _openLegacyLab(lab),
              ),
            ),
          ),
        ],
      ],
    );

    if (_isCs) {
      return Theme(
        data: LeetCodeTheme.darkTheme(),
        child: Scaffold(
          backgroundColor: LeetCodeTheme.background,
          appBar: AppBar(
            title: Text(category.name),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: body,
        ),
      );
    }

    return Scaffold(
      backgroundColor: PracticeLabGameTheme.background(context),
      appBar: AppBar(
        title: Text('${category.emoji} ${category.name}'.trim(), style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: PracticeLabGameTheme.background(context),
        foregroundColor: PracticeLabGameTheme.textPrimary(context),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: body,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.dark = false});

  final String title;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(Icons.star_rounded, size: 18, color: dark ? LeetCodeTheme.accent : StudyColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: dark ? LeetCodeTheme.textPrimary : null,
          ),
        ),
      ],
    );
  }
}

