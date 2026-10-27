/// Lectures: scripted or generated professor talks with synchronized
/// highlighting of the concept being spoken about, plus a knowledge check.
///
/// Everything here is deterministic. An AI professor (see
/// `services/life_ai_service.dart`) can answer follow-up questions, but the
/// lecture content, highlighting and knowledge-check scoring never depend on AI.
library;

import 'university.dart';

/// Which teaching visual a lecture uses.
enum LectureBoard { body, concepts }

class LectureLine {
  const LectureLine(this.text, {this.highlights = const <String>[]});
  final String text;

  /// Ids to highlight while this line is spoken (organs on the body board,
  /// terms on the concept board). Empty = derive from the text.
  final List<String> highlights;
}

class Lecture {
  const Lecture({
    required this.courseId,
    required this.number,
    required this.title,
    required this.board,
    required this.lines,
    required this.check,
    required this.terms,
  });

  final String courseId;
  final int number;
  final String title;
  final LectureBoard board;
  final List<LectureLine> lines;

  /// Knowledge-check questions asked after the lecture.
  final List<ExamQuestion> check;

  /// Concept-board terms (id → label) shown on the board.
  final Map<String, String> terms;
}

/// Body board regions: id → label.
const Map<String, String> kOrgans = <String, String>{
  'skull': 'Skull',
  'brain': 'Brain',
  'spine': 'Spine',
  'ribs': 'Rib cage',
  'heart': 'Heart',
  'lungs': 'Lungs',
  'liver': 'Liver',
  'stomach': 'Stomach',
  'kidneys': 'Kidneys',
  'intestines': 'Intestines',
  'bladder': 'Bladder',
  'femur': 'Femur',
};

/// Words that trigger an organ highlight when spoken.
const Map<String, String> kOrganWords = <String, String>{
  'skull': 'skull',
  'cranium': 'skull',
  'brain': 'brain',
  'cerebellum': 'brain',
  'cerebrum': 'brain',
  'spine': 'spine',
  'spinal': 'spine',
  'vertebrae': 'spine',
  'rib': 'ribs',
  'ribs': 'ribs',
  'heart': 'heart',
  'cardiac': 'heart',
  'aorta': 'heart',
  'lung': 'lungs',
  'lungs': 'lungs',
  'alveoli': 'lungs',
  'liver': 'liver',
  'stomach': 'stomach',
  'kidney': 'kidneys',
  'kidneys': 'kidneys',
  'intestine': 'intestines',
  'intestines': 'intestines',
  'bowel': 'intestines',
  'bladder': 'bladder',
  'femur': 'femur',
  'thigh': 'femur',
};

class LectureLibrary {
  const LectureLibrary._();

  static const int lectureCount = CourseRequirements.lecturesRequired;

  /// Lecture [number] (1-based) of [course].
  static Lecture forCourse(Course course, int number) {
    final int n = ((number - 1) % lectureCount) + 1;
    final Lecture? scripted = _scripted(course.id, n);
    if (scripted != null) return scripted;
    return _generated(course, n);
  }

  /// Organ ids mentioned in [text].
  static List<String> organsIn(String text) {
    final Set<String> out = <String>{};
    for (final String w in _words(text)) {
      final String? id = kOrganWords[w];
      if (id != null) out.add(id);
    }
    return out.toList();
  }

  /// Term ids (from [terms]) mentioned in [text].
  static List<String> termsIn(String text, Map<String, String> terms) {
    final String t = text.toLowerCase();
    return <String>[
      for (final MapEntry<String, String> e in terms.entries)
        if (t.contains(e.value.toLowerCase())) e.key,
    ];
  }

  /// Highlights to show for a line.
  static List<String> highlightsFor(Lecture l, LectureLine line) {
    if (line.highlights.isNotEmpty) return line.highlights;
    return l.board == LectureBoard.body ? organsIn(line.text) : termsIn(line.text, l.terms);
  }

  /// Scores a knowledge check: fraction correct.
  static double scoreCheck(Lecture l, List<int?> answers) {
    if (l.check.isEmpty) return 1;
    int ok = 0;
    for (int i = 0; i < l.check.length; i++) {
      if (i < answers.length && answers[i] == l.check[i].correct) ok++;
    }
    return ok / l.check.length;
  }

