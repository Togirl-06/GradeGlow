import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/ai_practice_mode.dart';
import '../models/practice_lab.dart';
import '../services/ai_practice_service.dart';
import '../services/subscription_service.dart';
import '../services/tutor_voice_service.dart';
import '../theme/study_theme.dart';
import '../utils/premium_access.dart';
import '../utils/study_messenger.dart';
import '../widgets/ai_practice/ai_practice_avatar.dart';
import '../widgets/ai_practice/ai_practice_widgets.dart';
import '../widgets/study_surface.dart';
import '../widgets/tutor_markdown_body.dart';

/// Step 3 — immersive live simulation with avatar, actions, voice, and chat.
class AiPracticeSessionScreen extends StatefulWidget {
  const AiPracticeSessionScreen({
    super.key,
    required this.major,
    required this.scenario,
    required this.difficulty,
  });

  final PracticeLabCategory major;
  final PracticeScenarioTemplate scenario;
  final PracticeDifficulty difficulty;

  @override
  State<AiPracticeSessionScreen> createState() => _AiPracticeSessionScreenState();
}

class _AiPracticeSessionScreenState extends State<AiPracticeSessionScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _chatScroll = ScrollController();
  final TutorVoiceService _voice = TutorVoiceService();
  Timer? _timer;

  SimulationStart? _start;
  PracticeModeGrade? _grade;
  final List<SimulationMessage> _history = <SimulationMessage>[];
  bool _loading = false;
  String? _error;
  AvatarEmotion _emotion = AvatarEmotion.neutral;
  bool _voiceReady = false;
  bool _autoSpeak = true;
  bool _showChat = false;
  PracticeInteractionMode _mode = PracticeInteractionMode.askQuestion;
  Duration _elapsed = Duration.zero;
  bool _holdingMic = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _initVoice() async {
    final VoiceCapabilities caps = await _voice.initialize();
    if (mounted) setState(() => _voiceReady = caps.anyReady);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _voice.dispose();
    _input.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    if (!mounted) return;

    if (!AppConfig.hasOpenAi) {
      setState(() => _error = 'OpenAI is not configured. Add OPENAI_API_KEY to your .env file.');
      return;
    }

    final AiPracticeService service = context.read<AiPracticeService>();
    if (!await service.canStartSession()) {
      if (!mounted) return;
      await PremiumAccess.showUpgradeDialog(context, feature: PremiumFeature.aiPracticeMode);
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final SimulationStart start = await service.startSession(
        major: widget.major,
        scenario: widget.scenario,
        difficulty: widget.difficulty,
      );
      if (!mounted) return;
      setState(() {
        _start = start;
        _history
          ..clear()
          ..add(SimulationMessage.ai(start.openingMessage));
        _emotion = inferEmotionFromText(start.openingMessage);
        _loading = false;
      });
      _startTimer();
      await _speakIfEnabled(start.openingMessage);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = StudyMessenger.clean(error);
      });
    }
  }

  String? get _latestAiSpeech {
    for (int i = _history.length - 1; i >= 0; i--) {
      if (!_history[i].isStudent) return _history[i].text;
    }
    return null;
  }

  Future<void> _speakIfEnabled(String text) async {
    if (!_autoSpeak || !_voice.canSpeak) return;
    if (mounted) setState(() {});
    await _voice.speak(text);
    if (mounted) setState(() {});
  }

  String _prefixMessage(String text) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    return '[${_mode.label}] $trimmed';
  }

  Future<void> _send() async {
    final String text = _input.text.trim();
    if (text.isEmpty || _loading || _start == null || _grade != null) return;
    _input.clear();
    await _submitMessage(_prefixMessage(text));
  }

  Future<void> _submitMessage(String text) async {
    final AiPracticeService service = context.read<AiPracticeService>();
    setState(() {
      _loading = true;
      _history.add(SimulationMessage.student(text));
    });
    _scrollChatToBottom();

    try {
      final String reply = await service.sendStudentMessage(
        major: widget.major,
        scenario: widget.scenario,
        difficulty: widget.difficulty,
        start: _start!,
        history: _history.sublist(0, _history.length - 1),
        message: text,
      );
      if (!mounted) return;
      setState(() {
        _history.add(SimulationMessage.ai(reply));
        _emotion = inferEmotionFromText(reply);
        _loading = false;
      });
      _scrollChatToBottom();
      await _speakIfEnabled(reply);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScroll.hasClients) return;
      _chatScroll.animateTo(
        _chatScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _startHoldToSpeak() async {
    final SubscriptionService subs = context.read<SubscriptionService>();
    if (!await PremiumAccess.checkAndPrompt(context, subs, feature: PremiumFeature.voiceTutor)) {
      return;
    }
    setState(() => _holdingMic = true);
    await _voice.startListening(
      onWords: (String words, bool isFinal) {
        if (mounted) setState(() => _input.text = words);
      },
      onListeningState: () {
        if (mounted) setState(() {});
      },
      onListeningStopped: () {
        if (mounted) setState(() => _holdingMic = false);
      },
    );
  }

  Future<void> _stopHoldToSpeak() async {
    await _voice.stopListening();
    if (!mounted) return;
    setState(() => _holdingMic = false);
    final String text = _input.text.trim();
    if (text.isNotEmpty) await _send();
  }

  Future<void> _endAndGrade() async {
    if (_start == null || _grade != null || _loading) return;
    if (_history.where((SimulationMessage m) => m.isStudent).isEmpty) {
      StudyMessenger.showError(context, 'Send at least one message before ending the scenario.');
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('End scenario?'),
        content: const Text('Your performance will be scored with strengths, improvements, and study topics.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep going')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Get my score')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    _timer?.cancel();
    await _voice.stopSpeaking();
    if (!mounted) return;
    final AiPracticeService service = context.read<AiPracticeService>();
    setState(() => _loading = true);

    try {
      final PracticeModeGrade grade = await service.endAndGrade(
        major: widget.major,
        scenario: widget.scenario,
        difficulty: widget.difficulty,
        start: _start!,
        history: _history,
      );
      if (!mounted) return;
      setState(() {
        _grade = grade;
        _loading = false;
      });
      await service.refreshUsage();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SimulationStart? start = _start;
    final PracticeModeGrade? grade = _grade;
    final bool isSpeaking = _voice.isSpeaking;
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.scenario.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(
              '${widget.major.name} · ${widget.difficulty.label}',
              style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: <Widget>[
          if (grade == null && start != null) SessionTimer(elapsed: _elapsed),
          if (grade == null && _voiceReady)
            IconButton(
              tooltip: _autoSpeak ? 'Mute AI voice' : 'Enable AI voice',
              onPressed: () => setState(() => _autoSpeak = !_autoSpeak),
              icon: Icon(_autoSpeak ? Icons.volume_up_rounded : Icons.volume_off_rounded),
            ),
          if (grade == null && start != null)
            TextButton(onPressed: _loading ? null : _endAndGrade, child: const Text('End Scenario')),
        ],
      ),
      body: _error != null
          ? _ErrorBody(message: _error!, onRetry: _boot)
          : grade != null
              ? _ResultsBody(grade: grade, onDone: () => Navigator.pop(context))
              : _loading && start == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: <Widget>[
                        if (start != null)
                          SimulationScene(
                            role: widget.scenario.avatarRole,
                            aiRole: start.aiRole,
                            speechText: _latestAiSpeech ?? start.openingMessage,
                            isSpeaking: isSpeaking,
                            emotion: _emotion,
                          ),
                        if (start != null)
                          SizedBox(
                            height: 44,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              children: PracticeInteractionMode.values.map((PracticeInteractionMode mode) {
                                final bool selected = _mode == mode;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    avatar: Icon(mode.icon, size: 16, color: selected ? StudyColors.primary : textSecondary),
                                    label: Text(mode.label, style: const TextStyle(fontSize: 12)),
                                    selected: selected,
                                    onSelected: (_) => setState(() {
                                      _mode = mode;
                                      _input.text = '';
                                    }),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        Expanded(
                          child: _showChat
                              ? _ChatPanel(
                                  scrollController: _chatScroll,
                                  history: _history,
                                  aiRole: start?.aiRole ?? 'AI',
                                  loading: _loading,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: StudySurfaceCard(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Scenario briefing', style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        Text(start?.scenarioTitle ?? '', style: const TextStyle(fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: TutorMarkdownBody(text: start?.briefing ?? ''),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        _SessionInputBar(
                          controller: _input,
                          mode: _mode,
                          enabled: !_loading && start != null,
                          holdingMic: _holdingMic,
                          showChat: _showChat,
                          onToggleChat: () => setState(() => _showChat = !_showChat),
                          onSend: _send,
                          onHoldStart: _startHoldToSpeak,
                          onHoldEnd: _stopHoldToSpeak,
                        ),
                      ],
                    ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({
    required this.scrollController,
    required this.history,
    required this.aiRole,
    required this.loading,
  });

  final ScrollController scrollController;
  final List<SimulationMessage> history;
  final String aiRole;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: history.length + (loading ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (index >= history.length) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        return _ChatBubble(message: history[index], aiRole: aiRole);
      },
    );
  }
}

class _SessionInputBar extends StatelessWidget {
  const _SessionInputBar({
    required this.controller,
    required this.mode,
    required this.enabled,
    required this.holdingMic,
    required this.showChat,
    required this.onToggleChat,
    required this.onSend,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  final TextEditingController controller;
  final PracticeInteractionMode mode;
  final bool enabled;
  final bool holdingMic;
  final bool showChat;
  final VoidCallback onToggleChat;
  final VoidCallback onSend;
  final VoidCallback onHoldStart;
  final Future<void> Function() onHoldEnd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: onToggleChat,
                  icon: Icon(showChat ? Icons.notes_outlined : Icons.chat_bubble_outline_rounded),
                  tooltip: showChat ? 'Show briefing' : 'Show chat',
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: mode.hint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: enabled ? (_) => onSend() : null,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filled(onPressed: enabled ? onSend : null, icon: const Icon(Icons.send_rounded, size: 20)),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onLongPressStart: enabled ? (_) => onHoldStart() : null,
              onLongPressEnd: enabled ? (_) => onHoldEnd() : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: holdingMic ? StudyColors.danger : StudyColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(holdingMic ? Icons.mic_rounded : Icons.mic_none_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      holdingMic ? 'Release to send' : 'Hold to speak',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.aiRole});

  final SimulationMessage message;
  final String aiRole;

  @override
  Widget build(BuildContext context) {
    final bool isStudent = message.isStudent;
    final Color bg = isStudent
        ? StudyColors.primary.withValues(alpha: 0.12)
        : StudyColors.surface(Theme.of(context).brightness);
    return Align(
      alignment: isStudent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StudyColors.border(Theme.of(context).brightness)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              isStudent ? 'You' : aiRole,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: StudyColors.textSecondary(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: 4),
            TutorMarkdownBody(text: message.text),
          ],
        ),
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({required this.grade, required this.onDone});

  final PracticeModeGrade grade;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final bool great = grade.score >= 80;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const PracticeStepLabel(step: 4, title: 'Performance Feedback'),
        StudySurfaceCard(
          child: Column(
            children: <Widget>[
              PracticeScoreRing(score: grade.score),
              const SizedBox(height: 12),
              Text(
                great ? 'Great job!' : grade.score >= 70 ? 'Good work!' : 'Keep practicing!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              TutorMarkdownBody(text: grade.summary),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FeedbackBulletList(
          title: 'Strengths',
          items: grade.strengths,
          icon: Icons.check_circle_rounded,
          iconColor: StudyColors.success,
        ),
        const SizedBox(height: 16),
        FeedbackBulletList(
          title: 'Areas to improve',
          items: grade.improvements,
          icon: Icons.info_outline_rounded,
          iconColor: StudyColors.warning,
        ),
        if (grade.studyTopics.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          const Text('Recommended topics', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: grade.studyTopics
                .map(
                  (String topic) => Chip(
                    label: Text(topic, style: const TextStyle(fontSize: 12)),
                    backgroundColor: StudyColors.primary.withValues(alpha: 0.1),
                  ),
                )
                .toList(),
          ),
        ],
        if (grade.criteriaScores.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          const Text('Criteria breakdown', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...grade.criteriaScores.entries.map(
            (MapEntry<String, int> e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('${e.value}%', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: e.value / 100,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: StudyColors.border(Theme.of(context).brightness),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text('Improvement plan', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        StudySurfaceCard(child: TutorMarkdownBody(text: grade.improvementPlan)),
        const SizedBox(height: 20),
        FilledButton(onPressed: onDone, child: const Text('Done')),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: StudySurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}
