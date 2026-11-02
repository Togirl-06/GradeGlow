import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/parsed_question.dart';
import '../models/search_filters.dart';
import '../models/solution.dart';
import '../models/study_material.dart';
import '../services/auth_service.dart';
import '../services/flashcard_service.dart';
import '../services/material_service.dart';
import '../services/question_service.dart';
import '../services/solution_service.dart';
import '../services/tutor_context_service.dart';
import '../services/tutor_voice_service.dart';
import '../services/user_service.dart';
import '../theme/study_theme.dart';
import '../utils/gamification.dart';
import '../widgets/study_surface.dart';
import '../widgets/voice_study_panel.dart';

/// Practice test from parsed exam questions with hide/reveal answers.
class QuizModeScreen extends StatefulWidget {
  const QuizModeScreen({super.key, this.initialMaterialId});

  final String? initialMaterialId;

  @override
  State<QuizModeScreen> createState() => _QuizModeScreenState();
}

class _QuizModeScreenState extends State<QuizModeScreen> {
  String? _materialId;
  int _index = 0;
  bool _revealed = false;
  bool _hideAll = true;
  final Map<String, String?> _answers = <String, String?>{};
  final Set<String> _correctIds = <String>{};
  final Set<String> _wrongIds = <String>{};
  bool _loadingAnswer = false;

  // Verbal quiz mode: AI reads the question aloud, listens for the spoken
  // answer, then reveals and reads the posted solution aloud.
  final TutorVoiceService _voice = TutorVoiceService();
  bool _voiceMode = false;
  bool _voiceSpeaking = false;
  bool _voiceListening = false;
  String _partial = '';
  String _heardAnswer = '';
  double _voiceLevel = 0;
  String? _voicedQuestionId;

