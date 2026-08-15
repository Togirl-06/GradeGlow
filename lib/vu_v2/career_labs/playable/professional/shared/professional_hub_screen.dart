import 'package:flutter/material.dart';

import 'professional_ranks.dart';
import 'professional_theme.dart';
import 'professional_case_store.dart';

class ProDept {
  const ProDept({
    required this.id,
    required this.icon,
    required this.title,
    required this.blurb,
  });

  final String id;
  final String icon;
  final String title;
  final String blurb;
}

class ProMission {
  const ProMission({
    required this.id,
    required this.icon,
    required this.title,
    required this.blurb,
    required this.briefing,
    required this.objective,
    this.checklist = const <String>[],
    this.xpReward = 150,
    this.coinReward = 3,
    this.badgeReward = 'Mission Badge',
    this.npcName = 'Supervisor',
    this.npcRole = 'Lead',
  });

  final String id;
  final String icon;
  final String title;
  final String blurb;
  final String briefing;
  final String objective;
  final List<String> checklist;
  final int xpReward;
  final int coinReward;
  final String badgeReward;
  final String npcName;
  final String npcRole;
}

/// Professional workplace dashboard — departments · live mission · meters · career.
class ProSimHubScreen extends StatelessWidget {
  const ProSimHubScreen({
    super.key,
    required this.theme,
    required this.store,
    required this.departments,
    required this.missions,
    required this.selectedDeptId,
    required this.selectedMissionId,
    required this.onSelectDept,
    required this.onSelectMission,
    required this.onContinue,
    required this.workspace,
    this.meterLabels = const <String>[],
  });

  final ProSimTheme theme;
  final ProCaseStore store;
  final List<ProDept> departments;
  final List<ProMission> missions;
  final String selectedDeptId;
  final String selectedMissionId;
  final ValueChanged<String> onSelectDept;
  final ValueChanged<String> onSelectMission;
  final VoidCallback onContinue;
  final Widget workspace;
  final List<String> meterLabels;

  ProMission get _mission => missions.firstWhere(
        (ProMission m) => m.id == selectedMissionId,
        orElse: () => missions.first,
      );

  ProRank get _rank => ProCareerRanks.forXp(theme.id, store.xp);

  double get _progress {
    if (missions.isEmpty) return 0;
    final int done = missions
        .where((ProMission m) => store.completedMissionIds.contains(m.id))
        .length;
    return done / missions.length;
  }

  @override
  Widget build(BuildContext context) {
    final bool narrow = MediaQuery.sizeOf(context).width < 980;
    final List<String> skills =
        ProCareerRanks.skills[theme.id] ?? const <String>[];

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _TopBar(theme: theme, store: store, rank: _rank),
            Expanded(
              child: narrow
                  ? Column(
                      children: <Widget>[
                        SizedBox(
                          height: 48,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            children: missions
                                .map(
                                  (ProMission m) => Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text('${m.icon} ${m.blurb}'),
                                      selected: m.id == selectedMissionId,
                                      onSelected: (_) => onSelectMission(m.id),
                                      selectedColor: theme.accent,
                                      labelStyle: TextStyle(
                                        color: m.id == selectedMissionId
                                            ? Colors.black
                                            : Colors.white70,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                      backgroundColor: const Color(0xFF151C2C),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(child: _stage()),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          width: 260,
                          child: _LeftRail(
                            theme: theme,
                            departments: departments,
                            missions: missions,
                            selectedDeptId: selectedDeptId,
                            selectedMissionId: selectedMissionId,
                            completed: store.completedMissionIds,
                            mission: _mission,
                            onSelectDept: onSelectDept,
                            onSelectMission: onSelectMission,
                            onContinue: onContinue,
                          ),
                        ),
                        Expanded(child: _stage()),
                        SizedBox(
                          width: 260,
                          child: _RightRail(
                            theme: theme,
                            mission: _mission,
                            progress: _progress,
                            done: missions
                                .where((ProMission m) =>
                                    store.completedMissionIds.contains(m.id))
                                .length,
                            total: missions.length,
                            skills: skills,
                            store: store,
                            meterLabels: meterLabels,
                          ),
                        ),
                      ],
                    ),
            ),
            _Footer(theme: theme),
          ],
        ),
      ),
    );
  }

  Widget _stage() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.accent.withValues(alpha: 0.28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            color: const Color(0xFF121C2E),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _mission.title,
                style: TextStyle(
                  color: theme.accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(child: workspace),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.theme,
    required this.store,
    required this.rank,
  });

  final ProSimTheme theme;
  final ProCaseStore store;
  final ProRank rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1422),
        border: Border(
          bottom: BorderSide(color: theme.accent.withValues(alpha: 0.28)),
        ),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          ),
          Text(theme.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            theme.title.toUpperCase(),
            style: TextStyle(
              color: theme.accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${theme.workplace}  ·  ${theme.tagline}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.accent.withValues(alpha: 0.7),
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
          _pill('XP ${store.xp}', theme.accent),
          const SizedBox(width: 8),
          _pill('LVL ${rank.level}', const Color(0xFFFBBF24)),
          const SizedBox(width: 8),
          Text(
            rank.title,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _pill(String t, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Text(
        t,
        style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 11),
      ),
    );
  }
}

