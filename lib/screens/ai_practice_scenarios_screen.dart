import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/ai_practice_catalog.dart';
import '../models/ai_practice_mode.dart';
import '../models/practice_lab.dart';
import '../services/ai_practice_service.dart';
import '../services/subscription_service.dart';
import '../theme/study_theme.dart';
import '../utils/ai_practice_limits.dart';
import '../screens/membership_screen.dart';
import '../widgets/ai_practice/ai_practice_widgets.dart';
import '../widgets/study_surface.dart';
import 'ai_practice_session_screen.dart';

/// Step 2 — choose a scenario with difficulty filters.
class AiPracticeScenariosScreen extends StatefulWidget {
  const AiPracticeScenariosScreen({super.key, required this.major});

  final PracticeLabCategory major;

  @override
  State<AiPracticeScenariosScreen> createState() => _AiPracticeScenariosScreenState();
}

class _AiPracticeScenariosScreenState extends State<AiPracticeScenariosScreen> {
  PracticeDifficulty? _filter;

  List<PracticeScenarioTemplate> get _allScenarios => <PracticeScenarioTemplate>[
        ...AiPracticeCatalog.scenariosFor(widget.major),
        AiPracticeCatalog.aiGenerated,
      ];

  List<PracticeScenarioTemplate> get _filtered {
    if (_filter == null) return _allScenarios;
    return _allScenarios.where((PracticeScenarioTemplate s) => s.defaultDifficulty == _filter || s.isAiGenerated).toList();
  }

  void _start(PracticeScenarioTemplate scenario) {
    final PracticeDifficulty difficulty = scenario.isAiGenerated
        ? (_filter ?? PracticeDifficulty.intermediate)
        : scenario.defaultDifficulty;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AiPracticeSessionScreen(
          major: widget.major,
          scenario: scenario,
          difficulty: difficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final AiPracticeUsage? usage = context.watch<AiPracticeService>().usage;
    final bool isPremium = context.watch<SubscriptionService>().isPremium;
    final String majorLabel = '${widget.major.emoji} ${widget.major.name}'.trim();

    return Scaffold(
      appBar: AppBar(title: Text(majorLabel)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          const PracticeStepLabel(step: 2, title: 'Choose a Scenario'),
          Text(
            'Select a scenario for $majorLabel. Each includes an AI role, tasks, and difficulty-appropriate grading.',
            style: TextStyle(color: textSecondary, height: 1.4),
          ),
          if (usage != null && !isPremium) ...<Widget>[
            const SizedBox(height: 10),
            StudySurfaceCard(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${usage.remaining} of ${AiPracticeLimits.freeSessionsPerMonth} free sessions left this month',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _FilterChip(
                  label: 'All Levels',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                ...PracticeDifficulty.values.map(
                  (PracticeDifficulty d) => _FilterChip(
                    label: d.label,
                    selected: _filter == d,
                    color: AiPracticeCatalog.difficultyColor(d),
                    onTap: () => setState(() => _filter = d),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._filtered.map(
            (PracticeScenarioTemplate scenario) => ScenarioListCard(
              scenario: scenario,
              onStart: () => _start(scenario),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _start(AiPracticeCatalog.aiGenerated),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Custom Scenario'),
          ),
          if (usage?.isAtLimit == true) ...<Widget>[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
              ),
              child: const Text('Upgrade for unlimited practice'),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color active = color ?? StudyColors.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: active.withValues(alpha: 0.18),
        checkmarkColor: active,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? active : StudyColors.textSecondary(Theme.of(context).brightness),
          fontSize: 12,
        ),
      ),
    );
  }
}
