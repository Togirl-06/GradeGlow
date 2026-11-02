import 'package:flutter/material.dart';

enum LawCaseCategory { criminal, civil, school, workplace }

enum LawSimulationPhase { briefing, investigation, argument, courtroom, verdict }

enum LawPartySide { prosecution, defense }

enum LawCourtAction { opening, presentEvidence, crossExamine, objection, closing }

enum LawEvidenceKind {
  photo,
  email,
  medical,
  document,
  expert,
  timeline,
  law,
  other,
}

class LawEvidence {
  const LawEvidence({
    required this.id,
    required this.title,
    required this.description,
    required this.revealAction,
    this.supportsProsecution = true,
    this.isFakeLead = false,
    this.kind = LawEvidenceKind.other,
    this.dateLabel,
    List<String>? probeQuestions,
  }) : _probeQuestions = probeQuestions;

  final String id;
  final String title;
  final String description;
  final String revealAction;
  final bool supportsProsecution;
  final bool isFakeLead;
  final LawEvidenceKind kind;
  final String? dateLabel;
  final List<String>? _probeQuestions;

  /// Null-safe for hot reload after field additions.
  List<String> get probeQuestions => _probeQuestions ?? const <String>[];

  LawEvidenceKind get resolvedKind {
    if (kind != LawEvidenceKind.other) return kind;
    final String t = title.toLowerCase();
    if (t.contains('photo') || t.contains('cctv') || t.contains('camera') || t.contains('footage')) {
      return LawEvidenceKind.photo;
    }
    if (t.contains('email') || t.contains('fax') || t.contains('text') || t.contains('notification')) {
      return LawEvidenceKind.email;
    }
    if (t.contains('medical') || t.contains('er ') || t.contains('hospital') || t.contains('injury')) {
      return LawEvidenceKind.medical;
    }
    if (t.contains('expert') || t.contains('forensic') || t.contains('analysis') || t.contains('audit')) {
      return LawEvidenceKind.expert;
    }
    if (t.contains('timeline') || t.contains('log') || t.contains('dispatch')) {
      return LawEvidenceKind.timeline;
    }
    if (t.contains('statute') || t.contains('policy') || t.contains('code') || t.contains('treaty') || t.contains('permit')) {
      return LawEvidenceKind.law;
    }
    return LawEvidenceKind.document;
  }
}

class LawWitness {
  const LawWitness({
    required this.id,
    required this.name,
    required this.role,
    required this.bias,
    required this.personality,
    required this.knowledge,
    required this.revealAction,
  });

  final String id;
  final String name;
  final String role;
  final String bias;
  final String personality;
  final List<String> knowledge;
  final String revealAction;
}

class LawInvestigationAction {
  const LawInvestigationAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.hint,
  });

  final String id;
  final String label;
  final IconData icon;
  final String hint;
}

class LawCaseFile {
  const LawCaseFile({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.summary,
    required this.chargeOrClaim,
    required this.hiddenTruth,
    required this.prosecutionTheory,
    required this.defenseTheory,
    required this.evidence,
    required this.fakeLeads,
    required this.witnesses,
    required this.investigationActions,
    required this.openingPoliceReport,
    this.specializationId,
    this.specializationName,
    this.caseNumber,
    this.badgeName,
    this.learningGoal,
    this.xpReward,
    List<String>? narrativeBeats,
  }) : _narrativeBeats = narrativeBeats;

  final String id;
  final String title;
  final LawCaseCategory category;
  final int difficulty;
  final int estimatedMinutes;
  final String summary;
  final String chargeOrClaim;
  final String hiddenTruth;
  final String prosecutionTheory;
  final String defenseTheory;
  final List<LawEvidence> evidence;
  final List<LawEvidence> fakeLeads;
  final List<LawWitness> witnesses;
  final List<LawInvestigationAction> investigationActions;
  final String openingPoliceReport;
  /// Links this courtroom case to a Law School specialization track.
  final String? specializationId;
  final String? specializationName;
  final String? caseNumber;
  final String? badgeName;
  final String? learningGoal;
  final int? xpReward;
  final List<String>? _narrativeBeats;

  /// Null-safe for hot reload after field additions.
  List<String> get narrativeBeats => _narrativeBeats ?? const <String>[];

  String get displayTrack => specializationName ?? _fallbackTrack;

  String get displayCaseNumber =>
      caseNumber ?? 'Case #${2026000 + (id.hashCode.abs() % 900)}';

  String get displayBadge => badgeName ?? _defaultBadge;

  String get displayLearningGoal =>
      learningGoal ?? 'Apply $displayTrack doctrine through investigation, briefing, and courtroom advocacy.';

  int get displayXp => xpReward ?? (120 + difficulty * 110 + evidence.length * 15);

  String get difficultyLabel => switch (difficulty) {
        1 => 'Beginner',
        2 => 'Intermediate',
        3 => 'Advanced',
        _ => 'Expert',
      };

  int get photoCount =>
      evidence.where((LawEvidence e) => e.resolvedKind == LawEvidenceKind.photo).length;
  int get emailCount =>
      evidence.where((LawEvidence e) => e.resolvedKind == LawEvidenceKind.email).length;
  int get medicalCount =>
      evidence.where((LawEvidence e) => e.resolvedKind == LawEvidenceKind.medical).length;
  int get documentCount => evidence.length;

