import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';
import 'law_case_file_screen.dart';
import 'law_interview_screen.dart';

const PlayableCareer lawCareer = PlayableCareer(
  id: 'law_firm',
  accent: Color(0xFFD4A574),
  bg: Color(0xFF0C0A08),
  surface: Color(0xFF1A1510),
  workplaceName: 'Hartwell & Associates',
  clockLine: 'Monday — 8:47 AM',
  roleTitle: 'Junior Law Associate',
  supervisorName: 'Maya Chen',
  supervisorRole: 'Senior Associate',
  hireTagline: 'This is not a quiz. You work cases — interview, investigate, argue.',
  supervisorBrief:
      '“Good morning. We have a new client — Jordan Hale.\n\n'
      'I want you to handle the initial interview. Conference room. '
      'Don\'t make me regret this.”',
  enterCta: 'ENTER THE FIRM',
  startCta: 'MEET THE CLIENT',
  startLocationId: 'conference',
  roleGlyph: '⚖️',
  supervisorGlyph: '👩‍💼',
  liveLabel: 'ON THE CLOCK',
  meterLabels: <String>['Pressure', 'Credibility', 'Case'],
  ambientFeed: <String>[
    'Reception: Hale arrived · waiting in Conference B',
    'Partner Vargas in hearing until noon',
    'War room printer jam — IT ticket open',
    'Opposing counsel filed motion overnight',
    'Library terminal 3 free for research',
  ],
  rooms: <PlayableRoom>[
    PlayableRoom(
      id: 'reception',
      name: 'Reception',
      icon: '🏛️',
      blurb: 'Glass doors. Soft carpet. First impressions.',
      atmosphere:
          'The receptionist nods toward Conference B. A folder waits: '
          'Hale v. Northline. Maya wants you with the client — now.',
    ),
    PlayableRoom(
      id: 'conference',
      name: 'Conference',
      icon: '🗣️',
      blurb: 'Where clients tell their story — if you ask well.',
      atmosphere:
          'Long table. Water pitcher. Jordan Hale sits at the far end, '
          'fidgeting. This interview decides how hard the case gets later.',
    ),
    PlayableRoom(
      id: 'evidence',
      name: 'Evidence Room',
      icon: '📁',
      blurb: 'Documents, photos, timelines.',
      atmosphere:
          'The digital case folder is open. Police report. Contract. Emails. '
          'Tag what matters. Build the timeline Maya will grill you on.',
      lockedUntilStageId: 'interview_done',
    ),
    PlayableRoom(
      id: 'library',
      name: 'Law Library',
      icon: '📚',
      blurb: 'Reporters and quiet focus.',
      atmosphere:
          'Bound reporters. Research terminals. Legal research unlocks after '
          'your case file work.',
      lockedUntilStageId: 'casefile_done',
    ),
    PlayableRoom(
      id: 'courtroom',
      name: 'Courtroom',
      icon: '⚖️',
      blurb: 'Trial floor — earn it.',
      atmosphere: 'Not yet. Earn the courtroom.',
      lockedUntilStageId: 'casefile_done',
    ),
  ],
  stages: <PlayableStage>[
    PlayableStage(
      id: 'interview',
      locationId: 'conference',
      bannerTitle: 'ACTIVE CASE',
      bannerBody:
          'Jordan Hale is waiting. Interview them — they will not dump the whole story.',
      cta: 'Start interview',
      unlockKey: 'interview_done',
    ),
    PlayableStage(
      id: 'casefile',
      locationId: 'evidence',
      bannerTitle: 'CASE FILE READY',
      bannerBody:
          'Open documents. Tag evidence. Build the timeline. Maya will ask why.',
      cta: 'Open case file',
      unlockKey: 'casefile_done',
      requiresKey: 'interview_done',
    ),
  ],
);

/// Premium Law firm entry — cinematic workplace + interview/case labs.
Widget lawPlayableScreen() {
  int intakeScore = 55;
  return PlayableWorkplaceScreen(
    career: augmentCareerWithVisualLabs(lawCareer),
    onOpenStage: (BuildContext context, PlayableStage stage) async {
      final bool? visual = await tryRunVisualStage(context, stage);
      if (visual != null) return visual;
      if (!context.mounted) return false;
      switch (stage.id) {
        case 'interview':
          final int? score = await Navigator.of(context).push<int>(
            MaterialPageRoute<int>(builder: (_) => const LawInterviewScreen()),
          );
          if (score != null) intakeScore = score;
          return score != null;
        case 'casefile':
          final bool? ok = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => LawCaseFileScreen(intakeScore: intakeScore),
            ),
          );
          return ok == true;
        default:
          return false;
      }
    },
  );
}
