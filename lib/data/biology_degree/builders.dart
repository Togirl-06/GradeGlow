import '../../models/biology_degree.dart';

String bioSlug(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r"[''']"), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

BiologyDegreeLesson bioLesson(String title, {String? id}) {
  return BiologyDegreeLesson(id: id ?? bioSlug(title), title: title);
}

List<BiologyDegreeLesson> bioLessons(List<String> titles) {
  return titles.map(bioLesson).toList(growable: false);
}

BiologyDegreeModule bioModule(String title, List<String> lessons) {
  return BiologyDegreeModule(
    id: bioSlug(title),
    title: title,
    lessons: bioLessons(lessons),
  );
}

BiologyDegreeCourse bioCourse(
  String id,
  String title, {
  required List<BiologyDegreeModule> modules,
  String emoji = '🧬',
  String? tagline,
}) {
  return BiologyDegreeCourse(
    id: id,
    title: title,
    modules: modules,
    emoji: emoji,
    tagline: tagline,
  );
}

BiologyDegreeCourse bioFlatCourse(
  String id,
  String title,
  List<String> topics, {
  String emoji = '🧬',
  String? tagline,
}) {
  return bioCourse(
    id,
    title,
    modules: <BiologyDegreeModule>[
      BiologyDegreeModule(
        id: 'core_topics',
        title: 'Core Topics',
        lessons: bioLessons(topics),
      ),
    ],
    emoji: emoji,
    tagline: tagline,
  );
}

BiologyDegreeYear bioYear(
  int year,
  String title,
  List<BiologyDegreeCourse> courses, {
  String? subtitle,
}) {
  return BiologyDegreeYear(
    year: year,
    title: title,
    courses: courses,
    subtitle: subtitle,
  );
}

List<String> bioDefaultTopics(String courseName) => <String>[
      'Introduction to $courseName',
      'Core Concepts & Vocabulary',
      'Key Structures & Functions',
      'Mechanisms & Processes',
      'Laboratory Techniques',
      'Clinical & Real-World Applications',
      'Common Misconceptions',
      'Research Connections',
      'Case Studies',
      'Virtual Lab Session',
      'Practice Problems',
      'Exam Review',
    ];
