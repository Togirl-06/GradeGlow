/// Pharmacy workplace scenarios (hospital / clinic pharmacy).
///
/// Stations: `dispensing_bench`, `counselling_desk`, `stock_room`.
/// Two scenarios are generated from a seed so the numbers differ.
/// All content is an educational simulation — never real medical advice.
library;

import '../../core/stable_random.dart';
import '../work_task.dart';

const String _ph = 'pharmacist';
const String _note = 'Educational simulation — not real medical advice or real dosing guidance.';

const List<RubricItem> _counsel = <RubricItem>[
  RubricItem('Explains what the medicine is for in plain language', <String>['this medicine', 'this tablet', 'this is for', 'it helps', 'it is used', 'treats', 'to lower', 'to control']),
  RubricItem('Gives clear directions: how much, when, with or without food', <String>['once', 'twice', 'daily', 'a day', 'with food', 'after food', 'before', 'morning', 'every']),
  RubricItem('Mentions the common side effects or warning signs', <String>['side effect', 'may cause', 'dizz', 'drows', 'nausea', 'rash', 'tell us', 'contact']),
  RubricItem('Checks understanding and invites questions', <String>['any questions', 'questions', 'does that make sense', 'can you tell me', 'understand', 'repeat back', 'teach-back']),
];

String _n(num v) => v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

WorkScenario _doseByWeight(int seed) {
  final StableRandom r = StableRandom(seed + 5);
  final int weight = 8 + r.nextInt(30); // kg
  final int mgPerKgDay = <int>[10, 15, 20, 30, 40][r.nextInt(5)];
  final int doses = <int>[2, 3, 4][r.nextInt(3)];
  final double daily = (weight * mgPerKgDay).toDouble();
  final double perDose = daily / doses;
  return WorkScenario(
    id: 'gen:ph_dose:$seed',
    careerId: _ph,
    title: 'Check a weight-based dose',
    brief: 'A prescription for a child has come in. Check the dose before dispensing (fictional drug "Glowmycin").',
    assignedBy: 'Chief Pharmacist',
    station: 'dispensing_bench',
    minutes: 40,
    difficulty: 2,
    skillGain: const <String, double>{'pharmacy': 3.0},
    educationalNote: _note,
    stages: <WorkStage>[
      WorkStage.numeric(
        id: 'ph_dose-$seed-1',
        prompt: 'The child weighs $weight kg. The reference range for Glowmycin is $mgPerKgDay mg/kg/day. What is the total daily dose in mg?',
        answer: daily,
        tolerance: 0.5,
        unit: 'mg',
        explanation: '$weight kg × $mgPerKgDay mg/kg = ${_n(daily)} mg per day.',
      ),
      WorkStage.numeric(
        id: 'ph_dose-$seed-2',
        prompt: 'It is to be given in $doses equal doses a day. How many mg is each dose?',
        answer: perDose,
        tolerance: 0.5,
        unit: 'mg',
        explanation: '${_n(daily)} mg ÷ $doses = ${_n(perDose)} mg per dose.',
      ),
      WorkStage.choice(
        id: 'ph_dose-$seed-3',
        prompt: 'The prescription states ${_n(perDose * 10)} mg per dose. What do you do?',
        options: <String>[
          'Do not dispense: contact the prescriber, explain the calculation and agree a corrected dose',
          'Dispense it; the prescriber must know best',
          'Quietly change the label to the dose you calculated',
          'Halve it and hope that is right',
        ],
        correct: 0,
        explanation: 'A tenfold error is a classic, dangerous slip. Never dispense a dose you believe is wrong, and never change a prescription without the prescriber.',
        notes: <int, String>{1: 'Pharmacists are a safety net; check and query.', 2: 'You cannot alter a prescription yourself.', 3: 'Guessing is never acceptable.'},
      ),
    ],
  );
}

