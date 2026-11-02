import 'package:flutter/material.dart';

import '../../models/english_lesson.dart';
import '../../theme/study_theme.dart';
import 'english_session_chrome.dart';

typedef EnglishAnswerCallback = void Function(dynamic answer);

/// Activity renderer — tap options when available; type when there are no choices.
class EnglishActivityPanel extends StatefulWidget {
  const EnglishActivityPanel({
    super.key,
    required this.activity,
    required this.phase,
    required this.feedback,
    required this.lastCorrect,
    required this.onSubmit,
    this.onContinue,
    this.onListen,
    this.onStopReading,
    this.showSubmitButton = false,
    this.showFeedback = false,
    this.onPanelReady,
    this.listening = false,
    this.canListen = false,
    this.grading = false,
    this.readingElapsedSeconds,
    this.readingMinSeconds = kEnglishReadingAloudShortMinSeconds,
    this.readingSessionActive = false,
  });

  final EnglishActivity activity;
  final EnglishLessonPhase phase;
  final String? feedback;
  final bool lastCorrect;
  final EnglishAnswerCallback onSubmit;
  final VoidCallback? onContinue;
  final VoidCallback? onListen;
  final VoidCallback? onStopReading;
  final bool listening;
  final bool canListen;
  final bool grading;
  final int? readingElapsedSeconds;
  final int readingMinSeconds;
  final bool readingSessionActive;
  /// When false, parent renders submit in a fixed bottom bar (recommended).
  final bool showSubmitButton;
  /// When false, parent renders feedback in a fixed bottom bar (recommended).
  final bool showFeedback;
  /// Called when this panel is ready — used for external submit bar.
  final ValueChanged<EnglishActivityPanelState>? onPanelReady;

  @override
  State<EnglishActivityPanel> createState() => EnglishActivityPanelState();
}

