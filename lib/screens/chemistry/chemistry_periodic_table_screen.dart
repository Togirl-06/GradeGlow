import 'package:flutter/material.dart';

import '../../data/chemistry_periodic_table_data.dart';
import '../../models/chemistry_degree.dart';
import '../../theme/chemistry_degree_theme.dart';

class ChemistryPeriodicTableScreen extends StatefulWidget {
  const ChemistryPeriodicTableScreen({super.key, required this.path});

  final ChemistryLessonPath path;

  @override
  State<ChemistryPeriodicTableScreen> createState() =>
      _ChemistryPeriodicTableScreenState();
}

class _ChemistryPeriodicTableScreenState extends State<ChemistryPeriodicTableScreen> {
  ChemElement? _selected;
  ChemElement? _hovered;

  @override
  Widget build(BuildContext context) {
    final ChemistryDegreeColors c = ChemistryDegreeTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Interactive Periodic Table',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          Text(
            'Tap an element for a full profile. Hover highlights group and period trends.',
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ChemistryPeriodicTableData.elements.map((ChemElement e) {
              final bool isSelected = _selected?.symbol == e.symbol;
              final bool isHovered = _hovered?.symbol == e.symbol;
              return MouseRegion(
                onEnter: (_) => setState(() => _hovered = e),
                onExit: (_) => setState(() => _hovered = null),
                child: InkWell(
                  onTap: () => setState(() => _selected = e),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? c.primary.withValues(alpha: 0.25)
                          : isHovered
                              ? c.surfaceElevated
                              : c.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? c.primary
                            : isHovered
                                ? c.accent
                                : c.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          e.atomicNumber.toString(),
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          e.symbol,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          e.name,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 9,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_hovered != null) ...<Widget>[
            const SizedBox(height: 16),
            _TrendBanner(element: _hovered!, colors: c),
          ],
          if (_selected != null) ...<Widget>[
            const SizedBox(height: 20),
            _ElementProfile(element: _selected!, colors: c),
          ],
        ],
      ),
      bottomNavigationBar: _selected != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Continue lesson',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _TrendBanner extends StatelessWidget {
  const _TrendBanner({required this.element, required this.colors});

  final ChemElement element;
  final ChemistryDegreeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: colors.cardDecoration(borderColor: colors.accent.withValues(alpha: 0.5)),
      child: Text(
        'Group ${element.group} · Period ${element.period} · ${element.category} · '
        'Electronegativity ${element.electronegativity} · Radius ~${element.atomicRadiusPm} pm',
        style: TextStyle(
          color: colors.textPrimary.withValues(alpha: 0.85),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ElementProfile extends StatelessWidget {
  const _ElementProfile({required this.element, required this.colors});

  final ChemElement element;
  final ChemistryDegreeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: colors.cardDecoration(borderColor: colors.primary.withValues(alpha: 0.45)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${element.name} (${element.symbol})',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          ...<MapEntry<String, String>>[
            MapEntry('Discovery', element.discovery),
            MapEntry('Atomic mass', '${element.atomicMass} u'),
            MapEntry('Electron configuration', element.electronConfig),
            MapEntry('Oxidation states', element.oxidationStates),
            MapEntry('Uses', element.uses),
            MapEntry('Industrial uses', element.industrialUses),
            MapEntry('Biological importance', element.biologicalImportance),
            MapEntry('Hazards', element.hazards),
            MapEntry('Common compounds', element.compounds),
            MapEntry('Interesting facts', element.facts),
          ].map(
            (MapEntry<String, String> row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    row.key,
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    row.value,
                    style: TextStyle(
                      color: colors.textPrimary.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
