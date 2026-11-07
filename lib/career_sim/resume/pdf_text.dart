/// Pure-Dart PDF text extraction for resumes, so uploads work the same on
/// web, Android, iOS and desktop.
///
/// It reads the objects (including compressed object streams), follows the
/// page tree, decodes Flate/ASCII85 content streams and maps glyph codes to
/// Unicode through each font's ToUnicode CMap (falling back to WinAnsi for
/// simple fonts). Scanned PDFs have no text layer and come back empty.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:image/image.dart' as img;

class PdfName {
  const PdfName(this.name);
  final String name;
  @override
  bool operator ==(Object other) => other is PdfName && other.name == name;
  @override
  int get hashCode => name.hashCode;
  @override
  String toString() => '/$name';
}

class PdfRef {
  const PdfRef(this.num);
  final int num;
}

class _Op {
  const _Op(this.op);
  final String op;
}

class _Tok {
  const _Tok(this.kind, [this.value]);

  /// 'num', 'name', 'str', 'op', '[', ']', '<<', '>>', '{', '}'.
  final String kind;
  final Object? value;
}

bool _ws(int c) => c == 32 || c == 9 || c == 13 || c == 10 || c == 12 || c == 0;
bool _delim(int c) => c == 0x28 || c == 0x29 || c == 0x3c || c == 0x3e || c == 0x5b || c == 0x5d || c == 0x7b || c == 0x7d || c == 0x2f || c == 0x25;
bool _hex(int c) => (c >= 48 && c <= 57) || (c >= 65 && c <= 70) || (c >= 97 && c <= 102);

class _Lexer {
  _Lexer(this.b, [this.i = 0]);
  final Uint8List b;
  int i;

  void skip() {
    while (i < b.length) {
      final int c = b[i];
      if (_ws(c)) {
        i++;
      } else if (c == 0x25) {
        while (i < b.length && b[i] != 10 && b[i] != 13) {
          i++;
        }
      } else {
        break;
      }
    }
  }

  _Tok? next() {
    skip();
    if (i >= b.length) return null;
    final int c = b[i];
    if (c == 0x2f) {
      int j = i + 1;
      while (j < b.length && !_ws(b[j]) && !_delim(b[j])) {
        j++;
      }
      String n = latin1.decode(b.sublist(i + 1, j));
      i = j;
      if (n.contains('#')) {
        n = n.replaceAllMapped(RegExp('#([0-9a-fA-F]{2})'), (Match m) => String.fromCharCode(int.parse(m[1]!, radix: 16)));
      }
      return _Tok('name', n);
    }
    if (c == 0x28) return _Tok('str', _literal());
    if (c == 0x3c) {
      if (i + 1 < b.length && b[i + 1] == 0x3c) {
        i += 2;
        return const _Tok('<<');
      }
      final List<int> h = <int>[];
      i++;
      while (i < b.length && b[i] != 0x3e) {
        if (_hex(b[i])) h.add(b[i]);
        i++;
      }
      i++;
      if (h.length.isOdd) h.add(48);
      final Uint8List out = Uint8List(h.length ~/ 2);
      for (int k = 0; k < out.length; k++) {
        out[k] = int.parse(String.fromCharCodes(h.sublist(2 * k, 2 * k + 2)), radix: 16);
      }
      return _Tok('str', out);
    }
    if (c == 0x3e) {
      if (i + 1 < b.length && b[i + 1] == 0x3e) {
        i += 2;
        return const _Tok('>>');
      }
      i++;
      return const _Tok('op', '>');
    }
    if (c == 0x5b || c == 0x5d || c == 0x7b || c == 0x7d) {
      i++;
      return _Tok(String.fromCharCode(c));
    }
    int j = i;
    while (j < b.length && !_ws(b[j]) && !_delim(b[j])) {
      j++;
    }
    if (j == i) j++;
    final String t = latin1.decode(b.sublist(i, j));
    i = j;
    final double? v = double.tryParse(t);
    if (v != null) return _Tok('num', v);
    return _Tok('op', t);
  }

