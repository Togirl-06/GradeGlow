import '../../models/mathematics_degree.dart';

String mathSlug(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r"[''']"), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

MathematicsDegreeLesson mathLesson(String title, {String? id}) {
  return MathematicsDegreeLesson(id: id ?? mathSlug(title), title: title);
}

List<MathematicsDegreeLesson> mathLessons(List<String> titles) {
  return titles.map(mathLesson).toList(growable: false);
}

MathematicsDegreeModule mathModule(String title, List<String> lessons) {
  return MathematicsDegreeModule(
    id: mathSlug(title),
    title: title,
    lessons: mathLessons(lessons),
  );
}

MathematicsDegreeCourse mathCourse(
  String id,
  String title, {
  required List<MathematicsDegreeModule> modules,
  String emoji = '📘',
  String? tagline,
}) {
  return MathematicsDegreeCourse(
    id: id,
    title: title,
    modules: modules,
    emoji: emoji,
    tagline: tagline,
  );
}

/// Flat topic list → single "Core Topics" module (Year 2+ style).
MathematicsDegreeCourse mathFlatCourse(
  String id,
  String title,
  List<String> topics, {
  String emoji = '📘',
  String? tagline,
}) {
  return mathCourse(
    id,
    title,
    modules: <MathematicsDegreeModule>[
      MathematicsDegreeModule(
        id: 'core_topics',
        title: 'Core Topics',
        lessons: mathLessons(topics),
      ),
    ],
    emoji: emoji,
    tagline: tagline,
  );
}

MathematicsDegreeYear mathYear(
  int year,
  String title,
  List<MathematicsDegreeCourse> courses, {
  String? subtitle,
}) {
  return MathematicsDegreeYear(
    year: year,
    title: title,
    courses: courses,
    subtitle: subtitle,
  );
}
