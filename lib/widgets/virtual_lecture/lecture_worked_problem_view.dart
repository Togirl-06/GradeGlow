import 'package:flutter/material.dart';

import '../../models/virtual_lecture.dart';
import 'lecture_math_view.dart';

/// Problem-first whiteboard — the AI professor solves step by step as speech progresses.
class LectureWorkedProblemView extends StatelessWidget {
  const LectureWorkedProblemView({
    super.key,
    required this.problem,
    required this.steps,
    required this.progress,
    this.answer,
    this.accent,
    this.textColor,
  });

  final String problem;
  final List<LectureProblemStep> steps;
  final double progress;
  final String? answer;
  final Color? accent;
  final Color? textColor;

  int get _totalRevealSlots => 1 + steps.length + (answer != null ? 1 : 0);

  int get _revealedSlots {
    // Spend early progress on the problem statement so steps don't race the voice.
    final double eased = progress <= 0.12
        ? progress / 0.12 * 0.15
        : 0.15 + ((progress - 0.12) / 0.88) * 0.85;
    return (eased.clamp(0.0, 1.0) * _totalRevealSlots).floor().clamp(0, _totalRevealSlots);
  }

  bool get _showProblem => _revealedSlots >= 1;

  int get _visibleSteps => (_revealedSlots - 1).clamp(0, steps.length);

  bool get _showAnswer => answer != null && _revealedSlots >= _totalRevealSlots;

  @override
  Widget build(BuildContext context) {
    // Prefer explicit colors — avoid Theme.of during video-lecture teardown.
    final Color primary = accent ?? const Color(0xFFFACC15);
    final Color body = textColor ?? const Color(0xFFF8FAFC);

    return ListView(
      physics: const ClampingScrollPhysics(),
      children: <Widget>[
        AnimatedOpacity(
          opacity: _showProblem ? 1 : 0,
          duration: const Duration(milliseconds: 320),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.assignment_outlined, size: 16, color: primary),
                    const SizedBox(width: 6),
                    Text(
                      'Problem',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LectureMathText(
                  text: problem,
                  color: body,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
        ),
        if (_visibleSteps > 0) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            'Solution',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          ...List<Widget>.generate(_visibleSteps, (int i) {
            final LectureProblemStep step = steps[i];
            final bool isLatest = i == _visibleSteps - 1;
            return _StepCard(
              index: i + 1,
              step: step,
              accent: primary,
              textColor: body,
              highlighted: isLatest && progress < 1,
            );
          }),
        ],
        if (_showAnswer && answer != null) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.45)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: LectureMathText(
                    text: 'Answer: $answer',
                    color: body,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.step,
    required this.accent,
    required this.textColor,
    this.highlighted = false,
  });

  final int index;
  final LectureProblemStep step;
  final Color accent;
  final Color textColor;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted ? accent.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted ? accent.withValues(alpha: 0.5) : accent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step.title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: LectureMathText(
              text: step.work,
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (step.note != null) ...<Widget>[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                step.note!,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.75),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
