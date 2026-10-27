import 'package:flutter/material.dart';

import '../../education/skills.dart';
import '../../education/university.dart';
import '../../game/life_game.dart';
import '../life_session.dart';
import '../life_widgets.dart';

enum CampusTab { degrees, lectures, study, exams }

class CampusScreen extends StatelessWidget {
  const CampusScreen({super.key, required this.life, this.tab = CampusTab.degrees});
  final LifeSession life;
  final CampusTab tab;

  @override
  Widget build(BuildContext context) => Theme(
        data: lifeTheme(),
        child: DefaultTabController(
          length: 4,
          initialIndex: tab.index,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('🎓 Glowland University'),
              bottom: const TabBar(isScrollable: true, tabs: <Tab>[Tab(text: 'Degrees'), Tab(text: 'Lectures'), Tab(text: 'Study'), Tab(text: 'Exams')]),
            ),
            body: ListenableBuilder(
              listenable: life,
              builder: (BuildContext context, _) => TabBarView(children: <Widget>[_degrees(context), _lectures(context), _study(context), _exams(context)]),
            ),
          ),
        ),
      );

  List<Course> _enrolled() {
    final Degree? d = life.game.university.activeDegree;
    if (d == null) return <Course>[];
    return d.courses.where((Course c) {
      final CourseProgress p = life.game.university.progress(c.id);
      return p.enrolled && !p.passed;
    }).toList();
  }

  Widget _degrees(BuildContext context) {
    final LifeGame g = life.game;
    final UniversityRecord u = g.university;
    return ListView(padding: const EdgeInsets.all(14), children: <Widget>[
      Text('Your education: ${g.educationRank == 0 ? 'High school' : const <String>['High school', 'Associate degree', "Bachelor's degree", "Master's degree", 'Doctorate'][g.educationRank]}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      const SizedBox(height: 4),
      const Text('Each course: attend 4 lectures, study 4 hours, then pass the exam (75%+). Finish every course to graduate.', style: TextStyle(color: LifeColors.muted, fontSize: 12.5)),
      for (final Degree d in UniversityCatalog.degrees) ...<Widget>[
        const SizedBox(height: 12),
        Panel(
          border: u.activeDegreeId == d.id ? LifeColors.blue : (u.has(d.id) ? LifeColors.green : null),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Row(children: <Widget>[
              Text(d.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(d.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text('${u.passedIn(d)}/${d.courses.length} courses passed · tuition ${money(d.totalTuition)}', style: const TextStyle(color: LifeColors.muted, fontSize: 12.5)),
              ])),
              if (u.has(d.id)) const Tag('Graduated', color: LifeColors.green) else if (u.activeDegreeId == d.id) const Tag('Enrolled', color: LifeColors.blue),
            ]),
            if (d.prereqRank > 0 && !u.has(d.id)) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Requires a bachelor\'s degree first.', style: TextStyle(color: g.educationRank >= d.prereqRank ? LifeColors.green : LifeColors.amber, fontSize: 12.5))),
            const SizedBox(height: 8),
            if (!u.has(d.id) && u.activeDegreeId != d.id)
              BigButton(label: 'Enrol', icon: Icons.school_rounded, onPressed: UniversityEngine.canEnrolDegree(u, d, g.educationRank) != null ? null : () => life.report(g.enrolDegree(d.id)))
            else if (u.activeDegreeId == d.id) ...<Widget>[
              for (final Course c in d.courses) _courseRow(c),
              const SizedBox(height: 6),
              TextButton(onPressed: () => life.report(g.withdrawDegree()), child: const Text('Withdraw from degree')),
            ],
            if (!u.has(d.id) && u.activeDegreeId != d.id && UniversityEngine.canEnrolDegree(u, d, g.educationRank) != null)
              Padding(padding: const EdgeInsets.only(top: 6), child: Text(UniversityEngine.canEnrolDegree(u, d, g.educationRank)!, style: const TextStyle(color: LifeColors.amber, fontSize: 12.5))),
          ]),
        ),
      ],
    ]);
  }

  Widget _courseRow(Course c) {
    final CourseProgress p = life.game.university.progress(c.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: <Widget>[
        Icon(p.passed ? Icons.check_circle_rounded : (p.enrolled ? Icons.timelapse_rounded : Icons.circle_outlined), color: p.passed ? LifeColors.green : (p.enrolled ? LifeColors.blue : LifeColors.muted)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(p.passed ? 'Passed ${(p.bestScore * 100).round()}%' : (p.enrolled ? 'Lectures ${p.lectures}/${CourseRequirements.lecturesRequired} · Study ${p.studyMinutes ~/ 60}/${CourseRequirements.studyMinutesRequired ~/ 60}h' : c.summary), style: const TextStyle(color: LifeColors.muted, fontSize: 12)),
        ])),
        if (!p.enrolled && !p.passed) OutlinedButton(onPressed: () => life.report(life.game.enrolCourse(c.id)), child: Text('Enrol ${money(c.tuition)}')),
      ]),
    );
  }

  Widget _lectures(BuildContext context) {
    final LifeGame g = life.game;
    final List<Course> list = _enrolled();
    final bool open = UniversityEngine.lectureOpen(g.day, g.minute);
    return ListView(padding: const EdgeInsets.all(14), children: <Widget>[
      Panel(child: Text(open ? 'Lectures are in session. Each lecture takes 2 hours.' : 'Lectures run on weekdays 9am–5pm. It is ${clockLabel(g.minute)} now.', style: TextStyle(color: open ? LifeColors.green : LifeColors.amber, fontWeight: FontWeight.w700))),
      const SizedBox(height: 10),
      if (list.isEmpty) const Panel(child: Text('Enrol in a degree and its courses first (Degrees tab).')),
      for (final Course c in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(c.summary, style: const TextStyle(color: LifeColors.muted, fontSize: 12.5)),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: g.university.progress(c.id).lectures / CourseRequirements.lecturesRequired, minHeight: 8, backgroundColor: Colors.white12),
              Text('Lectures ${g.university.progress(c.id).lectures}/${CourseRequirements.lecturesRequired}', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              BigButton(label: 'Attend lecture', icon: Icons.record_voice_over_rounded, onPressed: () => life.report(g.attendLecture(c.id))),
            ]),
          ),
        ),
    ]);
  }

  Widget _study(BuildContext context) {
    final LifeGame g = life.game;
    final List<Course> list = _enrolled();
    return ListView(padding: const EdgeInsets.all(14), children: <Widget>[
      if (list.isEmpty) const Panel(child: Text('No enrolled courses. You can still read at the library shelves to build general knowledge.')),
      for (final Course c in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: (g.university.progress(c.id).studyMinutes / CourseRequirements.studyMinutesRequired).clamp(0.0, 1.0), minHeight: 8, backgroundColor: Colors.white12),
              Text('Study ${g.university.progress(c.id).studyMinutes} / ${CourseRequirements.studyMinutesRequired} min', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              BigButton(label: 'Study for 1 hour', icon: Icons.menu_book_rounded, color: LifeColors.teal, onPressed: () => life.report(g.studyCourse(c.id))),
            ]),
          ),
        ),
      BigButton(label: 'Read general books (1 hour)', icon: Icons.local_library_rounded, color: LifeColors.purple, onPressed: () => life.report(g.selfStudy())),
    ]);
  }

  Widget _exams(BuildContext context) {
    final LifeGame g = life.game;
    final List<Course> list = _enrolled();
    return ListView(padding: const EdgeInsets.all(14), children: <Widget>[
      Panel(child: Text('Exam fee ${money(CourseRequirements.examFee)} · pass mark ${(CourseRequirements.passMark * 100).round()}% · weekdays 9am–5pm.', style: const TextStyle(color: LifeColors.muted))),
      const SizedBox(height: 10),
      if (list.isEmpty) const Panel(child: Text('No courses to examine.')),
      for (final Course c in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(g.university.progress(c.id).examReady ? 'Ready to sit the exam.' : 'Not ready: ${g.university.progress(c.id).lectures}/4 lectures, ${g.university.progress(c.id).studyMinutes}/240 study minutes.', style: TextStyle(color: g.university.progress(c.id).examReady ? LifeColors.green : LifeColors.amber)),
              if (g.university.progress(c.id).attempts > 0) Text('Attempts ${g.university.progress(c.id).attempts} · best ${(g.university.progress(c.id).bestScore * 100).round()}%', style: const TextStyle(fontSize: 12, color: LifeColors.muted)),
              const SizedBox(height: 8),
              BigButton(
                label: 'Sit exam',
                icon: Icons.edit_note_rounded,
                color: LifeColors.red,
                onPressed: !g.university.progress(c.id).examReady
                    ? null
                    : () {
                        final ({List<ExamQuestion>? questions, String? error}) ex = g.beginExam(c.id);
                        if (ex.questions == null) {
                          life.say(ex.error ?? 'Cannot sit the exam now.');
                          return;
                        }
                        life.changed();
                        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ExamScreen(life: life, course: c, questions: ex.questions!)));
                      },
              ),
            ]),
          ),
        ),
    ]);
  }
}

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key, required this.life, required this.course, required this.questions});
  final LifeSession life;
  final Course course;
  final List<ExamQuestion> questions;
  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late final List<int?> _answers = List<int?>.filled(widget.questions.length, null);
  int _i = 0;
  ExamResult? _res;
  Degree? _graduated;

  void _finish() {
    final ({ExamResult result, Degree? graduated}) o = widget.life.game.submitExam(widget.course.id, widget.questions, _answers);
    widget.life.changed();
    setState(() {
      _res = o.result;
      _graduated = o.graduated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ExamResult? r = _res;
    if (r != null) {
      return LifePage(
        title: 'Exam result',
        subtitle: widget.course.name,
        child: ListView(padding: const EdgeInsets.all(16), children: <Widget>[
          Panel(
            border: r.passed ? LifeColors.green : LifeColors.red,
            child: Column(children: <Widget>[
              Text(r.passed ? '🎉 Passed' : 'Not passed', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              Text('${(r.score * 100).round()}%', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900)),
              if (_graduated != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('🎓 You graduated with ${_graduated!.name}!', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, color: LifeColors.green))),
              if (!r.passed) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Study another couple of hours, then try again.', style: TextStyle(color: LifeColors.muted))),
            ]),
          ),
          if (r.wrong.isNotEmpty) ...<Widget>[
            const SectionTitle('Review'),
            for (final String w in r.wrong) Padding(padding: const EdgeInsets.only(bottom: 8), child: Panel(child: Text(w))),
          ],
          const SizedBox(height: 12),
          BigButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
        ]),
      );
    }
    final ExamQuestion q = widget.questions[_i];
    return LifePage(
      title: widget.course.name,
      subtitle: 'Question ${_i + 1} of ${widget.questions.length}',
      child: ListView(padding: const EdgeInsets.all(16), children: <Widget>[
        LinearProgressIndicator(value: _i / widget.questions.length, minHeight: 6, backgroundColor: Colors.white12),
        const SizedBox(height: 16),
        Text(q.prompt, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.35)),
        const SizedBox(height: 14),
        for (int k = 0; k < q.options.length; k++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Panel(
              color: _answers[_i] == k ? LifeColors.blue.withValues(alpha: 0.25) : null,
              border: _answers[_i] == k ? LifeColors.blue : null,
              onTap: () => setState(() => _answers[_i] = k),
              child: Row(children: <Widget>[Icon(_answers[_i] == k ? Icons.radio_button_checked : Icons.radio_button_off, color: LifeColors.blue), const SizedBox(width: 10), Expanded(child: Text(q.options[k]))]),
            ),
          ),
        const SizedBox(height: 12),
        BigButton(
          label: _i == widget.questions.length - 1 ? 'Submit exam' : 'Next question',
          icon: Icons.arrow_forward_rounded,
          onPressed: _answers[_i] == null ? null : () => _i == widget.questions.length - 1 ? _finish() : setState(() => _i++),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Certifications (library certification desk)
// ---------------------------------------------------------------------------

class CertScreen extends StatelessWidget {
  const CertScreen({super.key, required this.life});
  final LifeSession life;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: life,
        builder: (BuildContext context, _) {
          final LifeGame g = life.game;
          return LifePage(
            title: '🏅 Certificates',
            subtitle: 'Study at the library desk',
            child: ListView(padding: const EdgeInsets.all(14), children: <Widget>[
              for (final Certification c in CertificationCatalog.all)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Panel(
                    border: g.skills.certifications.contains(c.id) ? LifeColors.green : null,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Row(children: <Widget>[
                        Expanded(child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                        if (g.skills.certifications.contains(c.id)) const Tag('Earned', color: LifeColors.green) else Tag(money(c.cost), color: LifeColors.amber),
                      ]),
                      Text('${c.studyHours} hours · boosts ${Skills.nameOf(c.skill)} +${c.skillGain.round()}', style: const TextStyle(color: LifeColors.muted, fontSize: 12.5)),
                      if (!g.skills.certifications.contains(c.id)) ...<Widget>[
                        const SizedBox(height: 6),
                        LinearProgressIndicator(value: ((g.certMinutes[c.id] ?? 0) / (c.studyHours * 60)).clamp(0.0, 1.0), minHeight: 8, backgroundColor: Colors.white12),
                        const SizedBox(height: 8),
                        BigButton(label: 'Study 1 hour', icon: Icons.menu_book_rounded, color: LifeColors.teal, onPressed: () => life.report(g.studyCertification(c.id))),
                      ],
                    ]),
                  ),
                ),
            ]),
          );
        },
      );
}
