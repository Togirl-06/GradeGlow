import 'package:flutter/material.dart';

import '../shared/playable_cinematic.dart';

/// Live ward assignment board — acuity pulses, charts, priority call.
class NursingLab1ShiftScreen extends StatefulWidget {
  const NursingLab1ShiftScreen({super.key});

  @override
  State<NursingLab1ShiftScreen> createState() => _NursingLab1ShiftScreenState();
}

class _NursingLab1ShiftScreenState extends State<NursingLab1ShiftScreen>
    with SingleTickerProviderStateMixin {
  static const Color _accent = Color(0xFF2DD4A8);
  static const Color _bg = Color(0xFF061412);
  static const Color _surface = Color(0xFF0F2420);
  static const String _correctFirst = '103';

  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);

  String? _pickedFirst;
  bool _gotFeedback = false;
  String? _openChart;
  final Set<String> _reviewed = <String>{};

  static const List<_PatientCard> _patients = <_PatientCard>[
    _PatientCard(
      room: '101',
      name: 'Ellis Park',
      acuity: 'Stable',
      level: 1,
      vitals: 'HR 78 · SpO₂ 98%',
      summary: 'Post-procedure recovery. Sleeping.',
      chart:
          'Age 54 · Lap chole yesterday. Pain 2/10. SpO2 98% RA. '
          'Orders: ambulate with assist, clear liquids.',
    ),
    _PatientCard(
      room: '102',
      name: 'Maya Ortiz',
      acuity: 'Routine',
      level: 2,
      vitals: 'HR 88 · FSBS due',
      summary: 'Type 2 DM. Morning glucose due.',
      chart:
          'Age 61 · FSBS qAC & HS. Last FSBS 142. Metformin held NPO overnight. '
          'No acute complaints.',
    ),
    _PatientCard(
      room: '103',
      name: 'Jordan Lee',
      acuity: 'HIGH',
      level: 4,
      vitals: 'SpO₂ 88% · sitting forward',
      summary: 'Shortness of breath. Anxious. Needs you now.',
      chart:
          'Age 68 · COPD/CHF hx. Night SpO2 dipped to 88% on 2L. '
          'Now reporting "I don\'t feel right." Needs immediate assessment.',
    ),
    _PatientCard(
      room: '104',
      name: 'Sam Rivera',
      acuity: 'Stable',
      level: 1,
      vitals: 'Pain 3/10 · PCA',
      summary: 'Post-op day 1. Pain controlled.',
      chart:
          'Age 45 · ORIF ankle. Dressing dry. Pain 3/10. '
          'PT later today. Call light within reach.',
    ),
  ];

  bool get _canFinish =>
      _pickedFirst != null && _gotFeedback && _reviewed.length >= 4;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _confirmPriority() async {
    if (_pickedFirst == null) return;
    final bool correct = _pickedFirst == _correctFirst;
    await showPlayableCinematic(
      context: context,
      accent: _accent,
      bg: _bg,
      surface: _surface,
      eyebrow: 'Charge Nurse Diaz',
      title: correct ? 'Good call.' : 'Wrong first stop.',
      body: correct
          ? '“103 first. Respiratory changes don\'t wait for a neat schedule. '
              'Review every chart — then get in that room.”'
          : '“You picked Room $_pickedFirst. I would have started with 103 — '
              'airway and breathing trump a stable recovery. Lesson noted. '
              'Review the charts, then we move on.”',
      cta: 'BACK TO BOARD',
      glyph: '🧑‍⚕️',
    );
    if (!mounted) return;
    setState(() => _gotFeedback = true);
  }

  @override
  Widget build(BuildContext context) {
    final _PatientCard? open = _openChart == null
        ? null
        : _patients.firstWhere((_PatientCard p) => p.room == _openChart);

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PlayableSceneBackdrop(
            accent: _accent,
            bg: _bg,
            surface: _surface,
            roomId: 'ward_board',
            intensity: 0.9,
          ),
          SafeArea(
            child: open != null
                ? _ChartView(
                    patient: open,
                    accent: _accent,
                    onClose: () {
                      setState(() {
                        _reviewed.add(open.room);
                        _openChart = null;
                      });
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () => Navigator.pop(context, false),
                              icon: const Icon(Icons.close, color: Colors.white54),
                            ),
                            const Expanded(
                              child: Text(
                                'ASSIGNMENT BOARD',
                                style: TextStyle(
                                  color: _accent,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const PlayableLiveBadge(
                              accent: _accent,
                              label: '4 PATIENTS',
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                        child: Text(
                          'Who do you see first?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                        child: Text(
                          'Tap a room to open the chart. Then lock your first contact.\n'
                          'Reviewed ${_reviewed.length}/4 · '
                          '${_pickedFirst == null ? 'No priority set' : 'First: Room $_pickedFirst'}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            height: 1.4,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.92,
                          ),
                          itemCount: _patients.length,
                          itemBuilder: (BuildContext context, int i) {
                            final _PatientCard p = _patients[i];
                            final bool selected = _pickedFirst == p.room;
                            final bool reviewed = _reviewed.contains(p.room);
                            return AnimatedBuilder(
                              animation: _pulse,
                              builder: (BuildContext context, _) {
                                return _WardTile(
                                  patient: p,
                                  accent: _accent,
                                  selected: selected,
                                  reviewed: reviewed,
                                  pulse: p.level >= 4 ? _pulse.value : 0,
                                  onOpen: () => setState(() => _openChart = p.room),
                                  onSelect: () =>
                                      setState(() => _pickedFirst = p.room),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: <Widget>[
                            if (!_gotFeedback)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed:
                                      _pickedFirst == null ? null : _confirmPriority,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _accent,
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor: Colors.white12,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text(
                                    'LOCK FIRST CONTACT',
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _canFinish
                                      ? () => Navigator.pop(context, true)
                                      : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _accent,
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor: Colors.white12,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(
                                    _canFinish
                                        ? 'START THE SHIFT'
                                        : 'REVIEW ALL CHARTS (${_reviewed.length}/4)',
                                    style: const TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _WardTile extends StatelessWidget {
  const _WardTile({
    required this.patient,
    required this.accent,
    required this.selected,
    required this.reviewed,
    required this.pulse,
    required this.onOpen,
    required this.onSelect,
  });

  final _PatientCard patient;
  final Color accent;
  final bool selected;
  final bool reviewed;
  final double pulse;
  final VoidCallback onOpen;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final bool hot = patient.level >= 4;
    final Color border = selected
        ? accent
        : hot
            ? Color.lerp(const Color(0xFFEF4444), accent, pulse)!
            : Colors.white12;

    return Material(
      color: const Color(0xFF0A1C18),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        onLongPress: onSelect,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: hot || selected ? 2 : 1),
            boxShadow: hot
                ? <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2 + pulse * 0.25),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'RM ${patient.room}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: hot
                          ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                          : accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      patient.acuity,
                      style: TextStyle(
                        color: hot ? const Color(0xFFFCA5A5) : accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                patient.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                patient.vitals,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const Spacer(),
              Text(
                patient.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Text(
                    reviewed ? 'Chart ✓' : 'Open chart',
                    style: TextStyle(
                      color: reviewed ? accent : Colors.white54,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onSelect,
                    child: Text(
                      selected ? 'FIRST' : 'Set 1st',
                      style: TextStyle(
                        color: selected ? accent : Colors.white38,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartView extends StatelessWidget {
  const _ChartView({
    required this.patient,
    required this.accent,
    required this.onClose,
  });

  final _PatientCard patient;
  final Color accent;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
              ),
              Expanded(
                child: Text(
                  'ROOM ${patient.room} · CHART',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          Text(
            patient.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            patient.vitals,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  patient.chart,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.55,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onClose,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'MARK CHART REVIEWED',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientCard {
  const _PatientCard({
    required this.room,
    required this.name,
    required this.acuity,
    required this.level,
    required this.vitals,
    required this.summary,
    required this.chart,
  });

  final String room;
  final String name;
  final String acuity;
  final int level;
  final String vitals;
  final String summary;
  final String chart;
}
