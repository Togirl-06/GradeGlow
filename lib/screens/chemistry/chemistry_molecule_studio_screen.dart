import 'package:flutter/material.dart';

import '../../data/chemistry_molecule_data.dart';
import '../../data/chemistry_periodic_table_data.dart';
import '../../models/chemistry_degree.dart';
import '../../theme/chemistry_degree_theme.dart';

class ChemistryMoleculeStudioScreen extends StatefulWidget {
  const ChemistryMoleculeStudioScreen({super.key, required this.path});

  final ChemistryLessonPath path;

  @override
  State<ChemistryMoleculeStudioScreen> createState() =>
      _ChemistryMoleculeStudioScreenState();
}

class _ChemistryMoleculeStudioScreenState extends State<ChemistryMoleculeStudioScreen> {
  late ChemMolecule _molecule;
  MoleculeViewMode _viewMode = MoleculeViewMode.ballAndStick;
  double _rotY = 0.4;
  double _rotX = 0.3;
  double _scale = 90;
  int? _selectedAtom;
  bool _exploded = false;

  @override
  void initState() {
    super.initState();
    _molecule = ChemistryMoleculeData.moleculeForTopic(widget.path.lesson.title);
  }

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_molecule.name} · Molecule Studio',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails d) {
                setState(() {
                  _rotY += d.delta.dx * 0.01;
                  _rotX += d.delta.dy * 0.01;
                });
              },
              child: CustomPaint(
                painter: _MoleculePainter(
                  molecule: _molecule,
                  viewMode: _viewMode,
                  rotX: _rotX,
                  rotY: _rotY,
                  scale: _scale,
                  selectedAtom: _selectedAtom,
                  exploded: _exploded,
                  colors: c,
                ),
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Drag to rotate · Tap atoms',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: ChemistryMoleculeData.catalog.map((ChemMolecule m) {
                final bool selected = m.id == _molecule.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(m.formula),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _molecule = m;
                      _selectedAtom = null;
                    }),
                    selectedColor: c.primary,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: MoleculeViewMode.values.map((MoleculeViewMode mode) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(mode.label),
                    selected: _viewMode == mode,
                    onSelected: (_) => setState(() => _viewMode = mode),
                    selectedColor: c.primary.withValues(alpha: 0.35),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Slider(
                    value: _scale,
                    min: 60,
                    max: 140,
                    onChanged: (double v) => setState(() => _scale = v),
                    activeColor: c.primary,
                  ),
                ),
                Text('Zoom', style: TextStyle(color: c.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          if (_selectedAtom != null) _AtomPanel(
            atom: _molecule.atoms[_selectedAtom!],
            colors: c,
          ),
          if (_molecule.bondAngleDeg != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Bond angle: ${_molecule.bondAngleDeg} · ${_molecule.polarity ?? ''}',
                style: TextStyle(color: c.textSecondary, fontSize: 12),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _exploded = !_exploded),
                    child: Text(_exploded ? 'Collapse' : 'Explode molecule'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AtomPanel extends StatelessWidget {
  const _AtomPanel({required this.atom, required this.colors});

  final MoleculeAtom atom;
  final ChemistryDegreeColors colors;

  @override
  Widget build(BuildContext context) {
    final ChemElement? profile = ChemistryPeriodicTableData.bySymbol(atom.element);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: colors.cardDecoration(borderColor: colors.primary.withValues(alpha: 0.4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Atom: ${atom.element}',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (profile != null) ...<Widget>[
            Text('Z = ${profile.atomicNumber} · Mass ${profile.atomicMass}',
                style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            Text('Config: ${profile.electronConfig}',
                style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            Text('Electronegativity: ${profile.electronegativity}',
                style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          ],
          if (atom.lonePairs > 0)
            Text('Lone pairs: ${atom.lonePairs}',
                style: TextStyle(color: colors.accent, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MoleculePainter extends CustomPainter {
  _MoleculePainter({
    required this.molecule,
    required this.viewMode,
    required this.rotX,
    required this.rotY,
    required this.scale,
    required this.selectedAtom,
    required this.exploded,
    required this.colors,
  });

  final ChemMolecule molecule;
  final MoleculeViewMode viewMode;
  final double rotX;
  final double rotY;
  final double scale;
  final int? selectedAtom;
  final bool exploded;
  final ChemistryDegreeColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final List<Offset> positions = List<Offset>.generate(
      molecule.atoms.length,
      (int i) {
        final MoleculeAtom atom = molecule.atoms[i];
        final double factor = exploded ? 1.35 : 1.0;
        return ChemistryMoleculeData.project(
          MoleculeAtom(
            element: atom.element,
            x: atom.x * factor,
            y: atom.y * factor,
            z: atom.z * factor,
          ),
          rotY,
          rotX,
          scale,
        );
      },
    );

    if (viewMode != MoleculeViewMode.lewis) {
      for (final MoleculeBond bond in molecule.bonds) {
        final Paint bondPaint = Paint()
          ..color = viewMode == MoleculeViewMode.wireframe
              ? colors.primary.withValues(alpha: 0.6)
              : colors.textSecondary.withValues(alpha: 0.7)
          ..strokeWidth = bond.order == 2 ? 3 : 2;
        canvas.drawLine(
          center + positions[bond.a],
          center + positions[bond.b],
          bondPaint,
        );
      }
    }

    for (var i = 0; i < molecule.atoms.length; i++) {
      final MoleculeAtom atom = molecule.atoms[i];
      final Offset pos = center + positions[i];
      final Color color =
          ChemistryMoleculeData.elementColors[atom.element] ?? colors.primary;
      final double radius = viewMode == MoleculeViewMode.spaceFilling ? 18 : 14;

      if (viewMode == MoleculeViewMode.lewis) {
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: atom.element,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
        continue;
      }

      canvas.drawCircle(
        pos,
        radius,
        Paint()..color = viewMode == MoleculeViewMode.wireframe ? Colors.transparent : color,
      );
      if (viewMode == MoleculeViewMode.wireframe || selectedAtom == i) {
        canvas.drawCircle(
          pos,
          radius,
          Paint()
            ..color = selectedAtom == i ? colors.accent : colors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MoleculePainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) => true;
}
