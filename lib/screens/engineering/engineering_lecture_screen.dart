import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/ai_professor_offline_chapter.dart';
import '../../mixins/ai_professor_voice_mixin.dart';
import '../../models/engineering/engineering_program.dart';
import '../../services/openai_service.dart';
import '../../theme/engineering_theme.dart';
import '../../utils/professor_stream_buffer.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/ai_professor/ai_professor_voice_panel.dart';
import '../../widgets/professor_message_body.dart';
import 'engineering_design_review_screen.dart';
import 'engineering_workspace_screen.dart';

/// Interactive AI engineering professor — curiosity first, formulas second.
class EngineeringLectureScreen extends StatefulWidget {
  const EngineeringLectureScreen({
    super.key,
    required this.major,
    required this.course,
    required this.topicTitle,
  });

  final EngineeringMajor major;
  final EngineeringCourse course;
  final String topicTitle;

  @override
  State<EngineeringLectureScreen> createState() => _EngineeringLectureScreenState();
}

class _EngineeringLectureScreenState extends State<EngineeringLectureScreen> with AiProfessorVoiceMixin {
  final TextEditingController _question = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<({bool isProfessor, String text})> _messages = <({bool isProfessor, String text})>[];
  bool _loading = false;
  bool _streaming = false;
  int? _streamingIndex;
  ProfessorStreamBuffer? _streamBuffer;

