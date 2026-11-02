/// Step-by-step algorithm visualization data for CS learning.
class AlgorithmVisualizerStep {
  const AlgorithmVisualizerStep({
    required this.title,
    required this.description,
    required this.array,
    this.leftIndex,
    this.midIndex,
    this.rightIndex,
    this.visited = const <int>[],
    this.sorted = const <int>[],
    this.highlights = const <String>[],
  });

  final String title;
  final String description;
  final List<int> array;
  final int? leftIndex;
  final int? midIndex;
  final int? rightIndex;
  final List<int> visited;
  final List<int> sorted;
  final List<String> highlights;
}

class AlgorithmVisualizerLesson {
  const AlgorithmVisualizerLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.topicTags,
    required this.initialArray,
    required this.steps,
    this.timeComplexity,
    this.spaceComplexity,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<String> topicTags;
  final List<int> initialArray;
  final List<AlgorithmVisualizerStep> steps;
  final String? timeComplexity;
  final String? spaceComplexity;
}

class AlgorithmVisualizerCatalog {
  AlgorithmVisualizerCatalog._();

  static const List<AlgorithmVisualizerLesson> lessons = <AlgorithmVisualizerLesson>[
    binarySearch,
    mergeSort,
    bfs,
    dfs,
  ];

  static AlgorithmVisualizerLesson? byId(String id) {
    for (final AlgorithmVisualizerLesson l in lessons) {
      if (l.id == id) return l;
    }
    return null;
  }

  static const AlgorithmVisualizerLesson binarySearch = AlgorithmVisualizerLesson(
    id: 'binary_search',
    title: 'Binary Search',
    subtitle: 'Divide the sorted array in half each step.',
    topicTags: <String>['Arrays', 'Search', 'O(log n)'],
    initialArray: <int>[2, 5, 8, 10, 15, 20],
    timeComplexity: 'O(log n) time',
    spaceComplexity: 'O(1) space',
    steps: <AlgorithmVisualizerStep>[
      AlgorithmVisualizerStep(
        title: 'Setup',
        description: 'Target = 10. Set left = 0, right = 5 on a sorted array.',
        array: <int>[2, 5, 8, 10, 15, 20],
        leftIndex: 0,
        rightIndex: 5,
        highlights: <String>['left pointer', 'right pointer'],
      ),
      AlgorithmVisualizerStep(
        title: 'Find middle',
        description: 'mid = (left + right) // 2 → index 2, value 8. 8 < 10, search right half.',
        array: <int>[2, 5, 8, 10, 15, 20],
        leftIndex: 0,
        midIndex: 2,
        rightIndex: 5,
        visited: <int>[2],
        highlights: <String>['mid pointer', 'discard left of mid'],
      ),
      AlgorithmVisualizerStep(
        title: 'Move left',
        description: 'left = mid + 1 → index 3. mid = 4, value 15. 15 > 10, search left.',
        array: <int>[2, 5, 8, 10, 15, 20],
        leftIndex: 3,
        midIndex: 4,
        rightIndex: 5,
        visited: <int>[2, 4],
        highlights: <String>['shrink search space'],
      ),
      AlgorithmVisualizerStep(
        title: 'Found',
        description: 'left = 3, right = 3, mid = 3, value 10. Target found at index 3.',
        array: <int>[2, 5, 8, 10, 15, 20],
        leftIndex: 3,
        midIndex: 3,
        rightIndex: 3,
        visited: <int>[2, 4, 3],
        sorted: <int>[3],
        highlights: <String>['match found'],
      ),
    ],
  );

