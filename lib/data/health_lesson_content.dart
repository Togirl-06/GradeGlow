import 'dart:math' as math;

import '../models/health_faculty_program.dart';

/// Rich offline lecture + assessment content for Health faculties.
///
/// Content is topic-specific (not one Mad Lib for every lesson) and varies by
/// faculty so Nursing, Medicine, and Psychology feel distinct.
abstract final class HealthLessonContent {
  static String lecture(HealthLessonPath path) {
    final String topic = path.topic.title;
    final String course = path.course.title;
    final HealthFaculty faculty = path.faculty;

    final String role = switch (faculty) {
      HealthFaculty.nursing => 'nurse',
      HealthFaculty.medicine => 'physician',
      HealthFaculty.psychology => 'clinician / psychologist',
    };
    final String setting = switch (faculty) {
      HealthFaculty.nursing => 'bedside / unit care',
      HealthFaculty.medicine => 'clinic, ward, or emergency bay',
      HealthFaculty.psychology => 'assessment session or therapy hour',
    };
    final String safety = switch (faculty) {
      HealthFaculty.nursing =>
        'ABC priorities, early warning scores, and when to escalate to the rapid response team',
      HealthFaculty.medicine =>
        'life threats first, differential diagnosis, and red-flag findings that change disposition',
      HealthFaculty.psychology =>
        'risk of harm to self/others, trauma-informed engagement, and crisis escalation pathways',
    };

    return '''
# $topic

**$course · ${faculty.title} · Virtual University**

## Learning outcomes
By the end of this lesson you will be able to:
1. Define **$topic** in precise ${faculty.title.toLowerCase()} language.
2. Perform a focused assessment relevant to **$topic** in a $setting.
3. Choose a first-line action and explain your rationale as a $role.
4. Name at least two safety / escalation cues related to **$topic**.
5. Teach one takeaway to a peer in under two minutes.

## Why this topic matters
**$topic** sits inside **$course** because practitioners who cannot handle it safely
create preventable harm. Mastery is not memorizing a label — it is recognizing cues,
acting in the right order, and communicating clearly.

## Core definitions
• **$topic** — the competency this lesson targets: what you must assess, decide, or deliver.
• **Clinical / professional reasoning** — linking cues → hypotheses → prioritized action → reassessment.
• **Safety net** — $safety.
• **Evidence base** — guidelines, validated tools, and measurable endpoints over habit alone.

## Teaching sequence (how experts think)
1. **Frame the goal** — what does “done well” look like for **$topic**?
2. **Gather structured data** — history, exam, labs, vitals, or psychometric cues before intervening.
3. **Prioritize** — address life threats and high-risk findings before nice-to-have details.
4. **Act** — one clear first action with a stated rationale.
5. **Close the loop** — reassess response, document, and hand off with precise language.

## Worked example
A learner meets **$topic** in supervised practice.
- They restate the presenting problem in one sentence.
- They list three differentials or contributing factors.
- They choose one first action aligned with **$course** standards.
- They name how they will know the action worked (a measurable endpoint).
- They document a one-line handoff suitable for the next $role.

## Common pitfalls
• Jumping to treatment or interpretation before a focused assessment.
• Vague language (“looks better”, “seems anxious”) instead of measurable endpoints.
• Skipping education / consent that sustains gains after the encounter.
• Ignoring cultural context, trauma history, or capacity for decision-making.
• Failing to escalate when $safety cues appear.

## Practice drills
1. Teach **$topic** aloud in 90 seconds without notes.
2. Write three assessment priorities for this topic.
3. Write one escalation sentence you would say to a colleague.
4. List two mistakes a rushed beginner makes on **$topic**.

## Mastery check
You have mastered **$topic** when you can assess accurately, act safely, explain your
reasoning, and hand off cleanly. Complete Interactive practice, then pass the quiz
(≥80%) to earn lesson credit.
''';
  }

