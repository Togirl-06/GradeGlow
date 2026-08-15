import 'package:ai_study_buddy/data/lecture_speech_hygiene.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('drops open-your-notes framing and keeps the teaching', () {
    const String raw =
        'Open your notes. We are on Osmosis — Definitions. '
        'I am going to teach this the way I would in a university classroom, not give you a one-line summary. '
        'Osmosis is the net movement of water across a semipermeable membrane toward higher solute concentration.';

    final String cleaned = LectureSpeechHygiene.clean(raw);
    expect(cleaned.toLowerCase(), isNot(contains('open your notes')));
    expect(cleaned.toLowerCase(), isNot(contains('university classroom')));
    expect(cleaned, contains('Osmosis is the net movement of water'));
  });
}
