import '../models/leetcode_problem.dart';

/// Additional debug challenges — buggy starter code users must fix.
class LeetcodeDebugBank {
  LeetcodeDebugBank._();

  static const List<LeetcodeProblem> all = <LeetcodeProblem>[
    _containsDuplicateBug,
    _validAnagramBug,
    _maxProfitBug,
    _climbStairsBug,
    _reverseListBug,
    _maxDepthBug,
    _numIslandsBug,
    _coinChangeBug,
    _lengthOfLongestSubstringBug,
    _groupAnagramsBug,
    _dailyTemperaturesBug,
    _hasCycleBug,
    _invertTreeBug,
    _canFinishBug,
    _houseRobberBug,
    _subsetsBug,
    _moveZeroesBug,
    _singleNumberBug,
    _validPalindromeBug,
    _mergeIntervalsBug,
    _rotateArrayBug,
    _productExceptSelfBug,
    _minStackBug,
    _levelOrderBug,
    _wordBreakBug,
    _permuteBug,
    _trapBug,
    _kthLargestBug,
    _lruCacheBug,
    _sortColorsBug,
  ];

  static const LeetcodeProblem _containsDuplicateBug = LeetcodeProblem(
    id: 'debug-bank-217',
    title: 'Contains Duplicate (Buggy)',
    slug: 'debug-bank-contains-duplicate',
    difficulty: 'Easy',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Array', 'Debugging'],
    functionName: 'containsDuplicate',
    description: 'Return `true` if any value appears at least twice. The code below always returns false.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [1,2,3,1]', output: 'true'),
      LeetcodeExample(input: 'nums = [1,2,3,4]', output: 'false'),
    ],
    constraints: <String>['1 <= nums.length <= 10^5'],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def containsDuplicate(self, nums: list[int]) -> bool:
        seen = set()
        for n in nums:
            seen.add(n)
        return len(seen) == len(nums)
''',
    },
  );

  static const LeetcodeProblem _validAnagramBug = LeetcodeProblem(
    id: 'debug-bank-242',
    title: 'Valid Anagram (Buggy)',
    slug: 'debug-bank-valid-anagram',
    difficulty: 'Easy',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['String', 'Debugging'],
    functionName: 'isAnagram',
    description: 'Return whether `t` is an anagram of `s`. The frequency check is wrong.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 's = "anagram", t = "nagaram"', output: 'true'),
      LeetcodeExample(input: 's = "rat", t = "car"', output: 'false'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        if len(s) != len(t):
            return True
        return sorted(s) == sorted(t)
''',
    },
  );

  static const LeetcodeProblem _maxProfitBug = LeetcodeProblem(
    id: 'debug-bank-121',
    title: 'Best Time to Buy and Sell Stock (Buggy)',
    slug: 'debug-bank-best-time-to-buy-and-sell-stock',
    difficulty: 'Easy',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Array', 'Debugging'],
    functionName: 'maxProfit',
    description: 'Find max profit from one buy and one sell. The loop tracks the wrong minimum.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'prices = [7,1,5,3,6,4]', output: '5'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def maxProfit(self, prices: list[int]) -> int:
        if not prices:
            return 0
        min_price = 0
        best = 0
        for p in prices:
            min_price = min(min_price, p)
            best = max(best, p - min_price)
        return best
''',
    },
  );

  static const LeetcodeProblem _climbStairsBug = LeetcodeProblem(
    id: 'debug-bank-70',
    title: 'Climbing Stairs (Buggy)',
    slug: 'debug-bank-climbing-stairs',
    difficulty: 'Easy',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Dynamic Programming', 'Debugging'],
    functionName: 'climbStairs',
    description: 'Count ways to climb `n` stairs taking 1 or 2 steps. Base cases are incorrect.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'n = 3', output: '3'),
      LeetcodeExample(input: 'n = 2', output: '2'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def climbStairs(self, n: int) -> int:
        if n <= 2:
            return 1
        a, b = 1, 1
        for _ in range(3, n + 1):
            a, b = b, a + b
        return b
''',
    },
  );

  static const LeetcodeProblem _reverseListBug = LeetcodeProblem(
    id: 'debug-bank-206b',
    title: 'Reverse Linked List (Buggy)',
    slug: 'debug-bank-reverse-linked-list',
    difficulty: 'Easy',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Linked List', 'Debugging'],
    functionName: 'reverseList',
    description: 'Reverse a singly linked list. Pointer updates drop the tail.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'head = [1,2,3,4,5]', output: '[5,4,3,2,1]'),
    ],
    constraints: <String>[],
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
            head = nxt
        return head
