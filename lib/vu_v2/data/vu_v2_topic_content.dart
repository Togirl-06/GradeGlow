import 'dart:math' as math;

import 'vu_v2_cs_notes_code.dart';
import 'vu_v2_topic_content_models.dart';

/// Builds rich university textbook notes + quizzes/exams for every V2 topic.
///
/// Notes are long-form chapters (definitions, mechanisms, worked examples,
/// misconceptions, applications, study guides) — not one-paragraph stubs.
abstract final class VuV2TopicContent {
  static VuV2TopicPackage forLesson({
    required String subjectId,
    required String facultyTitle,
    required String facultyEmoji,
    required String trackTitle,
    required String courseTitle,
    required String topicTitle,
    String? topicSubtitle,
    bool interactive = false,
  }) {
    final _Discipline d = _disciplineFor(subjectId);
    final List<VuV2TextbookSection> sections = interactive
        ? _buildInteractiveChapter(
            discipline: d,
            facultyTitle: facultyTitle,
            trackTitle: trackTitle,
            courseTitle: courseTitle,
            topic: topicTitle,
          )
        : _buildChapter(
            discipline: d,
            subjectId: subjectId,
            facultyTitle: facultyTitle,
            trackTitle: trackTitle,
            courseTitle: courseTitle,
            topic: topicTitle,
            subtitle: topicSubtitle,
          );
    final List<VuV2Mcq> quiz = topicQuiz(
      subjectId: subjectId,
      facultyTitle: facultyTitle,
      courseTitle: courseTitle,
      topicTitle: topicTitle,
      count: interactive ? 6 : 8,
    );
    return VuV2TopicPackage(
      subjectId: subjectId,
      facultyTitle: facultyTitle,
      courseTitle: courseTitle,
      trackTitle: trackTitle,
      topicTitle: topicTitle,
      sections: sections,
      topicQuiz: quiz,
    );
  }

  /// End-of-topic quiz (8–10 questions with explanations).
  static List<VuV2Mcq> topicQuiz({
    required String subjectId,
    required String facultyTitle,
    required String courseTitle,
    required String topicTitle,
    int count = 8,
  }) {
    return _buildMcqs(
      subjectId: subjectId,
      facultyTitle: facultyTitle,
      courseTitle: courseTitle,
      topicTitle: topicTitle,
      count: count,
      examMode: false,
    );
  }

  /// End-of-course exam (sampled across lesson titles in the course).
  static VuV2ExamPackage courseExam({
    required String subjectId,
    required String facultyTitle,
    required String courseTitle,
    required List<String> lessonTitles,
    int count = 20,
  }) {
    final List<String> topics = lessonTitles.isEmpty
        ? <String>[courseTitle]
        : lessonTitles;
    final math.Random rng = math.Random(
      subjectId.hashCode ^ courseTitle.hashCode ^ 0xC0FFEE,
    );
    final List<VuV2Mcq> unique = <VuV2Mcq>[];
    final Set<String> seen = <String>{};
    int salt = 0;
    while (unique.length < count && salt < count * 8) {
      final String topic = topics[salt % topics.length];
      final List<VuV2Mcq> chunk = _buildMcqs(
        subjectId: subjectId,
        facultyTitle: facultyTitle,
        courseTitle: courseTitle,
        topicTitle: topic,
        count: 6,
        examMode: true,
        seedSalt: salt * 97,
      );
      chunk.shuffle(rng);
      for (final VuV2Mcq q in chunk) {
        if (seen.add(q.prompt)) {
          unique.add(q);
          if (unique.length >= count) break;
        }
      }
      salt++;
    }
    return VuV2ExamPackage(
      courseTitle: courseTitle,
      facultyTitle: facultyTitle,
      questions: unique.take(count).toList(growable: false),
      passPercent: 70,
    );
  }

  // ── Chapter builder ──────────────────────────────────────────────────────

  /// Focused chapter: five strong explanations, no filler sections.
  static List<VuV2TextbookSection> _buildInteractiveChapter({
    required _Discipline discipline,
    required String facultyTitle,
    required String trackTitle,
    required String courseTitle,
    required String topic,
  }) {
    final String field = facultyTitle;
    return <VuV2TextbookSection>[
      VuV2TextbookSection(
        title: 'Definition',
        body: discipline.explainDefinition(topic, courseTitle, field),
      ),
      VuV2TextbookSection(
        title: 'How it works',
        body: discipline.explainHowItWorks(topic, courseTitle, field),
      ),
      VuV2TextbookSection(
        title: 'How to apply it',
        body: discipline.explainHowToApply(topic, courseTitle, field),
      ),
      VuV2TextbookSection(
        title: 'Worked example',
        body: discipline.explainWorkedExample(topic, courseTitle, field),
      ),
      VuV2TextbookSection(
        title: 'Mistakes to avoid',
        body: discipline.explainMistakes(topic, courseTitle, field),
      ),
    ];
  }

