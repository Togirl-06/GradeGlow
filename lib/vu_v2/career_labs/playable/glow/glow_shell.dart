import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'glow_models.dart';
import 'glow_progress.dart';
import 'glow_widgets.dart';

/// Level map + HUD for any [GlowLab].
class GlowLabScreen extends StatefulWidget {
  const GlowLabScreen({super.key, required this.lab});

  final GlowLab lab;

  @override
  State<GlowLabScreen> createState() => _GlowLabScreenState();
}

class _GlowLabScreenState extends State<GlowLabScreen> {
  late final GlowProgress _progress = GlowProgress(widget.lab.id);
  Map<String, int> _stars = <String, int>{};
  int _xp = 0;
  int _streak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final Map<String, int> stars = await _progress.loadStars(
      widget.lab.levels.map((GlowLevel l) => l.id),
    );
    final int xp = await _progress.getXp();
    final int streak = await _progress.getStreak();
    if (!mounted) return;
    setState(() {
      _stars = stars;
      _xp = xp;
      _streak = streak;
      _loading = false;
    });
  }

  bool _unlocked(int index) {
    if (index == 0) return true;
    return (_stars[widget.lab.levels[index - 1].id] ?? 0) >= 1;
  }

  int get _rankIndex =>
      math.min(_xp ~/ 100, widget.lab.rankTitles.length - 1);

  bool get _maxRank => _rankIndex >= widget.lab.rankTitles.length - 1;

  Future<void> _play(int index) async {
    final GlowLevel level = widget.lab.levels[index];
    if (!_unlocked(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Earn at least 1 star on the previous level first.'),
        ),
      );
      return;
    }
    final GlowLevelResult? result = await Navigator.of(context)
        .push<GlowLevelResult>(
      MaterialPageRoute<GlowLevelResult>(
        builder: (_) => GlowLevelPlayer(lab: widget.lab, level: level),
      ),
    );
    if (result == null || !mounted) return;
    final int old = _stars[level.id] ?? 0;
    if (result.stars > old) {
      final int gain = (((result.stars - old) * level.xp) / 3).round();
      await _progress.saveStars(level.id, result.stars);
      await _progress.addXp(gain);
    }
    await _progress.touchStreak();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final GlowLab lab = widget.lab;
    return Scaffold(
      backgroundColor: GlowColors.bg,
      appBar: AppBar(
        backgroundColor: GlowColors.bg,
        foregroundColor: GlowColors.ink,
        elevation: 0,
        title: Text('${lab.emoji}  ${lab.title}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: <Widget>[
                _buildHud(lab),
                const SizedBox(height: 18),
                for (int i = 0; i < lab.levels.length; i++) ...<Widget>[
                  _buildLevelTile(lab, i),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }

  Widget _buildHud(GlowLab lab) {
    final double rankFraction = _maxRank ? 1.0 : (_xp % 100) / 100.0;
    return GlowPanel(
      accent: lab.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      lab.subtitle,
                      style: const TextStyle(
                        color: GlowColors.mute,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lab.rankTitles[_rankIndex],
                      style: const TextStyle(
                        color: GlowColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: GlowColors.surfaceHi,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🔥 $_streak day${_streak == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: GlowColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlowMeter(
            label: _maxRank
                ? 'Max rank reached'
                : 'Next: ${lab.rankTitles[_rankIndex + 1]}',
            valueText: '$_xp XP',
            fraction: rankFraction,
            color: lab.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTile(GlowLab lab, int index) {
    final GlowLevel level = lab.levels[index];
    final bool unlocked = _unlocked(index);
    final int stars = _stars[level.id] ?? 0;
    final Color border = level.isBoss ? GlowColors.gold : lab.accent;
    return Opacity(
      opacity: unlocked ? 1 : 0.45,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _play(index),
        child: GlowPanel(
          accent: unlocked ? border : null,
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: GlowColors.surfaceHi,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(level.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            'Level ${index + 1} · ${level.title}',
                            style: const TextStyle(
                              color: GlowColors.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (level.isBoss) ...<Widget>[
                          const SizedBox(width: 8),
                          const Text(
                            'BOSS',
                            style: TextStyle(
                              color: GlowColors.gold,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      level.tagline,
                      style: const TextStyle(
                        color: GlowColors.mute,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              unlocked
                  ? GlowStars(stars: stars, size: 20)
                  : const Icon(Icons.lock_rounded, color: GlowColors.mute),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hosts one level: app bar, retry support and the result card.
class GlowLevelPlayer extends StatefulWidget {
  const GlowLevelPlayer({super.key, required this.lab, required this.level});

  final GlowLab lab;
  final GlowLevel level;

  @override
  State<GlowLevelPlayer> createState() => _GlowLevelPlayerState();
}

class _GlowLevelPlayerState extends State<GlowLevelPlayer> {
  int _attempt = 0;
  bool _finished = false;

  Future<void> _onFinish(GlowLevelResult result) async {
    if (_finished) return;
    _finished = true;
    final bool? tryAgain = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => _ResultDialog(
        accent: widget.lab.accent,
        level: widget.level,
        result: result,
      ),
    );
    if (!mounted) return;
    if (tryAgain == true) {
      setState(() {
        _attempt += 1;
        _finished = false;
      });
      return;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlowColors.bg,
      appBar: AppBar(
        backgroundColor: GlowColors.bg,
        foregroundColor: GlowColors.ink,
        elevation: 0,
        title: Text('${widget.level.emoji}  ${widget.level.title}'),
      ),
      body: SafeArea(
        child: KeyedSubtree(
          key: ValueKey<int>(_attempt),
          child: widget.level.builder(context, _onFinish),
        ),
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({
    required this.accent,
    required this.level,
    required this.result,
  });

  final Color accent;
  final GlowLevel level;
  final GlowLevelResult result;

  @override
  Widget build(BuildContext context) {
    final bool passed = result.passed;
    final int xp = ((result.stars * level.xp) / 3).round();
    return AlertDialog(
      backgroundColor: GlowColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Column(
        children: <Widget>[
          Text(
            passed ? 'Level cleared!' : 'Not quite yet',
            style: const TextStyle(
              color: GlowColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          GlowStars(stars: result.stars, size: 34),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Score ${result.score}/100${passed ? '  ·  up to +$xp XP' : ''}',
            style: TextStyle(color: accent, fontWeight: FontWeight.w700),
          ),
          if (result.note.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              result.note,
              textAlign: TextAlign.center,
              style: const TextStyle(color: GlowColors.mute, height: 1.35),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Retry'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: accent),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(passed ? 'Continue' : 'Back to map'),
        ),
      ],
    );
  }
}
