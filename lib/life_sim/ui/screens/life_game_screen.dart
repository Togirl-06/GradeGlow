import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../avatar/avatar_profile.dart';
import '../../game/life_game.dart';
import '../../services/life_save_service.dart';
import '../../world/city_map.dart';
import '../../world/interiors.dart';
import '../../world/world_model.dart';
import '../life_session.dart';
import '../life_widgets.dart';
import '../painters/avatar_painter.dart';
import '../painters/city_painter.dart';
import '../painters/interior_painter.dart';
import 'avatar_editor.dart';
import 'interactions.dart';
import 'phone_screen.dart';
import 'status_screens.dart';

/// Entry point: loads the cloud/local save or shows the character creator.
class LifeGameLauncher extends StatefulWidget {
  const LifeGameLauncher({super.key});
  @override
  State<LifeGameLauncher> createState() => _LifeGameLauncherState();
}

class _LifeGameLauncherState extends State<LifeGameLauncher> {
  LifeSession? session;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    LifeGame? g;
    try {
      g = await const LifeSaveService().load();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      session = g == null ? null : LifeSession(g);
      loading = false;
    });
  }

  @override
  void dispose() {
    session?.dispose();
    super.dispose();
  }

  void _start(AvatarProfile p) {
    final LifeSession s = LifeSession(LifeGame.newGame(p));
    s.changed();
    setState(() => session = s);
  }

  Future<void> _reset() async {
    await const LifeSaveService().delete();
    session?.dispose();
    setState(() => session = null);
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: lifeTheme(),
        child: loading
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : session == null
                ? CharacterCreatorScreen(onStart: _start)
                : LifeGameScreen(life: session!, onNewGame: _reset),
      );
}

/// The game world: city or interior, HUD and controls.
class LifeGameScreen extends StatefulWidget {
  const LifeGameScreen({super.key, required this.life, this.onNewGame});
  final LifeSession life;
  final VoidCallback? onNewGame;
  @override
  State<LifeGameScreen> createState() => _LifeGameScreenState();
}

