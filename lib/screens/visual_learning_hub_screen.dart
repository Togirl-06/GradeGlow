import 'package:flutter/material.dart';

import '../data/visual_learning_catalog.dart';
import '../models/practice_lab_subject.dart';
import '../models/visual_learning_lab.dart';
import '../theme/practice_lab_game_theme.dart';
import '../utils/visual_learning_navigation.dart';
import '../widgets/practice_lab/practice_labs_hub_widgets.dart';

/// Browse Visual Learning Labs for a subject — labeling, drag-drop, simulations.
class VisualLearningHubScreen extends StatefulWidget {
  const VisualLearningHubScreen({super.key, required this.subject});

  final PracticeLabSubject subject;

  @override
  State<VisualLearningHubScreen> createState() => _VisualLearningHubScreenState();
}

class _VisualLearningHubScreenState extends State<VisualLearningHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  PracticeLabSubject get subject => widget.subject;
  VisualLabEnvironmentConfig get _env => VisualLearningCatalog.configForSubject(subject.id);
  PracticeLabGroupStyle get _style => PracticeLabGroupStyle.forGroup(subject.groupId);

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

  List<VisualLabSection> get _sections {
    final String q = _query.trim().toLowerCase();
    final List<VisualLabSection> all = VisualLearningCatalog.sectionsFor(subject.id);
    if (q.isEmpty) return all;
    return all
        .map((VisualLabSection section) {
          final List<VisualLabActivity> filtered = section.activities
              .where(
                (VisualLabActivity a) =>
                    a.title.toLowerCase().contains(q) ||
                    a.description.toLowerCase().contains(q) ||
                    a.typeLabel.toLowerCase().contains(q),
              )
              .toList();
          if (filtered.isEmpty) return null;
          return VisualLabSection(title: section.title, activities: filtered);
        })
        .whereType<VisualLabSection>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<VisualLabSection> sections = _sections;
    final int liveCount = sections.fold<int>(
      0,
      (int n, VisualLabSection s) => n + s.activities.where((VisualLabActivity a) => a.isLive).length,
    );

    return Scaffold(
      backgroundColor: PracticeLabGameTheme.background(context),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Visual Learning Labs', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            Text(
              subject.name,
              style: TextStyle(fontSize: 11, color: PracticeLabGameTheme.textSecondary(context), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: PracticeLabGameTheme.background(context),
        foregroundColor: PracticeLabGameTheme.textPrimary(context),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: <Widget>[
          _EnvironmentHero(config: _env, liveCount: liveCount),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            style: TextStyle(color: PracticeLabGameTheme.textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'Search activities…',
              hintStyle: TextStyle(color: PracticeLabGameTheme.textSecondary(context)),
              prefixIcon: Icon(Icons.search_rounded, color: _style.accent),
              filled: true,
              fillColor: PracticeLabGameTheme.surface(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: PracticeLabGameTheme.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: PracticeLabGameTheme.border(context)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Interact with diagrams, drag-and-drop labels, and profession-specific simulations — not just multiple choice.',
            style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 18),
          ...sections.expand((VisualLabSection section) => <Widget>[
                _SectionHeader(title: section.title, count: section.activities.length),
                const SizedBox(height: 10),
                ...section.activities.map(
                  (VisualLabActivity activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ActivityTile(
                      activity: activity,
                      accent: _env.accent,
                      onTap: () => pickDifficultyAndStartVisualActivity(
                        context: context,
                        subject: subject,
                        activity: activity,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ]),
          if (sections.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text('No activities match your search.', style: TextStyle(color: PracticeLabGameTheme.textSecondary(context))),
            ),
        ],
      ),
    );
  }
}

class _EnvironmentHero extends StatelessWidget {
  const _EnvironmentHero({required this.config, required this.liveCount});

  final VisualLabEnvironmentConfig config;
  final int liveCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: config.gradient),
        border: Border.all(color: config.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(config.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      config.title,
                      style: TextStyle(color: config.accent, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                    ),
                    Text(
                      config.tagline,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, height: 1.35, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _HeroChip(label: '$liveCount interactive', icon: Icons.touch_app_outlined),
              _HeroChip(label: 'Beginner → Advanced', icon: Icons.trending_up_rounded),
              _HeroChip(label: 'Accuracy + Speed', icon: Icons.speed_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: PracticeLabGameTheme.textPrimary(context),
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: PracticeLabGameTheme.xp(context).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text('$count', style: TextStyle(color: PracticeLabGameTheme.xp(context), fontWeight: FontWeight.w800, fontSize: 11)),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, required this.accent, required this.onTap});

  final VisualLabActivity activity;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PracticeLabGameTheme.surface(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(activity.typeIcon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            activity.title,
                            style: TextStyle(
                              color: PracticeLabGameTheme.textPrimary(context),
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!activity.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: PracticeLabGameTheme.border(context),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: PracticeLabGameTheme.textSecondary(context))),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.description,
                      style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 12, height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.typeLabel,
                      style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_outline_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
