import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/career_models.dart';
import '../../model/tasks.dart';
import '../../store/career_sim_store.dart';
import '../../ui/common.dart';
import '../hospital_cases.dart';
import '../hospital_engine.dart';
import '../lab_panels.dart';
import '../hospital_models.dart';
import 'hospital_painters.dart';
import '../../ui/gg_kit.dart';

const String hospitalDisclaimer =
    'Educational simulation: virtual patients only. Completing it does not grant a nursing or medical licence or permission to treat real patients. '
    'Scenarios follow standard teaching frameworks and have not yet been reviewed by a practising clinician.';

IconData _deptIcon(HospitalDept d) => switch (d) {
      HospitalDept.emergency => Icons.emergency_rounded,
      HospitalDept.icu => Icons.monitor_heart_rounded,
      HospitalDept.ward => Icons.bed_rounded,
      HospitalDept.pediatric => Icons.child_care_rounded,
      HospitalDept.maternity => Icons.pregnant_woman_rounded,
      HospitalDept.theatre => Icons.medical_services_rounded,
      HospitalDept.medsurg => Icons.local_hospital_rounded,
      HospitalDept.cardiology => Icons.favorite_rounded,
      HospitalDept.neurology => Icons.psychology_rounded,
      HospitalDept.oncology => Icons.healing_rounded,
      HospitalDept.pharmacy => Icons.medication_rounded,
      HospitalDept.laboratory => Icons.biotech_rounded,
      HospitalDept.radiology => Icons.document_scanner_rounded,
      HospitalDept.triage => Icons.how_to_reg_rounded,
    };

String caseStatus(CareerSimStore store, String id) {
  final HospitalRun? r = store.profile.hospitalRuns[id];
  final HospitalResult? res = store.latestHospitalResult(id);
  if (r != null && !r.done) return 'In progress';
  if (res == null) return 'New patient';
  if (res.critical) return 'Remediation required';
  return res.passed ? 'Passed (${res.score})' : 'Not passed (${res.score})';
}

/// The hospital: departments and the patients who need attention.
class HospitalScreen extends StatelessWidget {
  const HospitalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Hospital')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text('Mercy Valley Medical Center', style: TextStyle(color: GG.ink, fontSize: 22, fontWeight: FontWeight.w900)),
          Text('You are working as: ${store.clinicalRole == ClinicalRole.medicine ? 'medical student / trainee' : 'student nurse / trainee'}', style: TextStyle(color: GG.mute)),
          const SizedBox(height: 6),
          Text(hospitalDisclaimer, key: const ValueKey<String>('hospital_disclaimer'), style: TextStyle(color: GG.mute, fontSize: 11.5)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
            FilledButton.icon(
              key: const ValueKey<String>('start_shift'),
              onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => const ShiftScreen())),
              icon: const Icon(Icons.schedule_rounded),
              label: Text('Nursing shift: ${wardShift.title}'),
            ),
            FilledButton.tonalIcon(
              key: const ValueKey<String>('open_triage'),
              onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => const TriageScreen())),
              icon: const Icon(Icons.how_to_reg_rounded),
              label: const Text('Reception and triage board'),
            ),
          ]),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
            final int cols = c.maxWidth >= 720 ? 4 : 2;
            final double w = (c.maxWidth - 8 * (cols - 1)) / cols;
            return Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
              for (final HospitalDept d in HospitalDept.values)
                if (d != HospitalDept.triage)
                  SizedBox(
                    width: w,
                    child: Material(
                      color: GG.mute.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        key: ValueKey<String>('dept_${d.name}'),
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).push(ggRoute<void>((_) => HospitalDeptScreen(dept: d))),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                            Icon(_deptIcon(d), color: GG.accent),
                            const SizedBox(height: 4),
                            Text(d.label, maxLines: 2, style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800, fontSize: 13)),
                            Text('${hospitalCases.where((PatientCase x) => x.dept == d).length} patient(s) · '
                                '${hospitalCases.where((PatientCase x) => x.dept == d && !store.profile.hospitalPassed(x.id)).length} need care',
                                style: TextStyle(color: GG.mute, fontSize: 11.5)),
                          ]),
                        ),
                      ),
                    ),
                  ),
            ]);
          }),
        ],
      ),
    );
  }
}

