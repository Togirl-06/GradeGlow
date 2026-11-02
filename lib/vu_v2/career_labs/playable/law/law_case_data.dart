/// Hale v. Northline Delivery — playable Law Lab case content.
library;

enum LawEvidenceTag { none, important, irrelevant, needsVerification }

enum LawDocKind { report, contract, email, statement, photo, medical, note }

class LawFact {
  const LawFact({
    required this.id,
    required this.topic,
    required this.revealText,
    required this.keywords,
    required this.critical,
    this.vagueReply =
        'I\'m not sure how that helps. Can we stick to what happened?',
  });

  final String id;
  final String topic;
  final String revealText;
  final List<String> keywords;
  final bool critical;
  final String vagueReply;
}

class LawDocument {
  const LawDocument({
    required this.id,
    required this.title,
    required this.kind,
    required this.body,
    required this.timelineHint,
    this.defaultTag = LawEvidenceTag.none,
  });

  final String id;
  final String title;
  final LawDocKind kind;
  final String body;
  final String timelineHint;
  final LawEvidenceTag defaultTag;
}

class LawChatLine {
  const LawChatLine({required this.fromStudent, required this.text});

  final bool fromStudent;
  final String text;
}

/// Scripted client that unlocks facts by keyword — not a quiz.
class LawClientInterviewEngine {
  LawClientInterviewEngine({this.clientName = 'Jordan Hale'});

  final String clientName;
  final List<LawChatLine> transcript = <LawChatLine>[];
  final Set<String> revealedFactIds = <String>{};
  int irrelevantAsks = 0;

  static const List<LawFact> facts = <LawFact>[
    LawFact(
      id: 'what',
      topic: 'What happened',
      revealText:
          'I slipped on the loading dock at Northline. I was carrying a pallet '
          'jack and went down hard on my back. Their supervisor saw me fall.',
      keywords: <String>[
        'what happened',
        'what happen',
        'accident',
        'crash',
        'fall',
        'slip',
        'injury event',
        'tell me',
      ],
      critical: true,
    ),
    LawFact(
      id: 'when',
      topic: 'When',
      revealText:
          'It was March 14th, around 4:20 in the afternoon. End of my route.',
      keywords: <String>['when', 'date', 'time', 'march', 'day'],
      critical: true,
    ),
    LawFact(
      id: 'where',
      topic: 'Where',
      revealText:
          'Northline warehouse — Dock 3. The floor by the bay door was wet.',
      keywords: <String>['where', 'location', 'dock', 'warehouse', 'place'],
      critical: true,
    ),
    LawFact(
      id: 'injury',
      topic: 'Injury',
      revealText:
          'Lower back. I went to the ER that night. They said soft-tissue '
          'injury, maybe a disc. I still can\'t lift.',
      keywords: <String>[
        'injur',
        'hurt',
        'pain',
        'hospital',
        'er',
        'back',
        'medical',
      ],
      critical: true,
    ),
    LawFact(
      id: 'witness',
      topic: 'Witnesses',
      revealText:
          'Priya from receiving saw me go down. She said she\'d write a statement '
          'if anyone asked.',
      keywords: <String>['witness', 'see', 'saw', 'anyone', 'who saw', 'priya'],
      critical: true,
    ),
    LawFact(
      id: 'contract',
      topic: 'Contract status',
      revealText:
          'They call me an independent contractor. I signed something in January. '
          'They control my routes and my hours though.',
      keywords: <String>[
        'contract',
        'employee',
        'contractor',
        'agreement',
        'hired',
        'w-2',
        '1099',
      ],
      critical: true,
    ),
    LawFact(
      id: 'prior',
      topic: 'Prior notice',
      revealText:
          'A week before, someone emailed ops about water pooling at Dock 3. '
          'Nothing changed.',
      keywords: <String>[
        'email',
        'warn',
        'wet',
        'before',
        'prior',
        'notice',
        'complain',
      ],
      critical: true,
    ),
    LawFact(
      id: 'offer',
      topic: 'Settlement offer',
      revealText:
          'HR called and offered two thousand dollars if I signed a release. '
          'I said no.',
      keywords: <String>['offer', 'settle', 'money', 'release', 'hr', 'pay'],
      critical: false,
    ),
  ];