  static List<VuV2TextbookSection> _buildChapter({
    required _Discipline discipline,
    required String subjectId,
    required String facultyTitle,
    required String trackTitle,
    required String courseTitle,
    required String topic,
    String? subtitle,
  }) {
    final String field = facultyTitle;
    final String lens = discipline.label;
    final String why = discipline.whyMatters(topic, courseTitle);
    final String deep = discipline.deepExplanation(topic, courseTitle, field);
    final String method = discipline.method(topic, courseTitle);
    final String rules = discipline.rulesAndFormulas(topic, courseTitle);
    final String example1 = discipline.workedExample(topic, courseTitle, 1);
    final String example2 = discipline.workedExample(topic, courseTitle, 2);
    final String pitfalls = discipline.misconceptions(topic);
    final String apps = discipline.applications(topic, field);
    final String advanced = discipline.advanced(topic, courseTitle);
    final String connect = discipline.connections(topic, courseTitle, trackTitle);

    return <VuV2TextbookSection>[
      VuV2TextbookSection(
        title: 'Chapter overview',
        body:
            '**$topic**\n'
            '$courseTitle · $trackTitle · $field · Virtual University\n\n'
            '${subtitle == null || subtitle.isEmpty ? '' : '$subtitle\n\n'}'
            'This is a full university chapter — not a summary. Read it as you would '
            'a required textbook unit: learn precise definitions, understand mechanisms '
            'in detail, work the examples without peeking, then prove mastery on the '
            'end-of-topic quiz. A course final exam waits after you finish every topic '
            'in **$courseTitle**.',
      ),
      VuV2TextbookSection(
        title: 'Learning outcomes',
        body:
            'By the end of this chapter you will be able to:\n\n'
            '1. **Define** $topic in precise $lens language that a professor would accept '
            'on an exam.\n'
            '2. **Explain** the underlying mechanism / reasoning — not only the label — '
            'so a peer who has never seen the topic can follow you.\n'
            '3. **Apply** $topic to a realistic problem inside $courseTitle, showing '
            'each step and stating assumptions.\n'
            '4. **Diagnose** at least three common mistakes and correct them with the '
            'right principle.\n'
            '5. **Connect** $topic to earlier and later topics in $courseTitle and to '
            'professional practice in $field.\n'
            '6. **Assess** your own understanding by answering the self-check questions '
            'and scoring ≥70% on the topic quiz.',
      ),
      VuV2TextbookSection(
        title: 'Why this topic matters',
        body: why,
      ),
      VuV2TextbookSection(
        title: 'Prerequisites',
        body:
            'Before you study **$topic**, make sure you can already:\n\n'
            '• Restate the big story of **$courseTitle** in two or three sentences '
            '(what the course trains you to do).\n'
            '• Use the basic vocabulary of $field without freezing — if a word in this '
            'chapter is unfamiliar, define it before moving on.\n'
            '• Follow a multi-step argument: claim → evidence / derivation → conclusion.\n'
            '• Work with units, citations, or code (as relevant to $lens) carefully.\n\n'
            'If any of these feel shaky, skim the previous roadmap topics in '
            '**$trackTitle**, then return here. Gaps in prerequisites cause most '
            'failures on $topic assessments.',
      ),
      VuV2TextbookSection(
        title: 'Precise definitions',
        body:
            '**$topic (working definition).** '
            'In $field, **$topic** names the core idea this chapter teaches: the '
            'object, process, rule, method, or relationship you must understand deeply '
            'enough to use under exam pressure.\n\n'
            '**Operational definition.** '
            'You “know” $topic when you can (a) state it without notes, (b) give a '
            'non-example that looks similar but fails a key condition, and (c) use it '
            'to make a decision, prediction, proof, diagnosis, or design choice inside '
            '**$courseTitle**.\n\n'
            '**Related vocabulary.** '
            'Separate **$topic** from nearby terms that students often collapse: '
            'causes vs effects, models vs reality, rules vs exceptions, correlation vs '
            'causation, syntax vs semantics, symptoms vs diagnosis — whichever pair '
            'fits this $lens topic. Write one sentence that contrasts them.\n\n'
            '**Scope boundary.** '
            'This chapter covers what a first-pass university treatment of **$topic** '
            'must include. Research frontiers and rare edge cases appear in the '
            'Advanced section; do not skip foundations to chase them.',
      ),
      VuV2TextbookSection(
        title: 'Deep explanation',
        body: deep,
      ),
      VuV2TextbookSection(
        title: 'Step-by-step method',
        body: method,
      ),
      VuV2TextbookSection(
        title: 'Rules, formulas & governing principles',
        body: rules,
      ),
      VuV2TextbookSection(
        title: 'Conceptual model',
        body:
            'Hold this mental picture while you study **$topic**:\n\n'
            '```\n'
            'Context ($courseTitle)\n'
            '   ↓\n'
            'Inputs / evidence / givens\n'
            '   ↓\n'
            'Core process: $topic\n'
            '   ↓\n'
            'Check constraints & assumptions\n'
            '   ↓\n'
            'Output: answer · decision · design · diagnosis · argument\n'
            '   ↓\n'
            'Verify · explain · communicate\n'
            '```\n\n'
            'Every professional use of **$topic** follows this flow, even when experts '
            'do it quickly. Slow the flow down until each arrow is conscious, then '
            'speed up. If you cannot fill one box, that is exactly where your gap is.',
      ),
      VuV2TextbookSection(
        title: 'Worked example 1 — guided',
        body: example1,
      ),
      VuV2TextbookSection(
        title: 'Worked example 2 — independent style',
        body: example2,
      ),
      VuV2TextbookSection(
        title: 'Edge cases & exceptions',
        body:
            'University exams love boundaries. For **$topic**, study these edges:\n\n'
            '1. **Missing information.** What can you still conclude, and what must '
            'you refuse to invent?\n'
            '2. **Conflicting cues.** Which principle in $courseTitle wins, and why?\n'
            '3. **Scale change.** Does the same reasoning hold at a different size, '
            'time scale, population, voltage, jurisdiction, or market?\n'
            '4. **Near-miss lookalikes.** Name one situation that appears to be '
            '**$topic** but fails a necessary condition.\n'
            '5. **When the model breaks.** State when the simplified classroom model '
            'of **$topic** is no longer safe to use without extra theory.\n\n'
            'Write a short “exception card” for each item — two sentences max — and '
            'review it before the course exam.',
      ),
      VuV2TextbookSection(
        title: 'Common misconceptions (and corrections)',
        body: pitfalls,
      ),
      VuV2TextbookSection(
        title: 'Real-world applications',
        body: apps,
      ),
      VuV2TextbookSection(
        title: 'How this connects in your degree',
        body: connect,
      ),
      VuV2TextbookSection(
        title: 'Advanced extensions',
        body: advanced,
      ),
      VuV2TextbookSection(
        title: 'Study guide & memory anchors',
        body:
            '**Teach-back (2 minutes).** Close the notes. Explain **$topic** aloud as '
            'if tutoring a classmate in $courseTitle. Record yourself if possible.\n\n'
            '**One-page sheet.** On a blank page write: definition · 3 key steps · '
            '1 formula/rule · 1 worked skeleton · 2 mistakes to avoid.\n\n'
            '**Retrieval prompts.** Cover the page and answer:\n'
            '• What is **$topic**?\n'
            '• Why does $courseTitle require it?\n'
            '• What is the first move when applying it?\n'
            '• What evidence would falsify a wrong answer?\n\n'
            '**Spaced review.** Revisit this chapter tomorrow and again before the '
            '**$courseTitle** final exam. Recognition is not mastery — retrieval is.',
      ),
      VuV2TextbookSection(
        title: 'Self-check (open response)',
        body:
            'Answer in writing before you open the quiz:\n\n'
            '1. Define **$topic** in ≤40 words without circular language.\n'
            '2. List the steps of the method for applying **$topic**.\n'
            '3. Give one realistic $field scenario and solve/argue it in outline form.\n'
            '4. Name two misconceptions and the correct principle for each.\n'
            '5. Explain how **$topic** prepares you for a later topic in **$courseTitle**.\n\n'
            'Compare your answers to the chapter. Gaps that remain become your quiz '
            'study targets.',
      ),
      VuV2TextbookSection(
        title: 'Chapter summary',
        body:
            '**$topic** is a required competency inside **$courseTitle** ($field). '
            'You have definitions, a deep mechanism explanation, a reusable method, '
            'governing principles, two worked examples, edge cases, misconception '
            'repairs, applications, degree connections, and advanced extensions.\n\n'
            'Mastery standard: you can teach **$topic**, apply it under time pressure, '
            'and explain why wrong answers fail. Next: take the **end-of-topic quiz**. '
            'After every topic in this course is complete, take the **course final exam**.',
      ),
      VuV2TextbookSection(
        title: 'Mastery checklist',
        body:
            '□ I can define **$topic** without notes\n'
            '□ I can explain the mechanism / reasoning in detail\n'
            '□ I can apply the step-by-step method to a fresh problem\n'
            '□ I can state the key rules / formulas / principles\n'
            '□ I worked both examples without looking at the answer first\n'
            '□ I can correct the main misconceptions\n'
            '□ I can give a real-world $field application\n'
            '□ I am ready for the topic quiz (≥70% to pass)\n'
            '□ I will include this topic in my **$courseTitle** exam review',
      ),
    ];
  }

  // ── MCQ bank ─────────────────────────────────────────────────────────────

