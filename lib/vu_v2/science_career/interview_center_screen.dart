import 'package:flutter/material.dart';

import 'interview_catalog.dart';
import 'science_career_content.dart';
import 'science_career_progress.dart';
import 'science_career_theme.dart';

class InterviewCenterScreen extends StatefulWidget {
  const InterviewCenterScreen({
    super.key,
    required this.progress,
    this.forJobId,
  });

  final ScienceCareerProgress progress;
  final String? forJobId;

  @override
  State<InterviewCenterScreen> createState() => _InterviewCenterScreenState();
}

class _ChatMsg {
  const _ChatMsg({required this.fromRecruiter, required this.text});
  final bool fromRecruiter;
  final String text;
}

class _InterviewCenterScreenState extends State<InterviewCenterScreen> {
  InterviewScenario? _active;
  String _query = '';
  String _filter = 'All';

  List<InterviewScenario> get _list {
    final ScienceMajor major = ScienceMajors.byId(widget.progress.majorId);
    Iterable<InterviewScenario> list = InterviewCatalog.all;
    if (_filter == 'My major') {
      list = list.where((InterviewScenario s) => s.majorTag == major.title);
    } else if (_filter != 'All') {
      list = list.where((InterviewScenario s) => s.level == _filter);
    }
    final String q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where(
        (InterviewScenario s) =>
            s.title.toLowerCase().contains(q) ||
            s.company.toLowerCase().contains(q) ||
            s.role.toLowerCase().contains(q),
      );
    }
    return list.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_active != null) {
      return _InterviewRoom(
        progress: widget.progress,
        scenario: _active!,
        forJobId: widget.forJobId,
        onBack: () => setState(() => _active = null),
      );
    }

    final List<InterviewScenario> list = _list;
    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: SciCosmic.appBar(
        context: context,
        title: 'Interview Center',
        icon: Icons.chat_bubble_outline_rounded,
        subtitle: '${InterviewCatalog.all.length} scenarios',
      ),
      body: SciStarfield(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                onChanged: (String v) => setState(() => _query = v),
                style: const TextStyle(color: SciCosmic.ink),
                decoration: InputDecoration(
                  hintText: 'Search company or role',
                  hintStyle: const TextStyle(color: SciCosmic.mute),
                  filled: true,
                  fillColor: SciCosmic.panel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: SciCosmic.mute),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: <String>[
                  'All',
                  'My major',
                  'Intern',
                  'Junior',
                  'Advanced',
                ]
                    .map(
                      (String f) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => setState(() => _filter = f),
                          child: SciCosmic.pill(
                            f,
                            bg: _filter == f
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${list.length} interviews',
                  style: const TextStyle(color: SciCosmic.mute, fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: list.length,
                itemBuilder: (_, int i) {
                  final InterviewScenario s = list[i];
                  final bool done = widget.progress.interviewHistory.any(
                    (Map<String, dynamic> h) => h['scenarioId'] == s.id,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(() => _active = s),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: SciCosmic.panelBox(radius: 14),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    s.role,
                                    style: const TextStyle(
                                      color: SciCosmic.ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${s.company} · ${s.recruiter}',
                                    style: const TextStyle(
                                      color: SciCosmic.mute,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    children: <Widget>[
                                      SciCosmic.pill(s.level),
                                      SciCosmic.pill(s.majorTag),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              done
                                  ? Icons.check_circle
                                  : Icons.chevron_right,
                              color: done
                                  ? SciCosmic.success
                                  : SciCosmic.mute,
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
      ),
    );
  }
}

class _InterviewRoom extends StatefulWidget {
  const _InterviewRoom({
    required this.progress,
    required this.scenario,
    required this.onBack,
    this.forJobId,
  });

  final ScienceCareerProgress progress;
  final InterviewScenario scenario;
  final VoidCallback onBack;
  final String? forJobId;

  @override
  State<_InterviewRoom> createState() => _InterviewRoomState();
}

class _InterviewRoomState extends State<_InterviewRoom> {
  late final TextEditingController _answer;
  late final List<_ChatMsg> _msgs;
  int _step = 0;
  bool _finished = false;
  bool _sending = false;
  final Map<String, int> _scores = <String, int>{
    'Technical correctness': 3,
    'Communication': 4,
    'Reasoning': 3,
    'Problem solving': 3,
  };

  @override
  void initState() {
    super.initState();
    _answer = TextEditingController();
    _msgs = <_ChatMsg>[
      _ChatMsg(fromRecruiter: true, text: widget.scenario.opener),
    ];
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _answer.text.trim();
    if (text.isEmpty || _finished || _sending) return;
    setState(() {
      _sending = true;
      _msgs.add(_ChatMsg(fromRecruiter: false, text: text));
      _answer.clear();
    });

    final String lower = text.toLowerCase();
    int hits = 0;
    for (final String k in widget.scenario.keywords) {
      if (lower.contains(k.toLowerCase())) hits++;
    }
    if (text.length > 80) hits++;
    if (hits >= 1) {
      _scores['Technical correctness'] =
          (_scores['Technical correctness']! + 1).clamp(1, 5);
      _scores['Problem solving'] =
          (_scores['Problem solving']! + 1).clamp(1, 5);
    }
    if (text.length > 60) {
      _scores['Communication'] =
          (_scores['Communication']! + 1).clamp(1, 5);
      _scores['Reasoning'] = (_scores['Reasoning']! + 1).clamp(1, 5);
    }

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    if (_step < widget.scenario.followUps.length) {
      setState(() {
        _msgs.add(
          _ChatMsg(
            fromRecruiter: true,
            text: widget.scenario.followUps[_step],
          ),
        );
        _step++;
        _sending = false;
      });
      return;
    }

    final int avg = (_scores.values.reduce((int a, int b) => a + b) /
            _scores.length)
        .round();
    final bool passed = avg >= 3 && text.length >= 30;
    await widget.progress.recordInterview(
      passed: passed,
      scores: Map<String, int>.from(_scores),
      feedback:
          'Focus on why you chose an approach. Hint cue: ${widget.scenario.hint}',
      scenarioId: widget.scenario.id,
      forJobId: widget.forJobId,
    );
    if (!mounted) return;
    setState(() {
      _finished = true;
      _sending = false;
      _msgs.add(
        _ChatMsg(
          fromRecruiter: true,
          text: passed
              ? (widget.forJobId != null
                  ? 'Interview passed. Check Career Center for your offer, then accept to unlock your workplace.'
                  : 'Strong practice round. Apply with your résumé in Career Center first, then interview for that role.')
              : 'Good effort. Expand answers with concrete steps, then retake.',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final InterviewScenario s = widget.scenario;
    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: SciCosmic.appBar(
        context: context,
        title: 'Interview Center',
        icon: Icons.chat_bubble_outline_rounded,
        subtitle: '${s.role} · ${s.level}',
        trailing: <Widget>[
          TextButton(
            onPressed: widget.onBack,
            child: const Text('All interviews'),
          ),
        ],
      ),
      body: SciStarfield(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final bool wide = c.maxWidth >= 900;
            final Widget left = Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: SciCosmic.panelBox(radius: 18),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: <Color>[
                            Color(0xFF1A1040),
                            Color(0xFF0E1A3A),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: SciCosmic.blue,
                            child: Icon(Icons.person, color: Colors.white, size: 40),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            s.recruiter,
                            style: const TextStyle(
                              color: SciCosmic.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'Recruiter · ${s.company}',
                            style: const TextStyle(color: SciCosmic.mute),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._scores.entries.map(
                    (MapEntry<String, int> e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            e.key,
                            style: const TextStyle(
                              color: SciCosmic.mute,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List<Widget>.generate(5, (int i) {
                              return Container(
                                width: 20,
                                height: 7,
                                margin: const EdgeInsets.only(right: 3),
                                decoration: BoxDecoration(
                                  color: i < e.value
                                      ? SciCosmic.blue
                                      : SciCosmic.stroke,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );

            final Widget right = Container(
              margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
              padding: const EdgeInsets.all(14),
              decoration: SciCosmic.panelBox(radius: 18),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Question ${_step + 1} of ${s.followUps.length + 1}',
                        style: const TextStyle(
                          color: SciCosmic.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      SciCosmic.pill(s.level),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _msgs.length,
                      itemBuilder: (_, int i) {
                        final _ChatMsg m = _msgs[i];
                        return Align(
                          alignment: m.fromRecruiter
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 480),
                            decoration: BoxDecoration(
                              color: m.fromRecruiter
                                  ? SciCosmic.panelAlt
                                  : SciCosmic.purple.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              m.text,
                              style: const TextStyle(
                                color: SciCosmic.ink,
                                height: 1.4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  TextField(
                    controller: _answer,
                    enabled: !_finished,
                    maxLines: 3,
                    style: const TextStyle(color: SciCosmic.ink),
                    decoration: InputDecoration(
                      hintText: 'Type your answer…',
                      hintStyle: const TextStyle(color: SciCosmic.mute),
                      filled: true,
                      fillColor: SciCosmic.panelAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.hint)),
                          );
                        },
                        child: const Text('Ask for a hint'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _finished || _sending ? null : _send,
                        style: FilledButton.styleFrom(
                          backgroundColor: SciCosmic.purple,
                        ),
                        child: Text(_sending ? 'Sending…' : 'Send answer'),
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (wide) {
              return Row(
                children: <Widget>[
                  SizedBox(width: 300, child: left),
                  Expanded(child: right),
                ],
              );
            }
            return ListView(
              children: <Widget>[
                SizedBox(height: 320, child: left),
                SizedBox(height: 520, child: right),
              ],
            );
          },
        ),
      ),
    );
  }
}