  int get criticalRevealed => facts
      .where((LawFact f) => f.critical && revealedFactIds.contains(f.id))
      .length;

  int get criticalTotal => facts.where((LawFact f) => f.critical).length;

  void start() {
    if (transcript.isNotEmpty) return;
    transcript.add(
      LawChatLine(
        fromStudent: false,
        text:
            'Hi… I\'m $clientName. Maya said you\'d take my statement. '
            'I don\'t really know how this works. Where do I start?',
      ),
    );
  }

  /// Returns client reply after student question.
  String ask(String raw) {
    final String q = raw.trim();
    if (q.isEmpty) return '';
    transcript.add(LawChatLine(fromStudent: true, text: q));
    final String lower = q.toLowerCase();

    LawFact? hit;
    for (final LawFact f in facts) {
      if (revealedFactIds.contains(f.id)) continue;
      for (final String k in f.keywords) {
        if (lower.contains(k)) {
          hit = f;
          break;
        }
      }
      if (hit != null) break;
    }

    String reply;
    if (hit != null) {
      revealedFactIds.add(hit.id);
      reply = hit.revealText;
    } else if (_isGreeting(lower)) {
      reply =
          'Thanks for seeing me. I\'m nervous. Ask whatever you need about the accident.';
    } else if (_isHowAreYou(lower)) {
      reply = 'Sore. Scared I\'ll lose the work. Mostly I want someone to take this seriously.';
    } else {
      irrelevantAsks++;
      reply = _vague(lower);
    }

    transcript.add(LawChatLine(fromStudent: false, text: reply));
    return reply;
  }

  bool _isGreeting(String lower) =>
      lower.contains('hello') ||
      lower.contains('hi ') ||
      lower == 'hi' ||
      lower.contains('good morning') ||
      lower.contains('introduce');

  bool _isHowAreYou(String lower) =>
      lower.contains('how are you') || lower.contains('how do you feel');

  String _vague(String lower) {
    if (lower.length < 8) {
      return 'Could you ask that more specifically? I want to get this right.';
    }
    if (irrelevantAsks >= 3) {
      return 'I feel like we\'re circling. Can we talk about what happened at the warehouse?';
    }
    return 'I\'m not sure that helps my case. What else do you need about the incident?';
  }

  /// Intake quality: 0–100 from facts + completeness keywords in summary fields.
  int scoreIntake({
    required String factsText,
    required String timelineText,
    required String peopleText,
    required String issuesText,
    required String missingText,
  }) {
    double score = (criticalRevealed / criticalTotal) * 55;
    score += _filled(factsText) * 9;
    score += _filled(timelineText) * 9;
    score += _filled(peopleText) * 9;
    score += _filled(issuesText) * 9;
    score += _filled(missingText) * 9;
    if (factsText.toLowerCase().contains('dock') ||
        factsText.toLowerCase().contains('northline')) {
      score += 5;
    }
    if (issuesText.toLowerCase().contains('negligen') ||
        issuesText.toLowerCase().contains('contractor') ||
        issuesText.toLowerCase().contains('premises')) {
      score += 8;
    }
    return score.clamp(0, 100).round();
  }

  double _filled(String t) => t.trim().length >= 12 ? 1 : (t.trim().isEmpty ? 0 : 0.4);

  String mayaReview(int intakeScore) {
    if (intakeScore >= 80 && criticalRevealed >= criticalTotal - 1) {
      return 'Solid intake. You pulled the dock, timing, injury, and the wet-floor email. '
          'Case file is on your desk. Tag what matters — don\'t drown in paper.';
    }
    if (intakeScore >= 55) {
      return 'Usable start, but you left gaps. Check the case file carefully — '
          'what you missed in interview may be sitting in a document.';
    }
    return 'Thin interview. The client walked out more confused than when they walked in. '
          'Still — open the case file. Recover what you can from the papers.';
  }
}

