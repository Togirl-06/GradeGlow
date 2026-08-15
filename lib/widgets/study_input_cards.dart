import 'package:flutter/material.dart';

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
      subtitle: 'Image, file, audio, video',
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: upload),
        const SizedBox(width: 8),
        Expanded(child: paste),
        const SizedBox(width: 8),
        Expanded(child: record),
      ],
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
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 132,
          padding: const EdgeInsets.fromLTRB(13, 14, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 25, color: scheme.primary),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 8.5,
                  height: 1.3,
                ),
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
