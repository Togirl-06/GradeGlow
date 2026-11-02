import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/mathematics_degree_theme.dart';

/// Typewriter-style professor dialogue — feels like live teaching, not a textbook.
class LectureSpeechBubble extends StatefulWidget {
  const LectureSpeechBubble({
    super.key,
    required this.speech,
    required this.isSpeaking,
    this.speed = 1,
  });

  final String speech;
  final bool isSpeaking;
  final double speed;

  @override
  State<LectureSpeechBubble> createState() => _LectureSpeechBubbleState();
}

class _LectureSpeechBubbleState extends State<LectureSpeechBubble> {
  int _visibleChars = 0;
  Timer? _typeTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(LectureSpeechBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speech != widget.speech) {
      _startTyping();
    } else if (widget.isSpeaking && !oldWidget.isSpeaking) {
      _startTyping();
    }
  }

  void _startTyping() {
    _typeTimer?.cancel();
    _visibleChars = 0;
    if (widget.speech.isEmpty) return;

    final int msPerChar = (28 / widget.speed).round().clamp(12, 48);
    _typeTimer = Timer.periodic(Duration(milliseconds: msPerChar), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_visibleChars >= widget.speech.length) {
        timer.cancel();
        return;
      }
      setState(() => _visibleChars += 1);
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);
    final String visible = widget.speech.substring(0, _visibleChars.clamp(0, widget.speech.length));
    final bool complete = _visibleChars >= widget.speech.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isSpeaking ? c.primary.withValues(alpha: 0.45) : c.border,
          width: widget.isSpeaking ? 1.5 : 1,
        ),
        boxShadow: widget.isSpeaking
            ? <BoxShadow>[
                BoxShadow(
                  color: c.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.record_voice_over_rounded, size: 16, color: c.primary),
              const SizedBox(width: 6),
              Text(
                widget.isSpeaking ? 'Professor is teaching…' : 'Professor',
                style: TextStyle(
                  color: c.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
              if (widget.isSpeaking) ...<Widget>[
                const Spacer(),
                _SpeakingDots(color: c.primary),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            visible,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 16,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!complete && widget.isSpeaking)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                width: 8,
                height: 16,
                color: c.primary.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpeakingDots extends StatefulWidget {
  const _SpeakingDots({required this.color});

  final Color color;

  @override
  State<_SpeakingDots> createState() => _SpeakingDotsState();
}

class _SpeakingDotsState extends State<_SpeakingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(3, (int i) {
            final double phase = (_controller.value + i * 0.2) % 1.0;
            final double opacity = 0.35 + (phase < 0.5 ? phase : 1 - phase);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
