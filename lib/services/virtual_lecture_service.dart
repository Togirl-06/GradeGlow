import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../data/virtual_lecture_completeness.dart';
import '../data/virtual_lecture_curriculum_script.dart';
import '../data/virtual_lecture_fallback.dart';
import '../data/virtual_lecture_topic_profile.dart';
import '../models/biology_degree.dart';
import '../models/chemistry_degree.dart';
import '../models/mathematics_degree.dart';
import '../models/virtual_lecture.dart';
import '../utils/lecture_slide_sync.dart';
import 'openai_service.dart';

/// Generates lecture scripts, handles Ask Professor, and stores analytics.
class VirtualLectureService {
  VirtualLectureService(this._openAi);

  final OpenAiService _openAi;
  static const String _analyticsKey = 'virtual_lecture_analytics_v1';

  Future<VirtualLectureScript> loadScript({
    required MathematicsLessonPath path,
    required LectureMode mode,
    double masteryHint = 0,
    List<String> weakAreas = const <String>[],
  }) {
    return loadLessonScript(
      lessonTitle: path.lesson.title,
      courseTitle: path.course.title,
      moduleTitle: path.module.title,
      courseId: path.course.id,
      lessonId: path.lesson.id,
      mode: mode,
      masteryHint: masteryHint,
      weakAreas: weakAreas,
      faculty: 'mathematics',
    );
  }

  Future<VirtualLectureScript> loadBiologyScript({
    required BiologyLessonPath path,
    required LectureMode mode,
    double masteryHint = 0,
    List<String> weakAreas = const <String>[],
  }) {
    return loadLessonScript(
      lessonTitle: path.lesson.title,
      courseTitle: path.course.title,
      moduleTitle: path.module.title,
      courseId: path.course.id,
      lessonId: path.lesson.id,
      mode: mode,
      masteryHint: masteryHint,
      weakAreas: weakAreas,
      faculty: 'biology',
    );
  }

  Future<VirtualLectureScript> loadChemistryScript({
    required ChemistryLessonPath path,
    required LectureMode mode,
    double masteryHint = 0,
    List<String> weakAreas = const <String>[],
  }) {
    return loadLessonScript(
      lessonTitle: path.lesson.title,
      courseTitle: path.course.title,
      moduleTitle: path.module.title,
      courseId: path.course.id,
      lessonId: path.lesson.id,
      mode: mode,
      masteryHint: masteryHint,
      weakAreas: weakAreas,
      faculty: 'chemistry',
    );
  }

  /// Instant offline script — use this to start the lecture without waiting on the network.
  VirtualLectureScript loadOfflineLessonScript({
    required String lessonTitle,
    required String courseTitle,
    required String moduleTitle,
    required String courseId,
    required String lessonId,
    required LectureMode mode,
    String faculty = 'general',
  }) {
    final VirtualLectureScript raw =
        VirtualLectureCurriculumScript.prefersCurriculumBank(
              faculty: faculty,
              courseId: courseId,
            )
            ? VirtualLectureCurriculumScript.build(
                lessonTitle: lessonTitle,
                courseTitle: courseTitle,
                moduleTitle: moduleTitle,
                courseId: courseId,
                lessonId: lessonId,
                mode: mode,
                faculty: faculty,
              )
            : VirtualLectureFallback.build(
                topic: lessonTitle,
                course: courseTitle,
                module: moduleTitle,
                courseId: courseId,
                lessonId: lessonId,
                mode: mode,
              );
    return LectureSlideSync.syncScript(
      VirtualLectureCompleteness.ensure(
        script: raw,
        faculty: faculty,
        mode: mode,
        courseId: courseId,
        lessonId: lessonId,
      ),
    );
  }

