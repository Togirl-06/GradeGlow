import 'package:flutter/material.dart';

import '../shared/playable_models.dart';

/// Riverside Med Core Lab — MLS Student under Tessa Adebayo.
const PlayableCareer mlsCareer = PlayableCareer(
  id: 'medical_lab_science',
  accent: Color(0xFFC084FC),
  bg: Color(0xFF0C0614),
  surface: Color(0xFF1A1028),
  workplaceName: 'Riverside Med · Core Lab',
  clockLine: 'Monday — 6:45 AM',
  roleTitle: 'MLS Student',
  supervisorName: 'Tessa Adebayo',
  supervisorRole: 'Lead MLS',
  hireTagline:
      'Specimens don\'t wait. Identity, order, analyze, report — no shortcuts.',
  supervisorBrief:
      '“STAT chemistry just landed. Identify it, prep in the correct order, '
      'then interpret the panel. Critical values get phoned — always.”',
  enterCta: 'ENTER THE LAB',
  startCta: 'RECEIVE SPECIMEN',
  startLocationId: 'receiving',
  rooms: <PlayableRoom>[
    PlayableRoom(
      id: 'receiving',
      name: 'Receiving',
      icon: '📦',
      blurb: 'Tubes arrive. Identity is everything.',
      atmosphere:
          'Pneumatic tube thunks. A lavender-top and a gold-top share a bag — '
          'labels matter before anything else.',
    ),
    PlayableRoom(
      id: 'bench',
      name: 'Chemistry Bench',
      icon: '🧪',
      blurb: 'Analyzers, QC, your workstation.',
      atmosphere:
          'Hiss of reagents. Screen waiting for accession. Tessa watches technique.',
    ),
    PlayableRoom(
      id: 'micro',
      name: 'Micro Bay',
      icon: '🦠',
      blurb: 'Cultures — not today\'s STAT.',
      atmosphere: 'Incubators hum. Not your queue this morning.',
    ),
    PlayableRoom(
      id: 'blood_bank',
      name: 'Blood Bank',
      icon: '🩸',
      blurb: 'Type & screen window.',
      atmosphere: 'Locked fridge. Separate credentialing.',
      lockedUntilStageId: 'panel',
    ),
    PlayableRoom(
      id: 'report',
      name: 'Result Desk',
      icon: '📠',
      blurb: 'Verify, flag, call criticals.',
      atmosphere:
          'Phone sticky-note: "Critical K+ — call floor within 15 min."',
    ),
  ],
  stages: <PlayableStage>[
    PlayableStage(
      id: 'pipeline',
      locationId: 'receiving',
      bannerTitle: 'STAT ARRIVAL',
      bannerBody:
          'Identify the specimen, then run prep steps in the correct order.',
      cta: 'Open specimen',
      unlockKey: 'pipeline_done',
    ),
    PlayableStage(
      id: 'panel',
      locationId: 'report',
      bannerTitle: 'PANEL READY',
      bannerBody:
          'Interpret results, flag the critical value, and report correctly.',
      cta: 'Open results',
      unlockKey: 'panel_done',
      requiresKey: 'pipeline_done',
    ),
  ],
);
