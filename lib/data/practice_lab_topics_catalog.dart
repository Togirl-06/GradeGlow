import '../models/ai_practice_mode.dart';

import '../models/practice_lab.dart';

import '../models/practice_lab_topic.dart';

import 'practice_lab_topics/major_topics_registry.dart';



/// Topic-based AI Practice Labs — unlimited scenarios per topic and difficulty.

/// Every major has its own distinct topic catalog.

class PracticeLabTopicsCatalog {

  PracticeLabTopicsCatalog._();



  static bool hasTopicsFor(String majorId, {String? groupId}) =>

      areasFor(majorId, groupId: groupId).isNotEmpty;



  static List<PracticeLabTopicArea> areasFor(

    String majorId, {

    String? groupId,

    String? majorName,

  }) {

    return MajorTopicsRegistry.topicsFor(

      majorId: majorId,

      majorName: majorName,

      groupId: groupId,

    );

  }



  static int totalLabCountFor(String majorId, {String? groupId, String? majorName}) =>

      areasFor(majorId, groupId: groupId, majorName: majorName)

          .fold<int>(0, (int sum, PracticeLabTopicArea area) => sum + area.labCount);



  static PracticeLabTopicArea? areaById({

    required String majorId,

    required String areaId,

    String? groupId,

    String? majorName,

  }) {

    for (final PracticeLabTopicArea area in areasFor(majorId, groupId: groupId, majorName: majorName)) {

      if (area.id == areaId) return area;

    }

    return null;

  }



  static PracticeLabTopic? topicById({

    required String majorId,

    required String areaId,

    required String topicId,

    String? groupId,

    String? majorName,

  }) {

    final PracticeLabTopicArea? area = areaById(

      majorId: majorId,

      areaId: areaId,

      groupId: groupId,

      majorName: majorName,

    );

    if (area == null) return null;

    for (final PracticeLabTopic topic in area.topics) {

      if (topic.id == topicId) return topic;

    }

    return null;

  }



  static PracticeLabType labFor({

    required PracticeLabCategory major,

    required PracticeLabTopicArea area,

    required PracticeLabTopic topic,

    required PracticeDifficulty difficulty,

  }) {

    return PracticeLabType(

      id: 'topic_${major.id}_${area.id}_${topic.id}_${difficulty.name}',

      title: topic.name,

      subtitle:

          '${area.name} · ${difficulty.label} AI lab for ${major.name}. '

          '${topic.description} Each session generates a unique scenario.',

      style: topic.style,

      codeLab: topic.codeLab,

      timed: topic.style == SimulationStyle.erEmergency,

      aiRole: topic.aiRole,

      studentTasks: topic.studentTasks,

      evaluationCriteria: topic.evaluationCriteria,

      difficulty: difficulty.label,

    );

  }



  static List<PracticeDifficulty> availableDifficulties(PracticeLabTopic topic) {

    final List<PracticeDifficulty> levels = <PracticeDifficulty>[];

    if (topic.beginner) levels.add(PracticeDifficulty.beginner);

    if (topic.intermediate) levels.add(PracticeDifficulty.intermediate);

    if (topic.advanced) levels.add(PracticeDifficulty.advanced);

    return levels;

  }



  static List<({PracticeLabTopicArea area, PracticeLabTopic topic})> searchTopics(

    String query, {

    required String majorId,

    String? groupId,

    String? majorName,

  }) {

    final String trimmed = query.trim().toLowerCase();

    if (trimmed.isEmpty) return const <({PracticeLabTopicArea area, PracticeLabTopic topic})>[];



    final List<({PracticeLabTopicArea area, PracticeLabTopic topic})> hits =

        <({PracticeLabTopicArea area, PracticeLabTopic topic})>[];

    for (final PracticeLabTopicArea area in areasFor(majorId, groupId: groupId, majorName: majorName)) {

      for (final PracticeLabTopic topic in area.topics) {

        final bool matches = area.name.toLowerCase().contains(trimmed) ||

            topic.name.toLowerCase().contains(trimmed) ||

            topic.description.toLowerCase().contains(trimmed);

        if (matches) hits.add((area: area, topic: topic));

      }

    }

    return hits;

  }

}


