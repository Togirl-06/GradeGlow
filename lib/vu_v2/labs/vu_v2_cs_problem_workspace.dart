import 'package:flutter/material.dart';

import '../../data/coding_languages.dart';
import '../../models/leetcode_problem.dart';
import '../../services/code_judge_service.dart';
import '../../theme/leetcode_theme.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_problem_enrichment.dart';
import 'vu_v2_vscode_editor.dart';

/// Code Bench — problem + editor for Algorithm Arena (Flutter-web safe).
class VuV2CsProblemWorkspace extends StatefulWidget {
  const VuV2CsProblemWorkspace({
    super.key,
    required this.problem,
    required this.problemIndex,
    required this.totalProblems,
    required this.playlist,
    this.judge,
  });

  final LeetcodeProblem problem;
  final int problemIndex;
  final int totalProblems;
  final List<LeetcodeProblem> playlist;

  /// Injected in tests; defaults to the server judge.
  final CodeJudgeService? judge;

  @override
  State<VuV2CsProblemWorkspace> createState() => _VuV2CsProblemWorkspaceState();
}

class _VuV2CsProblemWorkspaceState extends State<VuV2CsProblemWorkspace> {
  late LeetcodeProblem _problem;
  late int _index;
  late TextEditingController _code;
  final ScrollController _editorScroll = ScrollController();

  String _languageId = 'python3';
  String _console = 'Run checks your code against the sample cases. Submit runs every hidden test on the server.';
  JudgeResult? _lastResult;
  bool _accepted = false;
  bool _busy = false;
  late final CodeJudgeService _judge = widget.judge ?? CodeJudgeService();
  double _progress = 0.1;

  final List<CodingLanguage> _languages = <CodingLanguage>[];

  CodingLanguage get _language {
    for (int i = 0; i < _languages.length; i++) {
      if (_languages[i].id == _languageId) {
        return _languages[i];
      }
    }
    return CodingLanguage.python3;
  }

  bool get _graded => CodeJudgeService.isGraded(_languageId);

  @override
  void initState() {
    super.initState();
    _languages.addAll(CodingLanguage.leftColumn);
    _languages.addAll(CodingLanguage.rightColumn);
    _problem = widget.problem;
    _index = (widget.problemIndex - 1).clamp(0, widget.playlist.length - 1);
    _code = TextEditingController(text: _safeStarter(_language));
  }

  @override
  void dispose() {
    _code.dispose();
    _editorScroll.dispose();
    super.dispose();
  }

  String _safeStarter(CodingLanguage language) {
    final String? shaped = _shapedStarter(language);
    if (shaped != null) {
      return shaped;
    }
    try {
      final String s = CodingLanguage.starterForProblem(_problem, language);
      if (s.trim().isNotEmpty) {
        return s;
      }
    } catch (_) {}
    return 'class Solution:\n'
        '    def ${_problem.functionName}(self, *args):\n'
        '        pass\n';
  }

  String? _shapedStarter(CodingLanguage language) {
    // Only override when the problem has no language-specific starter map.
    if (_problem.starterCode.isNotEmpty) {
      return null;
    }
    final String id = language.id;
    final String fn = _problem.functionName;
    if (id == 'python3' || id == 'python') {
      if (fn == 'maxSwingProfit' || fn == 'maxProfit') {
        return 'class Solution:\n'
            '    def $fn(self, prices: list[int]) -> int:\n'
            '        \n';
      }
      if (fn == 'findTwinIndices' || fn == 'twoSum') {
        return 'class Solution:\n'
            '    def $fn(self, nums: list[int], target: int) -> list[int]:\n'
            '        \n';
      }
      if (fn == 'hasEchoValue' || fn == 'containsDuplicate') {
        return 'class Solution:\n'
            '    def $fn(self, nums: list[int]) -> bool:\n'
            '        \n';
      }
    }
    if (id == 'javascript') {
      if (fn == 'maxSwingProfit' || fn == 'maxProfit') {
        return '/**\n'
            ' * @param {number[]} prices\n'
            ' * @return {number}\n'
            ' */\n'
            'var $fn = function(prices) {\n'
            '    \n'
            '};\n';
      }
    }
    return null;
  }

