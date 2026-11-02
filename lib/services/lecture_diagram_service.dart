import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/diagram_asset_registry.dart';
import '../data/science_diagram_catalog.dart';
import '../models/science_diagram.dart';
import 'diagram_asset_service.dart';

/// Resolved illustration for a lecture whiteboard (never a hand-drawn shape).
class LectureDiagramRef {
  const LectureDiagramRef.network(this.networkUrl)
      : assetPath = null,
        assert(networkUrl != null);

  const LectureDiagramRef.asset(this.assetPath)
      : networkUrl = null,
        assert(assetPath != null);

  final String? networkUrl;
  final String? assetPath;

  bool get isNetwork => networkUrl != null && networkUrl!.isNotEmpty;
  bool get isSvg {
    final String path = (networkUrl ?? assetPath ?? '').toLowerCase();
    return path.endsWith('.svg') || path.contains('image/svg');
  }
}

/// Loads real educational diagrams from bundled assets or the open web
/// (Wikimedia Commons / Wikipedia) — not CustomPaint shapes.
class LectureDiagramService {
  LectureDiagramService._();
  static final LectureDiagramService instance = LectureDiagramService._();

  final Map<String, LectureDiagramRef> _cache = <String, LectureDiagramRef>{};

  /// Longer / more specific keys first — word-boundary matched.
  static const List<MapEntry<String, String>> _keywordToDiagramId =
      <MapEntry<String, String>>[
    MapEntry<String, String>('plant cell', 'plant_cell'),
    MapEntry<String, String>('heart failure', 'heart_detail'),
    MapEntry<String, String>('postoperative', 'human_organs'),
    MapEntry<String, String>('post-operative', 'human_organs'),
    MapEntry<String, String>('preoperative', 'human_organs'),
    MapEntry<String, String>('pre-operative', 'human_organs'),
    MapEntry<String, String>('surgical', 'human_organs'),
    MapEntry<String, String>('complication', 'human_organs'),
    MapEntry<String, String>('wound care', 'human_organs'),
    MapEntry<String, String>('wound', 'human_organs'),
    MapEntry<String, String>('sepsis', 'bacteria'),
    MapEntry<String, String>('infection', 'bacteria'),
    MapEntry<String, String>('pneumonia', 'respiratory'),
    MapEntry<String, String>('atelectasis', 'respiratory'),
    MapEntry<String, String>('pulmonary', 'respiratory'),
    MapEntry<String, String>('respiratory', 'respiratory'),
    MapEntry<String, String>('cardiovascular', 'heart_detail'),
    MapEntry<String, String>('cardiac', 'heart_detail'),
    MapEntry<String, String>('heart', 'heart_detail'),
    MapEntry<String, String>('organelle', 'animal_cell'),
    MapEntry<String, String>('chromosome', 'chromosome'),
    MapEntry<String, String>('bacteria', 'bacteria'),
    MapEntry<String, String>('skeleton', 'skeleton'),
    MapEntry<String, String>('respiratory', 'respiratory'),
    MapEntry<String, String>('neuron', 'neuron'),
    MapEntry<String, String>('nerve', 'neuron'),
    MapEntry<String, String>('organs', 'human_organs'),
    MapEntry<String, String>('organ', 'human_organs'),
    MapEntry<String, String>('lung', 'respiratory'),
    MapEntry<String, String>('bone', 'skeleton'),
    MapEntry<String, String>('dna', 'dna'),
    MapEntry<String, String>('gene', 'dna'),
    MapEntry<String, String>('cell', 'animal_cell'),
    MapEntry<String, String>('atom', 'atom'),
    MapEntry<String, String>('electron', 'atom'),
    MapEntry<String, String>('molecule', 'molecule'),
    MapEntry<String, String>('chemical', 'molecule'),
    MapEntry<String, String>('beaker', 'chem_equipment'),
    MapEntry<String, String>('flask', 'chem_equipment'),
    MapEntry<String, String>('titration', 'chem_equipment'),
    MapEntry<String, String>('circuit', 'dc_circuit'),
    MapEntry<String, String>('current', 'dc_circuit'),
    MapEntry<String, String>('force', 'force'),
    MapEntry<String, String>('vector', 'force'),
    MapEntry<String, String>('wave', 'wave'),
    MapEntry<String, String>('oscillat', 'wave'),
  ];

