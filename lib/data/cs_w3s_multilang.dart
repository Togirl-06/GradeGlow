import '../data/coding_languages.dart';

/// Per-language syntax + Try It starters for CS hybrid topics.
class CsW3sMultilang {
  CsW3sMultilang._();

  /// Languages surfaced in the learning UI (full list still available in editor).
  static const List<String> learningLanguageIds = <String>[
    'python3',
    'javascript',
    'typescript',
    'java',
    'cpp',
    'csharp',
    'go',
    'rust',
    'kotlin',
    'swift',
    'ruby',
    'php',
  ];

  static List<CodingLanguage> get learningLanguages => learningLanguageIds
      .map((String id) => CodingLanguage.byId(id))
      .whereType<CodingLanguage>()
      .toList();

  static List<String> syntaxBullets(String topicId, String languageId) {
    return _syntax[topicId]?[languageId] ??
        _syntax[topicId]?['python3'] ??
        const <String>[];
  }

  static String tryItStarter(String topicId, String languageId) {
    return _tryIt[topicId]?[languageId] ??
        _tryIt[topicId]?['python3'] ??
        '';
  }

  static final Map<String, Map<String, List<String>>> _syntax = <String, Map<String, List<String>>>{
    'arrays': _arraysSyntax,
    'loops': _loopsSyntax,
    'functions': _functionsSyntax,
    'hash_maps': _hashMapsSyntax,
    'linked_lists': _linkedListsSyntax,
    'stacks': _stacksSyntax,
    'binary_search': _binarySearchSyntax,
    'recursion': _recursionSyntax,
    'sorting': _sortingSyntax,
  };

  static final Map<String, Map<String, String>> _tryIt = <String, Map<String, String>>{
    'arrays': _arraysTryIt,
    'loops': _loopsTryIt,
    'functions': _functionsTryIt,
    'hash_maps': _hashMapsTryIt,
    'linked_lists': _linkedListsTryIt,
    'stacks': _stacksTryIt,
    'binary_search': _binarySearchTryIt,
    'recursion': _recursionTryIt,
    'sorting': _sortingTryIt,
  };

  static const Map<String, List<String>> _arraysSyntax = <String, List<String>>{
    'python3': <String>[
      'Create: nums = [1, 2, 3]',
      'Read: nums[0]',
      'Write: nums[i] = value',
      'Length: len(nums)',
      'Loop: for x in nums:',
    ],
    'javascript': <String>[
      'Create: const nums = [1, 2, 3]',
      'Read: nums[0]',
      'Write: nums[i] = value',
      'Length: nums.length',
      'Loop: for (const x of nums)',
    ],
    'typescript': <String>[
      'Create: const nums: number[] = [1, 2, 3]',
      'Read: nums[0]',
      'Length: nums.length',
      'Loop: nums.forEach(x => ...)',
    ],
    'java': <String>[
      'Create: int[] nums = {1, 2, 3}',
      'Read: nums[0]',
      'Length: nums.length',
      'Loop: for (int x : nums)',
    ],
    'cpp': <String>[
      'Create: vector<int> nums = {1, 2, 3}',
      'Read: nums[0]',
      'Size: nums.size()',
      'Loop: for (int x : nums)',
    ],
    'csharp': <String>[
      'Create: int[] nums = {1, 2, 3}',
      'Read: nums[0]',
      'Length: nums.Length',
      'Loop: foreach (int x in nums)',
    ],
    'go': <String>[
      'Create: nums := []int{1, 2, 3}',
      'Read: nums[0]',
      'Length: len(nums)',
      'Loop: for _, x := range nums',
    ],
    'rust': <String>[
      'Create: let nums = vec![1, 2, 3]',
      'Read: nums[0]',
      'Length: nums.len()',
      'Loop: for x in &nums',
    ],
    'kotlin': <String>[
      'Create: val nums = intArrayOf(1, 2, 3)',
      'Read: nums[0]',
      'Loop: for (x in nums)',
    ],
    'swift': <String>[
      'Create: let nums = [1, 2, 3]',
      'Read: nums[0]',
      'Loop: for x in nums',
    ],
    'ruby': <String>[
      'Create: nums = [1, 2, 3]',
      'Read: nums[0]',
      'Loop: nums.each { |x| ... }',
    ],
    'php': <String>[
      'Create: \$nums = [1, 2, 3]',
      'Read: \$nums[0]',
      'Count: count(\$nums)',
      'Loop: foreach (\$nums as \$x)',
    ],
  };

