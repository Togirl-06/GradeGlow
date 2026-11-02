"""GradeGlow-original Algorithm Arena problems.

Each problem has a statement, Python and JavaScript reference solutions, sample
inputs and hidden inputs. `gen_arena_originals.py` computes every expected
output by running the Python reference, writes lib/data/arena_original_problems.dart,
and the functions test suite re-checks both references through the real judge.
"""
from collections import deque
import heapq

L = 'Linked List'
T = 'Tree'

PROBLEMS = []


def problem(**kw):
    PROBLEMS.append(kw)
    return kw


# ---------------------------------------------------------------- Easy
def _pair_sum(nums, target):
    seen = {}
    for i, n in enumerate(nums):
        if target - n in seen:
            return [seen[target - n], i]
        seen[n] = i
    return []


problem(
    id='GGO-001', title='Twin Sum Lookup', slug='twin-sum-lookup', difficulty='Easy', tags=['Array', 'Hash Table'],
    fn='pairSum', params=['nums', 'target'],
    description='A cashier scans prices `nums`. Return the indices `[i, j]` (with `i < j`) of the two prices that add up to `target`. '
                'Exactly one pair works, and the same index cannot be used twice.',
    constraints=['2 <= nums.length <= 10^4', '-10^9 <= nums[i], target <= 10^9', 'Exactly one valid pair exists.'],
    py=_pair_sum,
    py_src='class Solution:\n    def pairSum(self, nums: List[int], target: int) -> List[int]:\n        seen = {}\n        for i, n in enumerate(nums):\n            if target - n in seen:\n                return [seen[target - n], i]\n            seen[n] = i\n',
    js_src='var pairSum = function(nums, target) {\n  const seen = new Map();\n  for (let i = 0; i < nums.length; i++) {\n    if (seen.has(target - nums[i])) return [seen.get(target - nums[i]), i];\n    seen.set(nums[i], i);\n  }\n};',
    examples=[([[2, 7, 11, 15], 9], 'nums[0] + nums[1] = 2 + 7 = 9.'), ([[3, 2, 4], 6], None)],
    hidden=[[[3, 3], 6], [[-1, -2, -3, -4, -5], -8], [[0, 4, 3, 0], 0], [[1, 5, 9, 14, 20], 34], [list(range(0, 2000, 2)) + [7], 1005]],
)


def _brackets_ok(s):
    st, m = [], {')': '(', ']': '[', '}': '{'}
    for c in s:
        if c in m:
            if not st or st.pop() != m[c]:
                return False
        else:
            st.append(c)
    return not st


problem(
    id='GGO-002', title='Bracket Inspector', slug='bracket-inspector', difficulty='Easy', tags=['String', 'Stack'],
    fn='bracketsOk', params=['s'],
    description='A code formatter must check that every bracket in `s` (only `()[]{}`) is closed by the same type, in the right order. Return `true` if `s` is balanced.',
    constraints=['1 <= s.length <= 10^4', 's contains only ()[]{}'],
    py=_brackets_ok,
    py_src='class Solution:\n    def bracketsOk(self, s: str) -> bool:\n        st, m = [], {")": "(", "]": "[", "}": "{"}\n        for c in s:\n            if c in m:\n                if not st or st.pop() != m[c]:\n                    return False\n            else:\n                st.append(c)\n        return not st\n',
    js_src='var bracketsOk = function(s) {\n  const st = [], m = {")": "(", "]": "[", "}": "{"};\n  for (const c of s) {\n    if (m[c]) { if (st.pop() !== m[c]) return false; } else st.push(c);\n  }\n  return st.length === 0;\n};',
    examples=[(['()[]{}'], None), (['(]'], 'The round bracket is closed by a square one.'), (['{[()]}'], None)],
    hidden=[['('], [')'], ['([)]'], ['(((((((((())))))))))'], ['{}{}{}[[]]'], ['((('],],
)


def _best_trade(prices):
    lo, best = float('inf'), 0
    for p in prices:
        lo = min(lo, p)
        best = max(best, p - lo)
    return best


