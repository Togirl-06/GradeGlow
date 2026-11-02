import 'package:flutter/material.dart';

import '../../data/leetcode_problem_bank.dart';
import '../../data/practice_lab_university_catalog.dart';
import '../../models/ai_practice_mode.dart';
import '../../models/leetcode_problem.dart';
import '../../models/practice_lab.dart';
import '../../models/practice_lab_subject.dart';
import '../../models/practice_lab_topic.dart';
import '../../screens/computer_science/cs_debug_challenge_screen.dart';
import '../../screens/leetcode_practice_session_screen.dart';
import '../../theme/leetcode_theme.dart';

/// Browse and solve curated LeetCode-style problems.
class CsProblemBrowserScreen extends StatefulWidget {
  const CsProblemBrowserScreen({super.key, this.preferDebug = false});

  final bool preferDebug;

  @override
  State<CsProblemBrowserScreen> createState() => _CsProblemBrowserScreenState();
}

class _CsProblemBrowserScreenState extends State<CsProblemBrowserScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String _difficulty = 'All';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _query = _search.text));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<LeetcodeProblem> get _problems {
    final String q = _query.trim().toLowerCase();
    final List<LeetcodeProblem> pool =
        widget.preferDebug ? LeetcodeProblemBank.allDebugProblems : LeetcodeProblemBank.allCuratedProblems;
    return pool.where((LeetcodeProblem p) {
      if (!widget.preferDebug && p.isDebug) return false;
      final bool matchQ = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.tags.any((String t) => t.toLowerCase().contains(q));
      if (!matchQ) return false;
      if (_difficulty == 'All') return true;
      return p.difficulty.toLowerCase().contains(_difficulty.toLowerCase());
    }).toList()
      ..sort((LeetcodeProblem a, LeetcodeProblem b) => a.title.compareTo(b.title));
  }

  void _solve(LeetcodeProblem problem) {
    if (widget.preferDebug || problem.isDebug) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CsDebugChallengeScreen(
            problem: problem,
            allProblems: LeetcodeProblemBank.allDebugProblems,
          ),
        ),
      );
      return;
    }
    final PracticeLabSubject? subject =
        PracticeLabUniversityCatalog.subjectById('computer_science');
    if (subject == null) return;
    final PracticeLabCategory category = subject.toCategory();
    final PracticeLabTopic topic = PracticeLabTopic(
      id: problem.slug,
      name: problem.title,
      description: problem.description,
      beginner: problem.difficulty.toLowerCase().contains('easy'),
      intermediate: problem.difficulty.toLowerCase().contains('med'),
      advanced: true,
      style: SimulationStyle.codingInterview,
      aiRole: 'Technical Interviewer',
      studentTasks: const <String>['Implement a correct solution', 'Analyze complexity'],
      evaluationCriteria: const <String>['Correctness', 'Complexity', 'Code quality'],
    );
    final PracticeLabType lab = PracticeLabType(
      id: 'cs_problem_${problem.slug}',
      title: problem.title,
      subtitle: '${problem.difficulty} · ${problem.tags.join(", ")}',
      style: problem.isDebug ? SimulationStyle.debugging : SimulationStyle.codingInterview,
      codeLab: true,
      timed: false,
      aiRole: 'Senior Engineer',
      studentTasks: const <String>['Write working code', 'Pass all test cases'],
      evaluationCriteria: const <String>['Correctness', 'Time complexity', 'Readability'],
      difficulty: problem.difficulty,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LeetcodePracticeSessionScreen(
          category: category,
          lab: lab,
          topic: topic,
          area: PracticeLabTopicArea(
            id: 'cs_problems',
            name: 'Coding Challenges',
            emoji: '💻',
            topics: <PracticeLabTopic>[topic],
          ),
          difficulty: PracticeDifficulty.intermediate,
          courseName: 'Computer Science',
          subjectId: 'computer_science',
          courseId: 'algorithms',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<LeetcodeProblem> problems = _problems;
    return Scaffold(
      backgroundColor: LeetCodeTheme.background,
      appBar: AppBar(
        backgroundColor: LeetCodeTheme.surface,
        foregroundColor: LeetCodeTheme.textPrimary,
        title: Text(widget.preferDebug ? 'Debug Challenges' : 'Coding Problems'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              style: const TextStyle(color: LeetCodeTheme.textPrimary),
              decoration: InputDecoration(
                hintText: widget.preferDebug ? 'Search debug challenges…' : 'Search problems…',
                hintStyle: const TextStyle(color: LeetCodeTheme.textSecondary),
                prefixIcon: const Icon(Icons.search, color: LeetCodeTheme.textSecondary),
                filled: true,
                fillColor: LeetCodeTheme.surface,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <String>['All', 'Easy', 'Medium', 'Hard'].map((String d) {
                final bool selected = _difficulty == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(d),
                    selected: selected,
                    onSelected: (_) => setState(() => _difficulty = d),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: problems.length,
              itemBuilder: (BuildContext context, int i) {
                final LeetcodeProblem p = problems[i];
                return Card(
                  color: LeetCodeTheme.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(p.title, style: const TextStyle(color: LeetCodeTheme.textPrimary, fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      '${p.difficulty} · ${p.tags.take(3).join(", ")}',
                      style: const TextStyle(color: LeetCodeTheme.textSecondary, fontSize: 12),
                    ),
                    trailing: Icon(
                      p.isDebug ? Icons.bug_report_rounded : Icons.code_rounded,
                      color: LeetCodeTheme.difficultyColor(p.difficulty),
                    ),
                    onTap: () => _solve(p),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
