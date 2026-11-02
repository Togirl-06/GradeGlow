class SearchFilters {
  const SearchFilters({
    this.courseCode,
    this.professor,
    this.semester,
    this.examType,
    this.questionType,
    this.topic,
    this.hasSolution,
    this.query,
  });

  final String? courseCode;
  final String? professor;
  final String? semester;
  final String? examType;
  final String? questionType;
  final String? topic;
  final bool? hasSolution;
  final String? query;

  SearchFilters copyWith({
    String? courseCode,
    String? professor,
    String? semester,
    String? examType,
    String? questionType,
    String? topic,
    bool? hasSolution,
    String? query,
    bool clearCourseCode = false,
    bool clearProfessor = false,
    bool clearSemester = false,
    bool clearExamType = false,
    bool clearQuestionType = false,
    bool clearTopic = false,
    bool clearHasSolution = false,
    bool clearQuery = false,
  }) {
    return SearchFilters(
      courseCode: clearCourseCode ? null : (courseCode ?? this.courseCode),
      professor: clearProfessor ? null : (professor ?? this.professor),
      semester: clearSemester ? null : (semester ?? this.semester),
      examType: clearExamType ? null : (examType ?? this.examType),
      questionType: clearQuestionType ? null : (questionType ?? this.questionType),
      topic: clearTopic ? null : (topic ?? this.topic),
      hasSolution: clearHasSolution ? null : (hasSolution ?? this.hasSolution),
      query: clearQuery ? null : (query ?? this.query),
    );
  }

  bool get isEmpty =>
      courseCode == null &&
      professor == null &&
      semester == null &&
      examType == null &&
      questionType == null &&
      topic == null &&
      hasSolution == null &&
      (query == null || query!.trim().isEmpty);
}
