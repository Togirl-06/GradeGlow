import '../models/leetcode_problem.dart';
import 'coding_languages.dart';

/// Builds language-specific buggy starter code for debug challenges.
class DebugStarterLocalizer {
  DebugStarterLocalizer._();

  static String forProblem(LeetcodeProblem problem, CodingLanguage language) {
    final String langId = _normalizeId(language.id);
    final String? exact = problem.starterCode[langId] ??
        problem.starterCode[language.id] ??
        (langId == 'python3' ? problem.starterCode['python'] : null);
    if (exact != null && exact.trim().isNotEmpty) return exact;

    final Map<String, String>? variants = _byFunction[problem.functionName];
    if (variants != null) {
      final String? match = variants[langId] ?? variants[language.id];
      if (match != null) return match;
    }

    final String? python = problem.starterCode['python3'] ?? problem.starterCode['python'];
    if (python != null && python.trim().isNotEmpty) {
      return _wrapTranslated(problem.functionName, langId, python);
    }

    return CodingLanguage.starterFor(language, problem.functionName);
  }

  static String _normalizeId(String id) {
    if (id == 'python') return 'python3';
    return id;
  }

  /// When we only have Python source, emit a same-bug skeleton in the target language.
  static String _wrapTranslated(String functionName, String langId, String pythonSource) {
    final String note = '// Same bug as the Python starter — fix the logic.\n';
    return switch (langId) {
      'javascript' => '''$note/**
 * @return {*}
 */
var $functionName = function(...args) {
    // TODO: port and fix the buggy logic below
    // Python reference (buggy):
    /*
$pythonSource*/
};
''',
      'typescript' => '''${note}function $functionName(...args: any[]): any {
    // TODO: port and fix the buggy logic
    // Python reference (buggy):
    /*
$pythonSource*/
}
''',
      'java' => '''${note}class Solution {
    public Object $functionName(Object... args) {
        // TODO: port and fix the buggy logic
        // Python reference (buggy):
        /*
$pythonSource*/
        return null;
    }
}
''',
      'cpp' => '''${note}class Solution {
public:
    auto $functionName(auto... args) {
        // TODO: port and fix the buggy logic
        /*
$pythonSource*/
    }
};
''',
      'csharp' => '''${note}public class Solution {
    public object ${functionName[0].toUpperCase()}${functionName.substring(1)}(params object[] args) {
        // TODO: port and fix the buggy logic
        /*
$pythonSource*/
        return null;
    }
}
''',
      'go' => '''${note}func $functionName(args ...interface{}) interface{} {
    // TODO: port and fix the buggy logic
    /*
$pythonSource*/
    return nil
}
''',
      'kotlin' => '''${note}class Solution {
    fun $functionName(vararg args: Any?): Any? {
        // TODO: port and fix the buggy logic
        /*
$pythonSource*/
        return null
    }
}
''',
      'swift' => '''${note}class Solution {
    func $functionName(_ args: Any...) -> Any? {
        // TODO: port and fix the buggy logic
        /*
$pythonSource*/
        return nil
    }
}
''',
      'rust' => '''${note}impl Solution {
    pub fn $functionName(args: Vec<i32>) -> i32 {
        // TODO: port and fix the buggy logic
        /*
$pythonSource*/
        0
    }
}
''',
      'dart' => '''${note}class Solution {
  dynamic $functionName(List args) {
    // TODO: port and fix the buggy logic
    /*
$pythonSource*/
    return null;
  }
}
''',
      'ruby' => '''$note# TODO: port and fix the buggy logic
def $functionName(*args)
  # Python reference (buggy):
=begin
$pythonSource
=end
end
''',
      'php' => '''$note<?php
class Solution {
    function $functionName(...\$args) {
        // TODO: port and fix the buggy logic
        /*
$pythonSource*/
        return null;
    }
}
''',
      'c' => '''${note}int $functionName(/* args */) {
    /* TODO: port and fix the buggy logic
$pythonSource*/
    return 0;
}
''',
      'scala' => '''${note}object Solution {
    def $functionName(args: Any*): Any = {
        // TODO: port and fix the buggy logic
        /*
$pythonSource*/
        null
    }
}
''',
      _ => pythonSource,
    };
  }