class HospitalDeptScreen extends StatelessWidget {
  const HospitalDeptScreen({super.key, required this.dept});
  final HospitalDept dept;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final List<PatientCase> list = hospitalCases.where((PatientCase c) => c.dept == dept).toList();
    return Scaffold(
      appBar: AppBar(title: Text(dept.label)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          if (list.isEmpty) Text('No patients here right now.', style: TextStyle(color: GG.mute)),
          for (final PatientCase c in list)
            Card(
              child: ListTile(
                key: ValueKey<String>('patient_${c.id}'),
                leading: SizedBox(width: 56, height: 44, child: CustomPaint(painter: PatientPainter(c.appearance, c.vitals))),
                title: Text('${c.name}, ${c.age == 0 ? 'infant' : c.age}'),
                subtitle: Text('${c.complaint}\nPriority ${c.priority} · ${c.level.label} · ${caseStatus(store, c.id)}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final PatientSim? s = await runCareerAction<PatientSim>(context, () => store.startHospitalCase(c.id, restart: store.profile.hospitalRuns[c.id]?.done ?? false));
                  if (s != null && context.mounted) await Navigator.of(context).push(ggRoute<void>((_) => PatientRoomScreen(caseId: c.id)));
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// The patient's room: the patient, the bedside monitor, and every action —
/// talk, examine, equipment, chart, orders, treatment, escalation and notes.
class PatientRoomScreen extends StatefulWidget {
  const PatientRoomScreen({super.key, required this.caseId, this.shift = false});
  final String caseId;

  /// Part of the ward shift (actions go through the shared clock).
  final bool shift;

  @override
  State<PatientRoomScreen> createState() => _PatientRoomScreenState();
}

class _PatientRoomScreenState extends State<PatientRoomScreen> {
  String _tab = 'talk';
  String _target = '';
  final TextEditingController _talk = TextEditingController();
  final TextEditingController _sbar = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  bool _allergyOpen = false;

  @override
  void dispose() {
    _talk.dispose();
    _sbar.dispose();
    _notes.dispose();
    super.dispose();
  }

  PatientSim? _sim(CareerSimStore s) => widget.shift ? s.shiftSim(wardShift.id)?.sims[widget.caseId] : s.hospitalSim(widget.caseId);

  Future<void> _act(CareerSimStore store, SimAction a) async {
    final PatientSim? before = _sim(store);
    final int safety = before?.safety.length ?? 0;
    final bool ok = await runCareerAction<bool>(context, () async {
          if (widget.shift) {
            await store.shiftAct(widget.caseId, a);
          } else {
            await store.hospitalAct(widget.caseId, a);
          }
          return true;
        }) ??
        false;
    if (!ok || !mounted) return;
    final PatientSim? s = _sim(store);
    if (s != null && s.safety.length > safety) {
      final SafetyEvent e = s.safety.last;
      await showDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          key: const ValueKey<String>('safety_dialog'),
          icon: Icon(e.critical ? Icons.report_rounded : Icons.info_outline_rounded, color: e.critical ? GG.red : null),
          title: Text(e.critical ? 'Safety stop' : 'Check your scope'),
          content: Text('${e.action}\n\n${e.explanation}'),
          actions: <Widget>[FilledButton(key: const ValueKey<String>('safety_ok'), onPressed: () => Navigator.of(ctx).pop(), child: const Text('Understood'))],
        ),
      );
    }
    setState(() {});
  }

  static const Map<String, String> _sampleQuestions = <String, String>{
    'intro': 'Hello, my name is Sam and I\'m the student looking after you today.',
    'identity': 'Can you tell me your full name and date of birth?',
    'consent': 'Is it okay if I examine you?',
  };

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final PatientSim? s = _sim(store);
    if (s == null) return const Scaffold(body: Center(child: Text('Start this patient first.')));
    final PatientCase c = s.c;
    final LogLine? warning = s.log.lastWhere((LogLine l) => l.warning, orElse: () => const LogLine(-1, '', ''));
    final int base = widget.shift ? wardShift.start : 8 * 60;
    Widget tab(String id, String label, IconData icon) => ChoiceChip(
          key: ValueKey<String>('tab_$id'),
          avatar: Icon(icon, size: 16),
          label: Text(label),
          selected: _tab == id,
          onSelected: (_) => setState(() => _tab = id),
        );
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: <Widget>[
          Icon(Icons.school_rounded, color: Colors.white),
          SizedBox(width: 8),
          Flexible(child: Text('GradeGlow', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900))),
          SizedBox(width: 12),
          Icon(Icons.local_hospital_rounded, color: GG.red),
          SizedBox(width: 6),
          Flexible(child: Text('Virtual Hospital', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700))),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: SizedBox(
            height: 40,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8), children: <Widget>[
              for (final HospitalDept d in HospitalDept.values)
                TextButton(
                  key: ValueKey<String>('room_dept_${d.name}'),
                  onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => HospitalDeptScreen(dept: d))),
                  child: Text(d.label.split(' ').first == 'Patient' ? 'Triage' : d.label.replaceAll(' Department', '').replaceAll(' and Imaging', '').replaceAll(' & Labor and Delivery', ''),
                      style: TextStyle(color: d == c.dept ? Colors.white : GG.mute, fontWeight: d == c.dept ? FontWeight.w800 : FontWeight.w500, decoration: d == c.dept ? TextDecoration.underline : null)),
                ),
            ]),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
        children: <Widget>[
          Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
            Text('${c.age == 0 ? 'Infant' : '${c.age}${c.sex}'} · ${c.mrn} · ${c.dept.label}', style: TextStyle(color: GG.mute)),
            StatusChip('Time ${s.clock(base)} (+${s.minute} min)'),
            if (!c.child) StatusChip('NEWS2 ${s.news()}', color: s.news() >= 5 ? GG.red : null),
            StatusChip(s.role == ClinicalRole.medicine ? 'Medicine' : 'Nursing', color: GG.mute),
          ]),
          const SizedBox(height: 8),
          LayoutBuilder(builder: (BuildContext context, BoxConstraints b) {
            final bool wide = b.maxWidth >= 860;
            final Widget scene = ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: wide ? 430 : 300,
                child: Stack(children: <Widget>[
                  Positioned.fill(child: CustomPaint(key: const ValueKey<String>('patient_view'), painter: RoomScenePainter(c.appearance, s.v, distress: distressOf(s)))),
                  Positioned(
                    top: 18,
                    left: wide ? b.maxWidth * 0.2 : 120,
                    right: 16,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        key: const ValueKey<String>('patient_says'),
                        constraints: const BoxConstraints(maxWidth: 340),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x44000000), blurRadius: 10)]),
                        child: Text(context.watch<CareerSimStore>().patientSays(s.patientLine), style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  Positioned(left: 12, bottom: 12, child: _QuickActions(sim: s, onAct: (SimAction a) => _act(store, a))),
                ]),
              ),
            );
            final Widget side = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              _PatientInfo(sim: s),
              const SizedBox(height: 10),
              GGPanel(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                  const Text('Actions', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  for (final (String key, String label, String tabId) in const <(String, String, String)>[
                    ('act_vitals', 'Take Vitals', 'equip'),
                    ('act_orders', 'Order Tests', 'orders'),
                    ('act_treat', 'Start Treatment', 'treat'),
                    ('act_chart', 'View Chart', 'chart'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: GGButton(key: ValueKey<String>(key), label: label, color: const Color(0xFF3B5BDB), dense: true, onPressed: () => setState(() => _tab = tabId)),
                    ),
                ]),
              ),
            ]);
            final Widget monitor = BedsideMonitor(sim: s);
            return wide
                ? Column(children: <Widget>[
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Expanded(child: scene), const SizedBox(width: 12), SizedBox(width: 280, child: side)]),
                    const SizedBox(height: 10),
                    monitor,
                  ])
                : Column(children: <Widget>[scene, const SizedBox(height: 8), side, const SizedBox(height: 8), monitor]);
          }),
          if (warning != null && warning.minute >= 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('⚠ ${warning.text}', key: const ValueKey<String>('room_warning'), style: TextStyle(color: GG.red, fontWeight: FontWeight.w700)),
            ),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
            tab('talk', 'Talk', Icons.chat_rounded),
            tab('exam', 'Examine', Icons.pan_tool_rounded),
            tab('equip', 'Equipment', Icons.medical_services_rounded),
            tab('chart', 'Chart', Icons.folder_shared_rounded),
            tab('orders', 'Orders', Icons.science_rounded),
            tab('treat', 'Treat', Icons.healing_rounded),
            tab('escalate', 'Escalate', Icons.phone_in_talk_rounded),
            tab('document', 'Document', Icons.edit_note_rounded),
          ]),
          const SizedBox(height: 8),
          ..._panel(store, s),
          const SizedBox(height: 12),
          ExpansionTile(
            key: const ValueKey<String>('room_log'),
            tilePadding: EdgeInsets.zero,
            title: Text('Activity (${s.log.length})'),
            children: <Widget>[
              for (final LogLine l in s.log.reversed.take(40))
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text('${s.clock(base - s.minute + l.minute)} ${l.who == 'you' ? 'You' : l.who[0].toUpperCase() + l.who.substring(1)}: ${l.text}',
                        style: TextStyle(color: l.warning ? GG.red : GG.ink, fontSize: 12.5)),
                  ),
                ),
            ],
          ),
          Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
            OutlinedButton.icon(
              key: const ValueKey<String>('case_hint'),
              onPressed: () => _act(store, const SimAction('hint', '')),
              icon: const Icon(Icons.lightbulb_outline_rounded),
              label: const Text('Ask the supervisor for a hint'),
            ),
            OutlinedButton.icon(
              key: const ValueKey<String>('case_wait'),
              onPressed: () => _act(store, const SimAction('wait', '5')),
              icon: const Icon(Icons.hourglass_bottom_rounded),
              label: const Text('Wait 5 minutes'),
            ),
            if (!widget.shift)
              BusyButton(
                key: const ValueKey<String>('case_finish'),
                label: 'Finish and debrief',
                icon: Icons.flag_rounded,
                onPressed: () async {
                  final HospitalResult? r = await runCareerAction<HospitalResult>(context, () => store.finishHospitalCase(widget.caseId));
                  if (r != null && context.mounted) {
                    await Navigator.of(context).pushReplacement(ggRoute<void>((_) => CaseDebriefScreen(sim: s, result: r)));
                  }
                },
              ),
          ]),
          if (s.log.any((LogLine l) => l.who == 'supervisor'))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Supervisor: ${s.log.lastWhere((LogLine l) => l.who == 'supervisor').text}', key: const ValueKey<String>('supervisor_says'), style: TextStyle(color: GG.ink)),
            ),
        ],
      ),
    );
  }

  List<Widget> _panel(CareerSimStore store, PatientSim s) {
    final PatientCase c = s.c;
    Widget btn(String key, String label, VoidCallback onTap, {bool done = false, IconData? icon}) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: OutlinedButton.icon(
            key: ValueKey<String>(key),
            style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
            onPressed: onTap,
            icon: Icon(done ? Icons.check_circle_rounded : (icon ?? Icons.play_arrow_rounded), size: 18, color: done ? GG.green : null),
            label: Text(label),
          ),
        );
    switch (_tab) {
      case 'talk':
        final List<Topic> topics = <Topic>[...c.topics, ...generalTopics];
        return <Widget>[
          Row(children: <Widget>[
            Expanded(
              child: TextField(
                key: const ValueKey<String>('talk_field'),
                controller: _talk,
                decoration: const InputDecoration(hintText: 'Ask or tell the patient something…', border: OutlineInputBorder(), isDense: true),
                onSubmitted: (_) {},
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              key: const ValueKey<String>('talk_send'),
              onPressed: () async {
                final String q = _talk.text.trim();
                if (q.isEmpty) return;
                _talk.clear();
                await _act(store, SimAction('ask', '', q));
              },
              icon: const Icon(Icons.send_rounded),
            ),
          ]),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
            for (final Topic t in topics)
              ActionChip(
                key: ValueKey<String>('topic_${t.id}'),
                avatar: s.has('ask:${t.id}') ? const Icon(Icons.check_rounded, size: 16) : null,
                label: Text(t.label),
                onPressed: () => _act(store, SimAction('ask', '', _sampleQuestions[t.id] ?? t.label)),
              ),
          ]),
        ];
      case 'exam':
        return <Widget>[for (final Exam e in exams) btn('exam_${e.id}', e.label, () => _act(store, SimAction('exam', e.id)), done: s.has('exam:${e.id}'))];
      case 'equip':
        return <Widget>[
          Text('Equipment trolley', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          for (final Equipment e in equipment) btn('equip_${e.id}', e.label, () => _act(store, SimAction('measure', e.id)), done: s.has('measure:${e.id}'), icon: Icons.monitor_heart_outlined),
          btn('equip_oxygen', 'Oxygen delivery', () => _act(store, const SimAction('intervene', 'oxygen')), done: s.has('do:oxygen'), icon: Icons.air_rounded),
          btn('equip_iv', 'IV equipment (cannula)', () => _act(store, const SimAction('intervene', 'iv_access')), done: s.has('do:iv_access'), icon: Icons.vaccines_rounded),
          btn('equip_defib', 'Defibrillator (training device)', () => _act(store, const SimAction('intervene', 'defib')), icon: Icons.bolt_rounded),
          if (s.has('measure:ecg')) ...<Widget>[const SizedBox(height: 6), EcgStrip(rhythm: c.ecg, hr: s.v.hr)],
        ];
      case 'chart':
        return <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: GGButton(
              key: const ValueKey<String>('open_records'),
              icon: Icons.folder_shared_rounded,
              label: 'Open patient records',
              onPressed: () => Navigator.of(context).push(ggRoute<void>((_) => PatientRecordsScreen(caseId: widget.caseId, shift: widget.shift))),
            ),
          ),
          const SizedBox(height: 8),
          SectionCard(
            title: 'Patient record',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('${c.name} · ${c.age == 0 ? 'infant' : '${c.age} years'} · ${c.sex} · MRN ${c.mrn}'),
              Text('Arrived: ${c.arrival}'),
              Text('Presenting complaint: ${c.complaint}'),
              const SizedBox(height: 6),
              Text('Medical history', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
              BulletList(c.history),
              Text('Medication list', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
              BulletList(c.medications.isEmpty ? const <String>['None recorded'] : c.medications),
              const SizedBox(height: 4),
              if (_allergyOpen || s.has('chart:allergies'))
                Text('ALLERGIES: ${c.allergies.isEmpty ? 'No known allergies' : c.allergies.join('; ')}', key: const ValueKey<String>('allergy_list'), style: TextStyle(color: GG.red, fontWeight: FontWeight.w800))
              else
                FilledButton.tonal(
                  key: const ValueKey<String>('chart_allergies'),
                  onPressed: () async {
                    await _act(store, const SimAction('chart', 'allergies'));
                    setState(() => _allergyOpen = true);
                  },
                  child: const Text('Open the allergy record'),
                ),
            ]),
          ),
          SectionCard(
            title: 'Vital signs chart',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              SizedBox(height: 90, width: double.infinity, child: CustomPaint(painter: VitalsChartPainter(s.chart))),
              for (final VitalsPoint p in s.chart.reversed.take(8))
                Text('+${p.minute} min  HR ${p.v.hr.round()}  BP ${p.v.sbp.round()}/${p.v.dbp.round()}  RR ${p.v.rr.round()}  SpO₂ ${p.v.spo2.round()}%  T ${p.v.temp.toStringAsFixed(1)}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              if (s.chart.isEmpty) Text('No observations recorded yet.', style: TextStyle(color: GG.mute)),
            ]),
          ),
          SectionCard(
            title: 'Progress notes and results',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              for (final String n in c.notes) Text('• $n'),
              if (s.notes.isNotEmpty) Text('Your note: ${s.notes}'),
              for (final MapEntry<String, String> r in s.results.entries) ...<Widget>[
                Text('${testDef(r.key)?.label ?? r.key}: ${r.value}', key: ValueKey<String>('result_${r.key}')),
                if (c.tests[r.key]?.image != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    height: 140,
                    width: 140,
                    child: CustomPaint(painter: ImagingPainter(c.tests[r.key]!.image!)),
                  ),
              ],
              for (final MapEntry<String, int> o in s.orders.entries)
                if (s.minute < o.value) Text('${testDef(o.key)?.label ?? o.key}: pending (ready at +${o.value} min)', style: TextStyle(color: GG.mute)),
            ]),
          ),
        ];
      case 'orders':
        return <Widget>[
          Text(s.role == ClinicalRole.nursing ? 'Nurses can start tests marked "protocol". For others, escalate with a recommendation.' : 'Order only what answers a clinical question.',
              style: TextStyle(color: GG.mute, fontSize: 12.5)),
          const SizedBox(height: 6),
          for (final TestDef t in testCatalog)
            btn('order_${t.id}', '${t.label}${t.nurse ? ' (protocol)' : ''}', () => _act(store, SimAction('order', t.id)), done: s.orders.containsKey(t.id), icon: t.imaging ? Icons.document_scanner_rounded : Icons.bloodtype_rounded),
        ];
      case 'treat':
        return <Widget>[
          for (final ActionDef a in s.interventions)
            if (a.id != 'defib') btn('do_${a.id}', a.label, () => _act(store, SimAction('intervene', a.id)), done: s.has('do:${a.id}')),
        ];
      case 'escalate':
        return <Widget>[
          Text('Who do you call?', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
          Wrap(spacing: 6, runSpacing: 6, children: <Widget>[
            for (int i = 0; i < escalationTargets.length; i++)
              ChoiceChip(key: ValueKey<String>('esc_target_$i'), label: Text(escalationTargets[i]), selected: _target == escalationTargets[i], onSelected: (_) => setState(() => _target = escalationTargets[i])),
          ]),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey<String>('sbar_field'),
            controller: _sbar,
            minLines: 4,
            maxLines: 10,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'SBAR: Situation, Background, Assessment, Recommendation'),
          ),
          const SizedBox(height: 6),
          FilledButton.icon(
            key: const ValueKey<String>('escalate_send'),
            onPressed: _target.isEmpty || _sbar.text.trim().isEmpty ? null : () => _act(store, SimAction('escalate', _target, _sbar.text.trim())),
            icon: const Icon(Icons.phone_in_talk_rounded),
            label: const Text('Call'),
          ),
          if (s.has('escalated')) Text('Escalated to ${s.escalatedTo}.', style: TextStyle(color: GG.green)),
        ];
      default:
        final List<ChoiceOption> opts = s.role == ClinicalRole.medicine ? c.diagnosis : c.nursingPriority;
        return <Widget>[
          Text(s.role == ClinicalRole.medicine ? 'Working diagnosis' : 'Nursing priority / care plan', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
          for (final ChoiceOption o in opts)
            RadioListTile<String>(
              key: ValueKey<String>('dx_${o.id}'),
              contentPadding: EdgeInsets.zero,
              value: o.id,
              groupValue: s.diagnosis,
              title: Text(o.label),
              onChanged: (String? v) => _act(store, SimAction('diagnose', o.id)),
            ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey<String>('notes_field'),
            controller: _notes,
            minLines: 4,
            maxLines: 12,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Clinical note: assessment, vital signs, actions, plan'),
          ),
          const SizedBox(height: 6),
          FilledButton.icon(
            key: const ValueKey<String>('notes_save'),
            onPressed: () => _act(store, SimAction('document', '', _notes.text.trim())),
            icon: const Icon(Icons.save_rounded),
            label: Text(s.has('document') ? 'Update note' : 'Save note'),
          ),
        ];
    }
  }
}

