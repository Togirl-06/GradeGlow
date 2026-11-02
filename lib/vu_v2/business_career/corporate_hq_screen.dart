import 'package:flutter/material.dart';

import 'business_career_content.dart';
import 'business_career_progress.dart';
import 'business_career_theme.dart';
import 'declining_company_mission_screen.dart';

/// Business Administration career environment — Corporate Headquarters.
class CorporateHqScreen extends StatefulWidget {
  const CorporateHqScreen({super.key, required this.progress});

  final BusinessCareerProgress progress;

  @override
  State<CorporateHqScreen> createState() => _CorporateHqScreenState();
}

class _CorporateHqScreenState extends State<CorporateHqScreen> {
  String _room = 'reception';

  Future<void> _talk(BizNpc npc) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: BizCosmic.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        final String line = switch (npc.id) {
          'mgr_chen' =>
            'If you have not started The Declining Company yet, talk to me from '
                'the Mission Board — I need a recovery plan backed by data.',
          'alex_rivera' =>
            'Customers feel delivery and quality slipping. Retention offers '
                'help for a month, then churn returns unless ops improves.',
          _ =>
            'Protect cash, but do not starve the product. Every dollar needs an ROI story.',
        };
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${npc.name} · ${npc.role}',
                style: const TextStyle(
                  color: BizCosmic.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                npc.personality,
                style: const TextStyle(color: BizCosmic.gold, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                line,
                style: const TextStyle(color: BizCosmic.mute, height: 1.4),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: npc.accent,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openObject(String id) async {
    final String title;
    final String body;
    switch (id) {
      case 'computer':
        title = 'Operations terminal';
        body =
            'Open the performance dashboard inside The Declining Company mission '
            'to inspect customers, revenue, cost, and satisfaction.';
      case 'budget':
        title = 'Budget dashboard';
        body =
            'You will allocate an \$80,000 recovery budget across retention, '
            'operations, and product during the signature mission.';
      case 'conference':
        title = 'Conference room';
        body =
            'Present your recommendation to Morgan Chen after you finish diagnosis '
            'and budget allocation.';
      default:
        title = 'Workstation';
        body = 'Interactive tools unlock inside active missions.';
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: BizCosmic.panel,
        title: Text(title, style: const TextStyle(color: BizCosmic.ink)),
        content: Text(body, style: const TextStyle(color: BizCosmic.mute)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _startMission() async {
    final bool done = widget.progress
        .isMissionComplete(BizMissionCatalog.decliningCompany.id);
    if (done) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Declining Company already completed — replay coming in a later phase.',
          ),
        ),
      );
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            DecliningCompanyMissionScreen(progress: widget.progress),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool missionDone = widget.progress
        .isMissionComplete(BizMissionCatalog.decliningCompany.id);
    final bool missionActive =
        widget.progress.activeMissionId == BizMissionCatalog.decliningCompany.id;

    return Scaffold(
      backgroundColor: BizCosmic.bg,
      appBar: BizCosmic.appBar(
        context: context,
        title: 'Corporate Headquarters',
        icon: Icons.apartment_rounded,
      ),
      body: BizStarfield(
        child: AnimatedBuilder(
          animation: widget.progress,
          builder: (BuildContext context, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BizCosmic.panelBox(radius: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Northwind Retail HQ',
                        style: TextStyle(
                          color: BizCosmic.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.progress.displayName} · ${widget.progress.stageLabel}',
                        style: const TextStyle(color: BizCosmic.mute),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          BizCosmic.pill(
                            'XP ${widget.progress.xp}',
                            bg: BizCosmic.royal.withValues(alpha: 0.25),
                          ),
                          BizCosmic.pill(
                            'Lv ${widget.progress.level}',
                            bg: BizCosmic.gold.withValues(alpha: 0.25),
                            fg: BizCosmic.gold,
                          ),
                          if (missionDone)
                            BizCosmic.pill(
                              'Strategic Thinker',
                              bg: BizCosmic.emerald.withValues(alpha: 0.25),
                              fg: BizCosmic.emerald,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <String>[
                      'reception',
                      'open_office',
                      'conference',
                      'manager',
                    ].map((String r) {
                      final String label = switch (r) {
                        'open_office' => 'Open office',
                        'conference' => 'Conference',
                        'manager' => "Manager's office",
                        _ => 'Reception',
                      };
                      final bool on = _room == r;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: on,
                          onSelected: (_) => setState(() => _room = r),
                          selectedColor: BizCosmic.emerald.withValues(alpha: 0.35),
                          labelStyle: const TextStyle(color: BizCosmic.ink),
                          backgroundColor: BizCosmic.panelAlt,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _roomTitle,
                  style: const TextStyle(
                    color: BizCosmic.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _roomBlurb,
                  style: const TextStyle(color: BizCosmic.mute, height: 1.35),
                ),
                const SizedBox(height: 14),
                const Text(
                  'People',
                  style: TextStyle(
                    color: BizCosmic.mute,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ...BizHqNpcs.all.map(
                  (BizNpc n) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => _talk(n),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: BizCosmic.stroke),
                      ),
                      tileColor: BizCosmic.panel,
                      leading: CircleAvatar(
                        backgroundColor: n.accent.withValues(alpha: 0.3),
                        child: Text(
                          n.name.isNotEmpty ? n.name[0] : '?',
                          style: const TextStyle(color: BizCosmic.ink),
                        ),
                      ),
                      title: Text(
                        n.name,
                        style: const TextStyle(
                          color: BizCosmic.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        n.role,
                        style: const TextStyle(color: BizCosmic.mute),
                      ),
                      trailing: const Icon(
                        Icons.chat_bubble_outline,
                        color: BizCosmic.mute,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Interactive objects',
                  style: TextStyle(
                    color: BizCosmic.mute,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _ObjChip(
                      icon: Icons.computer_rounded,
                      label: 'Computer',
                      onTap: () => _openObject('computer'),
                    ),
                    _ObjChip(
                      icon: Icons.pie_chart_rounded,
                      label: 'Budget dashboard',
                      onTap: () => _openObject('budget'),
                    ),
                    _ObjChip(
                      icon: Icons.tv_rounded,
                      label: 'Presentation screen',
                      onTap: () => _openObject('conference'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _startMission,
                  icon: Icon(
                    missionDone
                        ? Icons.check_circle_outline
                        : missionActive
                            ? Icons.play_circle_outline
                            : Icons.flag_rounded,
                  ),
                  label: Text(
                    missionDone
                        ? 'Declining Company completed'
                        : missionActive
                            ? 'Continue Declining Company'
                            : 'Start: The Declining Company',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: missionDone
                        ? BizCosmic.stroke
                        : BizCosmic.emerald,
                    foregroundColor:
                        missionDone ? BizCosmic.mute : Colors.black,
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
                if (missionDone &&
                    widget.progress.lastSimState != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    'Last score: ${widget.progress.lastSimState!['score']}/100',
                    style: const TextStyle(color: BizCosmic.mute, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String get _roomTitle => switch (_room) {
        'open_office' => 'Open-plan office',
        'conference' => 'Conference room',
        'manager' => "Manager's office",
        _ => 'Reception lobby',
      };

  String get _roomBlurb => switch (_room) {
        'open_office' =>
          'Analysts and coordinators work stations surround a shared performance wall.',
        'conference' =>
          'Glass boardroom with presentation screen — where recovery plans are judged.',
        'manager' =>
          'Morgan Chen\'s office. Briefings start here when a mission is active.',
        _ =>
          'Welcome desk, visitor lounge, and directory to departments.',
      };
}

class _ObjChip extends StatelessWidget {
  const _ObjChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: BizCosmic.gold),
      label: Text(label, style: const TextStyle(color: BizCosmic.ink)),
      backgroundColor: BizCosmic.panelAlt,
      side: const BorderSide(color: BizCosmic.stroke),
    );
  }
}
