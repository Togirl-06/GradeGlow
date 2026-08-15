import '../models/leetcode_problem.dart';
import '../models/practice_lab_question.dart';
import 'arena_challenge_branding.dart';
import 'leetcode_problem_bank_extended.dart';
import 'leetcode_problem_catalog_data.dart';
import 'leetcode_debug_bank.dart';

/// Curated LeetCode-style problems — used as seeds and offline fallbacks.
class LeetcodeProblemBank {
  static List<PracticeLabQuestion> buildForTopic({
    required String topicId,
    required String topicName,
    required String difficulty,
    int count = 12,
    bool preferDebug = false,
  }) {
    final bool debugTopic = preferDebug || isDebugTopic(topicId: topicId, topicName: topicName);
    final List<LeetcodeProblem> pool = <LeetcodeProblem>[
      if (debugTopic) ..._debugProblems,
      ..._problemsForTopicId(topicId),
      ..._problemsForTopicId(_categoryKey(topicId, topicName)),
      if (debugTopic) ..._problemsForTopicId('debugging'),
      ..._universalPool,
    ];
    final String diff = _normalizeDifficulty(difficulty);
    final List<LeetcodeProblem> filtered = pool
        .where((LeetcodeProblem p) => _difficultyMatches(p.difficulty, diff))
        .toList();
    final List<LeetcodeProblem> source = filtered.isNotEmpty ? filtered : pool;
    // Unique only — never repeat the same problem id in one session.
    final Map<String, LeetcodeProblem> unique = <String, LeetcodeProblem>{};
    for (final LeetcodeProblem p in source) {
      unique.putIfAbsent(p.id, () => p);
    }
    final List<LeetcodeProblem> uniqueList = unique.values.toList();
    final int take = count < uniqueList.length ? count : uniqueList.length;
    final List<LeetcodeProblem> picked = uniqueList.take(take).toList();
    return picked.asMap().entries.map((MapEntry<int, LeetcodeProblem> entry) {
      final LeetcodeProblem p = entry.value;
      return PracticeLabQuestion(
        id: '${p.slug}_${entry.key}',
        prompt: p.promptFallback,
        leetcode: p,
      );
    }).toList();
  }

  static final RegExp _titleNoise = RegExp(r'[^a-z0-9]+');

  /// Unique interview problems for Algorithm Arena (300+). Debug clones excluded.
  static List<LeetcodeProblem> get allCuratedProblems {
    final Map<String, LeetcodeProblem> byId = <String, LeetcodeProblem>{};
    final Map<String, String> titleOwner = <String, String>{};

    void consider(LeetcodeProblem p) {
      if (p.isDebug) return;
      // SQL stays in the catalog file but is not for the Code Bench editor.
      bool isSql = false;
      for (final String t in p.tags) {
        if (t.toLowerCase() == 'sql') {
          isSql = true;
          break;
        }
      }
      if (isSql) return;

      final String normTitle =
          p.title.toLowerCase().replaceAll(_titleNoise, ' ').trim();
      final String? existingTitleId = titleOwner[normTitle];
      if (existingTitleId != null && existingTitleId != p.id) {
        // Keep the richer / curated copy if already present.
        return;
      }

      final LeetcodeProblem? prev = byId[p.id];
      if (prev != null) {
        // Prefer longer descriptions / more examples (curated over thin catalog).
        final int prevScore = prev.description.length + prev.examples.length * 40;
        final int nextScore = p.description.length + p.examples.length * 40;
        if (nextScore <= prevScore) return;
      }

      byId[p.id] = p;
      titleOwner[normTitle] = p.id;
    }

    for (final LeetcodeProblem p in _catalogProblems) {
      consider(p);
    }
    for (final List<LeetcodeProblem> list in _byTopic.values) {
      for (final LeetcodeProblem p in list) {
        consider(p);
      }
    }
    for (final LeetcodeProblem p in _universalPool) {
      consider(p);
    }
    for (final LeetcodeProblem p in LeetcodeProblemBankExtended.all) {
      consider(p);
    }

    final List<LeetcodeProblem> out = byId.values.toList();
    out.sort((LeetcodeProblem a, LeetcodeProblem b) {
      final int? ai = int.tryParse(a.id);
      final int? bi = int.tryParse(b.id);
      if (ai != null && bi != null) return ai.compareTo(bi);
      if (ai != null) return -1;
      if (bi != null) return 1;
      return a.title.compareTo(b.title);
    });

    // Rebrand so titles/IDs/copy are GradeGlow originals — not third-party names.
    final List<LeetcodeProblem> branded = <LeetcodeProblem>[];
    for (int i = 0; i < out.length; i++) {
      branded.add(ArenaChallengeBranding.rebrand(out[i], arenaIndex: i));
    }
    return branded;
  }

