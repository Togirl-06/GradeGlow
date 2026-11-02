import 'package:flutter/material.dart';

import '../../data/er_simulation_data.dart';
import '../../models/ai_practice_mode.dart';
import '../../models/er_simulation.dart';
import '../ai_practice/ai_practice_avatar.dart';

class ErGameHud extends StatelessWidget {
  const ErGameHud({super.key, required this.run});

  final ErSimulationRun run;

  String _formatTime(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: ErSimulationData.panelBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.monetization_on_rounded, color: Color(0xFFF59E0B), size: 18),
                  const SizedBox(width: 4),
                  Text('${run.coins}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const Spacer(),
            Icon(Icons.timer_outlined, color: Colors.white.withValues(alpha: 0.7), size: 18),
            const SizedBox(width: 4),
            Text(_formatTime(run.secondsRemaining), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: <Color>[Color(0xFF2563EB), Color(0xFF7C3AED)]),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('LEVEL ${run.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: run.levelXp / run.levelXpMax,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  color: const Color(0xFF22D3EE),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${run.levelXp}/${run.levelXpMax} XP', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class ErVitalsPanel extends StatelessWidget {
  const ErVitalsPanel({super.key, required this.vitals});

  final ErVitals vitals;

  Widget _tile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: <Widget>[
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 10, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ErSimulationData.panelBg.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ErSimulationData.panelBorder),
      ),
      child: Row(
        children: <Widget>[
          _tile('HR', '${vitals.heartRate}', const Color(0xFFF87171)),
          const SizedBox(width: 8),
          _tile('BP', vitals.bloodPressure, const Color(0xFFFB7185)),
          const SizedBox(width: 8),
          _tile('RR', '${vitals.respiratoryRate}', const Color(0xFF34D399)),
          const SizedBox(width: 8),
          _tile('SpO₂', '${vitals.spo2}%', const Color(0xFF38BDF8)),
          const SizedBox(width: 8),
          _tile('TEMP', '${vitals.temperature.toStringAsFixed(1)}°', const Color(0xFFFBBF24)),
        ],
      ),
    );
  }
}

class ErPatientScene extends StatelessWidget {
  const ErPatientScene({super.key, required this.run});

  final ErSimulationRun run;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            border: Border.all(color: ErSimulationData.panelBorder),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AiPracticeAvatar(
                      role: AvatarRole.patient,
                      isSpeaking: run.patientLine.isNotEmpty,
                      emotion: inferEmotionFromText(run.patientLine),
                      size: 112,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AvatarRole.patient.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AvatarRole.patient.accentColor.withValues(alpha: 0.45)),
                      ),
                      child: Text(
                        '${run.caseData.patientName}, ${run.caseData.patientAge}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Hospital bed · Nasal cannula', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '"${run.patientLine}"',
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class ErActionGrid extends StatelessWidget {
  const ErActionGrid({super.key, required this.onAction});

  final ValueChanged<ErSimulationAction> onAction;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.05,
      children: ErSimulationData.actions.map((ErSimulationAction action) {
        return Material(
          color: action.color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => onAction(action),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: action.color.withValues(alpha: 0.45)),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(action.icon, color: action.color, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
