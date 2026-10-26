import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'anatomy_iframe_stub.dart'
    if (dart.library.html) 'anatomy_iframe_web.dart' as anatomy_iframe;
import 'health_career_progress.dart';
import 'health_career_theme.dart';
import 'models/anatomy_structure.dart';
import 'models/asset_registry.dart';

/// Anatomy laboratory — real photographic organ plates by default.
/// Optional Three.js schematic remains available as a secondary mode on web.
class AnatomyViewerScreen extends StatefulWidget {
  const AnatomyViewerScreen({super.key, required this.progress});

  final HealthCareerProgress progress;

  @override
  State<AnatomyViewerScreen> createState() => _AnatomyViewerScreenState();
}

class _AnatomyViewerScreenState extends State<AnatomyViewerScreen> {
  AnatomyStructure? _selected;
  String _system = 'All';
  double _yaw = 0.12;
  double _zoom = 1.0;
  String _assetKey = 'body';
  /// Animated schematic 3D is opt-in only — real organs are the default.
  bool _preferSchematic3d = false;
  static const String _viewType = 'gradeglow-anatomy-threejs';

  bool get _useThreeJs =>
      kIsWeb &&
      anatomy_iframe.anatomyThreeJsSupported &&
      _preferSchematic3d;

  List<AnatomyStructure> get _filtered {
    if (_system == 'All') return AnatomyCatalog.structures;
    return AnatomyCatalog.structures
        .where((AnatomyStructure s) => s.system == _system)
        .toList();
  }

  /// Hotspots only make sense on the body overview plate.
  List<AnatomyStructure> get _hotspotStructures {
    if (_assetKey != 'body') return const <AnatomyStructure>[];
    return _filtered;
  }

  Future<void> _select(AnatomyStructure s) async {
    setState(() {
      _selected = s;
      _assetKey = s.assetKey;
      _preferSchematic3d = false;
      _yaw = 0.12;
      _zoom = 1.0;
    });
    await widget.progress.markStructure(s.id);
  }

  Future<void> _selectFromThreeJs(Map<String, String> msg) async {
    final String id = msg['id'] ?? '';
    final AnatomyStructure? known = AnatomyCatalog.byId(id);
    if (known != null) {
      await _select(known);
      setState(() => _preferSchematic3d = true);
      return;
    }
    setState(() {
      _selected = AnatomyStructure(
        id: id.isEmpty ? 'custom' : id,
        name: msg['name'] ?? 'Structure',
        system: 'Interactive 3D',
        functionNote: msg['info'] ?? '',
        locationNote: 'Selected in the optional schematic 3D model.',
        educationNotes:
            'Animated schematic for spatial layout only — switch back to '
            'photographic plates for real organ appearance.',
        hotspot: (0, 0, 0, 0),
        assetKey: 'body',
      );
    });
    if (id.isNotEmpty) await widget.progress.markStructure(id);
  }

  void _showBodyOverview() {
    setState(() {
      _assetKey = 'body';
      _selected = null;
      _preferSchematic3d = false;
      _yaw = 0.12;
      _zoom = 1.0;
    });
  }

