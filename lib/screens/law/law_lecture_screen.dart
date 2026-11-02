import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/ai_professor_chapter_navigation.dart';
import '../../data/ai_professor_offline_chapter.dart';
import '../../mixins/ai_professor_voice_mixin.dart';
import '../../models/law/law_program.dart';
import '../../services/law_lecture_notes_service.dart';
import '../../services/openai_service.dart';
import '../../theme/law_theme.dart';
import '../../utils/professor_stream_buffer.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/ai_professor/ai_professor_chapter_nav_bar.dart';
import '../../widgets/ai_professor/ai_professor_voice_panel.dart';
import '../../widgets/professor_message_body.dart';
import 'law_exam_screen.dart';

class LawLectureScreen extends StatefulWidget {
  const LawLectureScreen({super.key, required this.course, required this.lesson});

  final LawCourse course;
  final LawLesson lesson;

  @override
  State<LawLectureScreen> createState() => _LawLectureScreenState();
}

class _LawLectureScreenState extends State<LawLectureScreen> with AiProfessorVoiceMixin {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_start()));
  }

  @override
  void dispose() {
    _streamBuffer?.dispose();
    _question.dispose();
    _scroll.dispose();
    disposeAiProfessorVoice();
    super.dispose();
  }

  void _scrollEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    });
  }

  Future<void> _start() async {
    final String offline = _offlineLecture();
    setState(() {
      _messages.add((isProfessor: true, text: offline));
    });
    setAiProfessorChapter(offline);
    if (!AppConfig.hasOpenAi) {
      await LawLectureNotesService.instance.saveNotes(
        courseTitle: widget.course.title,
        lessonId: widget.lesson.id,
        notes: offline,
      );
      return;
    }

    final OpenAiService openAi = context.read<OpenAiService>();
    await LawLectureNotesService.instance.saveNotes(
      courseTitle: widget.course.title,
      lessonId: widget.lesson.id,
      notes: offline,
    );
    if (!mounted) return;

    setState(() {
      _loading = true;
      _streaming = true;
      _streamingIndex = 0;
    });
    try {
      final int idx = 0;
      _streamBuffer = ProfessorStreamBuffer(
        onUpdate: (String fullText) {
          if (!mounted) return;
          setState(() {
            _messages[idx] = (isProfessor: true, text: fullText);
            _loading = false;
          });
          setAiProfessorChapter(fullText);
          _scrollEnd();
        },
      );
      await for (final String chunk in openAi.lawProfessorLectureStream(
            courseTitle: widget.course.title,
            lessonTitle: widget.lesson.title,
            hook: widget.lesson.hook,
            question: widget.lesson.question,
            elements: widget.lesson.elements,
          )) {
        if (!mounted) return;
        _streamBuffer!.add(chunk);
      }
      if (!mounted) return;
      _streamBuffer!.flushNow();
      await LawLectureNotesService.instance.saveNotes(
        courseTitle: widget.course.title,
        lessonId: widget.lesson.id,
        notes: _streamBuffer!.text,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (_streamingIndex != null && _messages[_streamingIndex!].text.trim().isEmpty) {
          _messages.removeAt(_streamingIndex!);
        }
        _messages.add((isProfessor: true, text: _offlineLecture()));
      });
      await LawLectureNotesService.instance.saveNotes(
        courseTitle: widget.course.title,
        lessonId: widget.lesson.id,
        notes: _offlineLecture(),
      );
      if (!mounted) return;
      StudyMessenger.showError(context, e);
    } finally {
      _streamBuffer?.dispose();
      _streamBuffer = null;
      if (mounted) setState(() { _streaming = false; _loading = false; _streamingIndex = null; });
    }
  }

  String _offlineLecture() {
    final LawLesson l = widget.lesson;
    final int idx = widget.course.lessons.indexWhere((LawLesson x) => x.id == l.id);
    final AiProfessorChapterNavigation nav = AiProfessorChapterNavigation.fromTitles(
      titles: widget.course.lessons.map((LawLesson x) => x.title).toList(),
      index: idx,
    );
    return AiProfessorOfflineChapter.law(
      courseTitle: widget.course.title,
      lessonTitle: l.title,
      hook: l.hook,
      question: l.question,
      doctrine: l.doctrine,
      elements: l.elements,
      nav: nav,
    );
  }

  AiProfessorChapterNavigation get _chapterNav {
    final int idx = widget.course.lessons.indexWhere((LawLesson x) => x.id == widget.lesson.id);
    return AiProfessorChapterNavigation.fromTitles(
      titles: widget.course.lessons.map((LawLesson x) => x.title).toList(),
      index: idx,
    );
  }

  void _openAdjacentLesson(LawLesson lesson) {
    unawaited(stopAiProfessorSpeech());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LawLectureScreen(course: widget.course, lesson: lesson),
      ),
    );
  }

  Future<void> _ask() async {
    final String q = _question.text.trim();
    if (q.isEmpty || _loading || _streaming) return;
    _question.clear();
    setState(() {
      _messages.add((isProfessor: false, text: q));
      _loading = true;
    });
    _scrollEnd();
    try {
      final String ctx = _messages.where((m) => m.isProfessor).map((m) => m.text).join('\n');
      final String reply = AppConfig.hasOpenAi
          ? await context.read<OpenAiService>().lawProfessorAnswer(
                courseTitle: widget.course.title,
                lessonTitle: widget.lesson.title,
                lectureContext: ctx,
                question: q,
              )
          : 'Good. Now map your answer onto these elements: ${widget.lesson.elements.join(', ')}. '
              'Which element is strongest on these facts, and which is weakest?';
      if (!mounted) return;
      setState(() {
        _messages.add((isProfessor: true, text: reply));
        _loading = false;
      });
      final String notes = _messages.where((m) => m.isProfessor).map((m) => m.text).join('\n\n');
      await LawLectureNotesService.instance.saveNotes(
        courseTitle: widget.course.title,
        lessonId: widget.lesson.id,
        notes: notes,
      );
      _scrollEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, e);
    }
  }

  Future<void> _openQuiz() async {
    final String notes = _messages.where((m) => m.isProfessor).map((m) => m.text).join('\n\n');
    if (notes.trim().length >= 40) {
      await LawLectureNotesService.instance.saveNotes(
        courseTitle: widget.course.title,
        lessonId: widget.lesson.id,
        notes: notes,
      );
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LawExamScreen(
          lesson: widget.lesson,
          courseTitle: widget.course.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AiProfessorChapterNavigation nav = _chapterNav;
    final int lessonIndex = widget.course.lessons.indexWhere((LawLesson x) => x.id == widget.lesson.id);
    final LawLesson? previous = lessonIndex > 0 ? widget.course.lessons[lessonIndex - 1] : null;
    final LawLesson? next = lessonIndex >= 0 && lessonIndex < widget.course.lessons.length - 1
        ? widget.course.lessons[lessonIndex + 1]
        : null;
    return Scaffold(
      backgroundColor: LawTheme.background,
      appBar: AppBar(
        backgroundColor: LawTheme.bench,
        foregroundColor: Colors.white,
        title: Text('AI Professor · ${widget.lesson.title}', style: const TextStyle(fontSize: 16)),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _loading || _streaming ? null : () => unawaited(_openQuiz()),
            icon: const Icon(Icons.quiz_outlined, size: 18),
            label: const Text('Quiz', style: TextStyle(fontWeight: FontWeight.w800)),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
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
            primaryColor: LawTheme.primary,
            surfaceColor: LawTheme.surface,
            textPrimaryColor: LawTheme.textPrimary,
            textSecondaryColor: LawTheme.textSecondary,
            onPlayPause: () => unawaited(toggleAiProfessorSpeech(topicTitle: widget.lesson.title)),
            onStop: () => unawaited(stopAiProfessorSpeech()),
            onSpeed: onAiProfessorSpeed,
            onRewind: rewindAiProfessorSpeech,
            onSkipAhead: skipAheadAiProfessorSpeech,
            onMode: onAiProfessorVoiceMode,
            studyActions: <VirtualUniversityStudyAction>[
              VirtualUniversityStudyAction(
                label: 'Topic quiz',
                icon: Icons.quiz_outlined,
                description: 'Test IRAC reasoning and lesson concepts',
                onTap: () => unawaited(_openQuiz()),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (BuildContext context, int i) {
                if (i >= _messages.length) {
                  return Text('Professor is thinking…', style: TextStyle(color: LawTheme.textSecondary));
                }
                final m = _messages[i];
                final bool isStreamingMessage = _streaming && m.isProfessor && i == _streamingIndex;
                return Align(
                  alignment: m.isProfessor ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: m.isProfessor ? double.infinity : MediaQuery.sizeOf(context).width * 0.88,
                    ),
                    decoration: BoxDecoration(
                      color: m.isProfessor ? LawTheme.surface : LawTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LawTheme.border),
                    ),
                    child: m.isProfessor
                        ? ProfessorMessageBody(
                            text: m.text,
                            isStreaming: isStreamingMessage,
                            textColor: LawTheme.textPrimary,
                          )
                        : Text(m.text, style: TextStyle(color: LawTheme.textPrimary, height: 1.4)),
                  ),
                );
              },
            ),
          ),
          AiProfessorChapterNavBar(
            chapterNumber: nav.chapterNumber,
            totalChapters: nav.totalChapters,
            previousTitle: nav.previousTitle,
            nextTitle: nav.nextTitle,
            onPrevious: previous != null ? () => _openAdjacentLesson(previous) : null,
            onNext: next != null ? () => _openAdjacentLesson(next) : null,
            primaryColor: LawTheme.primary,
            surfaceColor: LawTheme.surface,
            borderColor: LawTheme.border,
          ),
          Material(
            color: LawTheme.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _question,
                        decoration: const InputDecoration(hintText: 'Answer the professor / ask a question…', border: OutlineInputBorder()),
                        onSubmitted: (_) => unawaited(_ask()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _loading || _streaming ? null : () => unawaited(_ask()),
                      style: FilledButton.styleFrom(backgroundColor: LawTheme.primary, foregroundColor: Colors.white),
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