  static List<VuV2Mcq> _buildMcqs({
    required String subjectId,
    required String facultyTitle,
    required String courseTitle,
    required String topicTitle,
    required int count,
    required bool examMode,
    int seedSalt = 0,
  }) {
    final _Discipline d = _disciplineFor(subjectId);
    final String t = topicTitle;
    final String c = courseTitle;
    final String examTag = examMode ? ' [Exam]' : '';
    final math.Random rng = math.Random(
      subjectId.hashCode ^ t.hashCode ^ c.hashCode ^ seedSalt ^ (examMode ? 7 : 3),
    );

    final List<VuV2Mcq> bank = <VuV2Mcq>[
      VuV2Mcq(
        id: 'def',
        prompt: 'Which statement best captures a university-level definition of "$t"?$examTag',
        choices: <String>[
          'A vague buzzword with no operational meaning',
          'A precise idea you can state, contrast with near-misses, and apply inside $c',
          'Whatever appears first in a search result',
          'A topic you memorize once and never use',
        ],
        correctIndex: 1,
        explanation:
            'Exam-ready definitions are precise, contrastive, and usable in $c problems.',
      ),
      VuV2Mcq(
        id: 'first',
        prompt: 'Best first move when applying "$t" in $c?$examTag',
        choices: <String>[
          'Jump to a final answer with no framing',
          'Clarify givens, goal, and the governing principle before computing or deciding',
          'Ignore units, constraints, or ethics',
          'Copy a classmate outline without understanding',
        ],
        correctIndex: 1,
        explanation:
            'Experts frame the problem: what is given, what is asked, which rule applies.',
      ),
      VuV2Mcq(
        id: 'why',
        prompt: 'Why does $c include "$t"?$examTag',
        choices: <String>[
          'Only to fill the syllabus with unrelated trivia',
          'Because competent practice in $facultyTitle requires this competency',
          'Because it never appears in professional work',
          'Because exams should avoid transferable skills',
        ],
        correctIndex: 1,
        explanation:
            'Curriculum topics exist because the profession uses them under real constraints.',
      ),
      VuV2Mcq(
        id: 'mis',
        prompt: 'A common misconception about "$t" is:$examTag',
        choices: <String>[
          'Confusing surface similarity with the actual governing condition',
          'Checking assumptions carefully',
          'Explaining each step',
          'Verifying the result against a known limit case',
        ],
        correctIndex: 0,
        explanation:
            'Lookalike situations fail when a necessary condition for $t is missing.',
      ),
      VuV2Mcq(
        id: 'check',
        prompt: 'After producing an answer involving "$t", you should:$examTag',
        choices: <String>[
          'Assume correctness and stop',
          'Verify with a second path, units/limits, or counterexample check',
          'Delete your reasoning so nobody can review it',
          'Avoid stating assumptions',
        ],
        correctIndex: 1,
        explanation:
            'Verification is part of professional and exam-grade work.',
      ),
      VuV2Mcq(
        id: 'teach',
        prompt: 'You have mastered "$t" when you can:$examTag',
        choices: <String>[
          'Recognize the title on a slide',
          'Teach it, apply it to a fresh case, and repair misconceptions',
          'Highlight the chapter once',
          'Avoid practice questions',
        ],
        correctIndex: 1,
        explanation:
            'Recognition ≠ mastery. Teaching + transfer + error repair are the bar.',
      ),
      VuV2Mcq(
        id: 'edge',
        prompt: 'On an edge-case question about "$t", prioritize:$examTag',
        choices: <String>[
          'Inventing facts that were not given',
          'Stating what still follows from the given conditions and what does not',
          'Ignoring constraints that make the case unusual',
          'Giving a one-word answer with no justification',
        ],
        correctIndex: 1,
        explanation:
            'Edge cases test whether you respect scope and necessary conditions.',
      ),
      VuV2Mcq(
        id: 'link',
        prompt: 'How should "$t" connect to the rest of $c?$examTag',
        choices: <String>[
          'As an isolated trivia island',
          'As a building block that earlier topics prepare and later topics reuse',
          'As optional decoration',
          'As something to forget after the quiz',
        ],
        correctIndex: 1,
        explanation:
            'Degree roadmaps sequence topics so each one supports later mastery.',
      ),
      ...d.extraMcqs(topic: t, course: c, faculty: facultyTitle, examMode: examMode),
    ];

    final List<VuV2Mcq> shuffled = List<VuV2Mcq>.from(bank)..shuffle(rng);
    return shuffled
        .take(count.clamp(1, shuffled.length))
        .map((VuV2Mcq q) => _shuffleChoices(q, rng))
        .toList(growable: false);
  }

  static VuV2Mcq _shuffleChoices(VuV2Mcq q, math.Random rng) {
    final List<int> order = List<int>.generate(q.choices.length, (int i) => i)
      ..shuffle(rng);
    final List<String> choices = order.map((int i) => q.choices[i]).toList();
    final int correct = order.indexOf(q.correctIndex);
    return VuV2Mcq(
      id: q.id,
      prompt: q.prompt,
      choices: choices,
      correctIndex: correct,
      explanation: q.explanation,
    );
  }

  static _Discipline _disciplineFor(String subjectId) {
    return switch (subjectId) {
      'biology' || 'chemistry' || 'physics' || 'mathematics' ||
      'environmental_science' =>
        _Discipline.stem,
      'nursing' || 'medicine' || 'psychology' => _Discipline.health,
      'law' => _Discipline.law,
      'business' || 'accounting' || 'economics' || 'marketing' =>
        _Discipline.business,
      'computer_science' ||
      'software_engineering' ||
      'artificial_intelligence' ||
      'cybersecurity' =>
        _Discipline.cs,
      'engineering' => _Discipline.engineering,
      'english' || 'political_science' => _Discipline.humanities,
      _ => _Discipline.general,
    };
  }
}

enum _Discipline {
  stem('STEM'),
  health('clinical'),
  law('legal'),
  business('business'),
  cs('computer science'),
  engineering('engineering'),
  humanities('humanities / social science'),
  general('academic');

  const _Discipline(this.label);
  final String label;