  static const AlgorithmVisualizerLesson mergeSort = AlgorithmVisualizerLesson(
    id: 'merge_sort',
    title: 'Merge Sort',
    subtitle: 'Divide, sort halves, merge sorted subarrays.',
    topicTags: <String>['Sorting', 'Divide & Conquer', 'O(n log n)'],
    initialArray: <int>[38, 27, 43, 3, 9],
    timeComplexity: 'O(n log n) time',
    spaceComplexity: 'O(n) auxiliary space',
    steps: <AlgorithmVisualizerStep>[
      AlgorithmVisualizerStep(
        title: 'Split',
        description: 'Split [38,27,43,3,9] into [38,27] and [43,3,9].',
        array: <int>[38, 27, 43, 3, 9],
        highlights: <String>['divide step'],
      ),
      AlgorithmVisualizerStep(
        title: 'Sort left half',
        description: 'Recursively sort [38,27] → [27,38].',
        array: <int>[27, 38, 43, 3, 9],
        sorted: <int>[0, 1],
        highlights: <String>['left subarray sorted'],
      ),
      AlgorithmVisualizerStep(
        title: 'Sort right half',
        description: 'Sort [43,3,9] → [3,9,43].',
        array: <int>[27, 38, 3, 9, 43],
        sorted: <int>[2, 3, 4],
        highlights: <String>['right subarray sorted'],
      ),
      AlgorithmVisualizerStep(
        title: 'Merge',
        description: 'Merge [27,38] and [3,9,43] by comparing fronts → [3,9,27,38,43].',
        array: <int>[3, 9, 27, 38, 43],
        sorted: <int>[0, 1, 2, 3, 4],
        highlights: <String>['merge step complete'],
      ),
    ],
  );

  static const AlgorithmVisualizerLesson bfs = AlgorithmVisualizerLesson(
    id: 'bfs',
    title: 'Breadth-First Search',
    subtitle: 'Explore neighbors level by level using a queue.',
    topicTags: <String>['Graphs', 'BFS', 'Queue'],
    initialArray: <int>[0, 1, 2, 3, 4],
    timeComplexity: 'O(V + E) time',
    spaceComplexity: 'O(V) space',
    steps: <AlgorithmVisualizerStep>[
      AlgorithmVisualizerStep(
        title: 'Enqueue start',
        description: 'Start at node 0. Queue: [0]. Visited: {0}.',
        array: <int>[0, 1, 2, 3, 4],
        visited: <int>[0],
        highlights: <String>['queue: 0'],
      ),
      AlgorithmVisualizerStep(
        title: 'Level 1',
        description: 'Dequeue 0, enqueue neighbors 1 and 2.',
        array: <int>[0, 1, 2, 3, 4],
        visited: <int>[0, 1, 2],
        highlights: <String>['queue: 1, 2'],
      ),
      AlgorithmVisualizerStep(
        title: 'Level 2',
        description: 'Dequeue 1 → neighbor 3. Dequeue 2 → neighbor 4.',
        array: <int>[0, 1, 2, 3, 4],
        visited: <int>[0, 1, 2, 3, 4],
        highlights: <String>['full graph visited in BFS order'],
      ),
    ],
  );

  static const AlgorithmVisualizerLesson dfs = AlgorithmVisualizerLesson(
    id: 'dfs',
    title: 'Depth-First Search',
    subtitle: 'Go deep along one path before backtracking.',
    topicTags: <String>['Graphs', 'DFS', 'Stack/Recursion'],
    initialArray: <int>[0, 1, 2, 3, 4],
    timeComplexity: 'O(V + E) time',
    spaceComplexity: 'O(V) space',
    steps: <AlgorithmVisualizerStep>[
      AlgorithmVisualizerStep(
        title: 'Visit 0',
        description: 'Start DFS at 0. Push 0 on stack.',
        array: <int>[0, 1, 2, 3, 4],
        visited: <int>[0],
        highlights: <String>['stack: 0'],
      ),
      AlgorithmVisualizerStep(
        title: 'Go deep',
        description: 'From 0 → 1 → 3 before visiting 2.',
        array: <int>[0, 1, 2, 3, 4],
        visited: <int>[0, 1, 3],
        highlights: <String>['depth-first path'],
      ),
      AlgorithmVisualizerStep(
        title: 'Backtrack',
        description: 'Backtrack from 3, visit 2, then 4.',
        array: <int>[0, 1, 2, 3, 4],
        visited: <int>[0, 1, 3, 2, 4],
        highlights: <String>['complete DFS traversal'],
      ),
    ],
  );
}
