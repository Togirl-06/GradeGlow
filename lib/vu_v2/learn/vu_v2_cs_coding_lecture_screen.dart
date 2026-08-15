import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vu_v2_cs_coding_lecture.dart';
import '../data/vu_v2_cs_try_it.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_cs_try_it_panel.dart';

/// Mimo-style interactive coding lesson: short tips + tap-to-solve challenges.
class VuV2CsCodingLectureScreen extends StatefulWidget {
  const VuV2CsCodingLectureScreen({
    super.key,
    required this.spec,
  });

  final VuV2CsTryItSpec spec;

  @override
  State<VuV2CsCodingLectureScreen> createState() =>
      _VuV2CsCodingLectureScreenState();
}

class _VuV2CsCodingLectureScreenState extends State<VuV2CsCodingLectureScreen> {
  late final VuV2CsCodingLecture _lecture =
      VuV2CsCodingLectureBuilder.build(widget.spec);

  int _step = 0;
  bool _showTryIt = false;
  int _xp = 0;

  String? _picked;
  final List<String> _arranged = <String>[];
  bool? _correct;
  String? _feedback;

  VuV2CsLectureStep get _current => _lecture.steps[_step];

  double get _progress => (_step + 1) / _lecture.steps.length;

  bool get _canContinue {
    if (!_current.needsSolve) return true;
    return _correct == true;
  }

  void _resetInteraction() {
    _picked = null;
    _arranged.clear();
    _correct = null;
    _feedback = null;
  }

  void _checkFillOrQuiz(String choice) {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
    final bool ok = choice == _current.correctAnswer;
    setState(() {
      _picked = choice;
      _correct = ok;
      _feedback = ok ? _current.successLine : _current.failLine;
      if (ok) _xp += 10;
    });
  }

  void _tapArrangeChip(String chip) {
    if (_correct == true) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
    setState(() {
      _arranged.add(chip);
      _correct = null;
      _feedback = null;
    });
  }

  void _undoArrange() {
    if (_arranged.isEmpty || _correct == true) return;
    setState(() {
      _arranged.removeLast();
      _correct = null;
      _feedback = null;
    });
  }

  void _clearArrange() {
    if (_correct == true) return;
    setState(() {
      _arranged.clear();
      _correct = null;
      _feedback = null;
    });
  }