  Uint8List _literal() {
    i++;
    int depth = 1;
    final BytesBuilder out = BytesBuilder(copy: false);
    while (i < b.length) {
      final int c = b[i++];
      if (c == 0x5c) {
        if (i >= b.length) break;
        final int e = b[i++];
        switch (e) {
          case 0x6e:
            out.addByte(10);
          case 0x72:
            out.addByte(13);
          case 0x74:
            out.addByte(9);
          case 0x62:
            out.addByte(8);
          case 0x66:
            out.addByte(12);
          case 13:
            if (i < b.length && b[i] == 10) i++;
          case 10:
            break;
          default:
            if (e >= 0x30 && e <= 0x37) {
              int v = e - 0x30;
              for (int k = 0; k < 2 && i < b.length && b[i] >= 0x30 && b[i] <= 0x37; k++) {
                v = v * 8 + b[i++] - 0x30;
              }
              out.addByte(v & 255);
            } else {
              out.addByte(e);
            }
        }
      } else if (c == 0x28) {
        depth++;
        out.addByte(c);
      } else if (c == 0x29) {
        depth--;
        if (depth == 0) break;
        out.addByte(c);
      } else {
        out.addByte(c);
      }
    }
    return out.takeBytes();
  }

  Object? value() => valueFrom(next());

  Object? valueFrom(_Tok? t) {
    if (t == null) return null;
    switch (t.kind) {
      case '<<':
        final Map<String, Object?> d = <String, Object?>{};
        while (true) {
          final _Tok? k = next();
          if (k == null || k.kind == '>>') return d;
          if (k.kind == 'name') d[k.value! as String] = value();
        }
      case '[':
        final List<Object?> a = <Object?>[];
        while (true) {
          final _Tok? k = next();
          if (k == null || k.kind == ']') return a;
          a.add(valueFrom(k));
        }
      case 'num':
        final int save = i;
        final _Tok? g = next();
        if (g != null && g.kind == 'num') {
          final _Tok? r = next();
          if (r != null && r.kind == 'op' && r.value == 'R') return PdfRef((t.value! as double).toInt());
        }
        i = save;
        return t.value;
      case 'name':
        return PdfName(t.value! as String);
      case 'str':
        return t.value;
      case 'op':
        final String op = t.value! as String;
        if (op == 'true') return true;
        if (op == 'false') return false;
        if (op == 'null') return null;
        return _Op(op);
      default:
        return null;
    }
  }
}

class _Obj {
  _Obj(this.value, this.stream);
  final Object? value;
  final Uint8List? stream;
}

class _Pdf {
  _Pdf(this.b) {
    final RegExp header = RegExp(r'(?<![0-9])(\d+)\s+(\d+)\s+obj\b');
    final String text = latin1.decode(b);
    for (final RegExpMatch m in header.allMatches(text)) {
      final int num = int.parse(m[1]!);
      final _Lexer lx = _Lexer(b, m.end);
      final Object? v = lx.value();
      Uint8List? stream;
      lx.skip();
      if (v is Map<String, Object?> && _startsWith(lx.i, 'stream')) {
        int st = lx.i + 6;
        if (st + 1 < b.length && b[st] == 13 && b[st + 1] == 10) {
          st += 2;
        } else if (st < b.length && (b[st] == 10 || b[st] == 13)) {
          st += 1;
        }
        final Object? len = v['Length'];
        int end = -1;
        if (len is double) {
          final int e = st + len.toInt();
          if (e <= b.length && _endstreamNear(e)) end = e;
        }
        if (end < 0) {
          end = text.indexOf('endstream', st);
          if (end < 0) end = b.length;
          while (end > st && (b[end - 1] == 10 || b[end - 1] == 13)) {
            end--;
          }
        }
        stream = Uint8List.sublistView(b, st, end);
      }
      objs[num] = _Obj(v, stream);
    }
    // Compressed object streams (PDF 1.5+, e.g. Word and qpdf output).
    for (final _Obj o in objs.values.toList()) {
      final Object? v = o.value;
      if (v is Map<String, Object?> && get(v['Type']) == const PdfName('ObjStm') && o.stream != null) {
        final Uint8List data = decode(v, o.stream!);
        final int n = (get(v['N']) as double? ?? 0).toInt();
        final int first = (get(v['First']) as double? ?? 0).toInt();
        final _Lexer lx = _Lexer(data);
        final List<(int, int)> pairs = <(int, int)>[];
        for (int k = 0; k < n; k++) {
          final _Tok? a = lx.next();
          final _Tok? off = lx.next();
          if (a?.value is! double || off?.value is! double) break;
          pairs.add(((a!.value! as double).toInt(), (off!.value! as double).toInt()));
        }
        for (final (int on, int off) in pairs) {
          if (!objs.containsKey(on) && first + off < data.length) objs[on] = _Obj(_Lexer(data, first + off).value(), null);
        }
      }
    }
  }

