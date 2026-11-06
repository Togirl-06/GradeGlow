/// CAD drawing task: the student draws a part (outline and holes, in mm) on a
/// sheet, dimensions it, fills in the title block, and submits it for checking.
///
/// Marking is deterministic and follows drafting practice:
///  * the geometry must match the specification within a placement tolerance;
///  * every feature must be located from the datum edges (left and bottom)
///    through a chain of dimensions — a drawing that cannot be manufactured
///    from its dimensions is not complete;
///  * redundant dimensions (closing a chain that is already fixed) are faults;
///  * toleranced holes must carry their tolerance on the diameter dimension;
///  * the title block must state the right scale, projection and units.
library;

import '../../model/career_models.dart';
import '../lab_grading.dart';
import '../lab_models.dart';

/// A required hole: centre (x, y) from the bottom-left corner, diameter [d].
class HoleSpec {
  const HoleSpec(this.x, this.y, this.d, {this.tol});
  final double x;
  final double y;
  final double d;

  /// Tolerance the diameter dimension must carry, e.g. 'H7' or '±0.05'.
  final String? tol;
}

/// What the finished drawing must show.
class DrawingSpec {
  const DrawingSpec({
    required this.width,
    required this.height,
    this.holes = const <HoleSpec>[],
    this.requireDimensions = true,
    this.forbidRedundant = true,
    this.allowCountNotes = false,
    this.title = const <String, String>{},
    this.placementTol = 0.5,
  });
  final double width;
  final double height;
  final List<HoleSpec> holes;

  /// Every feature must be fully located by dimensions from the datums.
  final bool requireDimensions;

  /// Dimensions that over-constrain the part are faults.
  final bool forbidRedundant;

  /// One diameter dimension noted "4×" may cover four equal holes.
  final bool allowCountNotes;

  /// Title-block field → required value.
  final Map<String, String> title;

  /// How close a drawn feature must be to the specified position (mm).
  final double placementTol;
}

// ------------------------------------------------------------ the drawing

class DrawCircle {
  const DrawCircle(this.x, this.y, this.d);
  factory DrawCircle.fromJson(Map<String, dynamic> j) => DrawCircle(_d(j['x']), _d(j['y']), _d(j['d']));
  final double x;
  final double y;
  final double d;
  Map<String, Object> toJson() => <String, Object>{'x': x, 'y': y, 'd': d};
}

/// A dimension. [kind] is 'h' (horizontal), 'v' (vertical) or 'd' (diameter).
/// For h/v, [from] and [to] are references: 'L', 'R', 'B', 'T' (outline edges)
/// or 'c0', 'c1' … (hole centres). For 'd', [from] is the hole reference.
class DrawDim {
  const DrawDim(this.kind, this.from, [this.to = '', this.note = '']);
  factory DrawDim.fromJson(Map<String, dynamic> j) => DrawDim('${j['k'] ?? ''}', '${j['a'] ?? ''}', '${j['b'] ?? ''}', '${j['n'] ?? ''}');
  final String kind;
  final String from;
  final String to;
  final String note;
  Map<String, Object> toJson() => <String, Object>{'k': kind, 'a': from, 'b': to, 'n': note};
}

class Drawing {
  const Drawing({this.width, this.height, this.circles = const <DrawCircle>[], this.dims = const <DrawDim>[], this.title = const <String, String>{}});

  factory Drawing.fromJson(Map<String, dynamic> j) => Drawing(
        width: j['w'] == null ? null : _d(j['w']),
        height: j['h'] == null ? null : _d(j['h']),
        circles: <DrawCircle>[for (final dynamic c in (j['c'] as List<dynamic>? ?? const <dynamic>[])) DrawCircle.fromJson(c as Map<String, dynamic>)],
        dims: <DrawDim>[for (final dynamic c in (j['m'] as List<dynamic>? ?? const <dynamic>[])) DrawDim.fromJson(c as Map<String, dynamic>)],
        title: <String, String>{for (final MapEntry<String, dynamic> e in (j['t'] as Map<String, dynamic>? ?? const <String, dynamic>{}).entries) e.key: '${e.value}'},
      );

