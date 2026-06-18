import 'course_schedule.dart';
import 'study_progress.dart';

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.email,
    required this.school,
    required this.major,
    required this.year,
    required this.courseIds,
    required this.isEduVerified,
    required this.anonymousByDefault,
    required this.gpa,
    required this.streakDays,
    required this.lastStudyDate,
    required this.solutionsCount,
    required this.verifiedSolver,
    required this.xp,
    required this.badges,
    required this.weakTopics,
    required this.trackedSemesters,
    required this.courseSchedules,
    required this.studyProgress,
    this.plan = 'free',
  });

  final String displayName;
  final String email;
  final String school;
  final String major;
  final String year;
  final List<String> courseIds;
  final bool isEduVerified;
  final bool anonymousByDefault;
  final double gpa;
  final int streakDays;
  final DateTime? lastStudyDate;
  final int solutionsCount;
  final bool verifiedSolver;
  final int xp;
  final List<String> badges;
  /// Topic name → times marked wrong in quiz mode.
  final Map<String, int> weakTopics;
  /// Semester labels shown even before any class is added (e.g. "Spring 2026").
  final List<String> trackedSemesters;
  /// courseId → meeting time & reminder settings for this student.
  final Map<String, CourseSchedule> courseSchedules;
  final StudyProgress studyProgress;
  /// `free`, `premium`, or `premium_plus`
  final String plan;

  factory UserProfile.empty({required String email, String? displayName}) {
    return UserProfile(
      displayName: displayName ?? 'Student',
      email: email,
      school: '',
      major: '',
      year: '',
      courseIds: <String>[],
      isEduVerified: email.toLowerCase().endsWith('.edu'),
      anonymousByDefault: false,
      gpa: 0,
      streakDays: 0,
      lastStudyDate: null,
      solutionsCount: 0,
      verifiedSolver: false,
      xp: 0,
      badges: <String>[],
      weakTopics: <String, int>{},
      trackedSemesters: <String>[],
      courseSchedules: <String, CourseSchedule>{},
      studyProgress: StudyProgress.empty(),
      plan: 'free',
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic>? data, {required String email, String? displayName}) {
    if (data == null) {
      return UserProfile.empty(email: email, displayName: displayName);
    }
    final Map<String, int> weak = <String, int>{};
    final dynamic rawWeak = data['weakTopics'];
    if (rawWeak is Map) {
      rawWeak.forEach((dynamic key, dynamic value) {
        weak[key.toString()] = (value as num?)?.toInt() ?? 0;
      });
    }
    return UserProfile(
      displayName: data['displayName'] as String? ?? displayName ?? 'Student',
      email: email,
      school: data['school'] as String? ?? '',
      major: data['major'] as String? ?? '',
      year: data['year'] as String? ?? '',
      courseIds: (data['courseIds'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => e.toString()).toList(),
      isEduVerified: data['isEduVerified'] as bool? ?? email.toLowerCase().endsWith('.edu'),
      anonymousByDefault: data['anonymousByDefault'] as bool? ?? false,
      gpa: (data['gpa'] as num?)?.toDouble() ?? 0,
      streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
      lastStudyDate: DateTime.tryParse(data['lastStudyDate'] as String? ?? ''),
      solutionsCount: (data['solutionsCount'] as num?)?.toInt() ?? 0,
      verifiedSolver: data['verifiedSolver'] as bool? ?? false,
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      badges: (data['badges'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => e.toString()).toList(),
      weakTopics: weak,
      trackedSemesters: (data['trackedSemesters'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e.toString().trim())
          .where((String s) => s.isNotEmpty)
          .toList(),
      courseSchedules: _parseCourseSchedules(data['courseSchedules']),
      studyProgress: StudyProgress.fromMap(data['studyProgress'] as Map<String, dynamic>?),
      plan: data['plan'] as String? ?? 'free',
    );
  }

  static Map<String, CourseSchedule> _parseCourseSchedules(dynamic raw) {
    final Map<String, CourseSchedule> out = <String, CourseSchedule>{};
    if (raw is! Map) return out;
    raw.forEach((dynamic key, dynamic value) {
      if (value is Map<String, dynamic>) {
        out[key.toString()] = CourseSchedule.fromMap(key.toString(), value);
      } else if (value is Map) {
        out[key.toString()] = CourseSchedule.fromMap(
          key.toString(),
          value.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
        );
      }
    });
    return out;
  }

  UserProfile copyWith({
    String? displayName,
    String? school,
    String? major,
    String? year,
    List<String>? courseIds,
    bool? anonymousByDefault,
    double? gpa,
    int? streakDays,
    DateTime? lastStudyDate,
    int? solutionsCount,
    int? xp,
    List<String>? badges,
    Map<String, int>? weakTopics,
    List<String>? trackedSemesters,
    Map<String, CourseSchedule>? courseSchedules,
    StudyProgress? studyProgress,
    String? plan,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      email: email,
      school: school ?? this.school,
      major: major ?? this.major,
      year: year ?? this.year,
      courseIds: courseIds ?? this.courseIds,
      isEduVerified: isEduVerified,
      anonymousByDefault: anonymousByDefault ?? this.anonymousByDefault,
      gpa: gpa ?? this.gpa,
      streakDays: streakDays ?? this.streakDays,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      solutionsCount: solutionsCount ?? this.solutionsCount,
      verifiedSolver: verifiedSolver,
      xp: xp ?? this.xp,
      badges: badges ?? this.badges,
      weakTopics: weakTopics ?? this.weakTopics,
      trackedSemesters: trackedSemesters ?? this.trackedSemesters,
      courseSchedules: courseSchedules ?? this.courseSchedules,
      studyProgress: studyProgress ?? this.studyProgress,
      plan: plan ?? this.plan,
    );
  }

  List<MapEntry<String, int>> topWeakTopics({int limit = 5}) {
    final List<MapEntry<String, int>> sorted = weakTopics.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'displayName': displayName,
        'email': email,
        'school': school,
        'major': major,
        'year': year,
        'courseIds': courseIds,
        'isEduVerified': isEduVerified,
        'anonymousByDefault': anonymousByDefault,
        'gpa': gpa,
        'streakDays': streakDays,
        if (lastStudyDate != null) 'lastStudyDate': lastStudyDate!.toIso8601String(),
        'solutionsCount': solutionsCount,
        'verifiedSolver': verifiedSolver,
        'xp': xp,
        'badges': badges,
        'weakTopics': weakTopics,
        'trackedSemesters': trackedSemesters,
        'courseSchedules': courseSchedules.map(
          (String id, CourseSchedule s) => MapEntry<String, dynamic>(id, s.toMap()),
        ),
        'studyProgress': studyProgress.toMap(),
        'plan': plan,
      };
}
