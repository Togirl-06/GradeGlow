import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../data/coding_languages.dart';
import '../../data/cs_curriculum/cs_curriculum_catalog.dart';
import '../../data/cs_curriculum/cs_curriculum_workspace_builder.dart';
import '../../data/cs_w3s_catalog.dart';
import '../../models/cs_curriculum.dart';
import '../../models/cs_w3s_topic.dart';
import '../../models/leetcode_problem.dart';
import '../../services/cs_curriculum_progress_service.dart';
import '../../services/practice_lab_service.dart';
import '../../theme/cs_hybrid_theme.dart';
import '../../utils/network_reachability.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/cs/cs_hybrid_panels.dart';
import '../../widgets/leetcode/leetcode_problem_panel.dart';

/// W3Schools + LeetCode hybrid: lesson → try it → problems in one workspace.
class CsHybridWorkspaceScreen extends StatefulWidget {
  const CsHybridWorkspaceScreen({
    super.key,
    this.initialTopicId,
    this.curriculumLanguageId,
    this.startInPracticeMode = false,
  });

  final String? initialTopicId;
  final String? curriculumLanguageId;
  /// Opens directly on coding problems (Easy) for [initialTopicId].
  final bool startInPracticeMode;

  @override
  State<CsHybridWorkspaceScreen> createState() => _CsHybridWorkspaceScreenState();
}

class _CsHybridWorkspaceScreenState extends State<CsHybridWorkspaceScreen> {
  late CsW3sTopic _topic;
  final TextEditingController _tryItCode = TextEditingController();
  final TextEditingController _problemCode = TextEditingController();
  CodingLanguage _language = CodingLanguage.defaultLanguage;

  bool _problemMode = false;
  bool _practiceFocus = false;
  CsProblemTier _tier = CsProblemTier.easy;
  bool _loading = false;
  bool _hintLoading = false;
  bool _loadingOptimal = false;
  String? _tryItOutput;
  LeetcodeRunResult? _runResult;
  final List<String> _hints = <String>[];
  String? _optimalExplanation;
  bool _submitted = false;
  int _mobileTab = 0;

  @override
  void initState() {
    super.initState();
    final CsCurriculumLanguage? curriculumLang =
        CsCurriculumCatalog.languageById(widget.curriculumLanguageId ?? '');
    if (curriculumLang != null) {
      _language = CodingLanguage.byId(curriculumLang.codingLanguageId) ?? CodingLanguage.defaultLanguage;
    }
    _topic = _resolveTopic(widget.initialTopicId);
    _practiceFocus = widget.startInPracticeMode;
    _problemMode = widget.startInPracticeMode;
    _mobileTab = widget.startInPracticeMode ? 1 : 0;
    _loadTopicEditors();
  }

  static CsW3sTopic _resolveTopic(String? id) {
    if (id != null && id.isNotEmpty) {
      return CsW3sCatalog.byId(id) ??
          CsCurriculumWorkspaceBuilder.resolveTopic(id) ??
          CsW3sCatalog.defaultTopic;
    }
    return CsW3sCatalog.defaultTopic;
  }

  @override
  void dispose() {
    _tryItCode.dispose();
    _problemCode.dispose();
    super.dispose();
  }

  void _loadTopicEditors() {
    _tryItCode.text = _topic.tryItStarterFor(_language.id);
    _problemCode.text = CodingLanguage.starterForProblem(_activeProblem, _language);
    _tryItOutput = null;
    _runResult = null;
    _hints.clear();
    _optimalExplanation = null;
    _submitted = false;
  }

  LeetcodeProblem get _activeProblem => _topic.problemFor(_tier);

  void _selectTopic(CsW3sTopic topic) {
    setState(() {
      _topic = topic;
      _problemMode = _practiceFocus;
      _tier = CsProblemTier.easy;
      _loadTopicEditors();
    });
  }

  void _selectCurriculumTopic(CsCurriculumTopic topic) {
    final CsW3sTopic? resolved = CsCurriculumWorkspaceBuilder.resolveTopic(topic.id);
    if (resolved == null) return;
    setState(() {
      _topic = resolved;
      _problemMode = _practiceFocus;
      _tier = CsProblemTier.easy;
      _loadTopicEditors();
    });
  }

