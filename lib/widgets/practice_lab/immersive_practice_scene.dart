import 'package:flutter/material.dart';

import '../../data/practice_lab_scene_config.dart';
import '../../models/ai_practice_mode.dart';
import '../../models/practice_lab.dart';
import '../ai_practice/ai_practice_avatar.dart';
import 'practice_lab_game_widgets.dart';
import 'venue_scene_backdrops.dart';

/// Mockup-style immersive practice session — cinematic scene, side panels, action bar.
class ImmersivePracticeScene extends StatelessWidget {
  const ImmersivePracticeScene({
    super.key,
    required this.category,
    required this.lab,
    required this.config,
    required this.start,
    required this.avatarRole,
    required this.speechText,
    required this.isSpeaking,
    required this.emotion,
    required this.liveScore,
    required this.skillScores,
    this.topicAreaName,
    this.topicName,
    this.completedQuestSteps = const <int>{},
    this.sessionXp = 0,
    this.elapsed = Duration.zero,
    required this.onAction,
  });

  final PracticeLabCategory category;
  final PracticeLabType lab;
  final PracticeLabSceneConfig config;
  final SimulationStart start;
  final AvatarRole avatarRole;
  final String speechText;
  final bool isSpeaking;
  final AvatarEmotion emotion;
  final int liveScore;
  final Map<String, int> skillScores;
  final String? topicAreaName;
  final String? topicName;
  final Set<int> completedQuestSteps;
  final int sessionXp;
  final Duration elapsed;
  final ValueChanged<SceneAction> onAction;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide = width >= 760;

    return ColoredBox(
      color: const Color(0xFF070B14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SceneHeader(
            majorName: category.name.toUpperCase(),
            venueTitle: config.venueTitle,
            accent: config.accent,
            icon: config.sceneIcon,
            liveScore: liveScore,
          ),
          PracticeLabSessionGameHud(
            missionTitle: start.scenarioTitle,
            questSteps: config.checklist,
            completedSteps: completedQuestSteps,
            sessionXp: sessionXp,
            liveScore: liveScore,
            elapsed: elapsed,
            accent: config.accent,
          ),
          if (wide)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(width: 168, child: _LeftChecklist(config: config, completedSteps: completedQuestSteps)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CinematicStage(
                        config: config,
                        avatarRole: avatarRole,
                        speechText: speechText,
                        isSpeaking: isSpeaking,
                        emotion: emotion,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 188,
                      child: _ContextPanel(
                        config: config,
                        start: start,
                        lab: lab,
                        topicAreaName: topicAreaName,
                        topicName: topicName,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                children: <Widget>[
                  _CinematicStage(
                    config: config,
                    avatarRole: avatarRole,
                    speechText: speechText,
                    isSpeaking: isSpeaking,
                    emotion: emotion,
                    height: 260,
                  ),
                  const SizedBox(height: 10),
                  _ContextPanel(
                    config: config,
                    start: start,
                    lab: lab,
                    topicAreaName: topicAreaName,
                    topicName: topicName,
                  ),
                  const SizedBox(height: 10),
                  _LeftChecklist(config: config, horizontal: true, completedSteps: completedQuestSteps),
                ],
              ),
            ),
          if (skillScores.isNotEmpty) _SkillStrip(scores: skillScores, accent: config.accent),
          if (config.venue == PracticeLabVenue.hospital)
            HospitalVitalsBar(vitals: start.vitals, accent: config.accent),
          if (config.venue == PracticeLabVenue.courtroom)
            CourtroomStatusBar(
              accent: config.accent,
              caseName: start.contextFields['Case'] ?? start.scenarioTitle,
            ),
          _ActionBar(config: config, onAction: onAction),
        ],
      ),
    );
  }
}

class _SceneHeader extends StatelessWidget {
  const _SceneHeader({
    required this.majorName,
    required this.venueTitle,
    required this.accent,
    required this.icon,
    required this.liveScore,
  });

  final String majorName;
  final String venueTitle;
  final Color accent;
  final IconData icon;
  final int liveScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.25))),
        gradient: LinearGradient(colors: <Color>[accent.withValues(alpha: 0.12), Colors.transparent]),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(majorName, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
                Text(venueTitle, style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.6)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Text('$liveScore%', style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _LeftChecklist extends StatelessWidget {
  const _LeftChecklist({required this.config, this.horizontal = false, this.completedSteps = const <int>{}});

  final PracticeLabSceneConfig config;
  final bool horizontal;
  final Set<int> completedSteps;

  Widget _item(String text, int index) {
    final bool done = completedSteps.contains(index);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 15,
          color: done ? config.accent : Colors.white38,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: done ? config.accent : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: config.accent.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = horizontal
        ? Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List<Widget>.generate(config.checklist.length, (int i) => _item(config.checklist[i], i)),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('OBJECTIVES', style: TextStyle(color: config.accent, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(config.tagline, style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 12, height: 1.4)),
              const SizedBox(height: 14),
              ...List<Widget>.generate(
                config.checklist.length,
                (int i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _item(config.checklist[i], i)),
              ),
            ],
          );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: body,
    );
  }
}

