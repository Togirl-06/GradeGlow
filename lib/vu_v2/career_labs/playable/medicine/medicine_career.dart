import 'package:flutter/material.dart';

import '../shared/playable_models.dart';

/// Riverside Med diagnostic ward — Medical Student under Dr. Anika Shah.
const PlayableCareer medicineCareer = PlayableCareer(
  id: 'medicine',
  accent: Color(0xFF60A5FA),
  bg: Color(0xFF060B14),
  surface: Color(0xFF0F1A2C),
  workplaceName: 'Riverside Med · Diagnostic Ward',
  clockLine: 'Monday — 8:15 AM',
  roleTitle: 'Medical Student',
  supervisorName: 'Dr. Anika Shah',
  supervisorRole: 'Attending Physician',
  hireTagline:
      'This is detective work. Interview, differential, test wisely — then decide.',
  supervisorBrief:
      '“New consult in Clinic Bay 2 — fatigue and shortness of breath.\n\n'
      'Interview first. Don\'t order the whole lab menu. Think.”',
  enterCta: 'ENTER THE WARD',
  startCta: 'START INTERVIEW',
  startLocationId: 'clinic_bay',
  rooms: <PlayableRoom>[
    PlayableRoom(
      id: 'rounds',
      name: 'Rounds Board',
      icon: '📋',
      blurb: 'Team list, consults, Shah\'s expectations.',
      atmosphere:
          'Whiteboard scribbles. Coffee. Dr. Shah expects a clean differential by mid-morning.',
    ),
    PlayableRoom(
      id: 'clinic_bay',
      name: 'Clinic Bay 2',
      icon: '🩺',
      blurb: 'Where the history lives — if you ask well.',
      atmosphere:
          'Curtain half-drawn. Patient Avery Kim waits with a notebook of symptoms.',
    ),
    PlayableRoom(
      id: 'workroom',
      name: 'Workroom',
      icon: '💻',
      blurb: 'Differentials, orders, limited time points.',
      atmosphere:
          'Terminals glow. Every test costs time. Shah grades judgment, not volume.',
    ),
    PlayableRoom(
      id: 'ed',
      name: 'ED Bridge',
      icon: '🚑',
      blurb: 'Cross-cover for acute decompensation.',
      atmosphere: 'Radio chatter. Not your consult — yet.',
    ),
    PlayableRoom(
      id: 'radiology',
      name: 'Radiology',
      icon: '🩻',
      blurb: 'Imaging reads when ordered thoughtfully.',
      atmosphere: 'Dark room. Waiting for your order set.',
      lockedUntilStageId: 'interview',
    ),
    PlayableRoom(
      id: 'icu',
      name: 'ICU',
      icon: '🔒',
      blurb: 'Critical care — later rotations.',
      atmosphere: 'Locked for students until later.',
      lockedUntilStageId: 'differential',
    ),
  ],
  stages: <PlayableStage>[
    PlayableStage(
      id: 'interview',
      locationId: 'clinic_bay',
      bannerTitle: 'ACTIVE CONSULT',
      bannerBody:
          'Avery Kim — fatigue + SOB. Unlock the history with good questions.',
      cta: 'Interview patient',
      unlockKey: 'interview_done',
    ),
    PlayableStage(
      id: 'differential',
      locationId: 'workroom',
      bannerTitle: 'BUILD THE DIFFERENTIAL',
      bannerBody:
          'Rank differentials, pick most likely, order tests with limited time.',
      cta: 'Open differential board',
      unlockKey: 'differential_done',
      requiresKey: 'interview_done',
    ),
  ],
);
