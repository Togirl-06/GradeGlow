// Virtual University AI Lecture — script, playback & analytics models.

import 'package:flutter/material.dart';

/// How the interactive classroom runs — whiteboard-first, professor guides from the corner.
enum LectureMode {
  comprehensive(
    'Full Lecture',
    'Complete university lecture (1 hour+) — intro, history, theory, visuals, examples, Q&A, exercises, homework, reading',
    Icons.school_outlined,
    52,
    0.7,
    '60–75 min',
  ),
  concept(
    'Concept Mode',
    'Focused theory and intuition — still a full university lecture, not a chatbot answer',
    Icons.auto_stories_outlined,
    36,
    0.75,
    '45–60 min',
  ),
  practice(
    'Practice Mode',
    'You solve problems; the professor guides each step on the whiteboard',
    Icons.edit_note_outlined,
    18,
    0.9,
    '~35 min',
  ),
  exam(
    'Exam Mode',
    'University-style challenges — harder checks, less hand-holding',
    Icons.assignment_outlined,
    14,
    1.0,
    '~25 min',
  ),
  review(
    'Review Mode',
    'Fast whiteboard recap of weak areas and key ideas',
    Icons.replay_outlined,
    10,
    1.1,
    '≤20 min',
  ),
  deepLearning(
    'Deep Learning Mode',
    'Exhaustive proofs, advanced visuals, and full interactive examples',
    Icons.menu_book_outlined,
    64,
    0.65,
    '75–90 min',
  );

  const LectureMode(
    this.label,
    this.subtitle,
    this.icon,
    this.targetSegments,
    this.paceFactor,
    this.durationLabel,
  );

  final String label;
  final String subtitle;
  final IconData icon;
  final int targetSegments;
  /// Multiplier on estimated minutes (lower = longer per segment).
  final double paceFactor;
  final String durationLabel;

  /// Parses stored analytics / AI mode names (includes legacy values).
  static LectureMode fromName(String? name) {
    return switch (name) {
      'quickReview' => LectureMode.review,
      'standard' => LectureMode.concept,
      'deepDive' => LectureMode.deepLearning,
      null || '' => LectureMode.comprehensive,
      _ => LectureMode.values.firstWhere(
          (LectureMode m) => m.name == name,
          orElse: () => LectureMode.comprehensive,
        ),
    };
  }

  /// Full textbook-style university lecture (default for every lesson).
  bool get isFullLecture =>
      this == LectureMode.comprehensive ||
      this == LectureMode.concept ||
      this == LectureMode.deepLearning;

  bool get isGuidedPractice => this == LectureMode.practice || this == LectureMode.exam;
}

enum LecturePhase {
  introduction('Introduction'),
  objectives('Learning Objectives'),
  conceptExplanation('Concept Explanation'),
  visualDemonstration('Visual Demonstration'),
  guidedExamples('Guided Examples'),
  studentParticipation('Student Participation'),
  knowledgeCheck('Knowledge Check'),
  practiceProblems('Practice Problems'),
  lessonSummary('Lesson Summary'),
  homeworkRecommendation('Homework Recommendation');

  const LecturePhase(this.label);

  final String label;
}

enum WhiteboardKind {
  text,
  equation,
  graph,
  geometry,
  vector,
  matrix,
  table,
  probability,
  workedProblem,
  /// Real educational illustration (bundled asset or fetched from the web).
  diagram,
}

/// One step in a worked example — revealed on the whiteboard as the professor solves it.
class LectureProblemStep {
  const LectureProblemStep({
    required this.title,
    required this.work,
    this.note,
  });

  final String title;
  final String work;
  final String? note;

  factory LectureProblemStep.fromJson(Map<String, dynamic> json) {
    return LectureProblemStep(
      title: json['title'] as String? ?? '',
      work: json['work'] as String? ?? json['content'] as String? ?? '',
      note: json['note'] as String?,
    );
  }
}

enum KnowledgeCheckKind {
  multipleChoice,
  trueFalse,
  fillBlank,
  predictStep,
  graphIdentify,
}