WorkScenario _reorder(int seed) {
  final StableRandom r = StableRandom(seed + 9);
  final int daily = 12 + r.nextInt(40);
  final int lead = 2 + r.nextInt(5);
  final int safety = 20 + r.nextInt(5) * 10;
  final int point = daily * lead + safety;
  final int onHand = point - 15 - r.nextInt(30);
  return WorkScenario(
    id: 'gen:ph_reorder:$seed',
    careerId: _ph,
    title: 'Stock room — when to reorder',
    brief: 'Keep the pharmacy from running out of a fast-moving medicine without over-ordering.',
    assignedBy: 'Pharmacy Technician',
    station: 'stock_room',
    minutes: 35,
    difficulty: 1,
    skillGain: const <String, double>{'pharmacy': 3.0, 'management': 1.0},
    educationalNote: _note,
    stages: <WorkStage>[
      WorkStage.numeric(
        id: 'ph_reorder-$seed-1',
        prompt: 'We use about $daily packs a day. Delivery takes $lead days and we keep $safety packs as a safety buffer. What is the reorder point (packs)?',
        answer: point.toDouble(),
        tolerance: 0.5,
        unit: 'packs',
        explanation: 'Reorder point = daily use × lead time + safety stock = $daily × $lead + $safety = $point.',
      ),
      WorkStage.choice(
        id: 'ph_reorder-$seed-2',
        prompt: 'We have $onHand packs on hand. What should you do?',
        options: <String>[
          'Place an order now — stock is below the reorder point',
          'Wait until it hits zero',
          'Do nothing; deliveries are always early',
          'Borrow from a patient\'s own supply',
        ],
        correct: 0,
        explanation: '$onHand is below $point, so the order is due now, otherwise we risk running out during the delivery lead time.',
        notes: <int, String>{1: 'By then patients would go without.', 2: 'Never assume early deliveries.', 3: 'Dispensed medicine belongs to the patient.'},
      ),
    ],
  );
}

final List<ScenarioGenerator> pharmacyGenerators = <ScenarioGenerator>[
  ScenarioGenerator(id: 'ph_dose', careerId: _ph, build: _doseByWeight),
  ScenarioGenerator(id: 'ph_reorder', careerId: _ph, build: _reorder, maxRank: 4),
];