  @override
  void initState() {
    super.initState();
    unawaited(initAiProfessorVoice());
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_startLecture()));
  }

  @override
  void dispose() {
    _streamBuffer?.dispose();
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

  Future<void> _startLecture() async {
    final String offline = AiProfessorOfflineChapter.engineering(
      majorName: widget.major.name,
      courseTitle: widget.course.title,
      topicTitle: widget.topicTitle,
    );
    setState(() {
      _messages.add((isProfessor: true, text: offline));
    });
    setAiProfessorChapter(offline);

    if (!AppConfig.hasOpenAi) return;

    setState(() {
      _loading = true;
      _streaming = true;
      _streamingIndex = 0;
    });

    try {
      final OpenAiService ai = context.read<OpenAiService>();
      final int idx = 0;
      _streamBuffer = ProfessorStreamBuffer(
        onUpdate: (String fullText) {
          if (!mounted) return;
          setState(() {
            _messages[idx] = (isProfessor: true, text: fullText);
            _loading = false;
          });
          setAiProfessorChapter(fullText);
          _scrollToEnd();
        },
      );
      await for (final String chunk in ai.engineeringProfessorLectureStream(
        majorName: widget.major.name,
        courseTitle: widget.course.title,
        topicTitle: widget.topicTitle,
      )) {
        if (!mounted) return;
        _streamBuffer!.add(chunk);
      }
      if (!mounted) return;
      _streamBuffer!.flushNow();
      setAiProfessorChapter(_streamBuffer!.text);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (_streamingIndex != null &&
            _messages.isNotEmpty &&
            _messages[_streamingIndex!].text.trim().isEmpty) {
          _messages[_streamingIndex!] = (isProfessor: true, text: offline);
        }
        setAiProfessorChapter(offline);
      });
      StudyMessenger.showError(context, e);
    } finally {
      _streamBuffer?.dispose();
      _streamBuffer = null;
      if (mounted) {
        setState(() {
          _streaming = false;
          _loading = false;
          _streamingIndex = null;
        });
      }
    }
  }

  Future<void> _ask() async {
    final String q = _question.text.trim();
    if (q.isEmpty || _loading || _streaming) return;
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
        reply = await context.read<OpenAiService>().engineeringProfessorAnswer(
              majorName: widget.major.name,
              courseTitle: widget.course.title,
              topicTitle: widget.topicTitle,
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
    final String q = question.toLowerCase();
    if (q.contains('fail') || q.contains('collapse') || q.contains('break')) {
      return 'Failures usually start where **demand exceeds capacity** with no margin left. '
          'Ask: what is the load path, and which part is the weakest link? '
          'For **${widget.topicTitle}**, name that weak link in your own words, then we tighten the explanation.';
    }
    if (q.contains('formula') || q.contains('equation') || q.contains('calculate')) {
      return 'Before the equation: what are we solving for, and what is given? '
          'Write: unknown, knowns, units. Then the formula is just a relationship between those. '
          'Tell me the unknown for **${widget.topicTitle}**.';
    }
    if (q.contains('safe') || q.contains('fos') || q.contains('factor')) {
      return '**Factor of safety** ≈ how many times stronger the design is than the expected load. '
          'FoS = 1 means you are at the edge. Real structures often use FoS well above 1 because loads and materials are uncertain. '
          'What FoS would make you sleep at night for this problem?';
    }
    return 'Good question. In one sentence: what are you trying to **change**, and what bad outcome are you trying to **prevent**? '
        'Answer those two, and I will map it onto **${widget.topicTitle}**.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EngineeringTheme.background,
      appBar: AppBar(
        backgroundColor: EngineeringTheme.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.topicTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(
              '${widget.major.name} · ${widget.course.title}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          AiProfessorVoicePanel(
            speaking: aiProfessorSpeaking,
            speed: aiProfessorSpeed,
            mode: aiProfessorVoiceMode,
            voiceReady: aiProfessorVoiceReady,
            highlightSentence: aiProfessorHighlight,
            primaryColor: EngineeringTheme.primary,
            surfaceColor: EngineeringTheme.surface,
            textPrimaryColor: EngineeringTheme.textPrimary,
            textSecondaryColor: EngineeringTheme.textSecondary,
            onPlayPause: () => unawaited(toggleAiProfessorSpeech(topicTitle: widget.topicTitle)),
            onStop: () => unawaited(stopAiProfessorSpeech()),
            onSpeed: onAiProfessorSpeed,
            onRewind: rewindAiProfessorSpeech,
            onSkipAhead: skipAheadAiProfessorSpeech,
            onMode: onAiProfessorVoiceMode,
            studyActions: <VirtualUniversityStudyAction>[
              VirtualUniversityStudyAction(
                label: 'Design review',
                icon: Icons.rate_review_outlined,
                description: 'Submit a design and get professor feedback',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EngineeringDesignReviewScreen(major: widget.major, course: widget.course),
                  ),
                ),
              ),
              VirtualUniversityStudyAction(
                label: 'Virtual lab',
                icon: Icons.precision_manufacturing_outlined,
                description: 'Open the engineering workspace simulator',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EngineeringWorkspaceScreen(
                      major: widget.major,
                      course: widget.course,
                      mode: EngineeringLearningMode.virtualLab,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              itemCount: _messages.length + ((_loading || _streaming) && _messages.isNotEmpty ? 1 : 0),
              itemBuilder: (BuildContext context, int i) {
                if (i >= _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Professor is thinking…', style: TextStyle(color: EngineeringTheme.textSecondary, fontSize: 12)),
                  );
                }
                final ({bool isProfessor, String text}) m = _messages[i];
                final bool isStreamingMessage = _streaming && m.isProfessor && i == _streamingIndex;
                return Align(
                  alignment: m.isProfessor ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: m.isProfessor ? double.infinity : MediaQuery.sizeOf(context).width * 0.88,
                    ),
                    decoration: BoxDecoration(
                      color: m.isProfessor
                          ? EngineeringTheme.surface
                          : EngineeringTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: EngineeringTheme.border),
                    ),
                    child: m.isProfessor
                        ? ProfessorMessageBody(
                            text: m.text,
                            isStreaming: isStreamingMessage,
                            textColor: EngineeringTheme.textPrimary,
                          )
                        : Text(m.text, style: TextStyle(color: EngineeringTheme.textPrimary, height: 1.4)),
                  ),
                );
              },
            ),
          ),
          Material(
            color: EngineeringTheme.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _question,
                        style: TextStyle(color: EngineeringTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Interrupt — ask a design question…',
                          hintStyle: TextStyle(color: EngineeringTheme.textSecondary),
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => unawaited(_ask()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _loading || _streaming ? null : () => unawaited(_ask()),
                      style: FilledButton.styleFrom(
                        backgroundColor: EngineeringTheme.primary,
                        foregroundColor: Colors.white,
                      ),
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
