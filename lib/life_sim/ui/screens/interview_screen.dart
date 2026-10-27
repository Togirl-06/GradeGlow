import 'package:flutter/material.dart';

import '../../avatar/avatar_profile.dart';
import '../../employment/application.dart';
import '../../interview/interview_judge.dart';
import '../../interview/interview_session.dart';
import '../life_session.dart';
import '../life_widgets.dart';
import '../painters/avatar_painter.dart';

class _Msg {
  _Msg(this.fromMe, this.text);
  final bool fromMe;
  final String text;
}

/// Playable AI interview. One question at a time; scored on seven dimensions.
class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key, required this.life, required this.interview, this.application});
  final LifeSession life;
  final InterviewSession interview;

  /// Null for practice interviews.
  final ApplicationRecord? application;

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController _ctl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_Msg> _msgs = <_Msg>[];
  bool _busy = false;
  InterviewResult? _result;
  bool _recorded = false;

  InterviewSession get s => widget.interview;

  @override
  void initState() {
    super.initState();
    _msgs.add(_Msg(false, s.greeting));
    _msgs.add(_Msg(false, s.currentPrompt));
  }

  @override
  void dispose() {
    _ctl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent + 200, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  Future<void> _send() async {
    final String text = _ctl.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _msgs.add(_Msg(true, text));
      _ctl.clear();
    });
    _scrollDown();
    try {
      final InterviewTurn turn = await s.submit(text);
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg(false, turn.evaluation.reaction));
        if (!s.finished) {
          _msgs.add(_Msg(false, s.currentPrompt));
        } else {
          _msgs.add(_Msg(false, s.closingLine(null)));
          _result = s.result(applicationId: widget.application?.id ?? 'practice');
        }
        _busy = false;
      });
      if (_result != null) _record();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      widget.life.say('Something went wrong with that answer. Please try again.');
    }
    _scrollDown();
  }

  void _record() {
    if (_recorded || _result == null) return;
    _recorded = true;
    final LifeSession l = widget.life;
    if (widget.application == null) {
      l.game.finishPractice(_result!);
    } else {
      l.game.finishInterview(widget.application!, _result!);
    }
    l.changed();
  }

  @override
  Widget build(BuildContext context) {
    final InterviewerPersonaView who = s.interviewer;
    final InterviewerPersonaLike persona = InterviewerPersonaLike(who);
    return LifePage(
      title: s.practice ? 'Practice interview' : 'Interview · ${s.employer.name}',
      subtitle: _result != null ? 'Finished' : 'Question ${s.questionNumber} of ${s.totalQuestions}',
      child: _result != null ? _ResultView(result: _result!, practice: s.practice, employer: s.employer.name, role: s.listing.title) : Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Row(children: <Widget>[
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(color: LifeColors.panel2, borderRadius: BorderRadius.circular(16), border: Border.all(color: LifeColors.line)),
              child: AvatarView(look: persona.look, bust: true, size: 70, emotion: _busy ? AvatarEmotion.neutral : AvatarEmotion.happy, action: _busy ? AvatarAction.idle : AvatarAction.talk, t: DateTime.now().millisecondsSinceEpoch / 1000),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(who.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text('${who.title} · ${s.employer.name}', style: const TextStyle(color: LifeColors.muted, fontSize: 12)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: (s.questionNumber - 1) / s.totalQuestions, minHeight: 6, backgroundColor: Colors.white12),
                ),
              ]),
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(14),
            itemCount: _msgs.length + (_busy ? 1 : 0),
            itemBuilder: (BuildContext c, int i) {
              if (i >= _msgs.length) return const _Typing();
              final _Msg m = _msgs[i];
              return Align(
                alignment: m.fromMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 520),
                  decoration: BoxDecoration(
                    color: m.fromMe ? LifeColors.blue : LifeColors.panel2,
                    borderRadius: BorderRadius.circular(16),
                    border: m.fromMe ? null : Border.all(color: LifeColors.line),
                  ),
                  child: Text(m.text, style: const TextStyle(fontSize: 14.5, height: 1.35)),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
            Expanded(
              child: TextField(
                controller: _ctl,
                enabled: !_busy,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(hintText: 'Type your answer… (give examples and results)'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _busy ? null : _send, icon: const Icon(Icons.send_rounded), style: IconButton.styleFrom(backgroundColor: LifeColors.blue, padding: const EdgeInsets.all(14))),
          ]),
        ),
      ]),
    );
  }
}

