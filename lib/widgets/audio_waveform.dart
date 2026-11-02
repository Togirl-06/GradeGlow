import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../utils/recording_limits.dart';

/// Horizontal bar waveform — live or static preview.
class AudioWaveform extends StatelessWidget {
  const AudioWaveform({
    super.key,
    required this.heights,
    this.barColor = const Color(0xFF8B4545),
    this.progress = 1,
    this.playheadColor = const Color(0xFF22C55E),
    this.height = 56,
  });

  final List<double> heights;
  final Color barColor;
  final double progress;
  final Color playheadColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final int count = heights.length;
    if (count == 0) return SizedBox(height: height);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double gap = 3;
          final double barWidth = math.max(2, (constraints.maxWidth - gap * (count - 1)) / count);
          final int playheadIndex = (progress.clamp(0, 1) * (count - 1)).round();

          return Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List<Widget>.generate(count, (int i) {
                  final double h = heights[i].clamp(0.08, 1.0);
                  return Padding(
                    padding: EdgeInsets.only(right: i == count - 1 ? 0 : gap),
                    child: Container(
                      width: barWidth,
                      height: height * h,
                      decoration: BoxDecoration(
                        color: barColor.withValues(alpha: i <= playheadIndex ? 0.95 : 0.45),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  );
                }),
              ),
              if (progress > 0 && progress < 1)
                Positioned(
                  left: playheadIndex * (barWidth + gap),
                  child: Container(
                    width: 2,
                    height: height,
                    color: playheadColor,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static List<double> seededHeights(int seed, {int count = 48}) {
    final math.Random random = math.Random(seed);
    return List<double>.generate(count, (_) => 0.15 + random.nextDouble() * 0.85);
  }

  static List<double> liveHeights(List<double> history, double amplitude, {int count = 48}) {
    final List<double> next = List<double>.from(history);
    if (next.length != count) {
      next
        ..clear()
        ..addAll(List<double>.filled(count, 0.12));
    }
    next.removeAt(0);
    next.add(amplitude.clamp(0.08, 1.0));
    return next;
  }
}

/// Self-contained recording panel — wave + clock run independently of parent rebuilds.
class RecordingLiveSession extends StatefulWidget {
  const RecordingLiveSession({
    super.key,
    required this.waveColor,
    required this.isPaused,
    required this.onStop,
    required this.onPause,
    this.maxDuration = RecordingLimits.maxDuration,
    this.onMaxDuration,
    this.pauseBackground = const Color(0xFF2C2C2E),
    this.stopColor = const Color(0xFFE53935),
  });

  final Color waveColor;
  final ValueListenable<bool> isPaused;
  final VoidCallback onStop;
  final VoidCallback onPause;
  final Duration maxDuration;
  final VoidCallback? onMaxDuration;
  final Color pauseBackground;
  final Color stopColor;

  @override
  State<RecordingLiveSession> createState() => RecordingLiveSessionState();
}

class RecordingLiveSessionState extends State<RecordingLiveSession>
    with SingleTickerProviderStateMixin {
  final Stopwatch _stopwatch = Stopwatch();
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  double _wavePhase = 0;
  Duration _shown = Duration.zero;
  bool _paused = false;
  bool _maxFired = false;

  // Radians/second the wave advances — derived from elapsed time, not tick
  // count, so it stays smooth and in sync with the clock even when frames drop.
  static const double _activeWaveSpeed = 2.2;
  static const double _pausedWaveSpeed = 0.4;

  Duration get elapsed {
    // The stopwatch runs only while recording (stopped during pause), so its
    // elapsed value is the true length of the recorded audio. Don't add paused
    // time — the mic isn't capturing then, so counting it would make the timer
    // (and the saved duration) longer than the audio, and playback would appear
    // to stop short.
    final Duration total = _stopwatch.elapsed;
    if (total > widget.maxDuration) return widget.maxDuration;
    return total;
  }

  @override
  void initState() {
    super.initState();
    _paused = widget.isPaused.value;
    widget.isPaused.addListener(_onPausedChanged);
    _stopwatch.start();
    _ticker = createTicker(_onTick)..start();
  }

  void _onPausedChanged() {
    final bool next = widget.isPaused.value;
    if (next == _paused) return;
    if (next) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }
    _paused = next;
    if (mounted) setState(() {});
  }

  void _onTick(Duration frameTime) {
    if (!mounted) return;
    // Advance the wave by real elapsed time between frames, so it stays smooth
    // and locked to the clock even if some frames are skipped.
    final double dtSeconds =
        (frameTime - _lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTick = frameTime;
    _wavePhase += (_paused ? _pausedWaveSpeed : _activeWaveSpeed) * dtSeconds;

    final Duration live = elapsed;
    if (live != _shown) {
      _shown = live;
      if (live >= widget.maxDuration && !_maxFired) {
        _maxFired = true;
        widget.onMaxDuration?.call();
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.isPaused.removeListener(_onPausedChanged);
    _ticker?.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RepaintBoundary(
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: CustomPaint(
              painter: _SmoothWavePainter(
                phase: _wavePhase,
                color: widget.waveColor,
                barCount: 48,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _SessionControlChip(
              label: _paused ? 'Resume' : 'Pause',
              icon: _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              background: widget.pauseBackground,
              onTap: widget.onPause,
            ),
            const SizedBox(width: 12),
            _SessionControlChip(
              label: 'Stop',
              icon: Icons.stop_rounded,
              background: widget.stopColor,
              onTap: widget.onStop,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Tap Stop when done — up to 4 hours max',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: widget.stopColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              formatRecordingDuration(_shown),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }
}

class _SessionControlChip extends StatelessWidget {
  const _SessionControlChip({
    required this.label,
    required this.icon,
    required this.background,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight animated waveform for recording — CustomPaint only, no mic polling.
class SmoothRecordingWaveform extends StatefulWidget {
  const SmoothRecordingWaveform({
    super.key,
    this.barColor = const Color(0xFF8B4545),
    this.height = 56,
    this.active = true,
    this.barCount = 48,
  });

  final Color barColor;
  final double height;
  final bool active;
  final int barCount;

  @override
  State<SmoothRecordingWaveform> createState() => _SmoothRecordingWaveformState();
}

class _SmoothRecordingWaveformState extends State<SmoothRecordingWaveform> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void didUpdateWidget(SmoothRecordingWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return SizedBox(height: widget.height);
    }

    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return CustomPaint(
              painter: _SmoothWavePainter(
                phase: _controller.value * math.pi * 2,
                color: widget.barColor,
                barCount: widget.barCount,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SmoothWavePainter extends CustomPainter {
  _SmoothWavePainter({
    required this.phase,
    required this.color,
    required this.barCount,
  });

  final double phase;
  final Color color;
  final int barCount;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    const double gap = 3;
    final double barWidth = math.max(2, (size.width - gap * (barCount - 1)) / barCount);

    for (int i = 0; i < barCount; i++) {
      final double wave = math.sin(phase + i * 0.45) * 0.5 + 0.5;
      final double heightFactor = (0.14 + wave * 0.78).clamp(0.12, 1.0);
      final double barHeight = size.height * heightFactor;
      final double left = i * (barWidth + gap);
      final double top = (size.height - barHeight) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, barHeight),
          const Radius.circular(99),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SmoothWavePainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.color != color;
  }
}

/// Smooth recording clock that updates locally without rebuilding the parent.
class RecordingElapsedDisplay extends StatefulWidget {
  const RecordingElapsedDisplay({
    super.key,
    required this.elapsed,
    this.style,
    this.onTick,
  });

  final Duration Function() elapsed;
  final TextStyle? style;
  final ValueChanged<Duration>? onTick;

  @override
  State<RecordingElapsedDisplay> createState() => _RecordingElapsedDisplayState();
}

class _RecordingElapsedDisplayState extends State<RecordingElapsedDisplay> {
  Timer? _timer;
  Duration _shown = Duration.zero;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
    _tick();
  }

  void _tick() {
    if (!mounted) return;
    final Duration live = widget.elapsed();
    if (live != _shown) {
      setState(() => _shown = live);
    }
    widget.onTick?.call(live);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatRecordingDuration(_shown),
      style: widget.style,
    );
  }
}