/// After a case: what happened, what was right, what was missed, safety.
class CaseDebriefScreen extends StatelessWidget {
  const CaseDebriefScreen({super.key, required this.sim, required this.result});
  final PatientSim sim;
  final HospitalResult result;

  @override
  Widget build(BuildContext context) {
    final CaseScore sc = sim.score();
    final CareerSimStore store = context.read<CareerSimStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Debrief')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          if (result.critical)
            Container(
              key: const ValueKey<String>('critical_banner'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: GG.red.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Text('Critical safety issue — remediation required. A high score cannot hide this: repeat the case before progressing.',
                  style: TextStyle(color: GG.red, fontWeight: FontWeight.w800)),
            ),
          SectionCard(
            title: '${result.passed ? 'Passed' : 'Not passed'}: ${result.score}/100',
            subtitle: sim.c.name,
            trailing: const ValidatedBadge(label: 'Clinical rubric'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('What happened', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
              Text(sc.outcome, key: const ValueKey<String>('debrief_outcome')),
              const SizedBox(height: 8),
              for (final MapEntry<String, int> e in sc.categories.entries) LabeledBar(label: e.key[0].toUpperCase() + e.key.substring(1), value: e.value),
            ]),
          ),
          SectionCard(
            title: 'Vital signs over the case',
            child: SizedBox(height: 100, width: double.infinity, child: CustomPaint(painter: VitalsChartPainter(sim.chart))),
          ),
          if (sc.done.isNotEmpty) SectionCard(title: 'Appropriate actions', child: BulletList(sc.done, icon: Icons.check_circle_outline_rounded, color: GG.green)),
          if (sc.missed.isNotEmpty || sc.late.isNotEmpty)
            SectionCard(title: 'Missed or late', child: BulletList(<String>[...sc.missed, ...sc.late], icon: Icons.error_outline_rounded, color: GG.red)),
          if (sc.unnecessary.isNotEmpty) SectionCard(title: 'Not needed', child: BulletList(sc.unnecessary)),
          if (sc.safety.isNotEmpty)
            SectionCard(title: 'Safety', child: BulletList(<String>[for (final SafetyEvent e in sc.safety) '${e.critical ? 'CRITICAL' : 'Scope'} — ${e.action}: ${e.explanation}'], color: GG.red)),
          if (sc.improve.isNotEmpty) SectionCard(title: 'What to improve', child: BulletList(sc.improve)),
          if (sim.c.teaching.isNotEmpty) SectionCard(title: 'Key learning points', child: BulletList(sim.c.teaching)),
          Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
            FilledButton(key: const ValueKey<String>('debrief_done'), onPressed: () => Navigator.of(context).pop(), child: const Text('Back to the department')),
            OutlinedButton(
              key: const ValueKey<String>('case_retry'),
              onPressed: () async {
                await store.startHospitalCase(sim.c.id, restart: true, role: sim.role);
                if (context.mounted) await Navigator.of(context).pushReplacement(ggRoute<void>((_) => PatientRoomScreen(caseId: sim.c.id)));
              },
              child: const Text('Repeat this case'),
            ),
          ]),
        ],
      ),
    );
  }
}

