import 'package:flutter/material.dart';

import '../../theme/leetcode_theme.dart';
import '../../theme/study_theme.dart';

/// Opens a bottom sheet listing hints the student has already used this session.
void showUsedHintsSheet(
  BuildContext context, {
  required List<String> hints,
  bool leetcode = false,
}) {
  if (hints.isEmpty) return;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: leetcode ? LeetCodeTheme.surface : StudyColors.surface(Theme.of(context).brightness),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      final Color textSecondary = leetcode
          ? LeetCodeTheme.textSecondary
          : StudyColors.textSecondary(Theme.of(context).brightness);
      final Color accent = leetcode ? LeetCodeTheme.accent : StudyColors.primary;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.lightbulb_rounded, color: accent, size: 22),
                  const SizedBox(width: 8),
                  Text('Your hints', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: accent)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Review coaching hints from this session.',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: hints.length,
                  separatorBuilder: (_, int index) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    return _HintCard(
                      index: index + 1,
                      text: hints[index],
                      accent: accent,
                      leetcode: leetcode,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _HintCard extends StatelessWidget {
  const _HintCard({
    required this.index,
    required this.text,
    required this.accent,
    required this.leetcode,
  });

  final int index;
  final String text;
  final Color accent;
  final bool leetcode;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: leetcode
            ? LeetCodeTheme.surfaceElevated
            : accent.withValues(alpha: brightness == Brightness.dark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: leetcode ? LeetCodeTheme.border : accent.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Hint $index', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: accent)),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              height: 1.45,
              fontSize: 14,
              color: leetcode ? LeetCodeTheme.textPrimary : null,
            ),
          ),
        ],
      ),
    );
  }
}
