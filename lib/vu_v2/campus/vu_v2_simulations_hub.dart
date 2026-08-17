import 'package:flutter/material.dart';

import '../career_labs/career_lab_registry.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_components.dart';
import '../design/vu_v2_theme.dart';
import '../platform/vu_v2_platform.dart';

/// Professional simulations — law firm, hospital, company, not science benches.
class VuV2SimulationsHub extends StatelessWidget {
  const VuV2SimulationsHub({
    super.key,
    required this.session,
    required this.progress,
  });

  final VuV2Session session;
  final VuV2ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    final List<CareerLabDef> labs = CareerLabRegistry.simulations;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        const VuV2SectionTitle('Simulations'),
        const SizedBox(height: 8),
        Text(
          'You are not taking a quiz. You are on the job.\n'
          'Role · environment · mission · decisions · consequences · evaluation.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.45),
        ),
        const SizedBox(height: 8),
        Text(
          'Educational simulations — not a substitute for licensure or real clinical/legal training.',
          style: TextStyle(
            color: VuV2Colors.mute.withValues(alpha: 0.85),
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        ...labs.map(
          (CareerLabDef lab) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SimCard(
              lab: lab,
              onTap: lab.available ? () => openCareerLab(context, lab) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _SimCard extends StatelessWidget {
  const _SimCard({required this.lab, this.onTap});

  final CareerLabDef lab;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool locked = onTap == null;
    return Material(
      color: VuV2Colors.navyElevated,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: VuV2Colors.stroke),
          ),
          child: Row(
            children: <Widget>[
              Text(lab.emoji, style: TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      lab.role.toUpperCase(),
                      style: TextStyle(
                        color: VuV2Colors.orange,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lab.title,
                      style: TextStyle(
                        color: locked ? VuV2Colors.mute : VuV2Colors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lab.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: VuV2Colors.mute,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                locked ? Icons.lock_outline : Icons.play_circle_fill_rounded,
                color: locked ? VuV2Colors.mute : VuV2Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