  final Uint8List b;
  final Map<int, _Obj> objs = <int, _Obj>{};

  bool _startsWith(int i, String s) {
    if (i + s.length > b.length) return false;
    for (int k = 0; k < s.length; k++) {
      if (b[i + k] != s.codeUnitAt(k)) return false;
    }
    return true;
  }

  bool _endstreamNear(int e) {
    int i = e;
    while (i < b.length && _ws(b[i])) {
      i++;
    }
    return _startsWith(i, 'endstream');
  }

  Object? get(Object? v) {
    int guard = 0;
    while (v is PdfRef && guard++ < 32) {
      v = objs[v.num]?.value;
    }
    return v;
  }

  Map<String, Object?> dict(Object? v) {
    final Object? d = get(v);
    return d is Map<String, Object?> ? d : const <String, Object?>{};
  }

  Uint8List stream(Object? ref) {
    if (ref is! PdfRef) return Uint8List(0);
    final _Obj? o = objs[ref.num];
    if (o == null || o.stream == null || o.value is! Map<String, Object?>) return Uint8List(0);
    return decode(o.value! as Map<String, Object?>, o.stream!);
  }

  Uint8List decode(Map<String, Object?> d, Uint8List data) {
    final Object? f = get(d['Filter']);
    final List<Object?> filters = f is PdfName ? <Object?>[f] : (f is List<Object?> ? f : const <Object?>[]);
    Uint8List out = data;
    for (final Object? x in filters) {
      final Object? name = get(x);
      if (name == const PdfName('FlateDecode') || name == const PdfName('Fl')) {
        try {
          out = Uint8List.fromList(const ZLibDecoder().decodeBytes(out));
        } catch (_) {
          return Uint8List(0);
        }
      } else if (name == const PdfName('ASCII85Decode') || name == const PdfName('A85')) {
        out = ascii85(out);
      } else {
        return Uint8List(0); // images (DCT, JBIG2, …) carry no text
      }
    }
    return out;
  }
}

/// ASCII85 decoding (used by ReportLab and some printers).
Uint8List ascii85(Uint8List b) {
  final BytesBuilder out = BytesBuilder(copy: false);
  final List<int> grp = <int>[];
  int i = 0;
  if (b.length >= 2 && b[0] == 0x3c && b[1] == 0x7e) i = 2;
  void flush(int n) {
    int v = 0;
    for (final int g in grp) {
      v = v * 85 + g;
    }
    final List<int> bytes = <int>[(v >> 24) & 255, (v >> 16) & 255, (v >> 8) & 255, v & 255];
    out.add(bytes.sublist(0, n));
  }

  while (i < b.length) {
    final int c = b[i++];
    if (c == 0x7e) break;
    if (_ws(c)) continue;
    if (c == 0x7a && grp.isEmpty) {
      out.add(const <int>[0, 0, 0, 0]);
      continue;
    }
    grp.add(c - 33);
    if (grp.length == 5) {
      flush(4);
      grp.clear();
    }
  }
  if (grp.isNotEmpty) {
    final int n = grp.length;
    while (grp.length < 5) {
      grp.add(84);
    }
    flush(n - 1);
  }
  return out.takeBytes();
}

String _utf16(List<int> bytes) {
  final List<int> units = <int>[for (int k = 0; k + 1 < bytes.length; k += 2) (bytes[k] << 8) | bytes[k + 1]];
  return String.fromCharCodes(units);
}

List<int> _hexBytes(String h) => <int>[for (int k = 0; k + 1 < h.length; k += 2) int.parse(h.substring(k, k + 2), radix: 16)];

