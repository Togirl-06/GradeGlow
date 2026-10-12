import '../models/vu_game_models.dart';

/// Builds a stylized walkable workplace floor (shared engine, unique zones).
abstract final class CareerFloorFactory {
  static const double worldW = 920;
  static const double worldH = 620;

  static VuGameWorldLayout build({
    required String id,
    required String title,
    required List<VuGameZone> zones,
    required List<VuGameNpc> npcs,
    required List<VuGameInteractable> interactables,
    VuGameVec2 spawn = const VuGameVec2(120, 520),
    List<VuGameRect>? extraWalls,
  }) {
    return VuGameWorldLayout(
      id: id,
      title: title,
      worldSize: const VuGameVec2(worldW, worldH),
      playerSpawn: spawn,
      zones: zones,
      walls: <VuGameRect>[
        const VuGameRect(20, 20, 880, 16),
        const VuGameRect(20, 20, 16, 580),
        const VuGameRect(884, 20, 16, 580),
        const VuGameRect(20, 584, 880, 16),
        ...?extraWalls,
      ],
      npcs: npcs,
      interactables: interactables,
    );
  }

  /// Standard three-room workplace shell used by most majors.
  static VuGameWorldLayout workplace({
    required String id,
    required String title,
    required String lobbyName,
    required String workName,
    required String focusName,
    required int lobbyColor,
    required int workColor,
    required int focusColor,
    required List<VuGameNpc> npcs,
    required List<VuGameInteractable> interactables,
  }) {
    return build(
      id: id,
      title: title,
      zones: <VuGameZone>[
        VuGameZone(
          id: 'lobby',
          name: lobbyName,
          bounds: const VuGameRect(40, 420, 280, 180),
          floorColor: lobbyColor,
        ),
        VuGameZone(
          id: 'work',
          name: workName,
          bounds: const VuGameRect(340, 280, 540, 320),
          floorColor: workColor,
        ),
        VuGameZone(
          id: 'focus',
          name: focusName,
          bounds: const VuGameRect(40, 40, 840, 220),
          floorColor: focusColor,
        ),
      ],
      extraWalls: const <VuGameRect>[
        VuGameRect(300, 420, 20, 180),
        VuGameRect(40, 260, 860, 16),
        VuGameRect(520, 40, 16, 220),
      ],
      npcs: npcs,
      interactables: interactables,
    );
  }
}
