import 'package:flutter/material.dart';

import '../shared/science_lab_shell.dart';
import '../shared/science_lab_theme.dart';
import '../shared/science_notebook_store.dart';
import '../shared/science_workspace_shell.dart';

/// Drag H/H/O → H2O + Lewis-ish valence mode.
class ChemistryMolecularBuilder extends StatefulWidget {
  const ChemistryMolecularBuilder({super.key});

  @override
  State<ChemistryMolecularBuilder> createState() =>
      _ChemistryMolecularBuilderState();
}

class _ChemistryMolecularBuilderState extends State<ChemistryMolecularBuilder> {
  static const ScienceLabTheme t = ScienceLabTheme.chemistry;
  final ScienceNotebookStore _store = ScienceNotebookStore('chemistry');

  bool _lewisMode = false;
  final List<String> _slots = <String>['', '', '']; // H, O, H for water
  final List<_AtomNode> _atoms = <_AtomNode>[];
  final List<_Bond> _bonds = <_Bond>[];
  int? _bondFrom;
  String? _feedback;

  static const Map<String, int> _valence = <String, int>{
    'H': 1,
    'O': 2,
    'C': 4,
    'N': 3,
  };

  int _usedBonds(int atomIndex) =>
      _bonds.where((_Bond b) => b.a == atomIndex || b.b == atomIndex).fold(
            0,
            (int s, _Bond b) => s + b.order,
          );

  void _placeAtom(String symbol) {
    setState(() {
      _atoms.add(_AtomNode(symbol, 0.3 + _atoms.length * 0.12, 0.45));
      _feedback = null;
    });
  }

  void _tapAtom(int i) {
    if (_bondFrom == null) {
      setState(() => _bondFrom = i);
      return;
    }
    if (_bondFrom == i) {
      setState(() => _bondFrom = null);
      return;
    }
    setState(() {
      _bonds.add(_Bond(_bondFrom!, i, 1));
      _bondFrom = null;
      _feedback = _valenceFeedback();
    });
  }

  String _valenceFeedback() {
    final List<String> issues = <String>[];
    for (int i = 0; i < _atoms.length; i++) {
      final int need = _valence[_atoms[i].symbol] ?? 0;
      final int used = _usedBonds(i);
      if (used != need) {
        issues.add('${_atoms[i].symbol} wants $need bond(s), has $used');
      }
    }
    if (issues.isEmpty && _atoms.isNotEmpty) return 'Valence satisfied ✓';
    return issues.join(' · ');
  }

  bool get _waterBuilt {
    final int h = _slots.where((String s) => s == 'H').length;
    final int o = _slots.where((String s) => s == 'O').length;
    return h == 2 && o == 1 && _slots[1] == 'O';
  }

  bool get _lewisWaterOk {
    if (_atoms.length != 3) return false;
    final int hCount = _atoms.where((_AtomNode a) => a.symbol == 'H').length;
    final int oCount = _atoms.where((_AtomNode a) => a.symbol == 'O').length;
    if (hCount != 2 || oCount != 1) return false;
    for (int i = 0; i < _atoms.length; i++) {
      if (_usedBonds(i) != (_valence[_atoms[i].symbol] ?? -1)) return false;
    }
    return _bonds.length == 2;
  }

