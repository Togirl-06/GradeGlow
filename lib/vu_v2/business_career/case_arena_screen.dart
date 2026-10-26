import 'package:flutter/material.dart';

import 'business_career_content.dart';
import 'business_career_progress.dart';
import 'business_career_theme.dart';
import 'case_challenge_bank.dart';

/// Case Arena — pick a case, choose an approach, run checks, submit for XP.
class CaseArenaScreen extends StatefulWidget {
  const CaseArenaScreen({super.key, required this.progress});

  final BusinessCareerProgress progress;

  @override
  State<CaseArenaScreen> createState() => _CaseArenaScreenState();
}

class _CaseArenaScreenState extends State<CaseArenaScreen> {
  late final List<CaseChallenge> _challenges;
  CaseChallenge? _active;
  String? _selectedOption;
  List<CaseResult>? _results;
  bool _running = false;
  String _query = '';
  String _diff = 'All';
  String _majorFilter = 'My major';

  @override
  void initState() {
    super.initState();
    _challenges = CaseChallengeBank.all();
  }

  String get _myMajorTag =>
      BusinessMajors.majorTagFor(widget.progress.majorId);

  List<CaseChallenge> get _filtered {
    Iterable<CaseChallenge> list = _challenges;
    if (_majorFilter == 'My major') {
      list = list.where(
        (CaseChallenge c) => c.majorId == widget.progress.majorId,
      );
    } else if (_majorFilter != 'All majors') {
      list = list.where(
        (CaseChallenge c) =>
            BusinessMajors.majorTagFor(c.majorId) == _majorFilter,
      );
    }
    if (_diff != 'All') {
      list = list.where((CaseChallenge c) => c.difficulty == _diff);
    }
    final String q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where(
        (CaseChallenge c) =>
            c.title.toLowerCase().contains(q) ||
            c.topics.any((String t) => t.toLowerCase().contains(q)) ||
            c.id.toLowerCase().contains(q),
      );
    }
    return list.toList();
  }

  Future<void> _run({required bool submit}) async {
    final CaseChallenge? c = _active;
    final String? opt = _selectedOption;
    if (c == null || opt == null) return;
    setState(() {
      _running = true;
      _results = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 380));
    final List<CaseResult> results = c.grade(opt);
    final bool allPass = results.every((CaseResult t) => t.passed);
    if (submit && allPass) {
      await widget.progress.completeChallenge(c.id, xpGain: c.xpReward);
    }
    if (!mounted) return;
    setState(() {
      _results = results;
      _running = false;
    });
    if (submit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            allPass
                ? 'Submitted · case cleared · +${c.xpReward} XP'
                : 'Submission blocked — revise your approach',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final BusinessMajor major = BusinessMajors.byId(widget.progress.majorId);
    return Scaffold(
      backgroundColor: BizCosmic.bg,
      appBar: BizCosmic.appBar(
        context: context,
        title: 'Case Arena',
        icon: Icons.psychology_alt_rounded,
        trailing: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BizCosmic.pill(major.title),
          ),
        ],
      ),
      body: BizStarfield(
        child: _active == null ? _buildList() : _buildWorkspace(_active!),
      ),
    );
  }

  Widget _buildList() {
    final List<CaseChallenge> filtered = _filtered;
    final int cleared = widget.progress.completedChallenges.length;
    final List<String> majorFilters = <String>[
      'My major',
      'All majors',
      ...BusinessMajors.all.map((BusinessMajor m) => m.title),
    ];

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pick a case · $cleared cleared',
                style: const TextStyle(
                  color: BizCosmic.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose an approach, run criteria checks, submit for XP. '
                'Showing $_myMajorTag by default.',
                style: const TextStyle(color: BizCosmic.mute, fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (String v) => setState(() => _query = v),
                style: const TextStyle(color: BizCosmic.ink),
                decoration: InputDecoration(
                  hintText: 'Search title, topic, or id',
                  hintStyle: const TextStyle(color: BizCosmic.mute),
                  filled: true,
                  fillColor: BizCosmic.panel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: BizCosmic.mute),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: majorFilters
                      .map(
                        (String f) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => setState(() => _majorFilter = f),
                            child: BizCosmic.pill(
                              f,
                              bg: _majorFilter == f
                                  ? BizCosmic.royal.withValues(alpha: 0.35)
                                  : BizCosmic.panelAlt,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <String>['All', 'Easy', 'Medium', 'Hard']
                      .map(
                        (String d) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => setState(() => _diff = d),
                            child: BizCosmic.pill(
                              d,
                              bg: _diff == d
                                  ? BizCosmic.emerald.withValues(alpha: 0.3)
                                  : BizCosmic.panelAlt,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  '${filtered.length} shown',
                  style: const TextStyle(color: BizCosmic.mute, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            itemCount: filtered.length,
            itemBuilder: (_, int i) {
              final CaseChallenge c = filtered[i];
              final bool done =
                  widget.progress.completedChallenges.contains(c.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() {
                    _active = c;
                    _selectedOption = c.options.first.id;
                    _results = null;
                  }),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BizCosmic.panelBox(),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                c.title,
                                style: const TextStyle(
                                  color: BizCosmic.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: <Widget>[
                                  BizCosmic.pill(
                                    c.difficulty,
                                    bg: c.difficulty == 'Easy'
                                        ? BizCosmic.success
                                            .withValues(alpha: 0.15)
                                        : BizCosmic.warning
                                            .withValues(alpha: 0.15),
                                    fg: c.difficulty == 'Easy'
                                        ? BizCosmic.success
                                        : BizCosmic.warning,
                                  ),
                                  BizCosmic.pill(
                                    BusinessMajors.majorTagFor(c.majorId),
                                  ),
                                  ...c.topics.take(2).map(
                                        (String t) => BizCosmic.pill(t),
                                      ),
                                  BizCosmic.pill(
                                    '+${c.xpReward} XP',
                                    bg: BizCosmic.gold.withValues(alpha: 0.18),
                                    fg: BizCosmic.gold,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          done ? Icons.check_circle : Icons.chevron_right,
                          color: done ? BizCosmic.success : BizCosmic.mute,
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
    );
  }

  Widget _buildWorkspace(CaseChallenge c) {
    final CaseOption option = c.options.firstWhere(
      (CaseOption o) => o.id == _selectedOption,
      orElse: () => c.options.first,
    );
    final int passed =
        _results?.where((CaseResult t) => t.passed).length ?? 0;
    final int total = _results?.length ?? 0;
    final bool done = widget.progress.completedChallenges.contains(c.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: <Widget>[
        Row(
          children: <Widget>[
            TextButton(
              onPressed: () => setState(() => _active = null),
              child: const Text('← Cases'),
            ),
            if (done)
              BizCosmic.pill(
                'Cleared',
                bg: BizCosmic.success.withValues(alpha: 0.2),
                fg: BizCosmic.success,
              ),
          ],
        ),
        Text(
          c.title,
          style: const TextStyle(
            color: BizCosmic.ink,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            BizCosmic.pill(c.difficulty),
            ...c.topics.map((String t) => BizCosmic.pill(t)),
            BizCosmic.pill(
              '+${c.xpReward} XP',
              bg: BizCosmic.gold.withValues(alpha: 0.18),
              fg: BizCosmic.gold,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BizCosmic.panelBox(radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Scenario',
                style: TextStyle(
                  color: BizCosmic.mute,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                c.scenario,
                style: const TextStyle(
                  color: BizCosmic.ink,
                  height: 1.45,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                c.prompt,
                style: const TextStyle(
                  color: BizCosmic.electric,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BizCosmic.panelBox(radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Your approach',
                style: TextStyle(
                  color: BizCosmic.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ...c.options.map((CaseOption o) {
                final bool on = o.id == option.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() {
                      _selectedOption = o.id;
                      _results = null;
                    }),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: on
                            ? BizCosmic.royal.withValues(alpha: 0.2)
                            : BizCosmic.panelAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: on ? BizCosmic.electric : BizCosmic.stroke,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            o.label,
                            style: const TextStyle(
                              color: BizCosmic.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            o.detail,
                            style: const TextStyle(
                              color: BizCosmic.mute,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _running ? null : () => _run(submit: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BizCosmic.ink,
                        side: const BorderSide(color: BizCosmic.stroke),
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: Text(_running ? 'Running…' : 'Run checks'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _running ? null : () => _run(submit: true),
                      style: FilledButton.styleFrom(
                        backgroundColor: BizCosmic.emerald,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BizCosmic.panelBox(radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text(
                    'Case results',
                    style: TextStyle(
                      color: BizCosmic.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (_results != null)
                    BizCosmic.pill(
                      '$passed of $total passed',
                      bg: passed == total
                          ? BizCosmic.success.withValues(alpha: 0.15)
                          : BizCosmic.warning.withValues(alpha: 0.15),
                      fg: passed == total
                          ? BizCosmic.success
                          : BizCosmic.warning,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (_results == null)
                const Text(
                  'Run checks to score your approach against case criteria.',
                  style: TextStyle(color: BizCosmic.mute),
                )
              else
                ..._results!.map((CaseResult t) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: t.passed
                            ? BizCosmic.emerald.withValues(alpha: 0.14)
                            : BizCosmic.warning.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            t.passed ? Icons.check_circle : Icons.cancel,
                            color: t.passed
                                ? BizCosmic.success
                                : BizCosmic.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.passed
                                  ? '${t.name} passed.'
                                  : '${t.name}: ${t.detail}',
                              style: const TextStyle(
                                color: BizCosmic.ink,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              if (option.coachTip != null && _results != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  'Coach: ${option.coachTip}',
                  style: const TextStyle(
                    color: BizCosmic.mute,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
