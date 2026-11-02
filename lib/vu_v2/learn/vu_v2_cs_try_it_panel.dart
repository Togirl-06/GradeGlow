import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../screens/computer_science/cs_hybrid_workspace_screen.dart';
import '../../services/practice_lab_service.dart';
import '../../utils/network_reachability.dart';
import '../data/vu_v2_cs_try_it.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';

/// W3Schools-style Try It Yourself coding panel for CS V2 lessons.
class VuV2CsTryItPanel extends StatefulWidget {
  const VuV2CsTryItPanel({
    super.key,
    required this.spec,
  });

  final VuV2CsTryItSpec spec;

  @override
  State<VuV2CsTryItPanel> createState() => _VuV2CsTryItPanelState();
}

class _VuV2CsTryItPanelState extends State<VuV2CsTryItPanel> {
  late final TextEditingController _code;
  String? _output;
  bool _running = false;

  VuV2CsTryItSpec get spec => widget.spec;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(text: spec.starterCode);
  }

  @override
  void didUpdateWidget(covariant VuV2CsTryItPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spec.topicId != widget.spec.topicId ||
        oldWidget.spec.starterCode != widget.spec.starterCode) {
      _code.text = widget.spec.starterCode;
      _output = null;
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VuV2Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'TRY IT YOURSELF',
            style: TextStyle(
              color: VuV2Colors.orange,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'W3Schools-style coding lab · ${spec.languageLabel}',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            spec.task,
            style: TextStyle(color: VuV2Colors.ink, height: 1.45),
          ),
          const SizedBox(height: 12),
          _miniLabel('Example'),
          const SizedBox(height: 6),
          _codeBox(
            'Input: ${spec.exampleInput}\n'
            'Output: ${spec.exampleOutput}\n'
            'Steps: ${spec.exampleSteps}',
          ),
          if (spec.syntaxBullets.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            _miniLabel('Quick syntax'),
            const SizedBox(height: 6),
            ...spec.syntaxBullets.take(6).map(
                  (String b) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $b',
                      style: TextStyle(
                        color: VuV2Colors.mute,
                        height: 1.35,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
          ],
          const SizedBox(height: 12),
          _miniLabel('Your code'),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220),
              borderRadius: BorderRadius.circular(VuV2Radii.md),
              border: Border.all(color: VuV2Colors.stroke),
            ),
            child: TextField(
              controller: _code,
              maxLines: 14,
              minLines: 10,
              style: TextStyle(
                color: Color(0xFF86EFAC),
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.45,
              ),
              cursorColor: VuV2Colors.orange,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
                hintText: 'Write your code here…',
                hintStyle: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: VuV2PrimaryButton(
                  label: _running ? 'Running…' : 'Run ▶',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _running ? null : _run,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _code.text = spec.starterCode;
                      _output = null;
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CsHybridWorkspaceScreen(
                      initialTopicId: spec.topicId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.code_rounded),
              label: const Text('Open full coding lab'),
            ),
          ),
          if (spec.runContext.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              'Goal: ${spec.runContext}',
              style: TextStyle(
                color: VuV2Colors.mute,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          if (_output != null) ...<Widget>[
            const SizedBox(height: 12),
            _miniLabel('Output'),
            const SizedBox(height: 6),
            _codeBox(_output!),
          ],
        ],
      ),
    );
  }

  Widget _miniLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: VuV2Colors.mute,
        fontWeight: FontWeight.w900,
        fontSize: 11,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _codeBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(VuV2Radii.md),
        border: Border.all(color: VuV2Colors.stroke),
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          color: Color(0xFF86EFAC),
          fontFamily: 'monospace',
          fontSize: 12.5,
          height: 1.45,
        ),
      ),
    );
  }

  Future<void> _run() async {
    setState(() {
      _running = true;
      _output = null;
    });
    final PracticeLabService? labs =
        AppConfig.hasOpenAi ? context.read<PracticeLabService>() : null;
    try {
      if (labs != null) {
        await ensureOpenAiReachable();
        if (!mounted) return;
        final String out = await labs.runCodeSnippet(
          language: spec.languageId,
          code: _code.text,
          taskContext: '${spec.task}\n${spec.runContext}',
        );
        if (!mounted) return;
        setState(() => _output = out.isEmpty ? '(no output)' : out);
      } else {
        setState(() => _output = _offlineSimulate(_code.text, spec));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _output = 'Error: $e');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  /// Tiny offline fallback so Try It still works without OpenAI.
  static String _offlineSimulate(String code, VuV2CsTryItSpec spec) {
    final List<String> prints = <String>[];
    final RegExp py = RegExp(r'''print\s*\(\s*(["'])(.*?)\1\s*\)''');
    for (final RegExpMatch m in py.allMatches(code)) {
      prints.add(m.group(2) ?? '');
    }
    final RegExp js = RegExp(r'''console\.log\s*\(\s*(["'])(.*?)\1\s*\)''');
    for (final RegExpMatch m in js.allMatches(code)) {
      prints.add(m.group(2) ?? '');
    }
    if (prints.isNotEmpty) {
      return '${prints.join('\n')}\n\n(Offline preview — connect OpenAI for full execution.)';
    }
    // Sum demo often used in array starters.
    final RegExp list = RegExp(r'\[([0-9,\s]+)\]');
    final Match? lm = list.firstMatch(code);
    if (lm != null && code.contains('total')) {
      final Iterable<int> nums = (lm.group(1) ?? '')
          .split(',')
          .map((String s) => int.tryParse(s.trim()))
          .whereType<int>();
      if (nums.isNotEmpty) {
        final int sum = nums.fold<int>(0, (int a, int b) => a + b);
        return '$sum\n\n(Offline preview of array sum pattern.)';
      }
    }
    return 'Offline mode: code saved in the editor.\n'
        'Expected goal: ${spec.runContext}\n\n'
        'Tip: configure OpenAI to run full Try It Yourself execution, '
        'or open the full coding lab.';
  }
}
