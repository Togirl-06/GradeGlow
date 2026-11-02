import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/virtual_lecture.dart';
import '../../services/lecture_question_ticker.dart';
import '../../theme/mathematics_degree_theme.dart';

/// In-lecture question — unmistakable popup, 20s timer, one chance only.
class LectureCheckOverlay extends StatefulWidget {
  const LectureCheckOverlay({
    super.key,
    required this.check,
    required this.onAnswered,
  });

  final LectureKnowledgeCheck check;
  final void Function(bool correct, {String? tappedRegionId}) onAnswered;

  @override
  State<LectureCheckOverlay> createState() => _LectureCheckOverlayState();
}

class _LectureCheckOverlayState extends State<LectureCheckOverlay>
    with SingleTickerProviderStateMixin {
  int? _selected;
  String? _selectedRegionId;
  final TextEditingController _fillController = TextEditingController();
  bool? _answered;
  bool _timedOut = false;
  Timer? _autoContinueTimer;
  Timer? _countdownTimer;
  bool _continuing = false;
  late int _secondsLeft;
  late AnimationController _pulse;

  static const Duration _correctFeedbackDelay = Duration(milliseconds: 1400);
  static const Duration _incorrectOptionalDelay = Duration(milliseconds: 2200);

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.check.timeLimitSeconds.clamp(5, 120);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    unawaited(HapticFeedback.mediumImpact());
    unawaited(LectureQuestionTicker.start());
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _answered != null) return;
      setState(() => _secondsLeft -= 1);
      if (_secondsLeft <= 0) {
        _onTimeUp();
      }
    });
  }

  @override
  void dispose() {
    _autoContinueTimer?.cancel();
    _countdownTimer?.cancel();
    _pulse.dispose();
    unawaited(LectureQuestionTicker.stop());
    _fillController.dispose();
    super.dispose();
  }

  bool _grade() {
    final LectureKnowledgeCheck check = widget.check;
    if (check.kind == KnowledgeCheckKind.graphIdentify) {
      return _selectedRegionId == check.targetRegionId;
    }
    if (check.kind == KnowledgeCheckKind.fillBlank) {
      final String ans = _fillController.text.trim().toLowerCase();
      final String correct = (check.correctAnswer ?? '').trim().toLowerCase();
      return ans.isNotEmpty && ans == correct;
    }
    return _selected == check.correctIndex;
  }

  void _onTimeUp() {
    if (_answered != null || _continuing) return;
    _countdownTimer?.cancel();
    unawaited(LectureQuestionTicker.stop());
    setState(() {
      _timedOut = true;
      _answered = false;
    });
    _scheduleAutoContinue(false);
  }

  void _submitAnswer() {
    if (_answered != null || _continuing) return;
    _countdownTimer?.cancel();
    unawaited(LectureQuestionTicker.stop());
    final bool ok = _grade();
    setState(() {
      _timedOut = false;
      _answered = ok;
    });
    _scheduleAutoContinue(ok);
  }

  void _scheduleAutoContinue(bool correct) {
    _autoContinueTimer?.cancel();
    final Duration delay = correct ? _correctFeedbackDelay : _incorrectOptionalDelay;
    _autoContinueTimer = Timer(delay, () {
      if (!mounted || _answered == null || _continuing) return;
      _continuing = true;
      widget.onAnswered(correct, tappedRegionId: _selectedRegionId);
    });
  }

  bool _canSubmit(LectureKnowledgeCheck check) {
    if (check.kind == KnowledgeCheckKind.graphIdentify) {
      return _selectedRegionId != null;
    }
    if (check.kind == KnowledgeCheckKind.fillBlank) {
      return _fillController.text.trim().isNotEmpty;
    }
    return _selected != null;
  }

  @override
  Widget build(BuildContext context) {
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);
    final LectureKnowledgeCheck check = widget.check;
    final bool correct = _answered == true;
    final int limit = check.timeLimitSeconds.clamp(5, 120);
    final double progress = (_secondsLeft / limit).clamp(0.0, 1.0);

    return Column(
      children: <Widget>[
        Expanded(
          child: IgnorePointer(
            ignoring: check.kind == KnowledgeCheckKind.graphIdentify,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),
        ),
        Material(
          color: Colors.black.withValues(alpha: 0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.75, end: 1).animate(_pulse),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.primaryLight),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.quiz_rounded, color: c.primaryLight, size: 22),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'QUESTION — Your turn',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          if (_answered == null)
                            Text(
                              '${_secondsLeft}s',
                              style: TextStyle(
                                color: _secondsLeft <= 5
                                    ? Colors.redAccent
                                    : c.primaryLight,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_answered == null) ...<Widget>[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white12,
                        color: _secondsLeft <= 5 ? Colors.redAccent : c.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    check.prompt,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  if (check.kind == KnowledgeCheckKind.graphIdentify) ...<Widget>[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.primaryLight.withValues(alpha: 0.5)),
                      ),
                      child: const Text(
                        'Tap the structure on the lecture diagram above — one chance.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (check.kind == KnowledgeCheckKind.fillBlank)
                    TextField(
                      controller: _fillController,
                      enabled: _answered == null,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Your answer…',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                  else if (check.kind != KnowledgeCheckKind.graphIdentify)
                    ...List<Widget>.generate(check.options.length, (int i) {
                      final bool chosen = _selected == i;
                      final bool showResult = _answered != null;
                      final bool isCorrectOption = i == check.correctIndex;

                      Color? bg;
                      Color border = Colors.white24;
                      if (showResult && isCorrectOption) {
                        bg = c.success.withValues(alpha: 0.25);
                        border = c.success;
                      } else if (showResult && chosen && !isCorrectOption) {
                        bg = Colors.red.withValues(alpha: 0.2);
                        border = Colors.redAccent;
                      } else if (chosen) {
                        bg = c.primary.withValues(alpha: 0.2);
                        border = c.primary;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          onPressed:
                              _answered != null ? null : () => setState(() => _selected = i),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: bg,
                            foregroundColor: Colors.white,
                            side: BorderSide(color: border),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            alignment: Alignment.centerLeft,
                          ),
                          child: Text(check.options[i]),
                        ),
                      );
                    }),
                  if (_answered != null) ...<Widget>[
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Icon(
                          correct
                              ? Icons.check_circle_rounded
                              : Icons.info_outline_rounded,
                          color: correct ? c.success : c.primaryLight,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          correct
                              ? (_continuing ? 'Continuing…' : 'Correct!')
                              : (_timedOut
                                  ? "Time's up — one chance only"
                                  : 'Not quite — here is why:'),
                          style: TextStyle(
                            color: correct ? c.success : c.primaryLight,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      check.explanation.isNotEmpty
                          ? check.explanation
                          : (correct
                              ? 'Nice work — the lecture continues.'
                              : 'Review the explanation and keep going.'),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _continuing ? 'Resuming…' : 'Continuing automatically…',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_answered == null &&
                      check.kind != KnowledgeCheckKind.graphIdentify)
                    FilledButton.icon(
                      onPressed: _canSubmit(check) ? _submitAnswer : null,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Submit Answer'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
