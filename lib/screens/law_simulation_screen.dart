import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/law_simulation_data.dart';
import '../models/law_simulation.dart';
import '../models/practice_lab.dart';
import '../services/law_case_engine.dart';
import '../services/law_case_history_service.dart';
import '../services/law_daily_progress_service.dart';
import '../services/practice_lab_service.dart';
import '../theme/practice_lab_game_theme.dart';
import '../utils/law_case_navigation.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';
import '../widgets/law/law_simulation_widgets.dart';

/// Full case flow: briefing → investigation → argument → courtroom → AI verdict.
class LawSimulationScreen extends StatefulWidget {
  const LawSimulationScreen({
    super.key,
    required this.category,
    required this.lab,
    required this.caseId,
    required this.side,
    this.resume = false,
    this.isDailyCase = false,
    this.startWithBriefing = false,
  });

  final PracticeLabCategory category;
  final PracticeLabType lab;
  final String caseId;
  final LawPartySide side;
  final bool resume;
  final bool isDailyCase;
  final bool startWithBriefing;

  @override
  State<LawSimulationScreen> createState() => _LawSimulationScreenState();
}

class _LawSimulationScreenState extends State<LawSimulationScreen> {
  LawSimulationRun? _run;
  LawCaseEngine? _engine;
  bool _booting = true;
  String? _error;
  bool _loading = false;
  String _statusNote = '';
  int _briefingStep = 0;
  String _caseFileTab = 'evidence';
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _claimController = TextEditingController();
  final TextEditingController _reasoningController = TextEditingController();
  final TextEditingController _courtLineController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  LawVerdictBreakdown? _verdict;
  String _judgeLine = 'Court is now in session. Counsel may proceed when ready.';
  LawWitness? _activeWitness;

  static const List<String> _quizOptions = <String>['Yes', 'No', 'Not enough evidence'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  @override
  void dispose() {
    _questionController.dispose();
    _claimController.dispose();
    _reasoningController.dispose();
    _courtLineController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final PracticeLabService labs = context.read<PracticeLabService>();
    if (!await labs.canStartSimulation()) {
      if (!mounted) return;
      await PremiumAccess.showUpgradeDialog(context, feature: PremiumFeature.practiceLabs);
      if (mounted) Navigator.pop(context);
      return;
    }
    try {
      await labs.consumeSimulationSlot();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = StudyMessenger.clean(error);
        _booting = false;
      });
      return;
    }

