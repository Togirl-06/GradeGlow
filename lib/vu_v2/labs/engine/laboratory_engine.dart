import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/university_learning_engine.dart';
import '../university_lab_result.dart';
import 'lab_blueprint.dart';
import 'lab_session.dart';
import 'science_workspaces.dart';

abstract final class LaboratoryEngine {
  static Future<UniversityLabResult?> open({
    required BuildContext context,
    required UniversityLabLink link,
    required String subjectId,
    String courseTitle = '',
    String topicTitle = '',
    int level = 2,
  }) {
    final LabBlueprint bp = LabCatalog.forLesson(
      subjectId: subjectId,
      courseTitle: courseTitle,
      topicTitle: topicTitle.isEmpty ? link.title : topicTitle,
      link: link,
      level: level,
    );
    if (!bp.quality.publishable) {
      return Future<UniversityLabResult?>.error(
        StateError(bp.quality.defects.join('; ')),
      );
    }
    return Navigator.of(context).push<UniversityLabResult>(
      MaterialPageRoute<UniversityLabResult>(
        builder: (_) => LaboratoryEngineScreen(blueprint: bp),
      ),
    );
  }
}

class LaboratoryEngineScreen extends StatefulWidget {
  const LaboratoryEngineScreen({super.key, required this.blueprint});
  final LabBlueprint blueprint;

  @override
  State<LaboratoryEngineScreen> createState() => _LaboratoryEngineScreenState();
}

class _LaboratoryEngineScreenState extends State<LaboratoryEngineScreen> {
  late final LabSession session = LabSession(widget.blueprint);
  final TextEditingController _ask = TextEditingController();
  final TextEditingController _anal = TextEditingController();
  final TextEditingController _conc = TextEditingController();
  final TextEditingController _err = TextEditingController();
  bool _left = true;
  bool _right = true;
  bool _report = false;
  bool _layoutReady = false;
  Timer? _clock;

