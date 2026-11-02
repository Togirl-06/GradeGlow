import '../models/science_diagram.dart';
import 'science_diagram_catalog.dart';

/// Speech-driven visual cue for a lecture diagram.
///
/// The professor talks first. The plate reacts when a named structure is
/// spoken — other regions dim but stay visible.
class LectureSpokenVisual {
  const LectureSpokenVisual({
    this.regionIds = const <String>{},
    this.label,
    this.zoom = false,
  });

  final Set<String> regionIds;
  final String? label;
  final bool zoom;

  static const LectureSpokenVisual empty = LectureSpokenVisual();

  bool get isActive => regionIds.isNotEmpty;
}

class _VisualPhrase {
  const _VisualPhrase({
    required this.tokens,
    required this.regionIds,
    required this.label,
  });

  final List<String> tokens;
  final Set<String> regionIds;
  final String label;
}

class _TimedToken {
  const _TimedToken({
    required this.text,
    required this.start,
  });

  final String text;
  final double start;
}

/// Narration → keywords → visual targets.
///
/// Last spoken structure stays lit until the next structure is named.
abstract final class LectureVisualSync {
  static const Set<String> _quizModes = <String>{
    'identifyTap',
    'labelDrill',
  };

  static LectureSpokenVisual resolve({
    required String? diagramId,
    required String speech,
    required double progress,
    String? teachingMode,
    ScienceDiagram? diagram,
  }) {
    if (teachingMode != null && _quizModes.contains(teachingMode.trim())) {
      return LectureSpokenVisual.empty;
    }
    final ScienceDiagram? plate = diagram ??
        ((diagramId == null || diagramId.trim().isEmpty)
            ? null
            : ScienceDiagramCatalog.diagramById(diagramId.trim()));
    if (plate == null || plate.regions.isEmpty) {
      return LectureSpokenVisual.empty;
    }
    final String text = speech.trim();
    if (text.isEmpty) return LectureSpokenVisual.empty;

    final List<_TimedToken> tokens = _timedTokens(text);
    if (tokens.isEmpty) return LectureSpokenVisual.empty;

    final double t = progress.clamp(0.0, 1.0);
    final List<_VisualPhrase> lexicon = _lexiconFor(plate);

    _VisualPhrase? last;
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i].start - 0.0001 > t) break;
      _VisualPhrase? hit;
      for (final _VisualPhrase phrase in lexicon) {
        if (_matchesAt(tokens, i, phrase.tokens)) {
          hit = phrase;
          break;
        }
      }
      if (hit != null) last = hit;
    }

    if (last == null) return LectureSpokenVisual.empty;
    final Set<String> valid = last.regionIds
        .where((String id) => plate.regions.any((ScienceDiagramRegion r) => r.id == id))
        .toSet();
    if (valid.isEmpty) return LectureSpokenVisual.empty;
    return LectureSpokenVisual(
      regionIds: valid,
      label: last.label,
      zoom: valid.length <= 3,
    );
  }

  /// Last math token mentioned that also appears in [equation], if any.
  static String? spokenEquationTerm({
    required String speech,
    required String equation,
    required double progress,
  }) {
    final String eq = equation.trim();
    if (eq.isEmpty) return null;
    final List<_TimedToken> tokens = _timedTokens(speech);
    if (tokens.isEmpty) return null;
    final double t = progress.clamp(0.0, 1.0);
    String? last;
    for (final _TimedToken token in tokens) {
      if (token.start - 0.0001 > t) break;
      if (token.text.length > 16) continue;
      if (_stopWords.contains(token.text)) continue;
      if (eq.toLowerCase().contains(token.text)) {
        last = token.text;
      }
    }
    return last;
  }

  static List<_TimedToken> _timedTokens(String speech) {
    final List<String> raw = speech
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]+"), ' ')
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList(growable: false);
    if (raw.isEmpty) return const <_TimedToken>[];
    final List<int> weights = raw
        .map((String w) => w.length.clamp(2, 18))
        .toList(growable: false);
    final int total = weights.fold<int>(0, (int a, int b) => a + b);
    final List<_TimedToken> out = <_TimedToken>[];
    int acc = 0;
    for (int i = 0; i < raw.length; i++) {
      out.add(_TimedToken(text: raw[i], start: acc / total));
      acc += weights[i];
    }
    return out;
  }

  static bool _matchesAt(
    List<_TimedToken> tokens,
    int index,
    List<String> phrase,
  ) {
    if (index + phrase.length > tokens.length) return false;
    for (int j = 0; j < phrase.length; j++) {
      if (tokens[index + j].text != phrase[j]) return false;
    }
    return true;
  }

  static List<_VisualPhrase> _lexiconFor(ScienceDiagram diagram) {
    final List<_VisualPhrase> phrases = <_VisualPhrase>[];

    void add(String phrase, Iterable<String> ids, [String? label]) {
      final List<String> tokens = phrase
          .toLowerCase()
          .replaceAll(RegExp(r"[^a-z0-9]+"), ' ')
          .split(RegExp(r'\s+'))
          .where((String w) => w.isNotEmpty)
          .toList(growable: false);
      if (tokens.isEmpty) return;
      if (tokens.length == 1 && _stopWords.contains(tokens.first)) return;
      if (tokens.length == 1 && tokens.first.length < 3) return;
      final Set<String> regionIds = ids.toSet();
      if (regionIds.isEmpty) return;
      phrases.add(
        _VisualPhrase(
          tokens: tokens,
          regionIds: regionIds,
          label: (label ?? phrase).trim().toUpperCase(),
        ),
      );
    }

    for (final (String phrase, List<String> ids, String? label)
        in _extraAliases[diagram.id] ??
            const <(String, List<String>, String?)>[]) {
      add(phrase, ids, label);
    }

    for (final ScienceDiagramRegion region in diagram.regions) {
      add(region.name, <String>[region.id]);
      add(region.id.replaceAll('_', ' '), <String>[region.id], region.name);
      for (final String token in region.name.toLowerCase().split(RegExp(r'\s+'))) {
        if (token.length >= 5 && !_stopWords.contains(token)) {
          add(token, <String>[region.id], region.name);
        }
      }
    }

    phrases.sort(( _VisualPhrase a, _VisualPhrase b) {
      final int byLen = b.tokens.length.compareTo(a.tokens.length);
      if (byLen != 0) return byLen;
      return b.tokens.join().length.compareTo(a.tokens.join().length);
    });
    return phrases;
  }

  static const Set<String> _stopWords = <String>{
    'a',
    'an',
    'the',
    'of',
    'and',
    'or',
    'to',
    'in',
    'on',
    'is',
    'it',
    'this',
    'that',
    'left',
    'right',
    'cell',
    'body',
    'line',
    'arm',
    'short',
    'long',
  };

  static const Map<String, List<(String, List<String>, String?)>> _extraAliases =
      <String, List<(String, List<String>, String?)>>{
    'skeleton': <(String, List<String>, String?)>[
      (
        'axial skeleton',
        <String>['skull', 'spine', 'ribs', 'sternum', 'sacrum'],
        'AXIAL SKELETON',
      ),
      (
        'appendicular skeleton',
        <String>[
          'clavicle',
          'scapula',
          'humerus',
          'radius',
          'ulna',
          'pelvis',
          'femur',
          'patella',
          'tibia',
          'fibula',
        ],
        'APPENDICULAR SKELETON',
      ),
      ('vertebral column', <String>['spine'], 'VERTEBRAL COLUMN'),
      ('spinal column', <String>['spine'], 'VERTEBRAL COLUMN'),
      ('backbone', <String>['spine'], 'VERTEBRAL COLUMN'),
      ('thoracic cage', <String>['ribs', 'sternum'], 'THORACIC CAGE'),
      ('rib cage', <String>['ribs'], 'RIB CAGE'),
      ('ribs', <String>['ribs'], 'RIB CAGE'),
      ('cranium', <String>['skull'], 'SKULL'),
      ('brain', <String>['skull'], 'BRAIN'),
      ('lower jaw', <String>['mandible'], 'MANDIBLE'),
      ('jawbone', <String>['mandible'], 'MANDIBLE'),
      ('shoulder blade', <String>['scapula'], 'SCAPULA'),
      ('collarbone', <String>['clavicle'], 'CLAVICLE'),
      ('upper arm', <String>['humerus'], 'HUMERUS'),
      ('thigh bone', <String>['femur'], 'FEMUR'),
      ('shinbone', <String>['tibia'], 'TIBIA'),
      ('shin', <String>['tibia'], 'TIBIA'),
      ('kneecap', <String>['patella'], 'PATELLA'),
    ],
    'animal_cell': <(String, List<String>, String?)>[
      ('mitochondrion', <String>['mitochondria'], 'MITOCHONDRIA'),
      ('powerhouse', <String>['mitochondria'], 'MITOCHONDRIA'),
      ('golgi apparatus', <String>['golgi'], 'GOLGI'),
      ('endoplasmic reticulum', <String>['er'], 'ER'),
      ('rough er', <String>['er'], 'ER'),
      ('cell membrane', <String>['membrane'], 'CELL MEMBRANE'),
      ('plasma membrane', <String>['membrane'], 'CELL MEMBRANE'),
    ],
    'plant_cell': <(String, List<String>, String?)>[
      ('photosynthesis', <String>['chloroplast'], 'CHLOROPLAST'),
      ('cell wall', <String>['cell_wall'], 'CELL WALL'),
      ('central vacuole', <String>['vacuole'], 'VACUOLE'),
    ],
    'heart_detail': <(String, List<String>, String?)>[
      ('right ventricle', <String>['right_ventricle'], 'RIGHT VENTRICLE'),
      ('left ventricle', <String>['left_ventricle'], 'LEFT VENTRICLE'),
      ('right atrium', <String>['right_atrium'], 'RIGHT ATRIUM'),
      ('left atrium', <String>['left_atrium'], 'LEFT ATRIUM'),
      ('pulmonary artery', <String>['pulmonary_artery'], 'PULMONARY ARTERY'),
      ('pulmonary veins', <String>['pulmonary_veins'], 'PULMONARY VEINS'),
      ('mitral valve', <String>['mitral_valve'], 'MITRAL VALVE'),
      ('tricuspid valve', <String>['tricuspid_valve'], 'TRICUSPID VALVE'),
      ('great vessels', <String>['aorta', 'pulmonary_artery', 'pulmonary_veins'], 'GREAT VESSELS'),
    ],
    'atom': <(String, List<String>, String?)>[
      ('electron shell', <String>['shell'], 'ELECTRON SHELL'),
      ('energy level', <String>['shell'], 'ELECTRON SHELL'),
      ('subatomic particles', <String>['proton', 'neutron', 'electron'], 'PARTICLES'),
    ],
    'molecule': <(String, List<String>, String?)>[
      ('hydrogen', <String>['hydrogen_left', 'hydrogen_right'], 'HYDROGEN'),
      ('oxygen', <String>['oxygen'], 'OXYGEN'),
      ('covalent bond', <String>['bond_left', 'bond_right'], 'COVALENT BOND'),
    ],
    'force': <(String, List<String>, String?)>[
      ('gravity', <String>['weight'], 'GRAVITY'),
      ('weight', <String>['weight'], 'WEIGHT'),
      ('normal force', <String>['normal'], 'NORMAL FORCE'),
      ('friction', <String>['friction'], 'FRICTION'),
      ('applied force', <String>['applied'], 'APPLIED FORCE'),
    ],
    'human_organs': <(String, List<String>, String?)>[
      ('thoracic cavity', <String>['heart', 'lungs'], 'THORAX'),
    ],
    'respiratory': <(String, List<String>, String?)>[
      ('nasal cavity', <String>['nasal'], 'NASAL CAVITY'),
      ('gas exchange', <String>['lungs'], 'LUNGS'),
    ],
    'neuron': <(String, List<String>, String?)>[
      ('axon terminals', <String>['terminal'], 'AXON TERMINALS'),
      ('myelin sheath', <String>['myelin'], 'MYELIN'),
      ('soma', <String>['cell_body'], 'CELL BODY'),
      ('synapse', <String>['terminal'], 'SYNAPSE'),
    ],
    'dc_circuit': <(String, List<String>, String?)>[
      ('light bulb', <String>['bulb'], 'LIGHT BULB'),
      ('conducting wire', <String>['wire'], 'WIRE'),
    ],
    'dna': <(String, List<String>, String?)>[
      ('double helix', <String>['helix'], 'DOUBLE HELIX'),
      ('hydrogen bond', <String>['h_bond'], 'HYDROGEN BOND'),
      ('adenine', <String>['adenine'], 'ADENINE'),
      ('thymine', <String>['thymine'], 'THYMINE'),
    ],
    'bacteria': <(String, List<String>, String?)>[
      ('cell wall', <String>['cell_wall'], 'CELL WALL'),
    ],
  };
}
