import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../life_sim/ui/screens/life_game_screen.dart';
import '../../services/appearance_service.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';

/// Labs tab — GradeGlow Life campus (character, schools, labs, career loop).
class VuV2LabsHub extends StatelessWidget {
  const VuV2LabsHub({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    context.watch<AppearanceService>();
    VuV2Colors.syncTo(Theme.of(context));

    void openLifeSim() {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const LifeGameLauncher()),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
      children: <Widget>[
        Text(
          'Labs',
          style: TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Create a character, explore campus schools, use the labs, and run the full career loop.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.4),
        ),
        const SizedBox(height: 14),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: openLifeSim,
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    const Color(0xFF14B8A6),
                    const Color(0xFF3B82F6),
                    VuV2Colors.navy,
                  ],
                ),
                border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'GradeGlow Life — Campus',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Apartment, school buildings, working labs, interviews, jobs, and pay.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.location_city_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: openLifeSim,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.location_city_rounded),
            label: const Text(
              'Enter GradeGlow Life',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}
