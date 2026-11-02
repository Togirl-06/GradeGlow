class Course {
  const Course({
    required this.id,
    required this.code,
    required this.name,
    required this.professor,
    required this.semester,
    required this.school,
    required this.createdBy,
  });

  final String id;
  final String code;
  final String name;
  final String professor;
  final String semester;
  final String school;
  final String createdBy;

  String get label => '$code · $professor · $semester';

  factory Course.fromMap(String id, Map<String, dynamic> data) {
    return Course(
      id: id,
      code: data['code'] as String? ?? '',
      name: data['name'] as String? ?? '',
      professor: data['professor'] as String? ?? '',
      semester: data['semester'] as String? ?? '',
      school: data['school'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'code': code,
        'name': name,
        'professor': professor,
        'semester': semester,
        'school': school,
        'createdBy': createdBy,
        'searchKey': '${code}_${professor}_$semester'.toLowerCase(),
      };
}
