import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/binned_recording.dart';
import '../services/recording_bin_service.dart';
import '../theme/study_theme.dart';
import '../utils/recording_limits.dart';
import '../utils/study_messenger.dart';

class RecordingBinSheet extends StatelessWidget {
  const RecordingBinSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: StudyColors.surface(Theme.of(context).brightness),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => const RecordingBinSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RecordingBinService bin = context.watch<RecordingBinService>();
    final Brightness brightness = Theme.of(context).brightness;
    final Color textSecondary = StudyColors.textSecondary(brightness);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                const Icon(Icons.delete_outline_rounded),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Recording bin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                if (bin.items.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      final bool? confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Empty bin?'),
                          content: const Text('Permanently delete all recordings in the bin.'),
                          actions: <Widget>[
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(backgroundColor: StudyColors.danger),
                              child: const Text('Empty bin'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await bin.emptyBin();
                        if (!context.mounted) return;
                        StudyMessenger.showInfo(context, 'Recording bin emptied');
                      }
                    },
                    child: const Text('Empty'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Deleted recordings stay here for ${RecordingBinService.retention.inDays} days.',
              style: TextStyle(color: textSecondary, height: 1.35),
            ),
            const SizedBox(height: 16),
            if (bin.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Text(
                  'No deleted recordings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSecondary),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: bin.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final BinnedRecording item = bin.items[index];
                    return _BinTile(item: item);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BinTile extends StatelessWidget {
  const _BinTile({required this.item});

  final BinnedRecording item;

  @override
  Widget build(BuildContext context) {
    final RecordingBinService bin = context.read<RecordingBinService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final String title = item.label?.trim().isNotEmpty == true
        ? item.label!.trim()
        : item.fileName.replaceFirst('${item.id}_', '');

    return Material(
      color: StudyColors.surfaceElevated(Theme.of(context).brightness),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    '${formatRecordingDuration(Duration(seconds: item.durationSeconds))} · ${_whenLabel(item.deletedAt)}',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Restore',
              onPressed: () async {
                final String? restored = await bin.restore(item);
                if (!context.mounted) return;
                StudyMessenger.showSuccess(
                  context,
                  restored == null ? 'Recording restored to bin list' : 'Recording restored',
                );
              },
              icon: const Icon(Icons.restore_rounded),
            ),
            IconButton(
              tooltip: 'Delete forever',
              onPressed: () async {
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Delete forever?'),
                    content: Text('Permanently remove "$title"?'),
                    actions: <Widget>[
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(backgroundColor: StudyColors.danger),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await bin.deletePermanently(item);
                  if (!context.mounted) return;
                  StudyMessenger.showInfo(context, 'Recording deleted permanently');
                }
              },
              icon: Icon(Icons.delete_forever_outlined, color: StudyColors.danger.withValues(alpha: 0.9)),
            ),
          ],
        ),
      ),
    );
  }

  String _whenLabel(DateTime deletedAt) {
    final Duration ago = DateTime.now().difference(deletedAt);
    if (ago.inMinutes < 1) return 'just now';
    if (ago.inHours < 1) return '${ago.inMinutes}m ago';
    if (ago.inDays < 1) return '${ago.inHours}h ago';
    return '${ago.inDays}d ago';
  }
}
