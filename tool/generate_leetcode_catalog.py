#!/usr/bin/env python3
"""Generate leetcode_problem_catalog_data.dart from NeetCode README format."""

import re
import sys
from pathlib import Path

SECTION_TOPIC = {
    'arrays & hashing': 'arrays',
    'two pointers': 'arrays',
    'stack': 'stack_queue',
    'binary search': 'arrays',
    'linked list': 'linked_lists',
    'trees': 'trees',
    'tries': 'trees',
    'heap / priority queue': 'stack_queue',
    'backtracking': 'recursion',
    'graphs': 'graphs',
    'advanced graphs': 'graphs',
    '1-d dp': 'dynamic_programming',
    '2-d dp': 'dynamic_programming',
    'greedy': 'competitive',
    'intervals': 'arrays',
    'math & geometry': 'arrays',
    'bit manipulation': 'arrays',
}

EXTRA_PROBLEMS = [
    ('4', 'Median of Two Sorted Arrays', 'median-of-two-sorted-arrays', 'arrays', 'Hard'),
    ('5', 'Longest Palindromic Substring', 'longest-palindromic-substring', 'strings', 'Medium'),
    ('6', 'Zigzag Conversion', 'zigzag-conversion', 'strings', 'Medium'),
    ('7', 'Reverse Integer', 'reverse-integer', 'arrays', 'Medium'),
    ('8', 'String to Integer (atoi)', 'string-to-integer-atoi', 'strings', 'Medium'),
    ('9', 'Palindrome Number', 'palindrome-number', 'arrays', 'Easy'),
    ('10', 'Regular Expression Matching', 'regular-expression-matching', 'strings', 'Hard'),
    ('11', 'Container With Most Water', 'container-with-most-water', 'arrays', 'Medium'),
    ('12', 'Integer to Roman', 'integer-to-roman', 'strings', 'Medium'),
    ('13', 'Roman to Integer', 'roman-to-integer', 'strings', 'Easy'),
    ('15', '3Sum', '3sum', 'arrays', 'Medium'),
    ('16', '3Sum Closest', '3sum-closest', 'arrays', 'Medium'),
    ('17', 'Letter Combinations of a Phone Number', 'letter-combinations-of-a-phone-number', 'recursion', 'Medium'),
    ('18', '4Sum', '4sum', 'arrays', 'Medium'),
    ('19', 'Remove Nth Node From End of List', 'remove-nth-node-from-end-of-list', 'linked_lists', 'Medium'),
    ('22', 'Generate Parentheses', 'generate-parentheses', 'recursion', 'Medium'),
    ('24', 'Swap Nodes in Pairs', 'swap-nodes-in-pairs', 'linked_lists', 'Medium'),
    ('25', 'Reverse Nodes in k-Group', 'reverse-nodes-in-k-group', 'linked_lists', 'Hard'),
    ('26', 'Remove Duplicates from Sorted Array', 'remove-duplicates-from-sorted-array', 'arrays', 'Easy'),
    ('29', 'Divide Two Integers', 'divide-two-integers', 'arrays', 'Medium'),
    ('31', 'Next Permutation', 'next-permutation', 'arrays', 'Medium'),
    ('33', 'Search in Rotated Sorted Array', 'search-in-rotated-sorted-array', 'arrays', 'Medium'),
    ('34', 'Find First and Last Position of Element in Sorted Array', 'find-first-and-last-position-of-element-in-sorted-array', 'arrays', 'Medium'),
    ('35', 'Search Insert Position', 'search-insert-position', 'arrays', 'Easy'),
    ('37', 'Sudoku Solver', 'sudoku-solver', 'recursion', 'Hard'),
    ('38', 'Count and Say', 'count-and-say', 'strings', 'Medium'),
    ('39', 'Combination Sum', 'combination-sum', 'recursion', 'Medium'),
    ('40', 'Combination Sum II', 'combination-sum-ii', 'recursion', 'Medium'),
    ('41', 'First Missing Positive', 'first-missing-positive', 'arrays', 'Hard'),
    ('43', 'Multiply Strings', 'multiply-strings', 'strings', 'Medium'),
    ('44', 'Wildcard Matching', 'wildcard-matching', 'strings', 'Hard'),
    ('45', 'Jump Game II', 'jump-game-ii', 'competitive', 'Medium'),
    ('47', 'Permutations II', 'permutations-ii', 'recursion', 'Medium'),
    ('48', 'Rotate Image', 'rotate-image', 'arrays', 'Medium'),
    ('50', 'Pow(x, n)', 'powx-n', 'recursion', 'Medium'),
    ('51', 'N-Queens', 'n-queens', 'recursion', 'Hard'),
    ('52', 'N-Queens II', 'n-queens-ii', 'recursion', 'Hard'),
    ('54', 'Spiral Matrix', 'spiral-matrix', 'arrays', 'Medium'),
    ('55', 'Jump Game', 'jump-game', 'competitive', 'Medium'),
    ('57', 'Insert Interval', 'insert-interval', 'arrays', 'Medium'),
    ('59', 'Spiral Matrix II', 'spiral-matrix-ii', 'arrays', 'Medium'),
    ('61', 'Rotate List', 'rotate-list', 'linked_lists', 'Medium'),
    ('62', 'Unique Paths', 'unique-paths', 'dynamic_programming', 'Medium'),
    ('63', 'Unique Paths II', 'unique-paths-ii', 'dynamic_programming', 'Medium'),
    ('64', 'Minimum Path Sum', 'minimum-path-sum', 'dynamic_programming', 'Medium'),
    ('66', 'Plus One', 'plus-one', 'arrays', 'Easy'),
    ('67', 'Add Binary', 'add-binary', 'strings', 'Easy'),
    ('68', 'Text Justification', 'text-justification', 'strings', 'Hard'),
    ('69', 'Sqrt(x)', 'sqrtx', 'arrays', 'Easy'),
    ('71', 'Simplify Path', 'simplify-path', 'stack_queue', 'Medium'),
    ('72', 'Edit Distance', 'edit-distance', 'dynamic_programming', 'Hard'),
    ('73', 'Set Matrix Zeroes', 'set-matrix-zeroes', 'arrays', 'Medium'),
    ('74', 'Search a 2D Matrix', 'search-a-2d-matrix', 'arrays', 'Medium'),
    ('77', 'Combinations', 'combinations', 'recursion', 'Medium'),
    ('79', 'Word Search', 'word-search', 'recursion', 'Medium'),
    ('80', 'Remove Duplicates from Sorted Array II', 'remove-duplicates-from-sorted-array-ii', 'arrays', 'Medium'),
    ('81', 'Search in Rotated Sorted Array II', 'search-in-rotated-sorted-array-ii', 'arrays', 'Medium'),
    ('82', 'Remove Duplicates from Sorted List II', 'remove-duplicates-from-sorted-list-ii', 'linked_lists', 'Medium'),
    ('83', 'Remove Duplicates from Sorted List', 'remove-duplicates-from-sorted-list', 'linked_lists', 'Easy'),
    ('84', 'Largest Rectangle in Histogram', 'largest-rectangle-in-histogram', 'stack_queue', 'Hard'),
    ('85', 'Maximal Rectangle', 'maximal-rectangle', 'stack_queue', 'Hard'),
    ('86', 'Partition List', 'partition-list', 'linked_lists', 'Medium'),
    ('87', 'Scramble String', 'scramble-string', 'dynamic_programming', 'Hard'),
    ('89', 'Gray Code', 'gray-code', 'recursion', 'Medium'),
    ('90', 'Subsets II', 'subsets-ii', 'recursion', 'Medium'),
    ('91', 'Decode Ways', 'decode-ways', 'dynamic_programming', 'Medium'),
    ('92', 'Reverse Linked List II', 'reverse-linked-list-ii', 'linked_lists', 'Medium'),
    ('93', 'Restore IP Addresses', 'restore-ip-addresses', 'recursion', 'Medium'),
    ('94', 'Binary Tree Inorder Traversal', 'binary-tree-inorder-traversal', 'trees', 'Easy'),
    ('95', 'Unique Binary Search Trees II', 'unique-binary-search-trees-ii', 'trees', 'Medium'),
    ('96', 'Unique Binary Search Trees', 'unique-binary-search-trees', 'trees', 'Medium'),
    ('97', 'Interleaving String', 'interleaving-string', 'dynamic_programming', 'Medium'),
    ('99', 'Recover Binary Search Tree', 'recover-binary-search-tree', 'trees', 'Medium'),
    ('100', 'Same Tree', 'same-tree', 'trees', 'Easy'),
    ('101', 'Symmetric Tree', 'symmetric-tree', 'trees', 'Easy'),
    ('103', 'Binary Tree Zigzag Level Order Traversal', 'binary-tree-zigzag-level-order-traversal', 'trees', 'Medium'),
    ('105', 'Construct Binary Tree from Preorder and Inorder Traversal', 'construct-binary-tree-from-preorder-and-inorder-traversal', 'trees', 'Medium'),
    ('106', 'Construct Binary Tree from Inorder and Postorder Traversal', 'construct-binary-tree-from-inorder-and-postorder-traversal', 'trees', 'Medium'),
    ('107', 'Binary Tree Level Order Traversal II', 'binary-tree-level-order-traversal-ii', 'trees', 'Medium'),
    ('108', 'Convert Sorted Array to Binary Search Tree', 'convert-sorted-array-to-binary-search-tree', 'trees', 'Easy'),
    ('109', 'Convert Sorted List to Binary Search Tree', 'convert-sorted-list-to-binary-search-tree', 'trees', 'Medium'),
    ('110', 'Balanced Binary Tree', 'balanced-binary-tree', 'trees', 'Easy'),
    ('111', 'Minimum Depth of Binary Tree', 'minimum-depth-of-binary-tree', 'trees', 'Easy'),
    ('112', 'Path Sum', 'path-sum', 'trees', 'Easy'),
    ('113', 'Path Sum II', 'path-sum-ii', 'trees', 'Medium'),
    ('114', 'Flatten Binary Tree to Linked List', 'flatten-binary-tree-to-linked-list', 'trees', 'Medium'),
    ('115', 'Distinct Subsequences', 'distinct-subsequences', 'dynamic_programming', 'Hard'),
    ('116', 'Populating Next Right Pointers in Each Node', 'populating-next-right-pointers-in-each-node', 'trees', 'Medium'),
    ('117', 'Populating Next Right Pointers in Each Node II', 'populating-next-right-pointers-in-each-node-ii', 'trees', 'Medium'),
    ('120', 'Triangle', 'triangle', 'dynamic_programming', 'Medium'),
    ('121', 'Best Time to Buy and Sell Stock', 'best-time-to-buy-and-sell-stock', 'arrays', 'Easy'),
    ('124', 'Binary Tree Maximum Path Sum', 'binary-tree-maximum-path-sum', 'trees', 'Hard'),
    ('126', 'Word Ladder II', 'word-ladder-ii', 'graphs', 'Hard'),
    ('127', 'Word Ladder', 'word-ladder', 'graphs', 'Hard'),
    ('128', 'Longest Consecutive Sequence', 'longest-consecutive-sequence', 'hash_map', 'Medium'),
    ('130', 'Surrounded Regions', 'surrounded-regions', 'graphs', 'Medium'),
    ('131', 'Palindrome Partitioning', 'palindrome-partitioning', 'recursion', 'Medium'),
    ('133', 'Clone Graph', 'clone-graph', 'graphs', 'Medium'),
    ('134', 'Gas Station', 'gas-station', 'arrays', 'Medium'),
    ('135', 'Candy', 'candy', 'arrays', 'Hard'),
    ('136', 'Single Number', 'single-number', 'arrays', 'Easy'),
    ('137', 'Single Number II', 'single-number-ii', 'arrays', 'Medium'),
    ('138', 'Copy List with Random Pointer', 'copy-list-with-random-pointer', 'linked_lists', 'Medium'),
    ('139', 'Word Break', 'word-break', 'dynamic_programming', 'Medium'),
    ('140', 'Word Break II', 'word-break-ii', 'dynamic_programming', 'Hard'),
    ('141', 'Linked List Cycle', 'linked-list-cycle', 'linked_lists', 'Easy'),
    ('142', 'Linked List Cycle II', 'linked-list-cycle-ii', 'linked_lists', 'Medium'),
    ('143', 'Reorder List', 'reorder-list', 'linked_lists', 'Medium'),
    ('144', 'Binary Tree Preorder Traversal', 'binary-tree-preorder-traversal', 'trees', 'Easy'),
    ('145', 'Binary Tree Postorder Traversal', 'binary-tree-postorder-traversal', 'trees', 'Easy'),
    ('146', 'LRU Cache', 'lru-cache', 'hash_map', 'Medium'),
    ('147', 'Insertion Sort List', 'insertion-sort-list', 'linked_lists', 'Medium'),
    ('148', 'Sort List', 'sort-list', 'linked_lists', 'Medium'),
    ('149', 'Max Points on a Line', 'max-points-on-a-line', 'arrays', 'Hard'),
    ('150', 'Evaluate Reverse Polish Notation', 'evaluate-reverse-polish-notation', 'stack_queue', 'Medium'),
    ('151', 'Reverse Words in a String', 'reverse-words-in-a-string', 'strings', 'Medium'),
    ('152', 'Maximum Product Subarray', 'maximum-product-subarray', 'dynamic_programming', 'Medium'),
    ('153', 'Find Minimum in Rotated Sorted Array', 'find-minimum-in-rotated-sorted-array', 'arrays', 'Medium'),
    ('154', 'Find Minimum in Rotated Sorted Array II', 'find-minimum-in-rotated-sorted-array-ii', 'arrays', 'Hard'),
    ('155', 'Min Stack', 'min-stack', 'stack_queue', 'Medium'),
    ('160', 'Intersection of Two Linked Lists', 'intersection-of-two-linked-lists', 'linked_lists', 'Easy'),
    ('162', 'Find Peak Element', 'find-peak-element', 'arrays', 'Medium'),
    ('164', 'Maximum Gap', 'maximum-gap', 'arrays', 'Medium'),
    ('165', 'Compare Version Numbers', 'compare-version-numbers', 'strings', 'Medium'),
    ('166', 'Fraction to Recurring Decimal', 'fraction-to-recurring-decimal', 'strings', 'Medium'),
    ('167', 'Two Sum II - Input Array Is Sorted', 'two-sum-ii-input-array-is-sorted', 'arrays', 'Medium'),
    ('168', 'Excel Sheet Column Title', 'excel-sheet-column-title', 'strings', 'Easy'),
    ('169', 'Majority Element', 'majority-element', 'arrays', 'Easy'),
    ('171', 'Excel Sheet Column Number', 'excel-sheet-column-number', 'strings', 'Easy'),
    ('172', 'Factorial Trailing Zeroes', 'factorial-trailing-zeroes', 'arrays', 'Medium'),
    ('173', 'Binary Search Tree Iterator', 'binary-search-tree-iterator', 'trees', 'Medium'),
    ('174', 'Dungeon Game', 'dungeon-game', 'dynamic_programming', 'Hard'),
    ('175', 'Combine Two Tables', 'combine-two-tables', 'sql', 'Easy'),
    ('176', 'Second Highest Salary', 'second-highest-salary', 'sql', 'Medium'),
    ('177', 'Nth Highest Salary', 'nth-highest-salary', 'sql', 'Medium'),
    ('178', 'Rank Scores', 'rank-scores', 'sql', 'Medium'),
    ('179', 'Largest Number', 'largest-number', 'strings', 'Medium'),
    ('180', 'Consecutive Numbers', 'consecutive-numbers', 'sql', 'Medium'),
    ('181', 'Employees Earning More Than Their Managers', 'employees-earning-more-than-their-managers', 'sql', 'Easy'),
]

