import 'package:flutter/material.dart';

import '../theme/study_theme.dart';
import 'voice_note_recorder_bar.dart';

/// ChatGPT-style tutor input: + · Ask anything · send.
class TutorComposer extends StatefulWidget {
  const TutorComposer({
    super.key,
    required this.controller,
    required this.isSending,
    required this.isListening,
    required this.isVoiceNoteRecording,
    required this.isTranscribing,
    required this.mediaLimitReached,
    required this.liveTranscript,
    required this.voiceNoteLevel,
    required this.voiceModeActive,
    required this.isSpeaking,
    this.liveVoicePremiumLocked = false,
    required this.onSend,
    required this.onAddPhotosAndFiles,
    required this.onUploads,
    required this.onStartVoiceNote,
    required this.onCancelVoiceNote,
    required this.onConfirmVoiceNote,
    required this.onToggleVoiceMode,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isListening;
  final bool isVoiceNoteRecording;
  final bool isTranscribing;
  final bool mediaLimitReached;
  final String liveTranscript;
  final double voiceNoteLevel;
  final bool voiceModeActive;
  final bool isSpeaking;
  final bool liveVoicePremiumLocked;
  final VoidCallback onSend;
  final VoidCallback onAddPhotosAndFiles;
  final VoidCallback onUploads;
  final VoidCallback onStartVoiceNote;
  final VoidCallback onCancelVoiceNote;
  final VoidCallback onConfirmVoiceNote;
  final VoidCallback onToggleVoiceMode;

  @override
  State<TutorComposer> createState() => _TutorComposerState();
}

class _TutorComposerState extends State<TutorComposer> {
  final GlobalKey _plusKey = GlobalKey();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final bool next = widget.controller.text.trim().isNotEmpty;
    if (next != _hasText) setState(() => _hasText = next);
  }

  Future<void> _openAttachMenu() async {
    final RenderBox? box = _plusKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset topLeft = box.localToGlobal(Offset.zero);
    const double menuHeight = 112;
    final RelativeRect position = RelativeRect.fromLTRB(
      12,
      topLeft.dy - menuHeight,
      MediaQuery.sizeOf(context).width - 12,
      topLeft.dy,
    );

    final String? choice = await showMenu<String>(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: StudyColors.surface(Theme.of(context).brightness),
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'media',
          child: _MenuRow(icon: Icons.attach_file_rounded, label: 'Add photos & files'),
        ),
        const PopupMenuItem<String>(
          value: 'uploads',
          child: _MenuRow(
            icon: Icons.folder_outlined,
            label: 'Uploads',
            showChevron: true,
          ),
        ),
      ],
    );

    if (!mounted || choice == null) return;
    switch (choice) {
      case 'media':
        widget.onAddPhotosAndFiles();
        break;
      case 'uploads':
        widget.onUploads();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVoiceNoteRecording || widget.isTranscribing) {
      return VoiceNoteRecorderBar(
        liveTranscript: widget.liveTranscript,
        level: widget.voiceNoteLevel,
        isTranscribing: widget.isTranscribing,
        onAdd: widget.isSending ? () {} : widget.onAddPhotosAndFiles,
        onCancel: widget.onCancelVoiceNote,
        onConfirm: widget.onConfirmVoiceNote,
      );
    }

    final Brightness brightness = Theme.of(context).brightness;
    final Color border = StudyColors.border(brightness);
    final Color fill = brightness == Brightness.dark
        ? const Color(0xFF2F2F2F)
        : StudyColors.surfaceElevated(brightness);
    final Color hintColor = StudyColors.textSecondary(brightness);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Material(
            key: _plusKey,
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isSending || widget.mediaLimitReached ? null : _openAttachMenu,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.add_rounded, size: 26, color: hintColor),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              enabled: !widget.isSending,
              minLines: 1,
              maxLines: 5,
              style: TextStyle(color: StudyColors.textPrimary(brightness)),
              decoration: InputDecoration(
                hintText: 'Ask anything',
                hintStyle: TextStyle(color: hintColor),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                isDense: true,
              ),
              onSubmitted: widget.isSending ? null : (_) => widget.onSend(),
            ),
          ),
          IconButton(
            tooltip: widget.isVoiceNoteRecording
                ? 'Recording voice note'
                : 'Record voice note (edit before send)',
            onPressed: widget.isSending || widget.voiceModeActive ? null : widget.onStartVoiceNote,
            icon: Icon(
              Icons.mic_rounded,
              color: widget.isVoiceNoteRecording || widget.isListening
                  ? StudyColors.danger
                  : hintColor,
            ),
          ),
          IconButton(
            tooltip: widget.liveVoicePremiumLocked && !widget.voiceModeActive
                ? 'Live voice conversation — Premium only'
                : widget.voiceModeActive
                    ? 'End live voice conversation'
                    : 'Start live voice conversation',
            onPressed: widget.isSending ? null : widget.onToggleVoiceMode,
            icon: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Icon(
                  Icons.graphic_eq_rounded,
                  color: widget.liveVoicePremiumLocked && !widget.voiceModeActive
                      ? hintColor.withValues(alpha: 0.45)
                      : widget.voiceModeActive || widget.isSpeaking
                          ? StudyColors.primary
                          : hintColor,
                ),
                if (widget.liveVoicePremiumLocked && !widget.voiceModeActive)
                  const Positioned(
                    right: -4,
                    top: -4,
                    child: Icon(Icons.workspace_premium, color: StudyColors.accent, size: 14),
                  ),
              ],
            ),
          ),
          if (_hasText)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 6),
              child: Material(
                color: StudyColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: widget.isSending ? null : widget.onSend,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 22, color: StudyColors.textSecondary(Theme.of(context).brightness)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          if (showChevron)
            Icon(Icons.chevron_right, size: 20, color: StudyColors.textSecondary(Theme.of(context).brightness)),
        ],
      ),
    );
  }
}

/// Small sheet after "Add photos & files".
class TutorMediaPickerSheet extends StatelessWidget {
  const TutorMediaPickerSheet({
    super.key,
    required this.onPhoto,
    required this.onVideo,
  });

  final VoidCallback onPhoto;
  final VoidCallback onVideo;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onPhoto,
    required VoidCallback onVideo,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => TutorMediaPickerSheet(onPhoto: onPhoto, onVideo: onVideo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_outlined, color: StudyColors.primary),
              title: const Text('Photo from gallery'),
              onTap: () {
                Navigator.pop(context);
                onPhoto();
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam_outlined, color: StudyColors.primary),
              title: const Text('Video from gallery'),
              onTap: () {
                Navigator.pop(context);
                onVideo();
              },
            ),
          ],
        ),
      ),
    );
  }
}
