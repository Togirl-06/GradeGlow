class StudyMaterial {
  const StudyMaterial({
    required this.id,
    required this.fileName,
    required this.downloadUrl,
    required this.mimeType,
    required this.courseId,
    required this.courseCode,
    required this.professor,
    required this.examType,
    required this.semester,
    required this.topics,
    required this.isAnonymous,
    required this.uploaderId,
    required this.createdAt,
    required this.parseStatus,
  });

  final String id;
  final String fileName;
  final String downloadUrl;
  final String mimeType;
  final String courseId;
  final String courseCode;
  final String professor;
  final String examType;
  final String semester;
  final List<String> topics;
  final bool isAnonymous;
  final String uploaderId;
  final DateTime createdAt;
  final String parseStatus;

  bool get isParsed => parseStatus == 'done';

  factory StudyMaterial.fromMap(String id, Map<String, dynamic> data) {
    return StudyMaterial(
      id: id,
      fileName: data['fileName'] as String? ?? '',
      downloadUrl: data['downloadUrl'] as String? ?? '',
      mimeType: data['mimeType'] as String? ?? 'application/pdf',
      courseId: data['courseId'] as String? ?? '',
      courseCode: data['courseCode'] as String? ?? '',
      professor: data['professor'] as String? ?? '',
      examType: data['examType'] as String? ?? 'Exam',
      semester: data['semester'] as String? ?? '',
      topics: (data['topics'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => e.toString()).toList(),
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      uploaderId: data['uploaderId'] as String? ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
      parseStatus: data['parseStatus'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'mimeType': mimeType,
        'courseId': courseId,
        'courseCode': courseCode,
        'professor': professor,
        'examType': examType,
        'semester': semester,
        'topics': topics,
        'isAnonymous': isAnonymous,
        'uploaderId': uploaderId,
        'createdAt': createdAt.toIso8601String(),
        'parseStatus': parseStatus,
      };
}
