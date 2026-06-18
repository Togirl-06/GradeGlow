import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recent_timer.dart';
import '../services/auth_service.dart';
import '../services/pomodoro_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/gamification.dart';
import '../widgets/study_surface.dart';

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
      SnackBar(content: Text('+ $xp XP — ${Gamification.focusMilestoneLabel(minutes)} uninterrupted!')),
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
    final TextEditingController controller = TextEditingController(text: pomodoro.label);
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null) pomodoro.setLabel(result);
  }

  @override
  Widget build(BuildContext context) {
    final PomodoroService pomodoro = context.watch<PomodoroService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
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
  final void Function({required int hours, required int minutes, required int seconds}) onAdjust;

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
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[StudyColors.primaryDark, StudyColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: StudyColors.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              const Icon(Icons.hourglass_top_rounded, color: Colors.white70, size: 28),
              const SizedBox(height: 12),
              Text(
                formatDuration(pomodoro.pickerHours, pomodoro.pickerMinutes, pomodoro.pickerSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              const Text('Duration', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 20),
              _DurationStepper(
                label: 'Hours',
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
              const SizedBox(height: 10),
              _DurationStepper(
                label: 'Minutes',
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
              const SizedBox(height: 10),
              _DurationStepper(
                label: 'Seconds',
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
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Quick presets', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetMinutes.map((int minutes) {
            final bool selected = _isPresetSelected(minutes);
            final String label = minutes >= 60 ? '${minutes ~/ 60}h' : '${minutes}m';
            return FilterChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => _applyPreset(minutes),
              selectedColor: StudyColors.primary.withValues(alpha: 0.25),
              checkmarkColor: StudyColors.primary,
              labelStyle: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? StudyColors.primary : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        StudySurfaceCard(
          onTap: onEditLabel,
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StudyColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.edit_note_rounded, color: StudyColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Session name', style: TextStyle(color: textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(pomodoro.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _FocusRewardsLadder(continuousFocusSeconds: 0),
        if (pomodoro.recents.isNotEmpty) ...<Widget>[
          const SizedBox(height: 20),
          Text('Recent sessions', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pomodoro.recents.length,
              separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int index) {
                final RecentTimer recent = pomodoro.recents[index];
                return StudySurfaceCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  borderRadius: 16,
                  onTap: () {
                    onRecent(recent);
                    onStart();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        recent.displayTime,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recent.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: onReset,
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start focus'),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          IconButton(
            onPressed: value > 0 ? onDecrement : null,
            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white),
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Text(
              value.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: value < max ? onIncrement : null,
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
            visualDensity: VisualDensity.compact,
          ),
        ],
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
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final bool paused = pomodoro.isPaused;
    final double progress = pomodoro.progress.clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 12),
          SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress : null,
                    strokeWidth: 10,
                    backgroundColor: StudyColors.primary.withValues(alpha: 0.12),
                    color: paused ? StudyColors.accent : StudyColors.primary,
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
                            color: paused ? StudyColors.accent : null,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(pomodoro.label, style: TextStyle(color: textSecondary)),
                    if (paused) ...<Widget>[
                      const SizedBox(height: 8),
                      const Text(
                        'Paused',
                        style: TextStyle(
                          color: StudyColors.accent,
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
              color: (paused ? StudyColors.accent : StudyColors.success).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  paused ? Icons.coffee_rounded : Icons.bolt_rounded,
                  color: paused ? StudyColors.accent : StudyColors.success,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  paused
                      ? 'On break — timer paused'
                      : 'Uninterrupted ${format(pomodoro.continuousFocusSeconds)}',
                  style: TextStyle(
                    color: paused ? StudyColors.accent : StudyColors.success,
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
                        style: FilledButton.styleFrom(
                          backgroundColor: StudyColors.accent,
                          foregroundColor: const Color(0xFF1C1917),
                        ),
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
          _FocusRewardsLadder(continuousFocusSeconds: pomodoro.continuousFocusSeconds),
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
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: StudyColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.celebration_rounded, color: StudyColors.success, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            'Block complete!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(pomodoro.label, style: TextStyle(color: textSecondary, fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            '${pomodoro.continuousFocusSeconds ~/ 60} min uninterrupted',
            style: const TextStyle(color: StudyColors.success, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          _FocusRewardsLadder(continuousFocusSeconds: pomodoro.continuousFocusSeconds),
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
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final int continuousMinutes = continuousFocusSeconds ~/ 60;
    int? nextMilestone;
    for (final int m in Gamification.focusMilestoneMinutes) {
      if (continuousMinutes < m) {
        nextMilestone = m;
        break;
      }
    }

    return StudySurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.emoji_events_outlined, color: StudyColors.accent, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Focus streak rewards', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
            final double fill = earned ? 1 : (continuousMinutes / minutes).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: earned
                          ? StudyColors.primary.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      earned ? Icons.check_rounded : Icons.lock_outline_rounded,
                      size: 18,
                      color: earned ? StudyColors.primary : textSecondary,
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
                                color: earned ? StudyColors.primary : null,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: earned
                                    ? LinearGradient(
                                        colors: <Color>[StudyColors.primaryDark, StudyColors.primary],
                                      )
                                    : null,
                                color: earned ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
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
                            backgroundColor: StudyColors.primary.withValues(alpha: 0.1),
                            color: earned ? StudyColors.primary : StudyColors.primary.withValues(alpha: 0.45),
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
