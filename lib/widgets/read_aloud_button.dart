import 'package:flutter/material.dart';

import '../services/tutor_voice_service.dart';
import '../theme/study_theme.dart';

/// Reads [textBuilder]'s text aloud (OpenAI TTS with device-voice fallback).
///
/// Renders as either an [AppBar] icon ([compact] = true, the default) or a
/// full-width pill button. Owns its own [TutorVoiceService] for speech output
/// only — it never requests microphone permission.
class ReadAloudButton extends StatefulWidget {
  const ReadAloudButton({
    super.key,
    required this.textBuilder,
    this.compact = true,
    this.label = 'Listen',
    this.playingLabel = 'Stop',
  });

  /// Resolved lazily on tap so the latest content is read.
  final String Function() textBuilder;
  final bool compact;
  final String label;
  final String playingLabel;

  @override
  State<ReadAloudButton> createState() => _ReadAloudButtonState();
}

class _ReadAloudButtonState extends State<ReadAloudButton> {
  final TutorVoiceService _voice = TutorVoiceService();
  bool _ready = false;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final bool ok = await _voice.initializeForSpeechOutput();
    if (mounted) setState(() => _ready = ok);
  }

  @override
  void dispose() {
    _voice.stopSpeaking();
    _voice.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_speaking) {
      await _voice.stopSpeaking();
      if (mounted) setState(() => _speaking = false);
      return;
    }

    final String text = widget.textBuilder().trim();
    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nothing to read aloud yet.')),
        );
      }
      return;
    }

    setState(() => _speaking = true);
    final bool spoke = await _voice.speak(text);
    if (!mounted) return;
    setState(() => _speaking = false);
    if (!spoke) {
      final String detail = _voice.lastSpeakError ?? 'No available voice on this device.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read aloud: $detail')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon = _speaking ? Icons.stop_rounded : Icons.volume_up_rounded;

    if (widget.compact) {
      return IconButton(
        tooltip: _ready ? (_speaking ? widget.playingLabel : widget.label) : 'Voice unavailable',
        icon: _speaking
            ? Icon(icon, color: StudyColors.primary)
            : Icon(icon),
        onPressed: _ready ? _toggle : null,
      );
    }

    return OutlinedButton.icon(
      onPressed: _ready ? _toggle : null,
      icon: Icon(icon),
      label: Text(_speaking ? widget.playingLabel : widget.label),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
    );
  }
}
