/// Guided Project Lab missions — complete only when step checks pass.
class GuidedProject {
  const GuidedProject({
    required this.id,
    required this.majorId,
    required this.title,
    required this.blurb,
    required this.xpReward,
    required this.steps,
    this.resumeLine,
  });

  final String id;
  final String majorId;
  final String title;
  final String blurb;
  final int xpReward;
  final List<ProjectStep> steps;
  final String? resumeLine;
}

enum ProjectStepKind { choice, codePick, runTests }

class ProjectStep {
  const ProjectStep({
    required this.id,
    required this.title,
    required this.instruction,
    required this.kind,
    required this.options,
    required this.correctOptionId,
    this.coachTip,
  });

  final String id;
  final String title;
  final String instruction;
  final ProjectStepKind kind;
  final List<ProjectOption> options;
  final String correctOptionId;
  final String? coachTip;
}

class ProjectOption {
  const ProjectOption({
    required this.id,
    required this.label,
    this.detail,
  });

  final String id;
  final String label;
  final String? detail;
}

abstract final class ProjectLabCatalog {
  /// Legacy id still counts as completed for résumé gate.
  static const String legacySeId = 'se_auth_notes';
  static const String seLoginApiId = 'se_login_api';

  static List<GuidedProject> forMajor(String majorId) {
    final List<GuidedProject> mine =
        all.where((GuidedProject p) => p.majorId == majorId).toList();
    if (mine.isNotEmpty) return mine;
    return all.where((GuidedProject p) => p.majorId == 'software_engineering').toList();
  }

