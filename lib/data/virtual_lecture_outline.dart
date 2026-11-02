import '../models/virtual_lecture.dart';

/// One chapter in the cinematic lecture table of contents (mockup CONTENTS).
class LectureOutlineChapter {
  const LectureOutlineChapter({
    required this.id,
    required this.label,
    required this.kind,
    required this.icon,
    required this.accent,
    required this.segmentIndices,
    this.body = '',
  });

  final String id;
  final String label;
  final LectureOutlineKind kind;
  final IconDataRef icon;
  final LectureOutlineAccent accent;
  final List<int> segmentIndices;
  final String body;

  int get firstSegmentIndex =>
      segmentIndices.isEmpty ? 0 : segmentIndices.first;
}

enum LectureOutlineKind {
  introduction,
  history,
  theory,
  visual,
  formulas,
  applications,
  selfCheck,
  compare,
  practice,
  homework,
  reading,
}

enum LectureOutlineAccent { blue, amber, green, purple, orange, slate }

/// Lightweight icon token so outline data stays free of Flutter imports issues.
enum IconDataRef {
  book,
  history,
  theory,
  visual,
  formula,
  world,
  check,
  compare,
  practice,
  homework,
  reading,
}

/// Builds the CONTENTS sidebar + readable section cards for any topic/course.
abstract final class VirtualLectureOutline {
  static List<LectureOutlineChapter> build({
    required VirtualLectureScript script,
  }) {
    final String topic = script.topic;
    final List<LectureSegment> segs = script.segments;

    List<int> where(bool Function(LectureSegment s, int i) test) {
      final List<int> out = <int>[];
      for (int i = 0; i < segs.length; i++) {
        if (test(segs[i], i)) out.add(i);
      }
      return out;
    }

    String joinSpeech(List<int> idxs) {
      if (idxs.isEmpty) return '';
      return idxs
          .map((int i) => segs[i].professorSpeech.trim())
          .where((String s) => s.isNotEmpty)
          .join('\n\n');
    }

    final List<int> intro = where(
      (LectureSegment s, int i) =>
          s.phase == LecturePhase.introduction ||
          s.caption.toLowerCase().contains('why') ||
          s.caption.toLowerCase().contains('introduction'),
    );
    final List<int> history = where(
      (LectureSegment s, int i) =>
          s.caption.toLowerCase().contains('history') ||
          s.professorSpeech.toLowerCase().contains('history of'),
    );
    final List<int> visual = where(
      (LectureSegment s, int i) =>
          s.phase == LecturePhase.visualDemonstration ||
          s.whiteboard.kind == WhiteboardKind.graph ||
          s.caption.toLowerCase().contains('visual'),
    );
    final List<int> formulas = where(
      (LectureSegment s, int i) =>
          s.caption.toLowerCase().contains('formula') ||
          s.caption.toLowerCase().contains('symbol') ||
          s.whiteboard.kind == WhiteboardKind.equation,
    );
    final List<int> apps = where(
      (LectureSegment s, int i) =>
          s.caption.toLowerCase().contains('real-world') ||
          s.caption.toLowerCase().contains('application') ||
          s.caption.toLowerCase().contains('examples'),
    );
    final List<int> checks = where(
      (LectureSegment s, int i) =>
          s.phase == LecturePhase.knowledgeCheck ||
          s.phase == LecturePhase.studentParticipation ||
          s.knowledgeCheck != null,
    );
    final List<int> compare = where(
      (LectureSegment s, int i) =>
          s.caption.toLowerCase().contains('previous') ||
          s.caption.toLowerCase().contains('compare'),
    );
    final List<int> practice = where(
      (LectureSegment s, int i) =>
          s.phase == LecturePhase.practiceProblems ||
          s.phase == LecturePhase.guidedExamples ||
          s.caption.toLowerCase().contains('exercise') ||
          s.caption.toLowerCase().contains('practice'),
    );
    final List<int> homework = where(
      (LectureSegment s, int i) =>
          s.phase == LecturePhase.homeworkRecommendation ||
          s.caption.toLowerCase().contains('homework'),
    );
    final List<int> reading = where(
      (LectureSegment s, int i) =>
          s.caption.toLowerCase().contains('reading') ||
          s.caption.toLowerCase().contains('further'),
    );
    final List<int> theory = where(
      (LectureSegment s, int i) =>
          s.phase == LecturePhase.conceptExplanation ||
          s.phase == LecturePhase.objectives,
    );

    List<int> orFallback(List<int> primary, List<int> fallback) {
      if (primary.isNotEmpty) return primary;
      return fallback.where((int i) => i >= 0 && i < segs.length).toList();
    }

    final List<int> safeLast = segs.isEmpty ? <int>[] : <int>[segs.length - 1];
    final List<int> safeMid =
        segs.isEmpty ? <int>[] : <int>[(segs.length ~/ 2).clamp(0, segs.length - 1)];
    final List<int> safeNearEnd = segs.length < 2
        ? safeLast
        : <int>[segs.length - 2];

    final List<int> theoryOnly = theory
        .where(
          (int i) =>
              !history.contains(i) &&
              !apps.contains(i) &&
              !formulas.contains(i) &&
              !compare.contains(i),
        )
        .toList();

    return <LectureOutlineChapter>[
      LectureOutlineChapter(
        id: 'intro',
        label: 'Why $topic Matters',
        kind: LectureOutlineKind.introduction,
        icon: IconDataRef.book,
        accent: LectureOutlineAccent.blue,
        segmentIndices: orFallback(intro, <int>[0]),
        body: joinSpeech(orFallback(intro, <int>[0])),
      ),
      LectureOutlineChapter(
        id: 'history',
        label: 'The Evolution of $topic',
        kind: LectureOutlineKind.history,
        icon: IconDataRef.history,
        accent: LectureOutlineAccent.amber,
        segmentIndices: orFallback(history, theory.take(1).toList()),
        body: joinSpeech(orFallback(history, theory.take(1).toList())),
      ),
      LectureOutlineChapter(
        id: 'theory',
        label: _shortTitle(topic, 'Core Theory'),
        kind: LectureOutlineKind.theory,
        icon: IconDataRef.theory,
        accent: LectureOutlineAccent.purple,
        segmentIndices: orFallback(theoryOnly, theory),
        body: joinSpeech(orFallback(theoryOnly, theory)),
      ),
      LectureOutlineChapter(
        id: 'visual',
        label: 'Visualizing $topic',
        kind: LectureOutlineKind.visual,
        icon: IconDataRef.visual,
        accent: LectureOutlineAccent.orange,
        segmentIndices: orFallback(visual, theory.take(1).toList()),
        body: joinSpeech(orFallback(visual, theory.take(1).toList())),
      ),
      LectureOutlineChapter(
        id: 'formulas',
        label: 'Formulas & Every Symbol',
        kind: LectureOutlineKind.formulas,
        icon: IconDataRef.formula,
        accent: LectureOutlineAccent.slate,
        segmentIndices: orFallback(formulas, theory.take(1).toList()),
        body: joinSpeech(orFallback(formulas, theory.take(1).toList())),
      ),
      LectureOutlineChapter(
        id: 'apps',
        label: 'Real-World Applications',
        kind: LectureOutlineKind.applications,
        icon: IconDataRef.world,
        accent: LectureOutlineAccent.green,
        segmentIndices: orFallback(apps, theory.take(1).toList()),
        body: joinSpeech(orFallback(apps, theory.take(1).toList())),
      ),
      LectureOutlineChapter(
        id: 'check',
        label: 'Self-Check',
        kind: LectureOutlineKind.selfCheck,
        icon: IconDataRef.check,
        accent: LectureOutlineAccent.blue,
        segmentIndices: orFallback(checks, safeMid),
        body: joinSpeech(orFallback(checks, <int>[])),
      ),
      LectureOutlineChapter(
        id: 'compare',
        label: '$topic vs Prior Lessons',
        kind: LectureOutlineKind.compare,
        icon: IconDataRef.compare,
        accent: LectureOutlineAccent.amber,
        segmentIndices: orFallback(compare, theory.take(1).toList()),
        body: joinSpeech(orFallback(compare, theory.take(1).toList())),
      ),
      LectureOutlineChapter(
        id: 'practice',
        label: 'Practice Problems',
        kind: LectureOutlineKind.practice,
        icon: IconDataRef.practice,
        accent: LectureOutlineAccent.orange,
        segmentIndices: orFallback(practice, safeNearEnd),
        body: joinSpeech(orFallback(practice, <int>[])),
      ),
      LectureOutlineChapter(
        id: 'homework',
        label: 'Take-Home Assignment',
        kind: LectureOutlineKind.homework,
        icon: IconDataRef.homework,
        accent: LectureOutlineAccent.purple,
        segmentIndices: orFallback(homework, safeLast),
        body: joinSpeech(orFallback(homework, safeLast)).isNotEmpty
            ? joinSpeech(orFallback(homework, safeLast))
            : script.summary.homeworkRecommendation,
      ),
      LectureOutlineChapter(
        id: 'reading',
        label: 'Further Exploration',
        kind: LectureOutlineKind.reading,
        icon: IconDataRef.reading,
        accent: LectureOutlineAccent.green,
        segmentIndices: orFallback(reading, orFallback(homework, safeLast)),
        body: joinSpeech(orFallback(reading, orFallback(homework, safeLast))),
      ),
    ];
  }

