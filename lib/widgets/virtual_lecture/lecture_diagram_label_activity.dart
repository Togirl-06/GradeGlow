import 'package:flutter/material.dart';

import '../../data/science_diagram_catalog.dart';
import '../../models/science_diagram.dart';
import '../science/anatomy_asset_canvas.dart';
import '../science/science_diagram_canvas.dart';

/// Diagram labelling during a university lecture: each structure is
/// highlighted in turn and the student names it from the word bank.
class LectureDiagramLabelActivity extends StatefulWidget {
  const LectureDiagramLabelActivity({
    super.key,
    required this.diagramId,
    this.regionIds,
    this.title = 'Label the diagram',
  });

  final String diagramId;
  final List<String>? regionIds;
  final String title;

  static Future<bool?> open(
    BuildContext context, {
    required String diagramId,
    List<String>? regionIds,
    String title = 'Label the diagram',
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => LectureDiagramLabelActivity(
          diagramId: diagramId,
          regionIds: regionIds,
          title: title,
        ),
      ),
    );
  }

  @override
  State<LectureDiagramLabelActivity> createState() => _LectureDiagramLabelActivityState();
}

class _LectureDiagramLabelActivityState extends State<LectureDiagramLabelActivity> {
  int _index = 0;
  final Map<String, String> _answers = <String, String>{};
  bool _checked = false;

  List<ScienceDiagramRegion> _regions(ScienceDiagram d) => widget.regionIds == null
      ? d.regions
      : d.regions.where((ScienceDiagramRegion r) => widget.regionIds!.contains(r.id)).toList();

  @override
  Widget build(BuildContext context) {
    final ScienceDiagram? diagram = ScienceDiagramCatalog.diagramById(widget.diagramId);
    if (diagram == null) {
      return Scaffold(appBar: AppBar(title: Text(widget.title)), body: const Center(child: Text('Diagram not found')));
    }
    final List<ScienceDiagramRegion> regions = _regions(diagram);
    if (regions.isEmpty) {
      return Scaffold(appBar: AppBar(title: Text(widget.title)), body: const Center(child: Text('Nothing to label')));
    }
    final List<String> bank = regions.map((ScienceDiagramRegion r) => r.name).toSet().toList()..sort();
    final ScienceDiagramRegion current = regions[_index.clamp(0, regions.length - 1)];
    final int correct = regions.where((ScienceDiagramRegion r) => _answers[r.id] == r.name).length;
    final bool allAnswered = regions.every((ScienceDiagramRegion r) => _answers.containsKey(r.id));

    final Widget canvas = diagram.usesAnatomyAsset
        ? AnatomyAssetCanvas(diagram: diagram, highlightRegionId: current.id, showOverlays: false, onRegionTap: (_) {})
        : ScienceDiagramCanvas(diagram: diagram, highlightRegionId: current.id, showOverlays: false, onRegionTap: (_) {});

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(diagram.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(height: 280, child: canvas),
          const SizedBox(height: 12),
          Text('Structure ${_index + 1} of ${regions.length}: which part is highlighted?'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (final String name in bank)
                ChoiceChip(
                  label: Text(name),
                  selected: _answers[current.id] == name,
                  onSelected: _checked ? null : (_) => setState(() => _answers[current.id] = name),
                ),
            ],
          ),
          if (_checked && _answers[current.id] != current.name)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Not quite. ${current.funFact}', style: const TextStyle(color: Color(0xFFEF4444))),
            ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              OutlinedButton(
                onPressed: _index == 0 ? null : () => setState(() => _index--),
                child: const Text('Previous'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _index >= regions.length - 1 ? null : () => setState(() => _index++),
                child: const Text('Next'),
              ),
              const Spacer(),
              if (!_checked)
                FilledButton(
                  onPressed: allAnswered ? () => setState(() => _checked = true) : null,
                  child: const Text('Check labels'),
                )
              else if (correct == regions.length)
                FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Done'))
              else
                FilledButton(
                  onPressed: () => setState(() {
                    _checked = false;
                    _answers.removeWhere((String id, String v) => regions.any((ScienceDiagramRegion r) => r.id == id && r.name != v));
                  }),
                  child: const Text('Fix mistakes'),
                ),
            ],
          ),
          if (_checked) Padding(padding: const EdgeInsets.only(top: 8), child: Text('$correct of ${regions.length} correct')),
        ],
      ),
    );
  }
}

/// Anatomy labelling from the lecture flow (the same labelling activity,
/// focused on the regions the professor is discussing).
class LectureAnatomy3dActivity {
  static Future<bool?> open(
    BuildContext context, {
    String diagramId = 'skeleton',
    List<String>? focusRegionIds,
  }) {
    return LectureDiagramLabelActivity.open(
      context,
      diagramId: diagramId,
      regionIds: focusRegionIds,
      title: 'Anatomy labelling',
    );
  }
}