  /// Universal lecture script loader — any subject / course / lesson.
  Future<VirtualLectureScript> loadLessonScript({
    required String lessonTitle,
    required String courseTitle,
    required String moduleTitle,
    required String courseId,
    required String lessonId,
    required LectureMode mode,
    double masteryHint = 0,
    List<String> weakAreas = const <String>[],
    String faculty = 'general',
    bool preferOfflineFirst = false,
  }) async {
    final VirtualLectureScript offline = loadOfflineLessonScript(
      lessonTitle: lessonTitle,
      courseTitle: courseTitle,
      moduleTitle: moduleTitle,
      courseId: courseId,
      lessonId: lessonId,
      mode: mode,
      faculty: faculty,
    );
    if (preferOfflineFirst || !AppConfig.hasOpenAi) return offline;

    final VirtualLectureScript? ai = await tryLoadAiLessonScript(
      lessonTitle: lessonTitle,
      courseTitle: courseTitle,
      moduleTitle: moduleTitle,
      mode: mode,
      masteryHint: masteryHint,
      weakAreas: weakAreas,
      faculty: faculty,
    );
    return ai ?? offline;
  }

  /// Returns a richer AI script, or null if generation fails/times out.
  Future<VirtualLectureScript?> tryLoadAiLessonScript({
    required String lessonTitle,
    required String courseTitle,
    required String moduleTitle,
    required LectureMode mode,
    double masteryHint = 0,
    List<String> weakAreas = const <String>[],
    String faculty = 'general',
    String courseId = '',
    String lessonId = '',
  }) async {
    if (!AppConfig.hasOpenAi) return null;

    final String paceHint = masteryHint >= 0.7
        ? 'advanced student — go deeper, faster pace, still full lecture structure, fewer basic examples'
        : masteryHint >= 0.35
            ? 'standard first-year university student — full depth, clear steps'
            : 'struggling / returning learner — simplify language, more examples, review prerequisites, reteach differently when confused';

    final String reviewHint = weakAreas.isEmpty
        ? ''
        : ' Student weak areas to revisit on the whiteboard: ${weakAreas.join(', ')}.';

    final String facultyGuide = _facultyGuide(faculty);
    final VirtualLectureTopicProfile profile = VirtualLectureTopicProfile.resolve(
      topic: lessonTitle,
      course: courseTitle,
      courseId: courseId,
      module: moduleTitle,
      lessonId: lessonId,
    );

    try {
      final Map<String, dynamic> raw = await _openAi
          .generateVirtualLectureScriptRaw(
            topicName: lessonTitle,
            courseName: courseTitle,
            moduleName: moduleTitle,
            mode: mode.name,
            segmentCount: mode.isFullLecture
                ? mode.targetSegments.clamp(40, 64)
                : mode.targetSegments.clamp(10, 24),
            faculty: faculty,
            paceHint:
                '$facultyGuide$paceHint$reviewHint '
                'CURRICULUM LOCK: Teach ONLY "$lessonTitle" inside course "$courseTitle" '
                '(courseId=$courseId, module="$moduleTitle"). '
                'Whiteboard notes must match what you say — one slide note per spoken beat. '
                'REQUIRED: theory/example segments use beats[] so the board flips with each idea. '
                'Never 12+ sentences in one professorSpeech with a long lines[] list. '
                'TOPIC EQUATION/RULE: ${profile.mainEquation}. '
                'CATEGORY: ${profile.category.name}. '
                'FORBIDDEN: inventing trigonometry, calculus, algebra, or any other course content '
                'unless this lesson is explicitly that subject.',
            premium: true,
            courseId: courseId,
          )
          .timeout(const Duration(seconds: 90));
      final VirtualLectureScript script = VirtualLectureScript.fromJson(
        raw,
        mode: mode,
        topic: lessonTitle,
        course: courseTitle,
        module: moduleTitle,
      );
      if (script.segments.isNotEmpty) {
        return LectureSlideSync.syncScript(
          VirtualLectureCompleteness.ensure(
            script: script,
            faculty: faculty,
            mode: mode,
            profile: profile,
            courseId: courseId,
            lessonId: lessonId,
          ),
        );
      }
    } catch (e) {
      debugPrint('AI lecture generation failed/timed out: $e');
    }
    return null;
  }

