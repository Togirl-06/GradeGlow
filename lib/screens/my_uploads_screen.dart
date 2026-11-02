import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_material.dart';
import '../services/material_service.dart';
import '../theme/study_theme.dart';
import '../widgets/study_surface.dart';
import 'quiz_mode_screen.dart';
import 'upload_screen.dart';

/// Lists exams and files the signed-in user has uploaded.
class MyUploadsScreen extends StatelessWidget {
  const MyUploadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialService materials = context.watch<MaterialService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(title: const Text('My uploads')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const UploadScreen()),
          );
        },
        icon: const Icon(Icons.cloud_upload_outlined),
        label: const Text('Upload'),
      ),
      body: StreamBuilder<List<StudyMaterial>>(
        stream: materials.watchMyUploads(limit: 200),
        builder: (BuildContext context, AsyncSnapshot<List<StudyMaterial>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<StudyMaterial> uploads = snapshot.data ?? <StudyMaterial>[];
          if (uploads.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.folder_open_outlined, size: 48, color: textSecondary),
                    const SizedBox(height: 12),
                    Text(
                      'No uploads yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload an exam PDF or photo to build your question bank.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textSecondary),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(builder: (_) => const UploadScreen()),
                        );
                      },
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Upload exam'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            itemCount: uploads.length,
            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              final StudyMaterial material = uploads[index];
              final IconData icon = material.mimeType.startsWith('image/')
                  ? Icons.image_outlined
                  : Icons.picture_as_pdf_outlined;

              return StudySurfaceCard(
                onTap: material.isParsed
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => QuizModeScreen(initialMaterialId: material.id),
                          ),
                        );
                      }
                    : null,
                child: Row(
                  children: <Widget>[
                    Icon(icon, color: StudyColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${material.courseCode} · ${material.examType}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            material.fileName,
                            style: TextStyle(color: textSecondary, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${material.professor} · ${material.semester}',
                            style: TextStyle(color: textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: material.parseStatus),
                    if (material.isParsed) ...<Widget>[
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: textSecondary),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final String label = switch (status) {
      'done' => 'Parsed',
      'failed' => 'Failed',
      _ => 'Processing',
    };
    final Color color = switch (status) {
      'done' => StudyColors.success,
      'failed' => StudyColors.danger,
      _ => StudyColors.warning,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
