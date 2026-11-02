import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/chat_message.dart';
import '../theme/study_theme.dart';
import '../utils/voice_duration_format.dart';
import 'local_or_network_image.dart';
import 'tutor_markdown_body.dart';

/// ChatGPT-style user message (dark pill + timestamp & actions).
class TutorUserBubble extends StatelessWidget {
  const TutorUserBubble({
    super.key,
    required this.message,
    this.onEdit,
    this.branchCount = 0,
    this.activeBranch = 0,
    this.onPrevBranch,
    this.onNextBranch,
  });

  final ChatMessage message;
  final VoidCallback? onEdit;
  final int branchCount;
  final int activeBranch;
  final VoidCallback? onPrevBranch;
  final VoidCallback? onNextBranch;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color bubbleColor = brightness == Brightness.dark
        ? const Color(0xFF2F2F2F)
        : StudyColors.surfaceElevated(brightness);
    final Color textColor = StudyColors.textPrimary(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (message.hasMedia &&
                  message.mediaType == ChatMediaType.image &&
                  message.mediaPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LocalOrNetworkImage(
                    path: message.mediaPath!,
                    height: 140,
                    width: double.infinity,
                  ),
                ),
              if (message.hasMedia && message.mediaType == ChatMediaType.video)
                Row(
                  children: <Widget>[
                    Icon(Icons.videocam_rounded, size: 20, color: textColor.withValues(alpha: 0.75)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Video attached',
                        style: TextStyle(color: textColor.withValues(alpha: 0.9)),
                      ),
                    ),
                  ],
                ),
              if (message.text.isNotEmpty) ...<Widget>[
                if (message.hasMedia) const SizedBox(height: 8),
                Text(message.text, style: TextStyle(color: textColor, height: 1.45, fontSize: 15)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        _UserMessageActions(
          message: message,
          onEdit: message.hasMedia ? null : onEdit,
          branchCount: branchCount,
          activeBranch: activeBranch,
          onPrevBranch: onPrevBranch,
          onNextBranch: onNextBranch,
        ),
      ],
    );
  }
}

/// ChatGPT-style user voice transcript + duration footer.
class TutorVoiceUserBubble extends StatelessWidget {
  const TutorVoiceUserBubble({
    super.key,
    required this.message,
    this.onEdit,
    this.branchCount = 0,
    this.activeBranch = 0,
    this.onPrevBranch,
    this.onNextBranch,
  });

  final ChatMessage message;
  final VoidCallback? onEdit;
  final int branchCount;
  final int activeBranch;
  final VoidCallback? onPrevBranch;
  final VoidCallback? onNextBranch;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color bubbleColor = brightness == Brightness.dark
        ? const Color(0xFF2F2F2F)
        : StudyColors.surfaceElevated(brightness);
    final Color textColor = StudyColors.textPrimary(brightness);
    final Color metaColor = StudyColors.textSecondary(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (message.hasMedia &&
                  message.mediaType == ChatMediaType.image &&
                  message.mediaPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LocalOrNetworkImage(
                    path: message.mediaPath!,
                    height: 140,
                    width: double.infinity,
                  ),
                ),
              if (message.text.isNotEmpty)
                Text(message.text, style: TextStyle(color: textColor, height: 1.45, fontSize: 15)),
            ],
          ),
        ),
        if (message.isVoice && message.voiceDurationSeconds != null) ...<Widget>[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.mic_none_rounded, size: 14, color: metaColor),
              const SizedBox(width: 4),
              Text(
                formatVoiceDuration(message.voiceDurationSeconds!),
                style: TextStyle(color: metaColor, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
        _UserMessageActions(
          message: message,
          onEdit: message.hasMedia ? null : onEdit,
          branchCount: branchCount,
          activeBranch: activeBranch,
          onPrevBranch: onPrevBranch,
          onNextBranch: onNextBranch,
        ),
      ],
    );
  }
}

class _UserMessageActions extends StatelessWidget {
  const _UserMessageActions({
    required this.message,
    this.onEdit,
    this.branchCount = 0,
    this.activeBranch = 0,
    this.onPrevBranch,
    this.onNextBranch,
  });

