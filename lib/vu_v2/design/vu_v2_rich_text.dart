import 'package:flutter/material.dart';

import 'vu_v2_theme.dart';

/// Renders textbook/notes body with **bold** and ```fenced``` blocks.
class VuV2RichTeachBody extends StatelessWidget {
  const VuV2RichTeachBody({
    super.key,
    required this.text,
    required this.accent,
    this.fontSize = 15,
    this.height = 1.5,
  });

  final String text;
  final Color accent;
  final double fontSize;
  final double height;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    final List<String> parts = text.split('```');
    for (int i = 0; i < parts.length; i++) {
      final String chunk = parts[i];
      if (chunk.isEmpty) continue;
      if (i.isOdd) {
        children.add(_CodeFence(code: chunk, accent: accent));
      } else {
        children.addAll(_paragraphs(chunk.trim()));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<Widget> _paragraphs(String chunk) {
    if (chunk.isEmpty) return const <Widget>[];
    final List<String> paras = chunk
        .split(RegExp(r'\n\s*\n'))
        .map((String p) => p.trim())
        .where((String p) => p.isNotEmpty)
        .toList();
    return <Widget>[
      for (int i = 0; i < paras.length; i++)
        Padding(
          padding: EdgeInsets.only(bottom: i == paras.length - 1 ? 0 : 12),
          child: Text.rich(
            TextSpan(children: boldSpans(paras[i])),
            style: TextStyle(
              color: VuV2Colors.ink,
              height: height,
              fontSize: fontSize,
            ),
          ),
        ),
    ];
  }

  static List<InlineSpan> boldSpans(String raw) {
    final List<InlineSpan> spans = <InlineSpan>[];
    final RegExp re = RegExp(r'\*\*(.+?)\*\*');
    int start = 0;
    for (final RegExpMatch m in re.allMatches(raw)) {
      if (m.start > start) {
        spans.add(TextSpan(text: raw.substring(start, m.start)));
      }
      spans.add(
        TextSpan(
          text: m.group(1),
          style: TextStyle(
            color: Color(0xFF86EFAC),
            fontWeight: FontWeight.w800,
          ),
        ),
      );
      start = m.end;
    }
    if (start < raw.length) {
      spans.add(TextSpan(text: raw.substring(start)));
    }
    return spans;
  }
}

class _CodeFence extends StatelessWidget {
  const _CodeFence({required this.code, required this.accent});

  final String code;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    String body = code;
    final int nl = body.indexOf('\n');
    if (nl > 0 && !body.substring(0, nl).contains(' ')) {
      body = body.substring(nl + 1);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(VuV2Radii.md),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _Dot(const Color(0xFFF87171)),
                const SizedBox(width: 5),
                _Dot(const Color(0xFFFBBF24)),
                const SizedBox(width: 5),
                _Dot(const Color(0xFF4ADE80)),
                const Spacer(),
                Text(
                  'FIGURE / WORKED BOX',
                  style: TextStyle(
                    color: accent.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              body.trimRight(),
              style: TextStyle(
                color: Color(0xFF86EFAC),
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
