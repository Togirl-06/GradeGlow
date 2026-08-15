import '../models/virtual_lecture.dart';
import 'diagram_asset_registry.dart';
import 'lecture_classroom_pedagogy.dart';
import 'virtual_lecture_interactive_builder.dart';
import 'virtual_lecture_topic_profile.dart';

/// Builds topic-accurate offline lectures for any catalog lesson.
abstract final class VirtualLectureTopicLecture {
  static List<LectureSegment> segments({
    required VirtualLectureTopicProfile profile,
    required LectureMode mode,
  }) {
    final List<LectureSegment> theory = _theorySegments(profile);
    final List<LectureSegment> examples =
        (mode == LectureMode.practice || mode == LectureMode.exam)
            ? VirtualLectureInteractiveBuilder.examplesForMode(
                profile.topic,
                mode,
                courseId: profile.courseId,
                category: profile.category,
              )
            : const <LectureSegment>[];
    final List<LectureSegment> closing = _closingSegments(profile);

    if (mode == LectureMode.review) {
      final LectureSegment define = theory.firstWhere(
        (LectureSegment s) =>
            s.caption.startsWith('Explain') || s.caption.startsWith('Define'),
        orElse: () => theory.length > 1 ? theory[1] : theory.first,
      );
      final LectureSegment example = theory.firstWhere(
        (LectureSegment s) => s.phase == LecturePhase.guidedExamples,
        orElse: () => define,
      );
      return <LectureSegment>[
        theory.first,
        define,
        example,
        ...examples.take(1),
        closing[0],
      ];
    }
    if (mode == LectureMode.exam) {
      return <LectureSegment>[
        theory[0],
        ...examples.skip(2),
        closing[0],
      ];
    }
    if (mode == LectureMode.practice) {
      return <LectureSegment>[
        theory[0],
        ...examples,
        closing[0],
        closing[1],
      ];
    }

    return <LectureSegment>[
      ...theory,
      ...examples,
      closing[0],
      closing[1],
      closing[2],
    ];
  }

  static List<String> objectives(VirtualLectureTopicProfile profile) =>
      profile.objectives;

  static LectureSmartNotes notes(VirtualLectureTopicProfile profile) {
    return LectureSmartNotes(
      definitions: profile.definitions,
      formulas: profile.formulas,
      examples: profile.exampleIdeas,
      commonMistakes: profile.commonMistakes,
      tips: profile.tips,
    );
  }

  static LectureSummary summary(VirtualLectureTopicProfile profile) {
    return LectureSummary(
      learned: profile.summaryLearned,
      keyFormulas: profile.formulas,
      applications: profile.summaryApplications,
      reviewTopics: profile.summaryReview,
      homeworkRecommendation:
          'Homework: (1) Complete the lesson quiz. (2) Rework three ${profile.topic} problems closed-book, '
          'easy → hard. (3) Write five sentences connecting ${profile.topic} to a real job or daily situation. '
          '(4) Skim one extra reading or notes section on ${profile.topic}, then open the next lesson.',
    );
  }

  static List<LectureSegment> _theorySegments(VirtualLectureTopicProfile p) {
    final bool clinical = _isClinical(p);
    if (clinical) return _clinicalTheorySegments(p);
    return LectureClassroomPedagogy.build(p);
  }

