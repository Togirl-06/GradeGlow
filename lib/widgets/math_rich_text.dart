import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../theme/study_theme.dart';

/// Normalizes common LaTeX delimiter styles to `$...$` / `$$...$$`.
class MathDelimiter {
  MathDelimiter._();

  static String normalize(String input) {
    var text = input;
    text = text.replaceAllMapped(
      RegExp(r'\\\[(.+?)\\\]', dotAll: true),
      (Match m) => '\$\$${m.group(1)!.trim()}\$\$',
    );
    text = text.replaceAllMapped(
      RegExp(r'\\\((.+?)\\\)', dotAll: true),
      (Match m) => '\$${m.group(1)!.trim()}\$',
    );
    return text;
  }
}

/// Renders text with inline `$...$` and display `$$...$$` LaTeX math.
class MathRichText extends StatelessWidget {
  const MathRichText({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 15,
    this.fontWeight,
    this.height = 1.55,
    this.italic = false,
    this.textAlign,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight? fontWeight;
  final double height;
  final bool italic;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final String normalized = MathDelimiter.normalize(text);

    if (normalized.contains(r'$$')) {
      return _DisplayMixedColumn(
        text: normalized,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        italic: italic,
        textAlign: textAlign,
      );
    }

    if (!_containsMath(normalized) && !normalized.contains('**') && !normalized.contains('`')) {
      return Text(
        normalized,
        textAlign: textAlign,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      );
    }

    return MathMarkdown.inlineWidget(
      normalized,
      color: color,
      brightness: brightness,
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      italic: italic,
      textAlign: textAlign,
    );
  }

  static bool _containsMath(String value) =>
      value.contains(r'$') || value.contains(r'\(') || value.contains(r'\[');
}

/// Inline markdown + LaTeX as a wrapping row (avoids RenderFlex overflow).
class MathMarkdown {
  MathMarkdown._();

  static Widget inlineWidget(
    String value, {
    required Color color,
    required Brightness brightness,
    double fontSize = 15,
    double height = 1.55,
    FontWeight? fontWeight,
    bool italic = false,
    TextAlign? textAlign,
  }) {
    final TextStyle baseStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );

    final RegExp pattern = RegExp(r'\*\*([^*]+)\*\*|`([^`]+)`|\$([^$\n]+)\$');
    final List<Widget> parts = <Widget>[];
    int cursor = 0;

    for (final RegExpMatch match in pattern.allMatches(value)) {
      if (match.start > cursor) {
        parts.add(Text(value.substring(cursor, match.start), style: baseStyle));
      }

      if (match.group(1) != null) {
        parts.add(
          Text(
            match.group(1)!,
            style: baseStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      } else if (match.group(2) != null) {
        parts.add(
          Text(
            match.group(2)!,
            style: TextStyle(
              fontFamily: 'Consolas',
              fontFamilyFallback: const <String>['monospace'],
              fontSize: fontSize - 1,
              color: brightness == Brightness.dark ? const Color(0xFFF0ABFC) : const Color(0xFFBE185D),
              backgroundColor: brightness == Brightness.dark ? const Color(0xFF3A2A3A) : const Color(0xFFFCE7F3),
            ),
          ),
        );
      } else if (match.group(3) != null) {
        parts.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            child: _InlineMathChip(
              latex: match.group(3)!,
              color: color,
              fontSize: fontSize,
            ),
          ),
        );
      }
      cursor = match.end;
    }

    if (cursor < value.length) {
      parts.add(Text(value.substring(cursor), style: baseStyle));
    }

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: textAlign == TextAlign.center ? WrapAlignment.center : WrapAlignment.start,
        runSpacing: 4,
        children: parts,
      ),
    );
  }
}

/// Inline formula that scales down instead of overflowing the row.
class _InlineMathChip extends StatelessWidget {
  const _InlineMathChip({
    required this.latex,
    required this.color,
    required this.fontSize,
  });

  final String latex;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 32;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _MathChip(
              latex: latex,
              color: color,
              fontSize: fontSize,
              display: false,
            ),
          ),
        );
      },
    );
  }
}

class _DisplayMixedColumn extends StatelessWidget {
  const _DisplayMixedColumn({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
    required this.height,
    required this.italic,
    required this.textAlign,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight? fontWeight;
  final double height;
  final bool italic;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final RegExp display = RegExp(r'\$\$([^$]+)\$\$');
    final List<Widget> children = <Widget>[];
    int cursor = 0;

    for (final RegExpMatch match in display.allMatches(text)) {
      if (match.start > cursor) {
        children.add(
          MathRichText(
            text: text.substring(cursor, match.start),
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: height,
            italic: italic,
            textAlign: textAlign,
          ),
        );
      }
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: _MathChip(
                    latex: match.group(1)!.trim(),
                    color: color,
                    fontSize: fontSize + 2,
                    display: true,
                  ),
                ),
              );
            },
          ),
        ),
      );
      cursor = match.end;
    }

    if (cursor < text.length) {
      children.add(
        MathRichText(
          text: text.substring(cursor),
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
          italic: italic,
          textAlign: textAlign,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// Standalone display formula block.
class MathDisplayBlock extends StatelessWidget {
  const MathDisplayBlock({
    super.key,
    required this.latex,
    required this.color,
    this.fontSize = 18,
    this.compact = false,
  });

  final String latex;
  final Color color;
  final double fontSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 2 : 10),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width - 32;

          return SizedBox(
            width: maxWidth,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: _MathChip(latex: latex, color: color, fontSize: fontSize, display: true),
            ),
          );
        },
      ),
    );
  }
}

class _MathChip extends StatelessWidget {
  const _MathChip({
    required this.latex,
    required this.color,
    required this.fontSize,
    required this.display,
  });

  final String latex;
  final Color color;
  final double fontSize;
  final bool display;

  @override
  Widget build(BuildContext context) {
    try {
      return Math.tex(
        MathDelimiter.normalize(latex),
        mathStyle: display ? MathStyle.display : MathStyle.text,
        textStyle: TextStyle(color: color, fontSize: fontSize),
        settings: const TexParserSettings(strict: Strict.ignore),
        onErrorFallback: (FlutterMathException error) {
          return _fallback(context);
        },
      );
    } catch (_) {
      return _fallback(context);
    }
  }

  Widget _fallback(BuildContext context) {
    return Text(
      display ? '\$\$$latex\$\$' : '\$$latex\$',
      style: TextStyle(
        color: StudyColors.textSecondary(Theme.of(context).brightness),
        fontFamily: 'monospace',
        fontSize: fontSize,
      ),
    );
  }
}