class _LeftRail extends StatelessWidget {
  const _LeftRail({
    required this.theme,
    required this.departments,
    required this.missions,
    required this.selectedDeptId,
    required this.selectedMissionId,
    required this.completed,
    required this.mission,
    required this.onSelectDept,
    required this.onSelectMission,
    required this.onContinue,
  });

  final ProSimTheme theme;
  final List<ProDept> departments;
  final List<ProMission> missions;
  final String selectedDeptId;
  final String selectedMissionId;
  final Set<String> completed;
  final ProMission mission;
  final ValueChanged<String> onSelectDept;
  final ValueChanged<String> onSelectMission;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0A1220),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        children: <Widget>[
          Text(
            'DEPARTMENTS',
            style: TextStyle(
              color: theme.accent,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...departments.map((ProDept d) {
            final bool on = d.id == selectedDeptId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: InkWell(
                onTap: () => onSelectDept(d.id),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: on
                        ? theme.accent.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: on ? theme.accent : Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(d.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          d.title,
                          style: TextStyle(
                            color: on ? theme.accent : Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          Text(
            'MISSIONS',
            style: TextStyle(
              color: theme.accent,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...missions.map((ProMission m) {
            final bool on = m.id == selectedMissionId;
            final bool done = completed.contains(m.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: InkWell(
                onTap: () => onSelectMission(m.id),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: on
                        ? theme.accent.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: on ? theme.accent : Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(m.icon, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m.blurb,
                          style: TextStyle(
                            color: on ? theme.accent : Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (done)
                        Icon(Icons.check_circle, size: 14, color: theme.accent),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111A2A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.accent.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'CURRENT BRIEFING',
                  style: TextStyle(
                    color: theme.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${mission.npcName} · ${mission.npcRole}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mission.briefing,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                ...mission.checklist.take(4).map(
                      (String s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check_box_outline_blank,
                                size: 14, color: theme.accent),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                s,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.accent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+${mission.xpReward} XP · ${mission.coinReward} coins · ${mission.badgeReward}',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RightRail extends StatelessWidget {
  const _RightRail({
    required this.theme,
    required this.mission,
    required this.progress,
    required this.done,
    required this.total,
    required this.skills,
    required this.store,
    required this.meterLabels,
  });

  final ProSimTheme theme;
  final ProMission mission;
  final double progress;
  final int done;
  final int total;
  final List<String> skills;
  final ProCaseStore store;
  final List<String> meterLabels;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0A1220),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          _card(
            'OBJECTIVE',
            Text(
              mission.objective,
              style: const TextStyle(color: Colors.white70, height: 1.35, fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
          _card(
            'PROGRESS',
            Column(
              children: <Widget>[
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: theme.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                Text(
                  '$done / $total missions',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white12,
                    color: theme.accent,
                  ),
                ),
              ],
            ),
          ),
          if (meterLabels.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            _card(
              'LIVE METERS',
              Column(
                children: meterLabels.map((String k) {
                  final double v = (store.meters[k] ?? 50) / 100;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                k,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(
                              '${(v * 100).round()}',
                              style: TextStyle(
                                color: theme.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: v,
                            minHeight: 5,
                            backgroundColor: Colors.white12,
                            color: theme.accent,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 10),
          _card(
            'SKILLS',
            Column(
              children: skills.map((String s) {
                final int sx = store.skillXp[s] ?? 0;
                final double v = (sx / 200).clamp(0.12, 1.0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(s,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 5,
                          backgroundColor: Colors.white12,
                          color: theme.accent,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          _card(
            'CASE NOTEBOOK',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Notes: ${store.notes.length}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11)),
                Text('Evidence: ${store.evidence.length}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11)),
                Text('Decisions: ${store.decisions.length}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: theme.accent,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.theme});
  final ProSimTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF080E18),
        border: Border(
          top: BorderSide(color: theme.accent.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Text(
            'VIRTUAL UNIVERSITY',
            style: TextStyle(
              color: theme.accent,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'THE SIMULATION IS THE LESSON',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
