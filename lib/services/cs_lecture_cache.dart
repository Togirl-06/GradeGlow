import 'dart:async';

import 'openai_service.dart';

/// In-memory cache for CS professor lectures (session + prefetch).
class CsLectureCache {
  CsLectureCache._();

  static final Map<String, String> _lectures = <String, String>{};
  static final Set<String> _inFlight = <String>{};

  static String key({required String courseName, required String topicTitle}) =>
      '${courseName.trim().toLowerCase()}::${topicTitle.trim().toLowerCase()}';

  static String? get({required String courseName, required String topicTitle}) =>
      _lectures[key(courseName: courseName, topicTitle: topicTitle)];

  static void put({required String courseName, required String topicTitle, required String lecture}) {
    if (lecture.trim().isEmpty) return;
    _lectures[key(courseName: courseName, topicTitle: topicTitle)] = lecture;
  }

  static void prefetch({
    required OpenAiService openAi,
    required String courseName,
    required String topicTitle,
  }) {
    final String cacheKey = key(courseName: courseName, topicTitle: topicTitle);
    if (_lectures.containsKey(cacheKey) || _inFlight.contains(cacheKey)) return;
    _inFlight.add(cacheKey);
    unawaited(
      openAi.csProfessorLecture(courseName: courseName, topicTitle: topicTitle).then((String lecture) {
        put(courseName: courseName, topicTitle: topicTitle, lecture: lecture);
      }).whenComplete(() => _inFlight.remove(cacheKey)),
    );
  }
}
