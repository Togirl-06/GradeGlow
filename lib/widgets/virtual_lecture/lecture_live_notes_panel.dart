import 'package:flutter/material.dart';

import '../../models/virtual_lecture.dart';
import '../../theme/study_theme.dart';

/// Always-visible slide notes on the lecture screen (not just a buried button).
class LectureLiveNotesPanel extends StatelessWidget {
  const LectureLiveNotesPanel({
    super.key,
    required this.slideTitle,
    required this.notes,
    required this.expanded,
    required this.onToggle,
    required this.onOpenFull,
  });

  final String slideTitle;
  final LectureSlideNotes notes;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onOpenFull;

  @override
  Widget build(BuildContext context) {
    final Color accent = StudyColors.primary;
    final List<String> concepts = notes.keyConcepts.take(6).toList();

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onToggle,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.notes_rounded, color: accent, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Slide Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onOpenFull,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Full notes',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
              if (slideTitle.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  slideTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
              if (!expanded) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  notes.understand.trim().isNotEmpty
                      ? notes.understand.trim()
                      : (concepts.isNotEmpty
                          ? concepts.take(2).join(' · ')
                          : 'Tap to open study notes for this slide.'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ] else ...<Widget>[
                if (notes.understand.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  const Text(
                    'What you should understand',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notes.understand.trim(),
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
                if (concepts.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  const Text(
                    'Key concepts',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: concepts
                        .map(
                          (String c) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (notes.professorInsight.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  const Text(
                    'Professor insight',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${notes.professorInsight.trim()}"',
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (notes.examTip.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDBA74)),
                    ),
                    child: Text(
                      'Exam tip: ${notes.examTip.trim()}',
                      style: const TextStyle(
                        color: Color(0xFF9A3412),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onOpenFull,
                    icon: const Icon(Icons.open_in_full_rounded, size: 16),
                    label: const Text('Open full slide notes'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
