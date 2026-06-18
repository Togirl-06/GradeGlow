import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/study_summary.dart';
import '../services/notes_summarizer_service.dart';
import '../screens/summary_note_screen.dart';
import '../theme/study_theme.dart';
import '../utils/study_messenger.dart';
import '../utils/url_content_fetcher.dart';

class PasteContentSheet extends StatefulWidget {
  const PasteContentSheet({
    super.key,
    required this.course,
    required this.title,
    this.successPopCount = 1,
  });

  final Course course;
  final String title;
  final int successPopCount;

  static Future<void> show(
    BuildContext context, {
    required Course course,
    required String title,
    int successPopCount = 1,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: PasteContentSheet(course: course, title: title, successPopCount: successPopCount),
      ),
    );
  }

  @override
  State<PasteContentSheet> createState() => _PasteContentSheetState();
}

class _PasteContentSheetState extends State<PasteContentSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isLink = true;
  bool _busy = false;
  String _status = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String value = _controller.text.trim();
    if (value.isEmpty) return;

    final NavigatorState navigator = Navigator.of(context);

    setState(() {
      _busy = true;
      _status = _isLink ? 'Fetching link…' : 'Reading your notes…';
    });

    try {
      final NotesSummarizerService summarizer = context.read<NotesSummarizerService>();
      final String extracted = _isLink ? await fetchUrlAsStudyText(value) : value;

      if (mounted) {
        setState(() => _status = 'Creating summary, flashcards & quiz…');
      }

      final StudySummary summary = await summarizer.summarizeForCourseFromText(
        course: widget.course,
        title: widget.title,
        text: extracted,
      );

      for (int i = 0; i < widget.successPopCount; i++) {
        if (navigator.canPop()) navigator.pop();
      }

      await navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => SummaryNoteScreen(summary: summary),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error, duration: const Duration(seconds: 5));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Paste content', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'YouTube link, website URL, or raw notes text',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment<bool>(value: true, label: Text('Link'), icon: Icon(Icons.link_rounded, size: 18)),
                ButtonSegment<bool>(value: false, label: Text('Text'), icon: Icon(Icons.notes_rounded, size: 18)),
              ],
              selected: <bool>{_isLink},
              onSelectionChanged: _busy ? null : (Set<bool> value) => setState(() => _isLink = value.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              enabled: !_busy,
              maxLines: _isLink ? 2 : 8,
              decoration: InputDecoration(
                hintText: _isLink ? 'https://youtube.com/... or article URL' : 'Paste lecture notes here…',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        if (_status.isNotEmpty) ...<Widget>[
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              _status,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    )
                  : const Text('Create study set'),
            ),
          ],
        ),
      ),
    );
  }
}