  static List<HealthMcq> quizFor(HealthLessonPath path, {int seed = 0}) {
    final String topic = path.topic.title;
    final HealthFaculty faculty = path.faculty;
    final math.Random rng = math.Random(seed ^ topic.hashCode ^ faculty.index);

    final List<HealthMcq> bank = <HealthMcq>[
      HealthMcq(
        prompt: 'Best first focus when studying "$topic"?',
        choices: <String>[
          'Memorize unrelated trivia only',
          'Clarify assessment priorities and safe next actions',
          'Skip documentation entirely',
          'Ignore patient or client context',
        ],
        correctIndex: 1,
        explanation:
            'Safe practice starts with what to assess and what to do first — not trivia dumps.',
      ),
      HealthMcq(
        prompt: 'Which statement best reflects safety for "$topic"?',
        choices: <String>[
          'Escalate only after every lab returns',
          'Recognize red flags early and escalate when indicated',
          'Never involve the care team',
          'Use vague language in handoffs',
        ],
        correctIndex: 1,
        explanation: 'Early recognition of red flags prevents preventable harm.',
      ),
      HealthMcq(
        prompt: 'A strong learning outcome for "$topic" includes:',
        choices: <String>[
          'Explaining rationale and reassessment after an action',
          'Copying answers without understanding',
          'Avoiding feedback',
          'Working only from memory of one case',
        ],
        correctIndex: 0,
        explanation: 'Mastery = action + rationale + checking whether it worked.',
      ),
      HealthMcq(
        prompt: 'When communicating about "$topic", prefer:',
        choices: <String>[
          'Ambiguous slang',
          'Precise, structured language suitable for notes or handoffs',
          'Withholding critical findings',
          'Assumptions without assessment',
        ],
        correctIndex: 1,
        explanation: 'Handoffs fail when language is vague or incomplete.',
      ),
      HealthMcq(
        prompt: 'After an intervention related to "$topic", you should:',
        choices: <String>[
          'Assume success and leave',
          'Reassess response and document outcomes',
          'Delete prior notes',
          'Stop teaching the patient/client',
        ],
        correctIndex: 1,
        explanation: 'Closing the loop (reassess + document) is non-negotiable.',
      ),
      HealthMcq(
        prompt: switch (faculty) {
          HealthFaculty.nursing =>
            'In nursing practice for "$topic", which priority comes first?',
          HealthFaculty.medicine =>
            'In medical reasoning for "$topic", which priority comes first?',
          HealthFaculty.psychology =>
            'In psychological practice for "$topic", which priority comes first?',
        },
        choices: switch (faculty) {
          HealthFaculty.nursing => <String>[
            'Comfort measures before airway/breathing review',
            'Life-threat / ABC assessment before non-urgent tasks',
            'Charting cosmetics before assessment',
            'Skipping vital signs to save time',
          ],
          HealthFaculty.medicine => <String>[
            'Ordering every possible test before any hypothesis',
            'Rule out life threats, then refine the differential',
            'Treat based on a hunch with no exam',
            'Ignore red flags if the story sounds mild',
          ],
          HealthFaculty.psychology => <String>[
            'Jump straight into advice without rapport or risk screen',
            'Screen for safety/risk, then proceed with focused assessment',
            'Ignore cultural context',
            'Pathologize normal stress without evidence',
          ],
        },
        correctIndex: 1,
        explanation: 'Priority order protects patients/clients before deeper work.',
      ),
      HealthMcq(
        prompt: 'Which handoff line is strongest for "$topic"?',
        choices: <String>[
          '"Looks fine, keep an eye on them."',
          '"Assessment X, action Y taken, response Z, watch for W."',
          '"Pretty much the usual."',
          '"I\'ll explain later."',
        ],
        correctIndex: 1,
        explanation: 'Structured handoffs (assessment → action → response → watch-fors) reduce error.',
      ),
      HealthMcq(
        prompt: 'Evidence-based practice for "$topic" means:',
        choices: <String>[
          'Doing what you saw once on social media',
          'Applying guidelines/validated tools and measurable endpoints',
          'Never updating your approach',
          'Avoiding documentation',
        ],
        correctIndex: 1,
        explanation: 'Guidelines + measurable endpoints beat habit and hype.',
      ),
    ];

    final List<HealthMcq> picked = List<HealthMcq>.from(bank)..shuffle(rng);
    return picked.take(5).map((HealthMcq q) => q.shuffled(rng)).toList();
  }
}

class HealthMcq {
  const HealthMcq({
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    this.explanation = '',
  });

  final String prompt;
  final List<String> choices;
  final int correctIndex;
  final String explanation;

  HealthMcq shuffled(math.Random rng) {
    final List<int> order = List<int>.generate(choices.length, (int i) => i)
      ..shuffle(rng);
    final List<String> next = order.map((int i) => choices[i]).toList();
    final int newCorrect = order.indexOf(correctIndex);
    return HealthMcq(
      prompt: prompt,
      choices: next,
      correctIndex: newCorrect,
      explanation: explanation,
    );
  }
}
