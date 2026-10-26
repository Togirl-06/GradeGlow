import 'package:flutter/material.dart';

import 'coding_challenge_bank.dart';

class ScienceMajor {
  const ScienceMajor({
    required this.id,
    required this.title,
    required this.blurb,
    required this.icon,
  });

  final String id;
  final String title;
  final String blurb;
  final IconData icon;
}

abstract final class ScienceMajors {
  static const List<ScienceMajor> all = <ScienceMajor>[
    ScienceMajor(
      id: 'software_engineering',
      title: 'Software Engineering',
      blurb: 'Requirements, architecture, delivery, and quality.',
      icon: Icons.laptop_chromebook_rounded,
    ),
    ScienceMajor(
      id: 'computer_science',
      title: 'Computer Science',
      blurb: 'Algorithms, systems, and computational thinking.',
      icon: Icons.memory_rounded,
    ),
    ScienceMajor(
      id: 'ai_ml',
      title: 'AI & Machine Learning',
      blurb: 'Models, evaluation, and data pipelines.',
      icon: Icons.psychology_alt_rounded,
    ),
    ScienceMajor(
      id: 'data_science',
      title: 'Data Science',
      blurb: 'Clean data, find trends, explain decisions.',
      icon: Icons.insights_rounded,
    ),
    ScienceMajor(
      id: 'cybersecurity',
      title: 'Cybersecurity',
      blurb: 'Logs, threats, and secure systems.',
      icon: Icons.security_rounded,
    ),
    ScienceMajor(
      id: 'information_technology',
      title: 'Information Technology',
      blurb: 'Support tickets, networks, and reliability.',
      icon: Icons.dns_rounded,
    ),
    ScienceMajor(
      id: 'web_development',
      title: 'Web Development',
      blurb: 'Responsive UI and modern web apps.',
      icon: Icons.language_rounded,
    ),
    ScienceMajor(
      id: 'mobile_development',
      title: 'Mobile App Development',
      blurb: 'Flutter features, UI bugs, and device tests.',
      icon: Icons.phone_android_rounded,
    ),
  ];

  static ScienceMajor byId(String id) => all.firstWhere(
        (ScienceMajor m) => m.id == id,
        orElse: () => all.first,
      );
}

class CodeOption {
  const CodeOption({
    required this.id,
    required this.label,
    required this.code,
    this.coachTip,
  });

  final String id;
  final String label;
  final String code;
  final String? coachTip;
}

class TestResult {
  const TestResult({
    required this.name,
    required this.passed,
    required this.detail,
    this.expected,
    this.got,
  });

  final String name;
  final bool passed;
  final String detail;
  final String? expected;
  final String? got;
}

class CodingChallenge {
  const CodingChallenge({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.topics,
    required this.prompt,
    required this.examples,
    required this.constraints,
    required this.xpReward,
    required this.options,
    required this.correctOptionId,
    required this.runTests,
    this.pathLabel = 'Arrays path',
  });

  final String id;
  final String title;
  final String difficulty;
  final List<String> topics;
  final String prompt;
  final String examples;
  final String constraints;
  final int xpReward;
  final List<CodeOption> options;
  final String correctOptionId;
  final List<TestResult> Function(String optionId) runTests;
  final String pathLabel;
}

abstract final class CodingArenaCatalog {
  static List<CodingChallenge> forMajor(String majorId) =>
      CodingChallengeBank.forMajor(majorId);

  static List<CodingChallenge> all() => CodingChallengeBank.all();
}

class JobListing {
  const JobListing({
    required this.id,
    required this.title,
    required this.company,
    required this.companyLetter,
    required this.mode,
    required this.level,
    required this.payLabel,
    required this.blurb,
    required this.skills,
    required this.majorTag,
  });

  final String id;
  final String title;
  final String company;
  final String companyLetter;
  final String mode;
  final String level;
  final String payLabel;
  final String blurb;
  final List<String> skills;
  final String majorTag;
}

// Job board: job_catalog.dart · Project Lab: project_lab_catalog.dart
