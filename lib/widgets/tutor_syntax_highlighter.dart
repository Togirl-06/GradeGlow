import 'package:flutter/material.dart';

/// Lightweight syntax colors for tutor/lecture code blocks (light + dark).
class TutorSyntaxHighlighter {
  TutorSyntaxHighlighter._();

  static TextSpan highlight(
    String code, {
    String language = '',
    Brightness brightness = Brightness.light,
  }) {
    final _Palette palette = brightness == Brightness.dark ? _Palette.dark : _Palette.light;
    final String lang = language.toLowerCase();
    final List<TextSpan> lines = <TextSpan>[];
    final List<String> split = code.split('\n');

    for (int i = 0; i < split.length; i++) {
      if (i > 0) lines.add(const TextSpan(text: '\n'));
      lines.addAll(_highlightLine(split[i], lang, palette));
    }

    return TextSpan(children: lines);
  }

  static List<TextSpan> _highlightLine(String line, String lang, _Palette palette) {
    if (line.trimLeft().startsWith('#')) {
      return <TextSpan>[
        TextSpan(text: line, style: TextStyle(color: palette.comment)),
      ];
    }
    if (line.trimLeft().startsWith('//')) {
      return <TextSpan>[
        TextSpan(text: line, style: TextStyle(color: palette.comment)),
      ];
    }

    final List<_Token> tokens = _tokenize(line, lang, palette);
    return tokens
        .map(
          (_Token t) => TextSpan(
            text: t.text,
            style: TextStyle(color: t.color ?? palette.text),
          ),
        )
        .toList();
  }

  static List<_Token> _tokenize(String line, String lang, _Palette palette) {
    final Set<String> keywords = _keywordsFor(lang);
    final RegExp pattern = RegExp(
      r'("(?:\\.|[^"\\])*")'
      r"|('(?:\\.|[^'\\])*')"
      r'|(`(?:\\.|[^`\\])*`)'
      r'|\b\d+(?:\.\d+)?\b'
      r'|\b[A-Za-z_]\w*\b'
      r'|[^\s\w]',
    );

    final List<_Token> out = <_Token>[];
    for (final RegExpMatch m in pattern.allMatches(line)) {
      final String value = m.group(0)!;
      if (value.startsWith('"') || value.startsWith("'") || value.startsWith('`')) {
        out.add(_Token(value, palette.string));
      } else if (RegExp(r'^\d').hasMatch(value)) {
        out.add(_Token(value, palette.number));
      } else if (keywords.contains(value)) {
        out.add(_Token(value, palette.keyword));
      } else if (value.startsWith('<') || value.startsWith('>') || value.contains('/')) {
        out.add(_Token(value, palette.tag));
      } else {
        out.add(_Token(value, palette.text));
      }
    }
    return out;
  }

  static Set<String> _keywordsFor(String lang) {
    const Set<String> shared = <String>{
      'if',
      'else',
      'elif',
      'for',
      'while',
      'return',
      'import',
      'from',
      'class',
      'def',
      'print',
      'in',
      'and',
      'or',
      'not',
      'true',
      'false',
      'null',
      'none',
      'True',
      'False',
      'None',
    };

    if (lang.contains('html')) {
      return <String>{
        'html',
        'head',
        'body',
        'div',
        'span',
        'p',
        'a',
        'img',
        'ul',
        'ol',
        'li',
        'table',
        'form',
        'input',
        'button',
        'h1',
        'h2',
        'h3',
        'h4',
        'h5',
        'h6',
      };
    }

    if (lang.contains('dart') || lang.contains('flutter')) {
      return <String>{
        ...shared,
        'void',
        'int',
        'double',
        'String',
        'bool',
        'final',
        'const',
        'var',
        'async',
        'await',
        'extends',
        'implements',
        'new',
        'this',
        'super',
        'static',
      };
    }

    if (lang.contains('js') || lang.contains('javascript') || lang.contains('typescript') || lang.contains('ts')) {
      return <String>{
        ...shared,
        'function',
        'const',
        'let',
        'var',
        'async',
        'await',
        'export',
        'default',
        'new',
        'typeof',
        'instanceof',
      };
    }

    if (lang.contains('py') || lang.contains('python') || lang.isEmpty) {
      return shared;
    }

    return shared;
  }
}

class _Palette {
  const _Palette({
    required this.text,
    required this.keyword,
    required this.string,
    required this.number,
    required this.comment,
    required this.tag,
  });

  final Color text;
  final Color keyword;
  final Color string;
  final Color number;
  final Color comment;
  final Color tag;

  static const _Palette dark = _Palette(
    text: Color(0xFFD4D4D4),
    keyword: Color(0xFFC586C0),
    string: Color(0xFFCE9178),
    number: Color(0xFF4FC1FF),
    comment: Color(0xFF808080),
    tag: Color(0xFF569CD6),
  );

  static const _Palette light = _Palette(
    text: Color(0xFF1F2937),
    keyword: Color(0xFF7C3AED),
    string: Color(0xFF047857),
    number: Color(0xFF1D4ED8),
    comment: Color(0xFF6B7280),
    tag: Color(0xFF2563EB),
  );
}

class _Token {
  const _Token(this.text, this.color);

  final String text;
  final Color? color;
}
