String _speechCapture(Match match) => match.group(1)!;

/// Split textbook markdown into speakable sentences for Read Aloud narration.
List<String> textbookSpeechSentences(String markdown) {
  String plain = markdown
      .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
      .replaceAll(RegExp(r'\$\$[\s\S]*?\$\$'), ' equation. ')
      .replaceAll(RegExp(r'\$[^$]+\$'), ' ')
      .replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), _speechCapture)
      .replaceAllMapped(RegExp(r'\*([^*]+)\*'), _speechCapture)
      .replaceAllMapped(RegExp(r'`([^`]+)`'), _speechCapture)
      .replaceAllMapped(
        RegExp(r'^#{1,6}\s+(.+)$', multiLine: true),
        (Match match) => '${_speechCapture(match)}. ',
      )
      .replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '')
      .replaceAll(RegExp(r'\|[^|\n]+\|'), ' ')
      .replaceAll(RegExp(r'\n{2,}'), '\n')
      .trim();

  final List<String> raw = plain
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((String s) => s.trim())
      .where((String s) => s.length > 12)
      .toList();

  return raw;
}

/// Plain speech for a single sentence (no markdown).
String speechSentence(String sentence) =>
    sentence.replaceAll(RegExp(r'\s+'), ' ').trim();
