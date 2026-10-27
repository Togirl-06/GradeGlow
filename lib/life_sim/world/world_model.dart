/// Core world types: tiles, districts, buildings, interiors, interactables.
library;

enum Tile { grass, road, plaza, building, water }

extension TileWalk on Tile {
  bool get walkable => this == Tile.road || this == Tile.plaza || this == Tile.grass;
}

enum ActionType {
  sleep,
  eatHome,
  laptop,
  wardrobe,
  relaxHome,
  studyHome,
  decorate,
  payBills,
  shop, // arg = shop id: cafe, mall_clothing, mall_furniture, mall_food, grocery, transit
  bank,
  jobBoard,
  resumeDesk,
  interviewPractice,
  hrDesk, // arg = employer id
  clockIn, // arg = employer id
  workStation, // arg = station id
  breakRoom,
  enrolDesk,
  lectureHall,
  studyDesk,
  examHall,
  certDesk,
  healthCheck,
  watchMovie,
  workout,
  relaxPark,
  socialize,
  observeCourt,
  companyRegistry,
  talkNpc, // arg = npc id
}

class Interactable {
  const Interactable({
    required this.id,
    required this.name,
    required this.emoji,
    required this.x,
    required this.y,
    required this.type,
    this.arg,
    this.hint = '',
  });

  final String id;
  final String name;
  final String emoji;
  final int x;
  final int y;
  final ActionType type;
  final String? arg;
  final String hint;
}

class NpcDef {
  const NpcDef({
    required this.id,
    required this.name,
    required this.role,
    required this.x,
    required this.y,
    required this.persona,
    required this.lines,
    this.skinTone = 2,
    this.hairColor = 1,
    this.outfitColor = 0xFF6366F1,
    this.employerId,
  });

  final String id;
  final String name;
  final String role;
  final int x;
  final int y;

  /// Short description used to prompt the AI and to flavour offline chat.
  final String persona;

  /// Offline lines (also used when the AI is unreachable).
  final List<String> lines;
  final int skinTone;
  final int hairColor;
  final int outfitColor;
  final String? employerId;
}

class Interior {
  const Interior({
    required this.buildingId,
    required this.width,
    required this.height,
    required this.exitX,
    required this.exitY,
    required this.interactables,
    required this.npcs,
    this.floorColor = 0xFFE5E7EB,
    this.wallColor = 0xFF94A3B8,
  });

  final String buildingId;
  final int width;
  final int height;

  /// Walkable tile the avatar stands on when leaving / arriving.
  final int exitX;
  final int exitY;
  final List<Interactable> interactables;
  final List<NpcDef> npcs;
  final int floorColor;
  final int wallColor;

  bool blocked(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return true;
    for (final Interactable i in interactables) {
      if (i.x == x && i.y == y) return true;
    }
    for (final NpcDef n in npcs) {
      if (n.x == x && n.y == y) return true;
    }
    return false;
  }

  Interactable? interactableById(String id) {
    for (final Interactable i in interactables) {
      if (i.id == id) return i;
    }
    return null;
  }

  NpcDef? npcById(String id) {
    for (final NpcDef n in npcs) {
      if (n.id == id) return n;
    }
    return null;
  }
}

class District {
  const District({required this.id, required this.name, required this.emoji, required this.col, required this.row, required this.color});
  final String id;
  final String name;
  final String emoji;
  final int col;
  final int row;
  final int color;
}

class Building {
  const Building({
    required this.id,
    required this.name,
    required this.districtId,
    required this.emoji,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.openHour,
    required this.closeHour,
    required this.color,
    this.openWeekends = true,
    this.employerId,
  });

  final String id;
  final String name;
  final String districtId;
  final String emoji;
  final int x;
  final int y;
  final int w;
  final int h;
  final int openHour;
  final int closeHour;
  final int color;
  final bool openWeekends;
  final String? employerId;

  /// The plaza tile in front of the building where the avatar stands.
  int get doorX => x + w ~/ 2;
  int get doorY => y + h;

  bool isOpen(int day, int minuteOfDay) {
    final bool weekend = ((day - 1) % 7) >= 5;
    if (weekend && !openWeekends) return false;
    if (openHour == 0 && closeHour >= 24) return true;
    final int h = minuteOfDay ~/ 60;
    return h >= openHour && h < closeHour;
  }
}
