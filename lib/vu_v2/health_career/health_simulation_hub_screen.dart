import 'package:flutter/material.dart';

import 'anatomy_viewer_screen.dart';
import 'clinical_skills_screen.dart';
import 'health_career_content.dart';
import 'health_career_progress.dart';
import 'health_career_theme.dart';
import 'healthcare_management_screen.dart';
import 'medical_lab_screen.dart';
import 'medicine_consultation_screen.dart';
import 'nursing_clinical_case_screen.dart';
import 'nutrition_clinic_screen.dart';
import 'performance_screen.dart';
import 'pharmacy_sim_screen.dart';
import 'public_health_sim_screen.dart';
import 'virtual_hospital_screen.dart';

/// School of Health and Medicine — Medical Simulation Hub.
class HealthSimulationHubScreen extends StatefulWidget {
  const HealthSimulationHubScreen({
    super.key,
    this.initialCourseId,
    this.playerName,
  });

  final String? initialCourseId;
  final String? playerName;

  @override
  State<HealthSimulationHubScreen> createState() =>
      _HealthSimulationHubScreenState();
}

class _HealthSimulationHubScreenState extends State<HealthSimulationHubScreen> {
  final HealthCareerProgress _progress = HealthCareerProgress.instance;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _progress.ensureLoaded();
    if (widget.initialCourseId != null) {
      await _progress.setCourse(widget.initialCourseId!);
    }
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => screen,
        transitionsBuilder: (_, Animation<double> a, _, Widget child) {
          return FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: MedCosmic.bg,
        body: Center(
          child: CircularProgressIndicator(color: MedCosmic.clinical),
        ),
      );
    }

    final HealthProgram program = _progress.program;
    final String name =
        (widget.playerName ?? 'Student').trim().split(' ').first;
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: MedCosmic.bg,
      body: MedStarfield(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _progress,
            builder: (BuildContext context, _) {
              return Column(
                children: <Widget>[
                  _TopHud(
                    name: name,
                    initial: initial,
                    level: _progress.level,
                    xp: _progress.xpIntoLevel,
                    xpMax: _progress.xpToNextLevel,
                    courseTitle: program.title,
                    courseAccent: program.accent,
                  ),
                  Expanded(
                    child: _Destinations(
                      courseId: _progress.courseId,
                      onHospital: () => _open(
                        VirtualHospitalScreen(progress: _progress),
                      ),
                      onAnatomy: () => _open(
                        AnatomyViewerScreen(progress: _progress),
                      ),
                      onCase: () {
                        final String c = _progress.courseId;
                        if (c == 'medicine') {
                          _open(MedicineConsultationScreen(progress: _progress));
                        } else if (c == 'public_health') {
                          _open(PublicHealthSimScreen(progress: _progress));
                        } else if (c == 'nutrition') {
                          _open(NutritionClinicScreen(progress: _progress));
                        } else if (c == 'pharmacy_fundamentals') {
                          _open(PharmacySimScreen(progress: _progress));
                        } else if (c == 'healthcare_management') {
                          _open(HealthcareManagementScreen(progress: _progress));
                        } else if (c == 'medical_lab_science') {
                          _open(MedicalLabScreen(progress: _progress));
                        } else if (c == 'anatomy_physiology') {
                          _open(AnatomyViewerScreen(progress: _progress));
                        } else {
                          _open(NursingClinicalCaseScreen(progress: _progress));
                        }
                      },
                      onMedicine: () => _open(
                        MedicineConsultationScreen(progress: _progress),
                      ),
                      onPublicHealth: () => _open(
                        PublicHealthSimScreen(progress: _progress),
                      ),
                      onNutrition: () => _open(
                        NutritionClinicScreen(progress: _progress),
                      ),
                      onPharmacy: () => _open(
                        PharmacySimScreen(progress: _progress),
                      ),
                      onManagement: () => _open(
                        HealthcareManagementScreen(progress: _progress),
                      ),
                      onLab: () => _open(
                        MedicalLabScreen(progress: _progress),
                      ),
                      onSkills: () => _open(
                        ClinicalSkillsScreen(progress: _progress),
                      ),
                      onPerformance: () => _open(
                        PerformanceScreen(progress: _progress),
                      ),
                    ),
                  ),
                  _BottomHud(
                    program: program,
                    progress: _progress,
                    onCourseChanged: (String id) async {
                      await _progress.setCourse(id);
                      setState(() {});
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  const _TopHud({
    required this.name,
    required this.initial,
    required this.level,
    required this.xp,
    required this.xpMax,
    required this.courseTitle,
    required this.courseAccent,
  });

  final String name;
  final String initial;
  final int level;
  final int xp;
  final int xpMax;
  final String courseTitle;
  final Color courseAccent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 4),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: MedCosmic.mute,
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: MedCosmic.purple,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    color: MedCosmic.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Level $level · Medical Simulation',
                  style: const TextStyle(
                    color: MedCosmic.mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (xp / xpMax).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: MedCosmic.stroke,
                    color: MedCosmic.clinical,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$xp / $xpMax XP',
                  style: const TextStyle(color: MedCosmic.mute, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          MedCosmic.pill(
            courseTitle,
            bg: courseAccent.withValues(alpha: 0.22),
            fg: courseAccent,
            icon: Icons.school_rounded,
          ),
        ],
      ),
    );
  }
}

class _Destinations extends StatelessWidget {
  const _Destinations({
    required this.courseId,
    required this.onHospital,
    required this.onAnatomy,
    required this.onCase,
    required this.onMedicine,
    required this.onPublicHealth,
    required this.onNutrition,
    required this.onPharmacy,
    required this.onManagement,
    required this.onLab,
    required this.onSkills,
    required this.onPerformance,
  });

  final String courseId;
  final VoidCallback onHospital;
  final VoidCallback onAnatomy;
  final VoidCallback onCase;
  final VoidCallback onMedicine;
  final VoidCallback onPublicHealth;
  final VoidCallback onNutrition;
  final VoidCallback onPharmacy;
  final VoidCallback onManagement;
  final VoidCallback onLab;
  final VoidCallback onSkills;
  final VoidCallback onPerformance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        const Text(
          'Medical Simulation Hub',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MedCosmic.ink,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ward · specialty sims · lab · skills',
          style: TextStyle(
            color: MedCosmic.mute.withValues(alpha: 0.95),
            fontSize: 13,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: <Widget>[
              _DestTile(
                color: MedCosmic.clinical,
                label: '1. Enter Virtual Hospital',
                sub: 'Live ward — treat patients at the bedside',
                icon: Icons.apartment_rounded,
                glow: true,
                onTap: onHospital,
              ),
              _DestTile(
                color: MedCosmic.purple,
                label: '2. Explore Human Anatomy',
                sub: 'Identify structures in the anatomy lab',
                icon: Icons.accessibility_new_rounded,
                onTap: onAnatomy,
              ),
              _DestTile(
                color: const Color(0xFF1E3A5F),
                label: '3. Nursing Clinical Case',
                sub: 'Acute dyspnea ward scenario',
                icon: Icons.local_hospital_rounded,
                glow: courseId == 'nursing',
                onTap: onCase,
              ),
              _DestTile(
                color: MedCosmic.electric,
                label: '4. Medicine Consultation',
                sub: 'Jamal Reed — GERD vs ACS pathway',
                icon: Icons.medical_services_rounded,
                glow: courseId == 'medicine',
                onTap: onMedicine,
              ),
              _DestTile(
                color: MedCosmic.teal,
                label: '5. Public Health Outbreak',
                sub: 'Budget allocation · deterministic engine',
                icon: Icons.public_rounded,
                glow: courseId == 'public_health',
                onTap: onPublicHealth,
              ),
              _DestTile(
                color: MedCosmic.success,
                label: '6. Nutrition Clinic',
                sub: 'Food diary · educational meal plan',
                icon: Icons.restaurant_rounded,
                glow: courseId == 'nutrition',
                onTap: onNutrition,
              ),
              _DestTile(
                color: MedCosmic.warning,
                label: '7. Pharmacy Dispense',
                sub: 'Dosing · interactions · allergy gate',
                icon: Icons.local_pharmacy_rounded,
                glow: courseId == 'pharmacy_fundamentals',
                onTap: onPharmacy,
              ),
              _DestTile(
                color: MedCosmic.gold,
                label: '8. Healthcare Management',
                sub: 'Hospital day ops · beds · ED · quality',
                icon: Icons.apartment_rounded,
                glow: courseId == 'healthcare_management',
                onTap: onManagement,
              ),
              _DestTile(
                color: const Color(0xFF0891B2),
                label: '9. Medical Laboratory',
                sub: 'CBC + urinalysis · critical-value reporting',
                icon: Icons.biotech_rounded,
                glow: courseId == 'medical_lab_science',
                onTap: onLab,
              ),
              _DestTile(
                color: const Color(0xFF4C1D95),
                label: '10. Practice Clinical Skills',
                sub: 'Vitals kit on Maria Lopez',
                icon: Icons.monitor_heart_rounded,
                onTap: onSkills,
              ),
              _DestTile(
                color: const Color(0xFF7C3AED),
                label: '11. Review My Performance',
                sub: 'XP, badges, and recommended next',
                icon: Icons.insights_rounded,
                onTap: onPerformance,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DestTile extends StatelessWidget {
  const _DestTile({
    required this.color,
    required this.label,
    required this.sub,
    required this.icon,
    required this.onTap,
    this.glow = false,
  });

  final Color color;
  final String label;
  final String sub;
  final IconData icon;
  final VoidCallback onTap;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  color.withValues(alpha: 0.95),
                  color.withValues(alpha: 0.45),
                  MedCosmic.bgDeep.withValues(alpha: 0.92),
                ],
              ),
              border: Border.all(
                color: glow
                    ? MedCosmic.electric
                    : Colors.white.withValues(alpha: 0.16),
                width: glow ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomHud extends StatelessWidget {
  const _BottomHud({
    required this.program,
    required this.progress,
    required this.onCourseChanged,
  });

  final HealthProgram program;
  final HealthCareerProgress progress;
  final ValueChanged<String> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: MedCosmic.panelBox(radius: 20),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final bool stack = c.maxWidth < 560;

          final Widget courseDrop = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Your course',
                style: TextStyle(color: MedCosmic.mute, fontSize: 11),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: progress.courseId,
                  isExpanded: true,
                  dropdownColor: MedCosmic.panelAlt,
                  style: const TextStyle(
                    color: MedCosmic.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  items: HealthPrograms.all
                      .map(
                        (HealthProgram p) => DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(
                            p.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (String? id) {
                    if (id != null) onCourseChanged(id);
                  },
                ),
              ),
            ],
          );

          final Widget recommend = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Recommended next',
                style: TextStyle(color: MedCosmic.mute, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                progress.recommendedNext ?? 'Start a clinical case',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: MedCosmic.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          );

          final Widget sims = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: MedCosmic.panelAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Sims completed',
                  style: TextStyle(color: MedCosmic.mute, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  '${progress.simulationsCompleted}',
                  style: const TextStyle(
                    color: MedCosmic.clinical,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          );

          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                courseDrop,
                const SizedBox(height: 10),
                recommend,
                const SizedBox(height: 10),
                sims,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 3, child: courseDrop),
              const SizedBox(width: 12),
              Expanded(flex: 4, child: recommend),
              const SizedBox(width: 12),
              sims,
            ],
          );
        },
      ),
    );
  }
}
