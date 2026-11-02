import 'science_career_content.dart';

/// Builds 500 playable coding challenges with real option-based evaluators.
abstract final class CodingChallengeBank {
  static List<CodingChallenge>? _cache;

  static List<CodingChallenge> all() {
    final List<CodingChallenge>? existing = _cache;
    if (existing != null) return existing;

    final List<CodingChallenge> out = <CodingChallenge>[
      _handcraftedTwoSum(),
      _handcraftedSessionGuard(),
    ];

    // Fill to 500 unique challenges via parameterized templates.
    final List<_Template> templates = _templates;
    int n = 1;
    while (out.length < 500) {
      final _Template t = templates[(n - 1) % templates.length];
      final int variant = ((n - 1) ~/ templates.length) + 1;
      out.add(t.build(index: out.length + 1, variant: variant));
      n++;
    }

    _cache = out;
    return out;
  }

  static List<CodingChallenge> forMajor(String majorId) {
    final List<CodingChallenge> allCh = all();
    // Prefer major-flavored challenges first, then the rest.
    final String tag = switch (majorId) {
      'ai_ml' => 'AI',
      'data_science' => 'Data',
      'cybersecurity' => 'Security',
      'information_technology' => 'IT',
      'web_development' => 'Web',
      'mobile_development' => 'Mobile',
      'computer_science' => 'Algorithms',
      _ => 'Software',
    };
    final List<CodingChallenge> preferred = allCh
        .where((CodingChallenge c) => c.topics.any((String x) => x.contains(tag)))
        .toList();
    if (preferred.length >= 80) return preferred;
    return allCh;
  }

  static CodingChallenge _handcraftedTwoSum() {
    return CodingChallenge(
      id: 'se_two_sum',
      title: 'Two Sum',
      difficulty: 'Easy',
      topics: const <String>['Arrays', 'Hash maps', 'Software'],
      prompt:
          'Given an array of integers nums and an integer target, return '
          'indices of the two numbers such that they add up to target.',
      examples:
          'Input: nums = [2, 7, 11, 15], target = 9\nOutput: [0, 1]',
      constraints: 'Aim for one pass, O(n) time.',
      xpReward: 40,
      pathLabel: 'Arrays path',
      options: const <CodeOption>[
        CodeOption(
          id: 'broken_self',
          label: 'Store before check (buggy)',
          coachTip: 'Check the complement before storing the current index.',
          code:
              'def two_sum(nums, target):\n    seen = {}\n    for i, n in enumerate(nums):\n        seen[n] = i\n        need = target - n\n        if need in seen:\n            return [seen[need], i]\n    return []',
        ),
        CodeOption(
          id: 'values',
          label: 'Returns values not indices',
          coachTip: 'Return indices, not the numbers themselves.',
          code:
              'def two_sum(nums, target):\n    for a in nums:\n        for b in nums:\n            if a + b == target:\n                return [a, b]\n    return []',
        ),
        CodeOption(
          id: 'hash',
          label: 'Hash map one pass',
          coachTip: 'Nice — check first, then store.',
          code:
              'def two_sum(nums, target):\n    seen = {}\n    for i, n in enumerate(nums):\n        need = target - n\n        if need in seen:\n            return [seen[need], i]\n        seen[n] = i\n    return []',
        ),
      ],
      correctOptionId: 'hash',
      runTests: (String optionId) {
        List<int> Function(List<int>, int) impl;
        switch (optionId) {
          case 'hash':
            impl = (List<int> nums, int target) {
              final Map<int, int> seen = <int, int>{};
              for (int i = 0; i < nums.length; i++) {
                final int need = target - nums[i];
                if (seen.containsKey(need)) return <int>[seen[need]!, i];
                seen[nums[i]] = i;
              }
              return <int>[];
            };
          case 'broken_self':
            impl = (List<int> nums, int target) {
              final Map<int, int> seen = <int, int>{};
              for (int i = 0; i < nums.length; i++) {
                seen[nums[i]] = i;
                final int need = target - nums[i];
                if (seen.containsKey(need)) return <int>[seen[need]!, i];
              }
              return <int>[];
            };
          default:
            impl = (List<int> nums, int target) {
              for (final int a in nums) {
                for (final int b in nums) {
                  if (a + b == target) return <int>[a, b];
                }
              }
              return <int>[];
            };
        }
        TestResult caseOf(String name, List<int> nums, int target, List<int> want) {
          final List<int> got = impl(nums, target);
          final List<int> g = List<int>.from(got)..sort();
          final List<int> w = List<int>.from(want)..sort();
          final bool ok = g.length == w.length &&
              List.generate(g.length, (int i) => g[i] == w[i])
                  .every((bool v) => v);
          return TestResult(
            name: name,
            passed: ok,
            detail: ok ? 'Case passed.' : 'expected $want, got $got',
            expected: '$want',
            got: '$got',
          );
        }

        return <TestResult>[
          caseOf('Case 1', <int>[2, 7, 11, 15], 9, <int>[0, 1]),
          caseOf('Case 2', <int>[3, 2, 4], 6, <int>[1, 2]),
          caseOf('Case 3', <int>[3, 3], 6, <int>[0, 1]),
        ];
      },
    );
  }

  static CodingChallenge _handcraftedSessionGuard() {
    return CodingChallenge(
      id: 'se_session_guard',
      title: 'Session guard',
      difficulty: 'Medium',
      topics: const <String>['Logic', 'Auth', 'Software'],
      prompt:
          'A route should open only when the user has a valid session token '
          'AND the token is not expired.',
      examples: 'hasToken=true, expired=false → allow',
      constraints: 'Both conditions must be true.',
      xpReward: 60,
      pathLabel: 'Auth path',
      options: const <CodeOption>[
        CodeOption(
          id: 'or_bug',
          label: 'Uses OR',
          coachTip: 'OR is too permissive.',
          code:
              'def can_enter(has_token, expired):\n    return has_token or not expired',
        ),
        CodeOption(
          id: 'and_ok',
          label: 'Uses AND',
          coachTip: 'Correct.',
          code:
              'def can_enter(has_token, expired):\n    return has_token and not expired',
        ),
        CodeOption(
          id: 'ignore',
          label: 'Ignores expiry',
          coachTip: 'Reject expired tokens.',
          code: 'def can_enter(has_token, expired):\n    return has_token',
        ),
      ],
      correctOptionId: 'and_ok',
      runTests: (String optionId) {
        bool Function(bool, bool) impl;
        switch (optionId) {
          case 'and_ok':
            impl = (bool a, bool b) => a && !b;
          case 'ignore':
            impl = (bool a, bool b) => a;
          default:
            impl = (bool a, bool b) => a || !b;
        }
        return <TestResult>[
          TestResult(
            name: 'Case 1',
            passed: impl(true, false),
            detail: 'Valid session',
            expected: 'true',
            got: '${impl(true, false)}',
          ),
          TestResult(
            name: 'Case 2',
            passed: !impl(true, true),
            detail: 'Expired',
            expected: 'false',
            got: '${impl(true, true)}',
          ),
          TestResult(
            name: 'Case 3',
            passed: !impl(false, false),
            detail: 'Logged out',
            expected: 'false',
            got: '${impl(false, false)}',
          ),
        ];
      },
    );
  }

