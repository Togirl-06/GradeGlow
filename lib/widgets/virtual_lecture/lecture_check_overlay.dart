import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/virtual_lecture.dart';
import '../../theme/mathematics_degree_theme.dart';

/// Bottom participation panel — whiteboard stays visible while the student answers.
class LectureCheckOverlay extends StatefulWidget {
  const LectureCheckOverlay({
    super.key,
    required this.check,
    required this.onAnswered,
  });

  final LectureKnowledgeCheck check;
  final void Function(bool correct) onAnswered;

  @override
  State<LectureCheckOverlay> createState() => _LectureCheckOverlayState();
}

class _LectureCheckOverlayState extends State<LectureCheckOverlay> {
  int? _selected;
  final TextEditingController _fillController = TextEditingController();
  bool? _answered;
  Timer? _autoContinueTimer;
  bool _continuing = false;

  static const Duration _correctFeedbackDelay = Duration(milliseconds: 1400);
  static const Duration _incorrectOptionalDelay = Duration(milliseconds: 2200);

  @override
  void dispose() {
    _autoContinueTimer?.cancel();
    _fillController.dispose();
    super.dispose();
  }

  bool _grade() {
    final LectureKnowledgeCheck check = widget.check;
    if (check.kind == KnowledgeCheckKind.fillBlank) {
      final String ans = _fillController.text.trim().toLowerCase();
      final String correct = (check.correctAnswer ?? '').trim().toLowerCase();
      return ans.isNotEmpty && ans == correct;
    }
    return _selected == check.correctIndex;
  }

  void _submitAnswer() {
    if (_answered != null || _continuing) return;
    final bool ok = _grade();
    setState(() => _answered = ok);

    final LectureKnowledgeCheck check = widget.check;
    if (ok || !check.requireCorrect) {
      _scheduleAutoContinue(ok);
    }
  }

  void _scheduleAutoContinue(bool correct) {
    _autoContinueTimer?.cancel();
    final Duration delay = correct ? _correctFeedbackDelay : _incorrectOptionalDelay;
    _autoContinueTimer = Timer(delay, () {
      if (!mounted || _answered == null || _continuing) return;
      _continuing = true;
      widget.onAnswered(correct);
    });
  }

  void _tryAgain() {
    _autoContinueTimer?.cancel();
    setState(() {
      _answered = null;
      _selected = null;
      _continuing = false;
    });
  }

  bool _canSubmit(LectureKnowledgeCheck check) {
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

    return Column(
      children: <Widget>[
        Expanded(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
        ),
        Material(
          color: Colors.black.withValues(alpha: 0.94),
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
                  Row(
                    children: <Widget>[
                      Icon(Icons.draw_outlined, color: c.primaryLight, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          check.requireCorrect
                              ? 'Your turn — predict the next step on the board'
                              : 'Quick check — answer to continue',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  else
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
                          onPressed: _answered != null ? null : () => setState(() => _selected = i),
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
                          correct ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          color: correct ? c.success : c.primaryLight,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          correct
                              ? (_continuing ? 'Continuing on the board…' : 'Correct!')
                              : 'Not quite — here is why:',
                          style: TextStyle(
                            color: correct ? c.success : c.primaryLight,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      check.explanation,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), height: 1.4),
                    ),
                    if (correct || !check.requireCorrect) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        _continuing ? 'Resuming…' : 'The board continues automatically…',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  if (_answered == null)
                    FilledButton.icon(
                      onPressed: _canSubmit(check) ? _submitAnswer : null,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Submit Answer'),
                    )
                  else if (!correct && check.requireCorrect)
                    FilledButton.icon(
                      onPressed: _continuing ? null : _tryAgain,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
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
