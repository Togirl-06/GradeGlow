import '../../models/virtual_lecture.dart';
import '../data/vu_v2_topic_content.dart';
import '../data/vu_v2_topic_content_models.dart';
import 'textbook_fields.dart';

/// Conversational teaching. Never a text-to-speech reading of the textbook.
abstract final class ProfessorVoice {
  static VirtualLectureScript lecture({
    required String lessonTitle,
    required String courseTitle,
    required String moduleTitle,
    required String courseId,
    required String lessonId,
    required LectureMode mode,
    required String faculty,
  }) {
    final String subjectId = _subjectId(faculty, courseId);
    final VuV2TopicPackage pack = VuV2TopicContent.forLesson(
      subjectId: subjectId,
      facultyTitle: _facultyTitle(faculty, subjectId),
      facultyEmoji: '📘',
      trackTitle: moduleTitle.isEmpty ? courseTitle : moduleTitle,
      courseTitle: courseTitle,
      topicTitle: lessonTitle,
    );
    final TextbookKind kind = TextbookField.forTopic(subjectId, lessonTitle).kind;
    final List<LectureSegment> segments = _segments(
      kind: kind,
      topic: lessonTitle,
      course: courseTitle,
    );

    if (pack.topicQuiz.isNotEmpty && mode != LectureMode.review) {
      final VuV2Mcq q = pack.topicQuiz.first;
      segments.add(
        LectureSegment(
          phase: LecturePhase.knowledgeCheck,
          professorSpeech:
              'Stop and answer this one honestly. I am not looking for the heading. I am looking for whether the model is in your head. ${q.prompt}',
          caption: 'Checkpoint',
          whiteboard: LectureWhiteboardFrame(
            kind: WhiteboardKind.text,
            title: 'In-class check',
            lines: <String>[q.prompt, ...q.choices.take(4)],
          ),
          durationSeconds: 90,
          knowledgeCheck: LectureKnowledgeCheck(
            prompt: q.prompt,
            kind: KnowledgeCheckKind.multipleChoice,
            options: q.choices,
            correctIndex: q.correctIndex.clamp(0, q.choices.length - 1),
            explanation: q.explanation,
          ),
        ),
      );
    }

    segments.add(
      LectureSegment(
        phase: LecturePhase.lessonSummary,
        professorSpeech:
            'I am not going to recap by repeating the textbook. If you can rebuild the figure, walk the worked path, and say what would make you abandon your first hypothesis, you learned $lessonTitle. If you can only quote a definition, we are not done — open the chapter and come back to argue with me.',
        caption: 'Close',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Before you leave',
          lines: const <String>[
            'Rebuild the figure from memory',
            'Redo the worked path aloud',
            'Name the dangerous wrong move',
            'Then enter the lab and perform it',
          ],
        ),
        durationSeconds: 80,
      ),
    );

    final int take = switch (mode) {
      LectureMode.review => 8,
      LectureMode.practice || LectureMode.exam => 10,
      LectureMode.concept => 12,
      LectureMode.comprehensive || LectureMode.deepLearning => segments.length,
    };