  /// All debug challenges with pre-loaded buggy code (GradeGlow-branded titles).
  static List<LeetcodeProblem> get allDebugProblems {
    final Map<String, LeetcodeProblem> seen = <String, LeetcodeProblem>{};
    for (final LeetcodeProblem p in _debugProblems) {
      seen[p.id] = p;
    }
    for (final LeetcodeProblem p in LeetcodeProblemBankExtended.extraDebug) {
      seen[p.id] = p;
    }
    for (final LeetcodeProblem p in LeetcodeDebugBank.all) {
      seen[p.id] = p;
    }
    final List<LeetcodeProblem> raw = seen.values.toList()
      ..sort((LeetcodeProblem a, LeetcodeProblem b) => a.title.compareTo(b.title));
    final List<LeetcodeProblem> out = <LeetcodeProblem>[];
    for (int i = 0; i < raw.length; i++) {
      final LeetcodeProblem p = raw[i];
      final LeetcodeProblem branded =
          ArenaChallengeBranding.rebrand(p, arenaIndex: i);
      out.add(
        LeetcodeProblem(
          id: branded.id,
          title: '${branded.title} · Debug Desk',
          slug: branded.slug,
          difficulty: branded.difficulty,
          description: branded.description,
          examples: branded.examples,
          constraints: branded.constraints,
          tags: branded.tags,
          functionName: branded.functionName,
          kind: LeetcodeProblemKind.debug,
          starterCode: p.starterCode,
          hiddenTests: p.hiddenTests,
        ),
      );
    }
    return out;
  }

  static List<LeetcodeProblem>? _catalogCache;
  static List<LeetcodeProblem> get _catalogProblems =>
      _catalogCache ??= LeetcodeProblemCatalogData.buildProblems();

  static String _categoryKey(String topicId, String topicName) {
    final String hay = '$topicId $topicName'.toLowerCase();
    if (isDebugTopic(topicId: topicId, topicName: topicName)) return 'debugging';
    if (hay.contains('array') || hay.contains('two-pointer')) return 'arrays';
    if (hay.contains('linked')) return 'linked_lists';
    if (hay.contains('tree') || hay.contains('bst')) return 'trees';
    if (hay.contains('graph') || hay.contains('bfs') || hay.contains('dfs')) return 'graphs';
    if (hay.contains('sort')) return 'sorting';
    if (hay.contains('dynamic') || hay.contains('dp')) return 'dynamic_programming';
    if (hay.contains('recurs')) return 'recursion';
    if (hay.contains('sql')) return 'sql';
    if (hay.contains('string')) return 'strings';
    if (hay.contains('hash') || hay.contains('map')) return 'hash_map';
    if (hay.contains('stack') || hay.contains('queue')) return 'stack_queue';
    if (hay.contains('competitive') || hay.contains('contest')) return 'competitive';
    return topicId;
  }

  static bool isDebugTopic({required String topicId, required String topicName}) {
    final String hay = '$topicId $topicName'.toLowerCase();
    return hay.contains('debug') ||
        hay.contains('refactor') ||
        hay.contains('fix') ||
        hay.contains('code_review') ||
        hay.contains('broken') ||
        hay.contains('troubleshoot');
  }

  static String _normalizeDifficulty(String d) {
    final String lower = d.toLowerCase();
    if (lower.contains('begin') || lower == 'easy') return 'Easy';
    if (lower.contains('inter') || lower == 'medium') return 'Medium';
    return 'Hard';
  }

