import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One experiment write-up in the shared science notebook.
class ExperimentEntry {
  ExperimentEntry({
    required this.id,
    this.question = '',
    this.hypothesis = '',
    this.independent = '',
    this.dependent = '',
    this.controls = '',
    this.procedure = '',
    this.observations = '',
    this.data = '',
    this.conclusion = '',
    DateTime? updated,
  }) : updated = updated ?? DateTime.now();

  String id;
  String question;
  String hypothesis;
  String independent;
  String dependent;
  String controls;
  String procedure;
  String observations;
  String data;
  String conclusion;
  DateTime updated;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'question': question,
        'hypothesis': hypothesis,
        'independent': independent,
        'dependent': dependent,
        'controls': controls,
        'procedure': procedure,
        'observations': observations,
        'data': data,
        'conclusion': conclusion,
        'updated': updated.toIso8601String(),
      };

  factory ExperimentEntry.fromJson(Map<String, dynamic> json) {
    return ExperimentEntry(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      hypothesis: json['hypothesis'] as String? ?? '',
      independent: json['independent'] as String? ?? '',
      dependent: json['dependent'] as String? ?? '',
      controls: json['controls'] as String? ?? '',
      procedure: json['procedure'] as String? ?? '',
      observations: json['observations'] as String? ?? '',
      data: json['data'] as String? ?? '',
      conclusion: json['conclusion'] as String? ?? '',
      updated: DateTime.tryParse(json['updated'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// SharedPreferences-backed notebook for biology | chemistry | physics.
class ScienceNotebookStore {
  ScienceNotebookStore(this.subjectId);

  /// One of: biology, chemistry, physics.
  final String subjectId;

  String get _prefix => 'science_nb_${subjectId}_';

  final List<String> notes = <String>[];
  final List<Map<String, dynamic>> diagrams = <Map<String, dynamic>>[];
  final List<ExperimentEntry> experiments = <ExperimentEntry>[];
  final List<Map<String, dynamic>> dataTables = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> graphsMeta = <Map<String, dynamic>>[];
  final List<String> conclusions = <String>[];
  final Set<String> completedWorkIds = <String>{};
  final Set<String> badges = <String>{};

  int xp = 0;
  int labCoins = 0;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final SharedPreferences p = await _prefs;
    notes
      ..clear()
      ..addAll(p.getStringList('${_prefix}notes') ?? const <String>[]);
    conclusions
      ..clear()
      ..addAll(p.getStringList('${_prefix}conclusions') ?? const <String>[]);
    completedWorkIds
      ..clear()
      ..addAll(p.getStringList('${_prefix}completed') ?? const <String>[]);
    badges
      ..clear()
      ..addAll(p.getStringList('${_prefix}badges') ?? const <String>[]);
    xp = p.getInt('${_prefix}xp') ?? 0;
    labCoins = p.getInt('${_prefix}lab_coins') ?? 0;

    diagrams
      ..clear()
      ..addAll(_decodeMapList(p.getString('${_prefix}diagrams')));
    dataTables
      ..clear()
      ..addAll(_decodeMapList(p.getString('${_prefix}data_tables')));
    graphsMeta
      ..clear()
      ..addAll(_decodeMapList(p.getString('${_prefix}graphs_meta')));

    experiments
      ..clear()
      ..addAll(_decodeExperiments(p.getString('${_prefix}experiments')));

    _loaded = true;
  }

  Future<void> _persist() async {
    final SharedPreferences p = await _prefs;
    await p.setStringList('${_prefix}notes', notes);
    await p.setStringList('${_prefix}conclusions', conclusions);
    await p.setStringList('${_prefix}completed', completedWorkIds.toList());
    await p.setStringList('${_prefix}badges', badges.toList());
    await p.setInt('${_prefix}xp', xp);
    await p.setInt('${_prefix}lab_coins', labCoins);
    await p.setString('${_prefix}diagrams', jsonEncode(diagrams));
    await p.setString('${_prefix}data_tables', jsonEncode(dataTables));
    await p.setString('${_prefix}graphs_meta', jsonEncode(graphsMeta));
    await p.setString(
      '${_prefix}experiments',
      jsonEncode(experiments.map((ExperimentEntry e) => e.toJson()).toList()),
    );
  }

  Future<void> addNote(String note) async {
    await ensureLoaded();
    final String t = note.trim();
    if (t.isEmpty) return;
    notes.add(t);
    await _persist();
  }

  Future<void> addDiagram(Map<String, dynamic> diagram) async {
    await ensureLoaded();
    diagrams.add(diagram);
    await _persist();
  }

  /// Optional stroke list as list of json maps under key `strokes`.
  Future<void> addDiagramStrokes({
    required String title,
    List<Map<String, dynamic>>? strokes,
    Map<String, dynamic>? extra,
  }) async {
    final Map<String, dynamic> entry = <String, dynamic>{
      'title': title,
      'at': DateTime.now().toIso8601String(),
      ...?extra,
    };
    if (strokes != null) {
      entry['strokes'] = strokes;
    }
    await addDiagram(entry);
  }

  Future<void> addExperiment(ExperimentEntry entry) async {
    await ensureLoaded();
    entry.updated = DateTime.now();
    final int idx = experiments.indexWhere((ExperimentEntry e) => e.id == entry.id);
    if (idx >= 0) {
      experiments[idx] = entry;
    } else {
      experiments.add(entry);
    }
    await _persist();
  }

  Future<void> addDataTable(Map<String, dynamic> table) async {
    await ensureLoaded();
    dataTables.add(table);
    await _persist();
  }

  Future<void> addGraphMeta(Map<String, dynamic> meta) async {
    await ensureLoaded();
    graphsMeta.add(meta);
    await _persist();
  }

  Future<void> addConclusion(String text) async {
    await ensureLoaded();
    final String t = text.trim();
    if (t.isEmpty) return;
    conclusions.add(t);
    await _persist();
  }

  Future<void> awardXp(int amount, {int coins = 0}) async {
    await ensureLoaded();
    if (amount == 0 && coins == 0) return;
    xp = (xp + amount).clamp(0, 999999);
    labCoins = (labCoins + coins).clamp(0, 999999);
    await _persist();
  }

  Future<void> unlockBadge(String badgeId) async {
    await ensureLoaded();
    if (badgeId.trim().isEmpty) return;
    if (badges.add(badgeId.trim())) {
      await _persist();
    }
  }

  Future<void> markComplete(String workId) async {
    await ensureLoaded();
    if (workId.trim().isEmpty) return;
    if (completedWorkIds.add(workId.trim())) {
      await _persist();
    }
  }

  static List<Map<String, dynamic>> _decodeMapList(String? raw) {
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((Map e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  static List<ExperimentEntry> _decodeExperiments(String? raw) {
    if (raw == null || raw.isEmpty) return <ExperimentEntry>[];
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) return <ExperimentEntry>[];
      return decoded
          .whereType<Map>()
          .map((Map e) => ExperimentEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return <ExperimentEntry>[];
    }
  }
}
