/// Offline full textbook chapters for AI Professor (non-summary).
library;
import 'ai_professor_chapter_navigation.dart';

class AiProfessorOfflineChapter {
  AiProfessorOfflineChapter._();

  static String cs({
    required String courseName,
    required String topicTitle,
  }) =>
      _build(
        chapterTitle: topicTitle,
        subtitle: '$courseName · Computer Science · Virtual University',
        introduction:
            '**$topicTitle** is a core topic in **$courseName**. '
            'This chapter gives the full textbook treatment: definitions, algorithms or syntax rules, '
            'complexity or performance notes, worked examples with code, common bugs, and practice problems. '
            'A student should master the topic using only this chapter.',
        history:
            'Computer science formalized **$topicTitle** as hardware and software scaled. '
            'From early machine code to modern frameworks, the underlying ideas remain essential for '
            'professional development, systems design, and technical interviews.',
        definitions: <String>[
          '**$topicTitle** — the central concept taught in this chapter; define it in precise technical language.',
          '**Input / Output** — what the program or algorithm receives and produces.',
          '**Invariant** — a condition that remains true across steps of an algorithm or loop.',
          '**Edge case** — unusual input that breaks naive implementations.',
        ],
        coreConcepts:
            'Teach **$topicTitle** in layers: intuition → formal rule → implementation → verification. '
            'Always state time and space complexity when discussing algorithms.',
        formulas:
            r'Pseudocode and complexity notation (e.g., $O(n)$, $O(n \log n)$) belong in this section with symbol definitions.',
        visuals:
            '```\nData flow (conceptual)\n  Input → Process ($topicTitle) → Output\n```',
        workedExamples:
            '### Example 1 — Walkthrough\n'
            '**Problem:** Apply **$topicTitle** to a concrete input.\n\n'
            '**Given:** State the input.\n\n'
            '**Steps:** Number each step.\n\n'
            '**Code:** Include a fenced ``` code block.\n\n'
            '**Answer:** State the output and verify.\n\n'
            '### Example 2 — Edge case\n'
            'Show what happens when input is empty, null, or maximal size.',
        commonErrors:
            '❌ **Mistake:** Coding before defining the problem.\n'
            '✅ **Correct:** Restate input, output, and invariants first.\n\n'
            '❌ **Mistake:** Ignoring complexity.\n'
            '✅ **Correct:** State Big-O and justify with the loop structure.',
        applications:
            '**Software engineering:** production systems and APIs.\n'
            '**Interviews:** whiteboard and take-home problems.\n'
            '**Open source:** reading real implementations of **$topicTitle**.',
        advanced: 'Extensions: parallel versions, cache effects, language-specific idioms, and formal verification.',
        practice:
            '### Concept questions\n- Define **$topicTitle**.\n- Name one edge case.\n\n'
            '### Coding problems\n- Implement from scratch.\n- Optimize time or space.\n\n'
            '### Research\n- How is this topic used in a major open-source project?',
        checklist: <String>[
          'Define **$topicTitle** without notes',
          'Implement a working solution',
          'Analyze time and space complexity',
          'Explain one edge case and fix',
          'Complete practice problems',
        ],
      );

  static String health({
    required String facultyTitle,
    required String courseTitle,
    required String topicTitle,
    required String lectureBody,
  }) {
    return '''
# $topicTitle

**$facultyTitle · $courseTitle · Virtual University**

$lectureBody

---
_Offline chapter ready. When online, your AI Professor can expand this into a full live lecture and answer questions._
''';
  }

