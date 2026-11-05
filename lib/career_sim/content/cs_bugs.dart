// Broken code for the bug-fix tasks. Each starter is verified to fail the
// hidden tests (functions/test/career_debug_starters.test.js).

const Map<String, String> bugBracketsIgnoresType = <String, String>{
  'python3': 'class Solution:\n    def bracketsOk(self, s: str) -> bool:\n        stack = []\n        for ch in s:\n            if ch in \'([{\':\n                stack.append(ch)\n            elif stack:\n                stack.pop()\n            else:\n                return False\n        return len(stack) == 0\n',
  'javascript': 'var bracketsOk = function(s) {\n    const stack = [];\n    for (const ch of s) {\n        if (\'([{\'.includes(ch)) {\n            stack.push(ch);\n        } else if (stack.length > 0) {\n            stack.pop();\n        } else {\n            return false;\n        }\n    }\n    return stack.length === 0;\n};\n',
};

const Map<String, String> bugBracketsLeftover = <String, String>{
  'python3': 'class Solution:\n    def bracketsOk(self, s: str) -> bool:\n        stack = []\n        pairs = {\')\': \'(\', \']\': \'[\', \'}\': \'{\'}\n        for ch in s:\n            if ch in \'([{\':\n                stack.append(ch)\n            elif not stack or stack.pop() != pairs[ch]:\n                return False\n        return True\n',
  'javascript': 'var bracketsOk = function(s) {\n    const stack = [];\n    const pairs = { \')\': \'(\', \']\': \'[\', \'}\': \'{\' };\n    for (const ch of s) {\n        if (\'([{\'.includes(ch)) {\n            stack.push(ch);\n        } else if (stack.length === 0 || stack.pop() !== pairs[ch]) {\n            return false;\n        }\n    }\n    return true;\n};\n',
};

const Map<String, String> bugBinarySearchBounds = <String, String>{
  'python3': 'class Solution:\n    def findIndex(self, nums: List[int], target: int) -> int:\n        lo, hi = 0, len(nums) - 1\n        while lo < hi:\n            mid = (lo + hi) // 2\n            if nums[mid] == target:\n                return mid\n            if nums[mid] < target:\n                lo = mid + 1\n            else:\n                hi = mid - 1\n        return -1\n',
  'javascript': 'var findIndex = function(nums, target) {\n    let lo = 0, hi = nums.length - 1;\n    while (lo < hi) {\n        const mid = Math.floor((lo + hi) / 2);\n        if (nums[mid] === target) return mid;\n        if (nums[mid] < target) lo = mid + 1;\n        else hi = mid - 1;\n    }\n    return -1;\n};\n',
};

const Map<String, String> bugStreakAllNegative = <String, String>{
  'python3': 'class Solution:\n    def bestStreak(self, nums: List[int]) -> int:\n        best = 0\n        cur = 0\n        for x in nums:\n            cur = max(0, cur + x)\n            best = max(best, cur)\n        return best\n',
  'javascript': 'var bestStreak = function(nums) {\n    let best = 0, cur = 0;\n    for (const x of nums) {\n        cur = Math.max(0, cur + x);\n        best = Math.max(best, cur);\n    }\n    return best;\n};\n',
};
