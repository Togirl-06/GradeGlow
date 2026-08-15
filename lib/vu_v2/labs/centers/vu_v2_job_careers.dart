import '../vu_v2_lab_models.dart';

/// One playable choice in a job shift (not a quiz — a workplace action).
class VuV2JobChoice {
  const VuV2JobChoice({
    required this.label,
    required this.result,
    this.deltaTrust = 0,
    this.deltaStress = 0,
    this.deltaQuality = 0,
    this.deltaPatient = 0,
    this.nextBeatId,
    this.failShift = false,
    this.winShift = false,
  });

  final String label;
  final String result;
  final int deltaTrust; // boss / charge nurse trust
  final int deltaStress;
  final int deltaQuality; // work quality / accuracy
  final int deltaPatient; // patient / client wellbeing (− bad, + good)
  final String? nextBeatId;
  final bool failShift;
  final bool winShift;
}

class VuV2JobBeat {
  const VuV2JobBeat({
    required this.id,
    required this.title,
    required this.scene,
    required this.choices,
  });

  final String id;
  final String title;
  final String scene;
  final List<VuV2JobChoice> choices;
}

class VuV2JobLevel {
  const VuV2JobLevel({
    required this.id,
    required this.levelNumber,
    required this.title,
    required this.brief,
    required this.roleMoment,
    required this.beats,
    required this.startBeatId,
  });

  final String id;
  final int levelNumber;
  final String title;
  final String brief;
  final String roleMoment;
  final List<VuV2JobBeat> beats;
  final String startBeatId;

  VuV2JobBeat beat(String id) =>
      beats.firstWhere((VuV2JobBeat b) => b.id == id, orElse: () => beats.first);
}

class VuV2JobCareer {
  const VuV2JobCareer({
    required this.school,
    required this.jobTitle,
    required this.workplace,
    required this.bossName,
    required this.tagline,
    required this.levels,
  });

  final VuV2LabSchool school;
  final String jobTitle;
  final String workplace;
  final String bossName;
  final String tagline;
  final List<VuV2JobLevel> levels;
}

abstract final class VuV2JobCareers {
  static VuV2JobCareer forSchool(VuV2LabSchool school) {
    switch (school) {
      case VuV2LabSchool.nursing:
        return _nursing;
      case VuV2LabSchool.physics:
        return _physics;
      case VuV2LabSchool.chemistry:
        return _chemistry;
      case VuV2LabSchool.biology:
        return _biology;
      case VuV2LabSchool.psychology:
        return _psychology;
      case VuV2LabSchool.mathematics:
        return _math;
      case VuV2LabSchool.business:
      case VuV2LabSchool.computerScience:
        return _nursing; // unused — hub routes elsewhere
    }
  }

