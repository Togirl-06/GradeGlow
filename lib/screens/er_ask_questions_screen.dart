import 'package:flutter/material.dart';

import '../data/er_simulation_data.dart';
import '../models/er_simulation.dart';

class ErAskQuestionsScreen extends StatefulWidget {
  const ErAskQuestionsScreen({super.key, required this.run, required this.onChanged});

  final ErSimulationRun run;
  final VoidCallback onChanged;

  @override
  State<ErAskQuestionsScreen> createState() => _ErAskQuestionsScreenState();
}

class _ErAskQuestionsScreenState extends State<ErAskQuestionsScreen> {
  String? _lastResponse;

  void _ask(ErQuestion question) {
    if (widget.run.askedQuestions.contains(question.prompt)) return;
    widget.run.askedQuestions.add(question.prompt);
    widget.run.patientLine = question.response;
    widget.run.addXp(question.xp);
    if (widget.run.askedQuestions.length >= 2 &&
        widget.run.objectives.length > 1 &&
        !widget.run.objectives[1].complete) {
      widget.run.objectives[1] = widget.run.objectives[1].advance();
      widget.run.achievements.add('Identified possible heart attack');
    }
    setState(() => _lastResponse = question.response);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final ErSimulationRun run = widget.run;
    return Scaffold(
      backgroundColor: ErSimulationData.screenBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('ASK QUESTIONS'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: <Widget>[
                const Icon(Icons.monetization_on_rounded, color: Color(0xFFF59E0B), size: 18),
                const SizedBox(width: 4),
                Text('${run.coins}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'What would you like to ask the patient?',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 14),
          ...run.caseData.questions.map((ErQuestion q) {
            final bool asked = run.askedQuestions.contains(q.prompt);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: asked ? const Color(0xFF312E81) : const Color(0xFF4C1D95),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: asked ? null : () => _ask(q),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(q.prompt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                        Text('+${q.xp} XP', style: TextStyle(color: asked ? Colors.white54 : const Color(0xFFC4B5FD), fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
            label: const Text('Back to Actions', style: TextStyle(color: Colors.white70)),
          ),
          if (_lastResponse != null) ...<Widget>[
            const SizedBox(height: 20),
            Text('PATIENT RESPONSE', style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ErSimulationData.panelBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ErSimulationData.panelBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: <Color>[Color(0xFF64748B), Color(0xFF334155)]),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '"$_lastResponse"',
                      style: const TextStyle(color: Colors.white, height: 1.45, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
