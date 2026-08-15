import 'package:flutter/material.dart';

import '../../data/algorithm_visualizer_data.dart';
import '../../theme/leetcode_theme.dart';

/// Step-through algorithm animation — press Next Step to advance.
class AlgorithmVisualizerScreen extends StatefulWidget {
  const AlgorithmVisualizerScreen({super.key, required this.lesson});

  final AlgorithmVisualizerLesson lesson;

  @override
  State<AlgorithmVisualizerScreen> createState() => _AlgorithmVisualizerScreenState();
}

class AlgorithmVisualizerListScreen extends StatelessWidget {
  const AlgorithmVisualizerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LeetCodeTheme.background,
      appBar: AppBar(rrr
        backgroundColor: LeetCodeTheme.surface,
        foregroundColor: LeetCodeTheme.textPrimary,
        title: const Text('Algorithm Visualizer'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AlgorithmVisualizerCatalog.lessons.length,
        itemBuilder: (BuildContext context, int index) {
          final AlgorithmVisualizerLesson lesson = AlgorithmVisualizerCatalog.lessons[index];
          return Card(
            color: LeetCodeTheme.surface,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(lesson.title, style: const TextStyle(color: LeetCodeTheme.textPrimary, fontWeight: FontWeight.w800)),
              subtitle: Text(lesson.subtitle, style: const TextStyle(color: LeetCodeTheme.textSecondary)),
              trailing: const Icon(Icons.play_arrow_rounded, color: LeetCodeTheme.accent),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AlgorithmVisualizerScreen(lesson: lesson),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AlgorithmVisualizerScreenState extends State<AlgorithmVisualizerScreen> {
  int _step = 0;

  AlgorithmVisualizerStep get _current => widget.lesson.steps[_step];

  @override
  Widget build(BuildContext context) {
    final AlgorithmVisualizerStep step = _current;
    return Scaffold(
      backgroundColor: LeetCodeTheme.background,
      appBar: AppBar(
        backgroundColor: LeetCodeTheme.surface,
        foregroundColor: LeetCodeTheme.textPrimary,
        title: Text(widget.lesson.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            step.title,
            style: const TextStyle(color: LeetCodeTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(step.description, style: const TextStyle(color: LeetCodeTheme.textSecondary, height: 1.45)),
          const SizedBox(height: 16),
          _ArrayViz(step: step),
          const SizedBox(height: 12),
          if (step.highlights.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: step.highlights
                  .map(
                    (String h) => Chip(
                      label: Text(h),
                      backgroundColor: LeetCodeTheme.surfaceElevated,
                      labelStyle: const TextStyle(color: LeetCodeTheme.accent, fontSize: 12),
                    ),
                  )
                  .toList(),
            ),
          if (widget.lesson.timeComplexity != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              '${widget.lesson.timeComplexity} · ${widget.lesson.spaceComplexity}',
              style: const TextStyle(color: LeetCodeTheme.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: _step > 0 ? () => setState(() => _step -= 1) : null,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _step < widget.lesson.steps.length - 1
                      ? () => setState(() => _step += 1)
                      : null,
                  child: Text(_step < widget.lesson.steps.length - 1 ? 'Next Step' : 'Complete'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_step + 1} of ${widget.lesson.steps.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ArrayViz extends StatelessWidget {
  const _ArrayViz({required this.step});

  final AlgorithmVisualizerStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LeetCodeTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LeetCodeTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Current state', style: TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (int i = 0; i < step.array.length; i++) _Cell(index: i, value: step.array[i], step: step),
            ],
          ),
          const SizedBox(height: 12),
          if (step.leftIndex != null || step.midIndex != null || step.rightIndex != null)
            Text(
              <String>[
                if (step.leftIndex != null) 'Left → index ${step.leftIndex}',
                if (step.midIndex != null) 'Mid → index ${step.midIndex}',
                if (step.rightIndex != null) 'Right → index ${step.rightIndex}',
              ].join('   '),
              style: const TextStyle(color: LeetCodeTheme.accent, fontSize: 12, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.index, required this.value, required this.step});

  final int index;
  final int value;
  final AlgorithmVisualizerStep step;

  @override
  Widget build(BuildContext context) {
    Color border = LeetCodeTheme.border;
    Color bg = LeetCodeTheme.surfaceElevated;
    if (step.sorted.contains(index)) {
      border = LeetCodeTheme.success;
      bg = LeetCodeTheme.success.withValues(alpha: 0.15);
    } else if (index == step.midIndex) {
      border = LeetCodeTheme.medium;
      bg = LeetCodeTheme.medium.withValues(alpha: 0.15);
    } else if (index == step.leftIndex || index == step.rightIndex) {
      border = LeetCodeTheme.accent;
      bg = LeetCodeTheme.accent.withValues(alpha: 0.12);
    } else if (step.visited.contains(index)) {
      border = LeetCodeTheme.textSecondary;
    }

    return Column(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: 2),
          ),
          child: Text('$value', style: const TextStyle(color: LeetCodeTheme.textPrimary, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 4),
        Text('$index', style: const TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 10)),
      ],
    );
  }
}
