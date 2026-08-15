import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../models/virtual_lecture.dart';
import 'khan_lecture_colors.dart';
import 'lecture_caption_bar.dart';
import 'lecture_whiteboard.dart';

/// Khan Academy–style AI video lecture — dark chalkboard + video chrome.
class LectureStage extends StatefulWidget {
  const LectureStage({
    super.key,
    required this.segment,
    required this.topicTitle,
    required this.phaseLabel,
    required this.isSpeaking,
    required this.segmentProgress,
    this.speed = 1,
    this.playing = false,
    this.onPlayPause,
    this.onSpeed,
    this.onSeek,
    this.onScrubStart,
    this.speedLabel = '1x',
    this.overallProgress,
    this.segmentIndex = 0,
    this.segmentCount = 1,
  });

  final LectureSegment segment;
  final String topicTitle;
  final String phaseLabel;
  final bool isSpeaking;
  final double segmentProgress;
  final double speed;
  final bool playing;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSpeed;
  /// Called with overall lecture progress 0–1 when the user releases the scrubber.
  final ValueChanged<double>? onSeek;
  /// Called once when the user begins dragging the scrubber (pause voice).
  final VoidCallback? onScrubStart;
  final String speedLabel;
  final double? overallProgress;
  final int segmentIndex;
  final int segmentCount;

  @override
  State<LectureStage> createState() => _LectureStageState();
}

class _LectureStageState extends State<LectureStage> {
  double _speechProgress = 0;
  double? _dragScrub;
  bool _alive = true;
  bool _chromeVisible = true;
  Timer? _progressTimer;
  int _elapsedTicks = 0;

  @override
  void initState() {
    super.initState();
    _syncProgressTimer(reset: true);
  }

  @override
  void didUpdateWidget(LectureStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool segmentChanged = oldWidget.segmentIndex != widget.segmentIndex ||
        oldWidget.segment.professorSpeech != widget.segment.professorSpeech ||
        oldWidget.segment.caption != widget.segment.caption ||
        oldWidget.segment.whiteboard.title != widget.segment.whiteboard.title ||
        oldWidget.segment.whiteboard.kind != widget.segment.whiteboard.kind;

    if (segmentChanged) {
      _speechProgress = 0;
      _elapsedTicks = 0;
      _dragScrub = null;
      _chromeVisible = true;
      _syncProgressTimer(reset: true);
      return;
    }

    if (oldWidget.playing != widget.playing ||
        oldWidget.isSpeaking != widget.isSpeaking ||
        oldWidget.speed != widget.speed) {
      _syncProgressTimer(reset: false);
    }
  }

  /// Advance while the lecture is playing (not only while TTS reports speaking),
  /// so the scrubber thumb keeps moving during the lesson.
  void _syncProgressTimer({required bool reset}) {
    _progressTimer?.cancel();
    _progressTimer = null;
    if (reset) {
      _elapsedTicks = 0;
      _speechProgress = 0;
    }
    if (!_alive || !widget.playing || _dragScrub != null) return;

    final String timingSource = widget.segment.professorSpeech.trim().isNotEmpty
        ? widget.segment.professorSpeech
        : widget.segment.caption;
    if (timingSource.isEmpty) {
      _scheduleProgress(1);
      return;
    }

    final int total = timingSource.length.clamp(1, 100000);
    final int msPerTick = (40 / widget.speed).round().clamp(16, 80);
    final int charsPerTick = (total / 120).ceil().clamp(1, 12);

    _progressTimer = Timer.periodic(Duration(milliseconds: msPerTick), (Timer t) {
      if (!_alive || !mounted || !widget.playing || _dragScrub != null) {
        t.cancel();
        return;
      }
      _elapsedTicks += charsPerTick;
      if (_elapsedTicks >= total) {
        t.cancel();
        _scheduleProgress(1);
        return;
      }
      _scheduleProgress(_elapsedTicks / total);
    });
  }

