import 'package:flutter/material.dart';

import '../models/practice_lab.dart';

/// Immersive venue archetype — each major field gets a distinct simulation world.
enum PracticeLabVenue {
  hospital,
  courtroom,
  scienceLab,
  workshop,
  boardroom,
  therapyRoom,
  classroom,
  general,
}

/// Visual + interaction config for immersive practice-lab scenes (per subject field).
class PracticeLabSceneConfig {
  const PracticeLabSceneConfig({
    required this.venue,
    required this.venueTitle,
    required this.tagline,
    required this.checklist,
    required this.actions,
    required this.panelTitle,
    required this.accent,
    required this.sceneColors,
    required this.sceneIcon,
  });

  final PracticeLabVenue venue;
  final String venueTitle;
  final String tagline;
  final List<String> checklist;
  final List<SceneAction> actions;
  final String panelTitle;
  final Color accent;
  final List<Color> sceneColors;
  final IconData sceneIcon;

  static PracticeLabSceneConfig forGroup(String? groupId) => forCategory(
        PracticeLabCategory(id: '', name: '', emoji: '', icon: Icons.hub, groupId: groupId, labs: const <PracticeLabType>[]),
        const PracticeLabType(id: '', title: '', subtitle: '', style: SimulationStyle.aiPatient),
      );