  static const Map<String, String> _arraysTryIt = <String, String>{
    'python3': 'nums = [4, 7, 2, 9]\ntotal = 0\nfor n in nums:\n    total += n\nprint(total)\n',
    'javascript': 'const nums = [4, 7, 2, 9];\nlet total = 0;\nfor (const n of nums) total += n;\nconsole.log(total);\n',
    'typescript': 'const nums: number[] = [4, 7, 2, 9];\nlet total = 0;\nfor (const n of nums) total += n;\nconsole.log(total);\n',
    'java': 'public class Main {\n    public static void main(String[] args) {\n        int[] nums = {4, 7, 2, 9};\n        int total = 0;\n        for (int n : nums) total += n;\n        System.out.println(total);\n    }\n}\n',
    'cpp': '#include <iostream>\n#include <vector>\nint main() {\n    std::vector<int> nums = {4, 7, 2, 9};\n    int total = 0;\n    for (int n : nums) total += n;\n    std::cout << total;\n}\n',
    'csharp': 'using System;\nclass Program {\n    static void Main() {\n        int[] nums = {4, 7, 2, 9};\n        int total = 0;\n        foreach (int n in nums) total += n;\n        Console.WriteLine(total);\n    }\n}\n',
    'go': 'package main\nimport "fmt"\nfunc main() {\n    nums := []int{4, 7, 2, 9}\n    total := 0\n    for _, n := range nums { total += n }\n    fmt.Println(total)\n}\n',
    'rust': 'fn main() {\n    let nums = vec![4, 7, 2, 9];\n    let total: i32 = nums.iter().sum();\n    println!("{}", total);\n}\n',
    'kotlin': 'fun main() {\n    val nums = intArrayOf(4, 7, 2, 9)\n    var total = 0\n    for (n in nums) total += n\n    println(total)\n}\n',
    'swift': 'let nums = [4, 7, 2, 9]\nvar total = 0\nfor n in nums { total += n }\nprint(total)\n',
    'ruby': 'nums = [4, 7, 2, 9]\ntotal = nums.sum\nputs total\n',
    'php': '<?php\n\$nums = [4, 7, 2, 9];\n\$total = array_sum(\$nums);\necho \$total;\n',
  };

  static const Map<String, List<String>> _loopsSyntax = <String, List<String>>{
    'python3': <String>['for i in range(n):', 'for item in items:', 'while condition:', 'break / continue'],
    'javascript': <String>['for (let i = 0; i < n; i++)', 'for (const x of arr)', 'while (cond)', 'break / continue'],
    'typescript': <String>['for (let i = 0; i < n; i++)', 'arr.forEach(x => ...)', 'while (cond)'],
    'java': <String>['for (int i = 0; i < n; i++)', 'for (int x : arr)', 'while (cond)', 'break / continue'],
    'cpp': <String>['for (int i = 0; i < n; i++)', 'for (auto x : arr)', 'while (cond)'],
    'csharp': <String>['for (int i = 0; i < n; i++)', 'foreach (var x in arr)', 'while (cond)'],
    'go': <String>['for i := 0; i < n; i++', 'for _, x := range arr', 'for cond { }'],
    'rust': <String>['for i in 0..n', 'for x in &arr', 'while cond', 'break / continue'],
    'kotlin': <String>['for (i in 0 until n)', 'for (x in arr)', 'while (cond)'],
    'swift': <String>['for i in 0..<n', 'for x in arr', 'while cond'],
    'ruby': <String>['n.times { |i| }', 'arr.each { |x| }', 'while cond'],
    'php': <String>['for (\$i = 0; \$i < \$n; \$i++)', 'foreach (\$arr as \$x)', 'while (\$cond)'],
  };

  static const Map<String, String> _loopsTryIt = <String, String>{
    'python3': 'for i in range(2, 11, 2):\n    print(i)\n',
    'javascript': 'for (let i = 2; i <= 10; i += 2) console.log(i);\n',
    'typescript': 'for (let i = 2; i <= 10; i += 2) console.log(i);\n',
    'java': 'public class Main {\n    public static void main(String[] args) {\n        for (int i = 2; i <= 10; i += 2) System.out.println(i);\n    }\n}\n',
    'cpp': '#include <iostream>\nint main() {\n    for (int i = 2; i <= 10; i += 2) std::cout << i << "\\n";\n}\n',
    'csharp': 'for (int i = 2; i <= 10; i += 2) Console.WriteLine(i);\n',
    'go': 'package main\nimport "fmt"\nfunc main() {\n    for i := 2; i <= 10; i += 2 { fmt.Println(i) }\n}\n',
    'rust': 'fn main() {\n    for i in (2..=10).step_by(2) { println!("{}", i); }\n}\n',
    'kotlin': 'fun main() {\n    for (i in 2..10 step 2) println(i)\n}\n',
    'swift': 'for i in stride(from: 2, through: 10, by: 2) { print(i) }\n',
    'ruby': '(2..10).step(2) { |i| puts i }\n',
    'php': '<?php\nfor (\$i = 2; \$i <= 10; \$i += 2) echo \$i . "\\n";\n',
  };