  static final RegExp _irrelevantTitle = RegExp(
    r'\b(map|maps|lithograph|currier|ives|brooklyn|manhattan|city of|'
    r'panorama|aerial view|bird.?s.?eye|painting of|portrait of|'
    r'postcard|stamp|coin|flag|coat of arms|cathedral|church of|'
    r'railway|locomotive|steamship|battleship)\b',
    caseSensitive: false,
  );

  static final RegExp _relevantTitle = RegExp(
    r'\b(anatomy|anatomical|medical|medicine|nursing|clinical|surgical|'
    r'surgery|postoperative|preoperative|wound|infection|sepsis|organ|'
    r'organs|heart|lung|respiratory|cardiac|diagram|illustration|'
    r'schematic|physiology|pathology|patient|body|skeleton|neuron|'
    r'cell|dna|atom|molecule|circuit|force|wave|biology|chemistry)\b',
    caseSensitive: false,
  );

  Future<LectureDiagramRef?> resolve({
    String? imageUrl,
    String? diagramId,
    String? diagramQuery,
    String? title,
    List<String> lines = const <String>[],
    String subjectId = '',
    String courseId = '',
    String topicId = '',
    String topicName = '',
  }) async {
    final String direct = (imageUrl ?? '').trim();
    if (direct.startsWith('http://') || direct.startsWith('https://')) {
      if (_isRelevantNetworkUrl(direct, title: title, topic: topicName)) {
        return LectureDiagramRef.network(direct);
      }
      // Bad AI/cached URL — fall through to topic-aware resolution.
    }

    final String id = (diagramId ?? '').trim();
    if (id.isNotEmpty && DiagramAssetRegistry.bundledByDiagramId.containsKey(id)) {
      return _fromBundledId(id);
    }

    final String query = <String>[
      if ((diagramQuery ?? '').trim().isNotEmpty) diagramQuery!.trim(),
      if ((title ?? '').trim().isNotEmpty) title!.trim(),
      if (topicName.trim().isNotEmpty) topicName.trim(),
      ...lines.take(2),
    ].join(' ').trim();

    if (query.isEmpty && topicName.trim().isEmpty) return null;

    final String cacheKey = <String>[
      subjectId,
      courseId,
      topicId,
      topicName,
      query,
    ].join('|').toLowerCase();
    final LectureDiagramRef? cached = _cache[cacheKey];
    if (cached != null) return cached;

    final String? catalogId = _catalogDiagramId(
      subjectId: subjectId,
      courseId: courseId,
      topicId: topicId,
      topicName: topicName.isNotEmpty ? topicName : (title ?? query),
      query: query,
    );
    if (catalogId != null) {
      final LectureDiagramRef ref = _fromBundledId(catalogId);
      _cache[cacheKey] = ref;
      return ref;
    }

    final String? matchedId = _matchBundledId(query);
    if (matchedId != null) {
      final LectureDiagramRef ref = _fromBundledId(matchedId);
      _cache[cacheKey] = ref;
      return ref;
    }

    // Clinical topics without a specific anatomy match: do not force a random
    // organ plate — leave the board as text/notes instead.
    final bool clinical =
        _looksClinical(query, subjectId: subjectId, courseId: courseId);
    if (clinical) {
      return null;
    }

    final LectureDiagramRef? remote =
        await _fetchFromWeb(query, clinical: clinical);
    if (remote != null) {
      _cache[cacheKey] = remote;
      return remote;
    }
    return null;
  }

