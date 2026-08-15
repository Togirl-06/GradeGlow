import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recent_timer.dart';
import '../services/auth_service.dart';
import '../services/pomodoro_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/gamification.dart';

/// Focus timer — Study Buddy styling (not iOS Clock).
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  String _formatCountdown(int seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int hours, int minutes, int seconds) {
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _awardMilestone(int minutes) async {
    final AuthService auth = context.read<AuthService>();
    final UserService users = context.read<UserService>();
    final String? uid = auth.uid;
    final int xp = Gamification.xpForFocusMilestone(minutes);
    if (uid != null) {
      await users.addXp(xp);
      await users.recordStudyActivity(uid);
      await users.incrementWeeklyStat(studyMinutes: minutes);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '+ $xp XP — ${Gamification.focusMilestoneLabel(minutes)} uninterrupted!',
        ),
      ),
    );
  }

  void _handleMilestones(PomodoroService pomodoro) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      int? milestone = pomodoro.takePendingMilestone();
      while (milestone != null) {
        await _awardMilestone(milestone);
        if (!mounted) return;
        milestone = pomodoro.takePendingMilestone();
      }
    });
  }

  Future<void> _editLabel(PomodoroService pomodoro) async {
    final TextEditingController controller = TextEditingController(
      text: pomodoro.label,
    );
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Session name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Chem review'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) pomodoro.setLabel(result);
  }

  @override
  Widget build(BuildContext context) {
    final PomodoroService pomodoro = context.watch<PomodoroService>();
    final Color textSecondary = StudyColors.textSecondary(
      Theme.of(context).brightness,
    );

    if (pomodoro.hasPendingMilestone) {
      _handleMilestones(pomodoro);
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Focus timer'),
            Text(
              pomodoro.isPaused
                  ? 'On break'
                  : pomodoro.isRunning
                  ? 'Session in progress'
                  : 'Set your block',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: textSecondary),
            ),
          ],
        ),
      ),
      body: pomodoro.isRunning
          ? _RunningView(
              pomodoro: pomodoro,
              format: _formatCountdown,
              onBreak: pomodoro.startBreak,
              onResume: pomodoro.resumeFocus,
              onCancel: pomodoro.cancelTimer,
            )
          : pomodoro.awaitingContinueChoice
          ? _CompleteView(
              pomodoro: pomodoro,
              onContinue: pomodoro.continueStudying,
              onEnd: pomodoro.endSession,
            )
          : _SetupView(
              pomodoro: pomodoro,
              formatDuration: _formatDuration,
              onReset: pomodoro.cancelTimer,
              onStart: pomodoro.startFocus,
              onEditLabel: () => _editLabel(pomodoro),
              onRecent: pomodoro.loadRecent,
              onAdjust: pomodoro.setPickerTime,
            ),
    );
  }
}

class _SetupView extends StatelessWidget {
  const _SetupView({
    required this.pomodoro,
    required this.formatDuration,
    required this.onReset,
    required this.onStart,
    required this.onEditLabel,
    required this.onRecent,
    required this.onAdjust,
  });

  final PomodoroService pomodoro;
  final String Function(int hours, int minutes, int seconds) formatDuration;
  final VoidCallback onReset;
  final VoidCallback onStart;
  final VoidCallback onEditLabel;
  final ValueChanged<RecentTimer> onRecent;
  final void Function({
    required int hours,
    required int minutes,
    required int seconds,
  })
  onAdjust;

  static const List<int> _presetMinutes = <int>[25, 45, 60, 90, 120];

  void _applyPreset(int minutes) {
    onAdjust(hours: minutes ~/ 60, minutes: minutes % 60, seconds: 0);
  }

