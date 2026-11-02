import 'package:flutter/material.dart';

import '../data/virtual_hospital_data.dart';
import '../data/visual_learning_catalog.dart';
import '../models/ai_practice_mode.dart';
import '../models/hospital_room.dart';
import '../models/practice_lab.dart';
import '../models/practice_lab_subject.dart';
import '../models/visual_learning_lab.dart';
import '../theme/practice_lab_game_theme.dart';
import 'er_simulation_screen.dart';
import 'practice_lab_session_screen.dart';

/// Walk through hospital wings — ER, ICU, OR, and more.
class VirtualHospitalHubScreen extends StatelessWidget {
  const VirtualHospitalHubScreen({
    super.key,
    required this.subject,
    required this.category,
    required this.lab,
    required this.activity,
    required this.difficulty,
    required this.teachingHospital,
  });

  final PracticeLabSubject subject;
  final PracticeLabCategory category;
  final PracticeLabType lab;
  final VisualLabActivity activity;
  final PracticeDifficulty difficulty;
  final bool teachingHospital;

  @override
  Widget build(BuildContext context) {
    final VisualLabEnvironmentConfig env = VisualLearningCatalog.configForSubject(subject.id);
    final List<HospitalRoom> rooms = VirtualHospitalData.roomsFor(teachingHospital: teachingHospital);

    return Scaffold(
      backgroundColor: PracticeLabGameTheme.background(context),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(env.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            Text(activity.title, style: TextStyle(fontSize: 11, color: PracticeLabGameTheme.textSecondary(context))),
          ],
        ),
        backgroundColor: PracticeLabGameTheme.background(context),
        foregroundColor: PracticeLabGameTheme.textPrimary(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: env.gradient),
            ),
            child: Text(
              teachingHospital
                  ? 'Walk the teaching hospital — AI doctors, nurses, and patients interact in real time. Patient conditions change during your shift.'
                  : 'Enter the AI hospital. Assess patients, administer care, and practice clinical decision-making.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.92), height: 1.4, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 20),
          Text('SELECT A WING', style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6)),
          const SizedBox(height: 12),
          ...rooms.map((HospitalRoom room) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: PracticeLabGameTheme.surface(context),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _enterRoom(context, room),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: room.accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(room.icon, color: room.accent, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(room.name, style: TextStyle(color: PracticeLabGameTheme.textPrimary(context), fontWeight: FontWeight.w800, fontSize: 16)),
                              Text(room.description, style: TextStyle(color: PracticeLabGameTheme.textSecondary(context), fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded, color: room.accent),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _enterRoom(BuildContext context, HospitalRoom room) {
    final String erLabId = switch (room.id) {
      'trauma' => 'er_trauma',
      'er' => 'er_stroke',
      'icu' => 'er_diabetic',
      _ => 'er_chest_pain',
    };
    final PracticeLabType roomLab = PracticeLabType(
      id: room.id == 'er' || room.id == 'trauma' || room.id == 'icu'
          ? erLabId
          : '${lab.id}_${room.id}',
      title: '${room.name} — ${activity.title}',
      subtitle: '${room.description} · ${difficulty.label}',
      style: SimulationStyle.erEmergency,
      timed: true,
      aiRole: 'Patient',
      studentTasks: const <String>[
        'Assess the patient',
        'Order interventions',
        'Communicate with the care team',
      ],
      evaluationCriteria: const <String>[
        'Accuracy',
        'Speed',
        'Critical Thinking',
        'Communication',
        'Clinical Decision Making',
      ],
      difficulty: difficulty.label,
    );

    if (room.id == 'er' || room.id == 'trauma' || room.id == 'icu') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ErSimulationScreen(category: category, lab: roomLab),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticeLabSessionScreen(
          category: category,
          lab: roomLab,
          courseName: envTitle(subject.id),
          topicAreaName: room.name,
          topicName: '${room.name} clinical scenario',
        ),
      ),
    );
  }

  String envTitle(String subjectId) => VisualLearningCatalog.configForSubject(subject.id).title;
}
