import '../../models/cs_curriculum.dart';
import 'cs_curriculum_topic_lists.dart';

/// Full multi-language curriculum catalog.
class CsCurriculumCatalog {
  CsCurriculumCatalog._();

  static const List<CsCurriculumLanguage> languages = <CsCurriculumLanguage>[
    CsCurriculumLanguage(id: 'html', label: 'HTML', codingLanguageId: 'html', isWeb: true),
    CsCurriculumLanguage(id: 'css', label: 'CSS', codingLanguageId: 'css', isWeb: true),
    CsCurriculumLanguage(id: 'javascript', label: 'JavaScript', codingLanguageId: 'javascript', isWeb: true),
    CsCurriculumLanguage(id: 'typescript', label: 'TypeScript', codingLanguageId: 'typescript'),
    CsCurriculumLanguage(id: 'java', label: 'Java', codingLanguageId: 'java'),
    CsCurriculumLanguage(id: 'python', label: 'Python', codingLanguageId: 'python3'),
    CsCurriculumLanguage(id: 'cpp', label: 'C++', codingLanguageId: 'cpp'),
    CsCurriculumLanguage(id: 'c', label: 'C', codingLanguageId: 'c'),
    CsCurriculumLanguage(id: 'csharp', label: 'C#', codingLanguageId: 'csharp'),
    CsCurriculumLanguage(id: 'rust', label: 'Rust', codingLanguageId: 'rust'),
    CsCurriculumLanguage(id: 'swift', label: 'Swift', codingLanguageId: 'swift'),
    CsCurriculumLanguage(id: 'dart', label: 'Dart', codingLanguageId: 'dart'),
    CsCurriculumLanguage(id: 'go', label: 'Go', codingLanguageId: 'go'),
    CsCurriculumLanguage(id: 'php', label: 'PHP', codingLanguageId: 'php'),
  ];

  static final List<CsCurriculumTopic> allTopics = _buildAllTopics();
  static final List<CsAlgorithmsTopic> algorithmsTopics = _buildAlgorithmsTopics();

  static CsCurriculumLanguage? languageById(String id) {
    for (final CsCurriculumLanguage lang in languages) {
      if (lang.id == id) return lang;
    }
    return null;
  }

  static List<CsCurriculumTopic> topicsForLanguage(String languageId) {
    return allTopics.where((CsCurriculumTopic t) => t.languageId == languageId).toList()
      ..sort((CsCurriculumTopic a, CsCurriculumTopic b) => a.order.compareTo(b.order));
  }

  static List<CsCurriculumTopic> topicsInTrack(String languageId) {
    if (languageId == 'algorithms') {
      return algorithmsTopics
          .map(
            (CsAlgorithmsTopic t) => CsCurriculumTopic(
              id: t.id,
              languageId: 'algorithms',
              title: t.title,
              order: t.order,
              level: t.level,
            ),
          )
          .toList()
        ..sort((CsCurriculumTopic a, CsCurriculumTopic b) => a.order.compareTo(b.order));
    }
    return topicsForLanguage(languageId);
  }

  static CsCurriculumTopic? nextTopicInTrack(String languageId, String currentTopicId) {
    final List<CsCurriculumTopic> topics = topicsInTrack(languageId);
    final int index = topics.indexWhere((CsCurriculumTopic t) => t.id == currentTopicId);
    if (index < 0 || index + 1 >= topics.length) return null;
    return topics[index + 1];
  }

  static CsCurriculumTopic? topicById(String id) {
    for (final CsCurriculumTopic topic in allTopics) {
      if (topic.id == id) return topic;
    }
    for (final CsAlgorithmsTopic algo in algorithmsTopics) {
      if (algo.id == id) {
        return CsCurriculumTopic(
          id: algo.id,
          languageId: 'algorithms',
          title: algo.title,
          order: algo.order,
          level: algo.level,
        );
      }
    }
    return null;
  }

  static CsAlgorithmsTopic? algorithmsTopicById(String id) {
    for (final CsAlgorithmsTopic topic in algorithmsTopics) {
      if (topic.id == id) return topic;
    }
    return null;
  }

  static int totalLessonCount() => allTopics.length + algorithmsTopics.length;

  static List<CsCurriculumTopic> _buildAllTopics() {
    final List<CsCurriculumTopic> out = <CsCurriculumTopic>[];
    for (final CsCurriculumLanguage lang in languages) {
      final List<String> titles = CsCurriculumTopicLists.byLanguageId[lang.id] ?? const <String>[];
      for (int i = 0; i < titles.length; i++) {
        out.add(
          CsCurriculumTopic(
            id: _topicId(lang.id, titles[i]),
            languageId: lang.id,
            title: titles[i],
            order: i,
            level: _levelForIndex(i, titles.length),
          ),
        );
      }
    }
    return out;
  }

  static List<CsAlgorithmsTopic> _buildAlgorithmsTopics() {
    const List<String> bankKeys = <String>[
      'loops',
      'loops',
      'functions',
      'arrays',
      'hash_map',
      'stack_queue',
      'linked_lists',
      'trees',
      'binary_search',
      'sorting',
      'recursion',
      'recursion',
      'dynamic_programming',
      'greedy',
      'graphs',
      'heap',
      'bit_manipulation',
      'two_pointers',
      'sliding_window',
      'union_find',
      'trie',
      'advanced_structures',
      'competitive',
      'projects',
    ];
    final List<CsAlgorithmsTopic> out = <CsAlgorithmsTopic>[];
    final List<String> titles = CsCurriculumTopicLists.algorithms;
    for (int i = 0; i < titles.length; i++) {
      out.add(
        CsAlgorithmsTopic(
          id: _topicId('algorithms', titles[i]),
          title: titles[i],
          order: i,
          level: _levelForIndex(i, titles.length),
          problemBankKey: i < bankKeys.length ? bankKeys[i] : 'competitive',
        ),
      );
    }
    return out;
  }

  static CsCurriculumLevel _levelForIndex(int index, int total) {
    final int beginnerEnd = (total * 0.35).ceil().clamp(1, total);
    final int intermediateEnd = (total * 0.7).ceil().clamp(beginnerEnd + 1, total);
    if (index < beginnerEnd) return CsCurriculumLevel.beginner;
    if (index < intermediateEnd) return CsCurriculumLevel.intermediate;
    return CsCurriculumLevel.advanced;
  }

  static String _topicId(String languageId, String title) {
    final String slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return '${languageId}_$slug';
  }
}