    final LawCaseFile file = LawSimulationData.caseById(widget.caseId);
    final bool withBriefing = widget.startWithBriefing || widget.isDailyCase;
    final LawSimulationRun run = LawSimulationRun(
      caseFile: file,
      side: widget.side,
      isDailyCase: widget.isDailyCase,
      phase: withBriefing ? LawSimulationPhase.briefing : LawSimulationPhase.investigation,
    );
    if (widget.resume && LawSimulationData.playerProgress.continuePhase != null) {
      run.phase = LawSimulationData.playerProgress.continuePhase!;
    }
    _run = run;
    _engine = LawCaseEngine(run);
    LawSimulationData.playerProgress.continueCaseId = widget.caseId;
    LawSimulationData.playerProgress.continuePhase = run.phase;
    await LawCaseHistoryService.instance.markPlayed(widget.caseId);
    if (mounted) setState(() => _booting = false);
  }

  Future<void> _goNextCase() async {
    final LawSimulationRun? run = _run;
    if (run == null || _loading) return;
    setState(() => _loading = true);
    try {
      await LawCaseNavigation.openNextCase(
        context,
        current: run.caseFile,
        category: widget.category,
        lab: widget.lab,
        isDailyCase: false,
        replace: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _advancePhase(LawSimulationPhase next) {
    setState(() {
      _run!.phase = next;
      LawSimulationData.playerProgress.continuePhase = next;
      _statusNote = '';
      _activeWitness = null;
    });
  }

  List<String> get _briefingLines {
    final LawSimulationRun run = _run!;
    final String side = run.shortSideLabel;
    final String theory =
        run.side == LawPartySide.prosecution ? run.caseFile.prosecutionTheory : run.caseFile.defenseTheory;
    final String opposing =
        run.side == LawPartySide.prosecution ? run.caseFile.defenseTheory : run.caseFile.prosecutionTheory;
    return <String>[
      'Good morning, Counselor.',
      'Today you\'re representing the $side.',
      'Your theory: $theory',
      'The other side will argue: $opposing',
      'Before court begins, review the evidence, interview witnesses, and build your case file.',
    ];
  }

  Future<void> _investigate(String actionType, {String? targetId}) async {
    final LawCaseEngine engine = _engine!;
    if (actionType == 'interview' && targetId != null) {
      setState(() {
        _activeWitness = engine.caseFile.witnesses.firstWhere((LawWitness w) => w.id == targetId);
        _caseFileTab = 'witnesses';
        _statusNote = 'Ask ${_activeWitness!.name} a specific question below.';
      });
      return;
    }
    final InvestigationResult result = engine.investigate(actionType: actionType, targetId: targetId);
    setState(() {
      _run!.investigationXp += result.xp;
      _statusNote = result.message;
      if (result.notes.isNotEmpty) {
        _statusNote = '${result.message}\n\n${result.notes.join('\n')}';
      }
      if (result.newlyRevealed.isNotEmpty) {
        _caseFileTab = 'evidence';
      }
    });
  }

  Future<void> _submitWitnessQuestion() async {
    final LawWitness? witness = _activeWitness;
    if (witness == null || _questionController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final PracticeLabService labs = context.read<PracticeLabService>();
      final LawCaseEngine engine = _engine!;
      final String question = _questionController.text.trim();
      final InvestigationResult result = engine.investigate(
        actionType: 'interview',
        targetId: witness.id,
        studentQuestion: question,
      );
      final String reply = await labs.lawWitnessInterview(
        witness: witness,
        caseBrief: engine.studentBrief,
        truthBlock: engine.aiTruthBlock,
        question: question,
        history: <SimulationMessage>[],
      );
      if (!mounted) return;
      setState(() {
        _run!.investigationXp += result.xp;
        _run!.interviewTranscript.add(LawCourtTurn(speaker: 'You', text: question, isUser: true));
        _run!.interviewTranscript.add(LawCourtTurn(speaker: witness.name, text: reply, isUser: false));
        _statusNote = '${witness.name}: "$reply"';
        _questionController.clear();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  void _openEvidenceDetail(LawEvidence evidence) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PracticeLabGameTheme.surface(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (BuildContext context) {
        final List<String> probeQs = evidence.probeQuestions;
        final List<String> probes = probeQs.isNotEmpty
            ? probeQs
            : <String>[
                'Does this support your theory?',
                'Could the other side explain this away?',
              ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(evidence.title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: PracticeLabGameTheme.textPrimary(context))),
              if (evidence.dateLabel != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(evidence.dateLabel!, style: TextStyle(color: PracticeLabGameTheme.primary(context), fontWeight: FontWeight.w700)),
              ],
              const SizedBox(height: 10),
              Text(evidence.description, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), height: 1.45)),
              const SizedBox(height: 14),
              Text('Questions', style: TextStyle(fontWeight: FontWeight.w800, color: PracticeLabGameTheme.textPrimary(context))),
              const SizedBox(height: 6),
              ...probes.map((String q) => Text('• $q', style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), height: 1.4))),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    if (!_run!.attorneyNotes.contains(evidence.title)) {
                      _run!.attorneyNotes.add('${evidence.title}: ${evidence.description}');
                    }
                    if (!_run!.markedFactIds.contains(evidence.id)) {
                      _run!.markedFactIds.add(evidence.id);
                    }
                  });
                  Navigator.pop(context);
                  StudyMessenger.showInfo(context, 'Added to your notes.');
                },
                child: const Text('Add to Notes'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _syncArgumentFromControllers() {
    _run!.argument.claim = _claimController.text;
    _run!.argument.reasoning = _reasoningController.text;
  }

  bool _isStrongEvidence(LawEvidence e) {
    if (e.isFakeLead) return false;
    return e.supportsProsecution == (_run!.side == LawPartySide.prosecution);
  }

  Future<void> _runCourtAction(String action) async {
    final LawCaseEngine engine = _engine!;
    final PracticeLabService labs = context.read<PracticeLabService>();
    final String line = _courtLineController.text.trim();
    if (line.isEmpty && action != 'closing') {
      StudyMessenger.showInfo(context, 'Enter your statement first.');
      return;
    }
    setState(() => _loading = true);
    try {
      final String judge = await labs.lawJudgeLine(
        action: action,
        caseBrief: engine.buildCourtroomBriefing(),
        truthBlock: engine.aiTruthBlock,
        studentLine: line.isEmpty ? 'The ${_run!.sideLabel} rests.' : line,
      );
      final String opponent = await labs.lawOpponentReply(
        sideLabel: _run!.sideLabel,
        opponentLabel: _run!.opponentLabel,
        caseBrief: engine.buildCourtroomBriefing(),
        truthBlock: engine.aiTruthBlock,
        studentLine: line,
        history: _run!.courtroomTranscript
            .map((LawCourtTurn t) => t.isUser ? SimulationMessage.student(t.text) : SimulationMessage.ai(t.text))
            .toList(),
      );
      if (!mounted) return;
      setState(() {
        if (line.isNotEmpty) {
          _run!.courtroomTranscript.add(LawCourtTurn(speaker: _run!.sideLabel, text: line, isUser: true));
        }
        _run!.courtroomTranscript.add(LawCourtTurn(speaker: 'Judge', text: judge, isUser: false));
        _run!.courtroomTranscript.add(LawCourtTurn(speaker: _run!.opponentLabel, text: opponent, isUser: false));
        _judgeLine = judge;
        _courtLineController.clear();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  Future<void> _deliverVerdict() async {
    setState(() {
      _loading = true;
      _run!.phase = LawSimulationPhase.verdict;
    });
    try {
      final LawCaseEngine engine = _engine!;
      final PracticeLabService labs = context.read<PracticeLabService>();
      final LawVerdictBreakdown verdict = await labs.lawVerdict(
        caseBrief: engine.buildCourtroomBriefing(),
        truthBlock: engine.aiTruthBlock,
        sideLabel: _run!.sideLabel,
        argumentSummary: '${_run!.argument.claim}\n${_run!.argument.reasoning}',
        courtroomHistory: _run!.courtroomTranscript
            .map(
              (LawCourtTurn t) => t.isUser
                  ? SimulationMessage.student('${t.speaker}: ${t.text}')
                  : SimulationMessage.ai('${t.speaker}: ${t.text}'),
            )
            .toList(),
      );
      LawSimulationData.playerProgress.addXp(verdict.xpEarned);
      LawSimulationData.playerProgress.casesPlayed += 1;
      if (verdict.overall >= 70) LawSimulationData.playerProgress.casesWon += 1;
      LawSimulationData.playerProgress.continueCaseId = null;
      LawSimulationData.playerProgress.continuePhase = null;
      final String? specId = _run!.caseFile.specializationId;
      if (specId != null) {
        await LawDailyProgressService.instance.markDailyCompleted(specId);
      }
      await labs.saveLawSimulationResult(
        category: widget.category,
        lab: widget.lab,
        caseTitle: _run!.caseFile.title,
        verdict: verdict,
        sideLabel: _run!.sideLabel,
      );
      if (!mounted) return;
      setState(() {
        _verdict = verdict;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(appBar: AppBar(title: const Text('Law Simulation')), body: Center(child: Text(_error!)));
    }

    final LawSimulationRun run = _run!;

    return Scaffold(
      backgroundColor: PracticeLabGameTheme.background(context),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(run.caseFile.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            Text(
              '${run.shortSideLabel} · ${run.caseFile.displayCaseNumber}',
              style: TextStyle(fontSize: 11, color: PracticeLabGameTheme.textSecondary(context)),
            ),
          ],
        ),
        backgroundColor: PracticeLabGameTheme.background(context),
        foregroundColor: PracticeLabGameTheme.textPrimary(context),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _loading ? null : _goNextCase,
            icon: const Icon(Icons.skip_next_rounded, size: 20),
            label: const Text('Next', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: <Widget>[
          LawPhaseStepper(current: run.phase),
          const SizedBox(height: 14),
          if (run.phase == LawSimulationPhase.briefing) _buildBriefing(context, run),
          if (run.phase == LawSimulationPhase.investigation) _buildInvestigation(context, run),
          if (run.phase == LawSimulationPhase.argument) _buildArgument(context, run),
          if (run.phase == LawSimulationPhase.courtroom) _buildCourtroom(context, run),
          if (run.phase == LawSimulationPhase.verdict) _buildVerdict(context, run),
        ],
      ),
    );
  }

  Widget _buildBriefing(BuildContext context, LawSimulationRun run) {
    final List<String> lines = _briefingLines;
    final int shown = (_briefingStep + 1).clamp(1, lines.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: <Color>[Color(0xFF3E2723), Color(0xFF5D4037)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'AI PROFESSOR BRIEFING',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8),
              ),
              const SizedBox(height: 10),
              Text(run.caseFile.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                'You represent the ${run.shortSideLabel}',
                style: const TextStyle(color: Color(0xFFD6A85B), fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...List<Widget>.generate(shown, (int i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PracticeLabGameTheme.surface(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PracticeLabGameTheme.border(context)),
              ),
              child: Text(
                lines[i],
                style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), height: 1.45, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        if (_briefingStep < lines.length - 1)
          FilledButton(
            onPressed: () => setState(() => _briefingStep += 1),
            child: const Text('Continue briefing'),
          )
        else
          FilledButton.icon(
            onPressed: () {
              run.briefingComplete = true;
              _advancePhase(LawSimulationPhase.investigation);
            },
            icon: const Icon(Icons.folder_open_rounded),
            label: const Text('Open case file'),
          ),
      ],
    );
  }

  Widget _buildInvestigation(BuildContext context, LawSimulationRun run) {
    final LawCaseEngine engine = _engine!;
    final bool showQuiz = run.revealedEvidence.length >= 3 && !run.professorQuizAnswered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'CASE FILE',
          style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6),
        ),
        const SizedBox(height: 8),
        Text(run.caseFile.openingPoliceReport, style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), height: 1.45)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              for (final String tab in <String>['evidence', 'witnesses', 'medical', 'emails', 'timeline', 'laws', 'notes'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_tabLabel(tab, run)),
                    selected: _caseFileTab == tab,
                    onSelected: (_) => setState(() => _caseFileTab = tab),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_caseFileTab == 'evidence') _evidenceTab(context, run, engine),
        if (_caseFileTab == 'witnesses') _witnessTab(context, run),
        if (_caseFileTab == 'medical') _filteredEvidenceTab(context, run, LawEvidenceKind.medical),
        if (_caseFileTab == 'emails') _filteredEvidenceTab(context, run, LawEvidenceKind.email),
        if (_caseFileTab == 'timeline') _filteredEvidenceTab(context, run, LawEvidenceKind.timeline),
        if (_caseFileTab == 'laws') _lawsTab(context, run),
        if (_caseFileTab == 'notes') _notesTab(context, run),
        if (showQuiz) ...<Widget>[
          const SizedBox(height: 16),
          _professorQuiz(context, run),
        ],
        if (_statusNote.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(_statusNote, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), height: 1.4)),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: run.revealedEvidence.isEmpty ? null : () => _advancePhase(LawSimulationPhase.argument),
          child: const Text('Build your case →'),
        ),
      ],
    );
  }

  String _tabLabel(String tab, LawSimulationRun run) {
    return switch (tab) {
      'evidence' => 'Evidence (${run.caseFile.evidence.length})',
      'witnesses' => 'Witnesses (${run.caseFile.witnesses.length})',
      'medical' => 'Medical',
      'emails' => 'Emails',
      'timeline' => 'Timeline',
      'laws' => 'Laws',
      'notes' => 'Notes',
      _ => tab,
    };
  }

  Widget _evidenceTab(BuildContext context, LawSimulationRun run, LawCaseEngine engine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Discovery requests', style: TextStyle(fontWeight: FontWeight.w800, color: PracticeLabGameTheme.textPrimary(context))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: engine.availableEvidenceRequests().map((String key) {
            return ActionChip(
              label: Text(key.replaceAll('_', ' ')),
              onPressed: _loading ? null : () => _investigate('request_evidence', targetId: key),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: _loading ? null : () => _investigate('analyze'), child: const Text('Analyze clues')),
        if (run.revealedEvidence.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          ...run.revealedEvidence.map((LawEvidence e) => _evidenceTile(context, e)),
        ],
      ],
    );
  }

  Widget _filteredEvidenceTab(BuildContext context, LawSimulationRun run, LawEvidenceKind kind) {
    final List<LawEvidence> items = <LawEvidence>[
      ...run.caseFile.evidence.where((LawEvidence e) => e.resolvedKind == kind),
      ...run.revealedEvidence.where((LawEvidence e) => e.resolvedKind == kind),
    ];
    final Set<String> seen = <String>{};
    final List<LawEvidence> unique = <LawEvidence>[];
    for (final LawEvidence e in items) {
      if (seen.add(e.id)) unique.add(e);
    }
    if (unique.isEmpty) {
      return Text(
        'No $kind files yet. Request discovery from Evidence.',
        style: TextStyle(color: PracticeLabGameTheme.textSecondary(context)),
      );
    }
    return Column(
      children: unique.map((LawEvidence e) {
        final bool revealed = run.revealedEvidenceIds.contains(e.id);
        return _evidenceTile(
          context,
          e,
          locked: !revealed,
          onLockedTap: () => _investigate('request_evidence', targetId: e.revealAction),
        );
      }).toList(),
    );
  }

  Widget _evidenceTile(
    BuildContext context,
    LawEvidence e, {
    bool locked = false,
    VoidCallback? onLockedTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: PracticeLabGameTheme.surface(context),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(
            locked
                ? Icons.lock_outline
                : e.isFakeLead
                    ? Icons.warning_amber_rounded
                    : Icons.inventory_2_outlined,
          ),
          title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(locked ? 'Tap to request this exhibit' : e.description, maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: locked ? onLockedTap : () => _openEvidenceDetail(e),
        ),
      ),
    );
  }

  Widget _witnessTab(BuildContext context, LawSimulationRun run) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ...run.caseFile.witnesses.map(
          (LawWitness w) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: OutlinedButton.icon(
              onPressed: _loading ? null : () => _investigate('interview', targetId: w.id),
              icon: const Icon(Icons.person_outline_rounded, size: 18),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text('${w.name} — ${w.role}${run.interviewedWitnessIds.contains(w.id) ? ' ✓' : ''}'),
              ),
            ),
          ),
        ),
        if (_activeWitness != null) ...<Widget>[
          const SizedBox(height: 10),
          Text('Interview · ${_activeWitness!.name}', style: TextStyle(fontWeight: FontWeight.w800, color: PracticeLabGameTheme.textPrimary(context))),
          const SizedBox(height: 8),
          ...run.interviewTranscript
              .where((LawCourtTurn t) => t.speaker == _activeWitness!.name || t.isUser)
              .map(
                (LawCourtTurn t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${t.speaker}: ${t.text}',
                    style: TextStyle(
                      color: t.isUser
                          ? PracticeLabGameTheme.primary(context)
                          : PracticeLabGameTheme.textPrimary(context),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          TextField(
            controller: _questionController,
            decoration: InputDecoration(
              hintText: 'Question for ${_activeWitness!.name}…',
              border: const OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _loading ? null : _submitWitnessQuestion, child: const Text('Ask witness')),
        ],
      ],
    );
  }

  Widget _lawsTab(BuildContext context, LawSimulationRun run) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PracticeLabGameTheme.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PracticeLabGameTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Applicable doctrine', style: TextStyle(fontWeight: FontWeight.w900, color: PracticeLabGameTheme.textPrimary(context))),
          const SizedBox(height: 8),
          Text(run.caseFile.chargeOrClaim, style: TextStyle(color: PracticeLabGameTheme.primary(context), fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(run.caseFile.displayLearningGoal, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), height: 1.4)),
          const SizedBox(height: 10),
          Text('Plaintiff theory', style: TextStyle(fontWeight: FontWeight.w800, color: PracticeLabGameTheme.textPrimary(context))),
          Text(run.caseFile.prosecutionTheory, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), height: 1.4)),
          const SizedBox(height: 8),
          Text('Defense theory', style: TextStyle(fontWeight: FontWeight.w800, color: PracticeLabGameTheme.textPrimary(context))),
          Text(run.caseFile.defenseTheory, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), height: 1.4)),
        ],
      ),
    );
  }

  Widget _notesTab(BuildContext context, LawSimulationRun run) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (run.attorneyNotes.isEmpty)
          Text('Pin exhibits and interview takeaways here.', style: TextStyle(color: PracticeLabGameTheme.textSecondary(context)))
        else
          ...run.attorneyNotes.map(
            (String n) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $n', style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), height: 1.35)),
            ),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          decoration: const InputDecoration(hintText: 'Add a note…', border: OutlineInputBorder()),
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            final String text = _notesController.text.trim();
            if (text.isEmpty) return;
            setState(() {
              run.attorneyNotes.add(text);
              _notesController.clear();
            });
          },
          child: const Text('Save note'),
        ),
      ],
    );
  }

  Widget _professorQuiz(BuildContext context, LawSimulationRun run) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PracticeLabGameTheme.primary(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PracticeLabGameTheme.primary(context).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Professor', style: TextStyle(color: PracticeLabGameTheme.primary(context), fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            'You\'ve reviewed ${run.revealedEvidence.length} pieces of evidence.\n\nDoes anything you\'ve seen establish causation?',
            style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), height: 1.4, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ..._quizOptions.asMap().entries.map((MapEntry<int, String> e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    run.professorQuizAnswered = true;
                    run.professorQuizIndex = e.key;
                    _statusNote = e.key == 2
                        ? 'Good instinct — keep investigating until causation is clear.'
                        : e.key == 0
                            ? 'Strong claim. Pin the exhibits that prove the causal chain.'
                            : 'Then keep digging — causation is often the decisive element.';
                  });
                },
                child: Align(alignment: Alignment.centerLeft, child: Text('${String.fromCharCode(65 + e.key)}.  ${e.value}')),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildArgument(BuildContext context, LawSimulationRun run) {
    final List<LawEvidence> strong = run.revealedEvidence.where(_isStrongEvidence).toList();
    final List<LawEvidence> weak = run.revealedEvidence.where((LawEvidence e) => !_isStrongEvidence(e)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'YOUR ARGUMENT',
          style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontWeight: FontWeight.w800, fontSize: 11),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _claimController,
          decoration: const InputDecoration(labelText: 'Your claim (what happened?)', border: OutlineInputBorder()),
          minLines: 2,
          maxLines: 4,
          onChanged: (_) => _syncArgumentFromControllers(),
        ),
        const SizedBox(height: 12),
        Text('Strong evidence', style: TextStyle(fontWeight: FontWeight.w800, color: PracticeLabGameTheme.textPrimary(context))),
        const SizedBox(height: 6),
        Text(
          'Tap to add exhibits that support your theory.',
          style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: strong.map((LawEvidence e) {
            final bool selected = run.argument.selectedEvidenceIds.contains(e.id);
            return LawEvidenceChip(
              evidence: e,
              selected: selected,
              onTap: () {
                setState(() {
                  if (selected) {
                    run.argument.selectedEvidenceIds.remove(e.id);
                  } else {
                    run.argument.selectedEvidenceIds.add(e.id);
                  }
                });
              },
            );
          }).toList(),
        ),
        if (weak.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          Text('Weak / risky evidence', style: TextStyle(fontWeight: FontWeight.w800, color: PracticeLabGameTheme.textPrimary(context))),
          const SizedBox(height: 6),
          Text(
            'These may help the other side or are unreliable — use carefully.',
            style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weak.map((LawEvidence e) {
              final bool selected = run.argument.selectedEvidenceIds.contains(e.id);
              return LawEvidenceChip(
                evidence: e,
                selected: selected,
                onTap: () {
                  setState(() {
                    if (selected) {
                      run.argument.selectedEvidenceIds.remove(e.id);
                    } else {
                      run.argument.selectedEvidenceIds.add(e.id);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 10),
        TextField(
          controller: _reasoningController,
          decoration: const InputDecoration(labelText: 'Legal reasoning', border: OutlineInputBorder()),
          minLines: 3,
          maxLines: 6,
          onChanged: (_) => _syncArgumentFromControllers(),
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: () {
            _syncArgumentFromControllers();
            final String err = _engine!.validateArgument();
            if (err.isNotEmpty) {
              StudyMessenger.showInfo(context, err);
              return;
            }
            _advancePhase(LawSimulationPhase.courtroom);
          },
          child: const Text('Enter courtroom →'),
        ),
      ],
    );
  }

  Widget _buildCourtroom(BuildContext context, LawSimulationRun run) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LawCourtroomBanner(judgeLine: _judgeLine, loading: _loading),
        const SizedBox(height: 12),
        TextField(
          controller: _courtLineController,
          decoration: const InputDecoration(
            hintText: 'Your statement, objection, or question…',
            border: OutlineInputBorder(),
          ),
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ActionChip(label: const Text('Opening'), onPressed: _loading ? null : () => _runCourtAction('opening')),
            ActionChip(label: const Text('Present evidence'), onPressed: _loading ? null : () => _runCourtAction('present_evidence')),
            ActionChip(label: const Text('Objection · Hearsay'), onPressed: _loading ? null : () {
              _courtLineController.text = 'Objection — hearsay.';
              _runCourtAction('objection');
            }),
            ActionChip(label: const Text('Cross-examine'), onPressed: _loading ? null : () => _runCourtAction('cross_examine')),
            ActionChip(label: const Text('Closing'), onPressed: _loading ? null : () => _runCourtAction('closing')),
          ],
        ),
        const SizedBox(height: 12),
        ...run.courtroomTranscript.reversed.take(8).map(
          (LawCourtTurn t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Align(
              alignment: t.isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: t.isUser
                      ? PracticeLabGameTheme.primary(context).withValues(alpha: 0.15)
                      : PracticeLabGameTheme.surface(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${t.speaker}: ${t.text}',
                  style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), height: 1.35),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _loading ? null : _deliverVerdict,
          child: const Text('Rest — request verdict'),
        ),
      ],
    );
  }

  Widget _buildVerdict(BuildContext context, LawSimulationRun run) {
    if (_loading || _verdict == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final LawVerdictBreakdown v = _verdict!;
    final bool won = v.overall >= 70;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Icon(Icons.gavel_rounded, size: 48, color: Color(0xFFD4A574)),
        const SizedBox(height: 8),
        Text(
          'VERDICT',
          textAlign: TextAlign.center,
          style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        Text(
          v.ruling,
          textAlign: TextAlign.center,
          style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          won ? 'You successfully proved your case theory.' : 'The court was not fully persuaded — review the weak points.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), height: 1.4),
        ),
        const SizedBox(height: 12),
        Text(
          '${v.overall}%',
          textAlign: TextAlign.center,
          style: TextStyle(color: PracticeLabGameTheme.primary(context), fontSize: 40, fontWeight: FontWeight.w900),
        ),
        Text(
          'Overall Score',
          textAlign: TextAlign.center,
          style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(v.summary, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), height: 1.45)),
        const SizedBox(height: 16),
        _scoreRow('Legal Reasoning', v.logic),
        _scoreRow('Evidence Usage', v.evidenceUse),
        _scoreRow('Courtroom Performance', v.persuasion),
        _scoreRow('Accuracy', v.accuracy),
        if (v.keyEvidence.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Text('Key evidence', style: TextStyle(fontWeight: FontWeight.w800, color: PracticeLabGameTheme.textPrimary(context))),
          ...v.keyEvidence.map((String s) => Text('✔ $s', style: TextStyle(color: PracticeLabGameTheme.textSecondary(context)))),
        ],
        if (v.weakPoints.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Text('Where to improve', style: TextStyle(fontWeight: FontWeight.w800, color: PracticeLabGameTheme.textPrimary(context))),
          ...v.weakPoints.map((String s) => Text('• $s', style: TextStyle(color: PracticeLabGameTheme.textSecondary(context)))),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Earned ${v.xpEarned} XP · ${run.caseFile.displayBadge}'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _loading ? null : _goNextCase,
          icon: const Icon(Icons.skip_next_rounded),
          label: const Text('Next court case'),
        ),
      ],
    );
  }

  Widget _scoreRow(String label, int score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context)))),
          Text('$score%', style: TextStyle(fontWeight: FontWeight.w900, color: PracticeLabGameTheme.textPrimary(context))),
        ],
      ),
    );
  }
}
