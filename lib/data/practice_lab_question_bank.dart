import '../models/practice_lab_question.dart';
import '../models/topic_profile.dart';
import '../data/topic_profile_database.dart';
import '../utils/topic_scope_validator.dart';
import 'topic_question_catalog.dart';

/// Builds large local question sets for any topic / difficulty (no API required).
class PracticeLabQuestionBank {
  PracticeLabQuestionBank._();

  static int targetCountForDifficulty(String difficulty) {
    final String d = difficulty.toLowerCase();
    if (d.contains('exam')) return 75;
    if (d.contains('adv')) return 80;
    if (d.contains('inter')) return 70;
    return 60;
  }

  static List<PracticeLabQuestion> build({
    required String topicName,
    required String courseName,
    required String unitName,
    required String difficulty,
    List<String> aiQuestions = const <String>[],
    String? subjectId,
    String? courseId,
    String? topicId,
  }) {
    final int target = targetCountForDifficulty(difficulty);
    final Set<String> seen = <String>{};
    final List<PracticeLabQuestion> out = <PracticeLabQuestion>[];

    final TopicProfile? profile = topicId != null
        ? TopicProfileDatabase.resolve(
            topicId: topicId,
            topicName: topicName,
            subjectId: subjectId,
            courseId: courseId,
            courseName: courseName,
            unitName: unitName,
          )
        : null;

    void add(String prompt) {
      final String trimmed = prompt.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) return;
      if (profile != null && !TopicScopeValidator.isOnTopic(trimmed, profile)) return;
      out.add(PracticeLabQuestion(id: 'q_${out.length + 1}', prompt: trimmed));
    }

    for (final String q in aiQuestions) {
      add(q);
    }

    if (topicId != null) {
      for (final String q in TopicQuestionCatalog.questionsFor(
        topicName: topicName,
        topicId: topicId,
        courseName: courseName,
        unitName: unitName,
        difficulty: difficulty,
        subjectId: subjectId,
        courseId: courseId,
        profile: profile,
      )) {
        add(q);
      }
    }

    final List<String> stems = profile != null
        ? TopicScopeValidator.objectiveStems(profile, difficulty)
        : subjectId == 'mathematics'
            ? _mathStemsFor(difficulty)
            : _stemsFor(difficulty);

    int round = 0;
    while (out.length < target) {
      for (final String stem in stems) {
        add(
          stem
              .replaceAll('{topic}', topicName)
              .replaceAll('{course}', courseName)
              .replaceAll('{unit}', unitName)
              .replaceAll('{n}', '${round + 1}'),
        );
        if (out.length >= target) break;
      }
      round++;
      if (round > 50) break;
    }