  String whyMatters(String topic, String course) {
    return switch (this) {
      _Discipline.stem =>
        '**$topic** is not optional decoration inside **$course** — it is a load-bearing '
        'idea. Without it, later derivations, lab interpretations, and quantitative '
        'predictions collapse into memorized recipes. Scientists and mathematicians use '
        '**$topic** to turn observations and axioms into reliable claims: define the '
        'system, identify variables, apply conservation or logical structure, predict, '
        'and test.\n\n'
        'In exams and in research, shallow familiarity fails. You must explain *why* a '
        'step is valid, estimate magnitudes, catch impossible answers, and connect the '
        'symbolism back to a physical, chemical, biological, or mathematical meaning. '
        'That is why this chapter spends time on mechanisms, not slogans.',
      _Discipline.health =>
        '**$topic** sits inside **$course** because patient and client safety depend on '
        'it. A practitioner who vaguely “knows about” **$topic** but cannot assess, '
        'prioritize, act, reassess, and hand off creates preventable harm.\n\n'
        'Clinical education therefore demands more than vocabulary: you need cue '
        'recognition, differential thinking, first-line actions with rationale, red-flag '
        'awareness, and clear documentation language. Treat every paragraph in this '
        'chapter as something you might need at the bedside, in clinic, or in a crisis '
        'conversation — under time pressure and with incomplete information.',
      _Discipline.law =>
        '**$topic** matters in **$course** because legal analysis is issue-spotting plus '
        'rule application — not vibes. Courts, clients, and exams punish conclusory '
        'labels. You must state the issue, recite the governing rule / elements, apply '
        'facts element-by-element, and conclude with a holding that follows.\n\n'
        'Professionals who skip elements, invent facts, or confuse policy with doctrine '
        'lose credibility. This chapter trains the IRAC muscle for **$topic** so you can '
        'survive cold calls, memos, and timed exams.',
      _Discipline.business =>
        '**$topic** is taught in **$course** because managers, analysts, and founders '
        'make costly decisions with incomplete data. The difference between a slogan and '
        'a skill is whether you can define metrics, state assumptions, compare options, '
        'and explain trade-offs to a skeptical stakeholder.\n\n'
        'Use this chapter to build an executive-ready explanation of **$topic**: what it '
        'is, when it applies, how to compute or decide, what can go wrong, and how you '
        'would measure success after the decision ships.',
      _Discipline.cs =>
        '**$topic** is core to **$course** because software fails in production when '
        'engineers only “sort of” understand a concept. Interviews, code review, and '
        'debugging all test whether you can define behavior, handle edge cases, reason '
        'about complexity, and verify correctness.\n\n'
        'Read this chapter as if you must implement **$topic**, explain it on a '
        'whiteboard, and defend your choices. Intuition → formal rule → implementation '
        '→ tests is the path; skipping any layer shows up as bugs.',
      _Discipline.engineering =>
        '**$topic** exists in **$course** because engineered systems must perform safely '
        'under real loads, uncertainties, and constraints. Guessing is not a design '
        'method. You need definitions, governing relations, assumptions, factors of '
        'safety, failure modes, and verification.\n\n'
        'This chapter trains you to treat **$topic** the way a professional engineer '
        'does: quantify, check limits, document assumptions, and know when the model is '
        'no longer valid.',
      _Discipline.humanities =>
        '**$topic** is central to **$course** because careful thinking in this field '
        'requires definitions, evidence, mechanisms or arguments, and honest treatment '
        'of trade-offs and counterarguments. Buzzwords without operational meaning fail '
        'both seminars and civic life.\n\n'
        'Use this chapter to build a defensible account of **$topic**: what it is, how '
        'it works, what evidence supports claims about it, who is affected, and what a '
        'responsible analyst would do next.',
      _Discipline.general =>
        '**$topic** is included in **$course** because university mastery means you can '
        'define, explain, apply, and evaluate — not merely recognize a heading. This '
        'chapter gives you the full treatment so nothing essential is missing before '
        'you face the topic quiz and course exam.',
    };
  }

  /// Compact teaching for interactive notes.
  String coreTeach(String topic, String course, String field) =>
      explainHowItWorks(topic, course, field);

  String explainDefinition(String topic, String course, String field) {
    final String lens = label;
    return switch (this) {
      _Discipline.stem =>
        '**Working definition.** In **$course**, **$topic** is a precise $lens idea: '
        'a named relationship, quantity, structure, or process you can state without hand-waving.\n\n'
        '**What it includes.** The conditions under which **$topic** applies, the symbols or '
        'objects involved, and what changes when **$topic** is present.\n\n'
        '**What it is not.** It is not a vague slogan, a single formula memorized without meaning, '
        'or a lookalike concept that fails a necessary condition.\n\n'
        '**Exam-ready sentence.** “**$topic** means ___ ; it applies when ___ ; it does not apply when ___.”\n\n'
        '**Mini example.** Pick one concrete case from $field where **$topic** clearly appears, '
        'and one near-miss case that only looks similar.',
      _Discipline.health =>
        '**Working definition.** In **$course** ($field), **$topic** is a clinical competency: '
        'what you must recognize, assess, decide, or perform safely.\n\n'
        '**What it includes.** The cues you collect, the priority order, the first-line action, '
        'and how you know the action worked.\n\n'
        '**What it is not.** It is not “doing something” before assessment, using vague endpoints '
        '(“looks better”), or ignoring red flags.\n\n'
        '**Exam-ready sentence.** “For **$topic**, I assess ___, act by ___, and reassess ___.”\n\n'
        '**Mini example.** One bedside/clinic moment where **$topic** changes what you do next.',
      _Discipline.law =>
        '**Working definition.** In **$course**, **$topic** is a legal doctrine or skill: '
        'a rule with elements (or factors) that you apply to facts.\n\n'
        '**What it includes.** The black-letter rule, each required element, and the consequence '
        'if the rule is met or failed.\n\n'
        '**What it is not.** It is not a conclusory label (“liable,” “guilty”) without element '
        'analysis, and not invented facts.\n\n'
        '**Exam-ready sentence.** “**$topic** requires elements ___; on these facts, element ___ '
        'is the key dispute.”\n\n'
        '**Mini example.** One short fact pattern where **$topic** is the central issue.',
      _Discipline.business =>
        '**Working definition.** In **$course**, **$topic** is a decision tool: a concept, metric, '
        'or framework that changes what a manager should do.\n\n'
        '**What it includes.** The decision it informs, the inputs/metrics needed, and the '
        'trade-offs it forces into the open.\n\n'
        '**What it is not.** It is not a buzzword slide, a KPI with no definition, or a '
        'recommendation with only upsides.\n\n'
        '**Exam-ready sentence.** “**$topic** helps decide ___; measured by ___; main trade-off ___.”\n\n'
        '**Mini example.** One realistic business choice where **$topic** should drive the call.',
      _Discipline.cs => VuV2CsNotesCode.definition(topic, course),
      _Discipline.engineering =>
        '**Working definition.** In **$course**, **$topic** is an engineering principle used to '
        'predict, design, or verify a system under constraints.\n\n'
        '**What it includes.** The governing idea/relation, units, assumptions, and the check '
        'that the design remains safe.\n\n'
        '**What it is not.** Guessing without a model, dropping units, or trusting a simulation '
        'with no sanity check.\n\n'
        '**Exam-ready sentence.** “**$topic** relates ___; valid when ___; fails when ___.”\n\n'
        '**Mini example.** One design/calculation situation where **$topic** decides pass/fail.',
      _Discipline.humanities =>
        '**Working definition.** In **$course**, **$topic** is an analytical idea: a term you can '
        'define operationally and use to explain a case, text, or institution.\n\n'
        '**What it includes.** Meaning, mechanism or argument structure, and how evidence '
        'supports claims about it.\n\n'
        '**What it is not.** A buzzword without definition, or one anecdote treated as proof.\n\n'
        '**Exam-ready sentence.** “**$topic** means ___; it works by ___; evidence looks like ___.”\n\n'
        '**Mini example.** One real case where **$topic** clarifies what is happening.',
      _Discipline.general =>
        '**Working definition.** **$topic** in **$course** ($field) is the idea you must define '
        'precisely, contrast with lookalikes, and use on a fresh problem.\n\n'
        '**Include:** meaning, when it applies, when it does not.\n'
        '**Exclude:** vague recognition without application.\n\n'
        'Write one exam-ready sentence defining **$topic**.',
    };
  }

