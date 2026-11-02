import 'dart:convert';

/// Extract and decode JSON blobs returned by OpenAI (handles fences, LaTeX, newlines).
Map<String, dynamic> decodeAiJson(String text) {
  final String blob = extractJsonBlob(text);
  try {
    return jsonDecode(blob) as Map<String, dynamic>;
  } on FormatException {
    return jsonDecode(repairJsonStringLiterals(blob)) as Map<String, dynamic>;
  }
}

/// Pull the outermost `{...}` object from an assistant message.
String extractJsonBlob(String text) {
  String trimmed = text.trim();
  final RegExp fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```', caseSensitive: false);
  final Match? match = fence.firstMatch(trimmed);
  if (match != null) {
    trimmed = match.group(1)!.trim();
  }

  final int start = trimmed.indexOf('{');
  final int end = trimmed.lastIndexOf('}');
  if (start == -1 || end == -1 || end <= start) {
    throw const FormatException('Could not find JSON object in AI response.');
  }
  return trimmed.substring(start, end + 1);
}

/// Fix invalid `\` escapes and raw newlines inside JSON string literals (common with LaTeX).
String repairJsonStringLiterals(String json) {
  final StringBuffer out = StringBuffer();
  bool inString = false;

  for (int i = 0; i < json.length; i++) {
    final String char = json[i];

    if (!inString) {
      out.write(char);
      if (char == '"') inString = true;
      continue;
    }

    if (char == '"') {
      out.write(char);
      inString = false;
      continue;
    }

    if (char == '\n' || char == '\r') {
      out.write(r'\n');
      continue;
    }

    if (char == '\\') {
      if (i + 1 >= json.length) {
        out.write(r'\\');
        continue;
      }

      final String next = json[i + 1];
      if (next == 'u' && i + 5 < json.length) {
        final String hex = json.substring(i + 2, i + 6);
        if (RegExp(r'^[0-9a-fA-F]{4}$').hasMatch(hex)) {
          out.write('\\u$hex');
          i += 5;
          continue;
        }
      }

      if (next == '\\' || '"/bfnrt'.contains(next)) {
        out.write('\\');
        out.write(next);
        i += 1;
        continue;
      }

      out.write(r'\\');
      continue;
    }

    out.write(char);
  }

  return out.toString();
}