HARD_SLUGS = {
    'trapping-rain-water', 'merge-k-sorted-lists', 'minimum-window-substring',
    'find-median-from-data-stream', 'serialize-and-deserialize-binary-tree',
    'word-ladder', 'alien-dictionary', 'sliding-window-maximum',
    'longest-valid-parentheses', 'first-missing-positive', 'trapping-rain-water-ii',
    'basic-calculator', 'basic-calculator-ii', 'burst-balloons',
    'regular-expression-matching', 'wildcard-matching', 'edit-distance',
    'distinct-subsequences', 'best-time-to-buy-and-sell-stock-iii',
    'best-time-to-buy-and-sell-stock-iv', 'maximal-rectangle', 'largest-rectangle-in-histogram',
}

EASY_HINTS = (
    'concatenation', 'replace elements', 'length of last word', 'remove element',
    'majority element', 'pascal', 'valid anagram', 'contains duplicate',
    'reverse string', 'palindrome', 'fibonacci', 'climbing stairs',
    'two sum', 'valid parentheses', 'merge sorted array', 'binary search',
    'maximum depth', 'same tree', 'invert binary', 'linked list cycle',
)


def slug_to_function(slug: str) -> str:
    parts = slug.split('-')
    return parts[0] + ''.join(p.capitalize() for p in parts[1:])