    return VirtualLectureScript(
      mode: mode,
      topic: lessonTitle,
      course: courseTitle,
      module: moduleTitle,
      objectives: <String>[
        'Explain $lessonTitle in spoken language without reciting the chapter',
        'Use a figure or table to make a prediction',
        'Catch the most expensive misconception in $courseTitle',
        'Apply the idea to a professional case with uncertainty named',
      ],
      estimatedMinutes: switch (mode) {
        LectureMode.review => 18,
        LectureMode.exam => 25,
        LectureMode.practice => 35,
        LectureMode.concept => 50,
        LectureMode.comprehensive => 60,
        LectureMode.deepLearning => 75,
      },
      segments: segments.take(take.clamp(6, segments.length)).toList(),
      notes: LectureSmartNotes(
        definitions: <String>[
          'Classroom notes are cues, not the chapter. Open the textbook for the full argument on $lessonTitle.',
          'If a line still works after swapping the title, it is not a definition yet.',
        ],
        formulas: <String>[
          kind == TextbookKind.physics
              ? 'g = 2h/t² near Earth, neglecting drag — then argue the error'
              : kind == TextbookKind.chemistry
                  ? 'Moles at the true endpoint / volume of unknown — overshoot stays in the notebook'
                  : 'Name the governing rule, then the check a skeptic would demand',
        ],
        examples: const <String>[
          'The worked path is in the textbook. In class we hide the label and ask you to choose the next move.',
        ],
        commonMistakes: <String>[
          'Memorizing a slogan and stopping',
          'Reading the chapter in your head while I am asking a question',
          'Treating the lab as a quiz that happens to have a beaker',
        ],
        tips: const <String>[
          'Argue, do not quote',
          'Predict before the reveal',
          'Write one sentence of uncertainty after every claim',
        ],
      ),
      summary: LectureSummary(
        learned: <String>[
          'Conversational model of $lessonTitle',
          'A prediction from a figure',
          'A repaired misconception',
        ],
        keyFormulas: const <String>[],
        applications: <String>['$courseTitle professional case'],
        reviewTopics: <String>[moduleTitle, lessonTitle],
        homeworkRecommendation:
            'Read the textbook chapter (not these lecture cues). Teach the worked example aloud. Then do the investigation lab — do not skip to the report.',
      ),
    );
  }

  static List<LectureSegment> _segments({
    required TextbookKind kind,
    required String topic,
    required String course,
  }) {
    final _Voice v = _Voice.forKind(kind, topic, course);
    return <LectureSegment>[
      LectureSegment(
        phase: LecturePhase.introduction,
        professorSpeech: v.opener,
        caption: 'Let’s slow down',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: topic,
          lines: v.boardOpen,
        ),
        durationSeconds: _sec(v.opener),
      ),
      LectureSegment(
        phase: LecturePhase.objectives,
        professorSpeech: v.objectivesTalk,
        caption: 'What I will hold you to',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'By the end of this hour',
          lines: v.objectivesBoard,
        ),
        durationSeconds: _sec(v.objectivesTalk),
      ),
      LectureSegment(
        phase: LecturePhase.conceptExplanation,
        professorSpeech: v.theory,
        caption: 'The model',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Do not memorize the slogan',
          lines: v.theoryBoard,
        ),
        durationSeconds: _sec(v.theory),
        beats: <LectureInteractiveBeat>[
          LectureInteractiveBeat(
            professorSpeech: v.theory,
            caption: 'The model',
            durationSeconds: _sec(v.theory),
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: 'The working model',
              lines: v.theoryBoard,
            ),
          ),
          LectureInteractiveBeat(
            professorSpeech: v.question1Speech,
            caption: 'Your turn',
            durationSeconds: 50,
            whiteboard: LectureWhiteboardFrame(
              kind: WhiteboardKind.text,
              title: 'Predict',
              lines: <String>[v.question1Prompt, ...v.question1Options],
            ),
            studentChoice: LectureKnowledgeCheck(
              prompt: v.question1Prompt,
              kind: KnowledgeCheckKind.multipleChoice,
              options: v.question1Options,
              correctIndex: v.question1Correct,
              explanation: v.question1Why,
            ),
          ),
        ],
      ),
      LectureSegment(
        phase: LecturePhase.visualDemonstration,
        professorSpeech: v.diagramTalk,
        caption: 'Look at the diagram',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Figure — use it',
          lines: v.diagramBoard,
        ),
        durationSeconds: _sec(v.diagramTalk),
        knowledgeCheck: LectureKnowledgeCheck(
          prompt: v.diagramPrompt,
          kind: KnowledgeCheckKind.multipleChoice,
          options: v.diagramOptions,
          correctIndex: v.diagramCorrect,
          explanation: v.diagramWhy,
        ),
      ),
      LectureSegment(
        phase: LecturePhase.guidedExamples,
        professorSpeech: v.worked,
        caption: 'Worked path',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Walk this with me',
          lines: v.workedBoard,
        ),
        durationSeconds: _sec(v.worked),
      ),
      LectureSegment(
        phase: LecturePhase.studentParticipation,
        professorSpeech: v.misconception,
        caption: 'The expensive mistake',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Common collapse',
          lines: v.mythBoard,
        ),
        durationSeconds: _sec(v.misconception),
      ),
      LectureSegment(
        phase: LecturePhase.practiceProblems,
        professorSpeech: v.application,
        caption: 'Now you decide',
        whiteboard: LectureWhiteboardFrame(
          kind: WhiteboardKind.text,
          title: 'Professional move',
          lines: v.appBoard,
        ),
        durationSeconds: _sec(v.application),
      ),
    ];
  }

  static int _sec(String speech) {
    final int words =
        speech.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).length;
    return (words / 2.2).round().clamp(45, 160);
  }

  static String _subjectId(String faculty, String courseId) {
    final String f = faculty.toLowerCase();
    if (f.contains('bio')) return 'biology';
    if (f.contains('chem')) return 'chemistry';
    if (f.contains('phys')) return 'physics';
    if (f.contains('nurs')) return 'nursing';
    if (f.contains('med')) return 'medicine';
    if (f.contains('law')) return 'law';
    if (f.contains('bus')) return 'business';
    if (courseId.toLowerCase().contains('bio')) return 'biology';
    return faculty.isEmpty ? 'general' : faculty.toLowerCase();
  }

  static String _facultyTitle(String faculty, String subjectId) {
    if (faculty.trim().isNotEmpty) return faculty;
    return subjectId.isEmpty
        ? 'Virtual University'
        : '${subjectId[0].toUpperCase()}${subjectId.substring(1)}';
  }
}

