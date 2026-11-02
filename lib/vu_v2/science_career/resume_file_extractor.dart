import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';

import '../../utils/pdf_text_extractor.dart';

/// Extract plain text from a résumé PDF or DOCX for hire scoring.
class ResumeFileExtractor {
  ResumeFileExtractor._();

  static Future<String> extract({
    required Uint8List bytes,
    required String extension,
    required String fileName,
  }) async {
    final String ext = extension.toLowerCase().replaceAll('.', '');
    if (ext == 'docx') {
      return _fromDocx(bytes);
    }
    if (ext == 'pdf') {
      final String text = await PdfTextExtractor.fromBytes(
        bytes,
        fileName: fileName.endsWith('.pdf') ? fileName : '$fileName.pdf',
      );
      // Web / scan failures return help messages — treat as empty for scoring.
      if (text.startsWith('PDF text extraction') ||
          text.startsWith('Could not extract')) {
        return '';
      }
      return text;
    }
    return '';
  }

  static String _fromDocx(Uint8List bytes) {
    try {
      final Archive archive = ZipDecoder().decodeBytes(bytes);
      final ArchiveFile? doc = archive.findFile('word/document.xml');
      if (doc == null) return '';
      final List<int> content = doc.content;
      if (content.isEmpty) return '';
      final String xml = String.fromCharCodes(content);
      final RegExp tags = RegExp(r'<w:t[^>]*>([^<]*)</w:t>');
      final String text =
          tags.allMatches(xml).map((RegExpMatch m) => m.group(1) ?? '').join(' ');
      return text.trim();
    } catch (_) {
      if (kIsWeb) return '';
      return '';
    }
  }
}
