import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/study_summary.dart';
import '../models/study_upload_input.dart';
import '../screens/my_courses_screen.dart';
import '../services/material_service.dart';
import '../services/mic_capture_service.dart';
import '../services/notes_summarizer_service.dart';
import '../utils/course_summary_actions.dart';
import '../utils/io_file_bytes.dart';
import '../utils/study_messenger.dart';
import '../widgets/file_picker_gate.dart';
import '../widgets/paste_content_sheet.dart';
import '../widgets/record_audio_summarize_dialog.dart';
import 'study_file_types.dart';

/// Pick a course then run Upload / Paste / Record for summarization.
class StudyContentInputActions {
  StudyContentInputActions._();

  static Future<Course?> pickCourse(BuildContext context, List<Course> courses) async {
    if (courses.isEmpty) {
      final bool? go = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Add a class first'),
          content: const Text('Add your courses, then create study sets for each one.'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('My courses')),
          ],
        ),
      );
      if (go == true && context.mounted) {
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => const MyCoursesScreen()),
        );
      }
      return null;
    }

    if (courses.length == 1) return courses.first;

    return showModalBottomSheet<Course>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text('Choose class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              ...courses.map(
                (Course course) => ListTile(
                  title: Text(course.code),
                  subtitle: course.professor.isNotEmpty ? Text(course.professor) : null,
                  onTap: () => Navigator.pop(context, course),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String defaultTitle(Course course) => '${course.code} notes';

  static Future<StudySummary?> upload(
    BuildContext context, {
    required Course course,
    String? title,
  }) async {
    final String studyTitle = title?.trim().isNotEmpty == true ? title!.trim() : defaultTitle(course);
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: StudyFileTypes.uploadExtensions,
      allowMultiple: true,
      withData: true,
      dialogTitle: 'Upload study material',
    );
    if (result == null || result.files.isEmpty || !context.mounted) return null;

    final NotesSummarizerService summarizer = context.read<NotesSummarizerService>();
    final List<StudyUploadInput> inputs = <StudyUploadInput>[];

    try {
      for (final PlatformFile file in result.files) {
        final String ext = (file.extension ?? '').toLowerCase();
        if (!StudyFileTypes.uploadExtensions.contains(ext)) {
          throw Exception('Unsupported file type: ${file.name}');
        }

        final Uint8List? bytes = await _readBytes(file);
        final String? path = (!kIsWeb && file.path != null && file.path!.isNotEmpty)
            ? file.path
            : null;

        if (bytes == null && path == null) {
          throw Exception('Could not read ${file.name}.');
        }

        inputs.add(
          StudyUploadInput(
            fileName: file.name,
            filePath: path,
            bytes: bytes,
          ),
        );
      }

      final StudySummary summary = await summarizer.summarizeMultipleForCourse(
        course: course,
        title: studyTitle,
        files: inputs,
      );

      if (!context.mounted) return null;
      return summary;
    } catch (error) {
      if (!context.mounted) return null;
      StudyMessenger.showError(context, error);
      return null;
    }
  }

  static Future<Uint8List?> _readBytes(PlatformFile file) async {
    if (file.bytes != null && file.bytes!.isNotEmpty) return file.bytes;
    if (!kIsWeb && file.path != null && file.path!.isNotEmpty) {
      return readFileBytes(file.path!);
    }
    return null;
  }

  static Future<void> paste(
    BuildContext context, {
    required Course course,
    String? title,
    int successPopCount = 1,
  }) {
    return PasteContentSheet.show(
      context,
      course: course,
      title: title?.trim().isNotEmpty == true ? title!.trim() : defaultTitle(course),
      successPopCount: successPopCount,
    );
  }

  /// Opens the record dialog: record → review → transcript → summarize.
  static Future<bool> startRecording(
    BuildContext context, {
    required Course course,
    String? title,
  }) async {
    final String studyTitle = title?.trim().isNotEmpty == true ? title!.trim() : defaultTitle(course);

    await MicCaptureService.instance.prepareSession();
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!context.mounted) return false;

    return RecordAudioSummarizeDialog.show(
      context,
      onSummarize: (String audioFilePath, String transcript) async {
        final NotesSummarizerService summarizer = context.read<NotesSummarizerService>();
        final StudySummary summary = await summarizer.summarizeForCourseFromAudio(
          course: course,
          title: studyTitle,
          audioFilePath: audioFilePath,
          transcript: transcript,
        );
        if (!context.mounted) return;
        await CourseSummaryActions.openGeneratedNote(context, summary);
      },
    );
  }

  /// Fallback upload paths when file picker is unavailable.
  static Future<void> uploadPdfViaGate(BuildContext context, Course course, String title) async {
    final Uint8List? bytes = await FilePickerGate.pickPdf(context);
    if (bytes == null || !context.mounted) return;
    final NotesSummarizerService summarizer = context.read<NotesSummarizerService>();
    await summarizer.summarizeForCourse(
      course: course,
      title: title,
      fileName: 'notes.pdf',
      byteLength: bytes.length,
      mimeType: 'application/pdf',
      bytes: bytes,
    );
  }

  static Future<void> uploadImageFromGallery(BuildContext context, Course course, String title) async {
    final MaterialService materials = context.read<MaterialService>();
    final Uint8List? bytes = await materials.pickImage(ImageSource.gallery);
    if (bytes == null || !context.mounted) return;
    final NotesSummarizerService summarizer = context.read<NotesSummarizerService>();
    await summarizer.summarizeForCourse(
      course: course,
      title: title,
      fileName: 'slides.jpg',
      byteLength: bytes.length,
      mimeType: 'image/jpeg',
      bytes: bytes,
    );
  }
}
