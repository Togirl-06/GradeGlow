import '../models/leetcode_problem.dart';

/// Rewrites interview drills into GradeGlow Algorithm Arena branding.
/// Titles, IDs, and copy must not mirror third-party problem names.
class ArenaChallengeBranding {
  ArenaChallengeBranding._();

  /// Apply unique Arena identity to a bank/catalog problem.
  static LeetcodeProblem rebrand(LeetcodeProblem raw, {required int arenaIndex}) {
    final String ggId = 'GG-${(arenaIndex + 1).toString().padLeft(4, '0')}';
    final String title = _arenaTitle(raw);
    final String topicHint = raw.tags.isNotEmpty ? raw.tags.first : 'Algorithms';
    final String fn = _arenaFunctionName(raw.functionName, ggId);

    final String description = _arenaDescription(
      title: title,
      topicHint: topicHint,
      difficulty: raw.difficulty,
      ggId: ggId,
      functionName: fn,
      seed: raw.description,
    );

    final List<LeetcodeExample> examples = <LeetcodeExample>[];
    for (int i = 0; i < raw.examples.length; i++) {
      final LeetcodeExample e = raw.examples[i];
      examples.add(
        LeetcodeExample(
          input: _scrubLeetcodeWords(e.input),
          output: _scrubLeetcodeWords(e.output),
          explanation: e.explanation == null
              ? null
              : _scrubLeetcodeWords(e.explanation!),
        ),
      );
    }
    if (examples.isEmpty) {
      examples.add(
        LeetcodeExample(
          input: 'sample = [...]',
          output: 'result',
          explanation: 'Check $fn against the sample, then cover edge cases.',
        ),
      );
    }

    final List<String> constraints = <String>[];
    for (final String c in raw.constraints) {
      constraints.add(_scrubLeetcodeWords(c));
    }
    if (constraints.isEmpty) {
      constraints.add('1 <= n <= 10^5 for the main input size');
      constraints.add('Solution should be correct for every valid input');
    }

    return LeetcodeProblem(
      id: ggId,
      title: title,
      slug: 'arena-${raw.slug}'.replaceAll(RegExp(r'[^a-z0-9\-]+'), '-'),
      difficulty: raw.difficulty,
      description: description,
      examples: examples,
      constraints: constraints,
      tags: raw.tags,
      functionName: fn,
      kind: raw.kind,
      starterCode: raw.starterCode,
      hiddenTests: raw.hiddenTests,
    );
  }

  static String _arenaTitle(LeetcodeProblem raw) {
    final String? mapped = _titleBySlug[raw.slug] ?? _titleByLegacyId[raw.id];
    if (mapped != null) return mapped;

    // Never fall back to the original third-party title — invent one.
    final String topic = raw.tags.isNotEmpty
        ? raw.tags.first
        : 'Logic';
    final List<String> moods = <String>[
      'Drill',
      'Lab',
      'Puzzle',
      'Sprint',
      'Challenge',
      'Workshop',
      'Gauntlet',
      'Quest',
    ];
    final List<String> flavors = <String>[
      'Neon',
      'Orbit',
      'Pulse',
      'Vector',
      'Signal',
      'Forge',
      'Prism',
      'Echo',
      'Nova',
      'Circuit',
    ];
    final int h = raw.slug.hashCode.abs();
    return '${flavors[h % flavors.length]} $topic ${moods[(h ~/ 7) % moods.length]}';
  }

  static String _arenaFunctionName(String legacy, String ggId) {
    // Keep short callable names, but avoid famous public API names when possible.
    final String? mapped = _fnByLegacy[legacy];
    if (mapped != null) return mapped;
    final String digits = ggId.replaceAll(RegExp(r'[^0-9]'), '');
    return 'solve$digits';
  }

  static String _arenaDescription({
    required String title,
    required String topicHint,
    required String difficulty,
    required String ggId,
    required String functionName,
    required String seed,
  }) {
    final String cleaned = _scrubLeetcodeWords(seed).trim();
    final String core = cleaned.isEmpty
        ? 'Build a correct $topicHint routine for this $difficulty Arena drill.'
        : cleaned;
    return '**$title** ($ggId)\n\n'
        '$core\n\n'
        'Implement `$functionName` in Code Bench. Pass every sample, then Submit '
        'against hidden Arena cases.\n\n'
        'This challenge is original to GradeGlow Algorithm Arena — write your own approach.';
  }

  static String _scrubLeetcodeWords(String text) {
    return text
        .replaceAll(RegExp(r'LeetCode', caseSensitive: false), 'Algorithm Arena')
        .replaceAll(RegExp(r'\bleetcode\b', caseSensitive: false), 'Arena');
  }