/// Parses a ToUnicode CMap into code → text, and the code width in bytes.
(Map<int, String>, int) parseCMap(Uint8List data) {
  final String s = latin1.decode(data);
  final Map<int, String> m = <int, String>{};
  int width = 1;
  for (final RegExpMatch blk in RegExp(r'begincodespacerange(.*?)endcodespacerange', dotAll: true).allMatches(s)) {
    final RegExpMatch? h = RegExp('<([0-9a-fA-F]+)>').firstMatch(blk[1]!);
    if (h != null) width = (h[1]!.length ~/ 2).clamp(1, 4);
  }
  for (final RegExpMatch blk in RegExp(r'beginbfchar(.*?)endbfchar', dotAll: true).allMatches(s)) {
    for (final RegExpMatch e in RegExp(r'<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]*)>').allMatches(blk[1]!)) {
      m[int.parse(e[1]!, radix: 16)] = _utf16(_hexBytes(e[2]!));
    }
  }
  for (final RegExpMatch blk in RegExp(r'beginbfrange(.*?)endbfrange', dotAll: true).allMatches(s)) {
    for (final RegExpMatch e in RegExp(r'<([0-9a-fA-F]+)>\s*<([0-9a-fA-F]+)>\s*(<[0-9a-fA-F]+>|\[[^\]]*\])').allMatches(blk[1]!)) {
      final int lo = int.parse(e[1]!, radix: 16);
      final int hi = int.parse(e[2]!, radix: 16);
      final String dst = e[3]!;
      if (dst.startsWith('[')) {
        int k = 0;
        for (final RegExpMatch h in RegExp('<([0-9a-fA-F]*)>').allMatches(dst)) {
          m[lo + k++] = _utf16(_hexBytes(h[1]!));
        }
      } else if (hi >= lo && hi - lo < 65536) {
        final List<int> base = _hexBytes(dst.substring(1, dst.length - 1));
        if (base.length < 2) continue;
        final int last = (base[base.length - 2] << 8) | base[base.length - 1];
        for (int k = 0; k <= hi - lo; k++) {
          final int u = last + k;
          m[lo + k] = _utf16(<int>[...base.sublist(0, base.length - 2), (u >> 8) & 255, u & 255]);
        }
      }
    }
  }
  return (m, width);
}

const Map<int, String> _winAnsi = <int, String>{
  0x80: '€', 0x85: '…', 0x91: '‘', 0x92: '’', 0x93: '“', 0x94: '”', 0x95: '•', 0x96: '–', 0x97: '—', 0x99: '™',
};

class _Font {
  _Font(_Pdf pdf, Object? ref) {
    final Map<String, Object?> fd = pdf.dict(ref);
    final Object? tu = fd['ToUnicode'];
    if (tu != null) {
      final (Map<int, String> m, int w) = parseCMap(pdf.stream(tu));
      map = m;
      width = w;
    } else if (pdf.get(fd['Subtype']) == const PdfName('Type0')) {
      width = 2;
    }
  }

  Map<int, String>? map;
  int width = 1;

  String text(Uint8List bs) {
    final Map<int, String>? m = map;
    if (m == null) {
      if (width == 2) return '';
      return String.fromCharCodes(<int>[for (final int c in bs) _winAnsi[c]?.codeUnitAt(0) ?? c]);
    }
    final StringBuffer out = StringBuffer();
    for (int i = 0; i + width <= bs.length; i += width) {
      int c = 0;
      for (int k = 0; k < width; k++) {
        c = (c << 8) | bs[i + k];
      }
      out.write(m[c] ?? '');
    }
    return out.toString();
  }
}

/// Extracts the text of every page, pages separated by a blank line.
/// Throws [FormatException] if the bytes are not a PDF.
String extractPdfText(Uint8List bytes) {
  if (bytes.length < 5 || latin1.decode(bytes.sublist(0, 5)) != '%PDF-') {
    throw const FormatException('This file is not a PDF.');
  }
  final _Pdf pdf = _Pdf(bytes);
  if (pdf.objs.values.any((_Obj o) => o.value is Map<String, Object?> && (o.value! as Map<String, Object?>).containsKey('Encrypt'))) {
    throw const FormatException('This PDF is password-protected. Save an unprotected copy and upload that.');
  }
  Map<String, Object?>? root;
  for (final _Obj o in pdf.objs.values) {
    final Object? v = o.value;
    if (v is Map<String, Object?> && pdf.get(v['Type']) == const PdfName('Catalog')) {
      root = v;
      break;
    }
  }
  final List<(Map<String, Object?>, Object?)> pages = <(Map<String, Object?>, Object?)>[];
  void walk(Object? node, Object? res, int depth) {
    final Map<String, Object?> n = pdf.dict(node);
    if (n.isEmpty || depth > 50) return;
    final Object? r = n['Resources'] ?? res;
    if (pdf.get(n['Type']) == const PdfName('Pages') || n.containsKey('Kids')) {
      final Object? kids = pdf.get(n['Kids']);
      if (kids is List<Object?>) {
        for (final Object? k in kids) {
          walk(k, r, depth + 1);
        }
      }
    } else {
      pages.add((n, r));
    }
  }

  if (root != null) walk(root['Pages'], null, 0);
  final List<String> out = <String>[];
  for (final (Map<String, Object?> page, Object? res) in pages) {
    final Map<String, Object?> resources = pdf.dict(res);
    final Map<String, _Font> fonts = <String, _Font>{
      for (final MapEntry<String, Object?> e in pdf.dict(resources['Font']).entries) e.key: _Font(pdf, e.value),
    };
    final Object? c = pdf.get(page['Contents']);
    final List<Object?> refs = c is List<Object?> ? c : <Object?>[page['Contents']];
    final BytesBuilder data = BytesBuilder(copy: false);
    for (final Object? r in refs) {
      data.add(pdf.stream(r));
      data.addByte(10);
    }
    final String t = _contentText(data.takeBytes(), fonts);
    if (t.isNotEmpty) out.add(t);
  }
  return out.join('\n\n');
}