  static const Map<String, List<String>> _functionsSyntax = <String, List<String>>{
    'python3': <String>['def name(a, b):', 'return value', 'Default: def f(x=0):'],
    'javascript': <String>['function name(a, b) { }', 'return value', 'Arrow: const f = (x) => x * 2'],
    'typescript': <String>['function name(a: number): number', 'return value', 'const f = (x: number) => x * 2'],
    'java': <String>['public static int name(int a)', 'return value;', 'Method inside class'],
    'cpp': <String>['int name(int a, int b)', 'return value;', 'auto name(...) -> int'],
    'csharp': <String>['static int Name(int a)', 'return value;', 'public static methods'],
    'go': <String>['func name(a int) int', 'return value', 'Multiple returns allowed'],
    'rust': <String>['fn name(a: i32) -> i32', 'return value;', 'Last expression can return'],
    'kotlin': <String>['fun name(a: Int): Int', 'return value', 'Single-expression: fun f(x)=x*2'],
    'swift': <String>['func name(_ a: Int) -> Int', 'return value', 'func double(_ x: Int) -> Int'],
    'ruby': <String>['def name(a, b)', 'return value', 'Implicit return of last expr'],
    'php': <String>['function name(\$a, \$b)', 'return \$value;', 'function double(\$x) { return \$x * 2; }'],
  };

  static const Map<String, String> _functionsTryIt = <String, String>{
    'python3': 'def double(x):\n    return x * 2\nprint(double(7))\n',
    'javascript': 'function double(x) { return x * 2; }\nconsole.log(double(7));\n',
    'typescript': 'function double(x: number): number { return x * 2; }\nconsole.log(double(7));\n',
    'java': 'public class Main {\n    static int doubleVal(int x) { return x * 2; }\n    public static void main(String[] args) {\n        System.out.println(doubleVal(7));\n    }\n}\n',
    'cpp': '#include <iostream>\nint doubleVal(int x) { return x * 2; }\nint main() { std::cout << doubleVal(7); }\n',
    'csharp': 'int Double(int x) => x * 2;\nConsole.WriteLine(Double(7));\n',
    'go': 'package main\nimport "fmt"\nfunc double(x int) int { return x * 2 }\nfunc main() { fmt.Println(double(7)) }\n',
    'rust': 'fn double(x: i32) -> i32 { x * 2 }\nfn main() { println!("{}", double(7)); }\n',
    'kotlin': 'fun double(x: Int) = x * 2\nfun main() { println(double(7)) }\n',
    'swift': 'func double(_ x: Int) -> Int { x * 2 }\nprint(double(7))\n',
    'ruby': 'def double(x); x * 2; end\nputs double(7)\n',
    'php': '<?php\nfunction double(\$x) { return \$x * 2; }\necho double(7);\n',
  };

  static const Map<String, List<String>> _hashMapsSyntax = <String, List<String>>{
    'python3': <String>['d = {}', 'd[key] = value', 'key in d', 'd.get(key, 0)'],
    'javascript': <String>['const d = {}', 'd[key] = value', 'key in d', 'Map for any key type'],
    'typescript': <String>['const d: Record<string, number> = {}', 'd[key] = value', 'Map<string, number>'],
    'java': <String>['Map<String, Integer> d = new HashMap<>()', 'd.put(k, v)', 'd.getOrDefault(k, 0)'],
    'cpp': <String>['unordered_map<string,int> d', 'd[key] = value', 'd.count(key)'],
    'csharp': <String>['var d = new Dictionary<string, int>()', 'd[key] = value', 'd.TryGetValue'],
    'go': <String>['d := make(map[string]int)', 'd[key] = value', 'v, ok := d[key]'],
    'rust': <String>['use std::collections::HashMap', 'let mut d = HashMap::new()', 'd.insert(k, v)'],
    'kotlin': <String>['val d = mutableMapOf<String, Int>()', 'd[key] = value', 'd.getOrDefault(k, 0)'],
    'swift': <String>['var d = [String: Int]()', 'd[key] = value', 'd[key, default: 0]'],
    'ruby': <String>['d = {}', 'd[key] = value', 'd.fetch(key, 0)'],
    'php': <String>['\$d = []', '\$d[\$key] = \$value', 'isset(\$d[\$key])', '\$d[\$key] ?? 0'],
  };

