import 'package:flutter/material.dart';

/// How every Law School lesson moves from curiosity to advocacy.
enum LawLearningMode {
  hookCase,
  aiProfessor,
  legalWriting,
  courtroom,
  objections,
  negotiation,
  exam,
}

extension LawLearningModeX on LawLearningMode {
  String get label => switch (this) {
        LawLearningMode.hookCase => 'Today\'s Case Hook',
        LawLearningMode.aiProfessor => 'AI Professor',
        LawLearningMode.legalWriting => 'Legal Writing',
        LawLearningMode.courtroom => 'Live Courtroom',
        LawLearningMode.objections => 'Objection Drill',
        LawLearningMode.negotiation => 'Negotiation',
        LawLearningMode.exam => 'Professor Topic Quiz',
      };

  String get subtitle => switch (this) {
        LawLearningMode.hookCase => 'Start with a dispute — think before the rule',
        LawLearningMode.aiProfessor => 'Full digital textbook chapter with voice audio',
        LawLearningMode.legalWriting => 'Memos, motions, letters — graded on reasoning',
        LawLearningMode.courtroom => 'Investigate, argue, object, persuade the court',
        LawLearningMode.objections => 'Spot hearsay, relevance, leading — and why',
        LawLearningMode.negotiation => 'Settle or try — every offer has consequences',
        LawLearningMode.exam => 'Quiz from the AI professor\'s notes on this topic',
      };

  IconData get icon => switch (this) {
        LawLearningMode.hookCase => Icons.gavel_rounded,
        LawLearningMode.aiProfessor => Icons.school_outlined,
        LawLearningMode.legalWriting => Icons.edit_note_rounded,
        LawLearningMode.courtroom => Icons.account_balance_rounded,
        LawLearningMode.objections => Icons.front_hand_outlined,
        LawLearningMode.negotiation => Icons.handshake_outlined,
        LawLearningMode.exam => Icons.quiz_outlined,
      };
}

class LawSpecialization {
  const LawSpecialization({
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.courses,
  });

  final String id;
  final String name;
  final String tagline;
  final IconData icon;
  final List<LawCourse> courses;
}

class LawCourse {
  const LawCourse({
    required this.id,
    required this.title,
    required this.blurb,
    required this.lessons,
  });

  final String id;
  final String title;
  final String blurb;
  final List<LawLesson> lessons;
}

/// One lesson always opens with a dispute, then teaches through practice.
class LawLesson {
  const LawLesson({
    required this.id,
    required this.title,
    required this.hook,
    required this.question,
    required this.doctrine,
    required this.elements,
    required this.briefCaseName,
    required this.briefFacts,
    required this.briefIssue,
    required this.briefRule,
    required this.briefHolding,
    required this.writingPrompt,
    required this.writingType,
    required this.objectionStem,
    required this.objectionOptions,
    required this.correctObjectionIndex,
    required this.objectionExplain,
    required this.clientOpening,
    required this.clientFacts,
    required this.negotiationOffer,
    required this.examHypo,
    this.simulationCaseId,
  });

  final String id;
  final String title;
  final String hook;
  final String question;
  final String doctrine;
  final List<String> elements;
  final String briefCaseName;
  final String briefFacts;
  final String briefIssue;
  final String briefRule;
  final String briefHolding;
  final String writingPrompt;
  final String writingType;
  final String objectionStem;
  final List<String> objectionOptions;
  final int correctObjectionIndex;
  final String objectionExplain;
  final String clientOpening;
  final List<String> clientFacts;
  final String negotiationOffer;
  final String examHypo;
  final String? simulationCaseId;
}