  String explainHowItWorks(String topic, String course, String field) {
    return switch (this) {
      _Discipline.stem =>
        '**Mechanism.** **$topic** works by linking cause → rule → consequence inside **$course**.\n\n'
        '1. **Identify the system** — what objects, quantities, or states are involved?\n'
        '2. **Name the governing idea** — conservation, definition, theorem, empirical law, or model?\n'
        '3. **State assumptions** — what must be true for the model to hold?\n'
        '4. **Follow the chain** — if the inputs change, what must **$topic** predict?\n'
        '5. **Test meaning** — what measurement or observation would falsify a wrong use of **$topic**?\n\n'
        'If you only remember a formula but cannot explain this chain, you do not yet understand '
        '**$topic** in $field.',
      _Discipline.health =>
        '**Clinical reasoning spine for $topic.**\n\n'
        '1. **Frame the goal** — what does “done well” look like?\n'
        '2. **Gather focused data** — history, exam, vitals, labs, or mental-status cues.\n'
        '3. **Prioritize** — address life threats / red flags before nice-to-haves.\n'
        '4. **Act** — one clear first action with a stated rationale.\n'
        '5. **Reassess** — pick a measurable endpoint that proves response.\n'
        '6. **Communicate** — document/hand off in language another $field professional can use.\n\n'
        '**$topic** deepens one or more of these steps. Skipping assessment to “just do something” '
        'breaks the whole chain.',
      _Discipline.law =>
        '**How $topic works in analysis (IRAC).**\n\n'
        '1. **Issue** — phrase the precise legal question the facts raise.\n'
        '2. **Rule** — state the doctrine and list every element/factor of **$topic**.\n'
        '3. **Application** — march through elements using only record facts.\n'
        '4. **Conclusion** — hold for a party and identify the weakest/strongest element.\n\n'
        'The work is in application: each element needs a fact that satisfies or fails it. '
        'Policy talk is optional; element analysis is not.',
      _Discipline.business =>
        '**How $topic drives a decision in $course.**\n\n'
        '1. Clarify the decision **$topic** is supposed to unlock.\n'
        '2. Define the metrics/inputs (no fuzzy KPIs).\n'
        '3. Generate options and name trade-offs (cost, speed, risk, cash, brand).\n'
        '4. Log assumptions explicitly.\n'
        '5. Choose, then define the feedback signal that shows success or failure.\n\n'
        'If **$topic** does not change the decision or the metrics, you are still at slogan level.',
      _Discipline.cs => VuV2CsNotesCode.howItWorks(topic, course),
      _Discipline.engineering =>
        '**How $topic guides design.**\n\n'
        '1. Start from the requirement (what must the system do?).\n'
        '2. Write the governing relation for **$topic** with units.\n'
        '3. List assumptions (linearity, steady state, ideal materials, etc.).\n'
        '4. Compute a nominal result, then apply safety/tolerance thinking.\n'
        '5. Name the failure mode if assumptions break.\n\n'
        '**$topic** is useful only when the model’s limits are visible.',
      _Discipline.humanities =>
        '**How $topic explains the world in $course.**\n\n'
        '1. Define it operationally.\n'
        '2. Explain the mechanism or argument structure (how A leads to B).\n'
        '3. Bring evidence (case, data, text, institution).\n'
        '4. Note uncertainty, stakeholders, and a serious counterargument.\n\n'
        'A strong explanation of **$topic** can teach a peer in two minutes with one example.',
      _Discipline.general =>
        '**How $topic works.**\n\n'
        '1. State the idea precisely.\n'
        '2. Explain the mechanism (why outcomes follow).\n'
        '3. Show what changes when inputs change.\n'
        '4. Name when the idea stops applying.\n\n'
        'Use this chain every time **$topic** appears in **$course**.',
    };
  }

  String explainHowToApply(String topic, String course, String field) {
    return switch (this) {
      _Discipline.stem || _Discipline.engineering =>
        '**Application checklist for $topic.**\n\n'
        '1. **Restate the goal** — what must you find, prove, or design?\n'
        '2. **Inventory givens** — numbers, constraints, diagrams, knowns/unknowns.\n'
        '3. **Select the principle** — which form of **$topic** governs this problem?\n'
        '4. **Set up** — equation, free-body, table, or model with every symbol defined.\n'
        '5. **Execute** — show intermediate steps; do not jump to a naked answer.\n'
        '6. **Verify** — units, magnitude, limit case, or opposite extreme.\n'
        '7. **Communicate** — box the answer and say what it means in $field language.\n\n'
        'If step 3 is fuzzy, stop and re-read the definition before calculating.',
      _Discipline.health =>
        '**How to apply $topic on a case.**\n\n'
        '1. Restate the patient/client problem in one sentence.\n'
        '2. Collect the minimum focused assessment for **$topic**.\n'
        '3. List 2–3 differentials or contributing factors.\n'
        '4. Choose the first action aligned with **$course** standards.\n'
        '5. State the rationale in one line.\n'
        '6. Reassess a measurable endpoint.\n'
        '7. Write a one-line handoff another clinician can use.\n\n'
        'Practice this sequence aloud — speed comes after reliability.',
      _Discipline.law =>
        '**How to apply $topic on an exam/memo.**\n\n'
        '1. Spot the issue that triggers **$topic**.\n'
        '2. Recite the rule and number the elements.\n'
        '3. For each element: cite a fact that satisfies or fails it.\n'
        '4. Address the opponent’s best counter on the weakest element.\n'
        '5. Conclude with a holding tied to the analysis.\n\n'
        'No facts → no credit for that element.',
      _Discipline.business =>
        '**How to apply $topic in a recommendation.**\n\n'
        '1. Name the decision owner and decision.\n'
        '2. Define metrics for **$topic** (formulas, not vibes).\n'
        '3. Compare at least two options with explicit trade-offs.\n'
        '4. List assumptions and what would invalidate them.\n'
        '5. Recommend one option and the review cadence after launch.\n\n'
        'A complete answer always includes costs and measurement.',
      _Discipline.cs => VuV2CsNotesCode.howToApply(topic, course),
      _Discipline.humanities || _Discipline.general =>
        '**How to apply $topic.**\n\n'
        '1. Restate the question or case.\n'
        '2. Define **$topic** in one precise sentence.\n'
        '3. Map it onto the facts/evidence.\n'
        '4. Explain the mechanism linking evidence → claim.\n'
        '5. Answer a likely objection.\n'
        '6. Conclude with what a competent analyst would do next.\n\n'
        'Application means transfer to a new case, not repeating the lecture title.',
    };
  }

