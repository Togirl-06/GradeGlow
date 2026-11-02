import 'package:flutter/material.dart';

import 'biz_interview_catalog.dart';
import 'business_career_content.dart';
import 'business_career_progress.dart';
import 'business_career_theme.dart';

/// Interview Center — 4 MCQs for current major; 3/4 to pass → offer.
class BizInterviewCenterScreen extends StatefulWidget {
  const BizInterviewCenterScreen({super.key, required this.progress});

  final BusinessCareerProgress progress;

  @override
  State<BizInterviewCenterScreen> createState() =>
      _BizInterviewCenterScreenState();
}

class _BizInterviewCenterScreenState extends State<BizInterviewCenterScreen> {
  late List<BizInterviewQ> _questions;
  int _index = 0;
  final Map<String, String> _answers = <String, String>{};
  bool _finished = false;
  bool _passed = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final List<BizInterviewQ> pool =
        BizInterviewCatalog.forMajor(widget.progress.majorId);
    _questions = pool.take(4).toList();
    if (_questions.length < 4 && pool.isNotEmpty) {
      // Pad from full bank if a major has fewer than 4 (shouldn't happen).
      final List<BizInterviewQ> extra = BizInterviewCatalog.all()
          .where((BizInterviewQ q) => !_questions.any((BizInterviewQ x) => x.id == q.id))
          .take(4 - _questions.length)
          .toList();
      _questions = <BizInterviewQ>[..._questions, ...extra];
    }
    _index = 0;
    _answers.clear();
    _finished = false;
    _passed = false;
  }

  int get _score {
    int n = 0;
    for (final BizInterviewQ q in _questions) {
      if (_answers[q.id] == q.correctId) n++;
    }
    return n;
  }

  String? _firstAppliedWithoutOffer() {
    for (final String id in widget.progress.appliedJobIds) {
      final String s = widget.progress.applicationStatus[id] ?? 'none';
      if (s == 'applied' || s == 'interviewed') return id;
    }
    // Fallback: any applied that is not offered/hired/rejected
    for (final String id in widget.progress.appliedJobIds) {
      final String s = widget.progress.applicationStatus[id] ?? 'none';
      if (s != 'offered' && s != 'hired' && s != 'rejected') return id;
    }
    return null;
  }

  Future<void> _finish() async {
    if (_busy) return;
    setState(() => _busy = true);
    final int score = _score;
    final bool pass = score >= 3;
    setState(() {
      _finished = true;
      _passed = pass;
    });
    String? offeredJobId;
    if (pass) {
      offeredJobId = _firstAppliedWithoutOffer();
      if (offeredJobId != null) {
        await widget.progress.markInterviewed(offeredJobId);
        await widget.progress.grantOffer(offeredJobId);
      }
      await widget.progress.awardXp(80);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pass
              ? (offeredJobId != null
                  ? 'Interview passed · offer unlocked in Career Center'
                  : 'Interview passed · apply to a job to receive an offer')
              : 'Need 3 of 4 correct to pass. Review tips and try again.',
        ),
      ),
    );
  }

  void _select(String optionId) {
    if (_finished || _questions.isEmpty) return;
    final BizInterviewQ q = _questions[_index];
    setState(() => _answers[q.id] = optionId);
  }

  Future<void> _next() async {
    if (_questions.isEmpty) return;
    final BizInterviewQ q = _questions[_index];
    if (!_answers.containsKey(q.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick an answer first.')),
      );
      return;
    }
    if (_index >= _questions.length - 1) {
      await _finish();
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    final BusinessMajor major = BusinessMajors.byId(widget.progress.majorId);

    return Scaffold(
      backgroundColor: BizCosmic.bg,
      appBar: BizCosmic.appBar(
        context: context,
        title: 'Interview Center',
        icon: Icons.chat_bubble_outline_rounded,
        trailing: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BizCosmic.pill(major.title),
          ),
        ],
      ),
      body: BizStarfield(
        child: _questions.isEmpty
            ? const Center(
                child: Text(
                  'No interview questions for this major yet.',
                  style: TextStyle(color: BizCosmic.mute),
                ),
              )
            : _finished
                ? _buildResult()
                : _buildQuestion(),
      ),
    );
  }

  Widget _buildQuestion() {
    final BizInterviewQ q = _questions[_index];
    final String? selected = _answers[q.id];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        Text(
          'Question ${_index + 1} of ${_questions.length}',
          style: const TextStyle(color: BizCosmic.mute, fontSize: 12),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (_index + 1) / _questions.length,
            minHeight: 8,
            backgroundColor: BizCosmic.stroke,
            color: BizCosmic.emerald,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BizCosmic.panelBox(radius: 16),
          child: Text(
            q.prompt,
            style: const TextStyle(
              color: BizCosmic.ink,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...q.options.map((({String id, String label}) o) {
          final bool on = selected == o.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => _select(o.id),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: on
                      ? BizCosmic.royal.withValues(alpha: 0.22)
                      : BizCosmic.panel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: on ? BizCosmic.electric : BizCosmic.stroke,
                  ),
                ),
                child: Text(
                  o.label,
                  style: const TextStyle(
                    color: BizCosmic.ink,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy ? null : _next,
          style: FilledButton.styleFrom(
            backgroundColor: BizCosmic.emerald,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(
            _index >= _questions.length - 1 ? 'Submit interview' : 'Next',
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Pass with 3 of 4 correct. A pass marks you interviewed and grants '
          'an offer on your first applied job.',
          style: TextStyle(color: BizCosmic.mute, fontSize: 12, height: 1.35),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BizCosmic.panelBox(radius: 18),
          child: Column(
            children: <Widget>[
              Icon(
                _passed ? Icons.celebration_rounded : Icons.refresh_rounded,
                color: _passed ? BizCosmic.gold : BizCosmic.warning,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                _passed ? 'Interview passed' : 'Not quite',
                style: const TextStyle(
                  color: BizCosmic.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$_score of ${_questions.length} correct',
                style: TextStyle(
                  color: _passed ? BizCosmic.success : BizCosmic.warning,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _passed
                    ? 'Check Career Center for Accept offer on your applied role.'
                    : 'Review the tips below, then try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: BizCosmic.mute, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._questions.map((BizInterviewQ q) {
          final bool ok = _answers[q.id] == q.correctId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BizCosmic.panelBox(radius: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        ok ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: ok ? BizCosmic.success : BizCosmic.danger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          q.prompt,
                          style: const TextStyle(
                            color: BizCosmic.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tip: ${q.tip}',
                    style: const TextStyle(
                      color: BizCosmic.mute,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => setState(_load),
          style: OutlinedButton.styleFrom(
            foregroundColor: BizCosmic.ink,
            side: const BorderSide(color: BizCosmic.stroke),
            minimumSize: const Size.fromHeight(46),
          ),
          child: const Text('Retake interview'),
        ),
      ],
    );
  }
}