''',
    },
  );

  static const LeetcodeProblem _maxDepthBug = LeetcodeProblem(
    id: 'debug-bank-104',
    title: 'Maximum Depth of Binary Tree (Buggy)',
    slug: 'debug-bank-max-depth',
    difficulty: 'Easy',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Tree', 'Debugging'],
    functionName: 'maxDepth',
    description: 'Return max depth of a binary tree. The recursion never goes right.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'root = [3,9,20,null,null,15,7]', output: '3'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

class Solution:
    def maxDepth(self, root: TreeNode) -> int:
        if root is None:
            return 0
        return 1 + self.maxDepth(root.left)
''',
    },
  );

  static const LeetcodeProblem _numIslandsBug = LeetcodeProblem(
    id: 'debug-bank-200',
    title: 'Number of Islands (Buggy)',
    slug: 'debug-bank-number-of-islands',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Graph', 'Debugging'],
    functionName: 'numIslands',
    description: 'Count islands of `1` in a grid. DFS does not mark visited cells.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'grid = [["1","1","0"],["0","1","0"],["1","0","1"]]', output: '3'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def numIslands(self, grid: list[list[str]]) -> int:
        if not grid:
            return 0
        rows, cols = len(grid), len(grid[0])
        count = 0

        def dfs(r: int, c: int) -> None:
            if r < 0 or c < 0 or r >= rows or c >= cols or grid[r][c] != "1":
                return
            dfs(r + 1, c)
            dfs(r - 1, c)
            dfs(r, c + 1)
            dfs(r, c - 1)

        for r in range(rows):
            for c in range(cols):
                if grid[r][c] == "1":
                    count += 1
                    dfs(r, c)
        return count
''',
    },
  );

  static const LeetcodeProblem _coinChangeBug = LeetcodeProblem(
    id: 'debug-bank-322',
    title: 'Coin Change (Buggy)',
    slug: 'debug-bank-coin-change',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Dynamic Programming', 'Debugging'],
    functionName: 'coinChange',
    description: 'Fewest coins to make `amount`. DP initialization is wrong.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'coins = [1,2,5], amount = 11', output: '3'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def coinChange(self, coins: list[int], amount: int) -> int:
        dp = [0] * (amount + 1)
        for a in range(1, amount + 1):
            best = float("inf")
            for c in coins:
                if a - c >= 0:
                    best = min(best, dp[a - c] + 1)
            dp[a] = best
        return dp[amount] if dp[amount] != float("inf") else -1
''',
    },
  );

  static const LeetcodeProblem _lengthOfLongestSubstringBug = LeetcodeProblem(
    id: 'debug-bank-3',
    title: 'Longest Substring Without Repeating (Buggy)',
    slug: 'debug-bank-longest-substring',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['String', 'Debugging'],
    functionName: 'lengthOfLongestSubstring',
    description: 'Sliding window never shrinks when a duplicate appears.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 's = "abcabcbb"', output: '3'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        seen = set()
        best = 0
        left = 0
        for right in range(len(s)):
            seen.add(s[right])
            best = max(best, right - left + 1)
        return best
''',
    },
  );

  static const LeetcodeProblem _groupAnagramsBug = LeetcodeProblem(
    id: 'debug-bank-49',
    title: 'Group Anagrams (Buggy)',
    slug: 'debug-bank-group-anagrams',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Hash Table', 'Debugging'],
    functionName: 'groupAnagrams',
    description: 'Group anagrams using a key that does not ignore character order.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'strs = ["eat","tea","tan","ate","nat","bat"]', output: 'grouped anagrams'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def groupAnagrams(self, strs: list[str]) -> list[list[str]]:
        groups: dict[str, list[str]] = {}
        for word in strs:
            key = word
            groups.setdefault(key, []).append(word)
        return list(groups.values())
''',
    },
  );

  static const LeetcodeProblem _dailyTemperaturesBug = LeetcodeProblem(
    id: 'debug-bank-739',
    title: 'Daily Temperatures (Buggy)',
    slug: 'debug-bank-daily-temperatures',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Stack', 'Debugging'],
    functionName: 'dailyTemperatures',
    description: 'Days until warmer temperature. Stack indices are never popped.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'temperatures = [73,74,75,71,69,72,76,73]', output: '[1,1,4,2,1,1,0,0]'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def dailyTemperatures(self, temperatures: list[int]) -> list[int]:
        n = len(temperatures)
        ans = [0] * n
        stack: list[int] = []
        for i, t in enumerate(temperatures):
            stack.append(i)
            for j in stack:
                if temperatures[j] < t:
                    ans[j] = i - j
        return ans
''',
    },
  );

  static const LeetcodeProblem _hasCycleBug = LeetcodeProblem(
    id: 'debug-bank-141b',
    title: 'Linked List Cycle (Buggy)',
    slug: 'debug-bank-linked-list-cycle',
    difficulty: 'Easy',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Linked List', 'Debugging'],
    functionName: 'hasCycle',
    description: 'Detect a cycle. Fast and slow pointers move at the same speed.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'head = [3,2,0,-4], pos = 1', output: 'true'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def hasCycle(self, head) -> bool:
        slow = fast = head
        while fast and fast.next:
            slow = slow.next
            fast = fast.next
            if slow == fast:
                return True
        return False
''',
    },
  );

  static const LeetcodeProblem _invertTreeBug = LeetcodeProblem(
    id: 'debug-bank-226',
    title: 'Invert Binary Tree (Buggy)',
    slug: 'debug-bank-invert-tree',
    difficulty: 'Easy',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Tree', 'Debugging'],
    functionName: 'invertTree',
    description: 'Invert a binary tree. Only the root children are swapped.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'root = [4,2,7,1,3,6,9]', output: '[4,7,2,9,6,3,1]'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

class Solution:
    def invertTree(self, root: TreeNode) -> TreeNode:
        if not root:
            return None
        root.left, root.right = root.right, root.left
        return root
''',
    },
  );

  static const LeetcodeProblem _canFinishBug = LeetcodeProblem(
    id: 'debug-bank-207',
    title: 'Course Schedule (Buggy)',
    slug: 'debug-bank-course-schedule',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Graph', 'Debugging'],
    functionName: 'canFinish',
    description: 'Detect if all courses can be finished. Cycle detection never marks nodes visited.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'numCourses = 2, prerequisites = [[1,0]]', output: 'true'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def canFinish(self, numCourses: int, prerequisites: list[list[int]]) -> bool:
        graph: dict[int, list[int]] = {i: [] for i in range(numCourses)}
        for course, pre in prerequisites:
            graph[pre].append(course)

        def dfs(node: int, path: set[int]) -> bool:
            if node in path:
                return False
            path.add(node)
            for nxt in graph[node]:
                if not dfs(nxt, path):
                    return False
            return True

        for i in range(numCourses):
            if not dfs(i, set()):
                return False
        return True
''',
    },
  );

  static const LeetcodeProblem _houseRobberBug = LeetcodeProblem(
    id: 'debug-bank-198',
    title: 'House Robber (Buggy)',
    slug: 'debug-bank-house-robber',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Dynamic Programming', 'Debugging'],
    functionName: 'rob',
    description: 'Max money without robbing adjacent houses. Allows robbing neighbors.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [2,7,9,3,1]', output: '12'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def rob(self, nums: list[int]) -> int:
        if not nums:
            return 0
        prev2 = prev1 = 0
        for n in nums:
            prev2, prev1 = prev1, max(prev1 + n, prev2 + n)
        return prev1
''',
    },
  );

  static const LeetcodeProblem _subsetsBug = LeetcodeProblem(
    id: 'debug-bank-78',
    title: 'Subsets (Buggy)',
    slug: 'debug-bank-subsets',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Backtracking', 'Debugging'],
    functionName: 'subsets',
    description: 'Return all subsets. Backtracking never explores without the current element.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [1,2,3]', output: '8 subsets'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def subsets(self, nums: list[int]) -> list[list[int]]:
        res: list[list[int]] = []

        def backtrack(start: int, path: list[int]) -> None:
            res.append(path[:])
            for i in range(start, len(nums)):
                path.append(nums[i])
                backtrack(i + 1, path)
                path.pop()

        backtrack(0, [])
        return res
''',
    },
  );

  static const LeetcodeProblem _moveZeroesBug = LeetcodeProblem(
    id: 'debug-bank-283',
    title: 'Move Zeroes (Buggy)',
    slug: 'debug-bank-move-zeroes',
    difficulty: 'Easy',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Array', 'Debugging'],
    functionName: 'moveZeroes',
    description: 'Move zeroes to the end in-place. Non-zero order is not preserved.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [0,1,0,3,12]', output: '[1,3,12,0,0]'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def moveZeroes(self, nums: list[int]) -> None:
        write = 0
        for n in nums:
            if n != 0:
                nums[write] = n
                write += 1
        while write < len(nums):
            nums[write] = 0
            write += 1
''',
    },
  );

  static const LeetcodeProblem _singleNumberBug = LeetcodeProblem(
    id: 'debug-bank-136',
    title: 'Single Number (Buggy)',
    slug: 'debug-bank-single-number',
    difficulty: 'Easy',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Bit Manipulation', 'Debugging'],
    functionName: 'singleNumber',
    description: 'Find the element that appears once. XOR combines with zero incorrectly.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [4,1,2,1,2]', output: '4'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def singleNumber(self, nums: list[int]) -> int:
        ans = 1
        for n in nums:
            ans ^= n
        return ans
''',
    },
  );

  static const LeetcodeProblem _validPalindromeBug = LeetcodeProblem(
    id: 'debug-bank-125',
    title: 'Valid Palindrome (Buggy)',
    slug: 'debug-bank-valid-palindrome',
    difficulty: 'Easy',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['String', 'Debugging'],
    functionName: 'isPalindrome',
    description: 'Check palindrome ignoring non-alphanumeric. Pointers do not skip junk characters.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 's = "A man, a plan, a canal: Panama"', output: 'true'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def isPalindrome(self, s: str) -> bool:
        s = s.lower()
        left, right = 0, len(s) - 1
        while left < right:
            if s[left] != s[right]:
                return False
            left += 1
            right -= 1
        return True
''',
    },
  );

  static const LeetcodeProblem _mergeIntervalsBug = LeetcodeProblem(
    id: 'debug-bank-56',
    title: 'Merge Intervals (Buggy)',
    slug: 'debug-bank-merge-intervals',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Array', 'Debugging'],
    functionName: 'merge',
    description: 'Merge overlapping intervals. Intervals are not sorted first.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'intervals = [[1,3],[2,6],[8,10],[15,18]]', output: '[[1,6],[8,10],[15,18]]'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def merge(self, intervals: list[list[int]]) -> list[list[int]]:
        if not intervals:
            return []
        merged = [intervals[0]]
        for start, end in intervals[1:]:
            last = merged[-1]
            if start <= last[1]:
                last[1] = max(last[1], end)
            else:
                merged.append([start, end])
        return merged
''',
    },
  );

  static const LeetcodeProblem _rotateArrayBug = LeetcodeProblem(
    id: 'debug-bank-189',
    title: 'Rotate Array (Buggy)',
    slug: 'debug-bank-rotate-array',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Array', 'Debugging'],
    functionName: 'rotate',
    description: 'Rotate array right by `k`. Does not handle `k` larger than length.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [1,2,3,4,5,6,7], k = 3', output: '[5,6,7,1,2,3,4]'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def rotate(self, nums: list[int], k: int) -> None:
        n = len(nums)
        nums[:] = nums[-k:] + nums[:-k]
''',
    },
  );

  static const LeetcodeProblem _productExceptSelfBug = LeetcodeProblem(
    id: 'debug-bank-238',
    title: 'Product of Array Except Self (Buggy)',
    slug: 'debug-bank-product-except-self',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Array', 'Debugging'],
    functionName: 'productExceptSelf',
    description: 'Product of all elements except self. Uses division which fails on zeros.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [1,2,3,4]', output: '[24,12,8,6]'),
    ],
    constraints: <String>['Do not use division'],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def productExceptSelf(self, nums: list[int]) -> list[int]:
        total = 1
        for n in nums:
            total *= n
        return [total // n for n in nums]
''',
    },
  );

  static const LeetcodeProblem _minStackBug = LeetcodeProblem(
    id: 'debug-bank-155',
    title: 'Min Stack (Buggy)',
    slug: 'debug-bank-min-stack',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Stack', 'Debugging'],
    functionName: 'MinStack',
    description: 'Stack with O(1) getMin. Min stack is not updated on pop.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'push(-2), push(0), push(-3), getMin()', output: '-3'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class MinStack:
    def __init__(self):
        self.stack = []
        self.mins = []

    def push(self, val: int) -> None:
        self.stack.append(val)
        if not self.mins or val <= self.mins[-1]:
            self.mins.append(val)

    def pop(self) -> None:
        self.stack.pop()

    def top(self) -> int:
        return self.stack[-1]

    def getMin(self) -> int:
        return self.mins[-1]
''',
    },
  );

  static const LeetcodeProblem _levelOrderBug = LeetcodeProblem(
    id: 'debug-bank-102',
    title: 'Binary Tree Level Order (Buggy)',
    slug: 'debug-bank-level-order',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Tree', 'BFS', 'Debugging'],
    functionName: 'levelOrder',
    description: 'Return level-order traversal. BFS puts all nodes in one level.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'root = [3,9,20,null,null,15,7]', output: '[[3],[9,20],[15,7]]'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

class Solution:
    def levelOrder(self, root: TreeNode) -> list[list[int]]:
        if not root:
            return []
        queue = [root]
        res: list[list[int]] = []
        level: list[int] = []
        while queue:
            node = queue.pop(0)
            level.append(node.val)
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)
        res.append(level)
        return res
''',
    },
  );

  static const LeetcodeProblem _wordBreakBug = LeetcodeProblem(
    id: 'debug-bank-139',
    title: 'Word Break (Buggy)',
    slug: 'debug-bank-word-break',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Dynamic Programming', 'Debugging'],
    functionName: 'wordBreak',
    description: 'Segment string using dictionary. Greedy picks shortest prefix only.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 's = "leetcode", wordDict = ["leet","code"]', output: 'true'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def wordBreak(self, s: str, wordDict: list[str]) -> bool:
        words = set(wordDict)
        for i in range(1, len(s) + 1):
            if s[:i] in words and self.wordBreak(s[i:], wordDict):
                return True
        return s == ""
''',
    },
  );

  static const LeetcodeProblem _permuteBug = LeetcodeProblem(
    id: 'debug-bank-46',
    title: 'Permutations (Buggy)',
    slug: 'debug-bank-permutations',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Backtracking', 'Debugging'],
    functionName: 'permute',
    description: 'Generate permutations. Reuses the same element in one path.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [1,2,3]', output: '6 permutations'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def permute(self, nums: list[int]) -> list[list[int]]:
        res: list[list[int]] = []

        def backtrack(path: list[int]) -> None:
            if len(path) == len(nums):
                res.append(path[:])
                return
            for n in nums:
                path.append(n)
                backtrack(path)
                path.pop()

        backtrack([])
        return res
''',
    },
  );

  static const LeetcodeProblem _trapBug = LeetcodeProblem(
    id: 'debug-bank-42',
    title: 'Trapping Rain Water (Buggy)',
    slug: 'debug-bank-trapping-rain-water',
    difficulty: 'Hard',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Array', 'Debugging'],
    functionName: 'trap',
    description: 'Compute trapped water. Uses min of neighbors incorrectly.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'height = [0,1,0,2,1,0,1,3,2,1,2,1]', output: '6'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def trap(self, height: list[int]) -> int:
        if not height:
            return 0
        water = 0
        for i in range(1, len(height) - 1):
            left_max = max(height[:i])
            right_max = max(height[i + 1:])
            water += max(0, min(left_max, right_max) - height[i])
        return water
''',
    },
  );

  static const LeetcodeProblem _kthLargestBug = LeetcodeProblem(
    id: 'debug-bank-215',
    title: 'Kth Largest Element (Buggy)',
    slug: 'debug-bank-kth-largest',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Heap', 'Debugging'],
    functionName: 'findKthLargest',
    description: 'Find kth largest element. Sorts ascending and picks wrong index.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [3,2,1,5,6,4], k = 2', output: '5'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def findKthLargest(self, nums: list[int], k: int) -> int:
        nums.sort()
        return nums[k - 1]
''',
    },
  );

  static const LeetcodeProblem _lruCacheBug = LeetcodeProblem(
    id: 'debug-bank-146',
    title: 'LRU Cache (Buggy)',
    slug: 'debug-bank-lru-cache',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Design', 'Debugging'],
    functionName: 'LRUCache',
    description: 'LRU cache get/put. `get` does not refresh recency.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'put(1,1), put(2,2), get(1), put(3,3)', output: 'get(1)=1'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class LRUCache:
    def __init__(self, capacity: int):
        self.cap = capacity
        self.store: dict[int, int] = {}

    def get(self, key: int) -> int:
        return self.store.get(key, -1)

    def put(self, key: int, value: int) -> None:
        if key not in self.store and len(self.store) >= self.cap:
            self.store.pop(next(iter(self.store)))
        self.store[key] = value
''',
    },
  );

  static const LeetcodeProblem _sortColorsBug = LeetcodeProblem(
    id: 'debug-bank-75',
    title: 'Sort Colors (Buggy)',
    slug: 'debug-bank-sort-colors',
    difficulty: 'Medium',
    kind: LeetcodeProblemKind.debug,
    tags: <String>['Array', 'Debugging'],
    functionName: 'sortColors',
    description: 'Sort 0/1/2 in-place. Counting sort writes in wrong order.',
    examples: <LeetcodeExample>[
      LeetcodeExample(input: 'nums = [2,0,2,1,1,0]', output: '[0,0,1,1,2,2]'),
    ],
    constraints: <String>[],
    starterCode: <String, String>{
      'python3': '''class Solution:
    def sortColors(self, nums: list[int]) -> None:
        counts = [0, 0, 0]
        for n in nums:
            counts[n] += 1
        i = 0
        for color in range(3):
            for _ in range(counts[color]):
                nums[i] = color
                i += 1
''',
    },
  );
}
