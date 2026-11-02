/// Splits long extracted document text into API-friendly chunks at paragraph boundaries.
class DocumentTextChunker {
  DocumentTextChunker._();

  /// Larger chunks → fewer API round-trips for long docs.
  static const int chunkSize = 22000;

  static List<String> chunk(String text) {
    final String trimmed = text.trim();
    if (trimmed.length <= chunkSize) return <String>[trimmed];

    final List<String> paragraphs = trimmed.split(RegExp(r'\n\s*\n'));
    final List<String> chunks = <String>[];
    final StringBuffer buffer = StringBuffer();

    for (final String paragraph in paragraphs) {
      final String block = paragraph.trim();
      if (block.isEmpty) continue;

      final int nextLength = buffer.length + (buffer.isEmpty ? 0 : 2) + block.length;
      if (nextLength > chunkSize && buffer.isNotEmpty) {
        chunks.add(buffer.toString().trim());
        buffer.clear();
      }

      if (block.length > chunkSize) {
        if (buffer.isNotEmpty) {
          chunks.add(buffer.toString().trim());
          buffer.clear();
        }
        chunks.addAll(_splitOversizedBlock(block));
        continue;
      }

      if (buffer.isNotEmpty) buffer.writeln();
      buffer.write(block);
    }

    if (buffer.isNotEmpty) {
      chunks.add(buffer.toString().trim());
    }

    return chunks.isEmpty ? <String>[trimmed] : chunks;
  }

  static List<String> _splitOversizedBlock(String block) {
    final List<String> parts = <String>[];
    int start = 0;
    while (start < block.length) {
      final int end = (start + chunkSize).clamp(0, block.length);
      parts.add(block.substring(start, end).trim());
      start = end;
    }
    return parts.where((String part) => part.isNotEmpty).toList();
  }
}