  static bool _difficultyMatches(String problemDiff, String target) {
    if (target == 'Easy') return problemDiff == 'Easy';
    if (target == 'Medium') return problemDiff == 'Easy' || problemDiff == 'Medium';
    return true;
  }

  static List<LeetcodeProblem> _problemsForTopicId(String key) {
    final List<LeetcodeProblem> catalog = _catalogByTopic[key] ?? const <LeetcodeProblem>[];
    final List<LeetcodeProblem> base = _byTopic[key] ?? const <LeetcodeProblem>[];
    final List<LeetcodeProblem> extra =
        LeetcodeProblemBankExtended.byTopic[key] ?? const <LeetcodeProblem>[];
    return <LeetcodeProblem>[...catalog, ...base, ...extra];
  }

  static Map<String, List<LeetcodeProblem>>? _catalogByTopicCache;
  static Map<String, List<LeetcodeProblem>> get _catalogByTopic {
    if (_catalogByTopicCache != null) return _catalogByTopicCache!;
    final Map<String, List<LeetcodeProblem>> map = <String, List<LeetcodeProblem>>{};
    for (final List<String> row in LeetcodeProblemCatalogData.entries) {
      final String topic = row[3];
      map.putIfAbsent(topic, () => <LeetcodeProblem>[]).add(LeetcodeProblemCatalogData.toProblem(row));
    }
    return _catalogByTopicCache = map;
  }

  static final Map<String, List<LeetcodeProblem>> _byTopic = <String, List<LeetcodeProblem>>{
    'arrays': _arrayProblems,
    'linked_lists': _linkedListProblems,
    'trees': _treeProblems,
    'graphs': _graphProblems,
    'sorting': _sortingProblems,
    'dynamic_programming': _dpProblems,
    'recursion': _recursionProblems,
    'strings': _stringProblems,
    'hash_map': _hashProblems,
    'stack_queue': _stackProblems,
    'sql': _sqlProblems,
    'competitive': _competitiveProblems,
    'debugging': _debugProblems,
  };

  static final List<LeetcodeProblem> _universalPool = <LeetcodeProblem>[
    _twoSum,
    _validParentheses,
    _mergeSortedArrays,
    _maxSubarray,
    _binarySearch,
  ];

