import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ai/career_ai.dart';
import '../engine/interview_engine.dart';
import '../engine/text_rubric.dart';
import '../model/career_models.dart';
import '../model/content_models.dart';
import '../store/career_sim_store.dart';
import 'common.dart';
import 'job_screens.dart';
import 'task_views.dart';
import 'gg_kit.dart';

class _Line {
  const _Line(this.fromInterviewer, this.text);
  final bool fromInterviewer;
  final String text;
}

/// Live interview. The interviewer adapts the next question to the validated
/// score of the previous answer; the candidate then asks their own questions.
class InterviewScreen extends StatefulWidget {
  const InterviewScreen({
    super.key,
    required this.plan,
    required this.company,
    required this.applicationId,
    required this.day,
    required this.onFinished,
    this.practice = false,
  });

  final InterviewPlan plan;
  final CompanyProfile company;
  final String applicationId;
  final int day;
  final bool practice;
  final Future<void> Function(InterviewRecord record) onFinished;

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  late final InterviewSession _s = InterviewSession(
    plan: widget.plan,
    company: widget.company,
    applicationId: widget.applicationId,
    day: widget.day,
    practice: widget.practice,
  );
  final List<_Line> _lines = <_Line>[];
  final TextEditingController _answer = TextEditingController();
  final TextEditingController _ask = TextEditingController();
  InterviewRecord? _record;
  bool _saving = false;

  static const List<String> _suggested = <String>[
    'What does success look like in the first three months?',
    'How is the team structured and who would I work with?',
    'What training and mentoring do new starters get?',
    'What are the next steps in the process?',
  ];

  @override
  void initState() {
    super.initState();
    _lines.add(_Line(true, widget.plan.opening));
    _pushQuestion();
  }

  @override
  void dispose() {
    _answer.dispose();
    _ask.dispose();
    super.dispose();
  }

  void _pushQuestion() {
    final InterviewQuestion? q = _s.current;
    if (q != null) {
      _lines.add(_Line(true, q.prompt));
    } else {
      _lines.add(const _Line(true, 'That\'s all from me. What would you like to ask us?'));
    }
  }

  CareerAi? get _ai {
    try {
      return context.read<CareerSimStore>().ai;
    } catch (_) {
      return null;
    }
  }

  /// Replaces line [i] with the AI's spoken version when it arrives. The
  /// scripted line stays if AI is unavailable or adds anything new.
  Future<void> _voice(int i, String scripted, String heard) async {
    final CareerAi? ai = _ai;
    if (ai == null || scripted.isEmpty) return;
    final String? v = await ai.voice(character: 'the interviewer, ${widget.plan.interviewer}, in a job interview', scripted: scripted, heard: heard);
    if (v == null || !mounted || i >= _lines.length || _lines[i].text != scripted) return;
    setState(() => _lines[i] = _Line(true, v));
  }

  void _afterAnswer(String shown) {
    _lines.add(_Line(false, shown));
    _lines.add(_Line(true, _s.lastReaction));
    _voice(_lines.length - 1, _s.lastReaction, shown);
    _pushQuestion();
  }

  static const Map<String, String> _topicOptions = <String, String>{
    'team': 'who they would work with: the team, colleagues or manager',
    'training': 'training, learning, mentoring or career growth',
    'success': 'how success or performance is measured or what is expected',
    'culture': 'the culture, values or what a typical day is like',
    'tools': 'tools, software, technology or equipment used',
    'next': 'next steps, timeline or how the hiring decision is made',
    'salary': 'pay, salary or benefits',
  };

  String _replyFor(String topic) => switch (topic) {
        'team' => widget.company.team,
        'training' => widget.company.training,
        'success' => widget.company.success,
        'culture' => widget.company.culture,
        'tools' => widget.company.tools,
        'next' => widget.company.nextSteps,
        _ => 'Compensation and benefits are set out in writing if we make an offer.',
      };

  /// When the rules did not recognise the question, AI works out what it is
  /// about and the interviewer answers from the company's written profile.
  Future<void> _understand(int i, String question, String fallback) async {
    final CareerAi? ai = _ai;
    if (ai == null) return;
    final String? topic = await ai.classify(text: question, options: _topicOptions, context: 'A job candidate asked the interviewer a question.');
    if (topic == null || !mounted || i >= _lines.length || _lines[i].text != fallback) return;
    setState(() => _lines[i] = _Line(true, _replyFor(topic)));
  }

