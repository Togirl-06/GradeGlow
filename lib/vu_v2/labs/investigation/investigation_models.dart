import '../../curriculum/academic_quality_contract.dart';
import '../../../data/university_learning_engine.dart';

enum InvestigationKind {
  biologyCell,
  chemistryTitration,
  physicsGravity,
  clinicalEd,
  businessHq,
  lawTrial,
  generic,
}

enum LabPhase {
  briefing,
  bench,
  analysis,
  report,
  debrief,
}

class InvestigationSpec {
  const InvestigationSpec({
    required this.kind,
    required this.title,
    required this.role,
    required this.scenario,
    required this.objectives,
    required this.equipment,
    required this.safety,
    required this.procedure,
    required this.environment,
    required this.beats,
  });

  final InvestigationKind kind;
  final String title;
  final String role;
  final String scenario;
  final List<String> objectives;
  final List<String> equipment;
  final String safety;
  final List<String> procedure;
  final String environment;
  final List<String> beats;

  LabQualityReport get quality => LabQualityContract.inspectSpec(
        InvestigationSpecLike(
          scenario: scenario,
          objectives: objectives,
          equipment: equipment,
          procedure: procedure,
          beats: beats,
        ),
      );
}

abstract final class InvestigationCatalog {
  static InvestigationKind kindFor({
    required String subjectId,
    required String topicTitle,
    String labId = '',
  }) {
    final String s = '${subjectId}_${topicTitle}_$labId'.toLowerCase();
    if (s.contains('law') ||
        s.contains('contract') ||
        s.contains('tort') ||
        s.contains('evidence') ||
        s.contains('hearing')) {
      return InvestigationKind.lawTrial;
    }
    if (s.contains('bus') ||
        s.contains('revenue') ||
        s.contains('market') ||
        s.contains('financ') ||
        s.contains('account') ||
        s.contains('company')) {
      return InvestigationKind.businessHq;
    }
    if (s.contains('nurs') ||
        s.contains('medicine') ||
        s.contains('chest') ||
        s.contains('cardiac') ||
        s.contains('vital') ||
        s.contains('triage') ||
        s.contains('ed')) {
      return InvestigationKind.clinicalEd;
    }
    if (s.contains('gravity') ||
        s.contains('free fall') ||
        s.contains('kinematic') ||
        s.contains('physics')) {
      return InvestigationKind.physicsGravity;
    }
    if (s.contains('titrat') ||
        s.contains('acid-base') ||
        s.contains('molarity') ||
        s.contains('chemistry')) {
      return InvestigationKind.chemistryTitration;
    }
    if (s.contains('cell') ||
        s.contains('membrane') ||
        s.contains('microscop') ||
        s.contains('bio') ||
        s.contains('anatomy') ||
        s.contains('skelet')) {
      return InvestigationKind.biologyCell;
    }
    return InvestigationKind.generic;
  }

  static InvestigationSpec forLesson({
    required String subjectId,
    required String courseTitle,
    required String topicTitle,
    required UniversityLabLink link,
    required int level,
  }) {
    final InvestigationKind kind = kindFor(
      subjectId: subjectId,
      topicTitle: topicTitle,
      labId: link.labId,
    );
    return spec(kind, courseTitle, topicTitle, link.title, level);
  }

