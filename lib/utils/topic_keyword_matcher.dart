/// Strict topic keyword matching — avoids false positives like `organ` in `organelles`.
class TopicKeywordMatcher {
  TopicKeywordMatcher({
    required String topicId,
    required String topicName,
    String? subjectId,
    String? courseId,
  }) : _hay = _compose(subjectId, courseId, topicId, topicName);

  final String _hay;

  late final List<String> _segments = _hay
      .split(RegExp(r'[|_]+'))
      .where((String s) => s.isNotEmpty)
      .toList(growable: false);

  static String _compose(String? subjectId, String? courseId, String topicId, String topicName) {
    final String nameSlug = topicName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return <String>[
      if (subjectId != null && subjectId.isNotEmpty) subjectId.toLowerCase(),
      if (courseId != null && courseId.isNotEmpty) courseId.toLowerCase(),
      topicId.toLowerCase(),
      nameSlug,
    ].join('|');
  }

  String get haystack => _hay;

  /// Whether [keyword] matches this topic (segment-equal or safe prefix).
  bool matches(String keyword) {
    final String k = keyword.toLowerCase().trim();
    if (k.isEmpty) return false;

    for (final String segment in _segments) {
      if (segment == k) return true;
    }

    if (k.length < 4) return false;

    for (final String segment in _segments) {
      if (!segment.startsWith(k) || segment.length <= k.length) continue;
      if (_blockedPrefix(k, segment)) continue;
      return true;
    }
    return false;
  }

  bool matchesAny(Iterable<String> keywords) {
    for (final String keyword in keywords) {
      if (matches(keyword)) return true;
    }
    return false;
  }

  static bool _blockedPrefix(String keyword, String segment) {
    return switch (keyword) {
      'organ' => segment.startsWith('organelle'),
      'sort' => segment.startsWith('resort'),
      'force' => segment.contains('enforce'),
      _ => false,
    };
  }

  bool get isBoneAnatomyTopic => matchesAny(const <String>[
        'skeletal',
        'skeleton',
        'bone',
        'bones',
        'skull',
        'femur',
        'tibia',
        'humerus',
        'scapula',
        'sternum',
        'pelvis',
        'musculoskeletal',
        'orthopedic',
        'ortho',
        'fracture',
        'joint_types',
        'limb_anatomy',
        'rib',
        'vertebral',
        'cranial_fornamina',
        'brachial_plexus',
      ]);

  bool get isOrganelleOrCellTopic => matchesAny(const <String>[
        'organelle',
        'organelles',
        'cell_structure',
        'cell_membrane',
        'membrane_transport',
        'membrane',
        'mitochondria',
        'chloroplast',
        'lysosome',
        'golgi',
        'cytoplasm',
        'cytoskeleton',
        'atp',
        'atp_energy',
        'cellular_respiration',
        'endocytosis',
        'exocytosis',
        'apoptosis',
        'cell_cycle',
        'cell_communication',
        'signal_transduction',
      ]);

  /// Topics that should never receive bone/skeleton questions or diagrams.
  bool get excludesBoneContent => isOrganelleOrCellTopic || matchesAny(const <String>[
        'dna',
        'genetic',
        'genetics',
        'mendelian',
        'punnett',
        'ecology',
        'ecosystem',
        'photosynthesis',
        'evolution',
        'bacteria',
        'virus',
        'microbio',
        'stoichiometry',
        'acid',
        'circuit',
        'kinematic',
        'dosage',
        'pharmacology',
        'sql',
        'algorithm',
        'marketing',
        'accounting',
      ]);
}
