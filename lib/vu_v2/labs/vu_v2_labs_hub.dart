import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/appearance_service.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';
import '../business_career/business_career_hub_screen.dart';
import '../career_labs/playable/glow/life_skills/budget_boss_lab.dart';
import '../engineering_career/engineering_career_hub_screen.dart';
import '../health_career/health_simulation_hub_screen.dart';
import '../../life_sim/ui/screens/life_game_screen.dart';
import '../science_career/science_career_hub_screen.dart';

/// Labs tab = career simulation labs (Technology, Engineering, Business, Health).
class VuV2LabsHub extends StatelessWidget {
  const VuV2LabsHub({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    context.watch<AppearanceService>();
    VuV2Colors.syncTo(Theme.of(context));

    void openTechLab() {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ScienceCareerHubScreen(
            initialMajorId: _scienceMajorId(session.majorId),
            playerName: session.displayName,
          ),
        ),
      );
    }

    void openEngLab() {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => EngineeringCareerHubScreen(
            initialMajorId: _engineeringMajorId(session.majorId),
            playerName: session.displayName,
          ),
        ),
      );
    }

    void openBizLab() {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => BusinessCareerHubScreen(
            initialMajorId: 'business_administration',
            playerName: session.displayName,
          ),
        ),
      );
    }

    void openHealthLab() {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => HealthSimulationHubScreen(
            initialCourseId: 'nursing',
            playerName: session.displayName,
          ),
        ),
      );
    }

    void openBudgetBoss() {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => budgetBossScreen()),
      );
    }

    void openLifeSim() {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const LifeGameLauncher()),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
      children: <Widget>[
        Text(
          'Labs',
          style: TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Immersive career simulations for Technology, Engineering, Business, and Health.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.4),
        ),
        const SizedBox(height: 14),
        _LabBanner(
          title: 'School of Technology and Computer Science Lab',
          subtitle:
              'Coding Arena → Northwind interview → job offer → office ticket.',
          colors: <Color>[
            VuV2Colors.orange,
            VuV2Colors.orangeDeep,
            VuV2Colors.navy,
          ],
          icon: Icons.rocket_launch_rounded,
          onEnter: openTechLab,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: openTechLab,
            style: FilledButton.styleFrom(
              backgroundColor: VuV2Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text(
              'Enter Technology Lab',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 22),
        _LabBanner(
          title: 'School of Engineering Lab',
          subtitle: 'Build it. Test it. Get hired. — MechWorks Factory playable now.',
          colors: <Color>[
            const Color(0xFF3B82F6),
            const Color(0xFF8B5CF6),
            VuV2Colors.navy,
          ],
          icon: Icons.precision_manufacturing_rounded,
          onEnter: openEngLab,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: openEngLab,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.precision_manufacturing_rounded),
            label: const Text(
              'Enter School of Engineering Lab',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 22),
        _LabBanner(
          title: 'School of Business & Economics',
          subtitle:
              'Corporate HQ · The Declining Company — strategy, budget, consequences.',
          colors: <Color>[
            const Color(0xFF10B981),
            const Color(0xFF3B82F6),
            VuV2Colors.navy,
          ],
          icon: Icons.apartment_rounded,
          onEnter: openBizLab,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: openBizLab,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.apartment_rounded),
            label: const Text(
              'Enter School of Business & Economics',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 22),
        _LabBanner(
          title: 'School of Health and Medicine',
          subtitle:
              'Medical Simulation Hub — hospital, anatomy, clinical cases, lab, skills.',
          colors: <Color>[
            const Color(0xFF38BDF8),
            const Color(0xFF8B5CF6),
            VuV2Colors.navy,
          ],
          icon: Icons.medical_services_rounded,
          onEnter: openHealthLab,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: openHealthLab,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.medical_services_rounded),
            label: const Text(
              'Enter Medical Simulation Hub',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 22),
        _LabBanner(
          title: 'Career & Life Skills — Budget Boss',
          subtitle:
              'Personal finance game lab — needs vs wants, fees, paychecks, credit, crisis.',
          colors: <Color>[
            const Color(0xFFA855F7),
            const Color(0xFF7C3AED),
            VuV2Colors.navy,
          ],
          icon: Icons.savings_rounded,
          onEnter: openBudgetBoss,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: openBudgetBoss,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFA855F7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.savings_rounded),
            label: const Text(
              'Enter Budget Boss',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 22),
        _LabBanner(
          title: 'GradeGlow Life — Virtual Life Simulation',
          subtitle:
              'Explore the city, get a degree, interview, work as a nurse, doctor, lawyer, engineer, accountant or manager.',
          colors: <Color>[
            const Color(0xFF14B8A6),
            const Color(0xFF3B82F6),
            VuV2Colors.navy,
          ],
          icon: Icons.location_city_rounded,
          onEnter: openLifeSim,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: openLifeSim,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.location_city_rounded),
            label: const Text(
              'Enter GradeGlow Life',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _LoopStrip(),
      ],
    );
  }
}

String _scienceMajorId(String? majorId) {
  final String id = (majorId ?? '').toLowerCase();
  if (id.contains('software')) return 'software_engineering';
  if (id.contains('cyber')) return 'cybersecurity';
  if (id.contains('data')) return 'data_science';
  if (id.contains('ai') || id.contains('machine')) return 'ai_ml';
  if (id.contains('web')) return 'web_development';
  if (id.contains('mobile')) return 'mobile_development';
  if (id.contains('information') || id.contains('it')) {
    return 'information_technology';
  }
  if (id.contains('computer') || id.contains('cs')) return 'computer_science';
  return 'software_engineering';
}

String _engineeringMajorId(String? majorId) {
  final String id = (majorId ?? '').toLowerCase();
  if (id.contains('civil')) return 'civil_engineering';
  if (id.contains('electrical') || id.contains('ee')) {
    return 'electrical_engineering';
  }
  if (id.contains('chemical') || id.contains('chem')) {
    return 'chemical_engineering';
  }
  if (id.contains('aero') || id.contains('aerospace')) {
    return 'aerospace_engineering';
  }
  if (id.contains('industrial') || id.contains('ie')) {
    return 'industrial_engineering';
  }
  if (id.contains('mechanical') || id.contains('mech')) {
    return 'mechanical_engineering';
  }
  return 'mechanical_engineering';
}

class _LabBanner extends StatelessWidget {
  const _LabBanner({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.icon,
    required this.onEnter,
  });

  final String title;
  final String subtitle;
  final List<Color> colors;
  final IconData icon;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEnter,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            border: Border.all(color: colors.first.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoopStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<String> steps = <String>[
      'Design',
      'Simulate',
      'Interview',
      'Job',
      'XP',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: VuV2Colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VuV2Colors.stroke),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < steps.length; i++) ...<Widget>[
            if (i > 0)
              Icon(Icons.arrow_forward_rounded, size: 12, color: VuV2Colors.mute),
            Expanded(
              child: Text(
                steps[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: VuV2Colors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