problem(
    id='GGO-003', title='Best Single Trade', slug='best-single-trade', difficulty='Easy', tags=['Array', 'Greedy'],
    fn='bestTrade', params=['prices'],
    description='`prices[i]` is the practice-market price of a share on day `i`. Buy on one day and sell on a later day. Return the largest profit possible, or `0` if every trade loses money.',
    constraints=['1 <= prices.length <= 10^5', '0 <= prices[i] <= 10^4'],
    py=_best_trade,
    py_src='class Solution:\n    def bestTrade(self, prices: List[int]) -> int:\n        lo, best = float("inf"), 0\n        for p in prices:\n            lo = min(lo, p)\n            best = max(best, p - lo)\n        return best\n',
    js_src='var bestTrade = function(prices) {\n  let lo = Infinity, best = 0;\n  for (const p of prices) { lo = Math.min(lo, p); best = Math.max(best, p - lo); }\n  return best;\n};',
    examples=[([[7, 1, 5, 3, 6, 4]], 'Buy at 1 on day 1, sell at 6 on day 4.'), ([[7, 6, 4, 3, 1]], 'Prices only fall, so do not trade.')],
    hidden=[[[1, 2]], [[2, 4, 1]], [[3, 3, 5, 0, 0, 3, 1, 4]], [[5]], [[9, 1, 8, 2, 7, 3, 10]]],
)


def _find_index(nums, target):
    lo, hi = 0, len(nums) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if nums[mid] == target:
            return mid
        if nums[mid] < target:
            lo = mid + 1
        else:
            hi = mid - 1
    return -1


problem(
    id='GGO-004', title='Shelf Finder', slug='shelf-finder', difficulty='Easy', tags=['Array', 'Binary Search'],
    fn='findIndex', params=['nums', 'target'],
    description='Library shelf numbers `nums` are sorted ascending and distinct. Return the index of `target`, or `-1` if it is not on the shelf. Aim for O(log n).',
    constraints=['1 <= nums.length <= 10^5', 'nums is sorted ascending with distinct values'],
    py=_find_index,
    py_src='class Solution:\n    def findIndex(self, nums: List[int], target: int) -> int:\n        lo, hi = 0, len(nums) - 1\n        while lo <= hi:\n            mid = (lo + hi) // 2\n            if nums[mid] == target:\n                return mid\n            if nums[mid] < target:\n                lo = mid + 1\n            else:\n                hi = mid - 1\n        return -1\n',
    js_src='var findIndex = function(nums, target) {\n  let lo = 0, hi = nums.length - 1;\n  while (lo <= hi) { const m = (lo + hi) >> 1; if (nums[m] === target) return m; if (nums[m] < target) lo = m + 1; else hi = m - 1; }\n  return -1;\n};',
    examples=[([[-1, 0, 3, 5, 9, 12], 9], None), ([[-1, 0, 3, 5, 9, 12], 2], '2 is not in the list.')],
    hidden=[[[5], 5], [[1, 3], 3], [[1, 3], 0], [list(range(0, 3000, 3)), 2997], [list(range(0, 3000, 3)), 1000]],
)


def _stair_paths(n):
    a, b = 1, 1
    for _ in range(n):
        a, b = b, a + b
    return a


problem(
    id='GGO-005', title='Stair Paths', slug='stair-paths', difficulty='Easy', tags=['Dynamic Programming', 'Math'],
    fn='stairPaths', params=['n'],
    description='The library staircase has `n` steps. Each move climbs 1 or 2 steps. In how many different ways can you reach the top?',
    constraints=['1 <= n <= 45'],
    py=_stair_paths,
    py_src='class Solution:\n    def stairPaths(self, n: int) -> int:\n        a, b = 1, 1\n        for _ in range(n):\n            a, b = b, a + b\n        return a\n',
    js_src='var stairPaths = function(n) {\n  let a = 1, b = 1;\n  for (let i = 0; i < n; i++) [a, b] = [b, a + b];\n  return a;\n};',
    examples=[([2], '1+1 or 2.'), ([3], '1+1+1, 1+2 or 2+1.')],
    hidden=[[1], [5], [10], [30], [45]],
)


def _is_palindrome_text(s):
    t = [c.lower() for c in s if c.isalnum()]
    return t == t[::-1]


problem(
    id='GGO-006', title='Mirror Message', slug='mirror-message', difficulty='Easy', tags=['String', 'Two Pointers'],
    fn='isMirror', params=['s'],
    description='Return `true` if `s` reads the same forwards and backwards after removing every character that is not a letter or digit and ignoring case.',
    constraints=['1 <= s.length <= 2 * 10^5'],
    py=_is_palindrome_text,
    py_src='class Solution:\n    def isMirror(self, s: str) -> bool:\n        t = [c.lower() for c in s if c.isalnum()]\n        return t == t[::-1]\n',
    js_src='var isMirror = function(s) {\n  const t = s.toLowerCase().replace(/[^a-z0-9]/g, "");\n  return t === [...t].reverse().join("");\n};',
    examples=[(['A man, a plan, a canal: Panama'], None), (['race a car'], None)],
    hidden=[[' '], ['0P'], ['Was it a car or a cat I saw?'], ['ab_a'], ['No lemon, no melon']],
)


