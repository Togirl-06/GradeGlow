// Read models for the Virtual University campus dashboard (Phase 1).

class VuContinueItem {
  const VuContinueItem({
    required this.subjectId,
    required this.subjectName,
    required this.courseTitle,
    required this.lessonTitle,
    required this.routeHint,
    required this.progress,
  });

  factory VuContinueItem.fromJson(Map<String, dynamic> json) {
    return VuContinueItem(
      subjectId: json['subjectId'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      courseTitle: json['courseTitle'] as String? ?? '',
      lessonTitle: json['lessonTitle'] as String? ?? '',
      routeHint: json['routeHint'] as String? ?? '',
      progress: ((json['progress'] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0),
    );
  }

  final String subjectId;
  final String subjectName;
  final String courseTitle;
  final String lessonTitle;
  final String routeHint;
  final double progress;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'subjectId': subjectId,
    'subjectName': subjectName,
    'courseTitle': courseTitle,
    'lessonTitle': lessonTitle,
    'routeHint': routeHint,
    'progress': progress,
  };

  VuContinueItem copyWith({
    String? subjectId,
    String? subjectName,
    String? courseTitle,
    String? lessonTitle,
    String? routeHint,
    double? progress,
  }) {
    return VuContinueItem(
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      courseTitle: courseTitle ?? this.courseTitle,
      lessonTitle: lessonTitle ?? this.lessonTitle,
      routeHint: routeHint ?? this.routeHint,
      progress: progress ?? this.progress,
    );
  }
}

class VuCertificateItem {
  const VuCertificateItem({
    required this.id,
    required this.title,
    required this.subjectName,
    this.earnedAt,
    this.badgeIds = const <String>[],
  });

  final String id;
  final String title;
  final String subjectName;
  final DateTime? earnedAt;
  final List<String> badgeIds;
}

class VuAchievementItem {
  const VuAchievementItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

class VuCourseProgressItem {
  const VuCourseProgressItem({
    required this.subjectId,
    required this.subjectName,
    required this.courseTitle,
    required this.progress,
  });

  final String subjectId;
  final String subjectName;
  final String courseTitle;
  final double progress;
}

class VuDashboardSnapshot {
  const VuDashboardSnapshot({
    required this.welcomeName,
    required this.continueItems,
    required this.currentCourses,
    required this.streakDays,
    required this.weeklyGoal,
    required this.weeklyCompleted,
    required this.dailyStudyMinutes,
    required this.upcomingLessons,
    required this.recommendations,
    required this.recentlyCompleted,
    required this.certificates,
    required this.achievements,
    required this.overallProgress,
    required this.totalXp,
  });

  final String welcomeName;
  final List<VuContinueItem> continueItems;
  final List<VuCourseProgressItem> currentCourses;
  final int streakDays;
  final int weeklyGoal;
  final int weeklyCompleted;
  final int dailyStudyMinutes;
  final List<String> upcomingLessons;
  final List<String> recommendations;
  final List<VuContinueItem> recentlyCompleted;
  final List<VuCertificateItem> certificates;
  final List<VuAchievementItem> achievements;
  final double overallProgress;
  final int totalXp;
}
