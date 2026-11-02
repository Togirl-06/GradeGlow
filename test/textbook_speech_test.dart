import 'package:ai_study_buddy/utils/speech_text.dart';
import 'package:ai_study_buddy/utils/textbook_speech.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('textbookSpeechSentences strips bold markdown for read-aloud', () {
    final sentences = textbookSpeechSentences(
      '**Velocity** is a foundational concept in **Kinematics**.',
    );

    expect(sentences, isNotEmpty);
    expect(sentences.first, contains('Velocity'));
    expect(sentences.first, contains('Kinematics'));
    expect(sentences.first, isNot(contains(r'$1')));
  });

  test('speechTextFromMarkdown strips bold markdown for TTS', () {
    final plain = speechTextFromMarkdown(
      '**Velocity** is a foundational concept in **Kinematics**.',
    );

    expect(plain, contains('Velocity'));
    expect(plain, contains('Kinematics'));
    expect(plain, isNot(contains(r'$1')));
  });
}
