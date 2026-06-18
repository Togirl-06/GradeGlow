/// Normalize assistant markdown into plain text suitable for TTS.
String speechTextFromMarkdown(String text) {
  String out = text.trim();
  if (out.isEmpty) return out;

  // Drop fenced code — not meant to be read aloud.
  out = out.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');

  // Strip markdown structure while keeping readable words.
  out = out.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
  out = out.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
  out = out.replaceAll(RegExp(r'`([^`]+)`'), r'$1');
  out = out.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');
  out = out.replaceAll(RegExp(r'^>\s*', multiLine: true), '');
  out = out.replaceAll(RegExp(r'^[-*]\s+', multiLine: true), '');
  out = out.replaceAll(RegExp(r'\n{2,}'), '. ');
  out = out.replaceAll(RegExp(r'\s+'), ' ').trim();

  if (out.isEmpty) {
    return 'Here is my answer in the chat.';
  }

  if (out.length > 1200) {
    out = '${out.substring(0, 1197)}…';
  }
  return out;
}
