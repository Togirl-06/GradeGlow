import 'dart:math';

import '../models/ai_practice_mode.dart';

/// Punnett square genetics problems by difficulty.
class PunnettSquareData {
  PunnettSquareData._();

  static List<PunnettProblem> deckFor(PracticeDifficulty difficulty, String seed) {
    final List<PunnettProblem> pool = switch (difficulty) {
      PracticeDifficulty.beginner => _beginner,
      PracticeDifficulty.intermediate => _intermediate,
      PracticeDifficulty.advanced => _advanced,
    };
    final List<PunnettProblem> deck = List<PunnettProblem>.from(pool);
    deck.shuffle(Random(seed.hashCode));
    return deck.take(difficulty == PracticeDifficulty.beginner ? 4 : difficulty == PracticeDifficulty.intermediate ? 5 : 6).toList();
  }
}

class PunnettProblem {
  const PunnettProblem({
    required this.prompt,
    required this.parent1,
    required this.parent2,
    required this.answers,
    required this.correctIndex,
    required this.explanation,
  });

  final String prompt;
  final String parent1;
  final String parent2;
  final List<String> answers;
  final int correctIndex;
  final String explanation;
}

const List<PunnettProblem> _beginner = <PunnettProblem>[
  PunnettProblem(
    prompt: 'Cross two heterozygous tall pea plants (Tt × Tt). What fraction are tall?',
    parent1: 'Tt',
    parent2: 'Tt',
    answers: <String>['3/4 tall', '1/2 tall', '1/4 tall', 'All short'],
    correctIndex: 0,
    explanation: 'Tt × Tt gives TT, Tt, Tt, tt — three tall to one short.',
  ),
  PunnettProblem(
    prompt: 'Cross Tt × tt. What fraction show the recessive phenotype?',
    parent1: 'Tt',
    parent2: 'tt',
    answers: <String>['1/4', '1/2', '3/4', 'None'],
    correctIndex: 1,
    explanation: 'Half the offspring are tt (recessive).',
  ),
  PunnettProblem(
    prompt: 'Cross TT × tt. What are all offspring genotypes?',
    parent1: 'TT',
    parent2: 'tt',
    answers: <String>['All Tt', 'Half TT', 'Half tt', '1/4 TT'],
    correctIndex: 0,
    explanation: 'Every gamete combination gives Tt.',
  ),
];

const List<PunnettProblem> _intermediate = <PunnettProblem>[
  PunnettProblem(
    prompt: 'In guinea pigs, B = black, b = white. Cross Bb × Bb. P(black)?',
    parent1: 'Bb',
    parent2: 'Bb',
    answers: <String>['75%', '50%', '25%', '100% white'],
    correctIndex: 0,
    explanation: 'BB, Bb, Bb, bb → 3/4 black phenotype.',
  ),
  PunnettProblem(
    prompt: 'Cross Aa × AA. What fraction are heterozygous?',
    parent1: 'Aa',
    parent2: 'AA',
    answers: <String>['1/2', '1/4', '3/4', 'All homozygous'],
    correctIndex: 0,
    explanation: 'AA and Aa each appear twice in four cells.',
  ),
  PunnettProblem(
    prompt: 'Cross two heterozygotes for cystic fibrosis (Ff × Ff). Carrier fraction?',
    parent1: 'Ff',
    parent2: 'Ff',
    answers: <String>['1/2', '1/4', '3/4', '1/3'],
    correctIndex: 0,
    explanation: 'FF, Ff, Ff, ff — two carriers of four.',
  ),
];

const List<PunnettProblem> _advanced = <PunnettProblem>[
  PunnettProblem(
    prompt: 'Dihybrid: RrYy × RrYy. Expected ratio of R_Y_ phenotype?',
    parent1: 'RrYy',
    parent2: 'RrYy',
    answers: <String>['9/16', '3/16', '1/16', '4/16'],
    correctIndex: 0,
    explanation: 'Classic 9:3:3:1 — both dominant traits.',
  ),
  PunnettProblem(
    prompt: 'Cross AaBb × Aabb. Probability of Aabb?',
    parent1: 'AaBb',
    parent2: 'Aabb',
    answers: <String>['1/4', '1/2', '1/8', '3/8'],
    correctIndex: 0,
    explanation: '1/2 Aa × 1/2 ab from gametes → 1/4 Aabb.',
  ),
];

/// Visual 2×2 Punnett grid from parent gametes.
class PunnettGrid {
  PunnettGrid({required String parent1, required String parent2}) {
    final List<String> g1 = _gametes(parent1);
    final List<String> g2 = _gametes(parent2);
    cells = <List<String>>[
      <String>[g1[0] + g2[0], g1[0] + g2[1]],
      <String>[g1[1] + g2[0], g1[1] + g2[1]],
    ];
    rowLabels = g1;
    colLabels = g2;
  }

  late final List<List<String>> cells;
  late final List<String> rowLabels;
  late final List<String> colLabels;

  static List<String> _gametes(String genotype) {
    if (genotype.length == 2) {
      return <String>[genotype[0], genotype[1]];
    }
    if (genotype.length == 4) {
      return <String>['${genotype[0]}${genotype[2]}', '${genotype[1]}${genotype[3]}'];
    }
    return <String>['?', '?'];
  }
}