  LabBlueprint get bp => widget.blueprint;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && session.briefed) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_layoutReady) {
      final bool wide = MediaQuery.sizeOf(context).width >= 980;
      _left = wide;
      _right = wide;
      _layoutReady = true;
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    session.dispose();
    _ask.dispose();
    _anal.dispose();
    _conc.dispose();
    _err.dispose();
    super.dispose();
  }

  String _level() {
    switch (bp.level) {
      case 1:
        return 'Level 1 · Guided';
      case 2:
        return 'Level 2 · Assisted';
      case 3:
        return 'Level 3 · Independent';
      default:
        return 'Level 4 · Professional';
    }
  }

  String _clockLabel() {
    final int s = DateTime.now().difference(session.startedAt).inSeconds;
    final int m = s ~/ 60;
    return '${m.toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _finish() async {
    Navigator.of(context).pop(
      session.grade(
        analysis: _anal.text,
        conclusion: _conc.text,
        error: _err.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    final bool wide = w >= 980;
    return ListenableBuilder(
      listenable: session,
      builder: (BuildContext context, _) {
        if (!session.briefed) return _briefing();
        return Scaffold(
          backgroundColor: const Color(0xFF050505),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                _topBar(),
                if (session.paused) _pauseBanner(),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (wide && _left) _side(isLeft: true, width: 268),
                          Expanded(child: _center()),
                          if (wide && _right) _side(isLeft: false, width: 300),
                        ],
                      ),
                      if (!wide && _left)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Material(
                            elevation: 12,
                            color: const Color(0xFF111111),
                            child: _side(isLeft: true, width: 280),
                          ),
                        ),
                      if (!wide && _right)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Material(
                            elevation: 12,
                            color: const Color(0xFF111111),
                            child: _side(isLeft: false, width: 300),
                          ),
                        ),
                    ],
                  ),
                ),
                _bottomBar(wide),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _briefing() {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(bp.courseTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: <Widget>[
          Text(bp.unit.toUpperCase(),
              style: const TextStyle(
                  color: Color(0xFF3DDBAD),
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(bp.title,
              style: const TextStyle(
                  fontFamily: 'Georgia',
                  color: Colors.white,
                  fontSize: 32,
                  height: 1.15)),
          const SizedBox(height: 8),
          Text('${_level()}  ·  ~${bp.estimatedMinutes} min  ·  ${bp.environmentLabel}',
              style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 22),
          _fact('Role', bp.role),
          _fact('Mission', bp.mission),
          _fact('Scenario', bp.scenario),
          _fact('Objectives', bp.objectives.map((String o) => '• $o').join('\n')),
          _fact('Required knowledge', bp.requiredKnowledge.join(' · ')),
          _fact('Safety', bp.safety),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              session.briefed = true;
              session.act('briefed', say: 'The workspace is live. Use the model — not a submit button.');
            },
            child: const Text('Enter the laboratory'),
          ),
        ],
      ),
    );
  }

  Widget _fact(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(k,
              style: const TextStyle(
                  color: Color(0xFF3DDBAD), fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(v, style: const TextStyle(color: Colors.white, height: 1.45)),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Container(
      height: 52,
      color: const Color(0xFF0A0A0A),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
          Expanded(
            child: Text(
              '${bp.courseTitle}  ·  ${bp.title}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          Text(_level(),
              style: const TextStyle(color: Color(0xFF3DDBAD), fontSize: 12)),
          const SizedBox(width: 8),
          Text(
            _clockLabel(),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          TextButton(
            onPressed: () {
              session.note(
                'Checkpoint ${DateTime.now().toIso8601String()} · ${session.events.length} actions',
              );
              session.act('save', inspect: 'Session saved. Your actions are still on the lab record.');
            },
            child: const Text('SAVE'),
          ),
          IconButton(
            tooltip: 'Toggle tools',
            onPressed: () => setState(() => _left = !_left),
            icon: const Icon(Icons.view_sidebar_outlined, color: Colors.white54),
          ),
          IconButton(
            tooltip: 'Toggle inspector',
            onPressed: () => setState(() => _right = !_right),
            icon: const Icon(Icons.info_outline, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _pauseBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF3B1520),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(session.pauseWhy ?? 'Simulation paused.',
                style: const TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: session.clearPause,
            child: const Text('I know what went wrong'),
          ),
        ],
      ),
    );
  }

  Widget _center() {
    return ColoredBox(
      color: const Color(0xFF000000),
      child: LabWorkspaceHost(session: session),
    );
  }

  Widget _side({required bool isLeft, required double width}) {
    return Container(
      width: width,
      color: const Color(0xFF111111),
      child: isLeft ? _leftPanel() : _rightPanel(),
    );
  }

  Widget _leftPanel() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        const Text('MISSION',
            style: TextStyle(
                color: Color(0xFF3DDBAD),
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(bp.mission, style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 13)),
        const SizedBox(height: 16),
        const Text('LAYERS',
            style: TextStyle(
                color: Color(0xFF3DDBAD),
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900)),
        ...bp.layers.map(
          (String l) => SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(l, style: const TextStyle(color: Colors.white, fontSize: 13)),
            value: session.layersOn.contains(l),
            activeThumbColor: const Color(0xFF3DDBAD),
            onChanged: (_) => session.toggleLayer(l),
          ),
        ),
        const SizedBox(height: 8),
        const Text('TOOLS / MATERIALS',
            style: TextStyle(
                color: Color(0xFF3DDBAD),
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900)),
        Wrap(
          spacing: 6,
          children: <Widget>[
            for (final String t in <String>[...bp.tools, ...bp.materials])
              ActionChip(
                label: Text(t, style: const TextStyle(fontSize: 11)),
                onPressed: () => _tool(t),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('NOTEBOOK',
            style: TextStyle(
                color: Color(0xFF3DDBAD),
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900)),
        TextField(
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Record an observation',
            hintStyle: TextStyle(color: Colors.white38),
          ),
          onSubmitted: (String v) {
            if (v.trim().isNotEmpty) session.note(v.trim());
          },
        ),
        for (final String n in session.notebook.reversed.take(4))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('• $n', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _rightPanel() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        const Text('INSPECTOR',
            style: TextStyle(
                color: Color(0xFF3DDBAD),
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(session.inspector, style: const TextStyle(color: Colors.white, height: 1.45)),
        const SizedBox(height: 16),
        const Text('AI PROFESSOR',
            style: TextStyle(
                color: Color(0xFF3DDBAD),
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(session.professor, style: const TextStyle(color: Colors.white70, height: 1.4)),
        const SizedBox(height: 8),
        TextField(
          controller: _ask,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Why did my experiment fail?',
            hintStyle: const TextStyle(color: Colors.white38),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF3DDBAD), size: 18),
              onPressed: () {
                session.askProfessor(_ask.text);
                _ask.clear();
              },
            ),
          ),
        ),
        TextButton(onPressed: session.hint, child: Text('Hint ${session.hintsUsed}/4 (affects score)')),
        const Divider(color: Colors.white12),
        FilledButton.tonal(
          onPressed: () => setState(() => _report = true),
          child: const Text('Laboratory report'),
        ),
        if (_report) ...<Widget>[
          TextField(controller: _anal, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Analysis / reasoning')),
          TextField(controller: _conc, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Conclusion')),
          TextField(controller: _err, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Sources of error')),
          const SizedBox(height: 8),
          FilledButton(onPressed: _finish, child: const Text('Submit & score')),
        ],
      ],
    );
  }

  Widget _bottomBar(bool wide) {
    return Container(
      color: const Color(0xFF0A0A0A),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (final String t in bp.bottomTools)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  onPressed: () => _tool(t),
                  child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 11)),
                ),
              ),
            if (!wide)
              TextButton(onPressed: () => setState(() => _left = !_left), child: const Text('TOOLS')),
            if (!wide)
              TextButton(onPressed: () => setState(() => _right = !_right), child: const Text('PROFESSOR')),
          ],
        ),
      ),
    );
  }

  void _tool(String raw) {
    final String t = raw.toLowerCase();
    if (t.contains('rotate') || t == 'orbit') {
      session.setVar('yaw', (session.getv<double>('yaw') ?? 0) + 0.35, inspectorText: 'Orbit updated');
      session.act('rotate');
    } else if (t.contains('zoom')) {
      session.setVar('mag', ((session.getv<double>('mag') ?? 4) * 1.4).clamp(4, 40));
      session.act('zoom');
    } else if (t.contains('isolate')) {
      session.act('isolate', inspect: 'Isolating active layer. Hide what you do not need.');
    } else if (t == '4×' || t.contains('4x')) {
      session.setVar('mag', 4);
      session.act('obj4');
    } else if (t.contains('40')) {
      final bool focused = session.getv<double>('focus') != null &&
          ((session.getv<double>('focus')! - 0.62).abs() < 0.1);
      if (!focused) {
        session.act('obj40_early', pause: true);
      } else {
        session.setVar('mag', 40);
      }
    } else if (t.contains('10')) {
      session.setVar('mag', 10);
    } else if (t.contains('lamp') || t.contains('illumin')) {
      session.setVar('lamp', true);
      session.act('lamp');
    } else if (t.contains('unknown') || t.contains('slide')) {
      session.setVar('slide', true);
      session.act('slide', inspect: 'Unknown smear on the stage. Lamp, then 4×, then focus.');
    } else if (t.contains('classif') || t.contains('hypothes')) {
      final List<String> pins = (session.getv<List<dynamic>>('pins') ?? <dynamic>[])
          .map((dynamic e) => e.toString().toLowerCase())
          .toList();
      final bool wall = pins.any((String p) => p.contains('wall'));
      final bool chloro = pins.any((String p) => p.contains('chlor'));
      if (wall && chloro) {
        session.act(
          'classified_plant',
          inspect:
              'Plant cell: wall + chloroplasts. That classification is an argument from the field, not a dropdown.',
        );
        session.act('hypothesize');
      } else {
        session.act(
          'hypothesize',
          say: 'Pin a wall and a chloroplast first. Classification without those observations is a guess.',
        );
      }
    } else if (t.contains('rinse')) {
      session.setVar('rinsed', true);
      session.act('rinsed', say: 'Glassware rinsed.');
    } else if (t.contains('fill') || t.contains('burette')) {
      if (session.getv<bool>('rinsed') != true) {
        session.act('skip_rinse', pause: true, say: 'Rinse first. Residual water is a systematic error.');
      } else {
        session.setVar('ready', true);
        session.act('ready', say: 'Burette charged. Drag the stopcock on the bench.');
      }
    } else if (t.contains('drop') || t.contains('add')) {
      session.setVar('ml', (session.getv<double>('ml') ?? 0) + 0.15);
    } else if (t.contains('launch')) {
      session.setVar('launched', true);
      session.act('run', inspect: 'Campaign is live. Read CAC and ROAS on the board.');
    } else if (t.contains('run')) {
      session.act('run');
    } else if (t.contains('reset')) {
      session.vars.clear();
      session.act('reset', inspect: 'Workspace reset.');
    } else if (t.contains('ecg') || t.contains('lead')) {
      session.setVar('leads', true);
      session.act('ecg', inspect: 'Leads on the chest wall.');
    } else if (t.contains('vital') || t.contains('cuff')) {
      session.setVar('hr', 98);
      session.act('vitals', inspect: 'HR 98 · SpO₂ 95% · pain 7/10');
    } else if (t.contains('ask') || t.contains('history') || t.contains('symptom')) {
      session.act('history', inspect: 'Pressure, 40 min, some radiation and nausea. Brother with MI at 50.');
    } else if (t.contains('call') || t.contains('supervis')) {
      if (!session.events.any((LabEvent e) => e.id == 'vitals') ||
          !session.events.any((LabEvent e) => e.id == 'ecg')) {
        session.act('skip_vitals', pause: true);
        return;
      }
      session.act('call', say: 'You brought a pattern, not a vibe.');
    } else if (t.contains('patch') || t.contains('comparison')) {
      session.setVar('patched', true);
      session.act('patch', inspect: 'Comparator restored. Run the inserts.');
      session.act('test_pass');
    } else if (t.contains('load')) {
      final int n = (session.getv<List<dynamic>>('joints') ?? <dynamic>[]).length;
      if (n < 4) {
        session.setVar('failed', true);
        session.act('bridge_fail', pause: true);
      } else {
        session.act('redesign', inspect: 'Span holds under this load. Check the reddest member anyway.');
      }
    } else if (t.contains('shock')) {
      session.setVar('shocked', true);
      session.act('shock');
    } else if (t.contains('rebalanc') || t.contains('allocat')) {
      session.setVar('eq', 0.45);
      session.act('allocate');
      session.act('rebalance');
    } else if (t.contains('record') || t.contains('pin') || t.contains('measure')) {
      session.act('pin', inspect: session.inspector);
    } else if (t.contains('sun') || t.contains('material')) {
      session.setVar('sun', ((session.getv<double>('sun') ?? 0.4) + 0.15).clamp(0, 1));
      session.act('inspect');
    } else if (t.contains('argue') || t.contains('hearing')) {
      session.act('decide', inspect: 'Hearing: argue the writing. Expect the March 3 conversation.');
    } else if (t.contains('decide') || t.contains('strategy')) {
      session.act('decide', inspect: 'Strategy locked. The model will project consequences from Region B / Product X.');
    } else {
      session.act('tool', data: raw, inspect: 'Using $raw on the workspace.');
    }
  }
}
