import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/coding_languages.dart';
import '../../data/cs_bigo_catalog.dart';
import '../../models/cs_bigo_lesson.dart';
import '../../models/cs_w3s_topic.dart';
import '../../services/practice_lab_service.dart';
import '../../theme/cs_hybrid_theme.dart';
import '../../utils/network_reachability.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/cs/cs_hybrid_panels.dart';
import '../../widgets/leetcode/leetcode_problem_panel.dart';

/// W3Schools-style Big-O learning: lesson → try it → practice quizzes.
class CsBigOLearningScreen extends StatefulWidget {
  const CsBigOLearningScreen({super.key, this.initialLessonId});

  final String? initialLessonId;

  @override
  State<CsBigOLearningScreen> createState() => _CsBigOLearningScreenState();
}

class _CsBigOLearningScreenState extends State<CsBigOLearningScreen> {
  late CsBigOLesson _lesson;
  final TextEditingController _code = TextEditingController();
  CodingLanguage _language = CodingLanguage.defaultLanguage;

  bool _practiceMode = false;
  bool _loading = false;
  String? _output;
  int _mobileTab = 1;
  int _quizIndex = 0;
  int? _picked;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _lesson = CsBigOCatalog.byId(widget.initialLessonId ?? '') ?? CsBigOCatalog.defaultLesson;
    _loadEditors();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _loadEditors() {
    _code.text = _lesson.asW3sTopic().tryItStarterFor(_language.id);
    if (_code.text.isEmpty) {
      _code.text = _lesson.tryIt.starterCode;
    }
    _output = null;
    _quizIndex = 0;
    _picked = null;
    _revealed = false;
  }

  void _selectLesson(CsBigOLesson lesson) {
    setState(() {
      _lesson = lesson;
      _practiceMode = false;
      _loadEditors();
    });
  }

  void _onLanguageChange(CodingLanguage lang) {
    setState(() {
      _language = lang;
      final String starter = _lesson.asW3sTopic().tryItStarterFor(lang.id);
      _code.text = starter.isNotEmpty ? starter : _lesson.tryIt.starterCode;
    });
  }

