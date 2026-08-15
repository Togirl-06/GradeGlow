import '../models/virtual_lecture.dart';
import 'virtual_lecture_topic_profile.dart';

/// Guarantees every lecture — any course, any topic — covers the full university checklist.
///
/// Missing beats are injected after generation (AI or offline) so students never get a
/// ChatGPT-style short answer.
abstract final class VirtualLectureCompleteness {
  /// Required teaching beats for every GradeGlow lecture.
  static const List<String> checklist = <String>[
    'Introduce the topic and explain why it matters',
    'Explain the history behind the concept',
    'Teach the theory in depth',
    'Draw diagrams and visual explanations',
    'Show formulas and explain every symbol',
    'Give three or more real-world examples',
    'Ask the student questions throughout the lesson',
    'Detect confusion and reteach concepts differently',
    'Compare the concept to previous lessons',
    'Generate exercises with increasing difficulty',
    'Give homework',
    'Recommend additional reading',
  ];

  static VirtualLectureScript ensure({
    required VirtualLectureScript script,
    String faculty = 'general',
    LectureMode? mode,
    VirtualLectureTopicProfile? profile,
    String courseId = '',
    String lessonId = '',
  }) {
    final String topic = script.topic;
    final String course = script.course;
    final String module = script.module;
    final VirtualLectureTopicProfile resolved = profile ??
        VirtualLectureTopicProfile.resolve(
          topic: topic,
          course: course,
          courseId: courseId,
          module: module,
          lessonId: lessonId,
        );
    final String blob = _speechBlob(script);
    final LectureMode resolvedMode = mode ?? script.mode;
    final bool fullHour = resolvedMode.isFullLecture;

    final List<LectureSegment> out = List<LectureSegment>.from(script.segments);
    if (out.isEmpty) {
      out.addAll(_fullScaffold(topic: topic, course: course, module: module, profile: resolved));
    } else {
      final bool hasWhy = _needs(
        blob,
        <String>['why it matters', 'why this matters', 'matters because', 'important because', 'why we study'],
      );
      final bool weakIntro = out.isNotEmpty &&
          out.first.phase == LecturePhase.introduction &&
          out.first.professorSpeech.trim().split(RegExp(r'\s+')).length < 40;
      if (!hasWhy || !_hasPhase(out, LecturePhase.introduction) || weakIntro) {
        _insertAfterIntro(out, _introWhy(topic, course));
      }
      _ensureSomewhere(
        out,
        satisfied: _needs(blob, <String>['history', 'origin', 'developed', 'invented', 'centuries', 'histor']),
        segment: _history(topic, course),
        afterPhase: LecturePhase.objectives,
      );
      _ensureSomewhere(
        out,
        satisfied: _needs(blob, <String>['theory', 'definition', 'formally', 'precisely', 'concept']),
        segment: _deepTheory(topic, profile: resolved),
        afterPhase: LecturePhase.conceptExplanation,
      );
      _ensureSomewhere(
        out,
        satisfied: _hasVisual(out) ||
            _needs(blob, <String>['diagram', 'graph', 'visual', 'sketch', 'figure', 'board', 'number line']),
        segment: _visual(topic, profile: resolved),
        afterPhase: LecturePhase.visualDemonstration,
        requirePhase: LecturePhase.visualDemonstration,
      );
      _ensureSomewhere(
        out,
        satisfied: _needs(blob, <String>['symbol', 'stands for', 'equation', 'formula', 'where a', 'where b', 'definition']),
        segment: _formulas(topic, profile: resolved),
        afterPhase: LecturePhase.conceptExplanation,
      );
      _ensureSomewhere(
        out,
        satisfied: _countMatches(blob, <String>['example', 'for instance', 'real world', 'real-world', 'application']) >= 3,
        segment: _threeExamples(topic, profile: resolved),
        afterPhase: LecturePhase.conceptExplanation,
      );
      _ensureSomewhere(
        out,
        satisfied: _hasQuestions(out),
        segment: _midQuestion(topic, profile: resolved),
        afterPhase: LecturePhase.knowledgeCheck,
        requirePhase: LecturePhase.knowledgeCheck,
      );
      _ensureSomewhere(
        out,
        satisfied: _needs(blob, <String>['previous lesson', 'earlier lesson', 'last topic', 'builds on', 'connects to', 'compared to', 'unlike']),
        segment: _comparePrevious(topic, course, module),
        afterPhase: LecturePhase.conceptExplanation,
      );
      _ensureSomewhere(
        out,
        satisfied: _needs(blob, <String>['easy', 'medium', 'hard', 'increasing', 'practice problem', 'exercise']) ||
            _hasPhase(out, LecturePhase.practiceProblems) ||
            _hasPhase(out, LecturePhase.guidedExamples),
        segment: _exercisesRamp(topic, profile: resolved),
        afterPhase: LecturePhase.practiceProblems,
        requirePhase: LecturePhase.practiceProblems,
      );
      _ensureSomewhere(
        out,
        satisfied: _hasPhase(out, LecturePhase.homeworkRecommendation) ||
            _needs(blob, <String>['homework', 'assignment', 'tonight', 'before next']),
        segment: _homework(topic),
        afterPhase: LecturePhase.homeworkRecommendation,
        requirePhase: LecturePhase.homeworkRecommendation,
      );
      _ensureSomewhere(
        out,
        satisfied: _needs(blob, <String>['reading', 'read ', 'textbook', 'chapter', 'article', 'further study']),
        segment: _additionalReading(topic, course),
        afterPhase: LecturePhase.homeworkRecommendation,
      );
      _ensureSomewhere(
        out,
        satisfied: _needs(blob, <String>['confused', 'reteach', 'different way', 'another analogy', 'raise hand']),
        segment: _confusionCue(topic),
        afterPhase: LecturePhase.studentParticipation,
      );
    }

    // Full lectures must run about an hour or longer (authored board time).
    if (fullHour) {
      _padToHourLecture(out, topic: topic, course: course, module: module, profile: resolved);
    }

    final LectureSummary summary = _ensureSummary(script.summary, topic, course);
    final int authoredMinutes = (_authoredSeconds(out) / 60).ceil();
    final int floorMinutes = fullHour
        ? 60
        : (resolvedMode == LectureMode.practice
            ? 30
            : resolvedMode == LectureMode.exam
                ? 20
                : 15);
    final int minutes = <int>[
      script.estimatedMinutes,
      authoredMinutes,
      floorMinutes,
    ].reduce((int a, int b) => a > b ? a : b);

    return script.copyWith(
      segments: out,
      summary: summary,
      estimatedMinutes: minutes,
      mode: resolvedMode,
      objectives: script.objectives.isEmpty ? resolved.objectives : script.objectives,
    );
  }

