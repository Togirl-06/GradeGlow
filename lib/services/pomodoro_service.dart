import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/recent_timer.dart';
import '../utils/gamification.dart';

enum PomodoroPhase { idle, focus, breakTime }

class PomodoroService extends ChangeNotifier {
  PomodoroPhase _phase = PomodoroPhase.idle;
  int _durationSeconds = 30 * 60;
  int _pickerHours = 0;
  int _pickerMinutes = 30;
  int _pickerSeconds = 0;
  String _label = 'Study';
  int _secondsLeft = 30 * 60;
  int _continuousFocusSeconds = 0;
  final Set<int> _awardedMilestones = <int>{};
  int? _pendingMilestoneMinutes;
  Timer? _timer;
  int _completedBlocks = 0;
  bool _awaitingContinueChoice = false;
  final List<RecentTimer> _recents = <RecentTimer>[];

  PomodoroPhase get phase => _phase;
  bool get awaitingContinueChoice => _awaitingContinueChoice;
  bool get isRunning => _phase == PomodoroPhase.focus || _phase == PomodoroPhase.breakTime;
  bool get isPaused => _phase == PomodoroPhase.breakTime;
  bool get isFocusing => _phase == PomodoroPhase.focus;
  int get pickerHours => _pickerHours;
  int get pickerMinutes => _pickerMinutes;
  int get pickerSeconds => _pickerSeconds;
  String get label => _label;
  int get durationSeconds => _durationSeconds;
  int get secondsLeft => _secondsLeft;
  int get continuousFocusSeconds => _continuousFocusSeconds;
  int get completedBlocks => _completedBlocks;
  List<RecentTimer> get recents => List<RecentTimer>.unmodifiable(_recents);
  bool get canEditSettings => _phase == PomodoroPhase.idle && !_awaitingContinueChoice;

  double get progress {
    if (!isRunning || _durationSeconds <= 0) return 0;
    return 1 - (_secondsLeft / _durationSeconds);
  }

  bool get hasPendingMilestone => _pendingMilestoneMinutes != null;

  int? takePendingMilestone() {
    final int? pending = _pendingMilestoneMinutes;
    _pendingMilestoneMinutes = null;
    return pending;
  }

  void setLabel(String value) {
    if (!canEditSettings) return;
    _label = value.trim().isEmpty ? 'Study' : value.trim();
    notifyListeners();
  }

  void setPickerTime({required int hours, required int minutes, required int seconds}) {
    if (!canEditSettings) return;
    _pickerHours = hours.clamp(0, 23);
    _pickerMinutes = minutes.clamp(0, 59);
    _pickerSeconds = seconds.clamp(0, 59);
    final int total = _pickerHours * 3600 + _pickerMinutes * 60 + _pickerSeconds;
    _durationSeconds = total <= 0 ? 60 : total;
    _secondsLeft = _durationSeconds;
    notifyListeners();
  }

  void loadRecent(RecentTimer recent) {
    if (!canEditSettings) return;
    _label = recent.label;
    setPickerTime(hours: recent.hours, minutes: recent.minutes, seconds: recent.seconds);
  }

  void startFocus() {
    if (_durationSeconds <= 0) return;
    _cancelTimerInternal();
    _phase = PomodoroPhase.focus;
    _awaitingContinueChoice = false;
    _secondsLeft = _durationSeconds;
    _saveRecent();
    _tick();
    notifyListeners();
  }

  /// Pauses the countdown and resets the uninterrupted focus streak.
  void startBreak() {
    if (_phase != PomodoroPhase.focus) return;
    _cancelTimerInternal();
    _resetContinuousStreak();
    _phase = PomodoroPhase.breakTime;
    notifyListeners();
  }

  /// Resumes the focus session from a break (streak starts fresh).
  void resumeFocus() {
    if (_phase != PomodoroPhase.breakTime) return;
    _phase = PomodoroPhase.focus;
    _tick();
    notifyListeners();
  }

  void cancelTimer() {
    if (_phase == PomodoroPhase.focus || _phase == PomodoroPhase.breakTime) {
      _resetContinuousStreak();
      _cancelTimerInternal();
      _phase = PomodoroPhase.idle;
      _secondsLeft = _durationSeconds;
      _awaitingContinueChoice = false;
    } else if (canEditSettings) {
      setPickerTime(hours: 0, minutes: 30, seconds: 0);
      _label = 'Study';
    }
    notifyListeners();
  }

  void continueStudying() {
    _cancelTimerInternal();
    _awaitingContinueChoice = false;
    _phase = PomodoroPhase.focus;
    _secondsLeft = _durationSeconds;
    _tick();
    notifyListeners();
  }

  void endSession() {
    _resetContinuousStreak();
    _cancelTimerInternal();
    _awaitingContinueChoice = false;
    _phase = PomodoroPhase.idle;
    _secondsLeft = _durationSeconds;
    notifyListeners();
  }

  void _saveRecent() {
    final RecentTimer entry = RecentTimer(label: _label, totalSeconds: _durationSeconds);
    _recents.removeWhere((RecentTimer r) => r.totalSeconds == entry.totalSeconds && r.label == entry.label);
    _recents.insert(0, entry);
    if (_recents.length > 10) {
      _recents.removeLast();
    }
  }

  void _resetContinuousStreak() {
    _continuousFocusSeconds = 0;
    _awardedMilestones.clear();
  }

  void _tick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_phase == PomodoroPhase.focus) {
        _continuousFocusSeconds += 1;
        _checkMilestones();
      }

      if (_secondsLeft <= 1) {
        _onPhaseComplete();
        return;
      }
      _secondsLeft -= 1;
      notifyListeners();
    });
  }

  void _checkMilestones() {
    final int continuousMinutes = _continuousFocusSeconds ~/ 60;
    for (final int milestone in Gamification.focusMilestoneMinutes) {
      if (continuousMinutes >= milestone && !_awardedMilestones.contains(milestone)) {
        _awardedMilestones.add(milestone);
        _pendingMilestoneMinutes = milestone;
      }
    }
  }

  void _onPhaseComplete() {
    _cancelTimerInternal();
    if (_phase == PomodoroPhase.focus) {
      _completedBlocks += 1;
      _phase = PomodoroPhase.idle;
      _awaitingContinueChoice = true;
      _secondsLeft = 0;
    }
    notifyListeners();
  }

  void _cancelTimerInternal() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimerInternal();
    super.dispose();
  }
}
