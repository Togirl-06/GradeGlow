import '../models/virtual_lecture.dart';

/// Builds usable slide notes when AI omits them (offline / incomplete scripts).
abstract final class LectureSlideNotesSynthesizer {
  static LectureSlideNotes fromSegment({
    required LectureSegment segment,
    LectureSmartNotes? lessonNotes,
  }) {
    final LectureSlideNotes? existing = segment.slideNotes;
    if (existing != null && !existing.isEmpty) {
      return _enrich(existing, segment, lessonNotes);
    }

    final LectureWhiteboardFrame board = segment.whiteboard;
    final List<String> concepts = <String>[
      ...board.keyPoints.where((String e) => e.trim().isNotEmpty),
      ...board.processSteps.where((String e) => e.trim().isNotEmpty),
      ...board.lines.where((String e) => e.trim().isNotEmpty).take(6),
    ];
    final List<String> unique = <String>[];
    for (final String c in concepts) {
      if (!unique.contains(c)) unique.add(c);
    }

    final String title = board.title.trim().isNotEmpty
        ? board.title.trim()
        : segment.caption.trim();
    final String speech = segment.professorSpeech.trim();

    return LectureSlideNotes(
      understand: board.subtitle?.trim().isNotEmpty == true
          ? board.subtitle!.trim()
          : (speech.isNotEmpty
              ? _firstSentences(speech, 2)
              : 'Understand the core idea of $title.'),
      keyConcepts: unique.take(8).toList(),
      professorInsight: speech.isNotEmpty
          ? _firstSentences(speech, 1)
          : 'The slide shows the structure; the lecture explains why it matters.',
      remember: unique.isNotEmpty
          ? unique.first
          : 'Focus on the main idea of $title.',
      examTip: lessonNotes?.tips.isNotEmpty == true
          ? lessonNotes!.tips.first
          : 'Be ready to explain $title in your own words on an exam.',
      studyNotes: unique.isEmpty
          ? title
          : unique.map((String e) => '• $e').join('\n'),
      questions: <String>[
        if (segment.knowledgeCheck != null) segment.knowledgeCheck!.prompt,
        'How would you explain $title to a classmate?',
        if (unique.isNotEmpty) 'Why does "${unique.first}" matter for $title?',
      ],
      vocabulary: <String>[
        ...unique.where((String e) => e.split(' ').length <= 4).take(4),
        ...?lessonNotes?.definitions.take(3),
      ],
    );
  }

  static LectureSlideNotes _enrich(
    LectureSlideNotes notes,
    LectureSegment segment,
    LectureSmartNotes? lessonNotes,
  ) {
    final LectureWhiteboardFrame board = segment.whiteboard;
    final List<String> fallbackConcepts = <String>[
      ...board.keyPoints,
      ...board.processSteps,
      ...board.lines.take(4),
    ].where((String e) => e.trim().isNotEmpty).toList();

    return LectureSlideNotes(
      understand: notes.understand.trim().isNotEmpty
          ? notes.understand
          : (board.subtitle ?? _firstSentences(segment.professorSpeech, 2)),
      keyConcepts: notes.keyConcepts.isNotEmpty ? notes.keyConcepts : fallbackConcepts,
      professorInsight: notes.professorInsight.trim().isNotEmpty
          ? notes.professorInsight
          : _firstSentences(segment.professorSpeech, 1),
      remember: notes.remember.trim().isNotEmpty
          ? notes.remember
          : (notes.keyConcepts.isNotEmpty
              ? notes.keyConcepts.first
              : fallbackConcepts.isNotEmpty
                  ? fallbackConcepts.first
                  : board.title),
      examTip: notes.examTip.trim().isNotEmpty
          ? notes.examTip
          : (lessonNotes?.tips.isNotEmpty == true
              ? lessonNotes!.tips.first
              : 'Expect an exam item on ${board.title}.'),
      studyNotes: notes.studyNotes.trim().isNotEmpty
          ? notes.studyNotes
          : (notes.keyConcepts.isNotEmpty
              ? notes.keyConcepts.map((String e) => '• $e').join('\n')
              : board.title),
      questions: notes.questions.isNotEmpty
          ? notes.questions
          : <String>[
              if (segment.knowledgeCheck != null) segment.knowledgeCheck!.prompt,
              'Explain ${board.title} without looking at the slide.',
            ],
      vocabulary: notes.vocabulary.isNotEmpty
          ? notes.vocabulary
          : <String>[
              ...notes.keyConcepts.where((String e) => e.split(' ').length <= 3).take(4),
              ...?lessonNotes?.definitions.take(3),
            ],
    );
  }

  static String _firstSentences(String text, int count) {
    final List<String> parts = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((String e) => e.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return text;
    return parts.take(count).join(' ').trim();
  }
}
