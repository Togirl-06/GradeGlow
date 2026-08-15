import 'package:flutter/material.dart';

import '../shared/playable_models.dart';

/// Riverside Med Dispensary — Pharmacy Student under Ada Okonkwo.
const PlayableCareer pharmacyCareer = PlayableCareer(
  id: 'pharmacy',
  accent: Color(0xFF5EEAD4),
  bg: Color(0xFF041411),
  surface: Color(0xFF0C221E),
  workplaceName: 'Riverside Med · Dispensary',
  clockLine: 'Monday — 9:10 AM',
  roleTitle: 'Pharmacy Student',
  supervisorName: 'Ada Okonkwo',
  supervisorRole: 'Clinical Pharmacist',
  hireTagline:
      'Every Rx is a safety check. Patient, drug, dose, allergy, interaction.',
  supervisorBrief:
      '“New script at verification. Profile the patient before you bag anything. '
      'Then counsel — they will ask when to take it and what if they forget.”',
  enterCta: 'ENTER THE PHARMACY',
  startCta: 'OPEN VERIFICATION',
  startLocationId: 'verification',
  rooms: <PlayableRoom>[
    PlayableRoom(
      id: 'intake',
      name: 'Intake Window',
      icon: '🪟',
      blurb: 'Scripts land, insurance pings.',
      atmosphere:
          'Queue number soft-dings. A paper Rx sits in the priority tray.',
    ),
    PlayableRoom(
      id: 'verification',
      name: 'Verification',
      icon: '🔍',
      blurb: 'Profile review before dispense.',
      atmosphere:
          'Dual monitors. Allergy banner yellow. Ada: “Read the whole profile.”',
    ),
    PlayableRoom(
      id: 'shelves',
      name: 'Shelves',
      icon: '📦',
      blurb: 'Stock, beyond-use dates.',
      atmosphere: 'Rows of amber bottles. Count tray waiting.',
    ),
    PlayableRoom(
      id: 'counseling',
      name: 'Counseling Booth',
      icon: '🗣️',
      blurb: 'Teach-back, not a pamphlet dump.',
      atmosphere:
          'Quiet booth. Patient waiting with questions about timing and missed doses.',
    ),
    PlayableRoom(
      id: 'sterile',
      name: 'IV Room',
      icon: '🔒',
      blurb: 'Sterile compounding — later rotation.',
      atmosphere: 'Positive pressure. Not today.',
      lockedUntilStageId: 'counsel',
    ),
  ],
  stages: <PlayableStage>[
    PlayableStage(
      id: 'verify',
      locationId: 'verification',
      bannerTitle: 'RX WAITING',
      bannerBody:
          'Review patient, drug, dose, allergy, interaction — catch the conflict.',
      cta: 'Verify prescription',
      unlockKey: 'verify_done',
    ),
    PlayableStage(
      id: 'counsel',
      locationId: 'counseling',
      bannerTitle: 'PATIENT AT WINDOW',
      bannerBody:
          'Counsel on timing and missed doses — free-text chat with keywords.',
      cta: 'Start counseling',
      unlockKey: 'counsel_done',
      requiresKey: 'verify_done',
    ),
  ],
);
