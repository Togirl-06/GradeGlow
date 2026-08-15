import 'package:flutter/material.dart';

import '../../data/leetcode_problem_bank.dart';
import '../../models/leetcode_problem.dart';
import '../../theme/leetcode_theme.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_cs_problem_workspace.dart';

/// Computer Science Virtual Lab — interview-style algorithm problem browser.
/// Branded as Algorithm Arena (not a third-party product name).
class VuV2CsCodingArenaScreen extends StatefulWidget {
  const VuV2CsCodingArenaScreen({
    super.key,
    this.difficultyFilter,
    this.debugOnly = false,
    this.title = 'Algorithm Arena',
  });

  /// `Easy` | `Medium` | `Hard` or null for all.
  final String? difficultyFilter;
  final bool debugOnly;
  final String title;

  @override
  State<VuV2CsCodingArenaScreen> createState() =>
      _VuV2CsCodingArenaScreenState();
}

class _VuV2CsCodingArenaScreenState extends State<VuV2CsCodingArenaScreen> {
  String _diff = 'All';
  String _query = '';
  String _topic = 'All';
  String? _preferDiff;

  @override
  void initState() {
    super.initState();
    // Tracks like "Easy" prefer that difficulty first, but still show the
    // full unique catalog (300+) so problems never pad/repeat.
    _preferDiff = widget.difficultyFilter;
    _diff = 'All';
  }

  List<LeetcodeProblem> get _all {
    if (widget.debugOnly) return LeetcodeProblemBank.allDebugProblems;
    return LeetcodeProblemBank.allCuratedProblems;
  }

  List<String> get _topics {
    final Set<String> tags = <String>{};
    for (final LeetcodeProblem p in _all) {
      tags.addAll(p.tags);
    }
    final List<String> sorted = tags.toList()..sort();
    return <String>['All', ...sorted];
  }

  List<LeetcodeProblem> get _filtered {
    final String q = _query.trim().toLowerCase();
    final List<LeetcodeProblem> out = <LeetcodeProblem>[];
    for (final LeetcodeProblem p in _all) {
      if (_diff != 'All' &&
          p.difficulty.toLowerCase() != _diff.toLowerCase()) {
        continue;
      }
      if (_topic != 'All') {
        bool tagOk = false;
        for (final String t in p.tags) {
          if (t.toLowerCase() == _topic.toLowerCase()) {
            tagOk = true;
            break;
          }
        }
        if (!tagOk) continue;
      }
      if (q.isNotEmpty) {
        final bool inTitle = p.title.toLowerCase().contains(q);
        bool inTag = false;
        for (final String t in p.tags) {
          if (t.toLowerCase().contains(q)) {
            inTag = true;
            break;
          }
        }
        if (!inTitle && !inTag && !p.id.contains(q)) continue;
      }
      out.add(p);
    }

    int rank(String d) {
      final String x = d.toLowerCase();
      if (_preferDiff != null && x == _preferDiff!.toLowerCase()) return -1;
      if (x == 'easy') return 0;
      if (x == 'medium') return 1;
      return 2;
    }

    out.sort((LeetcodeProblem a, LeetcodeProblem b) {
      final int byDiff = rank(a.difficulty).compareTo(rank(b.difficulty));
      if (byDiff != 0) return byDiff;
      final int? ai = int.tryParse(a.id);
      final int? bi = int.tryParse(b.id);
      if (ai != null && bi != null) return ai.compareTo(bi);
      return a.title.compareTo(b.title);
    });
    return out;
  }

  void _open(LeetcodeProblem problem, int index, List<LeetcodeProblem> list) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VuV2CsProblemWorkspace(
          problem: problem,
          problemIndex: index + 1,
          totalProblems: list.length,
          playlist: list,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<LeetcodeProblem> list = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${list.length} unique problems'
                  '${_diff != 'All' ? ' · $_diff' : ''}'
                  '${_topic != 'All' ? ' · $_topic' : ''}',
                  style: TextStyle(
                    color: VuV2Colors.orange,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Solve algorithm problems like a coding interview — '
                  'read the prompt, write code, run tests, submit. '
                  'No duplicate problems in this list.',
                  style: TextStyle(color: VuV2Colors.mute, height: 1.4),
                ),
                const SizedBox(height: 12),
                TextField(
                  style: const TextStyle(color: VuV2Colors.ink),
                  decoration: InputDecoration(
                    hintText: 'Search problems…',
                    hintStyle: const TextStyle(color: VuV2Colors.mute),
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: VuV2Colors.navyElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (String v) => setState(() => _query = v),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      for (final String d in <String>[
                        'All',
                        'Easy',
                        'Medium',
                        'Hard',
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(d),
                            selected: _diff == d,
                            onSelected: (_) => setState(() => _diff = d),
                            selectedColor:
                                VuV2Colors.orange.withValues(alpha: 0.25),
                            labelStyle: TextStyle(
                              color: _diff == d
                                  ? VuV2Colors.orange
                                  : VuV2Colors.mute,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      for (final String t in _topics.take(24))
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(t),
                            selected: _topic == t,
                            onSelected: (_) => setState(() => _topic = t),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? const VuV2EmptyState(
                    title: 'No problems match',
                    subtitle: 'Try another difficulty or clear search.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    itemCount: list.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int i) {
                      final LeetcodeProblem p = list[i];
                      final Color diffColor =
                          LeetCodeTheme.difficultyColor(p.difficulty);
                      return Material(
                        color: VuV2Colors.navyElevated,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _open(p, i, list),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: VuV2Colors.stroke),
                            ),
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    p.id,
                                    style: const TextStyle(
                                      color: VuV2Colors.mute,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        p.title,
                                        style: const TextStyle(
                                          color: VuV2Colors.ink,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: <Widget>[
                                          if (p.isDebug)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: LeetCodeTheme.hard
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Debug',
                                                style: TextStyle(
                                                  color: LeetCodeTheme.hard,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          for (final String t in p.tags.take(3))
                                            Text(
                                              t,
                                              style: const TextStyle(
                                                color: VuV2Colors.mute,
                                                fontSize: 11,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  LeetCodeTheme.difficultyLabel(p.difficulty),
                                  style: TextStyle(
                                    color: diffColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: VuV2Colors.orange,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