  static PracticeLabSceneConfig forCategory(PracticeLabCategory category, PracticeLabType lab) {
    final String groupId = category.groupId ?? 'general';
    final List<String> checklist = lab.studentTasks.isNotEmpty
        ? lab.studentTasks
        : _defaultChecklist(groupId);

    return switch (groupId) {
      'health_medical' => PracticeLabSceneConfig(
          venue: PracticeLabVenue.hospital,
          venueTitle: 'AI HOSPITAL',
          tagline: 'Treat live AI patients — assess, diagnose, intervene, and educate.',
          checklist: checklist,
          actions: const <SceneAction>[
            SceneAction('Ask Question', Icons.chat_bubble_outline_rounded, 'I need to ask the patient: '),
            SceneAction('Examine', Icons.monitor_heart_outlined, 'On physical examination: '),
            SceneAction('Order Test', Icons.biotech_outlined, 'I would like to order: '),
            SceneAction('Treat Patient', Icons.medical_services_outlined, 'My treatment plan is: ', primary: true),
          ],
          panelTitle: 'Patient Info',
          accent: const Color(0xFF22D3EE),
          sceneColors: <Color>[Color(0xFF0C4A6E), Color(0xFF164E63), Color(0xFF083344)],
          sceneIcon: Icons.local_hospital_rounded,
        ),
      'law_criminal_justice' => PracticeLabSceneConfig(
          venue: PracticeLabVenue.courtroom,
          venueTitle: 'AI COURTROOM',
          tagline: 'Argue live cases — question witnesses, present evidence, make objections.',
          checklist: checklist,
          actions: const <SceneAction>[
            SceneAction('Ask Question', Icons.chat_bubble_outline_rounded, 'Counsel, I ask the witness: '),
            SceneAction('Present Evidence', Icons.folder_open_outlined, 'Your Honor, I present into evidence: '),
            SceneAction('Objection', Icons.gavel_outlined, 'Objection! '),
            SceneAction('Make Argument', Icons.balance_outlined, 'Your Honor, my argument is: ', primary: true),
          ],
          panelTitle: 'Case Details',
          accent: const Color(0xFFA78BFA),
          sceneColors: <Color>[Color(0xFF3B0764), Color(0xFF4C1D95), Color(0xFF1E1B4B)],
          sceneIcon: Icons.gavel_rounded,
        ),
      'science' => PracticeLabSceneConfig(
          venue: PracticeLabVenue.scienceLab,
          venueTitle: 'AI SCIENCE LAB',
          tagline: 'Run live experiments — record data, analyze, and draw conclusions.',
          checklist: checklist,
          actions: const <SceneAction>[
            SceneAction('Instructions', Icons.menu_book_outlined, 'Reviewing the protocol: '),
            SceneAction('Record Data', Icons.edit_note_outlined, 'Recording observation: '),
            SceneAction('Analyze', Icons.analytics_outlined, 'My analysis shows: '),
            SceneAction('Conclusion', Icons.science_outlined, 'My conclusion is: ', primary: true),
          ],
          panelTitle: 'Lab Notebook',
          accent: const Color(0xFF34D399),
          sceneColors: <Color>[Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF022C22)],
          sceneIcon: Icons.science_rounded,
        ),
      'engineering' => PracticeLabSceneConfig(
          venue: PracticeLabVenue.workshop,
          venueTitle: 'AI WORKSHOP',
          tagline: 'Design, build, test, and optimize real engineering challenges.',
          checklist: checklist,
          actions: const <SceneAction>[
            SceneAction('View Blueprint', Icons.architecture_outlined, 'Looking at the blueprint: '),
            SceneAction('Run Simulation', Icons.precision_manufacturing_outlined, 'Running simulation: '),
            SceneAction('Test Design', Icons.build_circle_outlined, 'Testing the design: '),
            SceneAction('Improve', Icons.trending_up_rounded, 'To improve this design: ', primary: true),
          ],
          panelTitle: 'Project Brief',
          accent: const Color(0xFFFB923C),
          sceneColors: <Color>[Color(0xFF7C2D12), Color(0xFF9A3412), Color(0xFF431407)],
          sceneIcon: Icons.engineering_rounded,
        ),
      'business' => PracticeLabSceneConfig(
          venue: PracticeLabVenue.boardroom,
          venueTitle: 'AI BOARDROOM',
          tagline: 'Lead live strategy sessions — analyze, decide, and execute.',
          checklist: checklist,
          actions: const <SceneAction>[
            SceneAction('Analyze Market', Icons.insights_outlined, 'Market analysis: '),
            SceneAction('Financials', Icons.payments_outlined, 'Financial review: '),
            SceneAction('Team Input', Icons.groups_outlined, 'From the team perspective: '),
            SceneAction('Make Decision', Icons.how_to_vote_outlined, 'My decision is: ', primary: true),
          ],
          panelTitle: 'Scenario',
          accent: const Color(0xFF38BDF8),
          sceneColors: <Color>[Color(0xFF0C4A6E), Color(0xFF1E3A5F), Color(0xFF0F172A)],
          sceneIcon: Icons.business_center_rounded,
        ),
      'psychology_social_sciences' => PracticeLabSceneConfig(
          venue: PracticeLabVenue.therapyRoom,
          venueTitle: 'AI THERAPY ROOM',
          tagline: 'Work with live AI clients — assess, listen, analyze, and help.',
          checklist: checklist,
          actions: const <SceneAction>[
            SceneAction('Start Session', Icons.play_circle_outline_rounded, 'To begin our session: '),
            SceneAction('Ask Question', Icons.chat_bubble_outline_rounded, 'Can you tell me more about: '),
            SceneAction('Reflect', Icons.psychology_outlined, 'What I hear you saying is: '),
            SceneAction('Next Step', Icons.arrow_forward_rounded, 'A helpful next step could be: ', primary: true),
          ],
          panelTitle: 'Client Profile',
          accent: const Color(0xFFE879F9),
          sceneColors: <Color>[Color(0xFF701A75), Color(0xFF86198F), Color(0xFF3B0764)],
          sceneIcon: Icons.psychology_rounded,
        ),
      _ => PracticeLabSceneConfig(
          venue: PracticeLabVenue.general,
          venueTitle: 'AI PRACTICE LAB',
          tagline: 'Live AI characters. Real scenarios. Instant feedback.',
          checklist: checklist,
          actions: const <SceneAction>[
            SceneAction('Ask Question', Icons.chat_bubble_outline_rounded, 'I have a question: '),
            SceneAction('Give Instructions', Icons.assignment_outlined, 'My instructions are: '),
            SceneAction('Analyze', Icons.analytics_outlined, 'My analysis: '),
            SceneAction('Make Decision', Icons.touch_app_outlined, 'My decision is: ', primary: true),
          ],
          panelTitle: 'Scenario',
          accent: const Color(0xFF818CF8),
          sceneColors: <Color>[Color(0xFF312E81), Color(0xFF3730A3), Color(0xFF1E1B4B)],
          sceneIcon: Icons.hub_rounded,
        ),
    };
  }

  static List<String> _defaultChecklist(String groupId) {
    return switch (groupId) {
      'health_medical' => <String>['Assess', 'Diagnose', 'Treat', 'Educate'],
      'law_criminal_justice' => <String>['Argue Cases', 'Question Witnesses', 'Present Evidence', 'Win Justice'],
      'science' => <String>['Run Experiments', 'Analyze Results', 'Draw Conclusions', 'Think Like a Scientist'],
      'engineering' => <String>['Design', 'Build', 'Test', 'Optimize'],
      'business' => <String>['Solve Problems', 'Make Decisions', 'Lead Teams', 'Grow Companies'],
      'psychology_social_sciences' => <String>['Assess', 'Listen', 'Analyze', 'Help'],
      _ => <String>['Observe', 'Respond', 'Decide', 'Reflect'],
    };
  }
}

class SceneAction {
  const SceneAction(this.label, this.icon, this.promptPrefix, {this.primary = false});

  final String label;
  final IconData icon;
  final String promptPrefix;
  final bool primary;
}
