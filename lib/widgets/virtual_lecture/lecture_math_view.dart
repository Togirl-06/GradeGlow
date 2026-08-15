import 'package:flutter/material.dart';

import '../../utils/lecture_math_format.dart';
import '../math_rich_text.dart';

/// Clear math rendering for the lecture whiteboard.
class LectureMathDisplay extends StatelessWidget {
  const LectureMathDisplay({
    super.key,
    required this.expression,
    required this.color,
    this.highlight,
    this.fontSize = 22,
    this.progress = 1,
    this.compact = false,
  });

  final String expression;
  final Color color;
  final String? highlight;
  final double fontSize;
  final double progress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (expression.trim().isEmpty) return const SizedBox.shrink();

    // Clinical / English checklists must stay readable (math mode eats spaces).
    if (!LectureMathFormat.containsMath(expression)) {
      final double opacity = (0.4 + 0.6 * progress.clamp(0, 1)).clamp(0.4, 1);
      return AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 280),
        child: Text(
          expression.trim(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),
      );
    }

    final String latex = LectureMathFormat.withHighlight(expression, highlight);
    final double opacity = (0.4 + 0.6 * progress.clamp(0, 1)).clamp(0.4, 1);

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 280),
      child: MathDisplayBlock(
        latex: latex,
        color: color,
        fontSize: fontSize,
        compact: compact,
      ),
    );
  }
}

/// Body text that renders inline math when present.
class LectureMathText extends StatelessWidget {
  const LectureMathText({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 15,
    this.fontWeight,
    this.textAlign,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    if (LectureMathFormat.containsMath(trimmed)) {
      final String latex = LectureMathFormat.toLatex(trimmed);
      return MathRichText(
        text: r'$' + latex + r'$',
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        textAlign: textAlign,
      );
    }

    return Text(
      trimmed,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.4,
      ),
    );
  }
}
