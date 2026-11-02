import 'package:flutter/material.dart';

import 'health_career_progress.dart';
import 'health_career_theme.dart';

enum _NutStep { diary, patterns, build, score, done }

class _Food {
  const _Food({
    required this.id,
    required this.label,
    required this.fiberG,
    required this.proteinG,
    required this.sodiumMg,
    required this.slotHint,
  });

  final String id;
  final String label;
  final double fiberG;
  final double proteinG;
  final int sodiumMg;
  final String slotHint;
}

/// Educational nutrition clinic — fictional patient meal planning (not Rx).
class NutritionClinicScreen extends StatefulWidget {
  const NutritionClinicScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  @override
  State<NutritionClinicScreen> createState() => _NutritionClinicScreenState();
}

class _NutritionClinicScreenState extends State<NutritionClinicScreen> {
  static const String _scenarioId = 'nutrition_clinic_v1';

  static const List<String> _diary = <String>[
    'Breakfast skipped (coffee only)',
    'Lunch: deli turkey sandwich + chips (≈1,100 mg sodium)',
    'Snack: energy drink',
    'Dinner: frozen pizza + soda (low fiber, high sodium)',
    'Evening: ice cream',
  ];

  static const List<_Pattern> _patterns = <_Pattern>[
    _Pattern(id: 'high_sodium', label: 'High sodium pattern'),
    _Pattern(id: 'low_fiber', label: 'Low fiber pattern'),
    _Pattern(id: 'skip_bfast', label: 'Skipped breakfast'),
    _Pattern(id: 'low_protein', label: 'Chronically low protein (trap)'),
    _Pattern(id: 'dehydration', label: 'Severe dehydration risk (trap)'),
  ];

  static const Set<String> _correctPatterns = <String>{
    'high_sodium',
    'low_fiber',
    'skip_bfast',
  };

  static const List<_Food> _catalog = <_Food>[
    _Food(
      id: 'oats',
      label: 'Oatmeal + berries',
      fiberG: 6,
      proteinG: 8,
      sodiumMg: 80,
      slotHint: 'breakfast',
    ),
    _Food(
      id: 'eggs',
      label: 'Eggs + spinach',
      fiberG: 2,
      proteinG: 14,
      sodiumMg: 220,
      slotHint: 'breakfast',
    ),
    _Food(
      id: 'yogurt',
      label: 'Greek yogurt + fruit',
      fiberG: 2,
      proteinG: 15,
      sodiumMg: 70,
      slotHint: 'breakfast',
    ),
    _Food(
      id: 'salad',
      label: 'Bean & greens salad',
      fiberG: 10,
      proteinG: 12,
      sodiumMg: 280,
      slotHint: 'lunch',
    ),
    _Food(
      id: 'chicken_rice',
      label: 'Grilled chicken + brown rice',
      fiberG: 4,
      proteinG: 28,
      sodiumMg: 320,
      slotHint: 'lunch',
    ),
    _Food(
      id: 'soup',
      label: 'Canned cream soup (high Na)',
      fiberG: 2,
      proteinG: 6,
      sodiumMg: 980,
      slotHint: 'lunch',
    ),
    _Food(
      id: 'salmon',
      label: 'Baked salmon + broccoli',
      fiberG: 5,
      proteinG: 30,
      sodiumMg: 210,
      slotHint: 'dinner',
    ),
    _Food(
      id: 'stirfry',
      label: 'Tofu veggie stir-fry',
      fiberG: 7,
      proteinG: 18,
      sodiumMg: 400,
      slotHint: 'dinner',
    ),
    _Food(
      id: 'frozen_pizza',
      label: 'Frozen pizza slice meal',
      fiberG: 2,
      proteinG: 12,
      sodiumMg: 1100,
      slotHint: 'dinner',
    ),
    _Food(
      id: 'chips',
      label: 'Potato chips side',
      fiberG: 1,
      proteinG: 2,
      sodiumMg: 450,
      slotHint: 'any',
    ),
    _Food(
      id: 'apple',
      label: 'Fresh apple',
      fiberG: 4,
      proteinG: 0,
      sodiumMg: 2,
      slotHint: 'any',
    ),
    _Food(
      id: 'water',
      label: 'Water (2 cups)',
      fiberG: 0,
      proteinG: 0,
      sodiumMg: 0,
      slotHint: 'any',
    ),
  ];

  // Educational day targets (labeled as such — not medical prescription).
  static const double _fiberTarget = 25;
  static const double _proteinTarget = 60;
  static const int _sodiumCap = 2300;

  _NutStep _step = _NutStep.diary;
  final Set<String> _markedPatterns = <String>{};
  final Set<String> _breakfast = <String>{};
  final Set<String> _lunch = <String>{};
  final Set<String> _dinner = <String>{};
  int? _score;
  List<String> _feedback = <String>[];
  bool _submitting = false;

  _Food _food(String id) => _catalog.firstWhere((_Food f) => f.id == id);