abstract final class LawCaseVault {
  static const String caseCaption = 'Hale v. Northline Delivery Co.';

  static const List<LawDocument> documents = <LawDocument>[
    LawDocument(
      id: 'police',
      title: 'Police / Incident Report',
      kind: LawDocKind.report,
      timelineHint: 'Mar 14 · Incident logged',
      body:
          'INCIDENT REPORT — City PD\n'
          'Date: March 14\n'
          'Location: Northline Delivery warehouse, Dock 3\n'
          'Complainant: Jordan Hale\n'
          'Narrative: Hale reported slip-and-fall near bay door. Floor described '
          'as wet. No citation issued. Photos taken by responding officer.\n'
          'Witness listed: P. Singh (receiving).',
    ),
    LawDocument(
      id: 'contract',
      title: 'Independent Contractor Agreement',
      kind: LawDocKind.contract,
      timelineHint: 'Jan 8 · Contract signed',
      body:
          'NORTHLINE DELIVERY — INDEPENDENT CONTRACTOR AGREEMENT\n'
          'Signed: January 8\n'
          'Party: Jordan Hale\n'
          '§3 Company sets routes, delivery windows, and uniform requirements.\n'
          '§7 Hale provides own vehicle; Northline provides scanning device.\n'
          '§12 Hale waives certain workplace claims “to the extent permitted by law.”\n'
          'NOTE: Control factors may support employee misclassification analysis.',
    ),
    LawDocument(
      id: 'email_wet',
      title: 'Internal email — wet floor Dock 3',
      kind: LawDocKind.email,
      timelineHint: 'Mar 7 · Wet-floor warning',
      body:
          'From: ops-safety@northline.example\n'
          'To: warehouse-leads@northline.example\n'
          'Date: March 7\n'
          'Subject: Water pooling at Dock 3 again\n\n'
          'Please put cones out. We\'ve had two near-misses this month. '
          'Facilities still hasn\'t fixed the roof drip above bay 3.',
    ),
    LawDocument(
      id: 'witness',
      title: 'Witness statement — P. Singh',
      kind: LawDocKind.statement,
      timelineHint: 'Mar 15 · Witness statement',
      body:
          'I saw Jordan slip near Dock 3 around 4:20. There was water by the door. '
          'A supervisor walked over after. Nobody put out a wet-floor sign that afternoon.',
    ),
    LawDocument(
      id: 'photo',
      title: 'Photograph — Dock 3 floor',
      kind: LawDocKind.photo,
      timelineHint: 'Mar 14 · Photo of Dock 3',
      body:
          '[PHOTO DESCRIPTION]\n'
          'Bay door open. Dark water sheen on concrete. No caution cone visible. '
          'Pallet jack tipped nearby. Timestamp watermark: 16:22.',
    ),
    LawDocument(
      id: 'medical',
      title: 'ER discharge summary',
      kind: LawDocKind.medical,
      timelineHint: 'Mar 14 · ER visit',
      body:
          'ED VISIT — March 14, 21:10\n'
          'CC: Lower back pain after fall at work\n'
          'Impression: Lumbar strain; disc injury not excluded\n'
          'Plan: NSAIDs, follow-up ortho, work restrictions: no lifting >10 lb',
    ),
    LawDocument(
      id: 'offer',
      title: 'HR email — \$2,000 release offer',
      kind: LawDocKind.email,
      timelineHint: 'Mar 18 · Settlement offer',
      body:
          'From: hr@northline.example\n'
          'Subject: Goodwill offer\n\n'
          'We can provide \$2,000 as a one-time payment if you sign the enclosed '
          'general release. Please respond within five days.',
    ),
  ];
}