  bool _isPresetSelected(int minutes) {
    return pomodoro.pickerHours == minutes ~/ 60 &&
        pomodoro.pickerMinutes == minutes % 60 &&
        pomodoro.pickerSeconds == 0;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: <Widget>[
        Text(
          'FOCUS SESSION',
          style: TextStyle(
            color: scheme.primary,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.25,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Make this time count',
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Choose a focused block, name your goal, and work without distractions.',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.center_focus_strong_rounded,
                      color: scheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'SESSION LENGTH',
                      style: TextStyle(
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Text(
                    'CUSTOM',
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                formatDuration(
                  pomodoro.pickerHours,
                  pomodoro.pickerMinutes,
                  pomodoro.pickerSeconds,
                ),
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _DurationStepper(
                      label: 'HOURS',
                      value: pomodoro.pickerHours,
                      max: 23,
                      onDecrement: () => onAdjust(
                        hours: (pomodoro.pickerHours - 1).clamp(0, 23),
                        minutes: pomodoro.pickerMinutes,
                        seconds: pomodoro.pickerSeconds,
                      ),
                      onIncrement: () => onAdjust(
                        hours: (pomodoro.pickerHours + 1).clamp(0, 23),
                        minutes: pomodoro.pickerMinutes,
                        seconds: pomodoro.pickerSeconds,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DurationStepper(
                      label: 'MINUTES',
                      value: pomodoro.pickerMinutes,
                      max: 59,
                      onDecrement: () => onAdjust(
                        hours: pomodoro.pickerHours,
                        minutes: (pomodoro.pickerMinutes - 1).clamp(0, 59),
                        seconds: pomodoro.pickerSeconds,
                      ),
                      onIncrement: () => onAdjust(
                        hours: pomodoro.pickerHours,
                        minutes: (pomodoro.pickerMinutes + 1).clamp(0, 59),
                        seconds: pomodoro.pickerSeconds,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DurationStepper(
                      label: 'SECONDS',
                      value: pomodoro.pickerSeconds,
                      max: 59,
                      onDecrement: () => onAdjust(
                        hours: pomodoro.pickerHours,
                        minutes: pomodoro.pickerMinutes,
                        seconds: (pomodoro.pickerSeconds - 1).clamp(0, 59),
                      ),
                      onIncrement: () => onAdjust(
                        hours: pomodoro.pickerHours,
                        minutes: pomodoro.pickerMinutes,
                        seconds: (pomodoro.pickerSeconds + 1).clamp(0, 59),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'QUICK START',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 67,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _presetMinutes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) {
              final int minutes = _presetMinutes[index];
              final bool selected = _isPresetSelected(minutes);
              final String label = minutes >= 60
                  ? '${minutes ~/ 60} hr'
                  : '$minutes min';
              return _FocusPreset(
                label: label,
                selected: selected,
                onTap: () => _applyPreset(minutes),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Material(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(19),
          child: InkWell(
            onTap: onEditLabel,
            borderRadius: BorderRadius.circular(19),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.flag_outlined,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'SESSION GOAL',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          pomodoro.label,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined, color: scheme.primary, size: 19),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _FocusRewardsLadder(continuousFocusSeconds: 0),
        if (pomodoro.recents.isNotEmpty) ...<Widget>[
          const SizedBox(height: 22),
          Text(
            'RECENT SESSIONS',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pomodoro.recents.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int index) {
                final RecentTimer recent = pomodoro.recents[index];
                return Material(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      onRecent(recent);
                      onStart();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            recent.displayTime,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recent.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 22),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: onReset,
                child: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'Begin focus',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DurationStepper extends StatelessWidget {
  const _DurationStepper({
    required this.label,
    required this.value,
    required this.max,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int value;
  final int max;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 7),
      decoration: BoxDecoration(
        color: scheme.onPrimaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.62),
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.45,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _StepButton(
                icon: Icons.remove_rounded,
                onPressed: value > 0 ? onDecrement : null,
              ),
              const SizedBox(width: 5),
              _StepButton(
                icon: Icons.add_rounded,
                onPressed: value < max ? onIncrement : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 26,
        height: 24,
        decoration: BoxDecoration(
          color: scheme.onPrimaryContainer.withValues(
            alpha: onPressed == null ? 0.03 : 0.09,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 14,
          color: scheme.onPrimaryContainer.withValues(
            alpha: onPressed == null ? 0.3 : 0.8,
          ),
        ),
      ),
    );
  }
}

class _FocusPreset extends StatelessWidget {
  const _FocusPreset({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 82,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                selected
                    ? Icons.check_circle_outline_rounded
                    : Icons.timer_outlined,
                color: selected ? scheme.onPrimary : scheme.primary,
                size: 18,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunningView extends StatelessWidget {
  const _RunningView({
    required this.pomodoro,
    required this.format,
    required this.onBreak,
    required this.onResume,
    required this.onCancel,
  });

  final PomodoroService pomodoro;
  final String Function(int seconds) format;
  final VoidCallback onBreak;
  final VoidCallback onResume;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color textSecondary = scheme.onSurfaceVariant;
    final bool paused = pomodoro.isPaused;
    final double progress = pomodoro.progress.clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        children: <Widget>[
          Text(
            paused ? 'TAKE A BREATH' : 'FOCUS IN PROGRESS',
            style: TextStyle(
              color: scheme.primary,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            paused ? 'Your session is paused' : 'Stay with one thing',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 244,
            height: 244,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress : null,
                    strokeWidth: 10,
                    backgroundColor: scheme.surfaceContainerHighest,
                    color: scheme.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      format(pomodoro.secondsLeft),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: paused
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pomodoro.label,
                      style: TextStyle(color: textSecondary),
                    ),
                    if (paused) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        'Paused',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  paused ? Icons.coffee_rounded : Icons.bolt_rounded,
                  color: scheme.onPrimaryContainer,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  paused
                      ? 'On break — timer paused'
                      : 'Uninterrupted ${format(pomodoro.continuousFocusSeconds)}',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: paused
                    ? FilledButton.icon(
                        onPressed: onResume,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Resume'),
                      )
                    : FilledButton.icon(
                        onPressed: onBreak,
                        icon: const Icon(Icons.pause_rounded),
                        label: const Text('Break'),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Stop'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: StudyColors.danger,
                    side: const BorderSide(color: StudyColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _FocusRewardsLadder(
            continuousFocusSeconds: pomodoro.continuousFocusSeconds,
          ),
          if (!paused) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              'Taking a break resets your focus streak for XP rewards.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CompleteView extends StatelessWidget {
  const _CompleteView({
    required this.pomodoro,
    required this.onContinue,
    required this.onEnd,
  });

  final PomodoroService pomodoro;
  final VoidCallback onContinue;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color textSecondary = scheme.onSurfaceVariant;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      child: Column(
        children: <Widget>[
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: scheme.onPrimaryContainer,
              size: 38,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Focus block complete',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pomodoro.label,
            style: TextStyle(color: textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            '${pomodoro.continuousFocusSeconds ~/ 60} min uninterrupted',
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _FocusRewardsLadder(
            continuousFocusSeconds: pomodoro.continuousFocusSeconds,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Keep going (keep streak)'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onEnd,
              child: const Text('End session'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal milestone ladder — distinct from iOS list table.
class _FocusRewardsLadder extends StatelessWidget {
  const _FocusRewardsLadder({required this.continuousFocusSeconds});

  final int continuousFocusSeconds;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color textSecondary = scheme.onSurfaceVariant;
    final int continuousMinutes = continuousFocusSeconds ~/ 60;
    int? nextMilestone;
    for (final int m in Gamification.focusMilestoneMinutes) {
      if (continuousMinutes < m) {
        nextMilestone = m;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.emoji_events_outlined,
                color: scheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Focus streak rewards',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              if (nextMilestone != null && continuousFocusSeconds > 0)
                Text(
                  'Next: ${Gamification.focusMilestoneDurationLabel(nextMilestone)}',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Study without stopping to earn XP. Pausing or stopping resets your streak.',
            style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 16),
          ...Gamification.focusStreakRewards.map((MapEntry<int, int> reward) {
            final int minutes = reward.key;
            final int xp = reward.value;
            final bool earned = continuousMinutes >= minutes;
            final double fill = earned
                ? 1
                : (continuousMinutes / minutes).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: earned
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      earned ? Icons.check_rounded : Icons.lock_outline_rounded,
                      size: 18,
                      color: earned ? scheme.primary : textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              Gamification.focusMilestoneDurationLabel(minutes),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: earned ? scheme.primary : null,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: earned
                                    ? LinearGradient(
                                        colors: <Color>[
                                          scheme.primary,
                                          scheme.primary.withValues(
                                            alpha: 0.78,
                                          ),
                                        ],
                                      )
                                    : null,
                                color: earned
                                    ? null
                                    : scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+$xp XP',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: earned ? Colors.white : textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fill,
                            minHeight: 5,
                            backgroundColor: scheme.surfaceContainerHighest,
                            color: earned
                                ? scheme.primary
                                : scheme.primary.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
