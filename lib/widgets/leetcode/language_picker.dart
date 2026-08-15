import 'package:flutter/material.dart';

import '../../data/coding_languages.dart';
import '../../theme/leetcode_theme.dart';

/// LeetCode-style language selector button + two-column picker popup.
class LeetcodeLanguagePickerButton extends StatelessWidget {
  const LeetcodeLanguagePickerButton({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CodingLanguage selected;
  final ValueChanged<CodingLanguage> onSelected;

  Future<void> _openPicker(BuildContext context) async {
    final CodingLanguage? picked = await showDialog<CodingLanguage>(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) => _LanguagePickerDialog(selected: selected),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPicker(context),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              selected.label,
              style: const TextStyle(
                color: LeetCodeTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, color: LeetCodeTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _LanguagePickerDialog extends StatelessWidget {
  const _LanguagePickerDialog({required this.selected});

  final CodingLanguage selected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: LeetCodeTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LeetCodeTheme.border),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: _LanguageColumn(languages: CodingLanguage.leftColumn, selected: selected)),
                const VerticalDivider(width: 1, color: LeetCodeTheme.border),
                Expanded(child: _LanguageColumn(languages: CodingLanguage.rightColumn, selected: selected)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageColumn extends StatelessWidget {
  const _LanguageColumn({required this.languages, required this.selected});

  final List<CodingLanguage> languages;
  final CodingLanguage selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: languages
          .map(
            (CodingLanguage lang) => _LanguageTile(
              language: lang,
              isSelected: lang.id == selected.id,
              onTap: () => Navigator.pop(context, lang),
            ),
          )
          .toList(),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final CodingLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: LeetCodeTheme.border.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 18,
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: LeetCodeTheme.textPrimary)
                    : null,
              ),
              Expanded(
                child: Text(
                  language.label,
                  style: TextStyle(
                    color: LeetCodeTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