  String get _defaultBadge => switch (specializationId) {
        'torts' => 'Consumer Protector',
        'criminal_law' => 'Truth Seeker',
        'contracts' => 'Deal Enforcer',
        'family_law' => 'Child Advocate',
        'constitutional_law' => 'Rights Defender',
        'corporate_law' => 'Fiduciary Watch',
        'ip_law' => 'IP Guardian',
        'environmental_law' => 'Earth Counsel',
        _ => 'Case Closer',
      };

  String get _fallbackTrack => switch (category) {
        LawCaseCategory.criminal => 'Criminal',
        LawCaseCategory.civil => 'Civil',
        LawCaseCategory.school => 'School',
        LawCaseCategory.workplace => 'Workplace',
      };
}

class LawArgumentDraft {
  LawArgumentDraft({
    this.claim = '',
    this.reasoning = '',
    List<String>? selectedEvidenceIds,
  }) : selectedEvidenceIds = selectedEvidenceIds ?? <String>[];

  String claim;
  String reasoning;
  List<String> selectedEvidenceIds;
}

class LawCourtTurn {
  const LawCourtTurn({
    required this.speaker,
    required this.text,
    required this.isUser,
  });

  final String speaker;
  final String text;
  final bool isUser;
}

class LawVerdictBreakdown {
  const LawVerdictBreakdown({
    required this.logic,
    required this.evidenceUse,
    required this.persuasion,
    required this.accuracy,
    required this.overall,
    required this.ruling,
    required this.summary,
    required this.weakPoints,
    required this.keyEvidence,
    required this.xpEarned,
  });

  factory LawVerdictBreakdown.fromJson(Map<String, dynamic> json) {
    int score(dynamic v) => (v as num?)?.round().clamp(0, 100) ?? 0;
    return LawVerdictBreakdown(
      logic: score(json['logic']),
      evidenceUse: score(json['evidenceUse']),
      persuasion: score(json['persuasion']),
      accuracy: score(json['accuracy']),
      overall: score(json['overall'] ?? json['score']),
      ruling: (json['ruling'] as String?)?.trim() ?? 'Hung jury — review the record.',
      summary: (json['summary'] as String?)?.trim() ?? '',
      weakPoints: ((json['weakPoints'] as List<dynamic>?) ?? <dynamic>[]).map((dynamic e) => '$e').toList(),
      keyEvidence: ((json['keyEvidence'] as List<dynamic>?) ?? <dynamic>[]).map((dynamic e) => '$e').toList(),
      xpEarned: (json['xpEarned'] as num?)?.round() ?? 40,
    );
  }

  final int logic;
  final int evidenceUse;
  final int persuasion;
  final int accuracy;
  final int overall;
  final String ruling;
  final String summary;
  final List<String> weakPoints;
  final List<String> keyEvidence;
  final int xpEarned;
}

class LawPlayerProgress {
  LawPlayerProgress({
    this.xp = 0,
    this.level = 1,
    this.rankTitle = 'Law Student',
    this.casesWon = 0,
    this.casesPlayed = 0,
    this.continueCaseId,
    this.continuePhase,
  });

  int xp;
  int level;
  String rankTitle;
  int casesWon;
  int casesPlayed;
  String? continueCaseId;
  LawSimulationPhase? continuePhase;

  void addXp(int amount) {
    xp += amount;
    while (xp >= level * 120) {
      xp -= level * 120;
      level += 1;
      rankTitle = switch (level) {
        <= 2 => 'Law Student',
        <= 4 => 'Junior Associate',
        <= 6 => 'Trial Attorney',
        <= 8 => 'Senior Counsel',
        _ => 'Master Advocate',
      };
    }
  }
}

class LawSimulationRun {
  LawSimulationRun({
    required this.caseFile,
    required this.side,
    this.phase = LawSimulationPhase.briefing,
    this.isDailyCase = false,
  });

  final LawCaseFile caseFile;
  final LawPartySide side;
  final bool isDailyCase;
  LawSimulationPhase phase;
  final Set<String> revealedEvidenceIds = <String>{};
  final Set<String> interviewedWitnessIds = <String>{};
  final Set<String> completedInvestigationActions = <String>{};
  final List<String> markedFactIds = <String>[];
  final List<String> attorneyNotes = <String>[];
  final List<LawCourtTurn> courtroomTranscript = <LawCourtTurn>[];
  final List<LawCourtTurn> interviewTranscript = <LawCourtTurn>[];
  LawArgumentDraft argument = LawArgumentDraft();
  int investigationXp = 0;
  bool argumentValidated = false;
  bool briefingComplete = false;
  int professorQuizIndex = 0;
  bool professorQuizAnswered = false;

  List<LawEvidence> get revealedEvidence => <LawEvidence>[
        ...caseFile.evidence.where((LawEvidence e) => revealedEvidenceIds.contains(e.id)),
        ...caseFile.fakeLeads.where((LawEvidence e) => revealedEvidenceIds.contains(e.id)),
      ];

  String get sideLabel => side == LawPartySide.prosecution ? 'Plaintiff / Prosecution' : 'Defense / Respondent';

  String get opponentLabel => side == LawPartySide.prosecution ? 'Defense Counsel' : 'Plaintiff Counsel';

  String get shortSideLabel => side == LawPartySide.prosecution ? 'Plaintiff' : 'Defense';
}
