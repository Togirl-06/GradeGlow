import 'package:flutter/material.dart';

import '../../models/virtual_lecture.dart';
import '../../theme/mathematics_degree_theme.dart';

void showLectureSpeedSheet(
  BuildContext context, {
  required List<double> speeds,
  required double current,
  required ValueChanged<double> onSelected,
}) {
  String labelFor(double speed) {
    final double rounded = (speed * 100).round() / 100;
    if (rounded == rounded.roundToDouble()) {
      return '${rounded.toInt()}x';
    }
    return '${rounded}x';
  }

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds.map((double speed) {
            return ListTile(
              title: Text(labelFor(speed)),
              trailing: (current - speed).abs() < 0.01
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () {
                onSelected(speed);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      );
    },
  );
}

void showLectureNotesSheet(
  BuildContext context, {
  required LectureSmartNotes notes,
  required List<String> transcript,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext ctx) {
      final double height = MediaQuery.sizeOf(ctx).height * 0.72;
      return SizedBox(
        height: height,
        child: LectureNotesSheet(
          notes: notes,
          transcript: transcript,
        ),
      );
    },
  );
}

class LectureNotesSheet extends StatelessWidget {
  const LectureNotesSheet({
    super.key,
    required this.notes,
    required this.transcript,
  });

  final LectureSmartNotes notes;
  final List<String> transcript;

  List<Widget> _section(BuildContext context, String title, List<String> items) {
    if (items.isEmpty) return const <Widget>[];
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);
    return <Widget>[
      const SizedBox(height: 14),
      Text(
        title,
        style: TextStyle(color: c.primary, fontWeight: FontWeight.w800, fontSize: 14),
      ),
      const SizedBox(height: 6),
      ...items.map(
        (String item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text('• $item', style: TextStyle(color: c.textSecondary, height: 1.4)),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: <Widget>[
          Text(
            'Smart Notes',
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          ..._section(context, 'Definitions', notes.definitions),
          ..._section(context, 'Formulas', notes.formulas),
          ..._section(context, 'Examples', notes.examples),
          ..._section(context, 'Common Mistakes', notes.commonMistakes),
          ..._section(context, 'Tips', notes.tips),
          if (transcript.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              'Transcript',
              style: TextStyle(
                color: c.primary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...transcript.map(
              (String line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  line,
                  style: TextStyle(color: c.textSecondary, fontSize: 12, height: 1.4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
