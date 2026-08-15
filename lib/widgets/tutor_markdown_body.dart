import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import '../utils/tutor_message_parser.dart';
import 'math_rich_text.dart';
import 'tutor_code_block.dart';

/// Renders tutor replies with structured headings, lists, quotes, and code.
class TutorMarkdownBody extends StatelessWidget {
  const TutorMarkdownBody({
    super.key,
    required this.text,
    this.textColor,
    this.readerMode = false,
  });

  final String text;
  final Color? textColor;
  final bool readerMode;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color bodyColor = textColor ?? StudyColors.textPrimary(brightness);
    final String normalized = MathDelimiter.normalize(text);
    final List<MessageSegment> segments = TutorMessageParser.parse(normalized);

    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((MessageSegment segment) {
        return switch (segment) {
          TextSegment(:final String text) => _StructuredText(
              text: text,
              color: bodyColor,
              brightness: brightness,
              readerMode: readerMode,
            ),
          CodeBlockSegment(:final String language, :final String code) =>
            TutorCodeBlock(code: code, language: language),
        };
      }).toList(),
    );
  }
}

class _StructuredText extends StatelessWidget {
  const _StructuredText({
    required this.text,
    required this.color,
    required this.brightness,
    required this.readerMode,
  });

  final String text;
  final Color color;
  final Brightness brightness;
  final bool readerMode;

  @override
  Widget build(BuildContext context) {
    final List<_Block> blocks = _BlockParser.parse(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks
          .map(
            (_Block block) => block.build(
              color: color,
              brightness: brightness,
              readerMode: readerMode,
            ),
          )
          .toList(),
    );
  }
}

sealed class _Block {
  Widget build({
    required Color color,
    required Brightness brightness,
    required bool readerMode,
  });
}

class _HeadingBlock extends _Block {
  _HeadingBlock(this.text, {required this.level});

  final String text;
  final int level;

  @override
  Widget build({
    required Color color,
    required Brightness brightness,
    required bool readerMode,
  }) {
    final double size = readerMode ? (level == 2 ? 20 : 17) : (level == 2 ? 17 : 15);
    final Color accent = StudyColors.primary;
    return Padding(
      padding: EdgeInsets.only(top: readerMode ? 18 : 14, bottom: readerMode ? 8 : 6),
      child: Container(
        width: double.infinity,
        padding: readerMode ? const EdgeInsets.fromLTRB(10, 8, 10, 8) : EdgeInsets.zero,
        decoration: readerMode
            ? BoxDecoration(
                color: accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(color: accent.withValues(alpha: 0.65), width: 4)),
              )
            : null,
        child: MathRichText(
          text: text,
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w900,
          height: 1.35,
        ),
      ),
    );
  }
}

class _ParagraphBlock extends _Block {
  _ParagraphBlock(this.text);

  final String text;

  @override
  Widget build({
    required Color color,
    required Brightness brightness,
    required bool readerMode,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: readerMode ? 12 : 8),
      child: MathRichText(
        text: text,
        color: color,
        fontSize: readerMode ? 16 : 15,
        height: readerMode ? 1.72 : 1.55,
      ),
    );
  }
}

class _BulletBlock extends _Block {
  _BulletBlock(this.text, {this.number});

  final String text;
  final String? number;

