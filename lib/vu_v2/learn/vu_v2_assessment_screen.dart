import 'package:flutter/material.dart';

import '../data/vu_v2_topic_content_models.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

/// Interactive topic quiz or course final exam.
class VuV2AssessmentScreen extends StatefulWidget {
  const VuV2AssessmentScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.questions,
    this.passPercent = 70,
    this.isExam = false,
    this.onCompleted,
  });

  final String title;
  final String subtitle;
  final List<VuV2Mcq> questions;
  final int passPercent;
  final bool isExam;
  final ValueChanged<double>? onCompleted;

  @override
  State<VuV2AssessmentScreen> createState() => _VuV2AssessmentScreenState();
}

class _VuV2AssessmentScreenState extends State<VuV2AssessmentScreen> {
  int _index = 0;
  final Map<int, int> _answers = <int, int>{};
  final Map<int, String> _short = <int, String>{};
  bool _submitted = false;
  bool _reported = false;

  VuV2Mcq get _current => widget.questions[_index];

  bool _isCorrect(int i) {
    final VuV2Mcq q = widget.questions[i];
    if (q.kind == VuV2QuestionKind.shortAnswer) {
      final String ans = (_short[i] ?? '').trim().toLowerCase();
      final List<String> keys = q.shortAnswerKey ?? const <String>[];
      if (keys.isEmpty) return ans.isNotEmpty;
      return keys.any((String k) => ans.contains(k.toLowerCase()));
    }
    return _answers[i] == q.correctIndex;
  }

  int get _score {
    int correct = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (_isCorrect(i)) correct++;
    }
    return correct;
  }

  double get _percent =>
      widget.questions.isEmpty ? 0 : 100 * _score / widget.questions.length;

  bool get _passed => _percent >= widget.passPercent;

  void _submitResults() {
    setState(() => _submitted = true);
    if (!_reported) {
      _reported = true;
      widget.onCompleted?.call(_percent);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const VuV2EmptyState(
          title: 'No questions yet',
          subtitle: 'Assessment content is still being authored for this item.',
        ),
      );
    }

    if (_submitted) return _results();

    final bool short = _current.kind == VuV2QuestionKind.shortAnswer;
    final int? selected = _answers[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isExam ? 'Course exam' : 'Topic quiz'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            widget.title,
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(widget.subtitle, style: const TextStyle(color: VuV2Colors.mute)),
          const SizedBox(height: 12),
          VuV2ProgressBar(
            value: (_index + 1) / widget.questions.length,
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${_index + 1} of ${widget.questions.length}'
            '${_current.kind == VuV2QuestionKind.trueFalse ? ' · True/False' : ''}'
            '${short ? ' · Short answer' : ''}',
            style: TextStyle(
              color: VuV2Colors.orange,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          VuV2Surface(
            child: Text(
              _current.prompt,
              style: const TextStyle(
                color: VuV2Colors.ink,
                fontWeight: FontWeight.w800,
                height: 1.4,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (short)
            TextField(
              style: const TextStyle(color: VuV2Colors.ink),
              decoration: const InputDecoration(
                hintText: 'Type a short answer…',
                hintStyle: TextStyle(color: VuV2Colors.mute),
                border: OutlineInputBorder(),
              ),
              onChanged: (String v) => _short[_index] = v,
            )
          else
            ...List<Widget>.generate(_current.choices.length, (int i) {
              final bool isSelected = selected == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isSelected
                      ? VuV2Colors.orange.withValues(alpha: 0.18)
                      : VuV2Colors.navyElevated,
                  borderRadius: BorderRadius.circular(VuV2Radii.md),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(VuV2Radii.md),
                    onTap: () => setState(() => _answers[_index] = i),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(VuV2Radii.md),
                        border: Border.all(
                          color: isSelected
                              ? VuV2Colors.orange
                              : VuV2Colors.stroke,
                        ),
                      ),
                      child: Text(
                        '${String.fromCharCode(65 + i)}. ${_current.choices[i]}',
                        style: const TextStyle(
                          color: VuV2Colors.ink,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              if (_index > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _index--),
                    child: Text('Back'),
                  ),
                ),
              if (_index > 0) const SizedBox(width: 10),
              Expanded(
                child: VuV2PrimaryButton(
                  label: _index == widget.questions.length - 1
                      ? 'Submit'
                      : 'Next',
                  onPressed: () {
                    if (short && (_short[_index] ?? '').trim().isEmpty) return;
                    if (!short && selected == null) return;
                    if (_index == widget.questions.length - 1) {
                      _submitResults();
                    } else {
                      setState(() => _index++);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _results() {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _passed ? 'Passed' : 'Not yet — review and retry',
                  style: TextStyle(
                    color: _passed ? const Color(0xFF34D399) : VuV2Colors.orange,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_score / ${widget.questions.length} correct · '
                  '${_percent.round()}% (pass ≥${widget.passPercent}%)',
                  style: const TextStyle(color: VuV2Colors.ink, height: 1.4),
                ),
                const SizedBox(height: 12),
                VuV2ProgressBar(value: _percent / 100),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const VuV2SectionTitle('Answer review'),
          const SizedBox(height: 8),
          ...List<Widget>.generate(widget.questions.length, (int i) {
            final VuV2Mcq q = widget.questions[i];
            final bool ok = _isCorrect(i);
            final String yours = q.kind == VuV2QuestionKind.shortAnswer
                ? (_short[i] ?? '—')
                : (_answers[i] == null
                    ? '—'
                    : q.choices[_answers[i]!]);
            final String correct = q.kind == VuV2QuestionKind.shortAnswer
                ? (q.shortAnswerKey?.join(', ') ?? q.explanation)
                : q.choices[q.correctIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: VuV2Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${ok ? '✓' : '✗'} Q${i + 1}. ${q.prompt}',
                      style: TextStyle(
                        color: ok
                            ? const Color(0xFF34D399)
                            : VuV2Colors.orange,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your answer: $yours',
                      style: const TextStyle(color: VuV2Colors.mute),
                    ),
                    Text(
                      'Correct: $correct',
                      style: const TextStyle(color: VuV2Colors.ink),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      q.explanation,
                      style: const TextStyle(
                        color: VuV2Colors.mute,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          VuV2PrimaryButton(
            label: _passed ? 'Done' : 'Retry assessment',
            onPressed: () {
              if (_passed) {
                Navigator.pop(context, true);
              } else {
                setState(() {
                  _submitted = false;
                  _reported = false;
                  _index = 0;
                  _answers.clear();
                  _short.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
