import 'package:flutter/material.dart';

import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_roadmap_models.dart';
import '../data/vu_v2_session.dart';
import '../data/vu_v2_topic_content.dart';
import '../data/vu_v2_topic_content_models.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_study_course_picker.dart';

/// Course → topics → flip flashcards generated from those topics.
abstract final class VuV2FlashcardsFlow {
  static void open({
    required BuildContext context,
    required VuV2Session session,
    required VuV2ProgressStore progress,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VuV2StudyCoursePickerScreen(
          session: session,
          progress: progress,
          title: 'Flashcards',
          subtitle:
              'Pick a course, select topics, then study flip cards generated from those topics.',
          onCourseSelected: (BuildContext ctx, VuV2StudyCourseRef c) {
            Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (_) => VuV2TopicSelectScreen(
                  heading: 'Flashcards',
                  course: c,
                  ctaLabel: 'Start flashcards',
                  onStart: (List<VuV2RoadmapLesson> topics, String _) {
                    final List<VuV2StudyFlashcard> cards = _buildCards(c, topics);
                    Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VuV2FlashcardsSessionScreen(
                          courseTitle: c.course.title,
                          cards: cards,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static List<VuV2StudyFlashcard> _buildCards(
    VuV2StudyCourseRef c,
    List<VuV2RoadmapLesson> topics,
  ) {
    final List<VuV2StudyFlashcard> cards = <VuV2StudyFlashcard>[];
    for (final VuV2RoadmapLesson lesson in topics) {
      cards.add(
        VuV2StudyFlashcard(
          front: lesson.title,
          back:
              'Explain ${lesson.title} in your own words for ${c.course.title}. '
              '${lesson.subtitle ?? "Cover definition, why it matters, and one example."}',
        ),
      );
      final List<VuV2Mcq> quiz = VuV2TopicContent.topicQuiz(
        subjectId: c.subjectId,
        facultyTitle: c.facultyTitle,
        courseTitle: c.course.title,
        topicTitle: lesson.title,
        count: 4,
      );
      for (final VuV2Mcq q in quiz) {
        final String answer = q.kind == VuV2QuestionKind.shortAnswer
            ? (q.shortAnswerKey?.join(', ') ?? q.explanation)
            : (q.choices.isNotEmpty
                ? q.choices[q.correctIndex.clamp(0, q.choices.length - 1)]
                : q.explanation);
        cards.add(
          VuV2StudyFlashcard(
            front: q.prompt,
            back: '$answer\n\n${q.explanation}',
          ),
        );
      }
    }
    return cards;
  }
}

/// Course → topics → unlimited-style practice by difficulty.
abstract final class VuV2QuestionBankFlow {
  static void open({
    required BuildContext context,
    required VuV2Session session,
    required VuV2ProgressStore progress,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VuV2StudyCoursePickerScreen(
          session: session,
          progress: progress,
          title: 'Question bank',
          subtitle:
              'Pick a course and topics, set difficulty, then practice as many sets as you want.',
          onCourseSelected: (BuildContext ctx, VuV2StudyCourseRef c) {
            Navigator.of(ctx).push(
              MaterialPageRoute<void>(
                builder: (_) => VuV2TopicSelectScreen(
                  heading: 'Question bank',
                  course: c,
                  ctaLabel: 'Start practice',
                  showDifficulty: true,
                  onStart: (List<VuV2RoadmapLesson> topics, String difficulty) {
                    Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VuV2QuestionBankSessionScreen(
                          course: c,
                          topics: topics,
                          difficulty: difficulty,
                          progress: progress,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class VuV2TopicSelectScreen extends StatefulWidget {
  const VuV2TopicSelectScreen({
    super.key,
    required this.heading,
    required this.course,
    required this.ctaLabel,
    required this.onStart,
    this.showDifficulty = false,
  });

  final String heading;
  final VuV2StudyCourseRef course;
  final String ctaLabel;
  final void Function(List<VuV2RoadmapLesson> topics, String difficulty) onStart;
  final bool showDifficulty;

  @override
  State<VuV2TopicSelectScreen> createState() => _VuV2TopicSelectScreenState();
}

class _VuV2TopicSelectScreenState extends State<VuV2TopicSelectScreen> {
  final Set<String> _selected = <String>{};
  String _difficulty = 'Medium';

  List<VuV2RoadmapLesson> get _lessons => widget.course.course.allLessons;

  @override
  void initState() {
    super.initState();
    for (final VuV2RoadmapLesson l in _lessons.take(5)) {
      _selected.add(l.id);
    }
  }

  List<VuV2RoadmapLesson> get _picked => _lessons
      .where((VuV2RoadmapLesson l) => _selected.contains(l.id))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(
        title: Text(widget.course.course.title),
        backgroundColor: VuV2Colors.navy,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: <Widget>[
                Text(
                  '${widget.course.facultyEmoji} ${widget.course.facultyTitle}',
                  style: TextStyle(
                    color: VuV2Colors.mute,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select topics · ${widget.heading}',
                  style: TextStyle(
                    color: VuV2Colors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: () => setState(() {
                        _selected
                          ..clear()
                          ..addAll(_lessons.map((VuV2RoadmapLesson l) => l.id));
                      }),
                      child: const Text('Select all'),
                    ),
                    TextButton(
                      onPressed: () => setState(_selected.clear),
                      child: const Text('Clear'),
                    ),
                    const Spacer(),
                    Text(
                      '${_selected.length} / ${_lessons.length}',
                      style: TextStyle(
                        color: VuV2Colors.orange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                ..._lessons.map((VuV2RoadmapLesson l) {
                  final bool on = _selected.contains(l.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: VuV2Colors.navyElevated,
                      borderRadius: BorderRadius.circular(VuV2Radii.md),
                      child: CheckboxListTile(
                        value: on,
                        onChanged: (_) => setState(() {
                          if (!_selected.add(l.id)) _selected.remove(l.id);
                        }),
                        activeColor: VuV2Colors.orange,
                        checkColor: Colors.black,
                        title: Text(
                          l.title,
                          style: TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  );
                }),
                if (widget.showDifficulty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    'Difficulty',
                    style: TextStyle(
                      color: VuV2Colors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: <String>['Easy', 'Medium', 'Hard'].map((String d) {
                      final bool on = _difficulty == d;
                      return ChoiceChip(
                        label: Text(d),
                        selected: on,
                        onSelected: (_) => setState(() => _difficulty = d),
                        selectedColor: VuV2Colors.orange,
                        labelStyle: TextStyle(
                          color: on ? Colors.black : VuV2Colors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                        backgroundColor: VuV2Colors.navyElevated,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: VuV2PrimaryButton(
                label: widget.ctaLabel,
                icon: Icons.play_arrow_rounded,
                onPressed: _selected.isEmpty
                    ? null
                    : () => widget.onStart(_picked, _difficulty),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VuV2StudyFlashcard {
  const VuV2StudyFlashcard({required this.front, required this.back});
  final String front;
  final String back;
}

class VuV2FlashcardsSessionScreen extends StatefulWidget {
  const VuV2FlashcardsSessionScreen({
    super.key,
    required this.courseTitle,
    required this.cards,
  });

  final String courseTitle;
  final List<VuV2StudyFlashcard> cards;

  @override
  State<VuV2FlashcardsSessionScreen> createState() =>
      _VuV2FlashcardsSessionScreenState();
}

class _VuV2FlashcardsSessionScreenState
    extends State<VuV2FlashcardsSessionScreen> {
  int _index = 0;
  bool _showBack = false;
  int _known = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: const VuV2EmptyState(
          title: 'No cards',
          subtitle: 'Select more topics and try again.',
        ),
      );
    }
    final VuV2StudyFlashcard card = widget.cards[_index];
    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(
        title: const Text('Study Center'),
        backgroundColor: VuV2Colors.navy,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: VuV2Colors.card,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: VuV2Colors.stroke),
                  ),
                  child: Text(
                    'Card ${_index + 1} / ${widget.cards.length}',
                    style: TextStyle(
                      color: VuV2Colors.mute,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: VuV2Colors.mint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: VuV2Colors.mint.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    widget.courseTitle.toUpperCase().length > 12
                        ? widget.courseTitle.toUpperCase().substring(0, 12)
                        : widget.courseTitle.toUpperCase(),
                    style: TextStyle(
                      color: VuV2Colors.mint,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showBack = !_showBack),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: VuV2Colors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: VuV2Colors.stroke),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            _showBack ? 'DEFINITION' : 'TERM',
                            style: TextStyle(
                              color: VuV2Colors.mint,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _showBack ? card.back : card.front,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: VuV2Colors.ink,
                              fontWeight: FontWeight.w900,
                              fontSize: _showBack ? 18 : 26,
                              height: 1.3,
                            ),
                          ),
                          if (!_showBack) ...<Widget>[
                            const SizedBox(height: 14),
                            Text(
                              'Click to flip',
                              style: TextStyle(color: VuV2Colors.mute),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _FlashNav(
                    icon: Icons.arrow_back_rounded,
                    label: 'Prev',
                    filled: false,
                    onTap: _index == 0
                        ? null
                        : () => setState(() {
                              _index--;
                              _showBack = false;
                            }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FlashNav(
                    icon: Icons.flip_rounded,
                    label: 'Flip',
                    filled: false,
                    onTap: () => setState(() => _showBack = !_showBack),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FlashNav(
                    icon: Icons.arrow_forward_rounded,
                    label: 'Next',
                    filled: true,
                    onTap: () {
                      setState(() {
                        if (_showBack) _known++;
                        _showBack = false;
                        if (_index < widget.cards.length - 1) {
                          _index++;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Marked known: $_known',
              style: TextStyle(color: VuV2Colors.mute, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashNav extends StatelessWidget {
  const _FlashNav({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return Material(
      color: filled ? VuV2Colors.mint : VuV2Colors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: filled ? VuV2Colors.mint : VuV2Colors.stroke,
              ),
            ),
            child: Column(
              children: <Widget>[
                Icon(
                  icon,
                  color: filled ? const Color(0xFF04110C) : VuV2Colors.ink,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: filled ? const Color(0xFF04110C) : VuV2Colors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VuV2QuestionBankSessionScreen extends StatefulWidget {
  const VuV2QuestionBankSessionScreen({
    super.key,
    required this.course,
    required this.topics,
    required this.difficulty,
    required this.progress,
  });

  final VuV2StudyCourseRef course;
  final List<VuV2RoadmapLesson> topics;
  final String difficulty;
  final VuV2ProgressStore progress;

  @override
  State<VuV2QuestionBankSessionScreen> createState() =>
      _VuV2QuestionBankSessionScreenState();
}

class _VuV2QuestionBankSessionScreenState
    extends State<VuV2QuestionBankSessionScreen> {
  late List<VuV2Mcq> _questions;
  int _index = 0;
  int? _picked;
  int _correct = 0;
  int _answered = 0;
  int _set = 1;
  String? _feedback;

  int get _perSet {
    switch (widget.difficulty) {
      case 'Easy':
        return 6;
      case 'Hard':
        return 12;
      default:
        return 8;
    }
  }

  @override
  void initState() {
    super.initState();
    _questions = _buildSet();
  }

  List<VuV2Mcq> _buildSet() {
    final bool challenge = widget.difficulty == 'Hard';
    final int perTopic = widget.difficulty == 'Easy' ? 2 : 3;
    final List<VuV2Mcq> out = <VuV2Mcq>[];
    for (final VuV2RoadmapLesson t in widget.topics) {
      out.addAll(
        VuV2TopicContent.topicQuiz(
          subjectId: widget.course.subjectId,
          facultyTitle: widget.course.facultyTitle,
          courseTitle: widget.course.course.title,
          topicTitle: t.title,
          count: perTopic,
          challenge: challenge,
        ),
      );
    }
    out.shuffle();
    return out.take(_perSet).toList();
  }

  Future<void> _submit() async {
    if (_picked == null) return;
    final VuV2Mcq q = _questions[_index];
    final bool ok = _picked == q.correctIndex;
    setState(() {
      _answered++;
      if (ok) _correct++;
      _feedback =
          ok ? 'Correct. ${q.explanation}' : 'Not quite. ${q.explanation}';
    });
    await widget.progress.recordQuiz(
      'qbank_${widget.course.course.id}_$_set',
      _answered == 0 ? 0 : 100 * _correct / _answered,
    );
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      setState(() {
        _set++;
        _questions = _buildSet();
        _index = 0;
        _picked = null;
        _feedback = null;
      });
      return;
    }
    setState(() {
      _index++;
      _picked = null;
      _feedback = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Question bank')),
        body: const VuV2EmptyState(
          title: 'No questions',
          subtitle: 'Pick more topics and try again.',
        ),
      );
    }
    final VuV2Mcq q = _questions[_index];
    return Scaffold(
      backgroundColor: VuV2Colors.navy,
      appBar: AppBar(
        title: Text('Question bank · set $_set'),
        backgroundColor: VuV2Colors.navy,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            '${widget.course.course.title} · ${widget.difficulty} · '
            '$_correct/$_answered correct',
            style: TextStyle(color: VuV2Colors.mute),
          ),
          const SizedBox(height: 12),
          Text(
            'Q${_index + 1} / ${_questions.length}',
            style: TextStyle(
              color: VuV2Colors.orange,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            q.prompt,
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          ...List<Widget>.generate(q.choices.length, (int i) {
            final bool selected = _picked == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: selected
                    ? VuV2Colors.orange.withValues(alpha: 0.16)
                    : VuV2Colors.navyElevated,
                borderRadius: BorderRadius.circular(VuV2Radii.md),
                child: InkWell(
                  onTap: _feedback != null
                      ? null
                      : () => setState(() => _picked = i),
                  borderRadius: BorderRadius.circular(VuV2Radii.md),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(VuV2Radii.md),
                      border: Border.all(
                        color: selected ? VuV2Colors.orange : VuV2Colors.stroke,
                      ),
                    ),
                    child: Text(
                      q.choices[i],
                      style: TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              _feedback!,
              style: TextStyle(color: VuV2Colors.mute, height: 1.4),
            ),
          ],
          const SizedBox(height: 16),
          if (_feedback == null)
            VuV2PrimaryButton(
              label: 'Check answer',
              onPressed: _picked == null ? null : _submit,
            )
          else
            VuV2PrimaryButton(
              label: _index >= _questions.length - 1
                  ? 'Next set (unlimited)'
                  : 'Next question',
              onPressed: _next,
            ),
        ],
      ),
    );
  }
}
