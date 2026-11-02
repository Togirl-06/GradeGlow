import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/flashcard_service.dart';
import '../theme/study_theme.dart';
import '../widgets/study_surface.dart';
import '../utils/study_messenger.dart';

class FlashcardGeneratorScreen extends StatefulWidget {
  const FlashcardGeneratorScreen({super.key});

  @override
  State<FlashcardGeneratorScreen> createState() => _FlashcardGeneratorScreenState();
}

class _FlashcardGeneratorScreenState extends State<FlashcardGeneratorScreen> {
  final TextEditingController _topic = TextEditingController(text: 'Photosynthesis');
  int _count = 10;

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final String topic = _topic.text.trim();
    if (topic.isEmpty) return;
    final FlashcardService flashcards = context.read<FlashcardService>();
    try {
      final int added = await flashcards.generateFromTopic(topic: topic, count: _count);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $added flashcards on "$topic"')),
      );
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final FlashcardService flashcards = context.watch<FlashcardService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Flashcard Generator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text('Enter a topic — AI creates Q&A cards and saves them to Firebase.', style: TextStyle(color: textSecondary)),
          const SizedBox(height: 16),
          TextField(
            controller: _topic,
            decoration: const InputDecoration(labelText: 'Topic', hintText: 'Photosynthesis'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _count,
            decoration: const InputDecoration(labelText: 'Number of cards'),
            items: const <DropdownMenuItem<int>>[
              DropdownMenuItem<int>(value: 5, child: Text('5 cards')),
              DropdownMenuItem<int>(value: 10, child: Text('10 cards')),
              DropdownMenuItem<int>(value: 20, child: Text('20 cards')),
            ],
            onChanged: (int? v) => setState(() => _count = v ?? 10),
          ),
          const SizedBox(height: 20),
          StudySurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Example', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Q: What is photosynthesis?', style: TextStyle(color: textSecondary)),
                Text('A: Process plants use to make food.', style: TextStyle(color: textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: flashcards.isGenerating ? null : _generate,
            icon: flashcards.isGenerating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome),
            label: Text(flashcards.isGenerating ? 'Generating…' : 'Generate flashcards'),
          ),
        ],
      ),
    );
  }
}
