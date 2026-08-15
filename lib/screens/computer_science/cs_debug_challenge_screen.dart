import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/coding_languages.dart';
import '../../models/leetcode_problem.dart';
import '../../services/leetcode_debug_judge.dart';
import '../../services/practice_lab_service.dart';
import '../../theme/leetcode_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/leetcode/leetcode_problem_panel.dart';
import '../../widgets/tutor_markdown_body.dart';

/// Fix pre-loaded buggy code — run tests, submit, and get graded per challenge.
class CsDebugChallengeScreen extends StatefulWidget {
  const CsDebugChallengeScreen({
    super.key,
    required this.problem,
    this.allProblems,
  });

  final LeetcodeProblem problem;
  final List<LeetcodeProblem>? allProblems;

  @override
  State<CsDebugChallengeScreen> createState() => _CsDebugChallengeScreenState();
}

class _CsDebugChallengeScreenState extends State<CsDebugChallengeScreen> {
  final TextEditingController _code = TextEditingController();
  final TextEditingController _chat = TextEditingController();
  final ScrollController _chatScroll = ScrollController();
  CodingLanguage _language = CodingLanguage.defaultLanguage;
  String _starterTemplate = '';
  int _tab = 0;
  bool _loading = false;
  bool _chatLoading = false;
  LeetcodeRunResult? _lastRun;
  bool _submitted = false;
  int? _gradeScore;
  final List<({bool isAi, String text})> _chatMessages = <({bool isAi, String text})>[];

  LeetcodeProblem get _problem => widget.problem;

  @override
  void initState() {
    super.initState();
    _syncStarter();
    _chatMessages.add((
      isAi: true,
      text: 'Ask me about the bug — for example: “Why doesn’t this terminate?” or “What should left/right become?”',
    ));
  }

