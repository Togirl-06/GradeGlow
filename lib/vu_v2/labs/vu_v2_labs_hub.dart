import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/appearance_service.dart';
import '../data/vu_v2_progress_store.dart';
import '../data/vu_v2_session.dart';
import '../design/vu_v2_theme.dart';
import '../game/career/vu_career_world_pack.dart';
import '../game/career/vu_career_world_router.dart';
import '../game/career/vu_career_worlds.dart';
import '../game/ui/campus_iso_preview.dart';

/// Labs tab = Career Games (walkable engine worlds). Old Labs are not used.
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

    final VuCareerWorldPack? yours = VuCareerWorlds.forMajor(session.majorId);
    final List<VuCareerWorldPack> others = VuCareerWorlds.all
        .where((VuCareerWorldPack w) => w.id != yours?.id)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
      children: <Widget>[
        Text(
          'Career Games',
          style: TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Learn → Practice → Experience. Walk into the profession.',
          style: TextStyle(color: VuV2Colors.mute, height: 1.4),
        ),
        const SizedBox(height: 14),
        CampusIsoPreview(
          onExplore: yours == null
              ? null
              : () => VuCareerWorldRouter.open(context, yours),
        ),
        const SizedBox(height: 14),
        _LoopStrip(),
        const SizedBox(height: 18),
        if (yours != null) ...<Widget>[
          Text(
            'Your career world',
            style: TextStyle(
              color: VuV2Colors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${session.majorLabel} · ${yours.role}',
            style: TextStyle(color: VuV2Colors.mute, fontSize: 13),
          ),
          const SizedBox(height: 10),
          _WorldHero(
            pack: yours,
            badge: yours.id == 'nursing' ? 'FLAGSHIP CLINICAL' : 'PLAYABLE',
            onEnter: () => VuCareerWorldRouter.open(context, yours),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          'All career worlds',
          style: TextStyle(
            color: VuV2Colors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Each major has its own walkable workplace, NPCs, and mission.',
          style: TextStyle(color: VuV2Colors.mute, fontSize: 13),
        ),
        const SizedBox(height: 10),
        ...others.map(
          (VuCareerWorldPack w) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _WorldRow(
              pack: w,
              onEnter: () => VuCareerWorldRouter.open(context, w),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoopStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<String> steps = <String>[
      'Study',
      'Lecture',
      'Practice',
      'Career game',
      'XP',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: VuV2Colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VuV2Colors.stroke),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < steps.length; i++) ...<Widget>[
            if (i > 0)
              Icon(Icons.arrow_forward_rounded, size: 12, color: VuV2Colors.mute),
            Expanded(
              child: Text(
                steps[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: i == 3 ? VuV2Colors.mint : VuV2Colors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorldHero extends StatelessWidget {
  const _WorldHero({
    required this.pack,
    required this.onEnter,
    this.badge,
  });

  final VuCareerWorldPack pack;
  final VoidCallback onEnter;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final Color accent = Color(pack.accent);
    return Material(
      color: VuV2Colors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onEnter,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.5)),
            gradient: LinearGradient(
              colors: <Color>[
                accent.withValues(alpha: 0.16),
                VuV2Colors.card,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(pack.emoji, style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          pack.title,
                          style: TextStyle(
                            color: VuV2Colors.ink,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          pack.role,
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                pack.subtitle,
                style: TextStyle(
                  color: VuV2Colors.mute,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onEnter,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    pack.id == 'nursing' ? 'Enter hospital' : 'Enter world',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldRow extends StatelessWidget {
  const _WorldRow({required this.pack, required this.onEnter});

  final VuCareerWorldPack pack;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VuV2Colors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onEnter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: VuV2Colors.stroke),
          ),
          child: Row(
            children: <Widget>[
              Text(pack.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      pack.title,
                      style: TextStyle(
                        color: VuV2Colors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      pack.subtitle,
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
              Icon(Icons.chevron_right_rounded, color: VuV2Colors.mute),
            ],
          ),
        ),
      ),
    );
  }
}
