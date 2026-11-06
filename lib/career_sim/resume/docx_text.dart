/// Text extraction for Word .docx resumes: unzips the file and reads the body
/// paragraphs (including tables, text boxes, headers and footers) in order.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

String _xmlUnescape(String s) => s
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (Match m) => String.fromCharCode(int.parse(m[1]!, radix: 16)))
    .replaceAllMapped(RegExp(r'&#(\d+);'), (Match m) => String.fromCharCode(int.parse(m[1]!)))
    .replaceAll('&amp;', '&');

/// Paragraph texts of one WordprocessingML part.
List<String> docxParagraphs(String xml) {
  final List<String> out = <String>[];
  for (final RegExpMatch p in RegExp(r'<w:p[ >].*?</w:p>|<w:p/>', dotAll: true).allMatches(xml)) {
    final StringBuffer b = StringBuffer();
    for (final RegExpMatch t in RegExp(r'<w:t(?:\s[^>]*)?>(.*?)</w:t>|<w:tab/>|<w:br/>|<w:cr/>', dotAll: true).allMatches(p[0]!)) {
      final String tag = t[0]!;
      if (tag == '<w:tab/>') {
        b.write('\t');
      } else if (tag == '<w:br/>' || tag == '<w:cr/>') {
        b.write('\n');
      } else {
        b.write(_xmlUnescape(t[1] ?? ''));
      }
    }
    out.add(b.toString());
  }
  return out;
}

/// Extracts the text of a .docx file. Throws [FormatException] if it is not one.
String extractDocxText(Uint8List bytes) {
  final Archive a;
  try {
    a = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    throw const FormatException('This file is not a Word .docx document.');
  }
  ArchiveFile? part(String name) {
    for (final ArchiveFile f in a.files) {
      if (f.isFile && f.name == name) return f;
    }
    return null;
  }

  final ArchiveFile? doc = part('word/document.xml');
  if (doc == null) throw const FormatException('This file is not a Word .docx document (no document body).');
  String read(ArchiveFile f) => utf8.decode(f.content, allowMalformed: true);
  final List<String> lines = <String>[];
  for (final ArchiveFile f in a.files) {
    if (f.isFile && RegExp(r'^word/header\d*\.xml$').hasMatch(f.name)) lines.addAll(docxParagraphs(read(f)));
  }
  lines.addAll(docxParagraphs(read(doc)));
  return lines.map((String l) => l.trimRight()).join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}
