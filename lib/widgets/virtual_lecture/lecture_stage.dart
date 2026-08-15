import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/virtual_lecture.dart';
import 'lecture_university_slide.dart';

/// University lecture stage — cream concept slide + AI professor strip (mockup layout).
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
    this.onSettings,
    this.onFullscreen,
    this.onSeek,
    this.onScrubStart,
    this.speedLabel = '1x',
    this.overallProgress,
    this.segmentIndex = 0,
    this.segmentCount = 1,
    this.fullscreenActive = false,
    this.utteranceProgress,
    this.forceDiagramInteractive = false,
    this.identifyTargetId,
    this.onRegionIdentified,
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
  final VoidCallback? onSettings;
  final VoidCallback? onFullscreen;
  final ValueChanged<double>? onSeek;
  final VoidCallback? onScrubStart;
  final String speedLabel;
  final double? overallProgress;
  final int segmentIndex;
  final int segmentCount;
  final bool fullscreenActive;
  final ValueListenable<double>? utteranceProgress;
  final bool forceDiagramInteractive;
  final String? identifyTargetId;
  final ValueChanged<String>? onRegionIdentified;

  @override
  State<LectureStage> createState() => _LectureStageState();
}

class _LectureStageState extends State<LectureStage> {
  double _speechProgress = 0;
  double? _dragScrub;
  bool _alive = true;
  Timer? _progressTimer;
  int _elapsedTicks = 0;
  VoidCallback? _audioListener;
  ValueListenable<double>? _listeningProgress;

  @override
  void initState() {
    super.initState();
    _attachUtteranceProgress();
    _syncProgressTimer(reset: true);
  }

