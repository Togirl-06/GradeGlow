import 'package:flutter/material.dart';

import '../../../data/science_diagram_catalog.dart';
import '../../../models/science_diagram.dart';
import '../../../services/lab_runner/lab_runner.dart';
import '../../../services/lab_runner/lab_runner_host.dart';
import '../../../vu_v2/design/vu_v2_theme.dart';
import '../../../widgets/science/anatomy_asset_canvas.dart';
import '../../../widgets/science/science_diagram_canvas.dart';
import '../../ui/common.dart';
import '../../model/tasks.dart';
import '../lab_models.dart';

const TextStyle _mono = TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.35);

Widget codeBox(String text, {Color? color, Key? key}) => Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
      child: SelectableText(text.isEmpty ? '(no output)' : text, style: _mono.copyWith(color: color ?? const Color(0xFFE2E8F0))),
    );

/// A console that runs any program the student writes, with their own input.
class ConsoleTool extends StatefulWidget {
  const ConsoleTool({super.key});

  @override
  State<ConsoleTool> createState() => _ConsoleToolState();
}

class _ConsoleToolState extends State<ConsoleTool> {
  String _lang = 'python3';
  final TextEditingController _code = TextEditingController(text: 'for i in range(3):\n    print("Hello from Python", i)\n');
  final TextEditingController _stdin = TextEditingController();
  ProgramOutput? _out;

  @override
  void dispose() {
    _code.dispose();
    _stdin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LabRunner runner = careerStore(context).runner;
    final ProgramOutput? o = _out;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(children: <Widget>[
          DropdownButton<String>(
            key: const ValueKey<String>('console_lang'),
            value: _lang,
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(value: 'python3', child: Text('Python 3')),
              DropdownMenuItem<String>(value: 'javascript', child: Text('JavaScript')),
            ],
            onChanged: (String? v) => setState(() {
              _lang = v ?? _lang;
              _code.text = _lang == 'python3' ? 'print("Hello from Python")\n' : 'console.log("Hello from JavaScript");\n';
            }),
          ),
          const Spacer(),
          Text(runner.where, style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
        ]),
        TextField(key: const ValueKey<String>('console_code'), controller: _code, minLines: 5, maxLines: 14, style: _mono, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Program')),
        const SizedBox(height: 6),
        TextField(key: const ValueKey<String>('console_stdin'), controller: _stdin, minLines: 1, maxLines: 4, style: _mono, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Input (stdin)', isDense: true)),
        const SizedBox(height: 6),
        Row(children: <Widget>[
          BusyButton(
            key: const ValueKey<String>('console_run'),
            label: 'Run',
            icon: Icons.play_arrow_rounded,
            onPressed: () async {
              final ProgramOutput r = await runner.runProgram(_lang, _code.text, stdin: _stdin.text);
              if (mounted) setState(() => _out = r);
            },
          ),
          const SizedBox(width: 8),
          LabRunnerHost(runner: runner),
          if (o != null) Text(o.ok ? 'Exit 0 · ${o.ms} ms' : (o.timedOut ? 'Stopped (time limit)' : 'Error'), style: TextStyle(color: o.ok ? VuV2Colors.success : VuV2Colors.danger)),
        ]),
        if (o != null) ...<Widget>[
          const SizedBox(height: 6),
          if (o.unavailable != null) Text(o.unavailable!, style: const TextStyle(color: VuV2Colors.danger)),
          codeBox(o.stdout, key: const ValueKey<String>('console_output')),
          if (o.stderr.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: codeBox(o.stderr, color: const Color(0xFFFCA5A5))),
        ],
      ],
    );
  }
}

/// A result grid for SQL output.
class SqlTableView extends StatelessWidget {
  const SqlTableView({super.key, required this.table});
  final SqlTable table;

  @override
  Widget build(BuildContext context) {
    if (table.columns.isEmpty) return Text('No rows returned.', style: TextStyle(color: VuV2Colors.mute));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 32,
        dataRowMinHeight: 28,
        dataRowMaxHeight: 32,
        columns: <DataColumn>[for (final String c in table.columns) DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.w700)))],
        rows: <DataRow>[
          for (final List<Object?> r in table.rows.take(100))
            DataRow(cells: <DataCell>[for (final Object? v in r) DataCell(Text(v == null ? 'NULL' : '$v', style: _mono))]),
        ],
      ),
    );
  }
}

/// Runs any SQL against a fresh copy of the lab database.
class SqlWorkbench extends StatefulWidget {
  const SqlWorkbench({super.key, required this.lab, this.initial = 'SELECT * FROM students;'});
  final LabSpec lab;
  final String initial;

  @override
  State<SqlWorkbench> createState() => _SqlWorkbenchState();
}

class _SqlWorkbenchState extends State<SqlWorkbench> {
  late final TextEditingController _sql = TextEditingController(text: widget.initial);
  SqlOutput? _out;

