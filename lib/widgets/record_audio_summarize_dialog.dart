import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../config/app_config.dart';
import '../services/mic_capture_service.dart';
import '../services/openai_whisper_service.dart';
import '../services/recording_bin_service.dart';
import '../services/lecture_recording_service.dart';
import '../services/subscription_service.dart';
import '../theme/study_theme.dart';
import '../utils/lecture_record_config.dart';
import '../utils/premium_access.dart';
import '../utils/recording_limits.dart';
import '../utils/study_messenger.dart';
import '../utils/wav_header_repair.dart';
import 'audio_waveform.dart';
import 'recording_bin_sheet.dart';

enum _RecordStep { ready, recording, review, transcript, summarizing }

class TranscriptSegment {
  const TranscriptSegment({required this.start, required this.text});

  final Duration start;
  final String text;
}

/// Studley-style record flow: record → review → transcript → summarize.
class RecordAudioSummarizeDialog extends StatefulWidget {
  const RecordAudioSummarizeDialog({
    super.key,
    required this.onSummarize,
  });

  final Future<void> Function(String audioFilePath, String transcript) onSummarize;

  static Future<bool> show(
    BuildContext context, {
    required Future<void> Function(String audioFilePath, String transcript) onSummarize,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (BuildContext context) => RecordAudioSummarizeDialog(onSummarize: onSummarize),
    ).then((bool? value) => value ?? false);
  }

  @override
  State<RecordAudioSummarizeDialog> createState() => _RecordAudioSummarizeDialogState();
}

class _RecordAudioSummarizeDialogState extends State<RecordAudioSummarizeDialog> {
  static const Color _surface = Color(0xFF1A1A1C);
  static const Color _inner = Color(0xFF141416);
  static const Color _stopRed = Color(0xFFE53935);
  static const Color _pauseBg = Color(0xFF2C2C2E);

  final MicCaptureService _mic = MicCaptureService.instance;
  AudioPlayer? _player;
  bool _playerBound = false;
  String? _playbackTempPath;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<void>? _completeSub;

  final ValueNotifier<bool> _pausedNotifier = ValueNotifier<bool>(false);
  GlobalKey<RecordingLiveSessionState>? _recordingSessionKey;

  _RecordStep _step = _RecordStep.ready;
  bool _savingRecording = false;
  Duration _recordedDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  String? _filePath;
  Uint8List? _recordingBytes;
  bool _playing = false;
  double _playbackVolume = 0.8;
  bool _loadingTranscript = false;
  bool _actionBusy = false;
  String? _inlineMessage;
  bool _inlineIsError = false;
  String? _transcript;
  final TextEditingController _transcriptController = TextEditingController();
  List<TranscriptSegment> _segments = <TranscriptSegment>[];
  List<double> _waveHeights = AudioWaveform.seededHeights(42);
  int _waveSeed = 42;

  @override
  void initState() {
    super.initState();
    _mic.onUnexpectedStop = _handleUnexpectedMicStop;
    unawaited(context.read<RecordingBinService>().ensureLoaded());
  }

  void _handleUnexpectedMicStop() {
    if (!mounted || _step != _RecordStep.recording || _savingRecording) return;
    _pausedNotifier.value = false;
    _recordingSessionKey = null;
    setState(() {
      _step = _RecordStep.ready;
      _filePath = null;
      _recordingBytes = null;
    });
    _showError('Microphone stopped unexpectedly. Tap the mic to try again.');
  }

  Future<AudioPlayer> _ensurePlayer() async {
    final AudioPlayer? existing = _player;
    if (existing != null) {
      if (!_playerBound) _bindPlayer();
      return existing;
    }
    final AudioPlayer player = AudioPlayer();
    _player = player;
    _bindPlayer();
    await _initPlayer();
    return player;
  }

  Future<void> _initPlayer() async {
    final AudioPlayer? player = _player;
    if (player == null) return;
    try {
      await player.setPlayerMode(PlayerMode.mediaPlayer);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(_playbackVolume);
    } catch (_) {}
  }

  Future<void> _setPlaybackVolume(double volume) async {
    final double clamped = volume.clamp(0.0, 1.0);
    setState(() => _playbackVolume = clamped);
    final AudioPlayer? player = _player;
    if (player == null) return;
    try {
      await player.setVolume(clamped);
    } catch (_) {}
  }

