class NoteItem {
  const NoteItem({
    required this.id,
    required this.name,
    required this.downloadUrl,
    required this.sizeBytes,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String downloadUrl;
  final int sizeBytes;
  final DateTime createdAt;

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory NoteItem.fromMap(String id, Map<String, dynamic> data) {
    return NoteItem(
      id: id,
      name: data['name'] as String? ?? 'Untitled',
      downloadUrl: data['downloadUrl'] as String? ?? '',
      sizeBytes: (data['sizeBytes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        'downloadUrl': downloadUrl,
        'sizeBytes': sizeBytes,
        'createdAt': createdAt.toIso8601String(),
      };
}