  void _checkArrange() {
    if (_arranged.isEmpty) return;
    final bool ok = _listEq(_arranged, _current.correctOrder);
    setState(() {
      _correct = ok;
      _feedback = ok ? _current.successLine : _current.failLine;
      if (ok) {
        _xp += 15;
      } else {
        // Allow retry after wrong order.
        _arranged.clear();
      }
    });
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _goNext() {
    if (!_canContinue) return;
    if (_step >= _lecture.steps.length - 1) {
      setState(() => _showTryIt = true);
      return;
    }
    setState(() {
      _step++;
      _resetInteraction();
    });
  }

  void _goBack() {
    if (_step <= 0) return;
    setState(() {
      _step--;
      _resetInteraction();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showTryIt) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Try It · ${widget.spec.topicTitle}'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () => setState(() => _showTryIt = false),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: <Widget>[
            VuV2Surface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'LESSON CLEAR · +$_xp XP',
                    style: TextStyle(
                      color: VuV2Colors.orange,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Now code ${widget.spec.topicTitle} yourself',
                    style: const TextStyle(
                      color: VuV2Colors.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Same idea as Mimo practice — type it, run it, own it.',
                    style: TextStyle(color: VuV2Colors.mute, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            VuV2CsTryItPanel(spec: widget.spec),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _showTryIt = false;
                _step = 0;
                _xp = 0;
                _resetInteraction();
              }),
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Replay lesson'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spec.topicTitle),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '⚡ $_xp',
                style: const TextStyle(
                  color: VuV2Colors.yellow,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _showTryIt = true),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text(
                      'Mimo-style lesson',
                      style: TextStyle(
                        color: VuV2Colors.mute,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_step + 1}/${_lecture.steps.length}',
                      style: const TextStyle(
                        color: VuV2Colors.mute,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                VuV2ProgressBar(value: _progress, height: 8),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: <Widget>[
                _CoachBubble(
                  emoji: _current.emoji,
                  title: _current.title,
                  coach: _current.coach,
                ),
                const SizedBox(height: 12),
                if (_current.code != null)
                  _CodeStage(
                    code: _current.code!,
                    filled: _current.kind == VuV2MimoKind.fillBlank &&
                            _correct == true
                        ? _picked
                        : (_current.kind == VuV2MimoKind.fillBlank
                            ? _picked
                            : null),
                    blankToken: _current.blankToken,
                    highlightBlank: _current.kind == VuV2MimoKind.fillBlank,
                  ),
                if (_current.kind == VuV2MimoKind.arrange) ...<Widget>[
                  const SizedBox(height: 12),
                  _ArrangeTray(tokens: _arranged),
                ],
                if (_current.needsSolve) ...<Widget>[
                  const SizedBox(height: 14),
                  if (_current.kind == VuV2MimoKind.arrange)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        ..._availableArrangeChips().map(
                          (String c) => _ChipButton(
                            label: c,
                            selected: false,
                            onTap: () => _tapArrangeChip(c),
                          ),
                        ),
                      ],
                    )
                  else
                    ..._current.choices.map((String c) {
                      final bool selected = _picked == c;
                      Color? tint;
                      if (_correct != null && selected) {
                        tint = _correct! ? VuV2Colors.success : VuV2Colors.danger;
                      } else if (_correct == true && c == _current.correctAnswer) {
                        tint = VuV2Colors.success;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ChoiceTile(
                          label: c,
                          selected: selected,
                          tint: tint,
                          enabled: _correct != true,
                          onTap: () => _checkFillOrQuiz(c),
                        ),
                      );
                    }),
                  if (_current.kind == VuV2MimoKind.arrange) ...<Widget>[
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        TextButton(
                          onPressed: _undoArrange,
                          child: const Text('Undo'),
                        ),
                        TextButton(
                          onPressed: _clearArrange,
                          child: const Text('Clear'),
                        ),
                        const Spacer(),
                        FilledButton.tonal(
                          onPressed: _arranged.isEmpty || _correct == true
                              ? null
                              : _checkArrange,
                          child: const Text('Check'),
                        ),
                      ],
                    ),
                  ],
                ],
                if (_feedback != null) ...<Widget>[
                  const SizedBox(height: 12),
                  _FeedbackBanner(
                    text: _feedback!,
                    ok: _correct == true,
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: <Widget>[
                  if (_step > 0)
                    IconButton.filledTonal(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  if (_step > 0) const SizedBox(width: 8),
                  Expanded(
                    child: VuV2PrimaryButton(
                      label: !_current.needsSolve
                          ? (_step >= _lecture.steps.length - 1
                              ? 'Start Try It'
                              : 'Continue')
                          : (_correct == true
                              ? (_step >= _lecture.steps.length - 1
                                  ? 'Start Try It'
                                  : 'Continue')
                              : 'Solve to continue'),
                      icon: _step >= _lecture.steps.length - 1
                          ? Icons.code_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: _canContinue ? _goNext : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _availableArrangeChips() {
    final Map<String, int> need = <String, int>{};
    for (final String c in _current.choices) {
      need[c] = (need[c] ?? 0) + 1;
    }
    for (final String c in _arranged) {
      need[c] = (need[c] ?? 0) - 1;
    }
    final List<String> out = <String>[];
    for (final String c in _current.choices) {
      if ((need[c] ?? 0) > 0) {
        out.add(c);
        need[c] = need[c]! - 1;
      }
    }
    return out;
  }
}

class _CoachBubble extends StatelessWidget {
  const _CoachBubble({
    required this.emoji,
    required this.title,
    required this.coach,
  });

  final String emoji;
  final String title;
  final String coach;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VuV2Colors.navyElevated,
        borderRadius: BorderRadius.circular(VuV2Radii.xl),
        border: Border.all(color: VuV2Colors.orange.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: VuV2Colors.orange.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  coach,
                  style: const TextStyle(
                    color: VuV2Colors.mute,
                    height: 1.4,
                    fontSize: 14.5,
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

class _CodeStage extends StatelessWidget {
  const _CodeStage({
    required this.code,
    required this.blankToken,
    required this.highlightBlank,
    this.filled,
  });

  final String code;
  final String blankToken;
  final bool highlightBlank;
  final String? filled;

  @override
  Widget build(BuildContext context) {
    final String shown = filled != null && code.contains(blankToken)
        ? code.replaceAll(blankToken, filled!)
        : code;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(VuV2Radii.lg),
        border: Border.all(color: const Color(0xFF86EFAC).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              _Traffic(Color(0xFFF87171)),
              SizedBox(width: 5),
              _Traffic(Color(0xFFFBBF24)),
              SizedBox(width: 5),
              _Traffic(Color(0xFF4ADE80)),
              Spacer(),
              Text(
                'editor',
                style: TextStyle(
                  color: VuV2Colors.mute,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (highlightBlank && filled == null && code.contains(blankToken))
            _BlankHighlightText(code: code, blank: blankToken)
          else
            SelectableText(
              shown,
              style: const TextStyle(
                color: Color(0xFF86EFAC),
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _BlankHighlightText extends StatelessWidget {
  const _BlankHighlightText({required this.code, required this.blank});

  final String code;
  final String blank;

  @override
  Widget build(BuildContext context) {
    final int i = code.indexOf(blank);
    if (i < 0) {
      return Text(
        code,
        style: const TextStyle(
          color: Color(0xFF86EFAC),
          fontFamily: 'monospace',
          fontSize: 14,
          height: 1.5,
        ),
      );
    }
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: Color(0xFF86EFAC),
          fontFamily: 'monospace',
          fontSize: 14,
          height: 1.5,
        ),
        children: <InlineSpan>[
          TextSpan(text: code.substring(0, i)),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: VuV2Colors.yellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: VuV2Colors.yellow),
              ),
              child: Text(
                '????',
                style: TextStyle(
                  color: VuV2Colors.yellow,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          TextSpan(text: code.substring(i + blank.length)),
        ],
      ),
    );
  }
}

class _Traffic extends StatelessWidget {
  const _Traffic(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ArrangeTray extends StatelessWidget {
  const _ArrangeTray({required this.tokens});
  final List<String> tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(VuV2Radii.md),
        border: Border.all(
          color: tokens.isEmpty
              ? VuV2Colors.stroke
              : const Color(0xFF86EFAC).withValues(alpha: 0.4),
        ),
      ),
      child: tokens.isEmpty
          ? const Text(
              'Your line appears here…',
              style: TextStyle(color: VuV2Colors.mute, fontSize: 13),
            )
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tokens
                  .map(
                    (String t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: VuV2Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          color: VuV2Colors.ink,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? VuV2Colors.orange.withValues(alpha: 0.25)
          : Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: VuV2Colors.stroke),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.tint,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final Color border = tint ?? (selected ? VuV2Colors.orange : VuV2Colors.stroke);
    return Material(
      color: tint != null
          ? tint!.withValues(alpha: 0.14)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(VuV2Radii.md),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(VuV2Radii.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VuV2Radii.md),
            border: Border.all(color: border, width: selected || tint != null ? 1.6 : 1),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w700,
              height: 1.35,
              fontFamily: 'monospace',
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.text, required this.ok});

  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final Color c = ok ? VuV2Colors.success : VuV2Colors.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(VuV2Radii.md),
        border: Border.all(color: c.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            ok ? Icons.check_circle_rounded : Icons.refresh_rounded,
            color: c,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: c,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
