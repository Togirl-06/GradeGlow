import '../models/cs_bigo_lesson.dart';
import '../models/cs_w3s_topic.dart';

/// W3Schools-style Big-O notation lessons for the CS learning track.
class CsBigOCatalog {
  CsBigOCatalog._();

  static const List<String> lessonIds = <String>[
    'big_o_intro',
    'big_o_loops',
    'big_o_log',
    'big_o_recursion',
    'big_o_space',
  ];

  static const List<CsBigOLesson> lessons = <CsBigOLesson>[
    _intro,
    _loops,
    _logarithmic,
    _recursion,
    _space,
  ];

  static CsBigOLesson? byId(String id) {
    for (final CsBigOLesson lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  static CsBigOLesson get defaultLesson => lessons.first;

  static const CsBigOLesson _intro = CsBigOLesson(
    id: 'big_o_intro',
    title: 'Big-O Basics',
    track: 'Complexity',
    lesson: CsW3sLesson(
      whatItDoes: 'Describes how runtime or memory grows as input size `n` increases.',
      whenToUse: 'When comparing algorithms, explaining interview solutions, or choosing data structures.',
      keyIdea: 'We care about the **growth rate**, not exact milliseconds. Drop constants and lower terms.',
      bullets: <String>[
        'O(1) — constant: one lookup, no loops over n',
        'O(n) — linear: single pass through n items',
        'O(n²) — quadratic: nested loops over n',
        'O(log n) — logarithmic: halving the problem each step',
        'O(n log n) — common for efficient sorts',
        'Rule: multiply nested work, add sequential steps',
      ],
    ),
    example: CsW3sExample(
      input: 'n = 1,000,000',
      output: 'O(n) loop ≈ 1M steps · O(n²) nested ≈ 1T steps',
      steps: 'Doubling n doubles O(n) work but quadruples O(n²) work — that is why Big-O matters.',
    ),
    tryIt: CsW3sTryIt(
      task: 'Run a single loop `n` times and print how many iterations executed.',
      starterCode: '''n = 8
count = 0
for i in range(n):
    count += 1
print(f"Iterations: {count}")
print("Time complexity: O(n)")
''',
      runContext: 'Should print Iterations: 8 and note O(n) time.',
    ),
    quizzes: <CsBigOQuiz>[
      CsBigOQuiz(
        code: 'for i in range(n):\n  print(i)',
        question: 'What is the time complexity?',
        options: <String>['O(1)', 'O(n)', 'O(n²)', 'O(log n)'],
        correctIndex: 1,
        explanation: 'One loop over n elements → O(n) time, O(1) extra space.',
      ),
    ],
  );

  static const CsBigOLesson _loops = CsBigOLesson(
    id: 'big_o_loops',
    title: 'Loop Analysis',
    track: 'Complexity',
    lesson: CsW3sLesson(
      whatItDoes: 'Teaches how to count work done by loops and nested loops.',
      whenToUse: 'Reading unfamiliar code, optimizing hot paths, or whiteboard interviews.',
      keyIdea: 'Multiply loop depths. A loop inside another loop over n usually means O(n²).',
      bullets: <String>[
        'One loop 0..n-1 → O(n)',
        'Two nested loops, each 0..n-1 → O(n²)',
        'Loop halving i (i //= 2) → O(log n)',
        'Sequential loops: O(n) + O(n) = O(n)',
        'Nested with inner loop 0..i → still O(n²)',
      ],
    ),
    example: CsW3sExample(
      input: 'n = 4',
      output: 'Nested i,j loops run 16 times',
      steps: 'Outer runs n times; inner runs n times per outer → n × n = n² iterations.',
    ),
    tryIt: CsW3sTryIt(
      task: 'Count how many times the inner `print` runs for nested loops.',
      starterCode: '''n = 4
total = 0
for i in range(n):
    for j in range(n):
        total += 1
print(f"Inner body ran {total} times")
print("Time complexity: O(n²)")
''',
      runContext: 'Should print 16 for n=4 and note O(n²).',
    ),
    quizzes: <CsBigOQuiz>[
      CsBigOQuiz(
        code: 'for i in range(n):\n  for j in range(n):\n    sum += i * j',
        question: 'What is the time complexity?',
        options: <String>['O(n)', 'O(n log n)', 'O(n²)', 'O(2^n)'],
        correctIndex: 2,
        explanation: 'Nested loops each running n times → O(n²).',
      ),
    ],
  );

  static const CsBigOLesson _logarithmic = CsBigOLesson(
    id: 'big_o_log',
    title: 'Logarithmic Time',
    track: 'Complexity',
    lesson: CsW3sLesson(
      whatItDoes: 'Explains algorithms that cut the problem in half each step.',
      whenToUse: 'Binary search, balanced trees, divide-and-conquer merges.',
      keyIdea: 'Each step removes half the remaining work → about log₂(n) steps.',
      bullets: <String>[
        'Binary search on sorted array → O(log n)',
        'Merge sort → O(n log n): log n levels, O(n) merge per level',
        'While loop dividing by 2 → O(log n)',
        'log n grows slowly: n=1,000,000 → ~20 steps',
      ],
    ),
    example: CsW3sExample(
      input: 'sorted = [2,5,8,12,16,23,38,56,72,91], target = 23',
      output: 'Found at index 5 in ~4 comparisons',
      steps: 'Compare middle, discard half, repeat — that is O(log n) on sorted data.',
    ),
    tryIt: CsW3sTryIt(
      task: 'Simulate binary search and print how many comparisons were made.',
      starterCode: '''arr = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91]
target = 23
lo, hi = 0, len(arr) - 1
steps = 0
while lo <= hi:
    steps += 1
    mid = (lo + hi) // 2
    if arr[mid] == target:
        print(f"Found at index {mid} in {steps} steps")
        break
    elif arr[mid] < target:
        lo = mid + 1
    else:
        hi = mid - 1
print("Time complexity: O(log n)")
''',
      runContext: 'Should find index 5 in a few steps and note O(log n).',
    ),
    quizzes: <CsBigOQuiz>[
      CsBigOQuiz(
        code: 'def binary_search(arr, target):\n  lo, hi = 0, len(arr)-1\n  while lo <= hi:\n    mid = (lo+hi)//2',
        question: 'What is the time complexity on a sorted array?',
        options: <String>['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
        correctIndex: 1,
        explanation: 'Halving the search space each step → O(log n).',
      ),
      CsBigOQuiz(
        code: 'def merge_sort(arr):\n  if len(arr) <= 1: return arr\n  mid = len(arr)//2',
        question: 'What is the time complexity?',
        options: <String>['O(n)', 'O(n log n)', 'O(n²)', 'O(log n)'],
        correctIndex: 1,
        explanation: 'Divide and merge across log n levels, O(n) work per level → O(n log n).',
      ),
    ],
  );

  static const CsBigOLesson _recursion = CsBigOLesson(
    id: 'big_o_recursion',
    title: 'Recursion & Memo',
    track: 'Complexity',
    lesson: CsW3sLesson(
      whatItDoes: 'Shows how recursive calls stack up — and how memoization fixes repeated work.',
      whenToUse: 'DP problems, tree traversals, backtracking analysis.',
      keyIdea: 'Naive recursion can explode (O(2^n)); caching subproblems often drops to O(n).',
      bullets: <String>[
        'Fibonacci naive recursion → O(2^n) time',
        'Fibonacci + memo → O(n) time, O(n) space',
        'Tree height h traversal → O(n) nodes visited',
        'Each recursive call uses stack space',
      ],
    ),
    example: CsW3sExample(
      input: 'fib(5) naive vs memo',
      output: 'Naive ~15 calls · Memo ~6 calls',
      steps: 'Memoization stores results so each `n` is solved once.',
    ),
    tryIt: CsW3sTryIt(
      task: 'Run memoized Fibonacci and print the result for n=10.',
      starterCode: '''memo = {}

def fib(n):
    if n in memo:
        return memo[n]
    if n <= 1:
        return n
    memo[n] = fib(n - 1) + fib(n - 2)
    return memo[n]

print(f"fib(10) = {fib(10)}")
print(f"Cached {len(memo)} subproblems")
print("Time complexity with memo: O(n)")
''',
      runContext: 'Should print fib(10) = 55 and note O(n) with memo.',
    ),
    quizzes: <CsBigOQuiz>[
      CsBigOQuiz(
        code: 'memo = {}\ndef fib(n):\n  if n in memo: return memo[n]',
        question: 'Time complexity with memoization?',
        options: <String>['O(2^n)', 'O(n)', 'O(n²)', 'O(log n)'],
        correctIndex: 1,
        explanation: 'Each subproblem computed once → O(n) time, O(n) space for memo.',
      ),
    ],
  );

  static const CsBigOLesson _space = CsBigOLesson(
    id: 'big_o_space',
    title: 'Space Complexity',
    track: 'Complexity',
    lesson: CsW3sLesson(
      whatItDoes: 'Measures extra memory an algorithm uses beyond the input.',
      whenToUse: 'Large inputs, embedded systems, or when comparing in-place vs extra-array solutions.',
      keyIdea: 'Count auxiliary structures: new arrays, hash maps, recursion stack depth.',
      bullets: <String>[
        'In-place swap / two pointers → O(1) extra space',
        'New array copy of input → O(n) space',
        'Hash map storing n keys → O(n) space',
        'Recursion depth n → O(n) stack space',
        'Time–space trade-off: hash map speeds lookup but uses memory',
      ],
    ),
    example: CsW3sExample(
      input: 'Reverse array in-place vs new array',
      output: 'In-place O(1) extra · Copy O(n) extra',
      steps: 'Same O(n) time, but extra array doubles memory use.',
    ),
    tryIt: CsW3sTryIt(
      task: 'Reverse a list in-place using two pointers (no extra array).',
      starterCode: '''nums = [1, 2, 3, 4, 5]
lo, hi = 0, len(nums) - 1
while lo < hi:
    nums[lo], nums[hi] = nums[hi], nums[lo]
    lo += 1
    hi -= 1
print(nums)
print("Extra space: O(1)")
''',
      runContext: 'Should print [5,4,3,2,1] with O(1) extra space.',
    ),
    quizzes: <CsBigOQuiz>[
      CsBigOQuiz(
        code: 'seen = set()\nfor x in nums:\n  seen.add(x)',
        question: 'What is the extra space complexity?',
        options: <String>['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
        correctIndex: 2,
        explanation: 'A set may store up to n distinct elements → O(n) auxiliary space.',
      ),
    ],
  );
}