  void _resetCamera() {
    setState(() {
      _yaw = 0.12;
      _zoom = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final MedAssetEntry asset = MedAssetRegistry.fallbackFor(_assetKey);
    final bool wide = MediaQuery.sizeOf(context).width >= 900;
    final List<String> systems = <String>[
      'All',
      ...AnatomyCatalog.structures.map((AnatomyStructure s) => s.system).toSet(),
    ];

    final Widget viewport = _useThreeJs
        ? Container(
            margin: const EdgeInsets.all(12),
            decoration: MedCosmic.panelBox(radius: 18),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: anatomy_iframe.buildAnatomyThreeJsView(
                    viewType: _viewType,
                    onSelect: (Map<String, String> m) {
                      _selectFromThreeJs(m);
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: MedCosmic.pill(
                    'Schematic 3D · animated (not real organs)',
                    bg: MedCosmic.gold.withValues(alpha: 0.22),
                    fg: MedCosmic.gold,
                  ),
                ),
              ],
            ),
          )
        : _Viewport(
            asset: asset,
            yaw: _yaw,
            zoom: _zoom,
            selected: _selected,
            structures: _hotspotStructures,
            onSelect: _select,
            onYaw: (double d) => setState(() => _yaw = (_yaw + d).clamp(-0.6, 0.6)),
            onZoom: (double z) => setState(() => _zoom = z.clamp(0.75, 1.8)),
            onShowBody: _showBodyOverview,
          );

    final Widget side = _SidePanel(
      selected: _selected,
      systems: systems,
      system: _system,
      onSystem: (String v) => setState(() => _system = v),
      structures: _filtered,
      onSelect: _select,
      identified: widget.progress.identifiedStructures,
      onReset: _resetCamera,
      useThreeJs: _useThreeJs,
      onToggleRenderer: kIsWeb
          ? () => setState(() => _preferSchematic3d = !_preferSchematic3d)
          : null,
      onShowBody: _showBodyOverview,
      assetLabel: asset.label,
    );

    return Scaffold(
      backgroundColor: MedCosmic.bg,
      appBar: MedCosmic.appBar(
        context: context,
        title: 'Explore Human Anatomy',
        icon: Icons.accessibility_new_rounded,
      ),
      body: MedStarfield(
        child: Column(
          children: <Widget>[
            _OrganStrip(
              selectedId: _selected?.id,
              assetKey: _assetKey,
              onSelect: _select,
              onBody: _showBodyOverview,
            ),
            Expanded(
              child: wide
                  ? Row(
                      children: <Widget>[
                        Expanded(flex: 3, child: viewport),
                        SizedBox(width: 320, child: side),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        Expanded(flex: 3, child: viewport),
                        Expanded(flex: 2, child: side),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganStrip extends StatelessWidget {
  const _OrganStrip({
    required this.selectedId,
    required this.assetKey,
    required this.onSelect,
    required this.onBody,
  });

  final String? selectedId;
  final String assetKey;
  final ValueChanged<AnatomyStructure> onSelect;
  final VoidCallback onBody;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _Chip(
              label: 'Full body',
              selected: assetKey == 'body' && selectedId == null,
              onTap: onBody,
            ),
            const SizedBox(width: 6),
            ...AnatomyCatalog.structures.map((AnatomyStructure s) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _Chip(
                  label: s.name,
                  selected: selectedId == s.id,
                  onTap: () => onSelect(s),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? MedCosmic.clinical.withValues(alpha: 0.28)
          : MedCosmic.panelAlt,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? MedCosmic.clinical : Colors.white12,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? MedCosmic.clinical : MedCosmic.ink,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _Viewport extends StatelessWidget {
  const _Viewport({
    required this.asset,
    required this.yaw,
    required this.zoom,
    required this.selected,
    required this.structures,
    required this.onSelect,
    required this.onYaw,
    required this.onZoom,
    required this.onShowBody,
  });

  final MedAssetEntry asset;
  final double yaw;
  final double zoom;
  final AnatomyStructure? selected;
  final List<AnatomyStructure> structures;
  final ValueChanged<AnatomyStructure> onSelect;
  final ValueChanged<double> onYaw;
  final ValueChanged<double> onZoom;
  final VoidCallback onShowBody;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: MedCosmic.panelBox(radius: 18),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: <Widget>[
                MedCosmic.pill(
                  'Real anatomy plate · ${asset.label}',
                  bg: MedCosmic.clinical.withValues(alpha: 0.22),
                  fg: MedCosmic.clinical,
                ),
                const Spacer(),
                if (asset.id != 'body')
                  TextButton(
                    onPressed: onShowBody,
                    child: const Text(
                      'Full body',
                      style: TextStyle(color: MedCosmic.electric, fontSize: 12),
                    ),
                  ),
                IconButton(
                  tooltip: 'Zoom out',
                  onPressed: () => onZoom(zoom - 0.1),
                  icon: const Icon(Icons.remove, color: MedCosmic.mute),
                ),
                IconButton(
                  tooltip: 'Zoom in',
                  onPressed: () => onZoom(zoom + 0.1),
                  icon: const Icon(Icons.add, color: MedCosmic.mute),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (DragUpdateDetails d) {
                onYaw(d.delta.dx * 0.004);
              },
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        ColoredBox(
                          color: const Color(0xFF0A1220),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0012)
                              ..rotateY(yaw)
                              ..scaleByDouble(zoom, zoom, zoom, 1),
                            child: Image.asset(
                              asset.path,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Center(
                                child: Text(
                                  'Anatomy asset failed to load',
                                  style: TextStyle(color: MedCosmic.danger),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ...structures.map((AnatomyStructure s) {
                          final (double l, double t, double w, double h) =
                              s.hotspot;
                          final bool on = selected?.id == s.id;
                          return Positioned(
                            left: c.maxWidth * l,
                            top: c.maxHeight * t,
                            width: c.maxWidth * w,
                            height: c.maxHeight * h,
                            child: GestureDetector(
                              onTap: () => onSelect(s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: on
                                        ? MedCosmic.clinical
                                        : Colors.white24,
                                    width: on ? 2.5 : 1,
                                  ),
                                  color: on
                                      ? MedCosmic.clinical
                                          .withValues(alpha: 0.18)
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          );
                        }),
                        if (selected != null && asset.id != 'body')
                          Positioned(
                            left: 12,
                            bottom: 12,
                            right: 12,
                            child: MedCosmic.pill(
                              selected!.name,
                              bg: Colors.black54,
                              fg: MedCosmic.ink,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Text(
              'Drag to orbit · pinch/zoom controls · photographic educational plate',
              style: TextStyle(
                color: MedCosmic.mute.withValues(alpha: 0.9),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({
    required this.selected,
    required this.systems,
    required this.system,
    required this.onSystem,
    required this.structures,
    required this.onSelect,
    required this.identified,
    required this.onReset,
    required this.useThreeJs,
    required this.onShowBody,
    required this.assetLabel,
    this.onToggleRenderer,
  });

  final AnatomyStructure? selected;
  final List<String> systems;
  final String system;
  final ValueChanged<String> onSystem;
  final List<AnatomyStructure> structures;
  final ValueChanged<AnatomyStructure> onSelect;
  final Set<String> identified;
  final VoidCallback onReset;
  final bool useThreeJs;
  final VoidCallback onShowBody;
  final String assetLabel;
  final VoidCallback? onToggleRenderer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: MedCosmic.panelBox(radius: 18),
      child: ListView(
        children: <Widget>[
          const Text(
            'Organ systems',
            style: TextStyle(
              color: MedCosmic.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: systems.map((String s) {
              final bool on = system == s;
              return ChoiceChip(
                label: Text(s, style: const TextStyle(fontSize: 11)),
                selected: on,
                onSelected: (_) => onSystem(s),
                selectedColor: MedCosmic.purple.withValues(alpha: 0.35),
                labelStyle: const TextStyle(color: MedCosmic.ink),
                backgroundColor: MedCosmic.panelAlt,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.center_focus_strong, size: 16),
            label: const Text('Reset camera'),
            style: OutlinedButton.styleFrom(foregroundColor: MedCosmic.clinical),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: onShowBody,
            icon: const Icon(Icons.accessibility_new, size: 16),
            label: const Text('Full body overview'),
            style: OutlinedButton.styleFrom(foregroundColor: MedCosmic.electric),
          ),
          if (onToggleRenderer != null) ...<Widget>[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onToggleRenderer,
              child: Text(
                useThreeJs
                    ? 'Back to real organ photos'
                    : 'Optional: schematic 3D',
                style: const TextStyle(color: MedCosmic.electric),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            useThreeJs
                ? 'You are viewing an animated schematic (not real organs). Prefer photographic plates for study.'
                : 'Showing real anatomy photographs ($assetLabel). Tap an organ above to open its plate.',
            style: TextStyle(
              color: MedCosmic.mute.withValues(alpha: 0.95),
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (selected == null)
            const Text(
              'Select an organ to open its real anatomy plate.',
              style: TextStyle(color: MedCosmic.mute),
            )
          else ...<Widget>[
            Text(
              selected!.name,
              style: const TextStyle(
                color: MedCosmic.clinical,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            MedCosmic.pill(selected!.system),
            const SizedBox(height: 10),
            _Info('Function', selected!.functionNote),
            _Info('Location', selected!.locationNote),
            _Info('Notes', selected!.educationNotes),
          ],
          const SizedBox(height: 14),
          const Text(
            'Structures',
            style: TextStyle(
              color: MedCosmic.mute,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          ...structures.map((AnatomyStructure s) {
            final bool done = identified.contains(s.id);
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              onTap: () => onSelect(s),
              title: Text(
                s.name,
                style: const TextStyle(
                  color: MedCosmic.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: Icon(
                done ? Icons.check_circle : Icons.circle_outlined,
                color: done ? MedCosmic.success : MedCosmic.mute,
                size: 18,
              ),
            );
          }),
          Text(
            'Mastery ${identified.length}/${AnatomyCatalog.structures.length}',
            style: const TextStyle(color: MedCosmic.mute, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.body);
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: MedCosmic.gold,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          Text(
            body,
            style: const TextStyle(color: MedCosmic.mute, height: 1.35),
          ),
        ],
      ),
    );
  }
}
