import 'dart:async';

import 'package:flutter/material.dart';

import '../services/lecture_voice_controller.dart';
import '../utils/textbook_speech.dart';
import '../widgets/ai_professor/ai_professor_voice_panel.dart';

/// Shared voice + learning-mode behavior for AI Professor screens.
mixin AiProfessorVoiceMixin<T extends StatefulWidget> on State<T> {
  final LectureVoiceController aiProfessorVoice = LectureVoiceController();
  bool aiProfessorSpeaking = false;
  bool aiProfessorVoiceReady = false;
  double aiProfessorSpeed = 1;
  AiProfessorVoiceMode aiProfessorVoiceMode = AiProfessorVoiceMode.professor;
  String? aiProfessorHighlight;
  List<String> _aiProfessorSentences = <String>[];
  int _aiProfessorResumeIndex = 0;
  String _aiProfessorChapter = '';
  String _aiProfessorTopicTitle = 'this topic';

  Future<void> initAiProfessorVoice() async {
    final bool ready = await aiProfessorVoice.ensureReady();
    if (mounted) setState(() => aiProfessorVoiceReady = ready);
  }

  void disposeAiProfessorVoice() {
    aiProfessorVoice.dispose();
  }

  void setAiProfessorChapter(String markdown) {
    _aiProfessorChapter = markdown;
    _aiProfessorResumeIndex = 0;
    _refreshAiProfessorSentences();
  }

  void onAiProfessorVoiceMode(AiProfessorVoiceMode mode) {
    if (mode != AiProfessorVoiceMode.readAloud) {
      unawaited(stopAiProfessorSpeech());
    }
    setState(() {
      aiProfessorVoiceMode = mode;
      if (mode == AiProfessorVoiceMode.readAloud) {
        _refreshAiProfessorSentences();
      }
    });
  }

  void onAiProfessorSpeed(double speed) {
    setState(() => aiProfessorSpeed = speed);
  }

  void rewindAiProfessorSpeech() {
    setState(() {
      _aiProfessorResumeIndex = (_aiProfessorResumeIndex - 2).clamp(0, _aiProfessorSentences.length);
      aiProfessorHighlight = _aiProfessorSentences.isNotEmpty ? _aiProfessorSentences[_aiProfessorResumeIndex] : null;
    });
    if (aiProfessorSpeaking) {
      unawaited(stopAiProfessorSpeech().then((_) {
        if (mounted) unawaited(toggleAiProfessorSpeech(topicTitle: _aiProfessorTopicTitle));
      }));
    }
  }

  void skipAheadAiProfessorSpeech() {
    setState(() {
      _aiProfessorResumeIndex = (_aiProfessorResumeIndex + 2).clamp(0, _aiProfessorSentences.length - 1);
      aiProfessorHighlight = _aiProfessorSentences.isNotEmpty ? _aiProfessorSentences[_aiProfessorResumeIndex] : null;
    });
    if (aiProfessorSpeaking) {
      unawaited(stopAiProfessorSpeech().then((_) {
        if (mounted) unawaited(toggleAiProfessorSpeech(topicTitle: _aiProfessorTopicTitle));
      }));
    }
  }

  void _refreshAiProfessorSentences() {
    _aiProfessorSentences = textbookSpeechSentences(_aiProfessorChapter);
  }

  Future<void> toggleAiProfessorSpeech({required String topicTitle}) async {
    _aiProfessorTopicTitle = topicTitle;
    if (aiProfessorVoiceMode != AiProfessorVoiceMode.readAloud) {
      onAiProfessorVoiceMode(AiProfessorVoiceMode.readAloud);
    }

    if (aiProfessorSpeaking) {
      await aiProfessorVoice.stop();
      if (mounted) setState(() => aiProfessorSpeaking = false);
      return;
    }

    if (_aiProfessorSentences.isEmpty && _aiProfessorChapter.isNotEmpty) {
      _refreshAiProfessorSentences();
    }
    if (_aiProfessorSentences.isEmpty) return;

    final bool ready = await aiProfessorVoice.ensureReady();
    if (!mounted) return;
    setState(() => aiProfessorVoiceReady = ready);
    if (!ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No text-to-speech engine was found. Install or enable a device TTS voice, then try again.',
          ),
        ),
      );
      return;
    }

    setState(() => aiProfessorSpeaking = true);
    final int startIndex = _aiProfessorResumeIndex.clamp(0, _aiProfessorSentences.length - 1);
    final bool spoke = await aiProfessorVoice.speakSequence(
      sentences: _aiProfessorSentences,
      speed: aiProfessorSpeed,
      startIndex: startIndex,
      onSentence: (int index, String sentence) {
        if (!mounted) return;
        setState(() {
          _aiProfessorResumeIndex = index;
          aiProfessorHighlight = sentence;
        });
      },
    );
    if (mounted) {
      setState(() {
        aiProfessorSpeaking = false;
        aiProfessorVoiceReady = spoke || aiProfessorVoice.isAvailable;
        if (!spoke) aiProfessorHighlight = null;
      });
      if (!spoke) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio could not start. Check the device text-to-speech settings.')),
        );
      }
    }
  }

  Future<void> stopAiProfessorSpeech() async {
    await aiProfessorVoice.stop();
    if (mounted) {
      setState(() {
        aiProfessorSpeaking = false;
        aiProfessorHighlight = null;
      });
    }
  }
}
