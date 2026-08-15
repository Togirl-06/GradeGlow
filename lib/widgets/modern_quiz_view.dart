import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import 'math_rich_text.dart';

/// Aptitude-style quiz layout: progress bar, option cards, Next CTA.
class ModernQuizView extends StatefulWidget {
  const ModernQuizView({
    super.key,
    required this.title,
    required this.questionNumber,
    required this.totalQuestions,
    required this.prompt,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
    required this.onBack,
    required this.onNext,
    this.onEndExam,
    this.nextLabel = 'Next',
    this.nextEnabled = true,
    this.showTimer = true,
    this.questionSeconds = 120,
    this.useMath = false,
    this.revealed = false,
    this.correctIndex,
  });

  final String title;
  final int questionNumber;
  final int totalQuestions;
  final String prompt;
  final List<String> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback? onEndExam;
  final String nextLabel;
  final bool nextEnabled;
  final bool showTimer;
  final int questionSeconds;
  final bool useMath;
  final bool revealed;
  final int? correctIndex;

  @override
  State<ModernQuizView> createState() => _ModernQuizViewState();
}

class _ModernQuizViewState extends State<ModernQuizView> {
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void didUpdateWidget(ModernQuizView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionNumber != widget.questionNumber) {
      _resetTimer();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    if (!widget.showTimer) return;
    _secondsLeft = widget.questionSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      if (_secondsLeft <= 0) {
        t.cancel();
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

  String _formatTime(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;
    final Color textPrimary = StudyColors.textPrimary(brightness);
    final Color textSecondary = StudyColors.textSecondary(brightness);
    final double progress = widget.totalQuestions <= 0
        ? 0
        : widget.questionNumber / widget.totalQuestions;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? <Color>[const Color(0xFF0F172A), StudyColors.background(brightness)]
              : <Color>[StudyColors.primaryTint(brightness), const Color(0xFFF8FAFC)],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: <Widget>[
                  _RoundIconButton(icon: Icons.arrow_back_rounded, onTap: widget.onBack),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (widget.showTimer)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.schedule_rounded, size: 18, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(_secondsLeft),
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.05, 1.0),
                  minHeight: 5,
                  backgroundColor: StudyColors.primary.withValues(alpha: 0.12),
                  color: StudyColors.primary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                'Questions ${widget.questionNumber} of ${widget.totalQuestions}',
                style: TextStyle(
                  color: StudyColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                children: <Widget>[
                  widget.useMath
                      ? MathRichText(
                          text: widget.prompt,
                          color: textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        )
                      : Text(
                          widget.prompt,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                  const SizedBox(height: 24),
                  ...List<Widget>.generate(widget.options.length, (int index) {
                    final bool selected = widget.selectedIndex == index;
                    final bool? correctState = widget.revealed && widget.correctIndex != null
                        ? index == widget.correctIndex
                        : null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _QuizOptionCard(
                        label: widget.options[index],
                        selected: selected,
                        revealed: widget.revealed,
                        isCorrect: correctState,
                        useMath: widget.useMath,
                        onTap: widget.revealed
                            ? null
                            : () {
                                // Single-choice: one selection per question.
                                widget.onSelect(index);
                              },
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: widget.nextEnabled ? widget.onNext : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                        foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                        disabledBackgroundColor: (isDark ? Colors.white : const Color(0xFF0F172A))
                            .withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(widget.nextLabel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  if (widget.onEndExam != null) ...<Widget>[
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: widget.onEndExam,
                      child: Text(
                        'End exam',
                        style: TextStyle(
                          color: textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Material(
      color: StudyColors.surface(brightness),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: StudyColors.textPrimary(brightness)),
        ),
      ),
    );
  }
}

class _QuizOptionCard extends StatelessWidget {
  const _QuizOptionCard({
    required this.label,
    required this.selected,
    required this.onTap,
    this.useMath = false,
    this.revealed = false,
    this.isCorrect,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool useMath;
  final bool revealed;
  final bool? isCorrect;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;
    final Color textPrimary = StudyColors.textPrimary(brightness);

    Color borderColor = StudyColors.border(brightness);
    Color fillStart = StudyColors.surface(brightness);
    Color fillEnd = StudyColors.surface(brightness);
    Color indicatorFill = Colors.transparent;
    Color indicatorBorder = StudyColors.border(brightness);
    IconData? indicatorIcon;

    if (revealed && isCorrect == true) {
      borderColor = StudyColors.success;
      fillStart = StudyColors.success.withValues(alpha: 0.14);
      fillEnd = StudyColors.success.withValues(alpha: 0.06);
      indicatorFill = StudyColors.success;
      indicatorBorder = StudyColors.success;
      indicatorIcon = Icons.check_rounded;
    } else if (revealed && selected && isCorrect == false) {
      borderColor = StudyColors.danger;
      fillStart = StudyColors.danger.withValues(alpha: 0.12);
      fillEnd = StudyColors.danger.withValues(alpha: 0.05);
      indicatorFill = StudyColors.danger;
      indicatorBorder = StudyColors.danger;
      indicatorIcon = Icons.close_rounded;
    } else if (selected) {
      borderColor = StudyColors.primary;
      fillStart = StudyColors.primary.withValues(alpha: isDark ? 0.28 : 0.14);
      fillEnd = StudyColors.primaryLight.withValues(alpha: isDark ? 0.12 : 0.06);
      indicatorFill = StudyColors.primary;
      indicatorBorder = StudyColors.primary;
      indicatorIcon = Icons.check_rounded;
    } else if (revealed) {
      borderColor = StudyColors.border(brightness).withValues(alpha: 0.5);
      fillStart = StudyColors.surface(brightness).withValues(alpha: 0.55);
      fillEnd = StudyColors.surface(brightness).withValues(alpha: 0.55);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[fillStart, fillEnd],
            ),
            border: Border.all(color: borderColor, width: selected || revealed ? 1.5 : 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: useMath
                      ? MathRichText(
                          text: label,
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        )
                      : Text(
                          label,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: indicatorFill,
                    border: Border.all(color: indicatorBorder, width: 1.5),
                  ),
                  child: indicatorIcon != null
                      ? Icon(indicatorIcon, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Results screen after completing a quiz.
class ModernQuizResultsView extends StatelessWidget {
  const ModernQuizResultsView({
    super.key,
    required this.title,
    required this.score,
    required this.total,
    required this.onDone,
    required this.onRetry,
    this.answeredCount,
    this.endedEarly = false,
  });

  final String title;
  final int score;
  final int total;
  final VoidCallback onDone;
  final VoidCallback onRetry;
  final int? answeredCount;
  final bool endedEarly;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final int percent = total <= 0 ? 0 : ((score / total) * 100).round();
    final int answered = answeredCount ?? total;
    final String detail = endedEarly
        ? '$score / $total correct · $answered of $total answered'
        : '$score / $total correct · $percent%';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            StudyColors.primaryTint(brightness),
            StudyColors.background(brightness),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                percent >= 70 ? Icons.emoji_events_rounded : Icons.school_rounded,
                size: 64,
                color: percent >= 70 ? StudyColors.accent : StudyColors.primary,
              ),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                detail,
                style: TextStyle(
                  color: StudyColors.textSecondary(brightness),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (endedEarly) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  'Exam ended early',
                  style: TextStyle(color: StudyColors.textSecondary(brightness), fontSize: 13),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: onDone,
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Try again', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirms ending a quiz before all questions are answered.
Future<bool> confirmEndExam(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('End exam?'),
      content: const Text(
        'Your progress will be saved for the questions you answered. '
        'Unanswered questions count as incorrect.',
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep going')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('End exam')),
      ],
    ),
  );
  return confirmed ?? false;
}
