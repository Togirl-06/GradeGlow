import 'package:flutter/material.dart';

import 'tutor_markdown_body.dart';

/// Renders professor lecture text safely: plain text while streaming, rich
/// markdown + math only after the stream completes.
class ProfessorMessageBody extends StatelessWidget {
  const ProfessorMessageBody({
    super.key,
    required this.text,
    required this.isStreaming,
    this.textColor,
    this.placeholder = 'Writing lecture…',
  });

  final String text;
  final bool isStreaming;
  final Color? textColor;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final Color bodyColor = textColor ?? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;

    if (isStreaming) {
      if (text.trim().isEmpty) {
        return Text(
          placeholder,
          style: TextStyle(
            color: bodyColor.withValues(alpha: 0.72),
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        );
      }

      return Text(
        text,
        style: TextStyle(color: bodyColor, fontSize: 16, height: 1.68),
      );
    }

    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return TutorMarkdownBody(text: text, textColor: textColor, readerMode: true);
  }
}
