import '../models/cs_w3s_topic.dart';
import '../models/leetcode_problem.dart';

/// Practice-first CS topics: W3Schools micro-lesson + LeetCode problems.
class CsW3sCatalog {
  CsW3sCatalog._();

  static const List<CsW3sTrack> tracks = <CsW3sTrack>[
    CsW3sTrack(name: 'Fundamentals', topicIds: <String>['arrays', 'loops', 'functions']),
    CsW3sTrack(name: 'Data Structures', topicIds: <String>['hash_maps', 'linked_lists', 'stacks']),
    CsW3sTrack(name: 'Algorithms', topicIds: <String>['binary_search', 'recursion', 'sorting']),
  ];

  static final List<CsW3sTopic> topics = <CsW3sTopic>[
    _arrays,
    _loops,
    _functions,
    _hashMaps,
    _linkedLists,
    _stacks,
    _binarySearch,
    _recursion,
    _sorting,
  ];

  static CsW3sTopic? byId(String id) {
    for (final CsW3sTopic t in topics) {
      if (t.id == id) return t;
    }
    return null;
  }

  static CsW3sTopic get defaultTopic => topics.first;

  static LeetcodeProblem _mini({
    required String id,
    required String title,
    required String slug,
    required String difficulty,
    required String description,
    required String functionName,
    required List<LeetcodeExample> examples,
    List<String> constraints = const <String>[],
    List<LeetcodeHiddenTest> hidden = const <LeetcodeHiddenTest>[],
    List<String> tags = const <String>[],
  }) {
    return LeetcodeProblem(
      id: id,
      title: title,
      slug: slug,
      difficulty: difficulty,
      description: description,
      functionName: functionName,
      examples: examples,
      constraints: constraints,
      hiddenTests: hidden,
      tags: tags,
    );
  }

