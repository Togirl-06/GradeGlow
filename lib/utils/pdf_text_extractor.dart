import 'dart:io';
import 'dart:typed_data';

import 'package:read_pdf_text/read_pdf_text.dart';

/// Extract plain text from a PDF file for OpenAI analysis.
class PdfTextExtractor {
  static Future<String> fromBytes(Uint8List bytes, {String fileName = 'document.pdf'}) async {
    final Directory temp = Directory.systemTemp;
    final File file = File('${temp.path}/study_buddy_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    try {
      return await fromPath(file.path);
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  static Future<String> fromPath(String path) async {
    try {
      final String raw = await ReadPdfText.getPDFtext(path);
      final String trimmed = raw.trim();
      if (trimmed.isEmpty) {
        return 'Could not extract text from this PDF. It may be scanned — try uploading slides as photos instead.';
      }
      return trimmed;
    } catch (_) {
      return 'Could not extract text from this PDF. Try a text-based PDF or upload photos of the pages.';
    }
  }
}
