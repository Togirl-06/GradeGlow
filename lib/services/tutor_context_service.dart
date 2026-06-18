import 'package:flutter/foundation.dart';

import '../models/parsed_question.dart';
import '../models/study_material.dart';
import '../models/tutor_context.dart';

class TutorContextService extends ChangeNotifier {
  TutorContext _context = const TutorContext();

  TutorContext get context => _context;

  void setFromMaterial(StudyMaterial material, List<ParsedQuestion> questions) {
    _context = TutorContext(
      courseCode: material.courseCode,
      professor: material.professor,
      examType: material.examType,
      materialLabel: '${material.fileName} · ${material.examType}',
      questions: questions,
    );
    notifyListeners();
  }

  void setFromQuestion(ParsedQuestion question, List<ParsedQuestion> examQuestions) {
    _context = TutorContext(
      courseCode: question.courseCode,
      professor: question.professor,
      examType: question.examType,
      materialLabel: question.examType,
      questions: examQuestions.isNotEmpty ? examQuestions : <ParsedQuestion>[question],
    );
    notifyListeners();
  }

  void clear() {
    _context = const TutorContext();
    notifyListeners();
  }
}
