import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/practice_lab_course_topics.dart';
import '../data/topic_activities_catalog.dart';
import '../models/practice_lab_subject.dart';
import '../models/practice_lab_topic.dart';
import '../models/practice_lab_unit.dart';
import '../models/topic_activity.dart';
import '../services/practice_lab_service.dart';
import '../theme/practice_lab_game_theme.dart';
import '../utils/practice_lab_limits.dart';
import '../utils/topic_activity_navigation.dart';
import '../utils/topic_activity_session_info.dart';
import '../widgets/practice_lab/practice_lab_usage_banner.dart';
import '../widgets/practice_lab/practice_labs_hub_widgets.dart' hide PracticeLabUsageBanner;

/// Hub showing all activity types for one curriculum topic.
class TopicActivityHubScreen extends StatefulWidget {
  const TopicActivityHubScreen({
    super.key,
    required this.subject,
    required this.course,
    required this.unit,
    required this.topic,
  });

  final PracticeLabSubject subject;
  final PracticeLabCourse course;
  final PracticeLabUnit unit;
  final PracticeLabTopic topic;

  @override
  State<TopicActivityHubScreen> createState() => _TopicActivityHubScreenState();
}

class _TopicActivityHubScreenState extends State<TopicActivityHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  PracticeLabSubject get subject => widget.subject;
  PracticeLabCourse get course => widget.course;
  PracticeLabUnit get unit => widget.unit;
  PracticeLabTopic get topic => widget.topic;
  PracticeLabGroupStyle get _style => PracticeLabGroupStyle.forGroup(subject.groupId);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _query = _searchController.text));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PracticeLabService>().refreshUsage();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TopicActivity> get _activities {
    final List<TopicActivity> all = TopicActivitiesCatalog.forTopic(
      subjectId: subject.id,
      courseId: course.id,
      topicId: topic.id,
      topicName: topic.name,
      codeLab: PracticeLabCourseTopics.codeLabForCourse(subject.id, course.id),
      defaultStyle: topic.style,
    );
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (TopicActivity a) =>
              a.title.toLowerCase().contains(q) ||
              a.description.toLowerCase().contains(q) ||
              a.categoryLabel.toLowerCase().contains(q),
        )
        .toList();
  }

  Map<String, List<TopicActivity>> get _grouped {
    final Map<String, List<TopicActivity>> groups = <String, List<TopicActivity>>{};
    for (final TopicActivity activity in _activities) {
      groups.putIfAbsent(activity.categoryLabel, () => <TopicActivity>[]).add(activity);
    }
    return groups;
  }

  static const List<String> _categoryOrder = <String>[
    'Diagram & Visual',
    'Virtual Lab',
    'Scenarios & Simulation',
    'Coding Practice',
    'Quiz & Questions',
    'Voice Practice',
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, List<TopicActivity>> grouped = _grouped;
    final PracticeLabService labs = context.watch<PracticeLabService>();
    final PracticeLabUsage? usage = labs.usage;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(topic.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            Text(
              unit.name,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[_style.accent.withValues(alpha: 0.22), _style.accent.withValues(alpha: 0.06)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _style.accent.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(subject.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${_activities.length} activities',
                            style: TextStyle(color: _style.accent, fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (usage != null)
            PracticeLabUsageBanner(
              remaining: usage.remaining,
              limit: PracticeLabLimits.freeSimulationsPerMonth,
              isPremium: usage.isPremium,
            ),
          if (usage != null) const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search activities…',
              prefixIcon: Icon(Icons.search_rounded, color: _style.accent),
            ),
          ),
          const SizedBox(height: 16),
          ..._categoryOrder.where(grouped.containsKey).map((String category) {
            final List<TopicActivity> items = grouped[category]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      color: _style.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...items.map((TopicActivity activity) => _ActivityCard(
                        activity: activity,
                        style: _style,
                        onTap: () => pickDifficultyAndStartTopicActivity(
                          context: context,
                          subject: subject,
                          course: course,
                          unit: unit,
                          topic: topic,
                          activity: activity,
                        ),
                      )),
                ],
              ),
            );
          }),
          ...grouped.entries
              .where((MapEntry<String, List<TopicActivity>> e) => !_categoryOrder.contains(e.key))
              .map((MapEntry<String, List<TopicActivity>> entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.key.toUpperCase(),
                    style: TextStyle(color: _style.accent, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.7),
                  ),
                  const SizedBox(height: 10),
                  ...entry.value.map((TopicActivity activity) => _ActivityCard(
                        activity: activity,
                        style: _style,
                        onTap: () => pickDifficultyAndStartTopicActivity(
                          context: context,
                          subject: subject,
                          course: course,
                          unit: unit,
                          topic: topic,
                          activity: activity,
                        ),
                      )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.style, required this.onTap});

  final TopicActivity activity;
  final PracticeLabGroupStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: style.accent.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: style.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(activity.emoji, style: const TextStyle(fontSize: 22))),
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
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (!activity.isLive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'AI+',
                                style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 9, fontWeight: FontWeight.w800),
                              ),
                            ),
                          if (activity.timed)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.timer_outlined, size: 14, color: style.accent.withValues(alpha: 0.7)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.description,
                        style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 12, height: 1.35),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _sessionMeta(activity),
                        style: TextStyle(color: style.accent.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: style.accent.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _sessionMeta(TopicActivity activity) {
    final TopicActivitySessionInfo beginner = TopicActivitySessionInfo.forActivity(activity, 'Beginner');
    if (activity.isLive) {
      return '${beginner.sizeLabel} · ${beginner.durationLabel} at beginner';
    }
    return 'AI-guided · ${beginner.sizeLabel} · ${beginner.durationLabel}';
  }
}