/// A full nursing shift: three patients, one clock, a handover at the end.
class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final TextEditingController _handover = TextEditingController();
  HospitalResult? _result;

  @override
  void dispose() {
    _handover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final ShiftSim? sh = store.shiftSim(wardShift.id);
    final HospitalRun? run = store.profile.hospitalRuns[wardShift.id];
    final HospitalResult? res = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Ward shift')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text(wardShift.title, style: TextStyle(color: GG.ink, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(hospitalDisclaimer, style: TextStyle(color: GG.mute, fontSize: 11.5)),
          SectionCard(title: 'Handover from the night shift', child: Text(wardShift.brief)),
          if (res != null)
            SectionCard(
              key: const ValueKey<String>('shift_result'),
              title: 'Shift ${res.passed ? 'passed' : 'not passed'}: ${res.score}/100',
              subtitle: res.critical ? 'Critical safety issue — remediation required.' : null,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                for (final MapEntry<String, int> e in res.categories.entries) LabeledBar(label: e.key, value: e.value),
                Text(res.outcome),
                BulletList(res.notes),
              ]),
            )
          else if (sh == null || run == null || run.done)
            FilledButton.icon(
              key: const ValueKey<String>('shift_begin'),
              onPressed: () => runCareerAction<ShiftSim>(context, () => store.startShift(restart: run?.done ?? false)),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start the shift at 07:00'),
            )
          else ...<Widget>[
            StatusChip('Shift clock ${sh.sims.values.first.clock(wardShift.start)}'),
            const SizedBox(height: 8),
            for (final MapEntry<String, PatientSim> e in sh.sims.entries)
              Card(
                child: ListTile(
                  key: ValueKey<String>('shift_patient_${e.key}'),
                  leading: SizedBox(width: 56, height: 44, child: CustomPaint(painter: PatientPainter(e.value.c.appearance, e.value.v, distress: distressOf(e.value)))),
                  title: Text(e.value.c.name),
                  subtitle: Text('${e.value.c.complaint}\n${e.value.actions.length} actions · ${e.value.log.where((LogLine l) => l.warning).isEmpty ? 'no warnings' : '⚠ ${e.value.log.lastWhere((LogLine l) => l.warning).text}'}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(ggRoute<void>((_) => PatientRoomScreen(caseId: e.key, shift: true))),
                ),
              ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey<String>('handover_field'),
              controller: _handover,
              minLines: 5,
              maxLines: 14,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'End-of-shift handover (each patient: status, results, risks, what is outstanding)'),
            ),
            const SizedBox(height: 6),
            BusyButton(
              key: const ValueKey<String>('shift_finish'),
              label: 'Hand over and finish the shift',
              icon: Icons.assignment_turned_in_rounded,
              onPressed: () async {
                final HospitalResult? r = await runCareerAction<HospitalResult>(context, () => store.finishShift(_handover.text));
                if (r != null && mounted) setState(() => _result = r);
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Reception and triage: prioritise arrivals 1 (immediate) – 5 (non-urgent).
class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  final Map<String, int> _levels = <String, int>{};
  HospitalResult? _result;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final HospitalResult? r = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Reception and triage')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text('Six people have just arrived. Give each a triage level: 1 immediate, 2 emergent, 3 urgent, 4 less urgent, 5 non-urgent.', style: TextStyle(color: GG.ink)),
          const SizedBox(height: 8),
          for (final TriageArrival a in triageArrivals)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text('${a.name}, ${a.age}', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800)),
                  Text(a.story),
                  Text(a.vitals, style: TextStyle(color: GG.mute)),
                  Wrap(spacing: 6, children: <Widget>[
                    for (int n = 1; n <= 5; n++)
                      ChoiceChip(key: ValueKey<String>('tri_${a.id}_$n'), label: Text('$n'), selected: _levels[a.id] == n, onSelected: r != null ? null : (_) => setState(() => _levels[a.id] = n)),
                  ]),
                ]),
              ),
            ),
          if (r == null)
            BusyButton(
              key: const ValueKey<String>('triage_submit'),
              label: 'Submit triage decisions',
              icon: Icons.send_rounded,
              onPressed: () async {
                final HospitalResult? x = await runCareerAction<HospitalResult>(context, () => store.submitTriage(Map<String, int>.from(_levels)));
                if (x != null && mounted) setState(() => _result = x);
              },
            )
          else
            SectionCard(
              key: const ValueKey<String>('triage_result'),
              title: 'Triage score ${r.score}/100${r.critical ? ' — critical under-triage' : ''}',
              child: BulletList(r.notes.isEmpty ? const <String>['Every patient was triaged correctly.'] : r.notes),
            ),
        ],
      ),
    );
  }
}