  static const Map<String, String> _hashMapsTryIt = <String, String>{
    'python3': 'word = "hello"\ncounts = {}\nfor ch in word:\n    counts[ch] = counts.get(ch, 0) + 1\nprint(counts)\n',
    'javascript': 'const word = "hello";\nconst counts = {};\nfor (const ch of word) counts[ch] = (counts[ch] || 0) + 1;\nconsole.log(counts);\n',
    'typescript': 'const word = "hello";\nconst counts: Record<string, number> = {};\nfor (const ch of word) counts[ch] = (counts[ch] ?? 0) + 1;\nconsole.log(counts);\n',
    'java': 'import java.util.*;\npublic class Main {\n    public static void main(String[] args) {\n        Map<Character, Integer> counts = new HashMap<>();\n        for (char ch : "hello".toCharArray())\n            counts.put(ch, counts.getOrDefault(ch, 0) + 1);\n        System.out.println(counts);\n    }\n}\n',
    'cpp': '#include <iostream>\n#include <unordered_map>\n#include <string>\nint main() {\n    std::unordered_map<char,int> c;\n    for (char ch : std::string("hello")) c[ch]++;\n    for (auto& p : c) std::cout << p.first << p.second;\n}\n',
    'csharp': 'var counts = new Dictionary<char, int>();\nforeach (var ch in "hello") counts[ch] = counts.GetValueOrDefault(ch) + 1;\nConsole.WriteLine(string.Join(", ", counts));\n',
    'go': 'package main\nimport "fmt"\nfunc main() {\n    counts := map[rune]int{}\n    for _, ch := range "hello" { counts[ch]++ }\n    fmt.Println(counts)\n}\n',
    'rust': 'use std::collections::HashMap;\nfn main() {\n    let mut counts = HashMap::new();\n    for ch in "hello".chars() { *counts.entry(ch).or_insert(0) += 1; }\n    println!("{:?}", counts);\n}\n',
    'kotlin': 'fun main() {\n    val counts = mutableMapOf<Char, Int>()\n    for (ch in "hello") counts[ch] = counts.getOrDefault(ch, 0) + 1\n    println(counts)\n}\n',
    'swift': 'var counts: [Character: Int] = [:]\nfor ch in "hello" { counts[ch, default: 0] += 1 }\nprint(counts)\n',
    'ruby': 'counts = Hash.new(0)\n"hello".each_char { |ch| counts[ch] += 1 }\nputs counts\n',
    'php': '<?php\n\$counts = [];\nforeach (str_split("hello") as \$ch) \$counts[\$ch] = (\$counts[\$ch] ?? 0) + 1;\nprint_r(\$counts);\n',
  };

  static const Map<String, List<String>> _linkedListsSyntax = <String, List<String>>{
    'python3': <String>['class Node: val, next', 'head = first node', 'while node: node = node.next'],
    'javascript': <String>['class ListNode { constructor(val, next) }', 'let head = ...', 'while (head) head = head.next'],
    'java': <String>['class ListNode { int val; ListNode next; }', 'ListNode head', 'while (head != null)'],
    'cpp': <String>['struct ListNode { int val; ListNode* next; }', 'ListNode* head', 'while (head)'],
    'csharp': <String>['class ListNode { public int val; public ListNode next; }', 'while (head != null)'],
    'go': <String>['type ListNode struct { Val int; Next *ListNode }', 'for head != nil'],
    'rust': <String>['struct ListNode { val: i32, next: Option<Box<ListNode>> }', 'while let Some(n) = ...'],
    'kotlin': <String>['class ListNode(var `val`: Int) { var next: ListNode? = null }'],
    'swift': <String>['class ListNode { var val: Int; var next: ListNode? }', 'while let node = ...'],
    'ruby': <String>['Node = Struct.new(:val, :next)', 'walk with while node'],
    'php': <String>['class ListNode { public \$val, \$next; }', 'while (\$head !== null)'],
  };

  static const Map<String, String> _linkedListsTryIt = <String, String>{
    'python3': 'nodes = [(1, 1), (2, 2), (3, -1)]\nidx = 0\nwhile idx != -1:\n    val, idx = nodes[idx]\n    print(val)\n',
    'javascript': 'const nodes = [[1,1],[2,2],[3,-1]];\nlet idx = 0;\nwhile (idx !== -1) {\n  const [val, next] = nodes[idx];\n  console.log(val);\n  idx = next;\n}\n',
    'typescript': 'const nodes: [number, number][] = [[1,1],[2,2],[3,-1]];\nlet idx = 0;\nwhile (idx !== -1) {\n  const [val, next] = nodes[idx];\n  console.log(val);\n  idx = next;\n}\n',
    'java': 'public class Main {\n    public static void main(String[] args) {\n        int[][] nodes = {{1,1},{2,2},{3,-1}};\n        int idx = 0;\n        while (idx != -1) {\n            System.out.println(nodes[idx][0]);\n            idx = nodes[idx][1];\n        }\n    }\n}\n',
    'cpp': '#include <iostream>\n#include <vector>\nint main() {\n    std::vector<std::pair<int,int>> nodes = {{1,1},{2,2},{3,-1}};\n    int idx = 0;\n    while (idx != -1) {\n        std::cout << nodes[idx].first << "\\n";\n        idx = nodes[idx].second;\n    }\n}\n',
    'csharp': 'var nodes = new (int val, int next)[] {(1,1),(2,2),(3,-1)};\nint idx = 0;\nwhile (idx != -1) {\n    Console.WriteLine(nodes[idx].val);\n    idx = nodes[idx].next;\n}\n',
    'go': 'package main\nimport "fmt"\nfunc main() {\n    nodes := [][2]int{{1,1},{2,2},{3,-1}}\n    idx := 0\n    for idx != -1 {\n        fmt.Println(nodes[idx][0])\n        idx = nodes[idx][1]\n    }\n}\n',
    'rust': 'fn main() {\n    let nodes = vec![(1,1),(2,2),(3,-1)];\n    let mut idx = 0usize;\n    while idx != usize::MAX {\n        let (val, next) = nodes[idx];\n        println!("{}", val);\n        idx = if next == -1 { usize::MAX } else { next as usize };\n    }\n}\n',
    'kotlin': 'fun main() {\n    val nodes = listOf(1 to 1, 2 to 2, 3 to -1)\n    var idx = 0\n    while (idx != -1) {\n        println(nodes[idx].first)\n        idx = nodes[idx].second\n    }\n}\n',
    'swift': 'let nodes = [(1,1),(2,2),(3,-1)]\nvar idx = 0\nwhile idx != -1 {\n    print(nodes[idx].0)\n    idx = nodes[idx].1\n}\n',
    'ruby': 'nodes = [[1,1],[2,2],[3,-1]]\nidx = 0\nwhile idx != -1\n  val, idx = nodes[idx]\n  puts val\nend\n',
    'php': '<?php\n\$nodes = [[1,1],[2,2],[3,-1]];\n\$idx = 0;\nwhile (\$idx !== -1) {\n    echo \$nodes[\$idx][0] . "\\n";\n    \$idx = \$nodes[\$idx][1];\n}\n',
  };

