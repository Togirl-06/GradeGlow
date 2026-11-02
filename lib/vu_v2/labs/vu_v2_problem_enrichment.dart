import '../../models/leetcode_problem.dart';

/// Expands thin catalog problems into a fuller Algorithm Arena brief.
class VuV2ProblemEnrichment {
  VuV2ProblemEnrichment._();

  static VuV2EnrichedProblem enrich(LeetcodeProblem problem) {
    final String lookupSlug = problem.slug.startsWith('arena-')
        ? problem.slug.substring('arena-'.length)
        : problem.slug;
    final VuV2EnrichedProblem? curated =
        _curated[problem.id] ?? _curated[lookupSlug] ?? _curated[problem.slug];
    if (curated != null) {
      return curated.mergeBase(problem);
    }
    return _fromThin(problem);
  }

  static VuV2EnrichedProblem _fromThin(LeetcodeProblem p) {
    final List<VuV2ExampleView> examples = <VuV2ExampleView>[];
    for (int i = 0; i < p.examples.length; i++) {
      final LeetcodeExample e = p.examples[i];
      examples.add(
        VuV2ExampleView(
          input: e.input,
          output: e.output,
          explanation: e.explanation ??
              'Verify that ${p.functionName} returns ${e.output} for this input.',
        ),
      );
    }
    if (examples.isEmpty) {
      examples.add(
        const VuV2ExampleView(
          input: 'See function signature / starter code',
          output: 'Correct answer for the sample',
          explanation: 'Add edge-case coverage before submitting.',
        ),
      );
    }
    if (examples.length == 1) {
      examples.add(
        VuV2ExampleView(
          input: 'A second edge-case input for ${p.functionName}',
          output: 'Expected result',
          explanation:
              'Think about empty inputs, duplicates, and extreme values allowed by the constraints.',
        ),
      );
    }

    final List<String> constraints = <String>[];
    constraints.addAll(p.constraints);
    if (constraints.isEmpty) {
      constraints.add('1 <= n <= 10^5 where n is the primary input size');
      constraints.add('Your solution should aim for O(n) or O(n log n) when possible');
    }

    final String desc = p.description.trim().isEmpty
        ? 'Implement `${p.functionName}` so every sample and hidden test passes.'
        : p.description.trim();

    return VuV2EnrichedProblem(
      id: p.id,
      title: p.title,
      difficulty: p.difficulty,
      tags: p.tags,
      description: desc,
      examples: examples,
      constraints: constraints,
      followUp:
          'Can you solve it with better time or space complexity? '
          'What edge cases should you double-check before Submit?',
      hints: <String>[
        'Restate the drill in one sentence, then pick a brute-force idea.',
        'Identify what you must track while scanning the input once.',
        'Check constraints — they often hint at the needed complexity.',
      ],
    );
  }

  static final Map<String, VuV2EnrichedProblem> _curated =
      <String, VuV2EnrichedProblem>{
    'best-time-to-buy-and-sell-stock': VuV2EnrichedProblem(
      id: 'GG-stock',
      title: 'Market Swing Maximizer',
      difficulty: 'Easy',
      tags: <String>['Array', 'Dynamic Programming'],
      description:
          'You are given an array `prices` where `prices[i]` is the price of an asset on day `i`.\n\n'
          'Choose **one day** to buy and a **later day** to sell. Return the maximum profit from that single trade. '
          'If no profitable trade exists, return `0`.',
      examples: <VuV2ExampleView>[
        VuV2ExampleView(
          input: 'prices = [7,1,5,3,6,4]',
          output: '5',
          explanation:
              'Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = 5. '
              'You must buy before you sell.',
        ),
        VuV2ExampleView(
          input: 'prices = [7,6,4,3,1]',
          output: '0',
          explanation: 'Prices only fall, so the best profit is 0.',
        ),
      ],
      constraints: <String>[
        '1 <= prices.length <= 10^5',
        '0 <= prices[i] <= 10^4',
      ],
      followUp:
          'Can you solve it in O(n) time and O(1) extra space by tracking the lowest price so far?',
      hints: <String>[
        'Brute force: try every buy day i and sell day j > i.',
        'One pass: keep the lowest price seen and the best profit.',
        'Profit on day i is prices[i] - minPriceSoFar.',
      ],
    ),
    'two-sum': VuV2EnrichedProblem(
      id: 'GG-twins',
      title: 'Twin Index Target',
      difficulty: 'Easy',
      tags: <String>['Array', 'Hash Table'],
      description:
          'Given integers `nums` and a `target`, return **two indices** whose values add up to `target`.\n\n'
          'Exactly one solution exists. Do not reuse the same index twice. Order of the two indices does not matter.',
      examples: <VuV2ExampleView>[
        VuV2ExampleView(
          input: 'nums = [2,7,11,15], target = 9',
          output: '[0,1]',
          explanation: 'nums[0] + nums[1] == 9.',
        ),
        VuV2ExampleView(
          input: 'nums = [3,2,4], target = 6',
          output: '[1,2]',
          explanation: 'nums[1] + nums[2] == 6.',
        ),
      ],
      constraints: <String>[
        '2 <= nums.length <= 10^4',
        '-10^9 <= nums[i] <= 10^9',
        '-10^9 <= target <= 10^9',
        'Exactly one valid answer exists.',
      ],
      followUp: 'Can you do it faster than checking every pair?',
      hints: <String>[
        'A map from value → index finds complements quickly.',
        'Look up target - nums[i] before inserting nums[i].',
      ],
    ),
    'contains-duplicate': VuV2EnrichedProblem(
      id: 'GG-echo',
      title: 'Echo Value Detector',
      difficulty: 'Easy',
      tags: <String>['Array', 'Hash Table', 'Sorting'],
      description:
          'Given integer array `nums`, return `true` if any value appears at least twice, otherwise `false`.',
      examples: <VuV2ExampleView>[
        const VuV2ExampleView(
          input: 'nums = [1,2,3,1]',
          output: 'true',
          explanation: '1 appears twice.',
        ),
        const VuV2ExampleView(
          input: 'nums = [1,2,3,4]',
          output: 'false',
          explanation: 'All values are unique.',
        ),
      ],
      constraints: <String>[
        '1 <= nums.length <= 10^5',
        '-10^9 <= nums[i] <= 10^9',
      ],
      followUp: 'Solve it with a set in average O(n) time.',
      hints: <String>[
        'Insert into a set; a failed insert means a duplicate.',
        'Sorting then scanning neighbors also works.',
      ],
    ),
  };
}

class VuV2ExampleView {
  const VuV2ExampleView({
    required this.input,
    required this.output,
    this.explanation,
  });

  final String input;
  final String output;
  final String? explanation;
}

class VuV2EnrichedProblem {
  const VuV2EnrichedProblem({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.tags,
    required this.description,
    required this.examples,
    required this.constraints,
    required this.followUp,
    required this.hints,
  });

  final String id;
  final String title;
  final String difficulty;
  final List<String> tags;
  final String description;
  final List<VuV2ExampleView> examples;
  final List<String> constraints;
  final String followUp;
  final List<String> hints;

  VuV2EnrichedProblem mergeBase(LeetcodeProblem base) {
    return VuV2EnrichedProblem(
      id: base.id,
      title: base.title.isNotEmpty ? base.title : title,
      difficulty: base.difficulty.isNotEmpty ? base.difficulty : difficulty,
      tags: base.tags.isNotEmpty ? base.tags : tags,
      description: description,
      examples: examples,
      constraints: constraints.isNotEmpty ? constraints : base.constraints,
      followUp: followUp,
      hints: hints,
    );
  }
}
