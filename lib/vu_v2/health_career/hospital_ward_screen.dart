import 'package:flutter/material.dart';

import 'bedside_treatment_screen.dart';
import 'health_career_progress.dart';
import 'health_career_theme.dart';
import 'models/hospital_case.dart';
import 'models/patient_profile.dart';

/// Live hospital floor — pick a bed and treat the patient in real time.
class HospitalWardScreen extends StatelessWidget {
  const HospitalWardScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  Future<void> _openBed(BuildContext context, HospitalBed bed) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BedsideTreatmentScreen(
          progress: progress,
          bed: bed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<HospitalBed> beds = HospitalWardCatalog.beds;
    final bool wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'GradeGlow General Hospital',
        icon: Icons.local_hospital_rounded,
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: <Widget>[
              _NurseStationBanner(
                census: beds.length,
                critical: beds.where((HospitalBed b) => b.acuity == 'Critical').length,
                urgent: beds.where((HospitalBed b) => b.acuity == 'Urgent').length,
              ),
              const SizedBox(height: 16),
              const Text(
                'Active beds',
                style: TextStyle(
                  color: MedCosmic.mute,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 10),
              if (wide)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: beds
                      .map(
                        (HospitalBed b) => SizedBox(
                          width: (MediaQuery.sizeOf(context).width - 56) / 2,
                          child: _BedCard(
                            bed: b,
                            done: progress.completedScenarios.contains(b.caseId),
                            score: progress.scenarioScores[b.caseId],
                            onTap: () => _openBed(context, b),
                          ),
                        ),
                      )
                      .toList(),
                )
              else
                ...beds.map(
                  (HospitalBed b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BedCard(
                      bed: b,
                      done: progress.completedScenarios.contains(b.caseId),
                      score: progress.scenarioScores[b.caseId],
                      onTap: () => _openBed(context, b),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: MedCosmic.panelBox(),
                child: const Text(
                  'Treat patients at the bedside: take history, measure vitals, '
                  'intervene, and watch the monitor respond. Educational simulation — '
                  'not a substitute for supervised clinical practice.',
                  style: TextStyle(color: MedCosmic.mute, height: 1.4, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NurseStationBanner extends StatelessWidget {
  const _NurseStationBanner({
    required this.census,
    required this.critical,
    required this.urgent,
  });

  final int census;
  final int critical;
  final int urgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF152238),
            Color(0xFF0F1A2E),
            Color(0xFF1A1040),
          ],
        ),
        border: Border.all(color: MedCosmic.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: MedCosmic.clinical.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.desk_rounded, color: MedCosmic.clinical),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Nurse station · Day shift',
                      style: TextStyle(
                        color: MedCosmic.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Select a bed to begin bedside treatment',
                      style: TextStyle(color: MedCosmic.mute, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _Stat('Census', '$census'),
              _Stat('Critical', '$critical', color: MedCosmic.danger),
              _Stat('Urgent', '$urgent', color: MedCosmic.warning),
              _Stat('Shift', '07:00'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(color: MedCosmic.mute, fontSize: 10)),
          Text(
            value,
            style: TextStyle(
              color: color ?? MedCosmic.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _BedCard extends StatelessWidget {
  const _BedCard({
    required this.bed,
    required this.done,
    required this.onTap,
    this.score,
  });

  final HospitalBed bed;
  final bool done;
  final int? score;
  final VoidCallback onTap;

  Color get _acuity {
    switch (bed.acuity) {
      case 'Critical':
        return MedCosmic.danger;
      case 'Urgent':
        return MedCosmic.warning;
      case 'Watch':
        return MedCosmic.gold;
      default:
        return MedCosmic.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final PatientProfile p = bed.patient;
    final PatientVitals v = p.vitals;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: MedCosmic.panelBox(radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: _acuity, width: 4),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: p.skinTone,
                      child: Text(
                        p.displayName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Room ${bed.roomId} · ${bed.bayLabel}',
                            style: const TextStyle(
                              color: MedCosmic.mute,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            p.displayName,
                            style: const TextStyle(
                              color: MedCosmic.ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${p.ageYears} · ${p.sexLabel} · ${bed.unit}',
                            style: const TextStyle(
                              color: MedCosmic.mute,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MedCosmic.pill(
                      bed.acuity,
                      bg: _acuity.withValues(alpha: 0.2),
                      fg: _acuity,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Text(
                  p.chiefComplaint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MedCosmic.mute,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    _VitalChip('HR', '${v.hr}', v.hr > 100),
                    _VitalChip('BP', v.bpLabel, v.systolic >= 140 || v.systolic < 100),
                    _VitalChip('SpO₂', '${v.spo2}%', v.spo2 < 94),
                    _VitalChip('Temp', v.tempLabel, v.tempC >= 38),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: MedCosmic.stroke)),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      done ? Icons.check_circle : Icons.medical_services_outlined,
                      size: 16,
                      color: done ? MedCosmic.success : MedCosmic.clinical,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        done
                            ? 'Treated · score ${score ?? "—"}'
                            : 'Enter room · treat at bedside',
                        style: TextStyle(
                          color: done ? MedCosmic.success : MedCosmic.clinical,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: MedCosmic.mute),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VitalChip extends StatelessWidget {
  const _VitalChip(this.k, this.v, this.abn);
  final String k;
  final String v;
  final bool abn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: abn
            ? MedCosmic.danger.withValues(alpha: 0.15)
            : MedCosmic.panelAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: abn ? MedCosmic.danger.withValues(alpha: 0.45) : MedCosmic.stroke,
        ),
      ),
      child: Text(
        '$k $v',
        style: TextStyle(
          color: abn ? MedCosmic.danger : MedCosmic.ink,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
