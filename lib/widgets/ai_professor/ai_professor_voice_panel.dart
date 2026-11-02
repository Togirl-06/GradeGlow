import 'package:flutter/material.dart';

import '../../models/virtual_university_learning_mode.dart';

export '../../models/virtual_university_learning_mode.dart';

/// Mode switcher + context panel for Read Aloud / AI Professor / Study.
class AiProfessorVoicePanel extends StatelessWidget {
  const AiProfessorVoicePanel({
    super.key,
    required this.mode,
    required this.onMode,
    required this.primaryColor,
    required this.surfaceColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    this.speaking = false,
    this.speed = 1,
    this.voiceReady = true,
    this.highlightSentence,
    this.onPlayPause,
    this.onStop,
    this.onSpeed,
    this.onRewind,
    this.onSkipAhead,
    this.studyActions = const <VirtualUniversityStudyAction>[],
  });

  final AiProfessorVoiceMode mode;
  final ValueChanged<AiProfessorVoiceMode> onMode;
  final Color primaryColor;
  final Color surfaceColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final bool speaking;
  final double speed;
  final bool voiceReady;
  final String? highlightSentence;
  final VoidCallback? onPlayPause;
  final VoidCallback? onStop;
  final ValueChanged<double>? onSpeed;
  final VoidCallback? onRewind;
  final VoidCallback? onSkipAhead;
  final List<VirtualUniversityStudyAction> studyActions;

  static const List<double> speeds = <double>[0.5, 0.75, 1, 1.25, 1.5, 2];

  String get _speedLabel {
    if (speed == 1) return '1x';
    if (speed == speed.roundToDouble()) return '${speed.toInt()}x';
    return '${speed}x';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'LEARNING FLOW',
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: AiProfessorVoiceMode.values.map((AiProfessorVoiceMode m) {
              final bool selected = mode == m;
              return ChoiceChip(
                avatar: Icon(m.icon, size: 16, color: selected ? primaryColor : textSecondaryColor),
                label: Text(m.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                selected: selected,
                onSelected: (_) => onMode(m),
                selectedColor: primaryColor.withValues(alpha: 0.14),
                labelStyle: TextStyle(color: selected ? primaryColor : textPrimaryColor),
                side: BorderSide(
                  color: selected ? primaryColor.withValues(alpha: 0.5) : primaryColor.withValues(alpha: 0.15),
                ),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          _ModeBody(
            mode: mode,
            primaryColor: primaryColor,
            textPrimaryColor: textPrimaryColor,
            textSecondaryColor: textSecondaryColor,
            speaking: speaking,
            voiceReady: voiceReady,
            speedLabel: _speedLabel,
            highlightSentence: highlightSentence,
            onPlayPause: onPlayPause,
            onStop: onStop,
            onSpeed: onSpeed,
            onRewind: onRewind,
            onSkipAhead: onSkipAhead,
            studyActions: studyActions,
          ),
        ],
      ),
    );
  }
}

class _ModeBody extends StatelessWidget {
  const _ModeBody({
    required this.mode,
    required this.primaryColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.speaking,
    required this.voiceReady,
    required this.speedLabel,
    required this.studyActions,
    this.highlightSentence,
    this.onPlayPause,
    this.onStop,
    this.onSpeed,
    this.onRewind,
    this.onSkipAhead,
  });

  final AiProfessorVoiceMode mode;
  final Color primaryColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final bool speaking;
  final bool voiceReady;
  final String speedLabel;
  final String? highlightSentence;
  final VoidCallback? onPlayPause;
  final VoidCallback? onStop;
  final ValueChanged<double>? onSpeed;
  final VoidCallback? onRewind;
  final VoidCallback? onSkipAhead;
  final List<VirtualUniversityStudyAction> studyActions;