  static String _facultyGuide(String faculty) {
    const String deepRule =
        'EVERY topic must include ALL of: intro+why it matters, history, deep theory, '
        'diagrams, formulas with every symbol, ≥3 real-world examples, questions throughout, '
        'confusion reteach differently, compare to previous lessons, easy→hard exercises, '
        'homework, and additional reading. Never give short chatbot answers. '
        'Full lectures must last ONE HOUR OR MORE of real teaching time. '
        'EXPLAIN WELL: plain meaning → precise definition → why it works → concrete example → pitfalls. '
        'Write complete sentences; define every symbol; whiteboard lines must teach, not just label.\n';
    switch (faculty) {
      case 'chemistry':
        return 'CHEMISTRY FACULTY: Teach like a world-class lab professor. '
            'Build reactions and electron movement on the board while speaking. $deepRule';
      case 'biology':
        return 'BIOLOGY FACULTY: Teach like a medical & research professor. '
            'Animate cells and processes on the board; pause for questions. $deepRule';
      case 'physics':
        return 'PHYSICS FACULTY: Derive formulas on the board, draw free-body diagrams, connect to experiments. $deepRule';
      case 'computer_science':
      case 'software_engineering':
      case 'artificial_intelligence':
      case 'cybersecurity':
        return 'COMPUTER SCIENCE FACULTY: Walk concepts on a digital board, show code steps, ask prediction questions. $deepRule';
      case 'mathematics':
        return 'MATHEMATICS FACULTY: Write equations step-by-step; explain every symbol; never skip reasoning. $deepRule';
      case 'engineering':
        return 'ENGINEERING FACULTY: Systems thinking — diagrams first, then formulas, then design tradeoffs. $deepRule';
      case 'law':
        return 'LAW FACULTY: Define doctrine, walk a case, ask analysis questions, compare precedents. $deepRule';
      case 'business':
      case 'business_administration':
      case 'accounting':
      case 'economics':
      case 'marketing':
        return 'BUSINESS FACULTY: Frameworks + real company examples; decisions and consequences on the board. $deepRule';
      case 'nursing':
        return 'NURSING FACULTY: Teach clinical judgment for THIS nursing topic only — '
            'assessment cues, priorities, safe actions, reassessment, documentation, escalation. '
            'Use bedside / unit language. Never teach trigonometry or unrelated math. $deepRule';
      case 'medicine':
        return 'MEDICINE FACULTY: Teach diagnostic reasoning for THIS medical topic only — '
            'presentation, differentials, red flags, first actions, disposition. '
            'Never drift into unrelated courses. $deepRule';
      case 'psychology':
        return 'PSYCHOLOGY FACULTY: Teach assessment and intervention for THIS psychology topic only — '
            'definitions, mechanisms, ethics, clinical application. Never invent other subjects. $deepRule';
      default:
        return 'UNIVERSITY FACULTY: Teach as if students are in your lecture hall for 60–75 minutes. '
            'Stay strictly on the assigned topic and course. $deepRule';
    }
  }

  Future<String> askBiologyProfessor({
    required BiologyLessonPath path,
    required String currentSpeech,
    required String question,
  }) {
    return askProfessorForLesson(
      lessonTitle: path.lesson.title,
      courseTitle: path.course.title,
      currentSpeech: currentSpeech,
      question: question,
    );
  }

  Future<String> askChemistryProfessor({
    required ChemistryLessonPath path,
    required String currentSpeech,
    required String question,
  }) {
    return askProfessorForLesson(
      lessonTitle: path.lesson.title,
      courseTitle: path.course.title,
      currentSpeech: currentSpeech,
      question: question,
    );
  }

  Future<String> askProfessorForLesson({
    required String lessonTitle,
    required String courseTitle,
    required String currentSpeech,
    required String question,
  }) async {
    if (!AppConfig.hasOpenAi) {
      return _offlineAskAnswer(lessonTitle, question);
    }
    try {
      return await _openAi.askProfessorDuringLecture(
        topicName: lessonTitle,
        courseName: courseTitle,
        currentSegmentSpeech: currentSpeech,
        studentQuestion: question,
        premium: true,
      );
    } catch (e) {
      debugPrint('Ask professor failed: $e');
      return _offlineAskAnswer(lessonTitle, question);
    }
  }

  Future<LectureSegment?> expandBiologyLecture({
    required BiologyLessonPath path,
    required String currentSpeech,
    required String studentRequest,
  }) {
    return expandLectureForLesson(
      lessonTitle: path.lesson.title,
      courseTitle: path.course.title,
      currentSpeech: currentSpeech,
      studentRequest: studentRequest,
    );
  }

