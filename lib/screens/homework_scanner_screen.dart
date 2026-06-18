import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/openai_service.dart';
import '../services/tutor_voice_service.dart';
import '../theme/study_theme.dart';
import '../widgets/premium_gate.dart';
import '../widgets/study_surface.dart';
import '../utils/study_messenger.dart';

/// Camera → OpenAI Vision → step-by-step solution (+ optional speech).
class HomeworkScannerScreen extends StatefulWidget {
  const HomeworkScannerScreen({super.key});

  @override
  State<HomeworkScannerScreen> createState() => _HomeworkScannerScreenState();
}

class _HomeworkScannerScreenState extends State<HomeworkScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final TutorVoiceService _voice = TutorVoiceService();
  String? _imagePath;
  String? _solution;
  bool _loading = false;
  bool _voiceReady = false;

  @override
  void initState() {
    super.initState();
    _voice.initialize().then((VoiceCapabilities c) {
      if (mounted) setState(() => _voiceReady = c.canSpeak);
    });
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (photo == null || !mounted) return;
    setState(() {
      _imagePath = photo.path;
      _solution = null;
    });
  }

  Future<void> _solve() async {
    if (_imagePath == null) return;
    setState(() => _loading = true);
    final OpenAiService openAi = context.read<OpenAiService>();
    try {
      final String steps = await openAi.solveHomeworkFromImage(_imagePath!);
      if (!mounted) return;
      setState(() => _solution = steps);
      if (_voiceReady) await _voice.speak(steps);
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      title: 'Exam review',
      description:
          'AI-generated study guides and exam reviews are included with Premium. Upgrade to scan assignments and get guided solutions.',
      icon: Icons.document_scanner_outlined,
      child: _HomeworkScannerBody(
        picker: _picker,
        voice: _voice,
        imagePath: _imagePath,
        solution: _solution,
        loading: _loading,
        voiceReady: _voiceReady,
        onCapture: _capture,
        onSolve: _solve,
      ),
    );
  }
}

class _HomeworkScannerBody extends StatelessWidget {
  const _HomeworkScannerBody({
    required this.picker,
    required this.voice,
    required this.imagePath,
    required this.solution,
    required this.loading,
    required this.voiceReady,
    required this.onCapture,
    required this.onSolve,
  });

  final ImagePicker picker;
  final TutorVoiceService voice;
  final String? imagePath;
  final String? solution;
  final bool loading;
  final bool voiceReady;
  final Future<void> Function() onCapture;
  final Future<void> Function() onSolve;

  @override
  Widget build(BuildContext context) {
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(title: const Text('Homework Scanner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Take a picture of a math or science problem. AI explains Step 1, Step 2, Step 3…',
            style: TextStyle(color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          if (imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(imagePath!), fit: BoxFit.cover),
            ),
          if (imagePath == null)
            StudySurfaceCard(
              child: Column(
                children: <Widget>[
                  Icon(Icons.camera_alt_outlined, size: 48, color: StudyColors.primary),
                  const SizedBox(height: 8),
                  Text('No photo yet', style: TextStyle(color: textSecondary)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCapture,
                  icon: const Icon(Icons.camera_outlined),
                  label: const Text('Take photo'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: loading || imagePath == null ? null : onSolve,
                  icon: loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome),
                  label: Text(loading ? 'Solving…' : 'Solve'),
                ),
              ),
            ],
          ),
          if (solution != null) ...<Widget>[
            const SizedBox(height: 20),
            StudySurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Solution', style: TextStyle(fontWeight: FontWeight.w800, color: StudyColors.primary)),
                  const SizedBox(height: 10),
                  Text(solution!, style: const TextStyle(height: 1.5)),
                  if (voiceReady) ...<Widget>[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => voice.speak(solution!),
                      icon: const Icon(Icons.volume_up_outlined),
                      label: const Text('Listen'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
