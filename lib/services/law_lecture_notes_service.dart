import 'package:shared_preferences/shared_preferences.dart';

import '../models/law/law_program.dart';

/// Stores AI Professor lecture notes so the topic quiz can be generated from them.
class LawLectureNotesService {
  LawLectureNotesService._();

  static final LawLectureNotesService instance = LawLectureNotesService._();

  static const String _prefix = 'law_lecture_notes_v1:';

  final Map<String, String> _cache = <String, String>{};

  static String keyFor({
    required String courseTitle,
    required String lessonId,
  }) =>
      '$_prefix${courseTitle.trim()}|$lessonId';

  Future<void> saveNotes({
    required String courseTitle,
    required String lessonId,
    required String notes,
  }) async {
    final String text = notes.trim();
    if (text.length < 40) return;
    final String key = keyFor(courseTitle: courseTitle, lessonId: lessonId);
    _cache[key] = text;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, text);
  }

  Future<String?> loadNotes({
    required String courseTitle,
    required String lessonId,
  }) async {
    final String key = keyFor(courseTitle: courseTitle, lessonId: lessonId);
    if (_cache.containsKey(key)) return _cache[key];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString(key);
    if (stored != null && stored.trim().isNotEmpty) {
      _cache[key] = stored;
      return stored;
    }
    return null;
  }

  /// Prefer saved AI lecture notes; otherwise build study notes from the lesson.
  Future<String> notesForQuiz({
    required String courseTitle,
    required LawLesson lesson,
  }) async {
    final String? saved = await loadNotes(courseTitle: courseTitle, lessonId: lesson.id);
    if (saved != null && saved.trim().length >= 80) return saved.trim();
    return fallbackNotes(courseTitle: courseTitle, lesson: lesson);
  }

  static String fallbackNotes({
    required String courseTitle,
    required LawLesson lesson,
  }) {
    return '''
# AI Professor Notes — ${lesson.title}
Course: $courseTitle

## Case hook
${lesson.hook}

## Guiding question
${lesson.question}

## Doctrine
${lesson.doctrine}

## Elements to master
${lesson.elements.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

## How to study these notes
- Restate each element in plain English.
- Apply every element to the hook facts.
- Identify the strongest and weakest element for each side.
- Watch for common mistakes: reciting rules without facts, skipping causation/defenses, and ignoring counterarguments.
''';
  }
}
