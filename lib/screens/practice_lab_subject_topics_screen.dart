import 'package:flutter/material.dart';

import '../data/practice_lab_course_topics.dart';
import '../data/topic_activities_catalog.dart';
import '../models/practice_lab_subject.dart';
import '../screens/topic_activity_hub_screen.dart';
import '../theme/practice_lab_game_theme.dart';
import '../utils/practice_lab_helpers.dart';
import '../widgets/practice_lab/practice_labs_hub_widgets.dart';

/// All topics in a subject — tap a topic to open its activity hub.
class PracticeLabSubjectTopicsScreen extends StatefulWidget {
  const PracticeLabSubjectTopicsScreen({super.key, required this.subject});

  final PracticeLabSubject subject;

  @override
  State<PracticeLabSubjectTopicsScreen> createState() => _PracticeLabSubjectTopicsScreenState();
}

class _PracticeLabSubjectTopicsScreenState extends State<PracticeLabSubjectTopicsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  PracticeLabSubject get subject => widget.subject;
  PracticeLabGroupStyle get _style => PracticeLabGroupStyle.forGroup(subject.groupId);
  bool get _isCs => isComputerScienceMajor(subject.id, groupId: subject.groupId);

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

  List<PracticeLabSubjectTopicEntry> get _visibleEntries {
    final String q = _query.trim().toLowerCase();
    final List<PracticeLabSubjectTopicEntry> all = subject.topicEntries;
    if (q.isEmpty) return all;
    return all
        .where(
          (PracticeLabSubjectTopicEntry e) =>
              e.topic.name.toLowerCase().contains(q) ||
              e.unit.name.toLowerCase().contains(q) ||
              e.topic.description.toLowerCase().contains(q),
        )
        .toList();
  }

  Map<String, List<PracticeLabSubjectTopicEntry>> get _groupedByUnit {
    final Map<String, List<PracticeLabSubjectTopicEntry>> groups = <String, List<PracticeLabSubjectTopicEntry>>{};
    for (final PracticeLabSubjectTopicEntry entry in _visibleEntries) {
      groups.putIfAbsent(entry.unitKey, () => <PracticeLabSubjectTopicEntry>[]).add(entry);
    }
    return groups;
  }

  void _openHub(PracticeLabSubjectTopicEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TopicActivityHubScreen(
          subject: subject,
          course: entry.course,
          unit: entry.unit,
          topic: entry.topic,
        ),
      ),
    );
  }

  Widget _topicTile(PracticeLabSubjectTopicEntry entry) {
    final int activityCount = TopicActivitiesCatalog.activityCountFor(
      subjectId: subject.id,
      courseId: entry.course.id,
      topicId: entry.topic.id,
      topicName: entry.topic.name,
      codeLab: PracticeLabCourseTopics.codeLabForCourse(subject.id, entry.course.id),
      defaultStyle: entry.topic.style,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PracticeLabTopicTile(
        topic: entry.topic,
        style: _style,
        dark: true,
        activityCount: activityCount,
        onTap: () => _openHub(entry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<PracticeLabSubjectTopicEntry>> grouped = _groupedByUnit;
    final bool showUnitHeaders = grouped.length > 1;

    return Scaffold(
      backgroundColor: _isCs ? const Color(0xFF0A0E17) : PracticeLabGameTheme.background(context),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(subject.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            Text(
              '${subject.topicCount} topics',
              style: TextStyle(fontSize: 11, color: PracticeLabGameTheme.textSecondary(context), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: _isCs ? const Color(0xFF0A0E17) : PracticeLabGameTheme.background(context),
        foregroundColor: PracticeLabGameTheme.textPrimary(context),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: <Widget>[
          TextField(
            controller: _searchController,
            style: TextStyle(color: PracticeLabGameTheme.textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'Search topics…',
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
          const SizedBox(height: 14),
          PracticeLabDifficultyLegend(dark: true),
          const SizedBox(height: 16),
          if (grouped.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  'No topics match your search.',
                  style: TextStyle(color: PracticeLabGameTheme.textSecondary(context)),
                ),
              ),
            )
          else
            for (final List<PracticeLabSubjectTopicEntry> entries in grouped.values) ...<Widget>[
              if (showUnitHeaders) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 4),
                  child: Text(
                    entries.first.unit.name.toUpperCase(),
                    style: TextStyle(
                      color: _style.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ],
              ...entries.map(_topicTile),
            ],
        ],
      ),
    );
  }
}
