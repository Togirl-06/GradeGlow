import '../models/virtual_lecture.dart';
import 'virtual_lecture_interactive_builder.dart';
import 'virtual_lecture_topic_profile.dart';

/// Builds topic-accurate offline lectures for any catalog lesson.
abstract final class VirtualLectureTopicLecture {
  static List<LectureSegment> segments({
    required VirtualLectureTopicProfile profile,
    required LectureMode mode,
  }) {
    final List<LectureSegment> theory = _theorySegments(profile);
    final List<LectureSegment> examples = VirtualLectureInteractiveBuilder.examplesForMode(
      profile.topic,
      mode,
      courseId: profile.courseId,
      category: profile.category,
    );
    final List<LectureSegment> closing = _closingSegments(profile);

    if (mode == LectureMode.review) {
      return <LectureSegment>[
        theory[0],
        theory[3],
        theory[5],
        ...examples.take(1),
        closing[0],
      ];
    }
    if (mode == LectureMode.exam) {
      return <LectureSegment>[
        theory[0],
        ...examples.skip(2),
        closing[0],
      ];
    }
    if (mode == LectureMode.practice) {
      return <LectureSegment>[
        theory[0],
        ...examples,
        closing[0],
        closing[1],
      ];
    }

    return <LectureSegment>[
      ...theory,
      ...examples,
      closing[0],
      closing[1],
      closing[2],
    ];
  }

  static List<String> objectives(VirtualLectureTopicProfile profile) => profile.objectives;

  static LectureSmartNotes notes(VirtualLectureTopicProfile profile) {
    return LectureSmartNotes(
      definitions: profile.definitions,
      formulas: profile.formulas,
      examples: profile.exampleIdeas,
      commonMistakes: profile.commonMistakes,
      tips: profile.tips,
    );
  }

  static LectureSummary summary(VirtualLectureTopicProfile profile) {
    return LectureSummary(
      learned: profile.summaryLearned,
      keyFormulas: profile.formulas,
      applications: profile.summaryApplications,
      reviewTopics: profile.summaryReview,
      homeworkRecommendation:
          'Homework: (1) Complete the lesson quiz. (2) Rework three ${profile.topic} problems closed-book, '
          'easy → hard. (3) Write five sentences connecting ${profile.topic} to a real job or daily situation. '
          '(4) Skim one extra reading or notes section on ${profile.topic}, then open the next lesson.',
    );
  }

