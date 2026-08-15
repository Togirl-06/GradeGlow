import '../models/virtual_lecture.dart';
import '../vu_v2/data/vu_v2_topic_content.dart';
import '../vu_v2/data/vu_v2_topic_content_models.dart';

/// Builds AI Professor scripts from the real Virtual University curriculum
/// chapters ([VuV2TopicContent]) — not math Mad-libs.
abstract final class VirtualLectureCurriculumScript {
  static bool prefersCurriculumBank({
    required String faculty,
    required String courseId,
  }) {
    final String f = faculty.toLowerCase();
    final String c = courseId.toLowerCase();
    // Keep dedicated math banks for calculus/algebra/trig courses.
    if (f == 'mathematics' ||
        c.contains('calculus') ||
        c.contains('algebra') ||
        c.contains('trigon') ||
        c.contains('precalculus') ||
        c.contains('statistics') ||
        c.contains('linear_algebra') ||
        c.contains('differential_equation') ||
        c.contains('discrete_math') ||
        c.contains('numerical')) {
      return false;
    }
    if (f == 'biology' || f == 'chemistry') {
      // Degree catalogs already have specialty banks via Fallback categories.
      // Prefer curriculum chapter when course id is a health/world-style slug.
      return c.contains('nurs') || c.contains('health') || c.isEmpty;
    }
    return true;
  }

  static VirtualLectureScript build({
    required String lessonTitle,
    required String courseTitle,
    required String moduleTitle,
    required String courseId,
    required String lessonId,
    required LectureMode mode,
    required String faculty,
  }) {
    final String subjectId = _subjectId(faculty, courseId);
    final VuV2TopicPackage pack = VuV2TopicContent.forLesson(
      subjectId: subjectId,
      facultyTitle: _facultyTitle(faculty, subjectId),
      facultyEmoji: _emoji(subjectId),
      trackTitle: moduleTitle.isEmpty ? courseTitle : moduleTitle,
      courseTitle: courseTitle,
      topicTitle: lessonTitle,
    );

    final List<VuV2TextbookSection> sections = _pickSections(pack.sections, mode);
    final List<LectureSegment> segments = <LectureSegment>[];

    for (int i = 0; i < sections.length; i++) {
      final VuV2TextbookSection section = sections[i];
      segments.add(_sectionToSegment(section, lessonTitle, i));
    }

    // Curriculum checkpoint from topic quiz when available.
    if (pack.topicQuiz.isNotEmpty && mode != LectureMode.review) {
      final VuV2Mcq q = pack.topicQuiz.first;
      segments.add(
        LectureSegment(
          phase: LecturePhase.knowledgeCheck,
          professorSpeech:
              q.prompt,
          caption: 'Checkpoint — $lessonTitle',
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.text,
            title: 'Check — $lessonTitle',
            lines: <String>[q.prompt, ...q.choices.take(4)],
          ),
          durationSeconds: 100,
          knowledgeCheck: LectureKnowledgeCheck(
            prompt: q.prompt,
            kind: KnowledgeCheckKind.multipleChoice,
            options: q.choices,
            correctIndex: q.correctIndex.clamp(0, q.choices.length - 1),
            explanation: q.explanation,
          ),
        ),
      );
    }

