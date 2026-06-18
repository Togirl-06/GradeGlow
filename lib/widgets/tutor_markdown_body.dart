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
  });

  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color bodyColor = textColor ?? StudyColors.textPrimary(brightness);
    final List<MessageSegment> segments = TutorMessageParser.parse(text);

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
  });

  final String text;
  final Color color;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final List<_Block> blocks = _BlockParser.parse(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map(( _Block block) => block.build(color: color, brightness: brightness)).toList(),
    );
  }
}

sealed class _Block {
  Widget build({required Color color, required Brightness brightness});
}

class _HeadingBlock extends _Block {
  _HeadingBlock(this.text, {required this.level});

  final String text;
  final int level;

  @override
  Widget build({required Color color, required Brightness brightness}) {
    final double size = level == 2 ? 17 : 15;
    return Padding(
      padding: EdgeInsets.only(top: level == 2 ? 14 : 10, bottom: 6),
      child: MathRichText(
        text: text,
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1.35,
      ),
    );
  }
}

class _ParagraphBlock extends _Block {
  _ParagraphBlock(this.text);

  final String text;

  @override
  Widget build({required Color color, required Brightness brightness}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MathRichText(text: text, color: color, fontSize: 15, height: 1.55),
    );
  }
}

class _BulletBlock extends _Block {
  _BulletBlock(this.text);

  final String text;

  @override
  Widget build({required Color color, required Brightness brightness}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: StudyColors.textSecondary(brightness),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: MathRichText(text: text, color: color, fontSize: 15, height: 1.5),
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
  Widget build({required Color color, required Brightness brightness}) {
    final Color fill = brightness == Brightness.dark
        ? const Color(0xFF1A2332)
        : const Color(0xFFF8FAFC);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10, top: 2),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
              fontSize: 14.5,
              height: 1.5,
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
  Widget build({required Color color, required Brightness brightness}) {
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

      final StringBuffer paragraph = StringBuffer(trimmed);
      i++;
      while (i < lines.length) {
        final String next = lines[i].trim();
        if (next.isEmpty ||
            next.startsWith('## ') ||
            next.startsWith('### ') ||
            next.startsWith('> ') ||
            next.startsWith('- ') ||
            next.startsWith('* ')) {
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