class EnglishActivityPanelState extends State<EnglishActivityPanel> {
  /// Submit answer — call from parent bottom bar via [GlobalKey].
  void submitCurrentAnswer() {
    if (_usesOptionPicker) {
      _submitChoice();
    } else {
      _submitText();
    }
  }

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final List<String> _sentenceParts = <String>[];
  final List<String> _availableWords = <String>[];
  String? _emptyHint;
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    _resetLocal();
    _notifyPanelReady();
  }

  @override
  void didUpdateWidget(covariant EnglishActivityPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity.id != widget.activity.id ||
        (oldWidget.phase == EnglishLessonPhase.feedback &&
            widget.phase == EnglishLessonPhase.active)) {
      _textController.clear();
      _recipientController.clear();
      _emptyHint = null;
      _selectedOptionIndex = null;
      _resetLocal();
    }
    _notifyPanelReady();
  }

  void _notifyPanelReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onPanelReady?.call(this);
    });
  }

  void _resetLocal() {
    _sentenceParts.clear();
    if (widget.activity.kind == EnglishActivityKind.sentenceBuilder) {
      _availableWords
        ..clear()
        ..addAll(widget.activity.wordBank);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    if (widget.grading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Grading your answer…'),
            ],
          ),
        ),
      );
    }

    if (widget.showFeedback && widget.phase == EnglishLessonPhase.feedback) {
      return EnglishLessonFeedbackBar(
        correct: widget.lastCorrect,
        message: widget.feedback ?? '',
        brightness: brightness,
        onContinue: widget.onContinue,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.activity.taskLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              widget.activity.taskLabel!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: EnglishLessonTheme.textSecondary(brightness),
                  ),
            ),
          ),
        _buildBody(context, brightness),
        if (_needsInput) ...<Widget>[
          const SizedBox(height: 14),
          _textInput(context, brightness),
        ],
      ],
    );
  }

  bool get _usesOptionPicker {
    if (widget.activity.options.isEmpty) return false;
    return widget.activity.kind == EnglishActivityKind.multipleChoice ||
        widget.activity.kind == EnglishActivityKind.rapidReview ||
        widget.activity.kind == EnglishActivityKind.listening ||
        widget.activity.kind == EnglishActivityKind.explainError ||
        widget.activity.kind == EnglishActivityKind.bestSentence ||
        widget.activity.kind == EnglishActivityKind.readingInference ||
        widget.activity.kind == EnglishActivityKind.vocabularyContext;
  }

  bool get _needsInput {
    if (_usesOptionPicker) return false;
    switch (widget.activity.kind) {
      case EnglishActivityKind.sentenceBuilder:
      case EnglishActivityKind.microPrompt:
      case EnglishActivityKind.scenarioIntro:
      case EnglishActivityKind.speaking:
      case EnglishActivityKind.readingAloud:
        return false;
      default:
        return true;
    }
  }

  Widget _buildChoicePicker(
    BuildContext context,
    Brightness brightness, {
    bool includeListeningScript = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (includeListeningScript) ...<Widget>[
          _ListeningScript(
            script: widget.activity.listeningScript ?? '',
            brightness: brightness,
          ),
          const SizedBox(height: 12),
        ],
        _SelectableChoiceOptions(
          options: widget.activity.options,
          selectedIndex: _selectedOptionIndex,
          brightness: brightness,
          onSelect: (int index) => setState(() {
            _selectedOptionIndex = index;
            _emptyHint = null;
          }),
        ),
        if (_emptyHint != null) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            _emptyHint!,
            style: TextStyle(
              color: StudyColors.danger,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.grading ? null : _submitChoice,
            style: EnglishLessonTheme.primaryButton(brightness),
            child: const Text('Submit answer'),
          ),
        ),
      ],
    );
  }

  void _submitChoice() {
    final int? picked = _selectedOptionIndex;
    if (picked == null ||
        picked < 0 ||
        picked >= widget.activity.options.length) {
      setState(() {
        _emptyHint = 'Tap an option before submitting.';
      });
      return;
    }
    setState(() => _emptyHint = null);
    widget.onSubmit(widget.activity.options[picked]);
  }

  Widget _buildBody(BuildContext context, Brightness brightness) {
    switch (widget.activity.kind) {
      case EnglishActivityKind.multipleChoice:
      case EnglishActivityKind.rapidReview:
        if (_usesOptionPicker) {
          return _buildChoicePicker(context, brightness);
        }
        return _WritePromptHint(
          brightness: brightness,
          icon: Icons.edit_note_rounded,
          text: 'Write your full answer.',
        );
      case EnglishActivityKind.listening:
        if (_usesOptionPicker) {
          return _buildChoicePicker(
            context,
            brightness,
            includeListeningScript: true,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ListeningScript(
              script: widget.activity.listeningScript ?? '',
              brightness: brightness,
            ),
            const SizedBox(height: 10),
            _WritePromptHint(
              brightness: brightness,
              icon: Icons.edit_outlined,
              text: 'Write your answer based on what you read/heard.',
            ),
          ],
        );
      case EnglishActivityKind.emailWriting:
        return _EmailToneHint(
          tone: widget.activity.writingTone,
          brightness: brightness,
        );
      case EnglishActivityKind.sentenceBuilder:
        if (widget.activity.wordBank.isEmpty) {
          return _WritePromptHint(
            brightness: brightness,
            icon: Icons.warning_amber_rounded,
            text: 'Word bank missing for this step — skip or retry the lesson.',
          );
        }
        return _SentenceBuilder(
          built: _sentenceParts,
          available: _availableWords,
          onWord: (String w) => setState(() {
            _sentenceParts.add(w);
            _availableWords.remove(w);
          }),
          onUndo: () => setState(() {
            if (_sentenceParts.isEmpty) return;
            _availableWords.add(_sentenceParts.removeLast());
          }),
          onSubmit: () => widget.onSubmit(_sentenceParts.join(' ')),
        );
      case EnglishActivityKind.correction:
        return _CorrectionBlock(
          wrong: widget.activity.incorrectSentence ?? '',
          brightness: brightness,
        );
      case EnglishActivityKind.speaking:
        return _MicPrompt(
          listening: widget.listening,
          canListen: widget.canListen,
          onListen: widget.onListen,
        );
      case EnglishActivityKind.readingAloud:
        return _ReadingAloudBlock(
          passage: widget.activity.listeningScript ?? '',
          listening: widget.listening,
          canListen: widget.canListen && !widget.grading,
          onListen: widget.onListen,
          onStopReading: widget.onStopReading,
          brightness: brightness,
          elapsedSeconds: widget.readingElapsedSeconds ?? 0,
          minSeconds: widget.readingMinSeconds,
          grading: widget.grading,
          sessionActive: widget.readingSessionActive,
        );
      case EnglishActivityKind.paragraphCorrection:
        return _CorrectionBlock(
          wrong: widget.activity.incorrectSentence ?? widget.activity.prompt,
          brightness: brightness,
          multiline: true,
        );
      case EnglishActivityKind.sentenceRewrite:
      case EnglishActivityKind.combineSentences:
      case EnglishActivityKind.transformWriting:
        return _WritePromptHint(
          brightness: brightness,
          icon: Icons.edit_note_rounded,
          text: widget.activity.taskLabel ??
              'Rewrite or transform the text in the box below.',
        );
      case EnglishActivityKind.essayWriting:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.activity.gradingCriteria.isNotEmpty)
              _EssayRubricHint(
                criteria: widget.activity.gradingCriteria,
                minWords: widget.activity.minWords,
                brightness: brightness,
              ),
            _WritePromptHint(
              brightness: brightness,
              icon: Icons.article_outlined,
              text: 'Plan your response: thesis → body paragraphs → conclusion.',
            ),
          ],
        );
      case EnglishActivityKind.scenarioIntro:
        return _ScenarioIntroBlock(
          title: widget.activity.scenarioTitle ?? 'Scenario',
          briefing: widget.activity.secondaryPrompt ?? widget.activity.prompt,
          step: widget.activity.scenarioStep,
          brightness: brightness,
        );
      case EnglishActivityKind.explainError:
      case EnglishActivityKind.bestSentence:
      case EnglishActivityKind.readingInference:
      case EnglishActivityKind.vocabularyContext:
        if (_usesOptionPicker) {
          return _buildChoicePicker(context, brightness);
        }
        return const SizedBox.shrink();
      case EnglishActivityKind.fillBlank:
      case EnglishActivityKind.questionCard:
      case EnglishActivityKind.miniConversation:
        return _QuizAnswerBody(
          kind: widget.activity.kind,
          brightness: brightness,
        );
      case EnglishActivityKind.shortWriting:
        if (widget.activity.targetName != null) {
          return _WritePromptHint(
            brightness: brightness,
            icon: Icons.waving_hand_rounded,
            text: 'Write only the greeting line — not the full letter.',
          );
        }
        return _WritePromptHint(
          brightness: brightness,
          icon: Icons.draw_rounded,
          text: 'Write in full sentences.',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _textInput(BuildContext context, Brightness brightness) {
    final bool isEmail = widget.activity.kind == EnglishActivityKind.emailWriting;
    final bool multiline = isEmail ||
        widget.activity.kind == EnglishActivityKind.essayWriting ||
        widget.activity.kind == EnglishActivityKind.paragraphCorrection ||
        widget.activity.kind == EnglishActivityKind.correction ||
        widget.activity.kind == EnglishActivityKind.shortWriting ||
        widget.activity.kind == EnglishActivityKind.questionCard ||
        widget.activity.kind == EnglishActivityKind.miniConversation ||
        widget.activity.kind == EnglishActivityKind.fillBlank ||
        widget.activity.kind == EnglishActivityKind.sentenceRewrite ||
        widget.activity.kind == EnglishActivityKind.combineSentences ||
        widget.activity.kind == EnglishActivityKind.transformWriting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (isEmail && widget.activity.pickRecipient) ...<Widget>[
          TextField(
            controller: _recipientController,
            enabled: !widget.grading,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'To (who are you writing to?)',
              hintText: 'e.g. Professor Lee, my manager, Sarah',
              filled: true,
              fillColor: StudyColors.surfaceElevated(brightness),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: _textController,
          enabled: !widget.grading,
          autofocus: !isEmail,
          minLines: multiline ? (isEmail ? 6 : widget.activity.kind == EnglishActivityKind.essayWriting ? 8 : 2) : 1,
          maxLines: multiline ? (isEmail ? 10 : widget.activity.kind == EnglishActivityKind.essayWriting ? 14 : 4) : 1,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: _hint,
            filled: true,
            fillColor: StudyColors.surfaceElevated(brightness),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: StudyColors.border(brightness)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: StudyColors.border(brightness)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          onSubmitted: (_) => _submitText(),
        ),
        const SizedBox(height: 10),
        if (_emptyHint != null) ...<Widget>[
          Text(
            _emptyHint!,
            style: TextStyle(
              color: StudyColors.danger,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (widget.showSubmitButton)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.grading ? null : _submitText,
              style: EnglishLessonTheme.primaryButton(brightness),
              child: Text(isEmail
                  ? 'Submit email'
                  : widget.activity.kind == EnglishActivityKind.essayWriting
                      ? 'Submit essay'
                      : 'Submit answer'),
            ),
          ),
      ],
    );
  }

  String get _hint {
    switch (widget.activity.kind) {
      case EnglishActivityKind.emailWriting:
        return 'Write your email here — greeting, message, sign-off…';
      case EnglishActivityKind.essayWriting:
        return 'Write your essay here (${widget.activity.minWords}+ words)…';
      case EnglishActivityKind.paragraphCorrection:
        return 'Type the fully corrected paragraph…';
      case EnglishActivityKind.sentenceRewrite:
      case EnglishActivityKind.combineSentences:
      case EnglishActivityKind.transformWriting:
        return 'Type your rewritten sentence or paragraph…';
      case EnglishActivityKind.fillBlank:
        return 'Type your answer…';
      case EnglishActivityKind.correction:
        return 'Type the corrected sentence…';
      case EnglishActivityKind.multipleChoice:
      case EnglishActivityKind.rapidReview:
        return 'Type the correct full answer…';
      case EnglishActivityKind.listening:
        return 'Type your answer…';
      case EnglishActivityKind.speaking:
        return 'Or type what you said…';
      case EnglishActivityKind.shortWriting:
        return 'Write your response…';
      default:
        return 'Type your answer…';
    }
  }

  void _submitText() {
    FocusScope.of(context).unfocus();
    final String t = _textController.text.trim();
    if (t.isEmpty) {
      setState(() {
        _emptyHint = 'Type your answer before submitting.';
      });
      return;
    }
    setState(() => _emptyHint = null);

    if (widget.activity.kind == EnglishActivityKind.emailWriting) {
      widget.onSubmit(
        EnglishWrittenSubmission(
          body: t,
          recipient: _recipientController.text.trim(),
        ),
      );
      return;
    }

    widget.onSubmit(t);
  }
}

