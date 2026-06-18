import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/study_theme.dart';

/// Animated mic level bars (ChatGPT-style voice note waveform).
class VoiceNoteWaveform extends StatefulWidget {
  const VoiceNoteWaveform({
    super.key,
    required this.level,
    this.barCount = 28,
    this.height = 28,
  });

  /// Normalized 0–1 mic level.
  final double level;
  final int barCount;
  final double height;

  @override
  State<VoiceNoteWaveform> createState() => _VoiceNoteWaveformState();
}

class _VoiceNoteWaveformState extends State<VoiceNoteWaveform> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  final Random _random = Random();
  late List<double> _bars;

  @override
  void initState() {
    super.initState();
    _bars = List<double>.generate(widget.barCount, (_) => 0.15);
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 90))
      ..addListener(_tick)
      ..repeat();
  }

  void _tick() {
    final double level = widget.level.clamp(0.0, 1.0);
    setState(() {
      for (int i = 0; i < _bars.length; i++) {
        final double wave = sin((i * 0.55) + (_pulse.value * pi * 2));
        final double target = (0.12 + level * (0.35 + wave.abs() * 0.45)).clamp(0.08, 1.0);
        _bars[i] = _bars[i] * 0.55 + target * 0.45 + _random.nextDouble() * 0.04 * level;
      }
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color barColor = StudyColors.textSecondary(Theme.of(context).brightness);

    return SizedBox(
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List<Widget>.generate(_bars.length, (int i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                height: widget.height * _bars[i],
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.35 + _bars[i] * 0.55),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// ChatGPT-style voice note bar: + · waveform/transcript · cancel · send.
class VoiceNoteRecorderBar extends StatelessWidget {
  const VoiceNoteRecorderBar({
    super.key,
    required this.liveTranscript,
    required this.level,
    required this.isTranscribing,
    required this.onAdd,
    required this.onCancel,
    required this.onConfirm,
  });

  final String liveTranscript;
  final double level;
  final bool isTranscribing;
  final VoidCallback onAdd;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color fill = brightness == Brightness.dark
        ? const Color(0xFF2F2F2F)
        : StudyColors.surfaceElevated(brightness);
    final Color border = StudyColors.border(brightness);
    final Color textColor = StudyColors.textPrimary(brightness);
    final Color hintColor = StudyColors.textSecondary(brightness);
    final String text = liveTranscript.trim();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(6, 8, 8, 8),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: border),
      ),
      child: Row(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isTranscribing ? null : onAdd,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.add_rounded, size: 26, color: hintColor),
              ),
            ),
          ),
          Expanded(
            child: isTranscribing
                ? Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text('Transcribing…', style: TextStyle(color: hintColor)),
                    ],
                  )
                : text.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          VoiceNoteWaveform(level: level),
                          const SizedBox(height: 6),
                          Text(
                            'Recording… speak for 2+ seconds, then tap ✓',
                            style: TextStyle(color: hintColor, fontSize: 12),
                          ),
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              text,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textColor, fontSize: 15, height: 1.35),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 72,
                            child: VoiceNoteWaveform(level: level, barCount: 12),
                          ),
                        ],
                      ),
          ),
          IconButton(
            tooltip: 'Cancel',
            onPressed: isTranscribing ? null : onCancel,
            icon: Icon(Icons.close_rounded, color: hintColor),
          ),
          Material(
            color: StudyColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: isTranscribing ? null : onConfirm,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.check_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
