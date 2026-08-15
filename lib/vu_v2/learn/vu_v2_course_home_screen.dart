import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_session.dart';
import '../data/vu_v2_topic_content.dart';
import '../data/vu_v2_topic_content_models.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_assessment_screen.dart';
import 'vu_v2_lesson_learn_hub_screen.dart';
import 'vu_v2_semester_exam_screen.dart';

/// Full course structure: Overview · Modules · Exam.
class VuV2CourseHomeScreen extends StatelessWidget {
  const VuV2CourseHomeScreen({
    super.key,
    required this.session,
    required this.progress,
    required this.subjectId,
    required this.facultyTitle,
    required this.facultyEmoji,
    required this.trackTitle,
    required this.course,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;
  final String subjectId;
  final String facultyTitle;
  final String facultyEmoji;
  final String trackTitle;
  final VuV2RoadmapCourse course;

  List<VuV2RoadmapLesson> get _lessons => course.allLessons;

  double get _pct => progress.courseProgress(
        courseId: course.id,
        lessonIds: _lessons.map((VuV2RoadmapLesson l) => l.id).toList(),
      );

  @override
  Widget build(BuildContext context) {
    final List<VuV2RoadmapModule> modules = course.modules.isNotEmpty
        ? course.modules
        : <VuV2RoadmapModule>[
            VuV2RoadmapModule(
              id: '${course.id}_all',
              title: 'Module 1 · Course lessons',
              lessons: course.lessons,
            ),
          ];

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            '$facultyEmoji  $facultyTitle · $trackTitle',
            style: const TextStyle(color: VuV2Colors.mute, fontSize: 13),
          ),
          const SizedBox(height: 12),
          VuV2Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'OVERVIEW',
                  style: TextStyle(
                    color: VuV2Colors.orange,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.title,
                  style: const TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.subtitle ??
                      'A complete course with AI teaching sessions, notes, and quizzes.',
                  style: const TextStyle(color: VuV2Colors.mute, height: 1.45),
                ),
                const SizedBox(height: 14),
                Text(
                  'Learning objectives',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '• Explain core concepts with confidence\n'
                  '• Solve guided practice with the AI Professor\n'
                  '• Pass the module quiz and course exam',
                  style: TextStyle(color: VuV2Colors.mute, height: 1.45),
                ),
                const SizedBox(height: 12),
                Text(
                  'Estimated duration · ~${(_lessons.length * 25).clamp(60, 600)} min',
                  style: const TextStyle(color: VuV2Colors.mute, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Instructor · AI Professor',
                  style: TextStyle(color: VuV2Colors.mute, fontSize: 13),
                ),
                const SizedBox(height: 12),
                VuV2ProgressBar(value: _pct),
                const SizedBox(height: 6),
                Text(
                  '${(_pct * 100).round()}% complete',
                  style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const VuV2SectionTitle('Modules'),
          const SizedBox(height: 10),
          ...modules.map((VuV2RoadmapModule m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VuV2Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      m.title,
                      style: const TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...m.lessons.map((VuV2RoadmapLesson lesson) {
                      final bool done =
                          progress.completedLessonIds.contains(lesson.id);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          done
                              ? Icons.check_circle_rounded
                              : Icons.play_circle_outline,
                          color: done ? VuV2Colors.success : VuV2Colors.orange,
                        ),
                        title: Text(
                          lesson.title,
                          style: const TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          lesson.subtitle ?? 'AI Professor · Notes · Quiz',
                          style: const TextStyle(color: VuV2Colors.mute, fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => VuV2LessonLearnHubScreen(
                                session: session,
                                progress: progress,
                                subjectId: subjectId,
                                facultyTitle: facultyTitle,
                                facultyEmoji: facultyEmoji,
                                trackTitle: trackTitle,
                                courseTitle: course.title,
                                lesson: lesson,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    const Divider(color: VuV2Colors.stroke),
                    TextButton.icon(
                      onPressed: () {
                        final pack = VuV2TopicContent.forLesson(
                          subjectId: subjectId,
                          facultyTitle: facultyTitle,
                          facultyEmoji: facultyEmoji,
                          trackTitle: trackTitle,
                          courseTitle: course.title,
                          topicTitle: '${m.title} quiz',
                          interactive: true,
                        );
                        final List<VuV2Mcq> mixed = VuV2MixedQuiz.enrich(pack.topicQuiz);
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => VuV2AssessmentScreen(
                              title: '${m.title} quiz',
                              subtitle: '${course.title} · pass ≥70%',
                              questions: mixed,
                              onCompleted: (double pct) {
                                progress.recordQuiz('${m.id}_quiz', pct);
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.quiz_outlined),
                      label: const Text('Module quiz'),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          VuV2PrimaryButton(
            label: 'Course exam',
            icon: Icons.timer_outlined,
            onPressed: () {
              final exam = VuV2TopicContent.courseExam(
                subjectId: subjectId,
                facultyTitle: facultyTitle,
                courseTitle: course.title,
                lessonTitles:
                    _lessons.map((VuV2RoadmapLesson l) => l.title).toList(),
              );
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VuV2SemesterExamScreen(
                    progress: progress,
                    title: '${course.title} exam',
                    subtitle: '$trackTitle · timed · pass ≥70%',
                    questions: VuV2MixedQuiz.enrich(exam.questions),
                    studentName: session.displayName,
                    courseId: course.id,
                    courseTitle: course.title,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Adds T/F + short-answer variants alongside MC for demo coverage.
abstract final class VuV2MixedQuiz {
  static List<VuV2Mcq> enrich(List<VuV2Mcq> base) {
    if (base.isEmpty) {
      return const <VuV2Mcq>[
        VuV2Mcq(
          id: 'tf1',
          prompt: 'Practice improves retention. True or False?',
          choices: <String>['True', 'False'],
          correctIndex: 0,
          explanation: 'Spaced practice strengthens memory.',
          kind: VuV2QuestionKind.trueFalse,
        ),
        VuV2Mcq(
          id: 'sa1',
          prompt: 'Name one study habit that helps long-term memory.',
          choices: <String>[],
          correctIndex: 0,
          explanation: 'Spaced repetition, retrieval practice, or teaching others.',
          kind: VuV2QuestionKind.shortAnswer,
          shortAnswerKey: <String>['spaced', 'retrieval', 'practice', 'teach'],
        ),
      ];
    }
    final List<VuV2Mcq> out = List<VuV2Mcq>.from(base);
    final VuV2Mcq first = base.first;
    out.add(
      VuV2Mcq(
        id: '${first.id}_tf',
        prompt: 'True or False: ${first.prompt}',
        choices: const <String>['True', 'False'],
        correctIndex: 0,
        explanation: first.explanation,
        kind: VuV2QuestionKind.trueFalse,
      ),
    );
    out.add(
      VuV2Mcq(
        id: '${first.id}_sa',
        prompt: 'In one phrase, what is the main idea of: ${first.prompt}',
        choices: const <String>[],
        correctIndex: 0,
        explanation: first.explanation,
        kind: VuV2QuestionKind.shortAnswer,
        shortAnswerKey: first.prompt
            .toLowerCase()
            .split(RegExp(r'[^a-z0-9]+'))
            .where((String w) => w.length > 4)
            .take(3)
            .toList(),
      ),
    );
    return out;
  }
}