  Future<void> _runTryIt() async {
    if (!AppConfig.hasOpenAi) {
      StudyMessenger.showError(context, 'OpenAI is not configured.');
      return;
    }
    setState(() {
      _loading = true;
      _output = null;
    });
    final PracticeLabService labs = context.read<PracticeLabService>();
    try {
      await ensureOpenAiReachable();
      final String out = await labs.runCodeSnippet(
        language: _language.id,
        code: _code.text,
        taskContext: '${_lesson.tryIt.task}\n${_lesson.tryIt.runContext}',
      );
      if (!mounted) return;
      setState(() => _output = out);
    } catch (e) {
      if (mounted) StudyMessenger.showError(context, '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  CsBigOQuiz? get _activeQuiz {
    if (_lesson.quizzes.isEmpty) return null;
    return _lesson.quizzes[_quizIndex % _lesson.quizzes.length];
  }

  void _pickQuiz(int index) {
    if (_revealed) return;
    setState(() {
      _picked = index;
      _revealed = true;
    });
  }

  void _nextQuiz() {
    if (_lesson.quizzes.isEmpty) return;
    setState(() {
      _quizIndex = (_quizIndex + 1) % _lesson.quizzes.length;
      _picked = null;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CsW3sTopic topic = _lesson.asW3sTopic();
    return Scaffold(
      backgroundColor: CsHybridTheme.background,
      appBar: AppBar(
        backgroundColor: CsHybridTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Learn Big-O'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                _lesson.track,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 960;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(width: 220, child: _LessonSidebar(lesson: _lesson, onSelect: _selectLesson)),
                      const VerticalDivider(width: 1, color: CsHybridTheme.border),
                      Expanded(
                        flex: 3,
                        child: _CenterPanel(
                          topic: topic,
                          controller: _code,
                          language: _language,
                          onLanguageChange: _onLanguageChange,
                          onRun: _runTryIt,
                          loading: _loading,
                        ),
                      ),
                      const VerticalDivider(width: 1, color: CsHybridTheme.border),
                      SizedBox(
                        width: 360,
                        child: _RightPanel(
                          lesson: _lesson,
                          topic: topic,
                          language: _language,
                          practiceMode: _practiceMode,
                          onPracticeMode: (bool v) => setState(() => _practiceMode = v),
                          output: _output,
                          loading: _loading,
                          quiz: _activeQuiz,
                          quizIndex: _quizIndex,
                          picked: _picked,
                          revealed: _revealed,
                          onPick: _pickQuiz,
                          onNextQuiz: _nextQuiz,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: <Widget>[
                    NavigationBar(
                      selectedIndex: _mobileTab,
                      onDestinationSelected: (int i) => setState(() => _mobileTab = i),
                      destinations: const <NavigationDestination>[
                        NavigationDestination(icon: Icon(Icons.list), label: 'Lessons'),
                        NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Learn'),
                        NavigationDestination(icon: Icon(Icons.quiz_outlined), label: 'Practice'),
                      ],
                    ),
                    Expanded(
                      child: switch (_mobileTab) {
                        0 => _LessonSidebar(
                          lesson: _lesson,
                          onSelect: (CsBigOLesson l) {
                            _selectLesson(l);
                            setState(() => _mobileTab = 1);
                          },
                        ),
                        1 => _CenterPanel(
                          topic: topic,
                          controller: _code,
                          language: _language,
                          onLanguageChange: _onLanguageChange,
                          onRun: _runTryIt,
                          loading: _loading,
                          rightHeader: _ModeHeader(
                            practiceMode: _practiceMode,
                            onModeChange: (bool v) => setState(() => _practiceMode = v),
                          ),
                        ),
                        _ => _RightPanel(
                          lesson: _lesson,
                          topic: topic,
                          language: _language,
                          practiceMode: true,
                          onPracticeMode: (_) {},
                          output: _output,
                          loading: _loading,
                          quiz: _activeQuiz,
                          quizIndex: _quizIndex,
                          picked: _picked,
                          revealed: _revealed,
                          onPick: _pickQuiz,
                          onNextQuiz: _nextQuiz,
                        ),
                      },
                    ),
                  ],
                );
        },
      ),
    );
  }
}

class _LessonSidebar extends StatelessWidget {
  const _LessonSidebar({required this.lesson, required this.onSelect});

  final CsBigOLesson lesson;
  final ValueChanged<CsBigOLesson> onSelect;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CsHybridTheme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Text(
              'COMPLEXITY',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: CsHybridTheme.textSecondary, letterSpacing: 0.8),
            ),
          ),
          for (final CsBigOLesson item in CsBigOCatalog.lessons)
            _LessonTile(
              title: item.title,
              selected: lesson.id == item.id,
              onTap: () => onSelect(item),
            ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.title, required this.selected, required this.onTap});

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? CsHybridTheme.primary.withValues(alpha: 0.12) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: selected ? CsHybridTheme.primary : Colors.transparent, width: 3)),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? CsHybridTheme.primaryDark : CsHybridTheme.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeHeader extends StatelessWidget {
  const _ModeHeader({required this.practiceMode, required this.onModeChange});

  final bool practiceMode;
  final ValueChanged<bool> onModeChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CsHybridTheme.border)),
      ),
      child: SegmentedButton<bool>(
        segments: const <ButtonSegment<bool>>[
          ButtonSegment<bool>(value: false, label: Text('Try It', style: TextStyle(fontSize: 12))),
          ButtonSegment<bool>(value: true, label: Text('Practice', style: TextStyle(fontSize: 12))),
        ],
        selected: <bool>{practiceMode},
        onSelectionChanged: (Set<bool> s) => onModeChange(s.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          backgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) return CsHybridTheme.primary;
            return CsHybridTheme.background;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return CsHybridTheme.textPrimary;
          }),
        ),
      ),
    );
  }
}

class _CenterPanel extends StatelessWidget {
  const _CenterPanel({
    required this.topic,
    required this.controller,
    required this.language,
    required this.onLanguageChange,
    required this.onRun,
    required this.loading,
    this.rightHeader,
  });