def _move_zeros(nums):
    k = 0
    for x in nums:
        if x:
            nums[k] = x
            k += 1
    for i in range(k, len(nums)):
        nums[i] = 0
    return nums


problem(
    id='GGO-007', title='Zeros to the Back', slug='zeros-to-the-back', difficulty='Easy', tags=['Array', 'Two Pointers'],
    fn='zerosToBack', params=['nums'],
    description='Rearrange `nums` **in place** so every `0` moves to the end while the other values keep their order. Do not return anything; the judge checks `nums` afterwards.',
    constraints=['1 <= nums.length <= 10^4'],
    py=lambda nums: _move_zeros(list(nums)),
    py_src='class Solution:\n    def zerosToBack(self, nums: List[int]) -> None:\n        k = 0\n        for x in nums:\n            if x:\n                nums[k] = x\n                k += 1\n        for i in range(k, len(nums)):\n            nums[i] = 0\n',
    js_src='var zerosToBack = function(nums) {\n  let k = 0;\n  for (const x of nums) if (x) nums[k++] = x;\n  while (k < nums.length) nums[k++] = 0;\n};',
    examples=[([[0, 1, 0, 3, 12]], None), ([[0]], None)],
    hidden=[[[1, 2, 3]], [[0, 0, 1]], [[4, 0, 5, 0, 0, 6, 7]], [[-1, 0, -2, 0]]],
)


def _top_word(words):
    from collections import Counter
    c = Counter(words)
    return min(c.items(), key=lambda kv: (-kv[1], kv[0]))[0]


problem(
    id='GGO-008', title='Trending Word', slug='trending-word', difficulty='Easy', tags=['Hash Table', 'String'],
    fn='trendingWord', params=['words'],
    description='Given the words students typed into the campus search bar today, return the most frequent word. If several words tie, return the one that comes first alphabetically.',
    constraints=['1 <= words.length <= 10^4', 'words[i] contains lowercase letters only'],
    py=_top_word,
    py_src='class Solution:\n    def trendingWord(self, words: List[str]) -> str:\n        count = {}\n        for w in words:\n            count[w] = count.get(w, 0) + 1\n        return min(count, key=lambda w: (-count[w], w))\n',
    js_src='var trendingWord = function(words) {\n  const c = new Map();\n  for (const w of words) c.set(w, (c.get(w) || 0) + 1);\n  return [...c.entries()].sort((a, b) => b[1] - a[1] || (a[0] < b[0] ? -1 : 1))[0][0];\n};',
    examples=[([['exam', 'lab', 'exam', 'cafe']], None), ([['b', 'a', 'b', 'a']], 'a and b tie; a comes first.')],
    hidden=[[['solo']], [['z', 'y', 'x']], [['lab', 'lab', 'gym', 'gym', 'gym']], [['cs'] * 5 + ['law'] * 5 + ['art'] * 2]],
)


# ---------------------------------------------------------------- Medium
def _best_streak(nums):
    cur = best = nums[0]
    for x in nums[1:]:
        cur = max(x, cur + x)
        best = max(best, cur)
    return best


problem(
    id='GGO-101', title='Best Streak Sum', slug='best-streak-sum', difficulty='Medium', tags=['Array', 'Dynamic Programming'],
    fn='bestStreak', params=['nums'],
    description='`nums[i]` is the change in your study-streak score on day `i`. Return the largest total over any run of consecutive days (at least one day).',
    constraints=['1 <= nums.length <= 10^5', '-10^4 <= nums[i] <= 10^4'],
    py=_best_streak,
    py_src='class Solution:\n    def bestStreak(self, nums: List[int]) -> int:\n        cur = best = nums[0]\n        for x in nums[1:]:\n            cur = max(x, cur + x)\n            best = max(best, cur)\n        return best\n',
    js_src='var bestStreak = function(nums) {\n  let cur = nums[0], best = nums[0];\n  for (let i = 1; i < nums.length; i++) { cur = Math.max(nums[i], cur + nums[i]); best = Math.max(best, cur); }\n  return best;\n};',
    examples=[([[-2, 1, -3, 4, -1, 2, 1, -5, 4]], 'Days 3 to 6: 4 - 1 + 2 + 1 = 6.'), ([[5, 4, -1, 7, 8]], None)],
    hidden=[[[-3, -1, -2]], [[-1]], [[1]], [[2, -1, 2, -1, 2]], [[-5, 10, -4, 3, -100, 9]]],
)


