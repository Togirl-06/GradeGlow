import 'package:flutter/material.dart';

/// Previous / next chapter controls for sequential AI Professor reading.
class AiProfessorChapterNavBar extends StatelessWidget {
  const AiProfessorChapterNavBar({
    super.key,
    required this.chapterNumber,
    required this.totalChapters,
    this.previousTitle,
    this.nextTitle,
    this.onPrevious,
    this.onNext,
    this.primaryColor,
    this.surfaceColor,
    this.borderColor,
  });

  final int chapterNumber;
  final int totalChapters;
  final String? previousTitle;
  final String? nextTitle;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final Color? primaryColor;
  final Color? surfaceColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final Color primary = primaryColor ?? Theme.of(context).colorScheme.primary;
    final Color surface = surfaceColor ?? Theme.of(context).colorScheme.surface;
    final Color border = borderColor ?? Theme.of(context).dividerColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: primary.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Chapter $chapterNumber of $totalChapters · Read in order',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: primary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPrevious,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text(
                      previousTitle ?? 'First chapter',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: onPrevious != null ? primary : null,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      nextTitle ?? 'Last chapter',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