String _contentText(Uint8List data, Map<String, _Font> fonts) {
  final _Lexer lx = _Lexer(data);
  List<Object?> args = <Object?>[];
  _Font? font;
  final List<String> lines = <String>[];
  StringBuffer cur = StringBuffer();
  double? y;
  void newline() {
    lines.add(cur.toString());
    cur = StringBuffer();
  }

  while (true) {
    final _Tok? t = lx.next();
    if (t == null) break;
    if (t.kind != 'op') {
      args.add(lx.valueFrom(t));
      continue;
    }
    final String op = t.value! as String;
    final List<Object?> a = args;
    args = <Object?>[];
    switch (op) {
      case 'Tf':
        if (a.length >= 2 && a[0] is PdfName) font = fonts[(a[0]! as PdfName).name];
      case 'Tj' || "'" || '"':
        if (op != 'Tj') newline();
        if (a.isNotEmpty && a.last is Uint8List && font != null) cur.write(font.text(a.last! as Uint8List));
      case 'TJ':
        if (a.isNotEmpty && a.last is List<Object?> && font != null) {
          for (final Object? x in a.last! as List<Object?>) {
            if (x is Uint8List) {
              cur.write(font.text(x));
            } else if (x is double && x < -180) {
              final String s = cur.toString();
              if (s.isNotEmpty && !s.endsWith(' ')) cur.write(' ');
            }
          }
        }
      case 'Td' || 'TD':
        if (a.length >= 2 && a[1] is double && (a[1]! as double).abs() > 0.5) newline();
      case 'T*':
        newline();
      case 'Tm':
        if (a.length >= 6 && a[5] is double) {
          final double ny = a[5]! as double;
          if (y != null && (ny - y).abs() > 0.5) newline();
          y = ny;
        }
      case 'BI':
        // Skip inline image data.
        int e = lx.i;
        while (e + 1 < data.length && !(data[e] == 0x45 && data[e + 1] == 0x49 && (e + 2 >= data.length || _ws(data[e + 2])))) {
          e++;
        }
        lx.i = e + 2;
      default:
        break;
    }
  }
  newline();
  final String text = lines.map((String l) => l.trimRight()).join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}

// ---------------------------------------------------------------- scans

/// A page picture taken from a scanned resume, ready to send for reading.
class ResumeImage {
  const ResumeImage(this.bytes, this.mime, this.width, this.height);
  final Uint8List bytes;
  final String mime;
  final int width;
  final int height;
}