/// Look helper for the interviewer's portrait.
class InterviewerPersonaLike {
  InterviewerPersonaLike(InterviewerPersonaView v)
      : look = AvatarLook.fromPersona(InterviewerLike(
          skinTone: v.persona.skinTone,
          hairColor: v.persona.hairColor,
          outfitColor: v.persona.outfitColor,
          hairStyle: v.persona.hairStyle,
        ));
  final AvatarLook look;
}

class _Typing extends StatelessWidget {
  const _Typing();
  @override
  Widget build(BuildContext context) => const Align(
        alignment: Alignment.centerLeft,
        child: Padding(padding: EdgeInsets.all(8), child: Text('The interviewer is thinking…', style: TextStyle(color: LifeColors.muted, fontStyle: FontStyle.italic))),
      );
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result, required this.practice, required this.employer, required this.role});
  final InterviewResult result;
  final bool practice;
  final String employer;
  final String role;

  @override
  Widget build(BuildContext context) {
    final HireDecision d = result.decision;
    final Color c = practice ? LifeColors.blue : (d == HireDecision.offer ? LifeColors.green : (d == HireDecision.waitlist || d == HireDecision.secondInterview ? LifeColors.amber : LifeColors.red));
    final String headline = practice
        ? 'Practice complete'
        : (d == HireDecision.offer ? 'You received an offer!' : (d == HireDecision.secondInterview ? 'Invited to a final interview' : (d == HireDecision.waitlist ? 'You are on the waiting list' : 'Not selected this time')));
    return ListView(padding: const EdgeInsets.all(16), children: <Widget>[
      Panel(
        border: c,
        child: Column(children: <Widget>[
          Text(headline, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c)),
          const SizedBox(height: 6),
          Text('${result.interviewScore.round()}/100 · ${result.grade}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(result.closingLine, textAlign: TextAlign.center, style: const TextStyle(color: LifeColors.muted)),
          if (!practice) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              d == HireDecision.offer
                  ? 'Check your email for the offer from $employer, then review and sign your contract from your phone.'
                  : d == HireDecision.secondInterview
                      ? 'Check your email and calendar for the final interview time at $employer.'
                  : d == HireDecision.waitlist
                      ? 'Keep an eye on your email — $employer will decide in the next few days.'
                      : 'You can apply again after a short cooldown. Use the advice below to prepare.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ]),
      ),
      const SectionTitle('Your scores'),
      Panel(
        child: Column(children: <Widget>[
          for (final String k in InterviewDims.all)
            NeedBar(label: InterviewDims.labels[k] ?? k, value: ((result.dimensionAverages[k] ?? 0) * 10), emoji: '•', color: LifeColors.blue),
        ]),
      ),
      if (result.strengths.isNotEmpty) ...<Widget>[
        const SectionTitle('What went well'),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[for (final String s in result.strengths) Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text('✅ $s'))])),
      ],
      if (result.improvements.isNotEmpty) ...<Widget>[
        const SectionTitle('How to improve'),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[for (final String s in result.improvements) Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text('💡 $s'))])),
      ],
      if (result.questionNotes.isNotEmpty) ...<Widget>[
        const SectionTitle('Question by question'),
        for (final String n in result.questionNotes) Padding(padding: const EdgeInsets.only(bottom: 8), child: Panel(child: Text(n, style: const TextStyle(fontSize: 13)))),
      ],
      const SizedBox(height: 14),
      BigButton(label: 'Done', icon: Icons.check_rounded, onPressed: () => Navigator.of(context).pop()),
      const SizedBox(height: 20),
    ]);
  }
}
