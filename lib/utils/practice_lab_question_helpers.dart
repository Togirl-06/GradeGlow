/// Heuristics for whether a practice question expects code vs a written answer.
bool isCodingQuestion(String prompt) {
  final String p = prompt.toLowerCase();

  const List<String> conceptual = <String>[
    'define ',
    'what is',
    'what are',
    'explain why',
    'list three',
    'list ',
    'how would you explain',
    'describe a real-world',
    'true or false',
    'vocabulary',
    'compare ',
    'why it matters',
    'common mistake',
    'identify the main',
    'justify whether',
    'how would you teach',
    'build a short plan',
    'predict the outcome',
    'critically evaluate',
    'defend your reasoning',
    'construct a rigorous argument',
    'create a rubric',
    'evaluate published',
    'handle ambiguous data',
    'explain ',
    'give a simple example',
    'give an example',
    'what would you check',
    'how does ',
    'what assumptions',
    'diagnose errors in a flawed',
    'interpret data',
    'integrate ',
    'analyze a case where',
    'evaluate which approach',
    'propose improvements',
    'analyze trade-offs',
    'what edge cases',
    'synthesize ',
  ];

  for (final String phrase in conceptual) {
    if (p.contains(phrase)) return false;
  }

  const List<String> coding = <String>[
    'implement',
    'write a function',
    'write code',
    'write a program',
    'write sql',
    'debug this',
    'debug the',
    'refactor',
    'algorithm',
    'time complexity',
    'space complexity',
    'o(n)',
    'given an array',
    'given a string',
    'given a linked list',
    'binary search',
    'dynamic programming',
    'two-pointer',
    ' bfs',
    ' dfs',
    'sorting algorithm',
    'leetcode',
    'class solution',
    'fix the bug',
    'optimize the',
    'code review',
    'containerize',
    'write complex sql',
    'design combinational',
    'implement fsm',
    'fix collision',
    'optimize draw calls',
    'optimize orm',
    'optimize memory access',
    'filter noisy sensor',
  ];

  for (final String phrase in coding) {
    if (p.contains(phrase)) return true;
  }

  if (p.contains('solve a') || p.contains('solve an')) {
    return p.contains('exam-level') ||
        p.contains('contest') ||
        p.contains('leetcode') ||
        p.contains('coding');
  }

  return false;
}