  static const Map<String, List<String>> _stacksSyntax = <String, List<String>>{
    'python3': <String>['stack = []', 'stack.append(x)  # push', 'stack.pop()  # pop', 'if stack: peek = stack[-1]'],
    'javascript': <String>['const stack = []', 'stack.push(x)', 'stack.pop()', 'stack[stack.length - 1]'],
    'typescript': <String>['const stack: number[] = []', 'stack.push(x)', 'stack.pop()'],
    'java': <String>['Deque<Integer> stack = new ArrayDeque<>()', 'stack.push(x)', 'stack.pop()'],
    'cpp': <String>['stack<int> st', 'st.push(x)', 'st.pop()', 'st.top()'],
    'csharp': <String>['var stack = new Stack<int>()', 'stack.Push(x)', 'stack.Pop()'],
    'go': <String>['stack := []int{}', 'stack = append(stack, x)', 'stack = stack[:len(stack)-1]'],
    'rust': <String>['let mut stack = Vec::new()', 'stack.push(x)', 'stack.pop()'],
    'kotlin': <String>['val stack = ArrayDeque<Int>()', 'stack.addLast(x)', 'stack.removeLast()'],
    'swift': <String>['var stack: [Int] = []', 'stack.append(x)', 'stack.removeLast()'],
    'ruby': <String>['stack = []', 'stack.push(x)', 'stack.pop'],
    'php': <String>['\$stack = []', 'array_push(\$stack, \$x)', 'array_pop(\$stack)'],
  };

  static const Map<String, String> _stacksTryIt = <String, String>{
    'python3': 'word = "stack"\nstack = []\nfor ch in word: stack.append(ch)\nrev = ""\nwhile stack: rev += stack.pop()\nprint(rev)\n',
    'javascript': 'const word = "stack";\nconst stack = [];\nfor (const ch of word) stack.push(ch);\nlet rev = "";\nwhile (stack.length) rev += stack.pop();\nconsole.log(rev);\n',
    'typescript': 'const word = "stack";\nconst stack: string[] = [];\nfor (const ch of word) stack.push(ch);\nlet rev = "";\nwhile (stack.length) rev += stack.pop()!;\nconsole.log(rev);\n',
    'java': 'import java.util.*;\npublic class Main {\n    public static void main(String[] args) {\n        Deque<Character> stack = new ArrayDeque<>();\n        for (char ch : "stack".toCharArray()) stack.push(ch);\n        StringBuilder rev = new StringBuilder();\n        while (!stack.isEmpty()) rev.append(stack.pop());\n        System.out.println(rev);\n    }\n}\n',
    'cpp': '#include <iostream>\n#include <stack>\n#include <string>\nint main() {\n    std::stack<char> st;\n    for (char ch : std::string("stack")) st.push(ch);\n    std::string rev;\n    while (!st.empty()) { rev += st.top(); st.pop(); }\n    std::cout << rev;\n}\n',
    'csharp': 'var stack = new Stack<char>();\nforeach (var ch in "stack") stack.Push(ch);\nvar rev = "";\nwhile (stack.Count > 0) rev += stack.Pop();\nConsole.WriteLine(rev);\n',
    'go': 'package main\nimport "fmt"\nfunc main() {\n    stack := []rune{}\n    for _, ch := range "stack" { stack = append(stack, ch) }\n    rev := ""\n    for len(stack) > 0 {\n        rev += string(stack[len(stack)-1])\n        stack = stack[:len(stack)-1]\n    }\n    fmt.Println(rev)\n}\n',
    'rust': 'fn main() {\n    let mut stack: Vec<char> = "stack".chars().collect();\n    let rev: String = (0..stack.len()).map(|_| stack.pop().unwrap()).collect();\n    println!("{}", rev);\n}\n',
    'kotlin': 'fun main() {\n    val stack = ArrayDeque<Char>()\n    "stack".forEach { stack.addLast(it) }\n    val rev = buildString { while (stack.isNotEmpty()) append(stack.removeLast()) }\n    println(rev)\n}\n',
    'swift': 'var stack: [Character] = []\nfor ch in "stack" { stack.append(ch) }\nvar rev = ""\nwhile let c = stack.popLast() { rev.append(c) }\nprint(rev)\n',
    'ruby': 'stack = "stack".chars\nrev = stack.reverse.join\nputs rev\n',
    'php': '<?php\n\$stack = str_split("stack");\n\$rev = "";\nwhile (\$stack) \$rev .= array_pop(\$stack);\necho \$rev;\n',
  };