  /// A deterministic, offline answer for a student's question: the most
  /// relevant explanation from the course (used when AI is unavailable).
  static String offlineAnswer(Course course, String question) {
    final Set<String> q = _words(question).where((String w) => w.length > 3 && !_stop.contains(w)).toSet();
    String? best;
    int bestScore = 0;
    for (final ExamQuestion e in course.questions) {
      final Set<String> words = _words('${e.prompt} ${e.options[e.correct]} ${e.explanation}').toSet();
      final int score = q.where(words.contains).length;
      if (score > bestScore) {
        bestScore = score;
        best = '${e.options[e.correct]}. ${e.explanation}';
      }
    }
    if (best != null) return 'Good question. $best';
    return 'Good question — in ${course.name.split(' ').skip(1).join(' ')}, ${course.summary.toLowerCase()} '
        'Try the study desk and come back with a more specific question.';
  }

  static Iterable<String> _words(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').split(' ').where((String w) => w.isNotEmpty);

  static const Set<String> _stop = <String>{'what', 'does', 'which', 'this', 'that', 'with', 'about', 'from', 'have', 'would', 'could', 'please', 'explain', 'tell'};

  static bool _isBody(Course c) => c.skill == 'clinical' || c.skill == 'medicine';

  /// Builds a lecture from the course's own questions and explanations.
  static Lecture _generated(Course c, int n) {
    final List<ExamQuestion> qs = c.questions;
    final List<ExamQuestion> mine = <ExamQuestion>[
      for (int i = 0; i < qs.length; i++)
        if (i % lectureCount == (n - 1) % lectureCount) qs[i],
    ];
    final List<ExamQuestion> taught = mine.isEmpty ? <ExamQuestion>[qs[(n - 1) % qs.length]] : mine;
    final Map<String, String> terms = <String, String>{};
    for (final ExamQuestion q in qs) {
      final String ans = q.options[q.correct];
      final String key = ans.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').trim();
      if (key.isNotEmpty && key.length <= 28 && terms.length < 12) terms[key] = ans.replaceAll('…', '').trim();
    }
    final List<LectureLine> lines = <LectureLine>[
      LectureLine('Welcome to lecture $n of ${c.name}. ${c.summary}'),
      for (final ExamQuestion q in taught) ...<LectureLine>[
        LectureLine('Let us ask: ${q.prompt}'),
        LectureLine('The answer is ${q.options[q.correct]}. ${q.explanation}'),
      ],
      const LectureLine('That is today\'s lecture. Let us check what you took away.'),
    ];
    // Knowledge check: the taught questions, rotated so the answer is not always first.
    final List<ExamQuestion> check = <ExamQuestion>[for (final ExamQuestion q in taught.take(2)) _rotate(q, n)];
    return Lecture(
      courseId: c.id,
      number: n,
      title: '${c.name.split(' ').first} lecture $n',
      board: _isBody(c) ? LectureBoard.body : LectureBoard.concepts,
      lines: lines,
      check: check,
      terms: terms,
    );
  }

  static ExamQuestion _rotate(ExamQuestion q, int shift) {
    final int len = q.options.length;
    final int s = shift % len;
    final List<String> opts = <String>[...q.options.sublist(s), ...q.options.sublist(0, s)];
    final int idx = (q.correct - s) % len;
    return ExamQuestion(q.prompt, opts, idx < 0 ? idx + len : idx, q.explanation);
  }

  static Lecture? _scripted(String courseId, int n) {
    if (courseId != 'nu101') return null;
    switch (n) {
      case 1:
        return const Lecture(
          courseId: 'nu101',
          number: 1,
          title: 'Protection and support: the skeleton',
          board: LectureBoard.body,
          terms: <String, String>{},
          lines: <LectureLine>[
            LectureLine('Welcome to Anatomy and Physiology. Today we explore how the skeleton protects and supports the body.'),
            LectureLine('The skull protects the brain, our control centre.', highlights: <String>['skull', 'brain']),
            LectureLine('The spine, made of vertebrae, protects the spinal cord and holds us upright.', highlights: <String>['spine']),
            LectureLine('The rib cage shields the heart and lungs, and it moves as you breathe.', highlights: <String>['ribs', 'heart', 'lungs']),
            LectureLine('The femur in the thigh is the longest and strongest bone in the body.', highlights: <String>['femur']),
            LectureLine('Now let us check what you remember.'),
          ],
          check: <ExamQuestion>[
            ExamQuestion('Which structure protects the brain?', <String>['The skull', 'The rib cage', 'The femur', 'The bladder'], 0, 'The skull (cranium) surrounds and protects the brain.'),
            ExamQuestion('Which bone is the longest in the body?', <String>['Femur', 'Rib', 'Vertebra', 'Skull'], 0, 'The femur, in the thigh, is the longest bone.'),
          ],
        );
      case 2:
        return const Lecture(
          courseId: 'nu101',
          number: 2,
          title: 'Circulation: the heart and blood vessels',
          board: LectureBoard.body,
          terms: <String, String>{},
          lines: <LectureLine>[
            LectureLine('Today: the cardiovascular system, the body\'s delivery network.'),
            LectureLine('The heart pumps blood throughout the body with every beat.', highlights: <String>['heart']),
            LectureLine('Arteries carry blood away from the heart; veins return it. The aorta is the largest artery.', highlights: <String>['heart']),
            LectureLine('At rest, an adult heart beats about 60 to 100 times each minute.', highlights: <String>['heart']),
            LectureLine('Blood visits the lungs to pick up oxygen before it is sent around the body.', highlights: <String>['lungs', 'heart']),
            LectureLine('Let us check what you learned.'),
          ],
          check: <ExamQuestion>[
            ExamQuestion('Which organ pumps blood around the body?', <String>['Liver', 'Heart', 'Kidney', 'Stomach'], 1, 'The heart is the pump of the circulatory system.'),
            ExamQuestion('A normal adult resting heart rate is about…', <String>['10–20 beats/min', '200–250 beats/min', '60–100 beats/min', '0–5 beats/min'], 2, 'Resting adult pulse is typically 60–100.'),
          ],
        );
      case 3:
        return const Lecture(
          courseId: 'nu101',
          number: 3,
          title: 'Breathing and digestion',
          board: LectureBoard.body,
          terms: <String, String>{},
          lines: <LectureLine>[
            LectureLine('Today we follow two journeys: air and food.'),
            LectureLine('Air travels into the lungs, where gas exchange happens in tiny sacs called alveoli.', highlights: <String>['lungs']),
            LectureLine('Food is broken down in the stomach, then nutrients are absorbed in the intestines.', highlights: <String>['stomach', 'intestines']),
            LectureLine('The liver processes nutrients and filters the blood.', highlights: <String>['liver']),
            LectureLine('The kidneys filter waste from the blood into urine, which is stored in the bladder.', highlights: <String>['kidneys', 'bladder']),
            LectureLine('Let us check your understanding.'),
          ],
          check: <ExamQuestion>[
            ExamQuestion('Gas exchange happens in the…', <String>['Stomach', 'Alveoli of the lungs', 'Bladder', 'Spleen'], 1, 'Oxygen and CO₂ cross at the alveoli.'),
            ExamQuestion('Which organs filter waste from the blood into urine?', <String>['Lungs', 'Liver', 'Kidneys', 'Stomach'], 2, 'The kidneys filter blood and make urine.'),
          ],
        );
      default:
        return const Lecture(
          courseId: 'nu101',
          number: 4,
          title: 'Control and coordination: the nervous system',
          board: LectureBoard.body,
          terms: <String, String>{},
          lines: <LectureLine>[
            LectureLine('Our last lecture: the nervous system, the body\'s communication network.'),
            LectureLine('The brain interprets information and sends commands.', highlights: <String>['brain']),
            LectureLine('The cerebellum, at the back of the brain, coordinates movement and balance.', highlights: <String>['brain']),
            LectureLine('The spinal cord carries messages between the brain and the body, protected by the spine.', highlights: <String>['spine', 'brain']),
            LectureLine('Together these let you sense, decide, and move. Let us check what stuck.'),
          ],
          check: <ExamQuestion>[
            ExamQuestion('Which part of the brain controls balance and coordination?', <String>['Aorta', 'Pancreas', 'Cerebellum', 'Cornea'], 2, 'The cerebellum coordinates movement.'),
            ExamQuestion('What carries messages between the brain and the body?', <String>['The spinal cord', 'The femur', 'The bladder', 'The aorta'], 0, 'The spinal cord is the main pathway for nerve signals.'),
          ],
        );
    }
  }
}