def _longest_unique(s):
    last, lo, best = {}, 0, 0
    for i, c in enumerate(s):
        if c in last and last[c] >= lo:
            lo = last[c] + 1
        last[c] = i
        best = max(best, i - lo + 1)
    return best


problem(
    id='GGO-102', title='Unique Signal Run', slug='unique-signal-run', difficulty='Medium', tags=['String', 'Sliding Window'],
    fn='longestUniqueRun', params=['s'],
    description='A sensor logs one character per second in `s`. Return the length of the longest stretch with no repeated character.',
    constraints=['0 <= s.length <= 5 * 10^4'],
    py=_longest_unique,
    py_src='class Solution:\n    def longestUniqueRun(self, s: str) -> int:\n        last, lo, best = {}, 0, 0\n        for i, c in enumerate(s):\n            if c in last and last[c] >= lo:\n                lo = last[c] + 1\n            last[c] = i\n            best = max(best, i - lo + 1)\n        return best\n',
    js_src='var longestUniqueRun = function(s) {\n  const last = new Map(); let lo = 0, best = 0;\n  for (let i = 0; i < s.length; i++) { if (last.has(s[i]) && last.get(s[i]) >= lo) lo = last.get(s[i]) + 1; last.set(s[i], i); best = Math.max(best, i - lo + 1); }\n  return best;\n};',
    examples=[(['abcabcbb'], '"abc" has length 3.'), (['bbbbb'], None), (['pwwkew'], '"wke" has length 3.')],
    hidden=[[''], [' '], ['dvdf'], ['abba'], ['abcdefghijklmnopqrstuvwxyzabc']],
)


def _merge_shifts(intervals):
    out = []
    for a, b in sorted(intervals):
        if out and a <= out[-1][1]:
            out[-1][1] = max(out[-1][1], b)
        else:
            out.append([a, b])
    return out


problem(
    id='GGO-103', title='Merge Lab Bookings', slug='merge-lab-bookings', difficulty='Medium', tags=['Array', 'Sorting'],
    fn='mergeBookings', params=['intervals'],
    description='Each booking `[start, end]` reserves the lab. Merge every overlapping or touching booking and return the merged bookings sorted by start time.',
    constraints=['1 <= intervals.length <= 10^4', '0 <= start <= end <= 10^4'],
    py=_merge_shifts,
    py_src='class Solution:\n    def mergeBookings(self, intervals: List[List[int]]) -> List[List[int]]:\n        out = []\n        for a, b in sorted(intervals):\n            if out and a <= out[-1][1]:\n                out[-1][1] = max(out[-1][1], b)\n            else:\n                out.append([a, b])\n        return out\n',
    js_src='var mergeBookings = function(intervals) {\n  const out = [];\n  for (const [a, b] of [...intervals].sort((x, y) => x[0] - y[0] || x[1] - y[1])) {\n    if (out.length && a <= out[out.length - 1][1]) out[out.length - 1][1] = Math.max(out[out.length - 1][1], b);\n    else out.push([a, b]);\n  }\n  return out;\n};',
    examples=[([[[1, 3], [2, 6], [8, 10], [15, 18]]], None), ([[[1, 4], [4, 5]]], 'Touching bookings merge.')],
    hidden=[[[[1, 4], [0, 4]]], [[[1, 4], [2, 3]]], [[[5, 6], [1, 2]]], [[[1, 10], [2, 3], [4, 5], [11, 12]]]],
)


def _count_islands(grid):
    g = [row[:] for row in grid]
    R, C, n = len(g), len(g[0]), 0
    for i in range(R):
        for j in range(C):
            if g[i][j] == '1':
                n += 1
                st = [(i, j)]
                g[i][j] = '0'
                while st:
                    a, b = st.pop()
                    for x, y in ((a + 1, b), (a - 1, b), (a, b + 1), (a, b - 1)):
                        if 0 <= x < R and 0 <= y < C and g[x][y] == '1':
                            g[x][y] = '0'
                            st.append((x, y))
    return n


