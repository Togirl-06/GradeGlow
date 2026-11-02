import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note_item.dart';
import '../services/notes_service.dart';
import '../theme/study_theme.dart';
import '../widgets/file_picker_gate.dart';
import '../widgets/study_surface.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isUploading = false;

  Future<void> _upload(NotesService notes) async {
    setState(() => _isUploading = true);
    try {
      final Uint8List? bytes = await FilePickerGate.pickPdf(context);
      if (bytes == null || !mounted) return;
      final NoteItem note = await notes.uploadPdfBytes(bytes, 'notes.pdf');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded ${note.name}')),
      );
    } catch (error) {
      if (!mounted) return;
      final String message = error.toString().replaceFirst('Exception: ', '');
      if (message != 'No file selected.') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NotesService notes = context.watch<NotesService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        const Text('Notes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Upload PDFs and lecture notes', style: TextStyle(color: textSecondary)),
        const SizedBox(height: 16),
        StudySurfaceCard(
          onTap: _isUploading ? null : () => _upload(notes),
          child: Column(
            children: <Widget>[
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                )
              else ...<Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: StudyColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.cloud_upload_outlined, color: StudyColors.primary, size: 32),
                ),
                const SizedBox(height: 12),
                const Text('Upload notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  'Tap to add PDF files',
                  style: TextStyle(color: textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Your files', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        StreamBuilder<List<NoteItem>>(
          stream: notes.watchNotes(),
          builder: (BuildContext context, AsyncSnapshot<List<NoteItem>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final List<NoteItem> items = snapshot.data ?? <NoteItem>[];
            if (items.isEmpty) {
              return StudySurfaceCard(
                child: Text(
                  'No notes yet. Upload your first PDF.',
                  style: TextStyle(color: textSecondary),
                ),
              );
            }

            return Column(
              children: items
                  .map(
                    (NoteItem note) => _NoteTile(
                      title: note.name,
                      subtitle: note.sizeLabel,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return StudySurfaceCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: StudyColors.pdfRed.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: StudyColors.pdfRed),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