  void _onLanguageChange(CodingLanguage lang) {
    setState(() {
      _language = lang;
      _tryItCode.text = _topic.tryItStarterFor(lang.id);
      _problemCode.text = CodingLanguage.starterForProblem(_activeProblem, lang);
    });
  }

  void _onTierChange(CsProblemTier tier) {
    setState(() {
      _tier = tier;
      _problemCode.text = CodingLanguage.starterForProblem(_activeProblem, _language);
      _runResult = null;
      _hints.clear();
      _optimalExplanation = null;
      _submitted = false;
    });
  }

  Future<void> _runTryIt() async {
    if (!AppConfig.hasOpenAi) {
      StudyMessenger.showError(context, 'OpenAI is not configured.');
      return;
    }
    setState(() {
      _loading = true;
      _tryItOutput = null;
      _runResult = null;
    });
    final PracticeLabService labs = context.read<PracticeLabService>();
    try {
      await ensureOpenAiReachable();
      final String out = await labs.runCodeSnippet(
        language: _language.id,
        code: _tryItCode.text,
        taskContext: '${_topic.tryIt.task}\n${_topic.tryIt.runContext}',
      );
      if (!mounted) return;
      setState(() => _tryItOutput = out);
    } catch (e) {
      if (mounted) StudyMessenger.showError(context, '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _runProblem({required bool submit}) async {
    if (!AppConfig.hasOpenAi) {
      StudyMessenger.showError(context, 'OpenAI is not configured.');
      return;
    }
    setState(() {
      _loading = true;
      if (!submit) _runResult = null;
    });
    final PracticeLabService labs = context.read<PracticeLabService>();
    try {
      await ensureOpenAiReachable();
      final LeetcodeRunResult result = await labs.runLeetcodeTests(
        problem: _activeProblem,
        language: _language.id,
        code: _problemCode.text,
        submit: submit,
      );
      if (!mounted) return;
      setState(() {
        _runResult = result;
        _submitted = submit;
        _tryItOutput = null;
      });
      if (submit && result.accepted) {
        final String tierLabel = switch (_tier) {
          CsProblemTier.easy => 'Easy',
          CsProblemTier.medium => 'Medium',
          CsProblemTier.hard => 'Hard',
        };
        await context.read<CsCurriculumProgressService>().recordProblemSolved(
          topicId: _topic.id,
          tier: tierLabel,
          accepted: true,
        );
      }
    } catch (e) {
      if (mounted) StudyMessenger.showError(context, '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<String>> _requestHintAndReturn() async {
    await _requestHint();
    return List<String>.from(_hints);
  }

  Future<void> _requestHint() async {
    if (_hints.length >= 4) return;
    setState(() => _hintLoading = true);
    try {
      final PracticeLabService labs = context.read<PracticeLabService>();
      final String hint = await labs.requestLeetcodeHint(
        problem: _activeProblem,
        hintLevel: _hints.length + 1,
        language: _language.id,
        currentCode: _problemCode.text,
      );
      if (!mounted) return;
      setState(() => _hints.add(hint));
    } catch (e) {
      if (mounted) StudyMessenger.showError(context, '$e');
    } finally {
      if (mounted) setState(() => _hintLoading = false);
    }
  }

  Future<void> _showOptimal() async {
    setState(() => _loadingOptimal = true);
    try {
      final PracticeLabService labs = context.read<PracticeLabService>();
      final String text = await labs.requestOptimalExplanation(
        problem: _activeProblem,
        language: _language.id,
      );
      if (!mounted) return;
      setState(() => _optimalExplanation = text);
    } catch (e) {
      if (mounted) StudyMessenger.showError(context, '$e');
    } finally {
      if (mounted) setState(() => _loadingOptimal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CsHybridTheme.background,
      appBar: AppBar(
        backgroundColor: CsHybridTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.startInPracticeMode ? 'Practice: ${_topic.title}' : 'Learn by Coding'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                _topic.track,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth >= 960;
          if (!wide && _practiceFocus) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CsHybridRightHeader(
                  topic: _topic,
                  problemMode: true,
                  tier: _tier,
                  onSelectMode: (bool v) => setState(() => _problemMode = v),
                  onSelectTier: _onTierChange,
                ),
                Expanded(
                  flex: 2,
                  child: CsProblemStatement(problem: _activeProblem),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: CsHybridTheme.border), bottom: BorderSide(color: CsHybridTheme.border)),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Text('Your solution', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      const Spacer(),
                      CsPracticeHintsButton(
                        hints: _hints,
                        hintLoading: _hintLoading,
                        onRequestHint: _requestHintAndReturn,
                        compact: true,
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: _loading ? null : () => _runProblem(submit: false), child: const Text('Run')),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _loading ? null : () => _runProblem(submit: true),
                        style: FilledButton.styleFrom(backgroundColor: CsHybridTheme.primary, foregroundColor: Colors.white),
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LeetcodeCodeEditor(
                    controller: _problemCode,
                    language: _language,
                    onChangeLanguage: _onLanguageChange,
                  ),
                ),
                if (_runResult != null || _loading || _optimalExplanation != null)
                  SizedBox(
                    height: 160,
                    child: CsHybridOutputPanel(
                      stdout: _tryItOutput,
                      result: _runResult,
                      loading: _loading,
                      optimalExplanation: _optimalExplanation,
                      loadingOptimal: _loadingOptimal,
                      showOptimalButton: _submitted,
                      onShowOptimal: _showOptimal,
                    ),
                  ),
              ],
            );
          }
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: 220,
                  child: widget.curriculumLanguageId != null
                      ? _CurriculumSidebar(
                          languageId: widget.curriculumLanguageId!,
                          topic: _topic,
                          onSelect: _selectCurriculumTopic,
                        )
                      : _TopicSidebar(topic: _topic, onSelect: _selectTopic),
                ),
                const VerticalDivider(width: 1, color: CsHybridTheme.border),
                Expanded(flex: 3, child: _CenterPanel(
                  topic: _topic,
                  problemMode: _problemMode,
                  tier: _tier,
                  tryItController: _tryItCode,
                  problemController: _problemCode,
                  language: _language,
                  onLanguageChange: _onLanguageChange,
                  onRunTryIt: _runTryIt,
                  onRunProblem: () => _runProblem(submit: false),
                  onSubmitProblem: () => _runProblem(submit: true),
                  loading: _loading,
                  showLesson: !_practiceFocus,
                )),
                const VerticalDivider(width: 1, color: CsHybridTheme.border),
                SizedBox(width: 340, child: _RightPanel(
                  topic: _topic,
                  language: _language,
                  problemMode: _problemMode,
                  tier: _tier,
                  onSelectMode: (bool v) => setState(() {
                    _problemMode = v;
                    _runResult = null;
                    _tryItOutput = null;
                  }),
                  onSelectTier: _onTierChange,
                  tryItOutput: _tryItOutput,
                  runResult: _runResult,
                  loading: _loading,
                  hints: _hints,
                  hintLoading: _hintLoading,
                  onRequestHint: _problemMode ? _requestHintAndReturn : null,
                  optimalExplanation: _optimalExplanation,
                  loadingOptimal: _loadingOptimal,
                  showOptimalButton: _submitted,
                  onShowOptimal: _showOptimal,
                )),
              ],
            );
          }
          return Column(
            children: <Widget>[
              NavigationBar(
                selectedIndex: _mobileTab,
                onDestinationSelected: (int i) => setState(() => _mobileTab = i),
                destinations: const <NavigationDestination>[
                  NavigationDestination(icon: Icon(Icons.list), label: 'Topics'),
                  NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Learn'),
                  NavigationDestination(icon: Icon(Icons.terminal), label: 'Output'),
                ],
              ),
              Expanded(
                child: switch (_mobileTab) {
                  0 => widget.curriculumLanguageId != null
                      ? _CurriculumSidebar(
                          languageId: widget.curriculumLanguageId!,
                          topic: _topic,
                          onSelect: (CsCurriculumTopic t) {
                            _selectCurriculumTopic(t);
                            setState(() => _mobileTab = 1);
                          },
                        )
                      : _TopicSidebar(topic: _topic, onSelect: (CsW3sTopic t) {
                          _selectTopic(t);
                          setState(() => _mobileTab = 1);
                        }),
                  1 => _CenterPanel(
                    topic: _topic,
                    problemMode: _problemMode,
                    tier: _tier,
                    tryItController: _tryItCode,
                    problemController: _problemCode,
                    language: _language,
                    onLanguageChange: _onLanguageChange,
                    onRunTryIt: _runTryIt,
                    onRunProblem: () => _runProblem(submit: false),
                    onSubmitProblem: () => _runProblem(submit: true),
                    loading: _loading,
                    showLesson: !_practiceFocus,
                    rightHeader: CsHybridRightHeader(
                      topic: _topic,
                      problemMode: _problemMode,
                      tier: _tier,
                      onSelectMode: (bool v) => setState(() => _problemMode = v),
                      onSelectTier: _onTierChange,
                      hints: _hints,
                      hintLoading: _hintLoading,
                      onRequestHint: _problemMode ? _requestHintAndReturn : null,
                    ),
                  ),
                  _ => _RightPanel(
                    topic: _topic,
                    language: _language,
                    problemMode: _problemMode,
                    tier: _tier,
                    onSelectMode: (bool v) => setState(() => _problemMode = v),
                    onSelectTier: _onTierChange,
                    tryItOutput: _tryItOutput,
                    runResult: _runResult,
                    loading: _loading,
                    hints: _hints,
                    hintLoading: _hintLoading,
                    onRequestHint: _problemMode ? _requestHintAndReturn : null,
                    optimalExplanation: _optimalExplanation,
                    loadingOptimal: _loadingOptimal,
                    showOptimalButton: _submitted,
                    onShowOptimal: _showOptimal,
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

class _CurriculumSidebar extends StatelessWidget {
  const _CurriculumSidebar({required this.languageId, required this.topic, required this.onSelect});

  final String languageId;
  final CsW3sTopic topic;
  final ValueChanged<CsCurriculumTopic> onSelect;

  @override
  Widget build(BuildContext context) {
    final CsCurriculumProgressService progress = context.watch<CsCurriculumProgressService>();
    final List<CsCurriculumTopic> topics = languageId == 'algorithms'
        ? CsCurriculumCatalog.algorithmsTopics
            .map(
              (CsAlgorithmsTopic t) => CsCurriculumTopic(
                id: t.id,
                languageId: 'algorithms',
                title: t.title,
                order: t.order,
                level: t.level,
              ),
            )
            .toList()
        : CsCurriculumCatalog.topicsForLanguage(languageId);

    return ColoredBox(
      color: CsHybridTheme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          for (final CsCurriculumLevel level in CsCurriculumLevel.values) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Text(
                level.label.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: CsHybridTheme.textSecondary, letterSpacing: 0.8),
              ),
            ),
            for (final CsCurriculumTopic item in topics.where((CsCurriculumTopic t) => t.level == level))
              _TopicTile(
                  title: item.title,
                  selected: topic.id == item.id,
                  completed: progress.isCompleted(item.id),
                  onTap: () => onSelect(item),
                ),
          ],
        ],
      ),
    );
  }
}

class _TopicSidebar extends StatelessWidget {
  const _TopicSidebar({required this.topic, required this.onSelect});

