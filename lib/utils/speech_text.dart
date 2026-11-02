/// Normalize assistant markdown into plain text suitable for TTS.
String speechTextFromMarkdown(String text) {
  String out = text.trim();
  if (out.isEmpty) return out;

  // Drop fenced code — not meant to be read aloud.
  out = out.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');

  // Strip markdown structure while keeping readable words.
  String capture(Match match) => match.group(1)!;
  out = out.replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), capture);
  out = out.replaceAllMapped(RegExp(r'\*([^*]+)\*'), capture);
  out = out.replaceAllMapped(RegExp(r'`([^`]+)`'), capture);
  out = out.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');
  out = out.replaceAll(RegExp(r'^>\s*', multiLine: true), '');
  out = out.replaceAll(RegExp(r'^[-*]\s+', multiLine: true), '');
  out = out.replaceAll(RegExp(r'\n{2,}'), '. ');
  out = out.replaceAll(RegExp(r'\s+'), ' ').trim();

  if (out.isEmpty) {
    return 'Here is my answer in the chat.';
  }

  return out;
}

/// OpenAI TTS input limit is 4096 characters — keep a safety margin.
const int kOpenAiTtsMaxChars = 3800;

/// Split plain speech into chunks that finish on sentence boundaries.
/// Never mid-word / mid-sentence truncates with an ellipsis.
List<String> speechChunksForTts(
  String text, {
  int maxChars = kOpenAiTtsMaxChars,
}) {
  final String plain = text.trim();
  if (plain.isEmpty) return const <String>[];
  if (plain.length <= maxChars) return <String>[plain];

  final List<String> sentences = plain
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();

  if (sentences.isEmpty) {
    return _hardWrap(plain, maxChars);
  }

  final List<String> chunks = <String>[];
  final StringBuffer buf = StringBuffer();

  void flush() {
    final String piece = buf.toString().trim();
    if (piece.isNotEmpty) chunks.add(piece);
    buf.clear();
  }

  for (final String sentence in sentences) {
    if (sentence.length > maxChars) {
      flush();
      chunks.addAll(_hardWrap(sentence, maxChars));
      continue;
    }
    final int nextLen =
        buf.isEmpty ? sentence.length : buf.length + 1 + sentence.length;
    if (nextLen > maxChars) {
      flush();
    }
    if (buf.isNotEmpty) buf.write(' ');
    buf.write(sentence);
  }
  flush();
  return chunks;
}

List<String> _hardWrap(String text, int maxChars) {
  final List<String> out = <String>[];
  int i = 0;
  while (i < text.length) {
    int end = (i + maxChars).clamp(0, text.length);
    if (end < text.length) {
      final int space = text.lastIndexOf(' ', end);
      if (space > i + (maxChars ~/ 3)) {
        end = space;
      }
    }
    out.add(text.substring(i, end).trim());
    i = end;
    while (i < text.length && text[i] == ' ') {
      i++;
    }
  }
  return out.where((String s) => s.isNotEmpty).toList();
}