problem(
    id='GGO-104', title='Count the Islands', slug='count-the-islands', difficulty='Medium', tags=['Graph', 'Breadth-First Search'],
    fn='countIslands', params=['grid'],
    description='A survey map `grid` marks land `"1"` and water `"0"`. Land cells connected up, down, left or right form one island. Return the number of islands.',
    constraints=['1 <= rows, cols <= 300'],
    py=_count_islands,
    py_src='class Solution:\n    def countIslands(self, grid: List[List[str]]) -> int:\n        rows, cols, count = len(grid), len(grid[0]), 0\n        seen = set()\n        for r in range(rows):\n            for c in range(cols):\n                if grid[r][c] == "1" and (r, c) not in seen:\n                    count += 1\n                    stack = [(r, c)]\n                    seen.add((r, c))\n                    while stack:\n                        a, b = stack.pop()\n                        for x, y in ((a+1, b), (a-1, b), (a, b+1), (a, b-1)):\n                            if 0 <= x < rows and 0 <= y < cols and grid[x][y] == "1" and (x, y) not in seen:\n                                seen.add((x, y))\n                                stack.append((x, y))\n        return count\n',
    js_src='var countIslands = function(grid) {\n  const g = grid.map((r) => r.slice()); let n = 0;\n  for (let i = 0; i < g.length; i++) for (let j = 0; j < g[0].length; j++) if (g[i][j] === "1") {\n    n++; const st = [[i, j]]; g[i][j] = "0";\n    while (st.length) { const [a, b] = st.pop(); for (const [x, y] of [[a+1,b],[a-1,b],[a,b+1],[a,b-1]]) if (x >= 0 && y >= 0 && x < g.length && y < g[0].length && g[x][y] === "1") { g[x][y] = "0"; st.push([x, y]); } }\n  }\n  return n;\n};',
    examples=[([[['1', '1', '0'], ['1', '0', '0'], ['0', '0', '1']]], None), ([[['1', '1', '1', '1', '0'], ['1', '1', '0', '1', '0'], ['1', '1', '0', '0', '0'], ['0', '0', '0', '0', '0']]], None)],
    hidden=[[[['1']]], [[['0']]], [[['1', '0', '1'], ['0', '1', '0'], ['1', '0', '1']]], [[['1' if (i // 2 + j // 2) % 2 == 0 else '0' for j in range(20)] for i in range(20)]]],
)


def _fewest_coins(coins, amount):
    INF = float('inf')
    dp = [0] + [INF] * amount
    for a in range(1, amount + 1):
        for c in coins:
            if c <= a and dp[a - c] + 1 < dp[a]:
                dp[a] = dp[a - c] + 1
    return -1 if dp[amount] == INF else dp[amount]


problem(
    id='GGO-105', title='Fewest Coins', slug='fewest-coins', difficulty='Medium', tags=['Dynamic Programming'],
    fn='fewestCoins', params=['coins', 'amount'],
    description='The campus vending machine gives change using coin values `coins` (unlimited of each). Return the fewest coins that make exactly `amount`, or `-1` if it is impossible. Taking the largest coin first does not always work.',
    constraints=['1 <= coins.length <= 12', '0 <= amount <= 10^4'],
    py=_fewest_coins,
    py_src='class Solution:\n    def fewestCoins(self, coins: List[int], amount: int) -> int:\n        INF = float("inf")\n        dp = [0] + [INF] * amount\n        for a in range(1, amount + 1):\n            for c in coins:\n                if c <= a and dp[a - c] + 1 < dp[a]:\n                    dp[a] = dp[a - c] + 1\n        return -1 if dp[amount] == INF else dp[amount]\n',
    js_src='var fewestCoins = function(coins, amount) {\n  const dp = new Array(amount + 1).fill(Infinity); dp[0] = 0;\n  for (let a = 1; a <= amount; a++) for (const c of coins) if (c <= a && dp[a - c] + 1 < dp[a]) dp[a] = dp[a - c] + 1;\n  return dp[amount] === Infinity ? -1 : dp[amount];\n};',
    examples=[([[1, 2, 5], 11], '5 + 5 + 1.'), ([[2], 3], None), ([[1], 0], None)],
    hidden=[[[186, 419, 83, 408], 6249], [[1, 5, 10, 25], 63], [[3, 7], 5], [[2, 5, 10, 1], 27], [[1, 3, 4], 6]],
)


def _reverse_chain(head):
    return list(reversed(head))


problem(
    id='GGO-106', title='Reverse the Chain', slug='reverse-the-chain', difficulty='Easy', tags=[L],
    fn='reverseChain', params=['head'], list_params=['head'],
    description='`head` is the first node of a singly linked list (`val`, `next`). Reverse the list and return the new head.',
    constraints=['0 <= number of nodes <= 5000'],
    py=_reverse_chain,
    py_src='class Solution:\n    def reverseChain(self, head: Optional[ListNode]) -> Optional[ListNode]:\n        prev = None\n        while head:\n            head.next, prev, head = prev, head, head.next\n        return prev\n',
    js_src='var reverseChain = function(head) {\n  let prev = null;\n  while (head) { const n = head.next; head.next = prev; prev = head; head = n; }\n  return prev;\n};',
    examples=[([[1, 2, 3, 4, 5]], None), ([[1, 2]], None)],
    hidden=[[[]], [[7]], [list(range(50))]],
)


def _merge_chains(list1, list2):
    return sorted(list1 + list2)


problem(
    id='GGO-107', title='Merge Two Queues', slug='merge-two-queues', difficulty='Easy', tags=[L],
    fn='mergeQueues', params=['list1', 'list2'], list_params=['list1', 'list2'],
    description='Two sorted linked lists `list1` and `list2` hold ticket numbers. Merge them into one sorted linked list and return its head.',
    constraints=['0 <= nodes in each list <= 50', 'Both lists are sorted ascending'],
    py=_merge_chains,
    py_src='class Solution:\n    def mergeQueues(self, list1: Optional[ListNode], list2: Optional[ListNode]) -> Optional[ListNode]:\n        dummy = tail = ListNode()\n        while list1 and list2:\n            if list1.val <= list2.val:\n                tail.next, list1 = list1, list1.next\n            else:\n                tail.next, list2 = list2, list2.next\n            tail = tail.next\n        tail.next = list1 or list2\n        return dummy.next\n',
    js_src='var mergeQueues = function(a, b) {\n  const dummy = new ListNode(); let t = dummy;\n  while (a && b) { if (a.val <= b.val) { t.next = a; a = a.next; } else { t.next = b; b = b.next; } t = t.next; }\n  t.next = a || b;\n  return dummy.next;\n};',
    examples=[([[1, 2, 4], [1, 3, 4]], None), ([[], [0]], None)],
    hidden=[[[], []], [[5], [1, 2, 3]], [[1, 1, 1], [1, 1]], [[-3, 0, 9], [-5, 2, 10, 11]]],
)


def _tree_height(root):
    # root is level order; compute depth from the array.
    if not root or root[0] is None:
        return 0
    nodes = [(root[0], 1)]
    q = deque(nodes)
    i, best = 1, 1
    while q and i < len(root):
        _, d = q.popleft()
        for _ in range(2):
            if i < len(root) and root[i] is not None:
                q.append((root[i], d + 1))
                best = max(best, d + 1)
            i += 1
    return best


problem(
    id='GGO-108', title='Tree Height', slug='tree-height', difficulty='Easy', tags=[T, 'Depth-First Search'],
    fn='treeHeight', params=['root'], tree_params=['root'],
    description='`root` is the root of a binary tree (`val`, `left`, `right`), shown here in level order with `null` for missing children. Return the number of nodes on the longest path from the root down to a leaf.',
    constraints=['0 <= number of nodes <= 10^4'],
    py=_tree_height,
    py_src='class Solution:\n    def treeHeight(self, root: Optional[TreeNode]) -> int:\n        if not root:\n            return 0\n        return 1 + max(self.treeHeight(root.left), self.treeHeight(root.right))\n',
    js_src='var treeHeight = function(root) {\n  return root ? 1 + Math.max(treeHeight(root.left), treeHeight(root.right)) : 0;\n};',
    examples=[([[3, 9, 20, None, None, 15, 7]], None), ([[1, None, 2]], None)],
    hidden=[[[]], [[0]], [[1, 2, 3, 4, None, None, 5, 6]], [[1, 2, None, 3, None, 4, None, 5]]],
)


def _warmer_days(temps):
    out, st = [0] * len(temps), []
    for i, t in enumerate(temps):
        while st and temps[st[-1]] < t:
            j = st.pop()
            out[j] = i - j
        st.append(i)
    return out


problem(
    id='GGO-109', title='Warmer Days Ahead', slug='warmer-days-ahead', difficulty='Medium', tags=['Stack', 'Monotonic Stack'],
    fn='warmerDays', params=['temps'],
    description='For each day in `temps`, return how many days you must wait for a strictly warmer day. Use `0` when no warmer day comes.',
    constraints=['1 <= temps.length <= 10^5', '30 <= temps[i] <= 100'],
    py=_warmer_days,
    py_src='class Solution:\n    def warmerDays(self, temps: List[int]) -> List[int]:\n        out, st = [0] * len(temps), []\n        for i, t in enumerate(temps):\n            while st and temps[st[-1]] < t:\n                j = st.pop()\n                out[j] = i - j\n            st.append(i)\n        return out\n',
    js_src='var warmerDays = function(temps) {\n  const out = new Array(temps.length).fill(0), st = [];\n  temps.forEach((t, i) => { while (st.length && temps[st[st.length - 1]] < t) { const j = st.pop(); out[j] = i - j; } st.push(i); });\n  return out;\n};',
    examples=[([[73, 74, 75, 71, 69, 72, 76, 73]], None), ([[30, 40, 50, 60]], None)],
    hidden=[[[30, 60, 90]], [[90, 80, 70]], [[50]], [[55, 55, 56, 54, 57]]],
)


def _kth_largest(nums, k):
    return heapq.nlargest(k, nums)[-1]


problem(
    id='GGO-110', title='Kth Highest Score', slug='kth-highest-score', difficulty='Medium', tags=['Heap', 'Sorting'],
    fn='kthHighest', params=['nums', 'k'],
    description='Return the `k`-th highest exam score in `nums` (counting duplicates; the 1st highest is the maximum).',
    constraints=['1 <= k <= nums.length <= 10^5'],
    py=_kth_largest,
    py_src='class Solution:\n    def kthHighest(self, nums: List[int], k: int) -> int:\n        return heapq.nlargest(k, nums)[-1]\n',
    js_src='var kthHighest = function(nums, k) {\n  return [...nums].sort((a, b) => b - a)[k - 1];\n};',
    examples=[([[3, 2, 1, 5, 6, 4], 2], None), ([[3, 2, 3, 1, 2, 4, 5, 5, 6], 4], None)],
    hidden=[[[1], 1], [[7, 7, 7], 2], [[-1, -5, 0, 3], 4], [list(range(100)), 10]],
)


def _can_finish(n, prereqs):
    indeg = [0] * n
    adj = [[] for _ in range(n)]
    for a, b in prereqs:
        adj[b].append(a)
        indeg[a] += 1
    q = deque(i for i in range(n) if indeg[i] == 0)
    seen = 0
    while q:
        x = q.popleft()
        seen += 1
        for y in adj[x]:
            indeg[y] -= 1
            if indeg[y] == 0:
                q.append(y)
    return seen == n


problem(
    id='GGO-111', title='Degree Plan Check', slug='degree-plan-check', difficulty='Medium', tags=['Graph', 'Topological Sort'],
    fn='canGraduate', params=['n', 'prereqs'],
    description='There are `n` courses numbered `0` to `n-1`. Each pair `[a, b]` in `prereqs` means course `b` must be taken before course `a`. Return `true` if a student can take every course.',
    constraints=['1 <= n <= 2000', '0 <= prereqs.length <= 5000'],
    py=_can_finish,
    py_src='class Solution:\n    def canGraduate(self, n: int, prereqs: List[List[int]]) -> bool:\n        indeg = [0] * n\n        adj = [[] for _ in range(n)]\n        for a, b in prereqs:\n            adj[b].append(a)\n            indeg[a] += 1\n        q = deque(i for i in range(n) if indeg[i] == 0)\n        seen = 0\n        while q:\n            x = q.popleft()\n            seen += 1\n            for y in adj[x]:\n                indeg[y] -= 1\n                if indeg[y] == 0:\n                    q.append(y)\n        return seen == n\n',
    js_src='var canGraduate = function(n, prereqs) {\n  const indeg = new Array(n).fill(0), adj = Array.from({ length: n }, () => []);\n  for (const [a, b] of prereqs) { adj[b].push(a); indeg[a]++; }\n  const q = []; for (let i = 0; i < n; i++) if (!indeg[i]) q.push(i);\n  let seen = 0;\n  while (q.length) { const x = q.shift(); seen++; for (const y of adj[x]) if (--indeg[y] === 0) q.push(y); }\n  return seen === n;\n};',
    examples=[([2, [[1, 0]]], 'Take course 0, then course 1.'), ([2, [[1, 0], [0, 1]]], 'Each course needs the other first.')],
    hidden=[[1, []], [3, [[1, 0], [2, 1]]], [3, [[0, 1], [1, 2], [2, 0]]], [4, [[1, 0], [2, 0], [3, 1], [3, 2]]]],
)


def _rotate_grid(matrix):
    return [list(r) for r in zip(*matrix[::-1])]


problem(
    id='GGO-112', title='Rotate the Floor Plan', slug='rotate-the-floor-plan', difficulty='Medium', tags=['Array', 'Matrix'],
    fn='rotatePlan', params=['matrix'],
    description='Return a new `n x n` grid equal to `matrix` rotated 90 degrees clockwise.',
    constraints=['1 <= n <= 20'],
    py=_rotate_grid,
    py_src='class Solution:\n    def rotatePlan(self, matrix: List[List[int]]) -> List[List[int]]:\n        return [list(row) for row in zip(*matrix[::-1])]\n',
    js_src='var rotatePlan = function(m) {\n  const n = m.length;\n  return Array.from({ length: n }, (_, i) => Array.from({ length: n }, (_, j) => m[n - 1 - j][i]));\n};',
    examples=[([[[1, 2, 3], [4, 5, 6], [7, 8, 9]]], None), ([[[1]]], None)],
    hidden=[[[[1, 2], [3, 4]]], [[[5, 1, 9, 11], [2, 4, 8, 10], [13, 3, 6, 7], [15, 14, 12, 16]]]],
)


# ---------------------------------------------------------------- Hard
def _rain_catcher(h):
    l, r, lm, rm, w = 0, len(h) - 1, 0, 0, 0
    while l < r:
        if h[l] < h[r]:
            lm = max(lm, h[l])
            w += lm - h[l]
            l += 1
        else:
            rm = max(rm, h[r])
            w += rm - h[r]
            r -= 1
    return w


problem(
    id='GGO-201', title='Rain Catcher', slug='rain-catcher', difficulty='Hard', tags=['Array', 'Two Pointers'],
    fn='rainCatcher', params=['heights'],
    description='`heights` is a skyline of rooftops, each 1 unit wide. After a storm, how many units of rain are trapped between the rooftops?',
    constraints=['1 <= heights.length <= 2 * 10^4', '0 <= heights[i] <= 10^5'],
    py=_rain_catcher,
    py_src='class Solution:\n    def rainCatcher(self, heights: List[int]) -> int:\n        l, r, lm, rm, w = 0, len(heights) - 1, 0, 0, 0\n        while l < r:\n            if heights[l] < heights[r]:\n                lm = max(lm, heights[l]); w += lm - heights[l]; l += 1\n            else:\n                rm = max(rm, heights[r]); w += rm - heights[r]; r -= 1\n        return w\n',
    js_src='var rainCatcher = function(h) {\n  let l = 0, r = h.length - 1, lm = 0, rm = 0, w = 0;\n  while (l < r) { if (h[l] < h[r]) { lm = Math.max(lm, h[l]); w += lm - h[l++]; } else { rm = Math.max(rm, h[r]); w += rm - h[r--]; } }\n  return w;\n};',
    examples=[([[0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]], None), ([[4, 2, 0, 3, 2, 5]], None)],
    hidden=[[[5]], [[2, 0, 2]], [[5, 4, 1, 2]], [[3, 0, 0, 2, 0, 4]], [[1, 0, 1, 0, 1, 0, 1, 0, 1]]],
)


def _edit_steps(a, b):
    dp = list(range(len(b) + 1))
    for i in range(1, len(a) + 1):
        prev, dp[0] = dp[0], i
        for j in range(1, len(b) + 1):
            cur = dp[j]
            dp[j] = prev if a[i - 1] == b[j - 1] else 1 + min(prev, dp[j], dp[j - 1])
            prev = cur
    return dp[-1]


problem(
    id='GGO-202', title='Edit Steps', slug='edit-steps', difficulty='Hard', tags=['String', 'Dynamic Programming'],
    fn='editSteps', params=['a', 'b'],
    description='A spell-checker can insert, delete or replace one character per step. Return the fewest steps that turn word `a` into word `b`.',
    constraints=['0 <= a.length, b.length <= 500'],
    py=_edit_steps,
    py_src='class Solution:\n    def editSteps(self, a: str, b: str) -> int:\n        dp = list(range(len(b) + 1))\n        for i in range(1, len(a) + 1):\n            prev, dp[0] = dp[0], i\n            for j in range(1, len(b) + 1):\n                cur = dp[j]\n                dp[j] = prev if a[i-1] == b[j-1] else 1 + min(prev, dp[j], dp[j-1])\n                prev = cur\n        return dp[-1]\n',
    js_src='var editSteps = function(a, b) {\n  let dp = Array.from({ length: b.length + 1 }, (_, j) => j);\n  for (let i = 1; i <= a.length; i++) { let prev = dp[0]; dp[0] = i; for (let j = 1; j <= b.length; j++) { const cur = dp[j]; dp[j] = a[i-1] === b[j-1] ? prev : 1 + Math.min(prev, dp[j], dp[j-1]); prev = cur; } }\n  return dp[b.length];\n};',
    examples=[(['horse', 'ros'], 'horse -> rorse -> rose -> ros.'), (['intention', 'execution'], None)],
    hidden=[['', ''], ['', 'abc'], ['kitten', 'sitting'], ['gradeglow', 'gradeglow'], ['abcdef', 'azced']],
)