  final ChatMessage message;
  final VoidCallback? onEdit;
  final int branchCount;
  final int activeBranch;
  final VoidCallback? onPrevBranch;
  final VoidCallback? onNextBranch;

  @override
  Widget build(BuildContext context) {
    final Color muted = StudyColors.textSecondary(Theme.of(context).brightness);
    final String time = DateFormat.jm().format(message.createdAt);
    final bool showBranches = branchCount > 1;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showBranches) ...<Widget>[
            _ActionIcon(
              icon: Icons.chevron_left_rounded,
              tooltip: 'Previous branch',
              color: muted,
              onPressed: activeBranch > 0 ? onPrevBranch : null,
            ),
            Text(
              '${activeBranch + 1}/$branchCount',
              style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            _ActionIcon(
              icon: Icons.chevron_right_rounded,
              tooltip: 'Next branch',
              color: muted,
              onPressed: activeBranch < branchCount - 1 ? onNextBranch : null,
            ),
            const SizedBox(width: 4),
          ],
          Text(time, style: TextStyle(color: muted, fontSize: 11)),
          const SizedBox(width: 2),
          if (onEdit != null)
            _ActionIcon(
              icon: Icons.edit_outlined,
              tooltip: 'Edit message',
              color: muted,
              onPressed: onEdit,
            ),
          _ActionIcon(
            icon: Icons.copy_outlined,
            tooltip: 'Copy',
            color: muted,
            onPressed: message.text.isEmpty
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: message.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied')),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

/// ChatGPT-style assistant reply with markdown code blocks and actions.
class TutorAssistantBubble extends StatelessWidget {
  const TutorAssistantBubble({
    super.key,
    required this.message,
    this.onSpeak,
    this.isSpeaking = false,
    this.onRegenerate,
  });

  final ChatMessage message;
  final VoidCallback? onSpeak;
  final bool isSpeaking;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color muted = StudyColors.textSecondary(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.94),
          child: TutorMarkdownBody(text: message.text),
        ),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            _ActionIcon(
              icon: Icons.copy_outlined,
              tooltip: 'Copy',
              color: muted,
              onPressed: message.text.isEmpty
                  ? null
                  : () {
                      Clipboard.setData(ClipboardData(text: message.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied')),
                      );
                    },
            ),
            _ActionIcon(
              icon: Icons.thumb_up_outlined,
              tooltip: 'Good response',
              color: muted,
              onPressed: () => _showFeedback(context, positive: true),
            ),
            _ActionIcon(
              icon: Icons.thumb_down_outlined,
              tooltip: 'Bad response',
              color: muted,
              onPressed: () => _showFeedback(context, positive: false),
            ),
            if (onRegenerate != null)
              _ActionIcon(
                icon: Icons.refresh_rounded,
                tooltip: 'Regenerate',
                color: muted,
                onPressed: onRegenerate,
              ),
            if (onSpeak != null)
              _ActionIcon(
                icon: isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                tooltip: isSpeaking ? 'Speaking…' : 'Listen',
                color: muted,
                onPressed: isSpeaking ? null : onSpeak,
              ),
          ],
        ),
      ],
    );
  }

  void _showFeedback(BuildContext context, {required bool positive}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(positive ? 'Thanks for the feedback' : 'Thanks — we\'ll improve'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: onPressed == null ? color.withValues(alpha: 0.35) : color),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

/// Live transcript while the mic is open (ChatGPT-style).
class TutorListeningChip extends StatelessWidget {
  const TutorListeningChip({
    super.key,
    required this.partialText,
    required this.elapsedSeconds,
  });

  final String partialText;
  final int elapsedSeconds;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color bubbleColor = brightness == Brightness.dark
        ? const Color(0xFF2F2F2F)
        : StudyColors.surfaceElevated(brightness);

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: StudyColors.primary.withValues(alpha: 0.35)),
            ),
            child: Text(
              partialText.isEmpty ? 'Listening…' : partialText,
              style: TextStyle(
                color: StudyColors.textPrimary(brightness),
                height: 1.45,
                fontStyle: partialText.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.mic_rounded, size: 14, color: StudyColors.danger),
              const SizedBox(width: 4),
              Text(
                formatVoiceDuration(elapsedSeconds),
                style: TextStyle(
                  color: StudyColors.textSecondary(brightness),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