class _Voice {
  const _Voice({
    required this.opener,
    required this.boardOpen,
    required this.objectivesTalk,
    required this.objectivesBoard,
    required this.theory,
    required this.theoryBoard,
    required this.question1Speech,
    required this.question1Prompt,
    required this.question1Options,
    required this.question1Correct,
    required this.question1Why,
    required this.diagramTalk,
    required this.diagramBoard,
    required this.diagramPrompt,
    required this.diagramOptions,
    required this.diagramCorrect,
    required this.diagramWhy,
    required this.worked,
    required this.workedBoard,
    required this.misconception,
    required this.mythBoard,
    required this.application,
    required this.appBoard,
  });

  final String opener;
  final List<String> boardOpen;
  final String objectivesTalk;
  final List<String> objectivesBoard;
  final String theory;
  final List<String> theoryBoard;
  final String question1Speech;
  final String question1Prompt;
  final List<String> question1Options;
  final int question1Correct;
  final String question1Why;
  final String diagramTalk;
  final List<String> diagramBoard;
  final String diagramPrompt;
  final List<String> diagramOptions;
  final int diagramCorrect;
  final String diagramWhy;
  final String worked;
  final List<String> workedBoard;
  final String misconception;
  final List<String> mythBoard;
  final String application;
  final List<String> appBoard;