  String explainWorkedExample(String topic, String course, String field) {
    return switch (this) {
      _Discipline.cs => VuV2CsNotesCode.workedExample(topic, course),
      _Discipline.health =>
        '**Worked example — applying $topic in $course.**\n\n'
        '**Scenario.** A learner meets a case where **$topic** matters.\n\n'
        '**Step A.** One-sentence problem statement.\n'
        '**Step B.** Three assessment priorities for **$topic**.\n'
        '**Step C.** One first action + rationale.\n'
        '**Step D.** Measurable endpoint for reassessment.\n'
        '**Step E.** One escalation sentence if red flags appear.\n'
        '**Step F.** One-line handoff.\n\n'
        '**Model reflection.** Vague language (“seems better”) fails; measurable endpoints pass.\n\n'
        '**Your turn.** Change one cue in the scenario and redo steps C–E.',
      _Discipline.law =>
        '**Worked example — IRAC for $topic.**\n\n'
        '**Facts (short).** A dispute arises that may trigger **$topic**.\n\n'
        '**Issue.** Does **$topic** apply / is liability (or the claim) established?\n'
        '**Rule.** State the doctrine and list elements.\n'
        '**Application.** For each element: “Because [fact], element is met/failed.”\n'
        '**Conclusion.** Party X prevails on **$topic** because element Y is decisive.\n\n'
        '**Model reflection.** A conclusion without element-by-element facts is incomplete.\n\n'
        '**Your turn.** Flip one material fact and re-run application.',
      _Discipline.stem || _Discipline.engineering =>
        '**Worked example — solving with $topic in $course.**\n\n'
        '**Prompt.** A standard problem asks you to use **$topic** to find an unknown.\n\n'
        '**Step A — Restate.** What is asked? What does success look like?\n'
        '**Step B — Givens.** List knowns, unknowns, constraints.\n'
        '**Step C — Principle.** Name the **$topic** relation/rule and define symbols.\n'
        '**Step D — Setup.** Write the equation/model before substituting numbers.\n'
        '**Step E — Compute.** Show intermediate results.\n'
        '**Step F — Check.** Units, magnitude, and a limit case.\n'
        '**Step G — Interpret.** Say what the number means in $field terms.\n\n'
        '**Model reflection.** Setup errors beat calculator errors — fix the model first.\n\n'
        '**Your turn.** Change one given and predict whether the answer increases or decreases.',
      _ =>
        '**Worked example — using $topic in $course.**\n\n'
        '**Prompt.** Apply **$topic** to a realistic $field case.\n\n'
        '**Step A.** Restate the question.\n'
        '**Step B.** Define **$topic** in one sentence.\n'
        '**Step C.** Select the relevant facts/evidence.\n'
        '**Step D.** Explain the mechanism linking evidence to conclusion.\n'
        '**Step E.** Answer one counterargument.\n'
        '**Step F.** State the conclusion and next action.\n\n'
        '**Model reflection.** If step D is missing, you have a claim without reasoning.\n\n'
        '**Your turn.** Swap in a new case and repeat B–F without notes.',
    };
  }

  String explainMistakes(String topic, String course, String field) {
    return switch (this) {
      _Discipline.cs => VuV2CsNotesCode.mistakes(topic, course),
      _Discipline.health =>
        '**Mistakes to avoid with $topic.**\n\n'
        '1. Acting before focused assessment.\n'
        '2. Vague endpoints (“looks better”) instead of measurable response.\n'
        '3. Missing red flags / delayed escalation.\n'
        '4. Incomplete handoff language.\n'
        '5. Treating one case as every case.\n'
        '6. Skipping reassessment after intervention.\n\n'
        'Safe practice on **$topic** is assess → act → reassess → communicate.',
      _Discipline.law =>
        '**Mistakes to avoid with $topic.**\n\n'
        '1. Conclusory labels without IRAC.\n'
        '2. Stating the rule but never applying facts.\n'
        '3. Inventing facts not in the record.\n'
        '4. Skipping the weakest element.\n'
        '5. Mixing policy arguments into the rule statement.\n'
        '6. Stopping at “sounds like **$topic**” without element checks.\n\n'
        'Grade yourself: every element has a cited fact.',
      _Discipline.stem || _Discipline.engineering =>
        '**Mistakes to avoid with $topic.**\n\n'
        '1. Memorizing the name without the governing rule.\n'
        '2. Dropping units / dimensional sense.\n'
        '3. Using the model outside its assumptions.\n'
        '4. Jumping to a number with no setup.\n'
        '5. No limit-case or sanity check.\n'
        '6. Confusing a lookalike concept with **$topic**.\n\n'
        'If the answer is impossible by units or limits, the setup is wrong — not the calculator.',
      _Discipline.business =>
        '**Mistakes to avoid with $topic.**\n\n'
        '1. Buzzwords with undefined metrics.\n'
        '2. Recommendations with only upsides.\n'
        '3. Hidden assumptions.\n'
        '4. No success measure after the decision.\n'
        '5. Analyzing without naming the decision owner.\n'
        '6. Treating correlation as causation in **$topic** claims.\n\n'
        'Executive-ready work states trade-offs and how you will know.',
      _ =>
        '**Mistakes to avoid with $topic.**\n\n'
        '1. Recognizing the title without a definition.\n'
        '2. Skipping the mechanism (“how it works”).\n'
        '3. Using one example as universal proof.\n'
        '4. Ignoring counterarguments or edge cases.\n'
        '5. Jumping to conclusions without steps.\n'
        '6. Applying **$topic** where a necessary condition fails.\n\n'
        'Fix: definition → mechanism → application → check.',
    };
  }

  String deepExplanation(String topic, String course, String field) {
    return switch (this) {
      _Discipline.stem =>
        'Start with the system. For **$topic** inside **$course**, name what is being '
        'studied (particles, organisms, fields, functions, datasets of measurements) and '
        'what is held constant versus free to change.\n\n'
        'Next, identify the **governing idea**. Is **$topic** a conservation law, a '
        'definitional identity, a derived theorem, an empirical relation, a model with '
        'limited domain, or a classification scheme? Say which — out loud — before you '
        'manipulate symbols.\n\n'
        'Then unpack the **mechanism or derivation** in layers:\n'
        '1. Intuition in plain language (what must be true and why).\n'
        '2. Formal statement with every symbol defined.\n'
        '3. Conditions of validity (assumptions you are allowed to use).\n'
        '4. Immediate consequences (limits, special cases, dimensional checks).\n'
        '5. How you would falsify a wrong application.\n\n'
        'Finally, reconnect to meaning. Every equation or diagram about **$topic** '
        'should answer: what would I measure, observe, or compute differently if this '
        'idea were false? That question separates memorization from scientific '
        'understanding in $field.',
      _Discipline.health =>
        'Clinical mastery of **$topic** in **$course** follows a fixed reasoning spine:\n\n'
        '1. **Frame the goal** — what does “done well” look like for this competency?\n'
        '2. **Gather structured data** — history, exam, vitals, labs, mental status, or '
        'functional cues — before intervening.\n'
        '3. **Generate a short differential or contributing-factor list** — what else '
        'could this be?\n'
        '4. **Prioritize** — life threats and high-risk findings first.\n'
        '5. **Act** — one clear first action with a stated rationale.\n'
        '6. **Reassess** — what measurable change tells you it worked?\n'
        '7. **Document / hand off** — precise language another $field professional can use.\n\n'
        '**$topic** is the place in that spine this lesson deepens. Do not skip '
        'assessment to “do something.” Do not use vague endpoints (“looks better”). Do '
        'not ignore escalation cues. Detail is safety.',
      _Discipline.law =>
        'Legal analysis of **$topic** in **$course** is IRAC with discipline:\n\n'
        '**Issue** — phrase a precise question the facts force you to answer.\n'
        '**Rule** — state the black-letter doctrine and list each element or factor.\n'
        '**Application** — march through elements using *only* facts in the record; '
        'never invent.\n'
        '**Conclusion** — hold for a party and identify the weakest / strongest element.\n\n'
        'Depth means you can explain *why* each element is met or unmet, anticipate the '
        'opponent’s best counterargument, and distinguish policy reasons from doctrine. '
        'If you cannot point to a fact for an element, you do not yet understand '
        '**$topic** well enough for exam conditions.',
      _Discipline.business =>
        'A rigorous treatment of **$topic** in **$course** answers five executive '
        'questions:\n\n'
        '1. **What decision does this unlock?** (pricing, hiring, capital, growth, risk)\n'
        '2. **What data or model do I need?** (definitions of metrics, sample, horizon)\n'
        '3. **What are the options and trade-offs?** (cost, speed, risk, brand, cash)\n'
        '4. **What could make the analysis wrong?** (bias, missing costs, bad incentives)\n'
        '5. **How will we know it worked?** (leading and lagging indicators)\n\n'
        'Write those answers for **$topic** in your notes. Business education fails when '
        'students recite frameworks without tying them to a decision under constraints.',
      _Discipline.cs =>
        'Treat **$topic** as a contract between inputs, process, and outputs.\n\n'
        '• Specify the **interface**: what enters, what exits, what is illegal input.\n'
        '• Specify the **invariant**: what remains true across steps.\n'
        '• Specify **complexity**: time and space in terms of input size.\n'
        '• Specify **failure modes**: nulls, empties, overflow, races, invalid states.\n'
        '• Specify **verification**: tests, invariants, or proofs that catch regressions.\n\n'
        'Then implement a mental walkthrough on a small example and an adversarial edge '
        'case. If you cannot predict the output of **$topic** on those cases, you are '
        'not ready to code or interview on it inside **$course**.',
      _Discipline.engineering =>
        'Engineering depth for **$topic** means you can move from requirement → model → '
        'calculation → check → design decision.\n\n'
        'State the physical / systems phenomenon, write the governing relation with '
        'units, list assumptions (linearity, steady state, ideal materials, etc.), '
        'compute a nominal result, apply a factor of safety or tolerance, and name the '
        'failure mode if assumptions break.\n\n'
        '**$topic** in **$course** is where that discipline is practiced. Skipping units, '
        'ignoring boundary conditions, or treating simulation output as truth without '
        'sanity checks is how real systems fail.',
      _Discipline.humanities =>
        'A deep account of **$topic** in **$course** has four layers:\n\n'
        '1. **Definition** — operational, not ornamental.\n'
        '2. **Mechanism or argument structure** — how causes, incentives, institutions, '
        'texts, or ideas produce outcomes.\n'
        '3. **Evidence** — cases, data, primary sources, or competing interpretations.\n'
        '4. **Evaluation** — trade-offs, stakeholders, uncertainty, and counterarguments.\n\n'
        'Write one paragraph per layer for **$topic**. If any layer is empty, your '
        'understanding is still slogan-level.',
      _Discipline.general =>
        'Explain **$topic** in three passes: (1) plain-language intuition, (2) formal '
        'structure used in **$course**, (3) application with explicit assumptions and a '
        'verification step. Repeat until you can do all three without notes.',
    };
  }

