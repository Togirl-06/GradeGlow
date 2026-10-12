import 'dart:io';

void main() {
  final Directory root = Directory('lib/vu_v2');
  int files = 0;
  final RegExp start = RegExp(r'\bconst\s+([A-Z][A-Za-z0-9_\.]*)\s*\(');
  for (final FileSystemEntity e in root.listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.dart')) continue;
    String t = e.readAsStringSync();
    if (!t.contains('VuV2Colors') && !t.contains('RegistrarColors')) continue;
    final StringBuffer out = StringBuffer();
    int i = 0;
    bool changed = false;
    while (i < t.length) {
      final Match? m = start.matchAsPrefix(t, i);
      if (m == null) {
        out.write(t[i]);
        i++;
        continue;
      }
      final int open = m.end - 1;
      final int close = _matchingParen(t, open);
      if (close < 0) {
        out.write(t[i]);
        i++;
        continue;
      }
      final String body = t.substring(m.start, close + 1);
      if (body.contains('VuV2Colors') || body.contains('RegistrarColors')) {
        out.write(t.substring(m.start + 'const '.length, close + 1));
        changed = true;
      } else {
        out.write(body);
      }
      i = close + 1;
    }
    if (changed) {
      e.writeAsStringSync(out.toString());
      files++;
    }
  }
  stdout.writeln('Unconsted theme tokens in $files files');
}

int _matchingParen(String t, int open) {
  int depth = 0;
  for (int i = open; i < t.length; i++) {
    final String c = t[i];
    if (c == '(') depth++;
    if (c == ')') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}