  /// Hand-written multi-language buggy starters for common debug challenges.
  static final Map<String, Map<String, String>> _byFunction = <String, Map<String, String>>{
    'maxProfit': <String, String>{
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
      'javascript': '''/**
 * @param {number[]} prices
 * @return {number}
 */
var maxProfit = function(prices) {
    if (!prices.length) return 0;
    let minPrice = 0;
    let best = 0;
    for (const p of prices) {
        minPrice = Math.min(minPrice, p);
        best = Math.max(best, p - minPrice);
    }
    return best;
};
''',
      'typescript': '''function maxProfit(prices: number[]): number {
    if (!prices.length) return 0;
    let minPrice = 0;
    let best = 0;
    for (const p of prices) {
        minPrice = Math.min(minPrice, p);
        best = Math.max(best, p - minPrice);
    }
    return best;
}
''',
      'java': '''class Solution {
    public int maxProfit(int[] prices) {
        if (prices.length == 0) return 0;
        int minPrice = 0;
        int best = 0;
        for (int p : prices) {
            minPrice = Math.min(minPrice, p);
            best = Math.max(best, p - minPrice);
        }
        return best;
    }
}
''',
      'cpp': '''class Solution {
public:
    int maxProfit(vector<int>& prices) {
        if (prices.empty()) return 0;
        int minPrice = 0;
        int best = 0;
        for (int p : prices) {
            minPrice = min(minPrice, p);
            best = max(best, p - minPrice);
        }
        return best;
    }
};
''',
      'csharp': '''public class Solution {
    public int MaxProfit(int[] prices) {
        if (prices.Length == 0) return 0;
        int minPrice = 0;
        int best = 0;
        foreach (int p in prices) {
            minPrice = Math.Min(minPrice, p);
            best = Math.Max(best, p - minPrice);
        }
        return best;
    }
}
''',
      'go': '''func maxProfit(prices []int) int {
    if len(prices) == 0 {
        return 0
    }
    minPrice := 0
    best := 0
    for _, p := range prices {
        if p < minPrice {
            minPrice = p
        }
        if p-minPrice > best {
            best = p - minPrice
        }
    }
    return best
}
''',
      'dart': '''class Solution {
  int maxProfit(List<int> prices) {
    if (prices.isEmpty) return 0;
    int minPrice = 0;
    int best = 0;
    for (final int p in prices) {
      minPrice = minPrice < p ? minPrice : p;
      final int profit = p - minPrice;
      if (profit > best) best = profit;
    }
    return best;
  }
}
''',
    },
    'twoSum': <String, String>{
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
      'cpp': '''class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        for (int i = 0; i < (int)nums.size(); i++) {
            for (int j = 0; j < (int)nums.size(); j++) {
                if (nums[i] + nums[j] == target) return {i, j};
            }
        }
        return {};
    }
};
''',
      'typescript': '''function twoSum(nums: number[], target: number): number[] {
    for (let i = 0; i < nums.length; i++) {
        for (let j = 0; j < nums.length; j++) {
            if (nums[i] + nums[j] === target) return [i, j];
        }
    }
    return [];
}
''',
    },
    'isValid': <String, String>{
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
      'java': '''class Solution {
    public boolean isValid(String s) {
        java.util.Deque<Character> stack = new java.util.ArrayDeque<>();
        for (char ch : s.toCharArray()) {
            if (ch == ')' || ch == ']' || ch == '}') {
                if (stack.isEmpty()) return false;
                char open = stack.pop();
                if ((ch == ')' && open != '(') || (ch == ']' && open != '[') || (ch == '}' && open != '{')) return false;
            } else {
                stack.push(ch);
            }
        }
        return stack.isEmpty();
    }
}
''',
    },
    'containsDuplicate': <String, String>{
      'python3': '''class Solution:
    def containsDuplicate(self, nums: list[int]) -> bool:
        seen = set()
        for n in nums:
            seen.add(n)
        return len(seen) == len(nums)
''',
      'javascript': '''/**
 * @param {number[]} nums
 * @return {boolean}
 */
var containsDuplicate = function(nums) {
    const seen = new Set();
    for (const n of nums) seen.add(n);
    return seen.size === nums.length;
};
''',
      'java': '''class Solution {
    public boolean containsDuplicate(int[] nums) {
        java.util.Set<Integer> seen = new java.util.HashSet<>();
        for (int n : nums) seen.add(n);
        return seen.size() == nums.length;
    }
}
''',
      'typescript': '''function containsDuplicate(nums: number[]): boolean {
    const seen = new Set<number>();
    for (const n of nums) seen.add(n);
    return seen.size === nums.length;
}
''',
    },
    'climbStairs': <String, String>{
      'python3': '''class Solution:
    def climbStairs(self, n: int) -> int:
        if n <= 2:
            return 1
        a, b = 1, 1
        for _ in range(3, n + 1):
            a, b = b, a + b
        return b
''',
      'javascript': '''/**
 * @param {number} n
 * @return {number}
 */
var climbStairs = function(n) {
    if (n <= 2) return 1;
    let a = 1, b = 1;
    for (let i = 3; i <= n; i++) {
        const next = a + b;
        a = b;
        b = next;
    }
    return b;
};
''',
      'java': '''class Solution {
    public int climbStairs(int n) {
        if (n <= 2) return 1;
        int a = 1, b = 1;
        for (int i = 3; i <= n; i++) {
            int next = a + b;
            a = b;
            b = next;
        }
        return b;
    }
}
''',
    },
    'search': <String, String>{
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
      'java': '''class Solution {
    public int search(int[] nums, int target) {
        int left = 0, right = nums.length;
        while (left < right) {
            int mid = (left + right) / 2;
            if (nums[mid] == target) return mid;
            if (nums[mid] < target) left = mid;
            else right = mid;
        }
        return -1;
    }
}
''',
    },
    'isAnagram': <String, String>{
      'python3': '''class Solution:
    def isAnagram(self, s: str, t: str) -> bool:
        if len(s) != len(t):
            return True
        return sorted(s) == sorted(t)
''',
      'javascript': '''/**
 * @param {string} s
 * @param {string} t
 * @return {boolean}
 */
var isAnagram = function(s, t) {
    if (s.length !== t.length) return true;
    return [...s].sort().join('') === [...t].sort().join('');
};
''',
      'java': '''class Solution {
    public boolean isAnagram(String s, String t) {
        if (s.length() != t.length()) return true;
        char[] a = s.toCharArray();
        char[] b = t.toCharArray();
        java.util.Arrays.sort(a);
        java.util.Arrays.sort(b);
        return java.util.Arrays.equals(a, b);
    }
}
''',
    },
    'singleNumber': <String, String>{
      'python3': '''class Solution:
    def singleNumber(self, nums: list[int]) -> int:
        ans = 1
        for n in nums:
            ans ^= n
        return ans
''',
      'javascript': '''/**
 * @param {number[]} nums
 * @return {number}
 */
var singleNumber = function(nums) {
    let ans = 1;
    for (const n of nums) ans ^= n;
    return ans;
};
''',
      'java': '''class Solution {
    public int singleNumber(int[] nums) {
        int ans = 1;
        for (int n : nums) ans ^= n;
        return ans;
    }
}
''',
    },
    'moveZeroes': <String, String>{
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
      'javascript': '''/**
 * @param {number[]} nums
 * @return {void}
 */
var moveZeroes = function(nums) {
    let write = 0;
    for (const n of nums) {
        if (n !== 0) {
            nums[write] = n;
            write++;
        }
    }
    while (write < nums.length) {
        nums[write] = 0;
        write++;
    }
};
''',
      'java': '''class Solution {
    public void moveZeroes(int[] nums) {
        int write = 0;
        for (int n : nums) {
            if (n != 0) nums[write++] = n;
        }
        while (write < nums.length) nums[write++] = 0;
    }
}
''',
    },
  };
}
