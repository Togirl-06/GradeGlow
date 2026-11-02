import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../models/engineering/engineering_program.dart';
import '../../services/openai_service.dart';
import '../../theme/engineering_theme.dart';
import '../../utils/study_messenger.dart';
import '../../widgets/tutor_markdown_body.dart';

/// AI senior engineer reviews the student's design notes.
class EngineeringDesignReviewScreen extends StatefulWidget {
  const EngineeringDesignReviewScreen({
    super.key,
    required this.major,
    required this.course,
  });

  final EngineeringMajor major;
  final EngineeringCourse course;

  @override
  State<EngineeringDesignReviewScreen> createState() => _EngineeringDesignReviewScreenState();
}

class _EngineeringDesignReviewScreenState extends State<EngineeringDesignReviewScreen> {
  final TextEditingController _design = TextEditingController();
  String? _review;
  bool _loading = false;

  @override
  void dispose() {
    _design.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String notes = _design.text.trim();
    if (notes.isEmpty) {
      StudyMessenger.showInfo(context, 'Describe your design before requesting review.');
      return;
    }
    setState(() {
      _loading = true;
      _review = null;
    });
    try {
      final String review;
      if (AppConfig.hasOpenAi) {
        review = await context.read<OpenAiService>().engineeringDesignReview(
              majorName: widget.major.name,
              courseTitle: widget.course.title,
              challenge: widget.course.simulatorBrief,
              studentDesign: notes,
            );
      } else {
        review = _offlineReview(notes);
      }
      if (!mounted) return;
      setState(() {
        _review = review;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      StudyMessenger.showError(context, e);
    }
  }

  String _offlineReview(String notes) {
    final bool hasNumber = RegExp(r'\d').hasMatch(notes);
    final bool hasUnit = RegExp(r'(mm|cm|m|kN|MPa|bar|°C|V|A|Ω|rpm|MW)', caseSensitive: false).hasMatch(notes);
    final StringBuffer missing = StringBuffer();
    if (!hasNumber) missing.writeln('- Add actual numbers (sizes, loads, temperatures, voltages, etc.).');
    if (!hasUnit) missing.writeln('- Add units (mm, kN, MPa, °C, V…). Numbers without units are not engineering yet.');

    return '## What is working\n'
        'You wrote a design intent for **${widget.course.title}**. That is the right first step.\n\n'
        '## Safety & failure modes\n'
        'Ask: if this is 20% worse than expected, what fails first? Name one failure mode '
        '(yield, buckling, overheat, stall, leak, overload, kick, runaway).\n\n'
        '## Efficiency & cost\n'
        'Circle the most expensive or energy-hungry choice in your notes. Is there a cheaper option that still meets the requirement?\n\n'
        '## Top 3 fixes\n'
        '1. State the requirement in one sentence (must carry X / purify to Y / keep temp under Z).\n'
        '2. List governing variables you can change.\n'
        '3. Pick a target margin (factor of safety or performance headroom) and say why.\n\n'
        '## Beginner tip\n'
        'Good design notes always include: **goal, constraints, numbers+units, assumed materials, and how you will test**.\n\n'
        '${missing.isEmpty ? 'Your notes already include numbers/units — nice. Next, add the test plan.' : '## Missing details\n$missing'}\n'
        '_(Connect OpenAI for a full senior-engineer critique tailored to your text.)_';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EngineeringTheme.background,
      appBar: AppBar(
        backgroundColor: EngineeringTheme.primary,
        foregroundColor: Colors.white,
        title: const Text('AI Design Review'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          Text(
            'Submit like you would to a senior engineer — materials, dimensions, loads, and constraints.',
            style: TextStyle(color: EngineeringTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 8),
          Text(
            'Challenge: ${widget.course.simulatorBrief}',
            style: TextStyle(color: EngineeringTheme.primary, fontWeight: FontWeight.w700, height: 1.4),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _design,
            minLines: 8,
            maxLines: 16,
            style: TextStyle(color: EngineeringTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Example: Beam depth 45 cm, span 20 m, steel grade…',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: EngineeringTheme.surface,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: EngineeringTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.rate_review_outlined),
            label: Text(_loading ? 'Reviewing…' : 'Request design review', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          if (_review != null) ...<Widget>[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: EngineeringTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EngineeringTheme.border),
              ),
              child: TutorMarkdownBody(text: _review!, textColor: EngineeringTheme.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}