  /// Bundled diagram id for a lecture topic — only when the topic actually needs one.
  /// Returns null for abstract topics (interview skills, ethics, etc.).
  static String? preferredDiagramId({
    required String topic,
    String faculty = '',
    String courseId = '',
    String lessonId = '',
  }) {
    final String subject = _inferSubject(
      faculty: faculty,
      courseId: courseId,
      topic: topic,
    );
    final String topicId = lessonId.trim().isNotEmpty
        ? lessonId.trim()
        : _slug(topic);
    final String? catalogId = ScienceDiagramCatalog.diagramIdFor(
      subjectId: subject,
      courseId: courseId,
      topicId: topicId,
      topicName: topic,
      allowSubjectFallback: false,
    );
    final String? matched =
        catalogId ?? instance._matchBundledId('$topic $lessonId $courseId');
    if (matched == null) return null;
    return lectureSafeDiagramId(matched);
  }

  static bool topicNeedsDiagram({
    required String topic,
    String faculty = '',
    String courseId = '',
    String lessonId = '',
  }) {
    return preferredDiagramId(
          topic: topic,
          faculty: faculty,
          courseId: courseId,
          lessonId: lessonId,
        ) !=
        null;
  }

  /// Prefer labeled anatomy plates for the lecture board.
  static String lectureSafeDiagramId(String id) {
    if (id == 'human_organs') return 'human_body';
    return id;
  }

  /// Part labels to show under/over the figure (from the science catalog).
  static List<String> partLabelsFor(String? diagramId, {String topic = ''}) {
    if (diagramId == null || diagramId.isEmpty) return const <String>[];
    final String id = lectureSafeDiagramId(diagramId);
    // human_body shares organ region labels with human_organs catalog entry.
    final String catalogId = id == 'human_body' ? 'human_organs' : id;
    final ScienceDiagram? diagram = ScienceDiagramCatalog.diagramById(catalogId);
    if (diagram == null) return const <String>[];
    final List<ScienceDiagramRegion> regions =
        ScienceDiagramCatalog.regionsForTopic(
      diagram,
      topicId: _slug(topic),
      topicName: topic,
    );
    return regions
        .map((ScienceDiagramRegion r) => r.name.trim())
        .where((String n) => n.isNotEmpty)
        .take(24)
        .toList(growable: false);
  }

  LectureDiagramRef _fromBundledId(String id) {
    final String safeId = lectureSafeDiagramId(id);
    final DiagramAssetSource source = DiagramAssetService.instance.resolve(safeId);
    if (source.isNetwork) {
      return LectureDiagramRef.network(source.networkUrl!);
    }
    final String path = source.assetPath;
    // Never serve the old cartoon SVGs for anatomy — use real plates or network.
    if (path.contains('/anatomy/') && path.endsWith('.svg')) {
      final String? fallback = DiagramAssetRegistry.anatomyNetworkFallback[safeId] ??
          DiagramAssetRegistry.anatomyNetworkFallback[id];
      if (fallback != null) return LectureDiagramRef.network(fallback);
    }
    return LectureDiagramRef.asset(path);
  }

  String? _catalogDiagramId({
    required String subjectId,
    required String courseId,
    required String topicId,
    required String topicName,
    required String query,
  }) {
    final String subject = subjectId.trim().isNotEmpty
        ? subjectId.trim().toLowerCase()
        : _inferSubject(faculty: '', courseId: courseId, topic: '$topicName $query');
    if (!ScienceDiagramCatalog.supportsSubject(subject)) {
      // Still try nursing/medicine keywords via catalog when subject unknown.
      if (!_looksClinical('$topicName $query', courseId: courseId)) return null;
    }
    final String resolvedSubject = ScienceDiagramCatalog.supportsSubject(subject)
        ? subject
        : (_looksClinical('$topicName $query', courseId: courseId)
            ? 'nursing'
            : subject);
    if (!ScienceDiagramCatalog.supportsSubject(resolvedSubject)) return null;
    return ScienceDiagramCatalog.diagramIdFor(
      subjectId: resolvedSubject,
      courseId: courseId,
      topicId: topicId.trim().isNotEmpty ? topicId : _slug(topicName),
      topicName: topicName.isNotEmpty ? topicName : query,
      allowSubjectFallback: false,
    );
  }