/// Workplace task view: a hospital placement assigned at work.
class HospitalWorkView extends StatelessWidget {
  const HospitalWorkView({super.key, required this.spec, required this.onGraded});
  final HospitalTaskSpec spec;
  final Future<void> Function(TaskResult result) onGraded;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final bool shift = spec.caseId == wardShift.id;
    final int issued = store.profile.currentJob?.open?.issuedDay ?? 0;
    final HospitalResult? done = store.latestHospitalResult(spec.caseId, sinceDay: issued);
    final HospitalRun? run = store.profile.hospitalRuns[spec.caseId];
    final bool inProgress = run != null && !run.done;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text(hospitalDisclaimer, style: TextStyle(color: GG.mute, fontSize: 11.5)),
      const SizedBox(height: 8),
      FilledButton.icon(
        key: const ValueKey<String>('work_open_patient'),
        onPressed: () async {
          if (shift) {
            await Navigator.of(context).push(ggRoute<void>((_) => const ShiftScreen()));
            return;
          }
          final PatientSim? s = await runCareerAction<PatientSim>(context, () => store.startHospitalCase(spec.caseId, restart: !inProgress));
          if (s != null && context.mounted) await Navigator.of(context).push(ggRoute<void>((_) => PatientRoomScreen(caseId: spec.caseId)));
        },
        icon: const Icon(Icons.local_hospital_rounded),
        label: Text(shift ? 'Go to the ward shift' : (inProgress ? 'Return to the patient' : 'Go to the patient')),
      ),
      if (done != null) ...<Widget>[
        const SizedBox(height: 8),
        Text('Result: ${done.score}/100 · ${done.passed ? 'passed' : (done.critical ? 'critical safety issue' : 'not passed')}', key: const ValueKey<String>('work_hospital_result'),
            style: TextStyle(color: done.passed ? GG.green : GG.red, fontWeight: FontWeight.w800)),
        FilledButton.tonalIcon(
          key: const ValueKey<String>('work_attach_hospital'),
          onPressed: () => onGraded(TaskResult(
            taskId: spec.id,
            score: done.score,
            passed: done.passed,
            feedback: <String>[done.outcome, ...done.notes.take(3)],
          )),
          icon: const Icon(Icons.attach_file_rounded),
          label: const Text('Attach this result to the assignment'),
        ),
      ],
    ]);
  }
}


