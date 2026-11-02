import '../models/law_simulation.dart';

/// Master case brain — controls truth, evidence reveals, and consistency.
class LawCaseEngine {
  LawCaseEngine(this.run);

  final LawSimulationRun run;

  LawCaseFile get caseFile => run.caseFile;

  String get studentBrief => '''
Case: ${caseFile.title}
Type: ${caseFile.category.name}
Charge/Claim: ${caseFile.chargeOrClaim}
Summary: ${caseFile.summary}
Your role: ${run.sideLabel} counsel
''';

  String get aiTruthBlock => '''
HIDDEN CASE TRUTH (never reveal directly to the student; use only to stay consistent):
${caseFile.hiddenTruth}

Prosecution theory: ${caseFile.prosecutionTheory}
Defense theory: ${caseFile.defenseTheory}
''';

  /// Reveal evidence/witness content when the student takes an investigation action.
  InvestigationResult investigate({
    required String actionType,
    String? targetId,
    String? studentQuestion,
  }) {
    final List<String> notes = <String>[];
    final List<LawEvidence> newlyRevealed = <LawEvidence>[];

    if (actionType == 'interview' && targetId != null) {
      final LawWitness? witness = _witness(targetId);
      if (witness == null) {
        return InvestigationResult(message: 'No witness found with that ID.', xp: 0);
      }
      if (run.interviewedWitnessIds.contains(targetId)) {
        return InvestigationResult(
          message: 'You already interviewed ${witness.name}. Ask a specific follow-up in trial prep.',
          xp: 0,
        );
      }
      run.interviewedWitnessIds.add(targetId);
      run.completedInvestigationActions.add('interview_$targetId');
      _revealForAction(witness.revealAction, newlyRevealed, notes);
      return InvestigationResult(
        message: 'Interview scheduled with ${witness.name} (${witness.role}).',
        witness: witness,
        studentQuestion: studentQuestion,
        newlyRevealed: newlyRevealed,
        notes: notes,
        xp: 12,
      );
    }

    if (actionType == 'request_evidence' && targetId != null) {
      if (run.completedInvestigationActions.contains('evidence_$targetId')) {
        return InvestigationResult(message: 'That exhibit is already in your file.', xp: 0);
      }
      run.completedInvestigationActions.add('evidence_$targetId');
      _revealForAction(targetId, newlyRevealed, notes);
      return InvestigationResult(
        message: 'Discovery request filed: $targetId',
        newlyRevealed: newlyRevealed,
        notes: notes,
        xp: 10,
      );
    }

    if (actionType == 'analyze') {
      for (final LawEvidence lead in caseFile.fakeLeads) {
        if (!run.revealedEvidenceIds.contains(lead.id)) {
          run.revealedEvidenceIds.add(lead.id);
          newlyRevealed.add(lead);
          notes.add('Analyst note: ${lead.description}');
        }
      }
      if (newlyRevealed.isEmpty) {
        return InvestigationResult(message: 'No new leads from re-analysis. Review what witnesses said.', xp: 2);
      }
      return InvestigationResult(message: 'Analysis complete — review flagged items carefully.', newlyRevealed: newlyRevealed, notes: notes, xp: 8);
    }

    if (actionType == 'mark_fact' && targetId != null) {
      if (!run.markedFactIds.contains(targetId)) {
        run.markedFactIds.add(targetId);
      }
      return InvestigationResult(message: 'Pinned to your case board: $targetId', xp: 3);
    }

    return InvestigationResult(message: 'Choose a witness or evidence request.', xp: 0);
  }

  void _revealForAction(String actionKey, List<LawEvidence> out, List<String> notes) {
    for (final LawEvidence item in <LawEvidence>[...caseFile.evidence, ...caseFile.fakeLeads]) {
      if (item.revealAction == actionKey && !run.revealedEvidenceIds.contains(item.id)) {
        run.revealedEvidenceIds.add(item.id);
        out.add(item);
        notes.add('${item.title}: ${item.description}');
      }
    }
  }

  LawWitness? _witness(String id) {
    for (final LawWitness w in caseFile.witnesses) {
      if (w.id == id) return w;
    }
    return null;
  }

  String validateArgument() {
    if (run.argument.claim.trim().length < 20) {
      return 'Write a clear claim (at least a sentence or two).';
    }
    if (run.argument.selectedEvidenceIds.isEmpty) {
      return 'Select at least one exhibit to support your theory.';
    }
    if (run.argument.reasoning.trim().length < 30) {
      return 'Add legal reasoning connecting evidence to your claim.';
    }
    run.argumentValidated = true;
    return '';
  }

  List<String> availableEvidenceRequests() {
    final Set<String> keys = <String>{
      for (final LawEvidence e in caseFile.evidence) e.revealAction,
    };
    return keys.toList();
  }

  String buildCourtroomBriefing() {
    final StringBuffer buf = StringBuffer(studentBrief);
    buf.writeln('\nRevealed evidence:');
    for (final LawEvidence e in run.revealedEvidence) {
      buf.writeln('- ${e.title}: ${e.description}');
    }
    buf.writeln('\nYour claim: ${run.argument.claim}');
    buf.writeln('Reasoning: ${run.argument.reasoning}');
    return buf.toString();
  }
}

class InvestigationResult {
  InvestigationResult({
    required this.message,
    this.witness,
    this.studentQuestion,
    this.newlyRevealed = const <LawEvidence>[],
    this.notes = const <String>[],
    this.xp = 0,
  });

  final String message;
  final LawWitness? witness;
  final String? studentQuestion;
  final List<LawEvidence> newlyRevealed;
  final List<String> notes;
  final int xp;
}