class _SelectableChoiceOptions extends StatelessWidget {
  const _SelectableChoiceOptions({
    required this.options,
    required this.selectedIndex,
    required this.brightness,
    required this.onSelect,
  });

  final List<String> options;
  final int? selectedIndex;
  final Brightness brightness;
  final ValueChanged<int> onSelect;

  static const List<String> _labels = <String>['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Tap your answer',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? StudyColors.primaryTint(brightness)
                        : StudyColors.surfaceElevated(brightness),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedIndex == i
                          ? StudyColors.primary
                          : StudyColors.border(brightness),
                      width: selectedIndex == i ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedIndex == i
                              ? StudyColors.primary
                              : StudyColors.primaryTint(brightness),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          i < _labels.length ? _labels[i] : '${i + 1}',
                          style: TextStyle(
                            color: selectedIndex == i
                                ? Colors.white
                                : StudyColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          options[i],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.35,
                                fontWeight: selectedIndex == i
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                      ),
                      if (selectedIndex == i)
                        Icon(Icons.check_circle_rounded, color: StudyColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WritePromptHint extends StatelessWidget {
  const _WritePromptHint({
    required this.brightness,
    required this.icon,
    required this.text,
  });

  final Brightness brightness;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StudyColors.primaryTint(brightness),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudyColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: StudyColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _EmailToneHint extends StatelessWidget {
  const _EmailToneHint({required this.tone, required this.brightness});

  final EnglishWritingTone? tone;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final String label = switch (tone) {
      EnglishWritingTone.formal => 'Formal tone — Dear…, polite request, Best regards',
      EnglishWritingTone.informal => 'Informal tone — Hi/Hey…, friendly message, casual sign-off',
      _ => 'Choose your recipient and write naturally',
    };
    return _WritePromptHint(
      brightness: brightness,
      icon: Icons.mail_outline_rounded,
      text: label,
    );
  }
}

class _ListeningScript extends StatelessWidget {
  const _ListeningScript({required this.script, required this.brightness});

  final String script;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudyColors.primaryTint(brightness),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StudyColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.hearing_rounded, color: StudyColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              script,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CorrectionBlock extends StatelessWidget {
  const _CorrectionBlock({
    required this.wrong,
    required this.brightness,
    this.multiline = false,
  });

  final String wrong;
  final Brightness brightness;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudyColors.danger.withValues(alpha: brightness == Brightness.dark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StudyColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.edit_note_rounded, color: StudyColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              wrong,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: StudyColors.danger,
                decoration: TextDecoration.lineThrough,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SentenceBuilder extends StatelessWidget {
  const _SentenceBuilder({
    required this.built,
    required this.available,
    required this.onWord,
    required this.onUndo,
    required this.onSubmit,
  });

  final List<String> built;
  final List<String> available;
  final ValueChanged<String> onWord;
  final VoidCallback onUndo;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final Brightness b = Theme.of(context).brightness;
    final TextStyle labelStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.w700,
          color: EnglishLessonTheme.textSecondary(b),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Your sentence', style: labelStyle),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: StudyColors.border(b), width: 1.5),
            color: StudyColors.surfaceElevated(b),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            built.isEmpty ? 'Tap words in the bank below…' : built.join(' '),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  height: 1.35,
                  color: built.isEmpty
                      ? EnglishLessonTheme.textSecondary(b)
                      : null,
                ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Word bank — tap each word in order', style: labelStyle),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: StudyColors.primaryTint(b),
            border: Border.all(color: StudyColors.primary.withValues(alpha: 0.15)),
          ),
          child: available.isEmpty
              ? Text(
                  'All words used — tap Undo to change your sentence.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: available
                      .map(
                        (String w) => ActionChip(
                          label: Text(w),
                          onPressed: () => onWord(w),
                          backgroundColor: StudyColors.surfaceElevated(b),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: available.isEmpty && built.isNotEmpty ? onSubmit : null,
            style: EnglishLessonTheme.primaryButton(b),
            child: const Text('Submit answer'),
          ),
        ),
        if (available.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            'Use every word in the bank before submitting.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: EnglishLessonTheme.textSecondary(b),
                ),
          ),
        ],
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: built.isEmpty ? null : onUndo,
            child: const Text('Undo'),
          ),
        ),
      ],
    );
  }
}

