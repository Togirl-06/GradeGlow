class BinnedRecording {
  const BinnedRecording({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.durationSeconds,
    required this.deletedAt,
    this.label,
  });

  final String id;
  final String fileName;
  final String filePath;
  final int durationSeconds;
  final DateTime deletedAt;
  final String? label;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'fileName': fileName,
        'filePath': filePath,
        'durationSeconds': durationSeconds,
        'deletedAt': deletedAt.toIso8601String(),
        'label': label,
      };

  factory BinnedRecording.fromJson(Map<String, dynamic> json) => BinnedRecording(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        filePath: json['filePath'] as String,
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        deletedAt: DateTime.parse(json['deletedAt'] as String),
        label: json['label'] as String?,
      );
}