  void _scheduleProgress(double value) {
    if (!_alive) return;
    final double clamped = value.clamp(0.0, 1.0);
    if ((clamped - _speechProgress).abs() < 0.008 && clamped < 0.999) return;

    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      if (!mounted) return;
      setState(() => _speechProgress = clamped);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_alive || !mounted) return;
      if ((clamped - _speechProgress).abs() < 0.008 && clamped < 0.999) return;
      setState(() => _speechProgress = clamped);
    });
  }

  @override
  void dispose() {
    _alive = false;
    _progressTimer?.cancel();
    _progressTimer = null;
    super.dispose();
  }

  double get _scrubValue {
    final int count = widget.segmentCount <= 0 ? 1 : widget.segmentCount;
    final int index = widget.segmentIndex.clamp(0, count - 1);
    return ((index + _speechProgress) / count).clamp(0.0, 1.0);
  }

  double get _displayScrub => (_dragScrub ?? _scrubValue).clamp(0.0, 1.0);

  void _onScrubChanged(double value) {
    if (!_alive || !mounted) return;
    final bool firstDrag = _dragScrub == null;
    setState(() => _dragScrub = value.clamp(0.0, 1.0));
    _progressTimer?.cancel();
    _progressTimer = null;
    if (firstDrag) {
      widget.onScrubStart?.call();
    }
  }

  void _onScrubEnded(double value) {
    if (!_alive || !mounted) return;
    final double clamped = value.clamp(0.0, 1.0);
    setState(() => _dragScrub = null);
    widget.onSeek?.call(clamped);
    _syncProgressTimer(reset: false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_alive || !mounted) return;
        setState(() => _chromeVisible = !_chromeVisible);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              LectureWhiteboard(
                frame: widget.segment.whiteboard,
                speechProgress: _speechProgress,
                isSpeaking: widget.isSpeaking,
                khanStyle: true,
              ),
              const Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Text(
                  'GradeGlow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Opacity(
                  opacity: _chromeVisible ? 1 : 0.35,
                  child: _KhanVideoChrome(
                    caption: widget.segment.caption,
                    title: widget.topicTitle,
                    playing: widget.playing,
                    scrubValue: _displayScrub,
                    speedLabel: widget.speedLabel,
                    onPlayPause: widget.onPlayPause,
                    onSpeed: widget.onSpeed,
                    onScrubChanged: widget.onSeek == null ? null : _onScrubChanged,
                    onScrubEnded: widget.onSeek == null ? null : _onScrubEnded,
                    interactive: _chromeVisible,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KhanVideoChrome extends StatelessWidget {
  const _KhanVideoChrome({
    required this.caption,
    required this.title,
    required this.playing,
    required this.scrubValue,
    required this.speedLabel,
    this.onPlayPause,
    this.onSpeed,
    this.onScrubChanged,
    this.onScrubEnded,
    this.interactive = true,
  });

  final String caption;
  final String title;
  final bool playing;
  final double scrubValue;
  final String speedLabel;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSpeed;
  final ValueChanged<double>? onScrubChanged;
  final ValueChanged<double>? onScrubEnded;
  final bool interactive;

  static const SliderThemeData _sliderTheme = SliderThemeData(
    trackHeight: 3,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
    activeTrackColor: KhanLectureColors.scrubber,
    inactiveTrackColor: Colors.white24,
    thumbColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    final bool canScrub = interactive && onScrubChanged != null;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            KhanLectureColors.chrome,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LectureCaptionBar(caption: caption),
            SliderTheme(
              data: _sliderTheme,
              child: Slider(
                value: scrubValue.clamp(0, 1),
                onChanged: canScrub ? onScrubChanged : null,
                onChangeEnd: canScrub ? onScrubEnded : null,
              ),
            ),
            IgnorePointer(
              ignoring: !interactive,
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: onPlayPause,
                    icon: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onSpeed,
                    child: Text(
                      speedLabel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Icon(Icons.settings_outlined, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  const Icon(Icons.fullscreen_rounded, color: Colors.white70, size: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