/// Why a scanned page could not be turned into a picture.
class ScanImageUnsupported implements Exception {
  const ScanImageUnsupported(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The largest picture on each of the first [maxPages] pages of a scanned
/// PDF, as JPEG no wider or taller than [maxSide] pixels. Handles JPEG
/// (DCTDecode) scans and Flate-compressed grey, RGB and black-and-white
/// scans, including PNG predictors. Fax (CCITT), JBIG2 and JPEG 2000 scans
/// are reported with [ScanImageUnsupported].
List<ResumeImage> extractPdfScanImages(Uint8List bytes, {int maxPages = 3, int maxSide = 2000}) {
  if (bytes.length < 5 || latin1.decode(bytes.sublist(0, 5)) != '%PDF-') return const <ResumeImage>[];
  final _Pdf pdf = _Pdf(bytes);
  Map<String, Object?>? root;
  for (final _Obj o in pdf.objs.values) {
    final Object? v = o.value;
    if (v is Map<String, Object?> && pdf.get(v['Type']) == const PdfName('Catalog')) {
      root = v;
      break;
    }
  }
  final List<(Map<String, Object?>, Object?)> pages = <(Map<String, Object?>, Object?)>[];
  void walk(Object? node, Object? res, int depth) {
    final Map<String, Object?> n = pdf.dict(node);
    if (n.isEmpty || depth > 50) return;
    final Object? r = n['Resources'] ?? res;
    if (pdf.get(n['Type']) == const PdfName('Pages') || n.containsKey('Kids')) {
      final Object? kids = pdf.get(n['Kids']);
      if (kids is List<Object?>) {
        for (final Object? k in kids) {
          walk(k, r, depth + 1);
        }
      }
    } else {
      pages.add((n, r));
    }
  }

  if (root != null) walk(root['Pages'], null, 0);
  final List<ResumeImage> out = <ResumeImage>[];
  String? unsupported;
  for (final (Map<String, Object?> _, Object? res) in pages.take(maxPages)) {
    PdfRef? best;
    int bestArea = 0;
    void collect(Map<String, Object?> resources, int depth) {
      for (final Object? x in pdf.dict(resources['XObject']).values) {
        final Map<String, Object?> d = pdf.dict(x);
        if (pdf.get(d['Subtype']) == const PdfName('Image') && x is PdfRef) {
          final int area = ((pdf.get(d['Width']) as double? ?? 0) * (pdf.get(d['Height']) as double? ?? 0)).toInt();
          if (area > bestArea) {
            bestArea = area;
            best = x;
          }
        } else if (pdf.get(d['Subtype']) == const PdfName('Form') && depth < 4) {
          collect(pdf.dict(d['Resources']), depth + 1);
        }
      }
    }

    collect(pdf.dict(res), 0);
    if (best == null) continue;
    try {
      final img.Image? picture = _scanPicture(pdf, best!);
      if (picture == null) continue;
      out.add(_toJpeg(picture, maxSide));
    } on ScanImageUnsupported catch (e) {
      unsupported = e.message;
    }
  }
  if (out.isEmpty && unsupported != null) throw ScanImageUnsupported(unsupported);
  return out;
}

/// A photo or scan uploaded as an image file (JPEG or PNG).
ResumeImage? resumeImageFromFile(Uint8List bytes, {int maxSide = 2000}) {
  final img.Image? picture = img.decodeImage(bytes);
  return picture == null ? null : _toJpeg(picture, maxSide);
}

ResumeImage _toJpeg(img.Image picture, int maxSide) {
  img.Image p = picture;
  final int longest = p.width > p.height ? p.width : p.height;
  if (longest > maxSide) {
    p = p.width >= p.height ? img.copyResize(p, width: maxSide) : img.copyResize(p, height: maxSide);
  }
  return ResumeImage(Uint8List.fromList(img.encodeJpg(p, quality: 85)), 'image/jpeg', p.width, p.height);
}

img.Image? _scanPicture(_Pdf pdf, PdfRef ref) {
  final _Obj? o = pdf.objs[ref.num];
  if (o == null || o.stream == null || o.value is! Map<String, Object?>) return null;
  final Map<String, Object?> d = o.value! as Map<String, Object?>;
  final Object? f = pdf.get(d['Filter']);
  final List<PdfName> filters = <PdfName>[
    if (f is PdfName) f,
    if (f is List<Object?>)
      for (final Object? x in f)
        if (pdf.get(x) case final PdfName n) n,
  ];
  Uint8List data = o.stream!;
  for (final PdfName n in filters) {
    switch (n.name) {
      case 'FlateDecode' || 'Fl':
        try {
          data = Uint8List.fromList(const ZLibDecoder().decodeBytes(data));
        } catch (_) {
          return null;
        }
      case 'ASCII85Decode' || 'A85':
        data = ascii85(data);
      case 'DCTDecode' || 'DCT':
        return img.decodeJpg(data);
      case 'CCITTFaxDecode' || 'CCF' || 'JBIG2Decode':
        throw const ScanImageUnsupported('This scan uses black-and-white fax compression, which GradeGlow cannot read yet. Scan it again in colour or greyscale, or upload a photo.');
      case 'JPXDecode':
        throw const ScanImageUnsupported('This scan uses JPEG 2000, which GradeGlow cannot read yet. Save it again as a normal PDF, or upload a photo.');
      default:
        return null;
    }
  }
  final int w = (pdf.get(d['Width']) as double? ?? 0).toInt();
  final int h = (pdf.get(d['Height']) as double? ?? 0).toInt();
  if (w <= 0 || h <= 0 || w * h > 40000000) return null;
  final bool mask = pdf.get(d['ImageMask']) == true;
  final int bpc = mask ? 1 : (pdf.get(d['BitsPerComponent']) as double? ?? 8).toInt();
  int colors;
  final Object? cs = pdf.get(d['ColorSpace']);
  if (mask || cs == const PdfName('DeviceGray') || cs == const PdfName('CalGray')) {
    colors = 1;
  } else if (cs == const PdfName('DeviceRGB') || cs == const PdfName('CalRGB')) {
    colors = 3;
  } else if (cs is List<Object?> && cs.isNotEmpty && pdf.get(cs.first) == const PdfName('ICCBased') && cs.length > 1) {
    colors = (pdf.get(pdf.dict(cs[1])['N']) as double? ?? 3).toInt();
  } else {
    return null; // indexed, CMYK, Lab …: rare for resume scans
  }
  if (colors != 1 && colors != 3) return null;
  if (bpc != 1 && bpc != 8) return null;
  final Object? dp = pdf.get(d['DecodeParms']);
  final Map<String, Object?> parms = pdf.dict(dp is List<Object?> ? (dp.isEmpty ? null : dp.first) : dp);
  final int predictor = (pdf.get(parms['Predictor']) as double? ?? 1).toInt();
  final int rowBytes = (w * colors * bpc + 7) ~/ 8;
  if (predictor >= 10) data = _unPng(data, rowBytes, (colors * bpc + 7) ~/ 8, h);
  if (data.length < rowBytes * h) return null;
  // Decode [1 0] (or an image mask, where 0 paints) inverts grey levels.
  final Object? dec = pdf.get(d['Decode']);
  final bool invert = mask || (dec is List<Object?> && dec.length >= 2 && (pdf.get(dec[0]) as double? ?? 0) > (pdf.get(dec[1]) as double? ?? 1));
  final img.Image out = img.Image(width: w, height: h);
  for (int y = 0; y < h; y++) {
    final int row = y * rowBytes;
    for (int x = 0; x < w; x++) {
      if (bpc == 1) {
        final int bit = (data[row + (x >> 3)] >> (7 - (x & 7))) & 1;
        final int v = (bit == 1) != invert ? 255 : 0;
        out.setPixelRgb(x, y, v, v, v);
      } else if (colors == 1) {
        final int v = invert ? 255 - data[row + x] : data[row + x];
        out.setPixelRgb(x, y, v, v, v);
      } else {
        final int i = row + x * 3;
        out.setPixelRgb(x, y, data[i], data[i + 1], data[i + 2]);
      }
    }
  }
  return out;
}

/// Reverses PNG row filters (PDF Predictor 10–15).
Uint8List _unPng(Uint8List data, int rowBytes, int bpp, int rows) {
  final Uint8List out = Uint8List(rowBytes * rows);
  int i = 0;
  for (int y = 0; y < rows && i < data.length; y++) {
    final int type = data[i++];
    final int o = y * rowBytes;
    for (int x = 0; x < rowBytes && i < data.length; x++, i++) {
      final int a = x >= bpp ? out[o + x - bpp] : 0;
      final int b = y > 0 ? out[o - rowBytes + x] : 0;
      final int c = (x >= bpp && y > 0) ? out[o - rowBytes + x - bpp] : 0;
      final int raw = data[i];
      int v;
      switch (type) {
        case 1:
          v = raw + a;
        case 2:
          v = raw + b;
        case 3:
          v = raw + ((a + b) >> 1);
        case 4:
          final int p = a + b - c;
          final int pa = (p - a).abs(), pb = (p - b).abs(), pc = (p - c).abs();
          v = raw + ((pa <= pb && pa <= pc) ? a : (pb <= pc ? b : c));
        default:
          v = raw;
      }
      out[o + x] = v & 0xff;
    }
  }
  return out;
}
