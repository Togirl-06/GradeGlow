import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/coding_languages.dart';
import '../../models/leetcode_problem.dart';
import '../../theme/leetcode_theme.dart';
import 'language_picker.dart';

/// LeetCode-style problem description with examples and constraints.
class LeetcodeProblemPanel extends StatelessWidget {
  const LeetcodeProblemPanel({
    super.key,
    required this.problem,
    required this.problemIndex,
    required this.totalProblems,
    this.acceptanceRate,
  });

  final LeetcodeProblem problem;
  final int problemIndex;
  final int totalProblems;
  final String? acceptanceRate;

  @override
  Widget build(BuildContext context) {
    final Color diffColor = LeetCodeTheme.difficultyColor(problem.difficulty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              problemIndex > 0 ? '$problemIndex. ' : '',
              style: const TextStyle(color: LeetCodeTheme.textSecondary, fontWeight: FontWeight.w700, fontSize: 13),
            ),
            Expanded(
              child: Text(
                problem.title,
                style: const TextStyle(color: LeetCodeTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: diffColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: diffColor.withValues(alpha: 0.5)),
              ),
              child: Text(problem.difficulty, style: TextStyle(color: diffColor, fontWeight: FontWeight.w800, fontSize: 11)),
            ),
            if (problem.isDebug)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: LeetCodeTheme.hard.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: LeetCodeTheme.hard.withValues(alpha: 0.45)),
                ),
                child: const Text('Fix the bug', style: TextStyle(color: LeetCodeTheme.hard, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            if (acceptanceRate != null)
              Text('Acceptance $acceptanceRate', style: const TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 11)),
            Text('$problemIndex / $totalProblems', style: const TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 11)),
            ...problem.tags.map(
              (String tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: LeetCodeTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(tag, style: const TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (problem.isDebug)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: LeetCodeTheme.hard.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: LeetCodeTheme.hard.withValues(alpha: 0.35)),
            ),
            child: const Text(
              'Broken code is loaded in the editor below. Find the bug, fix it, then Run / Submit.',
              style: TextStyle(color: LeetCodeTheme.textPrimary, height: 1.45, fontSize: 13),
            ),
          ),
        Text(problem.description, style: const TextStyle(color: LeetCodeTheme.textPrimary, height: 1.55, fontSize: 14)),
        const SizedBox(height: 16),
        for (int i = 0; i < problem.examples.length; i++) ...<Widget>[
          Text('Example ${i + 1}:', style: const TextStyle(color: LeetCodeTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 6),
          _IoBlock(label: 'Input', value: problem.examples[i].input),
          const SizedBox(height: 4),
          _IoBlock(label: 'Output', value: problem.examples[i].output),
          if (problem.examples[i].explanation != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              'Explanation: ${problem.examples[i].explanation}',
              style: const TextStyle(color: LeetCodeTheme.textSecondary, height: 1.4, fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
        ],
        if (problem.constraints.isNotEmpty) ...<Widget>[
          const Text('Constraints:', style: TextStyle(color: LeetCodeTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 6),
          ...problem.constraints.map(
            (String c) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $c', style: const TextStyle(color: LeetCodeTheme.consoleGreen, fontFamily: 'monospace', fontSize: 12, height: 1.35)),
            ),
          ),
        ],
      ],
    );
  }
}

class _IoBlock extends StatelessWidget {
  const _IoBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: LeetCodeTheme.codeBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: LeetCodeTheme.border),
      ),
      child: SelectableText(
        '$label: $value',
        style: const TextStyle(color: LeetCodeTheme.consoleGreen, fontFamily: 'monospace', fontSize: 12, height: 1.4),
      ),
    );
  }
}

/// Dark code editor with line-number gutter.
class LeetcodeCodeEditor extends StatelessWidget {
  const LeetcodeCodeEditor({
    super.key,
    required this.controller,
    required this.language,
    required this.onChangeLanguage,
    this.enabled = true,
    this.onSubmit,
    this.isDebug = false,
  });