  static String _shortTitle(String topic, String fallback) {
    if (topic.trim().length <= 28) return topic.trim();
    return fallback;
  }

  static String lectureBlurb(VirtualLectureScript script) {
    if (script.objectives.isNotEmpty) {
      return 'This lecture provides a rigorous foundation for ${script.topic}. '
          'By the end you will: ${script.objectives.take(3).join('; ')}.';
    }
    return 'This lecture provides a rigorous foundation for understanding ${script.topic} '
        'in ${script.course}. You will learn the history, theory, visuals, real-world uses, '
        'practice problems, and homework — a full university class, not a chatbot summary.';
  }

  static List<String> prerequisites(String faculty) {
    return switch (faculty) {
      'mathematics' || 'physics' || 'engineering' => <String>[
          'High school algebra',
          'Basic coordinate systems',
          'Comfort with functions f(x)',
        ],
      'computer_science' => <String>[
          'Basic programming literacy',
          'Logical thinking',
          'High school math',
        ],
      'biology' || 'chemistry' || 'nursing' => <String>[
          'High school science',
          'Curiosity and careful reading',
          'Basic problem solving',
        ],
      'business' || 'accounting' || 'economics' || 'marketing' => <String>[
          'Basic numeracy',
          'Interest in real organizations',
          'Willingness to practice cases',
        ],
      _ => <String>[
          'Curiosity and focus',
          'Willingness to practice',
          'Openness to ask when confused',
        ],
    };
  }
}