  ({double fiber, double protein, int sodium}) _totals() {
    double fiber = 0;
    double protein = 0;
    int sodium = 0;
    for (final String id in <String>{
      ..._breakfast,
      ..._lunch,
      ..._dinner,
    }) {
      final _Food f = _food(id);
      fiber += f.fiberG;
      protein += f.proteinG;
      sodium += f.sodiumMg;
    }
    return (fiber: fiber, protein: protein, sodium: sodium);
  }

  Future<void> _scorePlan() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final List<String> fb = <String>[];
    int score = 15;

    final int patternHits =
        _markedPatterns.intersection(_correctPatterns).length;
    final int patternTraps = _markedPatterns
        .difference(_correctPatterns)
        .length;
    score += patternHits * 12;
    score -= patternTraps * 8;
    fb.add(
      'Patterns: $patternHits/3 correct'
      '${patternTraps > 0 ? ", $patternTraps trap(s)" : ""}.',
    );

    if (_breakfast.isEmpty) {
      score -= 10;
      fb.add('Breakfast still empty — address the skip pattern.');
    } else {
      score += 8;
      fb.add('Breakfast slot filled.');
    }
    if (_lunch.isEmpty || _dinner.isEmpty) {
      score -= 8;
      fb.add('Fill lunch and dinner slots.');
    }

    final totals = _totals();
    if (totals.fiber >= _fiberTarget) {
      score += 15;
      fb.add('Fiber ≥ ${_fiberTarget.toInt()} g educational target.');
    } else if (totals.fiber >= 18) {
      score += 8;
      fb.add('Fiber improving (${totals.fiber.toStringAsFixed(0)} g) but below 25 g target.');
    } else {
      fb.add('Fiber low (${totals.fiber.toStringAsFixed(0)} g) — add beans/veg/fruit.');
    }

    if (totals.protein >= _proteinTarget) {
      score += 12;
      fb.add('Protein ≥ ${_proteinTarget.toInt()} g educational target.');
    } else if (totals.protein >= 45) {
      score += 6;
      fb.add('Protein moderate (${totals.protein.toStringAsFixed(0)} g).');
    } else {
      fb.add('Protein below educational target (${totals.protein.toStringAsFixed(0)} g).');
    }

    if (totals.sodium <= _sodiumCap) {
      score += 15;
      fb.add('Sodium under $_sodiumCap mg educational day cap.');
    } else if (totals.sodium <= 2800) {
      score += 5;
      fb.add('Sodium elevated (${totals.sodium} mg) — trim packaged foods.');
    } else {
      score -= 8;
      fb.add('Sodium well over cap (${totals.sodium} mg).');
    }

    if (_lunch.contains('soup') || _dinner.contains('frozen_pizza')) {
      score -= 6;
      fb.add('High-sodium convenience items still in the plan.');
    }

    score = score.clamp(0, 100);
    await widget.progress.completeScenario(
      _scenarioId,
      score: score,
      xpGain: 80 + (score ~/ 4),
    );
    await widget.progress.completeSkill('nutrition_meal_plan', xpGain: 25);