def guess_difficulty(title: str, slug: str) -> str:
    if slug in HARD_SLUGS:
        return 'Hard'
    lower = title.lower()
    if any(h in lower for h in EASY_HINTS):
        return 'Easy'
    if 'hard' in lower or 'median' in lower or 'serialize' in lower:
        return 'Hard'
    if 'design' in lower or 'minimum window' in lower:
        return 'Hard'
    return 'Medium'


def topic_tags(topic: str) -> list[str]:
    mapping = {
        'arrays': ['Array'],
        'hash_map': ['Hash Table', 'Array'],
        'strings': ['String'],
        'linked_lists': ['Linked List'],
        'trees': ['Tree', 'Binary Tree'],
        'graphs': ['Graph', 'BFS', 'DFS'],
        'stack_queue': ['Stack'],
        'sorting': ['Sorting', 'Array'],
        'dynamic_programming': ['Dynamic Programming'],
        'recursion': ['Recursion', 'Backtracking'],
        'competitive': ['Greedy', 'Contest'],
        'sql': ['SQL'],
    }
    return mapping.get(topic, ['Algorithm'])


def parse_readme(text: str) -> list[tuple[str, str, str, str, str]]:
    pattern = re.compile(
        r'\[(\d+)\s*-\s*([^\]]+)\]\(https://leetcode\.com/problems/([^/)]+)/'
    )
    current_topic = 'arrays'
    rows: list[tuple[str, str, str, str, str]] = []
    seen: set[str] = set()

    for line in text.splitlines():
        header = re.match(r'^###\s+(.+)$', line.strip())
        if header:
            key = header.group(1).strip().lower()
            current_topic = SECTION_TOPIC.get(key, current_topic)
            continue
        for num, title, slug in pattern.findall(line):
            pid = str(int(num))
            if pid in seen:
                continue
            seen.add(pid)
            diff = guess_difficulty(title.strip(), slug)
            rows.append((pid, title.strip(), slug, current_topic, diff))

    return rows