  void _submitOpen() {
    final String t = _answer.text.trim();
    if (t.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Type your answer first.')));
      return;
    }
    setState(() {
      _s.answerOpen(t);
      _answer.clear();
      _afterAnswer(t);
    });
  }

  void _submitChoice(int i) {
    final String text = _s.current!.options[i];
    setState(() {
      _s.answerChoice(i);
      _afterAnswer(text);
    });
  }

  Future<void> _submitPractical(TaskResult r) async {
    setState(() {
      _s.answerPractical(r, 'Practical submitted.');
      _afterAnswer('[Practical submitted]');
    });
  }

  void _askQuestion(String q) {
    if (q.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Type a question for the interviewer.')));
      return;
    }
    try {
      final CandidateAnswer a = _s.ask(q);
      setState(() {
        _lines.add(_Line(false, q.trim()));
        _lines.add(_Line(true, a.reply));
        _ask.clear();
      });
      if (a.topic.isEmpty && a.reply.startsWith('I don\'t have a specific answer')) _understand(_lines.length - 1, q.trim(), a.reply);
    } on StateError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final InterviewRecord r = _s.finish();
    final bool? ok = await runCareerAction<bool>(context, () async {
      await widget.onFinished(r);
      return true;
    });
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (ok == true) _record = r;
    });
  }

  Widget _bubble(_Line l) => Align(
        alignment: l.fromInterviewer ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: l.fromInterviewer ? GG.panel2 : Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(l.text, style: TextStyle(color: GG.ink, height: 1.4)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final InterviewRecord? rec = _record;
    final InterviewQuestion? q = _s.current;
    return Scaffold(
      appBar: AppBar(title: Text(widget.practice ? 'Mock interview' : 'Interview · ${widget.company.name}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text('${widget.plan.interviewer} · ${widget.plan.interviewerRole}', style: TextStyle(color: GG.mute)),
          const SizedBox(height: 10),
          for (final _Line l in _lines) _bubble(l),
          const SizedBox(height: 8),
          if (rec != null) ...<Widget>[
            InterviewReportCard(record: rec),
            AiAssistPanel(
              role: CareerAiRole.interviewer,
              contextText: 'Interview transcript:\n${rec.turns.map((InterviewTurn t) => 'Q: ${t.prompt}\nA: ${t.answer}').join('\n')}',
              suggestion: 'How can I structure my answers better next time?',
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey<String>('interview_done'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ] else if (q != null) ...<Widget>[
            if (q.practical != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: GG.stroke), borderRadius: BorderRadius.circular(12)),
                child: TaskView(key: ValueKey<String>('practical_${q.id}'), spec: q.practical!, allowRetry: false, onGraded: _submitPractical),
              )
            else if (q.isChoice)
              Column(children: <Widget>[
                for (int i = 0; i < q.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        key: ValueKey<String>('iv_opt_$i'),
                        onPressed: () => _submitChoice(i),
                        child: Align(alignment: Alignment.centerLeft, child: Text(q.options[i])),
                      ),
                    ),
                  ),
              ])
            else ...<Widget>[
              WrittenField(
                fieldKey: const ValueKey<String>('iv_answer'),
                controller: _answer,
                rubric: const <Concept>[],
                minWords: q.minWords,
                label: 'Your answer',
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const ValueKey<String>('iv_send'),
                onPressed: _submitOpen,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Answer'),
              ),
            ],
          ] else ...<Widget>[
            Text('Your questions (${_s.candidateQuestions.length}/3)', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
              for (int i = 0; i < _suggested.length; i++)
                ActionChip(
                  key: ValueKey<String>('iv_suggest_$i'),
                  label: Text(_suggested[i]),
                  onPressed: _s.candidateQuestions.length >= 3 ? null : () => _askQuestion(_suggested[i]),
                ),
            ]),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey<String>('iv_ask'),
              controller: _ask,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Ask your own question'),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
              OutlinedButton(
                key: const ValueKey<String>('iv_ask_send'),
                onPressed: _s.candidateQuestions.length >= 3 ? null : () => _askQuestion(_ask.text),
                child: const Text('Ask'),
              ),
              FilledButton.icon(
                key: const ValueKey<String>('iv_finish'),
                onPressed: _saving ? null : _finish,
                icon: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.flag_rounded),
                label: const Text('Finish interview'),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}
