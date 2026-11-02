/// Normalized college / university roadmap tree for Virtual University V2.
///
/// Real catalogs differ (year→course→module→lesson, major→course→lesson,
/// level→track→course→topic). V2 always browses this shape.
class VuV2RoadmapLesson {
  const VuV2RoadmapLesson({
    required this.id,
    required this.title,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
}

class VuV2RoadmapModule {
  const VuV2RoadmapModule({
    required this.id,
    required this.title,
    required this.lessons,
    this.whyItMatters,
    this.realWorldApplications,
    this.industries = const <String>[],
  });

  final String id;
  final String title;
  final List<VuV2RoadmapLesson> lessons;

  /// Optional module intro copy (defaults generated in UI when null).
  final String? whyItMatters;
  final String? realWorldApplications;
  final List<String> industries;

  int get lessonCount => lessons.length;
}

class VuV2RoadmapCourse {
  const VuV2RoadmapCourse({
    required this.id,
    required this.title,
    this.subtitle,
    this.emoji,
    this.modules = const <VuV2RoadmapModule>[],
    this.lessons = const <VuV2RoadmapLesson>[],
    this.professorIntro,
    this.learningObjectives = const <String>[],
    this.skills = const <String>[],
    this.careerOpportunities = const <String>[],
    this.difficulty,
    this.estimatedMinutes,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? emoji;

  /// Prefer modules when the source catalog has them; else flat [lessons].
  final List<VuV2RoadmapModule> modules;
  final List<VuV2RoadmapLesson> lessons;

  final String? professorIntro;
  final List<String> learningObjectives;
  final List<String> skills;
  final List<String> careerOpportunities;
  final String? difficulty;
  final int? estimatedMinutes;

  int get lessonCount {
    if (modules.isNotEmpty) {
      return modules.fold<int>(
        0,
        (int n, VuV2RoadmapModule m) => n + m.lessonCount,
      );
    }
    return lessons.length;
  }

  List<VuV2RoadmapLesson> get allLessons {
    if (modules.isNotEmpty) {
      return modules
          .expand((VuV2RoadmapModule m) => m.lessons)
          .toList(growable: false);
    }
    return lessons;
  }

  String get resolvedDifficulty => difficulty ?? 'University';

  int get resolvedMinutes =>
      estimatedMinutes ?? (lessonCount * 25).clamp(60, 600);

  String get resolvedProfessorIntro =>
      professorIntro ??
      'Your AI Professor teaches this course with chalkboard lectures, '
          'worked examples, and checkpoints — the same journey in every major.';

  List<String> get resolvedObjectives {
    if (learningObjectives.isNotEmpty) return learningObjectives;
    return const <String>[
      'Explain core concepts with confidence',
      'Solve guided practice with the AI Professor',
      'Pass the knowledge check, challenge, and course exam',
    ];
  }

  List<String> get resolvedSkills {
    if (skills.isNotEmpty) return skills;
    return const <String>[
      'Critical reasoning',
      'Applied problem-solving',
      'Professional communication',
    ];
  }

  List<String> get resolvedCareers {
    if (careerOpportunities.isNotEmpty) return careerOpportunities;
    return const <String>[
      'Entry roles in the field',
      'Internship-ready projects',
      'Graduate / professional school prep',
    ];
  }
}

class VuV2RoadmapTrack {
  const VuV2RoadmapTrack({
    required this.id,
    required this.title,
    required this.courses,
    this.subtitle,
  });

  final String id;
  final String title;
  final String? subtitle;
  final List<VuV2RoadmapCourse> courses;

  int get courseCount => courses.length;

  int get lessonCount =>
      courses.fold<int>(0, (int n, VuV2RoadmapCourse c) => n + c.lessonCount);
}

/// Full synced degree / college roadmap for one faculty subject.
class VuV2DegreeRoadmap {
  const VuV2DegreeRoadmap({
    required this.subjectId,
    required this.title,
    required this.emoji,
    required this.sourceLabel,
    required this.tracks,
    this.tagline,
  });

  final String subjectId;
  final String title;
  final String emoji;
  final String? tagline;

  /// Where the tree came from (e.g. "Biology Degree Catalog · 4 years").
  final String sourceLabel;
  final List<VuV2RoadmapTrack> tracks;

  int get trackCount => tracks.length;

  int get courseCount =>
      tracks.fold<int>(0, (int n, VuV2RoadmapTrack t) => n + t.courseCount);

  int get lessonCount =>
      tracks.fold<int>(0, (int n, VuV2RoadmapTrack t) => n + t.lessonCount);

  VuV2RoadmapLesson? get firstLesson {
    for (final VuV2RoadmapTrack track in tracks) {
      for (final VuV2RoadmapCourse course in track.courses) {
        final List<VuV2RoadmapLesson> lessons = course.allLessons;
        if (lessons.isNotEmpty) return lessons.first;
      }
    }
    return null;
  }

  VuV2RoadmapCourse? get firstCourse {
    for (final VuV2RoadmapTrack track in tracks) {
      if (track.courses.isNotEmpty) return track.courses.first;
    }
    return null;
  }
}