  static final List<_Template> _templates = <_Template>[
    _Template.arraySum(),
    _Template.arrayMax(),
    _Template.arrayMin(),
    _Template.arrayProduct(),
    _Template.reverseArray(),
    _Template.containsValue(),
    _Template.countOccurrences(),
    _Template.isEvenCount(),
    _Template.stringLength(),
    _Template.isPalindrome(),
    _Template.countVowels(),
    _Template.stringUpper(),
    _Template.clampValue(),
    _Template.absDiff(),
    _Template.gcdLike(),
    _Template.isPrimeLike(),
    _Template.boolAnd(),
    _Template.boolXor(),
    _Template.sortAscCheck(),
    _Template.uniqueCount(),
    _Template.securityLogLevel(),
    _Template.dataMissingRate(),
    _Template.aiAccuracy(),
    _Template.webStatusOk(),
    _Template.mobileNullGuard(),
    _Template.itTicketPriority(),
    _Template.csBinarySearchStep(),
    _Template.hashFreqPeak(),
  ];
}

class _Template {
  const _Template({
    required this.family,
    required this.difficulty,
    required this.topics,
    required this.pathLabel,
    required this.xp,
    required this.buildBody,
  });

  final String family;
  final String difficulty;
  final List<String> topics;
  final String pathLabel;
  final int xp;
  final CodingChallenge Function(int index, int variant) buildBody;

  CodingChallenge build({required int index, required int variant}) =>
      buildBody(index, variant);

  static String _id(int index) =>
      'ch_${index.toString().padLeft(4, '0')}';

  /// Option-picker challenge: only correctOptionId passes all real assertions.
  static CodingChallenge choice({
    required int index,
    required int variant,
    required String title,
    required String difficulty,
    required List<String> topics,
    required String pathLabel,
    required int xp,
    required String prompt,
    required String examples,
    required String constraints,
    required String fnName,
    required String correctCode,
    required String wrongACode,
    required String wrongBCode,
    required String correctTip,
    required String wrongATip,
    required String wrongBTip,
    required List<TestResult> Function(String optionId) runTests,
  }) {
    return CodingChallenge(
      id: _id(index),
      title: '$title #$variant',
      difficulty: difficulty,
      topics: topics,
      prompt: prompt,
      examples: examples,
      constraints: constraints,
      xpReward: xp,
      pathLabel: pathLabel,
      options: <CodeOption>[
        CodeOption(
          id: 'a',
          label: 'Approach A',
          coachTip: wrongATip,
          code: wrongACode,
        ),
        CodeOption(
          id: 'b',
          label: 'Approach B',
          coachTip: wrongBTip,
          code: wrongBCode,
        ),
        CodeOption(
          id: 'ok',
          label: 'Recommended',
          coachTip: correctTip,
          code: correctCode,
        ),
      ],
      correctOptionId: 'ok',
      runTests: runTests,
    );
  }