  @override
  void didUpdateWidget(covariant LectureStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.utteranceProgress != widget.utteranceProgress) {
      _attachUtteranceProgress();
    }
    if (oldWidget.segment.professorSpeech != widget.segment.professorSpeech ||
        oldWidget.playing != widget.playing ||
        oldWidget.speed != widget.speed ||
        oldWidget.isSpeaking != widget.isSpeaking) {
      _syncProgressTimer(reset: oldWidget.segment.professorSpeech != widget.segment.professorSpeech);
    }
  }

  void _attachUtteranceProgress() {
    if (_listeningProgress != null && _audioListener != null) {
      _listeningProgress!.removeListener(_audioListener!);
    }
    _listeningProgress = widget.utteranceProgress;
    if (_listeningProgress == null) {
      _audioListener = null;
      return;
    }
    _audioListener = () {
      if (!_alive || !mounted) return;
      final double v = _listeningProgress!.value.clamp(0.0, 1.0);
      setState(() => _speechProgress = v);
    };
    _listeningProgress!.addListener(_audioListener!);
  }

  void _syncProgressTimer({required bool reset}) {
    _progressTimer?.cancel();
    if (widget.utteranceProgress != null) return;
    if (!widget.playing || !widget.isSpeaking) return;
    final String timingSource = widget.segment.professorSpeech.trim().isNotEmpty
        ? widget.segment.professorSpeech
        : widget.segment.caption;
    final int total = timingSource.length.clamp(1, 100000);
    if (reset) _elapsedTicks = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!_alive || !mounted) return;
      _elapsedTicks += (80 * widget.speed).round();
      final double next = (_elapsedTicks / (total * 45)).clamp(0.0, 1.0);
      setState(() => _speechProgress = next);
    });
  }

  @override
  void dispose() {
    _alive = false;
    if (_listeningProgress != null && _audioListener != null) {
      _listeningProgress!.removeListener(_audioListener!);
    }
    _progressTimer?.cancel();
    super.dispose();
  }

  double get _scrubValue {
    final int count = widget.segmentCount <= 0 ? 1 : widget.segmentCount;
    final int index = widget.segmentIndex.clamp(0, count - 1);
    return ((index + _speechProgress) / count).clamp(0.0, 1.0);
  }

  double get _displayScrub => (_dragScrub ?? _scrubValue).clamp(0.0, 1.0);

  String _fmt(double overall) {
    final int count = widget.segmentCount <= 0 ? 1 : widget.segmentCount;
    final int totalSec = (count * 50).clamp(30, 7200);
    final int cur = (overall * totalSec).round();
    String mmss(int s) {
      final int m = s ~/ 60;
      final int r = s % 60;
      return '$m:${r.toString().padLeft(2, '0')}';
    }
    return '${mmss(cur)} / ${mmss(totalSec)}';
  }

  void _onScrubChanged(double value) {
    if (!_alive || !mounted) return;
    final bool firstDrag = _dragScrub == null;
    setState(() => _dragScrub = value.clamp(0.0, 1.0));
    _progressTimer?.cancel();
    if (firstDrag) widget.onScrubStart?.call();
  }

  void _onScrubEnded(double value) {
    if (!_alive || !mounted) return;
    final double clamped = value.clamp(0.0, 1.0);
    final int count = widget.segmentCount <= 0 ? 1 : widget.segmentCount;
    final double pos = clamped * count;
    final double fraction = (pos - pos.floor()).clamp(0.0, 1.0);
    setState(() {
      _dragScrub = null;
      _speechProgress = fraction;
    });
    widget.onSeek?.call(clamped);
    _syncProgressTimer(reset: false);
  }

  @override
  Widget build(BuildContext context) {
    final String speech = widget.segment.professorSpeech.trim().isNotEmpty
        ? widget.segment.professorSpeech.trim()
        : widget.segment.caption;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 6,
              child: LectureUniversitySlide(
                frame: widget.segment.whiteboard,
                speechProgress: _speechProgress.clamp(0.0, 1.0),
                isSpeaking: widget.isSpeaking,
                khanStyle: false,
                phaseLabel: widget.phaseLabel,
                forceDiagramInteractive: widget.forceDiagramInteractive,
                identifyTargetId: widget.identifyTargetId,
                onRegionIdentified: widget.onRegionIdentified,
                professorSpeech: speech,
              ),
            ),
            _ProfessorStrip(
              speech: speech,
              speaking: widget.isSpeaking,
              playing: widget.playing,
              scrub: _displayScrub,
              timeLabel: _fmt(_displayScrub),
              speedLabel: widget.speedLabel,
              onPlayPause: widget.onPlayPause,
              onSpeed: widget.onSpeed,
              onScrubChanged: widget.onSeek == null ? null : _onScrubChanged,
              onScrubEnded: widget.onSeek == null ? null : _onScrubEnded,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessorStrip extends StatelessWidget {
  const _ProfessorStrip({
    required this.speech,
    required this.speaking,
    required this.playing,
    required this.scrub,
    required this.timeLabel,
    required this.speedLabel,
    this.onPlayPause,
    this.onSpeed,
    this.onScrubChanged,
    this.onScrubEnded,
  });

  final String speech;
  final bool speaking;
  final bool playing;
  final double scrub;
  final String timeLabel;
  final String speedLabel;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSpeed;
  final ValueChanged<double>? onScrubChanged;
  final ValueChanged<double>? onScrubEnded;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B1220),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            speaking || playing ? 'AI PROFESSOR IS SPEAKING' : 'AI PROFESSOR',
            style: const TextStyle(
              color: Color(0xFF2DD4BF),
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF134E4A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2DD4BF), width: 1.5),
                ),
                child: const Text(
                  'Dr',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 72, maxHeight: 148),
                  child: SingleChildScrollView(
                    child: Text(
                      speech.isEmpty ? 'Listening…' : '"$speech"',
                      style: const TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontSize: 13.5,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              IconButton(
                onPressed: onPlayPause,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: const Color(0xFFF59E0B),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFFF59E0B),
                  ),
                  child: Slider(
                    value: scrub,
                    onChanged: onScrubChanged,
                    onChangeEnd: onScrubEnded,
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
              const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 20),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              timeLabel,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
