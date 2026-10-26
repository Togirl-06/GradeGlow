import 'package:flutter/material.dart';

import 'science_career_content.dart';
import 'science_career_progress.dart';
import 'science_career_theme.dart';

class CodingArenaScreen extends StatefulWidget {
  const CodingArenaScreen({super.key, required this.progress});

  final ScienceCareerProgress progress;

  @override
  State<CodingArenaScreen> createState() => _CodingArenaScreenState();
}

class _CodingArenaScreenState extends State<CodingArenaScreen> {
  late final List<CodingChallenge> _challenges;
  CodingChallenge? _active;
  String? _selectedOption;
  List<TestResult>? _results;
  bool _running = false;
  int _tab = 0;
  int _hintSpends = 0;
  String _query = '';
  String _diff = 'All';

  @override
  void initState() {
    super.initState();
    _challenges = CodingArenaCatalog.all();
  }

  List<CodingChallenge> get _filtered {
    Iterable<CodingChallenge> list = _challenges;
    if (_diff != 'All') {
      list = list.where((CodingChallenge c) => c.difficulty == _diff);
    }
    final String q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where(
        (CodingChallenge c) =>
            c.title.toLowerCase().contains(q) ||
            c.topics.any((String t) => t.toLowerCase().contains(q)) ||
            c.id.toLowerCase().contains(q),
      );
    }
    return list.toList();
  }

  Future<void> _run({required bool submit}) async {
    final CodingChallenge? c = _active;
    final String? opt = _selectedOption;
    if (c == null || opt == null) return;
    setState(() {
      _running = true;
      _results = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 420));
    final List<TestResult> results = c.runTests(opt);
    final bool allPass = results.every((TestResult t) => t.passed);
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
                ? 'Submitted · all tests passed · +${c.xpReward} XP'
                : 'Submission blocked — fix failing tests first',
          ),
        ),
      );
    }
  }

  void _spendHint() {
    final CodingChallenge? c = _active;
    if (c == null) return;
    final CodeOption opt = c.options.firstWhere(
      (CodeOption o) => o.id == _selectedOption,
      orElse: () => c.options.first,
    );
    if (opt.coachTip == null) return;
    setState(() => _hintSpends++);
    widget.progress.awardXp(-5);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(opt.coachTip!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScienceMajor major = ScienceMajors.byId(widget.progress.majorId);
    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: SciCosmic.appBar(
        context: context,
        title: 'Coding Arena',
        icon: Icons.code_rounded,
        subtitle: '${_challenges.length} challenges',
        trailing: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SciCosmic.pill(major.title),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SciCosmic.pill(
              '${widget.progress.streakDays} day streak',
              icon: Icons.local_fire_department_rounded,
              bg: SciCosmic.orange.withValues(alpha: 0.18),
              fg: SciCosmic.orange,
            ),
          ),
        ],
      ),
      body: SciStarfield(
        child: _active == null ? _buildList() : _buildWorkspace(_active!),
      ),
    );
  }

  Widget _buildList() {
    final List<CodingChallenge> filtered = _filtered;
    final int cleared = widget.progress.completedChallenges.length;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pick a challenge · $cleared cleared',
                style: const TextStyle(
                  color: SciCosmic.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '500 problems with real test evaluators. Choose an approach, run tests, submit.',
                style: TextStyle(color: SciCosmic.mute, fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (String v) => setState(() => _query = v),
                style: const TextStyle(color: SciCosmic.ink),
                decoration: InputDecoration(
                  hintText: 'Search title, topic, or id',
                  hintStyle: const TextStyle(color: SciCosmic.mute),
                  filled: true,
                  fillColor: SciCosmic.panel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: SciCosmic.mute),
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
                            child: SciCosmic.pill(
                              d,
                              bg: _diff == d
                                  ? SciCosmic.blue.withValues(alpha: 0.35)
                                  : SciCosmic.panelAlt,
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
                  style: const TextStyle(color: SciCosmic.mute, fontSize: 12),
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
              final CodingChallenge c = filtered[i];
              final bool done =
                  widget.progress.completedChallenges.contains(c.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() {
                    _active = c;
                    _selectedOption = c.options.first.id;
                    _results = null;
                    _tab = 0;
                    _hintSpends = 0;
                  }),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: SciCosmic.panelBox(),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                c.title,
                                style: const TextStyle(
                                  color: SciCosmic.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: <Widget>[
                                  SciCosmic.pill(
                                    c.difficulty,
                                    bg: c.difficulty == 'Easy'
                                        ? SciCosmic.success
                                            .withValues(alpha: 0.15)
                                        : SciCosmic.orange
                                            .withValues(alpha: 0.15),
                                    fg: c.difficulty == 'Easy'
                                        ? SciCosmic.success
                                        : SciCosmic.orange,
                                  ),
                                  ...c.topics.take(3).map(
                                        (String t) => SciCosmic.pill(t),
                                      ),
                                  SciCosmic.pill(
                                    '+${c.xpReward} XP',
                                    bg: SciCosmic.orange.withValues(alpha: 0.15),
                                    fg: SciCosmic.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          done ? Icons.check_circle : Icons.chevron_right,
                          color: done ? SciCosmic.success : SciCosmic.mute,
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

  Widget _buildWorkspace(CodingChallenge c) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final bool wide = box.maxWidth >= 980;
        final Widget left = _ProblemPane(
          challenge: c,
          tab: _tab,
          onTab: (int i) => setState(() => _tab = i),
          arraysCleared: widget.progress.arraysCleared,
          done: widget.progress.completedChallenges.contains(c.id),
          onBack: () => setState(() => _active = null),
        );
        final Widget right = _EditorPane(
          challenge: c,
          selectedOption: _selectedOption,
          onSelect: (String id) => setState(() {
            _selectedOption = id;
            _results = null;
          }),
          results: _results,
          running: _running,
          onRun: () => _run(submit: false),
          onSubmit: () => _run(submit: true),
          onHint: _spendHint,
          hintSpends: _hintSpends,
        );
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(flex: 5, child: left),
              Expanded(flex: 6, child: right),
            ],
          );
        }
        return ListView(
          children: <Widget>[
            SizedBox(height: 420, child: left),
            SizedBox(height: 640, child: right),
          ],
        );
      },
    );
  }
}

