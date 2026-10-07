import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

import 'io_file_bytes.dart';

/// Extract plain text from a PDF file for OpenAI analysis.
class PdfTextExtractor {
  static Future<String> fromBytes(Uint8List bytes, {String fileName = 'document.pdf'}) async {
    if (kIsWeb) {
      return 'PDF text extraction is not available in the browser. '
          'Paste the text, or upload photos of the pages instead.';
    }
    final String path = await writeTempFileBytes(bytes, fileName);
    try {
      return await fromPath(path);
    } finally {
      // Best-effort cleanup is handled by the OS temp folder.
    }
  }

  static Future<String> fromPath(String path) async {
    if (kIsWeb) {
      return 'PDF text extraction is not available in the browser. '
          'Paste the text, or upload photos of the pages instead.';
    }
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