  static List<LectureSegment> _theorySegments(VirtualLectureTopicProfile p) {
    return <LectureSegment>[
      _seg(
        phase: LecturePhase.introduction,
        speech:
            '${p.introSpeech} This is a full university lecture — not a quick chatbot answer. '
            'We will take our time: why ${p.topic} matters, where the idea came from, the theory in depth, '
            'visuals on the board, real-world examples, questions for you, practice, and homework.',
        caption: '${p.topic} — university lecture',
        title: p.topic,
        lines: <String>[
          p.course,
          p.module,
          'Full lecture · intro → theory → practice → homework',
        ],
        seconds: 110,
      ),
      _seg(
        phase: LecturePhase.objectives,
        speech:
            'By the end of this lecture on ${p.topic}, you will: ${p.objectives.join('; ')}. '
            'Hold yourself to university standards — understanding, not memorizing slogans.',
        caption: 'Learning objectives',
        title: 'Objectives — ${p.topic}',
        lines: p.objectives,
        seconds: 90,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech: p.whySpeech,
        caption: 'Why ${p.topic} matters',
        title: 'Why ${p.topic}?',
        lines: p.applicationLines,
        seconds: 100,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Before the formal theory, a short history of ${p.topic}: ideas like this usually grew from '
            'practical problems people needed to solve, then became precise language so others could reuse them. '
            'Knowing that history helps you remember why the definitions look the way they do — and how ${p.topic} '
            'connects to earlier lessons in ${p.course}. Keep asking: what problem was this invented to solve?',
        caption: 'History & context',
        title: 'History of ${p.topic}',
        lines: <String>[
          'Origins: practical problems → precise language',
          'Link to earlier lessons in ${p.course}',
          'Ask: what problem did ${p.topic} solve?',
        ],
        seconds: 110,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech: p.conceptSpeech,
        caption: 'Core definition',
        title: p.topic,
        equation: p.mainEquation,
        lines: p.conceptLines,
        seconds: 120,
      ),
      _seg(
        phase: LecturePhase.visualDemonstration,
        speech: p.visualSpeech,
        caption: 'Visual demo — ${p.topic}',
        title: 'Visualization',
        graph: p.graphFunction,
        seconds: 110,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech: p.methodSpeech,
        caption: 'Method',
        title: 'How to solve ${p.topic} problems',
        lines: p.methodLines,
        seconds: 115,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech: p.mistakesSpeech,
        caption: 'Common mistakes',
        title: 'Avoid these errors',
        lines: p.mistakesLines,
        seconds: 95,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            '${p.applicationsSpeech} We need at least three concrete uses — jobs and everyday life — '
            'so ${p.topic} never feels abstract. Example one, example two, and example three should each '
            'show a different setting where ${p.topic} changes a decision.',
        caption: 'Real-world applications',
        title: '${p.topic} in the real world',
        lines: p.applicationLines,
        seconds: 140,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Now compare ${p.topic} to previous lessons in ${p.module} / ${p.course}. '
            'What stays familiar? What is brand new? Experts always make that comparison so ideas connect '
            'instead of sitting as isolated facts. If something from last week is fuzzy, tap Confused and I will reteach.',
        caption: 'Compare to previous lessons',
        title: 'Then vs now — ${p.topic}',
        lines: <String>[
          'Earlier lessons in ${p.course}',
          'What ${p.topic} adds',
          'Shared traps to avoid',
        ],
        seconds: 130,
      ),
      LectureSegment(
        phase: LecturePhase.knowledgeCheck,
        professorSpeech:
            'Pause. I want you to answer this before we go to interactive examples. '
            'If you are confused, use Confused and I will reteach ${p.topic} a different way — new analogy, new example.',
        caption: 'Checkpoint — ${p.topic}',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Check — ${p.topic}',
          lines: p.conceptLines.take(3).toList(),
        ),
        durationSeconds: 90,
        knowledgeCheck: LectureKnowledgeCheck(
          prompt: p.checkPrompt,
          kind: KnowledgeCheckKind.multipleChoice,
          options: p.checkOptions,
          correctIndex: p.checkCorrectIndex,
          explanation: p.checkExplanation,
        ),
      ),
      _seg(
        phase: LecturePhase.studentParticipation,
        speech:
            'Throughout this hour-long lecture on ${p.topic}, keep using Confused whenever a step feels fuzzy. '
            'I will not repeat the same speech louder — I switch analogy and walk a fresh example on the board.',
        caption: 'Confused? Different reteach',
        title: 'Office hours in-lecture',
        lines: <String>[
          'Tap Confused',
          'New analogy + new example',
          'Then continue',
        ],
        seconds: 100,
      ),
    ];
  }

  static List<LectureSegment> _closingSegments(VirtualLectureTopicProfile p) {
    return <LectureSegment>[
      LectureSegment(
        phase: LecturePhase.lessonSummary,
        professorSpeech:
            'Summary of ${p.topic}: we covered why it matters, its history, definitions, visuals, methods, '
            'mistakes, real-world uses, comparison to earlier lessons, questions, and interactive practice. '
            'You do not need a \$50,000 tuition bill to master this — keep showing up to lecture.',
        caption: 'Summary — ${p.topic}',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Summary — ${p.topic}',
          lines: p.summaryLearned,
        ),
        durationSeconds: 110,
      ),
      LectureSegment(
        phase: LecturePhase.homeworkRecommendation,
        professorSpeech:
            'Homework for ${p.topic}: finish the lesson quiz; rework three problems closed-book from easy to hard; '
            'write a short real-world connection; then open the next lesson. '
            'Use Raise Hand anytime you want me to reteach a step on the board.',
        caption: 'Homework & next steps',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Homework',
          lines: <String>[
            'Lesson quiz',
            '3 closed-book problems (easy → hard)',
            'Real-world write-up',
            'Next lesson + Raise Hand if stuck',
          ],
        ),
        durationSeconds: 100,
      ),
      LectureSegment(
        phase: LecturePhase.homeworkRecommendation,
        professorSpeech:
            'Additional reading for ${p.topic} in ${p.course}: re-read your notes end-to-end, '
            'review every definition and formula we wrote, and find one reputable textbook chapter, article, '
            'or documentation page on ${p.topic}. Bring one question to the next lecture.',
        caption: 'Additional reading',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Reading list',
          lines: <String>[
            'Re-read lesson notes',
            'Definitions & formulas',
            'One external chapter/article on ${p.topic}',
            'Bring one question next time',
          ],
        ),
        durationSeconds: 95,
      ),
    ];
  }

  static LectureSegment _seg({
    required LecturePhase phase,
    required String speech,
    required String caption,
    required String title,
    List<String> lines = const <String>[],
    String? equation,
    String? graph,
    int seconds = 80,
  }) {
    final WhiteboardKind kind = graph != null
        ? WhiteboardKind.graph
        : equation != null
            ? WhiteboardKind.equation
            : WhiteboardKind.text;

    return LectureSegment(
      phase: phase,
      professorSpeech: speech,
      caption: caption,
      whiteboard: LectureWhiteboardFrame(
        kind: kind,
        title: title,
        lines: lines,
        equation: equation,
        graphFunction: graph ?? 'linear',
      ),
      durationSeconds: seconds,
    );
  }
}