  final CsW3sTopic topic;
  final TextEditingController controller;
  final CodingLanguage language;
  final ValueChanged<CodingLanguage> onLanguageChange;
  final VoidCallback onRun;
  final bool loading;
  final Widget? rightHeader;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CsHybridTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ?rightHeader,
          SizedBox(height: 220, child: CsLessonPanel(topic: topic, language: language)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: CsHybridTheme.border), bottom: BorderSide(color: CsHybridTheme.border)),
            ),
            child: Row(
              children: <Widget>[
                const Text('Try It Yourself', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const Spacer(),
                FilledButton.icon(
                  onPressed: loading ? null : onRun,
                  style: FilledButton.styleFrom(backgroundColor: CsHybridTheme.primary, foregroundColor: Colors.white),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Run'),
                ),
              ],
            ),
          ),
          Expanded(
            child: LeetcodeCodeEditor(
              controller: controller,
              language: language,
              onChangeLanguage: onLanguageChange,
            ),
          ),
        ],
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({
    required this.lesson,
    required this.topic,
    required this.language,
    required this.practiceMode,
    required this.onPracticeMode,
    required this.output,
    required this.loading,
    required this.quiz,
    required this.quizIndex,
    required this.picked,
    required this.revealed,
    required this.onPick,
    required this.onNextQuiz,
  });

  final CsBigOLesson lesson;
  final CsW3sTopic topic;
  final CodingLanguage language;
  final bool practiceMode;
  final ValueChanged<bool> onPracticeMode;
  final String? output;
  final bool loading;
  final CsBigOQuiz? quiz;
  final int quizIndex;
  final int? picked;
  final bool revealed;
  final ValueChanged<int> onPick;
  final VoidCallback onNextQuiz;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CsHybridTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ModeHeader(practiceMode: practiceMode, onModeChange: onPracticeMode),
          Expanded(
            child: practiceMode
                ? _PracticePanel(
                    lesson: lesson,
                    quiz: quiz,
                    quizIndex: quizIndex,
                    picked: picked,
                    revealed: revealed,
                    onPick: onPick,
                    onNext: onNextQuiz,
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(flex: 5, child: CsTryItPanel(topic: topic, language: language)),
                      const VerticalDivider(width: 1, color: CsHybridTheme.border),
                      Expanded(
                        flex: 4,
                        child: CsHybridOutputPanel(stdout: output, loading: loading),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PracticePanel extends StatelessWidget {
  const _PracticePanel({
    required this.lesson,
    required this.quiz,
    required this.quizIndex,
    required this.picked,
    required this.revealed,
    required this.onPick,
    required this.onNext,
  });

  final CsBigOLesson lesson;
  final CsBigOQuiz? quiz;
  final int quizIndex;
  final int? picked;
  final bool revealed;
  final ValueChanged<int> onPick;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (quiz == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No practice questions for this lesson yet.', style: TextStyle(color: CsHybridTheme.textSecondary)),
        ),
      );
    }
    final CsBigOQuiz q = quiz!;
    final bool correct = picked == q.correctIndex;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        Text(
          'Practice ${quizIndex + 1} of ${lesson.quizzes.length}',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: CsHybridTheme.textSecondary),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CsHybridTheme.codeBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(q.code, style: const TextStyle(color: CsHybridTheme.consoleGreen, fontFamily: 'monospace', height: 1.4, fontSize: 12)),
        ),
        const SizedBox(height: 14),
        Text(q.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (int i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: _optionColor(i, q, picked, revealed),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: revealed ? null : () => onPick(i),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: CsHybridTheme.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${String.fromCharCode(65 + i)}. ${q.options[i]}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ),
          ),
        if (revealed) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            correct ? 'Correct!' : 'Not quite — ${q.options[q.correctIndex]}',
            style: TextStyle(color: correct ? CsHybridTheme.primary : CsHybridTheme.error, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(q.explanation, style: const TextStyle(color: CsHybridTheme.textSecondary, height: 1.45, fontSize: 13)),
          const SizedBox(height: 12),
          if (lesson.quizzes.length > 1)
            FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(backgroundColor: CsHybridTheme.primary, foregroundColor: Colors.white),
              child: const Text('Next question'),
            ),
        ],
      ],
    );
  }

  Color _optionColor(int i, CsBigOQuiz q, int? picked, bool revealed) {
    if (!revealed) return CsHybridTheme.surface;
    if (i == q.correctIndex) return CsHybridTheme.primary.withValues(alpha: 0.12);
    if (i == picked) return CsHybridTheme.error.withValues(alpha: 0.12);
    return CsHybridTheme.surface;
  }
}
