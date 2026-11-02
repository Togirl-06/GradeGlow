import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/app_branding.dart';
import '../theme/study_theme.dart';
import '../utils/io_file_bytes.dart';
import '../utils/study_file_types.dart';

/// Opens the system file browser, then leaves a GradeGlow screen underneath
/// with a visible back button when the user returns from Android's picker.
class FilePickerGate {
  FilePickerGate._();

  static Future<Uint8List?> pickPdf(BuildContext context) {
    return Navigator.of(context).push<Uint8List?>(
      MaterialPageRoute<Uint8List?>(
        fullscreenDialog: true,
        builder: (BuildContext context) => const _FilePickerGatePage(
          title: 'Choose file',
          fileLabel: 'file',
        ),
      ),
    );
  }

  static Future<Uint8List?> _pickPdfBytes() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: StudyFileTypes.documentExtensions,
      withData: true,
      dialogTitle: 'Select a file',
    );
    if (result == null || result.files.isEmpty) return null;
    final PlatformFile file = result.files.first;
    if (file.bytes != null && file.bytes!.isNotEmpty) return file.bytes;
    if (!kIsWeb && file.path != null && file.path!.isNotEmpty) {
      return readFileBytes(file.path!);
    }
    return null;
  }
}

class _FilePickerGatePage extends StatefulWidget {
  const _FilePickerGatePage({
    required this.title,
    required this.fileLabel,
  });

  final String title;
  final String fileLabel;

  @override
  State<_FilePickerGatePage> createState() => _FilePickerGatePageState();
}

class _FilePickerGatePageState extends State<_FilePickerGatePage> {
  bool _browserOpen = true;
  bool _ranPick = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openFileBrowser());
  }

  Future<void> _openFileBrowser() async {
    if (_ranPick) return;
    _ranPick = true;
    setState(() => _browserOpen = true);

    final Uint8List? bytes = await FilePickerGate._pickPdfBytes();

    if (!mounted) return;
    setState(() => _browserOpen = false);

    if (bytes != null) {
      Navigator.of(context).pop(bytes);
    }
  }

  void _backToApp() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color muted = StudyColors.textSecondary(brightness);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _backToApp),
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_browserOpen) ...<Widget>[
                const Spacer(),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
                Text(
                  'File browser is open',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'To return without choosing a file, use your phone\'s Back button or gesture. '
                  'You\'ll land here — then tap Back to ${AppBranding.name} below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, height: 1.45),
                ),
                const Spacer(),
              ] else ...<Widget>[
                const Spacer(),
                Icon(Icons.folder_off_outlined, size: 48, color: muted),
                const SizedBox(height: 16),
                Text(
                  'No ${widget.fileLabel} selected',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick a file or go back to the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    _ranPick = false;
                    _openFileBrowser();
                  },
                  icon: const Icon(Icons.folder_open_outlined),
                  label: Text('Browse ${widget.fileLabel} again'),
                ),
                const SizedBox(height: 10),
              ],
              OutlinedButton.icon(
                onPressed: _backToApp,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text('Back to ${AppBranding.name}'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