  static GuidedProject? byId(String id) {
    for (final GuidedProject p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  static final List<GuidedProject> all = <GuidedProject>[
    _seLoginApi,
    _csAlgo,
    _aiModel,
    _dataClean,
    _cyberIncident,
    _itRestore,
    _webResponsive,
    _mobileFlutterFix,
  ];

  static final GuidedProject _seLoginApi = GuidedProject(
    id: seLoginApiId,
    majorId: 'software_engineering',
    title: 'Login API mini-app',
    blurb:
        'Build a small login endpoint: handle missing email, keep valid logins '
        'working, and ship a regression test. Completes only when every check passes.',
    xpReward: 120,
    resumeLine: 'Built a login API with missing-field validation and regression tests',
    steps: <ProjectStep>[
      ProjectStep(
        id: 'spec',
        title: 'Step 1 · Spec the behavior',
        instruction:
            'When the email field is missing, what should the API return?',
        kind: ProjectStepKind.choice,
        correctOptionId: '400',
        coachTip: 'Client errors should be 4xx — missing input is not a 500.',
        options: const <ProjectOption>[
          ProjectOption(
            id: '500',
            label: '500 Internal Server Error',
            detail: 'Crash / unhandled null',
          ),
          ProjectOption(
            id: '400',
            label: '400 Bad Request with a clear message',
            detail: 'Correct client-error contract',
          ),
          ProjectOption(
            id: '200',
            label: '200 OK and invent an email',
            detail: 'Unsafe and wrong',
          ),
        ],
      ),
      ProjectStep(
        id: 'implement',
        title: 'Step 2 · Implement the fix',
        instruction: 'Pick the implementation that guards before calling .lower().',
        kind: ProjectStepKind.codePick,
        correctOptionId: 'guard',
        coachTip: 'Check email is present before calling methods on it.',
        options: const <ProjectOption>[
          ProjectOption(
            id: 'crash',
            label: 'Buggy',
            detail:
                'email = data.get("email").lower()  # crashes when None',
          ),
          ProjectOption(
            id: 'guard',
            label: 'Fixed',
            detail:
                'if not email: return {"error": "..."}, 400\nemail = email.lower()',
          ),
          ProjectOption(
            id: 'ignore',
            label: 'Ignores missing email',
            detail: 'Always continues with empty string',
          ),
        ],
      ),
      ProjectStep(
        id: 'tests',
        title: 'Step 3 · Run regression tests',
        instruction:
            'Choose the test suite result that proves missing email → 400 and valid login → 200.',
        kind: ProjectStepKind.runTests,
        correctOptionId: 'pass',
        coachTip: 'All visible cases must pass before you can ship.',
        options: const <ProjectOption>[
          ProjectOption(
            id: 'fail',
            label: '4 passed, 1 failed',
            detail: 'test_missing_email_returns_400: expected 400, got 500',
          ),
          ProjectOption(
            id: 'pass',
            label: '5 passed, 0 failed',
            detail: 'missing-email + valid login + regression covered',
          ),
          ProjectOption(
            id: 'skip',
            label: '0 tests run',
            detail: 'Skipped tests do not count',
          ),
        ],
      ),
      ProjectStep(
        id: 'ship',
        title: 'Step 4 · Ship checklist',
        instruction: 'Confirm the release checklist matches a complete ship.',
        kind: ProjectStepKind.choice,
        correctOptionId: 'ready',
        coachTip: 'Ship only when spec, fix, and tests all align.',
        options: const <ProjectOption>[
          ProjectOption(
            id: 'wip',
            label: 'Still in progress — merge tomorrow',
          ),
          ProjectOption(
            id: 'ready',
            label: 'Ready: 400 on missing email, valid login works, test added',
          ),
          ProjectOption(
            id: 'force',
            label: 'Force-merge without tests',
          ),
        ],
      ),
    ],
  );

  static final GuidedProject _csAlgo = GuidedProject(
    id: 'cs_two_pointer_design',
    majorId: 'computer_science',
    title: 'Two-pointer algorithm design',
    blurb: 'Design an O(n) approach for a sorted-array target-sum problem.',
    xpReward: 110,
    resumeLine: 'Designed an O(n) two-pointer algorithm with complexity analysis',
    steps: <ProjectStep>[
      ProjectStep(
        id: 'complexity',
        title: 'Step 1 · Complexity goal',
        instruction: 'Target time complexity for sorted pair-sum?',
        kind: ProjectStepKind.choice,
        correctOptionId: 'on',
        options: const <ProjectOption>[
          ProjectOption(id: 'on2', label: 'O(n²) nested loops'),
          ProjectOption(id: 'on', label: 'O(n) two pointers'),
          ProjectOption(id: 'exp', label: 'O(2ⁿ) search'),
        ],
      ),
      ProjectStep(
        id: 'move',
        title: 'Step 2 · Pointer move',
        instruction: 'If sum is too small, which pointer moves?',
        kind: ProjectStepKind.choice,
        correctOptionId: 'left',
        options: const <ProjectOption>[
          ProjectOption(id: 'left', label: 'Advance left pointer'),
          ProjectOption(id: 'right', label: 'Always move right leftward only'),
          ProjectOption(id: 'reset', label: 'Reset both to start'),
        ],
      ),
      ProjectStep(
        id: 'verify',
        title: 'Step 3 · Verify',
        instruction: 'Which check set proves correctness?',
        kind: ProjectStepKind.runTests,
        correctOptionId: 'ok',
        options: const <ProjectOption>[
          ProjectOption(id: 'ok', label: 'All edge cases pass'),
          ProjectOption(id: 'bad', label: 'Fails duplicates case'),
        ],
      ),
    ],
  );

  static final GuidedProject _aiModel = GuidedProject(
    id: 'ai_eval_slice',
    majorId: 'ai_ml',
    title: 'Model evaluation slice',
    blurb: 'Train/eval a tiny classifier and catch class-imbalance mistakes.',
    xpReward: 110,
    resumeLine: 'Evaluated a model with imbalance-aware metrics',
    steps: <ProjectStep>[
      ProjectStep(
        id: 'metric',
        title: 'Step 1 · Pick a metric',
        instruction: 'For rare positive class, prefer:',
        kind: ProjectStepKind.choice,
        correctOptionId: 'f1',
        options: const <ProjectOption>[
          ProjectOption(id: 'acc', label: 'Accuracy only'),
          ProjectOption(id: 'f1', label: 'Precision / recall / F1'),
          ProjectOption(id: 'loss', label: 'Training loss alone'),
        ],
      ),
      ProjectStep(
        id: 'split',
        title: 'Step 2 · Data split',
        instruction: 'How should you split?',
        kind: ProjectStepKind.choice,
        correctOptionId: 'holdout',
        options: const <ProjectOption>[
          ProjectOption(id: 'all', label: 'Train on all data, no holdout'),
          ProjectOption(id: 'holdout', label: 'Train/validation/test holdout'),
        ],
      ),
      ProjectStep(
        id: 'score',
        title: 'Step 3 · Eval gate',
        instruction: 'Ship only if validation F1 clears the bar.',
        kind: ProjectStepKind.runTests,
        correctOptionId: 'pass',
        options: const <ProjectOption>[
          ProjectOption(id: 'pass', label: 'F1 0.81 ≥ 0.75 — pass'),
          ProjectOption(id: 'fail', label: 'F1 0.41 — fail'),
        ],
      ),
    ],
  );

  static final GuidedProject _dataClean = GuidedProject(
    id: 'ds_revenue_clean',
    majorId: 'data_science',
    title: 'Revenue dataset cleanup',
    blurb: 'Clean missing revenue fields and explain a conversion dip.',
    xpReward: 110,
    resumeLine: 'Cleaned a revenue dataset and explained a conversion trend',
    steps: <ProjectStep>[
      ProjectStep(
        id: 'missing',
        title: 'Step 1 · Missing values',
        instruction: 'Best first move for null revenue?',
        kind: ProjectStepKind.choice,
        correctOptionId: 'audit',
        options: const <ProjectOption>[
          ProjectOption(id: 'dropall', label: 'Drop the entire table'),
          ProjectOption(id: 'audit', label: 'Audit rate, then impute or filter with reason'),
          ProjectOption(id: 'zero', label: 'Fill every null with 0 silently'),
        ],
      ),
      ProjectStep(
        id: 'trend',
        title: 'Step 2 · Explain the dip',
        instruction: 'Conversion fell after a tracking change. Likely cause?',
        kind: ProjectStepKind.choice,
        correctOptionId: 'track',
        options: const <ProjectOption>[
          ProjectOption(id: 'track', label: 'Measurement break from tracking change'),
          ProjectOption(id: 'crypto', label: 'Random crypto market only'),
        ],
      ),
      ProjectStep(
        id: 'report',
        title: 'Step 3 · Report gate',
        instruction: 'Which report is complete?',
        kind: ProjectStepKind.runTests,
        correctOptionId: 'ok',
        options: const <ProjectOption>[
          ProjectOption(id: 'ok', label: 'Missing rate + chart + written cause'),
          ProjectOption(id: 'bad', label: 'Chart only, no method notes'),
        ],
      ),
    ],
  );

  static final GuidedProject _cyberIncident = GuidedProject(
    id: 'sec_login_spike',
    majorId: 'cybersecurity',
    title: 'Failed-login spike incident',
    blurb: 'Investigate suspicious logs and pick a remediation.',
    xpReward: 110,
    resumeLine: 'Investigated a failed-login spike and remediated access risk',
    steps: <ProjectStep>[
      ProjectStep(
        id: 'triage',
        title: 'Step 1 · Triage',
        instruction: 'Spike of failed logins from one ASN. First action?',
        kind: ProjectStepKind.choice,
        correctOptionId: 'contain',
        options: const <ProjectOption>[
          ProjectOption(id: 'ignore', label: 'Ignore — probably users'),
          ProjectOption(id: 'contain', label: 'Contain: rate-limit / block ASN, alert'),
        ],
      ),
      ProjectStep(
        id: 'fix',
        title: 'Step 2 · Remediate',
        instruction: 'Hardening step after containment?',
        kind: ProjectStepKind.choice,
        correctOptionId: 'mfa',
        options: const <ProjectOption>[
          ProjectOption(id: 'mfa', label: 'Enforce MFA + review lockouts'),
          ProjectOption(id: 'open', label: 'Disable auth entirely'),
        ],
      ),
      ProjectStep(
        id: 'close',
        title: 'Step 3 · Close ticket',
        instruction: 'Evidence pack ready?',
        kind: ProjectStepKind.runTests,
        correctOptionId: 'ok',
        options: const <ProjectOption>[
          ProjectOption(id: 'ok', label: 'Timeline + IOC + fix verified'),
          ProjectOption(id: 'bad', label: 'Closed with no notes'),
        ],
      ),
    ],
  );

  static final GuidedProject _itRestore = GuidedProject(
    id: 'it_wiki_restore',
    majorId: 'information_technology',
    title: 'Restore internal wiki',
    blurb: 'Resolve a downed wiki service with a documented rollback.',
    xpReward: 110,
    resumeLine: 'Restored an internal wiki service with a verified rollback',
    steps: <ProjectStep>[
      ProjectStep(
        id: 'symptom',
        title: 'Step 1 · Symptoms',
        instruction: 'Wiki returns 502. First check?',
        kind: ProjectStepKind.choice,
        correctOptionId: 'health',
        options: const <ProjectOption>[
          ProjectOption(id: 'health', label: 'Health check, recent deploy, upstream deps'),
          ProjectOption(id: 'rewrite', label: 'Rewrite the wiki from scratch'),
        ],
      ),
      ProjectStep(
        id: 'fix',
        title: 'Step 2 · Fix',
        instruction: 'Bad config in last deploy. Best action?',
        kind: ProjectStepKind.choice,
        correctOptionId: 'rollback',
        options: const <ProjectOption>[
          ProjectOption(id: 'rollback', label: 'Rollback deploy + verify health'),
          ProjectOption(id: 'hope', label: 'Wait overnight'),
        ],
      ),
      ProjectStep(
        id: 'verify',
        title: 'Step 3 · Verify',
        instruction: 'Service green?',
        kind: ProjectStepKind.runTests,
        correctOptionId: 'ok',
        options: const <ProjectOption>[
          ProjectOption(id: 'ok', label: '200 on /health and sample page'),
          ProjectOption(id: 'bad', label: 'Still 502'),
        ],
      ),
    ],
  );

  static final GuidedProject _webResponsive = GuidedProject(
    id: 'web_landing_responsive',
    majorId: 'web_development',
    title: 'Responsive landing section',
    blurb: 'Ship a responsive hero that does not break desktop layout.',
    xpReward: 110,
    resumeLine: 'Shipped a responsive landing section with layout checks',
    steps: <ProjectStep>[
      ProjectStep(
        id: 'layout',
        title: 'Step 1 · Layout approach',
        instruction: 'Best base for stacking on mobile?',
        kind: ProjectStepKind.choice,
        correctOptionId: 'flex',
        options: const <ProjectOption>[
          ProjectOption(id: 'fixed', label: 'Fixed 1200px width only'),
          ProjectOption(id: 'flex', label: 'Flex/grid with breakpoints'),
        ],
      ),
      ProjectStep(
        id: 'a11y',
        title: 'Step 2 · Accessibility',
        instruction: 'CTA button needs:',
        kind: ProjectStepKind.choice,
        correctOptionId: 'label',
        options: const <ProjectOption>[
          ProjectOption(id: 'label', label: 'Visible label + focus state'),
          ProjectOption(id: 'div', label: 'Clickable div with no role'),
        ],
      ),
      ProjectStep(
        id: 'qa',
        title: 'Step 3 · QA gate',
        instruction: 'Pass visual QA?',
        kind: ProjectStepKind.runTests,
        correctOptionId: 'ok',
        options: const <ProjectOption>[
          ProjectOption(id: 'ok', label: 'Mobile + desktop screenshots pass'),
          ProjectOption(id: 'bad', label: 'Horizontal scroll on phone'),
        ],
      ),
    ],
  );

  static final GuidedProject _mobileFlutterFix = GuidedProject(
    id: 'mobile_null_text',
    majorId: 'mobile_development',
    title: 'Flutter null-safe label',
    blurb: 'Fix a Text crash when name is null and add a widget test.',
    xpReward: 110,
    resumeLine: 'Fixed a Flutter null Text crash and added a widget test',
    steps: <ProjectStep>[
      ProjectStep(
        id: 'bug',
        title: 'Step 1 · Reproduce',
        instruction: 'Text(name!) crashes when name is null. Fix?',
        kind: ProjectStepKind.codePick,
        correctOptionId: 'guest',
        options: const <ProjectOption>[
          ProjectOption(id: 'bang', label: 'Keep name! and hope', detail: 'Text(name!)'),
          ProjectOption(
            id: 'guest',
            label: 'Null-safe fallback',
            detail: "Text(name ?? 'Guest')",
          ),
        ],
      ),
      ProjectStep(
        id: 'test',
        title: 'Step 2 · Widget test',
        instruction: 'Which test proves the fix?',
        kind: ProjectStepKind.runTests,
        correctOptionId: 'ok',
        options: const <ProjectOption>[
          ProjectOption(id: 'ok', label: 'Pumps null name → finds Guest'),
          ProjectOption(id: 'bad', label: 'No test added'),
        ],
      ),
      ProjectStep(
        id: 'ship',
        title: 'Step 3 · Ship',
        instruction: 'Ready for review?',
        kind: ProjectStepKind.choice,
        correctOptionId: 'ready',
        options: const <ProjectOption>[
          ProjectOption(id: 'ready', label: 'Fix + test in PR'),
          ProjectOption(id: 'wip', label: 'Push broken main'),
        ],
      ),
    ],
  );
}
