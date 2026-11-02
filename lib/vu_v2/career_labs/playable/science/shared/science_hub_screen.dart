import 'package:flutter/material.dart';

import 'science_badges.dart';
import 'science_career_ranks.dart';
import 'science_lab_theme.dart';
import 'science_notebook_screen.dart';
import 'science_notebook_store.dart';

class ScienceHubStation {
  const ScienceHubStation({
    required this.id,
    required this.icon,
    required this.title,
    required this.blurb,
    required this.mission,
    this.instructorLine,
    this.missionNumber,
    this.checklist = const <String>[],
    this.xpReward = 150,
    this.coinReward = 3,
    this.badgeReward = 'Lab Badge',
  });

  final String id;
  final String icon;
  final String title;
  final String blurb;
  final String mission;
  final String? instructorLine;
  final String? missionNumber;
  final List<String> checklist;
  final int xpReward;
  final int coinReward;
  final String badgeReward;
}

/// Exact Virtual University lab dashboard (mockup): top · left · center · right · footer.
class ScienceLabHubScreen extends StatelessWidget {
  const ScienceLabHubScreen({
    super.key,
    required this.theme,
    required this.store,
    required this.stations,
    required this.selectedId,
    required this.onSelect,
    required this.onContinue,
    required this.workspace,
    this.badgeIds = const <String>[],
    this.subjectId = 'biology',
    this.tagline = 'EXPLORE · INVESTIGATE · DISCOVER',
    this.skillLabels = const <String>[
      'Observation',
      'Knowledge',
      'Accuracy',
      'Analysis',
    ],
    this.onSwitchSubject,
    this.mode = ScienceLabMode.experiment,
    this.onModeChanged,
  });

  final ScienceLabTheme theme;
  final ScienceNotebookStore store;
  final List<ScienceHubStation> stations;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onContinue;
  final Widget workspace;
  final List<String> badgeIds;
  final String subjectId;
  final String tagline;
  final List<String> skillLabels;
  final ValueChanged<String>? onSwitchSubject;
  final ScienceLabMode mode;
  final ValueChanged<ScienceLabMode>? onModeChanged;

  ScienceHubStation get _sel => stations.firstWhere(
        (ScienceHubStation s) => s.id == selectedId,
        orElse: () => stations.first,
      );

  int get _level => ScienceCareerRanks.forXp(subjectId, store.xp).level;

  double get _progress {
    if (stations.isEmpty) return 0;
    final int done =
        stations.where((ScienceHubStation s) => store.completedWorkIds.contains(s.id)).length;
    return (done / stations.length).clamp(0.0, 1.0);
  }