  static final CsW3sTopic _arrays = CsW3sTopic(
    id: 'arrays',
    title: 'Arrays',
    track: 'Fundamentals',
    lesson: const CsW3sLesson(
      whatItDoes: 'Store multiple values in one ordered list.',
      whenToUse: 'When you need indexed access, iteration, or in-place updates.',
      keyIdea: 'Index starts at 0. Last index = length − 1.',
      bullets: <String>[
        'Create: `nums = [1, 2, 3]`',
        'Read: `nums[0]` → first element',
        'Write: `nums[i] = value`',
        'Length: `len(nums)`',
        'Loop: `for x in nums:`',
      ],
    ),
    example: const CsW3sExample(
      input: 'nums = [10, 20, 30]',
      output: 'nums[1] → 20',
      steps: 'Index 0 → 10, index 1 → 20, index 2 → 30.',
    ),
    tryIt: const CsW3sTryIt(
      task: 'Print the sum of all numbers in the array.',
      starterCode: 'nums = [4, 7, 2, 9]\n\n# Print the total sum\ntotal = 0\nfor n in nums:\n    total += n\nprint(total)\n',
      runContext: 'Should print 22 (sum of 4+7+2+9).',
    ),
    easy: _mini(
      id: 'arr-easy',
      title: 'Array Sum',
      slug: 'array-sum',
      difficulty: 'Easy',
      functionName: 'arraySum',
      tags: <String>['Array'],
      description: 'Return the sum of all integers in `nums`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,2,3,4]', output: '10'),
        LeetcodeExample(input: 'nums = [5]', output: '5'),
      ],
      constraints: <String>['1 <= nums.length <= 10^4', '-10^4 <= nums[i] <= 10^4'],
    ),
    medium: _mini(
      id: '1',
      title: 'Two Sum',
      slug: 'two-sum',
      difficulty: 'Medium',
      functionName: 'twoSum',
      tags: <String>['Array', 'Hash Table'],
      description:
          'Given `nums` and `target`, return indices of two numbers that add to `target`. Exactly one solution exists.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [2,7,11,15], target = 9', output: '[0,1]'),
        LeetcodeExample(input: 'nums = [3,2,4], target = 6', output: '[1,2]'),
      ],
      constraints: <String>['2 <= nums.length <= 10^4'],
      hidden: <LeetcodeHiddenTest>[LeetcodeHiddenTest(input: 'nums = [3,3], target = 6', output: '[0,1]')],
    ),
    hard: _mini(
      id: '53',
      title: 'Maximum Subarray',
      slug: 'maximum-subarray',
      difficulty: 'Hard',
      functionName: 'maxSubArray',
      tags: <String>['Array', 'DP'],
      description: 'Find the contiguous subarray with the largest sum. Return that sum.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [-2,1,-3,4,-1,2,1,-5,4]', output: '6', explanation: 'Subarray [4,-1,2,1] sums to 6.'),
      ],
      constraints: <String>['1 <= nums.length <= 10^5'],
    ),
  );

  static final CsW3sTopic _loops = CsW3sTopic(
    id: 'loops',
    title: 'Loops',
    track: 'Fundamentals',
    lesson: const CsW3sLesson(
      whatItDoes: 'Repeat code until a condition is met or a collection is finished.',
      whenToUse: 'Counting, scanning arrays, building results step by step.',
      keyIdea: '`for` when you know how many steps; `while` when you stop on a condition.',
      bullets: <String>[
        '`for i in range(n):` — repeat n times',
        '`for item in items:` — visit each element',
        '`while condition:` — loop while true',
        'Use `break` to exit early',
        'Use `continue` to skip iteration',
      ],
    ),
    example: const CsW3sExample(
      input: 'n = 3',
      output: '0, 1, 2 printed',
      steps: '`for i in range(3)` runs with i = 0, then 1, then 2.',
    ),
    tryIt: const CsW3sTryIt(
      task: 'Print even numbers from 2 to 10 (one per line).',
      starterCode: '# Print evens: 2, 4, 6, 8, 10\nfor i in range(2, 11, 2):\n    print(i)\n',
      runContext: 'Should print 2, 4, 6, 8, 10 each on its own line.',
    ),
    easy: _mini(
      id: 'loop-easy',
      title: 'Count Evens',
      slug: 'count-evens',
      difficulty: 'Easy',
      functionName: 'countEvens',
      description: 'Return how many even numbers are in `nums`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,2,3,4,5,6]', output: '3'),
        LeetcodeExample(input: 'nums = [1,3,5]', output: '0'),
      ],
    ),
    medium: _mini(
      id: 'loop-med',
      title: 'FizzBuzz Count',
      slug: 'fizzbuzz-count',
      difficulty: 'Medium',
      functionName: 'fizzBuzzCount',
      description: 'For integers 1..n, count how many are divisible by 3 OR 5 (not both unless you count each once).',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'n = 15', output: '7'),
        LeetcodeExample(input: 'n = 5', output: '2'),
      ],
      constraints: <String>['1 <= n <= 10^4'],
    ),
    hard: _mini(
      id: 'loop-hard',
      title: 'Trapping Rain Water (1D)',
      slug: 'trap-rain-water-lite',
      difficulty: 'Hard',
      functionName: 'trap',
      description: 'Given elevation map `height`, return total trapped rain water after rain.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'height = [0,1,0,2,1,0,1,3,2,1,2,1]', output: '6'),
      ],
      constraints: <String>['n == height.length', '0 <= height[i] <= 10^5'],
    ),
  );

  static final CsW3sTopic _functions = CsW3sTopic(
    id: 'functions',
    title: 'Functions',
    track: 'Fundamentals',
    lesson: const CsW3sLesson(
      whatItDoes: 'Bundle reusable logic with inputs (parameters) and an output (return).',
      whenToUse: 'Avoid repeating code; name a clear action.',
      keyIdea: 'Define once, call many times with different arguments.',
      bullets: <String>[
        '`def name(a, b):` — define',
        '`return value` — send result back',
        'Parameters are local variables',
        'Default args: `def f(x=0):`',
        'Pure functions: same input → same output',
      ],
    ),
    example: const CsW3sExample(
      input: 'add(2, 3)',
      output: '5',
      steps: 'Function receives 2 and 3, returns their sum.',
    ),
    tryIt: const CsW3sTryIt(
      task: 'Write `double(x)` that returns x * 2. Call it with 7 and print the result.',
      starterCode: 'def double(x):\n    return x * 2\n\nprint(double(7))\n',
      runContext: 'Should print 14.',
    ),
    easy: _mini(
      id: 'fn-easy',
      title: 'Is Palindrome',
      slug: 'is-palindrome-fn',
      difficulty: 'Easy',
      functionName: 'isPalindrome',
      description: 'Return `true` if string `s` reads the same forward and backward.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = "racecar"', output: 'true'),
        LeetcodeExample(input: 's = "hello"', output: 'false'),
      ],
    ),
    medium: _mini(
      id: 'fn-med',
      title: 'Power',
      slug: 'power-fn',
      difficulty: 'Medium',
      functionName: 'myPow',
      description: 'Implement `x` raised to `n` (integer). Handle negative exponents.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'x = 2, n = 10', output: '1024'),
        LeetcodeExample(input: 'x = 2, n = -2', output: '0.25'),
      ],
    ),
    hard: _mini(
      id: 'fn-hard',
      title: 'Sqrt Integer',
      slug: 'sqrt-int',
      difficulty: 'Hard',
      functionName: 'mySqrt',
      description: 'Return integer square root of `x` (truncate decimals). No built-in sqrt.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'x = 8', output: '2'),
        LeetcodeExample(input: 'x = 16', output: '4'),
      ],
      constraints: <String>['0 <= x <= 2^31 - 1'],
    ),
  );

  static final CsW3sTopic _hashMaps = CsW3sTopic(
    id: 'hash_maps',
    title: 'Hash Maps',
    track: 'Data Structures',
    lesson: const CsW3sLesson(
      whatItDoes: 'Store key → value pairs with fast lookup.',
      whenToUse: 'Count frequencies, check membership, cache seen values.',
      keyIdea: 'Average O(1) get/set — trade memory for speed.',
      bullets: <String>[
        'Python: `d = {}` or `dict()`',
        '`d[key] = value` — insert/update',
        '`key in d` — membership test',
        'Loop keys: `for k in d:`',
        'Count: `d[x] = d.get(x, 0) + 1`',
      ],
    ),
    example: const CsW3sExample(
      input: 'words = ["a","b","a"]',
      output: '{"a": 2, "b": 1}',
      steps: 'Walk words; increment count per word in the map.',
    ),
    tryIt: const CsW3sTryIt(
      task: 'Count how many times each letter appears in "hello". Print the dict.',
      starterCode: 'word = "hello"\ncounts = {}\nfor ch in word:\n    counts[ch] = counts.get(ch, 0) + 1\nprint(counts)\n',
      runContext: 'Should print something like {"h":1,"e":1,"l":2,"o":1}.',
    ),
    easy: _mini(
      id: 'hash-easy',
      title: 'First Unique Character',
      slug: 'first-unique-char',
      difficulty: 'Easy',
      functionName: 'firstUniqChar',
      description: 'Return index of first non-repeating character in `s`, or -1 if none.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = "leetcode"', output: '0'),
        LeetcodeExample(input: 's = "aabb"', output: '-1'),
      ],
    ),
    medium: _mini(
      id: 'hash-med',
      title: 'Group Anagrams',
      slug: 'group-anagrams',
      difficulty: 'Medium',
      functionName: 'groupAnagrams',
      description: 'Group strings that are anagrams. Return list of groups.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'strs = ["eat","tea","tan","ate","nat","bat"]', output: '[["bat"],["nat","tan"],["ate","eat","tea"]]'),
      ],
    ),
    hard: _mini(
      id: 'hash-hard',
      title: 'Subarray Sum Equals K',
      slug: 'subarray-sum-k',
      difficulty: 'Hard',
      functionName: 'subarraySum',
      description: 'Return count of continuous subarrays whose sum equals `k`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,1,1], k = 2', output: '2'),
        LeetcodeExample(input: 'nums = [1,2,3], k = 3', output: '2'),
      ],
    ),
  );

  static final CsW3sTopic _linkedLists = CsW3sTopic(
    id: 'linked_lists',
    title: 'Linked Lists',
    track: 'Data Structures',
    lesson: const CsW3sLesson(
      whatItDoes: 'Chain nodes where each node holds a value and a pointer to the next.',
      whenToUse: 'Frequent insert/delete at head; unknown size growth.',
      keyIdea: 'Traverse with `while node:` — node = node.next.',
      bullets: <String>[
        'Node: `value` + `next`',
        'Head = first node',
        'Insert at head: O(1)',
        'Search: O(n) walk',
        'Watch for null `next` at tail',
      ],
    ),
    example: const CsW3sExample(
      input: '1 → 2 → 3 → null',
      output: 'Reverse → 3 → 2 → 1',
      steps: 'Rewire `next` pointers while walking the list.',
    ),
    tryIt: const CsW3sTryIt(
      task: 'Simulate a 3-node list as tuples (value, next_index). Print values in order.',
      starterCode: 'nodes = [(1, 1), (2, 2), (3, -1)]  # -1 = end\nidx = 0\nwhile idx != -1:\n    val, idx = nodes[idx]\n    print(val)\n',
      runContext: 'Should print 1, 2, 3 each on its own line.',
    ),
    easy: _mini(
      id: '206',
      title: 'Reverse Linked List',
      slug: 'reverse-linked-list',
      difficulty: 'Easy',
      functionName: 'reverseList',
      description: 'Reverse a singly linked list. Return new head.',
      examples: <LeetcodeExample>[LeetcodeExample(input: 'head = [1,2,3,4,5]', output: '[5,4,3,2,1]')],
    ),
    medium: _mini(
      id: 'll-med',
      title: 'Middle of Linked List',
      slug: 'middle-linked-list',
      difficulty: 'Medium',
      functionName: 'middleNode',
      description: 'Return the middle node. If two middles, return the second.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'head = [1,2,3,4,5]', output: '[3,4,5]'),
        LeetcodeExample(input: 'head = [1,2,3,4,5,6]', output: '[4,5,6]'),
      ],
    ),
    hard: _mini(
      id: 'll-hard',
      title: 'Reorder List',
      slug: 'reorder-list',
      difficulty: 'Hard',
      functionName: 'reorderList',
      description: 'Reorder L0→Ln→L1→Ln-1→… in-place.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'head = [1,2,3,4]', output: '[1,4,2,3]'),
      ],
    ),
  );

  static final CsW3sTopic _stacks = CsW3sTopic(
    id: 'stacks',
    title: 'Stacks',
    track: 'Data Structures',
    lesson: const CsW3sLesson(
      whatItDoes: 'Last-in, first-out (LIFO) structure — like a stack of plates.',
      whenToUse: 'Matching brackets, undo, DFS, monotonic patterns.',
      keyIdea: 'Push on top, pop from top. Peek at top without removing.',
      bullets: <String>[
        'Python: use a `list` as stack',
        '`append(x)` — push',
        '`pop()` — pop top',
        'Check empty: `if stack:`',
        'Classic: valid parentheses',
      ],
    ),
    example: const CsW3sExample(
      input: 's = "( ) [ ]"',
      output: 'valid → true',
      steps: 'Push opening brackets; pop when closing matches top.',
    ),
    tryIt: const CsW3sTryIt(
      task: 'Use a stack to reverse the word "stack". Print result.',
      starterCode: 'word = "stack"\nstack = []\nfor ch in word:\n    stack.append(ch)\nreversed_word = ""\nwhile stack:\n    reversed_word += stack.pop()\nprint(reversed_word)\n',
      runContext: 'Should print "kcats".',
    ),
    easy: _mini(
      id: '20',
      title: 'Valid Parentheses',
      slug: 'valid-parentheses',
      difficulty: 'Easy',
      functionName: 'isValid',
      description: 'Return true if bracket string is valid.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = "()"', output: 'true'),
        LeetcodeExample(input: 's = "(]"', output: 'false'),
      ],
    ),
    medium: _mini(
      id: 'stk-med',
      title: 'Daily Temperatures',
      slug: 'daily-temperatures',
      difficulty: 'Medium',
      functionName: 'dailyTemperatures',
      description: 'For each day, return days until a warmer temperature (0 if none).',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'temperatures = [73,74,75,71,69,72,76,73]', output: '[1,1,4,2,1,1,0,0]'),
      ],
    ),
    hard: _mini(
      id: 'stk-hard',
      title: 'Largest Rectangle in Histogram',
      slug: 'largest-rectangle',
      difficulty: 'Hard',
      functionName: 'largestRectangleArea',
      description: 'Given bar heights, return area of largest rectangle in histogram.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'heights = [2,1,5,6,2,3]', output: '10'),
      ],
    ),
  );

  static final CsW3sTopic _binarySearch = CsW3sTopic(
    id: 'binary_search',
    title: 'Binary Search',
    track: 'Algorithms',
    lesson: const CsW3sLesson(
      whatItDoes: 'Halve a sorted search space each step.',
      whenToUse: 'Sorted arrays, answer-space search, O(log n) lookup.',
      keyIdea: 'Compare mid; discard left or right half.',
      bullets: <String>[
        'Requires sorted data',
        '`lo, hi` pointers',
        '`mid = (lo + hi) // 2`',
        'If target < mid → search left',
        'If target > mid → search right',
      ],
    ),
    example: const CsW3sExample(
      input: 'nums = [1,3,5,7,9], target = 7',
      output: 'index 3',
      steps: 'Mid 5 → go right; mid 7 → found.',
    ),
    tryIt: const CsW3sTryIt(
      task: 'Binary search for 7 in sorted list. Print the index.',
      starterCode: 'nums = [1, 3, 5, 7, 9, 11]\ntarget = 7\nlo, hi = 0, len(nums) - 1\nfound = -1\nwhile lo <= hi:\n    mid = (lo + hi) // 2\n    if nums[mid] == target:\n        found = mid\n        break\n    elif nums[mid] < target:\n        lo = mid + 1\n    else:\n        hi = mid - 1\nprint(found)\n',
      runContext: 'Should print 3 (index of 7).',
    ),
    easy: _mini(
      id: '704',
      title: 'Binary Search',
      slug: 'binary-search',
      difficulty: 'Easy',
      functionName: 'search',
      description: 'Return index of `target` in sorted `nums`, or -1.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [-1,0,3,5,9,12], target = 9', output: '4'),
        LeetcodeExample(input: 'nums = [-1,0,3,5,9,12], target = 2', output: '-1'),
      ],
    ),
    medium: _mini(
      id: 'bs-med',
      title: 'Search Insert Position',
      slug: 'search-insert',
      difficulty: 'Medium',
      functionName: 'searchInsert',
      description: 'Return index of `target` or index where it would be inserted.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,3,5,6], target = 5', output: '2'),
        LeetcodeExample(input: 'nums = [1,3,5,6], target = 2', output: '1'),
      ],
    ),
    hard: _mini(
      id: 'bs-hard',
      title: 'Find Minimum in Rotated Array',
      slug: 'find-min-rotated',
      difficulty: 'Hard',
      functionName: 'findMin',
      description: 'Sorted array rotated at unknown pivot — find minimum in O(log n).',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [3,4,5,1,2]', output: '1'),
        LeetcodeExample(input: 'nums = [4,5,6,7,0,1,2]', output: '0'),
      ],
    ),
  );

  static final CsW3sTopic _recursion = CsW3sTopic(
    id: 'recursion',
    title: 'Recursion',
    track: 'Algorithms',
    lesson: const CsW3sLesson(
      whatItDoes: 'A function calls itself on a smaller subproblem.',
      whenToUse: 'Trees, divide-and-conquer, backtracking.',
      keyIdea: 'Every recursive call needs a base case + progress toward it.',
      bullets: <String>[
        'Base case stops recursion',
        'Recursive case shrinks input',
        'Call stack holds pending calls',
        'Risk: stack overflow without base case',
        'Often pairs with return value merge',
      ],
    ),
    example: const CsW3sExample(
      input: 'factorial(4)',
      output: '24',
      steps: '4×3×2×1 — each call waits for smaller factorial.',
    ),
    tryIt: const CsW3sTryIt(
      task: 'Recursive factorial. Print factorial(5).',
      starterCode: 'def factorial(n):\n    if n <= 1:\n        return 1\n    return n * factorial(n - 1)\n\nprint(factorial(5))\n',
      runContext: 'Should print 120.',
    ),
    easy: _mini(
      id: 'rec-easy',
      title: 'Fibonacci Number',
      slug: 'fibonacci',
      difficulty: 'Easy',
      functionName: 'fib',
      description: 'Return nth Fibonacci number (0-indexed: F(0)=0, F(1)=1).',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'n = 4', output: '3'),
        LeetcodeExample(input: 'n = 0', output: '0'),
      ],
    ),
    medium: _mini(
      id: 'rec-med',
      title: 'Pow(x, n)',
      slug: 'pow-x-n',
      difficulty: 'Medium',
      functionName: 'myPow',
      description: 'Compute x^n with recursion or divide-and-conquer in O(log n).',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'x = 2, n = 10', output: '1024'),
      ],
    ),
    hard: _mini(
      id: 'rec-hard',
      title: 'N-Queens Count',
      slug: 'n-queens-count',
      difficulty: 'Hard',
      functionName: 'totalNQueens',
      description: 'Return number of distinct solutions to place n queens on n×n board.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'n = 4', output: '2'),
        LeetcodeExample(input: 'n = 1', output: '1'),
      ],
    ),
  );

  static final CsW3sTopic _sorting = CsW3sTopic(
    id: 'sorting',
    title: 'Sorting',
    track: 'Algorithms',
    lesson: const CsW3sLesson(
      whatItDoes: 'Arrange elements in order (usually ascending).',
      whenToUse: 'Need ordered data, duplicates grouped, binary search prep.',
      keyIdea: 'Compare and swap (or merge) until entire array is sorted.',
      bullets: <String>[
        'Bubble / insertion — simple, O(n²)',
        'Merge sort — stable, O(n log n)',
        'Quick sort — fast average, partition',
        'Python: `sorted(arr)` / `arr.sort()`',
        'After sort → binary search works',
      ],
    ),
    example: const CsW3sExample(
      input: '[3, 1, 2]',
      output: '[1, 2, 3]',
      steps: 'Compare pairs, swap out-of-order values until sorted.',
    ),
    tryIt: const CsW3sTryIt(
      task: 'Sort the list and print it.',
      starterCode: 'nums = [3, 1, 4, 1, 5]\nnums.sort()\nprint(nums)\n',
      runContext: 'Should print [1, 1, 3, 4, 5].',
    ),
    easy: _mini(
      id: 'sort-easy',
      title: 'Sort Colors',
      slug: 'sort-colors',
      difficulty: 'Easy',
      functionName: 'sortColors',
      description: 'Sort array of 0s, 1s, 2s in-place (Dutch flag).',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [2,0,2,1,1,0]', output: '[0,0,1,1,2,2]'),
      ],
    ),
    medium: _mini(
      id: 'sort-med',
      title: 'Merge Intervals',
      slug: 'merge-intervals',
      difficulty: 'Medium',
      functionName: 'merge',
      description: 'Merge all overlapping intervals.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'intervals = [[1,3],[2,6],[8,10],[15,18]]', output: '[[1,6],[8,10],[15,18]]'),
      ],
    ),
    hard: _mini(
      id: 'sort-hard',
      title: 'Kth Largest Element',
      slug: 'kth-largest',
      difficulty: 'Hard',
      functionName: 'findKthLargest',
      description: 'Return the kth largest element in unsorted array.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [3,2,1,5,6,4], k = 2', output: '5'),
      ],
    ),
  );
}
