import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/cs_curriculum/cs_curriculum_catalog.dart';
import '../../data/ai_professor_offline_chapter.dart';
import '../../mixins/ai_professor_voice_mixin.dart';
import '../../models/cs_curriculum.dart';
import '../../services/cs_lecture_cache.dart';
import '../../services/openai_service.dart';
import '../../theme/cs_hybrid_theme.dart';
import '../../theme/leetcode_theme.dart';
import '../../theme/study_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/ai_professor/ai_professor_voice_panel.dart';
import '../../widgets/professor_message_body.dart';
import 'cs_w3s_practice_screen.dart';

/// Conversational AI professor lecture — interrupt anytime to ask questions.
class CsProfessorLectureScreen extends StatefulWidget {
  const CsProfessorLectureScreen({
    super.key,
    required this.topicTitle,
    required this.courseName,
    this.curriculumTopicId,
    this.curriculumLanguageId,
  });

  final String topicTitle;
  final String courseName;
  final String? curriculumTopicId;
  final String? curriculumLanguageId;

  @override
  State<CsProfessorLectureScreen> createState() => _CsProfessorLectureScreenState();
}

class CsProfessorTopicPickerScreen extends StatelessWidget {
  const CsProfessorTopicPickerScreen({super.key});

  static const List<({String course, String topic})> topics = <({String course, String topic})>[
    (course: 'Data Structures', topic: 'Arrays & Linked Lists'),
    (course: 'Data Structures', topic: 'Stacks & Queues'),
    (course: 'Algorithms', topic: 'Binary Search'),
    (course: 'Algorithms', topic: 'Sorting Algorithms'),
    (course: 'Algorithms', topic: 'Dynamic Programming'),
    (course: 'Algorithms', topic: 'Graph Traversal (BFS/DFS)'),
    (course: 'Programming Fundamentals', topic: 'Recursion'),
    (course: 'Databases', topic: 'SQL Joins'),
    (course: 'Operating Systems', topic: 'Processes & Threads'),
    (course: 'Software Engineering', topic: 'Design Patterns'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LeetCodeTheme.background,
      appBar: AppBar(
        backgroundColor: LeetCodeTheme.surface,
        foregroundColor: LeetCodeTheme.textPrimary,
        title: const Text('AI Professor'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        itemBuilder: (BuildContext context, int i) {
          final ({String course, String topic}) t = topics[i];
          return Card(
            color: LeetCodeTheme.surface,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(t.topic, style: const TextStyle(color: LeetCodeTheme.textPrimary, fontWeight: FontWeight.w700)),
              subtitle: Text(t.course, style: const TextStyle(color: LeetCodeTheme.textSecondary)),
              trailing: const Icon(Icons.school_rounded, color: LeetCodeTheme.accent),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CsProfessorLectureScreen(topicTitle: t.topic, courseName: t.course),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CsProfessorLectureScreenState extends State<CsProfessorLectureScreen> with AiProfessorVoiceMixin {
  final TextEditingController _question = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<({bool isProfessor, String text})> _messages = <({bool isProfessor, String text})>[];
  bool _loading = false;
  bool _streaming = false;
  int? _streamingProfessorIndex;
  Timer? _streamFlushTimer;
  String _pendingStreamText = '';
  bool _didAutoSpeak = false;

  @override
  void initState() {
    super.initState();
    unawaited(initAiProfessorVoice());
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLecture());
  }

  @override
  void dispose() {
    _streamFlushTimer?.cancel();
    _question.dispose();
    _scroll.dispose();
    disposeAiProfessorVoice();
    super.dispose();
  }

  void _prefetchNextTopic() {
    if (widget.curriculumTopicId == null || widget.curriculumLanguageId == null) return;
    final CsCurriculumTopic? next = CsCurriculumCatalog.nextTopicInTrack(
      widget.curriculumLanguageId!,
      widget.curriculumTopicId!,
    );
    if (next == null) return;
    CsLectureCache.prefetch(
      openAi: context.read<OpenAiService>(),
      courseName: widget.courseName,
      topicTitle: next.title,
    );
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  void _flushStreamText({required bool force}) {
    _streamFlushTimer?.cancel();
    _streamFlushTimer = null;
    if (_pendingStreamText.isEmpty || _streamingProfessorIndex == null) return;
    final int idx = _streamingProfessorIndex!;
    final String chunk = _pendingStreamText;
    _pendingStreamText = '';
    setState(() {
      final ({bool isProfessor, String text}) current = _messages[idx];
      _messages[idx] = (isProfessor: true, text: current.text + chunk);
    });
    if (force) _scrollToBottom();
  }

  void _appendStreamChunk(String chunk) {
    if (_streamingProfessorIndex == null) return;
    _pendingStreamText += chunk;
    if (_streamFlushTimer != null) return;
    _streamFlushTimer = Timer(const Duration(milliseconds: 60), () {
      _flushStreamText(force: true);
    });
  }

  Future<void> _startLecture() async {
    final String offline = AiProfessorOfflineChapter.cs(
      courseName: widget.courseName,
      topicTitle: widget.topicTitle,
    );

    void showChapter(String text) {
      setState(() {
        if (_messages.isEmpty) {
          _messages.add((isProfessor: true, text: text));
        } else if (_messages.first.isProfessor) {
          _messages[0] = (isProfessor: true, text: text);
        } else {
          _messages.insert(0, (isProfessor: true, text: text));
        }
      });
      setAiProfessorChapter(text);
    }

    showChapter(offline);
    _maybeAutoSpeak();

    if (!AppConfig.hasOpenAi) return;

    final String? cached = CsLectureCache.get(
      courseName: widget.courseName,
      topicTitle: widget.topicTitle,
    );
    if (cached != null) {
      showChapter(cached);
      _prefetchNextTopic();
      _maybeAutoSpeak();
      return;
    }

    setState(() {
      _loading = true;
      _streaming = true;
      _streamingProfessorIndex = 0;
    });

    final StringBuffer lecture = StringBuffer();
    try {
      await for (final String chunk in context.read<OpenAiService>().csProfessorLectureStream(
            courseName: widget.courseName,
            topicTitle: widget.topicTitle,
          )) {
        if (!mounted) return;
        lecture.write(chunk);
        if (_loading) {
          setState(() => _loading = false);
        }
        _appendStreamChunk(chunk);
      }
      if (!mounted) return;
      _flushStreamText(force: true);
      final String fullLecture = lecture.toString().trim();
      CsLectureCache.put(
        courseName: widget.courseName,
        topicTitle: widget.topicTitle,
        lecture: fullLecture,
      );
      setState(() {
        _streaming = false;
        _loading = false;
        _streamingProfessorIndex = null;
      });
      setAiProfessorChapter(fullLecture);
      _prefetchNextTopic();
    } catch (e) {
      if (!mounted) return;
      _flushStreamText(force: false);
      setState(() {
        _streaming = false;
        _loading = false;
        _streamingProfessorIndex = null;
        if (_messages.isNotEmpty && _messages.last.isProfessor && _messages.last.text.trim().isEmpty) {
          _messages.removeLast();
        }
      });
      StudyMessenger.showError(context, e);
    }
  }

  void _maybeAutoSpeak() {
    if (_didAutoSpeak || !mounted) return;
    final String chapter = _messages.isNotEmpty && _messages.first.isProfessor
        ? _messages.first.text.trim()
        : '';
    if (chapter.isEmpty) return;
    _didAutoSpeak = true;
    unawaited(toggleAiProfessorSpeech(topicTitle: widget.topicTitle));
  }

  Future<void> _confused() async {
    if (_loading || _streaming) return;
    _question.text =
        "I'm confused — please explain this more simply, step by step, with a short coding example.";
    await _ask();
  }

  Future<void> _ask() async {
    final String q = _question.text.trim();
    if (q.isEmpty || _loading || _streaming) return;
    _question.clear();
    setState(() {
      _messages.add((isProfessor: false, text: q));
      _loading = true;
    });
    try {
      final String reply = await context.read<OpenAiService>().csProfessorAnswer(
            courseName: widget.courseName,
            topicTitle: widget.topicTitle,
            lectureContext: _messages.where((m) => m.isProfessor).map((m) => m.text).join('\n'),
            question: q,
          );
      if (!mounted) return;
      setState(() {
        _messages.add((isProfessor: true, text: reply));
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, e);
    }
  }

  Future<void> _goToNextTopic(CsCurriculumTopic next) async {
    await stopAiProfessorSpeech();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CsProfessorLectureScreen(
          topicTitle: next.title,
          courseName: widget.courseName,
          curriculumTopicId: next.id,
          curriculumLanguageId: widget.curriculumLanguageId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool curriculum = widget.curriculumTopicId != null;
    final Color bg = curriculum ? CsHybridTheme.background : LeetCodeTheme.background;
    final Color surface = curriculum ? CsHybridTheme.surface : LeetCodeTheme.surface;
    final Color textPrimary = curriculum ? CsHybridTheme.textPrimary : LeetCodeTheme.textPrimary;
    final Color textSecondary = curriculum ? CsHybridTheme.textSecondary : LeetCodeTheme.textSecondary;
    final Color border = curriculum ? CsHybridTheme.border : LeetCodeTheme.border;
    final Color accent = curriculum ? StudyColors.primary : LeetCodeTheme.accent;
    final CsCurriculumTopic? nextTopic = curriculum &&
            widget.curriculumTopicId != null &&
            widget.curriculumLanguageId != null
        ? CsCurriculumCatalog.nextTopicInTrack(
            widget.curriculumLanguageId!,
            widget.curriculumTopicId!,
          )
        : null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: curriculum ? StudyColors.primary : LeetCodeTheme.surface,
        foregroundColor: curriculum ? Colors.white : LeetCodeTheme.textPrimary,
        title: Text(widget.topicTitle),
        actions: <Widget>[
          if (nextTopic != null)
            TextButton.icon(
              onPressed: _loading || _streaming ? null : () => unawaited(_goToNextTopic(nextTopic)),
              icon: Icon(Icons.arrow_forward_rounded, color: curriculum ? Colors.white : accent),
              label: Text(
                'Next',
                style: TextStyle(color: curriculum ? Colors.white : accent, fontWeight: FontWeight.w800),
              ),
            ),
          if (curriculum)
            TextButton.icon(
              onPressed: () async {
                await stopAiProfessorSpeech();
                if (!context.mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => CsW3sPracticeScreen(
                      topicId: widget.curriculumTopicId!,
                      curriculumLanguageId: widget.curriculumLanguageId,
                      topicTitle: widget.topicTitle,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.code_rounded, color: curriculum ? Colors.white : accent),
              label: Text('Practice', style: TextStyle(color: curriculum ? Colors.white : accent, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          AiProfessorVoicePanel(
            speaking: aiProfessorSpeaking,
            speed: aiProfessorSpeed,
            mode: aiProfessorVoiceMode,
            voiceReady: aiProfessorVoiceReady,
            highlightSentence: aiProfessorHighlight,
            primaryColor: accent,
            surfaceColor: surface,
            textPrimaryColor: textPrimary,
            textSecondaryColor: textSecondary,
            onPlayPause: () => unawaited(toggleAiProfessorSpeech(topicTitle: widget.topicTitle)),
            onStop: () => unawaited(stopAiProfessorSpeech()),
            onSpeed: onAiProfessorSpeed,
            onRewind: rewindAiProfessorSpeech,
            onSkipAhead: skipAheadAiProfessorSpeech,
            onMode: onAiProfessorVoiceMode,
            studyActions: <VirtualUniversityStudyAction>[
              if (curriculum && widget.curriculumTopicId != null)
                VirtualUniversityStudyAction(
                  label: 'Code practice',
                  icon: Icons.code_rounded,
                  description: 'Solve coding exercises for this topic',
                  onTap: () async {
                    await stopAiProfessorSpeech();
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CsW3sPracticeScreen(
                          topicId: widget.curriculumTopicId!,
                          curriculumLanguageId: widget.curriculumLanguageId,
                          topicTitle: widget.topicTitle,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          if (_loading && _messages.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(color: StudyColors.primary),
                    const SizedBox(height: 12),
                    const Text('Connecting to professor…', style: TextStyle(color: CsHybridTheme.textSecondary)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + ((_loading || _streaming) && _messages.isNotEmpty ? 1 : 0),
                itemBuilder: (BuildContext context, int i) {
                  if (i >= _messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    );
                  }
                  final ({bool isProfessor, String text}) m = _messages[i];
                  final bool isStreamingMessage =
                      _streaming && m.isProfessor && i == _streamingProfessorIndex;
                  return Align(
                    alignment: m.isProfessor ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(
                        maxWidth: m.isProfessor ? double.infinity : MediaQuery.sizeOf(context).width * 0.88,
                      ),
                      decoration: BoxDecoration(
                        color: m.isProfessor ? surface : (curriculum ? CsHybridTheme.background : LeetCodeTheme.surfaceElevated),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: m.isProfessor ? border : accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: m.isProfessor
                          ? ProfessorMessageBody(
                              text: m.text,
                              isStreaming: isStreamingMessage,
                              textColor: textPrimary,
                            )
                          : Text(m.text, style: TextStyle(color: textPrimary)),
                    ),
                  );
                },
              ),
            ),
          Material(
            color: surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: _loading || _streaming ? null : () => unawaited(_confused()),
                      icon: const Icon(Icons.psychology_alt_rounded, size: 18),
                      label: const Text('Confused'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textPrimary,
                        side: BorderSide(color: border),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _question,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Interrupt — ask a question…',
                          hintStyle: TextStyle(color: textSecondary),
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => unawaited(_ask()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _loading || _streaming ? null : () => unawaited(_ask()),
                      style: curriculum
                          ? FilledButton.styleFrom(backgroundColor: StudyColors.primary, foregroundColor: Colors.white)
                          : FilledButton.styleFrom(backgroundColor: LeetCodeTheme.accent, foregroundColor: Colors.black),
                      child: const Text('Ask'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
