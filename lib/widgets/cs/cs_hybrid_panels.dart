import 'package:flutter/material.dart';

import '../../data/coding_languages.dart';
import '../../data/cs_w3s_multilang.dart';
import '../../models/cs_w3s_topic.dart';
import '../../models/leetcode_problem.dart';
import '../../theme/cs_hybrid_theme.dart';
import '../../theme/study_theme.dart';

/// Horizontal language picker for the CS hybrid workspace.
class CsLanguageBar extends StatelessWidget {
  const CsLanguageBar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.compact = false,
  });

  final CodingLanguage selected;
  final ValueChanged<CodingLanguage> onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final List<CodingLanguage> langs = CsW3sMultilang.learningLanguages;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 6 : 8),
      decoration: const BoxDecoration(
        color: CsHybridTheme.surface,
        border: Border(bottom: BorderSide(color: CsHybridTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!compact)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text('Language', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: CsHybridTheme.textSecondary)),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: langs.map((CodingLanguage lang) {
                final bool isSelected = lang.id == selected.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(lang.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    selected: isSelected,
                    onSelected: (_) => onSelected(lang),
                    selectedColor: CsHybridTheme.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : CsHybridTheme.textPrimary),
                    backgroundColor: CsHybridTheme.background,
                    side: BorderSide(color: isSelected ? CsHybridTheme.primary : CsHybridTheme.border),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// W3Schools-style lesson block (bullets only).
class CsLessonPanel extends StatelessWidget {
  const CsLessonPanel({super.key, required this.topic, required this.language});

  final CsW3sTopic topic;
  final CodingLanguage language;

  @override
  Widget build(BuildContext context) {
    final CsW3sLesson lesson = topic.lesson;
    final List<String> syntax = topic.syntaxFor(language.id);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            topic.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: CsHybridTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          _SectionLabel('What it does'),
          Text(lesson.whatItDoes, style: const TextStyle(color: CsHybridTheme.textSecondary, height: 1.4)),
          const SizedBox(height: 10),
          _SectionLabel('When to use it'),
          Text(lesson.whenToUse, style: const TextStyle(color: CsHybridTheme.textSecondary, height: 1.4)),
          const SizedBox(height: 10),
          _SectionLabel('Key idea'),
          Text(lesson.keyIdea, style: const TextStyle(color: CsHybridTheme.textPrimary, height: 1.4, fontWeight: FontWeight.w600)),
          if (syntax.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            _SectionLabel('Syntax (${language.label})'),
            for (final String b in syntax)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('• ', style: TextStyle(color: CsHybridTheme.primary, fontWeight: FontWeight.w900)),
                    Expanded(child: Text(b, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.45))),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 16),
          _SectionLabel('Example'),
          _IoCard(label: 'Input', value: topic.example.input),
          const SizedBox(height: 6),
          _IoCard(label: 'Output', value: topic.example.output),
          const SizedBox(height: 8),
          Text(topic.example.steps, style: const TextStyle(color: CsHybridTheme.textSecondary, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: TextStyle(color: CsHybridTheme.primary, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

class _IoCard extends StatelessWidget {
  const _IoCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CsHybridTheme.codeBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: SelectableText(
        '$label: $value',
        style: const TextStyle(color: CsHybridTheme.consoleGreen, fontFamily: 'monospace', fontSize: 12, height: 1.4),
      ),
    );
  }
}

/// Compact hints control — opens the practice hints sheet.
class CsPracticeHintsButton extends StatelessWidget {
  const CsPracticeHintsButton({
    super.key,
    required this.hints,
    required this.hintLoading,
    required this.onRequestHint,
    this.compact = false,
  });

  final List<String> hints;
  final bool hintLoading;
  final Future<List<String>> Function() onRequestHint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => showCsPracticeHintsSheet(
        context,
        hints: hints,
        hintLoading: hintLoading,
        onRequestHint: onRequestHint,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: CsHybridTheme.primary,
        side: const BorderSide(color: CsHybridTheme.border),
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 6 : 8),
        visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      ),
      icon: const Icon(Icons.lightbulb_outline, size: 16),
      label: Text(
        hints.isEmpty ? 'Hints' : 'Hints (${hints.length})',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: compact ? 12 : 12),
      ),
    );
  }
}

/// Right panel header: Try It vs Problems + tier tabs.
class CsHybridRightHeader extends StatelessWidget {
  const CsHybridRightHeader({
    super.key,
    required this.topic,
    required this.problemMode,
    required this.tier,
    required this.onSelectMode,
    required this.onSelectTier,
    this.hints = const <String>[],
    this.hintLoading = false,
    this.onRequestHint,
  });

  final CsW3sTopic topic;
  final bool problemMode;
  final CsProblemTier? tier;
  final ValueChanged<bool> onSelectMode;
  final ValueChanged<CsProblemTier> onSelectTier;
  final List<String> hints;
  final bool hintLoading;
  final Future<List<String>> Function()? onRequestHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: const BoxDecoration(
        color: CsHybridTheme.surface,
        border: Border(bottom: BorderSide(color: CsHybridTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SegmentedButton<bool>(
            segments: const <ButtonSegment<bool>>[
              ButtonSegment<bool>(value: false, label: Text('Try It', style: TextStyle(fontSize: 12))),
              ButtonSegment<bool>(value: true, label: Text('Problems', style: TextStyle(fontSize: 12))),
            ],
            selected: <bool>{problemMode},
            onSelectionChanged: (Set<bool> s) => onSelectMode(s.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) return CsHybridTheme.primary;
                return CsHybridTheme.background;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return CsHybridTheme.textPrimary;
              }),
            ),
          ),
          if (problemMode) ...<Widget>[
            const SizedBox(height: 8),
            Row(
              children: CsProblemTier.values.map((CsProblemTier t) {
                final LeetcodeProblem p = topic.problemFor(t);
                final bool selected = tier == t;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: InkWell(
                      onTap: () => onSelectTier(t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? CsHybridTheme.tierColor(p.difficulty).withValues(alpha: 0.12) : CsHybridTheme.background,
                          border: Border.all(color: selected ? CsHybridTheme.tierColor(p.difficulty) : CsHybridTheme.border),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          p.difficulty,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: CsHybridTheme.tierColor(p.difficulty),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (onRequestHint != null) ...<Widget>[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: CsPracticeHintsButton(
                  hints: hints,
                  hintLoading: hintLoading,
                  onRequestHint: onRequestHint!,
                  compact: true,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Problem statement for right panel.
class CsProblemStatement extends StatelessWidget {
  const CsProblemStatement({super.key, required this.problem});

  final LeetcodeProblem problem;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            problem.title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: CsHybridTheme.tierColor(problem.difficulty)),
          ),
          const SizedBox(height: 8),
          Text(problem.description, style: const TextStyle(color: CsHybridTheme.textPrimary, height: 1.5, fontSize: 13)),
          const SizedBox(height: 12),
          for (int i = 0; i < problem.examples.length; i++) ...<Widget>[
            Text('Example ${i + 1}:', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 4),
            _IoCard(label: 'Input', value: problem.examples[i].input),
            const SizedBox(height: 4),
            _IoCard(label: 'Output', value: problem.examples[i].output),
            if (problem.examples[i].explanation != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(problem.examples[i].explanation!, style: const TextStyle(color: CsHybridTheme.textSecondary, fontSize: 12)),
            ],
            const SizedBox(height: 10),
          ],
          if (problem.constraints.isNotEmpty) ...<Widget>[
            const Text('Constraints:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 4),
            for (final String c in problem.constraints)
              Text('• $c', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: CsHybridTheme.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Try It task description.
class CsTryItPanel extends StatelessWidget {
  const CsTryItPanel({super.key, required this.topic, required this.language});

  final CsW3sTopic topic;
  final CodingLanguage language;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Try It Yourself', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(topic.tryIt.task, style: const TextStyle(color: CsHybridTheme.textPrimary, height: 1.5, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            'Write your solution in ${language.label}. Edit the code in the center panel, then click Run.',
            style: const TextStyle(color: CsHybridTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Output / feedback panel (light theme).
class CsHybridOutputPanel extends StatelessWidget {
  const CsHybridOutputPanel({
    super.key,
    this.stdout,
    this.result,
    this.loading = false,
    this.optimalExplanation,
    this.loadingOptimal = false,
    this.onShowOptimal,
    this.showOptimalButton = false,
  });

  final String? stdout;
  final LeetcodeRunResult? result;
  final bool loading;
  final String? optimalExplanation;
  final bool loadingOptimal;
  final VoidCallback? onShowOptimal;
  final bool showOptimalButton;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator(color: CsHybridTheme.primary));
    }

    final bool hasContent = result != null ||
        (stdout != null && stdout!.isNotEmpty) ||
        optimalExplanation != null ||
        (showOptimalButton && onShowOptimal != null);
    if (!hasContent) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (result != null) ...<Widget>[
            Row(
              children: <Widget>[
                Icon(
                  result!.accepted ? Icons.check_circle : Icons.cancel,
                  color: result!.accepted ? CsHybridTheme.primary : CsHybridTheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  result!.accepted ? 'Correct' : 'Incorrect',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: result!.accepted ? CsHybridTheme.primary : CsHybridTheme.error,
                  ),
                ),
              ],
            ),
            if (result!.feedback.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(result!.feedback, style: const TextStyle(height: 1.45, fontSize: 13)),
            ],
            if (result!.timeComplexity != null || result!.spaceComplexity != null) ...<Widget>[
              const SizedBox(height: 10),
              const Text('Complexity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              if (result!.timeComplexity != null) Text('Time: ${result!.timeComplexity}', style: const TextStyle(fontSize: 12)),
              if (result!.spaceComplexity != null) Text('Space: ${result!.spaceComplexity}', style: const TextStyle(fontSize: 12)),
            ],
            if (result!.optimizationTips != null && result!.optimizationTips!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              const Text('Improvement hint', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              Text(result!.optimizationTips!, style: const TextStyle(fontSize: 12, height: 1.45, color: CsHybridTheme.textSecondary)),
            ],
            for (final LeetcodeTestCaseResult t in result!.results) ...<Widget>[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: t.passed ? CsHybridTheme.primary.withValues(alpha: 0.08) : CsHybridTheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: t.passed ? CsHybridTheme.primary : CsHybridTheme.error),
                ),
                child: Text(
                  '${t.passed ? "✓" : "✗"} Case ${t.index}${t.hidden ? " (hidden)" : ""}\nExpected: ${t.expected}\nGot: ${t.actual}',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.4),
                ),
              ),
            ],
            if (showOptimalButton && onShowOptimal != null) ...<Widget>[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: loadingOptimal ? null : onShowOptimal,
                icon: loadingOptimal
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome, size: 16),
                label: const Text('Show optimal approach'),
              ),
            ],
            if (optimalExplanation != null) ...<Widget>[
              const SizedBox(height: 10),
              const Text('Optimal approach', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              Text(optimalExplanation!, style: const TextStyle(fontSize: 12, height: 1.5)),
            ],
          ] else if (stdout != null && stdout!.isNotEmpty) ...<Widget>[
            const Text('Output', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: CsHybridTheme.codeBg, borderRadius: BorderRadius.circular(4)),
              child: SelectableText(stdout!, style: const TextStyle(color: CsHybridTheme.consoleGreen, fontFamily: 'monospace', fontSize: 12)),
            ),
          ] else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

/// Popup sheet for coding-problem hints — compact until opened.
void showCsPracticeHintsSheet(
  BuildContext context, {
  required List<String> hints,
  required bool hintLoading,
  required Future<List<String>> Function() onRequestHint,
  int maxHints = 4,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: CsHybridTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) => _CsPracticeHintsSheet(
      initialHints: hints,
      hintLoading: hintLoading,
      onRequestHint: onRequestHint,
      maxHints: maxHints,
    ),
  );
}

class _CsPracticeHintsSheet extends StatefulWidget {
  const _CsPracticeHintsSheet({
    required this.initialHints,
    required this.hintLoading,
    required this.onRequestHint,
    required this.maxHints,
  });

  final List<String> initialHints;
  final bool hintLoading;
  final Future<List<String>> Function() onRequestHint;
  final int maxHints;

  @override
  State<_CsPracticeHintsSheet> createState() => _CsPracticeHintsSheetState();
}

class _CsPracticeHintsSheetState extends State<_CsPracticeHintsSheet> {
  late List<String> _hints;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _hints = List<String>.from(widget.initialHints);
    _loading = widget.hintLoading;
  }

  bool get _canRequestMore => _hints.length < widget.maxHints;

  Future<void> _requestNext() async {
    if (_loading || !_canRequestMore) return;
    setState(() => _loading = true);
    try {
      final List<String> updated = await widget.onRequestHint();
      if (!mounted) return;
      setState(() => _hints = List<String>.from(updated));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.55;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text(
                  'Hints',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: CsHybridTheme.textPrimary),
                ),
                const Spacer(),
                if (_canRequestMore)
                  TextButton.icon(
                    onPressed: _loading ? null : _requestNext,
                    icon: _loading
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: CsHybridTheme.primary),
                          )
                        : Icon(Icons.lightbulb_outline, size: 18, color: CsHybridTheme.primary),
                    label: Text(
                      'Hint ${_hints.length + 1}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: CsHybridTheme.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: _hints.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CsHybridTheme.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CsHybridTheme.border),
                      ),
                      child: Text(
                        _canRequestMore
                            ? 'Tap Hint 1 above when you need a nudge — hints unlock one at a time.'
                            : 'No hints available for this problem.',
                        style: const TextStyle(color: CsHybridTheme.textSecondary, height: 1.45, fontSize: 13),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          for (int i = 0; i < _hints.length; i++)
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: i < _hints.length - 1 ? 10 : 0),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: CsHybridTheme.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: CsHybridTheme.border),
                              ),
                              child: Text(
                                '${i + 1}. ${_hints[i]}',
                                style: const TextStyle(fontSize: 13, height: 1.5, color: CsHybridTheme.textPrimary),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// W3Schools-style practice: code snippet + multiple-choice question.
class CsW3sPracticePanel extends StatelessWidget {
  const CsW3sPracticePanel({
    super.key,
    required this.quizzes,
    required this.quizIndex,
    required this.picked,
    required this.revealed,
    required this.onPick,
    required this.onNext,
    this.topicTitle,
  });

  final List<CsW3sQuiz> quizzes;
  final int quizIndex;
  final int? picked;
  final bool revealed;
  final ValueChanged<int> onPick;
  final VoidCallback onNext;
  final String? topicTitle;

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No practice questions for this topic yet.', style: TextStyle(color: CsHybridTheme.textSecondary)),
        ),
      );
    }
    final CsW3sQuiz q = quizzes[quizIndex % quizzes.length];
    final bool correct = picked == q.correctIndex;
    final Color accent = StudyColors.primary;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (topicTitle != null) ...<Widget>[
          Text(
            topicTitle!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: CsHybridTheme.textPrimary),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          'Exercise ${quizIndex + 1} of ${quizzes.length}',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: CsHybridTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        if (q.code.trim().isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CsHybridTheme.codeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              q.code,
              style: const TextStyle(color: CsHybridTheme.consoleGreen, fontFamily: 'monospace', height: 1.4, fontSize: 12),
            ),
          ),
        if (q.code.trim().isNotEmpty) const SizedBox(height: 14),
        Text(q.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (int i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: _optionColor(i, q, picked, revealed, accent),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: revealed ? null : () => onPick(i),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: CsHybridTheme.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${String.fromCharCode(65 + i)}. ${q.options[i]}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
        if (revealed) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            correct ? 'Correct!' : 'Not quite — ${q.options[q.correctIndex]}',
            style: TextStyle(color: correct ? accent : CsHybridTheme.error, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(q.explanation, style: const TextStyle(color: CsHybridTheme.textSecondary, height: 1.45, fontSize: 13)),
          const SizedBox(height: 16),
          if (quizzes.length > 1)
            FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white),
              child: Text(quizIndex + 1 >= quizzes.length ? 'Try again' : 'Next question'),
            ),
        ],
      ],
    );
  }

  Color _optionColor(int i, CsW3sQuiz q, int? picked, bool revealed, Color accent) {
    if (!revealed) return CsHybridTheme.surface;
    if (i == q.correctIndex) return accent.withValues(alpha: 0.12);
    if (i == picked) return CsHybridTheme.error.withValues(alpha: 0.12);
    return CsHybridTheme.surface;
  }
}
