/// User-created class/subject folders for summaries.
class SummarySubjects {
  SummarySubjects._();

  static const String defaultSubject = 'General';

  static List<String> sortedNames(Iterable<String> names) {
    final List<String> keys = names.toSet().toList();
    keys.sort((String a, String b) {
      if (a == defaultSubject) return -1;
      if (b == defaultSubject) return 1;
      return a.compareTo(b);
    });
    return keys;
  }
}

class SummarySubject {
  const SummarySubject({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  factory SummarySubject.fromMap(String id, Map<String, dynamic> data) {
    return SummarySubject(
      id: id,
      name: data['name'] as String? ?? SummarySubjects.defaultSubject,
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };
}
