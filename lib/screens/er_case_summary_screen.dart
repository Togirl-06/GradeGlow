import 'package:flutter/material.dart';

import '../data/er_simulation_data.dart';
import '../models/er_simulation.dart';

class ErCaseSummaryScreen extends StatelessWidget {
  const ErCaseSummaryScreen({super.key, required this.run, required this.stars});

  final ErSimulationRun run;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final int bonus = run.secondsRemaining > 120 ? 150 : 50;
    final int totalXp = run.xp + bonus;

    return Scaffold(
      backgroundColor: ErSimulationData.screenBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              const Spacer(),
              const Text('Excellent Work!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(3, (int i) {
                  return Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 42,
                  );
                }),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ErSimulationData.panelBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ErSimulationData.panelBorder),
                ),
                child: Column(
                  children: <Widget>[
                    _XpRow(label: 'Case completion', value: run.xp),
                    _XpRow(label: 'Time bonus', value: bonus),
                    const Divider(color: Colors.white24),
                    _XpRow(label: 'Total XP', value: totalXp, bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...run.achievements.map(
                (String a) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
                      const SizedBox(width: 8),
                      Text(a, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _RewardChip(icon: Icons.bolt_rounded, label: '$totalXp XP'),
                  _RewardChip(icon: Icons.monetization_on_rounded, label: '250'),
                  _RewardChip(icon: Icons.workspace_premium_rounded, label: 'Cardiac Care'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _XpRow extends StatelessWidget {
  const _XpRow({required this.label, required this.value, this.bold = false});

  final String label;
  final int value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: bold ? FontWeight.w800 : FontWeight.w500))),
          Text('$value XP', style: TextStyle(color: Colors.white, fontWeight: bold ? FontWeight.w900 : FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ErSimulationData.panelBorder),
          ),
          child: Icon(icon, color: const Color(0xFFF59E0B)),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