  /// Target authored runtime for a full university lecture (≥ 1 hour).
  static const int minFullLectureSeconds = 60 * 60;

  static int _authoredSeconds(List<LectureSegment> segs) {
    int total = 0;
    for (final LectureSegment s in segs) {
      total += s.durationSeconds;
      for (final LectureInteractiveBeat b in s.beats) {
        total += b.durationSeconds;
      }
    }
    return total;
  }

  static void _padToHourLecture(
    List<LectureSegment> out, {
    required String topic,
    required String course,
    required String module,
    required VirtualLectureTopicProfile profile,
  }) {
    int guard = 0;
    while (_authoredSeconds(out) < minFullLectureSeconds && guard < 48) {
      guard++;
      final LectureSegment pack = _hourExpansion(
        topic: topic,
        course: course,
        module: module,
        profile: profile,
        index: guard,
      );
      final int hwIdx = out.lastIndexWhere(
        (LectureSegment s) => s.phase == LecturePhase.homeworkRecommendation,
      );
      final int at = hwIdx >= 0 ? hwIdx : out.length;
      out.insert(at.clamp(0, out.length), pack);
    }

    final int current = _authoredSeconds(out);
    if (current > 0 && current < minFullLectureSeconds) {
      final double factor = minFullLectureSeconds / current;
      for (int i = 0; i < out.length; i++) {
        final LectureSegment s = out[i];
        final int scaled = (s.durationSeconds * factor).round().clamp(90, 420);
        out[i] = s.copyWith(durationSeconds: scaled);
      }
    }
  }