class LectureWhiteboardFrame {
  const LectureWhiteboardFrame({
    required this.kind,
    required this.title,
    this.lines = const <String>[],
    this.equation,
    this.graphFunction = 'quadratic',
    this.highlight,
    this.graphApproachX,
    this.graphLimitY,
    this.problemStatement,
    this.solutionSteps = const <LectureProblemStep>[],
    this.imageUrl,
    this.diagramQuery,
    this.diagramId,
  });

  final WhiteboardKind kind;
  final String title;
  final List<String> lines;
  final String? equation;
  final String graphFunction;
  final String? highlight;
  /// Animated approach point on graphs (e.g. x → 2).
  final double? graphApproachX;
  final double? graphLimitY;
  /// Problem posed before step-by-step solution (guided examples).
  final String? problemStatement;
  final List<LectureProblemStep> solutionSteps;
  /// Direct https image URL for a real diagram (preferred).
  final String? imageUrl;
  /// Search terms to fetch an educational diagram from the web.
  final String? diagramQuery;
  /// Bundled / CDN diagram id (e.g. animal_cell, atom, dna).
  final String? diagramId;

  bool get isWorkedProblem =>
      kind == WhiteboardKind.workedProblem ||
      (problemStatement != null && solutionSteps.isNotEmpty);

  bool get wantsRealDiagram =>
      kind == WhiteboardKind.diagram ||
      kind == WhiteboardKind.graph ||
      kind == WhiteboardKind.geometry ||
      (imageUrl != null && imageUrl!.trim().isNotEmpty) ||
      (diagramQuery != null && diagramQuery!.trim().isNotEmpty) ||
      (diagramId != null && diagramId!.trim().isNotEmpty);