  @override
  void dispose() {
    _sql.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LabRunner runner = careerStore(context).runner;
    final SqlOutput? o = _out;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Tables', style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w700)),
        for (final String t in widget.lab.databaseTables) Text('• $t', style: _mono.copyWith(color: VuV2Colors.ink)),
        const SizedBox(height: 8),
        TextField(key: const ValueKey<String>('workbench_sql'), controller: _sql, minLines: 3, maxLines: 10, style: _mono, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'SQL')),
        const SizedBox(height: 6),
        Row(children: <Widget>[
          BusyButton(
            key: const ValueKey<String>('workbench_run'),
            label: 'Run SQL',
            icon: Icons.play_arrow_rounded,
            onPressed: () async {
              final SqlOutput r = await runner.runSql(setup: widget.lab.database, statements: _sql.text);
              if (mounted) setState(() => _out = r);
            },
          ),
          const SizedBox(width: 8),
          LabRunnerHost(runner: runner),
          Text(runner.canRunPrograms ? 'SQLite · fresh copy each run' : runner.where, style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
        ]),
        if (o != null) ...<Widget>[
          const SizedBox(height: 6),
          if (o.unavailable != null)
            Text(o.unavailable!, style: const TextStyle(color: VuV2Colors.danger))
          else if (!o.ok)
            Text('Error: ${o.error}', key: const ValueKey<String>('workbench_error'), style: const TextStyle(color: VuV2Colors.danger))
          else ...<Widget>[
            Text('${o.result.rows.length} row(s)${o.changes > 0 ? ' · ${o.changes} row(s) changed' : ''}', style: TextStyle(color: VuV2Colors.mute)),
            SqlTableView(table: o.result),
          ],
        ],
      ],
    );
  }
}

/// A bedside monitor showing one set of observations.
class BedsideMonitor extends StatelessWidget {
  const BedsideMonitor({super.key, required this.vitals});
  final Vitals vitals;

  Widget _cell(String label, String value, Color color) => Container(
        width: 112,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black, border: Border.all(color: color.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final Vitals v = vitals;
    return Container(
      key: const ValueKey<String>('bedside_monitor'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF050B14), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Observations · ${v.time}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
            _cell('HR bpm', '${v.hr}', const Color(0xFF22C55E)),
            _cell('BP mmHg', '${v.sbp}/${v.dbp}', const Color(0xFFF87171)),
            _cell('SpO₂ %', '${v.spo2}${v.onOxygen ? ' O₂' : ''}', const Color(0xFF38BDF8)),
            _cell('RR /min', '${v.rr}', const Color(0xFFFACC15)),
            _cell('Temp °C', v.temp.toStringAsFixed(1), const Color(0xFFE879F9)),
            _cell('ACVPU', v.alert ? 'A' : 'C/V/P/U', const Color(0xFFCBD5E1)),
          ]),
        ],
      ),
    );
  }
}

