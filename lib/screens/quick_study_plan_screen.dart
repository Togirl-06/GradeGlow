import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/study_planner_service.dart';
import '../theme/study_theme.dart';
import '../utils/study_messenger.dart';
import '../widgets/premium_gate.dart';

/// Quick AI study plan: exam date + subject → daily topics saved to Firestore.
class QuickStudyPlanScreen extends StatefulWidget {
  const QuickStudyPlanScreen({super.key});

  @override
  State<QuickStudyPlanScreen> createState() => _QuickStudyPlanScreenState();
}

class _QuickStudyPlanScreenState extends State<QuickStudyPlanScreen> {
  final TextEditingController _subject = TextEditingController(text: 'Calculus');
  DateTime _examDate = DateTime.now().add(const Duration(days: 14));

  @override
  void dispose() {
    _subject.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _examDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _examDate = picked);
  }

  Future<void> _generate() async {
    final StudyPlannerService planner = context.read<StudyPlannerService>();
    try {
      await planner.generateQuickPlan(subject: _subject.text.trim(), examDate: _examDate);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Study plan saved — open Planner to view tasks')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      StudyMessenger.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final StudyPlannerService planner = context.watch<StudyPlannerService>();
    final Color textSecondary = StudyColors.textSecondary(Theme.of(context).brightness);
    final DateFormat fmt = DateFormat.yMMMd();

    return PremiumGate(
      title: 'AI Study Plan',
      description:
          'Personalized AI study plans with day-by-day topics require Premium. Upgrade to generate a custom schedule for your exam.',
      icon: Icons.auto_awesome,
      child: Scaffold(
      appBar: AppBar(title: const Text('AI Study Plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Enter your exam date and subject. AI builds a day-by-day plan (Limits, Derivatives, …) and saves it.',
            style: TextStyle(color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _subject,
            decoration: const InputDecoration(labelText: 'Subject', hintText: 'Calculus'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Exam date'),
            subtitle: Text(fmt.format(_examDate)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: planner.isGenerating ? null : _generate,
            icon: planner.isGenerating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome),
            label: Text(planner.isGenerating ? 'Building plan…' : 'Generate study plan'),
          ),
        ],
      ),
    ),
    );
  }
}