  static String engineering({
    required String majorName,
    required String courseTitle,
    required String topicTitle,
  }) =>
      _build(
        chapterTitle: topicTitle,
        subtitle: '$majorName · $courseTitle · Virtual University Engineering',
        introduction:
            '**$topicTitle** in **$courseTitle** ($majorName) governs how engineers predict whether a design '
            'will perform safely under real loads. This chapter covers definitions, governing equations, '
            'factor of safety, worked numerical examples, failure modes, and design applications.',
        history:
            'Engineering practice for **$topicTitle** evolved from empirical rules to codified standards '
            'after industrial failures demonstrated the cost of designing at the margin with no safety factor.',
        definitions: <String>[
          '**Load** — demand placed on a member or system (force, moment, pressure, etc.).',
          '**Capacity** — maximum resistance the design can provide before failure.',
          '**Factor of safety** — ratio of capacity to expected load (or similar margin definition).',
          '**$topicTitle** — the specific quantity or method central to this lesson.',
        ],
        coreConcepts:
            'Engineering design compares **demand** to **capacity** with margin. '
            'Every calculation requires SI units, free-body or control-volume diagrams, and a stated failure mode.',
        formulas:
            'State governing relations for **$topicTitle**. For each: define symbols, SI units, assumptions, and when the model fails.',
        visuals:
            '```\nFree-body sketch\n  Applied load ↓\n  |——member——|\n  Reaction ↑\n```',
        workedExamples:
            '### Example 1 — Design check\n'
            '**Problem:** Given load and geometry, check whether the design is safe.\n\n'
            '**Given:** List values with units.\n\n'
            '**Equation:** Governing relation.\n\n'
            '**Calculation:** Substitute and solve.\n\n'
            '**Answer:** Compare to allowable; state factor of safety.\n\n'
            '### Example 2 — Redesign\n'
            'If the member fails, which variable (material, area, support) would you change first?',
        commonErrors:
            '❌ **Mistake:** Using formulas without a diagram.\n'
            '✅ **Correct:** Draw the system and label every force.\n\n'
            '❌ **Mistake:** FoS = 1 with no uncertainty margin.\n'
            '✅ **Correct:** Use codes and realistic load variability.',
        applications:
            '**Civil:** bridges and buildings.\n'
            '**Mechanical:** machines and thermal systems.\n'
            '**Aerospace:** weight-limited structures.\n'
            '**Biomedical:** implants and devices.',
        advanced: 'Nonlinear materials, dynamic loading, fatigue, and probabilistic design methods.',
        practice:
            '### Concept — Define load vs capacity.\n'
            '### Calculation — Numerical design check for **$topicTitle**.\n'
            '### Design — Propose a safer alternative configuration.',
        checklist: <String>[
          'Draw a correct diagram',
          'List units for every quantity',
          'Compute demand and capacity',
          'State factor of safety',
          'Identify the weakest link',
        ],
      );

  static String law({
    required String courseTitle,
    required String lessonTitle,
    required String hook,
    required String question,
    required String doctrine,
    required List<String> elements,
    AiProfessorChapterNavigation? nav,
  }) {
    final String body = _build(
      chapterTitle: lessonTitle,
      subtitle: '$courseTitle · Law · Virtual University',
      introduction:
          '$hook\n\n'
          'This chapter teaches **$lessonTitle** as a complete casebook-style lesson: '
          'black-letter rules, element-by-element analysis, policy rationale, worked application to facts, '
          'exam hypotheticals, and common student errors. Read every section in order before the next chapter.',
      history:
          'The doctrine of **$lessonTitle** developed through statutes, common-law evolution, and landmark cases. '
          'Understanding its history clarifies why courts balance the competing policies below.\n\n'
          '**Central question for this chapter:** $question',
      definitions: _lawDefinitions(lessonTitle, doctrine, elements),
      coreConcepts: '$doctrine\n\n'
          '**Element-by-element framework:** Courts analyze **$lessonTitle** by testing each element in order. '
          'If any required element fails, the claim or defense typically fails on that ground.',
      formulas: _lawRules(lessonTitle, elements, doctrine),
      visuals: _lawDiagrams(lessonTitle),
      workedExamples: _lawWorkedExamples(
        lessonTitle: lessonTitle,
        hook: hook,
        question: question,
        doctrine: doctrine,
        elements: elements,
      ),
      commonErrors: _lawCommonErrors(elements),
      applications:
          '**Litigation:** motions, trial strategy, and jury instructions.\n'
          '**Counseling:** advising clients on risk before conduct occurs.\n'
          '**Policy:** legislative reform and amicus briefing.\n'
          '**Exam practice:** issue-spotting under time pressure using IRAC.',
      advanced: 'Circuit splits, scholarly criticism, and reform proposals for **$lessonTitle**. '
          'Compare majority vs dissenting approaches in leading cases.',
      practice: _lawPractice(lessonTitle, elements, question),
      checklist: <String>[
        'Recite the rule for **$lessonTitle** accurately',
        'List every element: ${elements.join(', ')}',
        'Apply each element to facts using because/therefore',
        'Answer: $question',
        'Anticipate the strongest counterargument',
        'Complete one new hypothetical without notes',
      ],
    );
    if (nav == null) return body;
    return AiProfessorChapterNavigation.wrapChapter(
      courseTitle: courseTitle,
      topicTitle: lessonTitle,
      chapterBody: body,
      nav: nav,
    );
  }

  static List<String> _lawDefinitions(String lessonTitle, String doctrine, List<String> elements) {
    return elements.map((String e) {
      return '**$e** — An essential element of **$lessonTitle**. '
          'In application: identify facts in the record that satisfy or fail **$e**, '
          'then explain why under the governing rule: $doctrine';
    }).toList();
  }

  static String _lawRules(String lessonTitle, List<String> elements, String doctrine) {
    final StringBuffer buf = StringBuffer('**Black-letter rule:** $doctrine\n\n**Elements:**\n');
    for (int i = 0; i < elements.length; i++) {
      buf.writeln('${i + 1}. **${elements[i]}** — required for **$lessonTitle**.');
    }
    buf.writeln('\n**Balancing test / multi-factor analysis:** When the rule is not strict liability, '
        'weigh factors explicitly and state which side each factor favors.');
    return buf.toString().trim();
  }

