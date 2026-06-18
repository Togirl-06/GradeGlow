import '../models/course.dart';
import '../models/study_summary.dart';
import '../models/user_profile.dart';
import 'study_set_stats.dart';

/// Which topic in a class deserves the most attention right now.
class FocusTopicRecommendation {
  const FocusTopicRecommendation({
    required this.summary,
    required this.reason,
  });

  final StudySummary summary;
  final String reason;

  String get topicName => summary.title;
}

/// Summaries rolled up under one enrolled class (or general bucket).
class ClassStudyGroup {
  const ClassStudyGroup({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.summaries,
    this.course,
  });

  final String courseId;
  final String courseCode;
  final String courseName;
  final List<StudySummary> summaries;
  final Course? course;

  String get displayTitle {
    if (courseCode.isNotEmpty) return courseCode;
    if (courseName.isNotEmpty) return courseName;
    return 'General';
  }

  String get displaySubtitle {
    if (courseName.isNotEmpty && courseCode.isNotEmpty && courseName != courseCode) {
      return courseName;
    }
    return '';
  }

  int get topicCount => summaries.length;

  StudySummary get latestSummary => summaries.first;

  StudySetMastery get mastery => StudySetMastery.fromSummaries(summaries);

  Course get courseForNavigation {
    if (course != null) return course!;
    return Course(
      id: courseId.isNotEmpty ? courseId : courseCode,
      code: courseCode.isNotEmpty ? courseCode : 'General',
      name: courseName,
      professor: '',
      semester: '',
      school: '',
      createdBy: '',
    );
  }

  String get statsLabel {
    final String topicLabel = topicCount == 1 ? '1 topic' : '$topicCount topics';
    final int cards = mastery.total;
    final String cardLabel = cards == 1 ? '1 card' : '$cards cards';
    return '$topicLabel · $cardLabel';
  }

  /// Suggest the topic this student should prioritize in this class.
  FocusTopicRecommendation? focusRecommendation({UserProfile? profile}) {
    if (summaries.isEmpty) return null;

    final FocusTopicRecommendation? fromWeak = _focusFromWeakTopics(profile);
    if (fromWeak != null) return fromWeak;

    if (summaries.length > 1) {
      final FocusTopicRecommendation? fromCards = _focusFromMostNewCards();
      if (fromCards != null) return fromCards;
    }

    if (mastery.masteryPercent == 0 && mastery.total > 0) {
      final StudySummary target = summaries.length == 1 ? summaries.first : _summaryWithMostKeyConcepts();
      return FocusTopicRecommendation(
        summary: target,
        reason: summaries.length == 1
            ? 'All ${mastery.total} cards are still new'
            : 'Largest topic — start building momentum here',
      );
    }

    if (summaries.length == 1) {
      return FocusTopicRecommendation(
        summary: summaries.first,
        reason: 'Keep reviewing this topic',
      );
    }

    return null;
  }

  FocusTopicRecommendation? _focusFromWeakTopics(UserProfile? profile) {
    if (profile == null || profile.weakTopics.isEmpty) return null;

    StudySummary? bestSummary;
    String? bestWeakTopic;
    int bestMissCount = 0;

    for (final MapEntry<String, int> weak in profile.topWeakTopics(limit: 12)) {
      for (final StudySummary summary in summaries) {
        if (!_matchesWeakTopic(weak.key, summary)) continue;
        if (weak.value > bestMissCount) {
          bestMissCount = weak.value;
          bestSummary = summary;
          bestWeakTopic = weak.key;
        }
      }
    }

    if (bestSummary == null) return null;
    return FocusTopicRecommendation(
      summary: bestSummary,
      reason: bestMissCount > 1
          ? '"$bestWeakTopic" appears in $bestMissCount missed questions'
          : 'You missed questions on "$bestWeakTopic" recently',
    );
  }

  FocusTopicRecommendation? _focusFromMostNewCards() {
    StudySummary? best;
    int bestCards = 0;
    for (final StudySummary summary in summaries) {
      final int count = summary.flashcards.length;
      if (count > bestCards) {
        bestCards = count;
        best = summary;
      }
    }
    if (best == null || bestCards == 0) return null;
    return FocusTopicRecommendation(
      summary: best,
      reason: '$bestCards new cards waiting — most material to cover',
    );
  }

  StudySummary _summaryWithMostKeyConcepts() {
    StudySummary best = summaries.first;
    for (final StudySummary summary in summaries) {
      if (summary.keyConcepts.length > best.keyConcepts.length) {
        best = summary;
      }
    }
    return best;
  }

  bool _matchesWeakTopic(String weakKey, StudySummary summary) {
    final String weak = weakKey.trim().toLowerCase();
    if (weak.isEmpty) return false;

    final String title = summary.title.trim().toLowerCase();
    if (title.contains(weak) || weak.contains(title)) return true;

    for (final String concept in summary.keyConcepts) {
      final String normalized = concept.trim().toLowerCase();
      if (normalized.isEmpty) continue;
      if (normalized.contains(weak) || weak.contains(normalized)) return true;
    }
    return false;
  }
}

List<ClassStudyGroup> groupSummariesByClass({
  required List<StudySummary> summaries,
  required List<Course> enrolledCourses,
}) {
  if (summaries.isEmpty) return <ClassStudyGroup>[];

  final Map<String, Course> courseById = <String, Course>{
    for (final Course c in enrolledCourses) c.id: c,
  };
  final Map<String, Course> courseByCode = <String, Course>{
    for (final Course c in enrolledCourses) c.code.trim().toUpperCase(): c,
  };

  final Map<String, List<StudySummary>> buckets = <String, List<StudySummary>>{};

  for (final StudySummary summary in summaries) {
    final String key = _groupKey(summary);
    buckets.putIfAbsent(key, () => <StudySummary>[]).add(summary);
  }

  final List<ClassStudyGroup> groups = buckets.entries.map((MapEntry<String, List<StudySummary>> entry) {
    final List<StudySummary> items = List<StudySummary>.from(entry.value)
      ..sort((StudySummary a, StudySummary b) => b.createdAt.compareTo(a.createdAt));
    final StudySummary anchor = items.first;

    Course? matched;
    if (anchor.courseId.isNotEmpty) {
      matched = courseById[anchor.courseId];
    }
    if (matched == null && anchor.courseCode.trim().isNotEmpty) {
      matched = courseByCode[anchor.courseCode.trim().toUpperCase()];
    }

    final String code = matched?.code ?? anchor.courseCode.trim();
    final String id = matched?.id ?? anchor.courseId;
    final String name = matched?.name ?? '';

    return ClassStudyGroup(
      courseId: id,
      courseCode: code,
      courseName: name,
      summaries: items,
      course: matched,
    );
  }).toList();

  groups.sort((ClassStudyGroup a, ClassStudyGroup b) => a.displayTitle.compareTo(b.displayTitle));
  return groups;
}

String _groupKey(StudySummary summary) {
  if (summary.courseId.isNotEmpty) return 'id:${summary.courseId}';
  if (summary.courseCode.trim().isNotEmpty) return 'code:${summary.courseCode.trim().toUpperCase()}';
  return 'general';
}
