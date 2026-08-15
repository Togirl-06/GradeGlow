import 'package:flutter/material.dart';

import '../shared/playable_models.dart';

/// Riverside Med ED — Student Nurse under Charge Nurse Diaz.
const PlayableCareer nursingCareer = PlayableCareer(
  id: 'nursing_ed',
  accent: Color(0xFF2DD4A8),
  bg: Color(0xFF061412),
  surface: Color(0xFF0F2420),
  workplaceName: 'Riverside Med · ED',
  clockLine: 'Monday — 7:02 AM',
  roleTitle: 'Student Nurse',
  supervisorName: 'Charge Nurse Diaz',
  supervisorRole: 'Charge Nurse',
  hireTagline:
      'This is not a quiz. You care for patients — assess, monitor, prioritize.',
  supervisorBrief:
      '“Morning. Assignment board is up. Four patients on your wing.\n\n'
      'Prioritize who you see first — then get to Room 103. '
      'Nurses assess and escalate. Doctors diagnose. Got it?”',
  enterCta: 'ENTER THE HOSPITAL',
  startCta: 'OPEN ASSIGNMENT BOARD',
  startLocationId: 'nurses_station',
  roleGlyph: '👩‍⚕️',
  supervisorGlyph: '🧑‍⚕️',
  liveLabel: 'LIVE SHIFT',
  meterLabels: <String>['Acuity', 'Trust', 'Coverage'],
  ambientFeed: <String>[
    'ED triage: 3 waiting · avg wait 18m',
    'Lab calling on Room 102 glucose',
    'Family at Room 104 asking for update',
    'Code cart check overdue — Bay 2',
    'Dr. Park on floor for rounds',
  ],
  rooms: <PlayableRoom>[
    PlayableRoom(
      id: 'nurses_station',
      name: "Nurses' Station",
      icon: '🖥️',
      blurb: 'Assignment board, phones, Diaz\'s desk.',
      atmosphere:
          'Monitors chirp. The whiteboard lists four rooms. '
          'Diaz watches you from the desk — waiting for your priority call.',
    ),
    PlayableRoom(
      id: 'room_101',
      name: 'Room 101',
      icon: '🛏️',
      blurb: 'Post-procedure recovery — stable.',
      atmosphere:
          'Quiet beeps. Patient sleeping off anesthesia. Family in the chair.',
    ),
    PlayableRoom(
      id: 'room_102',
      name: 'Room 102',
      icon: '🛏️',
      blurb: 'Diabetes — morning glucose check due.',
      atmosphere:
          'Patient reading. Breakfast tray untouched. Glucometer on the cart.',
    ),
    PlayableRoom(
      id: 'room_103',
      name: 'Room 103',
      icon: '🫁',
      blurb: 'Respiratory distress — high acuity.',
      atmosphere:
          'Patient sits forward, lips pale. "I don\'t feel right." '
          'This is where nursing judgment lives.',
    ),
    PlayableRoom(
      id: 'room_104',
      name: 'Room 104',
      icon: '🛏️',
      blurb: 'Post-op day 1 — pain controlled.',
      atmosphere:
          'Dressing clean. PCA pump humming. Patient asks about walking later.',
    ),
    PlayableRoom(
      id: 'ed_bay',
      name: 'ED Bay',
      icon: '🚑',
      blurb: 'Walk-ins, stretchers, controlled chaos.',
      atmosphere:
          'Triage lights flash. A paramedic radio crackles. '
          'Your wing comes first this morning.',
    ),
    PlayableRoom(
      id: 'med_room',
      name: 'Med Room',
      icon: '💊',
      blurb: 'Pyxis, labels, double-checks.',
      atmosphere:
          'Locked cabinets. Scanner ready. No meds until assessments are clean.',
    ),
    PlayableRoom(
      id: 'icu',
      name: 'ICU',
      icon: '🔒',
      blurb: 'Higher acuity — unlock after first shift work.',
      atmosphere: 'Glass doors. Ventilators. Not yet.',
      lockedUntilStageId: 'assessment',
    ),
  ],
  stages: <PlayableStage>[
    PlayableStage(
      id: 'shift',
      locationId: 'nurses_station',
      bannerTitle: 'ACTIVE SITUATION',
      bannerBody:
          'Four patients assigned. Prioritize who you see first, then review charts.',
      cta: 'Open assignment board',
      unlockKey: 'shift_done',
    ),
    PlayableStage(
      id: 'assessment',
      locationId: 'room_103',
      bannerTitle: 'PATIENT CALLING',
      bannerBody:
          'Room 103 — "I don\'t feel right." Assess, document, escalate.',
      cta: 'Enter Room 103',
      unlockKey: 'assessment_done',
      requiresKey: 'shift_done',
    ),
  ],
);
