import '../models/virtual_lecture.dart';
import '../services/lecture_diagram_service.dart';
import 'lecture_diagram_progression.dart';
import 'lecture_diagram_teaching.dart';
import 'university_learning_engine.dart';
import 'virtual_lecture_topic_profile.dart';

/// Medical-school style classroom cycle for every AI Professor lecture.
///
/// explain → demo → ask → clinical/application → challenge → three takeaways → next
abstract final class LectureClassroomPedagogy {
  static List<LectureSegment> build(VirtualLectureTopicProfile p) {
    if (_isAnatomicalPositionTopic(p)) {
      return _anatomicalPositionClassroom(p);
    }

    final bool anatomy = _isAnatomyFamily(p);
    final String? diagramId = _diagramId(p);
    final List<LectureDiagramPart> parts = LectureDiagramTeaching.partsFor(
      diagramId: diagramId,
      topic: p.topic,
    );
    final List<List<LectureDiagramPart>> chunks =
        LectureDiagramTeaching.chunk(parts, size: anatomy ? 6 : 5);
    final bool judgeDemo = p.lessonId.contains('hackathon_demo');

    // First-place 90-sec path: skip long preamble — progressive teaching only.
    if (judgeDemo &&
        diagramId != null &&
        LectureDiagramProgression.supports(diagramId)) {
      return <LectureSegment>[
        _seg(
          phase: LecturePhase.introduction,
          speech:
              'Judges — other apps dump flashcards. Watch a university professor teach '
              'the skeleton progressively: organization first, then regions, then tap checks, '
              'then labels, then a clinical viva on a 3D model.',
          title: 'UNIVERSITY TEACHING',
          subtitle: 'Not a quiz app — progressive diagram pedagogy',
          caption: 'Judge opener',
          keyPoints: const <String>[
            'Progressive teaching',
            'Tap-to-find on the diagram',
            'Clinical reasoning next',
          ],
          seconds: 18,
        ),
        ...LectureDiagramProgression.buildProgressiveLecture(
          profile: p,
          diagramId: diagramId,
          anatomy: anatomy,
          judgeDemo: true,
        ),
        _seg(
          phase: LecturePhase.lessonSummary,
          speech:
              'Three takeaways: axial versus appendicular, radius is thumb-side, '
              'and clinical cases force the correct view before you diagnose. '
              'Now enter the Clinical Viva lab and prove it on the model.',
          title: 'BOARD TAKEAWAYS',
          subtitle: 'Enter the lab next',
          caption: 'Close',
          keyPoints: const <String>[
            'Axial vs appendicular',
            'Radius = thumb side',
            'Clinical viva grades WHY',
          ],
          seconds: 20,
        ),
      ];
    }

    return <LectureSegment>[
      _opener(p, anatomy: anatomy),
      _explain(p, anatomy: anatomy),
      if (diagramId != null && LectureDiagramProgression.supports(diagramId))
        ...LectureDiagramProgression.buildProgressiveLecture(
          profile: p,
          diagramId: diagramId,
          anatomy: anatomy,
        )
      else if (diagramId != null && chunks.isNotEmpty)
        ..._demoChunks(p, diagramId: diagramId, chunks: chunks, anatomy: anatomy)
      else if (diagramId != null)
        _simpleDemo(p, diagramId: diagramId),
      _checkpoint(p, anatomy: anatomy),
      _socraticProbe(p, anatomy: anatomy),
      _clinicalOrApplied(p, anatomy: anatomy),
      _challenge(p, anatomy: anatomy),
      _threeTakeaways(p, anatomy: anatomy),
      _nextClass(p, anatomy: anatomy),
    ];
  }

  static bool _isAnatomicalPositionTopic(VirtualLectureTopicProfile p) {
    final String t = '${p.topic} ${p.module}'.toLowerCase();
    return t.contains('anatomical position') ||
        t.contains('directional term') ||
        t.contains('anatomical language') ||
        t.contains('anatomical terminology') ||
        (t.contains('orientation') && t.contains('anatom'));
  }

