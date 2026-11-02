import '../career_sim_models.dart';

/// Riverside Med · Emergency Department — first complete Career Sim world.
abstract final class NursingEdWorld {
  static const String worldId = 'nursing_ed';
  static const String careerProgressId = 'career_nursing_ed';

  static CareerWorld build() {
    return CareerWorld(
      id: worldId,
      name: 'Emergency Department',
      workplace: 'Riverside Med · ED',
      role: const CareerRole(
        title: 'Student Nurse',
        shift: '7:00 AM – 7:00 PM',
        supervisorName: 'Charge Nurse Diaz',
        tagline: 'Your first shift starts now.',
      ),
      skillIds: CareerSkillId.nursingDefaults,
      careerTitles: const <String>[
        'Nursing Student',
        'Clinical Beginner',
        'Junior Nurse',
        'Clinical Practitioner',
        'Senior Nurse',
        'Charge Nurse',
        'Nurse Leader',
      ],
      locations: const <CareerLocation>[
        CareerLocation(
          id: 'nurses_station',
          name: "Nurses' Station",
          blurb: 'Assignment board, phones, Diaz\'s desk.',
          icon: '🖥️',
          unlockCareerLevel: 1,
        ),
        CareerLocation(
          id: 'triage',
          name: 'Triage / Waiting',
          blurb: 'Walk-ins, acuity sorting, family noise.',
          icon: '📋',
          unlockCareerLevel: 1,
        ),
        CareerLocation(
          id: 'ed_bay',
          name: 'ED Bay',
          blurb: 'Beds, monitors, the real work.',
          icon: '🛏️',
          unlockCareerLevel: 1,
        ),
        CareerLocation(
          id: 'med_room',
          name: 'Medication Room',
          blurb: 'Pyxis, labels, double-checks.',
          icon: '💊',
          unlockCareerLevel: 1,
        ),
        CareerLocation(
          id: 'supply',
          name: 'Supply Closet',
          blurb: 'Gloves, O2, crash cart access.',
          icon: '🧰',
          unlockCareerLevel: 1,
        ),
        CareerLocation(
          id: 'icu',
          name: 'ICU',
          blurb: 'Higher acuity — unlock with experience.',
          icon: '🔒',
          unlockCareerLevel: 4,
          lockedHint: 'Reach Career Level 4 to enter ICU.',
        ),
        CareerLocation(
          id: 'or',
          name: 'Operating Room',
          blurb: 'Peri-op support missions.',
          icon: '🔒',
          unlockCareerLevel: 6,
          lockedHint: 'Reach Career Level 6 for OR support shifts.',
        ),
        CareerLocation(
          id: 'pharmacy',
          name: 'Pharmacy',
          blurb: 'Med reconciliation with pharmacy team.',
          icon: '🔒',
          unlockCareerLevel: 5,
          lockedHint: 'Reach Career Level 5 to run pharmacy consults.',
        ),
      ],
      npcs: const <CareerNpc>[
        CareerNpc(
          id: 'diaz',
          name: 'Charge Nurse Diaz',
          role: 'Supervisor',
          personality: 'Direct, fair, zero tolerance for shortcuts.',
          avatarGlyph: '👩‍⚕️',
        ),
        CareerNpc(
          id: 'cole',
          name: 'Mr. Cole',
          role: 'Patient 104',
          personality: 'Anxious, short of breath, wants answers.',
          avatarGlyph: '🧑',
        ),
        CareerNpc(
          id: 'family',
          name: 'Ms. Cole',
          role: 'Family',
          personality: 'Protective, scared, interrupts when ignored.',
          avatarGlyph: '👩',
        ),
        CareerNpc(
          id: 'dr_park',
          name: 'Dr. Park',
          role: 'ED Physician',
          personality: 'Fast, expects clean handoffs.',
          avatarGlyph: '👨‍⚕️',
        ),
        CareerNpc(
          id: 'raya',
          name: 'Ms. Raya',
          role: 'Difficult patient',
          personality: 'Frustrated, ready to leave AMA.',
          avatarGlyph: '👩',
        ),
      ],
      missions: <CareerMission>[
        _m1FirstShift(),
        _m2FirstPatient(),
        _m3Deterioration(),
        _m4MedRound(),
        _m5DifficultPatient(),
        _m6EdChaos(),
        _m7NightBoss(),
      ],
    );
  }

