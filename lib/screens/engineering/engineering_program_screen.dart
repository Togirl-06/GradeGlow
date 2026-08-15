import 'package:flutter/material.dart';

import '../../data/engineering/engineering_catalog.dart';
import '../../models/engineering/engineering_program.dart';
import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import 'engineering_major_screen.dart';

/// Engineering Faculty home — pick a major, then learn like an engineer.
class EngineeringProgramScreen extends StatelessWidget {
  const EngineeringProgramScreen({super.key});

    @override
  Widget build(BuildContext context) {
    final FacultyPalette palette = FacultyPalette.engineering(context);
    final List<EngineeringMajor> majors = EngineeringCatalog.majors;

    return FacultyScaffold(
      palette: palette,
      title: 'Engineering Faculty',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: <Widget>[
          FacultyHeroCard(
            palette: palette,
            title: 'Think and work like an engineer',
            tagline: EngineeringCatalog.philosophy,
            body:
                'New to engineering? Start with Civil → Statics, or Mechanical → Mechanics of Materials. '
                'You will learn by changing real variables, watching systems fail safely, and fixing them.',
            stats: <String>[
              '${EngineeringCatalog.majorCount} majors',
              '${EngineeringCatalog.courseCount} courses',
              '6 learning modes',
            ],
            trailing: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.precision_manufacturing_rounded, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: 18),
          FacultyInfoPanel(
            palette: palette,
            icon: Icons.route_outlined,
            title: 'How every course works',
            text:
                'AI Professor → Interactive Concepts → Virtual Lab → Simulator → Design Review → Capstone. '
                'Recommended first path: Civil Engineering → Statics → AI Professor, then Interactive Concepts.',
          ),
          const SizedBox(height: 24),
          FacultySectionHeader(palette: palette, label: 'Select a major', icon: Icons.account_tree_outlined),
          ...majors.map(
            (EngineeringMajor major) => FacultyNavCard(
              palette: palette,
              icon: major.icon,
              title: major.name,
              subtitle: major.tagline,
              detail: '${major.courses.length} courses · ${major.gameplay.take(2).join(' · ')}',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => EngineeringMajorScreen(majorId: major.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
