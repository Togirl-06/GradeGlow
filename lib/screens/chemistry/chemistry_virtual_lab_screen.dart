import 'package:flutter/material.dart';

import '../../data/virtual_chemistry_data.dart';
import '../../models/chemistry_degree.dart';
import '../../theme/chemistry_degree_theme.dart';

class ChemistryVirtualLabScreen extends StatefulWidget {
  const ChemistryVirtualLabScreen({super.key, required this.path});

  final ChemistryLessonPath path;

  @override
  State<ChemistryVirtualLabScreen> createState() => _ChemistryVirtualLabScreenState();
}

class _ChemistryVirtualLabScreenState extends State<ChemistryVirtualLabScreen> {
  bool _safetyComplete = false;
  ChemReagent? _flaskA;
  ChemReagent? _flaskB;
  ChemReaction? _result;
  String? _professorNote;

  static const List<MapEntry<String, String>> _safetyItems = <MapEntry<String, String>>[
    MapEntry('🥽 PPE', 'Safety goggles, lab coat, closed shoes'),
    MapEntry('☣️ Hazards', 'Read labels · never taste or smell directly'),
    MapEntry('🔥 Fire', 'Know extinguisher location · tie back hair'),
    MapEntry('💧 Spills', 'Acid → base spill protocol · report immediately'),
    MapEntry('♻️ Waste', 'Segregate halogenated vs non-halogenated waste'),
  ];

  void _mix() {
    if (_flaskA == null || _flaskB == null) return;
    final ChemReaction reaction = VirtualChemistryData.mix(_flaskA!, _flaskB!);
    setState(() {
      _result = reaction;
      _professorNote =
          'Professor: Watch bond breaking and formation. ${_result!.outcome} '
          'Measured pH ≈ ${_result!.ph.toStringAsFixed(1)}. '
          'Relate this to ${widget.path.lesson.title}.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

    if (!_safetyComplete) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Laboratory Safety', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: <Widget>[
            Text(
              'Before any experiment on ${widget.path.lesson.title}, complete safety review.',
              style: TextStyle(color: c.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ..._safetyItems.map(
              (MapEntry<String, String> item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: c.cardDecoration(),
                  child: Row(
                    children: <Widget>[
                      Text(item.key, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.value,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _safetyComplete = true),
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'I understand — enter laboratory',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.path.lesson.title} · Virtual Lab',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          Text(
            'Select two reagents and mix. Wrong combinations may fail safely — the professor explains why.',
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: VirtualChemistryData.reagents.map((ChemReagent r) {
              final bool inA = _flaskA?.id == r.id;
              final bool inB = _flaskB?.id == r.id;
              return ActionChip(
                label: Text(r.name),
                backgroundColor: inA || inB ? c.primary.withValues(alpha: 0.25) : c.surface,
                side: BorderSide(
                  color: inA || inB ? c.primary : c.border,
                ),
                onPressed: () {
                  setState(() {
                    if (_flaskA?.id == r.id) {
                      _flaskA = null;
                    } else if (_flaskB?.id == r.id) {
                      _flaskB = null;
                    } else if (_flaskA == null) {
                      _flaskA = r;
                    } else if (_flaskB == null) {
                      _flaskB = r;
                    } else {
                      _flaskB = r;
                    }
                    _result = null;
                    _professorNote = null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(child: _Flask(label: 'Flask A', reagent: _flaskA, colors: c)),
              const SizedBox(width: 12),
              Expanded(child: _Flask(label: 'Flask B', reagent: _flaskB, colors: c)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _flaskA != null && _flaskB != null ? _mix : null,
              icon: const Icon(Icons.science_outlined),
              label: const Text('Mix reagents'),
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_result != null) ...<Widget>[
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 80,
              decoration: BoxDecoration(
                color: _result!.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              alignment: Alignment.center,
              child: Text(
                _result!.safe ? 'Reaction observed' : 'Unsafe outcome!',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            if (_professorNote != null)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: c.cardDecoration(borderColor: c.primary.withValues(alpha: 0.4)),
                  child: Text(
                    _professorNote!,
                    style: TextStyle(
                      color: c.textPrimary.withValues(alpha: 0.9),
                      height: 1.45,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
      bottomNavigationBar: _result != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Complete experiment',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _Flask extends StatelessWidget {
  const _Flask({required this.label, required this.reagent, required this.colors});

  final String label;
  final ChemReagent? reagent;
  final ChemistryDegreeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: colors.cardDecoration(),
      child: Column(
        children: <Widget>[
          Text(label, style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: reagent?.color ?? colors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              reagent?.name ?? 'Empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