  static const Map<String, List<String>> _binarySearchSyntax = <String, List<String>>{
    'python3': <String>['lo, hi = 0, len(nums)-1', 'mid = (lo + hi) // 2', 'if nums[mid] < target: lo = mid+1'],
    'javascript': <String>['let lo = 0, hi = nums.length - 1', 'const mid = Math.floor((lo+hi)/2)', 'if (nums[mid] < target) lo = mid+1'],
    'typescript': <String>['let lo = 0, hi = nums.length - 1', 'const mid = Math.floor((lo+hi)/2)'],
    'java': <String>['int lo = 0, hi = nums.length - 1', 'int mid = lo + (hi - lo) / 2', 'while (lo <= hi)'],
    'cpp': <String>['int lo = 0, hi = n - 1', 'int mid = lo + (hi - lo) / 2', 'while (lo <= hi)'],
    'csharp': <String>['int lo = 0, hi = nums.Length - 1', 'int mid = lo + (hi - lo) / 2'],
    'go': <String>['lo, hi := 0, len(nums)-1', 'mid := (lo + hi) / 2', 'for lo <= hi'],
    'rust': <String>['let mut lo = 0usize', 'let mut hi = nums.len() - 1', 'while lo <= hi'],
    'kotlin': <String>['var lo = 0', 'var hi = nums.lastIndex', 'while (lo <= hi)'],
    'swift': <String>['var lo = 0', 'var hi = nums.count - 1', 'while lo <= hi'],
    'ruby': <String>['lo, hi = 0, nums.length - 1', 'mid = (lo + hi) / 2', 'while lo <= hi'],
    'php': <String>['\$lo = 0; \$hi = count(\$nums) - 1', '\$mid = intdiv(\$lo + \$hi, 2)', 'while (\$lo <= \$hi)'],
  };

