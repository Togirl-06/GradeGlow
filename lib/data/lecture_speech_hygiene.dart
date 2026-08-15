import '../models/virtual_lecture.dart';

/// Strips classroom-roleplay filler so the professor just teaches the topic.
abstract final class LectureSpeechHygiene {
  static final List<RegExp> _dropSentence = <RegExp>[
    RegExp(r'open your notes', caseSensitive: false),
    RegExp(r'close your notes', caseSensitive: false),
    RegExp(r'university classroom', caseSensitive: false),
    RegExp(r'like a real university', caseSensitive: false),
    RegExp(r'real \$courseTitle classroom', caseSensitive: false),
    RegExp(r'i am going to teach', caseSensitive: false),
    RegExp(r"i['’]m going to teach", caseSensitive: false),
    RegExp(r'i will teach this the way', caseSensitive: false),
    RegExp(r'not a chatbot', caseSensitive: false),
    RegExp(r'not give you a one-line summary', caseSensitive: false),
    RegExp(r'i am not going to summarize', caseSensitive: false),
    RegExp(r'write this down', caseSensitive: false),
    RegExp(r'lock this in', caseSensitive: false),
    RegExp(r'your job:', caseSensitive: false),
    RegExp(r'teach it back', caseSensitive: false),
    RegExp(r'listen, write, and be ready', caseSensitive: false),
    RegExp(r'glance at the slide', caseSensitive: false),
    RegExp(r'the slide shows', caseSensitive: false),
    RegExp(r'stay with me[^.]*explain', caseSensitive: false),
    RegExp(r'good morning, everyone', caseSensitive: false),
    RegExp(r'^welcome\.?\s+today we are in', caseSensitive: false),
    RegExp(r'welcome to the biology lecture hall', caseSensitive: false),
    RegExp(r'welcome to the chemistry laboratory', caseSensitive: false),
    RegExp(r'class dismissed', caseSensitive: false),
    RegExp(r'like a future clinician', caseSensitive: false),
    RegExp(r'judges\s*[—-]', caseSensitive: false),
    RegExp(r'other apps dump', caseSensitive: false),
    RegExp(r'we will never hide', caseSensitive: false),
    RegExp(r'no labels yet', caseSensitive: false),
    RegExp(r'clean plate', caseSensitive: false),
    RegExp(r'not a quiz app', caseSensitive: false),
    RegExp(r'this is a full university chapter', caseSensitive: false),
    RegExp(r'take notes', caseSensitive: false),
    RegExp(r'pause and restate', caseSensitive: false),
    RegExp(r'if you only memorize the title', caseSensitive: false),
    RegExp(r'tell yourself the idea', caseSensitive: false),
    RegExp(r'tell yourself, in one sentence', caseSensitive: false),
    RegExp(r'i will not dump a definition', caseSensitive: false),
    RegExp(r'imagine we are not reading a page', caseSensitive: false),
  ];

  static VirtualLectureScript cleanScript(VirtualLectureScript script) {
    return script.copyWith(
      segments: script.segments.map(cleanSegment).toList(growable: false),
    );
  }

  static LectureSegment cleanSegment(LectureSegment segment) {
    return segment.copyWith(
      professorSpeech: clean(segment.professorSpeech),
      beats: segment.beats
          .map(
            (LectureInteractiveBeat b) => LectureInteractiveBeat(
              professorSpeech: clean(b.professorSpeech),
              caption: b.caption,
              durationSeconds: b.durationSeconds,
              whiteboard: b.whiteboard,
              studentChoice: b.studentChoice,
              slideNotes: b.slideNotes,
            ),
          )
          .toList(growable: false),
    );
  }

  static String clean(String speech) {
    final String raw = speech.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (raw.isEmpty) return raw;

    final List<String> kept = raw
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty && !_isMeta(s))
        .toList();

    if (kept.isEmpty) return raw;
    return kept.join(' ');
  }

  static bool _isMeta(String sentence) {
    for (final RegExp p in _dropSentence) {
      if (p.hasMatch(sentence)) return true;
    }
    final String t = sentence.toLowerCase();
    if (t.startsWith('welcome to ') &&
        (t.contains('today we') || t.contains('this entire lecture'))) {
      return true;
    }
    return false;
  }
}
