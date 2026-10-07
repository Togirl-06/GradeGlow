import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';

import 'io_file_bytes.dart';

/// Extract plain text from a PowerPoint (.pptx) file for OpenAI analysis.
class PptxTextExtractor {
  static Future<String> fromBytes(Uint8List bytes, {String fileName = 'slides.pptx'}) async {
    return _extractFromBytes(bytes);
  }

  static Future<String> fromPath(String path) async {
    try {
      final Uint8List bytes = await readFileBytes(path);
      return _extractFromBytes(bytes);
    } catch (_) {
      return 'Could not read this PowerPoint file. Try saving as .pptx or PDF.';
    }
  }

  static String _extractFromBytes(Uint8List bytes) {
    try {
      final Archive archive = ZipDecoder().decodeBytes(bytes);

      final List<ArchiveFile> slideFiles = archive.files
          .where(
            (ArchiveFile f) =>
                f.isFile && f.name.startsWith('ppt/slides/slide') && f.name.endsWith('.xml'),
          )
          .toList();
      slideFiles.sort(
        (ArchiveFile a, ArchiveFile b) => _slideNumber(a.name).compareTo(_slideNumber(b.name)),
      );

      final List<String> slideTexts = <String>[];
      for (final ArchiveFile slide in slideFiles) {
        final List<int> content = slide.content;
        if (content.isEmpty) continue;
        final String xml = String.fromCharCodes(content);
        final String text = _extractTextFromSlideXml(xml).trim();
        if (text.isNotEmpty) slideTexts.add(text);
      }

      final String combined = slideTexts.join('\n\n');
      if (combined.trim().isEmpty) {
        return 'Could not extract text from this PowerPoint. Try saving as PDF or paste the slide text.';
      }
      return combined.trim();
    } catch (_) {
      if (kIsWeb) {
        return 'Could not read this PowerPoint in the browser. Try Paste text, or upload photos of the slides.';
      }
      return 'Could not read this PowerPoint file. Try saving as .pptx or PDF.';
    }
  }

  static int _slideNumber(String name) {
    final RegExpMatch? match = RegExp(r'slide(\d+)\.xml').firstMatch(name);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  static String _extractTextFromSlideXml(String xml) {
    final RegExp textTags = RegExp(r'<a:t[^>]*>([^<]*)</a:t>');
    return textTags.allMatches(xml).map((RegExpMatch m) => m.group(1) ?? '').join(' ');
  }
}