class _ProblemPane extends StatelessWidget {
  const _ProblemPane({
    required this.challenge,
    required this.tab,
    required this.onTab,
    required this.arraysCleared,
    required this.done,
    required this.onBack,
  });

  final CodingChallenge challenge;
  final int tab;
  final ValueChanged<int> onTab;
  final int arraysCleared;
  final bool done;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: SciCosmic.panelBox(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              TextButton(
                onPressed: onBack,
                child: const Text('← Challenges'),
              ),
              if (done)
                SciCosmic.pill(
                  'Cleared',
                  bg: SciCosmic.success.withValues(alpha: 0.2),
                  fg: SciCosmic.success,
                ),
            ],
          ),
          Row(
            children: <Widget>[
              _Tab('Problem', 0, tab, onTab),
              _Tab('Hints', 1, tab, onTab),
              _Tab('Past attempts', 2, tab, onTab),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: <Widget>[
                if (tab == 0) ...<Widget>[
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      color: SciCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      SciCosmic.pill(
                        challenge.difficulty,
                        fg: SciCosmic.success,
                        bg: SciCosmic.success.withValues(alpha: 0.12),
                      ),
                      ...challenge.topics.map((String t) => SciCosmic.pill(t)),
                      SciCosmic.pill(
                        '+${challenge.xpReward} XP',
                        bg: SciCosmic.orange.withValues(alpha: 0.15),
                        fg: SciCosmic.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    challenge.prompt,
                    style: const TextStyle(
                      color: SciCosmic.ink,
                      height: 1.45,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SciCosmic.panelAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      challenge.examples,
                      style: const TextStyle(
                        color: SciCosmic.mute,
                        fontFamily: 'monospace',
                        height: 1.4,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    challenge.constraints,
                    style: const TextStyle(color: SciCosmic.purple, fontSize: 13),
                  ),
                ] else if (tab == 1)
                  const Text(
                    'Hints cost XP. Use the coach tip after you run tests, '
                    'or tap Show next hint under the results panel.',
                    style: TextStyle(color: SciCosmic.mute, height: 1.4),
                  )
                else
                  Text(
                    done
                        ? 'You cleared this challenge. Progress is saved.'
                        : 'No successful submissions yet.',
                    style: const TextStyle(color: SciCosmic.mute),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            challenge.pathLabel,
            style: const TextStyle(
              color: SciCosmic.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (arraysCleared / 5).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: SciCosmic.stroke,
              color: SciCosmic.purple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$arraysCleared of 5 cleared · Clear ${challenge.title} to move closer to the Array Boss.',
            style: const TextStyle(color: SciCosmic.mute, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(this.label, this.index, this.current, this.onTap);
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bool on = index == current;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: on ? SciCosmic.purple : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: on ? SciCosmic.ink : SciCosmic.mute,
              fontWeight: on ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorPane extends StatelessWidget {
  const _EditorPane({
    required this.challenge,
    required this.selectedOption,
    required this.onSelect,
    required this.results,
    required this.running,
    required this.onRun,
    required this.onSubmit,
    required this.onHint,
    required this.hintSpends,
  });

  final CodingChallenge challenge;
  final String? selectedOption;
  final ValueChanged<String> onSelect;
  final List<TestResult>? results;
  final bool running;
  final VoidCallback onRun;
  final VoidCallback onSubmit;
  final VoidCallback onHint;
  final int hintSpends;

  @override
  Widget build(BuildContext context) {
    final CodeOption option = challenge.options.firstWhere(
      (CodeOption o) => o.id == selectedOption,
      orElse: () => challenge.options.first,
    );
    final int passed =
        results?.where((TestResult t) => t.passed).length ?? 0;
    final int total = results?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: SciCosmic.panelBox(radius: 18),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text(
                        'solution.py',
                        style: TextStyle(
                          color: SciCosmic.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SciCosmic.pill('Python'),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: running ? null : onRun,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SciCosmic.ink,
                          side: const BorderSide(color: SciCosmic.stroke),
                        ),
                        child: Text(running ? 'Running…' : 'Run tests'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: running ? null : onSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: SciCosmic.purple,
                        ),
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: SciCosmic.panelAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: option.id,
                        dropdownColor: SciCosmic.panelAlt,
                        items: challenge.options
                            .map(
                              (CodeOption o) => DropdownMenuItem<String>(
                                value: o.id,
                                child: Text(
                                  o.label,
                                  style: const TextStyle(color: SciCosmic.ink),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (String? id) {
                          if (id != null) onSelect(id);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D111C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SciCosmic.stroke),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          option.code,
                          style: const TextStyle(
                            color: Color(0xFFD4E0FF),
                            fontFamily: 'monospace',
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: <Widget>[
                      Icon(Icons.lock_outline, size: 14, color: SciCosmic.mute),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Your code runs in an isolated sandbox on our servers, never on your device.',
                          style: TextStyle(color: SciCosmic.mute, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 4,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: SciCosmic.panelBox(radius: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Text(
                              'Test results',
                              style: TextStyle(
                                color: SciCosmic.ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            if (results != null)
                              SciCosmic.pill(
                                '$passed of $total passed',
                                bg: passed == total
                                    ? SciCosmic.success.withValues(alpha: 0.15)
                                    : SciCosmic.orange.withValues(alpha: 0.15),
                                fg: passed == total
                                    ? SciCosmic.success
                                    : SciCosmic.orange,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: results == null
                              ? const Text(
                                  'Run tests to see visible cases.',
                                  style: TextStyle(color: SciCosmic.mute),
                                )
                              : ListView.separated(
                                  itemCount: results!.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (_, int i) {
                                    final TestResult t = results![i];
                                    return Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: t.passed
                                            ? SciCosmic.blue
                                                .withValues(alpha: 0.18)
                                            : SciCosmic.orange
                                                .withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            t.passed
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: t.passed
                                                ? SciCosmic.electric
                                                : SciCosmic.orange,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              t.passed
                                                  ? '${t.name} passed.'
                                                  : '${t.name}: ${t.detail}',
                                              style: const TextStyle(
                                                color: SciCosmic.ink,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const Text(
                          '2 hidden tests unlock when every visible test passes.',
                          style: TextStyle(color: SciCosmic.mute, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: SciCosmic.panelBox(radius: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Coach tip',
                          style: TextStyle(
                            color: SciCosmic.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            results == null
                                ? 'Run tests to unlock targeted feedback.'
                                : (option.coachTip ??
                                    'Keep iterating until every case passes.'),
                            style: const TextStyle(
                              color: SciCosmic.mute,
                              height: 1.4,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: onHint,
                          child: Text(
                            hintSpends == 0
                                ? 'Show next hint (−5 XP)'
                                : 'Hint shown (−5 XP)',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
