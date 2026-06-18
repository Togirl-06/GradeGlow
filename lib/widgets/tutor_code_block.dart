import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/study_theme.dart';
import 'tutor_syntax_highlighter.dart';

/// ChatGPT-style fenced code block with language label and copy.
class TutorCodeBlock extends StatelessWidget {
  const TutorCodeBlock({
    super.key,
    required this.code,
    this.language = '',
  });

  final String code;
  final String language;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool dark = brightness == Brightness.dark;
    final Color shell = dark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6);
    final Color header = dark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB);
    final Color border = dark ? const Color(0xFF3A3A3A) : StudyColors.border(brightness);
    final String label = language.isEmpty ? 'code' : language.toLowerCase();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: shell,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: header,
            child: Row(
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: StudyColors.textSecondary(brightness),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _CopyIconButton(
                  tooltip: 'Copy code',
                  onCopy: () => Clipboard.setData(ClipboardData(text: code)),
                  brightness: brightness,
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: SelectableText.rich(
              TutorSyntaxHighlighter.highlight(code, language: language),
              style: const TextStyle(
                fontFamily: 'Consolas',
                fontFamilyFallback: <String>['Courier New', 'monospace'],
                fontSize: 13.5,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyIconButton extends StatelessWidget {
  const _CopyIconButton({
    required this.tooltip,
    required this.onCopy,
    required this.brightness,
  });

  final String tooltip;
  final VoidCallback onCopy;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCopy,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.copy_outlined,
          size: 16,
          color: StudyColors.textSecondary(brightness),
        ),
      ),
    );
  }
}
