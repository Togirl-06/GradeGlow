import 'package:flutter/material.dart';

import 'science_lab_theme.dart';
import 'science_notebook_screen.dart';
import 'science_notebook_store.dart';

class ScienceStation {
  const ScienceStation({
    required this.id,
    required this.icon,
    required this.title,
    required this.blurb,
    required this.onOpen,
    this.locked = false,
    this.badge,
    this.detail,
  });

  final String id;
  final String icon;
  final String title;
  final String blurb;
  final bool locked;
  final String? badge;

  /// Longer copy for the main stage panel.
  final String? detail;
  final VoidCallback onOpen;
}

/// Home layout: left stations | right current experiment stage (never empty).
class ScienceLabHomeShell extends StatefulWidget {
  const ScienceLabHomeShell({
    super.key,
    required this.theme,
    required this.subjectId,
    required this.stations,
    required this.currentTitle,
    required this.currentBrief,
    required this.onStartCurrent,
    this.stationsBuilder,
    this.notebook,
    this.initialStationId,
    this.onStationHighlight,
  });

  final ScienceLabTheme theme;
  final String subjectId;
  final List<ScienceStation> stations;
  final String currentTitle;
  final String currentBrief;
  final VoidCallback onStartCurrent;
  final List<ScienceStation> Function()? stationsBuilder;
  final ScienceNotebookStore? notebook;
  final String? initialStationId;

  /// Fired when user highlights a station (does not open yet).
  final ValueChanged<String>? onStationHighlight;

  @override
  State<ScienceLabHomeShell> createState() => _ScienceLabHomeShellState();
}

class _ScienceLabHomeShellState extends State<ScienceLabHomeShell> {
  late ScienceNotebookStore _store;
  bool _ready = false;
  String? _selectedStationId;

  ScienceLabTheme get t => widget.theme;

  List<ScienceStation> get _stations =>
      widget.stationsBuilder?.call() ?? widget.stations;

  @override
  void initState() {
    super.initState();
    _selectedStationId = widget.initialStationId;
    _store = widget.notebook ?? ScienceNotebookStore(widget.subjectId);
    _boot();
  }

  @override
  void didUpdateWidget(covariant ScienceLabHomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subjectId != widget.subjectId ||
        oldWidget.notebook != widget.notebook) {
      _store = widget.notebook ?? ScienceNotebookStore(widget.subjectId);
      _ready = false;
      _boot();
    }
    if (widget.initialStationId != null &&
        widget.initialStationId != oldWidget.initialStationId) {
      _selectedStationId = widget.initialStationId;
    }
  }

  Future<void> _boot() async {
    await _store.ensureLoaded();
    if (!mounted) return;
    setState(() {
      _ready = true;
      _selectedStationId ??=
          widget.initialStationId ??
          (_stations.isEmpty ? null : _stations.first.id);
    });
  }

  Future<void> _openNotebook() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScienceNotebookScreen(theme: t, store: _store),
      ),
    );
    if (mounted) setState(() {});
  }

  ScienceStation? _stationById(String? id) {
    if (id == null) return null;
    for (final ScienceStation s in _stations) {
      if (s.id == id) return s;
    }
    return null;
  }

  void _highlight(ScienceStation s) {
    if (s.locked) return;
    setState(() => _selectedStationId = s.id);
    widget.onStationHighlight?.call(s.id);
  }

  void _startSelected() {
    final ScienceStation? s = _stationById(_selectedStationId);
    if (s == null || s.locked) {
      widget.onStartCurrent();
      return;
    }
    s.onOpen();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: t.bg,
        body: Center(child: CircularProgressIndicator(color: t.accent)),
      );
    }

    final List<ScienceStation> stations = _stations;
    final ScienceStation? selected =
        _stationById(_selectedStationId) ??
        (stations.isEmpty ? null : stations.first);

    final String stageTitle =
        selected?.title ?? widget.currentTitle;
    final String stageBrief =
        selected?.detail ?? selected?.blurb ?? widget.currentBrief;
    final String stageIcon = selected?.icon ?? t.emoji;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _TopBar(
              theme: t,
              xp: _store.xp,
              coins: _store.labCoins,
              onBack: () => Navigator.of(context).maybePop(),
              onOpenNotebook: _openNotebook,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  final bool narrow = c.maxWidth < 700;
                  final Widget nav = _StationNav(
                    theme: t,
                    stations: stations,
                    selectedId: selected?.id,
                    onSelect: _highlight,
                  );
                  final Widget stage = _CurrentPanel(
                    theme: t,
                    icon: stageIcon,
                    title: stageTitle,
                    brief: stageBrief,
                    xp: _store.xp,
                    coins: _store.labCoins,
                    completedHint: selected?.badge,
                    onStart: _startSelected,
                  );
                  if (narrow) {
                    return Column(
                      children: <Widget>[
                        SizedBox(height: 168, child: nav),
                        Expanded(child: stage),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(width: 232, child: nav),
                      Expanded(child: stage),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.theme,
    required this.xp,
    required this.coins,
    required this.onBack,
    required this.onOpenNotebook,
  });

  final ScienceLabTheme theme;
  final int xp;
  final int coins;
  final VoidCallback onBack;
  final VoidCallback onOpenNotebook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.accent.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
          ),
          Text(theme.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              theme.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.accent,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _HudChip(label: 'XP', value: '$xp', color: theme.accent),
          const SizedBox(width: 8),
          _HudChip(label: '🪙', value: '$coins', color: const Color(0xFFFBBF24)),
          IconButton(
            tooltip: 'Open notebook',
            onPressed: onOpenNotebook,
            icon: Icon(Icons.menu_book_rounded, color: theme.accent),
          ),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StationNav extends StatelessWidget {
  const _StationNav({
    required this.theme,
    required this.stations,
    required this.onSelect,
    this.selectedId,
  });

  final ScienceLabTheme theme;
  final List<ScienceStation> stations;
  final String? selectedId;
  final ValueChanged<ScienceStation> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          right: BorderSide(color: theme.accent.withValues(alpha: 0.22)),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        itemCount: stations.length,
        itemBuilder: (BuildContext context, int i) {
          final ScienceStation s = stations[i];
          final bool sel = s.id == selectedId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: s.locked ? null : () => onSelect(s),
                borderRadius: BorderRadius.circular(12),
                child: Opacity(
                  opacity: s.locked ? 0.45 : 1,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel
                          ? theme.accent.withValues(alpha: 0.16)
                          : Colors.black.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel
                            ? theme.accent
                            : theme.accent.withValues(alpha: 0.22),
                        width: sel ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(s.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.title,
                                style: TextStyle(
                                  color: theme.accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (s.locked)
                              const Icon(Icons.lock, size: 14, color: Colors.white38),
                            if (s.badge != null && !s.locked)
                              Text(s.badge!, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.blurb,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CurrentPanel extends StatelessWidget {
  const _CurrentPanel({
    required this.theme,
    required this.icon,
    required this.title,
    required this.brief,
    required this.xp,
    required this.coins,
    required this.onStart,
    this.completedHint,
  });

  final ScienceLabTheme theme;
  final String icon;
  final String title;
  final String brief;
  final int xp;
  final int coins;
  final String? completedHint;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    // SizedBox.expand forces a non-zero stage — DecoratedBox alone can collapse.
    return ColoredBox(
      color: theme.bg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.accent.withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'CURRENT EXPERIMENT',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(icon, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        brief,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (completedHint != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      'Status: $completedHint',
                      style: TextStyle(
                        color: theme.accent.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: onStart,
                      child: const Text(
                        'START',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
