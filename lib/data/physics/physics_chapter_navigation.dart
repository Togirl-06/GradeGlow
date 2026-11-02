import '../../models/physics/physics_program.dart';

/// Previous / next topic within a course for sequential textbook reading.
class PhysicsChapterNav {
  const PhysicsChapterNav({
    this.previous,
    this.next,
    required this.chapterNumber,
    required this.totalChapters,
  });

  final PhysicsTopic? previous;
  final PhysicsTopic? next;
  final int chapterNumber;
  final int totalChapters;

  static PhysicsChapterNav forTopic({
    required PhysicsCourse course,
    required PhysicsTopic topic,
  }) {
    final List<PhysicsTopic> topics = course.topics;
    final int idx = topics.indexWhere((PhysicsTopic t) => t.id == topic.id);
    if (idx < 0) {
      return PhysicsChapterNav(chapterNumber: 1, totalChapters: topics.length);
    }
    return PhysicsChapterNav(
      previous: idx > 0 ? topics[idx - 1] : null,
      next: idx < topics.length - 1 ? topics[idx + 1] : null,
      chapterNumber: idx + 1,
      totalChapters: topics.length,
    );
  }

  String pathBanner(String courseTitle) {
    final StringBuffer buf = StringBuffer()
      ..writeln('**Course:** $courseTitle · **Chapter $chapterNumber of $totalChapters**');
    if (previous != null) {
      buf.writeln('**Previous chapter:** Chapter ${chapterNumber - 1} — ${previous!.title}');
    }
    if (next != null) {
      buf.writeln('**Next chapter:** Chapter ${chapterNumber + 1} — ${next!.title}');
    }
    buf.writeln(
      '\nRead chapters in order. Each chapter builds on the last — do not skip definitions or derivations.',
    );
    return buf.toString().trim();
  }

  String bridgeSection(String currentTitle) {
    final StringBuffer buf = StringBuffer();
    if (previous != null) {
      buf.writeln(
        '**From the previous chapter (${previous!.title}):** '
        'Recall the definitions and relations you mastered there. '
        '**$currentTitle** extends that foundation — connect new symbols to ones you already know.',
      );
    } else {
      buf.writeln(
        'This is the **first chapter** in the course sequence. '
        'Master every definition here before moving forward.',
      );
    }
    buf.writeln();
    if (next != null) {
      buf.writeln(
        '**Preparing for the next chapter (${next!.title}):** '
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

  /// Prepends reading path and appends continue-study footer to any chapter body.
  static String wrapChapter({
    required PhysicsCourse course,
    required PhysicsTopic topic,
    required String chapterBody,
  }) {
    final PhysicsChapterNav nav = forTopic(course: course, topic: topic);
    final StringBuffer buf = StringBuffer()
      ..writeln('## Reading Path')
      ..writeln()
      ..writeln(nav.pathBanner(course.title))
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln(chapterBody.trim())
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## Continue Your Study')
      ..writeln()
      ..writeln(nav._continueFooter(topic.title, course.title));
    return buf.toString();
  }

  String _continueFooter(String title, String courseTitle) {
    final StringBuffer buf = StringBuffer(
      'You have finished **Chapter: $title** in **$courseTitle**.\n\n',
    );
    if (next != null) {
      buf.writeln(
        '**Next chapter:** ${next!.title} (Chapter ${chapterNumber + 1} of $totalChapters). '
        'Open AI Professor and read it in full before skipping ahead.',
      );
    } else {
      buf.writeln('**End of course sequence** — review all chapters, then complete quizzes.');
    }
    buf.writeln('\n**Study loop:** AI Professor → Formula Notebook → 3D Simulation → Experiment Report → Quiz');
    return buf.toString().trim();
  }
}
