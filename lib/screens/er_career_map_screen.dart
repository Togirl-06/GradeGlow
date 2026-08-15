import 'package:flutter/material.dart';

import '../data/er_simulation_data.dart';

class ErCareerMapScreen extends StatelessWidget {
  const ErCareerMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ErSimulationData.screenBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Career Quest Map'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: <Color>[Color(0xFF2563EB), Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: <Widget>[
                CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.person_rounded, color: Colors.white, size: 32)),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('NURSE IN TRAINING', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
                      Text('Level 3', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Chapter 2: Emergency Care', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          ...ErSimulationData.careerMap.map((Map<String, dynamic> node) {
            final bool unlocked = node['unlocked'] == true;
            final bool current = node['current'] == true;
            final int stars = (node['stars'] as num?)?.toInt() ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: current ? const Color(0xFF312E81) : ErSimulationData.panelBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: current ? const Color(0xFF7C3AED) : ErSimulationData.panelBorder),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(unlocked ? Icons.medical_services_rounded : Icons.lock_rounded, color: unlocked ? const Color(0xFF22D3EE) : Colors.white38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(node['title'] as String, style: TextStyle(color: unlocked ? Colors.white : Colors.white54, fontWeight: FontWeight.w800)),
                    ),
                    if (unlocked)
                      Row(
                        children: List<Widget>.generate(3, (int i) {
                          return Icon(Icons.star_rounded, size: 16, color: i < stars ? const Color(0xFFF59E0B) : Colors.white24);
                        }),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
