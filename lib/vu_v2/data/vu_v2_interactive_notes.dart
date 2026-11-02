import 'vu_v2_topic_content_models.dart';

enum VuV2BeatKind {
  teach,
  pulse,
}

class VuV2PulseChoice {
  const VuV2PulseChoice({
    required this.label,
    required this.correct,
    required this.reaction,
  });

  final String label;
  final bool correct;
  final String reaction;
}

/// One interactive moment — teaching only, minimal chrome.
class VuV2InteractiveBeat {
  const VuV2InteractiveBeat({
    required this.kind,
    required this.eyebrow,
    required this.title,
    required this.body,
    this.moreBody,
    this.pulsePrompt,
    this.pulseChoices = const <VuV2PulseChoice>[],
    this.emoji = '📘',
  });

  final VuV2BeatKind kind;
  final String eyebrow;
  final String title;
  final String body;
  final String? moreBody;
  final String? pulsePrompt;
  final List<VuV2PulseChoice> pulseChoices;
  final String emoji;
}

/// Lean notes journey: teach the topic, one quick check, done.
abstract final class VuV2InteractiveNotes {
  static const int _maxBodyChars = 1800;
  static const int _maxMoreChars = 1800;

  static List<VuV2InteractiveBeat> build(VuV2TopicPackage pack) {
    final List<VuV2InteractiveBeat> beats = <VuV2InteractiveBeat>[];

    for (int i = 0; i < pack.sections.length; i++) {
      final VuV2TextbookSection section = pack.sections[i];
      final _BodySplit split = _splitBody(section.body);
      beats.add(
        VuV2InteractiveBeat(
          kind: VuV2BeatKind.teach,
          emoji: _emojiFor(section.title),
          eyebrow: '${i + 1}/${pack.sections.length}',
          title: section.title,
          body: split.body,
          moreBody: split.more,
        ),
      );
    }

    // One knowledge check at the end — not filler mid-lesson.
    beats.add(
      VuV2InteractiveBeat(
        kind: VuV2BeatKind.pulse,
        emoji: '⚡',
        eyebrow: 'CHECK',
        title: 'Quick check',
        body: 'Before the quiz: can you use the definition and apply it?',
        pulsePrompt: 'Best proof you understand this topic?',
        pulseChoices: const <VuV2PulseChoice>[
          VuV2PulseChoice(
            label: 'I recognize the title on a slide',
            correct: false,
            reaction: 'Recognition is not enough — you need definition + application.',
          ),
          VuV2PulseChoice(
            label: 'I can define it and solve/apply a new case with steps',
            correct: true,
            reaction: 'Yes. Definition + worked method = ready for the quiz.',
          ),
        ],
      ),
    );

    return beats;
  }

  static String _emojiFor(String title) {
    final String t = title.toLowerCase();
    if (t.contains('definition') || t.contains('concept')) return '🧩';
    if (t.contains('principle') ||
        t.contains('how it works') ||
        t.contains('deep')) {
      return '🧠';
    }
    if (t.contains('formula') ||
        t.contains('rule') ||
        t.contains('apply') ||
        t.contains('method')) {
      return '🛠️';
    }
    if (t.contains('diagram') || t.contains('illustration') || t.contains('model')) {
      return '🖼️';
    }
    if (t.contains('example')) return '🧪';
    if (t.contains('term') || t.contains('vocabulary')) return '📇';
    if (t.contains('mistake') || t.contains('misconception') || t.contains('avoid')) {
      return '⚠️';
    }
    return '📘';
  }

  static _BodySplit _splitBody(String raw) {
    final String text = raw.trim();
    if (text.isEmpty) {
      return const _BodySplit(body: 'Continue to the next section.');
    }
    if (text.length <= _maxBodyChars) {
      return _BodySplit(body: text);
    }
    int cut = text.lastIndexOf('\n\n', _maxBodyChars);
    if (cut < _maxBodyChars ~/ 2) {
      cut = text.lastIndexOf('. ', _maxBodyChars);
      if (cut > 0) cut += 1;
    }
    if (cut < _maxBodyChars ~/ 3) cut = _maxBodyChars;
    final String body = text.substring(0, cut).trim();
    String more = text.substring(cut).trim();
    if (more.length > _maxMoreChars) {
      more = '${more.substring(0, _maxMoreChars).trim()}...';
    }
    return _BodySplit(body: body, more: more.isEmpty ? null : more);
  }
}

class _BodySplit {
  const _BodySplit({required this.body, this.more});

  final String body;
  final String? more;
}