/// "What would you like to do?" — three sensible next steps (not answers).
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.sim, required this.onAct});
  final PatientSim sim;
  final ValueChanged<SimAction> onAct;

  static const List<(String, String, SimAction)> all = <(String, String, SimAction)>[
    ('do:hand_hygiene', 'Clean your hands', SimAction('intervene', 'hand_hygiene')),
    ('ask:intro', 'Introduce yourself', SimAction('ask', '', 'Hello, my name is Sam and I am the student looking after you today.')),
    ('exam:chest', 'Assess her breathing', SimAction('exam', 'chest')),
    ('measure:pulse_ox', 'Check heart rate and oxygen', SimAction('measure', 'pulse_ox')),
    ('ask:history', 'Review medical history', SimAction('ask', '', 'Can you tell me about your medical history?')),
    ('measure:bp', 'Take blood pressure', SimAction('measure', 'bp')),
  ];

  @override
  Widget build(BuildContext context) {
    final bool she = sim.c.sex == 'F';
    final List<(String, String, SimAction)> next = all.where(((String, String, SimAction) x) => !sim.has(x.$1)).take(3).toList();
    if (next.isEmpty) return const SizedBox.shrink();
    return Container(
      width: 270,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.94), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
        const Text('What would you like to do?', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        for (int i = 0; i < next.length; i++)
          InkWell(
            key: ValueKey<String>('quick_$i'),
            onTap: () => onAct(next[i].$3),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: <Widget>[
                const Icon(Icons.radio_button_unchecked, size: 16, color: Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                Expanded(child: Text(she ? next[i].$2 : next[i].$2.replaceAll('her ', 'his '), style: const TextStyle(color: Color(0xFF0F172A)))),
              ]),
            ),
          ),
      ]),
    );
  }
}

