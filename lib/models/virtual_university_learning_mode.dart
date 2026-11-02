import 'package:flutter/material.dart';

/// The three learning experiences on every AI Professor chapter screen.
enum AiProfessorVoiceMode {
  readAloud(
    'Read Aloud',
    Icons.headphones_outlined,
    'Narration',
    'Listen to the textbook notes exactly as written — word for word.',
    <String>[
      'Highlights each sentence while it reads',
      'Change speed from 0.5x to 2x',
      'Pause, rewind, or skip ahead',
      'Resume where you stopped',
    ],
  ),
  professor(
    'AI Professor',
    Icons.school_outlined,
    'Instruction',
    'Learn from an expert professor — explanations, examples, and Q&A.',
    <String>[
      'Read the full textbook chapter below',
      'Ask questions anytime in the chat box',
      'Get examples, diagrams, and step-by-step help',
      'Not the same as Read Aloud — this is interactive teaching',
    ],
  ),
  study(
    'Study',
    Icons.quiz_outlined,
    'Practice',
    'Reinforce the lesson with quizzes and active recall — not narration.',
    <String>[
      'Topic quizzes and practice questions',
      'Review summaries and key formulas',
      'Track weak areas and retest yourself',
      'Use after reading or listening to the chapter',
    ],
  );

  const AiProfessorVoiceMode(
    this.label,
    this.icon,
    this.role,
    this.summary,
    this.bullets,
  );

  final String label;
  final IconData icon;
  final String role;
  final String summary;
  final List<String> bullets;
}

/// One action shown inside Study mode (quiz, practice, etc.).
class VirtualUniversityStudyAction {
  const VirtualUniversityStudyAction({
    required this.label,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String description;
  final VoidCallback onTap;
}
