import '../../models/chemistry_degree.dart';

String chemSlug(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r"[''']"), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

ChemistryDegreeLesson chemLesson(String title, {String? id}) {
  return ChemistryDegreeLesson(id: id ?? chemSlug(title), title: title);
}

List<ChemistryDegreeLesson> chemLessons(List<String> titles) {
  return titles.map(chemLesson).toList(growable: false);
}

ChemistryDegreeModule chemModule(String title, List<String> lessons) {
  return ChemistryDegreeModule(
    id: chemSlug(title),
    title: title,
    lessons: chemLessons(lessons),
  );
}

ChemistryDegreeCourse chemCourse(
  String id,
  String title, {
  required List<ChemistryDegreeModule> modules,
  String emoji = '⚗️',
  String? tagline,
}) {
  return ChemistryDegreeCourse(
    id: id,
    title: title,
    modules: modules,
    emoji: emoji,
    tagline: tagline,
  );
}

ChemistryDegreeCourse chemFlatCourse(
  String id,
  String title,
  List<String> topics, {
  String emoji = '⚗️',
  String? tagline,
}) {
  return chemCourse(
    id,
    title,
    modules: <ChemistryDegreeModule>[
      ChemistryDegreeModule(
        id: 'core_topics',
        title: 'Core Topics',
        lessons: chemLessons(topics),
      ),
    ],
    emoji: emoji,
    tagline: tagline,
  );
}

ChemistryDegreeYear chemYear(
  int year,
  String title,
  List<ChemistryDegreeCourse> courses, {
  String? subtitle,
}) {
  return ChemistryDegreeYear(
    year: year,
    title: title,
    courses: courses,
    subtitle: subtitle,
  );
}

List<String> chemDefaultTopics(String courseName) => <String>[
      'Introduction to $courseName',
      'Historical Development',
      'Core Definitions & Theory',
      'Key Laws & Equations',
      'Laboratory Techniques',
      'Worked Examples',
      'Real-World Applications',
      'Industrial Applications',
      'Common Mistakes',
      'Virtual Lab Session',
      'Practice Problems',
      'Exam Review',
    ];