  static const LeetcodeProblem _twoSum = LeetcodeProblem(
    id: '1',
    title: 'Two Sum',
    slug: 'two-sum',
    difficulty: 'Easy',
    tags: <String>['Array', 'Hash Table'],
    functionName: 'twoSum',
    description:
        'Given an array of integers `nums` and an integer `target`, return indices of the two numbers such that they add up to `target`.\n\nYou may assume that each input would have exactly one solution, and you may not use the same element twice.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [2,7,11,15], target = 9', output: '[0,1]', explanation: 'Because nums[0] + nums[1] == 9, we return [0, 1].'),
      LeetcodeExample(input: 'nums = [3,2,4], target = 6', output: '[1,2]'),
    ],
    constraints: <String>['2 <= nums.length <= 10^4', '-10^9 <= nums[i] <= 10^9', 'Only one valid answer exists.'],
    hiddenTests: <LeetcodeHiddenTest>[
      LeetcodeHiddenTest(input: 'nums = [3,3], target = 6', output: '[0,1]'),
    ],
  );

  static const LeetcodeProblem _validParentheses = LeetcodeProblem(
    id: '20',
    title: 'Valid Parentheses',
    slug: 'valid-parentheses',
    difficulty: 'Easy',
    tags: <String>['String', 'Stack'],
    functionName: 'isValid',
    description: 'Given a string `s` containing just the characters `(`, `)`, `{`, `}`, `[` and `]`, determine if the input string is valid.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 's = "()"', output: 'true'),
      LeetcodeExample(input: 's = "()[]{}"', output: 'true'),
      LeetcodeExample(input: 's = "(]"', output: 'false'),
    ],
    constraints: <String>['1 <= s.length <= 10^4', 's consists of parentheses only.'],
  );

  static const LeetcodeProblem _mergeSortedArrays = LeetcodeProblem(
    id: '88',
    title: 'Merge Sorted Array',
    slug: 'merge-sorted-array',
    difficulty: 'Easy',
    tags: <String>['Array', 'Two Pointers'],
    functionName: 'merge',
    description:
        'You are given two integer arrays `nums1` and `nums2`, sorted in non-decreasing order, and integers `m` and `n`. Merge `nums2` into `nums1` as one sorted array in-place.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums1 = [1,2,3,0,0,0], m = 3, nums2 = [2,5,6], n = 3', output: '[1,2,2,3,5,6]'),
    ],
    constraints: <String>['nums1.length == m + n', 'nums2.length == n', 'Both arrays sorted ascending'],
  );

  static const LeetcodeProblem _maxSubarray = LeetcodeProblem(
    id: '53',
    title: 'Maximum Subarray',
    slug: 'maximum-subarray',
    difficulty: 'Medium',
    tags: <String>['Array', 'Dynamic Programming'],
    functionName: 'maxSubArray',
    description: 'Given an integer array `nums`, find the subarray with the largest sum, and return its sum.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [-2,1,-3,4,-1,2,1,-5,4]', output: '6', explanation: 'The subarray [4,-1,2,1] has the largest sum 6.'),
    ],
    constraints: <String>['1 <= nums.length <= 10^5', '-10^4 <= nums[i] <= 10^4'],
  );

  static const LeetcodeProblem _binarySearch = LeetcodeProblem(
    id: '704',
    title: 'Binary Search',
    slug: 'binary-search',
    difficulty: 'Easy',
    tags: <String>['Array', 'Binary Search'],
    functionName: 'search',
    description: 'Given a sorted array of distinct integers and a `target`, return the index of `target` or `-1` if not found. O(log n) time.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [-1,0,3,5,9,12], target = 9', output: '4'),
      LeetcodeExample(input: 'nums = [-1,0,3,5,9,12], target = 2', output: '-1'),
    ],
    constraints: <String>['1 <= nums.length <= 10^4', 'All integers in nums are unique', 'nums is sorted ascending'],
  );

  static const List<LeetcodeProblem> _arrayProblems = <LeetcodeProblem>[
    _twoSum,
    _mergeSortedArrays,
    _maxSubarray,
    LeetcodeProblem(
      id: '121',
      title: 'Best Time to Buy and Sell Stock',
      slug: 'best-time-to-buy-and-sell-stock',
      difficulty: 'Easy',
      tags: <String>['Array', 'Dynamic Programming'],
      functionName: 'maxProfit',
      description:
          'You are given an array `prices` where `prices[i]` is the price of a given stock on the `i`-th day.\n\n'
          'You want to maximize your profit by choosing a single day to buy one stock and choosing a different day in the future to sell that stock.\n\n'
          'Return the maximum profit you can achieve from this transaction. If you cannot achieve any profit, return `0`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(
          input: 'prices = [7,1,5,3,6,4]',
          output: '5',
          explanation:
              'Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = 6-1 = 5. Note that buying on day 2 and selling on day 1 is not allowed because you must buy before you sell.',
        ),
        LeetcodeExample(
          input: 'prices = [7,6,4,3,1]',
          output: '0',
          explanation: 'In this case, no transactions are done and the max profit = 0.',
        ),
      ],
      constraints: <String>[
        '1 <= prices.length <= 10^5',
        '0 <= prices[i] <= 10^4',
      ],
      hiddenTests: <LeetcodeHiddenTest>[
        LeetcodeHiddenTest(input: 'prices = [2,4,1]', output: '2'),
        LeetcodeHiddenTest(input: 'prices = [3,2,6,5,0,3]', output: '4'),
      ],
    ),
    LeetcodeProblem(
      id: '238',
      title: 'Product of Array Except Self',
      slug: 'product-of-array-except-self',
      difficulty: 'Medium',
      tags: <String>['Array', 'Prefix Sum'],
      functionName: 'productExceptSelf',
      description: 'Return an array `answer` such that `answer[i]` equals the product of all elements except `nums[i]`. Solve without division in O(n).',
      examples: <LeetcodeExample>[LeetcodeExample(input: 'nums = [1,2,3,4]', output: '[24,12,8,6]')],
      constraints: <String>['2 <= nums.length <= 10^5'],
    ),
  ];

  static const List<LeetcodeProblem> _linkedListProblems = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '206',
      title: 'Reverse Linked List',
      slug: 'reverse-linked-list',
      difficulty: 'Easy',
      tags: <String>['Linked List', 'Recursion'],
      functionName: 'reverseList',
      description: 'Given the head of a singly linked list, reverse the list and return the reversed head.',
      examples: <LeetcodeExample>[LeetcodeExample(input: 'head = [1,2,3,4,5]', output: '[5,4,3,2,1]')],
      constraints: <String>['0 <= list length <= 5000'],
    ),
    LeetcodeProblem(
      id: '21',
      title: 'Merge Two Sorted Lists',
      slug: 'merge-two-sorted-lists',
      difficulty: 'Easy',
      tags: <String>['Linked List'],
      functionName: 'mergeTwoLists',
      description: 'Merge two sorted linked lists and return the merged sorted list.',
      examples: <LeetcodeExample>[LeetcodeExample(input: 'list1 = [1,2,4], list2 = [1,3,4]', output: '[1,1,2,3,4,4]')],
      constraints: <String>['Both lists sorted in non-decreasing order'],
    ),
  ];

  static const List<LeetcodeProblem> _treeProblems = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '104',
      title: 'Maximum Depth of Binary Tree',
      slug: 'maximum-depth-of-binary-tree',
      difficulty: 'Easy',
      tags: <String>['Tree', 'DFS'],
      functionName: 'maxDepth',
      description: 'Given the root of a binary tree, return its maximum depth.',
      examples: <LeetcodeExample>[LeetcodeExample(input: 'root = [3,9,20,null,null,15,7]', output: '3')],
      constraints: <String>['Number of nodes in range [0, 10^4]'],
    ),
    LeetcodeProblem(
      id: '98',
      title: 'Validate Binary Search Tree',
      slug: 'validate-binary-search-tree',
      difficulty: 'Medium',
      tags: <String>['Tree', 'BST'],
      functionName: 'isValidBST',
      description: 'Determine if a binary tree is a valid binary search tree.',
      examples: <LeetcodeExample>[LeetcodeExample(input: 'root = [2,1,3]', output: 'true')],
      constraints: <String>['-2^31 <= Node.val <= 2^31 - 1'],
    ),
  ];

  static const List<LeetcodeProblem> _graphProblems = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '200',
      title: 'Number of Islands',
      slug: 'number-of-islands',
      difficulty: 'Medium',
      tags: <String>['Graph', 'DFS', 'BFS'],
      functionName: 'numIslands',
      description: 'Given an `m x n` grid of `1`s (land) and `0`s (water), return the number of islands.',
      examples: <LeetcodeExample>[
        LeetcodeExample(
          input: 'grid = [["1","1","0"],["0","1","0"],["1","0","1"]]',
          output: '3',
        ),
      ],
      constraints: <String>['m == grid.length', 'n == grid[i].length'],
    ),
  ];

  static const List<LeetcodeProblem> _sortingProblems = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '75',
      title: 'Sort Colors',
      slug: 'sort-colors',
      difficulty: 'Medium',
      tags: <String>['Array', 'Sorting', 'Two Pointers'],
      functionName: 'sortColors',
      description: 'Sort an array of `0`, `1`, and `2` in-place in one pass (Dutch national flag).',
      examples: <LeetcodeExample>[LeetcodeExample(input: 'nums = [2,0,2,1,1,0]', output: '[0,0,1,1,2,2]')],
      constraints: <String>['n == nums.length', '1 <= n <= 300'],
    ),
  ];

  static const List<LeetcodeProblem> _dpProblems = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '70',
      title: 'Climbing Stairs',
      slug: 'climbing-stairs',
      difficulty: 'Easy',
      tags: <String>['Dynamic Programming'],
      functionName: 'climbStairs',
      description: 'You can climb 1 or 2 steps at a time. How many distinct ways to reach step `n`?',
      examples: <LeetcodeExample>[LeetcodeExample(input: 'n = 3', output: '3')],
      constraints: <String>['1 <= n <= 45'],
    ),
    LeetcodeProblem(
      id: '322',
      title: 'Coin Change',
      slug: 'coin-change',
      difficulty: 'Medium',
      tags: <String>['Dynamic Programming', 'BFS'],
      functionName: 'coinChange',
      description: 'Return the fewest number of coins needed to make up `amount`, or `-1` if impossible.',
      examples: <LeetcodeExample>[LeetcodeExample(input: 'coins = [1,2,5], amount = 11', output: '3')],
      constraints: <String>['1 <= coins.length <= 12', '0 <= amount <= 10^4'],
    ),
  ];

  static const List<LeetcodeProblem> _recursionProblems = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '509',
      title: 'Fibonacci Number',
      slug: 'fibonacci-number',
      difficulty: 'Easy',
      tags: <String>['Recursion', 'Dynamic Programming'],
      functionName: 'fib',
      description: 'Return the `n`th Fibonacci number.',
      examples: <LeetcodeExample>[LeetcodeExample(input: 'n = 4', output: '3')],
      constraints: <String>['0 <= n <= 30'],
    ),
  ];

  static const List<LeetcodeProblem> _stringProblems = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '3',
      title: 'Longest Substring Without Repeating Characters',
      slug: 'longest-substring-without-repeating-characters',
      difficulty: 'Medium',
      tags: <String>['String', 'Sliding Window'],
      functionName: 'lengthOfLongestSubstring',
      description: 'Given a string `s`, find the length of the longest substring without repeating characters.',
      examples: <LeetcodeExample>[LeetcodeExample(input: 's = "abcabcbb"', output: '3')],
      constraints: <String>['0 <= s.length <= 5 * 10^4'],
    ),
    _validParentheses,
  ];

  static const List<LeetcodeProblem> _hashProblems = <LeetcodeProblem>[_twoSum];

  static const List<LeetcodeProblem> _stackProblems = <LeetcodeProblem>[_validParentheses];

  static const List<LeetcodeProblem> _sqlProblems = <LeetcodeProblem>[
    LeetcodeProblem(
      id: 'sql-175',
      title: 'Combine Two Tables',
      slug: 'combine-two-tables',
      difficulty: 'Easy',
      tags: <String>['SQL', 'Database'],
      functionName: 'query',
      description: 'Write an SQL query to report the first name, last name, city, and state of each person. Include all persons even if they have no address.',
      examples: <LeetcodeExample>[
        LeetcodeExample(
          input: 'Person: id=1, name=John | Address: personId=1, city=New York',
          output: 'firstName=John, lastName=Doe, city=New York, state=NY',
        ),
      ],
      constraints: <String>['Use LEFT JOIN', 'Return columns in specified order'],
    ),
  ];

  static const List<LeetcodeProblem> _competitiveProblems = <LeetcodeProblem>[
    LeetcodeProblem(
      id: 'contest-1',
      title: 'Minimum Window Substring',
      slug: 'minimum-window-substring',
      difficulty: 'Hard',
      tags: <String>['String', 'Sliding Window', 'Contest'],
      functionName: 'minWindow',
      description: 'Return the minimum window substring of `s` such that every character in `t` is included.',
      examples: <LeetcodeExample>[LeetcodeExample(input: 's = "ADOBECODEBANC", t = "ABC"', output: '"BANC"')],
      constraints: <String>['m == s.length', 'n == t.length', '1 <= m, n <= 10^5'],
    ),
  ];

  static const List<LeetcodeProblem> _debugProblems = <LeetcodeProblem>[
    LeetcodeProblem(
      id: 'debug-1',
      title: 'Two Sum (Buggy)',
      slug: 'debug-two-sum',
      difficulty: 'Easy',
      kind: LeetcodeProblemKind.debug,
      tags: <String>['Array', 'Debugging'],
      functionName: 'twoSum',
      description:
          'This solution should return indices of two numbers that add up to `target`, but it fails on several inputs. Find and fix the bug.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [2,7,11,15], target = 9', output: '[0,1]'),
        LeetcodeExample(input: 'nums = [3,2,4], target = 6', output: '[1,2]'),
      ],
      constraints: <String>['Do not use the same index twice', 'Exactly one valid answer exists'],
      starterCode: <String, String>{
        'python3': '''class Solution:
    def twoSum(self, nums: list[int], target: int) -> list[int]:
        for i in range(len(nums)):
            for j in range(len(nums)):
                if nums[i] + nums[j] == target:
                    return [i, j]
        return []
''',
        'javascript': '''/**
 * @param {number[]} nums
 * @param {number} target
 * @return {number[]}
 */
var twoSum = function(nums, target) {
    for (let i = 0; i < nums.length; i++) {
        for (let j = 0; j < nums.length; j++) {
            if (nums[i] + nums[j] === target) return [i, j];
        }
    }
    return [];
};
''',
        'java': '''class Solution {
    public int[] twoSum(int[] nums, int target) {
        for (int i = 0; i < nums.length; i++) {
            for (int j = 0; j < nums.length; j++) {
                if (nums[i] + nums[j] == target) return new int[] { i, j };
            }
        }
        return new int[0];
    }
}
''',
      },
      hiddenTests: <LeetcodeHiddenTest>[
        LeetcodeHiddenTest(input: 'nums = [3,3], target = 6', output: '[0,1]'),
      ],
    ),
    LeetcodeProblem(
      id: 'debug-20',
      title: 'Valid Parentheses (Buggy)',
      slug: 'debug-valid-parentheses',
      difficulty: 'Easy',
      kind: LeetcodeProblemKind.debug,
      tags: <String>['String', 'Stack', 'Debugging'],
      functionName: 'isValid',
      description: 'The bracket-matching logic below is incorrect. Fix it so nested and sequential pairs validate properly.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = "()"', output: 'true'),
        LeetcodeExample(input: 's = "()[]{}"', output: 'true'),
        LeetcodeExample(input: 's = "(]"', output: 'false'),
      ],
      constraints: <String>['1 <= s.length <= 10^4'],
      starterCode: <String, String>{
        'python3': '''class Solution:
    def isValid(self, s: str) -> bool:
        stack = []
        pairs = {')': '(', ']': '[', '}': '{'}
        for ch in s:
            if ch in pairs:
                if not stack or stack[-1] != pairs[ch]:
                    return False
                stack.pop()
            else:
                stack.append(ch)
        return len(stack) == 0
''',
        'javascript': '''/**
 * @param {string} s
 * @return {boolean}
 */
var isValid = function(s) {
    const stack = [];
    const pairs = { ')': '(', ']': '[', '}': '{' };
    for (const ch of s) {
        if (pairs[ch]) {
            if (!stack.length || stack.pop() !== pairs[ch]) return false;
        } else {
            stack.push(ch);
        }
    }
    return stack.length === 0;
};
''',
      },
    ),
    LeetcodeProblem(
      id: 'debug-704',
      title: 'Binary Search (Buggy)',
      slug: 'debug-binary-search',
      difficulty: 'Easy',
      kind: LeetcodeProblemKind.debug,
      tags: <String>['Binary Search', 'Debugging'],
      functionName: 'search',
      description: 'This binary search never terminates or returns the wrong index on some inputs. Correct the loop bounds.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [-1,0,3,5,9,12], target = 9', output: '4'),
        LeetcodeExample(input: 'nums = [-1,0,3,5,9,12], target = 2', output: '-1'),
      ],
      constraints: <String>['nums is sorted ascending', 'O(log n) expected'],
      starterCode: <String, String>{
        'python3': '''class Solution:
    def search(self, nums: list[int], target: int) -> int:
        left, right = 0, len(nums)
        while left < right:
            mid = (left + right) // 2
            if nums[mid] == target:
                return mid
            if nums[mid] < target:
                left = mid
            else:
                right = mid
        return -1
''',
        'javascript': '''/**
 * @param {number[]} nums
 * @param {number} target
 * @return {number}
 */
var search = function(nums, target) {
    let left = 0, right = nums.length;
    while (left < right) {
        const mid = Math.floor((left + right) / 2);
        if (nums[mid] === target) return mid;
        if (nums[mid] < target) left = mid;
        else right = mid;
    }
    return -1;
};
''',
      },
    ),
    LeetcodeProblem(
      id: 'debug-53',
      title: 'Maximum Subarray (Buggy)',
      slug: 'debug-maximum-subarray',
      difficulty: 'Medium',
      kind: LeetcodeProblemKind.debug,
      tags: <String>['Array', 'Debugging'],
      functionName: 'maxSubArray',
      description: 'Kadane\'s algorithm below returns the wrong answer when all numbers are negative. Fix the accumulation logic.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [-2,1,-3,4,-1,2,1,-5,4]', output: '6'),
        LeetcodeExample(input: 'nums = [-5,-2,-8]', output: '-2'),
      ],
      constraints: <String>['1 <= nums.length <= 10^5'],
      starterCode: <String, String>{
        'python3': '''class Solution:
    def maxSubArray(self, nums: list[int]) -> int:
        best = 0
        current = 0
        for n in nums:
            current += n
            best = max(best, current)
            if current < 0:
                current = 0
        return best
''',
        'javascript': '''/**
 * @param {number[]} nums
 * @return {number}
 */
var maxSubArray = function(nums) {
    let best = 0, current = 0;
    for (const n of nums) {
        current += n;
        best = Math.max(best, current);
        if (current < 0) current = 0;
    }
    return best;
};
''',
      },
    ),
    LeetcodeProblem(
      id: 'debug-509',
      title: 'Fibonacci Number (Buggy)',
      slug: 'debug-fibonacci',
      difficulty: 'Easy',
      kind: LeetcodeProblemKind.debug,
      tags: <String>['Recursion', 'Debugging'],
      functionName: 'fib',
      description: 'The recursive Fibonacci implementation below is wrong for base cases. Fix it without changing the function signature.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'n = 0', output: '0'),
        LeetcodeExample(input: 'n = 4', output: '3'),
      ],
      constraints: <String>['0 <= n <= 30'],
      starterCode: <String, String>{
        'python3': '''class Solution:
    def fib(self, n: int) -> int:
        if n <= 1:
            return 1
        return self.fib(n - 1) + self.fib(n - 2)
''',
        'javascript': '''/**
 * @param {number} n
 * @return {number}
 */
var fib = function(n) {
    if (n <= 1) return 1;
    return fib(n - 1) + fib(n - 2);
};
''',
      },
    ),
    LeetcodeProblem(
      id: 'debug-206',
      title: 'Reverse Linked List (Buggy)',
      slug: 'debug-reverse-linked-list',
      difficulty: 'Easy',
      kind: LeetcodeProblemKind.debug,
      tags: <String>['Linked List', 'Debugging'],
      functionName: 'reverseList',
      description: 'The list reversal below drops nodes. Repair the pointer updates so the full list reverses in-place.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'head = [1,2,3,4,5]', output: '[5,4,3,2,1]'),
        LeetcodeExample(input: 'head = [1,2]', output: '[2,1]'),
      ],
      constraints: <String>['0 <= list length <= 5000'],
      starterCode: <String, String>{
        'python3': '''class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next

class Solution:
    def reverseList(self, head: ListNode) -> ListNode:
        prev = None
        while head:
            nxt = head.next
            head.next = prev
            prev = head
            head = nxt
            prev.next = head
        return prev
''',
        'javascript': '''/**
 * @param {ListNode} head
 * @return {ListNode}
 */
var reverseList = function(head) {
    let prev = null;
    while (head) {
        const next = head.next;
        head.next = prev;
        prev = head;
        head = next;
        prev.next = head;
    }
    return prev;
};
''',
      },
    ),
  ];
}
