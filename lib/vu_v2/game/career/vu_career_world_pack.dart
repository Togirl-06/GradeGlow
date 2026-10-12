import '../models/vu_game_models.dart';
import '../services/vu_game_ai_dialogue.dart';
import 'objective_mission.dart';

/// One playable career world for the GradeGlow game engine (not old Labs).
class VuCareerWorldPack {
  const VuCareerWorldPack({
    required this.id,
    required this.majorId,
    required this.title,
    required this.subtitle,
    required this.role,
    required this.emoji,
    required this.accent,
    required this.welcomeTitle,
    required this.welcomeBody,
    required this.completeLabel,
    required this.achievement,
    required this.skillKeys,
    required this.layout,
    required this.dialogue,
    required this.mission,
    required this.objectHandlers,
    required this.supervisorNpcId,
    this.featured = false,
  });

  final String id;
  final String majorId;
  final String title;
  final String subtitle;
  final String role;
  final String emoji;
  final int accent;
  final String welcomeTitle;
  final String welcomeBody;
  final String completeLabel;
  final String achievement;
  /// Maps score category → progress skill key for persistence.
  final Map<String, String> skillKeys;
  final VuGameWorldLayout layout;
  final VuGameScriptedDialogue dialogue;
  final ObjectiveMission mission;
  /// actionId → feedback + objective marks + optional mistake.
  final Map<String, VuObjectHandler> objectHandlers;
  final String supervisorNpcId;
  final bool featured;
}

class VuObjectHandler {
  const VuObjectHandler({
    required this.toast,
    this.markObjectives = const <String>[],
    this.requiresMission = true,
    this.mistakeIfLocked = false,
    this.lockedToast,
    this.requireMarks = const <String>[],
    this.openDialogueId,
    this.vitalsLine,
  });

  final String toast;
  final List<String> markObjectives;
  final bool requiresMission;
  final bool mistakeIfLocked;
  final String? lockedToast;
  final List<String> requireMarks;
  final String? openDialogueId;
  final String? vitalsLine;
}
