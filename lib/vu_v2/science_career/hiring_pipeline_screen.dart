import 'package:flutter/material.dart';

import 'coding_challenge_bank.dart';
import 'job_catalog.dart';
import 'science_career_content.dart';
import 'science_career_progress.dart';
import 'science_career_theme.dart';

/// Recruiter call → Online assessment → Technical interview for one job.
class HiringPipelineScreen extends StatefulWidget {
  const HiringPipelineScreen({
    super.key,
    required this.progress,
    required this.job,
  });

  final ScienceCareerProgress progress;
  final JobListing job;

  @override
  State<HiringPipelineScreen> createState() => _HiringPipelineScreenState();
}

class _HiringPipelineScreenState extends State<HiringPipelineScreen> {
  String? _activeStage;

  String get _status => widget.progress.statusFor(widget.job.id);

  @override
  Widget build(BuildContext context) {
    if (_activeStage == 'recruiter') {
      return _RecruiterCallStage(
        job: widget.job,
        progress: widget.progress,
        onDone: (bool passed) async {
          await widget.progress.completePipelineStage(
            jobId: widget.job.id,
            company: widget.job.company,
            roleTitle: widget.job.title,
            stage: 'recruiter',
            passed: passed,
          );
          if (!mounted) return;
          setState(() => _activeStage = null);
          _toast(passed
              ? 'Recruiter call passed — online assessment unlocked'
              : 'Not moving forward after recruiter call');
        },
        onBack: () => setState(() => _activeStage = null),
      );
    }
    if (_activeStage == 'oa') {
      return _OnlineAssessmentStage(
        job: widget.job,
        progress: widget.progress,
        onDone: (bool passed) async {
          await widget.progress.completePipelineStage(
            jobId: widget.job.id,
            company: widget.job.company,
            roleTitle: widget.job.title,
            stage: 'oa',
            passed: passed,
          );
          if (!mounted) return;
          setState(() => _activeStage = null);
          _toast(passed
              ? 'Assessment passed — technical interview unlocked'
              : 'Not moving forward after the assessment');
        },
        onBack: () => setState(() => _activeStage = null),
      );
    }
    if (_activeStage == 'technical') {
      return _TechnicalInterviewStage(
        job: widget.job,
        progress: widget.progress,
        onDone: (bool passed) async {
          await widget.progress.completePipelineStage(
            jobId: widget.job.id,
            company: widget.job.company,
            roleTitle: widget.job.title,
            stage: 'technical',
            passed: passed,
            payCentsHour: CareerJobs.isNorthwindJob(widget.job.id) ? 2800 : 2400,
          );
          if (!mounted) return;
          setState(() => _activeStage = null);
          _toast(passed
              ? 'Technical interview passed — check your offer email'
              : 'Not moving forward after the technical interview');
        },
        onBack: () => setState(() => _activeStage = null),
      );
    }

    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: SciCosmic.appBar(
        context: context,
        title: 'Interview loop',
        icon: Icons.route_rounded,
        subtitle: widget.job.company,
      ),
      body: SciStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: SciCosmic.panelBox(radius: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.job.title,
                    style: const TextStyle(
                      color: SciCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete all three interviews before an offer.',
                    style: TextStyle(
                      color: SciCosmic.mute.withValues(alpha: 0.95),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _StageCard(
              step: 1,
              title: 'Recruiter call',
              detail: '15–30 min · background, why this role, logistics',
              status: _status,
              stageId: 'recruiter',
              onStart: () => setState(() => _activeStage = 'recruiter'),
            ),
            _StageCard(
              step: 2,
              title: 'Online assessment',
              detail: '45–90 min · timed algorithms (1–3 problems)',
              status: _status,
              stageId: 'oa',
              onStart: () => setState(() => _activeStage = 'oa'),
            ),
            _StageCard(
              step: 3,
              title: 'Technical interview',
              detail: '45–60 min · live coding + optional debug task',
              status: _status,
              stageId: 'technical',
              onStart: () => setState(() => _activeStage = 'technical'),
            ),
            _StageCard(
              step: 4,
              title: 'Offer',
              detail: 'Compensation details · accept or decline',
              status: _status,
              stageId: 'offered',
              onStart: null,
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.step,
    required this.title,
    required this.detail,
    required this.status,
    required this.stageId,
    required this.onStart,
  });

  final int step;
  final String title;
  final String detail;
  final String status;
  final String stageId;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final int cur = ScienceCareerProgress.pipelineOrder.indexOf(status);
    final int mine = ScienceCareerProgress.pipelineOrder.indexOf(stageId);
    final bool done = cur > mine && mine >= 0;
    final bool active = status == stageId;
    final bool locked = !done && !active;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: SciCosmic.panelBox(radius: 14),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: done
                  ? SciCosmic.success.withValues(alpha: 0.25)
                  : active
                      ? SciCosmic.purple.withValues(alpha: 0.3)
                      : SciCosmic.panelAlt,
              child: Text(
                done ? '✓' : '$step',
                style: TextStyle(
                  color: done
                      ? SciCosmic.success
                      : active
                          ? SciCosmic.ink
                          : SciCosmic.mute,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      color: SciCosmic.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: SciCosmic.mute,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (active && onStart != null)
              FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(backgroundColor: SciCosmic.teal),
                child: const Text('Start'),
              )
            else
              SciCosmic.pill(
                done
                    ? 'Done'
                    : locked
                        ? 'Locked'
                        : 'Current',
                bg: done
                    ? SciCosmic.success.withValues(alpha: 0.2)
                    : SciCosmic.panelAlt,
                fg: done ? SciCosmic.success : SciCosmic.mute,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── 1. Recruiter call ──────────────────────────────────────────────────────

class _RecruiterCallStage extends StatefulWidget {
  const _RecruiterCallStage({
    required this.job,
    required this.progress,
    required this.onDone,
    required this.onBack,
  });

  final JobListing job;
  final ScienceCareerProgress progress;
  final ValueChanged<bool> onDone;
  final VoidCallback onBack;

  @override
  State<_RecruiterCallStage> createState() => _RecruiterCallStageState();
}

class _RecruiterCallStageState extends State<_RecruiterCallStage> {
  int _q = 0;
  int _score = 0;
  String? _picked;

  static const List<_Q> _questions = <_Q>[
    _Q(
      'Tell me about your background — what have you been building lately?',
      <String>[
        'I walk through one concrete project, my role, and a result.',
        'I say I like coding in general with no examples.',
        'I talk only about salary expectations.',
      ],
      0,
    ),
    _Q(
      'Why this role at our company?',
      <String>[
        'I connect the job skills to my projects and what I want to learn here.',
        'I say any job is fine as long as it pays.',
        'I criticize my past coursework.',
      ],
      0,
    ),
    _Q(
      'Logistics — when could you start, and are you open to the work mode?',
      <String>[
        'I give a clear start window and confirm remote/hybrid/office fit.',
        'I refuse to discuss schedule at all.',
        'I say I can only work past midnight.',
      ],
      0,
    ),
  ];

  void _submit() {
    if (_picked == null) return;
    final _Q cur = _questions[_q];
    final int idx = cur.options.indexOf(_picked!);
    if (idx == cur.correct) _score++;
    if (_q >= _questions.length - 1) {
      widget.onDone(_score >= 2);
      return;
    }
    setState(() {
      _q++;
      _picked = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _Q cur = _questions[_q];
    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: SciCosmic.appBar(
        context: context,
        title: 'Recruiter call',
        icon: Icons.phone_in_talk_rounded,
        subtitle: '15–30 min · ${_q + 1}/${_questions.length}',
        trailing: <Widget>[
          TextButton(onPressed: widget.onBack, child: const Text('Exit')),
        ],
      ),
      body: SciStarfield(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: SciCosmic.panelBox(radius: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Maya Okafor · ${widget.job.company}',
                    style: const TextStyle(
                      color: SciCosmic.electric,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cur.prompt,
                    style: const TextStyle(
                      color: SciCosmic.ink,
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...cur.options.map((String o) {
              final bool sel = _picked == o;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _picked = o),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel
                          ? SciCosmic.purple.withValues(alpha: 0.25)
                          : SciCosmic.panelAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? SciCosmic.purple : SciCosmic.stroke,
                      ),
                    ),
                    child: Text(
                      o,
                      style: const TextStyle(color: SciCosmic.ink, height: 1.35),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _picked == null ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: SciCosmic.teal,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                _q >= _questions.length - 1 ? 'Finish call' : 'Continue',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Q {
  const _Q(this.prompt, this.options, this.correct);
  final String prompt;
  final List<String> options;
  final int correct;
}

// ─── 2. Online assessment ───────────────────────────────────────────────────

class _OnlineAssessmentStage extends StatefulWidget {
  const _OnlineAssessmentStage({
    required this.job,
    required this.progress,
    required this.onDone,
    required this.onBack,
  });

  final JobListing job;
  final ScienceCareerProgress progress;
  final ValueChanged<bool> onDone;
  final VoidCallback onBack;

  @override
  State<_OnlineAssessmentStage> createState() => _OnlineAssessmentStageState();
}

class _OnlineAssessmentStageState extends State<_OnlineAssessmentStage> {
  late final List<CodingChallenge> _problems;
  int _i = 0;
  int _correct = 0;
  String? _picked;
  late int _secondsLeft;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final List<CodingChallenge> bank =
        CodingChallengeBank.forMajor(widget.progress.majorId);
    _problems = bank
        .where(
          (CodingChallenge c) =>
              c.topics.any(
                (String t) =>
                    t.toLowerCase().contains('array') ||
                    t.toLowerCase().contains('hash') ||
                    t.toLowerCase().contains('string') ||
                    t.toLowerCase().contains('algorithm'),
              ) ||
              c.difficulty == 'Easy' ||
              c.difficulty == 'Medium',
        )
        .take(2)
        .toList();
    if (_problems.isEmpty) {
      _problems.addAll(bank.take(2));
    }
    _secondsLeft = 45 * 60; // 45 min feel
    _tick();
  }

  void _finish(bool passed) {
    if (_finished) return;
    _finished = true;
    widget.onDone(passed);
  }

  void _tick() {
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted || _finished || _secondsLeft <= 0) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft == 0) {
        _finish(_correct >= 1);
        return;
      }
      _tick();
    });
  }

  void _submit() {
    if (_picked == null || _finished) return;
    final CodingChallenge p = _problems[_i];
    if (_picked == p.correctOptionId) _correct++;
    if (_i >= _problems.length - 1) {
      _finish(_correct >= 1);
      return;
    }
    setState(() {
      _i++;
      _picked = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CodingChallenge p = _problems[_i];
    final int m = _secondsLeft ~/ 60;
    final int s = _secondsLeft % 60;
    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: SciCosmic.appBar(
        context: context,
        title: 'Online assessment',
        icon: Icons.timer_outlined,
        subtitle: '45–90 min · ${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
        trailing: <Widget>[
          TextButton(onPressed: widget.onBack, child: const Text('Exit')),
        ],
      ),
      body: SciStarfield(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            SciCosmic.pill(
              'Problem ${_i + 1} of ${_problems.length} · HackerRank-style',
              bg: SciCosmic.orange.withValues(alpha: 0.15),
              fg: SciCosmic.orange,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: SciCosmic.panelBox(radius: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    p.title,
                    style: const TextStyle(
                      color: SciCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.prompt,
                    style: const TextStyle(color: SciCosmic.mute, height: 1.4),
                  ),
                  if (p.examples.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      p.examples,
                      style: const TextStyle(
                        color: SciCosmic.electric,
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...p.options.map((CodeOption o) {
              final bool sel = _picked == o.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _picked = o.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel
                          ? SciCosmic.purple.withValues(alpha: 0.25)
                          : SciCosmic.panelAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? SciCosmic.purple : SciCosmic.stroke,
                      ),
                    ),
                    child: Text(
                      o.code.isNotEmpty ? o.code : o.label,
                      style: const TextStyle(
                        color: SciCosmic.ink,
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              );
            }),
            FilledButton(
              onPressed: _picked == null ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: SciCosmic.teal,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                _i >= _problems.length - 1 ? 'Submit assessment' : 'Next problem',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 3. Technical interview ─────────────────────────────────────────────────

class _TechnicalInterviewStage extends StatefulWidget {
  const _TechnicalInterviewStage({
    required this.job,
    required this.progress,
    required this.onDone,
    required this.onBack,
  });

  final JobListing job;
  final ScienceCareerProgress progress;
  final ValueChanged<bool> onDone;
  final VoidCallback onBack;

  @override
  State<_TechnicalInterviewStage> createState() =>
      _TechnicalInterviewStageState();
}

class _TechnicalInterviewStageState extends State<_TechnicalInterviewStage> {
  int _step = 0; // 0 coding, 1 debug
  String? _picked;
  int _score = 0;
  late final CodingChallenge _coding;
  late final CodingChallenge _debug;

  @override
  void initState() {
    super.initState();
    final List<CodingChallenge> bank =
        CodingChallengeBank.forMajor(widget.progress.majorId);
    _coding = bank.firstWhere(
      (CodingChallenge c) =>
          c.topics.any(
            (String t) =>
                t.toLowerCase().contains('array') ||
                t.toLowerCase().contains('hash') ||
                t.toLowerCase().contains('string'),
          ),
      orElse: () => bank.first,
    );
    _debug = bank.firstWhere(
      (CodingChallenge c) =>
          c.id != _coding.id &&
          (c.title.toLowerCase().contains('debug') ||
              c.topics.any((String t) => t.toLowerCase().contains('debug')) ||
              c.difficulty == 'Easy'),
      orElse: () => bank.length > 1 ? bank[1] : bank.first,
    );
  }

  void _submit() {
    if (_picked == null) return;
    final CodingChallenge cur = _step == 0 ? _coding : _debug;
    if (_picked == cur.correctOptionId) _score++;
    if (_step == 0) {
      setState(() {
        _step = 1;
        _picked = null;
      });
      return;
    }
    widget.onDone(_score >= 1);
  }

  @override
  Widget build(BuildContext context) {
    final CodingChallenge cur = _step == 0 ? _coding : _debug;
    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: SciCosmic.appBar(
        context: context,
        title: 'Technical interview',
        icon: Icons.code_rounded,
        subtitle: _step == 0 ? 'Live coding · 45–60 min' : 'Debugging task',
        trailing: <Widget>[
          TextButton(onPressed: widget.onBack, child: const Text('Exit')),
        ],
      ),
      body: SciStarfield(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: SciCosmic.panelBox(radius: 12),
              child: const Text(
                'Engineer: “Share your screen — talk through arrays, strings, or hash maps as you go.”',
                style: TextStyle(color: SciCosmic.mute, height: 1.35),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: SciCosmic.panelBox(radius: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    cur.title,
                    style: const TextStyle(
                      color: SciCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cur.prompt,
                    style: const TextStyle(color: SciCosmic.mute, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...cur.options.map((CodeOption o) {
              final bool sel = _picked == o.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _picked = o.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel
                          ? SciCosmic.purple.withValues(alpha: 0.25)
                          : SciCosmic.panelAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? SciCosmic.purple : SciCosmic.stroke,
                      ),
                    ),
                    child: Text(
                      o.code.isNotEmpty ? o.code : o.label,
                      style: const TextStyle(
                        color: SciCosmic.ink,
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              );
            }),
            FilledButton(
              onPressed: _picked == null ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: SciCosmic.teal,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(_step == 0 ? 'Submit coding answer' : 'Finish interview'),
            ),
          ],
        ),
      ),
    );
  }
}
