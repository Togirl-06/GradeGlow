import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/mathematics_degree_theme.dart';

enum LectureAskMode { ask, confused }

/// Pause overlay — student picks a prompt or writes a question; professor answers.
class LectureAskOverlay extends StatefulWidget {
  const LectureAskOverlay({
    super.key,
    required this.onSubmit,
    required this.onDismiss,
    this.mode = LectureAskMode.ask,
    this.busy = false,
    this.answer,
    this.question,
    this.topicHint,
    this.onAskAgain,
  });

  final Future<void> Function(String question) onSubmit;
  final VoidCallback onDismiss;
  final LectureAskMode mode;
  final bool busy;
  final String? answer;
  final String? question;
  final String? topicHint;
  final VoidCallback? onAskAgain;

  static const List<String> askPrompts = <String>[
    'Explain this in more detail.',
    'Give me another example.',
    'Explain this visually.',
    'What are common mistakes here?',
    'Why does this matter?',
  ];

  static const List<String> confusedPrompts = <String>[
    'I do not understand the definition.',
    'The example does not make sense.',
    'Explain this more simply.',
    'Give me a new analogy.',
    'Show a fresh example.',
    'What am I missing?',
  ];

  @override
  State<LectureAskOverlay> createState() => _LectureAskOverlayState();
}

class _LectureAskOverlayState extends State<LectureAskOverlay> {
  final TextEditingController _controller = TextEditingController();
  bool _showAnswer = false;

  bool get _confused => widget.mode == LectureAskMode.confused;

  List<String> get _prompts =>
      _confused ? LectureAskOverlay.confusedPrompts : LectureAskOverlay.askPrompts;

  @override
  void initState() {
    super.initState();
    _showAnswer = widget.answer != null && widget.answer!.trim().isNotEmpty;
    if (widget.question != null && widget.question!.trim().isNotEmpty) {
      _controller.text = widget.question!;
    }
  }

  @override
  void didUpdateWidget(LectureAskOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String? answer = widget.answer;
    if (answer != null &&
        answer.trim().isNotEmpty &&
        answer != oldWidget.answer) {
      setState(() => _showAnswer = true);
    }
    if (widget.question != oldWidget.question &&
        widget.question != null &&
        widget.question!.trim().isNotEmpty &&
        !widget.busy) {
      _controller.text = widget.question!;
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
                    Icon(
                      _confused
                          ? Icons.help_outline_rounded
                          : Icons.chat_bubble_outline_rounded,
                      color: c.primaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _confused
                            ? 'What are you confused about?'
                            : 'Ask the professor',
                        style: const TextStyle(
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
    final String topic = widget.topicHint?.trim() ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          _confused
              ? 'Pick a reason below, or write what confuses you. The professor will answer before you resume.'
              : 'Pick a prompt, or write your own question. The professor will answer before you resume.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), height: 1.4),
        ),
        if (topic.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            'Current topic: $topic',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.primaryLight.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _prompts.map((String prompt) {
            return ActionChip(
              label: Text(prompt, style: const TextStyle(fontSize: 12)),
              onPressed: widget.busy
                  ? null
                  : () {
                      _controller.text = prompt;
                      setState(() {});
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
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.send,
          onSubmitted: widget.busy ? null : (String v) => _submit(v),
          decoration: InputDecoration(
            hintText: _confused
                ? 'Write what confuses you…'
                : 'Write your question…',
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
          label: Text(
            widget.busy
                ? 'Professor is answering…'
                : (_confused ? 'Get a clearer explanation' : 'Ask Professor'),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswer(MathematicsDegreeColors c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Professor\'s answer',
          style: TextStyle(
            color: c.primaryLight,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 12),
        TextButton(
          onPressed: widget.busy
              ? null
              : () {
                  widget.onAskAgain?.call();
                  setState(() => _showAnswer = false);
                },
          child: const Text(
            'Ask another question',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 4),
        FilledButton.icon(
          onPressed: widget.onDismiss,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Resume Lecture'),
        ),
      ],
    );
  }
}
