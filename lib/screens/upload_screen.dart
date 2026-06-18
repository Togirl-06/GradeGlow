import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/user_profile.dart';
import '../services/course_service.dart';
import '../services/material_service.dart';
import '../services/user_service.dart';
import '../utils/gamification.dart';
import '../theme/study_theme.dart';
import '../widgets/file_picker_gate.dart';
import '../widgets/study_surface.dart';
import '../utils/study_messenger.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? _bytes;
  String _fileName = '';
  String _mimeType = 'application/pdf';
  int _rotation = 0;
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _professorController = TextEditingController();
  final TextEditingController _examTypeController = TextEditingController(text: 'Midterm');
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _topicsController = TextEditingController();
  bool _anonymous = false;

  @override
  void dispose() {
    _courseCodeController.dispose();
    _professorController.dispose();
    _examTypeController.dispose();
    _semesterController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final Uint8List? bytes = await FilePickerGate.pickPdf(context);
    if (bytes == null || !mounted) return;
    setState(() {
      _bytes = bytes;
      _fileName = 'exam.pdf';
      _mimeType = 'application/pdf';
      _rotation = 0;
    });
  }

  Future<void> _pickImage(MaterialService materials, ImageSource source) async {
    final Uint8List? bytes = await materials.pickImage(source);
    if (bytes == null) return;
    setState(() {
      _bytes = bytes;
      _fileName = 'scan.jpg';
      _mimeType = 'image/jpeg';
    });
  }

  Future<void> _upload(MaterialService materials) async {
    if (_bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a file first.')),
      );
      return;
    }

    final String code = _courseCodeController.text.trim();
    final String professor = _professorController.text.trim();
    final String semester = _semesterController.text.trim();
    if (code.isEmpty || professor.isEmpty || semester.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter course code, professor, and semester.')),
      );
      return;
    }

    try {
      final UserService users = context.read<UserService>();
      final CourseService courses = context.read<CourseService>();
      final UserProfile profile = await users.watchProfile().first;
      final Course course = await courses.addCourse(
        code: code,
        professor: professor,
        semester: semester,
        school: profile.school,
      );
      await users.addCourseToProfile(course.id);

      await users.addXp(Gamification.xpUpload);

      await materials.upload(
        MaterialUploadInput(
          bytes: _bytes!,
          fileName: _fileName,
          mimeType: _mimeType,
          courseId: course.id,
          courseCode: course.code,
          professor: course.professor,
          examType: _examTypeController.text.trim(),
          semester: semester,
          topics: _topicsFromInput(),
          isAnonymous: _anonymous,
          rotationDegrees: _rotation,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded and parsed! +${Gamification.xpUpload} XP')),
      );
      setState(() {
        _bytes = null;
        _fileName = '';
      });
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    }
  }

  List<String> _topicsFromInput() {
    return _topicsController.text
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final MaterialService materials = context.watch<MaterialService>();
    final UserService users = context.watch<UserService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: <Widget>[
        const Text('Upload', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Past exams & quizzes — PDF or photo scan', style: TextStyle(color: textSecondary)),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: materials.isUploading ? null : _pickPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('PDF'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: materials.isUploading ? null : () => _pickImage(materials, ImageSource.gallery),
                icon: const Icon(Icons.photo_outlined),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: materials.isUploading ? null : () => _pickImage(materials, ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
        if (_bytes != null && _mimeType.startsWith('image/')) ...<Widget>[
          const SizedBox(height: 12),
          StudySurfaceCard(
            child: Column(
              children: <Widget>[
                const Text('Scan tools', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      onPressed: () => setState(() => _rotation = (_rotation - 90) % 360),
                      icon: const Icon(Icons.rotate_left),
                      tooltip: 'Rotate left',
                    ),
                    IconButton(
                      onPressed: () => setState(() => _rotation = (_rotation + 90) % 360),
                      icon: const Icon(Icons.rotate_right),
                      tooltip: 'Rotate right',
                    ),
                    const Text('Auto-enhance on upload'),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        StreamBuilder<UserProfile>(
          stream: users.watchProfile(),
          builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Upload anonymously'),
              subtitle: Text('Hide your name on this upload', style: TextStyle(color: textSecondary)),
              value: _anonymous,
              onChanged: (bool value) => setState(() => _anonymous = value),
            );
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _courseCodeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Course code', hintText: 'CHEM 1211'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _professorController,
          decoration: const InputDecoration(labelText: 'Professor'),
        ),
        const SizedBox(height: 8),
        TextField(controller: _examTypeController, decoration: const InputDecoration(labelText: 'Exam type')),
        const SizedBox(height: 8),
        TextField(controller: _semesterController, decoration: const InputDecoration(labelText: 'Semester')),
        const SizedBox(height: 8),
        TextField(
          controller: _topicsController,
          decoration: const InputDecoration(labelText: 'Topics (comma separated)'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: materials.isUploading ? null : () => _upload(materials),
            icon: materials.isUploading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(materials.isUploading ? 'Uploading…' : 'Upload & parse questions'),
          ),
        ),
      ],
    );
  }
}