String _vitalText(PatientSim s, String k) {
  final Vitals? v = s.monitorOn ? s.v : (s.chart.isEmpty ? null : s.chart.last.v);
  final bool measured = s.monitorOn ||
      (switch (k) {
        'hr' => s.has('measure:pulse_ox'),
        'bp' => s.has('measure:bp'),
        'temp' => s.has('measure:thermometer'),
        'spo2' => s.has('measure:pulse_ox'),
        'rr' => s.has('measure:resp'),
        _ => false,
      });
  if (v == null || !measured) return '--';
  return switch (k) {
    'hr' => '${v.hr.round()} bpm',
    'bp' => '${v.sbp.round()}/${v.dbp.round()} mmHg',
    'temp' => '${v.temp.toStringAsFixed(1)}°C',
    'spo2' => '${v.spo2.round()}%',
    _ => '${v.rr.round()}/min',
  };
}

bool _abnormal(Vitals v, String k) => switch (k) {
      'hr' => v.hr > 100 || v.hr < 50,
      'bp' => v.sbp < 100 || v.sbp > 160,
      'temp' => v.temp >= 38 || v.temp < 36,
      'spo2' => v.spo2 < 94,
      _ => v.rr > 20 || v.rr < 10,
    };

class _PatientInfo extends StatelessWidget {
  const _PatientInfo({required this.sim});
  final PatientSim sim;

  @override
  Widget build(BuildContext context) {
    final PatientCase c = sim.c;
    return GGPanel(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        const Text('Patient Info', style: TextStyle(color: GG.ink, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(c.name, style: const TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
        Text('Age: ${c.age == 0 ? 'infant' : c.age} | ID: ${c.mrn}', style: const TextStyle(color: GG.mute, fontSize: 12.5)),
        Text('History: ${c.history.take(2).join(', ')}', style: const TextStyle(color: GG.mute, fontSize: 12.5)),
        const SizedBox(height: 8),
        for (final (String k, String label) in const <(String, String)>[('hr', 'HR'), ('bp', 'BP'), ('temp', 'Temp'), ('spo2', 'SpO₂'), ('rr', 'RR')])
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: <Widget>[
              Icon(Icons.add_circle_rounded, size: 16, color: _vitalText(sim, k) != '--' && _abnormal(sim.v, k) ? GG.red : GG.mute),
              const SizedBox(width: 6),
              Text('$label: ', style: const TextStyle(color: GG.ink)),
              Text(_vitalText(sim, k), key: ValueKey<String>('info_$k'), style: TextStyle(color: _vitalText(sim, k) != '--' && _abnormal(sim.v, k) ? const Color(0xFFFF6B6B) : GG.ink, fontWeight: FontWeight.w700)),
            ]),
          ),
        if (!c.child) Text('NEWS2: ${sim.news()} · ${newsBand(sim.news())}', style: TextStyle(color: sim.news() >= 5 ? const Color(0xFFFF6B6B) : GG.mute, fontSize: 12)),
      ]),
    );
  }
}