  static InvestigationSpec spec(
    InvestigationKind kind,
    String course,
    String topic,
    String labTitle,
    int level,
  ) {
    switch (kind) {
      case InvestigationKind.biologyCell:
        return InvestigationSpec(
          kind: kind,
          title: labTitle.trim().isEmpty
              ? 'Unknown cell investigation'
              : labTitle,
          role: 'Junior laboratory technician',
          scenario:
              'A research team received an unlabeled biological specimen. '
              'Your job is to determine what type of cell you have been given. '
              'You may not skip focusing the microscope to click an organelle name. '
              'Course: $course. Topic: $topic.',
          objectives: const <String>[
            'Prepare and focus the specimen in magnification order',
            'Record structures actually in the field',
            'State a cell-type hypothesis with a reason',
            'Test the hypothesis against further evidence',
            'Submit a complete laboratory report',
          ],
          equipment: const <String>[
            'Compound microscope',
            'Prepared slides',
            'Staining solution',
            'Specimen samples',
            'Ocular micrometer',
            'Laboratory notebook',
          ],
          safety:
              'Treat every slide as potentially contaminated. Do not drag 40× across an unfocused field. '
              'If the simulation pauses, identify what went wrong before continuing.',
          procedure: level >= 3
              ? const <String>[
                  'You have the problem, not a recipe. Decide the order of operations.',
                ]
              : const <String>[
                  'Select the unknown slide — not the blank.',
                  'Place it on the stage.',
                  'Start at 4×. Coarse focus, then fine. Light the field.',
                  'Move to 10×, then 40× only after the image is already sharp.',
                  'Observe, label what you see, hypothesize, then request more evidence.',
                ],
          environment: 'Teaching laboratory · wet bench · microscope station',
          beats: LabQualityContract.requiredBeats,
        );
      case InvestigationKind.chemistryTitration:
        return InvestigationSpec(
          kind: kind,
          title: labTitle.trim().isEmpty ? 'Acid–base titration' : labTitle,
          role: 'Analytical chemistry student',
          scenario:
              'You received an unknown monoprotic acid. Determine its concentration using standardized 0.1000 M NaOH. '
              'Overshooting the endpoint does not erase the trial. $course · $topic.',
          objectives: const <String>[
            'Prepare glassware so dilution is not invented',
            'Record initial and final burette volumes',
            'Approach the endpoint without “fixing” an overshoot',
            'Calculate molarity with shown algebra',
            'Discuss error in the report',
          ],
          equipment: const <String>[
            'Burette',
            'Erlenmeyer flask',
            'Pipette',
            'Phenolphthalein',
            'Standardized NaOH',
            'Unknown acid',
            'Balance',
            'Lab bench',
          ],
          safety:
              'NaOH is corrosive. Keep the burette over the bench. Do not mouth-pipette. '
              'If you pass the endpoint, the instructor will stop you — the trial still stands.',
          procedure: level >= 3
              ? const <String>['Plan a titration. The bench will not narrate the SOP.']
              : const <String>[
                  'Rinse glassware with the solution it will hold.',
                  'Fill the burette; clear the tip bubble.',
                  'Record initial volume. Pipette the unknown. Add indicator.',
                  'Titrate dropwise near pink. Record final volume. Repeat if needed. Calculate M.',
                ],
          environment: 'Quantitative analysis lab · fume-aware wet bench',
          beats: LabQualityContract.requiredBeats,
        );
      case InvestigationKind.physicsGravity:
        return InvestigationSpec(
          kind: kind,
          title: labTitle.trim().isEmpty ? 'Determine g from free fall' : labTitle,
          role: 'Introductory physics student',
          scenario:
              'Measure free-fall times from a known height. The simulator will not give you 9.81 on every trial. '
              'Your job is a table, a calculated g, a graph, and an error story. $course · $topic.',
          objectives: const <String>[
            'Collect at least five trials',
            'Calculate g = 2h/t² for each and the mean',
            'Graph the scatter',
            'Explain departure from 9.81 m/s²',
          ],
          equipment: const <String>[
            'Meter stick',
            'Stopwatch',
            'Falling mass',
            'Motion tracker',
            'Notebook',
          ],
          safety:
              'Clear the drop zone. Do not stand under the mass. Report timing limits honestly.',
          procedure: level >= 3
              ? const <String>['Design the measurement. Five trials minimum.']
              : const <String>[
                  'Measure height.',
                  'Drop and time. Repeat five times.',
                  'Compute g each time, then the mean and percent error.',
                ],
          environment: 'Mechanics bay · drop tower',
          beats: LabQualityContract.requiredBeats,
        );
      case InvestigationKind.clinicalEd:
        return InvestigationSpec(
          kind: kind,
          title: labTitle.trim().isEmpty
              ? 'Emergency department — chest discomfort'
              : labTitle,
          role: 'Junior clinician under supervision',
          scenario:
              '54-year-old man, chest discomfort. The patient will change if you stall. '
              'This is not a quiz about normal heart rate. $course · $topic.',
          objectives: const <String>[
            'Prioritize actions that change the next ten minutes',
            'Obtain vitals, history, and an ECG',
            'Call for help when the pattern is ACS-range',
            'Write a clinical reasoning report',
          ],
          equipment: const <String>[
            'Monitor',
            'Stethoscope',
            'ECG machine',
            'Chart',
            'Crash cart',
            'Supervising physician',
          ],
          safety:
              'Airway, breathing, circulation before trivia. Missing an ECG while the patient holds his chest will pause the case.',
          procedure: level >= 3
              ? const <String>['You have a patient. Decide.']
              : const <String>[
                  'Vitals and ABC glance.',
                  'Symptom and pain assessment; history.',
                  'Cardiovascular exam; ECG; labs as indicated.',
                  'Call the supervising physician; write the reasoning.',
                ],
          environment: 'Emergency department bay 3',
          beats: LabQualityContract.requiredBeats,
        );
      case InvestigationKind.businessHq:
        return InvestigationSpec(
          kind: kind,
          title: labTitle.trim().isEmpty ? 'Company HQ — revenue decline' : labTitle,
          role: 'Junior business analyst',
          scenario:
              'You were hired yesterday. Quarterly revenue is down 18%. The CEO wants a cause by Friday. '
              'Averages lie. $course · $topic.',
          objectives: const <String>[
            'Disaggregate until a mechanism appears',
            'Use more than one dashboard',
            'Recommend a decision',
            'Forecast a consequence if you are wrong',
          ],
          equipment: const <String>[
            'Sales dashboard',
            'Financial statements',
            'Customer data',
            'Employee reports',
            'Regional performance',
            'Marketing spend',
            'Competitor file',
          ],
          safety:
              'Do not brief the CEO on a company-level percentage. That is malpractice in this lab.',
          procedure: level >= 3
              ? const <String>['Investigate. The files are on the drive.']
              : const <String>[
                  'Open region before product; product before anecdotes.',
                  'Read complaints against the price-change date.',
                  'Choose a management action and live with the projection.',
                ],
          environment: 'Company HQ · strategy room',
          beats: LabQualityContract.requiredBeats,
        );
      case InvestigationKind.lawTrial:
        return InvestigationSpec(
          kind: kind,
          title: labTitle.trim().isEmpty ? 'Trial preparation' : labTitle,
          role: 'Junior associate',
          scenario:
              'The firm received a new case. You have a complaint, witnesses, a contract, emails, a photograph, a police report, a statute, and a precedent. '
              'Define consideration is not the assignment. $course · $topic.',
          objectives: const <String>[
            'Determine what happened and what is disputed',
            'Spot legal issues and admissibility problems',
            'Write argument and counterargument',
            'Survive a short simulated hearing',
          ],
          equipment: const <String>[
            'Complaint',
            'Witness statements',
            'Contract',
            'Emails',
            'Photograph',
            'Police report',
            'Statute',
            'Precedent memo',
          ],
          safety:
              'Do not offer a photograph to inflame. Flag prejudice vs probative value.',
          procedure: level >= 3
              ? const <String>['Read the file. The hearing is this afternoon.']
              : const <String>[
                  'Read every exhibit.',
                  'Issue-spot; flag one admissibility problem.',
                  'Write analysis, argument, counter, conclusion.',
                  'Enter the hearing.',
                ],
          environment: 'Law firm war room → simulated hearing',
          beats: LabQualityContract.requiredBeats,
        );
      case InvestigationKind.generic:
        return InvestigationSpec(
          kind: kind,
          title: labTitle.trim().isEmpty
              ? 'Unknown-sample investigation'
              : labTitle,
          role: 'Junior investigator',
          scenario:
              'You received an unknown related to $topic in $course. Your job is to observe, measure, decide, and report — not to click the answer key.',
          objectives: const <String>[
            'Calibrate before you trust a number',
            'Collect repeated measurements',
            'State a hypothesis you could abandon',
            'Analyze scatter and write a report',
          ],
          equipment: const <String>[
            'Calibrated instrument',
            'Unknown sample',
            'Timer',
            'Notebook',
            'Reference table',
          ],
          safety:
              'Skipping calibration makes later data unreliable. The lab will remember.',
          procedure: level >= 3
              ? const <String>['You have an unknown. Design the work.']
              : const <String>[
                  'Calibrate.',
                  'Five observations.',
                  'Hypothesis with a reason.',
                  'Analysis and report.',
                ],
          environment: 'Teaching laboratory · general bench',
          beats: LabQualityContract.requiredBeats,
        );
    }
  }
}
