import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/physics/physics_chapter_navigation.dart';
import '../../data/physics/physics_topic_knowledge_engine.dart';
import '../../mixins/ai_professor_voice_mixin.dart';
import '../../models/physics/physics_program.dart';
import '../../services/openai_service.dart';
import '../../theme/physics_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/ai_professor/ai_professor_chapter_nav_bar.dart';
import '../../widgets/ai_professor/ai_professor_voice_panel.dart';
import '../../widgets/professor_message_body.dart';
import 'physics_routes.dart';

/// AI physics professor — full digital textbook chapter plus voice and Q&A.
class PhysicsLectureScreen extends StatefulWidget {
  const PhysicsLectureScreen({
    super.key,
    required this.track,
    required this.course,
    required this.topic,
  });

  final PhysicsTrack track;
  final PhysicsCourse course;
  final PhysicsTopic topic;

  @override
  State<PhysicsLectureScreen> createState() => _PhysicsLectureScreenState();
}

class _PhysicsLectureScreenState extends State<PhysicsLectureScreen> with AiProfessorVoiceMixin {
  final TextEditingController _question = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<({bool isProfessor, String text})> _messages = <({bool isProfessor, String text})>[];
  bool _loading = false;
  bool _expandingChapter = false;

  @override
  void initState() {
    super.initState();
    unawaited(initAiProfessorVoice());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadChapter());
  }

  @override
  void dispose() {
    _question.dispose();
    _scroll.dispose();
    disposeAiProfessorVoice();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _loadChapter() {
    final String chapter = PhysicsTopicKnowledgeEngine.completeGuide(
      course: widget.course,
      topic: widget.topic,
      levelLabel: widget.track.level.label,
    );
    setState(() {
      _messages
        ..clear()
        ..add((isProfessor: true, text: chapter));
    });
    setAiProfessorChapter(chapter);
  }

  Future<void> _expandWithAi() async {
    if (!AppConfig.hasOpenAi) {
      StudyMessenger.showError(context, 'Connect OpenAI to generate the AI textbook edition.');
      return;
    }
    setState(() => _expandingChapter = true);
    try {
      final String expanded = await context.read<OpenAiService>().physicsProfessorTextbookChapter(
            levelLabel: widget.track.level.label,
            courseTitle: widget.course.title,
            topic: widget.topic,
            course: widget.course,
          );
      if (!mounted) return;
      setState(() {
        if (_messages.isNotEmpty && _messages.first.isProfessor) {
          _messages[0] = (isProfessor: true, text: expanded);
        } else {
          _messages.insert(0, (isProfessor: true, text: expanded));
        }
        _expandingChapter = false;
      });
      setAiProfessorChapter(expanded);
    } catch (e) {
      if (!mounted) return;
      setState(() => _expandingChapter = false);
      StudyMessenger.showError(context, e);
    }
  }

  Future<void> _ask() async {
    final String q = _question.text.trim();
    if (q.isEmpty || _loading) return;
    _question.clear();
    setState(() {
      _messages.add((isProfessor: false, text: q));
      _loading = true;
    });
    _scrollToEnd();

    try {
      final String contextText =
          _messages.where((m) => m.isProfessor).map((m) => m.text).join('\n');
      final String reply;
      if (AppConfig.hasOpenAi) {
        reply = await context.read<OpenAiService>().physicsProfessorAnswer(
              levelLabel: widget.track.level.label,
              courseTitle: widget.course.title,
              topicTitle: widget.topic.title,
              lectureContext: contextText,
              question: q,
            );
      } else {
        reply = _offlineAnswer(q);
      }
      if (!mounted) return;
      setState(() {
        _messages.add((isProfessor: true, text: reply));
        _loading = false;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, e);
    }
  }

  String _offlineAnswer(String question) {
    return '**${widget.topic.title}** — your question: "$question"\n\n'
        'Review the textbook chapter above: definitions, derivations, worked examples, labs, and the mastery checklist.';
  }

  PhysicsChapterNav get _chapterNav =>
      PhysicsChapterNav.forTopic(course: widget.course, topic: widget.topic);

  void _openAdjacentTopic(PhysicsTopic topic) {
    unawaited(stopAiProfessorSpeech());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => PhysicsLectureScreen(
          track: widget.track,
          course: widget.course,
          topic: topic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PhysicsChapterNav nav = _chapterNav;
    return Scaffold(
      backgroundColor: PhysicsTheme.background,
      appBar: AppBar(
        backgroundColor: PhysicsTheme.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.topic.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Text(
              'Digital Textbook · AI Professor',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70),
            ),
          ],
        ),
        actions: <Widget>[
          if (AppConfig.hasOpenAi)
            TextButton(
              onPressed: _expandingChapter ? null : () => unawaited(_expandWithAi()),
              child: Text(
                _expandingChapter ? 'Writing…' : 'AI edition',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
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
            primaryColor: PhysicsTheme.primary,
            surfaceColor: PhysicsTheme.surface,
            textPrimaryColor: PhysicsTheme.textPrimary,
            textSecondaryColor: PhysicsTheme.textSecondary,
            onPlayPause: () => unawaited(toggleAiProfessorSpeech(topicTitle: widget.topic.title)),
            onStop: () => unawaited(stopAiProfessorSpeech()),
            onSpeed: onAiProfessorSpeed,
            onRewind: rewindAiProfessorSpeech,
            onSkipAhead: skipAheadAiProfessorSpeech,
            onMode: onAiProfessorVoiceMode,
            studyActions: <VirtualUniversityStudyAction>[
              VirtualUniversityStudyAction(
                label: 'Topic quiz',
                icon: Icons.quiz_outlined,
                description: 'Multiple-choice review for ${widget.topic.title}',
                onTap: () => PhysicsRoutes.openMode(
                  context,
                  track: widget.track,
                  course: widget.course,
                  topic: widget.topic,
                  mode: PhysicsLearningMode.quiz,
                ),
              ),
              VirtualUniversityStudyAction(
                label: 'Formula notebook',
                icon: Icons.functions_outlined,
                description: 'All equations and symbols for this topic',
                onTap: () => PhysicsRoutes.openMode(
                  context,
                  track: widget.track,
                  course: widget.course,
                  topic: widget.topic,
                  mode: PhysicsLearningMode.formulaNotebook,
                ),
              ),
              VirtualUniversityStudyAction(
                label: '3D simulation',
                icon: Icons.view_in_ar_outlined,
                description: 'Run the virtual lab experiment',
                onTap: () => PhysicsRoutes.openMode(
                  context,
                  track: widget.track,
                  course: widget.course,
                  topic: widget.topic,
                  mode: PhysicsLearningMode.virtualLab,
                ),
              ),
            ],
          ),
          Expanded(child: _buildMessageList()),
          AiProfessorChapterNavBar(
            chapterNumber: nav.chapterNumber,
            totalChapters: nav.totalChapters,
            previousTitle: nav.previous?.title,
            nextTitle: nav.next?.title,
            onPrevious: nav.previous != null ? () => _openAdjacentTopic(nav.previous!) : null,
            onNext: nav.next != null ? () => _openAdjacentTopic(nav.next!) : null,
            primaryColor: PhysicsTheme.primary,
            surfaceColor: PhysicsTheme.surface,
            borderColor: PhysicsTheme.border,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _question,
                      decoration: InputDecoration(
                        hintText: 'Ask the professor about ${widget.topic.title}…',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => unawaited(_ask()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _loading ? null : () => unawaited(_ask()),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      itemCount: _messages.length + (_loading ? 1 : 0) + (_expandingChapter ? 1 : 0),
      itemBuilder: (BuildContext context, int i) {
        if (i >= _messages.length) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator(color: PhysicsTheme.primary)),
          );
        }
        final ({bool isProfessor, String text}) m = _messages[i];
        final bool isChapter = m.isProfessor && i == 0;
        return Align(
          alignment: m.isProfessor ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            width: isChapter ? double.infinity : null,
            constraints: BoxConstraints(
              maxWidth: isChapter ? double.infinity : MediaQuery.sizeOf(context).width * 0.92,
            ),
            decoration: BoxDecoration(
              color: m.isProfessor ? PhysicsTheme.surface : PhysicsTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PhysicsTheme.border),
            ),
            child: m.isProfessor
                ? ProfessorMessageBody(
                    text: m.text,
                    isStreaming: false,
                    textColor: PhysicsTheme.textPrimary,
                  )
                : Text(m.text, style: TextStyle(color: PhysicsTheme.textPrimary, height: 1.4)),
          ),
        );
      },
    );
  }
}
