import 'dart:io';

void main() {
  final Directory root = Directory('lib/vu_v2');
  int files = 0;
  for (final FileSystemEntity e in root.listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.dart')) continue;
    String t = e.readAsStringSync();
    if (!t.contains('VuV2Colors')) continue;
    final String orig = t;
    t = t.replaceAll('const TextStyle(', 'TextStyle(');
    t = t.replaceAll('const BorderSide(', 'BorderSide(');
    t = t.replaceAll('const Divider(', 'Divider(');
    t = t.replaceAll('const BoxDecoration(', 'BoxDecoration(');
    t = t.replaceAll('const ColoredBox(', 'ColoredBox(');
    t = t.replaceAll('const Border(', 'Border(');
    t = t.replaceAll('color: VuV2Colors.', 'color: VuV2Colors.');
    // Drop const on Icon(...) when color is a campus token (single-line).
    t = t.replaceAllMapped(
      RegExp(r'const Icon\(([^)]*VuV2Colors[^)]*)\)'),
      (Match m) => 'Icon(${m[1]})',
    );
    if (t != orig) {
      e.writeAsStringSync(t);
      files++;
    }
  }
  stdout.writeln('Updated $files campus files for theme-aware colors');
}