    if (!mounted) return;
    setState(() {
      _score = score;
      _feedback = fb;
      _step = _NutStep.score;
      _submitting = false;
    });
  }

  void _toggleSlot(Set<String> slot, String id) {
    setState(() {
      if (slot.contains(id)) {
        slot.remove(id);
      } else if (slot.length < 3) {
        slot.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'Nutrition Clinic',
        icon: Icons.restaurant_rounded,
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              _NutDots(step: _step),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey<_NutStep>(_step),
                    child: _body(),
                  ),
                ),
              ),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case _NutStep.diary:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: MedCosmic.panelBox(),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Patient: Avery Kim (fictional), 41',
                    style: TextStyle(
                      color: MedCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Educational food diary interview — not medical nutrition therapy.',
                    style: TextStyle(color: MedCosmic.mute, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Yesterday\'s meals',
              style: TextStyle(
                color: MedCosmic.mute,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ..._diary.map(
              (String line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: MedCosmic.panelBox(),
                  child: Text(
                    line,
                    style: const TextStyle(
                      color: MedCosmic.ink,
                      height: 1.35,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case _NutStep.patterns:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            const Text(
              'Identify dietary patterns',
              style: TextStyle(
                color: MedCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select all that the diary supports.',
              style: TextStyle(color: MedCosmic.mute, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ..._patterns.map((_Pattern p) {
              final bool on = _markedPatterns.contains(p.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ToggleTile(
                  selected: on,
                  title: p.label,
                  onTap: () {
                    setState(() {
                      if (on) {
                        _markedPatterns.remove(p.id);
                      } else {
                        _markedPatterns.add(p.id);
                      }
                    });
                  },
                ),
              );
            }),
          ],
        );
      case _NutStep.build:
        final totals = _totals();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
              child: Text(
                'Educational targets: fiber ≥${_fiberTarget.toInt()} g · '
                'protein ≥${_proteinTarget.toInt()} g · sodium ≤$_sodiumCap mg\n'
                'Current: fiber ${totals.fiber.toStringAsFixed(0)} · '
                'protein ${totals.protein.toStringAsFixed(0)} · '
                'sodium ${totals.sodium} mg',
                style: const TextStyle(
                  color: MedCosmic.mute,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _MealSlot(
              title: 'Breakfast (max 3)',
              selected: _breakfast,
              catalog: _catalog,
              onToggle: (String id) => _toggleSlot(_breakfast, id),
            ),
            _MealSlot(
              title: 'Lunch (max 3)',
              selected: _lunch,
              catalog: _catalog,
              onToggle: (String id) => _toggleSlot(_lunch, id),
            ),
            _MealSlot(
              title: 'Dinner (max 3)',
              selected: _dinner,
              catalog: _catalog,
              onToggle: (String id) => _toggleSlot(_dinner, id),
            ),
          ],
        );
      case _NutStep.score:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: MedCosmic.panelBox(),
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.eco_rounded,
                    color: MedCosmic.success,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Educational plan scored',
                    style: TextStyle(
                      color: MedCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Score ${_score ?? 0}/100 · $_scenarioId',
                    style: const TextStyle(color: MedCosmic.mute),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Not a medical prescription — learning exercise only.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: MedCosmic.warning, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ..._feedback.map(
              (String line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
                  child: Text(
                    line,
                    style: const TextStyle(
                      color: MedCosmic.mute,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case _NutStep.done:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: MedCosmic.panelBox(),
              child: const Text(
                'Clinic session complete. Return to the hub to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: MedCosmic.mute, height: 1.4),
              ),
            ),
          ],
        );
    }
  }

  Widget _footer() {
    if (_step == _NutStep.done) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: FilledButton.styleFrom(
              backgroundColor: MedCosmic.clinical,
              foregroundColor: MedCosmic.bgDeep,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Return to hub'),
          ),
        ),
      );
    }

    if (_step == _NutStep.score) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => setState(() => _step = _NutStep.done),
            style: FilledButton.styleFrom(
              backgroundColor: MedCosmic.purple,
              foregroundColor: MedCosmic.ink,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Finish'),
          ),
        ),
      );
    }

    final bool canNext = switch (_step) {
      _NutStep.diary => true,
      _NutStep.patterns => _markedPatterns.length >= 2,
      _NutStep.build =>
        _breakfast.isNotEmpty &&
            _lunch.isNotEmpty &&
            _dinner.isNotEmpty &&
            !_submitting,
      _NutStep.score => true,
      _NutStep.done => false,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: <Widget>[
          if (_step != _NutStep.diary)
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _step = _NutStep.values[_step.index - 1];
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: MedCosmic.mute,
                side: const BorderSide(color: MedCosmic.stroke),
              ),
              child: const Text('Back'),
            ),
          if (_step != _NutStep.diary) const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: !canNext
                  ? null
                  : () {
                      if (_step == _NutStep.build) {
                        _scorePlan();
                        return;
                      }
                      setState(() {
                        _step = _NutStep.values[_step.index + 1];
                      });
                    },
              style: FilledButton.styleFrom(
                backgroundColor: MedCosmic.purple,
                foregroundColor: MedCosmic.ink,
                disabledBackgroundColor: MedCosmic.panelAlt,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _submitting
                    ? 'Scoring…'
                    : _step == _NutStep.build
                        ? 'Score meal plan'
                        : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pattern {
  const _Pattern({required this.id, required this.label});

  final String id;
  final String label;
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.selected,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? MedCosmic.success.withValues(alpha: 0.16)
                : MedCosmic.panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? MedCosmic.success : MedCosmic.stroke,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: selected ? MedCosmic.success : MedCosmic.mute,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: MedCosmic.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealSlot extends StatelessWidget {
  const _MealSlot({
    required this.title,
    required this.selected,
    required this.catalog,
    required this.onToggle,
  });

  final String title;
  final Set<String> selected;
  final List<_Food> catalog;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: MedCosmic.ink,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: catalog.map((_Food f) {
              final bool on = selected.contains(f.id);
              return FilterChip(
                selected: on,
                label: Text(
                  f.label,
                  style: TextStyle(
                    color: on ? MedCosmic.ink : MedCosmic.mute,
                    fontSize: 12,
                  ),
                ),
                onSelected: (_) => onToggle(f.id),
                selectedColor: MedCosmic.purple.withValues(alpha: 0.35),
                backgroundColor: MedCosmic.panel,
                checkmarkColor: MedCosmic.electric,
                side: BorderSide(
                  color: on ? MedCosmic.purple : MedCosmic.stroke,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _NutDots extends StatelessWidget {
  const _NutDots({required this.step});

  final _NutStep step;

  static const List<String> _labels = <String>[
    'Diary',
    'Patterns',
    'Plan',
    'Score',
    'Done',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: List<Widget>.generate(_labels.length, (int i) {
          final bool active = i == step.index;
          final bool done = i < step.index;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: MedCosmic.pill(
              _labels[i],
              bg: active
                  ? MedCosmic.teal.withValues(alpha: 0.28)
                  : done
                      ? MedCosmic.success.withValues(alpha: 0.18)
                      : MedCosmic.panelAlt,
              fg: active
                  ? MedCosmic.teal
                  : done
                      ? MedCosmic.success
                      : MedCosmic.mute,
            ),
          );
        }),
      ),
    );
  }
}
