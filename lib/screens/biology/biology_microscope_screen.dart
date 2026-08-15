import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/biology_degree.dart';
import '../../theme/biology_degree_theme.dart';

class _SlideSpec {
  const _SlideSpec({
    required this.name,
    required this.asset,
    required this.notes,
    required this.hiddenLabels,
  });

  final String name;
  final String asset;
  final String notes;
  final List<String> hiddenLabels;
}

/// Virtual microscope — objective lenses, focus, stain, compare, capture.
class BiologyMicroscopeScreen extends StatefulWidget {
  const BiologyMicroscopeScreen({super.key, required this.path});

  final BiologyLessonPath path;

  @override
  State<BiologyMicroscopeScreen> createState() => _BiologyMicroscopeScreenState();
}

class _BiologyMicroscopeScreenState extends State<BiologyMicroscopeScreen> {
  int _slideIndex = 0;
  int? _compareIndex;
  double _focus = 0.55;
  int _mag = 40;
  bool _stained = false;
  bool _revealLabels = false;
  bool _compare = false;
  String? _captured;
  String? _aiLine;

  static const List<int> _mags = <int>[4, 10, 40, 100];

  static const List<_SlideSpec> _slides = <_SlideSpec>[
    _SlideSpec(
      name: 'Animal cell',
      asset: 'assets/biology/animal_cell.svg',
      notes: 'Identify membrane-bound organelles before revealing labels.',
      hiddenLabels: <String>['Nucleus', 'Mitochondria', 'Cytoplasm', 'Membrane'],
    ),
    _SlideSpec(
      name: 'Plant tissue',
      asset: 'assets/biology/plant_cell.svg',
      notes: 'Look for wall, chloroplasts, and large vacuole.',
      hiddenLabels: <String>['Cell wall', 'Chloroplast', 'Vacuole', 'Nucleus'],
    ),
    _SlideSpec(
      name: 'Bacteria',
      asset: 'assets/biology/bacteria.svg',
      notes: 'Prokaryotic morphology — no nucleus.',
      hiddenLabels: <String>['Cell wall', 'Nucleoid', 'Flagellum', 'Capsule'],
    ),
    _SlideSpec(
      name: 'Blood field',
      asset: 'assets/anatomy/organs.svg',
      notes: 'Compare cell density and staining contrast.',
      hiddenLabels: <String>['Erythrocyte', 'Leukocyte', 'Plasma'],
    ),
    _SlideSpec(
      name: 'Neuron',
      asset: 'assets/anatomy/neuron.svg',
      notes: 'Trace soma, axon, and dendrites.',
      hiddenLabels: <String>['Soma', 'Axon', 'Dendrite', 'Synapse'],
    ),
    _SlideSpec(
      name: 'Fungi',
      asset: 'assets/microbiology/hyphae.svg',
      notes: 'Hyphal threads — septate vs coenocytic patterns.',
      hiddenLabels: <String>['Hypha', 'Spore', 'Mycelium'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _aiLine =
        'Professor: Start on 4×, focus the field, then step up magnification. '
        'Identify structures before revealing labels.';
  }

  @override
  Widget build(BuildContext context) {
    final BiologyDegreeColors c = BiologyDegreeTheme.of(context);
    final _SlideSpec slide = _slides[_slideIndex];
    final double blur = ((0.55 - _focus).abs() * 14).clamp(0, 10);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text(
          'Virtual Microscope',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: Column(
        children: <Widget>[
          if (_aiLine != null)
            Container(
              width: double.infinity,
              color: c.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: <Widget>[
                  Icon(Icons.record_voice_over, color: c.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _aiLine!,
                      style: TextStyle(
                        color: c.textPrimary.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: _eyepiece(c, slide, blur, primary: true)),
                    if (_compare && _compareIndex != null) ...<Widget>[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _eyepiece(
                          c,
                          _slides[_compareIndex!],
                          blur * 0.6,
                          primary: false,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Text('Slide tray', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List<Widget>.generate(_slides.length, (int i) {
                    return ChoiceChip(
                      label: Text(_slides[i].name, style: const TextStyle(fontSize: 12)),
                      selected: _slideIndex == i,
                      onSelected: (_) => setState(() {
                        _slideIndex = i;
                        _revealLabels = false;
                        _aiLine = 'Professor: ${_slides[i].notes}';
                      }),
                      selectedColor: c.primary.withValues(alpha: 0.35),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                Text('Magnification', style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Row(
                  children: _mags.map((int m) {
                    final bool on = _mag == m;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilledButton(
                          onPressed: () => setState(() {
                            _mag = m;
                            _aiLine = m >= 100
                                ? 'Professor: Oil-immersion equivalent — fine focus carefully.'
                                : 'Professor: $_mag× objective selected.';
                          }),
                          style: FilledButton.styleFrom(
                            backgroundColor: on ? c.primary : c.surfaceElevated,
                            foregroundColor: on ? Colors.white : c.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('${m}x', style: const TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Text(
                  'Focus  ${(_focus * 100).round()}%',
                  style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w800),
                ),
                Slider(
                  value: _focus,
                  onChanged: (double v) => setState(() => _focus = v),
                  activeColor: c.primary,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    FilterChip(
                      label: const Text('Add stain'),
                      selected: _stained,
                      onSelected: (bool v) => setState(() {
                        _stained = v;
                        _aiLine = v
                            ? 'Professor: Stain increases contrast of membranes and nuclei.'
                            : 'Professor: Unstained field — morphology still visible at high contrast.';
                      }),
                      selectedColor: const Color(0xFFFF69B4).withValues(alpha: 0.35),
                    ),
                    FilterChip(
                      label: const Text('Compare slide'),
                      selected: _compare,
                      onSelected: (bool v) => setState(() {
                        _compare = v;
                        _compareIndex ??= (_slideIndex + 1) % _slides.length;
                      }),
                      selectedColor: c.accent.withValues(alpha: 0.35),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Capture image'),
                      onPressed: () => setState(() {
                        _captured =
                            '${slide.name} · ${_mag}x · focus ${(_focus * 100).round()}% · '
                            '${_stained ? 'stained' : 'unstained'}';
                        _aiLine = 'Professor: Image captured to lab notebook stub.';
                      }),
                    ),
                    FilterChip(
                      label: Text(_revealLabels ? 'Labels on' : 'Reveal labels'),
                      selected: _revealLabels,
                      onSelected: (bool v) => setState(() {
                        _revealLabels = v;
                        if (v) {
                          _aiLine =
                              'Professor: Confirm each label against what you observed independently.';
                        }
                      }),
                      selectedColor: c.primary.withValues(alpha: 0.35),
                    ),
                  ],
                ),
                if (_compare) ...<Widget>[
                  const SizedBox(height: 10),
                  Text('Compare against', style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w700)),
                  Wrap(
                    spacing: 8,
                    children: List<Widget>.generate(_slides.length, (int i) {
                      if (i == _slideIndex) return const SizedBox.shrink();
                      return ChoiceChip(
                        label: Text(_slides[i].name),
                        selected: _compareIndex == i,
                        onSelected: (_) => setState(() => _compareIndex = i),
                      );
                    }),
                  ),
                ],
                if (_revealLabels) ...<Widget>[
                  const SizedBox(height: 14),
                  Text('Hidden structures', style: TextStyle(color: c.primary, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: slide.hiddenLabels
                        .map(
                          (String l) => Chip(
                            label: Text(l),
                            backgroundColor: c.primary.withValues(alpha: 0.15),
                          ),
                        )
                        .toList(),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      slide.notes,
                      style: TextStyle(color: c.textSecondary, height: 1.4),
                    ),
                  ),
                if (_captured != null) ...<Widget>[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: c.cardDecoration(),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.photo, color: c.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Captured: $_captured',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Complete microscopy', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }

  Widget _eyepiece(BiologyDegreeColors c, _SlideSpec slide, double blur, {required bool primary}) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          border: Border.all(color: c.primary.withValues(alpha: 0.65), width: 4),
          boxShadow: <BoxShadow>[
            BoxShadow(color: c.primary.withValues(alpha: 0.25), blurRadius: 16),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: ColorFiltered(
                colorFilter: _stained
                    ? const ColorFilter.mode(Color(0x66FF69B4), BlendMode.srcATop)
                    : const ColorFilter.mode(Colors.transparent, BlendMode.srcATop),
                child: Center(
                  child: Transform.scale(
                    scale: (_mag / 40).clamp(0.35, 3.2),
                    child: SvgPicture.asset(
                      slide.asset,
                      height: 150,
                      placeholderBuilder: (_) =>
                          Icon(Icons.biotech, size: 80, color: c.primaryLight),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.black54,
                padding: const EdgeInsets.all(8),
                child: Text(
                  primary
                      ? '${slide.name} · ${_mag}x'
                      : 'Compare · ${slide.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