  /// Famous drills → unique GradeGlow names (never the public site titles).
  static const Map<String, String> _titleBySlug = <String, String>{
    'two-sum': 'Twin Index Target',
    'best-time-to-buy-and-sell-stock': 'Market Swing Maximizer',
    'best-time-to-buy-and-sell-stock-ii': 'Market Swing Relay',
    'contains-duplicate': 'Echo Value Detector',
    'valid-anagram': 'Letter Bag Match',
    'valid-parentheses': 'Bracket Balance Check',
    'merge-two-sorted-lists': 'Sorted Chain Merge',
    'maximum-subarray': 'Hottest Contiguous Stretch',
    'climbing-stairs': 'Stair Path Counter',
    'reverse-linked-list': 'Chain Flip',
    'invert-binary-tree': 'Mirror Tree Flip',
    'binary-search': 'Sorted Probe',
    'product-of-array-except-self': 'Silent Product Array',
    'maximum-depth-of-binary-tree': 'Tree Depth Gauge',
    'same-tree': 'Twin Tree Compare',
    'linked-list-cycle': 'Loop in the Chain',
    'min-stack': 'Floor Stack',
    'number-of-islands': 'Island Flood Count',
    'course-schedule': 'Prerequisite Order',
    'coin-change': 'Fewest Coin Mix',
    'house-robber': 'Skip-Adjacent Max',
    'longest-substring-without-repeating-characters': 'Unique Window Stretch',
    'group-anagrams': 'Anagram Clusters',
    'top-k-frequent-elements': 'Top Frequency Picks',
    'valid-palindrome': 'Phrase Mirror Test',
    'merge-intervals': 'Interval Fuse',
    'insert-interval': 'Interval Insert Fuse',
    '3sum': 'Triple Zero Combo',
    'container-with-most-water': 'Tallest Water Frame',
    'trapping-rain-water': 'Valley Water Capture',
    'longest-palindromic-substring': 'Mirror Substring Hunt',
    'word-break': 'Dictionary Split',
    'combination-sum': 'Target Combo Build',
    'permutations': 'Full Arrangements',
    'rotate-image': 'Matrix Quarter Turn',
    'spiral-matrix': 'Spiral Readout',
    'set-matrix-zeroes': 'Zero Cross Stamp',
    'search-a-2d-matrix': 'Grid Sorted Probe',
    'validate-binary-search-tree': 'BST Rule Check',
    'lowest-common-ancestor-of-a-binary-search-tree': 'BST Shared Ancestor',
    'binary-tree-level-order-traversal': 'Level Sweep',
    'serialize-and-deserialize-binary-tree': 'Tree Wire Pack',
    'implement-trie-prefix-tree': 'Prefix Tree Kit',
    'word-search': 'Letter Grid Path',
    'palindrome-number': 'Digit Mirror',
    'roman-to-integer': 'Glyph to Number',
    'longest-common-prefix': 'Shared Prefix Cut',
    'remove-duplicates-from-sorted-array': 'Sorted Unique Compact',
    'remove-element': 'Value Evict',
    'find-the-index-of-the-first-occurrence-in-a-string': 'Needle Locate',
    'length-of-last-word': 'Final Token Length',
    'plus-one': 'Digit Array Increment',
    'add-binary': 'Binary String Add',
    'sqrtx': 'Integer Root Floor',
    'merge-sorted-array': 'In-Place Sorted Merge',
    'pascal-s-triangle': 'Triangle Row Builder',
    'pascals-triangle': 'Triangle Row Builder',
    'single-number': 'Lone Bit Find',
    'intersection-of-two-arrays': 'Set Overlap',
    'intersection-of-two-arrays-ii': 'Multiplicity Overlap',
    'happy-number': 'Digit Square Fate',
    'move-zeroes': 'Zero Pack Right',
    'first-bad-version': 'Faulty Build Probe',
    'ransom-note': 'Magazine Cover Check',
    'fizz-buzz': 'Modulo Label Stream',
    'majority-element': 'Dominant Count',
    'missing-number': 'Absent Index',
  };

  static const Map<String, String> _titleByLegacyId = <String, String>{
    '1': 'Twin Index Target',
    '121': 'Market Swing Maximizer',
    '217': 'Echo Value Detector',
    '242': 'Letter Bag Match',
    '20': 'Bracket Balance Check',
    '21': 'Sorted Chain Merge',
    '53': 'Hottest Contiguous Stretch',
    '70': 'Stair Path Counter',
    '206': 'Chain Flip',
    '226': 'Mirror Tree Flip',
    '704': 'Sorted Probe',
    '238': 'Silent Product Array',
    '104': 'Tree Depth Gauge',
  };

  static const Map<String, String> _fnByLegacy = <String, String>{
    'twoSum': 'findTwinIndices',
    'maxProfit': 'maxSwingProfit',
    'containsDuplicate': 'hasEchoValue',
    'isAnagram': 'lettersMatch',
    'isValid': 'bracketsBalanced',
    'mergeTwoLists': 'mergeSortedChains',
    'maxSubArray': 'hottestStretch',
    'climbStairs': 'countStairPaths',
    'reverseList': 'flipChain',
    'invertTree': 'mirrorTree',
    'search': 'sortedProbe',
    'productExceptSelf': 'silentProducts',
    'maxDepth': 'treeDepth',
    'isSameTree': 'treesMatch',
    'hasCycle': 'chainLoops',
  };
}
