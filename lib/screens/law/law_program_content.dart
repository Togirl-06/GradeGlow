import 'package:flutter/material.dart';

import '../../data/law/law_catalog.dart';
import '../../models/law/law_program.dart';
import '../../models/law_simulation.dart';
import '../../models/practice_lab.dart';
import '../../services/law_daily_case_scheduler.dart';
import '../../services/law_daily_progress_service.dart';
import '../../theme/faculty_palette.dart';
import '../../theme/law_theme.dart';
import '../../widgets/faculty/faculty_ui.dart';
import '../law_simulation_hub_screen.dart';
import 'law_specialization_screen.dart';

/// Law School home body — loaded lazily to avoid memory spikes.
class LawProgramContent extends StatelessWidget {
  const LawProgramContent({super.key, required this.palette});

  final FacultyPalette palette;

  static final PracticeLabCategory _lawCategory = PracticeLabCategory(
    id: 'law',
    name: 'Law',
    emoji: '⚖️',
    icon: Icons.balance_outlined,
    labs: const <PracticeLabType>[],
    groupId: 'law_criminal_justice',
  );

  static const PracticeLabType _courtLab = PracticeLabType(
    id: 'law_school_courtroom',
    title: 'Live Courtroom',
    subtitle: 'Investigate, argue, and persuade an AI judge.',
    style: SimulationStyle.courtroom,
    aiRole: 'Judge',
  );

  @override
  Widget build(BuildContext context) {
    final String featuredSpecId = LawDailyCaseScheduler.weekdaySpecializationId();

    return ListenableBuilder(
      listenable: LawDailyProgressService.instance,
      builder: (BuildContext context, Widget? _) {
        final LawDailyProgressService progress = LawDailyProgressService.instance;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: <Widget>[
            FacultyHeroCard(
              palette: palette,
              title: 'Think like a lawyer',
              tagline: LawCatalog.philosophy,
              body: LawCatalog.mission,
              trailing: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.balance_rounded, color: LawTheme.gavel, size: 28),
              ),
            ),
            const SizedBox(height: 16),
            FacultyNavCard(
              palette: palette,
              icon: Icons.play_circle_outline,
              title: 'Continue learning',
              subtitle: 'Browse specializations and topics',
              detail: 'Pick up where you left off',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LawSpecializationScreen(specializationId: featuredSpecId),
                ),
              ),
            ),
            FacultyNavCard(
              palette: palette,
              icon: Icons.account_balance_rounded,
              title: 'Case library',
              subtitle: 'All specializations · AI judge',
              detail: 'Live courtroom simulations',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LawSimulationHubScreen(category: _lawCategory, lab: _courtLab),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FacultySectionHeader(palette: palette, label: 'How you learn', icon: Icons.school_outlined),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LawLearningMode.values
                  .take(6)
                  .map((LawLearningMode m) => FacultyConceptChip(label: m.label, palette: palette))
                  .toList(),
            ),
            const SizedBox(height: 22),
            FacultySectionHeader(palette: palette, label: 'Specializations', icon: Icons.folder_special_outlined),
            ...LawCatalog.specializations.map((LawSpecialization s) {
              final LawCaseFile? daily = LawDailyCaseScheduler.caseForSpecialization(s.id);
              final bool done = progress.isDailyCompleted(s.id);
              final int topicCount = s.courses.fold<int>(0, (int a, LawCourse c) => a + c.lessons.length);
              return FacultyNavCard(
                palette: palette,
                icon: s.icon,
                title: s.name,
                subtitle: s.tagline,
                detail: daily == null
                    ? '$topicCount topics'
                    : done
                        ? "Today's case done · ${daily.title}"
                        : "Today: ${daily.title}",
                badge: done ? 'Done' : (daily != null ? 'Daily' : null),
                trailing: done
                    ? Icon(Icons.check_circle_rounded, color: LawTheme.success, size: 22)
                    : null,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => LawSpecializationScreen(specializationId: s.id)),
                ),
              );
            }),
            const SizedBox(height: 12),
            Text(
              '${LawCatalog.specializationCount} tracks · ${LawCatalog.lessonCount} topics · courtroom practice included',
              style: TextStyle(color: palette.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