  String method(String topic, String course) {
    return 'Use this reusable procedure every time **$topic** appears in **$course**:\n\n'
        '**Step 1 — Restate.** Write one sentence: what is asked, and what success looks like.\n'
        '**Step 2 — Inventory.** List givens, unknowns, constraints, and forbidden moves.\n'
        '**Step 3 — Select principle.** Name the rule, model, statute element, clinical '
        'priority, algorithm, or framework that governs **$topic**.\n'
        '**Step 4 — Execute.** Show intermediate steps. Do not jump to a naked final answer.\n'
        '**Step 5 — Sanity-check.** Units, limits, ethics, edge cases, opposing counsel, '
        'patient safety — whichever fits your field.\n'
        '**Step 6 — Communicate.** Package the result so another professional can audit it.\n\n'
        'Tape this procedure above your desk. Speed comes after reliability.';
  }

  String rulesAndFormulas(String topic, String course) {
    return switch (this) {
      _Discipline.stem || _Discipline.engineering =>
        '**Governing statement.** Write the central relation or theorem for **$topic** '
        'with every symbol defined and SI (or course-standard) units listed.\n\n'
        '**Conservation / invariance checks.** Ask what must stay constant and what may '
        'change. Impossible answers often violate conservation, domain restrictions, or '
        'dimensional homogeneity.\n\n'
        '**Special cases.** Reduce **$topic** to a known limit (zero, infinity, '
        'equilibrium, linear approximation). If the limit disagrees with intuition, your '
        'setup is wrong.\n\n'
        '**Error propagation mindset.** Know which inputs **$topic** is most sensitive to '
        'inside **$course** problems — that is where careful measurement or assumption '
        'control matters most.',
      _Discipline.cs =>
        '**Correctness rule.** State preconditions, postconditions, and invariants for '
        '**$topic**.\n\n'
        '**Complexity rule.** Give Big-O time and space; justify from loops, recursion, '
        'or data-structure operations.\n\n'
        '**Safety rule.** Define behavior on empty, null, duplicate, and maximal inputs.\n\n'
        '**API rule.** Prefer clear names and total functions; partial functions must '
        'document failure modes used in **$course** exercises.',
      _Discipline.law =>
        '**Black-letter rule.** State the doctrine that controls **$topic** in one or two '
        'tight sentences.\n\n'
        '**Elements / factors.** Number them. On exams, missing an element is missing '
        'the issue.\n\n'
        '**Burden & standard.** Who must prove what, and to what standard?\n\n'
        '**Remedies / consequences.** What follows if the rule is satisfied or failed?\n\n'
        'Keep policy arguments labeled as policy — do not smuggle them into the rule '
        'statement for **$course**.',
      _Discipline.health =>
        '**Assessment before action.** For **$topic**, name the minimum data set you '
        'must gather.\n\n'
        '**First-line action rule.** State the preferred first intervention and why.\n\n'
        '**Red-flag rule.** List cues that force escalation inside **$course** standards.\n\n'
        '**Reassessment rule.** Define the endpoint that proves the action worked.\n\n'
        '**Communication rule.** Prefer measurable language suitable for notes and handoff.',
      _Discipline.business =>
        '**Decision rule.** Clarify the decision **$topic** informs in **$course**.\n\n'
        '**Metric definitions.** Write formulas for every KPI you cite; ambiguous metrics '
        'are not analytics.\n\n'
        '**Trade-off rule.** Every option has a cost — list at least two.\n\n'
        '**Assumption log.** Write assumptions explicitly; unstated assumptions become '
        'hidden risk.\n\n'
        '**Feedback rule.** Define the review cadence after the decision ships.',
      _ =>
        '**Core principle.** State the main rule that makes **$topic** work inside '
        '**$course**.\n\n'
        '**Conditions of use.** When does the principle apply, and when must you switch '
        'frameworks?\n\n'
        '**Quality bar.** What would a skeptical examiner require as justification?',
    };
  }

  String workedExample(String topic, String course, int n) {
    if (n == 1) {
      return '**Scenario.** A learner in **$course** faces a standard problem involving '
          '**$topic**.\n\n'
          '**Restate.** “I must use **$topic** to reach a justified conclusion from the '
          'given information.”\n\n'
          '**Inventory.** List three givens and one unknown. Cross out anything irrelevant.\n\n'
          '**Principle.** Name the governing idea for **$topic** in one line.\n\n'
          '**Execution.**\n'
          '1. Set up the representation (equation, IRAC outline, assessment table, '
          'pseudocode, decision matrix — as fits the field).\n'
          '2. Carry out the middle steps with labels — no silent arithmetic or silent leaps.\n'
          '3. Box the intermediate result and interpret it in words.\n\n'
          '**Verify.** Check a limit case or opposing explanation. If it fails, rewind to '
          'the principle.\n\n'
          '**Communicate.** Write a two-sentence answer a grader (or supervisor) can audit.\n\n'
          'Cover this example and reproduce it from memory before Example 2.';
    }
    return '**Harder variant.** Change one material condition in the Example 1 scenario '
        '(a constraint, a red flag, an edge-case input, a conflicting precedent, or a '
        'missing measurement).\n\n'
        '**Your task.**\n'
        '• Decide whether **$topic** still applies.\n'
        '• If yes, re-run the method and show what changes in the result.\n'
        '• If no, explain which necessary condition failed and what alternative tool from '
        '**$course** you would use instead.\n\n'
        '**Model reflection.** Strong students do not force **$topic** onto every prompt. '
        'They recognize scope. That discrimination is exactly what course exams test.';
  }

