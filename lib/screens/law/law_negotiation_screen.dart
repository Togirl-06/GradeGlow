import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../models/law/law_program.dart';
import '../../services/openai_service.dart';
import '../../theme/law_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/tutor_markdown_body.dart';

class LawNegotiationScreen extends StatefulWidget {
  const LawNegotiationScreen({super.key, required this.lesson});
  final LawLesson lesson;

  @override
  State<LawNegotiationScreen> createState() => _LawNegotiationScreenState();
}

class _LawNegotiationScreenState extends State<LawNegotiationScreen> {
  final TextEditingController _counter = TextEditingController();
  final List<String> _log = <String>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _log.add('Opening offer: ${widget.lesson.negotiationOffer}');
  }

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  Future<void> _move(String move) async {
    setState(() {
      _loading = true;
      _log.add('You: $move');
    });
    try {
      final String reply = AppConfig.hasOpenAi
          ? await context.read<OpenAiService>().lawNegotiationReply(
                offer: widget.lesson.negotiationOffer,
                caseContext: '${widget.lesson.hook}\n${widget.lesson.doctrine}',
                studentMove: move,
              )
          : _offline(move);
      if (!mounted) return;
      setState(() {
        _log.add('Other side: $reply');
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, e);
    }
  }

  String _offline(String move) {
    final String m = move.toLowerCase();
    if (m.contains('accept')) {
      return 'We have a deal on the current terms. I\'ll send a release. Confirm you advised the client on finality.';
    }
    if (m.contains('trial') || m.contains('walk')) {
      return 'Understood. We\'ll litigate. Our last number stays open for 48 hours.';
    }
    return 'Noted. We can move slightly if you justify the number with medicals/liability strength. What\'s your authority?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LawTheme.background,
      appBar: AppBar(backgroundColor: LawTheme.bench, foregroundColor: Colors.white, title: const Text('Negotiation')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(widget.lesson.negotiationOffer, style: TextStyle(color: LawTheme.textPrimary, fontWeight: FontWeight.w700, height: 1.4)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton(onPressed: _loading ? null : () => _move('We accept the offer.'), child: const Text('Accept')),
              OutlinedButton(onPressed: _loading ? null : () => _move('We reject and will proceed to trial.'), child: const Text('Go to trial')),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _counter,
            decoration: InputDecoration(
              labelText: 'Counter-offer details',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: LawTheme.surface,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _loading
                ? null
                : () {
                    final String t = _counter.text.trim();
                    if (t.isEmpty) {
                      StudyMessenger.showInfo(context, 'Type a counter first.');
                      return;
                    }
                    _move('Counter: $t');
                  },
            child: const Text('Send counter'),
          ),
          const SizedBox(height: 16),
          ..._log.map(
            (String line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: LawTheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: LawTheme.border)),
                child: TutorMarkdownBody(text: line, textColor: LawTheme.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
