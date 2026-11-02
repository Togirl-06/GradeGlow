import 'package:flutter/material.dart';

import '../../../models/practice_lab.dart';
import '../../../screens/er_simulation_screen.dart';

/// Opens the existing ER simulation as a deep clinical beat, then returns success.
abstract final class CareerSimErBridge {
  static const PracticeLabCategory _category = PracticeLabCategory(
    id: 'career_nursing_ed',
    name: 'Nursing ED',
    emoji: '🏥',
    icon: Icons.local_hospital_outlined,
    labs: <PracticeLabType>[_lab],
  );

  static const PracticeLabType _lab = PracticeLabType(
    id: 'er_chest',
    title: 'ED Cardiac Challenge',
    subtitle: 'Stabilize the patient, then return to your shift.',
    style: SimulationStyle.erEmergency,
    timed: true,
    aiRole: 'Patient',
    studentTasks: <String>[
      'Assess the patient',
      'Order interventions',
      'Communicate with the care team',
    ],
    evaluationCriteria: <String>[
      'Accuracy',
      'Speed',
      'Critical Thinking',
      'Communication',
      'Clinical Decision Making',
    ],
    difficulty: 'Career Sim',
  );

  /// Returns true if the student completed the ER case without aborting immediately.
  static Future<bool> openChallenge(BuildContext context) async {
    final bool? result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext ctx) => _ErBridgeHost(
          child: ErSimulationScreen(category: _category, lab: _lab),
        ),
      ),
    );
    return result ?? true;
  }
}

/// Captures route pop so Career Sim can credit the clinical challenge.
class _ErBridgeHost extends StatefulWidget {
  const _ErBridgeHost({required this.child});

  final Widget child;

  @override
  State<_ErBridgeHost> createState() => _ErBridgeHostState();
}

class _ErBridgeHostState extends State<_ErBridgeHost> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        Navigator.of(context).pop(true);
      },
      child: Stack(
        children: <Widget>[
          widget.child,
          Positioned(
            right: 12,
            top: MediaQuery.paddingOf(context).top + 8,
            child: SafeArea(
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  'Return to shift',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
