import 'dart:convert';

import 'package:flutter/material.dart';

import '../../model/career_models.dart';
import '../../ui/common.dart';
import '../lab_models.dart';
import '../ui/step_views.dart';
import 'anatomy3d.dart';
import 'viewer.dart';
import '../../ui/gg_kit.dart';

/// Identify structures on the 3D body (or, where 3D cannot run, from the
/// structure list — also available as an accessible alternative).
class Anatomy3DView extends StatefulWidget {
  const Anatomy3DView({super.key, required this.lab, required this.step, required this.onGraded});
  final LabSpec lab;
  final Anatomy3DStep step;
  final StepGraded onGraded;
  @override
  State<Anatomy3DView> createState() => _Anatomy3DViewState();
}

class _Anatomy3DViewState extends State<Anatomy3DView> {
  final Anatomy3DController _ctl = Anatomy3DController();
  final Map<int, String> _picks = <int, String>{};
  int _q = 0;
  String? _selected;
  bool _list = false;
  String? _system;
  Widget? _viewer;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _viewer = anatomy3DViewer(
      controller: _ctl,
      onPick: (String id) => setState(() => _selected = id),
      initialCommand: jsonEncode(<String, Object?>{'cmd': 'systems', 'list': widget.step.systems}),
    );
    _list = _viewer == null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final String? raw = careerStore(context).labRun(widget.lab.id)?.drafts[widget.step.id];
    if (raw == null || raw.isEmpty) return;
    try {
      final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
      m.forEach((String k, dynamic v) {
        final int? i = int.tryParse(k);
        if (i != null && i >= 0 && i < widget.step.questions.length && v is String) _picks[i] = v;
      });
      _q = _firstOpen();
    } on Object {
      _picks.clear();
    }
  }

  int _firstOpen() {
    for (int i = 0; i < widget.step.questions.length; i++) {
      if (!_picks.containsKey(i)) return i;
    }
    return widget.step.questions.length - 1;
  }

  void _confirm() {
    final String? id = _selected;
    if (id == null) return;
    setState(() {
      _picks[_q] = id;
      _selected = null;
      _q = _firstOpen();
    });
    careerStore(context).saveLabDraft(widget.lab, widget.step.id, jsonEncode(<String, String>{for (final MapEntry<int, String> e in _picks.entries) '${e.key}': e.value}));
  }

  Future<void> _submit() async {
    final TaskResult? r = await gradeLabStep(context, () => Anatomy3DGrader.grade(widget.step, _picks), widget.onGraded);
    if (r == null) return;
    final Map<String, String> marks = <String, String>{};
    for (int i = 0; i < widget.step.questions.length; i++) {
      final AnatomyQuestion q = widget.step.questions[i];
      final String got = _picks[i]!;
      if (q.answers.contains(got)) {
        marks[got] = 'correct';
      } else {
        marks[got] = 'wrong';
        marks[q.answers.first] = 'target';
      }
    }
    _ctl.command(jsonEncode(<String, Object>{'cmd': 'mark', 'marks': marks}));
  }

  @override
  Widget build(BuildContext context) {
    final Anatomy3DStep s = widget.step;
    final AnatomyQuestion q = s.questions[_q];
    final AnatomyStructure? sel = _selected == null ? null : structureById(_selected!);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
        for (int i = 0; i < s.questions.length; i++)
          ChoiceChip(
            key: ValueKey<String>('a3d_q_$i'),
            label: Text('${i + 1}'),
            avatar: _picks.containsKey(i) ? const Icon(Icons.check_rounded, size: 16) : null,
            selected: i == _q,
            onSelected: (_) => setState(() {
              _q = i;
              _selected = null;
            }),
          ),
      ]),
      const SizedBox(height: 6),
      Text('Find: ${q.prompt}', key: const ValueKey<String>('a3d_prompt'), style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800, fontSize: 16)),
      if (_picks[_q] != null) Text('Your answer: ${structureById(_picks[_q]!)?.name ?? _picks[_q]}', style: TextStyle(color: GG.mute, fontSize: 12)),
      const SizedBox(height: 6),
      if (_viewer != null)
        Row(children: <Widget>[
          Text('View:', style: TextStyle(color: GG.mute, fontSize: 12)),
          const SizedBox(width: 6),
          ChoiceChip(key: const ValueKey<String>('a3d_mode_3d'), label: const Text('3D model'), selected: !_list, onSelected: (_) => setState(() => _list = false)),
          const SizedBox(width: 4),
          ChoiceChip(key: const ValueKey<String>('a3d_mode_list'), label: const Text('List'), selected: _list, onSelected: (_) => setState(() => _list = true)),
        ]),
      if (_viewer == null) Text('The 3D model runs in the browser and on phones; here, choose from the list.', style: TextStyle(color: GG.mute, fontSize: 12)),
      const SizedBox(height: 6),
      // The 3D view stays mounted (only hidden) so the model is not reloaded.
      if (_viewer != null)
        Offstage(
          offstage: _list,
          child: Container(
            height: 440,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: GG.stroke)),
            clipBehavior: Clip.antiAlias,
            child: _viewer,
          ),
        ),
      if (_list) _structureList(),
      const SizedBox(height: 8),
      Row(children: <Widget>[
        Expanded(
          child: Text(sel == null ? 'Tap a structure to select it.' : 'Selected: ${sel.name}',
              key: const ValueKey<String>('a3d_selected'), style: TextStyle(color: GG.ink, fontWeight: FontWeight.w600)),
        ),
        FilledButton(key: const ValueKey<String>('a3d_confirm'), onPressed: sel == null ? null : _confirm, child: const Text('Confirm answer')),
      ]),
      if (sel != null) Text(sel.description, style: TextStyle(color: GG.mute, fontSize: 12)),
      const SizedBox(height: 10),
      Text('${_picks.length} of ${s.questions.length} identified', style: TextStyle(color: GG.mute, fontSize: 12)),
      labSubmitButton('a3d_submit', _submit),
    ]);
  }

  Widget _structureList() {
    final List<AnatomyStructure> shown = anatomyStructures.where((AnatomyStructure a) => _system == null || a.system == _system).toList()
      ..sort((AnatomyStructure a, AnatomyStructure b) => a.name.compareTo(b.name));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
        ChoiceChip(key: const ValueKey<String>('a3d_sys_all'), label: const Text('All systems'), selected: _system == null, onSelected: (_) => setState(() => _system = null)),
        for (final MapEntry<String, String> e in anatomySystems.entries)
          ChoiceChip(key: ValueKey<String>('a3d_sys_${e.key}'), label: Text(e.value), selected: _system == e.key, onSelected: (_) => setState(() => _system = e.key)),
      ]),
      const SizedBox(height: 6),
      Wrap(spacing: 4, runSpacing: 4, children: <Widget>[
        for (final AnatomyStructure a in shown)
          ChoiceChip(key: ValueKey<String>('a3d_pick_${a.id}'), label: Text(a.name), selected: _selected == a.id, onSelected: (_) => setState(() => _selected = a.id)),
      ]),
    ]);
  }
}
