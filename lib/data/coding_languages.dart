import '../models/leetcode_problem.dart';
import 'debug_starter_localizer.dart';

/// Supported languages for LeetCode-style practice labs.
class CodingLanguage {
  const CodingLanguage({
    required this.id,
    required this.label,
    required this.starter,
  });

  final String id;
  final String label;
  final String starter;

  static const CodingLanguage python3 = CodingLanguage(
    id: 'python3',
    label: 'Python3',
    starter: 'class Solution:\n    def solve(self, nums: list[int]) -> int:\n        pass\n',
  );

  static const List<CodingLanguage> leftColumn = <CodingLanguage>[
    CodingLanguage(
      id: 'cpp',
      label: 'C++',
      starter: 'class Solution {\npublic:\n    int solve(vector<int>& nums) {\n        \n    }\n};\n',
    ),
    CodingLanguage(
      id: 'java',
      label: 'Java',
      starter: 'class Solution {\n    public int solve(int[] nums) {\n        \n    }\n}\n',
    ),
    python3,
    CodingLanguage(
      id: 'python',
      label: 'Python',
      starter: 'class Solution(object):\n    def solve(self, nums):\n        """\n        :type nums: List[int]\n        :rtype: int\n        """\n        pass\n',
    ),
    CodingLanguage(
      id: 'javascript',
      label: 'JavaScript',
      starter: '/**\n * @param {number[]} nums\n * @return {number}\n */\nvar solve = function(nums) {\n    \n};\n',
    ),
    CodingLanguage(
      id: 'typescript',
      label: 'TypeScript',
      starter: 'function solve(nums: number[]): number {\n    \n}\n',
    ),
    CodingLanguage(
      id: 'csharp',
      label: 'C#',
      starter: 'public class Solution {\n    public int Solve(int[] nums) {\n        \n    }\n}\n',
    ),
    CodingLanguage(
      id: 'c',
      label: 'C',
      starter: 'int solve(int* nums, int numsSize) {\n    \n}\n',
    ),
  ];

  static const List<CodingLanguage> rightColumn = <CodingLanguage>[
    CodingLanguage(
      id: 'go',
      label: 'Go',
      starter: 'func solve(nums []int) int {\n    \n}\n',
    ),
    CodingLanguage(
      id: 'kotlin',
      label: 'Kotlin',
      starter: 'class Solution {\n    fun solve(nums: IntArray): Int {\n        \n    }\n}\n',
    ),
    CodingLanguage(
      id: 'swift',
      label: 'Swift',
      starter: 'class Solution {\n    func solve(_ nums: [Int]) -> Int {\n        \n    }\n}\n',
    ),
    CodingLanguage(
      id: 'rust',
      label: 'Rust',
      starter: 'impl Solution {\n    pub fn solve(nums: Vec<i32>) -> i32 {\n        \n    }\n}\n',
    ),
    CodingLanguage(
      id: 'ruby',
      label: 'Ruby',
      starter: "# @param {Integer[]} nums\n# @return {Integer}\ndef solve(nums)\n    \nend\n",
    ),
    CodingLanguage(
      id: 'php',
      label: 'PHP',
      starter: 'class Solution {\n    /**\n     * @param Integer[] \$nums\n     * @return Integer\n     */\n    function solve(\$nums) {\n        \n    }\n}\n',
    ),
    CodingLanguage(
      id: 'dart',
      label: 'Dart',
      starter: 'class Solution {\n  int solve(List<int> nums) {\n    \n  }\n}\n',
    ),
    CodingLanguage(
      id: 'scala',
      label: 'Scala',
      starter: 'object Solution {\n    def solve(nums: Array[Int]): Int = {\n        \n    }\n}\n',
    ),
  ];

  static List<CodingLanguage> get all => <CodingLanguage>[...leftColumn, ...rightColumn];

  static CodingLanguage get defaultLanguage => python3;

  static CodingLanguage? byId(String id) {
    for (final CodingLanguage lang in all) {
      if (lang.id == id) return lang;
    }
    return null;
  }

  static CodingLanguage byLabel(String label) {
    for (final CodingLanguage lang in all) {
      if (lang.label == label) return lang;
    }
    return defaultLanguage;
  }

  /// LeetCode-style starter with the problem's function name.
  static String starterFor(CodingLanguage language, String functionName) {
    return switch (language.id) {
      'python3' => 'class Solution:\n    def $functionName(self, *args):\n        pass\n',
      'java' => 'class Solution {\n    public Object $functionName(Object... args) {\n        \n    }\n}\n',
      'javascript' => '/**\n * @return {*}\n */\nvar $functionName = function(...args) {\n    \n};\n',
      'cpp' => 'class Solution {\npublic:\n    auto $functionName(auto... args) {\n        \n    }\n};\n',
      _ => language.starter.replaceAll('solve', functionName),
    };
  }

  /// Editor seed — buggy code for debug problems, empty template otherwise.
  /// Always returns code for [language] (never falls back to another language's source).
  static String starterForProblem(LeetcodeProblem problem, CodingLanguage language) {
    if (problem.isDebug) {
      return DebugStarterLocalizer.forProblem(problem, language);
    }
    final String? exact = problem.starterCode[language.id] ??
        (language.id == 'python' ? problem.starterCode['python3'] : null) ??
        (language.id == 'python3' ? problem.starterCode['python'] : null);
    if (exact != null && exact.trim().isNotEmpty) return exact;
    return starterFor(language, problem.functionName);
  }
}