  static LectureSegment _hourExpansion({
    required String topic,
    required String course,
    required String module,
    required VirtualLectureTopicProfile profile,
    required int index,
  }) {
    final String equation = profile.mainEquation.trim().isEmpty
        ? 'Definition of $topic'
        : profile.mainEquation;
    final List<String> examples = profile.exampleIdeas.isEmpty
        ? profile.applicationLines
        : profile.exampleIdeas;
    final String exampleLine = examples.isEmpty
        ? 'Concrete use of $topic'
        : examples[(index - 1) % examples.length];

    switch (index % 8) {
      case 1:
        return LectureSegment(
          phase: LecturePhase.conceptExplanation,
          professorSpeech:
              '${profile.conceptSpeech} Let us go deeper still on $topic — unpack the definition, '
              'rebuild it formally, and stay locked on this topic only.',
          caption: 'Deep theory extension — $topic',
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.text,
            title: 'Theory — $topic',
            lines: profile.conceptLines.isEmpty
                ? <String>[
                    'Definition of $topic',
                    'Formal statement',
                    'What each part means',
                  ]
                : profile.conceptLines,
          ),
          durationSeconds: 160,
        );
      case 2:
        return LectureSegment(
          phase: LecturePhase.visualDemonstration,
          professorSpeech: profile.visualSpeech,
          caption: 'Diagram — $topic',
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.diagram,
            title: 'Visual — $topic',
            diagramQuery: '$topic educational diagram labeled',
            lines: <String>[
              'Real diagram for $topic',
              ...profile.conceptLines.take(3),
            ],
          ),
          durationSeconds: 140,
        );
      case 3:
        return LectureSegment(
          phase: LecturePhase.conceptExplanation,
          professorSpeech:
              'Symbol-by-symbol for $topic: $equation. '
              'I will name each symbol and what happens if we change it. Topic lock: only $topic.',
          caption: 'Every symbol — $topic',
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.equation,
            title: 'Symbols — $topic',
            equation: equation,
            lines: profile.formulas.take(3).toList(),
          ),
          durationSeconds: 150,
        );
      case 4:
        return LectureSegment(
          phase: LecturePhase.guidedExamples,
          professorSpeech:
              'Real-world example of $topic: $exampleLine. '
              'Ask which part of the $topic definition just appeared — not some other lesson.',
          caption: 'Example — $topic',
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.text,
            title: 'Example — $topic',
            lines: <String>[
              exampleLine,
              'Which idea from $topic applies?',
              'What decision does it unlock?',
            ],
          ),
          durationSeconds: 150,
        );
      case 5:
        return LectureSegment(
          phase: LecturePhase.knowledgeCheck,
          professorSpeech:
              'Quick check on $topic only. ${profile.checkPrompt}',
          caption: 'Question — $topic',
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.text,
            title: 'Check — $topic',
            lines: profile.conceptLines.take(3).toList(),
          ),
          durationSeconds: 100,
          knowledgeCheck: LectureKnowledgeCheck(
            prompt: profile.checkPrompt,
            kind: KnowledgeCheckKind.multipleChoice,
            options: profile.checkOptions,
            correctIndex: profile.checkCorrectIndex,
            explanation: profile.checkExplanation,
          ),
        );
      case 6:
        return LectureSegment(
          phase: LecturePhase.conceptExplanation,
          professorSpeech:
              'Compare $topic to earlier work in $module / $course. '
              'What stays familiar? What is new about $topic specifically?',
          caption: 'Compare — $topic',
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.table,
            title: 'Then vs $topic',
            lines: <String>[
              'Earlier lesson | Today ($topic)',
              'Shared idea | New idea in $topic',
              'Trap to avoid | Check',
            ],
          ),
          durationSeconds: 130,
        );
      case 7:
        return LectureSegment(
          phase: LecturePhase.practiceProblems,
          professorSpeech:
              'Practice ramp locked to $topic: easy identification, medium application, hard synthesis. '
              '${profile.methodSpeech}',
          caption: 'Practice — $topic',
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.workedProblem,
            title: 'Practice — $topic',
            problemStatement: 'Work an easy, medium, and hard problem about $topic only.',
            solutionSteps: <LectureProblemStep>[
              LectureProblemStep(
                title: 'Easy',
                work: profile.methodLines.isEmpty
                    ? 'Identify the core idea of $topic.'
                    : profile.methodLines.first,
                note: 'Warm-up',
              ),
              LectureProblemStep(
                title: 'Medium',
                work: 'Apply the method for $topic carefully.',
                note: 'Main skill',
              ),
              LectureProblemStep(
                title: 'Hard',
                work: 'Combine ideas or handle a realistic twist still about $topic.',
                note: 'Exam-level',
              ),
            ],
            lines: <String>['Easy', 'Medium', 'Hard', 'Topic: $topic'],
          ),
          durationSeconds: 180,
        );
      default:
        return LectureSegment(
          phase: LecturePhase.studentParticipation,
          professorSpeech:
              'If any stretch of this hour on $topic feels fuzzy, tap Confused. '
              'I will switch analogy and example — still teaching $topic, never a different lesson.',
          caption: 'Confusion check — $topic',
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.text,
            title: 'Office hours — $topic',
            lines: <String>['Tap Confused', 'New analogy for $topic', 'New example', 'Continue'],
          ),
          durationSeconds: 110,
        );
    }
  }

  // ── detection helpers ────────────────────────────────────────────────────

  static String _speechBlob(VirtualLectureScript s) {
    final StringBuffer b = StringBuffer(s.summary.homeworkRecommendation);
    for (final LectureSegment seg in s.segments) {
      b.write(' ');
      b.write(seg.professorSpeech);
      b.write(' ');
      b.write(seg.caption);
      for (final String line in seg.whiteboard.lines) {
        b.write(' ');
        b.write(line);
      }
      if (seg.whiteboard.equation != null) b.write(' ${seg.whiteboard.equation}');
      if (seg.knowledgeCheck != null) b.write(' ${seg.knowledgeCheck!.prompt}');
      for (final LectureInteractiveBeat beat in seg.beats) {
        b.write(' ${beat.professorSpeech}');
        if (beat.studentChoice != null) b.write(' ${beat.studentChoice!.prompt}');
      }
    }
    return b.toString().toLowerCase();
  }

  static bool _needs(String blob, List<String> keys) {
    for (final String k in keys) {
      if (blob.contains(k.toLowerCase())) return true;
    }
    return false;
  }

  static int _countMatches(String blob, List<String> keys) {
    int n = 0;
    for (final String k in keys) {
      final String key = k.toLowerCase();
      int from = 0;
      while (true) {
        final int i = blob.indexOf(key, from);
        if (i < 0) break;
        n++;
        from = i + key.length;
      }
    }
    return n;
  }

  static bool _hasPhase(List<LectureSegment> segs, LecturePhase phase) =>
      segs.any((LectureSegment s) => s.phase == phase);

  static bool _hasVisual(List<LectureSegment> segs) => segs.any(
        (LectureSegment s) =>
            s.phase == LecturePhase.visualDemonstration ||
            s.whiteboard.kind == WhiteboardKind.diagram ||
            s.whiteboard.kind == WhiteboardKind.graph ||
            s.whiteboard.kind == WhiteboardKind.geometry ||
            s.whiteboard.kind == WhiteboardKind.workedProblem,
      );

  static bool _hasQuestions(List<LectureSegment> segs) => segs.any(
        (LectureSegment s) =>
            s.knowledgeCheck != null ||
            s.beats.any((LectureInteractiveBeat b) => b.studentChoice != null) ||
            s.phase == LecturePhase.knowledgeCheck ||
            s.phase == LecturePhase.studentParticipation,
      );

  static void _insertAfterIntro(List<LectureSegment> out, LectureSegment? seg) {
    if (seg == null) return;
    if (out.isEmpty) {
      out.add(seg);
      return;
    }
    // Replace weak intro or insert after first segment.
    if (out.first.phase == LecturePhase.introduction &&
        out.first.professorSpeech.trim().split(RegExp(r'\s+')).length < 40) {
      out[0] = seg;
      return;
    }
    out.insert(1.clamp(0, out.length), seg);
  }

  static void _ensureSomewhere(
    List<LectureSegment> out, {
    required bool satisfied,
    required LectureSegment segment,
    required LecturePhase afterPhase,
    LecturePhase? requirePhase,
  }) {
    if (satisfied) {
      if (requirePhase != null && !_hasPhase(out, requirePhase)) {
        // Keywords existed but required phase is still missing — inject.
      } else {
        return;
      }
    }
    if (out.any((LectureSegment s) => s.caption == segment.caption)) return;
    final int idx = out.lastIndexWhere((LectureSegment s) => s.phase == afterPhase);
    final int at = idx >= 0 ? idx + 1 : out.length;
    out.insert(at.clamp(0, out.length), segment);
  }

  // ── injected segments ────────────────────────────────────────────────────

  static LectureSegment _introWhy(String topic, String course) => LectureSegment(
        phase: LecturePhase.introduction,
        professorSpeech:
            'Welcome to our university lecture on $topic in $course. '
            'I will explain carefully — not with a one-paragraph chatbot answer. '
            'First, in plain language: $topic is the idea we will define precisely, then use. '
            'Second, why it matters: without $topic, later work in $course becomes guesswork. '
            'Third, how we will learn it: definition, history, theory, board visuals, real examples, '
            'questions, practice from easy to hard, then homework and reading. '
            'Stay with me — every sentence should make the next one easier.',
        caption: 'Introduction — why $topic matters',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: topic,
          lines: <String>[
            'What $topic means (plain language)',
            'Precise definition coming next',
            'Why $course needs it',
            'Plan: theory → examples → practice',
          ],
        ),
        durationSeconds: 130,
      );

  static LectureSegment _history(String topic, String course) => LectureSegment(
        phase: LecturePhase.conceptExplanation,
        professorSpeech:
            'History of $topic: this idea did not appear as a slogan. People needed a reliable way to solve a real problem, '
            'so they refined language until others could reuse it. '
            'That is why the definition of $topic looks careful — each word blocks a common confusion. '
            'In $course, we keep that history in mind so you remember what problem $topic was invented to solve, '
            'and how it connects to earlier lessons instead of floating as an isolated fact.',
        caption: 'History of $topic',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'History — $topic',
          lines: <String>[
            'Problem people needed to solve',
            'Language refined for reuse',
            'Why the definition is careful',
            'Link to earlier $course ideas',
          ],
        ),
        durationSeconds: 125,
      );

  static LectureSegment _deepTheory(
    String topic, {
    VirtualLectureTopicProfile? profile,
  }) =>
      LectureSegment(
        phase: LecturePhase.conceptExplanation,
        professorSpeech: profile?.conceptSpeech ??
            'Plain meaning first: $topic is the central idea we will use for the rest of this lecture. '
                'Precise definition: we will state exactly what counts as $topic and what does not — '
                'so you can decide membership or apply the rule without guessing. '
                'Why it works: the definition is shaped so later theorems and examples stay consistent. '
                'I will walk the logical chain step by step. Name every term; if a symbol appears, I will say what it stands for. '
                'Do not memorize a slogan — rebuild $topic from the definition when you need it.',
        caption: 'Deep theory — $topic',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Theory — $topic',
          lines: profile?.conceptLines.isNotEmpty == true
              ? profile!.conceptLines
              : <String>[
                  'Plain meaning of $topic',
                  'Precise definition (what counts / what does not)',
                  'Why the definition is shaped this way',
                  'Logical steps to rebuild it',
                ],
        ),
        durationSeconds: 145,
      );

  static LectureSegment _visual(
    String topic, {
    VirtualLectureTopicProfile? profile,
  }) {
    return LectureSegment(
      phase: LecturePhase.visualDemonstration,
      professorSpeech: profile?.visualSpeech ??
          'Look at the board. This is a real diagram of $topic — not a sketch of shapes. '
              'Trace each labeled part with me so you can see the relationships, not only hear them.',
      caption: 'Visual — $topic',
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.diagram,
        title: 'Diagram — $topic',
        diagramQuery: '$topic educational diagram labeled',
        lines: profile?.conceptLines.isNotEmpty == true
            ? profile!.conceptLines.take(4).toList()
            : <String>['Real diagram of $topic', 'Label every part'],
      ),
      durationSeconds: 110,
    );
  }

  static LectureSegment _formulas(
    String topic, {
    VirtualLectureTopicProfile? profile,
  }) {
    final String equation = (profile?.mainEquation.trim().isNotEmpty ?? false)
        ? profile!.mainEquation
        : 'Definition of $topic';
    return LectureSegment(
      phase: LecturePhase.conceptExplanation,
      professorSpeech:
          'Governing statement for $topic: $equation. '
          'I will explain every symbol — what it stands for and what it measures — in the same breath as I write it. '
          'Then we ask why this form works: if you change one piece, how does the result move? '
          'Finally, a concrete check: plug in a simple value or example and verify the statement still makes sense. '
          'Topic lock — we are only teaching $topic.',
      caption: 'Formulas & symbols — $topic',
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.equation,
        title: 'Symbols — $topic',
        equation: equation,
        lines: profile?.formulas.isNotEmpty == true
            ? profile!.formulas.take(4).toList()
            : <String>[
                'Write the statement',
                'Name each symbol (what it measures)',
                'Why this form works',
                'Quick numeric / concrete check',
              ],
      ),
      durationSeconds: 130,
    );
  }

  static LectureSegment _threeExamples(
    String topic, {
    VirtualLectureTopicProfile? profile,
  }) {
    final List<String> examples = <String>[
      ...?profile?.exampleIdeas,
      ...?profile?.applicationLines,
    ];
    final List<String> lines = examples.isEmpty
        ? <String>[
            '1. Professional / job use of $topic',
            '2. Everyday life use of $topic',
            '3. Broader field application of $topic',
          ]
        : examples.take(3).toList();
    while (lines.length < 3) {
      lines.add('Another concrete use of $topic');
    }
    return LectureSegment(
      phase: LecturePhase.conceptExplanation,
      professorSpeech: profile?.applicationsSpeech ??
          'Three real-world examples of $topic: ${lines.join('; ')}. '
              'After each example, ask: which part of the $topic theory just showed up?',
      caption: '≥3 real-world examples — $topic',
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.text,
        title: 'Real world — $topic',
        lines: lines,
      ),
      durationSeconds: 125,
    );
  }

  static LectureSegment _midQuestion(
    String topic, {
    VirtualLectureTopicProfile? profile,
  }) =>
      LectureSegment(
        phase: LecturePhase.knowledgeCheck,
        professorSpeech:
            'Pause. Before we continue, answer this check on $topic. '
            'If you are confused, tap Confused — I will reteach with a different analogy and a new example.',
        caption: 'Question check — $topic',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Check understanding — $topic',
          lines: profile?.conceptLines.take(3).toList() ??
              <String>['Answer before we move on'],
        ),
        durationSeconds: 80,
        knowledgeCheck: LectureKnowledgeCheck(
          prompt: profile?.checkPrompt ??
              'Which statement best captures $topic so far?',
          kind: KnowledgeCheckKind.multipleChoice,
          options: profile?.checkOptions ??
              <String>[
                'A precise idea with definitions, methods, and applications',
                'A random fact with no structure',
                'Only a formula with no meaning',
                'Something you memorize without understanding',
              ],
          correctIndex: profile?.checkCorrectIndex ?? 0,
          explanation: profile?.checkExplanation ??
              'University learning means definitions + methods + applications — not slogans.',
        ),
      );

  static LectureSegment _comparePrevious(String topic, String course, String module) =>
      LectureSegment(
        phase: LecturePhase.conceptExplanation,
        professorSpeech:
            'Compare $topic to previous lessons in $course ($module). '
            'What stays the same from earlier ideas, and what is new? '
            'Good students always ask: how does today build on yesterday? '
            'That comparison prevents mixing up similar concepts on exams.',
        caption: 'Compare to previous lessons',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.table,
          title: 'Then vs now',
          lines: <String>[
            'Earlier lessons → foundations',
            '$topic → what is new',
            'Do not confuse similar ideas',
          ],
        ),
        durationSeconds: 100,
      );

  static LectureSegment _exercisesRamp(String topic, {VirtualLectureTopicProfile? profile}) => LectureSegment(
        phase: LecturePhase.practiceProblems,
        professorSpeech:
            'Exercises for $topic with increasing difficulty. '
            'Easy: identify the idea. Medium: apply the method with numbers or a short case. '
            'Hard: combine ideas or handle a messy real scenario. '
            'Work with me on the board — predict the next step when I pause.',
        caption: 'Exercises: easy → hard',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.workedProblem,
          title: 'Practice — $topic',
          problemStatement: 'Solve an easy, then medium, then hard $topic problem.',
            solutionSteps: <LectureProblemStep>[
            LectureProblemStep(
              title: 'Easy',
              work: 'Identify the core idea of $topic.',
              note: 'Warm-up',
            ),
            LectureProblemStep(
              title: 'Medium',
              work: 'Apply the standard method with concrete values.',
              note: 'Main skill',
            ),
            LectureProblemStep(
              title: 'Hard',
              work: 'Combine ideas or handle a realistic twist.',
              note: 'Exam-level',
            ),
          ],
          lines: <String>['Easy', 'Medium', 'Hard'],
        ),
        durationSeconds: 140,
        beats: <LectureInteractiveBeat>[
          LectureInteractiveBeat(
            professorSpeech: 'Easy warm-up: what is the first thing you check for $topic?',
            caption: 'Easy',
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: 'Easy',
              lines: <String>['Identify the idea'],
            ),
            studentChoice: LectureKnowledgeCheck(
              prompt: 'First move on an easy $topic question?',
              kind: KnowledgeCheckKind.multipleChoice,
              options: <String>[
                'State the definition / identify the type',
                'Guess randomly',
                'Skip to the hardest case',
                'Ignore units and meaning',
              ],
              correctIndex: 0,
              explanation: 'Start from the definition, then apply the method.',
              requireCorrect: true,
            ),
            durationSeconds: 55,
          ),
          LectureInteractiveBeat(
            professorSpeech: 'Medium: apply the method carefully for $topic.',
            caption: 'Medium',
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: 'Medium',
              lines: <String>['Apply the method'],
            ),
            durationSeconds: 55,
          ),
          LectureInteractiveBeat(
            professorSpeech: 'Hard: stretch $topic toward exam difficulty.',
            caption: 'Hard',
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: 'Hard',
              lines: <String>['Combine or extend the idea'],
            ),
            durationSeconds: 60,
          ),
        ],
      );

  static LectureSegment _homework(String topic) => LectureSegment(
        phase: LecturePhase.homeworkRecommendation,
        professorSpeech:
            'Homework for $topic: (1) finish the lesson quiz, '
            '(2) rework three problems closed-book — easy, medium, hard, '
            '(3) write five sentences linking $topic to a real job or daily situation, '
            '(4) complete the additional reading I recommend next, then open the next lesson.',
        caption: 'Homework — $topic',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Homework',
          lines: <String>[
            'Quiz',
            '3 closed-book problems (easy → hard)',
            'Real-world write-up',
            'Additional reading',
            'Next lesson',
          ],
        ),
        durationSeconds: 90,
      );

  static LectureSegment _additionalReading(String topic, String course) => LectureSegment(
        phase: LecturePhase.homeworkRecommendation,
        professorSpeech:
            'Additional reading for $topic in $course: review your lesson notes end-to-end, '
            're-read the definitions and any formula sheet, and find one reputable article, textbook chapter, '
            'or documentation page on $topic. Bring one question to the next lecture or Raise Hand.',
        caption: 'Additional reading',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Reading list',
          lines: <String>[
            'Re-read lesson notes',
            'Formula / definition sheet',
            'One external chapter or article on $topic',
            'Bring one question next time',
          ],
        ),
        durationSeconds: 85,
      );

  static LectureSegment _confusionCue(String topic) => LectureSegment(
        phase: LecturePhase.studentParticipation,
        professorSpeech:
            'If any part of $topic feels fuzzy, tap Confused. '
            'I will reteach using a different analogy, slower steps, and a new example — '
            'not the same speech repeated. Strong students use that button; it is how real office hours work.',
        caption: 'Confused? I reteach differently',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Office hours',
          lines: <String>[
            'Tap Confused',
            'New analogy + new example',
            'Then continue the lecture',
          ],
        ),
        durationSeconds: 70,
      );

  static LectureSummary _ensureSummary(
    LectureSummary current,
    String topic,
    String course,
  ) {
    final String hw = current.homeworkRecommendation.trim().isEmpty
        ? 'Homework: quiz + 3 closed-book $topic problems (easy→hard) + real-world write-up. '
            'Reading: notes + one external chapter/article on $topic in $course. Then start the next lesson.'
        : current.homeworkRecommendation;
    final String withReading = hw.toLowerCase().contains('read')
        ? hw
        : '$hw Also complete additional reading: notes plus one external source on $topic.';
    return LectureSummary(
      learned: current.learned.isEmpty
          ? <String>[
              'What $topic is and why it matters',
              'History and deep theory of $topic',
              'Visuals, formulas/symbols, and ≥3 applications',
              'Exercises and homework plan',
            ]
          : current.learned,
      keyFormulas: current.keyFormulas,
      applications: current.applications.isEmpty
          ? <String>['Professional use', 'Everyday life', 'Broader field applications']
          : current.applications,
      reviewTopics: current.reviewTopics,
      homeworkRecommendation: withReading,
    );
  }

  static List<LectureSegment> _fullScaffold({
    required String topic,
    required String course,
    required String module,
    VirtualLectureTopicProfile? profile,
  }) =>
      <LectureSegment>[
        _introWhy(topic, course),
        _history(topic, course),
        _deepTheory(topic, profile: profile),
        _visual(topic, profile: profile),
        _formulas(topic, profile: profile),
        _threeExamples(topic, profile: profile),
        _comparePrevious(topic, course, module),
        _midQuestion(topic, profile: profile),
        _confusionCue(topic),
        _exercisesRamp(topic, profile: profile),
        _homework(topic),
        _additionalReading(topic, course),
      ];
}
