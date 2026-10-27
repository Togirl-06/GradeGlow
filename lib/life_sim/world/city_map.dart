/// The GradeGlow campus and city: 15 districts on a tile grid, buildings, and pathfinding.
library;

import '../employment/employers.dart';
import 'world_model.dart';

class CityMap {
  CityMap._() {
    _build();
  }
  static final CityMap instance = CityMap._();

  static const int cellW = 12;
  static const int cellH = 10;
  static const int cols = 5;
  static const int rows = 3;
  static const int width = cols * cellW + 1;
  static const int height = rows * cellH + 1;

  /// Where a brand-new avatar starts (in front of Student Housing).
  static const int spawnBuildingIndex = 0;

  /// GradeGlow campus + city. Row 0 is the academic north campus, row 1 the
  /// schools and student services, row 2 the city where graduates work and live.
  static const List<District> districts = <District>[
    District(id: 'residential', name: 'Student Housing', emoji: '🏘️', col: 0, row: 0, color: 0xFF86EFAC),
    District(id: 'university', name: 'University Quarter', emoji: '🎓', col: 1, row: 0, color: 0xFFFDE68A),
    District(id: 'science', name: 'Science Quarter', emoji: '🔬', col: 2, row: 0, color: 0xFFBBF7D0),
    District(id: 'health', name: 'Health Sciences', emoji: '🩺', col: 3, row: 0, color: 0xFFFECACA),
    District(id: 'hospital', name: 'Hospital District', emoji: '🏥', col: 4, row: 0, color: 0xFFFCA5A5),
    District(id: 'commons', name: 'Campus Commons', emoji: '🤝', col: 0, row: 1, color: 0xFFFED7AA),
    District(id: 'technology', name: 'Technology Quarter', emoji: '💻', col: 1, row: 1, color: 0xFFC7D2FE),
    District(id: 'eng_math', name: 'Engineering & Mathematics', emoji: '⚙️', col: 2, row: 1, color: 0xFFFDE68A),
    District(id: 'law_arts', name: 'Law & Humanities', emoji: '⚖️', col: 3, row: 1, color: 0xFFFBCFE8),
    District(id: 'business', name: 'Business & Economics', emoji: '📈', col: 4, row: 1, color: 0xFFBFDBFE),
    District(id: 'courthouse', name: 'Courthouse Square', emoji: '🏛️', col: 0, row: 2, color: 0xFFD6D3D1),
    District(id: 'shopping', name: 'Shopping Centre', emoji: '🛍️', col: 1, row: 2, color: 0xFFFBCFE8),
    District(id: 'financial', name: 'Financial Quarter', emoji: '🏦', col: 2, row: 2, color: 0xFFA7F3D0),
    District(id: 'tech', name: 'Tech Park', emoji: '🚀', col: 3, row: 2, color: 0xFFC4B5FD),
    District(id: 'entertainment', name: 'Entertainment Row', emoji: '🎭', col: 4, row: 2, color: 0xFF99F6E4),
  ];

  /// Ids of the per-major school buildings (each has its own labs and career path).
  static const List<String> schoolIds = <String>[
    'school_cs',
    'school_medicine',
    'school_nursing',
    'school_law',
    'school_engineering',
    'school_business',
    'school_math',
    'school_arts',
    'school_biology',
    'school_chemistry',
    'school_physics',
  ];

  late final List<Building> buildings;
  late final List<List<Tile>> tiles;

  District districtById(String id) => districts.firstWhere((District d) => d.id == id);

  Building? buildingById(String id) {
    for (final Building b in buildings) {
      if (b.id == id) return b;
    }
    return null;
  }

  Building? buildingForEmployer(String employerId) {
    final Employer? e = EmployerCatalog.byId(employerId);
    return e == null ? null : buildingById(e.buildingId);
  }

  District districtAt(int x, int y) {
    final int c = (x ~/ cellW).clamp(0, cols - 1);
    final int r = (y ~/ cellH).clamp(0, rows - 1);
    return districts.firstWhere((District d) => d.col == c && d.row == r);
  }

  Building? buildingAtDoor(int x, int y) {
    for (final Building b in buildings) {
      if (b.doorX == x && b.doorY == y) return b;
    }
    return null;
  }

  /// A building whose door is within one tile of (x, y), if any.
  Building? buildingNear(int x, int y) {
    for (final Building b in buildings) {
      if ((b.doorX - x).abs() + (b.doorY - y).abs() <= 1) return b;
    }
    return null;
  }