/// The electronic patient record.
class PatientChartView extends StatelessWidget {
  const PatientChartView({super.key, required this.patient});
  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final Patient p = patient;
    final TextStyle label = TextStyle(color: VuV2Colors.mute, fontSize: 12);
    final TextStyle value = TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w600);
    return DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0B3B5C), borderRadius: BorderRadius.circular(8)),
            child: Text('${p.name} · ${p.age} y · ${p.sex}\nMRN ${p.mrn} · DOB ${p.dob} · ${p.bed}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, height: 1.4)),
          ),
          if (p.allergies.isNotEmpty && !p.allergies.first.startsWith('No known'))
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(8),
              color: const Color(0xFFB91C1C),
              child: Text('ALLERGY: ${p.allergies.join('; ')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          const TabBar(isScrollable: true, tabs: <Widget>[Tab(text: 'Summary'), Tab(text: 'Observations'), Tab(text: 'MAR'), Tab(text: 'Results'), Tab(text: 'Notes')]),
          SizedBox(
            height: 260,
            child: TabBarView(children: <Widget>[
              ListView(padding: const EdgeInsets.all(8), children: <Widget>[
                Text('Presenting', style: label),
                Text(p.presenting, style: value),
                const SizedBox(height: 6),
                Text('History', style: label),
                for (final String h in p.history) Text('• $h', style: value),
                const SizedBox(height: 6),
                Text('Allergies', style: label),
                Text(p.allergies.join('; '), style: value),
                Text('Weight ${p.weightKg.toStringAsFixed(0)} kg', style: label),
              ]),
              p.vitals.isEmpty
                  ? const Center(child: Text('No observations recorded.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataRowMinHeight: 26,
                        dataRowMaxHeight: 30,
                        columns: const <DataColumn>[
                          DataColumn(label: Text('Time')), DataColumn(label: Text('RR')), DataColumn(label: Text('SpO₂')),
                          DataColumn(label: Text('BP')), DataColumn(label: Text('HR')), DataColumn(label: Text('Temp')), DataColumn(label: Text('Pain')),
                        ],
                        rows: <DataRow>[
                          for (final Vitals v in p.vitals)
                            DataRow(cells: <DataCell>[
                              DataCell(Text(v.time)), DataCell(Text('${v.rr}')), DataCell(Text('${v.spo2}${v.onOxygen ? ' O₂' : ''}')),
                              DataCell(Text('${v.sbp}/${v.dbp}')), DataCell(Text('${v.hr}')), DataCell(Text(v.temp.toStringAsFixed(1))), DataCell(Text('${v.pain}/10')),
                            ]),
                        ],
                      ),
                    ),
              ListView(padding: const EdgeInsets.all(8), children: <Widget>[
                for (int i = 0; i < p.medications.length; i++)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${i + 1}. ${p.medications[i].drug} ${p.medications[i].dose} ${p.medications[i].route} ${p.medications[i].frequency}', style: value),
                    subtitle: Text('Due ${p.medications[i].due}${p.medications[i].lastGiven.isEmpty ? '' : ' · last given ${p.medications[i].lastGiven}'}'
                        '${p.medications[i].notes.isEmpty ? '' : '\n${p.medications[i].notes}'}'),
                  ),
              ]),
              ListView(padding: const EdgeInsets.all(8), children: <Widget>[
                if (p.labs.isEmpty) const Text('No results.'),
                for (final Fact f in p.labs) Text('${f.label}: ${f.value}', style: value),
              ]),
              ListView(padding: const EdgeInsets.all(8), children: <Widget>[
                if (p.notes.isEmpty) const Text('No notes.'),
                for (final String n in p.notes) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(n, style: value)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}

/// Clinical notes for atlas structures (shown with the diagram's own facts).
const Map<String, String> _clinical = <String, String>{
  'heart': 'Clinical: chest pain, murmurs and arrhythmias; examined by auscultation at four valve areas.',
  'lungs': 'Clinical: crackles suggest fluid or infection; reduced breath sounds suggest effusion or collapse.',
  'liver': 'Clinical: enlarged in heart failure and liver disease; palpated below the right costal margin.',
  'kidneys': 'Clinical: renal angle tenderness in pyelonephritis; function measured by eGFR.',
  'brain': 'Clinical: assessed with GCS/ACVPU; sudden focal weakness suggests stroke.',
  'stomach': 'Clinical: epigastric pain in gastritis and peptic ulcer disease.',
  'femur': 'Clinical: neck-of-femur fracture after falls in older adults — a shortened, externally rotated leg.',
  'sternum': 'Clinical: landmark for chest compressions (lower half of the sternum).',
  'trachea': 'Clinical: deviation away from a tension pneumothorax is a late sign.',
  'diaphragm': 'Clinical: main muscle of inspiration; supplied by the phrenic nerve (C3–C5).',
};

/// Tap any structure to read about it.
class AnatomyAtlas extends StatefulWidget {
  const AnatomyAtlas({super.key});

  static const List<String> diagrams = <String>['human_organs', 'skeleton', 'respiratory', 'neuron'];

  @override
  State<AnatomyAtlas> createState() => _AnatomyAtlasState();
}

class _AnatomyAtlasState extends State<AnatomyAtlas> {
  String _diagram = AnatomyAtlas.diagrams.first;
  ScienceDiagramRegion? _selected;

  @override
  Widget build(BuildContext context) {
    final ScienceDiagram? d = ScienceDiagramCatalog.diagramById(_diagram);
    if (d == null) return const Text('Atlas unavailable.');
    void tap(ScienceDiagramRegion r) => setState(() => _selected = r);
    final Widget canvas = d.usesAnatomyAsset
        ? AnatomyAssetCanvas(diagram: d, highlightRegionId: _selected?.id, showOverlays: true, onRegionTap: tap)
        : ScienceDiagramCanvas(diagram: d, highlightRegionId: _selected?.id, showOverlays: true, onRegionTap: tap);
    final ScienceDiagramRegion? s = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(spacing: 6, children: <Widget>[
          for (final String id in AnatomyAtlas.diagrams)
            ChoiceChip(
              key: ValueKey<String>('atlas_$id'),
              label: Text(ScienceDiagramCatalog.diagramById(id)?.title ?? id),
              selected: _diagram == id,
              onSelected: (_) => setState(() {
                _diagram = id;
                _selected = null;
              }),
            ),
        ]),
        const SizedBox(height: 8),
        SizedBox(height: 300, child: canvas),
        const SizedBox(height: 6),
        Text('Or choose a structure:', style: TextStyle(color: VuV2Colors.mute, fontSize: 12)),
        Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
          for (final ScienceDiagramRegion r in d.regions)
            ActionChip(key: ValueKey<String>('atlas_region_${r.id}'), label: Text(r.name), onPressed: () => tap(r)),
        ]),
        if (s != null)
          Container(
            key: const ValueKey<String>('atlas_info'),
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: VuV2Colors.stroke), borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text(s.name, style: TextStyle(color: VuV2Colors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
              Text(s.funFact, style: TextStyle(color: VuV2Colors.ink, height: 1.4)),
              if (_clinical[s.id] != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_clinical[s.id]!, style: TextStyle(color: VuV2Colors.mute, height: 1.4))),
            ]),
          ),
      ],
    );
  }
}