  @override
  Widget build({
    required Color color,
    required Brightness brightness,
    required bool readerMode,
  }) {
    final Color markerColor = StudyColors.textSecondary(brightness);
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: readerMode ? 8 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: readerMode ? 4 : 7, right: 9),
            child: number == null
                ? Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                    ),
                  )
                : Text(
                    '$number.',
                    style: TextStyle(
                      color: markerColor,
                      fontSize: readerMode ? 15 : 14,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
          ),
          Expanded(
            child: MathRichText(
              text: text,
              color: color,
              fontSize: readerMode ? 16 : 15,
              height: readerMode ? 1.62 : 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteBlock extends _Block {
  _QuoteBlock(this.lines);

  final List<String> lines;

  @override
  Widget build({
    required Color color,
    required Brightness brightness,
    required bool readerMode,
  }) {
    final Color fill = brightness == Brightness.dark
        ? const Color(0xFF1A2332)
        : const Color(0xFFF8FAFC);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: readerMode ? 14 : 10, top: 2),
      padding: EdgeInsets.fromLTRB(12, readerMode ? 12 : 10, 12, readerMode ? 12 : 10),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: StudyColors.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((String line) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: MathRichText(
              text: line,
              color: StudyColors.textSecondary(brightness),
              fontSize: readerMode ? 15.5 : 14.5,
              height: readerMode ? 1.62 : 1.5,
              italic: true,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DisplayMathBlock extends _Block {
  _DisplayMathBlock(this.latex);

  final String latex;

  @override
  Widget build({
    required Color color,
    required Brightness brightness,
    required bool readerMode,
  }) {
    return MathDisplayBlock(latex: latex, color: color);
  }
}

class _BlockParser {
  static List<_Block> parse(String input) {
    final List<_Block> blocks = <_Block>[];
    final List<String> lines = input.split('\n');
    int i = 0;

    while (i < lines.length) {
      final String line = lines[i];
      final String trimmed = line.trim();

      if (trimmed.isEmpty) {
        i++;
        continue;
      }

      if (trimmed.startsWith(r'$$') && trimmed.endsWith(r'$$') && trimmed.length > 4) {
        blocks.add(_DisplayMathBlock(trimmed.substring(2, trimmed.length - 2).trim()));
        i++;
        continue;
      }

      if (trimmed == r'$$') {
        i++;
        final StringBuffer math = StringBuffer();
        while (i < lines.length) {
          final String mathLine = lines[i];
          final String mathTrimmed = mathLine.trim();
          if (mathTrimmed.endsWith(r'$$')) {
            if (mathTrimmed != r'$$') {
              math.writeln(mathTrimmed.substring(0, mathTrimmed.length - 2).trimRight());
            }
            i++;
            break;
          }
          math.writeln(mathLine);
          i++;
        }
        blocks.add(_DisplayMathBlock(math.toString().trim()));
        continue;
      }

      if (trimmed.startsWith('## ')) {
        blocks.add(_HeadingBlock(trimmed.substring(3).trim(), level: 2));
        i++;
        continue;
      }

      if (trimmed.startsWith('### ')) {
        blocks.add(_HeadingBlock(trimmed.substring(4).trim(), level: 3));
        i++;
        continue;
      }

      if (trimmed.startsWith('> ')) {
        final List<String> quoteLines = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('> ')) {
          quoteLines.add(lines[i].trim().substring(2).trim());
          i++;
        }
        blocks.add(_QuoteBlock(quoteLines));
        continue;
      }

      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        blocks.add(_BulletBlock(trimmed.substring(2).trim()));
        i++;
        continue;
      }

      final RegExpMatch? numbered = RegExp(r'^(\d+)[\.)]\s+(.+)$').firstMatch(trimmed);
      if (numbered != null) {
        blocks.add(_BulletBlock(numbered.group(2)!.trim(), number: numbered.group(1)));
        i++;
        continue;
      }

      final StringBuffer paragraph = StringBuffer(trimmed);
      i++;
      while (i < lines.length) {
        final String next = lines[i].trim();
        if (next.isEmpty ||
            next.startsWith('## ') ||
            next.startsWith('### ') ||
            next.startsWith('> ') ||
            next.startsWith('- ') ||
            next.startsWith('* ') ||
            RegExp(r'^(\d+)[\.)]\s+').hasMatch(next)) {
          break;
        }
        paragraph.write(' $next');
        i++;
      }
      blocks.add(_ParagraphBlock(paragraph.toString()));
    }

    return blocks;
  }
}
