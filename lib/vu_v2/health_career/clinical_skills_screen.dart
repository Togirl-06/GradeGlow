import 'package:flutter/material.dart';

import 'health_career_progress.dart';
import 'health_career_theme.dart';
import 'models/clinical_scenario.dart';
import 'models/patient_profile.dart';

/// Practice measuring each instrument against Maria's vitals.
class ClinicalSkillsScreen extends StatefulWidget {
  const ClinicalSkillsScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  @override
  State<ClinicalSkillsScreen> createState() => _ClinicalSkillsScreenState();
}

class _ClinicalSkillsScreenState extends State<ClinicalSkillsScreen> {
  static final PatientProfile _patient = PatientCatalog.mariaLopez;
  static const ClinicalScenario _scenario = ClinicalScenarioCatalog.dyspneaWard;

  final Set<ClinicalInstrument> _completed = <ClinicalInstrument>{};
  ClinicalInstrument? _active;
  String? _reading;
  bool _awarded = false;

  @override
  void initState() {
    super.initState();
    _awarded = widget.progress.completedSkills.contains('vitals_kit');
    if (_awarded) {
      _completed.addAll(ClinicalInstrument.values);
    }
  }

  String _label(ClinicalInstrument i) {
    switch (i) {
      case ClinicalInstrument.stethoscope:
        return 'Stethoscope';
      case ClinicalInstrument.thermometer:
        return 'Thermometer';
      case ClinicalInstrument.bpCuff:
        return 'BP cuff';
      case ClinicalInstrument.pulseOx:
        return 'Pulse ox';
    }
  }

  IconData _icon(ClinicalInstrument i) {
    switch (i) {
      case ClinicalInstrument.stethoscope:
        return Icons.hearing_rounded;
      case ClinicalInstrument.thermometer:
        return Icons.thermostat_rounded;
      case ClinicalInstrument.bpCuff:
        return Icons.monitor_heart_rounded;
      case ClinicalInstrument.pulseOx:
        return Icons.favorite_rounded;
    }
  }

  String _expectedReading(ClinicalInstrument i) {
    final InstrumentFinding? f = _scenario.findingFor(i);
    if (f != null) return f.summary;
    final PatientVitals v = _patient.vitals;
    switch (i) {
      case ClinicalInstrument.stethoscope:
        return 'HR ${v.hr} · RR ${v.rr}';
      case ClinicalInstrument.thermometer:
        return v.tempLabel;
      case ClinicalInstrument.bpCuff:
        return v.bpLabel;
      case ClinicalInstrument.pulseOx:
        return 'SpO₂ ${v.spo2}%';
    }
  }

  Future<void> _practice(ClinicalInstrument i) async {
    setState(() {
      _active = i;
      _reading = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _reading = _expectedReading(i);
      _completed.add(i);
    });
    if (_completed.length == ClinicalInstrument.values.length && !_awarded) {
      _awarded = true;
      await widget.progress.completeSkill('vitals_kit');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vitals kit skill complete — XP awarded'),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool allDone =
        _completed.length == ClinicalInstrument.values.length;

    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'Clinical Skills',
        icon: Icons.medical_services_rounded,
      ),
      body: MedStarfield(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: MedCosmic.panelBox(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: _patient.skinTone,
                          child: Text(
                            _patient.displayName[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Practice vitals on ${_patient.displayName}',
                            style: const TextStyle(
                              color: MedCosmic.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        MedCosmic.pill(
                          '${_completed.length}/4',
                          bg: allDone
                              ? MedCosmic.success.withValues(alpha: 0.2)
                              : MedCosmic.clinical.withValues(alpha: 0.2),
                          fg: allDone
                              ? MedCosmic.success
                              : MedCosmic.clinical,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Use each instrument once. Readings match her ward '
                      'scenario vitals (educational only).',
                      style: TextStyle(
                        color: MedCosmic.mute,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...ClinicalInstrument.values.map((ClinicalInstrument i) {
                final bool done = _completed.contains(i);
                final bool measuring = _active == i && _reading == null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: measuring ? null : () => _practice(i),
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: done
                              ? MedCosmic.teal.withValues(alpha: 0.12)
                              : MedCosmic.panel,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: done ? MedCosmic.teal : MedCosmic.stroke,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.08),
                              child: Icon(
                                _icon(i),
                                color: done
                                    ? MedCosmic.teal
                                    : MedCosmic.clinical,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _label(i),
                                    style: const TextStyle(
                                      color: MedCosmic.ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    measuring
                                        ? 'Measuring…'
                                        : done
                                            ? _expectedReading(i)
                                            : 'Tap to measure',
                                    style: TextStyle(
                                      color: measuring
                                          ? MedCosmic.clinical
                                          : MedCosmic.mute,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (done)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: MedCosmic.success,
                              )
                            else
                              const Icon(
                                Icons.touch_app_rounded,
                                color: MedCosmic.mute,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              if (_active != null && _reading != null) ...<Widget>[
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: MedCosmic.panelBox(color: MedCosmic.panelAlt),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Last reading · ${_label(_active!)}',
                        style: const TextStyle(
                          color: MedCosmic.mute,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _reading!,
                        style: const TextStyle(
                          color: MedCosmic.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (allDone) ...<Widget>[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: MedCosmic.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: MedCosmic.success.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    children: <Widget>[
                      Icon(Icons.emoji_events_rounded, color: MedCosmic.gold),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Skill complete: vitals_kit',
                          style: TextStyle(
                            color: MedCosmic.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
