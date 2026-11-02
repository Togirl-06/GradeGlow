import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/law/law_topic_practice_bank.dart';
import '../../models/law/law_program.dart';
import '../../services/openai_service.dart';
import '../../theme/law_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/tutor_markdown_body.dart';

class LawWritingScreen extends StatefulWidget {
  const LawWritingScreen({super.key, required this.lesson});
  final LawLesson lesson;

  @override
  State<LawWritingScreen> createState() => _LawWritingScreenState();
}

class _LawWritingScreenState extends State<LawWritingScreen> {
  late final List<LawWritingItem> _items;
  final TextEditingController _draft = TextEditingController();
  int _index = 0;
  String? _feedback;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _items = LawTopicPracticeBank.writingsFor(widget.lesson);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  LawWritingItem get _current => _items[_index];

  void _nextPrompt() {
    setState(() {
      _index = (_index + 1) % _items.length;
      _draft.clear();
      _feedback = null;
    });
  }

  Future<void> _grade() async {
    if (_draft.text.trim().length < 40) {
      StudyMessenger.showInfo(context, 'Write a fuller draft before grading.');
      return;
    }
    setState(() {
      _loading = true;
      _feedback = null;
    });
    try {
      final LawWritingItem item = _current;
      final String fb = AppConfig.hasOpenAi
          ? await context.read<OpenAiService>().lawGradeWriting(
                writingType: item.writingType,
                prompt: item.prompt,
                doctrine: '${widget.lesson.doctrine}\nElements: ${widget.lesson.elements.join(', ')}',
                studentText: _draft.text.trim(),
              )
          : '## Offline writing checklist\n\n'
              '- Caption / purpose clear?\n- Facts separated from argument?\n'
              '- Each element addressed (${widget.lesson.elements.join(', ')})?\n'
              '- Professional tone?\n- Specific ask / prayer for relief?\n\n'
              'Doctrine focus: ${widget.lesson.doctrine}';
      if (!mounted) return;
      setState(() {
        _feedback = fb;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LawWritingItem item = _current;
    return Scaffold(
      backgroundColor: LawTheme.background,
      appBar: AppBar(
        backgroundColor: LawTheme.bench,
        foregroundColor: Colors.white,
        title: Text(item.writingType),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _loading ? null : _nextPrompt,
            icon: const Icon(Icons.skip_next_rounded, size: 18),
            label: Text(
              '${_index + 1}/${_items.length}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            widget.lesson.title,
            style: TextStyle(color: LawTheme.primary, fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(item.prompt, style: TextStyle(color: LawTheme.textPrimary, height: 1.45, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _draft,
            minLines: 12,
            maxLines: 24,
            decoration: InputDecoration(
              hintText: 'Draft here…',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: LawTheme.surface,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _grade,
            style: FilledButton.styleFrom(
              backgroundColor: LawTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(_loading ? 'Grading…' : 'Grade writing', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _loading ? null : _nextPrompt,
            icon: const Icon(Icons.skip_next_rounded),
            label: Text(_index >= _items.length - 1 ? 'Back to first prompt' : 'Next writing prompt'),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: LawTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LawTheme.border),
              ),
              child: TutorMarkdownBody(text: _feedback!, textColor: LawTheme.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}