  /// Outline rectangle, drawn from the origin (bottom-left corner).
  final double? width;
  final double? height;
  final List<DrawCircle> circles;
  final List<DrawDim> dims;
  final Map<String, String> title;

  Map<String, Object?> toJson() => <String, Object?>{
        'w': width,
        'h': height,
        'c': <Object>[for (final DrawCircle c in circles) c.toJson()],
        'm': <Object>[for (final DrawDim d in dims) d.toJson()],
        't': title,
      };

  Drawing copyWith({double? width, double? height, List<DrawCircle>? circles, List<DrawDim>? dims, Map<String, String>? title}) =>
      Drawing(width: width ?? this.width, height: height ?? this.height, circles: circles ?? this.circles, dims: dims ?? this.dims, title: title ?? this.title);

  /// Coordinate of a reference along an axis ('x' for h dims, 'y' for v dims).
  double? coord(String ref, String axis) {
    if (width == null || height == null) return null;
    switch (ref) {
      case 'L':
        return axis == 'x' ? 0 : null;
      case 'R':
        return axis == 'x' ? width : null;
      case 'B':
        return axis == 'y' ? 0 : null;
      case 'T':
        return axis == 'y' ? height : null;
    }
    final int? i = ref.startsWith('c') ? int.tryParse(ref.substring(1)) : null;
    if (i == null || i < 0 || i >= circles.length) return null;
    return axis == 'x' ? circles[i].x : circles[i].y;
  }

  /// Measured value of a dimension, or null if its references are invalid.
  double? value(DrawDim m) {
    if (m.kind == 'd') {
      final int? i = m.from.startsWith('c') ? int.tryParse(m.from.substring(1)) : null;
      return i == null || i < 0 || i >= circles.length ? null : circles[i].d;
    }
    final String axis = m.kind == 'h' ? 'x' : 'y';
    final double? a = coord(m.from, axis), b = coord(m.to, axis);
    return a == null || b == null || m.from == m.to ? null : (b - a).abs();
  }
}

double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? double.nan;

/// Human label for a reference.
String refLabel(String r) => switch (r) {
      'L' => 'left edge',
      'R' => 'right edge',
      'B' => 'bottom edge',
      'T' => 'top edge',
      _ => 'hole ${(int.tryParse(r.substring(1)) ?? 0) + 1} centre',
    };

