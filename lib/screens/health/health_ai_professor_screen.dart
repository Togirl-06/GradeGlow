import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/ai_professor_offline_chapter.dart';
import '../../data/health_lesson_content.dart';
import '../../mixins/ai_professor_voice_mixin.dart';
import '../../models/health_faculty_program.dart';
import '../../models/virtual_university_lesson_contract.dart';
import '../../services/health_faculty_progress_service.dart';
import '../../services/openai_service.dart';
import '../../services/subscription_service.dart';
import '../../services/vu_notes_service.dart';
import '../../utils/professor_stream_buffer.dart';
import '../../utils/study_messenger.dart';
import '../../utils/virtual_university_premium.dart';
import '../../widgets/ai_professor/ai_professor_voice_panel.dart';
import '../../widgets/professor_message_body.dart';
import '../membership_screen.dart';

/// Real AI Professor for Nursing / Medicine / Psychology lessons.
class HealthAiProfessorScreen extends StatefulWidget {
  const HealthAiProfessorScreen({super.key, required this.path});

  final HealthLessonPath path;

  @override
  State<HealthAiProfessorScreen> createState() =>
      _HealthAiProfessorScreenState();
}

class _HealthAiProfessorScreenState extends State<HealthAiProfessorScreen>
    with AiProfessorVoiceMixin {
  final TextEditingController _question = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<({bool isProfessor, String text})> _messages =
      <({bool isProfessor, String text})>[];
  bool _loading = false;
  bool _streaming = false;
  int? _streamingIndex;
  ProfessorStreamBuffer? _streamBuffer;
  bool _finishing = false;

  HealthLessonPath get path => widget.path;

  @override
  void initState() {
    super.initState();
    unawaited(initAiProfessorVoice());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_startLecture());
    });
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
    final String offline = AiProfessorOfflineChapter.health(
      facultyTitle: path.faculty.title,
      courseTitle: path.course.title,
      topicTitle: path.topic.title,
      lectureBody: HealthLessonContent.lecture(path),
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
      final bool premium = _isPremium;
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
      await for (final String chunk in ai.healthProfessorLectureStream(
        facultyTitle: path.faculty.title,
        courseTitle: path.course.title,
        topicTitle: path.topic.title,
        premium: premium,
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

  bool get _isPremium {
    try {
      return context.read<SubscriptionService>().isPremium;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _ensureAiQuota() async {
    final bool premium = _isPremium;
    final bool allowed = await VirtualUniversityPremium.canAskAiProfessor(
      premium,
    );
    if (allowed) return true;
    if (!mounted) return false;
    final bool? go = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(VirtualUniversityPremium.dailyAiLimitReached.title),
        content: Text(VirtualUniversityPremium.dailyAiLimitReached.message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('OK'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
    if (go == true && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const MembershipScreen()),
      );
    }
    return false;
  }

  Future<void> _ask() async {
    final String q = _question.text.trim();
    if (q.isEmpty || _loading || _streaming) return;
    if (!await _ensureAiQuota()) return;
    await VirtualUniversityPremium.recordAiQuestion();

    _question.clear();
    setState(() {
      _messages.add((isProfessor: false, text: q));
      _loading = true;
    });
    _scrollToEnd();

    try {
      final String contextText = _messages
          .where((m) => m.isProfessor)
          .map((m) => m.text)
          .join('\n');
      final String reply;
      if (AppConfig.hasOpenAi) {
        if (!mounted) return;
        final OpenAiService ai = context.read<OpenAiService>();
        reply = await ai.healthProfessorAnswer(
          facultyTitle: path.faculty.title,
          courseTitle: path.course.title,
          topicTitle: path.topic.title,
          lectureContext: contextText,
          question: q,
          premium: _isPremium,
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
    if (q.contains('safe') || q.contains('red flag') || q.contains('escalat')) {
      return 'Safety first for **${path.topic.title}**: name the red flags, '
          'what you would escalate, and what measurable change means “better”. '
          'Write that triad, then we refine.';
    }
    if (q.contains('assess') || q.contains('exam') || q.contains('history')) {
      return 'Assessment before action. For **${path.topic.title}**, list '
          'three data points you must gather in the first 5 minutes, then the '
          'one finding that would change your plan.';
    }
    if (q.contains('document') || q.contains('handoff') || q.contains('note')) {
      return 'Use a crisp handoff: assessment → action → response → watch-fors. '
          'Draft one sentence for **${path.topic.title}** in that shape.';
    }
    return 'Good question. Restate **${path.topic.title}** in one sentence, '
        'then tell me what you are trying to decide. I will map the next teaching move.';
  }

  Future<void> _bookmark() async {
    try {
      await VuNotesService.instance.addBookmark(
        title: '${path.topic.title} · AI Professor',
        lessonId: path.topic.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmarked to campus notes')),
      );
    } catch (_) {}
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    try {
      await context.read<HealthFacultyProgressService>().complete(
        path.topic.id,
        VuCanonicalActivity.aiProfessor.name,
      );
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI Professor lecture complete')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              path.topic.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              '${path.faculty.title} · ${path.course.title}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Bookmark',
            onPressed: _bookmark,
            icon: const Icon(Icons.bookmark_add_outlined),
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
            primaryColor: scheme.primary,
            surfaceColor: scheme.surfaceContainerHighest,
            textPrimaryColor: scheme.onSurface,
            textSecondaryColor: scheme.onSurfaceVariant,
            onPlayPause: () async {
              final bool premium = _isPremium;
              if (!aiProfessorSpeaking) {
                final bool ok = await VirtualUniversityPremium.canUseLectureTts(
                  premium,
                );
                if (!mounted) return;
                if (!ok) {
                  StudyMessenger.showError(
                    this.context,
                    VirtualUniversityPremium.dailyTtsLimitReached.message,
                  );
                  return;
                }
                await VirtualUniversityPremium.recordTtsMinutes(1);
              }
              if (!mounted) return;
              await toggleAiProfessorSpeech(topicTitle: path.topic.title);
            },
            onStop: () => unawaited(stopAiProfessorSpeech()),
            onSpeed: onAiProfessorSpeed,
            onRewind: rewindAiProfessorSpeech,
            onSkipAhead: skipAheadAiProfessorSpeech,
            onMode: onAiProfessorVoiceMode,
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _messages.length + (_loading && !_streaming ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index >= _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final ({bool isProfessor, String text}) msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: msg.isProfessor
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.92,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: msg.isProfessor
                              ? scheme.surfaceContainerHighest
                              : scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: msg.isProfessor
                              ? ProfessorMessageBody(
                                  text: msg.text,
                                  isStreaming:
                                      _streaming && index == _streamingIndex,
                                )
                              : Text(
                                  msg.text,
                                  style: const TextStyle(height: 1.4),
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _question,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => unawaited(_ask()),
                          decoration: const InputDecoration(
                            hintText: 'Ask the AI Professor…',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _loading || _streaming
                            ? null
                            : () => unawaited(_ask()),
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _finishing ? null : _finish,
                      child: const Text('Finish lecture'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
