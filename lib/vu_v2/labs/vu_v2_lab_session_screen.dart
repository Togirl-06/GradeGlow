import 'package:flutter/material.dart';

import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import 'vu_v2_lab_models.dart';
import 'vu_v2_lab_simulations.dart';

class VuV2LabSessionScreen extends StatefulWidget {
  const VuV2LabSessionScreen({
    super.key,
    required this.schoolTitle,
    required this.schoolEmoji,
    required this.experiment,
  });

  final String schoolTitle;
  final String schoolEmoji;
  final VuV2LabExperiment experiment;

  @override
  State<VuV2LabSessionScreen> createState() => _VuV2LabSessionScreenState();
}

class _VuV2LabSessionScreenState extends State<VuV2LabSessionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final TextEditingController _notes;
  late final TextEditingController _ask;

  double _progress = 0.08;
  int _resetToken = 0;
  final List<String> _professorLog = <String>[];
  final Map<int, int> _quizAnswers = <int, int>{};
  final Set<int> _quizCorrect = <int>{};

  VuV2LabExperiment get exp => widget.experiment;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _notes = TextEditingController(text: exp.notesSeed);
    _ask = TextEditingController();
    _professorLog.add(exp.professorIntro);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _notes.dispose();
    _ask.dispose();
    super.dispose();
  }

  void _bump(double delta) {
    setState(() => _progress = (_progress + delta).clamp(0.0, 1.0));
  }

  void _professorSay(String msg, {double? progressBump}) {
    setState(() {
      _professorLog.add(msg);
      if (progressBump != null) {
        _progress = (_progress + progressBump).clamp(0.0, 1.0);
      }
    });
  }

  void _resetExperiment() {
    setState(() {
      _resetToken++;
      _progress = 0.08;
      _quizAnswers.clear();
      _quizCorrect.clear();
      _notes.text = exp.notesSeed;
      _professorLog
        ..clear()
        ..add('Experiment reset. Fresh bench — ${exp.professorIntro}');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Experiment reset')),
    );
  }

  void _askProfessor() {
    final String q = _ask.text.trim();
    if (q.isEmpty) return;
    _ask.clear();
    final String reply = _localProfessorReply(q);
    setState(() {
      _professorLog.add('You: $q');
      _professorLog.add('AI Professor: $reply');
      _progress = (_progress + 0.04).clamp(0.0, 1.0);
    });
  }

  String _localProfessorReply(String q) {
    final String lower = q.toLowerCase();
    if (lower.contains('hint') || lower.contains('help')) {
      return 'Re-read step ${(_progress * exp.instructions.length).ceil().clamp(1, exp.instructions.length)} '
          'in Instructions. Try one controlled change, observe, then ask what changed.';
    }
    if (lower.contains('why')) {
      return 'Great question. Connect it to the objective: ${exp.objectives.first}. '
          'What did the simulation do when you changed one variable?';
    }
    if (lower.contains('quiz') || lower.contains('test')) {
      return 'When you feel ready, open the Quiz tab. Explain your reasoning before locking an answer.';
    }
    return 'I hear you. In ${exp.title}, focus on: ${exp.objectives.take(2).join('; ')}. '
        'Try the interactive bench, then summarize what you saw in Notes.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.schoolEmoji} ${exp.title}'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _resetExperiment,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Text(
                      'Lab progress',
                      style: TextStyle(
                        color: VuV2Colors.mute,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(_progress * 100).round()}%',
                      style: TextStyle(
                        color: VuV2Colors.orange,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                VuV2ProgressBar(value: _progress, height: 8),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Material(
            color: VuV2Colors.navyElevated,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              labelColor: VuV2Colors.orange,
              unselectedLabelColor: VuV2Colors.mute,
              indicatorColor: VuV2Colors.orange,
              tabs: const <Tab>[
                Tab(text: 'Lab bench'),
                Tab(text: 'Guide'),
                Tab(text: 'Quiz'),
                Tab(text: 'Notes'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: <Widget>[
                _benchTab(),
                _guideTab(),
                _quizTab(),
                _notesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _resetExperiment,
        icon: const Icon(Icons.restart_alt_rounded),
        label: const Text('Reset experiment'),
      ),
    );
  }

  Widget _benchTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 88),
      children: <Widget>[
        _ProfessorPanel(
          log: _professorLog,
          askController: _ask,
          onAsk: _askProfessor,
        ),
        const SizedBox(height: 14),
        const VuV2SectionTitle('Interactive simulation'),
        const SizedBox(height: 8),
        Text(
          exp.blurb,
          style: const TextStyle(color: VuV2Colors.mute),
        ),
        const SizedBox(height: 10),
        VuV2LabSimulationArea(
          kind: exp.simulationKind,
          resetToken: _resetToken,
          onNotify: _professorSay,
        ),
      ],
    );
  }

  Widget _guideTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 88),
      children: <Widget>[
        const VuV2SectionTitle('Instructions'),
        const SizedBox(height: 10),
        ...exp.instructions.asMap().entries.map((MapEntry<int, String> e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: VuV2Surface(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: VuV2Colors.orange.withValues(alpha: 0.2),
                    child: Text(
                      '${e.key + 1}',
                      style: TextStyle(
                        color: VuV2Colors.orange,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        color: VuV2Colors.ink,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        const VuV2SectionTitle('Objectives'),
        const SizedBox(height: 8),
        ...exp.objectives.map(
          (String o) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.check_circle_outline, size: 18, color: VuV2Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(o, style: const TextStyle(color: VuV2Colors.mute, height: 1.35)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        VuV2PrimaryButton(
          label: 'Mark instructions reviewed',
          icon: Icons.done_all_rounded,
          onPressed: () {
            _bump(0.12);
            _professorSay('Instructions reviewed. Back to the bench when ready.');
            _tabs.animateTo(0);
          },
        ),
      ],
    );
  }

  Widget _quizTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 88),
      children: <Widget>[
        const VuV2SectionTitle('Quiz'),
        const SizedBox(height: 8),
        Text(
          'Check understanding after you experiment.',
          style: const TextStyle(color: VuV2Colors.mute),
        ),
        const SizedBox(height: 14),
        ...exp.quiz.asMap().entries.map((MapEntry<int, VuV2LabQuizItem> e) {
          final int qi = e.key;
          final VuV2LabQuizItem item = e.value;
          final int? chosen = _quizAnswers[qi];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: VuV2Surface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.prompt,
                    style: const TextStyle(
                      color: VuV2Colors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...item.choices.asMap().entries.map((MapEntry<int, String> c) {
                    final bool selected = chosen == c.key;
                    final bool revealed = chosen != null;
                    Color border = VuV2Colors.stroke;
                    if (revealed && c.key == item.correctIndex) {
                      border = VuV2Colors.success;
                    } else if (revealed && selected && c.key != item.correctIndex) {
                      border = VuV2Colors.danger;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: VuV2Colors.navy,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: chosen != null
                              ? null
                              : () {
                                  final bool ok = c.key == item.correctIndex;
                                  setState(() {
                                    _quizAnswers[qi] = c.key;
                                    if (ok) _quizCorrect.add(qi);
                                  });
                                  _professorSay(
                                    ok
                                        ? 'Quiz: correct. ${item.explain}'
                                        : 'Quiz: not quite. ${item.explain}',
                                    progressBump: ok ? 0.12 : 0.04,
                                  );
                                },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border),
                            ),
                            child: Text(
                              c.value,
                              style: const TextStyle(color: VuV2Colors.ink),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _notesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 88),
      children: <Widget>[
        const VuV2SectionTitle('Lab notes'),
        const SizedBox(height: 8),
        const Text(
          'Capture observations, hypotheses, and results.',
          style: TextStyle(color: VuV2Colors.mute),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          maxLines: 14,
          style: const TextStyle(color: VuV2Colors.ink, height: 1.45),
          onChanged: (_) => _bump(0.01),
          decoration: InputDecoration(
            filled: true,
            fillColor: VuV2Colors.navyElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        VuV2PrimaryButton(
          label: 'Save notes checkpoint',
          icon: Icons.bookmark_added_outlined,
          onPressed: () {
            _bump(0.08);
            _professorSay('Notes checkpoint saved. Strong lab habit.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notes saved for this session')),
            );
          },
        ),
      ],
    );
  }
}

class _ProfessorPanel extends StatelessWidget {
  const _ProfessorPanel({
    required this.log,
    required this.askController,
    required this.onAsk,
  });

  final List<String> log;
  final TextEditingController askController;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    return VuV2Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.school_rounded, color: VuV2Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'AI Professor',
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: log.length,
              itemBuilder: (_, int i) {
                final bool isYou = log[i].startsWith('You:');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    log[i],
                    style: TextStyle(
                      color: isYou ? VuV2Colors.mute : VuV2Colors.ink,
                      height: 1.4,
                      fontWeight: isYou ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: askController,
                  style: const TextStyle(color: VuV2Colors.ink),
                  decoration: const InputDecoration(
                    hintText: 'Ask your AI professor…',
                    hintStyle: TextStyle(color: VuV2Colors.mute),
                    isDense: true,
                  ),
                  onSubmitted: (_) => onAsk(),
                ),
              ),
              IconButton(
                onPressed: onAsk,
                icon: Icon(Icons.send_rounded, color: VuV2Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
