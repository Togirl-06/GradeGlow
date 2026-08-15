import 'package:flutter/material.dart';

import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'law_program_content.dart' deferred as content;

/// Law School home — think like a lawyer from day one.
class LawProgramScreen extends StatefulWidget {
  const LawProgramScreen({super.key});

  @override
  State<LawProgramScreen> createState() => _LawProgramScreenState();
}

class _LawProgramScreenState extends State<LawProgramScreen> {
    Future<void>? _load;

  @override
  void initState() {
    super.initState();
    _load = content.loadLibrary();
  }

  @override
  Widget build(BuildContext context) {
    final FacultyPalette palette = FacultyPalette.law(context);
    return FacultyScaffold(
      palette: palette,
      title: 'Law School',
      body: FutureBuilder<void>(
        future: _load,
        builder: (BuildContext context, AsyncSnapshot<void> snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(color: palette.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Law School…',
                    style: TextStyle(color: palette.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load Law School.\n${snap.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textSecondary),
                ),
              ),
            );
          }
          return content.LawProgramContent(palette: palette);
        },
      ),
    );
  }
}