  static const Map<String, String> _binarySearchTryIt = <String, String>{
    'python3': 'nums = [1, 3, 5, 7, 9, 11]\ntarget = 7\nlo, hi = 0, len(nums) - 1\nfound = -1\nwhile lo <= hi:\n    mid = (lo + hi) // 2\n    if nums[mid] == target:\n        found = mid\n        break\n    elif nums[mid] < target:\n        lo = mid + 1\n    else:\n        hi = mid - 1\nprint(found)\n',
    'javascript': 'const nums = [1,3,5,7,9,11];\nconst target = 7;\nlet lo = 0, hi = nums.length - 1, found = -1;\nwhile (lo <= hi) {\n  const mid = Math.floor((lo+hi)/2);\n  if (nums[mid] === target) { found = mid; break; }\n  else if (nums[mid] < target) lo = mid + 1;\n  else hi = mid - 1;\n}\nconsole.log(found);\n',
    'typescript': 'const nums = [1,3,5,7,9,11];\nconst target = 7;\nlet lo = 0, hi = nums.length - 1, found = -1;\nwhile (lo <= hi) {\n  const mid = Math.floor((lo+hi)/2);\n  if (nums[mid] === target) { found = mid; break; }\n  else if (nums[mid] < target) lo = mid + 1;\n  else hi = mid - 1;\n}\nconsole.log(found);\n',
    'java': 'public class Main {\n    public static void main(String[] args) {\n        int[] nums = {1,3,5,7,9,11};\n        int target = 7, lo = 0, hi = nums.length-1, found = -1;\n        while (lo <= hi) {\n            int mid = lo + (hi-lo)/2;\n            if (nums[mid] == target) { found = mid; break; }\n            else if (nums[mid] < target) lo = mid+1;\n            else hi = mid-1;\n        }\n        System.out.println(found);\n    }\n}\n',
    'cpp': '#include <iostream>\n#include <vector>\nint main() {\n    std::vector<int> nums = {1,3,5,7,9,11};\n    int target = 7, lo = 0, hi = (int)nums.size()-1, found = -1;\n    while (lo <= hi) {\n        int mid = lo + (hi-lo)/2;\n        if (nums[mid] == target) { found = mid; break; }\n        else if (nums[mid] < target) lo = mid+1;\n        else hi = mid-1;\n    }\n    std::cout << found;\n}\n',
    'csharp': 'int[] nums = {1,3,5,7,9,11};\nint target = 7, lo = 0, hi = nums.Length-1, found = -1;\nwhile (lo <= hi) {\n    int mid = lo + (hi-lo)/2;\n    if (nums[mid] == target) { found = mid; break; }\n    else if (nums[mid] < target) lo = mid+1;\n    else hi = mid-1;\n}\nConsole.WriteLine(found);\n',
    'go': 'package main\nimport "fmt"\nfunc main() {\n    nums := []int{1,3,5,7,9,11}\n    target, lo, hi, found := 7, 0, len(nums)-1, -1\n    for lo <= hi {\n        mid := (lo + hi) / 2\n        if nums[mid] == target { found = mid; break }\n        if nums[mid] < target { lo = mid+1 } else { hi = mid-1 }\n    }\n    fmt.Println(found)\n}\n',
    'rust': 'fn main() {\n    let nums = vec![1,3,5,7,9,11];\n    let target = 7;\n    let (mut lo, mut hi, mut found) = (0usize, nums.len()-1, -1isize);\n    while lo <= hi {\n        let mid = (lo + hi) / 2;\n        if nums[mid] == target { found = mid as isize; break; }\n        if nums[mid] < target { lo = mid+1; } else { hi = mid-1; }\n    }\n    println!("{}", found);\n}\n',
    'kotlin': 'fun main() {\n    val nums = intArrayOf(1,3,5,7,9,11)\n    var lo = 0; var hi = nums.lastIndex; var found = -1\n    while (lo <= hi) {\n        val mid = (lo + hi) / 2\n        when {\n            nums[mid] == 7 -> { found = mid; break }\n            nums[mid] < 7 -> lo = mid + 1\n            else -> hi = mid - 1\n        }\n    }\n    println(found)\n}\n',
    'swift': 'let nums = [1,3,5,7,9,11]\nvar lo = 0, hi = nums.count - 1, found = -1\nwhile lo <= hi {\n    let mid = (lo + hi) / 2\n    if nums[mid] == 7 { found = mid; break }\n    else if nums[mid] < 7 { lo = mid + 1 }\n    else { hi = mid - 1 }\n}\nprint(found)\n',
    'ruby': 'nums = [1,3,5,7,9,11]\nlo, hi, found = 0, nums.length-1, -1\nwhile lo <= hi\n  mid = (lo+hi)/2\n  if nums[mid] == 7; found = mid; break\n  elsif nums[mid] < 7; lo = mid+1\n  else hi = mid-1; end\nend\nputs found\n',
    'php': '<?php\n\$nums = [1,3,5,7,9,11];\n\$lo = 0; \$hi = count(\$nums)-1; \$found = -1;\nwhile (\$lo <= \$hi) {\n    \$mid = intdiv(\$lo+\$hi, 2);\n    if (\$nums[\$mid] == 7) { \$found = \$mid; break; }\n    if (\$nums[\$mid] < 7) \$lo = \$mid+1; else \$hi = \$mid-1;\n}\necho \$found;\n',
  };

  static const Map<String, List<String>> _recursionSyntax = <String, List<String>>{
    'python3': <String>['def f(n):', 'if n <= base: return base_case', 'return f(smaller)'],
    'javascript': <String>['function f(n) {', 'if (n <= base) return base;', 'return f(n-1);', '}'],
    'typescript': <String>['function f(n: number): number', 'base case + recursive call'],
    'java': <String>['public static int f(int n)', 'if (n <= 1) return 1;', 'return n * f(n-1);'],
    'cpp': <String>['int f(int n)', 'if (n <= 1) return 1;', 'return n * f(n-1);'],
    'csharp': <String>['static int F(int n)', 'if (n <= 1) return 1;', 'return n * F(n-1);'],
    'go': <String>['func f(n int) int', 'if n <= 1 { return 1 }', 'return n * f(n-1)'],
    'rust': <String>['fn f(n: i32) -> i32', 'if n <= 1 { 1 } else { n * f(n-1) }'],
    'kotlin': <String>['fun f(n: Int): Int', 'if (n <= 1) 1 else n * f(n-1)'],
    'swift': <String>['func f(_ n: Int) -> Int', 'guard n > 1 else { return 1 }', 'return n * f(n-1)'],
    'ruby': <String>['def f(n)', 'return 1 if n <= 1', 'n * f(n-1)', 'end'],
    'php': <String>['function f(\$n)', 'if (\$n <= 1) return 1;', 'return \$n * f(\$n-1);', '}'],
  };