  bool walkable(int x, int y) =>
      x >= 0 && y >= 0 && x < width && y < height && tiles[y][x].walkable;

  void _build() {
    final List<Building> out = <Building>[];
    void two(String district, Building a, Building b) {
      out
        ..add(a)
        ..add(b);
    }

    Building mk(String id, String name, String district, String emoji, int slot, int total,
        {int open = 8, int close = 20, bool weekends = true, int color = 0xFF94A3B8, String? employer}) {
      final District d = districts.firstWhere((District x) => x.id == district);
      final int cx = d.col * cellW;
      final int cy = d.row * cellH;
      final int w = total == 3 ? 3 : 5;
      final int x = total == 3 ? cx + 1 + slot * 4 : cx + (slot == 0 ? 1 : 7);
      return Building(
        id: id,
        name: name,
        districtId: district,
        emoji: emoji,
        x: x,
        y: cy + 2,
        w: w,
        h: 5,
        openHour: open,
        closeHour: close,
        openWeekends: weekends,
        color: color,
        employerId: employer,
      );
    }

    Building emp(String employerId, String district, int slot, int total, String emoji, {bool hospital = false}) {
      final Employer e = EmployerCatalog.require(employerId);
      return mk(e.buildingId, e.name, district, emoji, slot, total,
          open: hospital ? 0 : (e.startHour - 1).clamp(0, 23),
          close: hospital ? 24 : e.endHour + 1,
          weekends: hospital,
          color: e.accent,
          employer: e.id);
    }

    // ---- Row 0: north campus
    two('residential', mk('apartment_block', 'Student Housing', 'residential', '🏠', 0, 2, open: 0, close: 24, color: 0xFF22C55E),
        mk('corner_cafe', 'Corner Café', 'residential', '☕', 1, 2, open: 7, close: 22, color: 0xFFB45309));
    two('university', mk('university', 'University Hall', 'university', '🎓', 0, 2, open: 8, close: 18, weekends: false, color: 0xFFEAB308),
        mk('library', 'University Library', 'university', '📚', 1, 2, open: 7, close: 23, color: 0xFF92400E));
    out
      ..add(mk('school_biology', 'Biological Sciences Center', 'science', '🧬', 0, 3, open: 7, close: 22, color: 0xFF16A34A))
      ..add(mk('school_chemistry', 'Chemical Sciences Lab', 'science', '⚗️', 1, 3, open: 7, close: 22, color: 0xFF9333EA))
      ..add(mk('school_physics', 'Physical Sciences Center', 'science', '🔭', 2, 3, open: 7, close: 22, color: 0xFF0284C7));
    two('health', mk('school_medicine', 'School of Medicine', 'health', '🫀', 0, 2, open: 7, close: 22, color: 0xFFDC2626),
        mk('school_nursing', 'College of Nursing', 'health', '💉', 1, 2, open: 7, close: 22, color: 0xFF14B8A6));
    two('hospital', emp('st_gabriel', 'hospital', 0, 2, '🏥', hospital: true),
        emp('riverside', 'hospital', 1, 2, '🩺'));
    // ---- Row 1: schools and student services
    two('commons', mk('student_union', 'Student Union', 'commons', '🤝', 0, 2, open: 7, close: 23, color: 0xFFF43F5E),
        mk('employment_center', 'Career Center', 'commons', '💼', 1, 2, open: 8, close: 19, color: 0xFFF97316));
    two('technology', mk('school_cs', 'School of Computer Science', 'technology', '💻', 0, 2, open: 7, close: 23, color: 0xFF6366F1),
        mk('company_registry', 'Innovation Center', 'technology', '💡', 1, 2, open: 8, close: 20, color: 0xFF0EA5E9));
    two('eng_math', mk('school_engineering', 'Engineering Innovation Complex', 'eng_math', '⚙️', 0, 2, open: 7, close: 22, color: 0xFFF59E0B),
        mk('school_math', 'Mathematical Sciences Center', 'eng_math', '📐', 1, 2, open: 7, close: 22, color: 0xFF0891B2));
    two('law_arts', mk('school_law', 'College of Law & Justice', 'law_arts', '⚖️', 0, 2, open: 7, close: 22, color: 0xFF9F1239),
        mk('school_arts', 'Arts, Humanities & Communication', 'law_arts', '🎭', 1, 2, open: 7, close: 22, color: 0xFFDB2777));
    out
      ..add(mk('school_business', 'Business & Economics Tower', 'business', '📈', 0, 3, open: 7, close: 22, color: 0xFF2563EB))
      ..add(emp('meridian', 'business', 1, 3, '🏢'))
      ..add(emp('harbor_retail', 'business', 2, 3, '🏬'));
    // ---- Row 2: the city (workplaces, shops, fun)
    out
      ..add(emp('whitmore', 'courthouse', 0, 3, '⚖️'))
      ..add(emp('civic_legal', 'courthouse', 1, 3, '📜'))
      ..add(mk('courthouse', 'Glowland Courthouse', 'courthouse', '🏛️', 2, 3, open: 9, close: 17, weekends: false, color: 0xFF78716C));
    two('shopping', mk('mall', 'GradeGlow Mall', 'shopping', '🛍️', 0, 2, open: 9, close: 21, color: 0xFFEC4899),
        mk('grocery', 'Fresh Mart', 'shopping', '🛒', 1, 2, open: 7, close: 22, color: 0xFF16A34A));
    out
      ..add(mk('bank', 'Glow Bank', 'financial', '🏦', 0, 3, open: 9, close: 17, weekends: false, color: 0xFF059669))
      ..add(emp('ledger_co', 'financial', 1, 3, '🧾'))
      ..add(emp('ironclad', 'financial', 2, 3, '🔍'));
    two('tech', emp('pixelforge', 'tech', 0, 2, '🎮'), emp('nimbus', 'tech', 1, 2, '☁️'));
    out
      ..add(mk('cinema', 'Starlight Cinema', 'entertainment', '🎬', 0, 3, open: 10, close: 24, color: 0xFFDC2626))
      ..add(mk('gym', 'PulseFit Gym', 'entertainment', '🏋️', 1, 3, open: 6, close: 22, color: 0xFF0D9488))
      ..add(mk('park', 'Skyline Park', 'entertainment', '🌳', 2, 3, open: 0, close: 24, color: 0xFF65A30D));
    buildings = List<Building>.unmodifiable(out);

    tiles = List<List<Tile>>.generate(height, (int y) {
      return List<Tile>.generate(width, (int x) {
        if (x % cellW == 0 || y % cellH == 0) return Tile.road;
        final int ry = y % cellH;
        return ry >= 7 ? Tile.plaza : Tile.grass;
      });
    });
    for (final Building b in buildings) {
      for (int yy = b.y; yy < b.y + b.h; yy++) {
        for (int xx = b.x; xx < b.x + b.w; xx++) {
          tiles[yy][xx] = Tile.building;
        }
      }
    }
  }

