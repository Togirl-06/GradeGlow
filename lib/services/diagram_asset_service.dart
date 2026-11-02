import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../data/diagram_asset_registry.dart';

/// Resolves diagram artwork from CDN when configured, otherwise bundled assets.
class DiagramAssetService {
  DiagramAssetService._();
  static final DiagramAssetService instance = DiagramAssetService._();

  String? _cdnBase;

  String get cdnBase => _cdnBase ??= _readCdnBase();

  static String _readCdnBase() {
    final String raw = dotenv.env[DiagramAssetRegistry.cdnEnvKey]?.trim() ?? '';
    if (raw.isEmpty) return '';
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  /// Local asset path (always available offline).
  String bundledPath(String diagramId) => DiagramAssetRegistry.bundledPath(diagramId);

  /// Remote URL when CDN is configured, else null.
  String? remoteUrl(String diagramId) {
    if (cdnBase.isEmpty) return null;
    final String? file = DiagramAssetRegistry.remotePath(diagramId);
    if (file == null) return null;
    final String folder = DiagramAssetRegistry.subjectFolder(diagramId);
    return '$cdnBase/$folder/$file';
  }

  /// Prefer network when CDN is set; fall back to bundled asset path.
  DiagramAssetSource resolve(String diagramId, {String? bundledOverride}) {
    final String bundled = bundledOverride ?? bundledPath(diagramId);
    final String? remote = remoteUrl(diagramId);
    if (remote != null) {
      return DiagramAssetSource.network(remote, fallbackAsset: bundled);
    }
    return DiagramAssetSource.asset(bundled);
  }
}

/// How [EducationalDiagramCanvas] should load the illustration.
class DiagramAssetSource {
  const DiagramAssetSource.asset(this.assetPath) : networkUrl = null;

  const DiagramAssetSource.network(this.networkUrl, {required String fallbackAsset})
      : assetPath = fallbackAsset,
        assert(networkUrl != null);

  final String assetPath;
  final String? networkUrl;

  bool get isNetwork => networkUrl != null;
}