  Future<LectureSegment?> expandChemistryLecture({
    required ChemistryLessonPath path,
    required String currentSpeech,
    required String studentRequest,
  }) {
    return expandLectureForLesson(
      lessonTitle: path.lesson.title,
      courseTitle: path.course.title,
      currentSpeech: currentSpeech,
      studentRequest: studentRequest,
    );
  }

  Future<String> askProfessor({
    required MathematicsLessonPath path,
    required String currentSpeech,
    required String question,
  }) {
    return askProfessorForLesson(
      lessonTitle: path.lesson.title,
      courseTitle: path.course.title,
      currentSpeech: currentSpeech,
      question: question,
    );
  }

  Future<LectureSegment?> expandLecture({
    required MathematicsLessonPath path,
    required String currentSpeech,
    required String studentRequest,
  }) {
    return expandLectureForLesson(
      lessonTitle: path.lesson.title,
      courseTitle: path.course.title,
      currentSpeech: currentSpeech,
      studentRequest: studentRequest,
    );
  }

  Future<LectureSegment?> expandLectureForLesson({
    required String lessonTitle,
    required String courseTitle,
    required String currentSpeech,
    required String studentRequest,
  }) async {
    if (!AppConfig.hasOpenAi) {
      return LectureSlideSync.syncSegment(
        _offlineExpansionSegment(lessonTitle, studentRequest),
      );
    }
    try {
      final Map<String, dynamic> raw = await _openAi.generateLectureExpansionSegmentRaw(
        topicName: lessonTitle,
        courseName: courseTitle,
        currentSpeech: currentSpeech,
        studentRequest: studentRequest,
        premium: true,
      );
      final LectureSegment segment = LectureSegment.fromJson(raw);
      if (segment.professorSpeech.trim().isEmpty) return null;
      return LectureSlideSync.syncSegment(segment);
    } catch (e) {
      debugPrint('Lecture expansion failed: $e');
      return LectureSlideSync.syncSegment(
        _offlineExpansionSegment(lessonTitle, studentRequest),
      );
    }
  }

  static String _offlineAskAnswer(String topic, String question) {
    final String q = question.trim();
    return 'About $topic — here is a clearer take on your question'
        '${q.isEmpty ? '' : ' ("$q")'}. '
        'First, lock the core definition in simple words. '
        'Next, picture one concrete example that uses that definition. '
        'Then ask yourself: what would change if I removed this idea? '
        'If a specific term or step is still unclear, ask again and name that part exactly.';
  }

  static LectureSegment _offlineExpansionSegment(String topic, String request) {
    return LectureSegment(
      phase: LecturePhase.conceptExplanation,
      professorSpeech:
          'You asked for more on $topic: $request. '
          'Let us go deeper — here is a fuller explanation with an extra worked example on the board. '
          'Watch each step; I will pause for your prediction before continuing.',
      caption: 'Extra depth',
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.text,
        title: 'Expanded: $topic',
        lines: <String>[
          'More detail on your question',
          'Extra worked example',
          'Common mistake to avoid',
        ],
      ),
      durationSeconds: 100,
      knowledgeCheck: LectureKnowledgeCheck(
        prompt: 'What should we identify before solving?',
        kind: KnowledgeCheckKind.multipleChoice,
        options: <String>['Given & goal', 'Final answer only', 'Skip to formula', 'Guess'],
        correctIndex: 0,
        explanation: 'Always clarify given information and the target before computing.',
      ),
    );
  }

  Future<LectureAnalytics> loadAnalytics(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> all = _readAll(prefs);
    final Map<String, dynamic>? entry = all[lessonId] as Map<String, dynamic>?;
    if (entry == null) {
      return LectureAnalytics(lessonId: lessonId);
    }
    return LectureAnalytics.fromJson(entry);
  }

  Future<void> saveAnalytics(LectureAnalytics analytics) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> all = _readAll(prefs);
    all[analytics.lessonId] = analytics.toJson();
    await prefs.setString(_analyticsKey, jsonEncode(all));
  }

  Map<String, dynamic> _readAll(SharedPreferences prefs) {
    final String? raw = prefs.getString(_analyticsKey);
    if (raw == null) return <String, dynamic>{};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