  factory LectureWhiteboardFrame.fromJson(Map<String, dynamic> json) {
    final String kindStr = (json['kind'] as String? ?? 'text').toLowerCase();
    final List<LectureProblemStep> steps = (json['solutionSteps'] as List<dynamic>?)
            ?.map((dynamic e) => LectureProblemStep.fromJson(e as Map<String, dynamic>))
            .toList() ??
        (json['steps'] as List<dynamic>?)
            ?.map((dynamic e) => LectureProblemStep.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const <LectureProblemStep>[];

    WhiteboardKind kind = WhiteboardKind.values.firstWhere(
      (WhiteboardKind k) => k.name == kindStr,
      orElse: () => WhiteboardKind.text,
    );
    // Prefer real illustrations over shape sketches for visual kinds.
    if (kind == WhiteboardKind.graph || kind == WhiteboardKind.geometry) {
      kind = WhiteboardKind.diagram;
    }

    return LectureWhiteboardFrame(
      kind: kind,
      title: json['title'] as String? ?? '',
      lines: (json['lines'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      equation: json['equation'] as String?,
      graphFunction: json['graphFunction'] as String? ?? 'quadratic',
      highlight: json['highlight'] as String?,
      graphApproachX: (json['graphApproachX'] as num?)?.toDouble(),
      graphLimitY: (json['graphLimitY'] as num?)?.toDouble(),
      problemStatement: json['problemStatement'] as String? ?? json['problem'] as String?,
      solutionSteps: steps,
      imageUrl: json['imageUrl'] as String? ?? json['image'] as String?,
      diagramQuery: json['diagramQuery'] as String? ?? json['searchQuery'] as String?,
      diagramId: json['diagramId'] as String?,
    );
  }
}

class LectureKnowledgeCheck {
  const LectureKnowledgeCheck({
    required this.prompt,
    required this.kind,
    this.options = const <String>[],
    this.correctIndex = 0,
    this.correctAnswer,
    this.explanation = '',
    this.requireCorrect = false,
  });

  final String prompt;
  final KnowledgeCheckKind kind;
  final List<String> options;
  final int correctIndex;
  final String? correctAnswer;
  final String explanation;
  /// When true, the lecture waits until the student picks the right answer.
  final bool requireCorrect;

  static LectureKnowledgeCheck? tryParse(Map<String, dynamic>? json) {
    if (json == null) return null;
    final String kindStr = (json['kind'] as String? ?? 'multipleChoice').toLowerCase();
    KnowledgeCheckKind kind = KnowledgeCheckKind.multipleChoice;
    for (final KnowledgeCheckKind k in KnowledgeCheckKind.values) {
      if (k.name.toLowerCase() == kindStr.replaceAll('_', '')) {
        kind = k;
        break;
      }
    }
    return LectureKnowledgeCheck(
      prompt: json['prompt'] as String? ?? '',
      kind: kind,
      options: (json['options'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
      correctAnswer: json['correctAnswer'] as String?,
      explanation: json['explanation'] as String? ?? '',
      requireCorrect: json['requireCorrect'] as bool? ?? false,
    );
  }

  factory LectureKnowledgeCheck.fromJson(Map<String, dynamic> json) {
    return tryParse(json)!;
  }
}

/// One interactive tutoring moment — teach, animate, then optionally ask the student.
class LectureInteractiveBeat {
  const LectureInteractiveBeat({
    required this.professorSpeech,
    required this.whiteboard,
    this.caption,
    this.studentChoice,
    this.durationSeconds = 40,
  });

  final String professorSpeech;
  final LectureWhiteboardFrame whiteboard;
  final String? caption;
  final LectureKnowledgeCheck? studentChoice;
  final int durationSeconds;

  factory LectureInteractiveBeat.fromJson(Map<String, dynamic> json) {
    return LectureInteractiveBeat(
      professorSpeech: json['professorSpeech'] as String? ?? '',
      caption: json['caption'] as String?,
      whiteboard: LectureWhiteboardFrame.fromJson(
        json['whiteboard'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      studentChoice: LectureKnowledgeCheck.tryParse(
        json['studentChoice'] as Map<String, dynamic>? ??
            json['knowledgeCheck'] as Map<String, dynamic>?,
      ),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 45,
    );
  }
}

class LectureSegment {
  const LectureSegment({
    required this.phase,
    required this.professorSpeech,
    required this.caption,
    required this.whiteboard,
    this.knowledgeCheck,
    this.durationSeconds = 45,
    this.beats = const <LectureInteractiveBeat>[],
  });

  final LecturePhase phase;
  final String professorSpeech;
  final String caption;
  final LectureWhiteboardFrame whiteboard;
  final LectureKnowledgeCheck? knowledgeCheck;
  final int durationSeconds;
  /// Step-by-step interactive tutoring (choices pause until answered).
  final List<LectureInteractiveBeat> beats;

  bool get isInteractive => beats.isNotEmpty;

  LectureSegment viewAtBeat(int beatIndex) {
    if (beats.isEmpty) return this;
    final int idx = beatIndex.clamp(0, beats.length - 1);
    final LectureInteractiveBeat beat = beats[idx];
    return LectureSegment(
      phase: phase,
      professorSpeech: beat.professorSpeech,
      caption: beat.caption ?? caption,
      whiteboard: beat.whiteboard,
      knowledgeCheck: beat.studentChoice,
      durationSeconds: beat.durationSeconds,
    );
  }

  factory LectureSegment.fromJson(Map<String, dynamic> json) {
    final String phaseStr = json['phase'] as String? ?? 'introduction';
    return LectureSegment(
      phase: LecturePhase.values.firstWhere(
        (LecturePhase p) => p.name == phaseStr,
        orElse: () => LecturePhase.conceptExplanation,
      ),
      professorSpeech: json['professorSpeech'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      whiteboard: LectureWhiteboardFrame.fromJson(
        json['whiteboard'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      knowledgeCheck: LectureKnowledgeCheck.tryParse(
        json['knowledgeCheck'] as Map<String, dynamic>?,
      ),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 90,
      beats: _parseBeats(json['beats']),
    );
  }

  static List<LectureInteractiveBeat> _parseBeats(dynamic raw) {
    if (raw is! List<dynamic>) return const <LectureInteractiveBeat>[];
    final List<LectureInteractiveBeat> beats = <LectureInteractiveBeat>[];
    for (final dynamic entry in raw) {
      if (entry is! Map) continue;
      try {
        beats.add(LectureInteractiveBeat.fromJson(Map<String, dynamic>.from(entry)));
      } catch (_) {
        // Skip malformed beats.
      }
    }
    return beats;
  }

  LectureSegment copyWith({
    LecturePhase? phase,
    String? professorSpeech,
    String? caption,
    LectureWhiteboardFrame? whiteboard,
    LectureKnowledgeCheck? knowledgeCheck,
    int? durationSeconds,
    List<LectureInteractiveBeat>? beats,
  }) {
    return LectureSegment(
      phase: phase ?? this.phase,
      professorSpeech: professorSpeech ?? this.professorSpeech,
      caption: caption ?? this.caption,
      whiteboard: whiteboard ?? this.whiteboard,
      knowledgeCheck: knowledgeCheck ?? this.knowledgeCheck,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      beats: beats ?? this.beats,
    );
  }
}

class LectureSmartNotes {
  const LectureSmartNotes({
    this.definitions = const <String>[],
    this.formulas = const <String>[],
    this.examples = const <String>[],
    this.commonMistakes = const <String>[],
    this.tips = const <String>[],
  });

  final List<String> definitions;
  final List<String> formulas;
  final List<String> examples;
  final List<String> commonMistakes;
  final List<String> tips;

  factory LectureSmartNotes.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LectureSmartNotes();
    List<String> list(String key) =>
        (json[key] as List<dynamic>?)?.map((dynamic e) => e.toString()).toList() ??
        const <String>[];
    return LectureSmartNotes(
      definitions: list('definitions'),
      formulas: list('formulas'),
      examples: list('examples'),
      commonMistakes: list('commonMistakes'),
      tips: list('tips'),
    );
  }
}

class LectureSummary {
  const LectureSummary({
    this.learned = const <String>[],
    this.keyFormulas = const <String>[],
    this.applications = const <String>[],
    this.reviewTopics = const <String>[],
    this.homeworkRecommendation = '',
  });

  final List<String> learned;
  final List<String> keyFormulas;
  final List<String> applications;
  final List<String> reviewTopics;
  final String homeworkRecommendation;

  factory LectureSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LectureSummary();
    List<String> list(String key) =>
        (json[key] as List<dynamic>?)?.map((dynamic e) => e.toString()).toList() ??
        const <String>[];
    return LectureSummary(
      learned: list('learned'),
      keyFormulas: list('keyFormulas'),
      applications: list('applications'),
      reviewTopics: list('reviewTopics'),
      homeworkRecommendation: json['homeworkRecommendation'] as String? ?? '',
    );
  }
}

class VirtualLectureScript {
  const VirtualLectureScript({
    required this.mode,
    required this.topic,
    required this.course,
    required this.module,
    required this.objectives,
    required this.estimatedMinutes,
    required this.segments,
    required this.notes,
    required this.summary,
  });

  final LectureMode mode;
  final String topic;
  final String course;
  final String module;
  final List<String> objectives;
  final int estimatedMinutes;
  final List<LectureSegment> segments;
  final LectureSmartNotes notes;
  final LectureSummary summary;

  VirtualLectureScript copyWith({
    LectureMode? mode,
    List<String>? objectives,
    int? estimatedMinutes,
    List<LectureSegment>? segments,
    LectureSmartNotes? notes,
    LectureSummary? summary,
  }) {
    return VirtualLectureScript(
      mode: mode ?? this.mode,
      topic: topic,
      course: course,
      module: module,
      objectives: objectives ?? this.objectives,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      segments: segments ?? this.segments,
      notes: notes ?? this.notes,
      summary: summary ?? this.summary,
    );
  }

  VirtualLectureScript insertSegmentAfter(int index, LectureSegment segment) {
    final List<LectureSegment> next = List<LectureSegment>.from(segments);
    final int at = (index + 1).clamp(0, next.length);
    next.insert(at, segment);
    return copyWith(segments: next);
  }

  factory VirtualLectureScript.fromJson(
    Map<String, dynamic> json, {
    required LectureMode mode,
    required String topic,
    required String course,
    required String module,
  }) {
    final List<dynamic> raw = json['segments'] as List<dynamic>? ?? const <dynamic>[];
    return VirtualLectureScript(
      mode: mode,
      topic: json['topic'] as String? ?? topic,
      course: json['course'] as String? ?? course,
      module: json['module'] as String? ?? module,
      objectives: (json['objectives'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 15,
      segments: _parseSegments(raw),
      notes: LectureSmartNotes.fromJson(json['notes'] as Map<String, dynamic>?),
      summary: LectureSummary.fromJson(json['summary'] as Map<String, dynamic>?),
    );
  }

  static List<LectureSegment> _parseSegments(List<dynamic> raw) {
    final List<LectureSegment> segments = <LectureSegment>[];
    for (final dynamic entry in raw) {
      if (entry is! Map) continue;
      try {
        final LectureSegment segment = LectureSegment.fromJson(
          Map<String, dynamic>.from(entry),
        );
        if (segment.professorSpeech.trim().isNotEmpty) {
          segments.add(segment);
        }
      } catch (_) {
        // Skip malformed AI segments.
      }
    }
    return segments;
  }
}

class LectureAnalytics {
  const LectureAnalytics({
    this.lessonId = '',
    this.mode = LectureMode.comprehensive,
    this.completed = false,
    this.timeSpentSeconds = 0,
    this.participationCount = 0,
    this.questionsAsked = 0,
    this.checksCorrect = 0,
    this.checksTotal = 0,
    this.confidenceScore = 0,
    this.weakAreas = const <String>[],
  });

  final String lessonId;
  final LectureMode mode;
  final bool completed;
  final int timeSpentSeconds;
  final int participationCount;
  final int questionsAsked;
  final int checksCorrect;
  final int checksTotal;
  final double confidenceScore;
  final List<String> weakAreas;

  double get checkAccuracy => checksTotal == 0 ? 0 : checksCorrect / checksTotal;

  LectureAnalytics copyWith({
    String? lessonId,
    LectureMode? mode,
    bool? completed,
    int? timeSpentSeconds,
    int? participationCount,
    int? questionsAsked,
    int? checksCorrect,
    int? checksTotal,
    double? confidenceScore,
    List<String>? weakAreas,
  }) {
    return LectureAnalytics(
      lessonId: lessonId ?? this.lessonId,
      mode: mode ?? this.mode,
      completed: completed ?? this.completed,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      participationCount: participationCount ?? this.participationCount,
      questionsAsked: questionsAsked ?? this.questionsAsked,
      checksCorrect: checksCorrect ?? this.checksCorrect,
      checksTotal: checksTotal ?? this.checksTotal,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      weakAreas: weakAreas ?? this.weakAreas,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'lessonId': lessonId,
        'mode': mode.name,
        'completed': completed,
        'timeSpentSeconds': timeSpentSeconds,
        'participationCount': participationCount,
        'questionsAsked': questionsAsked,
        'checksCorrect': checksCorrect,
        'checksTotal': checksTotal,
        'confidenceScore': confidenceScore,
        'weakAreas': weakAreas,
      };

  factory LectureAnalytics.fromJson(Map<String, dynamic> json) {
    final String modeName = json['mode'] as String? ?? 'concept';
    return LectureAnalytics(
      lessonId: json['lessonId'] as String? ?? '',
      mode: LectureMode.fromName(modeName),
      completed: json['completed'] as bool? ?? false,
      timeSpentSeconds: (json['timeSpentSeconds'] as num?)?.toInt() ?? 0,
      participationCount: (json['participationCount'] as num?)?.toInt() ?? 0,
      questionsAsked: (json['questionsAsked'] as num?)?.toInt() ?? 0,
      checksCorrect: (json['checksCorrect'] as num?)?.toInt() ?? 0,
      checksTotal: (json['checksTotal'] as num?)?.toInt() ?? 0,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0,
      weakAreas: (json['weakAreas'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }
}