  final TextEditingController controller;
  final CodingLanguage language;
  final ValueChanged<CodingLanguage> onChangeLanguage;
  final bool enabled;
  final VoidCallback? onSubmit;
  final bool isDebug;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: LeetCodeTheme.codeBackground,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: LeetCodeTheme.surfaceElevated,
            child: Row(
              children: <Widget>[
                const Icon(Icons.code_rounded, size: 16, color: LeetCodeTheme.textSecondary),
                const SizedBox(width: 6),
                const Text('Code', style: TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                if (isDebug) ...<Widget>[
                  const SizedBox(width: 8),
                  Text('· fix the bug', style: TextStyle(color: LeetCodeTheme.hard.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w700)),
                ],
                const Spacer(),
                LeetcodeLanguagePickerButton(selected: language, onSelected: onChangeLanguage),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (BuildContext context, TextEditingValue value, Widget? child) {
                    final int lines = '\n'.allMatches(value.text).length + 1;
                    return ClipRect(
                      child: Container(
                        width: 36,
                        padding: const EdgeInsets.only(top: 12, right: 6),
                        color: const Color(0xFF161B22),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List<Widget>.generate(
                              lines.clamp(1, 999),
                              (int i) => Text(
                                '${i + 1}',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontFamily: 'monospace', fontSize: 12, height: 1.45),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: ColoredBox(
                    color: LeetCodeTheme.codeBackground,
                    child: TextField(
                      controller: controller,
                      enabled: enabled,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: LeetCodeTheme.consoleGreen, height: 1.45),
                      cursorColor: LeetCodeTheme.consoleGreen,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: LeetCodeTheme.codeBackground,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
                        hintText: isDebug ? '// Broken code — fix the bug' : '// Write your solution here',
                        hintStyle: const TextStyle(color: LeetCodeTheme.textSecondary, fontFamily: 'monospace'),
                      ),
                      inputFormatters: <TextInputFormatter>[const SingleLineFormatter(deny: false)],
                      onSubmitted: enabled ? (_) => onSubmit?.call() : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pass-through formatter placeholder (keeps multiline).
class SingleLineFormatter extends TextInputFormatter {
  const SingleLineFormatter({required this.deny});
  final bool deny;
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) => newValue;
}

class LeetcodeTestResultsPanel extends StatefulWidget {
  const LeetcodeTestResultsPanel({
    super.key,
    required this.result,
    this.loading = false,
  });

  final LeetcodeRunResult? result;
  final bool loading;

  @override
  State<LeetcodeTestResultsPanel> createState() => _LeetcodeTestResultsPanelState();
}

class _LeetcodeTestResultsPanelState extends State<LeetcodeTestResultsPanel> {
  int _selectedCase = 0;

  @override
  void didUpdateWidget(LeetcodeTestResultsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.result != oldWidget.result) {
      _selectedCase = 0;
      final int failed = widget.result?.results.indexWhere((LeetcodeTestCaseResult r) => !r.passed) ?? -1;
      if (failed >= 0) _selectedCase = failed;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator(color: LeetCodeTheme.accent));
    }
    final LeetcodeRunResult? result = widget.result;
    if (result == null) {
      return const Center(
        child: Text(
          'Click Run to execute sample test cases,\nor Submit to judge against all tests.',
          style: TextStyle(color: LeetCodeTheme.textSecondary, height: 1.5),
          textAlign: TextAlign.center,
        ),
      );
    }

    final int passed = result.results.where((LeetcodeTestCaseResult r) => r.passed).length;
    final int total = result.results.length;
    final LeetcodeTestCaseResult? active = result.results.isEmpty
        ? null
        : result.results[_selectedCase.clamp(0, result.results.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              result.accepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: result.accepted ? LeetCodeTheme.success : LeetCodeTheme.hard,
            ),
            const SizedBox(width: 8),
            Text(
              result.accepted ? 'Accepted' : 'Wrong Answer',
              style: TextStyle(
                color: result.accepted ? LeetCodeTheme.success : LeetCodeTheme.hard,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            Text(
              '$passed / $total passed',
              style: TextStyle(
                color: result.accepted ? LeetCodeTheme.success : LeetCodeTheme.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (result.runtimeNote.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text(result.runtimeNote, style: const TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12)),
        ],
        if (result.feedback.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Text(result.feedback, style: const TextStyle(color: LeetCodeTheme.textPrimary, height: 1.4)),
        ],
        if (result.codeReviewSummary.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          const Text('AI Code Review', style: TextStyle(color: LeetCodeTheme.accent, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 6),
          Text(result.codeReviewSummary, style: const TextStyle(color: LeetCodeTheme.textSecondary, height: 1.45, fontSize: 13)),
        ],
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List<Widget>.generate(result.results.length, (int i) {
              final LeetcodeTestCaseResult r = result.results[i];
              final bool selected = i == _selectedCase;
              final Color color = r.passed ? LeetCodeTheme.success : LeetCodeTheme.hard;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () => setState(() => _selectedCase = i),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? color.withValues(alpha: 0.15) : LeetCodeTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: selected ? color : LeetCodeTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          r.passed ? Icons.check_rounded : Icons.close_rounded,
                          size: 14,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Case ${r.index}',
                          style: TextStyle(
                            color: selected ? LeetCodeTheme.textPrimary : LeetCodeTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        if (active != null)
          Expanded(child: SingleChildScrollView(child: _CaseCard(result: active, expanded: true))),
      ],
    );
  }
}

class _CaseCard extends StatelessWidget {
  const _CaseCard({required this.result, this.expanded = false});

  final LeetcodeTestCaseResult result;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Color color = result.passed ? LeetCodeTheme.success : LeetCodeTheme.hard;
    return Container(
      margin: expanded ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LeetCodeTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!expanded)
            Text(
              'Case ${result.index}${result.hidden ? ' (hidden)' : ''} — ${result.passed ? 'Passed' : 'Failed'}',
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          if (!expanded) const SizedBox(height: 8),
          if (result.hidden && expanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Hidden test case', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          _IoBlock(label: 'Input', value: result.input),
          const SizedBox(height: 4),
          if (result.passed)
            _IoBlock(label: 'Output', value: result.expected)
          else ...<Widget>[
            _IoBlock(label: 'Expected', value: result.expected),
            const SizedBox(height: 4),
            _IoBlock(label: 'Stdout', value: result.actual.isEmpty ? '(empty)' : result.actual),
          ],
        ],
      ),
    );
  }
}
