import 'package:flutter/material.dart';

import '../theme/study_theme.dart';

/// ChatGPT-style inline editor shown in place of a user message.
class TutorMessageEditCard extends StatefulWidget {
  const TutorMessageEditCard({
    super.key,
    required this.controller,
    required this.onCancel,
    required this.onSave,
    this.isSaving = false,
  });

  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isSaving;

  @override
  State<TutorMessageEditCard> createState() => _TutorMessageEditCardState();
}

class _TutorMessageEditCardState extends State<TutorMessageEditCard> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool dark = brightness == Brightness.dark;
    final Color shell = dark ? const Color(0xFF2F2F2F) : StudyColors.surfaceElevated(brightness);
    final Color fieldFill = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final Color muted = StudyColors.textSecondary(brightness);

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.92),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: shell,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: !widget.isSaving,
            minLines: 2,
            maxLines: 8,
            style: TextStyle(
              color: StudyColors.textPrimary(brightness),
              fontSize: 15,
              height: 1.45,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: fieldFill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: StudyColors.border(brightness)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: StudyColors.border(brightness)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: StudyColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.info_outline_rounded, size: 16, color: muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Editing this message will create a new conversation branch.',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: widget.isSaving ? null : widget.onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: StudyColors.textPrimary(brightness),
                  backgroundColor: dark ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: widget.isSaving || widget.controller.text.trim().isEmpty ? null : widget.onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: dark ? const Color(0xFFE5E7EB) : const Color(0xFF111827),
                  foregroundColor: dark ? const Color(0xFF111827) : Colors.white,
                  disabledBackgroundColor: muted.withValues(alpha: 0.25),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: widget.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