class _LifeGameScreenState extends State<LifeGameScreen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final FocusNode _focus = FocusNode();
  Duration _last = Duration.zero;
  double t = 0;

  // Visual position (tile units) and queued path.
  late double vx;
  late double vy;
  List<(int, int)> queue = <(int, int)>[];
  bool facingRight = true;
  bool walking = false;

  // What to do when the queue empties.
  Building? goalBuilding;
  Interactable? goalItem;
  NpcDef? goalNpc;
  bool goalExit = false;
  bool busy = false;

  static const double stepSeconds = 0.17;
  double _stepT = 0;

  LifeGame get g => widget.life.game;
  LifeSession get life => widget.life;

  @override
  void initState() {
    super.initState();
    _syncVisual();
    _ticker = createTicker(_tick)..start();
    life.addListener(_onLife);
  }

  void _syncVisual() {
    vx = (g.isIndoors ? g.inX : g.cityX).toDouble();
    vy = (g.isIndoors ? g.inY : g.cityY).toDouble();
  }

  void _onLife() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    life.removeListener(_onLife);
    _ticker.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _tick(Duration d) {
    final double dt = _last == Duration.zero ? 0 : (d - _last).inMicroseconds / 1e6;
    _last = d;
    t += dt;
    if (queue.isNotEmpty && !busy) {
      walking = true;
      _stepT += dt;
      final (int, int) next = queue.first;
      final double fx = (g.isIndoors ? g.inX : g.cityX).toDouble();
      final double fy = (g.isIndoors ? g.inY : g.cityY).toDouble();
      final double k = (_stepT / stepSeconds).clamp(0, 1).toDouble();
      vx = fx + (next.$1 - fx) * k;
      vy = fy + (next.$2 - fy) * k;
      if (next.$1 != fx) facingRight = next.$1 > fx;
      if (_stepT >= stepSeconds) {
        _stepT = 0;
        final bool ok = g.isIndoors ? g.stepIndoors(next.$1, next.$2) : g.stepOutdoors(next.$1, next.$2);
        queue.removeAt(0);
        if (!ok) queue.clear();
        _syncVisual();
        if (queue.isEmpty) _arrive();
      }
    } else if (walking && queue.isEmpty) {
      walking = false;
    }
    if (mounted) setState(() {});
  }

  void _stop() {
    queue = <(int, int)>[];
    goalBuilding = null;
    goalItem = null;
    goalNpc = null;
    goalExit = false;
    walking = false;
    _stepT = 0;
    _syncVisual();
  }

  Future<void> _arrive() async {
    walking = false;
    final Building? b = goalBuilding;
    final Interactable? it = goalItem;
    final NpcDef? npc = goalNpc;
    final bool exit = goalExit;
    goalBuilding = null;
    goalItem = null;
    goalNpc = null;
    goalExit = false;
    if (b != null && !g.isIndoors) {
      final ActionResult r = g.enter(b);
      life.report(r);
      _syncVisual();
    } else if (exit && g.isIndoors) {
      life.report(g.leave());
      _syncVisual();
    } else if (it != null) {
      busy = true;
      await Interactions.run(context, life, it, openMap: _openMap);
      busy = false;
    } else if (npc != null) {
      busy = true;
      await Interactions.talk(context, life, npc);
      busy = false;
    }
    life.changed();
  }

  // ---- Input ----------------------------------------------------------

  void _goTo(int x, int y) {
    final List<(int, int)> p = g.isIndoors
        ? bfs(Interiors.of(g.buildingId!).width, Interiors.of(g.buildingId!).height, g.inX, g.inY, x, y, (int a, int b) => !Interiors.of(g.buildingId!).blocked(a, b))
        : CityMap.instance.path(g.cityX, g.cityY, x, y);
    if (p.length < 2) return;
    queue = p.sublist(1);
    _stepT = 0;
  }

  /// Walks next to a blocked tile (item / npc) using the nearest free neighbour.
  bool _goNextTo(int x, int y) {
    final Interior it = Interiors.of(g.buildingId!);
    List<(int, int)>? best;
    for (final (int, int) d in const <(int, int)>[(0, 1), (1, 0), (-1, 0), (0, -1)]) {
      final int nx = x + d.$1;
      final int ny = y + d.$2;
      if (it.blocked(nx, ny)) continue;
      final List<(int, int)> p = bfs(it.width, it.height, g.inX, g.inY, nx, ny, (int a, int b) => !it.blocked(a, b));
      if (p.isNotEmpty && (best == null || p.length < best.length)) best = p;
    }
    if (best == null) return false;
    queue = best.length > 1 ? best.sublist(1) : <(int, int)>[];
    _stepT = 0;
    if (queue.isEmpty) _arrive();
    return true;
  }

  void _onTap(TapUpDetails d, Size size) {
    if (busy) return;
    _focus.requestFocus();
    _stop();
    if (g.isIndoors) {
      final Interior it = Interiors.of(g.buildingId!);
      final InteriorHit h = InteriorPainter.pick(d.localPosition, size, it);
      if (h.exit) {
        goalExit = true;
        _goTo(it.exitX, it.exitY);
        if (queue.isEmpty) _arrive();
      } else if (h.item != null) {
        goalItem = h.item;
        if (!_goNextTo(h.item!.x, h.item!.y)) {
          goalItem = null;
          life.say("You can't reach that.");
        }
      } else if (h.npc != null) {
        goalNpc = h.npc;
        if (!_goNextTo(h.npc!.x, h.npc!.y)) {
          goalNpc = null;
        }
      } else if (!it.blocked(h.tileX, h.tileY)) {
        _goTo(h.tileX, h.tileY);
      }
    } else {
      final Size s = size;
      final CityHit h = CityPainter.pick(d.localPosition, s, vx, vy, _zoom);
      if (h.building != null) {
        final Building b = h.building!;
        final String? err = g.canEnter(b);
        if (err != null) {
          life.say(err);
          return;
        }
        goalBuilding = b;
        _goTo(b.doorX, b.doorY);
        if (queue.isEmpty) _arrive();
      } else {
        _goTo(h.tileX, h.tileY);
      }
    }
  }

  double get _zoom => 1.0;

  KeyEventResult _onKey(FocusNode n, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (busy) return KeyEventResult.ignored;
    final LogicalKeyboardKey k = e.logicalKey;
    // Iso axes: screen-right = +x -y ... map arrows to screen directions.
    int dx = 0, dy = 0;
    if (k == LogicalKeyboardKey.arrowUp || k == LogicalKeyboardKey.keyW) {
      dy = -1;
    } else if (k == LogicalKeyboardKey.arrowDown || k == LogicalKeyboardKey.keyS) {
      dy = 1;
    } else if (k == LogicalKeyboardKey.arrowLeft || k == LogicalKeyboardKey.keyA) {
      dx = -1;
    } else if (k == LogicalKeyboardKey.arrowRight || k == LogicalKeyboardKey.keyD) {
      dx = 1;
    } else if (k == LogicalKeyboardKey.keyE || k == LogicalKeyboardKey.space) {
      _interactNearest();
      return KeyEventResult.handled;
    } else if (k == LogicalKeyboardKey.keyP) {
      _openPhone();
      return KeyEventResult.handled;
    } else if (k == LogicalKeyboardKey.keyM) {
      _openMap();
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
    if (queue.isNotEmpty) return KeyEventResult.handled;
    final int nx = (g.isIndoors ? g.inX : g.cityX) + dx;
    final int ny = (g.isIndoors ? g.inY : g.cityY) + dy;
    if (g.isIndoors) {
      final Interior it = Interiors.of(g.buildingId!);
      if (!it.blocked(nx, ny)) {
        queue = <(int, int)>[(nx, ny)];
        _stepT = 0;
      }
    } else if (CityMap.instance.walkable(nx, ny)) {
      queue = <(int, int)>[(nx, ny)];
      _stepT = 0;
    } else {
      // Bumping a door tile line: try entering the building we face.
      final Building? b = _buildingNear();
      if (b != null) _enterBuilding(b);
    }
    return KeyEventResult.handled;
  }

  Building? _buildingNear() {
    for (final Building b in CityMap.instance.buildings) {
      if ((b.doorX - g.cityX).abs() + (b.doorY - g.cityY).abs() <= 1) return b;
    }
    return null;
  }

  void _enterBuilding(Building b) {
    final String? err = g.canEnter(b);
    if (err != null) {
      life.say(err);
      return;
    }
    if ((b.doorX - g.cityX).abs() + (b.doorY - g.cityY).abs() > 1) {
      goalBuilding = b;
      _goTo(b.doorX, b.doorY);
      return;
    }
    life.report(g.enter(b));
    _syncVisual();
  }

  Interactable? _nearItem() {
    if (!g.isIndoors) return null;
    final Interior it = Interiors.of(g.buildingId!);
    Interactable? best;
    double bd = 2.2;
    for (final Interactable i in it.interactables) {
      final double d = ((i.x - vx).abs() + (i.y - vy).abs());
      if (d < bd) {
        bd = d;
        best = i;
      }
    }
    return best;
  }

  NpcDef? _nearNpc() {
    if (!g.isIndoors) return null;
    for (final NpcDef n in Interiors.of(g.buildingId!).npcs) {
      if ((n.x - vx).abs() + (n.y - vy).abs() <= 1.6) return n;
    }
    return null;
  }

  Future<void> _interactNearest() async {
    if (busy) return;
    if (!g.isIndoors) {
      final Building? b = _buildingNear();
      if (b != null) _enterBuilding(b);
      return;
    }
    final Interactable? i = _nearItem();
    if (i != null) {
      busy = true;
      await Interactions.run(context, life, i, openMap: _openMap);
      busy = false;
      return;
    }
    final NpcDef? n = _nearNpc();
    if (n != null) {
      busy = true;
      await Interactions.talk(context, life, n);
      busy = false;
      return;
    }
    if ((vx - Interiors.exitX).abs() + (vy - Interiors.exitY).abs() <= 1.2) {
      life.report(g.leave());
      _syncVisual();
    } else {
      life.say('Nothing to interact with here.');
    }
  }

  Future<void> _openPhone() async {
    _stop();
    busy = true;
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PhoneScreen(life: life, onOpenMap: _openMap)));
    busy = false;
  }

  Future<void> _openStatus() async {
    _stop();
    busy = true;
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => Theme(data: lifeTheme(), child: StatusScreen(life: life))));
    busy = false;
  }

  Future<void> _openMap() async {
    if (!mounted) return;
    _stop();
    busy = true;
    final String? id = await Navigator.of(context).push<String>(MaterialPageRoute<String>(builder: (_) => Theme(data: lifeTheme(), child: CityMapScreen(life: life))));
    busy = false;
    if (id == null) return;
    if (g.isIndoors) {
      life.say('Leave the building first, then use the map.');
      return;
    }
    final Building? b = CityMap.instance.buildingById(id);
    if (b == null) return;
    final String? err = g.canEnter(b);
    if (err != null) {
      life.say('${b.name}: $err');
    }
    final int steps = g.pathToBuilding(id).length - 1;
    goalBuilding = err == null ? b : null;
    _goTo(b.doorX, b.doorY);
    if (steps > 40 && queue.isNotEmpty) {
      // Long trip: fast-travel and pay the walking time.
      queue = <(int, int)>[];
      life.report(g.travelTo(id));
      _syncVisual();
      if (err == null) life.report(g.enter(b));
      _syncVisual();
      goalBuilding = null;
    }
  }

  // ---- Build ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final double daylight = g.clock.daylight;
    final AvatarAction action = life.activity ?? (walking ? AvatarAction.walk : AvatarAction.idle);
    final AvatarLook look = AvatarLook.fromProfile(g.avatar);
    final Interactable? near = _nearItem();
    final NpcDef? nearNpc = _nearNpc();
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        body: Stack(children: <Widget>[
          Positioned.fill(
            child: LayoutBuilder(
              builder: (BuildContext c, BoxConstraints box) {
                final Size size = Size(box.maxWidth, box.maxHeight);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (TapUpDetails d) => _onTap(d, size),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: size,
                      painter: g.isIndoors
                          ? InteriorPainter(
                              interior: Interiors.of(g.buildingId!),
                              playerX: vx,
                              playerY: vy,
                              look: look,
                              action: action,
                              emotion: life.emotion,
                              facingRight: facingRight,
                              t: t,
                              daylight: daylight,
                              path: queue,
                              nearItemId: near?.id,
                              talkingNpcId: nearNpc?.id,
                              accent: g.currentBuilding == null ? null : Color(g.currentBuilding!.color),
                              roomName: g.currentBuilding?.name ?? '',
                            )
                          : CityPainter(
                              playerX: vx,
                              playerY: vy,
                              look: look,
                              action: action,
                              emotion: life.emotion,
                              facingRight: facingRight,
                              t: t,
                              daylight: daylight,
                              camX: vx,
                              camY: vy,
                              zoom: _zoom,
                              path: queue,
                              highlightBuildingId: goalBuilding?.id,
                              openCheck: (Building b) => b.isOpen(g.day, g.minute),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(child: _hud(near, nearNpc)),
        ]),
      ),
    );
  }

  Widget _hud(Interactable? near, NpcDef? nearNpc) {
    final bool unread = g.inbox.unreadCount > 0;
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          IconButton(
            tooltip: 'Back to University Labs',
            onPressed: () async {
              await life.saveNow();
              if (mounted) Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _openStatus,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: LifeColors.panel.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(14), border: Border.all(color: LifeColors.line)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Row(children: <Widget>[
                    Text(clockLabel(g.minute), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(width: 8),
                    Text('Day ${g.day}', style: const TextStyle(color: LifeColors.muted, fontSize: 12)),
                    const Spacer(),
                    Text(money(g.economy.cash), style: const TextStyle(color: LifeColors.green, fontWeight: FontWeight.w900)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: <Widget>[
                    _mini('⚡', g.needs.energy),
                    _mini('🍽️', g.needs.hunger),
                    _mini('😊', g.needs.happiness),
                    _mini('❤️', g.needs.health),
                    _mini('👥', g.needs.social),
                  ]),
                  Text(g.statusLine, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: LifeColors.muted, fontSize: 11)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Column(children: <Widget>[
            _roundBtn(Icons.smartphone_rounded, _openPhone, badge: unread),
            const SizedBox(height: 6),
            _roundBtn(Icons.map_rounded, _openMap),
            const SizedBox(height: 6),
            _roundBtn(Icons.more_horiz_rounded, _menu),
          ]),
        ]),
      ),
      const Spacer(),
      if (life.toast != null)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: LifeColors.panel2.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(14), border: Border.all(color: LifeColors.blue)),
          child: Text(life.toast!, textAlign: TextAlign.center),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(children: <Widget>[
          if (g.isIndoors)
            _action('🚪 Exit', () {
              _stop();
              goalExit = true;
              _goTo(Interiors.exitX, Interiors.exitY);
              if (queue.isEmpty) _arrive();
            }),
          const SizedBox(width: 8),
          if (near != null) Expanded(child: _action('${near.emoji} ${near.name}', _interactNearest, strong: true, sub: near.hint))
          else if (nearNpc != null) Expanded(child: _action('💬 Talk to ${nearNpc.name}', _interactNearest, strong: true, sub: nearNpc.role))
          else if (!g.isIndoors && _buildingNear() != null) Expanded(child: _action('${_buildingNear()!.emoji} Enter ${_buildingNear()!.name}', _interactNearest, strong: true))
          else const Spacer(),
        ]),
      ),
    ]);
  }

  Widget _mini(String e, double v) => Expanded(
        child: Row(children: <Widget>[
          Text(e, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 2),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: (v / 100).clamp(0, 1), minHeight: 5, color: v < 25 ? LifeColors.red : (v < 50 ? LifeColors.amber : LifeColors.green), backgroundColor: LifeColors.line),
            ),
          ),
          const SizedBox(width: 5),
        ]),
      );

  Widget _roundBtn(IconData i, VoidCallback f, {bool badge = false}) => Stack(clipBehavior: Clip.none, children: <Widget>[
        Material(
          color: LifeColors.panel.withValues(alpha: 0.92),
          shape: const CircleBorder(side: BorderSide(color: LifeColors.line)),
          child: InkWell(customBorder: const CircleBorder(), onTap: f, child: Padding(padding: const EdgeInsets.all(10), child: Icon(i, size: 22))),
        ),
        if (badge) const Positioned(right: 0, top: 0, child: CircleAvatar(radius: 5, backgroundColor: LifeColors.red)),
      ]);

  Widget _action(String label, VoidCallback f, {bool strong = false, String? sub}) => Material(
        color: strong ? LifeColors.blue : LifeColors.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: f,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
              if (sub != null && sub.isNotEmpty) Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: Colors.white70)),
            ]),
          ),
        ),
      );

  Future<void> _menu() async {
    final String? v = await showLifeSheet<String>(
      context,
      full: false,
      builder: (BuildContext c) => Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(leading: const Icon(Icons.save_rounded), title: const Text('Save now'), onTap: () => Navigator.pop(c, 'save')),
        ListTile(leading: const Icon(Icons.person_rounded), title: const Text('My status'), onTap: () => Navigator.pop(c, 'status')),
        ListTile(leading: const Icon(Icons.help_outline_rounded), title: const Text('Controls & about'), onTap: () => Navigator.pop(c, 'help')),
        ListTile(leading: const Icon(Icons.restart_alt_rounded, color: LifeColors.red), title: const Text('Start a new life (erases save)'), onTap: () => Navigator.pop(c, 'reset')),
      ]),
    );
    if (!mounted) return;
    switch (v) {
      case 'save':
        await life.saveNow();
        life.say('Game saved.');
      case 'status':
        _openStatus();
      case 'help':
        await showDialog<void>(
          context: context,
          builder: (BuildContext c) => AlertDialog(
            title: const Text('Controls'),
            content: const Text(
              'Tap the ground to walk, tap a building to enter, tap objects and people to use them. '
              'Keyboard: arrows/WASD move, E interact, P phone, M map.\n\n'
              'Medical and legal scenarios are an educational simulation set in the fictional country of Glowland — not real medical or legal advice. '
              'Money, time and progress are rule-based; AI only writes dialogue and feedback.',
            ),
            actions: <Widget>[TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
          ),
        );
      case 'reset':
        final bool? yes = await showDialog<bool>(
          context: context,
          builder: (BuildContext c) => AlertDialog(
            title: const Text('Start a new life?'),
            content: const Text('This deletes your current save.'),
            actions: <Widget>[TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Erase'))],
          ),
        );
        if (yes == true) widget.onNewGame?.call();
    }
  }
}
