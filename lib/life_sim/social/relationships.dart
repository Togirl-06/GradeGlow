/// How well the player knows each NPC. Relationships grow only through
/// actual conversations (never automatically).
class RelationshipEntry {
  RelationshipEntry({this.level = 0, this.talks = 0, this.lastTalkDay = 0, this.talksToday = 0});

  double level; // 0..100
  int talks;
  int lastTalkDay;
  int talksToday;

  Map<String, Object?> toJson() => <String, Object?>{
        'level': level,
        'talks': talks,
        'lastTalkDay': lastTalkDay,
        'talksToday': talksToday,
      };

  factory RelationshipEntry.fromJson(Map<String, Object?> j) => RelationshipEntry(
        level: (j['level'] as num?)?.toDouble() ?? 0,
        talks: (j['talks'] as num?)?.toInt() ?? 0,
        lastTalkDay: (j['lastTalkDay'] as num?)?.toInt() ?? 0,
        talksToday: (j['talksToday'] as num?)?.toInt() ?? 0,
      );
}

class Relationships {
  Relationships([Map<String, RelationshipEntry>? entries]) : entries = entries ?? <String, RelationshipEntry>{};

  final Map<String, RelationshipEntry> entries;

  RelationshipEntry of(String npcId) => entries[npcId] ?? RelationshipEntry();

  static String title(double level) {
    if (level < 8) return 'Stranger';
    if (level < 30) return 'Acquaintance';
    if (level < 60) return 'Friend';
    if (level < 85) return 'Close friend';
    return 'Best friend';
  }

  /// Records a conversation and returns the level gained. The first chat of
  /// a day is worth the most; further chats the same day add very little.
  double talk(String npcId, int day, {bool friendly = false}) {
    final RelationshipEntry e = entries.putIfAbsent(npcId, RelationshipEntry.new);
    if (e.lastTalkDay != day) {
      e.lastTalkDay = day;
      e.talksToday = 0;
    }
    e.talksToday++;
    e.talks++;
    final double gain = (e.talksToday == 1 ? (friendly ? 5 : 4) : (e.talksToday <= 3 ? 0.5 : 0)).toDouble();
    final double before = e.level;
    e.level = (e.level + gain).clamp(0, 100).toDouble();
    return e.level - before;
  }

  Map<String, Object?> toJson() => entries.map((String k, RelationshipEntry v) => MapEntry<String, Object?>(k, v.toJson()));

  factory Relationships.fromJson(Object? j) {
    final Relationships r = Relationships();
    if (j is Map) {
      j.forEach((Object? k, Object? v) {
        if (v is Map) r.entries[k.toString()] = RelationshipEntry.fromJson(Map<String, Object?>.from(v));
      });
    }
    return r;
  }
}
