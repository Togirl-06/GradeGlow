import 'package:flutter/material.dart';

import '../../services/vu_notes_service.dart';
import '../../widgets/study_surface.dart';
import '../../widgets/virtual_university/vu_accessibility.dart';

/// Lists Virtual University notes, bookmarks, and highlights with search + FAB.
class VuNotesScreen extends StatefulWidget {
  const VuNotesScreen({super.key, this.service});

  /// Optional override for tests; defaults to [VuNotesService.instance].
  final VuNotesService? service;

  @override
  State<VuNotesScreen> createState() => _VuNotesScreenState();
}

class _VuNotesScreenState extends State<VuNotesScreen> {
  late final VuNotesService _service =
      widget.service ?? VuNotesService.instance;
  final TextEditingController _search = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _service.ensureLoaded();
    if (mounted) setState(() => _loading = false);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    _search.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    final ({String title, String body})? result =
        await showDialog<({String title, String body})>(
          context: context,
          builder: (BuildContext context) => const _AddNoteDialog(),
        );
    if (result == null) return;
    await _service.addNote(title: result.title, body: result.body);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note saved')));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String query = _search.text;
    final ({
      List<VuNote> notes,
      List<VuBookmark> bookmarks,
      List<VuHighlight> highlights,
    })
    results = _service.search(query);

    return Scaffold(
      appBar: AppBar(title: const Text('VU Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: _loading ? null : _addNote,
        tooltip: 'Add note',
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
              children: <Widget>[
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search notes, bookmarks, highlights',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                            },
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                VuSemanticSectionHeader(
                  label: 'Notes',
                  child: Text(
                    'Notes (${results.notes.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (results.notes.isEmpty)
                  _EmptyLine(
                    text: 'No notes yet — tap + to add one.',
                    color: scheme.onSurfaceVariant,
                  )
                else
                  for (final VuNote note in results.notes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: StudySurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Delete note',
                                  onPressed: () => _service.removeNote(note.id),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                            if (note.lessonId != null &&
                                note.lessonId!.isNotEmpty) ...<Widget>[
                              Text(
                                'Lesson: ${note.lessonId}',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              note.body,
                              style: const TextStyle(height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
                VuSemanticSectionHeader(
                  label: 'Bookmarks',
                  child: Text(
                    'Bookmarks (${results.bookmarks.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (results.bookmarks.isEmpty)
                  _EmptyLine(
                    text: 'No bookmarks yet.',
                    color: scheme.onSurfaceVariant,
                  )
                else
                  for (final VuBookmark bookmark in results.bookmarks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: StudySurfaceCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.bookmark, color: scheme.primary),
                          title: Text(
                            bookmark.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text('Lesson: ${bookmark.lessonId}'),
                          trailing: IconButton(
                            tooltip: 'Remove bookmark',
                            onPressed: () =>
                                _service.removeBookmark(bookmark.id),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
                VuSemanticSectionHeader(
                  label: 'Highlights',
                  child: Text(
                    'Highlights (${results.highlights.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (results.highlights.isEmpty)
                  _EmptyLine(
                    text: 'No highlights yet.',
                    color: scheme.onSurfaceVariant,
                  )
                else
                  for (final VuHighlight highlight in results.highlights)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: StudySurfaceCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.highlight,
                            color: scheme.tertiary,
                          ),
                          title: Text(highlight.text),
                          subtitle: Text('Lesson: ${highlight.lessonId}'),
                          trailing: IconButton(
                            tooltip: 'Remove highlight',
                            onPressed: () =>
                                _service.removeHighlight(highlight.id),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(color: color)),
    );
  }
}

class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _body,
              decoration: const InputDecoration(labelText: 'Note'),
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final String title = _title.text.trim();
            final String body = _body.text.trim();
            if (title.isEmpty || body.isEmpty) return;
            Navigator.pop(context, (title: title, body: body));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