    segments.add(
      LectureSegment(
        phase: LecturePhase.lessonSummary,
        professorSpeech:
            'So $lessonTitle comes down to this: you can define it, explain how it works, and apply it in $courseTitle. '
            'The mistakes we covered are the ones that lose points — watch for those on the next problem.',
        caption: 'Summary — $lessonTitle',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'You should now be able to',
          lines: <String>[
            'Define $lessonTitle accurately',
            'Explain the mechanism / reasoning',
            'Apply it in a $courseTitle scenario',
          ],
        ),
        durationSeconds: 110,
      ),
    );

    final int minutes = switch (mode) {
      LectureMode.review => 18,
      LectureMode.comprehensive => 60,
      LectureMode.concept => 50,
      LectureMode.practice => 35,
      LectureMode.exam => 25,
      LectureMode.deepLearning => 75,
    };

    final List<LectureSegment> fitted = mode.isFullLecture
        ? segments
        : segments.take(mode.targetSegments.clamp(6, segments.length)).toList();

    String clipNote(String body, {int max = 220}) {
      final String t = body.replaceAll('**', '').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (t.length <= max) return t;
      return '${t.substring(0, max - 1).trim()}…';
    }

    String? sectionBody(String needle) {
      for (final VuV2TextbookSection s in pack.sections) {
        if (s.title.toLowerCase().contains(needle)) return s.body;
      }
      return null;
    }

    final String? defBody = sectionBody('definition') ?? sectionBody('precise');
    final String? methodBody = sectionBody('method') ?? sectionBody('rule');
    final String? mistakeBody =
        sectionBody('mistake') ?? sectionBody('misconception');

    return VirtualLectureScript(
      mode: mode,
      topic: lessonTitle,
      course: courseTitle,
      module: moduleTitle,
      objectives: <String>[
        'Define $lessonTitle for $courseTitle with operational meaning',
        'Explain the mechanism / reasoning in depth — not a slogan',
        'Apply a step-by-step method to a fresh case',
        'Catch and correct the most common mistakes',
      ],
      estimatedMinutes: minutes,
      segments: fitted,
      notes: LectureSmartNotes(
        definitions: <String>[
          if (defBody != null) clipNote(defBody, max: 280),
          if (defBody == null)
            '$lessonTitle — core competency in $courseTitle ($moduleTitle).',
        ],
        formulas: <String>[
          if (methodBody != null) clipNote(methodBody, max: 200),
          if (methodBody == null)
            (subjectId == 'nursing' || subjectId == 'medicine'
                ? 'Assess → Prioritize → Act → Reassess → Document'
                : 'Define → Explain → Apply → Verify'),
        ],
        examples: pack.sections
            .where((VuV2TextbookSection s) =>
                s.title.toLowerCase().contains('example') ||
                s.title.toLowerCase().contains('worked'))
            .map((VuV2TextbookSection s) => clipNote(s.body, max: 160))
            .take(3)
            .toList(),
        commonMistakes: <String>[
          if (mistakeBody != null) clipNote(mistakeBody, max: 200),
          'Skipping assumptions / assessment before the answer',
          'Memorizing the title without a worked method',
        ],
        tips: <String>[
          'Stay inside $courseTitle language',
          'Teach-back: explain $lessonTitle aloud for 2 minutes',
          'One-page sheet: definition · steps · example · mistakes',
        ],
      ),
      summary: LectureSummary(
        learned: <String>[
          '$lessonTitle definitions',
          'Deep mechanism / reasoning',
          'Worked method + example',
          'Mistake repairs',
        ],
        keyFormulas: const <String>[],
        applications: <String>['$courseTitle practice scenarios'],
        reviewTopics: <String>[moduleTitle, lessonTitle],
        homeworkRecommendation:
            'Homework: re-teach $lessonTitle aloud (2 min), write a one-page sheet, '
            'complete the topic quiz (≥70%), then attempt one fresh case using only '
            '$courseTitle standards.',
      ),
    );
  }

  static List<VuV2TextbookSection> _pickSections(
    List<VuV2TextbookSection> all,
    LectureMode mode,
  ) {
    if (all.isEmpty) return all;
    if (mode == LectureMode.review) {
      return all
          .where((VuV2TextbookSection s) {
            final String t = s.title.toLowerCase();
            return t.contains('why') ||
                t.contains('definition') ||
                t.contains('deep') ||
                t.contains('method') ||
                t.contains('mistake') ||
                t.contains('outcome');
          })
          .take(6)
          .toList();
    }
    if (mode == LectureMode.exam || mode == LectureMode.practice) {
      return all
          .where((VuV2TextbookSection s) {
            final String t = s.title.toLowerCase();
            return t.contains('definition') ||
                t.contains('deep') ||
                t.contains('method') ||
                t.contains('example') ||
                t.contains('mistake') ||
                t.contains('application');
          })
          .take(8)
          .toList();
    }
    // Full lecture: teach almost the whole chapter — not a 12-slide summary.
    final List<VuV2TextbookSection> preferred = all.where((VuV2TextbookSection s) {
      final String t = s.title.toLowerCase();
      return !t.contains('prerequisites') &&
          !t.contains('study guide') &&
          !t.contains('self-check') &&
          !t.contains('mastery checklist') &&
          !t.contains('chapter overview') &&
          !t.contains('learning outcome') &&
          !t.contains('why this topic matters');
    }).toList();
    return preferred.take(20).toList();
  }

  static LectureSegment _sectionToSegment(
    VuV2TextbookSection section,
    String topic,
    int index,
  ) {
    final List<String> teachingChunks = _teachingChunks(section.body);
    final List<String> boardLines = _slideNotes(section, topic);
    final LecturePhase phase = _phaseFor(section.title, index);

    // Real teaching: each beat speaks a full chunk (definition → how → example),
    // while the board reveals the matching teaching points.
    if (teachingChunks.length >= 2) {
      final List<LectureInteractiveBeat> beats = <LectureInteractiveBeat>[];
      for (int i = 0; i < teachingChunks.length; i++) {
        final String chunk = teachingChunks[i];
        final String focusLine = boardLines.isEmpty
            ? section.title
            : boardLines[
                ((i / teachingChunks.length) * boardLines.length)
                    .floor()
                    .clamp(0, boardLines.length - 1)];
        beats.add(
          LectureInteractiveBeat(
            professorSpeech: chunk.trim(),
            caption: '${section.title} · ${i + 1}/${teachingChunks.length}',
            durationSeconds: _secondsForSpeech(chunk),
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: section.title,
              // One teaching point per spoken beat — keeps slide and voice locked.
              lines: <String>[focusLine],
            ),
          ),
        );
      }
      return LectureSegment(
        phase: phase,
        professorSpeech: beats.first.professorSpeech,
        caption: section.title,
        whiteboard: beats.first.whiteboard,
        durationSeconds: beats.fold<int>(
          0,
          (int n, LectureInteractiveBeat b) => n + b.durationSeconds,
        ),
        beats: beats,
      );
    }

    final String speech = _teachSectionSpeech(section, topic);
    return LectureSegment(
      phase: phase,
      professorSpeech: speech,
      caption: section.title,
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.text,
        title: section.title,
        lines: boardLines.isEmpty ? <String>[section.title] : boardLines,
      ),
      durationSeconds: _secondsForSpeech(speech),
    );
  }

  /// Split a textbook section into spoken teaching chunks (not summary slogans).
  static List<String> _teachingChunks(String body) {
    final String plain = body
        .replaceAll('**', '')
        .replaceAll(RegExp(r'```[\s\S]*?```'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (plain.isEmpty) return const <String>[];

    final List<String> sentences = plain
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((String s) => s.trim())
        .where((String s) => s.length > 20 && !_isBreadcrumbLine(s))
        .toList();
    if (sentences.isEmpty) return <String>[plain];

    // Target ~3–5 sentences per beat so TTS feels like a real mini-lesson.
    const int perBeat = 4;
    final List<String> chunks = <String>[];
    for (int i = 0; i < sentences.length; i += perBeat) {
      final int end = (i + perBeat).clamp(0, sentences.length);
      chunks.add(sentences.sublist(i, end).join(' '));
    }
    // Cap beats so one section does not monopolize the hour, but keep depth.
    if (chunks.length > 6) {
      return <String>[
        ...chunks.take(5),
        chunks.sublist(5).join(' '),
      ];
    }
    return chunks;
  }

  static String _teachSectionSpeech(VuV2TextbookSection section, String topic) {
    final List<String> chunks = _teachingChunks(section.body);
    final String body = chunks.isEmpty
        ? section.body.replaceAll('**', '').trim()
        : chunks.join(' ');
    final String spoken = body.length <= 2200
        ? body
        : '${body.substring(0, 2100).trim()}…';
    return spoken;
  }

  static int _secondsForSpeech(String speech) {
    final int words = speech
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .length;
    // ~130 wpm teaching pace + board time.
    return (words * 60 / 130).ceil().clamp(55, 240);
  }

  static List<String> _slideNotes(VuV2TextbookSection section, String topic) {
    final String titleKey = section.title.toLowerCase();
    final List<String> bullets = _extractBullets(section.body);
    if (bullets.length >= 2) {
      return bullets.take(8).map(_boardClip).toList();
    }

    // Professor-style boards by section — teaching points, not slogans.
    if (titleKey.contains('overview') || titleKey.contains('chapter')) {
      return <String>[
        'Today we master: $topic',
        '1) Precise definition',
        '2) How / mechanism',
        '3) Step-by-step method',
        '4) Worked example + common mistakes',
      ];
    }
    if (titleKey.contains('learning outcome') || titleKey.contains('outcome')) {
      return <String>[
        'DEFINE $topic without notes',
        'EXPLAIN the mechanism in order',
        'APPLY it to a fresh $topic case',
        'CATCH 3 common mistakes',
        'TEACH it in a 60-second hand-off',
      ];
    }
    if (titleKey.contains('why')) {
      return <String>[
        'Why $topic matters in this course',
        'What fails if you skip it',
        'What “good” looks like in practice',
        'Where you will use it on exam / shift / job',
      ];
    }
    if (titleKey.contains('definition') ||
        titleKey.contains('precise') ||
        titleKey.contains('concept')) {
      return _definitionSlides(topic, section.body);
    }
    if (titleKey.contains('step-by-step') ||
        titleKey.contains('method') ||
        titleKey.contains('how to') ||
        titleKey.contains('principle') ||
        titleKey.contains('formula') ||
        titleKey.contains('rule')) {
      return _howSlides(topic, section.body);
    }
    if (titleKey.contains('worked example') || titleKey.contains('example')) {
      return _exampleSlides(topic, section.body);
    }
    if (titleKey.contains('mistake') || titleKey.contains('misconception')) {
      final List<String> fromBody = _extractBullets(section.body);
      if (fromBody.length >= 2) {
        return fromBody.take(6).map(_boardClip).toList();
      }
      return <String>[
        'Mistake students make with $topic',
        'Why that mistake fails',
        'Correct move instead',
        'Quick self-check before you leave',
      ];
    }
    if (titleKey.contains('deep') ||
        titleKey.contains('mechanism') ||
        titleKey.contains('key principle')) {
      return <String>[
        'Mechanism of $topic — what actually happens',
        'Inputs / evidence you collect',
        'How those cues change the next action',
        'What to verify before you conclude',
      ];
    }
    if (titleKey.contains('diagram') ||
        titleKey.contains('model') ||
        titleKey.contains('illustration')) {
      return <String>[
        'Mental model for $topic',
        'Inputs → process → check → output',
        'Where beginners lose the thread',
        'Redraw this from memory tonight',
      ];
    }

    final List<String> sentences = _shortSentences(section.body);
    if (sentences.length >= 2) return sentences.take(6).toList();
    return <String>[
      section.title,
      'Definition of $topic',
      'How it works',
      'Example you can reuse',
      'Mistake to avoid',
    ];
  }

  static List<String> _extractBullets(String body) {
    final List<String> raw = <String>[];
    for (final String line in body.split('\n')) {
      final String t = line.trim();
      if (t.isEmpty) continue;
      if (t.startsWith('•') ||
          t.startsWith('-') ||
          t.startsWith('*') ||
          RegExp(r'^\d+\.').hasMatch(t) ||
          RegExp(r'^\*\*Step', caseSensitive: false).hasMatch(t) ||
          RegExp(r'^Step\s+[A-Z0-9]', caseSensitive: false).hasMatch(t)) {
        raw.add(
          t
              .replaceFirst(RegExp(r'^[•\-\*]\s*'), '')
              .replaceFirst(RegExp(r'^\d+\.\s*'), '')
              .replaceFirst(RegExp(r'^\*\*'), '')
              .replaceAll('**', '')
              .trim(),
        );
      }
    }
    return raw.where((String s) => s.length > 8 && !_isBreadcrumbLine(s)).toList();
  }

  static bool _isBreadcrumbLine(String s) {
    final String t = s.toLowerCase();
    return t.contains('virtual university') ||
        (t.contains('·') && t.split('·').length >= 3) ||
        t.startsWith('this is a full university');
  }

  static List<String> _shortSentences(String body) {
    final String plain = body
        .replaceAll('**', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return plain
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((String s) => s.trim())
        .where((String s) => s.length > 24 && s.length < 160 && !_isBreadcrumbLine(s))
        .map(_boardClip)
        .toList();
  }

  static List<String> _definitionSlides(String topic, String body) {
    final String t = topic.toLowerCase();
    if (t.contains('prenatal')) {
      return <String>[
        'DEFINE: scheduled visits to track mom + fetus safely',
        'Includes: history, vitals, fundal height, FHR, labs, teaching',
        'Not: “just a weigh-in” with no assessment plan',
        'EXAMPLE: 28-week visit — BP, urine, kick counts, warning signs',
      ];
    }
    if (t.contains('heart failure') || t.contains('cardiac')) {
      return <String>[
        'DEFINE: heart cannot meet body demand',
        'Left failure → lung congestion; right → body edema',
        'HOW: ABCs/O2 → fluid status → meds → reassess',
        'EXAMPLE: new crackles + SpO2 88% → oxygen first',
      ];
    }
    final List<String> fromBody = _extractBullets(body);
    if (fromBody.length >= 3) return fromBody.take(6).map(_boardClip).toList();
    final List<String> sentences = _shortSentences(body);
    if (sentences.length >= 2) return sentences.take(5).toList();
    return <String>[
      'DEFINE: what $topic means without circular jargon',
      'What it includes (must-have pieces)',
      'What it is NOT (common lookalike)',
      'Operational test: can you use it to decide?',
      'EXAMPLE: one real case where $topic changes the next action',
    ];
  }

  static List<String> _howSlides(String topic, String body) {
    final List<String> steps = _extractBullets(body);
    if (steps.length >= 3) {
      return <String>[
        'HOW to apply $topic',
        ...steps.take(6).map(_boardClip),
      ].take(7).toList();
    }
    final String t = topic.toLowerCase();
    if (t.contains('prenatal')) {
      return <String>[
        'HOW: open with chief concerns + dating',
        'HOW: focused exam (BP, weight, urine, FHR, fundal height)',
        'HOW: labs/screenings for this trimester',
        'HOW: teach warning signs + next visit plan',
        'EXAMPLE: elevated BP → recheck, symptoms, escalate per protocol',
      ];
    }
    final List<String> sentences = _shortSentences(body);
    if (sentences.length >= 3) return sentences.take(6).toList();
    return <String>[
      'HOW: restate the problem in one sentence',
      'HOW: collect the minimum focused assessment / givens',
      'HOW: choose the first correct move + why',
      'HOW: check constraints and assumptions',
      'HOW: reassess a measurable endpoint',
      'EXAMPLE: write the one-line hand-off / answer',
    ];
  }

  static List<String> _exampleSlides(String topic, String body) {
    final List<String> steps = _extractBullets(body);
    final String t = topic.toLowerCase();
    if (t.contains('prenatal')) {
      return <String>[
        'EXAMPLE case: 24y, G1P0, 22 weeks, first visit today',
        'HOW: confirm dating, baseline BP/weight, urine, FHR',
        'HOW: order trimester-appropriate labs / screens',
        'Teach: kick counts later, bleeding/HA/vision = call now',
        'Your turn: change BP to 148/96 — what do you do next?',
      ];
    }
    if (steps.length >= 3) {
      return <String>[
        'EXAMPLE: $topic on a real case',
        ...steps.take(5).map(_boardClip),
      ].take(7).toList();
    }
    final List<String> sentences = _shortSentences(body);
    if (sentences.length >= 2) {
      return <String>[
        'EXAMPLE walkthrough for $topic',
        ...sentences.take(5),
      ].take(6).toList();
    }
    return <String>[
      'EXAMPLE setup for $topic',
      'Step 1 — frame the problem',
      'Step 2 — apply the method',
      'Step 3 — verify the answer',
      'Your turn: change one cue and redo the action',
    ];
  }

  static String _boardClip(String s) {
    final String t = s.trim();
    if (t.length <= 140) return t;
    return '${t.substring(0, 137).trim()}…';
  }

  static LecturePhase _phaseFor(String title, int index) {
    final String t = title.toLowerCase();
    if (index == 0 || t.contains('overview') || t.contains('outcome')) {
      return LecturePhase.introduction;
    }
    if (t.contains('why')) return LecturePhase.conceptExplanation;
    if (t.contains('definition')) return LecturePhase.conceptExplanation;
    if (t.contains('deep') || t.contains('explain')) {
      return LecturePhase.conceptExplanation;
    }
    if (t.contains('method') || t.contains('sequence') || t.contains('framework')) {
      return LecturePhase.conceptExplanation;
    }
    if (t.contains('example') || t.contains('worked') || t.contains('case')) {
      return LecturePhase.guidedExamples;
    }
    if (t.contains('mistake') || t.contains('pitfall')) {
      return LecturePhase.conceptExplanation;
    }
    if (t.contains('application') || t.contains('practice')) {
      return LecturePhase.studentParticipation;
    }
    if (t.contains('advanced') || t.contains('connect')) {
      return LecturePhase.conceptExplanation;
    }
    return LecturePhase.conceptExplanation;
  }

  static String _subjectId(String faculty, String courseId) {
    final String f = faculty.toLowerCase().trim();
    if (f.isNotEmpty && f != 'general') return f;
    final String c = courseId.toLowerCase();
    if (c.startsWith('nursing')) return 'nursing';
    if (c.startsWith('medicine')) return 'medicine';
    if (c.startsWith('psychology')) return 'psychology';
    if (c.startsWith('law')) return 'law';
    if (c.startsWith('business') || c.contains('financ') || c.contains('market')) {
      return 'business';
    }
    if (c.contains('computer') || c.contains('software')) return 'computer_science';
    if (c.contains('engineer')) return 'engineering';
    if (c.contains('english')) return 'english';
    if (c.contains('biology')) return 'biology';
    if (c.contains('chemistry')) return 'chemistry';
    if (c.contains('physics')) return 'physics';
    if (c.contains('math')) return 'mathematics';
    return f.isEmpty ? 'general' : f;
  }

  static String _facultyTitle(String faculty, String subjectId) {
    return switch (subjectId) {
      'nursing' => 'Nursing',
      'medicine' => 'Medicine',
      'psychology' => 'Psychology',
      'law' => 'Law',
      'business' => 'Business',
      'computer_science' => 'Computer Science',
      'engineering' => 'Engineering',
      'biology' => 'Biology',
      'chemistry' => 'Chemistry',
      'physics' => 'Physics',
      'mathematics' => 'Mathematics',
      'english' => 'English',
      _ => faculty.isEmpty ? 'Virtual University' : faculty,
    };
  }

  static String _emoji(String subjectId) {
    return switch (subjectId) {
      'nursing' => '🩺',
      'medicine' => '🏥',
      'psychology' => '🧠',
      'law' => '⚖️',
      'business' => '📈',
      'computer_science' => '💻',
      'engineering' => '🛠️',
      'biology' => '🧬',
      'chemistry' => '⚗️',
      'physics' => '⚛️',
      'mathematics' => '📐',
      _ => '📚',
    };
  }
}
