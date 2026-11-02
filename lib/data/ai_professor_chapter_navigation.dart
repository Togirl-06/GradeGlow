/// Sequential chapter navigation for any AI Professor course with ordered lessons/topics.
class AiProfessorChapterNavigation {
  const AiProfessorChapterNavigation({
    this.previousTitle,
    this.nextTitle,
    required this.chapterNumber,
    required this.totalChapters,
  });

  final String? previousTitle;
  final String? nextTitle;
  final int chapterNumber;
  final int totalChapters;

  static AiProfessorChapterNavigation fromTitles({
    required List<String> titles,
    required int index,
  }) {
    if (index < 0 || titles.isEmpty) {
      return const AiProfessorChapterNavigation(chapterNumber: 1, totalChapters: 1);
    }
    return AiProfessorChapterNavigation(
      previousTitle: index > 0 ? titles[index - 1] : null,
      nextTitle: index < titles.length - 1 ? titles[index + 1] : null,
      chapterNumber: index + 1,
      totalChapters: titles.length,
    );
  }

  String pathBanner(String courseTitle) {
    final StringBuffer buf = StringBuffer()
      ..writeln('**Course:** $courseTitle · **Chapter $chapterNumber of $totalChapters**');
    if (previousTitle != null) {
      buf.writeln('**Previous chapter:** Chapter ${chapterNumber - 1} — $previousTitle');
    }
    if (nextTitle != null) {
      buf.writeln('**Next chapter:** Chapter ${chapterNumber + 1} — $nextTitle');
    }
    buf.writeln(
      '\nRead chapters in order. Each chapter builds on the last — do not skip definitions or worked examples.',
    );
    return buf.toString().trim();
  }

  String bridgeSection(String currentTitle) {
    final StringBuffer buf = StringBuffer();
    if (previousTitle != null) {
      buf.writeln(
        '**From the previous chapter ($previousTitle):** '
        'Recall the definitions and rules you mastered there. '
        '**$currentTitle** extends that foundation — connect new terms to ones you already know.',
      );
    } else {
      buf.writeln(
        'This is the **first chapter** in the course sequence. '
        'Master every definition here before moving forward.',
      );
    }
    buf.writeln();
    if (nextTitle != null) {
      buf.writeln(
        '**Preparing for the next chapter ($nextTitle):** '
        'After the mastery checklist, you should be able to explain **$currentTitle** '
        'without notes. The next chapter assumes this fluency.',
      );
    } else {
      buf.writeln(
        'This is the **final chapter** in this course sequence. '
        'Use the summary and checklist as your exam review sheet.',
      );
    }
    return buf.toString().trim();
  }

  String continueFooter(String currentTitle, String courseTitle) {
    final StringBuffer buf = StringBuffer(
      'You have finished **Chapter: $currentTitle** in **$courseTitle**.\n\n',
    );
    if (nextTitle != null) {
      buf.writeln(
        '**Next chapter:** $nextTitle (Chapter ${chapterNumber + 1} of $totalChapters). '
        'Open AI Professor and read it in full before skipping ahead.',
      );
    } else {
      buf.writeln('**End of course sequence** — review all chapters, then complete practice exams.');
    }
    buf.writeln('\n**Study loop:** AI Professor → practice problems → application → review checklist');
    return buf.toString().trim();
  }

  static String wrapChapter({
    required String courseTitle,
    required String topicTitle,
    required String chapterBody,
    required AiProfessorChapterNavigation nav,
  }) {
    final StringBuffer buf = StringBuffer()
      ..writeln('## Reading Path')
      ..writeln()
      ..writeln(nav.pathBanner(courseTitle))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln(chapterBody.trim())
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## Continue Your Study')
      ..writeln()
      ..writeln(nav.continueFooter(topicTitle, courseTitle));
    return buf.toString();
  }
}
