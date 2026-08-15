import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/mathematics_degree_theme.dart';

/// Raise-hand interrupt — professor answers, can expand lecture, then resume.
class LectureAskOverlay extends StatefulWidget {
  const LectureAskOverlay({
    super.key,
    required this.onSubmit,
    required this.onDismiss,
    this.onExpandLecture,
    this.busy = false,
    this.answer,
    this.question,
  });

  final Future<void> Function(String question) onSubmit;
  final VoidCallback onDismiss;
  final VoidCallback? onExpandLecture;
  final bool busy;
  final String? answer;
  final String? question;

  static const List<String> quickPrompts = <String>[
    'Explain this in more detail.',
    'Show another proof.',
    'Give five more examples.',
    'Explain this visually.',
    'What are common mistakes here?',
  ];

  @override
  State<LectureAskOverlay> createState() => _LectureAskOverlayState();
}

class _LectureAskOverlayState extends State<LectureAskOverlay> {
  final TextEditingController _controller = TextEditingController();
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _showAnswer = widget.answer != null;
    if (widget.question != null) _controller.text = widget.question!;
  }

  @override
  void didUpdateWidget(LectureAskOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.answer != null && oldWidget.answer == null) {
      setState(() => _showAnswer = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String text) async {
    final String q = text.trim();
    if (q.isEmpty || widget.busy) return;
    await widget.onSubmit(q);
  }

  @override
  Widget build(BuildContext context) {
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);

    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).top -
                  MediaQuery.paddingOf(context).bottom -
                  40,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.pan_tool_alt_rounded, color: c.primaryLight, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Lecture paused — ask or go deeper',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.busy ? null : widget.onDismiss,
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _showAnswer ? _buildAnswer(c) : _buildQuestionForm(c),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionForm(MathematicsDegreeColors c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Ask for more depth — the lecture can expand without restarting.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), height: 1.4),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: LectureAskOverlay.quickPrompts.map((String prompt) {
            return ActionChip(
              label: Text(prompt, style: const TextStyle(fontSize: 12)),
              onPressed: widget.busy
                  ? null
                  : () {
                      _controller.text = prompt;
                      unawaited(_submit(prompt));
                    },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          autofocus: true,
          enabled: !widget.busy,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Or type your own question…',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: c.primaryLight),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: widget.busy ? null : () => _submit(_controller.text),
          icon: widget.busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_rounded),
          label: Text(widget.busy ? 'Professor is thinking…' : 'Ask Professor'),
        ),
      ],
    );
  }

  Widget _buildAnswer(MathematicsDegreeColors c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.primary.withValues(alpha: 0.4)),
          ),
          child: Text(
            widget.answer ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.55),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.onExpandLecture != null)
          OutlinedButton.icon(
            onPressed: widget.busy ? null : widget.onExpandLecture,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: c.primaryLight),
            ),
            icon: const Icon(Icons.draw_outlined),
            label: const Text('Add to lecture — teach more on the board'),
          ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: widget.onDismiss,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Resume Lecture'),
        ),
      ],
    );
  }
}