  @override
  void initState() {
    super.initState();
    _materialId = widget.initialMaterialId;
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceMode() async {
    if (_voiceMode) {
      await _stopVoiceMode();
      return;
    }
    final VoiceCapabilities cap = await _voice.initialize();
    if (!mounted) return;
    if (!cap.canListen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cap.statusMessage ?? 'Microphone unavailable on this device.')),
      );
      return;
    }
    setState(() {
      _voiceMode = true;
      _voicedQuestionId = null;
    });
  }

  Future<void> _stopVoiceMode() async {
    _voiceListening = false;
    await _voice.stopListening();
    await _voice.stopSpeaking();
    if (!mounted) return;
    setState(() {
      _voiceMode = false;
      _voiceSpeaking = false;
      _voiceListening = false;
      _partial = '';
      _voiceLevel = 0;
      _voicedQuestionId = null;
    });
  }

  /// Read the question aloud, capture the spoken answer, then reveal and read
  /// the posted solution. Runs once per question (tracked by [_voicedQuestionId]).
  Future<void> _maybeRunVoiceCycle(ParsedQuestion question, SolutionService solutions) async {
    if (!_voiceMode || !mounted) return;
    if (_voiceSpeaking || _voiceListening) return;
    if (_voicedQuestionId == question.id) return;
    _voicedQuestionId = question.id;

    setState(() {
      _voiceSpeaking = true;
      _heardAnswer = '';
      _partial = '';
    });
    await _voice.speak('Question. ${question.text}');
    if (!mounted || !_voiceMode || _voicedQuestionId != question.id) return;

    setState(() {
      _voiceSpeaking = false;
      _voiceListening = true;
    });
    final String? answer = await _voice.captureSpokenAnswer(
      shouldContinue: () =>
          mounted && _voiceMode && _voiceListening && _voicedQuestionId == question.id,
      onLevel: (double level) {
        if (mounted) setState(() => _voiceLevel = level);
      },
      onPartial: (String words) {
        if (mounted) setState(() => _partial = words);
      },
      silenceFor: const Duration(milliseconds: 2200),
      maxDuration: const Duration(seconds: 30),
    );
    if (!mounted || !_voiceMode || _voicedQuestionId != question.id) return;

    final QuestionSolution? top = await solutions.getTopSolution(question.id);
    final String solutionText = top != null
        ? (top.finalAnswer.isNotEmpty ? top.finalAnswer : top.stepByStep)
        : '';
    if (!mounted || !_voiceMode || _voicedQuestionId != question.id) return;

    setState(() {
      _voiceListening = false;
      _voiceLevel = 0;
      _heardAnswer = (answer ?? '').trim();
      _revealed = true;
      _answers[question.id] = solutionText.isEmpty ? null : solutionText;
      _voiceSpeaking = true;
    });
    await _voice.speak(
      solutionText.isNotEmpty
          ? 'The answer is. $solutionText'
          : 'No solution has been posted for this question yet.',
    );
    if (mounted) setState(() => _voiceSpeaking = false);
  }

  Future<void> _loadAnswer(SolutionService solutions, String questionId) async {
    if (_answers.containsKey(questionId)) return;
    setState(() => _loadingAnswer = true);
    final QuestionSolution? top = await solutions.getTopSolution(questionId);
    if (!mounted) return;
    setState(() {
      _answers[questionId] = top != null
          ? (top.finalAnswer.isNotEmpty ? top.finalAnswer : top.stepByStep)
          : null;
      _loadingAnswer = false;
    });
  }

  List<ParsedQuestion> _questionsForMaterial(List<ParsedQuestion> all, String? materialId) {
    if (materialId == null || materialId.isEmpty) return all;
    return all.where((ParsedQuestion q) => q.materialId == materialId).toList()
      ..sort((ParsedQuestion a, ParsedQuestion b) => a.orderIndex.compareTo(b.orderIndex));
  }

  @override
  Widget build(BuildContext context) {
    final QuestionService questions = context.watch<QuestionService>();
    final MaterialService materials = context.watch<MaterialService>();
    final SolutionService solutions = context.read<SolutionService>();
    final FlashcardService flashcards = context.read<FlashcardService>();
    final UserService users = context.read<UserService>();
    final TutorContextService tutorContext = context.read<TutorContextService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz mode'),
        actions: <Widget>[
          IconButton(
            tooltip: _voiceMode ? 'Turn off hands-free' : 'Hands-free voice mode',
            onPressed: _toggleVoiceMode,
            icon: Icon(
              _voiceMode ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
              color: _voiceMode ? StudyColors.primary : null,
            ),
          ),
          IconButton(
            tooltip: _hideAll ? 'Reveal all' : 'Hide all',
            onPressed: () => setState(() {
              _hideAll = !_hideAll;
              _revealed = !_hideAll;
            }),
            icon: Icon(_hideAll ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<StudyMaterial>>(
        stream: materials.watchMaterials(),
        builder: (BuildContext context, AsyncSnapshot<List<StudyMaterial>> matSnap) {
          final List<StudyMaterial> allMaterials =
              (matSnap.data ?? <StudyMaterial>[]).where((StudyMaterial m) => m.isParsed).toList();

          return StreamBuilder<List<ParsedQuestion>>(
            stream: questions.watchQuestions(const SearchFilters()),
            builder: (BuildContext context, AsyncSnapshot<List<ParsedQuestion>> qSnap) {
              final List<ParsedQuestion> pool = _questionsForMaterial(qSnap.data ?? <ParsedQuestion>[], _materialId);

              if (pool.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: <Widget>[
                    Text(
                      'Upload an exam to start a practice test.',
                      style: TextStyle(color: textSecondary),
                    ),
                    if (allMaterials.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 16),
                      const Text('Select an exam', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ...allMaterials.map(
                        (StudyMaterial m) => ListTile(
                          title: Text('${m.courseCode} · ${m.examType}'),
                          subtitle: Text(m.fileName),
                          onTap: () => setState(() {
                            _materialId = m.id;
                            _index = 0;
                            _revealed = false;
                          }),
                        ),
                      ),
                    ],
                  ],
                );
              }

              if (_materialId == null && allMaterials.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _materialId == null) {
                    setState(() => _materialId = widget.initialMaterialId ?? allMaterials.first.id);
                  }
                });
              }

              final ParsedQuestion current = pool[_index.clamp(0, pool.length - 1)];
              final bool showAnswer = !_hideAll || _revealed;

              if (showAnswer && !_answers.containsKey(current.id)) {
                _loadAnswer(solutions, current.id);
              }

              final String? answer = _answers[current.id];

              if (_voiceMode) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _maybeRunVoiceCycle(current, solutions);
                });
              }

              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            initialValue: _materialId,
                            decoration: const InputDecoration(
                              labelText: 'Exam',
                              isDense: true,
                            ),
                            items: <DropdownMenuItem<String?>>[
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All questions'),
                              ),
                              ...allMaterials.map(
                                (StudyMaterial m) => DropdownMenuItem<String?>(
                                  value: m.id,
                                  child: Text('${m.courseCode} · ${m.examType}'),
                                ),
                              ),
                            ],
                              onChanged: (String? id) {
                              final List<ParsedQuestion> nextPool =
                                  _questionsForMaterial(qSnap.data ?? <ParsedQuestion>[], id);
                              StudyMaterial? mat;
                              for (final StudyMaterial m in allMaterials) {
                                if (m.id == id) {
                                  mat = m;
                                  break;
                                }
                              }
                              if (mat != null) {
                                tutorContext.setFromMaterial(mat, nextPool);
                              }
                              setState(() {
                                _materialId = id;
                                _index = 0;
                                _revealed = false;
                                _correctIds.clear();
                                _wrongIds.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: LinearProgressIndicator(
                      value: (_index + 1) / pool.length,
                      backgroundColor: StudyColors.primaryTint(Theme.of(context).brightness),
                      color: StudyColors.primary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Question ${_index + 1} of ${pool.length} · ${current.courseCode}',
                      style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: <Widget>[
                        StudySurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Question', style: TextStyle(fontWeight: FontWeight.w700, color: StudyColors.primary)),
                              const SizedBox(height: 8),
                              Text(current.text, style: const TextStyle(fontSize: 16, height: 1.45)),
                            ],
                          ),
                        ),
                        if (_voiceMode) ...<Widget>[
                          const SizedBox(height: 12),
                          VoiceStudyPanel(
                            speaking: _voiceSpeaking,
                            listening: _voiceListening,
                            level: _voiceLevel,
                            partial: _partial,
                            heardAnswer: _heardAnswer,
                            onStopListening: () => _voice.stopListening(),
                            onReplay: _voiceSpeaking || _voiceListening
                                ? null
                                : () {
                                    _voicedQuestionId = null;
                                    _maybeRunVoiceCycle(current, solutions);
                                  },
                          ),
                        ],
                        const SizedBox(height: 12),
                        StudySurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Answer', style: TextStyle(fontWeight: FontWeight.w700, color: StudyColors.primary)),
                                  TextButton(
                                    onPressed: () => setState(() => _revealed = !_revealed),
                                    child: Text(showAnswer ? 'Hide' : 'Reveal'),
                                  ),
                                ],
                              ),
                              if (!showAnswer)
                                Text(
                                  'Tap Reveal when you are ready.',
                                  style: TextStyle(color: textSecondary, fontStyle: FontStyle.italic),
                                )
                              else if (_loadingAnswer)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              else if (answer != null && answer.isNotEmpty)
                                Text(answer, style: const TextStyle(fontSize: 16, height: 1.45))
                              else
                                Text(
                                  'No solution posted yet. Work through it, then add one from Browse.',
                                  style: TextStyle(color: textSecondary, height: 1.4),
                                ),
                            ],
                          ),
                        ),
                        if (showAnswer) ...<Widget>[
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _wrongIds.add(current.id);
                                      _correctIds.remove(current.id);
                                    });
                                    await users.recordQuizMiss(current);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Added to weak topics')),
                                    );
                                  },
                                  child: const Text('Got it wrong'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _correctIds.add(current.id);
                                      _wrongIds.remove(current.id);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Nice!')),
                                    );
                                  },
                                  child: const Text('Got it right'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (showAnswer && answer != null && answer.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await flashcards.addCard(
                                questionId: current.id,
                                front: current.text,
                                back: answer,
                                courseCode: current.courseCode,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Saved to flashcards')),
                              );
                            },
                            icon: const Icon(Icons.style_outlined),
                            label: const Text('Save as flashcard'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _index > 0
                                ? () => setState(() {
                                      _index -= 1;
                                      _revealed = !_hideAll;
                                    })
                                : null,
                            child: const Text('Previous'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              if (_index < pool.length - 1) {
                                setState(() {
                                  _index += 1;
                                  _revealed = !_hideAll;
                                });
                              } else {
                                final String? uid = context.read<AuthService>().uid;
                                if (uid != null) {
                                  await users.recordStudyActivity(uid);
                                  await users.addXp(Gamification.xpQuizComplete);
                                  await users.recordQuizResult(
                                    courseCode: current.courseCode,
                                    correct: _correctIds.length,
                                    total: pool.length,
                                  );
                                }
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Practice test complete! +${Gamification.xpQuizComplete} XP')),
                                );
                                setState(() {
                                  _index = 0;
                                  _revealed = false;
                                });
                              }
                            },
                            child: Text(_index < pool.length - 1 ? 'Next' : 'Finish'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