  String misconceptions(String topic) {
    return '1. **“If it sounds like $topic, it is $topic.”**\n'
        '   Correction: check necessary conditions. Lookalikes are the #1 exam trap.\n\n'
        '2. **“Memorizing the definition is enough.”**\n'
        '   Correction: definition without application fails transfer questions.\n\n'
        '3. **“Skipping justification saves time.”**\n'
        '   Correction: unjustified answers lose method points even when luckily right.\n\n'
        '4. **“One example proves the general rule.”**\n'
        '   Correction: examples illustrate; principles and evidence generalize.\n\n'
        '5. **“I can ignore edge cases until later.”**\n'
        '   Correction: edge cases reveal whether you understood **$topic** or only the '
        'happy path.\n\n'
        'Rewrite each correction in your own words. If you cannot, reread the Deep '
        'explanation section.';
  }

  String applications(String topic, String field) {
    return '**Professional practice.** In $field, **$topic** shows up when someone must '
        'decide, design, diagnose, argue, build, or measure under constraints. Write one '
        'paragraph describing a realistic workplace moment that requires **$topic**.\n\n'
        '**Public / societal impact.** Mistakes about **$topic** can waste resources, '
        'harm people, break systems, or mislead policy. Name one harm that competence '
        'prevents.\n\n'
        '**Transfer.** List two other courses or labs where **$topic** reappears. Degree '
        'roadmaps intentionally recycle core ideas — notice the recycle.\n\n'
        '**Portfolio move.** Turn your worked example into a short artifact (memo, lab '
        'note, code snippet, IRAC, care plan outline) you could show in an interview.';
  }

  String advanced(String topic, String course) {
    return 'Once the foundations of **$topic** are solid, stretch with:\n\n'
        '• A competing model or minority doctrine and why the course default usually wins.\n'
        '• A research paper, standard, guideline, or classic case that sharpened **$topic**.\n'
        '• A computational, clinical, courtroom, or market simulation that stresses the idea.\n'
        '• An open question in **$course** that specialists still debate.\n\n'
        'Advanced work is optional for first-pass credit but excellent exam insurance: '
        'students who know the frontier also know the center.';
  }

  String connections(String topic, String course, String track) {
    return 'Inside the **$track** roadmap, **$topic** is a node — not an island.\n\n'
        '**Looks backward.** Which earlier lessons in **$course** supplied vocabulary or '
        'skills you reused here? Name two.\n\n'
        '**Looks forward.** Which later lessons will assume you already own **$topic**? '
        'If you leave a fuzzy gap now, those later chapters will feel impossible.\n\n'
        '**Looks sideways.** Related faculties may use different words for similar '
        'structure (e.g., conservation, duty, invariant, KPI). Translating across fields '
        'is a mark of a strong Virtual University student.\n\n'
        'Before the course final exam, draw a mini-map: prior topics → **$topic** → next '
        'topics. Study the arrows, not only the boxes.';
  }

  List<VuV2Mcq> extraMcqs({
    required String topic,
    required String course,
    required String faculty,
    required bool examMode,
  }) {
    final String tag = examMode ? ' [Exam]' : '';
    return switch (this) {
      _Discipline.stem || _Discipline.engineering => <VuV2Mcq>[
          VuV2Mcq(
            id: 'units',
            prompt: 'In a quantitative "$topic" problem in $course, you should:$tag',
            choices: <String>[
              'Drop units to save time',
              'Track units / dimensions and reject dimensionally impossible answers',
              'Invent constants not given',
              'Skip limit-case checks',
            ],
            correctIndex: 1,
            explanation: 'Dimensional sense catches most setup errors early.',
          ),
          VuV2Mcq(
            id: 'assum',
            prompt: 'Assumptions in "$topic" matter because:$tag',
            choices: <String>[
              'They never affect validity',
              'They define when the model or derivation may be used safely',
              'They replace the need for definitions',
              'They are only for footnotes',
            ],
            correctIndex: 1,
            explanation: 'Out-of-assumption use is a classic exam and lab failure mode.',
          ),
        ],
      _Discipline.health => <VuV2Mcq>[
          VuV2Mcq(
            id: 'safety',
            prompt: 'Safety practice for "$topic" in $faculty requires:$tag',
            choices: <String>[
              'Acting before any assessment',
              'Recognizing red flags and escalating when indicated',
              'Using only vague endpoints',
              'Avoiding documentation',
            ],
            correctIndex: 1,
            explanation: 'Early recognition and escalation prevent preventable harm.',
          ),
          VuV2Mcq(
            id: 'reas',
            prompt: 'After an intervention tied to "$topic", best next step is:$tag',
            choices: <String>[
              'Assume success',
              'Reassess a measurable endpoint and document',
              'Stop communicating with the team',
              'Skip handoff details',
            ],
            correctIndex: 1,
            explanation: 'Closing the loop is part of competent care.',
          ),
        ],
      _Discipline.law => <VuV2Mcq>[
          VuV2Mcq(
            id: 'irac',
            prompt: 'Strong exam answers on "$topic" must:$tag',
            choices: <String>[
              'State a conclusion with no rule',
              'Apply each element to specific facts (IRAC discipline)',
              'Invent helpful facts',
              'Ignore the weakest element',
            ],
            correctIndex: 1,
            explanation: 'Application to facts — element by element — is the skill.',
          ),
        ],
      _Discipline.cs => <VuV2Mcq>[
          VuV2Mcq(
            id: 'edgecs',
            prompt: 'When coding concepts around "$topic", you should:$tag',
            choices: <String>[
              'Ignore empty/null inputs',
              'Define and test edge cases explicitly',
              'Skip complexity analysis always',
              'Avoid writing invariants',
            ],
            correctIndex: 1,
            explanation: 'Edge cases and invariants separate toy demos from real code.',
          ),
        ],
      _Discipline.business => <VuV2Mcq>[
          VuV2Mcq(
            id: 'trade',
            prompt: 'A complete "$topic" recommendation in $course includes:$tag',
            choices: <String>[
              'Only upsides',
              'Explicit trade-offs, assumptions, and success metrics',
              'No decision owner',
              'Undefined KPIs',
            ],
            correctIndex: 1,
            explanation: 'Executive-ready work names costs, assumptions, and measurement.',
          ),
        ],
      _ => <VuV2Mcq>[
          VuV2Mcq(
            id: 'evidence',
            prompt: 'Claims about "$topic" improve when you:$tag',
            choices: <String>[
              'Rely on a single unchecked anecdote',
              'Use evidence, note uncertainty, and address a counterargument',
              'Avoid definitions',
              'Ignore stakeholders',
            ],
            correctIndex: 1,
            explanation: 'University-level claims are evidenced and contested honestly.',
          ),
        ],
    };
  }
}