final List<WorkScenario> pharmacyScenarios = <WorkScenario>[
  WorkScenario(
    id: 'ph_interaction',
    careerId: _ph,
    title: 'Prescription check — drug interaction',
    brief: 'A new prescription for a patient already on warfarin (blood thinner) has arrived: an antibiotic course. Screen it.',
    assignedBy: 'Chief Pharmacist',
    station: 'dispensing_bench',
    minutes: 50,
    difficulty: 2,
    skillGain: const <String, double>{'pharmacy': 3.0, 'clinical': 1.0},
    educationalNote: _note,
    stages: <WorkStage>[
      WorkStage.inspect(
        id: 'ph_interaction-screen',
        prompt: 'Screen the prescription. Choose what you check.',
        items: const <InspectItem>[
          InspectItem(id: 'meds', label: 'Patient\'s current medicines list', reveal: 'On warfarin 5 mg daily and a statin.', value: InspectValue.essential),
          InspectItem(id: 'allergy', label: 'Allergy record', reveal: 'No known drug allergies.', value: InspectValue.essential),
          InspectItem(id: 'inr', label: 'Most recent INR (blood-clotting) result', reveal: 'INR 2.6 last week (target 2–3).', value: InspectValue.essential),
          InspectItem(id: 'interact', label: 'Interaction reference for the new antibiotic', reveal: 'This antibiotic can raise the effect of warfarin and increase bleeding risk — extra monitoring needed.', value: InspectValue.essential),
          InspectItem(id: 'renal', label: 'Kidney function', reveal: 'Normal for age.'),
          InspectItem(id: 'insurance', label: 'Look up the patient\'s holiday plans', reveal: 'Not relevant to the safety of this prescription.', value: InspectValue.wasteful, minutes: 10),
        ],
        explanation: 'Medicines list, allergies, recent INR and an interaction reference are the core of clinical screening.',
      ),
      WorkStage.choice(
        id: 'ph_interaction-act',
        prompt: 'The antibiotic interacts with warfarin. What is the best action?',
        options: <String>[
          'Contact the prescriber, flag the interaction and ask about an alternative or closer INR monitoring before dispensing',
          'Dispense it without comment',
          'Tell the patient to stop their warfarin',
          'Refuse to speak to the prescriber',
        ],
        correct: 0,
        explanation: 'Query the interaction with the prescriber; never stop a medicine on your own authority.',
        notes: <int, String>{1: 'An unflagged interaction can cause serious bleeding.', 2: 'Stopping warfarin suddenly can cause clots.', 3: 'Prescriber and pharmacist work as a team.'},
      ),
      WorkStage.text(
        id: 'ph_interaction-note',
        prompt: 'Document your intervention in the pharmacy record.',
        rubric: const <RubricItem>[
          RubricItem('Names the patient\'s medicine and the new prescription', <String>['warfarin', 'antibiotic']),
          RubricItem('States the problem (interaction / bleeding risk)', <String>['interaction', 'bleed', 'inr']),
          RubricItem('Records who was contacted and what was agreed', <String>['contacted', 'spoke', 'prescriber', 'doctor', 'agreed', 'advised']),
          RubricItem('Records the outcome or follow-up', <String>['monitor', 'follow', 'alternative', 'changed', 'recheck', 'review']),
        ],
        modelAnswer: 'Patient on warfarin prescribed an antibiotic that interacts and raises bleeding risk. I contacted the prescriber, who agreed an alternative antibiotic and an INR recheck in 3 days; patient advised and follow-up recorded.',
        minWords: 20,
      ),
    ],
  ),
  WorkScenario(
    id: 'ph_counsel',
    careerId: _ph,
    title: 'Counselling a new patient',
    brief: 'Mrs. Okoro (72) is starting a new blood-pressure tablet and looks worried. Counsel her.',
    assignedBy: 'Chief Pharmacist',
    station: 'counselling_desk',
    minutes: 45,
    difficulty: 1,
    skillGain: const <String, double>{'pharmacy': 2.5, 'communication': 2.0},
    educationalNote: _note,
    stages: <WorkStage>[
      WorkStage.choice(
        id: 'ph_counsel-open',
        prompt: 'How do you begin the conversation?',
        options: <String>[
          'Greet her, confirm her name, and ask what she already knows about the new tablet',
          'Hand over the bag and say "it\'s all on the leaflet"',
          'Read the whole leaflet aloud quickly',
          'Ask her family member to take the instructions instead',
        ],
        correct: 0,
        explanation: 'Confirm identity and ask what she knows. Build on her understanding.',
        notes: <int, String>{1: 'Leaflets alone do not check understanding.', 2: 'Too much, too fast.', 3: 'Counsel the patient unless she asks otherwise.'},
      ),
      WorkStage.text(
        id: 'ph_counsel-explain',
        prompt: 'Write what you tell Mrs. Okoro in plain language (purpose, how to take it, side effects, check understanding).',
        rubric: _counsel,
        modelAnswer: 'This tablet helps lower your blood pressure. Take one tablet once a day in the morning, with or without food. It may cause dizziness at first, so stand up slowly, and please tell us if you get a rash or swelling. Does that make sense, and do you have any questions? Can you tell me how you will take it?',
        minWords: 25,
      ),
      WorkStage.multi(
        id: 'ph_counsel-safety',
        prompt: 'Which advice should be part of good counselling? (Select all that apply.)',
        options: <String>[
          'Keep taking it even when she feels well',
          'Tell the pharmacist about any other medicines or supplements',
          'Share the tablets with a neighbour who has similar symptoms',
          'Store it safely, away from children',
        ],
        correct: <int>[0, 1, 3],
        explanation: 'Adherence, medicine reconciliation and safe storage matter. Never share prescription medicines.',
        notes: <int, String>{2: 'Sharing prescribed medicine is unsafe.'},
      ),
    ],
  ),
  WorkScenario(
    id: 'ph_dispense_order',
    careerId: _ph,
    title: 'The dispensing workflow',
    brief: 'Put the dispensing steps in the safe order before you start the afternoon queue.',
    assignedBy: 'Pharmacy Technician',
    station: 'dispensing_bench',
    minutes: 30,
    difficulty: 1,
    skillGain: const <String, double>{'pharmacy': 2.5},
    educationalNote: _note,
    stages: <WorkStage>[
      WorkStage.order(
        id: 'ph_dispense_order-1',
        prompt: 'Arrange the steps in the correct order.',
        options: <String>[
          'Receive and check the prescription is valid and complete',
          'Clinically screen it: dose, allergies, interactions',
          'Select and label the medicine; check the name, strength and expiry',
          'A second person (or you, after a pause) checks the product against the prescription',
          'Hand over with counselling and confirm the patient\'s identity',
        ],
        correct: <int>[0, 1, 2, 3, 4],
        explanation: 'Validity → clinical screen → assemble & label → independent check → hand-out with counselling.',
      ),
      WorkStage.choice(
        id: 'ph_dispense_order-2',
        prompt: 'Two medicines on the shelf have very similar names (look-alike, sound-alike). What reduces the chance of a mix-up?',
        options: <String>[
          'Separate them on the shelf, use "tall man" lettering and read the label aloud while checking',
          'Put them side by side so they are easy to find',
          'Work faster so you do not forget',
          'Rely on memory',
        ],
        correct: 0,
        explanation: 'Physical separation and deliberate checks prevent look-alike errors.',
        notes: <int, String>{1: 'Adjacent storage increases picking errors.', 2: 'Rushing raises error risk.', 3: 'Memory is fallible.'},
      ),
    ],
  ),
  WorkScenario(
    id: 'ph_controlled',
    careerId: _ph,
    title: 'Controlled medicines register',
    brief: 'The weekly check of the controlled-medicines cupboard found the count is 2 ampoules short of the register.',
    assignedBy: 'Chief Pharmacist',
    station: 'stock_room',
    minutes: 50,
    difficulty: 3,
    minRank: 1,
    skillGain: const <String, double>{'pharmacy': 3.5, 'management': 1.0},
    educationalNote: _note,
    stages: <WorkStage>[
      WorkStage.choice(
        id: 'ph_controlled-first',
        prompt: 'What is the right first response?',
        options: <String>[
          'Recount with a second person, check recent entries for a recording mistake, and report the discrepancy',
          'Adjust the register to match the cupboard so the books balance',
          'Say nothing; it is only two ampoules',
          'Blame the newest colleague',
        ],
        correct: 0,
        explanation: 'Recount, check for clerical errors, and escalate/report. Never falsify records.',
        notes: <int, String>{1: 'Falsifying a register is serious misconduct.', 2: 'Every discrepancy must be investigated.', 3: 'Do not blame without evidence.'},
      ),
      WorkStage.multi(
        id: 'ph_controlled-steps',
        prompt: 'Which follow-up actions are appropriate? (Select all that apply.)',
        options: <String>[
          'Review the register entries, deliveries and signatures for the period',
          'Complete an incident report and inform the accountable officer',
          'Quietly replace the stock from another ward',
          'Review access arrangements and who holds the keys',
        ],
        correct: <int>[0, 1, 3],
        explanation: 'Investigate transparently, report, and review controls. Never conceal a loss.',
        notes: <int, String>{2: 'Concealing a loss breaks the audit trail.'},
      ),
    ],
  ),
  WorkScenario(
    id: 'ph_adr',
    careerId: _ph,
    title: 'Possible adverse drug reaction',
    brief: 'A patient returns with an itchy rash that started two days after beginning a new antibiotic.',
    assignedBy: 'Chief Pharmacist',
    station: 'counselling_desk',
    minutes: 45,
    difficulty: 2,
    skillGain: const <String, double>{'pharmacy': 3.0, 'clinical': 1.5},
    educationalNote: _note,
    stages: <WorkStage>[
      WorkStage.inspect(
        id: 'ph_adr-assess',
        prompt: 'What do you ask or check?',
        items: const <InspectItem>[
          InspectItem(id: 'timeline', label: 'When the rash started relative to the first dose', reveal: 'Started 2 days after the first dose.', value: InspectValue.essential),
          InspectItem(id: 'breath', label: 'Any swelling of the lips/face or difficulty breathing', reveal: 'No swelling or breathing difficulty — but it is spreading.', value: InspectValue.essential),
          InspectItem(id: 'other', label: 'Other new medicines, foods or products', reveal: 'Nothing else new.', value: InspectValue.essential),
          InspectItem(id: 'history', label: 'Past reactions to similar medicines', reveal: 'Mild rash with a related antibiotic years ago.', value: InspectValue.essential),
          InspectItem(id: 'colour', label: 'Ask her favourite colour', reveal: 'Not clinically relevant.', value: InspectValue.wasteful, minutes: 5),
        ],
        explanation: 'Timing, severity signs, alternative causes and past reactions all help judge an adverse reaction.',
      ),
      WorkStage.choice(
        id: 'ph_adr-act',
        prompt: 'What is the best action?',
        options: <String>[
          'Advise her to see the prescriber today, hold the next dose until advised, report it as a suspected reaction and record the allergy once confirmed',
          'Tell her to keep taking it and ignore the rash',
          'Give her a different antibiotic from the shelf yourself',
          'Tell her it is definitely nothing',
        ],
        correct: 0,
        explanation: 'A spreading rash on a likely culprit needs prompt prescriber review and reporting; you cannot diagnose or switch treatment alone.',
        notes: <int, String>{1: 'Spreading rashes can progress.', 2: 'Only a prescriber can change therapy.', 3: 'False reassurance is unsafe.'},
      ),
    ],
  ),
  WorkScenario(
    id: 'ph_stewardship',
    careerId: _ph,
    title: 'Antibiotic stewardship review',
    brief: 'Review a ward\'s antibiotic list for appropriate use. Principles first, then the call.',
    assignedBy: 'Medical Director',
    station: 'dispensing_bench',
    minutes: 60,
    difficulty: 3,
    minRank: 2,
    skillGain: const <String, double>{'pharmacy': 3.5, 'management': 1.5},
    educationalNote: _note,
    stages: <WorkStage>[
      WorkStage.multi(
        id: 'ph_stewardship-principles',
        prompt: 'Which are good stewardship principles? (Select all that apply.)',
        options: <String>[
          'Take cultures before starting, where possible',
          'Review at 48–72 hours and narrow or stop if appropriate',
          'Always choose the broadest-spectrum drug to be safe',
          'Document the indication and planned duration',
        ],
        correct: <int>[0, 1, 3],
        explanation: 'Right drug, right dose, right duration. Broad-spectrum by default drives resistance.',
        notes: <int, String>{2: 'Unnecessary broad-spectrum use promotes resistance.'},
      ),
      WorkStage.text(
        id: 'ph_stewardship-memo',
        prompt: 'Write a short recommendation to the ward team about a patient on a broad antibiotic for 9 days with a negative culture and no fever.',
        rubric: const <RubricItem>[
          RubricItem('Notes the culture result and the patient\'s improvement', <String>['culture', 'negative', 'afebrile', 'no fever', 'improved', 'well']),
          RubricItem('Recommends stopping or narrowing the antibiotic', <String>['stop', 'narrow', 'discontinue', 'de-escalate', 'switch', 'oral']),
          RubricItem('Gives the reason (resistance, side effects, C. difficile)', <String>['resistance', 'side effect', 'difficile', 'harm', 'unnecessary']),
          RubricItem('Is collaborative: asks the team to review and decide', <String>['please review', 'would you', 'discuss', 'team', 'agree', 'happy to']),
        ],
        modelAnswer: 'The culture is negative and the patient has no fever and has improved after 9 days, so I recommend stopping or narrowing the antibiotic to reduce resistance and side effects such as C. difficile. Please review and let me know if the team agrees; I am happy to discuss.',
        minWords: 25,
      ),
    ],
  ),
  WorkScenario(
    id: 'ph_formulary',
    careerId: _ph,
    title: 'Formulary and budget decision',
    brief: 'The hospital wants a cheaper brand of a common medicine on the formulary. Decide how to evaluate it.',
    assignedBy: 'Medical Director',
    station: 'stock_room',
    minutes: 60,
    difficulty: 3,
    minRank: 3,
    skillGain: const <String, double>{'pharmacy': 3.0, 'management': 2.5},
    educationalNote: _note,
    stages: <WorkStage>[
      WorkStage.multi(
        id: 'ph_formulary-criteria',
        prompt: 'What should the evaluation consider? (Select all that apply.)',
        options: <String>[
          'Evidence that it is equivalent in quality, safety and effectiveness',
          'Supply reliability and shelf life',
          'Only the lowest price',
          'Look-alike packaging risks and staff training needs',
        ],
        correct: <int>[0, 1, 3],
        explanation: 'Cost matters, but never at the expense of quality, supply and safety.',
        notes: <int, String>{2: 'A cheap product that fails or runs out is not cheap.'},
      ),
      WorkStage.numeric(
        id: 'ph_formulary-saving',
        prompt: 'The current brand costs \$4.80 a pack and the new one \$3.60. We use 2,500 packs a year. What is the annual saving in dollars?',
        answer: 3000,
        tolerance: 1,
        unit: '\$',
        explanation: '(4.80 − 3.60) × 2,500 = 1.20 × 2,500 = \$3,000.',
      ),
    ],
  ),
];
