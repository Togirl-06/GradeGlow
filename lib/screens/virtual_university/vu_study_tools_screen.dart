import 'package:flutter/material.dart';

import '../../screens/flashcards_screen.dart';
import '../../widgets/study_surface.dart';
import '../../widgets/virtual_university/vu_accessibility.dart';

/// Offline Virtual University study tools hub.
class VuStudyToolsScreen extends StatelessWidget {
  const VuStudyToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Study Tools')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          VuSemanticSectionHeader(
            label: 'Study tools overview',
            child: Text(
              'Practice offline',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Flashcards, quizzes, summaries, and exam checklists — no network required.',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _ToolCard(
            icon: Icons.style_rounded,
            title: 'Flashcards',
            subtitle: 'Open your deck or generate 5 local cards from a topic.',
            color: scheme.primary,
            onTap: () => _openFlashcards(context),
          ),
          _ToolCard(
            icon: Icons.quiz_outlined,
            title: 'Quiz Generator',
            subtitle: 'Build a quick multiple-choice quiz from any topic.',
            color: scheme.tertiary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const _VuQuizGeneratorPage(),
              ),
            ),
          ),
          _ToolCard(
            icon: Icons.summarize_outlined,
            title: 'Summary Generator',
            subtitle: 'Paste notes and get short offline summary paragraphs.',
            color: scheme.secondary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const _VuSummaryGeneratorPage(),
              ),
            ),
          ),
          _ToolCard(
            icon: Icons.calendar_month_outlined,
            title: 'Study Planner',
            subtitle: 'Practical weekly planning tips for VU courses.',
            color: scheme.primary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const _VuStudyPlannerPage(),
              ),
            ),
          ),
          _ToolCard(
            icon: Icons.checklist_rtl_rounded,
            title: 'Revision Mode',
            subtitle: 'A focused checklist to tighten weak topics.',
            color: scheme.tertiary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const _VuChecklistPage(
                  title: 'Revision Mode',
                  intro:
                      'Work through each step before your next lecture review.',
                  items: <String>[
                    'Skim lecture outline and mark unclear sections',
                    'Re-read highlighted passages in your notes',
                    'Explain the topic aloud in under 2 minutes',
                    'Solve 5 practice questions without looking at answers',
                    'Write one real-world example for each key concept',
                    'List remaining questions for AI Professor office hours',
                  ],
                ),
              ),
            ),
          ),
          _ToolCard(
            icon: Icons.school_outlined,
            title: 'Exam Preparation',
            subtitle: 'Countdown checklist for midterms and finals.',
            color: scheme.secondary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const _VuChecklistPage(
                  title: 'Exam Preparation',
                  intro: 'Use this list in the final 7–10 days before an exam.',
                  items: <String>[
                    'Confirm exam format, weight, and allowed materials',
                    'Build a topic map of what will be tested',
                    'Schedule 3 timed practice blocks this week',
                    'Drill formulas / definitions until recall is automatic',
                    'Review wrong answers from previous quizzes',
                    'Sleep and hydration plan for the night before',
                    'Pack ID, calculator, and notes the evening before',
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFlashcards(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Flashcards',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.collections_bookmark_outlined),
                  title: const Text('Open flashcard deck'),
                  subtitle: const Text('Study cards already in your library'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const FlashcardsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.auto_awesome_outlined),
                  title: const Text('Generate 5 local cards'),
                  subtitle: const Text('Offline generator from a topic string'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const _VuLocalFlashcardPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: StudySurfaceCard(
        onTap: onTap,
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _VuLocalFlashcardPage extends StatefulWidget {
  const _VuLocalFlashcardPage();

  @override
  State<_VuLocalFlashcardPage> createState() => _VuLocalFlashcardPageState();
}

class _VuLocalFlashcardPageState extends State<_VuLocalFlashcardPage> {
  final TextEditingController _topic = TextEditingController();
  List<({String q, String a})> _cards = <({String q, String a})>[];
  int _index = 0;
  bool _flipped = false;

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  void _generate() {
    final String topic = _topic.text.trim();
    if (topic.isEmpty) return;
    final String t = topic[0].toUpperCase() + topic.substring(1);
    setState(() {
      _cards = <({String q, String a})>[
        (
          q: 'What is $t in one sentence?',
          a: '$t is a core idea you can define, apply, and teach back.',
        ),
        (
          q: 'Name one real-world use of $t.',
          a: 'Apply $t to a practical scenario from your course or daily life.',
        ),
        (
          q: 'What misconception do students have about $t?',
          a: 'Confusing surface vocabulary with the underlying mechanism of $t.',
        ),
        (
          q: 'How would you teach $t to a beginner?',
          a: 'Start with a simple analogy, then one worked example of $t.',
        ),
        (
          q: 'What should you practice next on $t?',
          a: 'Do a short quiz and explain one missed point about $t aloud.',
        ),
      ];
      _index = 0;
      _flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Local Flashcards')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _topic,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _generate(),
            decoration: const InputDecoration(
              labelText: 'Topic',
              hintText: 'e.g. Mitosis',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate 5 cards'),
          ),
          if (_cards.isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            Text(
              'Card ${_index + 1} of ${_cards.length}',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() => _flipped = !_flipped),
              child: StudySurfaceCard(
                child: SizedBox(
                  height: 180,
                  child: Center(
                    child: Text(
                      _flipped ? _cards[_index].a : _cards[_index].q,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap card to flip',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                OutlinedButton(
                  onPressed: _index > 0
                      ? () => setState(() {
                          _index -= 1;
                          _flipped = false;
                        })
                      : null,
                  child: const Text('Previous'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _index < _cards.length - 1
                      ? () => setState(() {
                          _index += 1;
                          _flipped = false;
                        })
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VuQuizGeneratorPage extends StatefulWidget {
  const _VuQuizGeneratorPage();

  @override
  State<_VuQuizGeneratorPage> createState() => _VuQuizGeneratorPageState();
}

class _VuQuizItem {
  _VuQuizItem({
    required this.prompt,
    required this.choices,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> choices;
  final int correctIndex;
  int? selected;
}

class _VuQuizGeneratorPageState extends State<_VuQuizGeneratorPage> {
  final TextEditingController _topic = TextEditingController();
  List<_VuQuizItem> _items = <_VuQuizItem>[];
  bool _submitted = false;

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  void _generate() {
    final String topic = _topic.text.trim();
    if (topic.isEmpty) return;
    final String t = topic[0].toUpperCase() + topic.substring(1);
    setState(() {
      _submitted = false;
      _items = <_VuQuizItem>[
        _VuQuizItem(
          prompt: 'Which statement best describes $t?',
          choices: <String>[
            '$t is a defined concept you can apply with examples',
            '$t is only memorized vocabulary with no application',
            '$t cannot be practiced offline',
            '$t is unrelated to exam preparation',
          ],
          correctIndex: 0,
        ),
        _VuQuizItem(
          prompt: 'What is the best first study step for $t?',
          choices: <String>[
            'Skip foundations and jump to advanced problems',
            'Define $t, then work one guided example',
            'Only watch videos without taking notes',
            'Avoid practice questions until exam day',
          ],
          correctIndex: 1,
        ),
        _VuQuizItem(
          prompt: 'How do you check understanding of $t?',
          choices: <String>[
            'Reread the same page silently once',
            'Highlight every sentence in the chapter',
            'Teach $t aloud and solve a short quiz',
            'Wait for the instructor to summarize everything',
          ],
          correctIndex: 2,
        ),
        _VuQuizItem(
          prompt: 'A strong exam answer about $t usually includes…',
          choices: <String>[
            'Only a dictionary definition',
            'Unrelated personal opinions',
            'Copying notes word-for-word',
            'Definition, mechanism, and one concrete example',
          ],
          correctIndex: 3,
        ),
      ];
    });
  }

  int get _score =>
      _items.where((_VuQuizItem i) => i.selected == i.correctIndex).length;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Generator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _topic,
            decoration: const InputDecoration(
              labelText: 'Topic',
              hintText: 'e.g. Newton’s Laws',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('Generate quiz'),
          ),
          if (_items.isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            for (int i = 0; i < _items.length; i++) ...<Widget>[
              StudySurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Q${i + 1}. ${_items[i].prompt}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    RadioGroup<int?>(
                      groupValue: _items[i].selected,
                      onChanged: (int? v) {
                        if (_submitted) return;
                        setState(() => _items[i].selected = v);
                      },
                      child: Column(
                        children: List<Widget>.generate(
                          _items[i].choices.length,
                          (int c) {
                            return ListTile(
                              dense: true,
                              title: Text(_items[i].choices[c]),
                              leading: Radio<int>(value: c),
                              trailing: !_submitted
                                  ? null
                                  : (c == _items[i].correctIndex
                                        ? Icon(
                                            Icons.check_circle,
                                            color: scheme.primary,
                                          )
                                        : (_items[i].selected == c
                                              ? Icon(
                                                  Icons.cancel,
                                                  color: scheme.error,
                                                )
                                              : null)),
                              onTap: _submitted
                                  ? null
                                  : () =>
                                        setState(() => _items[i].selected = c),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (!_submitted)
              FilledButton(
                onPressed: _items.every((_VuQuizItem i) => i.selected != null)
                    ? () => setState(() => _submitted = true)
                    : null,
                child: const Text('Check answers'),
              )
            else
              StudySurfaceCard(
                child: Text(
                  'Score: $_score / ${_items.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _VuSummaryGeneratorPage extends StatefulWidget {
  const _VuSummaryGeneratorPage();

  @override
  State<_VuSummaryGeneratorPage> createState() =>
      _VuSummaryGeneratorPageState();
}

class _VuSummaryGeneratorPageState extends State<_VuSummaryGeneratorPage> {
  final TextEditingController _input = TextEditingController();
  List<String> _paragraphs = <String>[];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _summarize() {
    final String raw = _input.text.trim();
    if (raw.isEmpty) return;
    final List<String> sentences = raw
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    if (sentences.isEmpty) return;

    final List<String> keyPoints = sentences.take(6).toList();
    final String overview = keyPoints.take(2).join(' ');
    final String details = keyPoints.skip(2).take(3).join(' ');
    final String action = keyPoints.length > 5
        ? keyPoints.last
        : 'Review the main ideas above and write one example from memory.';

    setState(() {
      _paragraphs = <String>[
        'Overview: $overview',
        if (details.isNotEmpty) 'Key details: $details',
        'Next step: $action',
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary Generator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _input,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Paste notes or lecture text',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _summarize,
            icon: const Icon(Icons.summarize_outlined),
            label: const Text('Generate summary'),
          ),
          if (_paragraphs.isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            for (final String p in _paragraphs) ...<Widget>[
              StudySurfaceCard(
                child: Text(p, style: const TextStyle(height: 1.45)),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}

class _VuStudyPlannerPage extends StatelessWidget {
  const _VuStudyPlannerPage();

  static const List<String> _tips = <String>[
    'Block 45–60 minute focus sessions with a single VU lesson goal.',
    'Alternate Learn (lecture) → Practice (lab/quiz) → Feedback (review mistakes).',
    'Keep one weekly catch-up slot for missed lessons instead of cramming.',
    'Schedule AI Professor questions in a batch so you use daily free quota wisely.',
    'End each day by writing three bullet takeaways in VU Notes.',
    'Protect sleep before heavy simulation or exam-prep days.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Planner')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _tips.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          return StudySurfaceCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 14,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _tips[index],
                    style: const TextStyle(height: 1.4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VuChecklistPage extends StatefulWidget {
  const _VuChecklistPage({
    required this.title,
    required this.intro,
    required this.items,
  });

  final String title;
  final String intro;
  final List<String> items;

  @override
  State<_VuChecklistPage> createState() => _VuChecklistPageState();
}

class _VuChecklistPageState extends State<_VuChecklistPage> {
  late final List<bool> _checked = List<bool>.filled(
    widget.items.length,
    false,
  );

  int get _done => _checked.where((bool v) => v).length;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            widget.intro,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            '$_done / ${widget.items.length} complete',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < widget.items.length; i++)
            CheckboxListTile(
              value: _checked[i],
              onChanged: (bool? v) => setState(() => _checked[i] = v ?? false),
              title: Text(widget.items[i]),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