  // ─── Mission 01 ─────────────────────────────────────────────
  static CareerMission _m1FirstShift() {
    return CareerMission(
      id: 'nurse_m1_first_shift',
      index: 1,
      title: 'Mission 01 — Your First Day',
      brief:
          'Report to the nurses\' station. Meet Charge Nurse Diaz. '
          'Open the chart for Patient 104.',
      objective: 'Complete your first shift check-in.',
      mode: CareerSimGameMode.training,
      trackStage: CareerTrackStage.training,
      difficultyStars: 1,
      xpReward: 250,
      requiredCareerLevel: 1,
      startBeatId: 'm1_cinematic',
      startLocationId: 'nurses_station',
      badgeOnClear: 'first_patient',
      objectives: const <CareerObjective>[
        CareerObjective(id: 'report_in', label: 'Report to nurses\' station'),
        CareerObjective(id: 'meet_diaz', label: 'Meet Charge Nurse Diaz'),
        CareerObjective(id: 'open_chart', label: 'Open Patient 104 chart'),
      ],
      beats: <CareerBeat>[
        const CareerBeat(
          id: 'm1_cinematic',
          kind: CareerBeatKind.cinematic,
          locationId: 'nurses_station',
          title: '7:02 AM · Monday',
          body:
              'Hospital doors open. The ED hums. Fluorescent lights. '
              'MONDAY — YOUR FIRST SHIFT.\n\n'
              'You have 12 hours ahead of you.\n\n'
              'OBJECTIVE: Report to the nurses\' station.',
          nextBeatId: 'm1_diaz',
          continueLabel: 'Enter the ED',
        ),
        CareerBeat(
          id: 'm1_diaz',
          kind: CareerBeatKind.dialogue,
          locationId: 'nurses_station',
          npcId: 'diaz',
          title: 'Charge Nurse Diaz',
          body:
              '"You\'re the new Student Nurse. Good. Bay 3 is yours on paper — '
              'Mr. Cole, chest discomfort. Don\'t disappear into the chart room. '
              'Patients first. Questions?"',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'ack',
              label: '"Understood. I\'ll review Cole\'s chart and go to Bay 3."',
              consequence: CareerConsequence(
                narrative:
                    'Diaz nods. "Open the chart. Then I want eyes on the patient."',
                nextBeatId: 'm1_chart',
                unlockObjectives: const <String>['report_in', 'meet_diaz'],
                skillDeltas: const <String, int>{
                  CareerSkillId.professionalism: 6,
                  CareerSkillId.communication: 4,
                },
                meterDeltas: const <String, int>{'trust': 8},
              ),
            ),
            CareerChoice(
              id: 'joke',
              label: '"Hopefully it\'s a quiet Monday."',
              consequence: CareerConsequence(
                narrative:
                    'Diaz doesn\'t smile. "It never is. Chart. Bay. Now."',
                nextBeatId: 'm1_chart',
                unlockObjectives: const <String>['report_in', 'meet_diaz'],
                skillDeltas: const <String, int>{
                  CareerSkillId.professionalism: -2,
                },
                meterDeltas: const <String, int>{'trust': -4, 'stress': 5},
              ),
            ),
          ],
        ),
        CareerBeat(
          id: 'm1_chart',
          kind: CareerBeatKind.tool,
          locationId: 'nurses_station',
          title: 'Patient 104 · Chart',
          body:
              'Electronic chart flashes open.\n\n'
              'Mr. Cole, 62 · CC: chest discomfort · Allergies: penicillin\n'
              'HR 102 · BP 148/92 · SpO₂ 94% on RA · Anxious\n\n'
              'Choose your next move.',
          toolIds: const <String>['open_chart', 'go_bay', 'coffee'],
          choices: <CareerChoice>[
            CareerChoice(
              id: 'open_chart',
              label: 'Review full history + allergies, then go to Bay 3',
              consequence: CareerConsequence(
                narrative:
                    'You note penicillin allergy and rising HR. Diaz watches — '
                    'she likes thorough students who still move.',
                nextBeatId: 'm1_end',
                unlockObjectives: const <String>['open_chart'],
                skillDeltas: const <String, int>{
                  CareerSkillId.clinicalKnowledge: 8,
                  CareerSkillId.criticalThinking: 6,
                },
                meterDeltas: const <String, int>{'trust': 6, 'patient': 4},
                completeMission: true,
              ),
            ),
            CareerChoice(
              id: 'go_bay',
              label: 'Skip details — rush to Bay 3 immediately',
              consequence: CareerConsequence(
                narrative:
                    'You arrive fast but miss the penicillin flag. Diaz: '
                    '"Read the chart. Allergies kill people."',
                nextBeatId: 'm1_end',
                unlockObjectives: const <String>['open_chart'],
                skillDeltas: const <String, int>{
                  CareerSkillId.timeManagement: 4,
                  CareerSkillId.clinicalKnowledge: -4,
                },
                meterDeltas: const <String, int>{'trust': -6, 'stress': 8},
                completeMission: true,
              ),
            ),
            CareerChoice(
              id: 'coffee',
              label: 'Grab coffee before anything else',
              consequence: CareerConsequence(
                narrative:
                    'Diaz finds you in the break room. "Shift started. '
                    'Patient waiting. Coffee can wait."',
                failMission: true,
                skillDeltas: const <String, int>{
                  CareerSkillId.professionalism: -12,
                  CareerSkillId.timeManagement: -10,
                },
                meterDeltas: const <String, int>{'trust': -20, 'stress': 10},
              ),
            ),
          ],
        ),
        const CareerBeat(
          id: 'm1_end',
          kind: CareerBeatKind.missionEnd,
          title: 'Shift check-in complete',
          body: 'You are on the board. Bay 3 is waiting.',
        ),
      ],
    );
  }

  // ─── Mission 02 ─────────────────────────────────────────────
  static CareerMission _m2FirstPatient() {
    return CareerMission(
      id: 'nurse_m2_first_patient',
      index: 2,
      title: 'Mission 02 — First Patient',
      brief:
          'Interview Mr. Cole, check vitals, document, and escalate if needed.',
      objective: 'Complete a full bedside assessment.',
      mode: CareerSimGameMode.career,
      trackStage: CareerTrackStage.firstMission,
      difficultyStars: 2,
      xpReward: 320,
      requiredCareerLevel: 1,
      startBeatId: 'm2_arrive',
      startLocationId: 'ed_bay',
      badgeOnClear: 'first_patient',
      objectives: const <CareerObjective>[
        CareerObjective(id: 'interview', label: 'Interview patient'),
        CareerObjective(id: 'vitals', label: 'Check vital signs'),
        CareerObjective(id: 'document', label: 'Document findings'),
      ],
      beats: <CareerBeat>[
        CareerBeat(
          id: 'm2_arrive',
          kind: CareerBeatKind.dialogue,
          locationId: 'ed_bay',
          npcId: 'cole',
          title: 'Bay 3 · Mr. Cole',
          body:
              '"I\'m feeling dizzy. Nobody told me what\'s going on. '
              'Is this a heart attack?"',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'listen',
              label: 'Sit, listen, ask onset / severity / radiation',
              consequence: CareerConsequence(
                narrative:
                    'He exhales. "Started an hour ago. Pressure, not sharp. '
                    'A little into my jaw." You have a clearer picture.',
                nextBeatId: 'm2_vitals',
                unlockObjectives: const <String>['interview'],
                skillDeltas: const <String, int>{
                  CareerSkillId.communication: 10,
                  CareerSkillId.patientCare: 8,
                },
                meterDeltas: const <String, int>{'patient': 8, 'trust': 5},
              ),
            ),
            CareerChoice(
              id: 'ignore',
              label: 'Tell him to wait — you\'ll be back',
              consequence: CareerConsequence(
                narrative:
                    'He raises his voice. Family appears. Diaz pages you: '
                    '"Bedside. Now."',
                nextBeatId: 'm2_vitals',
                skillDeltas: const <String, int>{
                  CareerSkillId.communication: -10,
                  CareerSkillId.patientCare: -8,
                },
                meterDeltas: const <String, int>{
                  'patient': -12,
                  'trust': -10,
                  'stress': 15,
                },
              ),
            ),
            CareerChoice(
              id: 'med_now',
              label: 'Offer medication immediately without assessment',
              consequence: CareerConsequence(
                narrative:
                    'Unsafe. You don\'t know allergies or orders yet. '
                    'Diaz intercepts: "Assessment first."',
                nextBeatId: 'm2_vitals',
                skillDeltas: const <String, int>{
                  CareerSkillId.clinicalKnowledge: -8,
                  CareerSkillId.professionalism: -6,
                },
                meterDeltas: const <String, int>{'trust': -12, 'stress': 10},
              ),
            ),
          ],
        ),
        CareerBeat(
          id: 'm2_vitals',
          kind: CareerBeatKind.tool,
          locationId: 'ed_bay',
          title: 'Vitals',
          body: 'Monitor ready. What do you do?',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'check_vitals',
              label: 'Check full vitals (BP, HR, SpO₂, RR, temp)',
              consequence: CareerConsequence(
                narrative:
                    'BP 148/94 · HR 110 · SpO₂ 93% · RR 24 · Temp 37.1°C\n'
                    'Slightly worse than triage. Document and update Diaz.',
                nextBeatId: 'm2_doc',
                unlockObjectives: const <String>['vitals'],
                skillDeltas: const <String, int>{
                  CareerSkillId.clinicalKnowledge: 10,
                  CareerSkillId.criticalThinking: 6,
                },
                meterDeltas: const <String, int>{'patient': 6, 'trust': 4},
                setFlags: const <String, String>{'vitals': 'borderline'},
              ),
            ),
            CareerChoice(
              id: 'guess',
              label: 'Skip vitals — he looks fine enough',
              consequence: CareerConsequence(
                narrative:
                    'Two minutes later SpO₂ dips to 90%. You scramble. '
                    'Missed data costs time.',
                nextBeatId: 'm2_doc',
                skillDeltas: const <String, int>{
                  CareerSkillId.clinicalKnowledge: -6,
                  CareerSkillId.criticalThinking: -4,
                },
                meterDeltas: const <String, int>{
                  'patient': -10,
                  'stress': 12,
                  'trust': -8,
                },
              ),
            ),
          ],
        ),
        CareerBeat(
          id: 'm2_doc',
          kind: CareerBeatKind.decision,
          locationId: 'ed_bay',
          npcId: 'diaz',
          title: 'Document & escalate?',
          body: 'Diaz: "What do you have?"',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'sbarr',
              label: 'Give a clean SBAR handoff + chart vitals',
              consequence: CareerConsequence(
                narrative:
                    'Diaz: "That\'s a handoff. Dr. Park is coming." '
                    'Mission complete.',
                unlockObjectives: const <String>['document'],
                skillDeltas: const <String, int>{
                  CareerSkillId.communication: 8,
                  CareerSkillId.professionalism: 10,
                },
                meterDeltas: const <String, int>{'trust': 12},
                completeMission: true,
              ),
            ),
            CareerChoice(
              id: 'vague',
              label: '"Uh… he\'s dizzy? Maybe cardiac?"',
              consequence: CareerConsequence(
                narrative:
                    'Diaz stares. "Try again with numbers." You recover, '
                    'but trust dips.',
                unlockObjectives: const <String>['document'],
                skillDeltas: const <String, int>{
                  CareerSkillId.communication: -4,
                  CareerSkillId.professionalism: 2,
                },
                meterDeltas: const <String, int>{'trust': -5},
                completeMission: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Mission 03 ─────────────────────────────────────────────
  static CareerMission _m3Deterioration() {
    return CareerMission(
      id: 'nurse_m3_deteriorate',
      index: 3,
      title: 'Mission 03 — Patient Deterioration',
      brief: 'Vitals change. Recognize decline and escalate correctly.',
      objective: 'Respond to deteriorating Patient 104.',
      mode: CareerSimGameMode.career,
      trackStage: CareerTrackStage.realScenarios,
      difficultyStars: 3,
      xpReward: 380,
      requiredCareerLevel: 1,
      startBeatId: 'm3_change',
      startLocationId: 'ed_bay',
      badgeOnClear: 'crisis_manager',
      objectives: const <CareerObjective>[
        CareerObjective(id: 'recognize', label: 'Recognize deterioration'),
        CareerObjective(id: 'escalate', label: 'Escalate appropriately'),
      ],
      beats: <CareerBeat>[
        CareerBeat(
          id: 'm3_change',
          kind: CareerBeatKind.dialogue,
          locationId: 'ed_bay',
          npcId: 'cole',
          title: 'Condition changing',
          body:
              'Alarm. SpO₂ 88% · BP 88/54 · HR 118\n\n'
              'Mr. Cole: "I can\'t… catch… my breath."\n\n'
              'The patient\'s condition appears to be deteriorating.',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'reassess',
              label: 'Stay: airway/breathing, raise HOB, O2 per protocol, call for help',
              consequence: CareerConsequence(
                narrative:
                    'You act. SpO₂ ticks to 90%. Rapid response on the way. '
                    'Diaz: "Good call."',
                nextBeatId: 'm3_escalate',
                unlockObjectives: const <String>['recognize'],
                skillDeltas: const <String, int>{
                  CareerSkillId.criticalThinking: 12,
                  CareerSkillId.patientCare: 12,
                  CareerSkillId.clinicalKnowledge: 8,
                },
                meterDeltas: const <String, int>{
                  'patient': 14,
                  'trust': 10,
                  'stress': 8,
                },
              ),
            ),
            CareerChoice(
              id: 'leave',
              label: 'Leave to find someone — alone',
              consequence: CareerConsequence(
                narrative:
                    'You leave the bedside. SpO₂ falls further. Diaz finds '
                    'Cole alone: "Never abandon a crashing patient."',
                nextBeatId: 'm3_escalate',
                skillDeltas: const <String, int>{
                  CareerSkillId.patientCare: -15,
                  CareerSkillId.criticalThinking: -8,
                },
                meterDeltas: const <String, int>{
                  'patient': -20,
                  'trust': -18,
                  'stress': 20,
                },
              ),
            ),
            CareerChoice(
              id: 'freeze',
              label: 'Freeze and keep watching the monitor',
              consequence: CareerConsequence(
                narrative: 'Seconds matter. Inaction becomes harm.',
                failMission: true,
                skillDeltas: const <String, int>{
                  CareerSkillId.criticalThinking: -12,
                  CareerSkillId.timeManagement: -10,
                },
                meterDeltas: const <String, int>{
                  'patient': -30,
                  'trust': -25,
                },
              ),
            ),
          ],
        ),
        CareerBeat(
          id: 'm3_escalate',
          kind: CareerBeatKind.decision,
          locationId: 'ed_bay',
          npcId: 'dr_park',
          title: 'Escalate',
          body: 'Dr. Park arrives. "Talk to me."',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'sbar',
              label: 'SBAR with vitals trend + actions already taken',
              consequence: CareerConsequence(
                narrative:
                    'Park: "Continue O2, get ABG, I\'m staying." '
                    'You unlocked a new objective: stabilize.',
                unlockObjectives: const <String>['escalate'],
                skillDeltas: const <String, int>{
                  CareerSkillId.communication: 10,
                  CareerSkillId.professionalism: 8,
                },
                meterDeltas: const <String, int>{'trust': 10, 'patient': 8},
                completeMission: true,
              ),
            ),
            CareerChoice(
              id: 'panic',
              label: '"He\'s crashing! Do something!"',
              consequence: CareerConsequence(
                narrative:
                    'Park takes over. You learn: panic ≠ handoff. '
                    'Mission barely saved.',
                unlockObjectives: const <String>['escalate'],
                skillDeltas: const <String, int>{
                  CareerSkillId.communication: -6,
                  CareerSkillId.professionalism: -4,
                },
                meterDeltas: const <String, int>{'trust': -4},
                completeMission: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Mission 04 ─────────────────────────────────────────────
  static CareerMission _m4MedRound() {
    return CareerMission(
      id: 'nurse_m4_meds',
      index: 4,
      title: 'Mission 04 — Medication Round',
      brief: 'Verify identity, allergies, orders, and timing before giving meds.',
      objective: 'Complete a safe medication pass.',
      mode: CareerSimGameMode.career,
      trackStage: CareerTrackStage.advanced,
      difficultyStars: 3,
      xpReward: 360,
      requiredCareerLevel: 2,
      startBeatId: 'm4_med',
      startLocationId: 'med_room',
      badgeOnClear: 'perfect_shift',
      objectives: const <CareerObjective>[
        CareerObjective(id: 'rights', label: 'Complete medication rights'),
        CareerObjective(id: 'allergy', label: 'Verify allergies'),
      ],
      beats: <CareerBeat>[
        CareerBeat(
          id: 'm4_med',
          kind: CareerBeatKind.tool,
          locationId: 'med_room',
          title: 'Pyxis · Ordered: Amoxicillin PO',
          body:
              'Order: Amoxicillin 500 mg PO now.\n'
              'Chart allergy: penicillin.\n\n'
              'What do you do?',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'hold',
              label: 'Hold med — allergy conflict — call provider',
              consequence: CareerConsequence(
                narrative:
                    'You catch it. Provider switches to azithromycin. '
                    'Diaz: "That\'s how you keep a license."',
                nextBeatId: 'm4_id',
                unlockObjectives: const <String>['allergy'],
                skillDeltas: const <String, int>{
                  CareerSkillId.clinicalKnowledge: 14,
                  CareerSkillId.criticalThinking: 10,
                  CareerSkillId.professionalism: 8,
                },
                meterDeltas: const <String, int>{'trust': 15, 'patient': 10},
              ),
            ),
            CareerChoice(
              id: 'give',
              label: 'Pull and give — orders are orders',
              consequence: CareerConsequence(
                narrative:
                    'Patient develops rash and throat tightness. '
                    'Emergency intervention. Consequence unlocked.',
                failMission: true,
                skillDeltas: const <String, int>{
                  CareerSkillId.clinicalKnowledge: -20,
                  CareerSkillId.patientCare: -20,
                },
                meterDeltas: const <String, int>{
                  'patient': -40,
                  'trust': -35,
                },
              ),
            ),
            CareerChoice(
              id: 'ask_patient',
              label: 'Ask patient if they\'re "really" allergic',
              consequence: CareerConsequence(
                narrative:
                    'He shrugs. Unreliable. Diaz: "Chart beats shrug. Hold and call."',
                nextBeatId: 'm4_id',
                skillDeltas: const <String, int>{
                  CareerSkillId.clinicalKnowledge: -4,
                },
                meterDeltas: const <String, int>{'trust': -6, 'stress': 8},
              ),
            ),
          ],
        ),
        CareerBeat(
          id: 'm4_id',
          kind: CareerBeatKind.decision,
          locationId: 'ed_bay',
          title: 'Two identifiers',
          body: 'New order: azithromycin. At bedside.',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'two_id',
              label: 'Verify name + DOB against wristband + MAR',
              consequence: CareerConsequence(
                narrative: 'Identifiers match. Med given safely. Documented.',
                unlockObjectives: const <String>['rights', 'allergy'],
                skillDeltas: const <String, int>{
                  CareerSkillId.professionalism: 8,
                  CareerSkillId.patientCare: 6,
                },
                meterDeltas: const <String, int>{'trust': 8},
                completeMission: true,
              ),
            ),
            CareerChoice(
              id: 'assume',
              label: 'Assume Bay 3 is always Cole — give quickly',
              consequence: CareerConsequence(
                narrative:
                    'Wrong patient almost — roommate spoke up. Near miss. '
                    'Diaz: "Two identifiers. Every. Time."',
                unlockObjectives: const <String>['rights'],
                skillDeltas: const <String, int>{
                  CareerSkillId.professionalism: -8,
                  CareerSkillId.patientCare: -6,
                },
                meterDeltas: const <String, int>{'trust': -12, 'stress': 10},
                completeMission: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Mission 05 ─────────────────────────────────────────────
  static CareerMission _m5DifficultPatient() {
    return CareerMission(
      id: 'nurse_m5_difficult',
      index: 5,
      title: 'Mission 05 — Difficult Patient',
      brief: 'Ms. Raya wants to leave. Use words — not only buttons.',
      objective: 'De-escalate and keep the patient safe.',
      mode: CareerSimGameMode.career,
      trackStage: CareerTrackStage.advanced,
      difficultyStars: 3,
      xpReward: 340,
      requiredCareerLevel: 2,
      startBeatId: 'm5_talk',
      startLocationId: 'ed_bay',
      badgeOnClear: 'leadership',
      objectives: const <CareerObjective>[
        CareerObjective(id: 'empathy', label: 'Show empathy'),
        CareerObjective(id: 'safety', label: 'Protect patient safety'),
      ],
      beats: <CareerBeat>[
        CareerBeat(
          id: 'm5_talk',
          kind: CareerBeatKind.freeText,
          locationId: 'ed_bay',
          npcId: 'raya',
          title: 'Ms. Raya',
          body:
              '"Nobody is listening to me. I want to leave."\n\n'
              'Type what you say to her.',
          freeTextHint: 'Acknowledge frustration, then safety.',
          freeTextGoodKeywords: const <String>[
            'understand',
            'frustrat',
            'safe',
            'listen',
            'before you leave',
            'concern',
            'help',
          ],
          freeTextGood: CareerConsequence(
            narrative:
                'She pauses. "Fine. I\'ll stay for the labs. But talk to me."',
            nextBeatId: 'm5_close',
            unlockObjectives: const <String>['empathy'],
            skillDeltas: const <String, int>{
              CareerSkillId.communication: 14,
              CareerSkillId.professionalism: 10,
              CareerSkillId.patientCare: 8,
            },
            meterDeltas: const <String, int>{'trust': 12, 'patient': 8},
          ),
          freeTextWeak: CareerConsequence(
            narrative:
                'She stands and grabs her bag. Diaz steps in. '
                'You get one more chance to repair trust.',
            nextBeatId: 'm5_retry',
            skillDeltas: const <String, int>{
              CareerSkillId.communication: -6,
            },
            meterDeltas: const <String, int>{'trust': -8, 'stress': 10},
          ),
        ),
        CareerBeat(
          id: 'm5_retry',
          kind: CareerBeatKind.decision,
          locationId: 'ed_bay',
          npcId: 'raya',
          title: 'Last chance',
          body: 'She\'s at the door.',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'repair',
              label:
                  '"I hear you. Before you go, I need to make sure you\'re safe — can we sit for two minutes?"',
              consequence: CareerConsequence(
                narrative: 'She sits. Bridge rebuilt.',
                nextBeatId: 'm5_close',
                unlockObjectives: const <String>['empathy', 'safety'],
                skillDeltas: const <String, int>{
                  CareerSkillId.communication: 8,
                  CareerSkillId.patientCare: 6,
                },
                meterDeltas: const <String, int>{'trust': 6},
              ),
            ),
            CareerChoice(
              id: 'block',
              label: 'Block the door and threaten security',
              consequence: CareerConsequence(
                narrative:
                    'Situation explodes. Security called. Teaching moment — '
                    'force escalates AMA conflict.',
                failMission: true,
                skillDeltas: const <String, int>{
                  CareerSkillId.communication: -12,
                  CareerSkillId.professionalism: -10,
                },
                meterDeltas: const <String, int>{'trust': -20},
              ),
            ),
          ],
        ),
        CareerBeat(
          id: 'm5_close',
          kind: CareerBeatKind.decision,
          locationId: 'ed_bay',
          npcId: 'diaz',
          title: 'Safety plan',
          body: 'Diaz: "Did you document AMA risk discussion?"',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'doc',
              label: 'Document conversation + notify provider',
              consequence: CareerConsequence(
                narrative: 'Chart complete. Patient stays for labs.',
                unlockObjectives: const <String>['safety'],
                skillDeltas: const <String, int>{
                  CareerSkillId.professionalism: 8,
                },
                completeMission: true,
              ),
            ),
            CareerChoice(
              id: 'skip_doc',
              label: 'Skip documentation — she\'s calm now',
              consequence: CareerConsequence(
                narrative:
                    'Later dispute. No note. Diaz: "If it isn\'t charted, '
                    'it didn\'t happen."',
                unlockObjectives: const <String>['safety'],
                skillDeltas: const <String, int>{
                  CareerSkillId.professionalism: -8,
                },
                meterDeltas: const <String, int>{'trust': -8},
                completeMission: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Mission 06 Crisis ──────────────────────────────────────
  static CareerMission _m6EdChaos() {
    return CareerMission(
      id: 'nurse_m6_chaos',
      index: 6,
      title: 'Mission 06 — ED Chaos',
      brief: 'Multiple priorities. Timer live. Random events incoming.',
      objective: 'Prioritize under pressure.',
      mode: CareerSimGameMode.crisis,
      trackStage: CareerTrackStage.crisis,
      difficultyStars: 4,
      xpReward: 450,
      requiredCareerLevel: 3,
      startBeatId: 'm6_start',
      startLocationId: 'triage',
      badgeOnClear: 'under_pressure',
      objectives: const <CareerObjective>[
        CareerObjective(id: 'prioritize', label: 'Prioritize correctly'),
        CareerObjective(id: 'survive', label: 'Stabilize the shift'),
      ],
      beats: <CareerBeat>[
        CareerBeat(
          id: 'm6_start',
          kind: CareerBeatKind.timerPressure,
          locationId: 'triage',
          title: 'EMERGENCY · 02:00',
          body:
              'Bay 2 hypotensive. Bay 5 needs meds. Family yelling at desk.\n'
              'Ambulance inbound.\n\n'
              'You have two minutes of decision pressure.',
          timerSeconds: 90,
          randomEventBeatIds: const <String>['m6_ambulance', 'm6_family'],
          choices: <CareerChoice>[
            CareerChoice(
              id: 'sickest',
              label: 'Go to hypotensive Bay 2 first',
              consequence: CareerConsequence(
                narrative:
                    'You choose acuity. Bay 2 gets fluids help. '
                    'Meds wait — correct priority.',
                nextBeatId: 'm6_mid',
                unlockObjectives: const <String>['prioritize'],
                skillDeltas: const <String, int>{
                  CareerSkillId.criticalThinking: 12,
                  CareerSkillId.timeManagement: 10,
                },
                meterDeltas: const <String, int>{'patient': 10, 'trust': 8},
                injectRandomEvent: true,
              ),
            ),
            CareerChoice(
              id: 'loudest',
              label: 'Handle the yelling family first',
              consequence: CareerConsequence(
                narrative:
                    'Family calms. Bay 2 worsens. Diaz: '
                    '"Noise isn\'t acuity."',
                nextBeatId: 'm6_mid',
                skillDeltas: const <String, int>{
                  CareerSkillId.criticalThinking: -6,
                  CareerSkillId.communication: 4,
                },
                meterDeltas: const <String, int>{
                  'patient': -12,
                  'stress': 12,
                  'trust': -6,
                },
                injectRandomEvent: true,
              ),
            ),
            CareerChoice(
              id: 'meds_first',
              label: 'Finish easy meds in Bay 5 first',
              consequence: CareerConsequence(
                narrative: 'Easy work while someone crashes. Costly.',
                nextBeatId: 'm6_mid',
                skillDeltas: const <String, int>{
                  CareerSkillId.criticalThinking: -10,
                  CareerSkillId.timeManagement: -6,
                },
                meterDeltas: const <String, int>{
                  'patient': -15,
                  'trust': -10,
                },
              ),
            ),
          ],
        ),
        CareerBeat(
          id: 'm6_ambulance',
          kind: CareerBeatKind.randomEvent,
          locationId: 'triage',
          title: '🚨 NEW PATIENT ARRIVING',
          body: 'Ambulance: chest pain, diaphoretic, 54M.',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'triage_fast',
              label: 'Rapid triage → monitored bay → notify MD',
              consequence: CareerConsequence(
                narrative: 'STEMI pathway started. Team moves.',
                nextBeatId: 'm6_er',
                skillDeltas: const <String, int>{
                  CareerSkillId.clinicalKnowledge: 8,
                  CareerSkillId.timeManagement: 6,
                },
                meterDeltas: const <String, int>{'trust': 6, 'patient': 6},
              ),
            ),
            CareerChoice(
              id: 'wait_lobby',
              label: 'Send to waiting room — we\'re busy',
              consequence: CareerConsequence(
                narrative: 'Risky delay. Diaz overrides you.',
                nextBeatId: 'm6_er',
                skillDeltas: const <String, int>{
                  CareerSkillId.clinicalKnowledge: -8,
                },
                meterDeltas: const <String, int>{'trust': -10, 'patient': -8},
              ),
            ),
          ],
        ),
        CareerBeat(
          id: 'm6_family',
          kind: CareerBeatKind.randomEvent,
          locationId: 'nurses_station',
          npcId: 'family',
          title: '👨‍👩‍👧 Family upset',
          body: 'Ms. Cole: "Why is nobody updating us?!"',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'update',
              label: '60-second update + promise to return',
              consequence: CareerConsequence(
                narrative: 'Family settles. You return to acuity.',
                nextBeatId: 'm6_er',
                skillDeltas: const <String, int>{
                  CareerSkillId.communication: 8,
                },
                meterDeltas: const <String, int>{'trust': 4},
              ),
            ),
            CareerChoice(
              id: 'snap',
              label: 'Snap: "We\'re busy — wait"',
              consequence: CareerConsequence(
                narrative: 'Complaint brewing. Stress rises.',
                nextBeatId: 'm6_er',
                skillDeltas: const <String, int>{
                  CareerSkillId.communication: -8,
                  CareerSkillId.professionalism: -4,
                },
                meterDeltas: const <String, int>{'stress': 10, 'trust': -6},
              ),
            ),
          ],
        ),
        CareerBeat(
          id: 'm6_mid',
          kind: CareerBeatKind.decision,
          locationId: 'ed_bay',
          title: '⚠️ PATIENT 204 CONDITION CHANGING',
          body: 'SpO₂ falling on your second patient.',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'split',
              label: 'Call for help + stay with sickest + assign meds',
              consequence: CareerConsequence(
                narrative: 'Teamwork. Both fires get water.',
                nextBeatId: 'm6_er',
                skillDeltas: const <String, int>{
                  CareerSkillId.criticalThinking: 8,
                  CareerSkillId.timeManagement: 8,
                  CareerSkillId.professionalism: 4,
                },
                meterDeltas: const <String, int>{'patient': 8, 'trust': 6},
              ),
            ),
            CareerChoice(
              id: 'alone',
              label: 'Try to do everything yourself',
              consequence: CareerConsequence(
                narrative: 'You drown. Quality drops.',
                nextBeatId: 'm6_er',
                skillDeltas: const <String, int>{
                  CareerSkillId.timeManagement: -8,
                },
                meterDeltas: const <String, int>{
                  'stress': 15,
                  'patient': -8,
                },
              ),
            ),
          ],
        ),
        const CareerBeat(
          id: 'm6_er',
          kind: CareerBeatKind.erChallenge,
          locationId: 'ed_bay',
          title: 'Deep clinical challenge',
          body:
              'Enter a full ER case simulation. Stabilize the patient, '
              'then return for your performance report.',
          erCategory: 'Cardiac',
          nextBeatId: 'm6_done',
          continueLabel: 'Enter ER case',
        ),
        CareerBeat(
          id: 'm6_done',
          kind: CareerBeatKind.decision,
          locationId: 'nurses_station',
          npcId: 'diaz',
          title: 'End of surge',
          body: 'Diaz: "Survived the rush?"',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'debrief',
              label: 'Debrief priorities you chose',
              consequence: CareerConsequence(
                narrative: 'Diaz: "That\'s how Charge Nurses are made."',
                unlockObjectives: const <String>['survive'],
                skillDeltas: const <String, int>{
                  CareerSkillId.professionalism: 6,
                },
                completeMission: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Mission 07 Boss ────────────────────────────────────────
  static CareerMission _m7NightBoss() {
    return CareerMission(
      id: 'nurse_m7_night',
      index: 7,
      title: 'BOSS — The Night Shift',
      brief:
          'Multi-patient night. Deterioration, meds, family, doctor calls. '
          'Use everything you learned.',
      objective: 'Complete a simulated night shift.',
      mode: CareerSimGameMode.boss,
      trackStage: CareerTrackStage.boss,
      difficultyStars: 5,
      xpReward: 600,
      requiredCareerLevel: 4,
      startBeatId: 'm7_open',
      startLocationId: 'nurses_station',
      badgeOnClear: 'perfect_shift',
      objectives: const <CareerObjective>[
        CareerObjective(id: 'triage_night', label: 'Manage competing priorities'),
        CareerObjective(id: 'survive_night', label: 'Finish the night safely'),
      ],
      beats: <CareerBeat>[
        const CareerBeat(
          id: 'm7_open',
          kind: CareerBeatKind.cinematic,
          locationId: 'nurses_station',
          title: '11:04 PM · Night Shift',
          body:
              'The ED thins — then fills again.\n\n'
              'Four patients. One nurse student. Diaz on break radio.\n\n'
              'OBJECTIVE: Keep everyone alive until dawn.',
          nextBeatId: 'm7_choice',
          continueLabel: 'Start night shift',
        ),
        CareerBeat(
          id: 'm7_choice',
          kind: CareerBeatKind.decision,
          locationId: 'ed_bay',
          title: 'Everything at once',
          body:
              '• Bay 1: pain meds due\n'
              '• Bay 3: SpO₂ trending down\n'
              '• Desk: Dr. Park calling\n'
              '• Lobby: family demanding update',
          choices: <CareerChoice>[
            CareerChoice(
              id: 'airway',
              label: 'Bay 3 SpO₂ first → call Park → then meds → brief family',
              consequence: CareerConsequence(
                narrative:
                    'Classic priority stack. Night holds. Diaz returns proud.',
                unlockObjectives: const <String>[
                  'triage_night',
                  'survive_night',
                ],
                skillDeltas: const <String, int>{
                  CareerSkillId.criticalThinking: 14,
                  CareerSkillId.timeManagement: 12,
                  CareerSkillId.patientCare: 10,
                  CareerSkillId.communication: 6,
                },
                meterDeltas: const <String, int>{
                  'patient': 12,
                  'trust': 14,
                },
                completeMission: true,
              ),
            ),
            CareerChoice(
              id: 'phone',
              label: 'Answer Park first while SpO₂ falls',
              consequence: CareerConsequence(
                narrative:
                    'Park appreciates the call — then hears the alarm. '
                    '"Why are you on the phone?"',
                unlockObjectives: const <String>['triage_night'],
                skillDeltas: const <String, int>{
                  CareerSkillId.criticalThinking: -6,
                  CareerSkillId.communication: 4,
                },
                meterDeltas: const <String, int>{
                  'patient': -10,
                  'trust': -4,
                  'stress': 12,
                },
                completeMission: true,
              ),
            ),
            CareerChoice(
              id: 'family_first',
              label: 'Long lobby conversation first',
              consequence: CareerConsequence(
                narrative: 'Bay 3 needs rapid response. Hard lesson.',
                failMission: true,
                skillDeltas: const <String, int>{
                  CareerSkillId.criticalThinking: -12,
                  CareerSkillId.patientCare: -10,
                },
                meterDeltas: const <String, int>{
                  'patient': -25,
                  'trust': -15,
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