  /// Breadth-first path from (sx,sy) to (gx,gy) on streets. Includes both ends.
  List<(int, int)> path(int sx, int sy, int gx, int gy) =>
      bfs(width, height, sx, sy, gx, gy, (int x, int y) => walkable(x, y));
}

/// Generic 4-direction BFS. Returns [] if unreachable.
List<(int, int)> bfs(int w, int h, int sx, int sy, int gx, int gy, bool Function(int, int) ok) {
  if (!ok(gx, gy) || !ok(sx, sy)) return <(int, int)>[];
  if (sx == gx && sy == gy) return <(int, int)>[(sx, sy)];
  final List<int> prev = List<int>.filled(w * h, -1);
  final List<int> queue = <int>[sy * w + sx];
  prev[sy * w + sx] = sy * w + sx;
  int head = 0;
  const List<(int, int)> dirs = <(int, int)>[(1, 0), (-1, 0), (0, 1), (0, -1)];
  while (head < queue.length) {
    final int cur = queue[head++];
    final int cx = cur % w;
    final int cy = cur ~/ w;
    for (final (int, int) d in dirs) {
      final int nx = cx + d.$1;
      final int ny = cy + d.$2;
      if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
      final int ni = ny * w + nx;
      if (prev[ni] != -1 || !ok(nx, ny)) continue;
      prev[ni] = cur;
      if (nx == gx && ny == gy) {
        final List<(int, int)> p = <(int, int)>[];
        int c = ni;
        while (c != sy * w + sx) {
          p.add((c % w, c ~/ w));
          c = prev[c];
        }
        p.add((sx, sy));
        return p.reversed.toList();
      }
      queue.add(ni);
    }
  }
  return <(int, int)>[];
}