  void _setLanguage(String? id) {
    if (id == null) {
      return;
    }
    CodingLanguage? next;
    for (int i = 0; i < _languages.length; i++) {
      if (_languages[i].id == id) {
        next = _languages[i];
        break;
      }
    }
    if (next == null) {
      return;
    }
    setState(() {
      _languageId = next!.id;
      _code.text = _safeStarter(next);
      _console = 'Language → ${next.label}';
      _lastResult = null;
      _accepted = false;
    });
  }

  Future<void> _pickLanguage() async {
    final CodingLanguage? picked = await showModalBottomSheet<CodingLanguage>(
      context: context,
      backgroundColor: const Color(0xFF252526),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: ListView(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Select Language Mode',
                  style: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              for (int i = 0; i < _languages.length; i++)
                ListTile(
                  dense: true,
                  title: Text(
                    _languages[i].label,
                    style: TextStyle(
                      color: _languages[i].id == _languageId
                          ? const Color(0xFF3794FF)
                          : const Color(0xFFCCCCCC),
                      fontWeight: _languages[i].id == _languageId
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    CodeJudgeService.isGraded(_languages[i].id)
                        ? 'Runs and grades tests'
                        : 'Editor only · not graded yet',
                    style: TextStyle(
                      color: CodeJudgeService.isGraded(_languages[i].id)
                          ? const Color(0xFF89D185)
                          : const Color(0xFF858585),
                      fontSize: 11,
                    ),
                  ),
                  trailing: _languages[i].id == _languageId
                      ? const Icon(Icons.check, color: Color(0xFF3794FF), size: 18)
                      : null,
                  onTap: () => Navigator.pop(ctx, _languages[i]),
                ),
            ],
          ),
        );
      },
    );
    if (picked != null) {
      _setLanguage(picked.id);
    }
  }

  void _reset() {
    setState(() {
      _code.text = _safeStarter(_language);
      _console = 'Reset.';
      _lastResult = null;
      _accepted = false;
    });
  }

  void _openAt(int index) {
    if (index < 0 || index >= widget.playlist.length) {
      return;
    }
    setState(() {
      _problem = widget.playlist[index];
      _index = index;
      _code.text = _safeStarter(_language);
      _console = 'Loaded ${_problem.title}';
      _lastResult = null;
      _accepted = false;
      _progress = 0.1;
    });
  }

  String _format(JudgeResult r) {
    final StringBuffer b = StringBuffer();
    b.writeln(r.verdict);
    if (r.message.isNotEmpty) b.writeln(r.message);
    if (r.runtimeMs != null || r.memoryKb != null) {
      b.writeln(<String>[
        if (r.runtimeMs != null) 'Runtime ${r.runtimeMs!.toStringAsFixed(2)} ms',
        if (r.memoryKb != null) 'Memory ${(r.memoryKb! / 1024).toStringAsFixed(1)} MB',
      ].join(' · '));
    }
    b.writeln();
    for (final JudgeCase c in r.cases) {
      final String tag = c.hidden ? ' (hidden)' : '';
      b.writeln('Case ${c.index}$tag: ${c.passed ? 'PASS' : 'FAIL'}  ${c.ms.toStringAsFixed(2)} ms');
      if (c.input != null) b.writeln('  in:  ${c.input}');
      if (c.expected != null) b.writeln('  exp: ${c.expected}');
      if (c.output != null) b.writeln('  got: ${c.output}');
      if (c.error != null) b.writeln('  err: ${c.error}');
    }
    if (r.stderr.trim().isNotEmpty && r.cases.isEmpty) {
      b.writeln(r.stderr.trim());
    }
    return b.toString();
  }

  Future<void> _execute({required bool submit}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _console = submit ? 'Submitting… running all hidden tests on the server.' : 'Running sample tests on the server…';
    });
    final JudgeResult r = await _judge.judge(
      problem: _problem,
      languageId: _languageId,
      code: _code.text,
      submit: submit,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastResult = r;
      _console = _format(r);
      if (submit && r.accepted) _accepted = true;
      if (!r.notGraded) {
        _progress = r.accepted
            ? (submit ? 1.0 : (_progress + 0.2).clamp(0.0, 0.9))
            : (_progress + 0.05).clamp(0.0, 0.95);
      }
    });
    if (submit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(r.accepted ? 'Accepted · ${r.passed}/${r.total} tests passed' : r.verdict),
          backgroundColor: r.accepted ? VuV2Colors.success : (r.notGraded ? VuV2Colors.navyElevated : VuV2Colors.danger),
        ),
      );
    }
  }

  void _run() => _execute(submit: false);

  void _submit() => _execute(submit: true);

  @override
  Widget build(BuildContext context) {
    final Color diff = LeetCodeTheme.difficultyColor(_problem.difficulty);
    final bool wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(
        backgroundColor: VuV2Colors.navyElevated,
        title: Text(_problem.title, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          IconButton(
            onPressed: _index > 0 ? () => _openAt(_index - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Center(
            child: Text(
              '${_index + 1}/${widget.playlist.length}',
              style: TextStyle(fontSize: 12, color: VuV2Colors.mute),
            ),
          ),
          IconButton(
            onPressed: _index < widget.playlist.length - 1
                ? () => _openAt(_index + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${LeetCodeTheme.difficultyLabel(_problem.difficulty)} · Code Bench · ${(_progress * 100).round()}%',
                style: TextStyle(
                  color: diff,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(flex: 5, child: _prompt()),
                Container(width: 1, color: VuV2Colors.stroke),
                Expanded(flex: 6, child: _editor()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(flex: 2, child: _prompt()),
                Container(height: 1, color: VuV2Colors.stroke),
                Expanded(flex: 3, child: _editor()),
              ],
            ),
    );
  }

  Widget _prompt() {
    final VuV2EnrichedProblem view = VuV2ProblemEnrichment.enrich(_problem);
    final Color diff = LeetCodeTheme.difficultyColor(view.difficulty);
    final String acceptance = LeetCodeTheme.acceptanceRate(_problem.slug);
    final List<String> descParts = view.description.split('\n\n');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: <Widget>[
        Text(
          '${view.id}. ${view.title}',
          style: TextStyle(
            color: LeetCodeTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            _Badge(
              label: LeetCodeTheme.difficultyLabel(view.difficulty),
              color: diff,
            ),
            Text(
              'Acceptance $acceptance',
              style: TextStyle(
                color: LeetCodeTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_index + 1} / ${widget.playlist.length}',
              style: TextStyle(
                color: LeetCodeTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            for (int i = 0; i < view.tags.length && i < 6; i++)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: LeetCodeTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  view.tags[i],
                  style: TextStyle(
                    color: LeetCodeTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Description'),
        const SizedBox(height: 8),
        for (int i = 0; i < descParts.length; i++) ...<Widget>[
          _Markdownish(descParts[i]),
          if (i < descParts.length - 1) const SizedBox(height: 10),
        ],
        const SizedBox(height: 20),
        for (int i = 0; i < view.examples.length; i++) ...<Widget>[
          _SectionTitle('Example ${i + 1}:'),
          const SizedBox(height: 8),
          _IoBlock(label: 'Input', value: view.examples[i].input),
          const SizedBox(height: 6),
          _IoBlock(label: 'Output', value: view.examples[i].output),
          if (view.examples[i].explanation != null &&
              view.examples[i].explanation!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Explanation:',
              style: TextStyle(
                color: LeetCodeTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              view.examples[i].explanation!,
              style: TextStyle(
                color: LeetCodeTheme.textSecondary,
                height: 1.45,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
        const _SectionTitle('Constraints:'),
        const SizedBox(height: 8),
        for (int i = 0; i < view.constraints.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '•  ',
                  style: TextStyle(
                    color: LeetCodeTheme.consoleGreen,
                    fontFamily: 'monospace',
                  ),
                ),
                Expanded(
                  child: Text(
                    view.constraints[i],
                    style: TextStyle(
                      color: LeetCodeTheme.consoleGreen,
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        const _SectionTitle('Follow-up'),
        const SizedBox(height: 8),
        Text(
          view.followUp,
          style: TextStyle(
            color: LeetCodeTheme.textSecondary,
            height: 1.45,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 18),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            title: const Text(
              'Hints',
              style: TextStyle(
                color: LeetCodeTheme.accent,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            iconColor: LeetCodeTheme.accent,
            collapsedIconColor: LeetCodeTheme.textSecondary,
            children: <Widget>[
              for (int i = 0; i < view.hints.length; i++)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Hint ${i + 1}: ${view.hints[i]}',
                      style: TextStyle(
                        color: LeetCodeTheme.textSecondary,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const _SectionTitle('Related Topics'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (int i = 0; i < view.tags.length; i++)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: LeetCodeTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: LeetCodeTheme.border),
                ),
                child: Text(
                  view.tags[i],
                  style: TextStyle(
                    color: LeetCodeTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _editor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: VuV2VsCodeEditor(
            controller: _code,
            languageLabel: _language.label,
            languageId: _languageId,
            onPickLanguage: _pickLanguage,
            onReset: _reset,
            scrollController: _editorScroll,
          ),
        ),
        Container(
          height: 110,
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            border: Border(
              top: BorderSide(color: Color(0xFF3C3C3C), width: 1),
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text(
                    'Result',
                    style: TextStyle(
                      color: Color(0xFF858585),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (_lastResult != null)
                    Text(
                      _lastResult!.verdict,
                      style: TextStyle(
                        color: _lastResult!.accepted
                            ? const Color(0xFF89D185)
                            : (_lastResult!.notGraded ? const Color(0xFFD7BA7D) : const Color(0xFFF14C4C)),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _console,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFFCCCCCC),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: const Color(0xFF252526),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: SafeArea(
            top: false,
            child: Row(
              children: <Widget>[
                _Btn(label: _busy ? 'Running…' : 'Run', filled: false, onTap: _busy || !_graded ? null : _run),
                const SizedBox(width: 10),
                _Btn(
                  label: _accepted ? 'Accepted' : 'Submit',
                  filled: true,
                  onTap: _busy || !_graded ? null : _submit,
                ),
                if (!_graded) ...<Widget>[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_language.label} is not graded yet. Use Python 3 or JavaScript to run tests.',
                      style: TextStyle(color: VuV2Colors.mute, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
      color: filled ? const Color(0xFF22C55E) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: filled ? const Color(0xFF22C55E) : VuV2Colors.stroke,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : VuV2Colors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: LeetCodeTheme.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 15,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LeetCodeTheme.codeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LeetCodeTheme.border),
      ),
      child: SelectableText(
        '$label: $value',
        style: TextStyle(
          color: LeetCodeTheme.consoleGreen,
          fontFamily: 'monospace',
          fontSize: 12.5,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Very light markdown: wraps `code` spans in monospace.
class _Markdownish extends StatelessWidget {
  const _Markdownish(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> spans = <InlineSpan>[];
    final RegExp re = RegExp(r'`([^`]+)`');
    int start = 0;
    for (final RegExpMatch m in re.allMatches(text)) {
      if (m.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, m.start),
            style: TextStyle(
              color: LeetCodeTheme.textPrimary,
              height: 1.55,
              fontSize: 14,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: m.group(1),
          style: TextStyle(
            color: LeetCodeTheme.consoleGreen,
            fontFamily: 'monospace',
            fontSize: 13.5,
            height: 1.55,
          ),
        ),
      );
      start = m.end;
    }
    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: TextStyle(
            color: LeetCodeTheme.textPrimary,
            height: 1.55,
            fontSize: 14,
          ),
        ),
      );
    }
    if (spans.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: LeetCodeTheme.textPrimary,
          height: 1.55,
          fontSize: 14,
        ),
      );
    }
    return Text.rich(TextSpan(children: spans));
  }
}