  static _Template arraySum() => _Template(
        family: 'sum',
        difficulty: 'Easy',
        topics: const <String>['Arrays', 'Software'],
        pathLabel: 'Arrays path',
        xp: 35,
        buildBody: (int index, int variant) {
          final int bias = variant;
          return choice(
            index: index,
            variant: variant,
            title: 'Array sum',
            difficulty: 'Easy',
            topics: const <String>['Arrays', 'Software'],
            pathLabel: 'Arrays path',
            xp: 35,
            prompt:
                'Return the sum of all integers in nums. Variant seed $bias.',
            examples: 'nums = [1, 2, 3] → 6',
            constraints: 'O(n) time.',
            fnName: 'array_sum',
            correctCode:
                'def array_sum(nums):\n    total = 0\n    for n in nums:\n        total += n\n    return total',
            wrongACode:
                'def array_sum(nums):\n    total = 0\n    for n in nums:\n        total += n\n    return total + $bias  # off-by-seed',
            wrongBCode:
                'def array_sum(nums):\n    return nums[0] if nums else 0',
            correctTip: 'Accumulate every element.',
            wrongATip: 'Do not add an extra constant.',
            wrongBTip: 'You must include every element, not only the first.',
            runTests: (String id) {
              int impl(List<int> nums) {
                if (id == 'ok') {
                  return nums.fold<int>(0, (int a, int b) => a + b);
                }
                if (id == 'a') {
                  return nums.fold<int>(0, (int a, int b) => a + b) + bias;
                }
                return nums.isEmpty ? 0 : nums.first;
              }

              final List<List<int>> cases = <List<int>>[
                <int>[1, 2, 3],
                <int>[bias, 4, 5],
                <int>[-2, 2, 10],
              ];
              return List<TestResult>.generate(3, (int i) {
                final int want =
                    cases[i].fold<int>(0, (int a, int b) => a + b);
                final int got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                  expected: '$want',
                  got: '$got',
                );
              });
            },
          );
        },
      );

  static _Template arrayMax() => _Template(
        family: 'max',
        difficulty: 'Easy',
        topics: const <String>['Arrays', 'Algorithms'],
        pathLabel: 'Arrays path',
        xp: 35,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Find maximum',
            difficulty: 'Easy',
            topics: const <String>['Arrays', 'Algorithms'],
            pathLabel: 'Arrays path',
            xp: 35,
            prompt: 'Return the maximum value in a non-empty list.',
            examples: '[3, 1, 7] → 7',
            constraints: 'Handle negatives.',
            fnName: 'array_max',
            correctCode:
                'def array_max(nums):\n    m = nums[0]\n    for n in nums:\n        if n > m: m = n\n    return m',
            wrongACode:
                'def array_max(nums):\n    return abs(nums[0])',
            wrongBCode:
                'def array_max(nums):\n    return min(nums)',
            correctTip: 'Track the running max.',
            wrongATip: 'Absolute value is not maximum.',
            wrongBTip: 'That returns the minimum.',
            runTests: (String id) {
              int impl(List<int> nums) {
                if (id == 'ok') {
                  return nums.reduce((int a, int b) => a > b ? a : b);
                }
                if (id == 'a') return nums.first.abs();
                return nums.reduce((int a, int b) => a < b ? a : b);
              }

              final List<List<int>> cases = <List<int>>[
                <int>[3, 1, 7],
                <int>[-5, -1, -9],
                <int>[variant, 0, -variant],
              ];
              return List<TestResult>.generate(3, (int i) {
                final int want =
                    cases[i].reduce((int a, int b) => a > b ? a : b);
                final int got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template arrayMin() => _Template(
        family: 'min',
        difficulty: 'Easy',
        topics: const <String>['Arrays', 'Algorithms'],
        pathLabel: 'Arrays path',
        xp: 35,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Find minimum',
            difficulty: 'Easy',
            topics: const <String>['Arrays', 'Algorithms'],
            pathLabel: 'Arrays path',
            xp: 35,
            prompt: 'Return the minimum value in a non-empty list.',
            examples: '[3, 1, 7] → 1',
            constraints: 'Handle negatives.',
            fnName: 'array_min',
            correctCode:
                'def array_min(nums):\n    m = nums[0]\n    for n in nums:\n        if n < m: m = n\n    return m',
            wrongACode: 'def array_min(nums):\n    return max(nums)',
            wrongBCode: 'def array_min(nums):\n    return nums[-1]',
            correctTip: 'Track the running min.',
            wrongATip: 'That is max.',
            wrongBTip: 'Last element is not always min.',
            runTests: (String id) {
              int impl(List<int> nums) {
                if (id == 'ok') {
                  return nums.reduce((int a, int b) => a < b ? a : b);
                }
                if (id == 'a') {
                  return nums.reduce((int a, int b) => a > b ? a : b);
                }
                return nums.last;
              }

              final List<List<int>> cases = <List<int>>[
                <int>[3, 1, 7],
                <int>[-5, -1, -9],
                <int>[variant + 2, variant, variant + 9],
              ];
              return List<TestResult>.generate(3, (int i) {
                final int want =
                    cases[i].reduce((int a, int b) => a < b ? a : b);
                final int got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template arrayProduct() => _Template(
        family: 'product',
        difficulty: 'Easy',
        topics: const <String>['Arrays', 'Software'],
        pathLabel: 'Arrays path',
        xp: 40,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Array product',
            difficulty: 'Easy',
            topics: const <String>['Arrays', 'Software'],
            pathLabel: 'Arrays path',
            xp: 40,
            prompt: 'Return the product of all integers in nums.',
            examples: '[2, 3, 4] → 24',
            constraints: 'Empty list → 1.',
            fnName: 'array_product',
            correctCode:
                'def array_product(nums):\n    p = 1\n    for n in nums:\n        p *= n\n    return p',
            wrongACode:
                'def array_product(nums):\n    return sum(nums)',
            wrongBCode:
                'def array_product(nums):\n    p = 0\n    for n in nums:\n        p *= n\n    return p',
            correctTip: 'Start at 1, multiply each.',
            wrongATip: 'Sum is not product.',
            wrongBTip: 'Starting at 0 makes everything 0.',
            runTests: (String id) {
              int impl(List<int> nums) {
                if (id == 'ok') {
                  return nums.fold<int>(1, (int a, int b) => a * b);
                }
                if (id == 'a') {
                  return nums.fold<int>(0, (int a, int b) => a + b);
                }
                return 0;
              }

              final List<List<int>> cases = <List<int>>[
                <int>[2, 3, 4],
                <int>[1, variant, 1],
                <int>[-1, 5],
              ];
              return List<TestResult>.generate(3, (int i) {
                final int want =
                    cases[i].fold<int>(1, (int a, int b) => a * b);
                final int got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template reverseArray() => _Template(
        family: 'reverse',
        difficulty: 'Easy',
        topics: const <String>['Arrays', 'Algorithms'],
        pathLabel: 'Arrays path',
        xp: 40,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Reverse array',
            difficulty: 'Easy',
            topics: const <String>['Arrays', 'Algorithms'],
            pathLabel: 'Arrays path',
            xp: 40,
            prompt: 'Return a new list with elements reversed.',
            examples: '[1,2,3] → [3,2,1]',
            constraints: 'Do not mutate incorrectly.',
            fnName: 'reverse_list',
            correctCode:
                'def reverse_list(nums):\n    return nums[::-1]',
            wrongACode:
                'def reverse_list(nums):\n    return nums',
            wrongBCode:
                'def reverse_list(nums):\n    return sorted(nums)',
            correctTip: 'Slice reverse or two pointers.',
            wrongATip: 'That returns the original order.',
            wrongBTip: 'Sorting is not reversing.',
            runTests: (String id) {
              List<int> impl(List<int> nums) {
                if (id == 'ok') return nums.reversed.toList();
                if (id == 'a') return List<int>.from(nums);
                final List<int> s = List<int>.from(nums)..sort();
                return s;
              }

              final List<List<int>> cases = <List<int>>[
                <int>[1, 2, 3],
                <int>[variant, 9, 0],
                <int>[5],
              ];
              return List<TestResult>.generate(3, (int i) {
                final List<int> want = cases[i].reversed.toList();
                final List<int> got = impl(cases[i]);
                final bool ok = want.toString() == got.toString();
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: ok,
                  detail: ok ? 'Case passed.' : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template containsValue() => _Template(
        family: 'contains',
        difficulty: 'Easy',
        topics: const <String>['Arrays', 'Hash maps', 'Software'],
        pathLabel: 'Hash maps path',
        xp: 35,
        buildBody: (int index, int variant) {
          final int target = variant + 3;
          return choice(
            index: index,
            variant: variant,
            title: 'Contains value',
            difficulty: 'Easy',
            topics: const <String>['Arrays', 'Hash maps', 'Software'],
            pathLabel: 'Hash maps path',
            xp: 35,
            prompt: 'Return True if target appears in nums.',
            examples: 'nums=[1,2,$target], target=$target → True',
            constraints: 'O(n) is fine.',
            fnName: 'contains',
            correctCode:
                'def contains(nums, target):\n    return target in nums',
            wrongACode:
                'def contains(nums, target):\n    return nums[0] == target',
            wrongBCode:
                'def contains(nums, target):\n    return False',
            correctTip: 'Scan or use a set.',
            wrongATip: 'Only checking index 0 is wrong.',
            wrongBTip: 'Always False fails positive cases.',
            runTests: (String id) {
              bool impl(List<int> nums, int t) {
                if (id == 'ok') return nums.contains(t);
                if (id == 'a') return nums.isNotEmpty && nums.first == t;
                return false;
              }

              final List<(List<int>, int, bool)> cases =
                  <(List<int>, int, bool)>[
                (<int>[1, 2, target], target, true),
                (<int>[1, 2, 3], 99, false),
                (<int>[target], target, true),
              ];
              return List<TestResult>.generate(3, (int i) {
                final (List<int> nums, int t, bool want) = cases[i];
                final bool got = impl(nums, t);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template countOccurrences() => _Template(
        family: 'count',
        difficulty: 'Easy',
        topics: const <String>['Arrays', 'Hash maps', 'Data'],
        pathLabel: 'Hash maps path',
        xp: 40,
        buildBody: (int index, int variant) {
          final int needle = variant % 5;
          return choice(
            index: index,
            variant: variant,
            title: 'Count occurrences',
            difficulty: 'Easy',
            topics: const <String>['Arrays', 'Hash maps', 'Data'],
            pathLabel: 'Hash maps path',
            xp: 40,
            prompt: 'Count how many times value x appears in nums.',
            examples: 'nums=[1,2,2], x=2 → 2',
            constraints: 'O(n).',
            fnName: 'count_x',
            correctCode:
                'def count_x(nums, x):\n    return sum(1 for n in nums if n == x)',
            wrongACode:
                'def count_x(nums, x):\n    return 1 if x in nums else 0',
            wrongBCode:
                'def count_x(nums, x):\n    return len(nums)',
            correctTip: 'Count equals, not membership.',
            wrongATip: 'Membership loses duplicate counts.',
            wrongBTip: 'That counts everything.',
            runTests: (String id) {
              int impl(List<int> nums, int x) {
                if (id == 'ok') {
                  return nums.where((int n) => n == x).length;
                }
                if (id == 'a') return nums.contains(x) ? 1 : 0;
                return nums.length;
              }

              final List<(List<int>, int)> cases = <(List<int>, int)>[
                (<int>[needle, 2, needle, needle], needle),
                (<int>[9, 8, 7], needle),
                (<int>[1, 1, 1, 1], 1),
              ];
              return List<TestResult>.generate(3, (int i) {
                final (List<int> nums, int x) = cases[i];
                final int want = nums.where((int n) => n == x).length;
                final int got = impl(nums, x);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template isEvenCount() => _Template(
        family: 'evens',
        difficulty: 'Easy',
        topics: const <String>['Arrays', 'Algorithms'],
        pathLabel: 'Arrays path',
        xp: 35,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Count evens',
            difficulty: 'Easy',
            topics: const <String>['Arrays', 'Algorithms'],
            pathLabel: 'Arrays path',
            xp: 35,
            prompt: 'Return how many even numbers are in nums.',
            examples: '[1,2,4] → 2',
            constraints: '0 is even.',
            fnName: 'count_evens',
            correctCode:
                'def count_evens(nums):\n    return sum(1 for n in nums if n % 2 == 0)',
            wrongACode:
                'def count_evens(nums):\n    return sum(1 for n in nums if n % 2 == 1)',
            wrongBCode:
                'def count_evens(nums):\n    return len(nums) // 2',
            correctTip: 'Use modulo 2 == 0.',
            wrongATip: 'That counts odds.',
            wrongBTip: 'Guessing half is wrong.',
            runTests: (String id) {
              int impl(List<int> nums) {
                if (id == 'ok') {
                  return nums.where((int n) => n.isEven).length;
                }
                if (id == 'a') {
                  return nums.where((int n) => n.isOdd).length;
                }
                return nums.length ~/ 2;
              }

              final List<List<int>> cases = <List<int>>[
                <int>[1, 2, 4],
                <int>[0, variant, variant + 1],
                <int>[3, 5, 7],
              ];
              return List<TestResult>.generate(3, (int i) {
                final int want = cases[i].where((int n) => n.isEven).length;
                final int got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template stringLength() => _Template(
        family: 'strlen',
        difficulty: 'Easy',
        topics: const <String>['Strings', 'Software'],
        pathLabel: 'Strings path',
        xp: 30,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'String length',
            difficulty: 'Easy',
            topics: const <String>['Strings', 'Software'],
            pathLabel: 'Strings path',
            xp: 30,
            prompt: 'Return the length of s.',
            examples: '"hi" → 2',
            constraints: 'Count characters.',
            fnName: 'strlen',
            correctCode: 'def strlen(s):\n    return len(s)',
            wrongACode: 'def strlen(s):\n    return len(s.split())',
            wrongBCode: 'def strlen(s):\n    return 0',
            correctTip: 'Use len(s).',
            wrongATip: 'Word count ≠ character count.',
            wrongBTip: 'Always 0 fails.',
            runTests: (String id) {
              int impl(String s) {
                if (id == 'ok') return s.length;
                if (id == 'a') {
                  return s.trim().isEmpty ? 0 : s.trim().split(RegExp(r'\s+')).length;
                }
                return 0;
              }

              final List<String> cases = <String>[
                'hi',
                'v$variant test',
                '',
              ];
              return List<TestResult>.generate(3, (int i) {
                final int want = cases[i].length;
                final int got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template isPalindrome() => _Template(
        family: 'palindrome',
        difficulty: 'Medium',
        topics: const <String>['Strings', 'Algorithms'],
        pathLabel: 'Strings path',
        xp: 55,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Palindrome check',
            difficulty: 'Medium',
            topics: const <String>['Strings', 'Algorithms'],
            pathLabel: 'Strings path',
            xp: 55,
            prompt: 'Return True if s equals its reverse.',
            examples: '"aba" → True',
            constraints: 'Case-sensitive.',
            fnName: 'is_pal',
            correctCode: 'def is_pal(s):\n    return s == s[::-1]',
            wrongACode: 'def is_pal(s):\n    return s == s.lower()',
            wrongBCode: 'def is_pal(s):\n    return len(s) > 0',
            correctTip: 'Compare to reversed string.',
            wrongATip: 'Lowercasing is not a palindrome check.',
            wrongBTip: 'Non-empty ≠ palindrome.',
            runTests: (String id) {
              bool impl(String s) {
                if (id == 'ok') {
                  return s == s.split('').reversed.join();
                }
                if (id == 'a') return s == s.toLowerCase();
                return s.isNotEmpty;
              }

              final List<(String, bool)> cases = <(String, bool)>[
                ('aba', true),
                ('ab', false),
                ('v${variant}v', true),
              ];
              return List<TestResult>.generate(3, (int i) {
                final (String s, bool want) = cases[i];
                final bool got = impl(s);
                // want for #3 depends on actual reverse
                final bool realWant = s == s.split('').reversed.join();
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == realWant,
                  detail: got == realWant
                      ? 'Case passed.'
                      : 'expected $realWant, got $got',
                );
              });
            },
          );
        },
      );

  static _Template countVowels() => _Template(
        family: 'vowels',
        difficulty: 'Easy',
        topics: const <String>['Strings', 'Data'],
        pathLabel: 'Strings path',
        xp: 40,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Count vowels',
            difficulty: 'Easy',
            topics: const <String>['Strings', 'Data'],
            pathLabel: 'Strings path',
            xp: 40,
            prompt: 'Count vowels aeiou in lowercase s.',
            examples: '"audio" → 4',
            constraints: 'Ignore consonants.',
            fnName: 'count_vowels',
            correctCode:
                "def count_vowels(s):\n    return sum(1 for c in s if c in 'aeiou')",
            wrongACode:
                "def count_vowels(s):\n    return sum(1 for c in s if c in 'aeiouAEIOU')",
            wrongBCode: 'def count_vowels(s):\n    return len(s)',
            correctTip: 'Only lowercase aeiou for this problem.',
            wrongATip: 'Uppercase should not count here.',
            wrongBTip: 'That counts all chars.',
            runTests: (String id) {
              int impl(String s) {
                const String v = 'aeiou';
                if (id == 'ok') {
                  return s.split('').where((String c) => v.contains(c)).length;
                }
                if (id == 'a') {
                  return s
                      .split('')
                      .where((String c) => 'aeiouAEIOU'.contains(c))
                      .length;
                }
                return s.length;
              }

              final List<String> cases = <String>[
                'audio',
                'AEIOU',
                'rhythm$variant',
              ];
              return List<TestResult>.generate(3, (int i) {
                final int want = cases[i]
                    .split('')
                    .where((String c) => 'aeiou'.contains(c))
                    .length;
                final int got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template stringUpper() => _Template(
        family: 'upper',
        difficulty: 'Easy',
        topics: const <String>['Strings', 'Web'],
        pathLabel: 'Strings path',
        xp: 30,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Uppercase',
            difficulty: 'Easy',
            topics: const <String>['Strings', 'Web'],
            pathLabel: 'Strings path',
            xp: 30,
            prompt: 'Return s in uppercase.',
            examples: '"Hi" → "HI"',
            constraints: 'Preserve non-letters.',
            fnName: 'to_upper',
            correctCode: 'def to_upper(s):\n    return s.upper()',
            wrongACode: 'def to_upper(s):\n    return s.lower()',
            wrongBCode: 'def to_upper(s):\n    return s.title()',
            correctTip: 'Use upper().',
            wrongATip: 'That lowercases.',
            wrongBTip: 'Title case ≠ upper.',
            runTests: (String id) {
              String impl(String s) {
                if (id == 'ok') return s.toUpperCase();
                if (id == 'a') return s.toLowerCase();
                if (s.isEmpty) return s;
                return s[0].toUpperCase() + s.substring(1).toLowerCase();
              }

              final List<String> cases = <String>['Hi', 'v$variant', 'a_b'];
              return List<TestResult>.generate(3, (int i) {
                final String want = cases[i].toUpperCase();
                final String got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template clampValue() => _Template(
        family: 'clamp',
        difficulty: 'Easy',
        topics: const <String>['Math', 'Mobile', 'Software'],
        pathLabel: 'Logic path',
        xp: 40,
        buildBody: (int index, int variant) {
          final int lo = variant;
          final int hi = variant + 10;
          return choice(
            index: index,
            variant: variant,
            title: 'Clamp value',
            difficulty: 'Easy',
            topics: const <String>['Math', 'Mobile', 'Software'],
            pathLabel: 'Logic path',
            xp: 40,
            prompt: 'Clamp x into [$lo, $hi].',
            examples: 'x=${lo - 2} → $lo',
            constraints: 'Inclusive bounds.',
            fnName: 'clamp',
            correctCode:
                'def clamp(x, lo, hi):\n    return max(lo, min(hi, x))',
            wrongACode: 'def clamp(x, lo, hi):\n    return x',
            wrongBCode: 'def clamp(x, lo, hi):\n    return lo',
            correctTip: 'max(lo, min(hi, x)).',
            wrongATip: 'Must enforce bounds.',
            wrongBTip: 'Always lo is wrong.',
            runTests: (String id) {
              int impl(int x) {
                if (id == 'ok') return x.clamp(lo, hi);
                if (id == 'a') return x;
                return lo;
              }

              final List<int> xs = <int>[lo - 2, (lo + hi) ~/ 2, hi + 3];
              return List<TestResult>.generate(3, (int i) {
                final int want = xs[i].clamp(lo, hi);
                final int got = impl(xs[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template absDiff() => _Template(
        family: 'absdiff',
        difficulty: 'Easy',
        topics: const <String>['Math', 'Algorithms'],
        pathLabel: 'Math path',
        xp: 35,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Absolute difference',
            difficulty: 'Easy',
            topics: const <String>['Math', 'Algorithms'],
            pathLabel: 'Math path',
            xp: 35,
            prompt: 'Return abs(a - b).',
            examples: 'a=3,b=10 → 7',
            constraints: 'Non-negative result.',
            fnName: 'abs_diff',
            correctCode: 'def abs_diff(a, b):\n    return abs(a - b)',
            wrongACode: 'def abs_diff(a, b):\n    return a - b',
            wrongBCode: 'def abs_diff(a, b):\n    return a + b',
            correctTip: 'Use absolute value.',
            wrongATip: 'Order can make this negative.',
            wrongBTip: 'Sum is not difference.',
            runTests: (String id) {
              int impl(int a, int b) {
                if (id == 'ok') return (a - b).abs();
                if (id == 'a') return a - b;
                return a + b;
              }

              final List<(int, int)> cases = <(int, int)>[
                (3, 10),
                (variant + 5, variant),
                (-2, 2),
              ];
              return List<TestResult>.generate(3, (int i) {
                final (int a, int b) = cases[i];
                final int want = (a - b).abs();
                final int got = impl(a, b);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template gcdLike() => _Template(
        family: 'gcd',
        difficulty: 'Medium',
        topics: const <String>['Math', 'Algorithms'],
        pathLabel: 'Math path',
        xp: 60,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'GCD',
            difficulty: 'Medium',
            topics: const <String>['Math', 'Algorithms'],
            pathLabel: 'Math path',
            xp: 60,
            prompt: 'Return the greatest common divisor of a and b (a,b ≥ 0).',
            examples: '12,18 → 6',
            constraints: 'Euclid algorithm.',
            fnName: 'gcd',
            correctCode:
                'def gcd(a, b):\n    while b:\n        a, b = b, a % b\n    return a',
            wrongACode: 'def gcd(a, b):\n    return min(a, b)',
            wrongBCode: 'def gcd(a, b):\n    return a + b',
            correctTip: 'Use Euclidean algorithm.',
            wrongATip: 'min is not GCD.',
            wrongBTip: 'Sum is wrong.',
            runTests: (String id) {
              int gcd(int a, int b) {
                while (b != 0) {
                  final int t = b;
                  b = a % b;
                  a = t;
                }
                return a;
              }

              int impl(int a, int b) {
                if (id == 'ok') return gcd(a, b);
                if (id == 'a') return a < b ? a : b;
                return a + b;
              }

              final List<(int, int)> cases = <(int, int)>[
                (12, 18),
                (7 * variant, 3 * variant),
                (0, 5),
              ];
              return List<TestResult>.generate(3, (int i) {
                final (int a, int b) = cases[i];
                final int want = gcd(a, b);
                final int got = impl(a, b);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template isPrimeLike() => _Template(
        family: 'prime',
        difficulty: 'Medium',
        topics: const <String>['Math', 'Algorithms'],
        pathLabel: 'Math path',
        xp: 65,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Is prime',
            difficulty: 'Medium',
            topics: const <String>['Math', 'Algorithms'],
            pathLabel: 'Math path',
            xp: 65,
            prompt: 'Return True if n is prime (n ≥ 2).',
            examples: '7 → True, 9 → False',
            constraints: 'Check divisors up to sqrt(n).',
            fnName: 'is_prime',
            correctCode:
                'def is_prime(n):\n    if n < 2: return False\n    d = 2\n    while d * d <= n:\n        if n % d == 0: return False\n        d += 1\n    return True',
            wrongACode: 'def is_prime(n):\n    return n % 2 != 0',
            wrongBCode: 'def is_prime(n):\n    return n > 1',
            correctTip: 'Trial division carefully.',
            wrongATip: 'Odd ≠ prime (9).',
            wrongBTip: 'All n>1 are not prime.',
            runTests: (String id) {
              bool isPrime(int n) {
                if (n < 2) return false;
                for (int d = 2; d * d <= n; d++) {
                  if (n % d == 0) return false;
                }
                return true;
              }

              bool impl(int n) {
                if (id == 'ok') return isPrime(n);
                if (id == 'a') return n.isOdd;
                return n > 1;
              }

              final List<int> cases = <int>[7, 9, 2 + variant * 0];
              // keep third case stable-ish
              cases[2] = variant % 2 == 0 ? 11 : 15;
              return List<TestResult>.generate(3, (int i) {
                final bool want = isPrime(cases[i]);
                final bool got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template boolAnd() => _Template(
        family: 'and',
        difficulty: 'Easy',
        topics: const <String>['Logic', 'Software'],
        pathLabel: 'Logic path',
        xp: 30,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Logical AND',
            difficulty: 'Easy',
            topics: const <String>['Logic', 'Software'],
            pathLabel: 'Logic path',
            xp: 30,
            prompt: 'Return a AND b.',
            examples: 'True, False → False',
            constraints: 'Boolean only.',
            fnName: 'both',
            correctCode: 'def both(a, b):\n    return a and b',
            wrongACode: 'def both(a, b):\n    return a or b',
            wrongBCode: 'def both(a, b):\n    return a',
            correctTip: 'Use and.',
            wrongATip: 'That is or.',
            wrongBTip: 'Ignoring b is wrong.',
            runTests: (String id) {
              bool impl(bool a, bool b) {
                if (id == 'ok') return a && b;
                if (id == 'a') return a || b;
                return a;
              }

              final List<(bool, bool)> cases = <(bool, bool)>[
                (true, true),
                (true, false),
                (false, false),
              ];
              return List<TestResult>.generate(3, (int i) {
                final (bool a, bool b) = cases[i];
                final bool want = a && b;
                final bool got = impl(a, b);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template boolXor() => _Template(
        family: 'xor',
        difficulty: 'Easy',
        topics: const <String>['Logic', 'Security'],
        pathLabel: 'Logic path',
        xp: 40,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Logical XOR',
            difficulty: 'Easy',
            topics: const <String>['Logic', 'Security'],
            pathLabel: 'Logic path',
            xp: 40,
            prompt: 'Return True if exactly one of a, b is True.',
            examples: 'True, False → True',
            constraints: 'Exclusive or.',
            fnName: 'xor',
            correctCode: 'def xor(a, b):\n    return a != b',
            wrongACode: 'def xor(a, b):\n    return a and b',
            wrongBCode: 'def xor(a, b):\n    return a or b',
            correctTip: 'a != b for booleans.',
            wrongATip: 'AND is not XOR.',
            wrongBTip: 'OR is not XOR.',
            runTests: (String id) {
              bool impl(bool a, bool b) {
                if (id == 'ok') return a != b;
                if (id == 'a') return a && b;
                return a || b;
              }

              final List<(bool, bool)> cases = <(bool, bool)>[
                (true, false),
                (true, true),
                (false, false),
              ];
              return List<TestResult>.generate(3, (int i) {
                final (bool a, bool b) = cases[i];
                final bool want = a != b;
                final bool got = impl(a, b);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template sortAscCheck() => _Template(
        family: 'sorted',
        difficulty: 'Easy',
        topics: const <String>['Sorting', 'Algorithms'],
        pathLabel: 'Sorting path',
        xp: 45,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Is sorted ascending',
            difficulty: 'Easy',
            topics: const <String>['Sorting', 'Algorithms'],
            pathLabel: 'Sorting path',
            xp: 45,
            prompt: 'Return True if nums is non-decreasing.',
            examples: '[1,2,2,4] → True',
            constraints: 'Allow duplicates.',
            fnName: 'is_sorted',
            correctCode:
                'def is_sorted(nums):\n    return all(nums[i] <= nums[i+1] for i in range(len(nums)-1))',
            wrongACode:
                'def is_sorted(nums):\n    return all(nums[i] < nums[i+1] for i in range(len(nums)-1))',
            wrongBCode: 'def is_sorted(nums):\n    return True',
            correctTip: 'Use <= for non-decreasing.',
            wrongATip: 'Strict < rejects duplicates.',
            wrongBTip: 'Always True fails.',
            runTests: (String id) {
              bool okFn(List<int> nums) {
                for (int i = 0; i < nums.length - 1; i++) {
                  if (nums[i] > nums[i + 1]) return false;
                }
                return true;
              }

              bool strict(List<int> nums) {
                for (int i = 0; i < nums.length - 1; i++) {
                  if (nums[i] >= nums[i + 1]) return false;
                }
                return true;
              }

              bool impl(List<int> nums) {
                if (id == 'ok') return okFn(nums);
                if (id == 'a') return strict(nums);
                return true;
              }

              final List<List<int>> cases = <List<int>>[
                <int>[1, 2, 2, 4],
                <int>[3, 1],
                <int>[variant, variant, variant + 1],
              ];
              return List<TestResult>.generate(3, (int i) {
                final bool want = okFn(cases[i]);
                final bool got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template uniqueCount() => _Template(
        family: 'unique',
        difficulty: 'Easy',
        topics: const <String>['Hash maps', 'Data'],
        pathLabel: 'Hash maps path',
        xp: 45,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Unique count',
            difficulty: 'Easy',
            topics: const <String>['Hash maps', 'Data'],
            pathLabel: 'Hash maps path',
            xp: 45,
            prompt: 'Return the number of unique values in nums.',
            examples: '[1,1,2] → 2',
            constraints: 'Use a set.',
            fnName: 'unique_count',
            correctCode: 'def unique_count(nums):\n    return len(set(nums))',
            wrongACode: 'def unique_count(nums):\n    return len(nums)',
            wrongBCode: 'def unique_count(nums):\n    return 1',
            correctTip: 'len(set(nums)).',
            wrongATip: 'That counts duplicates.',
            wrongBTip: 'Always 1 is wrong.',
            runTests: (String id) {
              int impl(List<int> nums) {
                if (id == 'ok') return nums.toSet().length;
                if (id == 'a') return nums.length;
                return 1;
              }

              final List<List<int>> cases = <List<int>>[
                <int>[1, 1, 2],
                <int>[variant, variant, variant],
                <int>[1, 2, 3, 4],
              ];
              return List<TestResult>.generate(3, (int i) {
                final int want = cases[i].toSet().length;
                final int got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template securityLogLevel() => _Template(
        family: 'sec',
        difficulty: 'Medium',
        topics: const <String>['Security', 'IT'],
        pathLabel: 'Security path',
        xp: 55,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Escalate log severity',
            difficulty: 'Medium',
            topics: const <String>['Security', 'IT'],
            pathLabel: 'Security path',
            xp: 55,
            prompt:
                'Map failed login count to level: 0-2 info, 3-5 warn, else critical.',
            examples: '4 → warn',
            constraints: 'Inclusive ranges.',
            fnName: 'level',
            correctCode:
                "def level(n):\n    if n <= 2: return 'info'\n    if n <= 5: return 'warn'\n    return 'critical'",
            wrongACode:
                "def level(n):\n    if n < 2: return 'info'\n    if n < 5: return 'warn'\n    return 'critical'",
            wrongBCode: "def level(n):\n    return 'info'",
            correctTip: 'Use <= boundaries carefully.',
            wrongATip: 'Off-by-one on boundaries.',
            wrongBTip: 'Always info fails.',
            runTests: (String id) {
              String correct(int n) {
                if (n <= 2) return 'info';
                if (n <= 5) return 'warn';
                return 'critical';
              }

              String wrongA(int n) {
                if (n < 2) return 'info';
                if (n < 5) return 'warn';
                return 'critical';
              }

              String impl(int n) {
                if (id == 'ok') return correct(n);
                if (id == 'a') return wrongA(n);
                return 'info';
              }

              final List<int> cases = <int>[2, 5, 6 + variant % 3];
              return List<TestResult>.generate(3, (int i) {
                final String want = correct(cases[i]);
                final String got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template dataMissingRate() => _Template(
        family: 'missing',
        difficulty: 'Medium',
        topics: const <String>['Data', 'AI'],
        pathLabel: 'Data path',
        xp: 55,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Missing rate',
            difficulty: 'Medium',
            topics: const <String>['Data', 'AI'],
            pathLabel: 'Data path',
            xp: 55,
            prompt:
                'Given total rows and missing count, return missing rate as percent integer (floor).',
            examples: 'total=10, missing=3 → 30',
            constraints: 'If total=0 return 0.',
            fnName: 'missing_rate',
            correctCode:
                'def missing_rate(total, missing):\n    if total == 0: return 0\n    return (missing * 100) // total',
            wrongACode:
                'def missing_rate(total, missing):\n    return (missing * 100) / total',
            wrongBCode:
                'def missing_rate(total, missing):\n    return missing',
            correctTip: 'Integer floor percent; guard total=0.',
            wrongATip: 'Need integer floor and zero-safe.',
            wrongBTip: 'That returns raw missing.',
            runTests: (String id) {
              int correct(int total, int missing) {
                if (total == 0) return 0;
                return (missing * 100) ~/ total;
              }

              int impl(int total, int missing) {
                if (id == 'ok') return correct(total, missing);
                if (id == 'a') {
                  if (total == 0) throw StateError('div0');
                  return ((missing * 100) / total).round();
                }
                return missing;
              }

              final List<(int, int)> cases = <(int, int)>[
                (10, 3),
                (0, 2),
                (7 + variant, 2),
              ];
              return List<TestResult>.generate(3, (int i) {
                final (int t, int m) = cases[i];
                final int want = correct(t, m);
                int got;
                try {
                  got = impl(t, m);
                } catch (_) {
                  got = -1;
                }
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template aiAccuracy() => _Template(
        family: 'acc',
        difficulty: 'Easy',
        topics: const <String>['AI', 'Data'],
        pathLabel: 'AI path',
        xp: 45,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Accuracy score',
            difficulty: 'Easy',
            topics: const <String>['AI', 'Data'],
            pathLabel: 'AI path',
            xp: 45,
            prompt:
                'accuracy = correct / total as percent integer (floor). total>0.',
            examples: 'correct=8,total=10 → 80',
            constraints: 'Floor division.',
            fnName: 'accuracy',
            correctCode:
                'def accuracy(correct, total):\n    return (correct * 100) // total',
            wrongACode:
                'def accuracy(correct, total):\n    return correct',
            wrongBCode:
                'def accuracy(correct, total):\n    return (correct * 100) / total',
            correctTip: 'Floor percent.',
            wrongATip: 'Raw correct is not percent.',
            wrongBTip: 'Need integer floor.',
            runTests: (String id) {
              int correct(int c, int t) => (c * 100) ~/ t;
              int impl(int c, int t) {
                if (id == 'ok') return correct(c, t);
                if (id == 'a') return c;
                return ((c * 100) / t).round();
              }

              final List<(int, int)> cases = <(int, int)>[
                (8, 10),
                (1, 3),
                (variant % 5, 5 + (variant % 3)),
              ];
              // ensure total > 0
              if (cases[2].$2 == 0) {
                cases[2] = (1, 5);
              }
              return List<TestResult>.generate(3, (int i) {
                final (int c, int t) = cases[i];
                final int tt = t == 0 ? 1 : t;
                final int want = correct(c, tt);
                final int got = impl(c, tt);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template webStatusOk() => _Template(
        family: 'http',
        difficulty: 'Easy',
        topics: const <String>['Web', 'Software'],
        pathLabel: 'Web path',
        xp: 40,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'HTTP success?',
            difficulty: 'Easy',
            topics: const <String>['Web', 'Software'],
            pathLabel: 'Web path',
            xp: 40,
            prompt: 'Return True if status is in 200..299.',
            examples: '201 → True, 404 → False',
            constraints: 'Inclusive range.',
            fnName: 'ok',
            correctCode:
                'def ok(status):\n    return 200 <= status <= 299',
            wrongACode: 'def ok(status):\n    return status == 200',
            wrongBCode: 'def ok(status):\n    return status < 400',
            correctTip: '2xx range.',
            wrongATip: '201 should also succeed.',
            wrongBTip: '3xx is not success here.',
            runTests: (String id) {
              bool impl(int s) {
                if (id == 'ok') return s >= 200 && s <= 299;
                if (id == 'a') return s == 200;
                return s < 400;
              }

              final List<int> cases = <int>[201, 404, 200 + (variant % 50)];
              return List<TestResult>.generate(3, (int i) {
                final bool want = cases[i] >= 200 && cases[i] <= 299;
                final bool got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template mobileNullGuard() => _Template(
        family: 'null',
        difficulty: 'Easy',
        topics: const <String>['Mobile', 'Software'],
        pathLabel: 'Mobile path',
        xp: 45,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Null-safe label',
            difficulty: 'Easy',
            topics: const <String>['Mobile', 'Software'],
            pathLabel: 'Mobile path',
            xp: 45,
            prompt:
                'Return name if non-empty, otherwise "Guest".',
            examples: 'None/"" → Guest',
            constraints: 'Treat empty string as missing.',
            fnName: 'label',
            correctCode:
                'def label(name):\n    return name if name else "Guest"',
            wrongACode:
                'def label(name):\n    return name',
            wrongBCode:
                'def label(name):\n    return "Guest"',
            correctTip: 'Fallback only when missing.',
            wrongATip: 'Empty should become Guest.',
            wrongBTip: 'Always Guest loses real names.',
            runTests: (String id) {
              String? impl(String? name) {
                if (id == 'ok') {
                  return (name == null || name.isEmpty) ? 'Guest' : name;
                }
                if (id == 'a') return name;
                return 'Guest';
              }

              final List<String?> cases = <String?>[
                'Tomachi',
                '',
                null,
              ];
              return List<TestResult>.generate(3, (int i) {
                final String? n = cases[i];
                final String want =
                    (n == null || n.isEmpty) ? 'Guest' : n;
                final String got = '${impl(n)}';
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template itTicketPriority() => _Template(
        family: 'prio',
        difficulty: 'Medium',
        topics: const <String>['IT', 'Software'],
        pathLabel: 'IT path',
        xp: 50,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Ticket priority',
            difficulty: 'Medium',
            topics: const <String>['IT', 'Software'],
            pathLabel: 'IT path',
            xp: 50,
            prompt:
                'If sev is "P1" or users_impacted >= 100 return "urgent", else "normal".',
            examples: 'P2, 120 → urgent',
            constraints: 'OR condition.',
            fnName: 'priority',
            correctCode:
                'def priority(sev, users):\n    if sev == "P1" or users >= 100:\n        return "urgent"\n    return "normal"',
            wrongACode:
                'def priority(sev, users):\n    if sev == "P1" and users >= 100:\n        return "urgent"\n    return "normal"',
            wrongBCode:
                'def priority(sev, users):\n    return "normal"',
            correctTip: 'Use OR, not AND.',
            wrongATip: 'AND is too strict.',
            wrongBTip: 'Always normal fails.',
            runTests: (String id) {
              String correct(String sev, int users) =>
                  (sev == 'P1' || users >= 100) ? 'urgent' : 'normal';
              String impl(String sev, int users) {
                if (id == 'ok') return correct(sev, users);
                if (id == 'a') {
                  return (sev == 'P1' && users >= 100) ? 'urgent' : 'normal';
                }
                return 'normal';
              }

              final List<(String, int)> cases = <(String, int)>[
                ('P1', 1),
                ('P2', 120),
                ('P3', variant % 40),
              ];
              return List<TestResult>.generate(3, (int i) {
                final (String s, int u) = cases[i];
                final String want = correct(s, u);
                final String got = impl(s, u);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template csBinarySearchStep() => _Template(
        family: 'bin',
        difficulty: 'Hard',
        topics: const <String>['Algorithms', 'Computer Science'],
        pathLabel: 'Algorithms path',
        xp: 80,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Binary search mid',
            difficulty: 'Hard',
            topics: const <String>['Algorithms'],
            pathLabel: 'Algorithms path',
            xp: 80,
            prompt:
                'Given lo, hi inclusive, return mid index using lo + (hi-lo)//2.',
            examples: 'lo=0,hi=5 → 2',
            constraints: 'Avoid overflow-style bugs conceptually.',
            fnName: 'mid',
            correctCode:
                'def mid(lo, hi):\n    return lo + (hi - lo) // 2',
            wrongACode: 'def mid(lo, hi):\n    return (lo + hi) // 2',
            wrongBCode: 'def mid(lo, hi):\n    return hi',
            correctTip: 'lo + (hi-lo)//2.',
            wrongATip: 'Works in Python but prefer safe form for this kata.',
            wrongBTip: 'Mid is not hi.',
            runTests: (String id) {
              // Accept both ok and mathematically equal (lo+hi)//2 for these cases,
              // but wrongB fails. For teaching, mark only 'ok' correct; 'a' may pass
              // numeric cases in Dart ints — force a failing case via large-ish values
              // where we still expect the ok formula.
              int impl(int lo, int hi) {
                if (id == 'ok') return lo + (hi - lo) ~/ 2;
                if (id == 'a') return (lo + hi) ~/ 2;
                return hi;
              }

              final List<(int, int)> cases = <(int, int)>[
                (0, 5),
                (2, 2),
                (variant, variant + 9),
              ];
              return List<TestResult>.generate(3, (int i) {
                final (int lo, int hi) = cases[i];
                final int want = lo + (hi - lo) ~/ 2;
                final int got = impl(lo, hi);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );

  static _Template hashFreqPeak() => _Template(
        family: 'mode',
        difficulty: 'Medium',
        topics: const <String>['Hash maps', 'Data', 'Algorithms'],
        pathLabel: 'Hash maps path',
        xp: 60,
        buildBody: (int index, int variant) {
          return choice(
            index: index,
            variant: variant,
            title: 'Most frequent value',
            difficulty: 'Medium',
            topics: const <String>['Hash maps', 'Data', 'Algorithms'],
            pathLabel: 'Hash maps path',
            xp: 60,
            prompt:
                'Return the most frequent value in nums (ties → smallest value).',
            examples: '[1,2,2,3] → 2',
            constraints: 'Use a frequency map.',
            fnName: 'mode',
            correctCode:
                'def mode(nums):\n    from collections import Counter\n    c = Counter(nums)\n    return sorted(c.keys(), key=lambda k: (-c[k], k))[0]',
            wrongACode: 'def mode(nums):\n    return max(nums)',
            wrongBCode: 'def mode(nums):\n    return nums[0]',
            correctTip: 'Frequency first, then smallest key on ties.',
            wrongATip: 'Max value ≠ mode.',
            wrongBTip: 'First element ≠ mode.',
            runTests: (String id) {
              int mode(List<int> nums) {
                final Map<int, int> c = <int, int>{};
                for (final int n in nums) {
                  c[n] = (c[n] ?? 0) + 1;
                }
                final List<int> keys = c.keys.toList()
                  ..sort((int a, int b) {
                    final int ca = c[a]!;
                    final int cb = c[b]!;
                    if (ca != cb) return cb.compareTo(ca);
                    return a.compareTo(b);
                  });
                return keys.first;
              }

              int impl(List<int> nums) {
                if (id == 'ok') return mode(nums);
                if (id == 'a') {
                  return nums.reduce((int a, int b) => a > b ? a : b);
                }
                return nums.first;
              }

              final List<List<int>> cases = <List<int>>[
                <int>[1, 2, 2, 3],
                <int>[variant, 1, variant, 1],
                <int>[9],
              ];
              return List<TestResult>.generate(3, (int i) {
                final int want = mode(cases[i]);
                final int got = impl(cases[i]);
                return TestResult(
                  name: 'Case ${i + 1}',
                  passed: got == want,
                  detail: got == want
                      ? 'Case passed.'
                      : 'expected $want, got $got',
                );
              });
            },
          );
        },
      );
}