  static const VuV2JobCareer _nursing = VuV2JobCareer(
    school: VuV2LabSchool.nursing,
    jobTitle: 'Student Nurse',
    workplace: 'Riverside Med · Floor 4',
    bossName: 'Charge Nurse Diaz',
    tagline: 'Real patients. Real vitals. Your license is on the line.',
    levels: <VuV2JobLevel>[
      VuV2JobLevel(
        id: 'nurse_l1',
        levelNumber: 1,
        title: 'Night shift · Bay 3',
        brief: 'Mr. Cole, 62, post-op. SpO₂ dipping. Diaz is watching.',
        roleMoment: 'You are the nurse at the bedside — not a quiz taker.',
        startBeatId: 'n1_arrive',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'n1_arrive',
            title: 'Hand-off',
            scene:
                'Bay 3. Mr. Cole: HR 118, SpO₂ 89%, RR 28, anxious. '
                'Monitor beeping. Diaz: "You own this patient. Don\'t make me regret staffing you."',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Stay at bedside — check airway/breathing, raise HOB, get SpO₂ trend',
                result: 'You stay. SpO₂ ticks to 90%. Cole calms a little. Diaz nods once.',
                deltaTrust: 8,
                deltaPatient: 12,
                deltaStress: 5,
                nextBeatId: 'n1_act',
              ),
              VuV2JobChoice(
                label: 'Finish charting in the hallway first — alarms can wait',
                result: 'Two minutes later SpO₂ 86%. Cole panicking. Diaz appears: "NOW."',
                deltaTrust: -15,
                deltaPatient: -18,
                deltaStress: 12,
                nextBeatId: 'n1_act',
              ),
              VuV2JobChoice(
                label: 'Tell him to walk it off down the hall',
                result: 'Unsafe. He nearly drops. Rapid response almost called on YOUR shift.',
                deltaTrust: -25,
                deltaPatient: -30,
                deltaStress: 20,
                failShift: true,
              ),
            ],
          ),
          VuV2JobBeat(
            id: 'n1_act',
            title: 'Intervene',
            scene:
                'Cole still working hard to breathe. You have oxygen available per protocol. '
                'Family is calling from the waiting room.',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Apply O₂ per protocol, stay, reassess in 5',
                result: 'SpO₂ climbs to 94%. RR eases. You document the response.',
                deltaTrust: 12,
                deltaPatient: 20,
                deltaQuality: 10,
                nextBeatId: 'n1_boss',
              ),
              VuV2JobChoice(
                label: 'Leave to update family before treating',
                result: 'Family calm, patient worse. Diaz: "Patient first. Always."',
                deltaTrust: -10,
                deltaPatient: -12,
                nextBeatId: 'n1_boss',
              ),
            ],
          ),
          VuV2JobBeat(
            id: 'n1_boss',
            title: 'Diaz check-in',
            scene:
                'Diaz at the door: "Talk to me. What did you do and what are the numbers now?"',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Report vitals trend + actions + plan to keep monitoring',
                result: 'Diaz: "That\'s a nurse. Level cleared. Don\'t get cocky."',
                deltaTrust: 15,
                deltaQuality: 12,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Shrug — "He seems fine now"',
                result: 'Diaz pulls you offline. Incomplete hand-off = failed shift.',
                deltaTrust: -20,
                failShift: true,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'nurse_l2',
        levelNumber: 2,
        title: 'Crash risk · Post-op chest pain',
        brief: 'Sudden dizziness and chest pressure. Clock is live.',
        roleMoment: 'Escalate or lose the patient.',
        startBeatId: 'n2_pain',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'n2_pain',
            title: 'Call light',
            scene:
                'Ms. Park, POD1. "Pressure on my chest… dizzy." BP 88/54, pale, sweaty.',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Call rapid response, stay, get O₂ sat, keep her in bed',
                result: 'Team inbound. You stay locked on ABCs.',
                deltaTrust: 10,
                deltaPatient: 15,
                nextBeatId: 'n2_orders',
              ),
              VuV2JobChoice(
                label: 'Wait 20 minutes — maybe gas pain',
                result: 'BP tanks. You burned the golden window.',
                deltaTrust: -18,
                deltaPatient: -25,
                nextBeatId: 'n2_orders',
              ),
              VuV2JobChoice(
                label: 'Send her to the bathroom alone to "settle"',
                result: 'Found on the floor. Night over — fail.',
                deltaPatient: -40,
                failShift: true,
              ),
            ],
          ),
          VuV2JobBeat(
            id: 'n2_orders',
            title: 'Team arrives',
            scene: 'Rapid response asks what you already did and what you need.',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Clear concise SBAR + stay for assist',
                result: 'Team moves fast. Patient stabilizes. Diaz later: "You earned Level 3."',
                deltaTrust: 18,
                deltaQuality: 15,
                deltaPatient: 10,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Freeze and wait for someone else to speak',
                result: 'Chaos. Patient lives, but your eval takes a hit — shift fail.',
                deltaTrust: -12,
                failShift: true,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'nurse_l3',
        levelNumber: 3,
        title: 'Charge test · Two patients',
        brief: 'Bay 2 alarm + Bay 5 family meltdown. You can\'t clone yourself.',
        roleMoment: 'Prioritize like a charge nurse.',
        startBeatId: 'n3_split',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'n3_split',
            title: 'Split attention',
            scene:
                'Bay 2 SpO₂ 87% alarming. Bay 5 family screaming about wait times. '
                'Aide asks which way you go.',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Bay 2 first — delegate family to aide with a time promise',
                result: 'Clinical first. Family gets a plan. Both fires cool.',
                deltaTrust: 14,
                deltaPatient: 16,
                deltaQuality: 10,
                nextBeatId: 'n3_end',
              ),
              VuV2JobChoice(
                label: 'Argue with family first to "de-escalate"',
                result: 'Bay 2 desats further. Diaz pulls you into the med room.',
                deltaTrust: -16,
                deltaPatient: -20,
                failShift: true,
              ),
            ],
          ),
          VuV2JobBeat(
            id: 'n3_end',
            title: 'End of shift',
            scene: 'Diaz: "You prioritized correctly under noise. That\'s the job."',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Clock out with a clean hand-off',
                result: 'Promotion track unlocked in this career path.',
                deltaTrust: 10,
                winShift: true,
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static const VuV2JobCareer _physics = VuV2JobCareer(
    school: VuV2LabSchool.physics,
    jobTitle: 'Lab Technician',
    workplace: 'University Physics Bay',
    bossName: 'Dr. Okonkwo (PI)',
    tagline: 'Boss wants data that survives peer review — tonight.',
    levels: <VuV2JobLevel>[
      VuV2JobLevel(
        id: 'phys_l1',
        levelNumber: 1,
        title: 'Drop tower deadline',
        brief: 'Grant visit tomorrow. Okonkwo wants Earth vs Moon g comparison logged.',
        roleMoment: 'You run the apparatus. The PI grades your judgment.',
        startBeatId: 'p1_brief',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'p1_brief',
            title: 'Morning stand-up',
            scene:
                'Okonkwo: "Visitors at 9. I need two g settings, fall times, and a one-line claim. '
                'Do NOT hand me vibes."',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Run Earth 9.8 then Moon 1.6 — log both times before chatting',
                result: 'Clean comparison. Numbers on the board.',
                deltaQuality: 15,
                deltaTrust: 8,
                nextBeatId: 'p1_boss',
              ),
              VuV2JobChoice(
                label: 'Guess the trend without running the drop',
                result: 'Okonkwo: "This is a lab, not a podcast." Fail.',
                deltaTrust: -20,
                failShift: true,
              ),
            ],
          ),
          VuV2JobBeat(
            id: 'p1_boss',
            title: 'PI review',
            scene: 'Okonkwo scans your log: "What is the claim?"',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Higher g → shorter fall time — here are the two trials',
                result: 'PI softens. "Level 1 clear. Don\'t disappear before the visit."',
                deltaTrust: 14,
                deltaQuality: 10,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Blame the equipment and leave early',
                result: 'Bad optics. Shift failed.',
                deltaTrust: -18,
                failShift: true,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'phys_l2',
        levelNumber: 2,
        title: 'Circuit bay · Safety hold',
        brief: 'Undergrad almost closed a live loop wrong. You are senior on the bench.',
        roleMoment: 'Protect people, then the data.',
        startBeatId: 'p2_spark',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'p2_spark',
            title: 'Near miss',
            scene: 'Intern reaches for both switches at once on a miswired demo.',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Kill power, explain open vs closed path, re-run safely',
                result: 'No injuries. Okonkwo hears and marks trust up.',
                deltaTrust: 16,
                deltaQuality: 12,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Laugh it off and keep filming for TikTok',
                result: 'Near miss report. You\'re benched.',
                deltaTrust: -25,
                failShift: true,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'phys_l3',
        levelNumber: 3,
        title: 'Range demo for donors',
        brief: 'Projectile bay. Donors want a show. PI wants science, not circus.',
        roleMoment: 'Balance spectacle and integrity.',
        startBeatId: 'p3_demo',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'p3_demo',
            title: 'Live demo',
            scene: 'Donor asks you to "make it go as far as possible, fake it if needed."',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Tune angle near 45°, show real trials, explain air drag limits',
                result: 'Honest wow. PI: "That\'s how we keep funding."',
                deltaTrust: 18,
                deltaQuality: 15,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Lie about the numbers to impress them',
                result: 'Okonkwo overhears. Career bruise — fail.',
                deltaTrust: -30,
                failShift: true,
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static const VuV2JobCareer _chemistry = VuV2JobCareer(
    school: VuV2LabSchool.chemistry,
    jobTitle: 'Junior Chemist',
    workplace: 'Helix Synthesis Lab',
    bossName: 'Supervisor Mara',
    tagline: 'Yield, safety, and a boss who hates shortcuts.',
    levels: <VuV2JobLevel>[
      VuV2JobLevel(
        id: 'chem_l1',
        levelNumber: 1,
        title: 'Batch 17 · Color change',
        brief: 'Mara needs a clean reaction run before noon QC.',
        roleMoment: 'You own the beaker.',
        startBeatId: 'c1',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'c1',
            title: 'Hood time',
            scene: 'Reagents ready. Mara: "PPE on. Add A, then B. Log what you see."',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Goggles on — add A then B — watch product cue — log it',
                result: 'Batch looks right. Mara initials your sheet.',
                deltaTrust: 12,
                deltaQuality: 14,
                nextBeatId: 'c1b',
              ),
              VuV2JobChoice(
                label: 'Skip goggles to "save time"',
                result: 'Mara shuts the hood. Fail.',
                deltaTrust: -25,
                failShift: true,
              ),
            ],
          ),
          VuV2JobBeat(
            id: 'c1b',
            title: 'QC ping',
            scene: 'QC asks if you are limiting-reagent aware on this ratio.',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Explain which reagent caps yield and why you logged volumes',
                result: 'QC smiles. Level clear.',
                deltaTrust: 10,
                deltaQuality: 12,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Say "it always works" and leave',
                result: 'Mara calls you back. Fail.',
                deltaTrust: -15,
                failShift: true,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'chem_l2',
        levelNumber: 2,
        title: 'Titration under pressure',
        brief: 'Endpoint in 12 minutes or the line stalls.',
        roleMoment: 'Slow near the flip — or overshoot and eat the cost.',
        startBeatId: 'c2',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'c2',
            title: 'Burette',
            scene: 'Color about to flip. Mara watching the clock AND your hands.',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Dropwise near endpoint — stop on color change — record mL',
                result: 'Within tolerance. Production continues.',
                deltaTrust: 16,
                deltaQuality: 18,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Dump base fast to beat the clock',
                result: 'Overshoot. Batch rework. Fail.',
                deltaTrust: -14,
                deltaQuality: -20,
                failShift: true,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'chem_l3',
        levelNumber: 3,
        title: 'pH crisis on the line',
        brief: 'Product reading acidic. Boss wants a call in 5 minutes.',
        roleMoment: 'Diagnose, don\'t panic-pour.',
        startBeatId: 'c3',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'c3',
            title: 'War room',
            scene: 'pH 3.2 when spec is ~7. Mara: "Fix it without creating a new hazard."',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Measure, neutralize carefully toward 7, re-check, report numbers',
                result: 'Line recovers. Mara: "You think like a chemist."',
                deltaTrust: 20,
                deltaQuality: 16,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Pour random base until it "looks fine"',
                result: 'Overshoot to 11. Worse. Fail.',
                failShift: true,
                deltaTrust: -20,
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static const VuV2JobCareer _biology = VuV2JobCareer(
    school: VuV2LabSchool.biology,
    jobTitle: 'Research Assistant',
    workplace: 'Genome & Cell Suite',
    bossName: 'PI Dr. Reyes',
    tagline: 'Wet lab truth > pretty slides.',
    levels: <VuV2JobLevel>[
      VuV2JobLevel(
        id: 'bio_l1',
        levelNumber: 1,
        title: 'Lab meeting in 40 minutes',
        brief: 'Reyes wants organelle roles straight before slides go up.',
        roleMoment: 'You prep like staff, not a student bluffing.',
        startBeatId: 'b1',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'b1',
            title: 'Microscope bay',
            scene: 'Reyes: "If you mix up nucleus and mitochondria on stage, you\'re done today."',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Review cell map — nucleus=DNA, mitochondria=ATP — annotate slide',
                result: 'Clean talking points. Reyes relaxes.',
                deltaTrust: 12,
                deltaQuality: 14,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Wing it with buzzwords',
                result: 'Called out mid-meeting. Fail.',
                failShift: true,
                deltaTrust: -18,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'bio_l2',
        levelNumber: 2,
        title: 'DNA desk · Contaminated sample',
        brief: 'Base pairing run looks wrong. Boss smells a mistake.',
        roleMoment: 'Find the error before it ships.',
        startBeatId: 'b2',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'b2',
            title: 'Sequence QC',
            scene: 'Complement strand has an A paired with G. Reyes is CC\'d on the email.',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Halt export — fix pairing (A-T, C-G) — re-run — notify Reyes',
                result: 'Caught before publication risk. Trust up.',
                deltaTrust: 18,
                deltaQuality: 16,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Send anyway — "deadlines"',
                result: 'Reyes freezes your badge access. Fail.',
                failShift: true,
                deltaTrust: -28,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'bio_l3',
        levelNumber: 3,
        title: 'Ecology model for grant',
        brief: 'Predator-prey sim must explain a population crash to funders.',
        roleMoment: 'Tell the causal story without lying.',
        startBeatId: 'b3',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'b3',
            title: 'Grant zoom',
            scene: 'Funder: "Why did prey crash last season in your model?"',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Show predator spike → delayed prey drop — advance seasons live',
                result: 'Funders get it. Reyes: "That\'s staff-level."',
                deltaTrust: 16,
                deltaQuality: 18,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Blame "randomness" and close the laptop',
                result: 'Grant cools. Fail.',
                failShift: true,
                deltaTrust: -16,
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static const VuV2JobCareer _psychology = VuV2JobCareer(
    school: VuV2LabSchool.psychology,
    jobTitle: 'Research Assistant',
    workplace: 'Cognitive Science Lab',
    bossName: 'Dr. Patel',
    tagline: 'Subjects, bias, and a PI who catches sloppy methods.',
    levels: <VuV2JobLevel>[
      VuV2JobLevel(
        id: 'psy_l1',
        levelNumber: 1,
        title: 'Memory span intake',
        brief: 'Participant is nervous. Patel wants clean protocol.',
        roleMoment: 'Run the study like staff.',
        startBeatId: 'y1',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'y1',
            title: 'Consent bay',
            scene: 'Subject jokes: "Just tell me the answers." Patel is behind the glass.',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Hold protocol — explain task — no coaching answers — record honestly',
                result: 'Valid data. Patel: "Good."',
                deltaTrust: 14,
                deltaQuality: 14,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Whisper hints so they "feel successful"',
                result: 'Data ruined. Fail.',
                failShift: true,
                deltaTrust: -22,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'psy_l2',
        levelNumber: 2,
        title: 'Attention shift · False alarms',
        brief: 'Vigilance task. Intern keeps clicking everything.',
        roleMoment: 'Train without shaming.',
        startBeatId: 'y2',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'y2',
            title: 'Control room',
            scene: 'Intern false-alarm rate is sky high. Patel: "Fix the criterion."',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Coach: respond only to TARGET — practice two clean blocks',
                result: 'False alarms drop. Level clear.',
                deltaTrust: 12,
                deltaQuality: 15,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Yell until they cry',
                result: 'HR incident. Fail.',
                failShift: true,
                deltaTrust: -20,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'psy_l3',
        levelNumber: 3,
        title: 'Bias meeting with hospital partner',
        brief: 'Partner trusts a vivid anecdote over base rates.',
        roleMoment: 'Protect good science in the room.',
        startBeatId: 'y3',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'y3',
            title: 'Stakeholder table',
            scene:
                'Partner: "This one patient story proves the test is perfect." Patel eyes you.',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Bring base rate + false positives into the decision calmly',
                result: 'Partner updates. Patel: "That\'s why you\'re on this grant."',
                deltaTrust: 20,
                deltaQuality: 16,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Agree to keep the peace',
                result: 'Bad policy risk. Patel benches you. Fail.',
                failShift: true,
                deltaTrust: -18,
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static const VuV2JobCareer _math = VuV2JobCareer(
    school: VuV2LabSchool.mathematics,
    jobTitle: 'Modeling Intern',
    workplace: 'Quant Desk · Northbridge',
    bossName: 'Lead Analyst Cho',
    tagline: 'Bosses want models that survive a meeting.',
    levels: <VuV2JobLevel>[
      VuV2JobLevel(
        id: 'math_l1',
        levelNumber: 1,
        title: 'Pricing line · y = mx + b',
        brief: 'Cho needs slope/intercept explained before client call.',
        roleMoment: 'You are on the hook live.',
        startBeatId: 'm1',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'm1',
            title: 'War room',
            scene: 'Client: "What happens if we raise the intercept?" Cho looks at you.',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Slide b up on the graph — show vertical shift — speak in money terms',
                result: 'Client gets it. Cho: "Keep going."',
                deltaTrust: 14,
                deltaQuality: 14,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Mumble formulas with no graph',
                result: 'Client lost. Fail.',
                failShift: true,
                deltaTrust: -16,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'math_l2',
        levelNumber: 2,
        title: 'Risk desk · Discriminant',
        brief: 'Quadratic payoff model. Cho asks if real roots exist.',
        roleMoment: 'Δ decides the story.',
        startBeatId: 'm2',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'm2',
            title: 'Live model',
            scene: 'Cho: "If Δ goes negative, what do you tell the desk?"',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'No real break-even in this regime — show the parabola live',
                result: 'Desk trusts you. Level clear.',
                deltaTrust: 16,
                deltaQuality: 16,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Invent two roots to look smart',
                result: 'Caught. Fail.',
                failShift: true,
                deltaTrust: -24,
              ),
            ],
          ),
        ],
      ),
      VuV2JobLevel(
        id: 'math_l3',
        levelNumber: 3,
        title: 'Coin desk · Bad sample',
        brief: 'Junior claims "guaranteed heads" after 5 flips. Boss is furious.',
        roleMoment: 'Kill superstition with the law of large numbers.',
        startBeatId: 'm3',
        beats: <VuV2JobBeat>[
          VuV2JobBeat(
            id: 'm3',
            title: 'Floor argument',
            scene: 'Junior: "It\'s due." Cho: "Educate them or I will."',
            choices: <VuV2JobChoice>[
              VuV2JobChoice(
                label: 'Run bulk flips — show p drift to ~0.5 — kill the gambler\'s fallacy',
                result: 'Floor learns. Cho: "That\'s why interns get offers."',
                deltaTrust: 18,
                deltaQuality: 18,
                winShift: true,
              ),
              VuV2JobChoice(
                label: 'Side with the superstition to be liked',
                result: 'Cho cuts your hours. Fail.',
                failShift: true,
                deltaTrust: -20,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