  /// Flagship medical-school classroom script for intro anatomy language.
  static List<LectureSegment> _anatomicalPositionClassroom(
    VirtualLectureTopicProfile p,
  ) {
    return <LectureSegment>[
      _seg(
        phase: LecturePhase.introduction,
        speech:
            'Good morning, everyone. Today we\'re beginning one of the most important '
            'subjects in medicine: Human Anatomy. '
            'Before we talk about diseases, medications, or surgery, you need to understand '
            'the structure of the human body. '
            'So today, we\'re going to start with a simple question: '
            'How do we describe where something is in the human body?',
        title: 'HUMAN ANATOMY',
        subtitle: 'Classroom opener · structure before disease',
        caption: 'Opener — ${p.topic}',
        keyPoints: const <String>[
          'Structure before disease',
          'Standard language for location',
          'Why physicians need a shared map',
        ],
        seconds: 70,
      ),
      _seg(
        phase: LecturePhase.conceptExplanation,
        speech:
            'Everyone, look at the model in front of you. '
            'This is called the anatomical position. '
            'The person is standing upright, facing forward, with the arms at the sides '
            'and the palms facing forward. '
            'Why does this matter? '
            'Because physicians need a standardized way to describe the location of structures. '
            'Look carefully at the structure I\'m highlighting. Do not just memorize the pose — '
            'tell yourself why every description starts from this reference.',
        title: 'LESSON 1: ANATOMICAL POSITION',
        subtitle: 'Standard reference for every description',
        caption: 'Explain — anatomical position',
        slideType: LectureSlideType.diagram,
        diagramId: 'human_organs',
        keyPoints: const <String>[
          'Standing upright, facing forward',
          'Arms at sides, palms forward',
          'Shared reference for all clinicians',
        ],
        seconds: 95,
      ),
      LectureSegment(
        phase: LecturePhase.knowledgeCheck,
        professorSpeech:
            'If I tell you the heart is medial to the lungs, what does that mean? '
            'Choose carefully — use the definition, not a guess.',
        caption: 'Check — medial',
        whiteboard: const LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'STUDENT INTERACTION',
          subtitle: 'Choose your answer · one chance',
          slideType: LectureSlideType.question,
          keyPoints: <String>[
            'A. Closer to the head',
            'B. Closer to the midline',
            'C. Farther from the midline',
            'D. Closer to the skin',
          ],
        ),
        durationSeconds: 45,
        knowledgeCheck: const LectureKnowledgeCheck(
          prompt: 'If the heart is medial to the lungs, what does that mean?',
          kind: KnowledgeCheckKind.multipleChoice,
          options: <String>[
            'The heart is closer to the head',
            'The heart is closer to the midline',
            'The heart is farther from the midline',
            'The heart is closer to the skin',
          ],
          correctIndex: 1,
          explanation: 'Correct. Medial means closer to the body\'s midline.',
          timeLimitSeconds: 20,
        ),
      ),
      _seg(
        phase: LecturePhase.visualDemonstration,
        speech:
            'Now let\'s apply what we just learned. Look at the heart. '
            'The heart is located in the thoracic cavity, between the lungs, '
            'within a region called the mediastinum. '
            'Notice its relationship with the diaphragm. '
            'The heart is superior to the diaphragm. '
            'The diaphragm is inferior to the heart. '
            'Don\'t just memorize the names — tell me why that relationship matters '
            'when you listen to breath sounds or order imaging.',
        title: 'APPLY: THE HEART',
        subtitle: 'Thoracic cavity · mediastinum · diaphragm',
        caption: 'Demo — heart relationships',
        slideType: LectureSlideType.diagram,
        diagramId: 'heart_detail',
        keyPoints: const <String>[
          'Thoracic cavity, between the lungs',
          'Within the mediastinum',
          'Superior to the diaphragm',
          'Diaphragm inferior to the heart',
        ],
        seconds: 110,
      ),
      LectureSegment(
        phase: LecturePhase.knowledgeCheck,
        professorSpeech:
            'Your turn. Where is the heart relative to the lungs? '
            'Say it in directional language.',
        caption: 'Check — heart vs lungs',
        whiteboard: const LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'YOUR TURN',
          subtitle: 'Directional language',
          slideType: LectureSlideType.question,
          keyPoints: <String>[
            'Use medial / lateral / superior / inferior',
            'Relate heart to lungs',
          ],
        ),
        durationSeconds: 40,
        knowledgeCheck: const LectureKnowledgeCheck(
          prompt: 'Where is the heart relative to the lungs?',
          kind: KnowledgeCheckKind.multipleChoice,
          options: <String>[
            'Lateral to the lungs',
            'Medial to the lungs',
            'Inferior to the lungs',
            'Superficial to the lungs',
          ],
          correctIndex: 1,
          explanation: 'Exactly. The heart is medial to the lungs.',
          timeLimitSeconds: 20,
        ),
      ),
      _seg(
        phase: LecturePhase.guidedExamples,
        speech:
            'Now let\'s see why this matters in medicine. '
            'A 24-year-old patient comes into the emergency department after a chest injury. '
            'They complain of severe chest pain and difficulty breathing. '
            'You are the medical student. '
            'Based on your knowledge of thoracic anatomy, what structures could potentially be injured? '
            'Think carefully. What structures are located inside the thoracic cavity? '
            'You can examine heart, lungs, ribs, sternum, pleura, great vessels, and diaphragm. '
            'I will guide you — I will not dump the answer. Reason from the map we just built.',
        title: 'CLINICAL CASE',
        subtitle: 'ED chest injury · you are the medical student',
        caption: 'Clinical — thoracic trauma',
        slideType: LectureSlideType.clinicalCase,
        keyPoints: const <String>[
          'Heart',
          'Lungs',
          'Ribs · sternum',
          'Pleura · great vessels · diaphragm',
          'Reason from thoracic anatomy',
        ],
        seconds: 120,
      ),
      LectureSegment(
        phase: LecturePhase.studentParticipation,
        professorSpeech:
            'Mini challenge. Name one thoracic structure from today, say why it matters, '
            'and what you would expect if it failed. '
            'Good. Now imagine that structure is damaged — what happens to the patient?',
        caption: 'Challenge — clinical anatomy',
        whiteboard: const LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'MINI CHALLENGE',
          subtitle: 'Name · locate · predict',
          slideType: LectureSlideType.challenge,
          keyPoints: <String>[
            'Name the structure',
            'Say why it matters',
            'Predict failure consequences',
          ],
        ),
        durationSeconds: 70,
        knowledgeCheck: const LectureKnowledgeCheck(
          prompt: 'Which statement best matches clinical anatomy thinking?',
          kind: KnowledgeCheckKind.multipleChoice,
          options: <String>[
            'Memorize names only',
            'Name, locate, and predict clinical effect',
            'Skip diagrams and read summaries',
            'Wait for the disease lecture',
          ],
          correctIndex: 1,
          explanation:
              'Exactly. Name it, locate it, and predict what happens when it fails.',
          timeLimitSeconds: 20,
        ),
      ),
      _seg(
        phase: LecturePhase.lessonSummary,
        speech:
            'Before you leave, I want you to remember three things from today\'s lecture. '
            'First, anatomical position gives physicians a standardized reference. '
            'Second, directional terms allow us to describe relationships between structures. '
            'Third, anatomy isn\'t simply about memorizing structures. '
            'Anatomy is the foundation for understanding what happens to patients. '
            'Next class, we\'ll begin the skeletal system and examine the bones of the human body.',
        title: 'THREE TAKEAWAYS',
        subtitle: 'End of class',
        caption: 'Summary — anatomical language',
        slideType: LectureSlideType.summary,
        keyPoints: const <String>[
          'Anatomical position = standardized reference',
          'Directional terms describe relationships',
          'Anatomy is the foundation for patient care',
        ],
        seconds: 85,
      ),
      _seg(
        phase: LecturePhase.homeworkRecommendation,
        speech:
            'Your practical anatomy lab and clinical case follow this lecture. '
            'Review the labeled plate, then open the next lesson when you are ready. '
            'Class dismissed — go practice like a future clinician.',
        title: 'NEXT STEPS',
        subtitle: 'Practical lab · clinical case · skeletal system',
        caption: 'Next — skeletal system',
        keyPoints: const <String>[
          'Practical anatomy lab',
          'Clinical case practice',
          'Next: skeletal system',
        ],
        seconds: 45,
      ),
    ];
  }

  static bool _isAnatomyFamily(VirtualLectureTopicProfile p) {
    final String t = '${p.topic} ${p.module} ${p.lessonId}'.toLowerCase();
    return t.contains('anatom') ||
        t.contains('skeleton') ||
        t.contains('skeletal') ||
        t.contains('axial') ||
        t.contains('appendicular') ||
        t.contains('directional') ||
        t.contains('anatomical position') ||
        t.contains('heart') ||
        t.contains('bone') ||
        t.contains('organelle') ||
        t.contains('neuron');
  }

  static String? _diagramId(VirtualLectureTopicProfile p) {
    return LectureDiagramService.preferredDiagramId(
      topic: p.topic,
      courseId: p.courseId,
      lessonId: p.lessonId,
    );
  }

  static LectureSegment _opener(VirtualLectureTopicProfile p, {required bool anatomy}) {
    final String speech = p.conceptSpeech.trim().isNotEmpty
        ? p.conceptSpeech.trim()
        : (p.introSpeech.trim().isNotEmpty
            ? p.introSpeech.trim()
            : '${p.topic} is the idea we work through in ${p.course}.');
    return _seg(
      phase: LecturePhase.introduction,
      speech: speech,
      title: p.topic.toUpperCase(),
      subtitle: p.course,
      caption: 'Opener — ${p.topic}',
      keyPoints: p.conceptLines.take(4).isNotEmpty
          ? p.conceptLines.take(4).toList()
          : p.objectives.take(3).toList(),
      seconds: 55,
    );
  }

  static LectureSegment _explain(VirtualLectureTopicProfile p, {required bool anatomy}) {
    final String speech = anatomy
        ? '${_first(p.conceptSpeech)} ${p.definitions.isNotEmpty ? p.definitions.first : ''} '
            '${_first(p.whySpeech)}'
        : '${_first(p.conceptSpeech)} ${_second(p.conceptSpeech)} ${_first(p.methodSpeech)}';
    return _seg(
      phase: LecturePhase.conceptExplanation,
      speech: speech,
      title: 'TODAY\'S CORE IDEA',
      subtitle: p.topic,
      caption: 'Explain — ${p.topic}',
      keyPoints: p.conceptLines.take(6).isNotEmpty
          ? p.conceptLines.take(6).toList()
          : p.definitions.take(4).toList(),
      equation: p.mainEquation,
      seconds: 90,
    );
  }

  static List<LectureSegment> _demoChunks(
    VirtualLectureTopicProfile p, {
    required String diagramId,
    required List<List<LectureDiagramPart>> chunks,
    required bool anatomy,
  }) {
    return List<LectureSegment>.generate(chunks.length, (int i) {
      final List<LectureDiagramPart> chunk = chunks[i];
      final bool multi = chunks.length > 1;
      final String part = multi ? 'PART ${i + 1} OF ${chunks.length}' : 'DEMONSTRATION';
      return _seg(
        phase: LecturePhase.visualDemonstration,
        speech: LectureDiagramTeaching.speechForChunk(
          chunk: chunk,
          partIndex: i,
          partCount: chunks.length,
          diagramTitle: anatomy ? 'anatomy plate' : 'diagram',
        ),
        title: multi ? '${p.topic.toUpperCase()} — $part' : p.topic.toUpperCase(),
        subtitle: anatomy
            ? 'Name each structure and say why it matters'
            : 'Walk every labeled part',
        caption: 'Demo ${i + 1} — ${p.topic}',
        slideType: LectureSlideType.diagram,
        diagramId: diagramId,
        keyPoints: chunk.map((LectureDiagramPart e) => e.bullet).toList(),
        seconds: 70 + chunk.length * 16,
      );
    });
  }

  static LectureSegment _simpleDemo(
    VirtualLectureTopicProfile p, {
    required String diagramId,
  }) {
    return _seg(
      phase: LecturePhase.visualDemonstration,
      speech:
          'Look at the figure with me. ${_first(p.visualSpeech)} '
          'Point to the main structure, say its job, then connect it back to ${p.topic}.',
      title: p.topic.toUpperCase(),
      subtitle: 'Visual demonstration',
      caption: 'Demo — ${p.topic}',
      slideType: LectureSlideType.diagram,
      diagramId: diagramId,
      keyPoints: p.conceptLines.take(6).toList(),
      seconds: 95,
    );
  }

  static LectureSegment _priorKnowledge(
    VirtualLectureTopicProfile p, {
    required bool anatomy,
  }) {
    final UniversityProfessorStyle style =
        UniversityProfessorStyle.forSubject(_subjectId(p));
    final String priorTopic = anatomy
        ? 'anatomical position and directional terms'
        : 'the prerequisite idea behind ${p.topic}';
    return LectureSegment(
      phase: LecturePhase.studentParticipation,
      professorSpeech:
          'Before we continue, ${style.questionStyle} '
          'What do you remember about $priorTopic?',
      caption: 'Prior knowledge — ${p.topic}',
      whiteboard: const LectureWhiteboardFrame(
        kind: WhiteboardKind.text,
        title: 'PRIOR KNOWLEDGE CHECK',
        subtitle: 'Answer in your own words',
        slideType: LectureSlideType.question,
        keyPoints: <String>[
          'Recall what you already know',
          'Professor adapts if you are close or off track',
          'We review before the core lecture',
        ],
      ),
      durationSeconds: 50,
      knowledgeCheck: LectureKnowledgeCheck(
        prompt: 'What do you remember about $priorTopic?',
        kind: KnowledgeCheckKind.fillBlank,
        options: const <String>[],
        correctIndex: 0,
        explanation:
            'Good. If you were close, we continue. If not, we review the prerequisite first.',
        timeLimitSeconds: 30,
      ),
    );
  }

  static LectureSegment _socraticProbe(
    VirtualLectureTopicProfile p, {
    required bool anatomy,
  }) {
    final String question = anatomy
        ? 'What do you think would happen if this structure were damaged in a patient?'
        : 'What do you think would happen if we changed the key variable in ${p.topic}?';
    return LectureSegment(
      phase: LecturePhase.studentParticipation,
      professorSpeech:
          'Pause here — Socratic mode. $question '
          'Give me your prediction first; then we examine why it is or is not complete.',
      caption: 'Socratic — ${p.topic}',
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.text,
        title: 'SOCRATIC MODE',
        subtitle: 'Predict before I reveal',
        slideType: LectureSlideType.question,
        keyPoints: <String>[
          question,
          'Reason from evidence, not memorization',
          'Professor guides — does not dump the answer',
        ],
      ),
      durationSeconds: 55,
      knowledgeCheck: LectureKnowledgeCheck(
        prompt: question,
        kind: KnowledgeCheckKind.fillBlank,
        options: const <String>[],
        correctIndex: 0,
        explanation:
            'Good prediction. Now let\'s examine why that answer is or is not complete.',
        timeLimitSeconds: 35,
      ),
    );
  }

  static LectureSegment _checkpoint(VirtualLectureTopicProfile p, {required bool anatomy}) {
    final bool directional = p.topic.toLowerCase().contains('directional') ||
        p.topic.toLowerCase().contains('anatomical position') ||
        p.topic.toLowerCase().contains('orientation');
    return LectureSegment(
      phase: LecturePhase.knowledgeCheck,
      professorSpeech: anatomy
          ? 'Your turn — one chance. Use the definition we just built, not a guess.'
          : 'Quick check — one chance. Use the definition, not memorized noise.',
      caption: 'Check — ${p.topic}',
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.text,
        title: 'KNOWLEDGE CHECK',
        subtitle: 'One chance · 20 seconds',
        slideType: LectureSlideType.question,
        keyPoints: p.conceptLines.take(4).toList(),
      ),
      durationSeconds: 45,
      knowledgeCheck: LectureKnowledgeCheck(
        prompt: directional
            ? 'If the heart is medial to the lungs, what does that mean?'
            : p.checkPrompt,
        kind: KnowledgeCheckKind.multipleChoice,
        options: directional
            ? const <String>[
                'The heart is closer to the head',
                'The heart is closer to the midline',
                'The heart is farther from the midline',
                'The heart is closer to the skin',
              ]
            : p.checkOptions,
        correctIndex: directional ? 1 : p.checkCorrectIndex,
        explanation: directional
            ? 'Correct. Medial means closer to the body\'s midline.'
            : p.checkExplanation,
        timeLimitSeconds: 20,
      ),
    );
  }

  static LectureSegment _clinicalOrApplied(
    VirtualLectureTopicProfile p, {
    required bool anatomy,
  }) {
    final String speech = anatomy
        ? 'Now we make this clinical. ${_first(p.applicationsSpeech)} '
            'Imagine a patient with a complaint related to ${p.topic}. '
            'Which structures could be involved, and what directional language would you use to describe them? '
            'Anatomy is not memorization — it is the foundation for understanding patients.'
        : 'Now apply it. ${_first(p.applicationsSpeech)} '
            'Picture a real decision where ${p.topic} changes what you do next. '
            'If you cannot connect the idea to a consequence, you have only memorized a slogan.';
    return _seg(
      phase: LecturePhase.guidedExamples,
      speech: speech,
      title: anatomy ? 'CLINICAL CASE' : 'REAL-WORLD APPLICATION',
      subtitle: anatomy ? 'Use anatomy to reason about a patient' : 'Use the idea in a real decision',
      caption: 'Apply — ${p.topic}',
      slideType: anatomy ? LectureSlideType.clinicalCase : LectureSlideType.caseStudy,
      keyPoints: anatomy
          ? <String>[
              'Identify structures at risk',
              'Use precise location language',
              'Predict what fails if damaged',
              ...p.applicationLines.take(2),
            ]
          : (p.applicationLines.isNotEmpty
              ? p.applicationLines.take(4).toList()
              : p.exampleIdeas.take(4).toList()),
      seconds: 100,
    );
  }

  static LectureSegment _challenge(VirtualLectureTopicProfile p, {required bool anatomy}) {
    return LectureSegment(
      phase: LecturePhase.studentParticipation,
      professorSpeech: anatomy
          ? 'Mini challenge. Name one structure from today, say why it matters, and what you would expect if it failed.'
          : 'Mini challenge. State ${p.topic} in your own words, then give one consequence if you get it wrong.',
      caption: 'Challenge — ${p.topic}',
      whiteboard: LectureWhiteboardFrame(
        kind: WhiteboardKind.text,
        title: 'MINI CHALLENGE',
        subtitle: 'Think like a professional',
        slideType: LectureSlideType.challenge,
        keyPoints: anatomy
            ? const <String>[
                'Name the structure',
                'Say why it matters',
                'Predict failure consequences',
              ]
            : <String>[
                'Define ${p.topic} in one sentence',
                'Give one real consequence',
                'Name one common mistake',
              ],
      ),
      durationSeconds: 70,
      knowledgeCheck: LectureKnowledgeCheck(
        prompt: anatomy
            ? 'Which statement best matches clinical anatomy thinking?'
            : 'Which approach best matches professional use of ${p.topic}?',
        kind: KnowledgeCheckKind.multipleChoice,
        options: anatomy
            ? const <String>[
                'Memorize names only',
                'Name, locate, and predict clinical effect',
                'Skip diagrams and read summaries',
                'Wait for the disease lecture',
              ]
            : <String>[
                'Memorize slogans only',
                'Define, apply to a case, then check yourself',
                'Skip examples',
                'Only watch the diagram once',
              ],
        correctIndex: 1,
        explanation: anatomy
            ? 'Exactly. Name it, locate it, and predict what happens when it fails.'
            : 'Professionals define the idea, apply it, and verify with a check.',
        timeLimitSeconds: 20,
      ),
    );
  }

  static LectureSegment _threeTakeaways(
    VirtualLectureTopicProfile p, {
    required bool anatomy,
  }) {
    final List<String> takeaways = anatomy
        ? <String>[
            'Use standardized anatomical language',
            'Every structure has a location and a job',
            'Anatomy is the foundation for patient reasoning',
          ]
        : <String>[
            if (p.summaryLearned.isNotEmpty) p.summaryLearned.first else 'Core definition of ${p.topic}',
            if (p.summaryLearned.length > 1) p.summaryLearned[1] else 'How to apply it in a real case',
            if (p.summaryLearned.length > 2) p.summaryLearned[2] else 'Common mistakes to avoid',
          ];
    return _seg(
      phase: LecturePhase.lessonSummary,
      speech: anatomy
          ? 'Before you leave, remember three things. First, ${takeaways[0].toLowerCase()}. '
              'Second, ${takeaways[1].toLowerCase()}. '
              'Third, ${takeaways[2].toLowerCase()}. '
              'Next class, we continue building the body map — come ready to point and explain.'
          : 'Before you leave, remember three things from today. '
              'First, ${takeaways[0]}. Second, ${takeaways[1]}. Third, ${takeaways[2]}. '
              'Next class builds on this — do not skip the practice.',
      title: 'THREE TAKEAWAYS',
      subtitle: 'End of class',
      caption: 'Summary — ${p.topic}',
      slideType: LectureSlideType.summary,
      keyPoints: takeaways,
      seconds: 70,
    );
  }

  static LectureSegment _nextClass(VirtualLectureTopicProfile p, {required bool anatomy}) {
    final UniversityLabLink? lab = UniversityLearningEngine.labForLesson(
      subjectId: _subjectId(p),
      lessonTitle: p.topic,
      moduleTitle: p.module,
    );
    final String labBridge = lab != null
        ? 'Now you are going to test these principles yourself. '
            'When class ends, tap ENTER LAB to open ${lab.title}. '
        : '';
    return _seg(
      phase: LecturePhase.homeworkRecommendation,
      speech: anatomy
          ? '${labBridge}Your practical lab and clinical case follow this lecture. '
              'Review the labeled plate, then open the next lesson when you are ready. '
              'Class dismissed — go practice like a future clinician.'
          : '${labBridge}Homework: review today\'s three takeaways, rework one example closed-book, then open the next lesson. '
              'Practice, lab work, and quizzes are how this becomes usable skill.',
      title: 'NEXT STEPS',
      subtitle: lab != null
          ? 'ENTER LAB · practice · next lecture'
          : (anatomy ? 'Practical lab · clinical case · next lecture' : 'Practice · quiz · next lecture'),
      caption: 'Next — ${p.topic}',
      keyPoints: lab != null
          ? <String>[
              lab.title,
              'Apply lecture concepts hands-on',
              'Professor debrief after lab',
            ]
          : (anatomy
              ? const <String>[
                  'Practical anatomy lab',
                  'Clinical case practice',
                  'Next lecture on the body map',
                ]
              : const <String>[
                  'Guided practice',
                  'Knowledge quiz',
                  'Next lecture',
                ]),
      seconds: 45,
    );
  }

  static String _subjectId(VirtualLectureTopicProfile p) {
    final String blob = '${p.courseId} ${p.course} ${p.module}'.toLowerCase();
    if (p.category == LectureTopicCategory.biology || blob.contains('bio')) {
      return 'biology';
    }
    if (p.category == LectureTopicCategory.chemistry || blob.contains('chem')) {
      return 'chemistry';
    }
    if (blob.contains('phys')) return 'physics';
    if (blob.contains('nurs')) return 'nursing';
    if (blob.contains('medicine') || blob.contains('medical')) return 'medicine';
    if (blob.contains('law')) return 'law';
    if (blob.contains('account') ||
        blob.contains('finance') ||
        blob.contains('market') ||
        blob.contains('business') ||
        blob.contains('econ')) {
      return 'business';
    }
    if (blob.contains('computer') || blob.contains('software') || blob.contains('cs')) {
      return 'computer_science';
    }
    if (p.category == LectureTopicCategory.statistics ||
        p.category == LectureTopicCategory.calculusOther ||
        p.category == LectureTopicCategory.derivatives ||
        p.category == LectureTopicCategory.limits ||
        blob.contains('math')) {
      return 'mathematics';
    }
    return p.courseId;
  }

  static String _first(String text) {
    final String plain = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (plain.isEmpty) return '';
    final List<String> parts = plain.split(RegExp(r'(?<=[.!?])\s+'));
    return parts.isEmpty ? plain : parts.first.trim();
  }

  static String _second(String text) {
    final String plain = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final List<String> parts = plain
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((String e) => e.trim().isNotEmpty)
        .toList();
    if (parts.length < 2) return '';
    return parts[1].trim();
  }

  static LectureSegment _seg({
    required LecturePhase phase,
    required String speech,
    required String title,
    required String caption,
    String? subtitle,
    LectureSlideType slideType = LectureSlideType.concept,
    List<String> keyPoints = const <String>[],
    String? equation,
    String? diagramId,
    int seconds = 80,
  }) {
    return LectureSegment(
      phase: phase,
      professorSpeech: speech,
      caption: caption,
      whiteboard: LectureWhiteboardFrame(
        kind: diagramId != null ? WhiteboardKind.diagram : WhiteboardKind.text,
        title: title,
        subtitle: subtitle,
        slideType: slideType,
        keyPoints: keyPoints,
        lines: keyPoints,
        equation: equation,
        diagramId: diagramId,
        diagramQuery: diagramId != null
            ? '$title labeled educational anatomy diagram'
            : null,
      ),
      durationSeconds: seconds,
    );
  }
}