  static const Map<String, String> _recursionTryIt = <String, String>{
    'python3': 'def factorial(n):\n    if n <= 1:\n        return 1\n    return n * factorial(n - 1)\nprint(factorial(5))\n',
    'javascript': 'function factorial(n) {\n  if (n <= 1) return 1;\n  return n * factorial(n - 1);\n}\nconsole.log(factorial(5));\n',
    'typescript': 'function factorial(n: number): number {\n  if (n <= 1) return 1;\n  return n * factorial(n - 1);\n}\nconsole.log(factorial(5));\n',
    'java': 'public class Main {\n    static int factorial(int n) {\n        if (n <= 1) return 1;\n        return n * factorial(n - 1);\n    }\n    public static void main(String[] args) {\n        System.out.println(factorial(5));\n    }\n}\n',
    'cpp': '#include <iostream>\nint factorial(int n) {\n    if (n <= 1) return 1;\n    return n * factorial(n - 1);\n}\nint main() { std::cout << factorial(5); }\n',
    'csharp': 'int Factorial(int n) => n <= 1 ? 1 : n * Factorial(n - 1);\nConsole.WriteLine(Factorial(5));\n',
    'go': 'package main\nimport "fmt"\nfunc factorial(n int) int {\n    if n <= 1 { return 1 }\n    return n * factorial(n-1)\n}\nfunc main() { fmt.Println(factorial(5)) }\n',
    'rust': 'fn factorial(n: i32) -> i32 {\n    if n <= 1 { 1 } else { n * factorial(n - 1) }\n}\nfn main() { println!("{}", factorial(5)); }\n',
    'kotlin': 'fun factorial(n: Int): Int = if (n <= 1) 1 else n * factorial(n - 1)\nfun main() { println(factorial(5)) }\n',
    'swift': 'func factorial(_ n: Int) -> Int {\n    guard n > 1 else { return 1 }\n    return n * factorial(n - 1)\n}\nprint(factorial(5))\n',
    'ruby': 'def factorial(n)\n  return 1 if n <= 1\n  n * factorial(n - 1)\nend\nputs factorial(5)\n',
    'php': '<?php\nfunction factorial(\$n) {\n    if (\$n <= 1) return 1;\n    return \$n * factorial(\$n - 1);\n}\necho factorial(5);\n',
  };

  static const Map<String, List<String>> _sortingSyntax = <String, List<String>>{
    'python3': <String>['sorted(arr) — new list', 'arr.sort() — in place', 'Bubble/merge/quick for learning'],
    'javascript': <String>['arr.sort((a,b) => a-b)', 'Spread: [...arr].sort()', 'Compare function required'],
    'typescript': <String>['arr.sort((a, b) => a - b)', 'Typed arrays: number[]'],
    'java': <String>['Arrays.sort(arr)', 'Collections.sort(list)', 'Comparable / Comparator'],
    'cpp': <String>['std::sort(v.begin(), v.end())', '#include <algorithm>'],
    'csharp': <String>['Array.Sort(arr)', 'arr.OrderBy(x => x)'],
    'go': <String>['sort.Ints(arr)', 'import "sort"'],
    'rust': <String>['arr.sort()', 'arr.sort_by(|a,b| a.cmp(b))'],
    'kotlin': <String>['arr.sort()', 'arr.sorted() — new list'],
    'swift': <String>['arr.sort()', 'arr.sorted() — new array'],
    'ruby': <String>['arr.sort', 'arr.sort! — in place'],
    'php': <String>['sort(\$arr)', r'usort($arr, fn($a,$b) => $a <=> $b)'],
  };

  static const Map<String, String> _sortingTryIt = <String, String>{
    'python3': 'nums = [3, 1, 4, 1, 5]\nnums.sort()\nprint(nums)\n',
    'javascript': 'const nums = [3, 1, 4, 1, 5];\nnums.sort((a, b) => a - b);\nconsole.log(nums);\n',
    'typescript': 'const nums = [3, 1, 4, 1, 5];\nnums.sort((a, b) => a - b);\nconsole.log(nums);\n',
    'java': 'import java.util.*;\npublic class Main {\n    public static void main(String[] args) {\n        int[] nums = {3,1,4,1,5};\n        Arrays.sort(nums);\n        System.out.println(Arrays.toString(nums));\n    }\n}\n',
    'cpp': '#include <iostream>\n#include <vector>\n#include <algorithm>\nint main() {\n    std::vector<int> nums = {3,1,4,1,5};\n    std::sort(nums.begin(), nums.end());\n    for (int n : nums) std::cout << n << " ";\n}\n',
    'csharp': 'var nums = new[] {3,1,4,1,5};\nArray.Sort(nums);\nConsole.WriteLine(string.Join(", ", nums));\n',
    'go': 'package main\nimport ("fmt"; "sort")\nfunc main() {\n    nums := []int{3,1,4,1,5}\n    sort.Ints(nums)\n    fmt.Println(nums)\n}\n',
    'rust': 'fn main() {\n    let mut nums = vec![3,1,4,1,5];\n    nums.sort();\n    println!("{:?}", nums);\n}\n',
    'kotlin': 'fun main() {\n    val nums = mutableListOf(3,1,4,1,5)\n    nums.sort()\n    println(nums)\n}\n',
    'swift': 'var nums = [3,1,4,1,5]\nnums.sort()\nprint(nums)\n',
    'ruby': 'nums = [3,1,4,1,5]\nputs nums.sort\n',
    'php': '<?php\n\$nums = [3,1,4,1,5];\nsort(\$nums);\nprint_r(\$nums);\n',
  };
}