  /// Clinical / nursing path — professor-prepared pathway slides + chart challenge.
  static List<LectureSegment> _clinicalTheorySegments(VirtualLectureTopicProfile p) {
    final bool preoperative = p.topic.toLowerCase().contains('preop') ||
        p.topic.toLowerCase().contains('pre-op') ||
        p.topic.toLowerCase().contains('preoperative') ||
        p.topic.toLowerCase().contains('surgical') ||
        p.topic.toLowerCase().contains('perioperative');
    final String title = preoperative
        ? 'PREOPERATIVE NURSING CARE'
        : p.topic.toUpperCase();
    final String subtitle = preoperative
        ? 'Preparing the Patient Before Surgery'
        : 'Bedside application of ${p.topic}';
    final List<String> pathway = preoperative
        ? const <String>[
            'Assessment',
            'Preparation',
            'Safety check',
            'Operating room',
          ]
        : <String>[
            'Assess',
            'Intervene',
            'Reassess',
            'Document / hand-off',
          ];
    final List<String> keyConcepts = preoperative
        ? const <String>[
            'Patient assessment',
            'Medical history',
            'Allergies',
            'Vital signs',
            'Medication review',
            'Informed consent',
            'Patient education',
            'Surgical-site verification',
          ]
        : (p.conceptLines.isNotEmpty
            ? p.conceptLines.take(8).toList()
            : p.objectives.take(6).toList());

    return <LectureSegment>[
      _seg(
        phase: LecturePhase.introduction,
        speech:
            'Before a patient enters the operating room, the nurse assesses the patient, verifies identity and consent, reviews allergies and meds, and confirms the surgical site. '
            'Each step exists to catch a risk while there is still time to stop.',
        caption: '$title — pathway',
        title: title,
        subtitle: subtitle,
        slideType: LectureSlideType.concept,
        processSteps: pathway,
        keyPoints: keyConcepts.take(4).toList(),
        diagramId: 'human_organs',
        diagramQuery: '$title human organs preoperative nursing anatomy',
        seconds: 40,
        slideNotes: _notesFor(
          understand: preoperative
              ? 'Preoperative nursing prepares the patient physically and psychologically for surgery.'
              : '${p.topic} is applied at the bedside through assessment, action, and reassessment.',
          concepts: keyConcepts,
          insight:
              'The nurse is not simply checking boxes. Each assessment helps identify potential risks before the patient reaches the operating room.',
          remember: preoperative
              ? 'Preoperative assessment is about identifying and reducing risks before surgery.'
              : 'Assessment finds risk; intervention reduces it; reassessment confirms safety.',
          exam: preoperative
              ? 'Know the difference between preoperative, intraoperative, and postoperative nursing care.'
              : 'Be ready to prioritize assessment findings for ${p.topic}.',
          study: pathway.map((String e) => '• $e').join('\n'),
          questions: <String>[
            preoperative
                ? 'What factors are important in preoperative assessment for a diabetic patient?'
                : 'What is the first nursing priority for ${p.topic}?',
          ],
          vocab: preoperative
              ? const <String>[
                  'Preoperative',
                  'Intraoperative',
                  'Postoperative',
                  'Informed consent',
                  'Surgical-site verification',
                ]
              : p.definitions.take(5).toList(),
        ),
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Definition in clinical language — not a slogan. ${_firstSentence(p.conceptSpeech)} '
            'Hold that meaning while we look at concrete findings next.',
        caption: 'Define — ${p.topic}',
        title: 'DEFINITION',
        subtitle: p.topic,
        slideType: LectureSlideType.concept,
        keyPoints: keyConcepts.take(5).toList(),
        lines: keyConcepts.take(5).toList(),
        seconds: 60,
        slideNotes: _notesFor(
          understand: _firstSentence(p.conceptSpeech),
          concepts: keyConcepts.take(5).toList(),
          insight: 'Clinical definitions drive what you check first at the bedside.',
          remember: keyConcepts.isNotEmpty ? keyConcepts.first : p.topic,
          exam: 'Define ${p.topic} the way a charge nurse would expect.',
          study: keyConcepts.take(5).map((String e) => '• $e').join('\n'),
          questions: <String>['Define ${p.topic} in one clinical sentence.'],
          vocab: keyConcepts.take(5).toList(),
        ),
      ),
      _seg(
        phase: LecturePhase.visualDemonstration,
        speech:
            'Look at the anatomical plate. I am explaining structures tied to ${p.topic}, not reading the title. '
            'Identify the systems that change risk before a procedure, then connect each to your assessment.',
        caption: 'Diagram — ${p.topic}',
        title: title,
        subtitle: 'Medical illustration — explain each region',
        slideType: LectureSlideType.diagram,
        diagramId: _diagramIdForTopic(p.topic, p.course) ?? 'human_organs',
        diagramQuery: '${p.topic} labeled anatomy real medical illustration',
        keyPoints: const <String>[
          'Locate — structures that matter for risk',
          'Relate — structure to assessment finding',
          'Explain — why it changes the care plan',
        ],
        seconds: 70,
        slideNotes: _notesFor(
          understand: 'Use the figure to connect anatomy to nursing priorities for ${p.topic}.',
          concepts: keyConcepts.take(6).toList(),
          insight: 'If you can point and explain, you understand — not just memorize.',
          remember: 'Anatomy → finding → action.',
          exam: 'Link a labeled structure to a preoperative risk.',
          study: 'Study the plate; explain three regions out loud.',
          questions: <String>['Which structure on the plate most affects surgical risk for this topic?'],
          vocab: const <String>['Assessment', 'Risk', 'Anatomy'],
        ),
      ),
      _seg(
        phase: LecturePhase.studentParticipation,
        speech:
            'Look at this patient\'s preoperative assessment. Identify anything that could create a surgical risk. '
            'One chance — twenty seconds. Choose the highest-priority finding, then I will explain why.',
        caption: 'Clinical challenge',
        title: 'PATIENT CHART — RISK FINDING',
        subtitle: 'Select the highest-priority concern',
        slideType: LectureSlideType.challenge,
        dataColumns: const <String>['Field', 'Value'],
        dataRows: const <List<String>>[
          <String>['Allergy', 'Penicillin — anaphylaxis'],
          <String>['BP', '168/98 mmHg'],
          <String>['Medication', 'Metformin; aspirin'],
          <String>['History', 'Diabetes mellitus type 2'],
        ],
        keyPoints: const <String>[
          'Allergy',
          'Abnormal vital sign',
          'Medication',
          'Medical history',
        ],
        seconds: 55,
        knowledgeCheck: const LectureKnowledgeCheck(
          prompt:
              'Which finding creates the most immediate preoperative / procedural risk?',
          kind: KnowledgeCheckKind.multipleChoice,
          options: <String>[
            'Allergy',
            'Abnormal vital sign',
            'Medication',
            'Medical history',
          ],
          correctIndex: 0,
          explanation:
              'A documented anaphylaxis allergy must be verified and communicated before any medication or procedure pathway continues.',
          timeLimitSeconds: 20,
        ),
        slideNotes: _notesFor(
          understand: 'Chart review is an active safety skill, not busywork.',
          concepts: const <String>[
            'Allergy',
            'Abnormal vital sign',
            'Medication',
            'Medical history',
          ],
          insight: 'Anaphylaxis history outranks most other findings for immediate communication.',
          remember: 'Always scan allergies first.',
          exam: 'Prioritize allergy, airway, and consent risks on chart questions.',
          study: 'Allergy → vitals → meds → history.',
          questions: <String>[
            'What is the first chart item you verify before surgery?',
          ],
          vocab: const <String>['Anaphylaxis', 'Consent', 'Risk'],
        ),
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            '${_firstSentence(p.whySpeech)} '
            'That is why ${p.course} drills ${p.topic} — weak habits here create preventable harm.',
        caption: 'Why it matters',
        title: 'WHY IT MATTERS',
        subtitle: p.topic,
        slideType: LectureSlideType.summary,
        keyPoints: _whySlideNotes(p),
        lines: _whySlideNotes(p),
        seconds: 50,
        slideNotes: _notesFor(
          understand: _firstSentence(p.whySpeech),
          concepts: _whySlideNotes(p),
          insight: 'Safety culture starts with disciplined preoperative habits.',
          remember: _whySlideNotes(p).isNotEmpty ? _whySlideNotes(p).first : p.topic,
          exam: preoperative
              ? 'Compare preoperative vs intraoperative vs postoperative priorities.'
              : 'Explain why ${p.topic} matters for patient safety.',
          study: _whySlideNotes(p).map((String e) => '• $e').join('\n'),
          questions: <String>['Why does weak ${p.topic} create preventable harm?'],
          vocab: const <String>['Patient safety', 'Hand-off'],
        ),
      ),
      LectureSegment(
        phase: LecturePhase.knowledgeCheck,
        professorSpeech:
            'Checkpoint — one chance, twenty seconds. Apply what we defined and practiced.',
        caption: 'Checkpoint — ${p.topic}',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'CHECK — ${p.topic.toUpperCase()}',
          subtitle: 'One chance · 20 seconds',
          slideType: LectureSlideType.question,
          keyPoints: keyConcepts.take(3).toList(),
          lines: keyConcepts.take(3).toList(),
        ),
        durationSeconds: 45,
        knowledgeCheck: LectureKnowledgeCheck(
          prompt: p.checkPrompt,
          kind: KnowledgeCheckKind.multipleChoice,
          options: p.checkOptions,
          correctIndex: p.checkCorrectIndex,
          explanation: p.checkExplanation,
          timeLimitSeconds: 20,
        ),
        slideNotes: _notesFor(
          understand: p.checkExplanation,
          concepts: keyConcepts.take(4).toList(),
          insight: p.checkExplanation,
          remember: keyConcepts.isNotEmpty ? keyConcepts.first : p.topic,
          exam: p.checkPrompt,
          study: p.checkExplanation,
          questions: <String>[p.checkPrompt],
          vocab: keyConcepts.take(4).toList(),
        ),
      ),
    ];
  }

  static LectureSlideNotes _notesFor({
    required String understand,
    required List<String> concepts,
    required String insight,
    required String remember,
    required String exam,
    required String study,
    required List<String> questions,
    required List<String> vocab,
  }) {
    return LectureSlideNotes(
      understand: understand,
      keyConcepts: concepts,
      professorInsight: insight,
      remember: remember,
      examTip: exam,
      studyNotes: study,
      questions: questions,
      vocabulary: vocab,
    );
  }

  static List<LectureSegment> _closingSegments(VirtualLectureTopicProfile p) {
    return <LectureSegment>[
      LectureSegment(
        phase: LecturePhase.lessonSummary,
        professorSpeech:
            'Summary of ${p.topic}: we covered why it matters, its history, definitions, visuals, methods, '
            'mistakes, real-world uses, comparison to earlier lessons, questions, and interactive practice. '
            'You do not need a \$50,000 tuition bill to master this — keep showing up to lecture.',
        caption: 'Summary — ${p.topic}',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Summary — ${p.topic}',
          lines: p.summaryLearned,
        ),
        durationSeconds: 110,
      ),
      LectureSegment(
        phase: LecturePhase.homeworkRecommendation,
        professorSpeech:
            'Homework for ${p.topic}: finish the lesson quiz; rework three problems closed-book from easy to hard; '
            'write a short real-world connection; then open the next lesson. '
            'Use Raise Hand anytime you want me to reteach a step on the board.',
        caption: 'Homework & next steps',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Homework',
          lines: <String>[
            'Lesson quiz',
            '3 closed-book problems (easy → hard)',
            'Real-world write-up',
            'Next lesson + Raise Hand if stuck',
          ],
        ),
        durationSeconds: 100,
      ),
      LectureSegment(
        phase: LecturePhase.homeworkRecommendation,
        professorSpeech:
            'Additional reading for ${p.topic} in ${p.course}: re-read your notes end-to-end, '
            'review every definition and formula we wrote, and find one reputable textbook chapter, article, '
            'or documentation page on ${p.topic}. Bring one question to the next lecture.',
        caption: 'Additional reading',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Reading list',
          lines: <String>[
            'Re-read lesson notes',
            'Definitions & formulas',
            'One external chapter/article on ${p.topic}',
            'Bring one question next time',
          ],
        ),
        durationSeconds: 95,
      ),
    ];
  }

  static List<String> _whySlideNotes(VirtualLectureTopicProfile p) {
    if (_isClinical(p)) {
      final String t = p.topic.toLowerCase();
      if (t.contains('heart') || t.contains('cardiac') || t.contains('chf')) {
        return <String>[
          'Fluid overload and low perfusion escalate fast',
          'Early cues: dyspnea, crackles, edema, fatigue',
          'Strong HF care shows up in every hand-off',
        ];
      }
      return <String>[
        'Patient safety depends on ${p.topic}',
        'Weak habits create preventable harm',
        'Strong ${p.topic} shows up in every hand-off',
      ];
    }
    return <String>[
      'Why ${p.topic} shows up in ${p.course}',
      'What breaks if you skip it',
      'Where you will use it next',
    ];
  }

  static bool _isClinical(VirtualLectureTopicProfile p) {
    final String t = p.topic.toLowerCase();
    return t.contains('preoperative') ||
        t.contains('postoperative') ||
        t.contains('perioperative') ||
        t.contains('pre-op') ||
        t.contains('post-op');
  }

  static LectureSegment _seg({
    required LecturePhase phase,
    required String speech,
    required String caption,
    required String title,
    String? subtitle,
    LectureSlideType slideType = LectureSlideType.concept,
    List<String> lines = const <String>[],
    List<String> keyPoints = const <String>[],
    List<String> processSteps = const <String>[],
    List<String> dataColumns = const <String>[],
    List<List<String>> dataRows = const <List<String>>[],
    String? equation,
    String? graph,
    String? diagramId,
    String? diagramQuery,
    int seconds = 80,
    LectureKnowledgeCheck? knowledgeCheck,
    LectureSlideNotes? slideNotes,
  }) {
    final String? resolvedDiagramId = diagramId ??
        (graph != null &&
                DiagramAssetRegistry.bundledByDiagramId.containsKey(graph)
            ? graph
            : null);
    final bool bundledDiagram = resolvedDiagramId != null;
    final WhiteboardKind kind = bundledDiagram
        ? WhiteboardKind.diagram
        : graph != null
            ? WhiteboardKind.graph
            : equation != null
                ? WhiteboardKind.equation
                : dataRows.isNotEmpty
                    ? WhiteboardKind.table
                    : (resolvedDiagramId != null ||
                            slideType == LectureSlideType.diagram ||
                            slideType == LectureSlideType.clinicalCase ||
                            slideType == LectureSlideType.label)
                        ? WhiteboardKind.diagram
                        : WhiteboardKind.text;

    final List<String> bullets = keyPoints.isNotEmpty ? keyPoints : lines;
    final String? autoId =
        resolvedDiagramId ?? _diagramIdForTopic(title, subtitle ?? caption);
    final bool wantsPlate = autoId != null ||
        slideType == LectureSlideType.diagram ||
        slideType == LectureSlideType.clinicalCase ||
        slideType == LectureSlideType.label;

    return LectureSegment(
      phase: phase,
      professorSpeech: speech,
      caption: caption,
      whiteboard: LectureWhiteboardFrame(
        kind: kind,
        title: title,
        subtitle: subtitle,
        slideType: slideType,
        lines: lines,
        keyPoints: bullets,
        processSteps: processSteps,
        dataColumns: dataColumns,
        dataRows: dataRows,
        equation: equation,
        graphFunction: bundledDiagram ? 'linear' : (graph ?? 'linear'),
        diagramId: autoId,
        diagramQuery: diagramQuery ??
            (wantsPlate
                ? '$title real anatomy organ photograph labeled plate'
                : null),
      ),
      durationSeconds: seconds,
      knowledgeCheck: knowledgeCheck,
      slideNotes: slideNotes,
    );
  }

  static String _firstSentence(String text) {
    final String plain = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (plain.isEmpty) return '';
    final int cut = plain.indexOf(RegExp(r'[.!?]'));
    if (cut < 0 || cut > 140) {
      return plain.length <= 140 ? plain : '${plain.substring(0, 137).trimRight()}…';
    }
    return plain.substring(0, cut + 1).trim();
  }

  static String? _diagramIdForTopic(String title, String subtitle) {
    final String t = '$title $subtitle'.toLowerCase();
    if (t.contains('skeleton') || t.contains('bone') || t.contains('skeletal')) {
      return 'skeleton';
    }
    if (t.contains('heart') || t.contains('cardiac') || t.contains('cardio')) {
      return 'heart_detail';
    }
    if (t.contains('lung') || t.contains('respir') || t.contains('pulmonary')) {
      return 'respiratory';
    }
    if (t.contains('neuron') || t.contains('nerve') || t.contains('nervous')) {
      return 'neuron';
    }
    if (t.contains('cell')) return 'animal_cell';
    if (t.contains('organ') ||
        t.contains('preoperative') ||
        t.contains('postoperative') ||
        t.contains('nurs') ||
        t.contains('patient') ||
        t.contains('anatomy') ||
        t.contains('body')) {
      return 'human_organs';
    }
    return null;
  }
}