/// The electronic health record: overview, vitals, lab results, imaging,
/// care plan and notes, with a sidebar like a hospital EHR.
class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key, required this.caseId, this.shift = false});
  final String caseId;
  final bool shift;

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  int _section = 2;

  @override
  Widget build(BuildContext context) {
    final CareerSimStore store = context.watch<CareerSimStore>();
    final PatientSim? s = widget.shift ? store.shiftSim(wardShift.id)?.sims[widget.caseId] : store.hospitalSim(widget.caseId);
    if (s == null) return const Scaffold(body: Center(child: Text('No record.')));
    final PatientCase c = s.c;
    final Map<String, String> results = s.results;
    Widget panel(String title, Widget child) => GGPanel(margin: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(title, style: const TextStyle(color: GG.ink, fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 8), child]));
    final List<Widget> body = switch (_section) {
      0 => <Widget>[
          panel('Overview', Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('${c.name} · ${c.age == 0 ? 'infant' : '${c.age} years'} · ${c.sex} · MRN ${c.mrn}'),
            Text('Department: ${c.dept.label} · Arrived ${c.arrival}'),
            Text('Presenting complaint: ${c.complaint}'),
            const SizedBox(height: 6),
            Text('History: ${c.history.join('; ')}'),
            Text('Medications: ${c.medications.isEmpty ? 'none' : c.medications.join(', ')}'),
            Text(s.has('chart:allergies') || s.has('allergies') ? 'Allergies: ${c.allergies.isEmpty ? 'no known allergies' : c.allergies.join('; ')}' : 'Allergies: open the allergy record from the room to review.',
                style: const TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w700)),
          ])),
        ],
      1 => <Widget>[
          panel('Vital signs', Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            SizedBox(height: 140, width: double.infinity, child: CustomPaint(painter: VitalsChartPainter(s.chart))),
            const Text('Green HR · Red systolic BP · Blue SpO₂ · Yellow RR', style: TextStyle(color: GG.mute, fontSize: 11.5)),
            for (final VitalsPoint p in s.chart.reversed.take(12))
              Text('+${p.minute} min  HR ${p.v.hr.round()}  BP ${p.v.sbp.round()}/${p.v.dbp.round()}  RR ${p.v.rr.round()}  SpO₂ ${p.v.spo2.round()}%  T ${p.v.temp.toStringAsFixed(1)}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            if (s.chart.isEmpty) const Text('No observations recorded yet.', style: TextStyle(color: GG.mute)),
          ])),
        ],
      2 => <Widget>[
          LayoutBuilder(builder: (BuildContext context, BoxConstraints b) {
            final Widget labs = panel(
              'Lab Results',
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  if (results.keys.where((String k) => !(testDef(k)?.imaging ?? false) && k != 'ecg').isEmpty)
                    const Text('No laboratory results yet. Order tests from the room.', style: TextStyle(color: Color(0xFF475569))),
                  for (final MapEntry<String, String> r in results.entries)
                    if (!(testDef(r.key)?.imaging ?? false))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                            SizedBox(width: 130, child: Text(testDef(r.key)?.label ?? r.key, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 12.5))),
                            Expanded(
                              child: Text('${r.value}${(c.tests[r.key]?.abnormal ?? false) ? ' ↑' : ''}',
                                  key: ValueKey<String>('rec_${r.key}'), style: TextStyle(color: (c.tests[r.key]?.abnormal ?? false) ? const Color(0xFFDC2626) : const Color(0xFF0F172A), fontSize: 12.5)),
                            ),
                          ]),
                          if (labPanel(c, r.key) case final List<LabRow> rows) LabPanelTable(testId: r.key, rows: rows),
                        ]),
                      ),
                ]),
              ),
            );
            final Widget ecg = panel(
              'ECG Result',
              s.has('measure:ecg')
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Container(
                        height: 90,
                        decoration: BoxDecoration(color: const Color(0xFF0B1220), borderRadius: BorderRadius.circular(8)),
                        child: CustomPaint(painter: WavePainter(rhythm: c.ecg, hr: s.v.hr, phase: 0), size: const Size(double.infinity, 90)),
                      ),
                      const SizedBox(height: 6),
                      Text(c.tests['ecg']?.result ?? 'Sinus rhythm, no acute changes.', style: const TextStyle(color: GG.ink, fontSize: 12.5)),
                    ])
                  : const Text('No ECG recorded yet.', style: TextStyle(color: GG.mute)),
            );
            return b.maxWidth >= 760
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Expanded(child: labs), const SizedBox(width: 12), Expanded(child: ecg)])
                : Column(children: <Widget>[labs, ecg]);
          }),
          _imaging(c, results, panel),
        ],
      3 => <Widget>[_imaging(c, results, panel)],
      4 => <Widget>[
          panel('Care plan', Text(s.diagnosis == null
              ? 'No working diagnosis or nursing priority recorded yet (Document tab in the room).'
              : '${s.role == ClinicalRole.medicine ? 'Working diagnosis' : 'Nursing priority'}: ${(s.role == ClinicalRole.medicine ? c.diagnosis : c.nursingPriority).where((ChoiceOption o) => o.id == s.diagnosis).map((ChoiceOption o) => o.label).join()}')),
        ],
      _ => <Widget>[
          panel('Notes', Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            for (final String n in c.notes) Text('• $n'),
            Text(s.notes.isEmpty ? 'No clinical note written yet.' : s.notes),
            if (s.sbar.isNotEmpty) ...<Widget>[const SizedBox(height: 6), Text('Escalation (SBAR) to ${s.escalatedTo}: ${s.sbar}')],
          ])),
        ],
    };
    return Scaffold(
      appBar: AppBar(title: Text('Patient Records - ${c.name}')),
      body: GGSidebarLayout(
        keyPrefix: 'rec',
        items: const <(String, IconData)>[
          ('Overview', Icons.dashboard_rounded),
          ('Vitals', Icons.monitor_heart_rounded),
          ('Lab Results', Icons.science_rounded),
          ('Imaging', Icons.document_scanner_rounded),
          ('Care Plan', Icons.assignment_rounded),
          ('Notes', Icons.edit_note_rounded),
        ],
        selected: _section,
        onSelect: (int i) => setState(() => _section = i),
        child: DecoratedBox(decoration: const BoxDecoration(gradient: GG.page), child: ListView(padding: const EdgeInsets.all(16), children: body)),
      ),
    );
  }

  Widget _imaging(PatientCase c, Map<String, String> results, Widget Function(String, Widget) panel) {
    final List<MapEntry<String, String>> imgs = results.entries.where((MapEntry<String, String> r) => testDef(r.key)?.imaging ?? false).toList();
    return panel(
      'Imaging',
      imgs.isEmpty
          ? const Text('No imaging yet.', style: TextStyle(color: GG.mute))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              for (final MapEntry<String, String> r in imgs) ...<Widget>[
                Text(testDef(r.key)?.label ?? r.key, style: const TextStyle(color: GG.ink, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Container(
                  height: 220,
                  width: 260,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: GG.stroke)),
                  child: CustomPaint(painter: ImagingPainter(c.tests[r.key]?.image ?? (r.key == 'ct_head' ? 'ct_head_normal' : 'cxr_normal'))),
                ),
                const SizedBox(height: 4),
                Text('Report: ${r.value}', style: const TextStyle(color: GG.ink, fontSize: 12.5)),
                const SizedBox(height: 10),
              ],
            ]),
    );
  }
}

/// A lab report table: test, result, units, reference range and flag, with
/// out-of-range values in red.
class LabPanelTable extends StatelessWidget {
  const LabPanelTable({super.key, required this.testId, required this.rows});
  final String testId;
  final List<LabRow> rows;

  @override
  Widget build(BuildContext context) {
    const TextStyle head = TextStyle(color: Color(0xFF475569), fontSize: 11.5, fontWeight: FontWeight.w700);
    const TextStyle cell = TextStyle(color: Color(0xFF0F172A), fontSize: 12.5);
    const TextStyle bad = TextStyle(color: Color(0xFFDC2626), fontSize: 12.5, fontWeight: FontWeight.w800);
    Widget pad(Widget w) => Padding(padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4), child: w);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Table(
        key: ValueKey<String>('panel_$testId'),
        columnWidths: const <int, TableColumnWidth>{0: FlexColumnWidth(2.4), 1: FlexColumnWidth(1.2), 2: FlexColumnWidth(1.4), 3: FlexColumnWidth(1.6), 4: FixedColumnWidth(34)},
        border: const TableBorder(horizontalInside: BorderSide(color: Color(0xFFE2E8F0))),
        children: <TableRow>[
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
            children: <Widget>[pad(const Text('Test', style: head)), pad(const Text('Result', style: head)), pad(const Text('Units', style: head)), pad(const Text('Reference', style: head)), pad(const Text('Flag', style: head))],
          ),
          for (final LabRow r in rows)
            TableRow(children: <Widget>[
              pad(Text(r.name, style: cell)),
              pad(Text(r.shown, key: ValueKey<String>('rec_${testId}_${r.id}'), style: r.abnormal ? bad : cell)),
              pad(Text(r.unit, style: const TextStyle(color: Color(0xFF475569), fontSize: 11.5))),
              pad(Text(r.range, style: const TextStyle(color: Color(0xFF475569), fontSize: 11.5))),
              pad(Text(switch (r.flag) { 'H' => 'H ↑', 'L' => 'L ↓', _ => '' }, style: bad)),
            ]),
        ],
      ),
    );
  }
}