    return out;
  }

  static List<String> _stemsFor(String difficulty) {
    final String d = difficulty.toLowerCase();
    if (d.contains('exam')) return _advancedStems;
    if (d.contains('adv')) return _advancedStems;
    if (d.contains('inter')) return _intermediateStems;
    return _beginnerStems;
  }

  static List<String> _mathStemsFor(String difficulty) {
    final String d = difficulty.toLowerCase();
    if (d.contains('exam')) return _mathExamStems;
    if (d.contains('adv')) return _mathAdvancedStems;
    if (d.contains('inter')) return _mathIntermediateStems;
    return _mathBeginnerStems;
  }

  static const List<String> _mathBeginnerStems = <String>[
    'Compute: Simplify the expression using {topic}.',
    'Solve: Find the value when applying {topic}.',
    'Evaluate: Work out the result for a basic {topic} problem.',
    'Fill in the blank: Complete the missing step in this {topic} calculation.',
    'Compare: Which of two values is larger using {topic}?',
    'Convert: Express one form as another using {topic}.',
    'Identify: What property of {topic} applies here?',
    'Practice {n}: Solve a one-step {topic} problem.',
    'Order: Arrange numbers using rules from {topic}.',
    'Find: The GCF, LCM, or equivalent fraction for a {topic} exercise.',
    'Plot: Mark the solution on a number line for {topic}.',
    'Check: Is this {topic} answer correct? Show why or why not.',
  ];

  static const List<String> _mathIntermediateStems = <String>[
    'Solve: A multi-step {topic} problem from {course}.',
    'Simplify: Reduce the expression using {topic}.',
    'Factor: Rewrite the polynomial or expression using {topic}.',
    'Graph: Sketch or describe the graph related to {topic}.',
    'Prove: Show that a statement about {topic} is true.',
    'Apply: Use {topic} to solve a word problem (state the equation only).',
    'Find: The slope, intercept, or vertex using {topic}.',
    'Practice {n}: Medium {topic} problem requiring two steps.',
    'Solve the system or equation set using {topic}.',
    'Differentiate or integrate (as appropriate) using {topic}.',
    'Determine: Domain and range for a {topic} function.',
    'Error analysis: Find the mistake in a flawed {topic} solution.',
  ];

  static const List<String> _mathAdvancedStems = <String>[
    'Prove rigorously: A theorem or identity from {topic}.',
    'Solve: An exam-level {topic} problem with full justification.',
    'Analyze: Limits, convergence, or continuity using {topic}.',
    'Derive: A formula or result from first principles in {topic}.',
    'Advanced {n}: Multi-part {topic} problem from {course}.',
    'Optimize: Find max/min using {topic}.',
    'Linear algebra: Matrix or vector problem using {topic}.',
    'Series: Evaluate or determine convergence with {topic}.',
    'Model: Set up and solve an equation using {topic} (math only).',
    'Challenge {n}: Open-ended proof or computation in {topic}.',
  ];

  static const List<String> _mathExamStems = <String>[
    'Exam {n}: Multi-part {topic} problem — solve all parts with full work.',
    'Prove: A non-trivial result from {topic} without skipping logical steps.',
    'Synthesis: Combine two ideas from {topic} in one rigorous solution.',
    'Exam {n}: Find all solutions to a challenging {topic} equation or system.',
    'Derive and apply: Prove a key {topic} formula, then use it in a hard problem.',
    'Analyze edge cases: When does the standard {topic} method fail? Give an example.',
    'Exam {n}: Optimization problem in {topic} with constraints — justify the maximum.',
    'Proof by contradiction: Show a statement about {topic} using a rigorous argument.',
    'Exam {n}: Graduate-style {topic} problem from {course} requiring 4+ steps.',
    'Compare methods: Solve the same {topic} problem two ways and explain trade-offs.',
    'Exam {n}: Construct an example or counterexample related to {topic}.',
    'Capstone-style: Integrate {topic} with prior material from {unit} in one problem.',
  ];

  static const List<String> _beginnerStems = <String>[
    'Define {topic} and explain why it matters in {course}.',
    'What is the first step when solving a {topic} problem in {unit}?',
    'Give a simple example of {topic} from {course}.',
    'List three key facts about {topic}.',
    'How would you explain {topic} to a classmate who missed the lecture?',
    'What common mistake do beginners make with {topic}?',
    'Identify the main concept behind {topic} in {course}.',
    'Walk through a basic {topic} example step by step.',
    'What vocabulary terms are essential for {topic}?',
    'Compare {topic} to a related idea you learned in {unit}.',
    'Practice set {n}: Solve a straightforward {topic} problem.',
    'What would you check first when reviewing {topic} homework?',
    'Describe a real-world use of {topic}.',
    'Fill in the gaps: explain missing steps in a {topic} solution.',
    'True or false style: justify whether a statement about {topic} is correct.',
    'Flashcard {n}: State the definition of a core {topic} term from {course}.',
    'Multiple choice style: List four options for a typical {topic} question and pick the best.',
    'What is the difference between two closely related concepts in {topic}?',
    'Summarize the main takeaway from {unit} as it applies to {topic}.',
    'Create a mnemonic or memory aid for {topic} vocabulary.',
    'What lab or clinical finding would support a {topic} diagnosis?',
    'Identify the independent and dependent variables in a {topic} experiment.',
    'What safety precaution applies when working with {topic}?',
    'Review question {n}: Explain {topic} in two sentences or less.',
    'Map the steps of a standard {topic} procedure in order.',
    'What historical discovery or scientist is linked to {topic}?',
    'Give an analogy that helps explain {topic} to a beginner.',
    'What chart, table, or diagram best represents {topic}?',
    'Practice {n}: Convert a word problem into a {topic} equation or model.',
  ];

  static const List<String> _intermediateStems = <String>[
    'Apply {topic} to a multi-step scenario from {course}.',
    'Analyze a case where {topic} is used incorrectly — what went wrong?',
    'How does {topic} connect to other ideas in {unit}?',
    'Solve a {topic} problem that requires two or more concepts.',
    'Evaluate which approach is best for this {topic} challenge.',
    'Interpret results or data related to {topic}.',
    'Explain the reasoning behind a non-obvious {topic} solution.',
    'Practice set {n}: Medium difficulty {topic} application.',
    'What assumptions must hold for standard {topic} methods to work?',
    'Compare two methods for handling {topic} problems.',
    'Diagnose errors in a flawed {topic} solution.',
    'How would you teach {topic} to someone preparing for an exam?',
    'Build a short plan to master {topic} this week.',
    'Predict the outcome when conditions change in a {topic} scenario.',
    'Integrate {topic} with prior knowledge from {course}.',
    'Case vignette {n}: Apply {topic} to interpret a short patient or lab scenario.',
    'What diagnostic test is most appropriate for a {topic} workup?',
    'Compare normal vs abnormal findings related to {topic}.',
    'Prioritize three nursing or clinical actions for a {topic} case.',
    'Interpret a table of values using {topic} principles.',
    'What complication is most likely if {topic} is mismanaged?',
    'Explain how {topic} differs between pediatric and adult populations.',
    'Draft a brief teaching point about {topic} for a patient or family.',
    'Identify red flags that require escalation in a {topic} scenario.',
    'Walk through a worked example {n} step by step for {topic}.',
    'What evidence-based guideline supports care related to {topic}?',
    'How would you document findings for {topic} in a clinical note?',
    'Spot the error in a sample solution involving {topic}.',
    'Link {topic} to a related disorder or concept from {course}.',
  ];

  static const List<String> _advancedStems = <String>[
    'Critically evaluate a complex {topic} scenario with constraints.',
    'Design a solution using {topic} when standard methods fail.',
    'Defend your reasoning in a high-stakes {topic} case from {course}.',
    'Synthesize {topic} with multiple units in {course}.',
    'Advanced practice {n}: Solve an exam-level {topic} problem.',
    'What edge cases break common {topic} approaches?',
    'Propose improvements to a given {topic} workflow.',
    'Analyze trade-offs between solutions in {topic}.',
    'Construct a rigorous argument using {topic} evidence.',
    'How would an expert troubleshoot a novel {topic} problem?',
    'Evaluate published or textbook approaches to {topic}.',
    'Create a rubric for grading {topic} work.',
    'Handle ambiguous data in a {topic} decision problem.',
    'Explain {topic} at a graduate level with nuance.',
    'Challenge question {n}: open-ended {topic} synthesis.',
    'Debate question {n}: Argue for and against a controversial approach in {topic}.',
    'Design a research question that could advance knowledge in {topic}.',
    'Critique a published case study related to {topic}.',
    'What ethical dilemma can arise in {topic} practice?',
    'Model a complex system using {topic} — state assumptions and limits.',
    'Peer review: What weaknesses exist in this {topic} solution?',
    'Board-exam style {n}: Multi-layered {topic} problem with justification.',
    'Propose a quality-improvement initiative based on {topic}.',
    'Synthesize {topic} with pharmacology, pathophysiology, or policy where relevant.',
    'Forecast how new technology could change {topic} in the next decade.',
    'Write an exam rubric for evaluating mastery of {topic}.',
    'Compare international or cultural differences in how {topic} is applied.',
    'Defend the most likely diagnosis using {topic} reasoning only.',
    'Capstone {n}: Integrate every major idea from {unit} into one {topic} case.',
  ];
}
