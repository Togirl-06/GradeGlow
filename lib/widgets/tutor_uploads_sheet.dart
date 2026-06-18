import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/parsed_question.dart';
import '../models/search_filters.dart';
import '../models/study_material.dart';
import '../services/material_service.dart';
import '../services/question_service.dart';
import '../services/tutor_context_service.dart';
import '../theme/study_theme.dart';

/// Pick one of the student's uploaded exams to use as tutor context.
class TutorUploadsSheet extends StatelessWidget {
  const TutorUploadsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => const TutorUploadsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MaterialService materials = context.watch<MaterialService>();
    final QuestionService questions = context.watch<QuestionService>();
    final TutorContextService tutorContext = context.read<TutorContextService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: StudyColors.border(Theme.of(context).brightness),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Uploads', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            'Attach an exam you uploaded so the tutor knows your questions.',
            style: TextStyle(color: textSecondary, fontSize: 13, height: 1.35),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: StreamBuilder<List<StudyMaterial>>(
                  stream: materials.watchMyUploads(limit: 50),
                  builder: (BuildContext context, AsyncSnapshot<List<StudyMaterial>> matSnap) {
                    return StreamBuilder<List<ParsedQuestion>>(
                      stream: questions.watchQuestions(const SearchFilters()),
                      builder: (BuildContext context, AsyncSnapshot<List<ParsedQuestion>> qSnap) {
                        final List<StudyMaterial> uploads = matSnap.data ?? <StudyMaterial>[];
                        final List<ParsedQuestion> allQuestions = qSnap.data ?? <ParsedQuestion>[];

                        if (uploads.isEmpty) {
                          return Center(
                            child: Text(
                              'No uploads yet. Upload an exam from Home → Recent uploads.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: textSecondary),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: uploads.length,
                          separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                          itemBuilder: (BuildContext context, int index) {
                            final StudyMaterial m = uploads[index];
                            final List<ParsedQuestion> pool = allQuestions
                                .where((ParsedQuestion q) => q.materialId == m.id)
                                .toList();

                            return ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: StudyColors.border(Theme.of(context).brightness)),
                              ),
                              leading: Icon(
                                m.mimeType.startsWith('image/')
                                    ? Icons.image_outlined
                                    : Icons.picture_as_pdf_outlined,
                                color: StudyColors.primary,
                              ),
                              title: Text(
                                '${m.courseCode} · ${m.examType}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(
                                '${m.fileName} · ${m.parseStatus == 'done' ? '${pool.length} questions' : m.parseStatus}',
                                style: TextStyle(color: textSecondary, fontSize: 12),
                              ),
                              trailing: const Icon(Icons.chevron_right, size: 20),
                              onTap: () {
                                tutorContext.setFromMaterial(m, pool);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Using ${m.courseCode} ${m.examType} as context')),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