String fmtMm(double v) {
  final String s = v.toStringAsFixed(2);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

// ------------------------------------------------------------ the step

class DrawingStep extends LabStep {
  const DrawingStep({
    required super.id,
    required super.title,
    required super.instructions,
    required this.spec,
    required this.model,
    this.titleOptions = const <String, List<String>>{},
    super.skills,
    super.passMark = 80,
  });
  final DrawingSpec spec;

  /// A correct drawing (used by the tests to prove the task can be passed).
  final Drawing model;

  /// Title-block field → choices offered.
  final Map<String, List<String>> titleOptions;

  @override
  String get kind => 'CAD drawing';
}

class _Uf {
  final Map<String, String> p = <String, String>{};
  String find(String a) {
    p.putIfAbsent(a, () => a);
    while (p[a] != a) {
      p[a] = p[p[a]!]!;
      a = p[a]!;
    }
    return a;
  }

  /// Joins a and b; false if they were already connected (redundant link).
  bool union(String a, String b) {
    final String x = find(a), y = find(b);
    if (x == y) return false;
    p[x] = y;
    return true;
  }
}

String _norm(String s) => s.toLowerCase().replaceAll(' ', '').replaceAll('+/-', '±').replaceAll('×', 'x');

abstract final class DrawingGrader {
  static TaskResult grade(DrawingStep step, Drawing d) {
    final DrawingSpec s = step.spec;
    if (d.width == null || d.height == null) throw LabGradingException('Draw the outline first (width and height).');
    final double tol = s.placementTol;
    int ok = 0, total = 0;
    bool geometryWrong = false;
    final List<String> fb = <String>[];

    // 1. Outline.
    total++;
    if ((d.width! - s.width).abs() <= tol && (d.height! - s.height).abs() <= tol) {
      ok++;
      fb.add('✓ Outline ${fmtMm(d.width!)} × ${fmtMm(d.height!)} mm.');
    } else {
      geometryWrong = true;
      fb.add('✗ Outline is ${fmtMm(d.width!)} × ${fmtMm(d.height!)} mm; the part is ${fmtMm(s.width)} × ${fmtMm(s.height)} mm.');
    }

    // 2. Holes: match each required hole to a drawn circle.
    final Map<int, int> match = <int, int>{}; // spec index → circle index
    final Set<int> used = <int>{};
    for (int i = 0; i < s.holes.length; i++) {
      final HoleSpec h = s.holes[i];
      total++;
      int? best;
      for (int j = 0; j < d.circles.length; j++) {
        if (used.contains(j)) continue;
        final DrawCircle c = d.circles[j];
        if ((c.x - h.x).abs() <= tol && (c.y - h.y).abs() <= tol) {
          best = j;
          break;
        }
      }
      if (best == null) {
        geometryWrong = true;
        fb.add('✗ Missing hole Ø${fmtMm(h.d)} at (${fmtMm(h.x)}, ${fmtMm(h.y)}).');
        continue;
      }
      used.add(best);
      match[i] = best;
      final DrawCircle c = d.circles[best];
      if ((c.d - h.d).abs() <= 0.05) {
        ok++;
        fb.add('✓ Hole ${best + 1}: Ø${fmtMm(c.d)} at (${fmtMm(c.x)}, ${fmtMm(c.y)}).');
      } else {
        geometryWrong = true;
        fb.add('✗ Hole ${best + 1} is Ø${fmtMm(c.d)}; it should be Ø${fmtMm(h.d)}.');
      }
    }
    for (int j = 0; j < d.circles.length; j++) {
      if (!used.contains(j)) {
        geometryWrong = true;
        total++;
        fb.add('✗ Hole ${j + 1} at (${fmtMm(d.circles[j].x)}, ${fmtMm(d.circles[j].y)}) is not on the part — it would be machined by mistake.');
      }
    }
    for (int j = 0; j < d.circles.length; j++) {
      final DrawCircle c = d.circles[j];
      if (c.x - c.d / 2 < 0 || c.y - c.d / 2 < 0 || c.x + c.d / 2 > d.width! || c.y + c.d / 2 > d.height!) {
        fb.add('✗ Hole ${j + 1} breaks out of the outline.');
        geometryWrong = true;
      }
    }

    // 3. Dimensions.
    if (s.requireDimensions) {
      final _Uf ux = _Uf(), uy = _Uf();
      final Map<int, List<DrawDim>> dia = <int, List<DrawDim>>{};
      int redundant = 0, invalid = 0;
      for (final DrawDim m in d.dims) {
        final double? v = d.value(m);
        if (v == null) {
          invalid++;
          continue;
        }
        if (m.kind == 'd') {
          (dia[int.parse(m.from.substring(1))] ??= <DrawDim>[]).add(m);
          continue;
        }
        final bool fresh = (m.kind == 'h' ? ux : uy).union(m.from, m.to);
        if (!fresh) {
          redundant++;
          fb.add('✗ Redundant dimension: ${refLabel(m.from)} to ${refLabel(m.to)} (${fmtMm(v)}) is already fixed by other dimensions.');
        }
      }
      if (invalid > 0) fb.add('✗ $invalid dimension(s) refer to features that are not on the drawing.');

      total++;
      if (ux.find('L') == ux.find('R')) {
        ok++;
        fb.add('✓ Overall width dimensioned.');
      } else {
        fb.add('✗ The overall width is not dimensioned.');
      }
      total++;
      if (uy.find('B') == uy.find('T')) {
        ok++;
        fb.add('✓ Overall height dimensioned.');
      } else {
        fb.add('✗ The overall height is not dimensioned.');
      }
      for (final MapEntry<int, int> e in match.entries) {
        final String r = 'c${e.value}';
        total++;
        final bool lx = ux.find(r) == ux.find('L'), ly = uy.find(r) == uy.find('B');
        if (lx && ly) {
          ok++;
          fb.add('✓ Hole ${e.value + 1} is located from the datums.');
        } else {
          fb.add('✗ Hole ${e.value + 1} is not located ${!lx && !ly ? 'in x or y' : !lx ? 'horizontally' : 'vertically'} from the datum edges.');
        }
      }
      // Diameters (a "4×" note covers that many equal holes).
      final Map<int, int> coveredBy = <int, int>{};
      for (final MapEntry<int, List<DrawDim>> e in dia.entries) {
        if (e.value.length > 1) {
          redundant += e.value.length - 1;
          fb.add('✗ Hole ${e.key + 1} has its diameter dimensioned ${e.value.length} times.');
        }
        final Match? mm = RegExp(r'^(\d+)\s*[x×]').firstMatch(e.value.first.note.trim().toLowerCase());
        final int n = mm == null ? 1 : int.parse(mm.group(1)!);
        if (n > 1 && s.allowCountNotes) {
          final double size = d.circles[e.key].d;
          final List<int> same = <int>[for (int j = 0; j < d.circles.length; j++) if ((d.circles[j].d - size).abs() < 0.01) j];
          if (same.length != n) fb.add('✗ The note on hole ${e.key + 1} says $n×, but the drawing has ${same.length} holes of that size.');
          for (final int j in same) {
            if (same.length == n) coveredBy[j] = e.key;
          }
        }
        coveredBy[e.key] = e.key;
      }
      for (final MapEntry<int, int> e in match.entries) {
        final HoleSpec h = s.holes[e.key];
        final int j = e.value;
        total++;
        final int? owner = coveredBy[j];
        if (owner == null) {
          fb.add('✗ The diameter of hole ${j + 1} is not dimensioned.');
          continue;
        }
        if (h.tol != null && !_norm(dia[owner]!.first.note).contains(_norm(h.tol!))) {
          fb.add('✗ Hole ${j + 1} needs its tolerance ${h.tol} on the diameter dimension.');
          continue;
        }
        ok++;
        fb.add('✓ Hole ${j + 1} diameter dimensioned${h.tol == null ? '' : ' with ${h.tol}'}.');
      }
      if (s.forbidRedundant && redundant > 0) {
        total += redundant;
        fb.add('Over-dimensioned drawings give conflicting instructions to the machinist; remove the redundant dimensions.');
      }
    }

    // 4. Title block.
    for (final MapEntry<String, String> e in s.title.entries) {
      total++;
      final String? got = d.title[e.key];
      if (got == e.value) {
        ok++;
        fb.add('✓ ${e.key}: $got.');
      } else {
        fb.add('✗ ${e.key} should be ${e.value}${got == null ? ' (not filled in)' : ', not $got'}.');
      }
    }

    if (geometryWrong) fb.insert(0, 'The geometry does not match the part, so the drawing cannot be released for manufacture.');
    return gradeResult(step, total == 0 ? 0 : ok / total, fb, breakdown: <String, int>{'met': ok, 'items': total}, forceFail: geometryWrong);
  }
}

// ------------------------------------------------------------ scenarios

/// A part drawn at three levels: geometry, full dimensioning, tolerances.
class DrawingPart {
  const DrawingPart({required this.key, required this.title, required this.client, required this.width, required this.height, required this.holes, this.tols = const <String?>[], this.countNote = false});
  final String key;
  final String title;
  final String client;
  final double width;
  final double height;
  final List<HoleSpec> holes;

  /// Level-3 tolerances per hole (null = untoleranced).
  final List<String?> tols;

  /// Level 3 may use one "n×" note for the equal holes.
  final bool countNote;
}

const Map<String, List<String>> drawingTitleOptions = <String, List<String>>{
  'Scale': <String>['1:1', '1:2', '2:1', '1:5'],
  'Projection': <String>['First angle', 'Third angle'],
  'Units': <String>['mm', 'inch'],
};

List<LabScenario> drawingScenarios(String prefix, DrawingPart p, {required List<LabDifficulty> levels, LabPerson? person, required List<String> skills}) {
  final Map<String, String> title = <String, String>{'Scale': p.width > 250 ? '1:2' : '1:1', 'Projection': 'Third angle', 'Units': 'mm'};
  final List<DrawCircle> circles = <DrawCircle>[for (final HoleSpec h in p.holes) DrawCircle(h.x, h.y, h.d)];
  List<DrawDim> locate() {
    final List<DrawDim> m = <DrawDim>[const DrawDim('h', 'L', 'R'), const DrawDim('v', 'B', 'T')];
    for (int i = 0; i < p.holes.length; i++) {
      m.add(DrawDim('h', 'L', 'c$i'));
      m.add(DrawDim('v', 'B', 'c$i'));
    }
    return m;
  }

  String holeList(List<HoleSpec> hs) => hs.map((HoleSpec h) => 'Ø${fmtMm(h.d)}${h.tol == null ? '' : ' ${h.tol}'} at x ${fmtMm(h.x)}, y ${fmtMm(h.y)}').join('; ');
  final List<HoleSpec> tolHoles = <HoleSpec>[for (int i = 0; i < p.holes.length; i++) HoleSpec(p.holes[i].x, p.holes[i].y, p.holes[i].d, tol: i < p.tols.length ? p.tols[i] : null)];

  final List<(String, DrawingSpec, Drawing, String)> lv = <(String, DrawingSpec, Drawing, String)>[
    (
      'Draw the outline and holes from the sketch, and fill in the title block.',
      DrawingSpec(width: p.width, height: p.height, holes: p.holes, requireDimensions: false, title: title),
      Drawing(width: p.width, height: p.height, circles: circles, title: title),
      'geometry',
    ),
    (
      'Draw the part and dimension it completely from the left and bottom datum edges, with no redundant dimensions.',
      DrawingSpec(width: p.width, height: p.height, holes: p.holes, title: title),
      Drawing(width: p.width, height: p.height, circles: circles, title: title, dims: <DrawDim>[...locate(), for (int i = 0; i < p.holes.length; i++) DrawDim('d', 'c$i')]),
      'fully dimensioned',
    ),
    (
      'Production release: draw, dimension from the datums with no redundancy, and add the hole tolerances to the diameter dimensions${p.countNote ? ' (you may use one “n×” note for equal holes)' : ''}.',
      DrawingSpec(width: p.width, height: p.height, holes: tolHoles, title: title, allowCountNotes: p.countNote),
      Drawing(width: p.width, height: p.height, circles: circles, title: title, dims: <DrawDim>[
        ...locate(),
        for (int i = 0; i < p.holes.length; i++) DrawDim('d', 'c$i', '', tolHoles[i].tol ?? ''),
      ]),
      'production release',
    ),
  ];
  return <LabScenario>[
    for (int l = 0; l < 3; l++)
      LabScenario(
        id: '${prefix}_${p.key}_${l + 1}',
        title: '${p.title} — ${lv[l].$4}',
        level: levels[l],
        people: <LabPerson>[if (person != null) person],
        briefing: Briefing(
          what: '${p.client} needs a drawing of the ${p.title.toLowerCase()}: ${fmtMm(p.width)} × ${fmtMm(p.height)} mm plate with ${l == 2 ? holeList(tolHoles) : holeList(p.holes)}. ${lv[l].$1}',
          why: 'The machine shop makes exactly what the drawing says. Missing or conflicting dimensions mean scrapped parts.',
          information: <String>[
            'Coordinates are in mm from the bottom-left corner (the datum corner).',
            'Locate every hole from the left and bottom edges; dimension each diameter.',
            'Title block: ${title.entries.map((MapEntry<String, String> e) => '${e.key} ${e.value}').join(', ')}.',
          ],
          tools: const <String>['Drawing sheet with 1 mm grid', 'Outline and hole tools', 'Dimension tool', 'Title block'],
          expected: 'A drawing the machine shop could make the part from without asking a question.',
        ),
        steps: <LabStep>[
          DrawingStep(
            id: '${prefix}_${p.key}_${l + 1}_draw',
            title: p.title,
            instructions: lv[l].$1,
            spec: lv[l].$2,
            model: lv[l].$3,
            titleOptions: drawingTitleOptions,
            skills: skills,
          ),
        ],
      ),
  ];
}
