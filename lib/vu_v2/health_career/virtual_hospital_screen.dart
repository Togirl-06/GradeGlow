import 'package:flutter/material.dart';

import '../game/ui/nursing_clinical_game_screen.dart';
import 'health_career_progress.dart';
import 'health_career_theme.dart';
import 'hospital_ward_screen.dart';
import 'medicine_consultation_screen.dart';
import 'nursing_clinical_case_screen.dart';

/// Hospital entrance — primary path is the live ward + bedside treatment.
class VirtualHospitalScreen extends StatelessWidget {
  const VirtualHospitalScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  Future<void> _openWard(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HospitalWardScreen(progress: progress),
      ),
    );
  }

  Future<void> _openNursingCase(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => NursingClinicalCaseScreen(progress: progress),
      ),
    );
  }

  Future<void> _openMedicineConsult(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MedicineConsultationScreen(progress: progress),
      ),
    );
  }

  Future<void> _openWalkable(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const NursingClinicalGameScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'Virtual Hospital',
        icon: Icons.apartment_rounded,
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFF14304A),
                      Color(0xFF0F1A2E),
                      Color(0xFF1E1538),
                    ],
                  ),
                  border: Border.all(color: MedCosmic.stroke),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MedCosmic.pill(
                      'Live clinical floor',
                      bg: MedCosmic.clinical.withValues(alpha: 0.22),
                      fg: MedCosmic.clinical,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Treat real ward patients',
                      style: TextStyle(
                        color: MedCosmic.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Walk the nurse station, pick a bed, take history and vitals, '
                      'then intervene while the bedside monitor updates.',
                      style: TextStyle(
                        color: MedCosmic.mute,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openWard(context),
                        icon: const Icon(Icons.local_hospital_rounded),
                        label: const Text('Enter hospital ward'),
                        style: FilledButton.styleFrom(
                          backgroundColor: MedCosmic.clinical,
                          foregroundColor: MedCosmic.bgDeep,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Also available',
                style: TextStyle(
                  color: MedCosmic.mute,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              _AltTile(
                icon: Icons.hotel_rounded,
                title: 'Maria Lopez — nursing case worksheet',
                sub: 'Structured dyspnea checklist (alternate path)',
                onTap: () => _openNursingCase(context),
              ),
              _AltTile(
                icon: Icons.medical_services_rounded,
                title: 'Jamal Reed — medicine consult pathway',
                sub: 'GERD vs ACS workup (clinic-style)',
                onTap: () => _openMedicineConsult(context),
              ),
              _AltTile(
                icon: Icons.map_rounded,
                title: 'Walkable clinical floor',
                sub: 'Isometric nursing floor practice',
                onTap: () => _openWalkable(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AltTile extends StatelessWidget {
  const _AltTile({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: MedCosmic.panelBox(radius: 14),
            child: Row(
              children: <Widget>[
                Icon(icon, color: MedCosmic.electric),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          color: MedCosmic.ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: const TextStyle(
                          color: MedCosmic.mute,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: MedCosmic.mute),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