  final CsW3sTopic topic;
  final ValueChanged<CsW3sTopic> onSelect;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CsHybridTheme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          for (final CsW3sTrack track in CsW3sCatalog.tracks) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Text(track.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: CsHybridTheme.textSecondary, letterSpacing: 0.8)),
            ),
            for (final String id in track.topicIds)
              if (CsW3sCatalog.byId(id) != null)
                _TopicTile(
                  title: CsW3sCatalog.byId(id)!.title,
                  selected: topic.id == id,
                  onTap: () => onSelect(CsW3sCatalog.byId(id)!),
                ),
          ],
        ],
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.completed = false,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool completed;

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
          child: Row(
            children: <Widget>[
              if (completed)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(Icons.check_circle, size: 14, color: CsHybridTheme.primary),
                ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: selected ? CsHybridTheme.primaryDark : CsHybridTheme.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterPanel extends StatelessWidget {
  const _CenterPanel({
    required this.topic,
    required this.problemMode,
    required this.tier,
    required this.tryItController,
    required this.problemController,
    required this.language,
    required this.onLanguageChange,
    required this.onRunTryIt,
    required this.onRunProblem,
    required this.onSubmitProblem,
    required this.loading,
    this.showLesson = true,
    this.rightHeader,
  });

  final CsW3sTopic topic;
  final bool problemMode;
  final CsProblemTier tier;
  final TextEditingController tryItController;
  final TextEditingController problemController;
  final CodingLanguage language;
  final ValueChanged<CodingLanguage> onLanguageChange;
  final VoidCallback onRunTryIt;
  final VoidCallback onRunProblem;
  final VoidCallback onSubmitProblem;
  final bool loading;
  final bool showLesson;
  final Widget? rightHeader;

  @override
  Widget build(BuildContext context) {
    final TextEditingController activeController = problemMode ? problemController : tryItController;
    return ColoredBox(
      color: CsHybridTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ?rightHeader,
          if (showLesson)
            SizedBox(
              height: 200,
              child: CsLessonPanel(topic: topic, language: language),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: CsHybridTheme.border), bottom: BorderSide(color: CsHybridTheme.border)),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  problemMode ? topic.problemFor(tier).title : 'Try It Yourself',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const Spacer(),
                if (!problemMode)
                  FilledButton.icon(
                    onPressed: loading ? null : onRunTryIt,
                    style: FilledButton.styleFrom(backgroundColor: CsHybridTheme.primary, foregroundColor: Colors.white),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Run'),
                  )
                else ...<Widget>[
                  OutlinedButton(onPressed: loading ? null : onRunProblem, child: const Text('Run')),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: loading ? null : onSubmitProblem,
                    style: FilledButton.styleFrom(backgroundColor: CsHybridTheme.primary, foregroundColor: Colors.white),
                    child: const Text('Submit'),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: LeetcodeCodeEditor(
              controller: activeController,
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
    required this.topic,
    required this.language,
    required this.problemMode,
    required this.tier,
    required this.onSelectMode,
    required this.onSelectTier,
    required this.tryItOutput,
    required this.runResult,
    required this.loading,
    required this.hints,
    required this.hintLoading,
    this.onRequestHint,
    this.optimalExplanation,
    this.loadingOptimal = false,
    this.showOptimalButton = false,
    this.onShowOptimal,
  });

  final CsW3sTopic topic;
  final CodingLanguage language;
  final bool problemMode;
  final CsProblemTier tier;
  final ValueChanged<bool> onSelectMode;
  final ValueChanged<CsProblemTier> onSelectTier;
  final String? tryItOutput;
  final LeetcodeRunResult? runResult;
  final bool loading;
  final List<String> hints;
  final bool hintLoading;
  final Future<List<String>> Function()? onRequestHint;
  final String? optimalExplanation;
  final bool loadingOptimal;
  final bool showOptimalButton;
  final VoidCallback? onShowOptimal;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CsHybridTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CsHybridRightHeader(
            topic: topic,
            problemMode: problemMode,
            tier: tier,
            onSelectMode: onSelectMode,
            onSelectTier: onSelectTier,
            hints: hints,
            hintLoading: hintLoading,
            onRequestHint: onRequestHint,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: problemMode
                      ? CsProblemStatement(problem: topic.problemFor(tier))
                      : CsTryItPanel(topic: topic, language: language),
                ),
                const VerticalDivider(width: 1, color: CsHybridTheme.border),
                Expanded(
                  flex: 4,
                  child: CsHybridOutputPanel(
                    stdout: tryItOutput,
                    result: runResult,
                    loading: loading,
                    optimalExplanation: optimalExplanation,
                    loadingOptimal: loadingOptimal,
                    showOptimalButton: showOptimalButton,
                    onShowOptimal: onShowOptimal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
