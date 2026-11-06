/// Content definitions: departments, training, projects, postings, interview
/// plans and workplaces. All const data; no state.
library;

import '../engine/text_rubric.dart';
import 'career_models.dart';
import 'tasks.dart';

class SkillDef {
  const SkillDef(this.id, this.label);
  final String id;
  final String label;
}

class LessonSection {
  const LessonSection(this.heading, this.body, {this.example = ''});
  final String heading;
  final String body;

  /// Worked example or code sample shown in a monospace box.
  final String example;
}

class TrainingModule {
  const TrainingModule({
    required this.id,
    required this.title,
    required this.summary,
    required this.skills,
    required this.lesson,
    required this.practice,
    this.minutes = 30,
  });

  final String id;
  final String title;
  final String summary;
  final List<String> skills;
  final List<LessonSection> lesson;

  /// The module is complete when the lesson is studied and every practice
  /// task is passed.
  final List<TaskSpec> practice;
  final int minutes;
}

class ProjectSpec {
  const ProjectSpec({
    required this.id,
    required this.title,
    required this.brief,
    required this.deliverables,
    required this.writeUp,
    required this.skills,
    this.requiresModules = const <String>[],
  });

  final String id;
  final String title;
  final String brief;
  final List<TaskSpec> deliverables;
  final WrittenTaskSpec writeUp;
  final List<String> skills;
  final List<String> requiresModules;
}

class Certification {
  const Certification({
    required this.id,
    required this.title,
    required this.issuer,
    required this.tasks,
    this.requiresModules = const <String>[],
    this.passMark = 80,
  });

  final String id;
  final String title;
  final String issuer;
  final List<TaskSpec> tasks;
  final List<String> requiresModules;
  final int passMark;
}

/// A lab, clinic, court or unit inside a department.
class DeptUnit {
  const DeptUnit({
    required this.id,
    required this.title,
    required this.setting,
    required this.modules,
    this.projects = const <ProjectSpec>[],
    this.emoji = '',
  });

  final String id;
  final String title;

  /// The professional environment, e.g. "Ward 4B — adult medical".
  final String setting;
  final List<TrainingModule> modules;
  final List<ProjectSpec> projects;
  final String emoji;
}

class Department {
  const Department({
    required this.id,
    required this.title,
    required this.school,
    required this.emoji,
    required this.summary,
    required this.majors,
    required this.skills,
    required this.units,
    this.certifications = const <Certification>[],
  });

  final String id;
  final String title;
  final String school;
  final String emoji;
  final String summary;
  final List<String> majors;
  final List<SkillDef> skills;
  final List<DeptUnit> units;
  final List<Certification> certifications;

  List<TrainingModule> get modules =>
      <TrainingModule>[for (final DeptUnit u in units) ...u.modules];

  List<ProjectSpec> get projects =>
      <ProjectSpec>[for (final DeptUnit u in units) ...u.projects];

  String skillLabel(String id) {
    for (final SkillDef s in skills) {
      if (s.id == id) return s.label;
    }
    return id;
  }
}

class CompanyProfile {
  const CompanyProfile({
    required this.name,
    required this.industry,
    required this.about,
    required this.team,
    required this.training,
    required this.culture,
    required this.success,
    required this.tools,
    required this.nextSteps,
  });

  final String name;
  final String industry;
  final String about;
  final String team;
  final String training;
  final String culture;

  /// What success in the first months looks like.
  final String success;
  final String tools;
  final String nextSteps;
}

enum JobType {
  internship,
  graduate,
  entryLevel,
  junior,
  midLevel,
  senior,
  management;

  String get label => switch (this) {
        JobType.internship => 'Internship',
        JobType.graduate => 'Graduate programme',
        JobType.entryLevel => 'Entry-level',
        JobType.junior => 'Junior',
        JobType.midLevel => 'Mid-level',
        JobType.senior => 'Senior',
        JobType.management => 'Management',
      };
}

class JobRequirements {
  const JobRequirements({
    this.modules = const <String>[],
    this.skills = const <String, int>{},
    this.projects = 0,
    this.minStage = CareerStage.student,
    this.certifications = const <String>[],
    this.completedInternship = false,
  });

  /// Training modules the employer expects (screened, not hard-gated).
  final List<String> modules;

  /// Skill id → minimum level (1 Foundation, 2 Practitioner, 3 Professional).
  final Map<String, int> skills;

  /// Department portfolio projects expected.
  final int projects;

  /// Hard eligibility: lower stages are rejected at screening.
  final CareerStage minStage;
  final List<String> certifications;

  /// Hard eligibility: a completed internship in this field.
  final bool completedInternship;
}

class JobPosting {
  const JobPosting({
    required this.id,
    required this.deptId,
    required this.company,
    required this.title,
    required this.type,
    required this.stageOnHire,
    required this.description,
    required this.responsibilities,
    required this.qualifications,
    required this.experience,
    required this.requirements,
    required this.salaryMin,
    required this.salaryMax,
    required this.location,
    required this.openDay,
    required this.deadlineDay,
    required this.interviewPlanId,
    required this.workplaceId,
    this.salaryPeriod = 'year',
    this.shortlistMark = 65,
    this.practicalRequired = true,
    this.level = '',
    this.department = '',
    this.hoursPerWeek = 40,
    this.positions = 1,
    this.workMode = 'On-site',
    this.requiredEducation = '',
    this.preferred = const <String>[],
    this.keywords = const <String>[],
    this.preferredKeywords = const <String>[],
    this.educationFields = const <String>[],
    this.questions = const <ApplicationQuestion>[],
    this.roleQuestions = const <InterviewQuestion>[],
    this.payFrequency = 'biweekly',
    this.benefits = const <String>[],
    this.simulationNote = '',
    this.majors = const <String>[],
  });

