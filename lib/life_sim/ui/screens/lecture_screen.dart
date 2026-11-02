import 'dart:async';

import 'package:flutter/material.dart';

import '../../avatar/avatar_profile.dart';
import '../../education/lectures.dart';
import '../../education/university.dart';
import '../../services/life_ai_service.dart';
import '../life_session.dart';
import '../life_widgets.dart';
import '../painters/avatar_painter.dart';
import '../painters/body_board.dart';

/// A lecture in a classroom: the professor speaks, the board highlights what
/// is being discussed, then a short knowledge check closes the session.
class LectureScreen extends StatefulWidget {
  const LectureScreen({super.key, required this.life, required this.course});
  final LifeSession life;
  final Course course;

  @override
  State<LectureScreen> createState() => _LectureScreenState();
}

enum _Phase { lecture, check, done }

class _LectureScreenState extends State<LectureScreen> with SingleTickerProviderStateMixin {
  late final Lecture lecture;
  late final AnimationController _anim;
  int line = 0;
  bool auto = true;
  Timer? _timer;
  _Phase phase = _Phase.lecture;
  final List<int?> answers = <int?>[];
  int checkIndex = 0;
  double score = 0;
  bool asking = false;
  final TextEditingController question = TextEditingController();
  final List<(bool, String)> qa = <(bool, String)>[];
  bool committed = false;

  @override
  void initState() {
    super.initState();
    final int number = widget.life.game.university.progress(widget.course.id).lectures + 1;
    lecture = LectureLibrary.forCourse(widget.course, number);
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    question.dispose();
    super.dispose();
  }

  void _schedule() {
    _timer?.cancel();
    if (!auto || phase != _Phase.lecture) return;
    final int len = lecture.lines[line].text.length;
    _timer = Timer(Duration(milliseconds: 1800 + len * 38), _next);
  }

  void _next() {
    if (!mounted) return;
    if (line + 1 < lecture.lines.length) {
      setState(() => line++);
      _schedule();
    } else {
      setState(() {
        phase = _Phase.check;
        answers.clear();
        checkIndex = 0;
      });
    }
  }

  void _answer(int i) {
    setState(() {
      answers.add(i);
      if (answers.length >= lecture.check.length) {
        score = LectureLibrary.scoreCheck(lecture, answers);
        phase = _Phase.done;
      } else {
        checkIndex++;
      }
    });
  }

