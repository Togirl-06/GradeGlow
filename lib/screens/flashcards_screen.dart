import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/flashcard.dart';
import '../models/parsed_question.dart';
import '../models/solution.dart';
import '../models/search_filters.dart';
import '../models/study_material.dart';
import '../services/auth_service.dart';
import '../services/flashcard_service.dart';
import '../services/material_service.dart';
import '../services/question_service.dart';
import '../services/solution_service.dart';
import '../services/tutor_voice_service.dart';
import '../services/user_service.dart';
import '../utils/gamification.dart';
import '../utils/speech_text.dart';
import '../theme/study_theme.dart';
import '../widgets/read_aloud_button.dart';
import '../widgets/study_surface.dart';
import '../widgets/voice_study_panel.dart';
import '../utils/study_messenger.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  bool _studying = false;
  int _studyIndex = 0;
  bool _flipped = false;
  List<Flashcard> _dueSession = <Flashcard>[];

  // Verbal (hands-free) flashcard mode: AI speaks the question, listens for the
  // student's spoken answer, then reveals and reads the answer aloud.
  final TutorVoiceService _voice = TutorVoiceService();
  bool _voiceMode = false;
  bool _voiceSpeaking = false;
  bool _voiceListening = false;
  String _heardAnswer = '';
  String _partial = '';
  double _voiceLevel = 0;
  int _voicedIndex = -1;

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
      _voicedIndex = -1;
    });
    _runVoiceCardCycle();
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
    });
  }

  /// Speak the current card's question, capture the spoken answer, then reveal
  /// and read the answer aloud. Runs once per card (tracked by [_voicedIndex]).
  Future<void> _runVoiceCardCycle() async {
    if (!_voiceMode || !_studying || _dueSession.isEmpty) return;
    if (_voicedIndex == _studyIndex) return;
    _voicedIndex = _studyIndex;
    final Flashcard card = _dueSession[_studyIndex];

    setState(() {
      _voiceSpeaking = true;
      _heardAnswer = '';
      _partial = '';
      _flipped = false;
    });
    await _voice.speak('Question. ${card.front}');
    if (!mounted || !_voiceMode || _voicedIndex != _studyIndex) return;

    setState(() {
      _voiceSpeaking = false;
      _voiceListening = true;
    });
    final String? answer = await _voice.captureSpokenAnswer(
      shouldContinue: () => mounted && _voiceMode && _voiceListening && _voicedIndex == _studyIndex,
      onLevel: (double level) {
        if (mounted) setState(() => _voiceLevel = level);
      },
      onPartial: (String words) {
        if (mounted) setState(() => _partial = words);
      },
      silenceFor: const Duration(milliseconds: 2200),
      maxDuration: const Duration(seconds: 30),
    );
    if (!mounted || !_voiceMode || _voicedIndex != _studyIndex) return;

    setState(() {
      _voiceListening = false;
      _voiceLevel = 0;
      _heardAnswer = (answer ?? '').trim();
      _flipped = true;
      _voiceSpeaking = true;
    });
    await _voice.speak('The answer is. ${card.back}');
    if (mounted) setState(() => _voiceSpeaking = false);
  }

  Future<void> _importFromMaterial(
    BuildContext context,
    StudyMaterial material,
    List<ParsedQuestion> questions,
    SolutionService solutions,
    FlashcardService flashcards,
  ) async {
    final List<ParsedQuestion> mine =
        questions.where((ParsedQuestion q) => q.materialId == material.id).toList();
    if (mine.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No questions found for this exam.')),
      );
      return;
    }

    int added = 0;
    for (final ParsedQuestion q in mine) {
      final QuestionSolution? top = await solutions.getTopSolution(q.id);
      final String back = top != null
          ? (top.finalAnswer.isNotEmpty ? top.finalAnswer : top.stepByStep)
          : '';
      if (back.isEmpty) continue;
      await flashcards.addCard(
        questionId: q.id,
        front: q.text,
        back: back,
        courseCode: q.courseCode,
      );
      added++;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $added flashcard${added == 1 ? '' : 's'}')),
    );
  }

  void _startSession(List<Flashcard> due) {
    if (due.isEmpty) return;
    setState(() {
      _dueSession = due;
      _studyIndex = 0;
      _flipped = false;
      _studying = true;
    });
  }

  Future<void> _rate(FlashcardService flashcards, int quality) async {
    if (_dueSession.isEmpty) return;
    final Flashcard card = _dueSession[_studyIndex];
    final AuthService auth = context.read<AuthService>();
    final UserService users = context.read<UserService>();
    await flashcards.rateCard(card.id, quality);

    if (_studyIndex >= _dueSession.length - 1) {
      final String? uid = auth.uid;
      if (uid != null) {
        await users.recordStudyActivity(uid);
        await users.addXp(Gamification.xpFlashcardSession);
      }
      if (!mounted) return;
      if (_voiceMode) await _stopVoiceMode();
      if (!mounted) return;
      setState(() {
        _studying = false;
        _dueSession = <Flashcard>[];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session complete! +${Gamification.xpFlashcardSession} XP')),
      );
      return;
    }

    setState(() {
      _studyIndex += 1;
      _flipped = false;
    });
    if (_voiceMode) _runVoiceCardCycle();
  }

  @override
  Widget build(BuildContext context) {
    final FlashcardService flashcards = context.watch<FlashcardService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    if (_studying && _dueSession.isNotEmpty) {
      final Flashcard card = _dueSession[_studyIndex];
      return Scaffold(
        appBar: AppBar(
          title: Text('Review ${_studyIndex + 1}/${_dueSession.length}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (_voiceMode) await _stopVoiceMode();
              if (mounted) setState(() => _studying = false);
            },
          ),
          actions: <Widget>[
            ReadAloudButton(
              key: ValueKey<String>('$_studyIndex-$_flipped'),
              textBuilder: () => speechTextFromMarkdown(
                _flipped ? card.back : card.front,
              ),
            ),
            IconButton(
              tooltip: _voiceMode ? 'Turn off hands-free' : 'Hands-free voice mode',
              icon: Icon(_voiceMode ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
                  color: _voiceMode ? StudyColors.primary : null),
              onPressed: _toggleVoiceMode,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _flipped = !_flipped),
                  child: StudySurfaceCard(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              _flipped ? 'Answer' : 'Question',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: StudyColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _flipped ? card.back : card.front,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, height: 1.45),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap card to flip',
                              style: TextStyle(color: textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                  onStopListening: () {
                    _voice.stopListening();
                  },
                  onReplay: _voiceSpeaking || _voiceListening
                      ? null
                      : () {
                          _voicedIndex = -1;
                          _runVoiceCardCycle();
                        },
                ),
              ],
              if (_flipped) ...<Widget>[
                const SizedBox(height: 12),
                const Text('How well did you know it?', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(child: _RateChip(label: 'Again', quality: 1, onRate: (int q) => _rate(flashcards, q))),
                    const SizedBox(width: 6),
                    Expanded(child: _RateChip(label: 'Hard', quality: 3, onRate: (int q) => _rate(flashcards, q))),
                    const SizedBox(width: 6),
                    Expanded(child: _RateChip(label: 'Good', quality: 4, onRate: (int q) => _rate(flashcards, q))),
                    const SizedBox(width: 6),
                    Expanded(child: _RateChip(label: 'Easy', quality: 5, onRate: (int q) => _rate(flashcards, q))),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

    final MaterialService materials = context.watch<MaterialService>();
    final QuestionService questions = context.watch<QuestionService>();
    final SolutionService solutions = context.read<SolutionService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: StreamBuilder<List<Flashcard>>(
        stream: flashcards.watchFlashcards(),
        builder: (BuildContext context, AsyncSnapshot<List<Flashcard>> snapshot) {
          final List<Flashcard> all = snapshot.data ?? <Flashcard>[];
          final List<Flashcard> due = flashcards.dueCards(all);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: <Widget>[
              StudySurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${due.length} card${due.length == 1 ? '' : 's'} due today',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Spaced repetition schedules reviews so you remember longer.',
                      style: TextStyle(color: textSecondary, height: 1.35),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: due.isEmpty ? null : () => _startSession(due),
                        child: const Text('Study due cards'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Import from exam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              StreamBuilder<List<StudyMaterial>>(
                stream: materials.watchMaterials(),
                builder: (BuildContext context, AsyncSnapshot<List<StudyMaterial>> matSnap) {
                  return StreamBuilder<List<ParsedQuestion>>(
                    stream: questions.watchQuestions(const SearchFilters()),
                    builder: (BuildContext context, AsyncSnapshot<List<ParsedQuestion>> qSnap) {
                      final List<StudyMaterial> parsed =
                          (matSnap.data ?? <StudyMaterial>[]).where((StudyMaterial m) => m.isParsed).take(6).toList();
                      if (parsed.isEmpty) {
                        return Text('Upload an exam first.', style: TextStyle(color: textSecondary));
                      }
                      return Column(
                        children: parsed
                            .map(
                              (StudyMaterial m) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('${m.courseCode} · ${m.examType}'),
                                subtitle: const Text('Create flashcards from Q&A with solutions'),
                                trailing: const Icon(Icons.add_circle_outline),
                                onTap: () => _importFromMaterial(
                                  context,
                                  m,
                                  qSnap.data ?? <ParsedQuestion>[],
                                  solutions,
                                  flashcards,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('AI flashcard generator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Auto-create a deck from exam questions using AI.',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<StudyMaterial>>(
                stream: materials.watchMaterials(),
                builder: (BuildContext context, AsyncSnapshot<List<StudyMaterial>> matSnap) {
                  return StreamBuilder<List<ParsedQuestion>>(
                    stream: questions.watchQuestions(const SearchFilters()),
                    builder: (BuildContext context, AsyncSnapshot<List<ParsedQuestion>> qSnap) {
                      final List<StudyMaterial> parsed = (matSnap.data ?? <StudyMaterial>[])
                          .where((StudyMaterial m) => m.isParsed)
                          .take(4)
                          .toList();
                      return Column(
                        children: parsed
                            .map(
                              (StudyMaterial m) {
                                final List<ParsedQuestion> qs = (qSnap.data ?? <ParsedQuestion>[])
                                    .where((ParsedQuestion q) => q.materialId == m.id)
                                    .toList();
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('${m.courseCode} · ${m.examType}'),
                                  subtitle: Text('${qs.length} questions → AI deck'),
                                  trailing: flashcards.isGenerating
                                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.auto_awesome),
                                  onTap: flashcards.isGenerating || qs.isEmpty
                                      ? null
                                      : () async {
                                          try {
                                            final int count = await flashcards.generateDeckWithAi(
                                              courseCode: m.courseCode,
                                              questionTexts: qs.map((ParsedQuestion q) => q.text).toList(),
                                            );
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Generated $count flashcards')),
                                            );
                                          } catch (error) {
                                            if (!context.mounted) return;
                                            StudyMessenger.showError(context, error);
                                          }
                                        },
                                );
                              },
                            )
                            .toList(),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Text('All cards (${all.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (all.isEmpty)
                Text('No flashcards yet. Import from an exam or save from Quiz mode.', style: TextStyle(color: textSecondary))
              else
                ...all.map(
                  (Flashcard c) => StudySurfaceCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(c.front, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${c.courseCode} · ${c.isDue ? 'Due' : 'Next ${c.nextReviewAt.toLocal().toString().split(' ').first}'}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => flashcards.deleteCard(c.id),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({required this.label, required this.quality, required this.onRate});

  final String label;
  final int quality;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => onRate(quality),
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
