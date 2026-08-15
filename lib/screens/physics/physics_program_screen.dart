import 'package:flutter/material.dart';

import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'physics_program_content.dart' deferred as content;

/// Physics Faculty home — foundations through research, not year-by-year.
class PhysicsProgramScreen extends StatefulWidget {
  const PhysicsProgramScreen({super.key});

  @override
  State<PhysicsProgramScreen> createState() => _PhysicsProgramScreenState();
}

class _PhysicsProgramScreenState extends State<PhysicsProgramScreen> {
  static final FacultyPalette _palette = FacultyPalette.physics();

  Future<void>? _load;

  @override
  void initState() {
    super.initState();
    _load = content.loadLibrary();
  }

  @override
  Widget build(BuildContext context) {
    return FacultyScaffold(
      palette: _palette,
      title: 'Physics Faculty',
      body: FutureBuilder<void>(
        future: _load,
        builder: (BuildContext context, AsyncSnapshot<void> snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(color: _palette.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Physics Faculty…',
                    style: TextStyle(color: _palette.textSecondary, fontWeight: FontWeight.w600),
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
                  'Could not load Physics Faculty.\n${snap.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _palette.textSecondary),
                ),
              ),
            );
          }
          return content.PhysicsProgramContent(palette: _palette);
        },
      ),
    );
  }
}