  static String _lawDiagrams(String lessonTitle) {
    return '### Diagram: IRAC structure\n\n'
        '```\nIssue → Rule → Application → Conclusion\n```\n\n'
        '### Diagram: Element checklist for $lessonTitle\n\n'
        '```\nFacts → Element 1? → Element 2? → … → Holding\n```\n\n'
        'Sketch this flow from memory before every exam answer.';
  }

  static String _lawWorkedExamples({
    required String lessonTitle,
    required String hook,
    required String question,
    required String doctrine,
    required List<String> elements,
  }) {
    final String elementApplication = elements
        .map((String e) => '- **$e:** Apply the rule to the hook facts — cite specific facts that satisfy or fail this element.')
        .join('\n');
    return '### Worked application — hook facts\n\n'
        '**Facts:** $hook\n\n'
        '**Issue:** $question\n\n'
        '**Rule:** $doctrine\n\n'
        '**Application (element by element):**\n$elementApplication\n\n'
        '**Conclusion:** State which party prevails and tie the conclusion to the weakest or strongest element.\n\n'
        '---\n\n'
        '### Hypothetical variation\n\n'
        '**Facts:** Change one material fact from the hook (e.g., intent, timing, or relationship).\n\n'
        '**Task:** Re-run IRAC for **$lessonTitle** and explain whether the outcome changes.\n\n'
        '---\n\n'
        '### Exam-style short answer\n\n'
        '**Prompt:** List all elements of **$lessonTitle** and define each in one sentence.\n\n'
        '**Model answer outline:** ${elements.join(' · ')}';
  }

  static String _lawCommonErrors(List<String> elements) {
    return '❌ **Mistake:** Stating the rule without applying it to facts.\n'
        '✅ **Correct:** Use IRAC and tie each element (${elements.join(', ')}) to specific facts.\n\n'
        '❌ **Mistake:** Conclusory labels ("negligent," "guilty") without analysis.\n'
        '✅ **Correct:** Because [fact] → therefore [element satisfied/failed].\n\n'
        '❌ **Mistake:** Skipping the weakest element for the losing party.\n'
        '✅ **Correct:** Address the element the opponent will attack first.';
  }

  static String _lawPractice(String lessonTitle, List<String> elements, String question) {
    return '### Concept questions\n'
        '- Define **$lessonTitle** in one paragraph.\n'
        '- List elements: ${elements.join(', ')}.\n\n'
        '### Application problems\n'
        '- Apply the doctrine to a new fact pattern (write full IRAC).\n'
        '- $question\n\n'
        '### Exam drills\n'
        '- 15-minute timed IRAC on **$lessonTitle**.\n'
        '- Spot the issue when only two elements are disputed.';
  }

  static String _build({
    required String chapterTitle,
    required String subtitle,
    required String introduction,
    required String history,
    required List<String> definitions,
    required String coreConcepts,
    required String formulas,
    required String visuals,
    required String workedExamples,
    required String commonErrors,
    required String applications,
    required String advanced,
    required String practice,
    required List<String> checklist,
  }) {
    final StringBuffer buf = StringBuffer()
      ..writeln('# Chapter: $chapterTitle')
      ..writeln()
      ..writeln('*$subtitle*')
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 1. Introduction')
      ..writeln()
      ..writeln(introduction)
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 2. Historical Background')
      ..writeln()
      ..writeln(history)
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 3. Definitions')
      ..writeln();
    for (final String d in definitions) {
      buf.writeln('### $d');
      buf.writeln();
    }
    buf
      ..writeln('---')
      ..writeln()
      ..writeln('## 4. Core Concepts')
      ..writeln()
      ..writeln(coreConcepts)
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 5. Rules, Formulas & Governing Relations')
      ..writeln()
      ..writeln(formulas)
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 6. Visual Explanations')
      ..writeln()
      ..writeln(visuals)
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 7. Worked Examples')
      ..writeln()
      ..writeln(workedExamples)
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 8. Common Errors')
      ..writeln()
      ..writeln(commonErrors)
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 9. Real-World Applications')
      ..writeln()
      ..writeln(applications)
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 10. Advanced Concepts')
      ..writeln()
      ..writeln(advanced)
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 11. Practice Problems & Exam Questions')
      ..writeln()
      ..writeln(practice)
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 12. Summary')
      ..writeln()
      ..writeln('- Master **$chapterTitle** through definitions, rules, and application.')
      ..writeln('- Work every worked example without looking at the answer key.')
      ..writeln('- Connect doctrine to professional practice.')
      ..writeln()
      ..writeln('---')
      ..writeln()
      ..writeln('## 13. Mastery Checklist')
      ..writeln();
    for (final String item in checklist) {
      buf.writeln('- $item');
    }
    return buf.toString();
  }
}
