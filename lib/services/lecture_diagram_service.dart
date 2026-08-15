import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/diagram_asset_registry.dart';
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

  static const Map<String, String> _keywordToDiagramId = <String, String>{
    'organ': 'human_organs',
    'organs': 'human_organs',
    'skeleton': 'skeleton',
    'bone': 'skeleton',
    'respiratory': 'respiratory',
    'lung': 'respiratory',
    'neuron': 'neuron',
    'nerve': 'neuron',
    'heart': 'heart_detail',
    'cardiac': 'heart_detail',
    'cell': 'animal_cell',
    'organelle': 'animal_cell',
    'plant cell': 'plant_cell',
    'dna': 'dna',
    'gene': 'dna',
    'chromosome': 'chromosome',
    'bacteria': 'bacteria',
    'atom': 'atom',
    'electron': 'atom',
    'molecule': 'molecule',
    'chemical': 'molecule',
    'lab': 'chem_equipment',
    'beaker': 'chem_equipment',
    'circuit': 'dc_circuit',
    'current': 'dc_circuit',
    'force': 'force',
    'vector': 'force',
    'wave': 'wave',
    'oscillat': 'wave',
  };

  Future<LectureDiagramRef?> resolve({
    String? imageUrl,
    String? diagramId,
    String? diagramQuery,
    String? title,
    List<String> lines = const <String>[],
  }) async {
    final String direct = (imageUrl ?? '').trim();
    if (direct.startsWith('http://') || direct.startsWith('https://')) {
      return LectureDiagramRef.network(direct);
    }

    final String id = (diagramId ?? '').trim();
    if (id.isNotEmpty && DiagramAssetRegistry.bundledByDiagramId.containsKey(id)) {
      return _fromBundledId(id);
    }

    final String query = <String>[
      if ((diagramQuery ?? '').trim().isNotEmpty) diagramQuery!.trim(),
      if ((title ?? '').trim().isNotEmpty) title!.trim(),
      ...lines.take(2),
    ].join(' ').trim();

    if (query.isEmpty) return null;

    final String cacheKey = query.toLowerCase();
    final LectureDiagramRef? cached = _cache[cacheKey];
    if (cached != null) return cached;

    final String? matchedId = _matchBundledId(query);
    if (matchedId != null) {
      final LectureDiagramRef ref = _fromBundledId(matchedId);
      _cache[cacheKey] = ref;
      return ref;
    }

    final LectureDiagramRef? remote = await _fetchFromWeb(query);
    if (remote != null) {
      _cache[cacheKey] = remote;
      return remote;
    }
    return null;
  }

  LectureDiagramRef _fromBundledId(String id) {
    final DiagramAssetSource source = DiagramAssetService.instance.resolve(id);
    if (source.isNetwork) {
      return LectureDiagramRef.network(source.networkUrl!);
    }
    return LectureDiagramRef.asset(source.assetPath);
  }

  String? _matchBundledId(String query) {
    final String q = query.toLowerCase();
    for (final MapEntry<String, String> e in _keywordToDiagramId.entries) {
      if (q.contains(e.key)) return e.value;
    }
    return null;
  }

  Future<LectureDiagramRef?> _fetchFromWeb(String query) async {
    final LectureDiagramRef? commons = await _searchWikimediaCommons(query);
    if (commons != null) return commons;
    return _wikipediaThumbnail(query);
  }

  Future<LectureDiagramRef?> _searchWikimediaCommons(String query) async {
    try {
      final Uri uri = Uri.https('commons.wikimedia.org', '/w/api.php', <String, String>{
        'action': 'query',
        'format': 'json',
        'origin': '*',
        'generator': 'search',
        'gsrnamespace': '6',
        'gsrsearch': '$query diagram OR illustration OR chart',
        'gsrlimit': '8',
        'prop': 'imageinfo',
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

      for (final Object? page in pages.values) {
        if (page is! Map<String, dynamic>) continue;
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
        if (chosen != null && chosen.startsWith('http')) {
          return LectureDiagramRef.network(chosen);
        }
      }
    } catch (e) {
      debugPrint('Wikimedia diagram search failed: $e');
    }
    return null;
  }

  Future<LectureDiagramRef?> _wikipediaThumbnail(String query) async {
    try {
      final String title = query
          .replaceAll(RegExp(r'[^\w\s\-]'), ' ')
          .trim()
          .replaceAll(RegExp(r'\s+'), '_');
      if (title.isEmpty) return null;
      final Uri uri = Uri.https(
        'en.wikipedia.org',
        '/api/rest_v1/page/summary/${Uri.encodeComponent(title)}',
      );
      final http.Response res = await http
          .get(uri, headers: <String, String>{'Accept': 'application/json'})
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      final Object? decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) return null;
      final Map<String, dynamic>? thumb =
          decoded['thumbnail'] as Map<String, dynamic>?;
      final String? source = thumb?['source'] as String?;
      if (source != null && source.startsWith('http')) {
        return LectureDiagramRef.network(source);
      }
      final Map<String, dynamic>? original =
          decoded['originalimage'] as Map<String, dynamic>?;
      final String? originalSrc = original?['source'] as String?;
      if (originalSrc != null && originalSrc.startsWith('http')) {
        return LectureDiagramRef.network(originalSrc);
      }
    } catch (e) {
      debugPrint('Wikipedia diagram lookup failed: $e');
    }
    return null;
  }
}
