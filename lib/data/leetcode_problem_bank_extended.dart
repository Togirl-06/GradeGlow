import '../models/leetcode_problem.dart';

/// Additional curated LeetCode-style problems for the CS problem browser.
class LeetcodeProblemBankExtended {
  LeetcodeProblemBankExtended._();

  static const List<LeetcodeProblem> all = <LeetcodeProblem>[
    ...extraArrays,
    ...extraStrings,
    ...extraHashMap,
    ...extraStackQueue,
    ...extraLinkedLists,
    ...extraTrees,
    ...extraGraphs,
    ...extraSorting,
    ...extraDp,
    ...extraRecursion,
    ...extraCompetitive,
    ...extraDebug,
  ];

  static final Map<String, List<LeetcodeProblem>> byTopic = <String, List<LeetcodeProblem>>{
    'arrays': extraArrays,
    'strings': extraStrings,
    'hash_map': extraHashMap,
    'stack_queue': extraStackQueue,
    'linked_lists': extraLinkedLists,
    'trees': extraTrees,
    'graphs': extraGraphs,
    'sorting': extraSorting,
    'dynamic_programming': extraDp,
    'recursion': extraRecursion,
    'competitive': extraCompetitive,
    'debugging': extraDebug,
  };

  static const List<LeetcodeProblem> extraArrays = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '217',
      title: 'Contains Duplicate',
      slug: 'contains-duplicate',
      difficulty: 'Easy',
      tags: <String>['Array', 'Hash Table'],
      functionName: 'containsDuplicate',
      description: 'Return `true` if any value appears at least twice in `nums`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,2,3,1]', output: 'true'),
        LeetcodeExample(input: 'nums = [1,2,3,4]', output: 'false'),
      ],
      constraints: <String>['1 <= nums.length <= 10^5'],
    ),
    LeetcodeProblem(
      id: '283',
      title: 'Move Zeroes',
      slug: 'move-zeroes',
      difficulty: 'Easy',
      tags: <String>['Array', 'Two Pointers'],
      functionName: 'moveZeroes',
      description: 'Move all `0`s to the end of `nums` while maintaining relative order of non-zero elements. Do this in-place.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [0,1,0,3,12]', output: '[1,3,12,0,0]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '189',
      title: 'Rotate Array',
      slug: 'rotate-array',
      difficulty: 'Medium',
      tags: <String>['Array', 'Two Pointers'],
      functionName: 'rotate',
      description: 'Rotate `nums` to the right by `k` steps, where `k` is non-negative.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,2,3,4,5,6,7], k = 3', output: '[5,6,7,1,2,3,4]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '136',
      title: 'Single Number',
      slug: 'single-number',
      difficulty: 'Easy',
      tags: <String>['Array', 'Bit Manipulation'],
      functionName: 'singleNumber',
      description: 'Every element appears twice except one. Find that single one.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [4,1,2,1,2]', output: '4'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '56',
      title: 'Merge Intervals',
      slug: 'merge-intervals',
      difficulty: 'Medium',
      tags: <String>['Array', 'Sorting'],
      functionName: 'merge',
      description: 'Merge all overlapping intervals.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'intervals = [[1,3],[2,6],[8,10],[15,18]]', output: '[[1,6],[8,10],[15,18]]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '42',
      title: 'Trapping Rain Water',
      slug: 'trapping-rain-water',
      difficulty: 'Hard',
      tags: <String>['Array', 'Two Pointers', 'Stack'],
      functionName: 'trap',
      description: 'Given elevation map `height`, compute how much water can be trapped after rain.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'height = [0,1,0,2,1,0,1,3,2,1,2,1]', output: '6'),
      ],
      constraints: <String>[],
    ),
  ];

  static const List<LeetcodeProblem> extraStrings = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '242',
      title: 'Valid Anagram',
      slug: 'valid-anagram',
      difficulty: 'Easy',
      tags: <String>['String', 'Hash Table'],
      functionName: 'isAnagram',
      description: 'Return `true` if `t` is an anagram of `s`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = "anagram", t = "nagaram"', output: 'true'),
        LeetcodeExample(input: 's = "rat", t = "car"', output: 'false'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '344',
      title: 'Reverse String',
      slug: 'reverse-string',
      difficulty: 'Easy',
      tags: <String>['String', 'Two Pointers'],
      functionName: 'reverseString',
      description: 'Reverse the character array `s` in-place.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = ["h","e","l","l","o"]', output: '["o","l","l","e","h"]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '387',
      title: 'First Unique Character',
      slug: 'first-unique-character-in-a-string',
      difficulty: 'Easy',
      tags: <String>['String', 'Hash Table'],
      functionName: 'firstUniqChar',
      description: 'Return the index of the first non-repeating character in `s`, or `-1` if none.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = "leetcode"', output: '0'),
        LeetcodeExample(input: 's = "aabb"', output: '-1'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '125',
      title: 'Valid Palindrome',
      slug: 'valid-palindrome',
      difficulty: 'Easy',
      tags: <String>['String', 'Two Pointers'],
      functionName: 'isPalindrome',
      description: 'Return `true` if `s` is a palindrome after converting to lowercase and removing non-alphanumeric characters.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = "A man, a plan, a canal: Panama"', output: 'true'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '424',
      title: 'Longest Repeating Character Replacement',
      slug: 'longest-repeating-character-replacement',
      difficulty: 'Medium',
      tags: <String>['String', 'Sliding Window'],
      functionName: 'characterReplacement',
      description: 'Return the length of the longest substring containing the same letter you can get after at most `k` replacements.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = "ABAB", k = 2', output: '4'),
      ],
      constraints: <String>[],
    ),
  ];

  static const List<LeetcodeProblem> extraHashMap = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '49',
      title: 'Group Anagrams',
      slug: 'group-anagrams',
      difficulty: 'Medium',
      tags: <String>['Hash Table', 'String'],
      functionName: 'groupAnagrams',
      description: 'Group the strings that are anagrams of each other.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'strs = ["eat","tea","tan","ate","nat","bat"]', output: '[["bat"],["nat","tan"],["ate","eat","tea"]]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '347',
      title: 'Top K Frequent Elements',
      slug: 'top-k-frequent-elements',
      difficulty: 'Medium',
      tags: <String>['Hash Table', 'Heap'],
      functionName: 'topKFrequent',
      description: 'Return the `k` most frequent elements in `nums`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,1,1,2,2,3], k = 2', output: '[1,2]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '560',
      title: 'Subarray Sum Equals K',
      slug: 'subarray-sum-equals-k',
      difficulty: 'Medium',
      tags: <String>['Hash Table', 'Prefix Sum'],
      functionName: 'subarraySum',
      description: 'Return the total number of continuous subarrays whose sum equals `k`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,1,1], k = 2', output: '2'),
      ],
      constraints: <String>[],
    ),
  ];

  static const List<LeetcodeProblem> extraStackQueue = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '155',
      title: 'Min Stack',
      slug: 'min-stack',
      difficulty: 'Medium',
      tags: <String>['Stack', 'Design'],
      functionName: 'MinStack',
      description: 'Design a stack that supports push, pop, top, and retrieving the minimum element in O(1).',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'push(-2), push(0), push(-3), getMin(), pop(), top(), getMin()', output: '-3, 0, -2'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '739',
      title: 'Daily Temperatures',
      slug: 'daily-temperatures',
      difficulty: 'Medium',
      tags: <String>['Stack', 'Monotonic Stack'],
      functionName: 'dailyTemperatures',
      description: 'For each day, return how many days until a warmer temperature (0 if none).',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'temperatures = [73,74,75,71,69,72,76,73]', output: '[1,1,4,2,1,1,0,0]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '150',
      title: 'Evaluate Reverse Polish Notation',
      slug: 'evaluate-reverse-polish-notation',
      difficulty: 'Medium',
      tags: <String>['Stack', 'Math'],
      functionName: 'evalRPN',
      description: 'Evaluate the value of an arithmetic expression in Reverse Polish Notation.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'tokens = ["2","1","+","3","*"]', output: '9'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '232',
      title: 'Implement Queue using Stacks',
      slug: 'implement-queue-using-stacks',
      difficulty: 'Easy',
      tags: <String>['Stack', 'Queue', 'Design'],
      functionName: 'MyQueue',
      description: 'Implement a FIFO queue using only stack operations.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'push(1), push(2), peek(), pop(), empty()', output: '1, 2, false'),
      ],
      constraints: <String>[],
    ),
  ];

  static const List<LeetcodeProblem> extraLinkedLists = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '141',
      title: 'Linked List Cycle',
      slug: 'linked-list-cycle',
      difficulty: 'Easy',
      tags: <String>['Linked List', 'Two Pointers'],
      functionName: 'hasCycle',
      description: 'Return `true` if the linked list has a cycle.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'head = [3,2,0,-4], pos = 1', output: 'true'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '19',
      title: 'Remove Nth Node From End of List',
      slug: 'remove-nth-node-from-end-of-list',
      difficulty: 'Medium',
      tags: <String>['Linked List', 'Two Pointers'],
      functionName: 'removeNthFromEnd',
      description: 'Remove the `n`th node from the end of the list and return its head.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'head = [1,2,3,4,5], n = 2', output: '[1,2,3,5]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '234',
      title: 'Palindrome Linked List',
      slug: 'palindrome-linked-list',
      difficulty: 'Easy',
      tags: <String>['Linked List', 'Two Pointers'],
      functionName: 'isPalindrome',
      description: 'Return `true` if the linked list is a palindrome.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'head = [1,2,2,1]', output: 'true'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '160',
      title: 'Intersection of Two Linked Lists',
      slug: 'intersection-of-two-linked-lists',
      difficulty: 'Easy',
      tags: <String>['Linked List', 'Two Pointers'],
      functionName: 'getIntersectionNode',
      description: 'Return the node where two singly linked lists intersect, or `null` if they do not.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'listA = [4,1,8,4,5], listB = [5,6,1,8,4,5]', output: 'intersect at 8'),
      ],
      constraints: <String>[],
    ),
  ];

  static const List<LeetcodeProblem> extraTrees = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '100',
      title: 'Same Tree',
      slug: 'same-tree',
      difficulty: 'Easy',
      tags: <String>['Tree', 'DFS'],
      functionName: 'isSameTree',
      description: 'Return `true` if two binary trees are structurally identical with the same values.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'p = [1,2,3], q = [1,2,3]', output: 'true'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '226',
      title: 'Invert Binary Tree',
      slug: 'invert-binary-tree',
      difficulty: 'Easy',
      tags: <String>['Tree', 'DFS', 'BFS'],
      functionName: 'invertTree',
      description: 'Invert a binary tree and return its root.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'root = [4,2,7,1,3,6,9]', output: '[4,7,2,9,6,3,1]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '102',
      title: 'Binary Tree Level Order Traversal',
      slug: 'binary-tree-level-order-traversal',
      difficulty: 'Medium',
      tags: <String>['Tree', 'BFS'],
      functionName: 'levelOrder',
      description: 'Return the level-order traversal of the binary tree nodes.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'root = [3,9,20,null,null,15,7]', output: '[[3],[9,20],[15,7]]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '572',
      title: 'Subtree of Another Tree',
      slug: 'subtree-of-another-tree',
      difficulty: 'Easy',
      tags: <String>['Tree', 'DFS'],
      functionName: 'isSubtree',
      description: 'Return `true` if `subRoot` is a subtree of `root`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'root = [3,4,5,1,2], subRoot = [4,1,2]', output: 'true'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '235',
      title: 'Lowest Common Ancestor of a BST',
      slug: 'lowest-common-ancestor-of-a-binary-search-tree',
      difficulty: 'Medium',
      tags: <String>['Tree', 'BST'],
      functionName: 'lowestCommonAncestor',
      description: 'Find the lowest common ancestor of two nodes in a BST.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'root = [6,2,8,0,4,7,9], p = 2, q = 8', output: '6'),
      ],
      constraints: <String>[],
    ),
  ];

  static const List<LeetcodeProblem> extraGraphs = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '133',
      title: 'Clone Graph',
      slug: 'clone-graph',
      difficulty: 'Medium',
      tags: <String>['Graph', 'DFS', 'BFS'],
      functionName: 'cloneGraph',
      description: 'Return a deep copy of the connected undirected graph.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'adjList = [[2,4],[1,3],[2,4],[1,3]]', output: 'deep copy of graph'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '207',
      title: 'Course Schedule',
      slug: 'course-schedule',
      difficulty: 'Medium',
      tags: <String>['Graph', 'Topological Sort'],
      functionName: 'canFinish',
      description: 'Return `true` if you can finish all courses given prerequisites (no cycle).',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'numCourses = 2, prerequisites = [[1,0]]', output: 'true'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '994',
      title: 'Rotting Oranges',
      slug: 'rotting-oranges',
      difficulty: 'Medium',
      tags: <String>['Graph', 'BFS', 'Matrix'],
      functionName: 'orangesRotting',
      description: 'Return the minimum minutes until no fresh orange remains, or `-1` if impossible.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'grid = [[2,1,1],[1,1,0],[0,1,1]]', output: '4'),
      ],
      constraints: <String>[],
    ),
  ];

  static const List<LeetcodeProblem> extraSorting = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '215',
      title: 'Kth Largest Element in an Array',
      slug: 'kth-largest-element-in-an-array',
      difficulty: 'Medium',
      tags: <String>['Array', 'Heap', 'Sorting'],
      functionName: 'findKthLargest',
      description: 'Return the `k`th largest element in the array.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [3,2,1,5,6,4], k = 2', output: '5'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '912',
      title: 'Sort an Array',
      slug: 'sort-an-array',
      difficulty: 'Medium',
      tags: <String>['Array', 'Sorting', 'Divide and Conquer'],
      functionName: 'sortArray',
      description: 'Sort `nums` in ascending order and return the sorted array.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [5,2,3,1]', output: '[1,2,3,5]'),
      ],
      constraints: <String>[],
    ),
  ];

  static const List<LeetcodeProblem> extraDp = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '198',
      title: 'House Robber',
      slug: 'house-robber',
      difficulty: 'Medium',
      tags: <String>['Dynamic Programming'],
      functionName: 'rob',
      description: 'Return the maximum amount you can rob tonight without alerting police (no two adjacent houses).',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,2,3,1]', output: '4'),
        LeetcodeExample(input: 'nums = [2,7,9,3,1]', output: '12'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '300',
      title: 'Longest Increasing Subsequence',
      slug: 'longest-increasing-subsequence',
      difficulty: 'Medium',
      tags: <String>['Dynamic Programming', 'Binary Search'],
      functionName: 'lengthOfLIS',
      description: 'Return the length of the longest strictly increasing subsequence.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [10,9,2,5,3,7,101,18]', output: '4'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '139',
      title: 'Word Break',
      slug: 'word-break',
      difficulty: 'Medium',
      tags: <String>['Dynamic Programming', 'String'],
      functionName: 'wordBreak',
      description: 'Return `true` if `s` can be segmented into a space-separated sequence of dictionary words.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = "leetcode", wordDict = ["leet","code"]', output: 'true'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '1143',
      title: 'Longest Common Subsequence',
      slug: 'longest-common-subsequence',
      difficulty: 'Medium',
      tags: <String>['Dynamic Programming', 'String'],
      functionName: 'longestCommonSubsequence',
      description: 'Return the length of the longest common subsequence of `text1` and `text2`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'text1 = "abcde", text2 = "ace"', output: '3'),
      ],
      constraints: <String>[],
    ),
  ];

  static const List<LeetcodeProblem> extraRecursion = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '50',
      title: 'Pow(x, n)',
      slug: 'powx-n',
      difficulty: 'Medium',
      tags: <String>['Recursion', 'Math'],
      functionName: 'myPow',
      description: 'Implement `pow(x, n)` which calculates `x` raised to the power `n`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'x = 2.00000, n = 10', output: '1024.00000'),
        LeetcodeExample(input: 'x = 2.00000, n = -2', output: '0.25000'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '78',
      title: 'Subsets',
      slug: 'subsets',
      difficulty: 'Medium',
      tags: <String>['Recursion', 'Backtracking'],
      functionName: 'subsets',
      description: 'Return all possible subsets of `nums`. The solution set must not contain duplicate subsets.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,2,3]', output: '[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '46',
      title: 'Permutations',
      slug: 'permutations',
      difficulty: 'Medium',
      tags: <String>['Recursion', 'Backtracking'],
      functionName: 'permute',
      description: 'Return all possible permutations of `nums`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,2,3]', output: '[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]'),
      ],
      constraints: <String>[],
    ),
  ];

  static const List<LeetcodeProblem> extraCompetitive = <LeetcodeProblem>[
    LeetcodeProblem(
      id: '23',
      title: 'Merge k Sorted Lists',
      slug: 'merge-k-sorted-lists',
      difficulty: 'Hard',
      tags: <String>['Linked List', 'Heap', 'Divide and Conquer'],
      functionName: 'mergeKLists',
      description: 'Merge `k` sorted linked lists and return it as one sorted list.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'lists = [[1,4,5],[1,3,4],[2,6]]', output: '[1,1,2,3,4,4,5,6]'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '76',
      title: 'Minimum Window Substring',
      slug: 'minimum-window-substring-hard',
      difficulty: 'Hard',
      tags: <String>['String', 'Sliding Window'],
      functionName: 'minWindow',
      description: 'Return the minimum window substring of `s` containing all characters of `t`.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = "ADOBECODEBANC", t = "ABC"', output: '"BANC"'),
      ],
      constraints: <String>[],
    ),
    LeetcodeProblem(
      id: '295',
      title: 'Find Median from Data Stream',
      slug: 'find-median-from-data-stream',
      difficulty: 'Hard',
      tags: <String>['Heap', 'Design'],
      functionName: 'MedianFinder',
      description: 'Design a data structure that supports adding integers and finding the median.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'addNum(1), addNum(2), findMedian(), addNum(3), findMedian()', output: '1.5, 2.0'),
      ],
      constraints: <String>[],
    ),
  ];

  static const List<LeetcodeProblem> extraDebug = <LeetcodeProblem>[
    LeetcodeProblem(
      id: 'debug-217',
      title: 'Contains Duplicate (Buggy)',
      slug: 'debug-contains-duplicate',
      difficulty: 'Easy',
      kind: LeetcodeProblemKind.debug,
      tags: <String>['Array', 'Debugging'],
      functionName: 'containsDuplicate',
      description: 'This duplicate check is wrong for some inputs. Fix the logic.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'nums = [1,2,3,1]', output: 'true'),
        LeetcodeExample(input: 'nums = [1,2,3,4]', output: 'false'),
      ],
      constraints: <String>[],
      starterCode: <String, String>{
        'python3': '''class Solution:
    def containsDuplicate(self, nums: list[int]) -> bool:
        for i in range(len(nums)):
            for j in range(i + 1, len(nums)):
                if nums[i] == nums[j]:
                    return True
        return False
''',
      },
      hiddenTests: <LeetcodeHiddenTest>[
        LeetcodeHiddenTest(input: 'nums = [1,1,1,3,3,4,3,2,4,2]', output: 'true'),
      ],
    ),
    LeetcodeProblem(
      id: 'debug-242',
      title: 'Valid Anagram (Buggy)',
      slug: 'debug-valid-anagram',
      difficulty: 'Easy',
      kind: LeetcodeProblemKind.debug,
      tags: <String>['String', 'Debugging'],
      functionName: 'isAnagram',
      description: 'The anagram check below fails when strings have different lengths or repeated chars. Fix it.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 's = "anagram", t = "nagaram"', output: 'true'),
        LeetcodeExample(input: 's = "rat", t = "car"', output: 'false'),
      ],
      constraints: <String>[],
      starterCode: <String, String>{
        'python3': '''class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        return sorted(s) == sorted(t) and len(s) == len(t) + 1
''',
      },
    ),
    LeetcodeProblem(
      id: 'debug-141',
      title: 'Linked List Cycle (Buggy)',
      slug: 'debug-linked-list-cycle',
      difficulty: 'Easy',
      kind: LeetcodeProblemKind.debug,
      tags: <String>['Linked List', 'Debugging'],
      functionName: 'hasCycle',
      description: 'Floyd\'s cycle detection below is broken. Fix the slow/fast pointer logic.',
      examples: <LeetcodeExample>[
        LeetcodeExample(input: 'head = [3,2,0,-4], pos = 1', output: 'true'),
        LeetcodeExample(input: 'head = [1]', output: 'false'),
      ],
      constraints: <String>[],
      starterCode: <String, String>{
        'python3': '''class Solution:
    def hasCycle(self, head) -> bool:
        slow = fast = head
        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next
            if slow == fast:
                return False
        return True
''',
      },
    ),
  ];
}