def dart_escape(s: str) -> str:
    return s.replace('\\', '\\\\').replace("'", "\\'")


def emit_dart(rows: list[tuple[str, str, str, str, str]], out_path: Path) -> None:
    lines = [
        "// GENERATED by tool/generate_leetcode_catalog.py — do not edit by hand.",
        "import '../models/leetcode_problem.dart';",
        "",
        "/// Compact catalog of classic interview problems (500+).",
        "class LeetcodeProblemCatalogData {",
        "  LeetcodeProblemCatalogData._();",
        "",
        f"  static const int catalogSize = {len(rows)};",
        "",
        "  /// [id, title, slug, topicKey, difficulty]",
        "  static const List<List<String>> entries = <List<String>>[",
    ]
    for pid, title, slug, topic, diff in rows:
        lines.append(
            f"    <String>['{pid}', '{dart_escape(title)}', '{slug}', '{topic}', '{diff}'],"
        )
    lines += [
        "  ];",
        "",
        "  static List<LeetcodeProblem> buildProblems() {",
        "    return entries.map(LeetcodeProblemCatalogData.toProblem).toList();",
        "  }",
        "",
        "  static LeetcodeProblem toProblem(List<String> row) {",
        "    final String id = row[0];",
        "    final String title = row[1];",
        "    final String slug = row[2];",
        "    final String topic = row[3];",
        "    final String difficulty = row[4];",
        "    final String functionName = _functionName(slug);",
        "    final List<String> tags = _tagsForTopic(topic);",
        "    return LeetcodeProblem(",
        "      id: id,",
        "      title: title,",
        "      slug: slug,",
        "      difficulty: difficulty,",
        "      tags: tags,",
        "      functionName: functionName,",
        "      description:",
        '          "Solve **$title** — a classic coding interview problem. "',
        '          "Implement a correct solution that passes all test cases.",',
        "      examples: <LeetcodeExample>[",
        "        LeetcodeExample(",
        '          input: "See problem statement for $title",',
        '          output: "Correct result for sample input",',
        "        ),",
        "      ],",
        '      constraints: <String>["Follow standard LeetCode constraints for $title"],',
        "    );",
        "  }",
        "",
        "  static String _functionName(String slug) {",
        "    final List<String> parts = slug.split('-');",
        "    if (parts.isEmpty) return 'solve';",
        "    return parts.first + parts.skip(1).map((String p) =>",
        "        p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1)).join();",
        "  }",
        "",
        "  static List<String> _tagsForTopic(String topic) {",
        "    switch (topic) {",
        "      case 'arrays': return <String>['Array'];",
        "      case 'hash_map': return <String>['Hash Table', 'Array'];",
        "      case 'strings': return <String>['String'];",
        "      case 'linked_lists': return <String>['Linked List'];",
        "      case 'trees': return <String>['Tree', 'Binary Tree'];",
        "      case 'graphs': return <String>['Graph'];",
        "      case 'stack_queue': return <String>['Stack'];",
        "      case 'sorting': return <String>['Sorting', 'Array'];",
        "      case 'dynamic_programming': return <String>['Dynamic Programming'];",
        "      case 'recursion': return <String>['Recursion', 'Backtracking'];",
        "      case 'competitive': return <String>['Greedy'];",
        "      case 'sql': return <String>['SQL'];",
        "      default: return <String>['Algorithm'];",
        "    }",
        "  }",
        "}",
        "",
    ]
    out_path.write_text('\n'.join(lines), encoding='utf-8')
    print(f'Wrote {len(rows)} problems to {out_path}')


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    readme = root / 'tool' / 'neetcode_readme.md'
    if not readme.exists():
        # fallback: agent-tools copy
        alt = Path(
            r'C:\Users\Tomachi Egere\.cursor\projects'
            r'\c-Users-Tomachi-Egere-OneDrive-Pictures-Documents-ai-study-buddy'
            r'\agent-tools\b655b15f-d088-46be-b060-b84036fdfa20.txt'
        )
        if alt.exists():
            readme.write_text(alt.read_text(encoding='utf-8'), encoding='utf-8')
        else:
            print('Missing tool/neetcode_readme.md', file=sys.stderr)
            sys.exit(1)

    rows = parse_readme(readme.read_text(encoding='utf-8'))
    seen = {row[0] for row in rows}
    for extra in EXTRA_PROBLEMS:
        if extra[0] not in seen:
            rows.append(extra)
            seen.add(extra[0])
    emit_dart(rows, root / 'lib' / 'data' / 'leetcode_problem_catalog_data.dart')


if __name__ == '__main__':
    main()