class _ReadingAloudBlock extends StatelessWidget {
  const _ReadingAloudBlock({
    required this.passage,
    required this.listening,
    required this.canListen,
    required this.brightness,
    required this.elapsedSeconds,
    required this.minSeconds,
    this.onListen,
    this.onStopReading,
    this.grading = false,
    this.sessionActive = false,
  });

  final String passage;
  final bool listening;
  final bool canListen;
  final Brightness brightness;
  final int elapsedSeconds;
  final int minSeconds;
  final VoidCallback? onListen;
  final VoidCallback? onStopReading;
  final bool grading;
  final bool sessionActive;

  String _formatTime(int totalSeconds) {
    final int m = totalSeconds ~/ 60;
    final int s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool minReached = elapsedSeconds >= minSeconds;
    final int remaining = (minSeconds - elapsedSeconds).clamp(0, minSeconds);
    final double progress = (elapsedSeconds / minSeconds).clamp(0.0, 1.0);
    final bool showTimer = sessionActive || elapsedSeconds > 0;

    final String primaryLabel;
    if (grading) {
      primaryLabel = 'Grading your reading…';
    } else if (sessionActive && minReached) {
      primaryLabel = 'Done reading? Tap Stop recording below.';
    } else if (sessionActive) {
      primaryLabel = 'Read the passage — tap Stop when you\'re done.';
    } else {
      primaryLabel = 'Tap the mic, then read the passage aloud';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Passage',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: EnglishLessonTheme.textSecondary(brightness),
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: StudyColors.primaryTint(brightness),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: StudyColors.primary.withValues(alpha: 0.2)),
          ),
          child: SingleChildScrollView(
            child: Text(
              passage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (showTimer)
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        color: minReached ? StudyColors.accent : StudyColors.primary,
                        backgroundColor: StudyColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  Material(
                    color: grading
                        ? StudyColors.border(brightness)
                        : (sessionActive
                            ? (minReached ? StudyColors.accent : StudyColors.primary)
                            : StudyColors.primary),
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: canListen && !grading ? onListen : null,
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: Icon(
                          grading
                              ? Icons.hourglass_top_rounded
                              : (sessionActive && listening
                                  ? Icons.graphic_eq_rounded
                                  : Icons.mic_rounded),
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                primaryLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (showTimer) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  minReached
                      ? 'Suggested time reached — stop when ready ✓'
                      : '${_formatTime(remaining)} suggested reading time left',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: minReached ? StudyColors.accent : StudyColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  'Elapsed: ${_formatTime(elapsedSeconds)} / ${_formatTime(minSeconds)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: EnglishLessonTheme.textSecondary(brightness),
                      ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                'AI grades accuracy, completeness, and clarity when you stop.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: EnglishLessonTheme.textSecondary(brightness),
                    ),
              ),
              if (sessionActive && !grading) ...<Widget>[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onStopReading,
                    style: FilledButton.styleFrom(
                      backgroundColor: StudyColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text(
                      'Stop recording',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuizAnswerBody extends StatelessWidget {
  const _QuizAnswerBody({required this.kind, required this.brightness});

  final EnglishActivityKind kind;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final String hint = switch (kind) {
      EnglishActivityKind.fillBlank =>
        'Type the missing word or phrase in the box below.',
      EnglishActivityKind.questionCard =>
        'Write a complete answer to the question above.',
      EnglishActivityKind.miniConversation =>
        'Reply naturally in one or two sentences.',
      _ => 'Type your answer below.',
    };
    return _WritePromptHint(
      brightness: brightness,
      icon: Icons.quiz_outlined,
      text: hint,
    );
  }
}

class _ScenarioIntroBlock extends StatelessWidget {
  const _ScenarioIntroBlock({
    required this.title,
    required this.briefing,
    required this.brightness,
    this.step,
  });

  final String title;
  final String briefing;
  final Brightness brightness;
  final int? step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudyColors.surfaceElevated(brightness),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StudyColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (step != null)
            Text(
              'Step $step',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: StudyColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            briefing,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: EnglishLessonTheme.textSecondary(brightness),
                ),
          ),
        ],
      ),
    );
  }
}

