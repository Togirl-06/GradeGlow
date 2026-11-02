import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/virtual_lecture.dart';
import '../../services/openai_tts_service.dart';
import '../../theme/mathematics_degree_theme.dart';

const String _kLectureVoicePref = 'lecture_openai_voice_v1';

Future<String> loadLectureVoicePreference() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? id = prefs.getString(_kLectureVoicePref);
    if (id != null && OpenAiTtsVoices.isValid(id)) return id;
  } catch (_) {}
  return OpenAiTtsVoices.defaultId;
}

Future<void> saveLectureVoicePreference(String voiceId) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLectureVoicePref, voiceId);
  } catch (_) {}
}

void showLectureSettingsSheet(
  BuildContext context, {
  required VoidCallback onSpeed,
  VoidCallback? onNotes,
  VoidCallback? onVoice,
  String speedLabel = '1x',
  String voiceLabel = 'Nova',
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: const Color(0xFF111827),
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                title: Text(
                  'Lecture settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.speed_rounded, color: Colors.white70),
                title: const Text(
                  'Playback speed',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  speedLabel,
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onSpeed();
                },
              ),
              if (onVoice != null)
                ListTile(
                  leading:
                      const Icon(Icons.record_voice_over_rounded, color: Colors.white70),
                  title: const Text(
                    'Professor voice',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    voiceLabel,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onVoice();
                  },
                ),
              if (onNotes != null)
                ListTile(
                  leading: const Icon(Icons.notes_rounded, color: Colors.white70),
                  title: const Text(
                    'Slide notes',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onNotes();
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

void showLectureVoiceSheet(
  BuildContext context, {
  required String currentVoiceId,
  required ValueChanged<String> onSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: const Color(0xFF111827),
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(
              title: Text(
                'Choose a voice',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(
                'Applies on the next section (or restart this one).',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            ...OpenAiTtsVoices.all.map((v) {
              final bool selected = v.id == currentVoiceId;
              return ListTile(
                title: Text(
                  v.label,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  v.blurb,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: selected
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : null,
                onTap: () {
                  onSelected(v.id);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

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
  LectureSlideNotes? slideNotes,
  String? slideTitle,
  VoidCallback? onSaveNotes,
  VoidCallback? onGenerateQuiz,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext ctx) {
      final double height = MediaQuery.sizeOf(ctx).height * 0.82;
      return SizedBox(
        height: height,
        child: LectureNotesSheet(
          notes: notes,
          transcript: transcript,
          slideNotes: slideNotes,
          slideTitle: slideTitle,
          onSaveNotes: onSaveNotes,
          onGenerateQuiz: onGenerateQuiz,
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
    this.slideNotes,
    this.slideTitle,
    this.onSaveNotes,
    this.onGenerateQuiz,
  });

  final LectureSmartNotes notes;
  final List<String> transcript;
  final LectureSlideNotes? slideNotes;
  final String? slideTitle;
  final VoidCallback? onSaveNotes;
  final VoidCallback? onGenerateQuiz;

  List<Widget> _section(BuildContext context, String title, List<String> items) {
    if (items.isEmpty) return const <Widget>[];
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);
    return <Widget>[
      const SizedBox(height: 14),
      Text(
        title,
        style: TextStyle(color: c.primary, fontWeight: FontWeight.w800, fontSize: 13),
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

  Widget _block(BuildContext context, String title, String body) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(color: c.primary, fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(color: c.textSecondary, height: 1.45)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MathematicsDegreeColors c = MathematicsDegreeTheme.of(context);
    final LectureSlideNotes? slide = slideNotes;
    final bool hasSlide = slide != null && !slide.isEmpty;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: <Widget>[
          Text(
            'SLIDE NOTES',
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          if (slideTitle != null && slideTitle!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              slideTitle!,
              style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
          if (hasSlide) ...<Widget>[
            _block(context, 'What you should understand', slide.understand),
            ..._section(context, 'KEY CONCEPTS', slide.keyConcepts),
            _block(context, 'PROFESSOR INSIGHT', slide.professorInsight),
            _block(context, 'Remember', slide.remember),
            _block(context, 'EXAM TIP', slide.examTip),
            _block(context, 'Study notes', slide.studyNotes),
            ..._section(context, 'Questions', slide.questions),
            ..._section(context, 'Vocabulary', slide.vocabulary),
          ] else ...<Widget>[
            ..._section(context, 'Definitions', notes.definitions),
            ..._section(context, 'Formulas', notes.formulas),
            ..._section(context, 'Examples', notes.examples),
            ..._section(context, 'Common Mistakes', notes.commonMistakes),
            ..._section(context, 'Tips', notes.tips),
          ],
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onSaveNotes?.call();
                  },
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('Save Notes'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onGenerateQuiz?.call();
                  },
                  icon: const Icon(Icons.quiz_outlined, size: 18),
                  label: const Text('Generate Quiz'),
                ),
              ),
            ],
          ),
          if (!hasSlide && transcript.isNotEmpty) ...<Widget>[
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