  IconData get _volumeIcon {
    if (_playbackVolume <= 0) return Icons.volume_off_outlined;
    if (_playbackVolume < 0.5) return Icons.volume_down_outlined;
    return Icons.volume_up_outlined;
  }

  Future<void> _downloadRecording() async {
    final SubscriptionService subs = context.read<SubscriptionService>();
    if (!await PremiumAccess.checkAndPrompt(context, subs, feature: PremiumFeature.exportContent)) {
      return;
    }

    final Uint8List? bytes = await _readRecordingBytes();
    if (bytes == null) {
      _showError('Recording file not found.');
      return;
    }

    final String fileName = _downloadFileName();

    try {
      final String? savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save lecture recording',
        fileName: fileName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: <String>[_recordingExtension],
      );
      if (!mounted) return;
      if (savedPath == null && !kIsWeb) {
        return;
      }
      StudyMessenger.showInfo(
        context,
        kIsWeb ? 'Download started' : 'Recording saved',
      );
    } catch (error) {
      if (!mounted) return;
      _showError('Could not download recording. ${StudyMessenger.clean(error)}');
    }
  }

  AudioContext get _playbackAudioContext {
    if (kIsWeb) {
      return AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playAndRecord,
          options: <AVAudioSessionOptions>{
            AVAudioSessionOptions.defaultToSpeaker,
            AVAudioSessionOptions.allowBluetooth,
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          audioMode: AndroidAudioMode.normal,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      );
    }

    return AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: <AVAudioSessionOptions>{
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        audioMode: AndroidAudioMode.normal,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    );
  }

  Future<void> _prepareForPlayback() async {
    if (!kIsWeb) {
      await _mic.prepareForPlayback();
    }
    final AudioPlayer player = await _ensurePlayer();
    await AudioPlayer.global.setAudioContext(_playbackAudioContext);
    await player.setAudioContext(_playbackAudioContext);
    await player.setPlayerMode(PlayerMode.mediaPlayer);
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setVolume(_playbackVolume);
  }

  Future<bool> _waitForPlaybackStarted({Duration timeout = const Duration(seconds: 5)}) async {
    final AudioPlayer? player = _player;
    if (player == null) return false;
    if (player.state == PlayerState.playing) return true;

    final Stopwatch stopwatch = Stopwatch()..start();
    Duration? lastPosition;

    while (stopwatch.elapsed < timeout) {
      if (player.state == PlayerState.playing) return true;
      try {
        final Duration? position = await player.getCurrentPosition();
        if (position != null && position.inMilliseconds > 0) {
          if (lastPosition != null && position > lastPosition) return true;
          lastPosition = position;
        }
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return player.state == PlayerState.playing;
  }

  String _playbackFailedMessage([Object? error]) {
    if (error != null) {
      final String detail = StudyMessenger.clean(error);
      if (detail.contains('MissingPluginException')) {
        return 'Could not play recording. Stop the app completely, then run flutter run to reinstall.';
      }
      if (detail.isNotEmpty && !detail.startsWith('Could not play')) {
        return 'Could not play recording. $detail';
      }
    }
    return 'Could not play recording. Try again, or tap Next to transcribe without preview.';
  }

  String get _recordingExtension => lectureRecordingExtension();

  String _downloadFileName() {
    final String ext = _recordingExtension;
    final String path = _filePath ?? '';
    String candidate = path.split(RegExp(r'[/\\]')).last.split('?').first.trim();
    if (candidate.isEmpty ||
        candidate.startsWith('blob:') ||
        !candidate.contains('.') ||
        candidate.length > 96) {
      return 'lecture_recording_${DateTime.now().millisecondsSinceEpoch}.$ext';
    }
    if (!candidate.toLowerCase().endsWith('.$ext')) {
      final int dot = candidate.lastIndexOf('.');
      if (dot > 0) {
        candidate = candidate.substring(0, dot);
      }
      return '$candidate.$ext';
    }
    return candidate;
  }

  Future<String> _nextRecordingPath() async {
    final String name = 'lecture_${DateTime.now().millisecondsSinceEpoch}.$_recordingExtension';
    if (kIsWeb) return name;
    final Directory dir = await getTemporaryDirectory();
    return '${dir.path}/$name';
  }

  Future<Uint8List?> _readRecordingBytes({bool requireTranscriptLength = false}) async {
    final Uint8List? cached = _recordingBytes ?? _mic.lastWavBytes;
    if (cached != null && cached.isNotEmpty) {
      if (!requireTranscriptLength || cached.length >= 500) {
        _recordingBytes = cached;
        return cached;
      }
    }

    final String? path = _filePath;
    if (path == null || kIsWeb) return null;

    final File file = File(path);
    if (!await file.exists()) return null;

    final int length = await file.length();
    if (length <= 0) return null;
    if (requireTranscriptLength && length < 500) return null;

    final Uint8List bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    if (requireTranscriptLength && bytes.length < 500) return null;

    _recordingBytes = bytes;
    return bytes;
  }

  Future<bool> _recordingSourceReady() async {
    final Uint8List? bytes = _recordingBytes ?? _mic.lastWavBytes;
    if (bytes != null && bytes.length > 44) return true;
    final String? path = _filePath;
    if (path == null) return false;
    if (kIsWeb) return bytes != null && bytes.isNotEmpty;
    return File(path).exists();
  }

  void _clearInlineMessage() {
    if (_inlineMessage == null) return;
    setState(() {
      _inlineMessage = null;
      _inlineIsError = false;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _inlineMessage = message;
      _inlineIsError = true;
    });
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      StudyMessenger.showError(context, message);
    }
  }

  void _showInfo(String message) {
    if (!mounted) return;
    setState(() {
      _inlineMessage = message;
      _inlineIsError = false;
    });
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      StudyMessenger.showInfo(context, message);
    }
  }

  Future<bool> _finalizeRecording() async {
    try {
      final String? stoppedPath = await _mic.stop();
      final Uint8List? wavBytes = _mic.lastWavBytes;
      if (stoppedPath == null || wavBytes == null || wavBytes.length <= 44) {
        _recordingBytes = null;
        return false;
      }
      _filePath = stoppedPath;
      _recordingBytes = wavBytes;
      return true;
    } catch (error) {
      debugPrint('Finalize recording failed: $error');
      _recordingBytes = null;
      return false;
    }
  }

  void _bindPlayer() {
    final AudioPlayer? player = _player;
    if (player == null || _playerBound) return;
    _playerBound = true;
    _positionSub = player.onPositionChanged.listen((Duration position) {
      if (!mounted) return;
      setState(() => _playbackPosition = position);
    });
    _durationSub = player.onDurationChanged.listen((Duration duration) {
      if (!mounted || duration <= Duration.zero) return;
      if (duration > _recordedDuration) {
        setState(() => _recordedDuration = duration);
      }
    });
    _stateSub = player.onPlayerStateChanged.listen((PlayerState state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });
    _completeSub = player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _playbackPosition = _recordedDuration;
      });
    });
  }

  @override
  void dispose() {
    if (_mic.onUnexpectedStop == _handleUnexpectedMicStop) {
      _mic.onUnexpectedStop = null;
    }
    _pausedNotifier.dispose();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    _transcriptController.dispose();
    final AudioPlayer? player = _player;
    if (player != null) {
      unawaited(player.dispose());
    }
    unawaited(_deletePlaybackTempFile());
    super.dispose();
  }

  String _formatDuration(Duration d) => formatRecordingDuration(d);

  String _formatRemaining(Duration position, Duration total) {
    final Duration left = total - position;
    if (left.isNegative) return '-0:00';
    return '-${_formatDuration(left)}';
  }

  double get _playbackProgress {
    final int totalMs = _recordedDuration.inMilliseconds;
    if (totalMs == 0) return 0;
    return (_playbackPosition.inMilliseconds / totalMs).clamp(0, 1);
  }

  Duration get _activeRecordingDuration =>
      _recordingSessionKey?.currentState?.elapsed ?? Duration.zero;

  Future<void> _releasePlayer() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _stateSub?.cancel();
    await _completeSub?.cancel();
    _positionSub = null;
    _durationSub = null;
    _stateSub = null;
    _completeSub = null;
    final AudioPlayer? player = _player;
    if (player != null) {
      try {
        await player.stop();
      } catch (_) {}
      await player.dispose();
    }
    _player = null;
    _playerBound = false;
    _playing = false;
    _playbackPosition = Duration.zero;
    await _deletePlaybackTempFile();
  }

  Future<void> _deletePlaybackTempFile() async {
    final String? tmp = _playbackTempPath;
    _playbackTempPath = null;
    if (tmp == null || kIsWeb) return;
    try {
      final File file = File(tmp);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  /// Native playback is most reliable from a rebuilt temp file on disk.
  Future<Source?> _resolvePlaybackSource() async {
    final String? path = _filePath;
    if (path == null) return null;

    final Uint8List? bytes = await _readRecordingBytes();

    if (kIsWeb) {
      if (bytes != null && bytes.isNotEmpty) {
        return BytesSource(bytes);
      }
      if (path.startsWith('blob:') || path.startsWith('http')) {
        return UrlSource(path);
      }
      return null;
    }

    if (bytes == null || bytes.length <= 44) return null;

    final Uint8List rebuilt = rebuildWavBytes(bytes, sampleRate: lectureRecordingSampleRate());
    await _deletePlaybackTempFile();
    final Directory dir = await getTemporaryDirectory();
    final String tmpPath = '${dir.path}/lecture_playback_${DateTime.now().millisecondsSinceEpoch}.wav';
    await File(tmpPath).writeAsBytes(rebuilt, flush: true);
    _playbackTempPath = tmpPath;
    return DeviceFileSource(tmpPath);
  }

  Future<bool> _playSource(Source source, {Duration? position}) async {
    final AudioPlayer player = await _ensurePlayer();
    await _prepareForPlayback();
    await player.stop();
    await player.setVolume(_playbackVolume);
    if (position != null && position > Duration.zero) {
      await player.play(source, position: position);
    } else {
      await player.play(source);
    }
    unawaited(_waitForPlayerDuration(player, minimum: _recordedDuration));
    return _waitForPlaybackStarted();
  }

  Future<void> _startRecording() async {
    if (!AppConfig.hasOpenAi) {
      _showError('Add OPENAI_API_KEY to your .env file.');
      return;
    }

    final LectureRecordingService background = context.read<LectureRecordingService>();
    if (background.isActive) {
      _showError('Finish the lecture recording bar first, then try again.');
      return;
    }

    try {
      await _releasePlayer();

      if (!kIsWeb) {
        final PermissionStatus mic = await Permission.microphone.request();
        if (!mic.isGranted) {
          _showError('Microphone permission is required to record.');
          return;
        }
      }

      final bool permitted = await _mic.recorder.hasPermission();
      if (!permitted) {
        _showError(
          kIsWeb
              ? 'Microphone blocked. Click the lock icon in your browser address bar and allow the mic.'
              : 'Microphone permission is required to record.',
        );
        return;
      }

      final RecordConfig config = lectureStreamRecordConfig();
      if (kIsWeb) {
        final bool supported = await _mic.recorder.isEncoderSupported(config.encoder);
        if (!supported) {
          _showError('Audio recording is not supported in this browser.');
          return;
        }
      }

      final String path = await _nextRecordingPath();
      _recordingBytes = null;
      await _mic.start(path: path);

      _waveSeed = DateTime.now().millisecondsSinceEpoch;
      _waveHeights = AudioWaveform.seededHeights(_waveSeed);
      _recordingSessionKey = GlobalKey<RecordingLiveSessionState>();
      _pausedNotifier.value = false;

      setState(() {
        _step = _RecordStep.recording;
        _filePath = path;
        _recordedDuration = Duration.zero;
      });
    } catch (error, stack) {
      debugPrint('Record start failed: $error\n$stack');
      _showError(
        kIsWeb
            ? 'Could not start recording. Allow microphone access in your browser, then try again.'
            : 'Could not start recording. Allow microphone permission and try again.',
      );
    }
  }

  Future<void> _pauseOrResume() async {
    if (_step != _RecordStep.recording) return;
    try {
      final bool next = !_pausedNotifier.value;
      if (next) {
        await _mic.pause();
      } else {
        await _mic.resume();
      }
      _pausedNotifier.value = next;
    } catch (_) {
      _showError('Pause is not supported on this device.');
    }
  }

  Future<void> _stopRecording({bool reachedTimeLimit = false}) async {
    if (_step != _RecordStep.recording || _savingRecording) return;

    final Duration timerDuration =
        _recordingSessionKey?.currentState?.elapsed ?? _activeRecordingDuration;
    if (mounted) setState(() => _savingRecording = true);

    final bool saved = await _finalizeRecording();

    if (!mounted) return;
    if (!saved) {
      setState(() {
        _savingRecording = false;
        _step = _RecordStep.ready;
        _filePath = null;
        _recordingBytes = null;
        _recordedDuration = Duration.zero;
        _playbackPosition = Duration.zero;
        _playing = false;
        _pausedNotifier.value = false;
      });
      _showError('Recording was not saved. Try again and speak for a few seconds.');
      return;
    }

    final Duration captured = _mic.capturedDuration;
    final Duration recordedDuration =
        captured > Duration.zero ? captured : timerDuration;

    setState(() {
      _savingRecording = false;
      _step = _RecordStep.review;
      _pausedNotifier.value = false;
      _recordingSessionKey = null;
      _recordedDuration = recordedDuration;
      _waveHeights = AudioWaveform.seededHeights(_waveSeed + recordedDuration.inSeconds);
      _playbackPosition = Duration.zero;
      _playing = false;
    });

    if (!kIsWeb) {
      await _mic.prepareForPlayback();
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }

    if (reachedTimeLimit && mounted) {
      _showInfo('4-hour recording limit reached. Playback is ready.');
    }
  }

  Future<bool> _waitForPlayerDuration(AudioPlayer player, {Duration? minimum}) async {
    Duration? best;
    for (int i = 0; i < 50; i++) {
      final Duration? duration = await player.getDuration();
      if (duration != null && duration > Duration.zero) {
        best = best == null || duration > best ? duration : best;
        if (minimum != null && best >= minimum) break;
        if (minimum == null) break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 75));
    }
    if (best != null && best > Duration.zero && mounted) {
      final Duration resolved = best;
      setState(() {
        if (resolved > _recordedDuration) {
          _recordedDuration = resolved;
        }
      });
      return true;
    }
    return false;
  }

  Future<void> _discardRecording() async {
    if (_actionBusy) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Move to bin?'),
        content: const Text(
          'This recording will move to the bin for 30 days. You can restore it from there.',
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Move to bin'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _actionBusy = true);
    try {
      try {
        await (await _ensurePlayer()).stop();
      } catch (_) {}
      final String? path = _filePath;
      final Uint8List? bytes = await _readRecordingBytes();
      if (!mounted) return;
      await context.read<RecordingBinService>().moveToBin(
            sourcePath: path ?? '',
            duration: _recordedDuration,
            label: 'Lecture recording',
            bytes: bytes ?? _recordingBytes,
          );

      if (!mounted) return;
      setState(() {
        _step = _RecordStep.ready;
        _filePath = null;
        _recordingBytes = null;
        _recordedDuration = Duration.zero;
        _playbackPosition = Duration.zero;
        _transcript = null;
        _transcriptController.clear();
        _segments = <TranscriptSegment>[];
        _playing = false;
        _inlineMessage = null;
        _inlineIsError = false;
      });
      _showInfo('Recording moved to bin');
    } catch (error) {
      if (!mounted) return;
      _showError('Could not move recording to bin. ${StudyMessenger.clean(error)}');
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _togglePlayback() async {
    if (_actionBusy) return;
    if (!await _recordingSourceReady()) {
      _showError('Recording was not saved. Record again and wait a moment after stopping.');
      return;
    }

    _clearInlineMessage();
    setState(() => _actionBusy = true);

    try {
      final AudioPlayer player = await _ensurePlayer();
      if (_playing) {
        await player.pause();
        return;
      }

      if (player.state == PlayerState.paused &&
          _playbackPosition > Duration.zero &&
          _playbackPosition < _recordedDuration) {
        await _prepareForPlayback();
        await player.setVolume(_playbackVolume);
        await player.resume();
        if (await _waitForPlaybackStarted()) return;
      }

      if (mounted) setState(() => _playbackPosition = Duration.zero);
      if (!kIsWeb) {
        await _releasePlayer();
      }
      final Source? source = await _resolvePlaybackSource();
      if (source == null) {
        _showError('Recording file not found. Tap Next to transcribe without preview.');
        return;
      }

      final bool started = await _playSource(source);
      if (!started && mounted) {
        setState(() => _playing = false);
        _showError(_playbackFailedMessage());
      }
    } catch (error) {
      if (mounted) setState(() => _playing = false);
      _showError(_playbackFailedMessage(error));
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  void _setTranscriptText(String text) {
    _transcript = text;
    _transcriptController.text = text;
    _segments = _buildSegments(text, _recordedDuration);
  }

  Future<void> _seekTo(Duration position) async {
    if (_filePath == null) return;

    _clearInlineMessage();
    try {
      if (!kIsWeb && !_playing) {
        await _releasePlayer();
      }

      final AudioPlayer player = await _ensurePlayer();
      if (_playing) {
        await player.seek(position);
        await player.setVolume(_playbackVolume);
        if (mounted) setState(() => _playbackPosition = position);
        return;
      }

      final Source? source = await _resolvePlaybackSource();
      if (source == null) {
        _showError('Recording file not found.');
        return;
      }

      final bool started = await _playSource(source, position: position);
      if (!mounted) return;
      setState(() {
        _playbackPosition = position;
        if (started) _playing = true;
      });
      if (!started) _showError(_playbackFailedMessage());
    } catch (error) {
      if (mounted) _showError(_playbackFailedMessage(error));
    }
  }

  Future<void> _seekRelative(int seconds) async {
    final Duration next = _playbackPosition + Duration(seconds: seconds);
    final Duration clamped = Duration(
      milliseconds: next.inMilliseconds.clamp(0, _recordedDuration.inMilliseconds),
    );
    await _seekTo(clamped);
  }

  List<TranscriptSegment> _buildSegments(String text, Duration total) {
    final RegExp splitter = RegExp(r'(?<=[.!?])\s+');
    final List<String> parts = text.split(splitter).where((String s) => s.trim().isNotEmpty).toList();
    if (parts.isEmpty) return <TranscriptSegment>[TranscriptSegment(start: Duration.zero, text: text)];

    final int totalMs = math.max(total.inMilliseconds, 1);
    final int chars = parts.fold<int>(0, (int sum, String p) => sum + p.length);
    int cursorMs = 0;
    final List<TranscriptSegment> segments = <TranscriptSegment>[];

    for (int i = 0; i < parts.length; i++) {
      final int sliceMs = i == parts.length - 1
          ? totalMs - cursorMs
          : ((parts[i].length / chars) * totalMs).round();
      segments.add(TranscriptSegment(start: Duration(milliseconds: cursorMs), text: parts[i].trim()));
      cursorMs += sliceMs;
    }
    return segments;
  }

  Future<void> _goToTranscript() async {
    if (_actionBusy) return;

    final String? path = _filePath;
    if (path == null) {
      _showError('Recording was not saved. Try recording again.');
      return;
    }

    _clearInlineMessage();
    setState(() {
      _actionBusy = true;
      _step = _RecordStep.transcript;
      _loadingTranscript = true;
      _playing = false;
      _playbackPosition = Duration.zero;
    });

    try {
      final Uint8List? bytes = await _readRecordingBytes(requireTranscriptLength: true);
      if (bytes == null) {
        throw Exception('Recording too short. Speak longer and try again.');
      }

      if (!kIsWeb) {
        final Uint8List rebuilt = rebuildWavBytes(bytes, sampleRate: lectureRecordingSampleRate());
        final File file = File(path);
        if (await file.exists()) {
          await file.writeAsBytes(rebuilt, flush: true);
        }
        _recordingBytes = rebuilt;
      }

      try {
        await (await _ensurePlayer()).stop();
      } catch (_) {}

      final String text = await OpenAiWhisperService().transcribeBytes(
        kIsWeb ? bytes : rebuildWavBytes(bytes, sampleRate: lectureRecordingSampleRate()),
        fileName: 'lecture.$_recordingExtension',
      );
      if (!mounted) return;
      setState(() {
        _loadingTranscript = false;
        _actionBusy = false;
      });
      _setTranscriptText(text);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _step = _RecordStep.review;
        _loadingTranscript = false;
        _actionBusy = false;
      });
      _showError(StudyMessenger.clean(error));
    }
  }

  Future<void> _finish() async {
    final String? path = _filePath;
    final String transcript = _transcriptController.text.trim();
    if (path == null || transcript.isEmpty) return;
    _transcript = transcript;

    setState(() => _step = _RecordStep.summarizing);
    try {
      await widget.onSummarize(path, transcript);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _step = _RecordStep.transcript);
      _showError(StudyMessenger.clean(error));
    }
  }

  Future<void> _close() async {
    if (_step == _RecordStep.summarizing) return;
    try {
      await _player?.stop();
    } catch (_) {}
    if (_step == _RecordStep.recording) {
      try {
        await _mic.stop();
      } catch (_) {}
    }
    if (!mounted) return;
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = StudyColors.primary;
    final Color waveColor = accent.withValues(alpha: 0.72);

    return Dialog(
      backgroundColor: _surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          maxWidth: 520,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Header(
                onClose: _step == _RecordStep.summarizing ? null : _close,
                onOpenBin: _step == _RecordStep.summarizing ? null : () => RecordingBinSheet.show(context),
              ),
              const SizedBox(height: 20),
              if (_step == _RecordStep.recording)
                _buildRecordingBody(waveColor)
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (_step == _RecordStep.ready) _buildReadyBody(accent),
                        if (_step == _RecordStep.review) _buildReviewBody(waveColor),
                        if (_step == _RecordStep.transcript || _step == _RecordStep.summarizing)
                          _buildTranscriptBody(accent),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _nextEnabled ? () => unawaited(_onNext()) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: accent.withValues(alpha: 0.35),
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.45),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: _actionBusy && _step == _RecordStep.review
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Next',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _nextEnabled {
    if (_actionBusy || _step == _RecordStep.ready || _step == _RecordStep.summarizing || _loadingTranscript) {
      return false;
    }
    if (_step == _RecordStep.recording) return false;
    if (_step == _RecordStep.review) return _filePath != null;
    if (_step == _RecordStep.transcript) {
      return _transcriptController.text.trim().isNotEmpty;
    }
    return false;
  }

  Future<void> _onNext() async {
    if (_actionBusy) return;
    if (_step == _RecordStep.review) {
      await _goToTranscript();
    } else if (_step == _RecordStep.transcript) {
      await _finish();
    }
  }

  Widget _buildReadyBody(Color accent) {
    return _InnerCard(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: _startRecording,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.45),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ready to Record',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Click the microphone to start recording',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingBody(Color waveColor) {
    if (_savingRecording) {
      return _InnerCard(
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(color: StudyColors.primary),
            const SizedBox(height: 16),
            Text(
              'Saving recording…',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return _InnerCard(
      child: RecordingLiveSession(
        key: _recordingSessionKey,
        waveColor: waveColor,
        isPaused: _pausedNotifier,
        onStop: () => unawaited(_stopRecording()),
        onPause: () => unawaited(_pauseOrResume()),
        onMaxDuration: () => unawaited(_stopRecording(reachedTimeLimit: true)),
        pauseBackground: _pauseBg,
        stopColor: _stopRed,
      ),
    );
  }

  Widget _buildReviewBody(Color waveColor) {
    return _InnerCard(
      child: Column(
        children: <Widget>[
          AudioWaveform(
            heights: _waveHeights,
            barColor: waveColor.withValues(alpha: 0.55),
            progress: _playbackProgress,
            playheadColor: StudyColors.primaryLight,
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(_formatDuration(_playbackPosition), style: _timeStyle),
              const Spacer(),
              Text(_formatDuration(_recordedDuration), style: _timeStyle),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _ControlChip(
                label: _actionBusy ? 'Loading…' : (_playing ? 'Pause' : 'Play'),
                icon: _actionBusy
                    ? Icons.hourglass_top_rounded
                    : (_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                background: Colors.white,
                foreground: Colors.black,
                enabled: !_actionBusy,
                onTap: () => unawaited(_togglePlayback()),
              ),
              const SizedBox(width: 12),
              _ControlChip(
                label: 'Bin',
                icon: Icons.delete_outline_rounded,
                background: _pauseBg,
                foreground: Colors.white,
                enabled: !_actionBusy,
                onTap: () => unawaited(_discardRecording()),
              ),
            ],
          ),
          if (_inlineMessage != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _inlineMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _inlineIsError ? const Color(0xFFFCA5A5) : Colors.white.withValues(alpha: 0.65),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Tap Next to transcribe this recording',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptBody(Color accent) {
    if (_step == _RecordStep.summarizing) {
      return _InnerCard(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 24),
            CircularProgressIndicator(color: accent),
            const SizedBox(height: 16),
            Text(
              'Building your study set…',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    if (_loadingTranscript) {
      return _InnerCard(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 24),
            CircularProgressIndicator(color: accent),
            const SizedBox(height: 16),
            Text(
              'Transcribing your recording…',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _InnerCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            children: <Widget>[
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: _playbackProgress,
                  onChanged: (double value) {
                    _seekTo(Duration(milliseconds: (_recordedDuration.inMilliseconds * value).round()));
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                ),
              ),
              Row(
                children: <Widget>[
                  Text(_formatDuration(_playbackPosition), style: _timeStyle),
                  const Spacer(),
                  Text(_formatRemaining(_playbackPosition, _recordedDuration), style: _timeStyle),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Icon(_volumeIcon, color: Colors.white.withValues(alpha: 0.5), size: 18),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: _playbackVolume,
                        onChanged: _setPlaybackVolume,
                        activeColor: Colors.white54,
                        inactiveColor: Colors.white24,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _seekRelative(-10),
                    icon: Icon(Icons.replay_10_rounded, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _togglePlayback,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _seekRelative(10),
                    icon: Icon(Icons.forward_10_rounded, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  IconButton(
                    tooltip: 'Download recording',
                    onPressed: _downloadRecording,
                    icon: Icon(Icons.download_outlined, color: Colors.white.withValues(alpha: 0.55)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Text(
              'TRANSCRIPT',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Copy transcript',
              onPressed: _transcript == null
                  ? null
                  : () {
                      Clipboard.setData(ClipboardData(text: _transcriptController.text.trim()));
                      StudyMessenger.showInfo(context, 'Transcript copied');
                    },
              icon: Icon(Icons.copy_rounded, color: Colors.white.withValues(alpha: 0.45), size: 18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _transcriptController,
          minLines: 3,
          maxLines: 8,
          style: const TextStyle(color: Colors.white, height: 1.45, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Edit transcript if it missed anything you said',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
            filled: true,
            fillColor: _inner,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accent.withValues(alpha: 0.65)),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
          onChanged: (String value) {
            _transcript = value.trim();
            _segments = _buildSegments(value.trim(), _recordedDuration);
          },
        ),
        if (_segments.length > 1) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            'Jump to section',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _segments
                .map(
                  (TranscriptSegment segment) => ActionChip(
                    label: Text(_formatDuration(segment.start)),
                    avatar: const Icon(Icons.play_arrow_rounded, size: 16),
                    onPressed: () => unawaited(_seekTo(segment.start)),
                    backgroundColor: _inner,
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  TextStyle get _timeStyle => TextStyle(
        color: Colors.white.withValues(alpha: 0.55),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );
}

class _Header extends StatelessWidget {
  const _Header({this.onClose, this.onOpenBin});

  final VoidCallback? onClose;
  final VoidCallback? onOpenBin;

  @override
  Widget build(BuildContext context) {
    final int binCount = context.watch<RecordingBinService>().items.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Record your lecture',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        if (onOpenBin != null)
          IconButton(
            tooltip: 'Recording bin',
            onPressed: onOpenBin,
            icon: Badge(
              isLabelVisible: binCount > 0,
              label: Text('$binCount'),
              child: Icon(Icons.delete_outline_rounded, color: Colors.white.withValues(alpha: 0.75)),
            ),
            visualDensity: VisualDensity.compact,
          ),
        IconButton(
          onPressed: onClose,
          icon: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.55)),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _InnerCard extends StatelessWidget {
  const _InnerCard({required this.child, this.padding = const EdgeInsets.symmetric(vertical: 32, horizontal: 16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _ControlChip extends StatelessWidget {
  const _ControlChip({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: enabled ? onTap : null,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: background.withValues(alpha: 0.45),
        disabledForegroundColor: foreground.withValues(alpha: 0.55),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
