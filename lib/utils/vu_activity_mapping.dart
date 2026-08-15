import '../models/business_school.dart';
import '../models/virtual_university_lesson_contract.dart';

/// Maps Business School activity kinds onto the VU canonical lesson contract.
VuCanonicalActivity? vuCanonicalFromBusiness(BusinessActivityKind kind) {
  switch (kind) {
    case BusinessActivityKind.professor:
      return VuCanonicalActivity.aiProfessor;
    case BusinessActivityKind.notes:
      return VuCanonicalActivity.textbookNotes;
    case BusinessActivityKind.video:
    case BusinessActivityKind.interactive:
    case BusinessActivityKind.simulation:
    case BusinessActivityKind.companySimulator:
    case BusinessActivityKind.management:
    case BusinessActivityKind.entrepreneurship:
    case BusinessActivityKind.operations:
    case BusinessActivityKind.leadership:
    case BusinessActivityKind.negotiation:
    case BusinessActivityKind.caseStudy:
    case BusinessActivityKind.dashboard:
    case BusinessActivityKind.ceoMentor:
      return VuCanonicalActivity.interactiveOrVideo;
    case BusinessActivityKind.homework:
    case BusinessActivityKind.project:
    case BusinessActivityKind.internship:
      return VuCanonicalActivity.practiceOrHomework;
    case BusinessActivityKind.exam:
    case BusinessActivityKind.capstone:
      return VuCanonicalActivity.quizOrExam;
    case BusinessActivityKind.aiTutor:
      return VuCanonicalActivity.discussionOrSummary;
  }
}