  @override
  Widget build(BuildContext context) {
    return switch (mode) {
      AiProfessorVoiceMode.readAloud => _ReadAloudBody(
          primaryColor: primaryColor,
          textPrimaryColor: textPrimaryColor,
          textSecondaryColor: textSecondaryColor,
          speaking: speaking,
          voiceReady: voiceReady,
          speedLabel: speedLabel,
          highlightSentence: highlightSentence,
          onPlayPause: onPlayPause,
          onStop: onStop,
          onSpeed: onSpeed,
          onRewind: onRewind,
          onSkipAhead: onSkipAhead,
          mode: mode,
        ),
      AiProfessorVoiceMode.professor => _InfoBody(mode: mode, primaryColor: primaryColor, textSecondaryColor: textSecondaryColor),
      AiProfessorVoiceMode.study => _StudyBody(
          mode: mode,
          primaryColor: primaryColor,
          textPrimaryColor: textPrimaryColor,
          textSecondaryColor: textSecondaryColor,
          studyActions: studyActions,
        ),
    };
  }
}

class _ReadAloudBody extends StatelessWidget {
  const _ReadAloudBody({
    required this.mode,
    required this.primaryColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.speaking,
    required this.voiceReady,
    required this.speedLabel,
    this.highlightSentence,
    this.onPlayPause,
    this.onStop,
    this.onSpeed,
    this.onRewind,
    this.onSkipAhead,
  });

  final AiProfessorVoiceMode mode;
  final Color primaryColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final bool speaking;
  final bool voiceReady;
  final String speedLabel;
  final String? highlightSentence;
  final VoidCallback? onPlayPause;
  final VoidCallback? onStop;
  final ValueChanged<double>? onSpeed;
  final VoidCallback? onRewind;
  final VoidCallback? onSkipAhead;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _InfoBody(mode: mode, primaryColor: primaryColor, textSecondaryColor: textSecondaryColor, compact: true),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            FilledButton.icon(
              onPressed: onPlayPause,
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(speaking ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 18),
              label: Text(
                speaking ? 'Pause' : (voiceReady ? 'Play narration' : 'Retry'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onStop,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.stop_rounded, size: 16),
              label: const Text('Stop', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            OutlinedButton.icon(
              onPressed: onRewind,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.replay_10_rounded, size: 16),
              label: const Text('Back', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            OutlinedButton.icon(
              onPressed: onSkipAhead,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.forward_10_rounded, size: 16),
              label: const Text('Skip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            if (onSpeed != null)
              PopupMenuButton<double>(
                tooltip: 'Playback speed',
                onSelected: onSpeed,
                itemBuilder: (BuildContext context) => AiProfessorVoicePanel.speeds
                    .map((double s) => PopupMenuItem<double>(
                          value: s,
                          child: Text(s == 1 ? '1x' : '${s}x'),
                        ))
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
                  ),
                  child: Text('Speed $speedLabel', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 11)),
                ),
              ),
          ],
        ),
        if (highlightSentence != null && highlightSentence!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              highlightSentence!,
              style: TextStyle(color: textPrimaryColor, fontSize: 12, height: 1.45, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoBody extends StatelessWidget {
  const _InfoBody({
    required this.mode,
    required this.primaryColor,
    required this.textSecondaryColor,
    this.compact = false,
  });

  final AiProfessorVoiceMode mode;
  final Color primaryColor;
  final Color textSecondaryColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${mode.role} · ${mode.summary}',
            style: TextStyle(color: primaryColor, fontSize: compact ? 11 : 12, fontWeight: FontWeight.w800, height: 1.35),
          ),
          if (!compact) ...<Widget>[
            const SizedBox(height: 6),
            ...mode.bullets.map(
              (String b) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('• ', style: TextStyle(color: textSecondaryColor, fontSize: 11)),
                    Expanded(
                      child: Text(b, style: TextStyle(color: textSecondaryColor, fontSize: 11, height: 1.35)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StudyBody extends StatelessWidget {
  const _StudyBody({
    required this.mode,
    required this.primaryColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.studyActions,
  });

  final AiProfessorVoiceMode mode;
  final Color primaryColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final List<VirtualUniversityStudyAction> studyActions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _InfoBody(mode: mode, primaryColor: primaryColor, textSecondaryColor: textSecondaryColor),
        if (studyActions.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          ...studyActions.map(
            (VirtualUniversityStudyAction action) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: OutlinedButton(
                onPressed: action.onTap,
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  side: BorderSide(color: primaryColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(action.icon, size: 18, color: primaryColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            action.label,
                            style: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                          Text(
                            action.description,
                            style: TextStyle(color: textSecondaryColor, fontSize: 10, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Study tools for this topic will appear here.',
              style: TextStyle(color: textSecondaryColor, fontSize: 11),
            ),
          ),
      ],
    );
  }
}
