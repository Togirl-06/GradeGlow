import 'package:flutter/material.dart';

import '../theme/study_theme.dart';

/// Studley-style Upload / Paste / Record input cards.
class StudyInputCards extends StatelessWidget {
  const StudyInputCards({
    super.key,
    required this.onUpload,
    required this.onPaste,
    required this.onRecord,
    this.enabled = true,
  });

  final VoidCallback? onUpload;
  final VoidCallback? onPaste;
  final VoidCallback? onRecord;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final _InputCard upload = _InputCard(
      icon: Icons.upload_rounded,
      title: 'Upload',
      subtitle: 'PDF, slides, media (multi)',
      onTap: enabled ? onUpload : null,
    );
    final _InputCard paste = _InputCard(
      icon: Icons.link_rounded,
      title: 'Paste',
      subtitle: 'YouTube, website, text',
      onTap: enabled ? onPaste : null,
    );
    final _InputCard record = _InputCard(
      icon: Icons.mic_rounded,
      title: 'Record',
      subtitle: 'Record live lecture',
      onTap: enabled ? onRecord : null,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              upload,
              const SizedBox(height: 10),
              paste,
              const SizedBox(height: 10),
              record,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: upload),
            const SizedBox(width: 10),
            Expanded(child: paste),
            const SizedBox(width: 10),
            Expanded(child: record),
          ],
        );
      },
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color bg = brightness == Brightness.dark ? const Color(0xFF1C1C1E) : StudyColors.surface(brightness);
    final Color border = StudyColors.border(brightness);
    final Color textSecondary = StudyColors.textSecondary(brightness);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 22, color: StudyColors.textPrimary(brightness)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: textSecondary, fontSize: 10, height: 1.25),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
