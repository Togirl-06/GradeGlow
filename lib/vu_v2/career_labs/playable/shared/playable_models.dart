import 'package:flutter/material.dart';

class PlayableRoom {
  const PlayableRoom({
    required this.id,
    required this.name,
    required this.icon,
    required this.blurb,
    required this.atmosphere,
    this.lockedUntilStageId,
  });

  final String id;
  final String name;
  final String icon;
  final String blurb;
  final String atmosphere;
  final String? lockedUntilStageId;
}

class PlayableStage {
  const PlayableStage({
    required this.id,
    required this.locationId,
    required this.bannerTitle,
    required this.bannerBody,
    required this.cta,
    required this.unlockKey,
    this.requiresKey,
  });

  final String id;
  final String locationId;
  final String bannerTitle;
  final String bannerBody;
  final String cta;
  final String unlockKey;
  final String? requiresKey;
}

class PlayableCareer {
  const PlayableCareer({
    required this.id,
    required this.accent,
    required this.bg,
    required this.surface,
    required this.workplaceName,
    required this.clockLine,
    required this.roleTitle,
    required this.supervisorName,
    required this.supervisorRole,
    required this.hireTagline,
    required this.supervisorBrief,
    required this.enterCta,
    required this.startCta,
    required this.startLocationId,
    required this.rooms,
    required this.stages,
    this.roleGlyph = '🧑‍💼',
    this.supervisorGlyph = '👤',
    this.liveLabel = 'LIVE SHIFT',
    this.ambientFeed = const <String>[],
    this.meterLabels = const <String>['Pressure', 'Trust', 'Progress'],
  });

  final String id;
  final Color accent;
  final Color bg;
  final Color surface;
  final String workplaceName;
  final String clockLine;
  final String roleTitle;
  final String supervisorName;
  final String supervisorRole;
  final String hireTagline;
  final String supervisorBrief;
  final String enterCta;
  final String startCta;
  final String startLocationId;
  final List<PlayableRoom> rooms;
  final List<PlayableStage> stages;
  final String roleGlyph;
  final String supervisorGlyph;
  final String liveLabel;
  final List<String> ambientFeed;
  final List<String> meterLabels;
}
