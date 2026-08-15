import 'package:flutter/material.dart';

import '../../data/physics/physics_catalog.dart';
import '../../models/physics/physics_program.dart';
import '../../theme/faculty_palette.dart';
import '../../widgets/faculty/faculty_ui.dart';
import '../../widgets/physics/physics_practical_lab_section.dart';
import 'physics_routes.dart';

/// Physics Faculty home body — loaded lazily so opening Physics stays responsive.
class PhysicsProgramContent extends StatelessWidget {
  const PhysicsProgramContent({super.key, required this.palette});

  final FacultyPalette palette;

  @override
  Widget build(BuildContext context) {
    final List<PhysicsLevel> levels = List<PhysicsLevel>.from(PhysicsCatalog.levels)
      ..sort((PhysicsLevel a, PhysicsLevel b) => a.order.compareTo(b.order));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: <Widget>[
        FacultyHeroCard(
          palette: palette,
          title: 'The complete physics universe',
          tagline: PhysicsCatalog.philosophy,
          body: PhysicsCatalog.mission,
          stats: <String>[
            '${PhysicsCatalog.courseCount} courses',
            '${PhysicsCatalog.topicCount} topics',
            '${PhysicsLearningMode.values.length} learning modes',
          ],
          trailing: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.public_rounded, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 24),
        const PhysicsPracticalLabSection(previewCount: 6),
        const SizedBox(height: 28),
        FacultySectionHeader(palette: palette, label: 'Select level', icon: Icons.layers_outlined),
        ...levels.map((PhysicsLevel level) {
          final PhysicsLevelStats stats = PhysicsCatalog.statsForLevel(level);
          return FacultyNavCard(
            palette: palette,
            icon: level.icon,
            title: level.label,
            subtitle: level.subtitle,
            detail: '${stats.courses} courses · ${stats.topics} topics',
            onTap: () => PhysicsRoutes.openLevel(context, level),
          );
        }),
      ],
    );
  }
}
