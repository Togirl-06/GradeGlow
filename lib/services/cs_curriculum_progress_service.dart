import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/cs_curriculum/cs_curriculum_catalog.dart';
import '../models/cs_curriculum.dart';

/// Tracks curriculum completion and unlocks the algorithms track.
class CsCurriculumProgressService extends ChangeNotifier {
  CsCurriculumProgressService._();

  static final CsCurriculumProgressService instance = CsCurriculumProgressService._();

  static const String _keyCompleted = 'cs_curriculum_completed_topic_ids';

  final Set<String> completedTopicIds = <String>{};
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    completedTopicIds
      ..clear()
      ..addAll(prefs.getStringList(_keyCompleted) ?? <String>[]);
    _loaded = true;
  }

  bool isCompleted(String topicId) => completedTopicIds.contains(topicId);

  bool isTopicUnlocked(CsCurriculumTopic topic) => true;

  bool get algorithmsUnlocked => true;

  int completedCountForLanguage(String languageId) {
    return CsCurriculumCatalog.topicsForLanguage(languageId)
        .where((CsCurriculumTopic t) => completedTopicIds.contains(t.id))
        .length;
  }

  double progressRatioForLanguage(String languageId) {
    final List<CsCurriculumTopic> topics = CsCurriculumCatalog.topicsForLanguage(languageId);
    if (topics.isEmpty) return 0;
    return completedCountForLanguage(languageId) / topics.length;
  }

  Future<void> recordTopicComplete(String topicId) async {
    await ensureLoaded();
    if (completedTopicIds.contains(topicId)) return;
    completedTopicIds.add(topicId);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCompleted, completedTopicIds.toList());
    notifyListeners();
  }

  Future<void> recordProblemSolved({
    required String topicId,
    required String tier,
    required bool accepted,
  }) async {
    if (!accepted) return;
    if (tier.toLowerCase().contains('easy')) {
      await recordTopicComplete(topicId);
    }
  }
}