class _ContextPanel extends StatelessWidget {
  const _ContextPanel({
    required this.config,
    required this.start,
    required this.lab,
    this.topicAreaName,
    this.topicName,
  });

  final PracticeLabSceneConfig config;
  final SimulationStart start;
  final PracticeLabType lab;
  final String? topicAreaName;
  final String? topicName;

  @override
  Widget build(BuildContext context) {
    final List<({String label, String value})> rows = <({String label, String value})>[];

    if (start.contextFields.isNotEmpty) {
      for (final MapEntry<String, String> entry in start.contextFields.entries) {
        rows.add((label: entry.key, value: entry.value));
      }
    } else {
      rows.addAll(<({String label, String value})>[
        (label: 'Scenario', value: start.scenarioTitle),
        (label: 'AI Role', value: start.aiRole),
        if (lab.difficulty.isNotEmpty) (label: 'Difficulty', value: lab.difficulty),
        if (topicName != null && topicName!.isNotEmpty) (label: 'Topic', value: topicName!),
        if (topicAreaName != null && topicAreaName!.isNotEmpty) (label: 'Topic Area', value: topicAreaName!),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: config.accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(config.panelTitle.toUpperCase(), style: TextStyle(color: config.accent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          ...rows.map(
            (({String label, String value}) row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(row.label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(row.value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, height: 1.35)),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white12, height: 16),
          Text(
            start.briefing,
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 11.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _CinematicStage extends StatelessWidget {
  const _CinematicStage({
    required this.config,
    required this.avatarRole,
    required this.speechText,
    required this.isSpeaking,
    required this.emotion,
    this.height,
  });

  final PracticeLabSceneConfig config;
  final AvatarRole avatarRole;
  final String speechText;
  final bool isSpeaking;
  final AvatarEmotion emotion;
  final double? height;

  Alignment get _characterAlignment => switch (config.venue) {
        PracticeLabVenue.hospital => const Alignment(0.05, 0.55),
        PracticeLabVenue.courtroom => const Alignment(0.35, 0.62),
        PracticeLabVenue.therapyRoom => const Alignment(-0.2, 0.6),
        _ => const Alignment(0, 0.72),
      };

  String get _characterLabel => switch (config.venue) {
        PracticeLabVenue.hospital => 'Live Patient',
        PracticeLabVenue.courtroom => 'Witness / Client',
        PracticeLabVenue.therapyRoom => 'Client',
        PracticeLabVenue.boardroom => 'Executive',
        PracticeLabVenue.classroom => 'Student',
        _ => 'AI Character',
      };

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: height != null ? StackFit.loose : StackFit.expand,
          children: <Widget>[
            Positioned.fill(child: VenueSceneBackdrop(config: config)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                  ),
                ),
              ),
            ),
            Align(
              alignment: _characterAlignment,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AiPracticeAvatar(
                    role: avatarRole,
                    isSpeaking: isSpeaking,
                    emotion: emotion,
                    size: height != null ? 100 : 118,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: config.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: config.accent.withValues(alpha: 0.4)),
                    ),
                    child: Text(_characterLabel, style: TextStyle(color: config.accent, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
            if (speechText.isNotEmpty)
              Positioned(
                left: 14,
                right: 14,
                top: 14,
                child: _SceneSpeechBubble(text: speechText, isSpeaking: isSpeaking, accent: config.accent),
              ),
          ],
        ),
      ),
    );
  }
}

class _SceneSpeechBubble extends StatelessWidget {
  const _SceneSpeechBubble({required this.text, required this.isSpeaking, required this.accent});

  final String text;
  final bool isSpeaking;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isSpeaking)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('Speaking…', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: accent)),
            ),
          Text(
            '"$text"',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13.5, height: 1.45, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.config, required this.onAction});

  final PracticeLabSceneConfig config;
  final ValueChanged<SceneAction> onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1220),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: config.actions.asMap().entries.map((MapEntry<int, SceneAction> entry) {
            final SceneAction action = entry.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: action.primary
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: config.accent.withValues(alpha: 0.45), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: FilledButton.icon(
                        onPressed: () => onAction(action),
                        style: FilledButton.styleFrom(
                          backgroundColor: config.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(action.icon, size: 18),
                        label: Text(action.label, style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: () => onAction(action),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: config.accent.withValues(alpha: 0.45)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(action.icon, size: 17, color: config.accent),
                      label: Text(action.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SkillStrip extends StatelessWidget {
  const _SkillStrip({required this.scores, required this.accent});

  final Map<String, int> scores;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: scores.entries
            .map(
              (MapEntry<String, int> e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text('${e.key}: ${e.value}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  backgroundColor: accent.withValues(alpha: 0.14),
                  side: BorderSide(color: accent.withValues(alpha: 0.35)),
                  labelStyle: TextStyle(color: accent),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