  String? _matchBundledId(String query) {
    final String q = query.toLowerCase();
    for (final MapEntry<String, String> e in _keywordToDiagramId) {
      if (_containsWordOrPhrase(q, e.key)) return e.value;
    }
    return null;
  }

  static bool _containsWordOrPhrase(String haystack, String needle) {
    if (needle.contains(' ')) return haystack.contains(needle);
    return RegExp('\\b${RegExp.escape(needle)}\\b').hasMatch(haystack);
  }

  static String _inferSubject({
    required String faculty,
    required String courseId,
    required String topic,
  }) {
    final String blob = '$faculty $courseId $topic'.toLowerCase();
    if (blob.contains('nurs') ||
        blob.contains('patient') ||
        blob.contains('preoperative') ||
        blob.contains('postoperative') ||
        blob.contains('clinical') ||
        blob.contains('vital')) {
      return 'nursing';
    }
    if (blob.contains('medic') || blob.contains('surg')) return 'medicine';
    if (blob.contains('chem')) return 'chemistry';
    if (blob.contains('physic')) return 'physics';
    if (blob.contains('bio') ||
        blob.contains('anatomy') ||
        blob.contains('cell') ||
        blob.contains('gene')) {
      return 'biology';
    }
    return faculty.trim().isNotEmpty ? faculty.trim().toLowerCase() : 'biology';
  }

  static bool _looksClinical(
    String text, {
    String subjectId = '',
    String courseId = '',
  }) {
    final String blob = '$subjectId $courseId $text'.toLowerCase();
    return blob.contains('nurs') ||
        blob.contains('medic') ||
        blob.contains('clinical') ||
        blob.contains('patient') ||
        blob.contains('preoperative') ||
        blob.contains('postoperative') ||
        blob.contains('post-op') ||
        blob.contains('surgical') ||
        blob.contains('wound') ||
        blob.contains('sepsis') ||
        blob.contains('complication') ||
        blob.contains('vital sign');
  }