  int get _doneCount =>
      stations.where((ScienceHubStation s) => store.completedWorkIds.contains(s.id)).length;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final bool narrow = size.width < 980;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _TopBar(
              theme: theme,
              tagline: tagline,
              xp: store.xp,
              level: _level,
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: narrow
                  ? _NarrowBody(
                      theme: theme,
                      stations: stations,
                      selected: _sel,
                      completed: store.completedWorkIds,
                      onSelect: onSelect,
                      onContinue: onContinue,
                      workspace: workspace,
                      progress: _progress,
                      doneCount: _doneCount,
                      total: stations.length,
                      skillLabels: skillLabels,
                      xp: store.xp,
                      badges: store.badges,
                      badgeIds: badgeIds,
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          width: 268,
                          child: _LeftRail(
                            theme: theme,
                            stations: stations,
                            selected: _sel,
                            completed: store.completedWorkIds,
                            onSelect: onSelect,
                            onContinue: onContinue,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: _CenterStage(
                              theme: theme,
                              title: _workspaceTitle(_sel),
                              child: workspace,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 268,
                          child: _RightRail(
                            theme: theme,
                            station: _sel,
                            progress: _progress,
                            doneCount: _doneCount,
                            total: stations.length,
                            skillLabels: skillLabels,
                            xp: store.xp,
                            badges: store.badges,
                            badgeIds: badgeIds,
                            completed: store.completedWorkIds.contains(_sel.id),
                          ),
                        ),
                      ],
                    ),
            ),
            _Footer(
              theme: theme,
              subjectId: subjectId,
              mode: mode,
              onSwitchSubject: onSwitchSubject,
              onModeChanged: onModeChanged,
              onNotebook: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ScienceNotebookScreen(theme: theme, store: store),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _workspaceTitle(ScienceHubStation s) {
    switch (subjectId) {
      case 'chemistry':
        return s.id == 'titration' ? 'Titration Setup' : s.title;
      case 'physics':
        return s.id == 'energy' ? 'Simulation' : s.title;
      default:
        return s.id == 'cell' ? 'Label the Cell' : s.title;
    }
  }
}

enum ScienceLabMode { learn, experiment, solve, grow }

// ─── Top bar ───────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.theme,
    required this.tagline,
    required this.xp,
    required this.level,
    required this.onBack,
  });

  final ScienceLabTheme theme;
  final String tagline;
  final int xp;
  final int level;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
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
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          ),
          Text(theme.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(
            theme.title.toUpperCase(),
            style: TextStyle(
              color: theme.accent,
              fontWeight: FontWeight.w900,
              fontSize: 17,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              tagline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.accent.withValues(alpha: 0.75),
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 1.6,
              ),
            ),
          ),
          _stat('XP', _comma(xp), theme.accent),
          const SizedBox(width: 10),
          _stat('LVL', '$level', const Color(0xFFFBBF24)),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.accent.withValues(alpha: 0.2),
            child: Icon(Icons.person, size: 18, color: theme.accent),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _comma(int n) {
    final String s = '$n';
    final StringBuffer b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final int fromEnd = s.length - i;
      b.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) b.write(',');
    }
    return b.toString();
  }

  Widget _stat(String k, String v, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.45)),
      ),
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '$k ',
              style: TextStyle(
                color: c.withValues(alpha: 0.85),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            TextSpan(
              text: v,
              style: TextStyle(
                color: c,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Left rail ─────────────────────────────────────────────────────────────

class _LeftRail extends StatelessWidget {
  const _LeftRail({
    required this.theme,
    required this.stations,
    required this.selected,
    required this.completed,
    required this.onSelect,
    required this.onContinue,
  });

  final ScienceLabTheme theme;
  final List<ScienceHubStation> stations;
  final ScienceHubStation selected;
  final Set<String> completed;
  final ValueChanged<String> onSelect;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0A1220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
              itemCount: stations.length,
              itemBuilder: (BuildContext context, int i) {
                final ScienceHubStation s = stations[i];
                final bool sel = s.id == selected.id;
                final bool done = completed.contains(s.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: sel
                        ? theme.accent.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onSelect(s.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel
                                ? theme.accent
                                : Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(s.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s.blurb.isNotEmpty && s.blurb.length < 22
                                    ? s.title
                                    : s.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: sel ? theme.accent : Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (done)
                              Icon(Icons.check_circle,
                                  size: 15, color: theme.accent),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            child: _CurrentExperimentCard(
              theme: theme,
              station: selected,
              done: completed.contains(selected.id),
              onContinue: onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentExperimentCard extends StatelessWidget {
  const _CurrentExperimentCard({
    required this.theme,
    required this.station,
    required this.done,
    required this.onContinue,
  });

  final ScienceLabTheme theme;
  final ScienceHubStation station;
  final bool done;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final List<String> steps = station.checklist.isEmpty
        ? <String>[
            'Open the station tools',
            'Complete the investigation',
            'Record evidence',
            'Submit conclusion',
          ]
        : station.checklist;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.accent.withValues(alpha: 0.45)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.accent.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'CURRENT EXPERIMENT',
            style: TextStyle(
              color: theme.accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            station.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            station.mission,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          ...steps.take(4).toList().asMap().entries.map((MapEntry<int, String> e) {
            final bool checked = done || e.key == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: <Widget>[
                  Icon(
                    checked ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 15,
                    color: checked ? theme.accent : Colors.white38,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      e.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: checked ? Colors.white : Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                done ? 'REPLAY' : 'CONTINUE',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Rewards',
            style: TextStyle(
              color: theme.accent.withValues(alpha: 0.9),
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+${station.xpReward} XP  ·  ${station.coinReward} coins  ·  ${station.badgeReward}',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── Center ────────────────────────────────────────────────────────────────

class _CenterStage extends StatelessWidget {
  const _CenterStage({
    required this.theme,
    required this.title,
    required this.child,
  });

  final ScienceLabTheme theme;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1626),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.accent.withValues(alpha: 0.28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF121C2E),
              border: Border(
                bottom: BorderSide(color: theme.accent.withValues(alpha: 0.2)),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  color: theme.accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ─── Right rail ────────────────────────────────────────────────────────────

class _RightRail extends StatelessWidget {
  const _RightRail({
    required this.theme,
    required this.station,
    required this.progress,
    required this.doneCount,
    required this.total,
    required this.skillLabels,
    required this.xp,
    required this.badges,
    required this.badgeIds,
    required this.completed,
  });

  final ScienceLabTheme theme;
  final ScienceHubStation station;
  final double progress;
  final int doneCount;
  final int total;
  final List<String> skillLabels;
  final int xp;
  final Set<String> badges;
  final List<String> badgeIds;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0A1220),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: <Widget>[
          _panel(
            title: 'MISSION DETAILS',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  station.missionNumber ?? 'Mission',
                  style: TextStyle(
                    color: theme.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  station.mission,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                ...(station.checklist.isEmpty
                        ? const <String>['Investigate', 'Record', 'Conclude']
                        : station.checklist)
                    .take(5)
                    .map(
                      (String s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.radio_button_checked,
                              size: 12,
                              color: theme.accent.withValues(alpha: 0.8),
                            ),
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
              ],
            ),
          ),
          const SizedBox(height: 12),
          _panel(
            title: 'YOUR PROGRESS',
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 96,
                  width: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 96,
                        width: 96,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white12,
                          color: theme.accent,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              color: theme.accent,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '$doneCount/$total',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Skills',
                    style: TextStyle(
                      color: theme.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...skillLabels.asMap().entries.map((MapEntry<int, String> e) {
                  final double v =
                      ((xp / 80) + e.key * 9 + (completed ? 12 : 0))
                          .clamp(18, 92) /
                      100;
                  return _skillBar(e.value, v);
                }),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Next Reward',
                    style: TextStyle(
                      color: theme.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '+${station.xpReward} XP · ${station.badgeReward}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                if (badgeIds.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: badgeIds.take(4).map((String id) {
                      final bool on = badges.contains(id);
                      return CircleAvatar(
                        radius: 16,
                        backgroundColor: on
                            ? theme.accent.withValues(alpha: 0.25)
                            : Colors.white10,
                        child: Text(
                          ScienceBadges.glyphOf(id),
                          style: TextStyle(
                            fontSize: 14,
                            color: on ? null : Colors.white24,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: theme.accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _skillBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: theme.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: Colors.white12,
              color: theme.accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer ────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer({
    required this.theme,
    required this.subjectId,
    required this.mode,
    required this.onNotebook,
    this.onSwitchSubject,
    this.onModeChanged,
  });

  final ScienceLabTheme theme;
  final String subjectId;
  final ScienceLabMode mode;
  final VoidCallback onNotebook;
  final ValueChanged<String>? onSwitchSubject;
  final ValueChanged<ScienceLabMode>? onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF080E18),
        border: Border(
          top: BorderSide(color: theme.accent.withValues(alpha: 0.22)),
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
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          const Flexible(
            child: Text(
              'REAL SKILLS. A BRIGHTER FUTURE.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),
          const SizedBox(width: 12),
          _subj('biology', '🔬', 'Biology'),
          _subj('chemistry', '🧪', 'Chemistry'),
          _subj('physics', '⚛️', 'Physics'),
          const SizedBox(width: 10),
          ...ScienceLabMode.values.map(_modeChip),
          IconButton(
            tooltip: 'Lab Notebook',
            onPressed: onNotebook,
            icon: Icon(Icons.menu_book_rounded, color: theme.accent, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _subj(String id, String emoji, String label) {
    final bool on = subjectId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onSwitchSubject == null ? null : () => onSwitchSubject!(id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: on ? theme.accent.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: on ? theme.accent : Colors.white12,
            ),
          ),
          child: Row(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: on ? theme.accent : Colors.white54,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeChip(ScienceLabMode m) {
    final bool on = mode == m;
    final String label = m.name.toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextButton(
        onPressed: onModeChanged == null ? null : () => onModeChanged!(m),
        style: TextButton.styleFrom(
          foregroundColor: on ? theme.accent : Colors.white38,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(0, 32),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.6,
            color: on ? theme.accent : Colors.white38,
          ),
        ),
      ),
    );
  }
}

// ─── Narrow / mobile ───────────────────────────────────────────────────────

class _NarrowBody extends StatelessWidget {
  const _NarrowBody({
    required this.theme,
    required this.stations,
    required this.selected,
    required this.completed,
    required this.onSelect,
    required this.onContinue,
    required this.workspace,
    required this.progress,
    required this.doneCount,
    required this.total,
    required this.skillLabels,
    required this.xp,
    required this.badges,
    required this.badgeIds,
  });

  final ScienceLabTheme theme;
  final List<ScienceHubStation> stations;
  final ScienceHubStation selected;
  final Set<String> completed;
  final ValueChanged<String> onSelect;
  final VoidCallback onContinue;
  final Widget workspace;
  final double progress;
  final int doneCount;
  final int total;
  final List<String> skillLabels;
  final int xp;
  final Set<String> badges;
  final List<String> badgeIds;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            itemCount: stations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (BuildContext context, int i) {
              final ScienceHubStation s = stations[i];
              final bool sel = s.id == selected.id;
              return ChoiceChip(
                label: Text('${s.icon} ${s.title}'),
                selected: sel,
                onSelected: (_) => onSelect(s.id),
                selectedColor: theme.accent,
                labelStyle: TextStyle(
                  color: sel ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
                backgroundColor: const Color(0xFF151C2C),
              );
            },
          ),
        ),
        Expanded(
          child: _CenterStage(
            theme: theme,
            title: selected.title,
            child: workspace,
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: <Widget>[
              _CurrentExperimentCard(
                theme: theme,
                station: selected,
                done: completed.contains(selected.id),
                onContinue: onContinue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dark embedded station placeholder when a full lab opens fullscreen.
class ScienceStationPreview extends StatelessWidget {
  const ScienceStationPreview({
    super.key,
    required this.theme,
    required this.icon,
    required this.title,
    required this.body,
    required this.onOpen,
  });

  final ScienceLabTheme theme;
  final String icon;
  final String title;
  final String body;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1320),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(icon, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'ENTER STATION',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
