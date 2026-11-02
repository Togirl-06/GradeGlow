/// Virtual Labs models for Grade Glow Virtual University.
library;

enum VuV2LabSchool {
  physics,
  chemistry,
  biology,
  computerScience,
  nursing,
  business,
  psychology,
  mathematics,
}

class VuV2LabExperiment {
  const VuV2LabExperiment({
    required this.id,
    required this.title,
    required this.emoji,
    required this.blurb,
    required this.objectives,
    required this.instructions,
    required this.professorIntro,
    required this.quiz,
    required this.notesSeed,
    required this.simulationKind,
  });

  final String id;
  final String title;
  final String emoji;
  final String blurb;
  final List<String> objectives;
  final List<String> instructions;
  final String professorIntro;
  final List<VuV2LabQuizItem> quiz;
  final String notesSeed;
  final VuV2LabSimulationKind simulationKind;
}

enum VuV2LabSimulationKind {
  physicsGravity,
  physicsCircuit,
  physicsProjectile,
  chemistryReaction,
  chemistryPh,
  chemistryMolecule,
  biologyAnatomy,
  biologyCell,
  biologyDna,
  csEditor,
  csDebug,
  csChallenge,
  nursingPatient,
  nursingScenario,
  nursingEquipment,
  businessCompany,
  businessMarketing,
  businessFinance,
  psychologyMemory,
  psychologyAttention,
  psychologyBias,
  mathGraph,
  mathQuadratic,
  mathProbability,
  physicsWaves,
  chemistryTitration,
  biologyEcology,
}

class VuV2LabQuizItem {
  const VuV2LabQuizItem({
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    required this.explain,
  });

  final String prompt;
  final List<String> choices;
  final int correctIndex;
  final String explain;
}

class VuV2LabSchoolDef {
  const VuV2LabSchoolDef({
    required this.school,
    required this.title,
    required this.emoji,
    required this.blurb,
    required this.subjectIds,
    required this.experiments,
  });

  final VuV2LabSchool school;
  final String title;
  final String emoji;
  final String blurb;

  /// Matches [VuV2Session.majorId] / roadmap subject ids.
  final List<String> subjectIds;
  final List<VuV2LabExperiment> experiments;
}
