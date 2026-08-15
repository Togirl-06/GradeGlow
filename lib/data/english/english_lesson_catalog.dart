import 'package:flutter/material.dart';

import '../../models/english_lesson.dart';
import 'lessons/articles_lesson.dart';
import 'lessons/comparatives_lesson.dart';
import 'lessons/conditionals_lesson.dart';
import 'lessons/countable_uncountable_lesson.dart';
import 'lessons/email_writing_lesson.dart';
import 'lessons/future_simple_lesson.dart';
import 'lessons/gerunds_infinitives_lesson.dart';
import 'lessons/linking_words_lesson.dart';
import 'lessons/modals_lesson.dart';
import 'lessons/opinions_lesson.dart';
import 'lessons/passive_voice_lesson.dart';
import 'lessons/past_continuous_lesson.dart';
import 'lessons/past_simple_lesson.dart';
import 'lessons/phrasal_verbs_lesson.dart';
import 'lessons/prepositions_lesson.dart';
import 'lessons/present_continuous_lesson.dart';
import 'lessons/present_perfect_lesson.dart';
import 'lessons/pronunciation_th_lesson.dart';
import 'lessons/question_words_lesson.dart';
import 'lessons/reading_comprehension_lesson.dart';
import 'lessons/reported_speech_lesson.dart';
import 'lessons/small_talk_lesson.dart';
import 'lessons/tag_questions_lesson.dart';

enum EnglishPracticeCategory {
  grammar('Grammar'),
  vocabulary('Vocabulary'),
  questions('Questions'),
  speaking('Speaking'),
  writing('Writing'),
  reading('Reading');

  const EnglishPracticeCategory(this.label);
  final String label;
}

class EnglishLessonEntry {
  const EnglishLessonEntry({
    required this.id,
    required this.title,
    required this.skillLabel,
    required this.script,
    required this.category,
    required this.icon,
  });

  final String id;
  final String title;
  final String skillLabel;
  final EnglishLessonScript script;
  final EnglishPracticeCategory category;
  final IconData icon;
}

EnglishLessonEntry _entry(
  EnglishLessonScript script,
  EnglishPracticeCategory category,
  IconData icon,
) =>
    EnglishLessonEntry(
      id: script.id,
      title: script.title,
      skillLabel: script.skillLabel,
      script: script,
      category: category,
      icon: icon,
    );

/// Full English practice library — rebuilt each access (hot-reload safe).
List<EnglishLessonEntry> buildEnglishLessonCatalog() => <EnglishLessonEntry>[
      // Grammar — tenses & structure
      _entry(presentPerfectLesson, EnglishPracticeCategory.grammar, Icons.schedule_rounded),
      _entry(pastSimpleLesson, EnglishPracticeCategory.grammar, Icons.history_rounded),
      _entry(presentContinuousLesson, EnglishPracticeCategory.grammar, Icons.motion_photos_on_rounded),
      _entry(pastContinuousLesson, EnglishPracticeCategory.grammar, Icons.timeline_rounded),
      _entry(futureSimpleLesson, EnglishPracticeCategory.grammar, Icons.upcoming_rounded),
      _entry(prepositionsLesson, EnglishPracticeCategory.grammar, Icons.place_outlined),
      _entry(comparativesLesson, EnglishPracticeCategory.grammar, Icons.compare_arrows_rounded),
      _entry(conditionalsLesson, EnglishPracticeCategory.grammar, Icons.call_split_rounded),
      _entry(passiveVoiceLesson, EnglishPracticeCategory.grammar, Icons.swap_horiz_rounded),
      _entry(gerundsInfinitivesLesson, EnglishPracticeCategory.grammar, Icons.format_list_bulleted_rounded),
      _entry(countableUncountableLesson, EnglishPracticeCategory.grammar, Icons.numbers_rounded),
      _entry(reportedSpeechLesson, EnglishPracticeCategory.grammar, Icons.chat_bubble_outline_rounded),
      // Vocabulary & real-life topics
      _entry(articlesLesson, EnglishPracticeCategory.vocabulary, Icons.abc_rounded),
      _entry(phrasalVerbsLesson, EnglishPracticeCategory.vocabulary, Icons.layers_rounded),
      // Questions
      _entry(questionWordsLesson, EnglishPracticeCategory.questions, Icons.help_outline_rounded),
      _entry(tagQuestionsLesson, EnglishPracticeCategory.questions, Icons.question_answer_rounded),
      // Speaking
      _entry(modalsLesson, EnglishPracticeCategory.speaking, Icons.record_voice_over_outlined),
      _entry(smallTalkLesson, EnglishPracticeCategory.speaking, Icons.people_outline_rounded),
      _entry(opinionsLesson, EnglishPracticeCategory.speaking, Icons.forum_outlined),
      _entry(pronunciationThLesson, EnglishPracticeCategory.speaking, Icons.graphic_eq_rounded),
      // Writing
      _entry(emailWritingLesson, EnglishPracticeCategory.writing, Icons.mail_outline_rounded),
      _entry(linkingWordsLesson, EnglishPracticeCategory.writing, Icons.notes_rounded),
      // Reading
      _entry(readingComprehensionLesson, EnglishPracticeCategory.reading, Icons.menu_book_rounded),
    ];

List<EnglishLessonEntry> get englishLessonCatalog => buildEnglishLessonCatalog();

const List<EnglishPracticeCategory> englishPracticeCategoryOrder =
    <EnglishPracticeCategory>[
  EnglishPracticeCategory.grammar,
  EnglishPracticeCategory.vocabulary,
  EnglishPracticeCategory.questions,
  EnglishPracticeCategory.speaking,
  EnglishPracticeCategory.writing,
  EnglishPracticeCategory.reading,
];

EnglishLessonEntry lessonForSkill(String skillId) {
  return englishLessonCatalog.firstWhere(
    (EnglishLessonEntry e) => e.id == skillId,
    orElse: () => englishLessonCatalog.first,
  );
}

List<EnglishLessonEntry> lessonsInCategory(EnglishPracticeCategory category) {
  return englishLessonCatalog
      .where((EnglishLessonEntry e) => e.category == category)
      .toList();
}

int get englishLessonCount => englishLessonCatalog.length;