  Future<void> _commit() async {
    if (committed) return;
    committed = true;
    widget.life.report(widget.life.game.attendLecture(widget.course.id, checkScore: score), animate: AvatarAction.study);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _ask() async {
    final String q = question.text.trim();
    if (q.isEmpty) return;
    question.clear();
    setState(() {
      qa.add((true, q));
      asking = true;
    });
    final String a = await const ProfessorService().answer(widget.course, lecture.title, q);
    if (!mounted) return;
    setState(() {
      qa.add((false, a));
      asking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final LectureLine current = lecture.lines[line];
    final Set<String> hl = phase == _Phase.lecture ? LectureLibrary.highlightsFor(lecture, current).toSet() : <String>{};
    return LifePage(
      title: lecture.title,
      subtitle: widget.course.name,
      child: Column(children: <Widget>[
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            decoration: BoxDecoration(color: const Color(0xFF0F2A24), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF3F6F5F), width: 3)),
            child: Row(children: <Widget>[
              Expanded(
                child: lecture.board == LectureBoard.body
                    ? AnimatedBuilder(animation: _anim, builder: (_, __) => CustomPaint(painter: BodyBoardPainter(highlighted: hl, t: _anim.value * 6.283), size: Size.infinite))
                    : _TermBoard(terms: lecture.terms, active: hl, title: widget.course.name),
              ),
              SizedBox(width: 120, child: AvatarView(look: _professorLook, action: AvatarAction.talk, emotion: AvatarEmotion.happy, size: 120)),
            ]),
          ),
        ),
        Expanded(flex: 4, child: _lower()),
      ]),
    );
  }

  AvatarLook get _professorLook => AvatarLook.fromProfile(AvatarProfile(name: 'Professor', skinTone: 0xFF8D5524, hairStyle: 'short', hairColor: 0xFF9CA3AF));

  Widget _lower() {
    switch (phase) {
      case _Phase.lecture:
        return ListView(padding: const EdgeInsets.all(12), children: <Widget>[
          Panel(
            border: LifeColors.teal,
            child: Text('🧑‍🏫  ${lecture.lines[line].text}', style: const TextStyle(fontSize: 16, height: 1.45)),
          ),
          const SizedBox(height: 8),
          Row(children: <Widget>[
            Text('${line + 1}/${lecture.lines.length}', style: const TextStyle(color: LifeColors.muted)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => setState(() {
                auto = !auto;
                _schedule();
              }),
              icon: Icon(auto ? Icons.pause_rounded : Icons.play_arrow_rounded),
              label: Text(auto ? 'Pause' : 'Auto-play'),
            ),
            FilledButton(onPressed: () {
              _timer?.cancel();
              _next();
            }, child: const Text('Next')),
          ]),
          const SizedBox(height: 6),
          _askBox(),
        ]);
      case _Phase.check:
        final ExamQuestion q = lecture.check[checkIndex];
        return ListView(padding: const EdgeInsets.all(12), children: <Widget>[
          Text('Knowledge check ${checkIndex + 1}/${lecture.check.length}', style: const TextStyle(color: LifeColors.muted)),
          const SizedBox(height: 6),
          Text(q.prompt, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (int i = 0; i < q.options.length; i++)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: OutlinedButton(onPressed: () => _answer(i), child: Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(q.options[i]))))),
        ]);
      case _Phase.done:
        return ListView(padding: const EdgeInsets.all(12), children: <Widget>[
          Panel(
            border: score >= 0.5 ? LifeColors.green : LifeColors.amber,
            child: Column(children: <Widget>[
              Text('Knowledge check: ${(score * 100).round()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              for (int i = 0; i < lecture.check.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text('${answers[i] == lecture.check[i].correct ? '✅' : '❌'} ${lecture.check[i].explanation}', style: const TextStyle(fontSize: 13)),
                ),
            ]),
          ),
          const SizedBox(height: 10),
          BigButton(label: 'Finish lecture (2 hours)', icon: Icons.check_rounded, color: LifeColors.green, onPressed: _commit),
          const SizedBox(height: 8),
          _askBox(),
        ]);
    }
  }

  Widget _askBox() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        for (final (bool, String) m in qa)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(m.$1 ? '🙋 ${m.$2}' : '🧑‍🏫 ${m.$2}', style: TextStyle(color: m.$1 ? LifeColors.muted : LifeColors.text, fontSize: 13.5))),
        if (asking) const Text('…', style: TextStyle(color: LifeColors.muted)),
        Row(children: <Widget>[
          Expanded(child: TextField(controller: question, onSubmitted: (_) => _ask(), decoration: const InputDecoration(hintText: 'Ask the professor a question…', isDense: true, border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: asking ? null : _ask, icon: const Icon(Icons.help_outline_rounded)),
        ]),
      ]);
}

class _TermBoard extends StatelessWidget {
  const _TermBoard({required this.terms, required this.active, required this.title});
  final Map<String, String> terms;
  final Set<String> active;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(title, style: const TextStyle(color: Color(0xFFBFE9D8), fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
            for (final MapEntry<String, String> e in terms.entries)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: active.contains(e.key) ? const Color(0xFFFDE047) : Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: active.contains(e.key) ? Colors.white : Colors.white24),
                ),
                child: Text(e.value, style: TextStyle(color: active.contains(e.key) ? Colors.black : Colors.white70, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
          ]),
        ]),
      );
}
