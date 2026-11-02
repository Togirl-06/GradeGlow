import 'dart:math' as math;

import '../models/world_curriculum_program.dart';

/// Offline lecture + quiz content for world-curriculum subjects
/// (Environmental Science, Political Science, and similar shells).
abstract final class WorldCurriculumLessonContent {
  static String lecture(WorldSubjectMeta meta, WorldLessonPath path) {
    final String topic = path.topic.title;
    final String course = path.course.title;
    final String field = meta.title;

    return '''
# $topic

**$course · $field · Virtual University**

## Learning outcomes
1. Define **$topic** accurately in the language of $field.
2. Explain how **$topic** connects to the bigger story of **$course**.
3. Apply **$topic** to one realistic case, policy, or problem.
4. Spot two common misconceptions and correct them.
5. Produce a short peer teaching summary (≤2 minutes).

## Core explanation
**$topic** is a building block of **$course**. Experts treat it as a system of
definitions, mechanisms (or causal pathways), evidence, and trade-offs — not a
single buzzword. Start with a precise definition, then map causes → effects →
levers for action.

## Framework you can reuse
1. **Define** — what exactly is **$topic**?
2. **Locate** — where does it appear in **$course** and in the real world?
3. **Mechanisms** — what processes drive outcomes?
4. **Evidence** — what data, cases, or models support the claim?
5. **Trade-offs** — who benefits, who bears cost, what is uncertain?
6. **Action** — what would a competent practitioner do next?

## Worked mini-case
Imagine a decision-maker facing a problem involving **$topic** inside **$course**.
- Restate the problem in one sentence.
- Name two competing explanations.
- Choose one intervention or analytic move.
- State how you would evaluate success within 30–90 days.

## Common mistakes
• Confusing correlation with causation.
• Using jargon without operational definitions.
• Ignoring scale (local vs national vs global).
• Treating one case study as universal proof.
• Skipping stakeholders who experience harms.

## Study checklist
□ Define **$topic** without notes  
□ Draw a simple cause → effect map  
□ Give one real-world example from $field  
□ Name one counterargument  
□ Write three quiz-style questions for yourself  

## Closing
Mastery means you can teach **$topic**, apply it, and defend your reasoning under
pushback. Complete interactive practice, then pass the quiz to earn lesson credit.
''';
  }

  static List<WorldMcq> quizFor(
    WorldSubjectMeta meta,
    WorldLessonPath path, {
    int seed = 0,
  }) {
    final String topic = path.topic.title;
    final String course = path.course.title;
    final math.Random rng = math.Random(
      seed ^ topic.hashCode ^ meta.subjectId.hashCode,
    );

    final List<WorldMcq> bank = <WorldMcq>[
      WorldMcq(
        prompt: 'Best first step when studying "$topic"?',
        choices: <String>[
          'Memorize buzzwords only',
          'Define the term and locate it inside $course',
          'Skip examples',
          'Ignore counterarguments',
        ],
        correctIndex: 1,
      ),
      WorldMcq(
        prompt: 'A strong application of "$topic" includes:',
        choices: <String>[
          'One vague opinion with no evidence',
          'A concrete case plus a clear evaluation criterion',
          'Copying a definition without context',
          'Avoiding any trade-off discussion',
        ],
        correctIndex: 1,
      ),
      WorldMcq(
        prompt: 'Which pitfall most often undermines analysis of "$topic"?',
        choices: <String>[
          'Confusing correlation with causation',
          'Using precise definitions',
          'Naming stakeholders',
          'Checking evidence quality',
        ],
        correctIndex: 0,
      ),
      WorldMcq(
        prompt: 'When explaining "$topic" to a peer, prioritize:',
        choices: <String>[
          'Long jargon lists',
          'Definition → mechanism → example → trade-off',
          'Only history with no application',
          'Only opinions with no structure',
        ],
        correctIndex: 1,
      ),
      WorldMcq(
        prompt: 'Evidence quality for "$topic" improves when you:',
        choices: <String>[
          'Rely on a single anecdote',
          'Compare multiple sources and note uncertainty',
          'Ignore conflicting data',
          'Treat social media as definitive',
        ],
        correctIndex: 1,
      ),
      WorldMcq(
        prompt: 'A useful study check for "$topic" is:',
        choices: <String>[
          'Can I teach it in two minutes with an example?',
          'Did I highlight every page once?',
          'Did I avoid practice questions?',
          'Did I memorize without understanding?',
        ],
        correctIndex: 0,
      ),
    ];

    final List<WorldMcq> picked = List<WorldMcq>.from(bank)..shuffle(rng);
    return picked.take(5).map((WorldMcq q) => q.shuffled(rng)).toList();
  }
}

class WorldMcq {
  const WorldMcq({
    required this.prompt,
    required this.choices,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> choices;
  final int correctIndex;

  WorldMcq shuffled(math.Random rng) {
    final List<int> order = List<int>.generate(choices.length, (int i) => i)
      ..shuffle(rng);
    return WorldMcq(
      prompt: prompt,
      choices: order.map((int i) => choices[i]).toList(),
      correctIndex: order.indexOf(correctIndex),
    );
  }
}
