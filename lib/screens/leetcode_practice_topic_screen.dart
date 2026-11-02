import 'package:flutter/material.dart';

import '../data/practice_lab_topics_catalog.dart';
import '../models/ai_practice_mode.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_topic.dart';
import '../theme/leetcode_theme.dart';
import '../widgets/practice_lab/practice_lab_features_bar.dart';
import 'leetcode_practice_session_screen.dart';

/// LeetCode-style problem browser for computer science practice labs.
class LeetcodePracticeTopicScreen extends StatefulWidget {
  const LeetcodePracticeTopicScreen({
    super.key,
    required this.major,
    required this.area,
  });

  final PracticeLabCategory major;
  final PracticeLabTopicArea area;

  @override
  State<LeetcodePracticeTopicScreen> createState() => _LeetcodePracticeTopicScreenState();
}

class _LeetcodePracticeTopicScreenState extends State<LeetcodePracticeTopicScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String _difficultyFilter = 'All';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _query = _search.text));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<PracticeLabTopic> get _topics {
    String trimmed = _query.trim().toLowerCase();
    return widget.area.topics.where((PracticeLabTopic topic) {
      final bool matchesSearch = trimmed.isEmpty ||
          topic.name.toLowerCase().contains(trimmed) ||
          topic.id.toLowerCase().contains(trimmed);
      if (!matchesSearch) return false;
      if (_difficultyFilter == 'All') return true;
      if (_difficultyFilter == 'Easy') return topic.beginner;
      if (_difficultyFilter == 'Med.') return topic.intermediate;
      return topic.advanced;
    }).toList();
  }

  void _solve(PracticeLabTopic topic, PracticeDifficulty difficulty) {
    final PracticeLabType lab = PracticeLabTopicsCatalog.labFor(
      major: widget.major,
      area: widget.area,
      topic: topic,
      difficulty: difficulty,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LeetcodePracticeSessionScreen(
          category: widget.major,
          lab: lab,
          topic: topic,
          area: widget.area,
          difficulty: difficulty,
        ),
      ),
    );
  }

  PracticeDifficulty _defaultDifficulty(PracticeLabTopic topic) {
    if (topic.beginner) return PracticeDifficulty.beginner;
    if (topic.intermediate) return PracticeDifficulty.intermediate;
    return PracticeDifficulty.advanced;
  }

  @override
  Widget build(BuildContext context) {
    final List<PracticeLabTopic> topics = _topics;

    return Theme(
      data: LeetCodeTheme.darkTheme(),
      child: Scaffold(
        backgroundColor: LeetCodeTheme.background,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.area.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(
                '${widget.major.name} · ${widget.area.topics.length} problems',
                style: const TextStyle(fontSize: 11, color: LeetCodeTheme.textSecondary),
              ),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: <Widget>[
            const PracticeLabFeaturesBar(compact: true, leetcode: true),
            const SizedBox(height: 12),
            TextField(
              controller: _search,
              style: const TextStyle(color: LeetCodeTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search problems…',
                hintStyle: const TextStyle(color: LeetCodeTheme.textSecondary),
                filled: true,
                fillColor: LeetCodeTheme.surface,
                prefixIcon: const Icon(Icons.search, color: LeetCodeTheme.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: LeetCodeTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: LeetCodeTheme.border),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <String>['All', 'Easy', 'Med.', 'Hard'].map((String label) {
                  final bool selected = _difficultyFilter == label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => setState(() => _difficultyFilter = label),
                      backgroundColor: LeetCodeTheme.surface,
                      selectedColor: LeetCodeTheme.accent.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: selected ? LeetCodeTheme.accent : LeetCodeTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: LeetCodeTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: LeetCodeTheme.border),
              ),
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 28, child: Text('St', style: TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700))),
                        Expanded(child: Text('Title', style: TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700))),
                        SizedBox(width: 52, child: Text('Diff', style: TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700))),
                        SizedBox(width: 56, child: Text('Acc.', style: TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700), textAlign: TextAlign.end)),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: LeetCodeTheme.border),
                  if (topics.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No problems match your filters.', style: TextStyle(color: LeetCodeTheme.textSecondary)),
                    )
                  else
                    ...topics.asMap().entries.map((MapEntry<int, PracticeLabTopic> entry) {
                      final PracticeLabTopic topic = entry.value;
                      final bool isLast = entry.key == topics.length - 1;
                      final PracticeDifficulty diff = _defaultDifficulty(topic);
                      final Color diffColor = LeetCodeTheme.difficultyColor(diff.label);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _solve(topic, diff),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              border: isLast ? null : const Border(bottom: BorderSide(color: LeetCodeTheme.border)),
                            ),
                            child: Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: 28,
                                  child: Icon(Icons.radio_button_unchecked, size: 16, color: LeetCodeTheme.textSecondary),
                                ),
                                Expanded(
                                  child: Text(
                                    topic.name,
                                    style: const TextStyle(color: LeetCodeTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                  width: 52,
                                  child: Text(
                                    LeetCodeTheme.difficultyLabel(diff.label),
                                    style: TextStyle(color: diffColor, fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  width: 56,
                                  child: Text(
                                    LeetCodeTheme.acceptanceRate(topic.id),
                                    style: const TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
