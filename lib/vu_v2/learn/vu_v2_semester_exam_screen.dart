import 'dart:async';

import 'package:flutter/material.dart';

import '../campus/vu_v2_certificate_screen.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_topic_content_models.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

/// Timed semester / course exam with pass-fail and certificate eligibility.
class VuV2SemesterExamScreen extends StatefulWidget {
  const VuV2SemesterExamScreen({
    super.key,
    required this.progress,
    required this.title,
    required this.subtitle,
    required this.questions,
    required this.studentName,
    required this.courseId,
    required this.courseTitle,
    this.minutes = 20,
    this.passPercent = 70,
  });

  final VuV2ProgressStore progress;
  final String title;
  final String subtitle;
  final List<VuV2Mcq> questions;
  final String studentName;
  final String courseId;
  final String courseTitle;
  final int minutes;
  final int passPercent;

  @override
  State<VuV2SemesterExamScreen> createState() => _VuV2SemesterExamScreenState();
}

class _VuV2SemesterExamScreenState extends State<VuV2SemesterExamScreen> {
  int _index = 0;
  final Map<int, int> _answers = <int, int>{};
  final Map<int, String> _short = <int, String>{};
  bool _submitted = false;
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.minutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      if (_secondsLeft <= 0) {
        t.cancel();
        setState(() => _submitted = true);
        unawaited(_finalize());
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  VuV2Mcq get _current => widget.questions[_index];

  int get _score {
    int correct = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      final VuV2Mcq q = widget.questions[i];
      if (q.kind == VuV2QuestionKind.shortAnswer) {
        final String ans = (_short[i] ?? '').trim().toLowerCase();
        final List<String> keys = q.shortAnswerKey ?? const <String>[];
        if (keys.any((String k) => ans.contains(k.toLowerCase()))) correct++;
      } else if (_answers[i] == q.correctIndex) {
        correct++;
      }
    }
    return correct;
  }

  double get _percent =>
      widget.questions.isEmpty ? 0 : 100 * _score / widget.questions.length;

  bool get _passed => _percent >= widget.passPercent;

  String get _clock {
    final int m = _secondsLeft ~/ 60;
    final int s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _finalize() async {
    await widget.progress.recordQuiz('exam_${widget.courseId}', _percent);
    if (_passed) {
      await widget.progress.awardCertificate(widget.courseId);
    }
  }

  Future<void> _submit() async {
    _timer?.cancel();
    setState(() => _submitted = true);
    await _finalize();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const VuV2EmptyState(
          title: 'Exam not ready',
          subtitle: 'Questions are still being authored for this semester.',
        ),
      );
    }

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: Text('Exam results')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: <Widget>[
            VuV2Surface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _passed ? 'Pass' : 'Fail',
                    style: TextStyle(
                      color: _passed ? VuV2Colors.success : VuV2Colors.danger,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_score / ${widget.questions.length} · ${_percent.round()}% '
                    '(pass ≥${widget.passPercent}%)',
                    style: TextStyle(color: VuV2Colors.ink),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _passed
                        ? 'Certificate eligible — open your certificate.'
                        : 'Review modules and retry when ready.',
                    style: TextStyle(color: VuV2Colors.mute),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_passed)
              VuV2PrimaryButton(
                label: 'View certificate',
                icon: Icons.workspace_premium_rounded,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VuV2CertificateScreen(
                        studentName: widget.studentName,
                        courseTitle: widget.courseTitle,
                        verificationId:
                            'GG-${widget.courseId.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch % 100000}',
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(_passed),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }

    final bool short = _current.kind == VuV2QuestionKind.shortAnswer;
    final int? selected = _answers[_index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course exam'),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _clock,
                style: TextStyle(
                  color: VuV2Colors.orange,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(widget.title,
              style: TextStyle(
                color: VuV2Colors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              )),
          Text(widget.subtitle, style: TextStyle(color: VuV2Colors.mute)),
          const SizedBox(height: 12),
          VuV2ProgressBar(value: (_index + 1) / widget.questions.length),
          const SizedBox(height: 14),
          VuV2Surface(
            child: Text(
              _current.prompt,
              style: TextStyle(
                color: VuV2Colors.ink,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (short)
            TextField(
              style: TextStyle(color: VuV2Colors.ink),
              decoration: InputDecoration(
                hintText: 'Short answer…',
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
                        _current.choices[i],
                        style: TextStyle(color: VuV2Colors.ink),
                      ),
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
          VuV2PrimaryButton(
            label: _index == widget.questions.length - 1 ? 'Submit exam' : 'Next',
            onPressed: () {
              if (short && (_short[_index] ?? '').trim().isEmpty) return;
              if (!short && selected == null) return;
              if (_index == widget.questions.length - 1) {
                unawaited(_submit());
              } else {
                setState(() => _index++);
              }
            },
          ),
        ],
      ),
    );
  }
}