  @override
  void dispose() {
    _code.dispose();
    _chat.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  /// Local-only: reloads buggy starter. Never touches the network.
  void _resetCode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _syncStarter();
      _loading = false;
    });
    StudyMessenger.showInfo(context, 'Code reset to the buggy starter.');
  }

  void _syncStarter() {
    _starterTemplate = CodingLanguage.starterForProblem(_problem, _language);
    _code.value = TextEditingValue(
      text: _starterTemplate,
      selection: TextSelection.collapsed(offset: _starterTemplate.length),
    );
    _lastRun = null;
    _submitted = false;
    _gradeScore = null;
  }

  Future<void> _changeLanguage(CodingLanguage language) async {
    if (language.id == _language.id) return;
    final bool dirty = _code.text.trim().isNotEmpty && _code.text.trim() != _starterTemplate.trim();
    if (dirty) {
      final bool? ok = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          backgroundColor: LeetCodeTheme.surface,
          title: const Text('Change language?', style: TextStyle(color: LeetCodeTheme.textPrimary)),
          content: Text(
            'Switching to ${language.label} reloads the broken starter code for that language.',
            style: const TextStyle(color: LeetCodeTheme.textSecondary),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: LeetCodeTheme.accent, foregroundColor: Colors.black),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Switch'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    setState(() {
      _language = language;
      _syncStarter();
    });
  }

  Future<void> _runTests({required bool submit}) async {
    if (_code.text.trim().isEmpty) {
      StudyMessenger.showInfo(context, 'Fix the code before running tests.');
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    try {
      final LeetcodeRunResult result = await context.read<PracticeLabService>().runLeetcodeTests(
            problem: _problem,
            language: _language.label,
            code: _code.text.trim(),
            submit: submit,
          );
      if (!mounted) return;
      final int passed = result.results.where((LeetcodeTestCaseResult r) => r.passed).length;
      final int total = result.results.isEmpty ? 1 : result.results.length;
      final int score = result.accepted ? 100 : ((passed / total) * 100).round().clamp(0, 99);
      setState(() {
        _lastRun = result;
        _tab = 1;
        _loading = false;
        if (submit) {
          _submitted = true;
          _gradeScore = score;
        }
      });
      if (submit) {
        if (result.accepted) {
          StudyMessenger.showInfo(context, 'Accepted — score: 100%');
        } else {
          StudyMessenger.showInfo(context, 'Not accepted — score: $score%. Fix the bug and submit again.');
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _lastRun = LeetcodeDebugJudge.offlineFallback(
          problem: _problem,
          includeHidden: submit,
          accepted: false,
          feedback: 'Could not grade. Fix the bug in the starter code and try again.',
        );
        _tab = 1;
      });
      StudyMessenger.showInfo(context, 'Graded offline. Keep fixing the bug and submit again.');
    }
  }

  Future<void> _askCoach() async {
    final String q = _chat.text.trim();
    if (q.isEmpty || _chatLoading) return;
    _chat.clear();
    setState(() {
      _chatMessages.add((isAi: false, text: q));
      _chatLoading = true;
      _tab = 2;
    });
    _scrollChatToEnd();
    try {
      final String reply = await context.read<PracticeLabService>().askDebugCoach(
            problem: _problem,
            language: _language.label,
            question: q,
            currentCode: _code.text,
          );
      if (!mounted) return;
      setState(() {
        _chatMessages.add((isAi: true, text: reply));
        _chatLoading = false;
      });
      _scrollChatToEnd();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _chatMessages.add((
          isAi: true,
          text: 'Could not reach the coach right now. Compare loop bounds and return values to the intended algorithm, then try Ask again.',
        ));
        _chatLoading = false;
      });
      _scrollChatToEnd();
    }
  }

  void _scrollChatToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScroll.hasClients) return;
      _chatScroll.animateTo(
        _chatScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _openNext() {
    final List<LeetcodeProblem>? all = widget.allProblems;
    if (all == null || all.length < 2) {
      Navigator.pop(context);
      return;
    }
    final int i = all.indexWhere((LeetcodeProblem p) => p.id == _problem.id);
    final int next = i < 0 ? 0 : (i + 1) % all.length;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CsDebugChallengeScreen(problem: all[next], allProblems: all),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int total = widget.allProblems?.length ?? 1;
    final int index = (widget.allProblems?.indexWhere((LeetcodeProblem p) => p.id == _problem.id) ?? 0) + 1;

    return Theme(
      data: LeetCodeTheme.darkTheme(),
      child: Scaffold(
        backgroundColor: LeetCodeTheme.background,
        appBar: AppBar(
          title: Text(_problem.title, style: const TextStyle(fontSize: 16)),
          actions: <Widget>[
            if (total > 1)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text('$index / $total', style: const TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12)),
                ),
              ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  Container(
                    color: LeetCodeTheme.surface,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _TabChip(label: 'Description', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                          _TabChip(label: 'Test Results', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
                          _TabChip(label: 'AI Chat', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
                          if (_gradeScore != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (_gradeScore! >= 70 ? LeetCodeTheme.success : LeetCodeTheme.hard).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Grade: $_gradeScore%',
                                  style: TextStyle(
                                    color: _gradeScore! >= 70 ? LeetCodeTheme.success : LeetCodeTheme.hard,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: LeetCodeTheme.surface,
                      padding: const EdgeInsets.all(14),
                      child: switch (_tab) {
                        0 => SingleChildScrollView(
                            child: LeetcodeProblemPanel(
                              problem: _problem,
                              problemIndex: index,
                              totalProblems: total,
                            ),
                          ),
                        1 => LeetcodeTestResultsPanel(result: _lastRun, loading: _loading && _tab == 1),
                        _ => _DebugChatPanel(
                            messages: _chatMessages,
                            loading: _chatLoading,
                            scrollController: _chatScroll,
                          ),
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: LeetCodeTheme.border),
            Expanded(
              flex: 3,
              child: LeetcodeCodeEditor(
                controller: _code,
                language: _language,
                onChangeLanguage: _changeLanguage,
                enabled: !_loading,
                isDebug: true,
              ),
            ),
            if (_lastRun != null && _tab == 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: const Color(0xFF161B22),
                child: Row(
                  children: <Widget>[
                    Icon(
                      _lastRun!.accepted ? Icons.check_circle_outline : Icons.error_outline,
                      size: 16,
                      color: _lastRun!.accepted ? LeetCodeTheme.success : LeetCodeTheme.hard,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastRun!.accepted
                            ? 'All test cases passed'
                            : '${_lastRun!.results.where((LeetcodeTestCaseResult r) => r.passed).length} / ${_lastRun!.results.length} passed',
                        style: TextStyle(
                          color: _lastRun!.accepted ? LeetCodeTheme.success : LeetCodeTheme.hard,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _tab = 1),
                      child: const Text('View', style: TextStyle(color: LeetCodeTheme.accent, fontSize: 12)),
                    ),
                  ],
                ),
              ),
          ],
        ),
        bottomNavigationBar: Material(
          color: LeetCodeTheme.surface,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (_loading || _chatLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: LinearProgressIndicator(minHeight: 2, color: LeetCodeTheme.accent),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _chat,
                          enabled: !_chatLoading,
                          minLines: 1,
                          maxLines: 3,
                          style: const TextStyle(color: LeetCodeTheme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Ask AI about the bug…',
                            hintStyle: const TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 13),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: LeetCodeTheme.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: LeetCodeTheme.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: LeetCodeTheme.accent),
                            ),
                          ),
                          onSubmitted: (_) => _askCoach(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _chatLoading ? null : _askCoach,
                        style: FilledButton.styleFrom(
                          backgroundColor: LeetCodeTheme.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        child: const Text('Ask', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading ? null : _resetCode,
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading ? null : () => _runTests(submit: false),
                          style: OutlinedButton.styleFrom(foregroundColor: LeetCodeTheme.consoleGreen),
                          child: const Text('Run'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: _loading ? null : () => _runTests(submit: true),
                          style: FilledButton.styleFrom(backgroundColor: LeetCodeTheme.accent, foregroundColor: Colors.black),
                          child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                  if (_submitted && widget.allProblems != null && widget.allProblems!.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: FilledButton.tonal(
                        onPressed: _loading ? null : _openNext,
                        child: const Text('Next challenge'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DebugChatPanel extends StatelessWidget {
  const _DebugChatPanel({
    required this.messages,
    required this.loading,
    required this.scrollController,
  });

  final List<({bool isAi, String text})> messages;
  final bool loading;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length + (loading ? 1 : 0),
      itemBuilder: (BuildContext context, int i) {
        if (i >= messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Thinking…', style: TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12)),
          );
        }
        final ({bool isAi, String text}) m = messages[i];
        return Align(
          alignment: m.isAi ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.85),
            decoration: BoxDecoration(
              color: m.isAi ? LeetCodeTheme.surfaceElevated : LeetCodeTheme.accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: LeetCodeTheme.border),
            ),
            child: m.isAi
                ? TutorMarkdownBody(text: m.text, textColor: LeetCodeTheme.textPrimary)
                : Text(m.text, style: const TextStyle(color: LeetCodeTheme.textPrimary, height: 1.4, fontSize: 13)),
          ),
        );
      },
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: selected ? LeetCodeTheme.accent : Colors.transparent, width: 2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? LeetCodeTheme.accent : LeetCodeTheme.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