  static _Voice forKind(TextbookKind kind, String topic, String course) {
    switch (kind) {
      case TextbookKind.skeletal:
        return _Voice(
          opener:
              'Let’s slow down. When I say $topic I do not want a sentence about support, protection, and movement. That is a caption. I want you thinking like someone about to read a film of a cyclist who just hit the ground. Before you name a fracture you have to know how the skeleton is organized — axial versus appendicular — and why that split changes what you clear first.',
          boardOpen: const <String>[
            'Not a caption: support / protection / movement',
            'A film, a fall, named bones',
            'Axial vs appendicular is a sorting tool',
          ],
          objectivesTalk:
              'By the time we stand up I want you able to sort axial from appendicular without blinking, describe a long bone so periosteum is living in your head, and connect remodeling to a cast. Reciting functions of bone will not get you there.',
          objectivesBoard: const <String>[
            'Sort axial vs appendicular',
            'Long-bone architecture',
            'Remodeling as lifelong',
            'Trauma first move',
          ],
          theory:
              'Axial is skull, vertebral column, thoracic cage. Appendicular is girdles and limbs. The clavicle is appendicular even though it sits near the midline — students love to get that wrong. A FOOSH is appendicular. A c-spine precaution is axial. Organization is what tells you which family of bones to inspect first.',
          theoryBoard: const <String>[
            'Axial: skull, spine, cage',
            'Appendicular: girdles + limbs',
            'Clavicle is appendicular',
          ],
          question1Speech:
              'A patient tenders the lower leg after a bicycle fall. Do not tell me “the skeletal system.” Tell me which bones you examine first, and why anatomical position matters for naming them.',
          question1Prompt:
              'Lower-leg trauma: which bones first, and which is medial in anatomical position?',
          question1Options: const <String>[
            'Femur and patella; fibula is medial',
            'Tibia and fibula; tibia is medial',
            'Radius and ulna; radius is medial',
            'The axial skeleton as a whole',
          ],
          question1Correct: 1,
          question1Why:
              'Leg means tibia and fibula, not thigh. In anatomical position the tibia is medial. Force can still transmit to ankle and knee — you still look — but you start with named leg bones.',
          diagramTalk:
              'Look at this diagram of a long bone. I want the diaphysis as a tube of compact bone, epiphyses of spongy bone under cartilage, periosteum living on the outside. If you cannot point to those, you are still holding a Halloween decoration.',
          diagramBoard: const <String>[
            'Diaphysis = shaft / compact',
            'Epiphysis = spongy + cartilage',
            'Periosteum is living',
          ],
          diagramPrompt: 'Which region is the shaft of compact bone around marrow?',
          diagramOptions: const <String>[
            'Epiphysis',
            'Diaphysis',
            'Articular cartilage',
            'Medullary cavity alone',
          ],
          diagramCorrect: 1,
          diagramWhy: 'Diaphysis is the shaft. The cavity is inside it; cartilage is on the joint surface.',
          worked:
              'FOOSH, pain in the distal forearm, dorsal tilt on the lateral film. Path: appendicular upper limb — not “arm,” that word is humerus. Distal radius is the usual story. Still inspect ulna and carpus. Articular involvement changes counseling. That is a worked identification, not a vibe.',
          workedBoard: const <String>[
            'FOOSH → distal radius pattern',
            'Forearm ≠ arm',
            'Still clear ulna / carpus',
          ],
          misconception:
              'Bone is not dead. Leg is not thigh. Axial does not mean “the important bones.” If those collapses are in your notes, tear that page out.',
          mythBoard: const <String>[
            'Bone is living',
            'Leg = tibia/fibula',
            'Clavicle ≠ axial',
          ],
          application:
              'You are the junior person at the film board. Say the first two bones you name, the division they belong to, and one injury you refuse to miss. Then go read the chapter — I will not read it to you.',
          appBoard: const <String>[
            'Name two bones',
            'Name the division',
            'Name the miss you refuse',
          ],
        );
      case TextbookKind.membrane:
        return _Voice(
          opener:
              'Let’s slow down on $topic. A red cell in distilled water swells. Nobody wished that. Water moved. I do not want the phrase selectively permeable as a trophy. I want you to ask, every time, protein or not, and ATP at this protein or not.',
          boardOpen: const <String>[
            'Water moved — that is the scene',
            'Protein or not?',
            'ATP at this protein or not?',
          ],
          objectivesTalk:
              'You should leave able to separate diffusion, facilitated diffusion, osmosis, and active transport, predict volume change from tonicity, and explain why ORS contains glucose and sodium. “Stuff crosses membranes” will not suffice.',
          objectivesBoard: const <String>[
            'Four transport classes',
            'Tonicity ≠ osmolarity slogan',
            'ORS = SGLT story',
          ],
          theory:
              'The bilayer’s hydrophobic core rejects hydrated ions. O₂ can pass. Sodium cannot usefully pass without a protein. Carriers saturate. The Na⁺/K⁺ pump spends ATP to build a battery. SGLT spends that battery. That sequence is the theory of this chapter in $course — not a list of protein names.',
          theoryBoard: const <String>[
            'Core rejects ions',
            'Carriers saturate',
            'Pump builds; SGLT spends',
          ],
          question1Speech:
              'Look at this membrane cartoon. I am pointing at the inner mitochondrial membrane another day. Today: which process requires ATP hydrolysis at the membrane protein itself?',
          question1Prompt: 'Which process hydrolyzes ATP at the transporter?',
          question1Options: const <String>[
            'Simple diffusion of O₂',
            'Facilitated diffusion of glucose via GLUT',
            'Na⁺/K⁺ ATPase',
            'Osmosis through aquaporins',
          ],
          question1Correct: 2,
          question1Why:
              'Primary active transport hydrolyzes ATP at the pump. GLUT is facilitated. Aquaporins are passive water pores.',
          diagramTalk:
              'On the gut apical membrane, SGLT couples glucose to sodium. Water follows. That is why ORS is not “drink water and hope.” If your diagram is a blank oval labeled cell, you are not looking at a figure. You are looking at a logo.',
          diagramBoard: const <String>[
            'SGLT: Na⁺ + glucose in',
            'Water follows osmotically',
            'Water-only misses the coupler',
          ],
          diagramPrompt: 'Why does ORS include glucose as well as sodium?',
          diagramOptions: const <String>[
            'Glucose tastes better so patients drink more, only',
            'SGLT is secondary active transport; water follows the absorbed solute',
            'Glucose pumps water with ATP directly',
            'Sodium cannot be absorbed without sucrose',
          ],
          diagramCorrect: 1,
          diagramWhy:
              'SGLT couples glucose to sodium. Absorbing both raises luminal-to-blood solute movement; water follows.',
          worked:
              'Hypotonic extracellular fluid with non-penetrating proteins trapped inside: water in, swell, possible lysis. The trap is “salt always pulls water” without asking which solutes penetrate. Tonicity is about the ones that do not.',
          workedBoard: const <String>[
            'Ask what cannot penetrate',
            'Water toward higher effective osmoles',
            'Lysis is a prediction, not a decoration',
          ],
          misconception:
              'Diffusion does not require ATP. Osmosis is not salt walking. Equilibrium for ions is not “equal concentrations” when charge is in the story. Kill those.',
          mythBoard: const <String>[
            'Diffusion can be passive',
            'Tonicity ≠ slogan saltiness',
            'Ions feel voltage too',
          ],
          application:
              'Infant with diarrhea given water only. You know enough to be angry at that order. Explain SGLT, then open the chapter for the full argument. I will not read the osmotic algebra aloud as if that were teaching.',
          appBoard: const <String>[
            'Water-only is a miss',
            'ORS recruits SGLT',
            'Then read the chapter',
          ],
        );
      default:
        return _Voice(
          opener:
              'Let’s slow down on $topic. I am not going to read the textbook to you. The chapter is the reference. I am here to make you argue: what is the model, what would you see if you were wrong, and what does a professional do first in $course.',
          boardOpen: <String>[
            'Textbook = reference',
            'Lecture = argument',
            topic,
          ],
          objectivesTalk:
              'I will hold you to an operational definition, a causal chain with verbs, one figure that does work, and the misconception that turns this topic into a slogan. Reciting the title of $topic does not count.',
          objectivesBoard: const <String>[
            'Define so a follow-up “why?” survives',
            'Mechanism with verbs',
            'Figure → prediction',
            'Repair the slogan',
          ],
          theory:
              'The working model of $topic is not a pile of nouns. It is a starting state, allowed operations, an invariant, and a failure mode. If your notes still work after swapping in a neighboring heading, you do not have a theory yet — you have a template. Let’s refuse that.',
          theoryBoard: const <String>[
            'Start → process → invariant',
            'Name a failure mode',
            'No interchangeable slogans',
          ],
          question1Speech:
              'Predict before I reveal anything. Which move actually tests the model of $topic rather than restating the title?',
          question1Prompt: 'What would actually test your model of $topic?',
          question1Options: <String>[
            'Repeat the heading in different words',
            'State an observation that would force you to drop the claim',
            'Underline the first paragraph of the notes',
            'Memorize three synonyms',
          ],
          question1Correct: 1,
          question1Why:
              'A model earns its keep by naming what would kill it. Synonyms are not tests.',
          diagramTalk:
              'Look at this diagram. I want you to tell me which part a novice skips — the inset, the control, the axis units, the rival hypothesis. If you cannot use the figure to make a prediction, it is clip art.',
          diagramBoard: const <String>[
            'Figures make predictions',
            'Name the skipped inset',
            'Name a rival reading',
          ],
          diagramPrompt: 'A figure is doing its job when you can…',
          diagramOptions: const <String>[
            'Caption it with the chapter title',
            'Make a prediction you could be wrong about',
            'Recolor it from memory',
            'Export it to a slide',
          ],
          diagramCorrect: 1,
          diagramWhy: 'If it cannot be wrong, it is not a prediction.',
          worked:
              'Unknown, governing rule, substitution or mapping, sanity check. That is the path for $topic in $course. I will not do the algebra or the analogical mapping while you watch passively. You walk it. I will interrupt if you skip the check.',
          workedBoard: const <String>[
            'Name the unknown',
            'Name the rule',
            'Sanity-check the result',
          ],
          misconception:
              'The expensive mistake is treating a slogan as a model. The second is ignoring units, laterality, or the other side’s best fact. If I hear the title back, I will ask “why” until a mechanism appears.',
          mythBoard: const <String>[
            'Slogan ≠ model',
            'Name a unit / side / citation',
            'Keep uncertainty visible',
          ],
          application:
              'You are the junior person on call for $topic. First observation. First action you refuse. One line of uncertainty. Then go perform it in the lab — this classroom is not the investigation.',
          appBoard: const <String>[
            'Observe',
            'Refuse the dangerous skip',
            'Then the laboratory',
          ],
        );
    }
  }
}
