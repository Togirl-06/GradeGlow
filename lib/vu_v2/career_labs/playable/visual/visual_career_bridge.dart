import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import 'visual_lab_catalog.dart';
import 'visual_lab_models.dart';
import 'visual_lab_runner.dart';

const String _visualBayId = 'visual_bay';

const PlayableRoom _visualBayRoom = PlayableRoom(
  id: _visualBayId,
  name: 'Visual Lab Bay',
  icon: '🔬',
  blurb: 'Diagrams, instruments, models — hands-on work.',
  atmosphere:
      'This is where you manipulate the subject matter — label, measure, assemble, interpret.',
);

/// Appends interactive visual labs + practical career exam stages.
PlayableCareer augmentCareerWithVisualLabs(PlayableCareer career) {
  final List<PlayableStage> extra = visualStagesForCareer(career.id);
  if (extra.isEmpty) return career;

  final bool hasBay =
      career.rooms.any((PlayableRoom r) => r.id == _visualBayId);
  final List<PlayableRoom> rooms = hasBay
      ? career.rooms
      : <PlayableRoom>[...career.rooms, _visualBayRoom];

  return PlayableCareer(
    id: career.id,
    accent: career.accent,
    bg: career.bg,
    surface: career.surface,
    workplaceName: career.workplaceName,
    clockLine: career.clockLine,
    roleTitle: career.roleTitle,
    supervisorName: career.supervisorName,
    supervisorRole: career.supervisorRole,
    hireTagline: career.hireTagline,
    supervisorBrief: career.supervisorBrief,
    enterCta: career.enterCta,
    startCta: career.startCta,
    startLocationId: career.startLocationId,
    rooms: rooms,
    stages: <PlayableStage>[...career.stages, ...extra],
    roleGlyph: career.roleGlyph,
    supervisorGlyph: career.supervisorGlyph,
    liveLabel: career.liveLabel,
    ambientFeed: career.ambientFeed,
    meterLabels: career.meterLabels,
  );
}

/// Build PlayableStages from the visual catalog for a career.
List<PlayableStage> visualStagesForCareer(String careerId) {
  final List<VisualLabSpec> labs = VisualLabCatalog.forCareer(careerId);
  final List<VisualLabSpec> exams =
      VisualLabCatalog.practicalExams(careerId: careerId);

  final List<PlayableStage> out = <PlayableStage>[];
  String? priorUnlock;

  for (int i = 0; i < labs.length; i++) {
    final VisualLabSpec lab = labs[i];
    out.add(
      PlayableStage(
        id: lab.id,
        locationId: _visualBayId,
        bannerTitle: _kindBanner(lab.kind),
        bannerBody: lab.brief,
        cta: _kindCta(lab.kind),
        unlockKey: '${lab.id}_done',
        requiresKey: priorUnlock,
      ),
    );
    priorUnlock = '${lab.id}_done';
  }

  for (final VisualLabSpec exam in exams) {
    out.add(
      PlayableStage(
        id: exam.id,
        locationId: _examLocation(careerId),
        bannerTitle: 'PRACTICAL CAREER EXAM',
        bannerBody: exam.brief,
        cta: 'Begin practical exam',
        unlockKey: '${exam.id}_done',
        requiresKey: priorUnlock,
      ),
    );
  }
  return out;
}

/// Returns true/false if [stage] is a visual lab; null if not visual.
Future<bool?> tryRunVisualStage(
  BuildContext context,
  PlayableStage stage,
) async {
  final VisualLabSpec? spec = VisualLabCatalog.byId(stage.id);
  if (spec == null) return null;
  return runVisualLab(context, spec);
}

String _kindBanner(VisualLabKind k) {
  switch (k) {
    case VisualLabKind.identify:
      return 'IDENTIFY';
    case VisualLabKind.label:
      return 'LABEL';
    case VisualLabKind.assemble:
      return 'ASSEMBLE';
    case VisualLabKind.measure:
      return 'MEASURE';
    case VisualLabKind.observe:
      return 'OBSERVE';
    case VisualLabKind.graph:
      return 'GRAPH';
    case VisualLabKind.interpret:
      return 'INTERPRET';
    case VisualLabKind.prioritize:
      return 'PRIORITIZE';
    case VisualLabKind.pathTrace:
      return 'TRACE PATH';
    case VisualLabKind.imagingAnnotate:
      return 'IMAGING';
  }
}

String _kindCta(VisualLabKind k) {
  switch (k) {
    case VisualLabKind.identify:
    case VisualLabKind.label:
      return 'Open diagram';
    case VisualLabKind.assemble:
      return 'Build it';
    case VisualLabKind.measure:
      return 'Use instrument';
    case VisualLabKind.observe:
      return 'Run observation';
    case VisualLabKind.graph:
      return 'Open graph lab';
    case VisualLabKind.interpret:
      return 'Interpret findings';
    case VisualLabKind.prioritize:
      return 'Set priorities';
    case VisualLabKind.pathTrace:
      return 'Trace pathway';
    case VisualLabKind.imagingAnnotate:
      return 'Open imaging';
  }
}

String _examLocation(String careerId) {
  switch (careerId) {
    case 'medicine':
      return 'clinic_bay';
    case 'nursing_ed':
      return 'ed_bay';
    case 'law_firm':
      return 'courtroom';
    default:
      return _visualBayId;
  }
}