  Future<void> _submit() async {
    final bool ok = _lewisMode ? _lewisWaterOk : _waterBuilt;
    if (!ok) {
      await showScienceResult(
        context: context,
        theme: t,
        passed: false,
        title: 'Not H₂O yet',
        body: _lewisMode
            ? 'Place O + 2 H and bond each H to O (valence must match).'
            : 'Drop H, O, H into the three slots (O in the middle).',
      );
      return;
    }
    await _store.addNote(
      _lewisMode
          ? 'Lewis H2O built — valence OK'
          : 'Molecular builder: H2O structure assembled',
    );
    if (!mounted) return;
    await showScienceResult(
      context: context,
      theme: t,
      passed: true,
      title: 'H₂O assembled',
      body: 'Bent water structure locked in. Molecule accepted.',
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ScienceWorkspaceShell(
      theme: t,
      dark: true,
      crumbs: const <String>['Chemistry Lab', 'Molecules', 'Builder'],
      footer: sciencePrimaryButton(
        accent: t.accent,
        label: 'CONFIRM MOLECULE',
        onPressed: _submit,
      ),
      tools: Wrap(
        spacing: 8,
        children: <String>['H', 'C', 'N', 'O'].map((String s) {
          return FilledButton(
            onPressed: () => _placeAtom(s),
            style: FilledButton.styleFrom(
              backgroundColor: t.accent,
              foregroundColor: Colors.black,
            ),
            child: Text(s, style: const TextStyle(fontWeight: FontWeight.w900)),
          );
        }).toList(),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ScienceSideCard(
            title: 'ATOMS',
            accent: t.accent,
            dark: true,
            child: ListView(
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Lewis bonds', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  value: _lewisMode,
                  activeThumbColor: t.accent,
                  onChanged: (bool v) => setState(() => _lewisMode = v),
                ),
                const Text(
                  'Tap two atoms to bond. H₂O needs O in the middle.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (_feedback != null)
                  Text(_feedback!, style: TextStyle(color: t.accent, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _lewisMode
                  ? LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints c) {
                        return Stack(
                          children: <Widget>[
                            CustomPaint(
                              size: Size(c.maxWidth, c.maxHeight),
                              painter: _LewisPainter(
                                atoms: _atoms,
                                bonds: _bonds,
                                accent: t.accent,
                              ),
                            ),
                            ...List<Widget>.generate(_atoms.length, (int i) {
                              final _AtomNode a = _atoms[i];
                              return Positioned(
                                left: a.fx * c.maxWidth - 22,
                                top: a.fy * c.maxHeight - 22,
                                child: GestureDetector(
                                  onTap: () => _tapAtom(i),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _bondFrom == i
                                          ? t.accent
                                          : const Color(0xFF334155),
                                      border: Border.all(color: Colors.white70),
                                    ),
                                    child: Text(
                                      a.symbol,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List<Widget>.generate(3, (int i) {
                            return DragTarget<String>(
                              onAcceptWithDetails: (DragTargetDetails<String> d) {
                                setState(() => _slots[i] = d.data);
                              },
                              builder: (BuildContext context, List<String?> cand, List<dynamic> rej) {
                                return Container(
                                  width: 72,
                                  height: 72,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _slots[i].isEmpty
                                        ? Colors.white12
                                        : t.accent.withValues(alpha: 0.35),
                                    border: Border.all(color: t.accent, width: 2),
                                  ),
                                  child: Text(
                                    _slots[i].isEmpty ? '·' : _slots[i],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          children: <String>['H', 'H', 'O'].map((String s) {
                            return Draggable<String>(
                              data: s,
                              feedback: _atomChip(s, dragging: true),
                              child: _atomChip(s),
                            );
                          }).toList(),
                        ),
                        if (_waterBuilt)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: CustomPaint(
                              size: const Size(180, 80),
                              painter: _WaterStructurePainter(accent: t.accent),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          ScienceSideCard(
            title: 'STRUCTURE',
            accent: t.accent,
            dark: true,
            child: ListView(
              children: <Widget>[
                Text(
                  _waterBuilt || _lewisWaterOk ? 'CH₄ / H₂O ready' : 'Build the molecule',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ball & stick · valence must match.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _atomChip(String s, {bool dragging = false}) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dragging ? t.accent : t.surface,
        border: Border.all(color: t.accent, width: 2),
      ),
      child: Text(
        s,
        style: TextStyle(
          color: dragging ? Colors.black : Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _AtomNode {
  _AtomNode(this.symbol, this.fx, this.fy);
  final String symbol;
  double fx;
  double fy;
}

class _Bond {
  _Bond(this.a, this.b, this.order);
  final int a;
  final int b;
  final int order;
}

class _WaterStructurePainter extends CustomPainter {
  _WaterStructurePainter({required this.accent});
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final Offset o = Offset(size.width * 0.5, size.height * 0.45);
    final Offset h1 = Offset(size.width * 0.22, size.height * 0.75);
    final Offset h2 = Offset(size.width * 0.78, size.height * 0.75);
    canvas.drawLine(o, h1, p);
    canvas.drawLine(o, h2, p);
    canvas.drawCircle(o, 14, Paint()..color = accent);
    canvas.drawCircle(h1, 10, Paint()..color = Colors.white70);
    canvas.drawCircle(h2, 10, Paint()..color = Colors.white70);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LewisPainter extends CustomPainter {
  _LewisPainter({required this.atoms, required this.bonds, required this.accent});
  final List<_AtomNode> atoms;
  final List<_Bond> bonds;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = accent.withValues(alpha: 0.8)
      ..strokeWidth = 2.5;
    for (final _Bond b in bonds) {
      if (b.a >= atoms.length || b.b >= atoms.length) continue;
      final Offset a = Offset(atoms[b.a].fx * size.width, atoms[b.a].fy * size.height);
      final Offset c = Offset(atoms[b.b].fx * size.width, atoms[b.b].fy * size.height);
      canvas.drawLine(a, c, p);
    }
  }

  @override
  bool shouldRepaint(covariant _LewisPainter oldDelegate) => true;
}
