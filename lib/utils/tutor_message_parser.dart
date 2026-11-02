/// Splits tutor markdown into plain text and fenced code blocks.
class TutorMessageParser {
  TutorMessageParser._();

  static final RegExp _fence = RegExp(
    r'```([^\n`]*)\n([\s\S]*?)```',
    multiLine: true,
  );

  static List<MessageSegment> parse(String input) {
    if (input.trim().isEmpty) return const <MessageSegment>[];

    final List<MessageSegment> segments = <MessageSegment>[];
    int cursor = 0;

    for (final RegExpMatch match in _fence.allMatches(input)) {
      if (match.start > cursor) {
        _addText(segments, input.substring(cursor, match.start));
      }
      final String language = (match.group(1) ?? '').trim();
      final String code = (match.group(2) ?? '').replaceFirst(RegExp(r'\n$'), '');
      if (code.trim().isNotEmpty) {
        segments.add(CodeBlockSegment(language: language, code: code));
      }
      cursor = match.end;
    }

    if (cursor < input.length) {
      _addText(segments, input.substring(cursor));
    }

    return segments;
  }

  static void _addText(List<MessageSegment> segments, String raw) {
    final String text = raw.trim();
    if (text.isNotEmpty) {
      segments.add(TextSegment(text));
    }
  }
}

sealed class MessageSegment {
  const MessageSegment();
}

class TextSegment extends MessageSegment {
  const TextSegment(this.text);

  final String text;
}

class CodeBlockSegment extends MessageSegment {
  const CodeBlockSegment({required this.language, required this.code});

  final String language;
  final String code;
}
