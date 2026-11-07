/// Reading scanned resumes and photos (OCR). The pictures are sent through
/// the app's OpenAI connection with a strict "copy exactly" instruction; the
/// student then checks every field on the review screen before it is used.
library;

import 'dart:typed_data';

import '../../services/openai_service.dart';
import 'pdf_text.dart';

abstract class ResumeOcr {
  /// The text on [pages], in reading order. Throws when it cannot be read.
  Future<String> transcribe(List<ResumeImage> pages);
}

class OpenAiResumeOcr implements ResumeOcr {
  OpenAiResumeOcr(this._service);
  final OpenAiService _service;

  static const String instruction = 'Transcribe this resume exactly as written, page by page, top to bottom. '
      'Copy every word, date, number, email and phone number exactly. Do not correct, summarise, translate, reorder or add anything. '
      'Keep each section heading on its own line and keep bullet points as separate lines starting with "- ". '
      'If a word cannot be read, write [unreadable]. If the picture is not a resume or has no readable text, reply NO_TEXT. '
      'Reply with plain text only.';

  @override
  Future<String> transcribe(List<ResumeImage> pages) async {
    final String text = await _service
        .transcribeDocumentPages(<(Uint8List, String)>[for (final ResumeImage p in pages) (p.bytes, p.mime)], instruction)
        .timeout(const Duration(seconds: 90));
    if (text.trim().toUpperCase().startsWith('NO_TEXT')) return '';
    return text.replaceAll(RegExp(r'^```[a-z]*\n?|```$', multiLine: true), '').trim();
  }
}
