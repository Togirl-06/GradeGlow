import 'package:flutter/material.dart';

/// Lightweight ChatGPT-style syntax colors (no extra packages).
class TutorSyntaxHighlighter {
  TutorSyntaxHighlighter._();

  static TextSpan highlight(String code, {String language = ''}) {
    final String lang = language.toLowerCase();
    final List<TextSpan> lines = <TextSpan>[];
    final List<String> split = code.split('\n');

    for (int i = 0; i < split.length; i++) {
      if (i > 0) lines.add(const TextSpan(text: '\n'));
      lines.addAll(_highlightLine(split[i], lang));
    }

    return TextSpan(children: lines);
  }

  static List<TextSpan> _highlightLine(String line, String lang) {
    if (line.trimLeft().startsWith('#')) {
      return <TextSpan>[
        TextSpan(text: line, style: const TextStyle(color: _Colors.comment)),
      ];
    }
    if (line.trimLeft().startsWith('//')) {
      return <TextSpan>[
        TextSpan(text: line, style: const TextStyle(color: _Colors.comment)),
      ];
    }

    final List<_Token> tokens = _tokenize(line, lang);
    return tokens
        .map(
          (_Token t) => TextSpan(
            text: t.text,
            style: TextStyle(color: t.color ?? _Colors.text),
          ),
        )
        .toList();
  }

  static List<_Token> _tokenize(String line, String lang) {
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
        out.add(_Token(value, _Colors.string));
      } else if (RegExp(r'^\d').hasMatch(value)) {
        out.add(_Token(value, _Colors.number));
      } else if (keywords.contains(value)) {
        out.add(_Token(value, _Colors.keyword));
      } else {
        out.add(_Token(value, _Colors.text));
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

class _Colors {
  static const Color text = Color(0xFFD4D4D4);
  static const Color keyword = Color(0xFFC586C0);
  static const Color string = Color(0xFF6A9955);
  static const Color number = Color(0xFF4FC1FF);
  static const Color comment = Color(0xFF808080);
}

class _Token {
  const _Token(this.text, this.color);

  final String text;
  final Color? color;
}
