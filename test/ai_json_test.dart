import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_buddy/utils/ai_json.dart';

void main() {
  test('repairs LaTeX backslashes and newlines in flashcard JSON', () {
    const String broken = '''
{"flashcards":[{"front": "What is \$\$\\int x
\\sin(x) \\, dx\$\$ using integration?", "back": "formula"}]}''';

    final Map<String, dynamic> parsed = decodeAiJson(broken);
    final List<dynamic> cards = parsed['flashcards'] as List<dynamic>;
    expect(cards, isNotEmpty);
    expect(cards.first['front'], contains(r'\sin'));
  });
}
