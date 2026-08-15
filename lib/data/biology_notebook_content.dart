/// Textbook-quality biology notebook sections for each lesson.
class BiologyNotebookSection {
  const BiologyNotebookSection({required this.title, required this.body});

  final String title;
  final String body;
}

class BiologyNotebookContent {
  BiologyNotebookContent._();

  static List<BiologyNotebookSection> build({
    required String topic,
    required String course,
  }) {
    return <BiologyNotebookSection>[
      BiologyNotebookSection(
        title: 'Learning Objectives',
        body:
            'By the end of this chapter on $topic ($course), you will define core terms, '
            'explain mechanisms at molecular and organismal scales, relate structures to functions, '
            'and apply concepts in laboratory and clinical or ecological scenarios.',
      ),
      BiologyNotebookSection(
        title: 'Clear Explanation',
        body:
            '$topic is best understood by asking: what structures are involved, what process happens, '
            'what energy or information drives it, and what happens when it fails? '
            'Build from definition → mechanism → evidence → application.',
      ),
      BiologyNotebookSection(
        title: 'Key Structures & Diagrams',
        body:
            'Sketch the primary diagram for $topic. Label every part. Compare similar structures '
            '(e.g., plant vs animal cell, artery vs vein, DNA vs RNA). '
            'Use tables comparing structure and function when two or more systems are related.',
      ),
      BiologyNotebookSection(
        title: 'Mechanism Step-by-Step',
        body:
            'Write the sequence for $topic as numbered steps. Include what enters, what is transformed, '
            'and what exits. Note regulation points (feedback, enzymes, hormones, gene switches).',
      ),
      BiologyNotebookSection(
        title: 'Clinical & Real-World Relevance',
        body:
            'Connect $topic to disease, biotechnology, agriculture, or conservation. '
            'University biology always asks: so what? How does this save a patient, fix a crop, or explain a population change?',
      ),
      BiologyNotebookSection(
        title: 'Common Misconceptions',
        body:
            '• Confusing correlation with causation in biological systems\n'
            '• Mixing DNA, RNA, and protein roles\n'
            '• Thinking evolution “wants” a goal\n'
            '• Ignoring levels of organization (molecule → cell → organ → organism → ecosystem)',
      ),
      BiologyNotebookSection(
        title: 'Mnemonics & Memory Aids',
        body:
            'Create one mnemonic tied specifically to $topic. Pair it with a sketch and an example from lecture.',
      ),
      BiologyNotebookSection(
        title: 'Summary Box',
        body:
            '$topic — structures, process, regulation, failure modes, and one application in $course.',
      ),
      BiologyNotebookSection(
        title: 'Practice & Flashcards',
        body:
            '1. Define $topic in one precise paragraph.\n'
            '2. Draw and label the core diagram.\n'
            '3. List three steps of the mechanism.\n'
            '4. Give one clinical or ecological example.\n'
            '5. Flashcard: front = “What happens if $topic fails?” back = write your answer.',
      ),
    ];
  }
}
