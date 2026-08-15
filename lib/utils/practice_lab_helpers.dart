import '../models/ai_practice_mode.dart';
import '../models/practice_lab.dart';

/// Practice labs use simple chat (no live avatar / immersive scene).
bool usesLiveAiCharacter(String majorId, {String? groupId}) => false;

/// Maps simulation styles and field of study to avatar archetypes for live AI characters.
AvatarRole avatarRoleForLab(
  PracticeLabType lab, {
  String? majorId,
  String? groupId,
  String? aiRoleName,
}) {
  final String roleHint = (aiRoleName ?? lab.aiRole ?? '').toLowerCase();

  if (roleHint.contains('patient') || roleHint.contains('elderly')) return AvatarRole.patient;
  if (roleHint.contains('witness')) return AvatarRole.witness;
  if (roleHint.contains('judge') || roleHint.contains('counsel') || roleHint.contains('attorney')) {
    return AvatarRole.lawyer;
  }
  if (roleHint.contains('ceo') || roleHint.contains('director') || roleHint.contains('board')) {
    return AvatarRole.ceo;
  }
  if (roleHint.contains('client') || roleHint.contains('customer') || roleHint.contains('guest')) {
    return AvatarRole.client;
  }
  if (roleHint.contains('professor') ||
      roleHint.contains('teacher') ||
      roleHint.contains('instructor') ||
      roleHint.contains('principal')) {
    return AvatarRole.teacher;
  }
  if (roleHint.contains('interviewer') || roleHint.contains('engineer') && lab.codeLab) {
    return AvatarRole.interviewer;
  }

  final AvatarRole fromStyle = switch (lab.style) {
    SimulationStyle.aiPatient => AvatarRole.patient,
    SimulationStyle.erEmergency => AvatarRole.patient,
    SimulationStyle.diagnosis => AvatarRole.patient,
    SimulationStyle.codingInterview => AvatarRole.interviewer,
    SimulationStyle.debugging => AvatarRole.interviewer,
    SimulationStyle.systemDesign => AvatarRole.interviewer,
    SimulationStyle.courtroom => AvatarRole.lawyer,
    SimulationStyle.counseling => AvatarRole.client,
    SimulationStyle.classroom => AvatarRole.teacher,
    SimulationStyle.customerScenario => _customerRoleForGroup(groupId),
    SimulationStyle.anatomyGame => AvatarRole.teacher,
    SimulationStyle.diagramLab => AvatarRole.teacher,
  };

  if (fromStyle != AvatarRole.manager) return fromStyle;

  return _roleForMajorGroup(groupId, majorId);
}

AvatarRole _customerRoleForGroup(String? groupId) {
  return switch (groupId) {
    'business' || 'mathematics_finance' => AvatarRole.ceo,
    'law_criminal_justice' => AvatarRole.lawyer,
    'hospitality_tourism' || 'communications_media' => AvatarRole.customer,
    'health_medical' => AvatarRole.patient,
    'psychology_social_sciences' => AvatarRole.client,
    _ => AvatarRole.manager,
  };
}

AvatarRole _roleForMajorGroup(String? groupId, String? majorId) {
  return switch (groupId) {
    'health_medical' => AvatarRole.patient,
    'law_criminal_justice' => AvatarRole.lawyer,
    'psychology_social_sciences' => AvatarRole.client,
    'business' => AvatarRole.ceo,
    'engineering' || 'science' => AvatarRole.manager,
    'arts_creative' || 'communications_media' => AvatarRole.customer,
    'humanities' => AvatarRole.teacher,
    'public_safety_government' => AvatarRole.manager,
    'hospitality_tourism' => AvatarRole.customer,
    'agriculture_environment' => AvatarRole.manager,
    'architecture_design' => AvatarRole.client,
    _ => AvatarRole.manager,
  };
}

const Set<String> computerScienceMajorIds = <String>{
  'computer_science',
  'software_engineering',
  'information_technology',
  'cybersecurity',
  'data_science',
  'artificial_intelligence',
  'machine_learning',
  'information_systems',
  'computer_engineering',
  'game_development',
  'web_development',
  'cloud_computing',
};

bool isComputerScienceMajor(String majorId, {String? groupId}) =>
    computerScienceMajorIds.contains(majorId) || groupId == 'computer_technology';
