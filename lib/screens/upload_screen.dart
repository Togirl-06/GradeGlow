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
import '../utils/study_messenger.dart';
import '../widgets/file_picker_gate.dart';

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
  final TextEditingController _examTypeController = TextEditingController(
    text: 'Midterm',
  );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a file first.')));
      return;
    }

    final String code = _courseCodeController.text.trim();
    final String professor = _professorController.text.trim();
    final String semester = _semesterController.text.trim();
    if (code.isEmpty || professor.isEmpty || semester.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter course code, professor, and semester.'),
        ),
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
        SnackBar(
          content: Text('Uploaded and parsed! +${Gamification.xpUpload} XP'),
        ),
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

  String get _sourceLabel {
    if (_bytes == null) return 'No file selected';
    if (_mimeType.startsWith('image/')) return 'Image ready · $_fileName';
    return 'PDF ready · $_fileName';
  }

  @override
  Widget build(BuildContext context) {
    final MaterialService materials = context.watch<MaterialService>();
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.cloud_upload_rounded,
                    color: scheme.onPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Past exams & quizzes',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Upload a PDF or photo scan and GradeGlow will parse the questions.',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.72),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'SOURCE',
            style: TextStyle(
              color: scheme.primary,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how to add the exam',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _SourceCard(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'PDF',
                  subtitle: 'Documents',
                  enabled: !materials.isUploading,
                  onTap: _pickPdf,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SourceCard(
                  icon: Icons.photo_outlined,
                  title: 'Gallery',
                  subtitle: 'Photo scan',
                  enabled: !materials.isUploading,
                  onTap: () => _pickImage(materials, ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SourceCard(
                  icon: Icons.camera_alt_outlined,
                  title: 'Camera',
                  subtitle: 'Live scan',
                  enabled: !materials.isUploading,
                  onTap: () => _pickImage(materials, ImageSource.camera),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  _bytes == null
                      ? Icons.insert_drive_file_outlined
                      : Icons.check_circle_rounded,
                  color: _bytes == null
                      ? scheme.onSurfaceVariant
                      : scheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _sourceLabel,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_bytes != null && _mimeType.startsWith('image/')) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Scan tools',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      _ToolChip(
                        icon: Icons.rotate_left_rounded,
                        label: 'Rotate L',
                        onTap: () =>
                            setState(() => _rotation = (_rotation - 90) % 360),
                      ),
                      const SizedBox(width: 8),
                      _ToolChip(
                        icon: Icons.rotate_right_rounded,
                        label: 'Rotate R',
                        onTap: () =>
                            setState(() => _rotation = (_rotation + 90) % 360),
                      ),
                      const Spacer(),
                      Text(
                        '$_rotation°',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'DETAILS',
            style: TextStyle(
              color: scheme.primary,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tag this upload',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: Text(
                'Upload anonymously',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                'Hide your name on this upload',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10),
              ),
              value: _anonymous,
              onChanged: (bool value) => setState(() => _anonymous = value),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _courseCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Course code',
              hintText: 'CHEM 1211',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _professorController,
            decoration: const InputDecoration(labelText: 'Professor'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _examTypeController,
            decoration: const InputDecoration(labelText: 'Exam type'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _semesterController,
            decoration: const InputDecoration(labelText: 'Semester'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _topicsController,
            decoration: const InputDecoration(
              labelText: 'Topics (comma separated)',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: materials.isUploading
                  ? null
                  : () => _upload(materials),
              icon: materials.isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                materials.isUploading
                    ? 'Uploading…'
                    : 'Upload & parse questions',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 112,
          padding: const EdgeInsets.fromLTRB(12, 13, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 24, color: scheme.primary),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 8.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: scheme.onPrimaryContainer),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
