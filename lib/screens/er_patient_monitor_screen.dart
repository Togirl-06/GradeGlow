import 'package:flutter/material.dart';

import '../data/er_simulation_data.dart';
import '../models/er_simulation.dart';

class ErPatientMonitorScreen extends StatelessWidget {
  const ErPatientMonitorScreen({super.key, required this.run});

  final ErSimulationRun run;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ErSimulationData.screenBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Patient Monitor'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: <Color>[Color(0xFF7F1D1D), Color(0xFF450A0A)]),
              border: Border.all(color: ErSimulationData.panelBorder),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                const Icon(Icons.favorite_rounded, size: 72, color: Color(0xFFFCA5A5)),
                Positioned(
                  bottom: 16,
                  child: Text('${run.vitals.heartRate} BPM', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'Current Status',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...run.caseData.statusLines.map(
                  (String line) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.circle, size: 8, color: Color(0xFFF87171)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(line, style: const TextStyle(color: Colors.white))),
                      ],
                    ),
                  ),
                ),
                if (run.isCritical)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F1D1D).withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEF4444)),
                    ),
                    child: const Row(
                      children: <Widget>[
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFCA5A5)),
                        SizedBox(width: 8),
                        Expanded(child: Text('Patient condition is critical!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Panel(
            title: 'Objectives',
            child: Column(
              children: run.objectives.map((ErObjective obj) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        obj.complete ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                        color: obj.complete ? const Color(0xFF34D399) : Colors.white38,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${obj.label} ${obj.progress}/${obj.target}', style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _Panel(
            title: 'TIP',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.local_hospital_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(run.caseData.tip, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), height: 1.4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ErSimulationData.panelBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ErSimulationData.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