class _EssayRubricHint extends StatelessWidget {
  const _EssayRubricHint({
    required this.criteria,
    required this.minWords,
    required this.brightness,
  });

  final List<String> criteria;
  final int minWords;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Include ($minWords+ words):',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: criteria
                .map(
                  (String c) => Chip(
                    label: Text(c),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MicPrompt extends StatelessWidget {
  const _MicPrompt({
    required this.listening,
    required this.canListen,
    this.onListen,
  });

  final bool listening;
  final bool canListen;
  final VoidCallback? onListen;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Material(
            color: listening ? StudyColors.accent : StudyColors.primary,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: canListen ? onListen : null,
              child: const SizedBox(
                width: 68,
                height: 68,
                child: Icon(Icons.mic_rounded, color: Colors.white, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            listening ? 'Listening…' : 'Tap the mic to speak',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class EnglishLessonFeedbackBar extends StatelessWidget {
  const EnglishLessonFeedbackBar({
    super.key,
    required this.correct,
    required this.message,
    required this.brightness,
    this.onContinue,
    this.embedded = false,
  });

  final bool correct;
  final String message;
  final Brightness brightness;
  final VoidCallback? onContinue;
  /// When true, renders inside a lesson card (no floating Material chrome).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final Color fg = EnglishLessonTheme.feedbackText(correct: correct);
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: EnglishLessonTheme.feedbackDecoration(brightness, correct: correct),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: fg,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      correct ? 'Correct!' : 'Not quite',
                      style: TextStyle(
                        color: fg,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (message.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(color: fg, fontSize: 15, height: 1.35),
                ),
              ],
            ],
          ),
        ),
        if (onContinue != null) ...<Widget>[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              style: EnglishLessonTheme.primaryButton(brightness),
              child: const Text('Next question'),
            ),
          ),
        ],
      ],
    );

    if (embedded) return body;

    return Material(
      elevation: 8,
      color: EnglishLessonTheme.surface(brightness),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: StudyColors.border(brightness)),
          ),
        ),
        child: body,
      ),
    );
  }
}
