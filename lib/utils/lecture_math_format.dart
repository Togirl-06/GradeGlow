/// Converts plain-text lecture equations to LaTeX for clear math rendering.
abstract final class LectureMathFormat {
  static String toLatex(String input) {
    String s = input.trim();
    if (s.isEmpty) return s;

    if (s.startsWith(r'$$') && s.endsWith(r'$$') && s.length > 4) {
      s = s.substring(2, s.length - 2).trim();
    } else if (s.startsWith(r'$') && s.endsWith(r'$') && s.length > 2) {
      s = s.substring(1, s.length - 1).trim();
    }

    if (_looksLikeLatex(s)) return s;

    s = _convertLimits(s);
    s = _replaceUnicode(s);
    s = _convertSuperscripts(s);
    s = _convertDerivatives(s);
    s = _convertFractions(s);
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool containsMath(String text) {
    final String t = text.trim();
    if (t.isEmpty) return false;
    return t.contains(r'$') ||
        t.contains(r'\') ||
        RegExp(r'[²³⁴⁺⁻⁼⁽⁾×÷→∞≤≥≠⇔′]').hasMatch(t) ||
        RegExp(r'\blim\b', caseSensitive: false).hasMatch(t) ||
        RegExp(r"f\s*[(']|d/dx|[=+\-*/^]").hasMatch(t);
  }

  static String graphLabel(String graphFunction) {
    return switch (graphFunction) {
      'linear' => r'y = x',
      'reciprocal' => r'y = \frac{1}{x}',
      'sine' => r'y = \sin x',
      _ => r'y = x^2',
    };
  }

  static String withHighlight(String latex, String? highlight) {
    if (highlight == null || highlight.isEmpty) return latex;
    final String hl = toLatex(highlight);
    final String body = toLatex(latex);
    if (hl.isEmpty || !body.contains(hl)) return body;
    return body.replaceFirst(hl, r'\boxed{' + hl + r'}');
  }

  static bool _looksLikeLatex(String s) =>
      RegExp(r'\\(lim|frac|sin|cos|tan|sqrt|int|sum|boxed|to|infty|le|ge|ne|pm|cdot|times|div)').hasMatch(s);

  static String _replaceUnicode(String s) {
    return s
        .replaceAll('∞', r'\infty')
        .replaceAll('→', r' \to ')
        .replaceAll('⇔', r' \Leftrightarrow ')
        .replaceAll('−', '-')
        .replaceAll('–', '-')
        .replaceAll('×', r' \times ')
        .replaceAll('·', r' \cdot ')
        .replaceAll('÷', r' \div ')
        .replaceAll('±', r' \pm ')
        .replaceAll('≤', r' \le ')
        .replaceAll('≥', r' \ge ')
        .replaceAll('≠', r' \ne ')
        .replaceAll('√', r'\sqrt')
        .replaceAll('π', r'\pi ')
        .replaceAll('θ', r'\theta ')
        .replaceAll('Δ', r'\Delta ')
        .replaceAll('⁺', '^+')
        .replaceAll('⁻', '^-')
        .replaceAll('′', "'")
        .replaceAll('✓', r'\checkmark');
  }

  static String _convertSuperscripts(String s) {
    return s
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('⁴', '^4')
        .replaceAllMapped(RegExp(r'(\w)\^(\d+)'), (Match m) => '${m.group(1)}^{${m.group(2)}}');
  }

  static String _convertLimits(String s) {
    return s.replaceAllMapped(
      RegExp(r'lim\s*\(\s*([^)]+→[^)]+)\s*\)', caseSensitive: false),
      (Match m) {
        final String inner = m.group(1)!
            .replaceAll('→', r' \to ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        return r'\lim_{' + inner + r'}';
      },
    );
  }

  static String _convertDerivatives(String s) {
    return s
        .replaceAllMapped(RegExp(r"d/dx\s*\[([^\]]+)\]"), (Match m) => r"\frac{d}{dx}\left(" + m.group(1)! + r"\right)")
        .replaceAllMapped(RegExp(r"f\s*\^\{\s*\\prime\s*\}|f'"), (_) => r"f'")
        .replaceAll('f′', r"f'");
  }

  static String _convertFractions(String s) {
    return s.replaceAllMapped(
      RegExp(r'\(\s*([^()]+?)\s*\)\s*/\s*\(\s*([^()]+?)\s*\)'),
      (Match m) => r'\frac{' + _strip(m.group(1)!) + r'}{' + _strip(m.group(2)!) + r'}',
    );
  }

  static String _strip(String s) => s.trim();
}