  /// Internship, Entry-level, Junior, Mid-level, Senior or Management.
  final String level;

  /// Department inside the employer (e.g. "Mobile Engineering").
  final String department;
  final int hoursPerWeek;
  final int positions;

  /// On-site, Hybrid or Remote.
  final String workMode;
  final String requiredEducation;

  /// Preferred qualifications (nice to have).
  final List<String> preferred;

  /// Skills and terms the resume is checked for (required).
  final List<String> keywords;
  final List<String> preferredKeywords;

  /// Fields of study that match the education requirement.
  final List<String> educationFields;

  /// Employer application questions, graded by rubric.
  final List<ApplicationQuestion> questions;

  /// Role-specific interview questions asked before the department's plan.
  final List<InterviewQuestion> roleQuestions;

  /// weekly, biweekly or monthly.
  final String payFrequency;
  final List<String> benefits;

  /// Shown on regulated (clinical/legal) roles: the simulation is not a licence.
  final String simulationNote;

  /// Majors this role recruits from (empty = the whole department).
  final List<String> majors;

  String get levelLabel => level.isNotEmpty ? level : type.label;

  final String id;
  final String deptId;
  final CompanyProfile company;
  final String title;
  final JobType type;
  final CareerStage stageOnHire;
  final String description;
  final List<String> responsibilities;
  final List<String> qualifications;
  final String experience;
  final JobRequirements requirements;
  final int salaryMin;
  final int salaryMax;
  final String salaryPeriod;
  final String location;
  final int openDay;
  final int deadlineDay;
  final String interviewPlanId;
  final String workplaceId;
  final int shortlistMark;

  /// The interview's practical (code, clinical, exercise) must be passed.
  final bool practicalRequired;
}

/// A question on the employer's application form.
class ApplicationQuestion {
  const ApplicationQuestion({required this.id, required this.prompt, required this.rubric, this.minWords = 40});

  final String id;
  final String prompt;
  final List<Concept> rubric;
  final int minWords;
}

enum Competency {
  communication,
  technical,
  problemSolving,
  readiness;

  String get label => switch (this) {
        Competency.communication => 'Communication',
        Competency.technical => 'Technical knowledge',
        Competency.problemSolving => 'Problem solving',
        Competency.readiness => 'Workplace readiness',
      };
}

/// One interviewer question.
///
/// Open questions are scored with [rubric]. Choice questions score the picked
/// option. A practical question carries a [practical] task (code, clinical
/// scenario, calculation …) graded by its own rule.
class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.prompt,
    required this.competency,
    this.rubric = const <Concept>[],
    this.minWords = 25,
    this.options = const <String>[],
    this.correctOption = -1,
    this.practical,
    this.probeId,
    this.stretchId,
    this.behavioural = false,
  });

  final String id;
  final String prompt;
  final Competency competency;
  final List<Concept> rubric;
  final int minWords;
  final List<String> options;
  final int correctOption;
  final TaskSpec? practical;

  /// Asked next when the answer scores below 60 (probing the gap).
  final String? probeId;

  /// Asked next when the answer scores 85 or more (a harder question).
  final String? stretchId;

  /// Scored for Situation–Task–Action–Result structure as well.
  final bool behavioural;

  bool get isChoice => options.isNotEmpty;
}

class InterviewPlan {
  const InterviewPlan({
    required this.id,
    required this.interviewer,
    required this.interviewerRole,
    required this.opening,
    required this.main,
    required this.bank,
    this.maxQuestions = 7,
  });

  final String id;
  final String interviewer;
  final String interviewerRole;
  final String opening;

  /// Question ids in the default order. Follow-ups come from [bank].
  final List<String> main;
  final List<InterviewQuestion> bank;
  final int maxQuestions;

  InterviewQuestion? question(String id) {
    for (final InterviewQuestion q in bank) {
      if (q.id == id) return q;
    }
    return null;
  }
}

class AssignmentSpec {
  const AssignmentSpec({
    required this.id,
    required this.title,
    required this.ticket,
    required this.acceptance,
    required this.task,
    this.deadlineDays = 2,
    this.leadership = false,
  });

  final String id;
  final String title;

  /// The supervisor's request, as written in the ticket or handover.
  final String ticket;
  final List<String> acceptance;
  final TaskSpec task;
  final int deadlineDays;

  /// Counts as leadership evidence for a Team Lead promotion.
  final bool leadership;
}

class WorkplaceDef {
  const WorkplaceDef({
    required this.id,
    required this.deptId,
    required this.name,
    required this.environment,
    required this.supervisor,
    required this.supervisorRole,
    required this.tools,
    required this.assignments,
    required this.titles,
    this.internshipLength = 3,
    this.returnOfferPostingId,
  });

  /// Job title at each stage in this workplace.
  final Map<CareerStage, String> titles;

  /// Entry-level posting offered to interns who pass the final evaluation.
  final String? returnOfferPostingId;

  String titleFor(CareerStage s, String fallback) => titles[s] ?? fallback;

  final String id;
  final String deptId;
  final String name;
  final String environment;
  final String supervisor;
  final String supervisorRole;
  final List<String> tools;
  final List<AssignmentSpec> assignments;

  /// Assignments an intern completes before the final evaluation.
  final int internshipLength;
}
