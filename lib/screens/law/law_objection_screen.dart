import 'package:flutter/material.dart';

import '../../data/law/law_topic_practice_bank.dart';
import '../../models/law/law_program.dart';
import '../../theme/law_theme.dart';

class LawObjectionScreen extends StatefulWidget {
  const LawObjectionScreen({super.key, required this.lesson});
  final LawLesson lesson;

  @override
  State<LawObjectionScreen> createState() => _LawObjectionScreenState();
}

class _LawObjectionScreenState extends State<LawObjectionScreen> {
  late final List<LawObjectionItem> _items;
  int _index = 0;
  int? _picked;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _items = LawTopicPracticeBank.objectionsFor(widget.lesson);
  }

  LawObjectionItem get _current => _items[_index];

  void _resetQuestion() {
    _picked = null;
    _revealed = false;
  }

  void _next() {
    if (_index >= _items.length - 1) {
      setState(() {
        _index = 0;
        _resetQuestion();
      });
      return;
    }
    setState(() {
      _index += 1;
      _resetQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final LawObjectionItem q = _current;
    final bool correct = _picked == q.correctIndex;

    return Scaffold(
      backgroundColor: LawTheme.courtroomBg,
      appBar: AppBar(
        backgroundColor: LawTheme.courtroomPanel,
        foregroundColor: LawTheme.courtroomText,
        title: const Text('Objection Drill'),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                '${_index + 1}/${_items.length}',
                style: const TextStyle(color: LawTheme.gavel, fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            widget.lesson.title,
            style: const TextStyle(color: LawTheme.courtroomMuted, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LawTheme.courtroomPanel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LawTheme.courtroomBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('COURTROOM', style: TextStyle(color: LawTheme.gavel, fontWeight: FontWeight.w800, letterSpacing: 0.6, fontSize: 11)),
                const SizedBox(height: 10),
                Text(q.stem, style: const TextStyle(color: LawTheme.courtroomText, height: 1.45, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                const Text('You rise:', style: TextStyle(color: LawTheme.courtroomMuted)),
                const SizedBox(height: 6),
                const Text('Objection!', style: TextStyle(color: LawTheme.gavel, fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List<Widget>.generate(q.options.length, (int i) {
            final bool selected = _picked == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: selected ? LawTheme.primary.withValues(alpha: 0.25) : LawTheme.courtroomPanel,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _revealed ? null : () => setState(() => _picked = i),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? LawTheme.primary : LawTheme.courtroomBorder),
                    ),
                    child: Text(q.options[i], style: const TextStyle(color: LawTheme.courtroomText, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          if (!_revealed)
            FilledButton(
              onPressed: _picked == null ? null : () => setState(() => _revealed = true),
              style: FilledButton.styleFrom(backgroundColor: LawTheme.gavel, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Judge rules', style: TextStyle(fontWeight: FontWeight.w900)),
            )
          else ...<Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (correct ? LawTheme.success : LawTheme.danger).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: correct ? LawTheme.success : LawTheme.danger),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    correct ? 'Sustained — well taken.' : 'Overruled / wrong ground.',
                    style: TextStyle(color: correct ? LawTheme.success : LawTheme.danger, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Correct ground: ${q.options[q.correctIndex]}\n\n${q.explain}',
                    style: const TextStyle(color: LawTheme.courtroomText, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _next,
              icon: const Icon(Icons.skip_next_rounded),
              label: Text(
                _index >= _items.length - 1 ? 'Restart drills' : 'Next question',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: LawTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