  static String _slug(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static bool _isRelevantNetworkUrl(
    String url, {
    String? title,
    String? topic,
  }) {
    final String blob = '$url ${title ?? ''} ${topic ?? ''}'.toLowerCase();
    if (_irrelevantTitle.hasMatch(blob)) return false;
    if (_looksClinical(topic ?? title ?? '')) {
      return _relevantTitle.hasMatch(blob);
    }
    return !_irrelevantTitle.hasMatch(blob);
  }

  Future<LectureDiagramRef?> _fetchFromWeb(
    String query, {
    required bool clinical,
  }) async {
    final String searchQuery = clinical
        ? '$query medical anatomy OR surgical OR nursing diagram -map -painting -lithograph'
        : '$query educational diagram OR labeled illustration OR chart -map -lithograph';
    final LectureDiagramRef? commons =
        await _searchWikimediaCommons(searchQuery, requireRelevant: true);
    if (commons != null) return commons;
    return _wikipediaThumbnail(query, requireRelevant: clinical);
  }

  Future<LectureDiagramRef?> _searchWikimediaCommons(
    String query, {
    bool requireRelevant = true,
  }) async {
    try {
      final Uri uri = Uri.https('commons.wikimedia.org', '/w/api.php', <String, String>{
        'action': 'query',
        'format': 'json',
        'origin': '*',
        'generator': 'search',
        'gsrnamespace': '6',
        'gsrsearch': query,
        'gsrlimit': '12',
        'prop': 'imageinfo|info',
        'inprop': 'url',
        'iiprop': 'url|mime|size',
        'iiurlwidth': '900',
      });
      final http.Response res = await http
          .get(uri, headers: <String, String>{'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final Object? decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) return null;
      final Map<String, dynamic>? queryMap =
          decoded['query'] as Map<String, dynamic>?;
      final Map<String, dynamic>? pages =
          queryMap?['pages'] as Map<String, dynamic>?;
      if (pages == null || pages.isEmpty) return null;

      LectureDiagramRef? fallback;
      for (final Object? page in pages.values) {
        if (page is! Map<String, dynamic>) continue;
        final String pageTitle = (page['title'] as String? ?? '').toLowerCase();
        if (_irrelevantTitle.hasMatch(pageTitle)) continue;
        final List<dynamic>? infos = page['imageinfo'] as List<dynamic>?;
        if (infos == null || infos.isEmpty) continue;
        final Map<String, dynamic> info =
            Map<String, dynamic>.from(infos.first as Map<dynamic, dynamic>);
        final String mime = (info['mime'] as String? ?? '').toLowerCase();
        if (!(mime.contains('jpeg') ||
            mime.contains('jpg') ||
            mime.contains('png') ||
            mime.contains('svg') ||
            mime.contains('webp') ||
            mime.contains('gif'))) {
          continue;
        }
        final String? thumb = info['thumburl'] as String?;
        final String? url = info['url'] as String?;
        final String? chosen = (thumb != null && thumb.isNotEmpty) ? thumb : url;
        if (chosen == null || !chosen.startsWith('http')) continue;
        final LectureDiagramRef candidate = LectureDiagramRef.network(chosen);
        if (!requireRelevant || _relevantTitle.hasMatch(pageTitle)) {
          return candidate;
        }
        fallback ??= candidate;
      }
      // Only accept non-matching fallbacks for non-clinical searches.
      if (!requireRelevant) return fallback;
    } catch (e) {
      debugPrint('Wikimedia diagram search failed: $e');
    }
    return null;
  }

  Future<LectureDiagramRef?> _wikipediaThumbnail(
    String query, {
    bool requireRelevant = false,
  }) async {
    try {
      final String title = query
          .replaceAll(RegExp(r'[^\w\s\-]'), ' ')
          .trim()
          .replaceAll(RegExp(r'\s+'), '_');
      if (title.isEmpty) return null;
      final Uri uri = Uri.https(
        'en.wikipedia.org',
        '/api/rest_v1/page/summary/${Uri.encodeComponent(title.split('_').take(6).join('_'))}',
      );
      final http.Response res = await http
          .get(uri, headers: <String, String>{'Accept': 'application/json'})
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      final Object? decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) return null;
      final String pageTitle = (decoded['title'] as String? ?? '').toLowerCase();
      final String extract = (decoded['extract'] as String? ?? '').toLowerCase();
      if (requireRelevant &&
          _irrelevantTitle.hasMatch('$pageTitle $extract') &&
          !_relevantTitle.hasMatch('$pageTitle $extract')) {
        return null;
      }
      final Map<String, dynamic>? thumb =
          decoded['thumbnail'] as Map<String, dynamic>?;
      final String? source = thumb?['source'] as String?;
      if (source != null && source.startsWith('http')) {
        if (_irrelevantTitle.hasMatch('$pageTitle $source')) return null;
        return LectureDiagramRef.network(source);
      }
      final Map<String, dynamic>? original =
          decoded['originalimage'] as Map<String, dynamic>?;
      final String? originalSrc = original?['source'] as String?;
      if (originalSrc != null && originalSrc.startsWith('http')) {
        if (_irrelevantTitle.hasMatch('$pageTitle $originalSrc')) return null;
        return LectureDiagramRef.network(originalSrc);
      }
    } catch (e) {
      debugPrint('Wikipedia diagram lookup failed: $e');
    }
    return null;
  }
}
