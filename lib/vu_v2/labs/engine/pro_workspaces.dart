import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'lab_session.dart';

class CsWorkspace extends StatefulWidget {
  const CsWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  State<CsWorkspace> createState() => _CsWorkspaceState();
}

class _CsWorkspaceState extends State<CsWorkspace> {
  static const String _broken = '''
Node insert(Node n, int v) {
  if (n == null) return Node(v);
  if (v > n.value) n.left = insert(n.left, v); // reversed comparator
  else n.right = insert(n.right, v);
  return n;
}
''';

  late final TextEditingController _code = TextEditingController(text: _broken);

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _run() {
    final String src = _code.text.replaceAll(' ', '');
    final bool fixed = src.contains('v<n.value') && !src.contains('v>n.value');
    widget.session.setVar('patched', fixed);
    if (fixed) {
      widget.session.act(
        'test_pass',
        inspect: 'insert(5), insert(3), insert(7) — left < node < right holds.',
        say: 'Tests passed because you repaired the comparator, not because you pressed a Patch chip.',
      );
      widget.session.act('patch');
    } else {
      widget.session.act(
        'trace_miss',
        pause: true,
        say: 'The tree still violates BST. Left children must be smaller. Run after you edit the source.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool patched = widget.session.getv<bool>('patched') ?? false;
    final List<int> order = patched
        ? const <int>[5, 3, 7, 2, 4]
        : const <int>[5, 7, 3, 4, 2];
    return Column(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: CustomPaint(
            painter: _BstPainter(values: order, broken: !patched),
            child: const SizedBox.expand(),
          ),
        ),
        ColoredBox(
          color: const Color(0xFF0D1117),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Broken insert. Edit the comparator, then Run.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                FilledButton(onPressed: _run, child: const Text('Run tests')),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: _code,
            maxLines: null,
            expands: true,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Color(0xFFC9D1D9),
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFF0D1117),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _BstPainter extends CustomPainter {
  _BstPainter({required this.values, required this.broken});
  final List<int> values;
  final bool broken;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0D1117));
    const List<Offset> slots = <Offset>[
      Offset(0.5, 0.18),
      Offset(0.32, 0.42),
      Offset(0.68, 0.42),
      Offset(0.22, 0.68),
      Offset(0.42, 0.68),
    ];
    for (int i = 1; i < values.length && i < slots.length; i++) {
      canvas.drawLine(
        Offset(slots[0].dx * size.width, slots[0].dy * size.height),
        Offset(slots[i].dx * size.width, slots[i].dy * size.height),
        Paint()
          ..color = broken ? const Color(0xFFEF4444) : const Color(0xFF3DDBAD)
          ..strokeWidth = 2,
      );
    }
    for (int i = 0; i < values.length && i < slots.length; i++) {
      final Offset p = Offset(slots[i].dx * size.width, slots[i].dy * size.height);
      canvas.drawCircle(p, 22, Paint()..color = const Color(0xFF1F6FEB));
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: '${values[i]}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _BstPainter old) =>
      old.broken != broken || old.values != values;
}

class EngineeringWorkspace extends StatelessWidget {
  const EngineeringWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final List<Offset> joints = <Offset>[];
    for (final dynamic e in session.getv<List<dynamic>>('joints') ?? <dynamic>[]) {
      if (e is List && e.length >= 2) {
        joints.add(Offset((e[0] as num).toDouble(), (e[1] as num).toDouble()));
      }
    }
    final bool failed = session.getv<bool>('failed') ?? false;
    return GestureDetector(
      onTapDown: (TapDownDetails d) {
        final List<dynamic> next = List<dynamic>.from(
          session.getv<List<dynamic>>('joints') ?? <dynamic>[],
        )..add(<double>[d.localPosition.dx, d.localPosition.dy]);
        session.setVar('joints', next, inspectorText: '${next.length} joints placed');
        session.act('place');
      },
      child: CustomPaint(
        painter: _BridgePainter(joints: joints, failed: failed),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BridgePainter extends CustomPainter {
  _BridgePainter({required this.joints, required this.failed});
  final List<Offset> joints;
  final bool failed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF101418));
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, 80, 12),
      Paint()..color = Colors.white24,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 80, size.height * 0.7, 80, 12),
      Paint()..color = Colors.white24,
    );
    if (joints.length >= 2) {
      for (int i = 0; i < joints.length - 1; i++) {
        canvas.drawLine(
          joints[i],
          joints[i + 1],
          Paint()
            ..color = failed ? const Color(0xFFEF4444) : const Color(0xFF3DDBAD)
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    for (final Offset j in joints) {
      canvas.drawCircle(j, 8, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _BridgePainter old) =>
      old.failed != failed || old.joints.length != joints.length;
}

class ClinicalWorkspace extends StatelessWidget {
  const ClinicalWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final int hr = session.getv<int>('hr') ?? 98;
    final bool leads = session.getv<bool>('leads') ?? false;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const ColoredBox(color: Color(0xFF1A1A1A)),
            CustomPaint(painter: _PatientPainter(leads: leads, hr: hr)),
            Positioned(
              right: 12,
              top: 12,
              child: _Monitor(hr: hr, spo2: session.getv<int>('spo2') ?? 95),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (TapDownDetails d) {
                  final double y = d.localPosition.dy / c.maxHeight;
                  if (y < 0.35) {
                    session.act('inspect', inspect: 'Face diaphoretic. Airway patent on glance.');
                  } else if (y < 0.55) {
                    session.act(
                      leads ? 'ecg' : 'inspect',
                      inspect: leads
                          ? 'Leads on the chest. ST concern forming on the monitor.'
                          : 'Chest — use ECG in the tools to place leads here, then tap again.',
                    );
                  } else {
                    session.act('inspect', inspect: 'Periphery cool. Get a cuff reading.');
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PatientPainter extends CustomPainter {
  _PatientPainter({required this.leads, required this.hr});
  final bool leads;
  final int hr;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.55, size.width * 0.64, size.height * 0.28),
      Paint()..color = const Color(0xFF2A2A32),
    );
    final Offset c = Offset(size.width * 0.5, size.height * 0.4);
    canvas.drawCircle(c + const Offset(0, -70), 36, Paint()..color = const Color(0xFFD7A184));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 90, height: 140),
        const Radius.circular(40),
      ),
      Paint()..color = const Color(0xFF4B7B6E),
    );
    if (leads) {
      canvas.drawCircle(c + const Offset(-12, 0), 6, Paint()..color = const Color(0xFF3DDBAD));
      canvas.drawCircle(c + const Offset(12, 10), 6, Paint()..color = const Color(0xFF3DDBAD));
    }
  }

  @override
  bool shouldRepaint(covariant _PatientPainter old) => old.leads != leads;
}

class _Monitor extends StatelessWidget {
  const _Monitor({required this.hr, required this.spo2});
  final int hr;
  final int spo2;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('HR $hr', style: const TextStyle(color: Color(0xFF22C55E), fontSize: 20)),
          Text('SpO₂ $spo2%', style: const TextStyle(color: Color(0xFF60A5FA))),
        ],
      ),
    );
  }
}

class FinanceWorkspace extends StatelessWidget {
  const FinanceWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final double eq = session.getv<double>('eq') ?? 0.5;
    final bool shocked = session.getv<bool>('shocked') ?? false;
    final double value = shocked ? 1000000 * (0.7 * eq + 0.95 * (1 - eq)) : 1000000;
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails d) {
        final double next = (eq + d.delta.dx / 400).clamp(0.05, 0.95);
        session.setVar(
          'eq',
          next,
          inspectorText:
              'Equity ${(next * 100).round()}%  ·  bonds/cash ${((1 - next) * 100).round()}%',
        );
        session.act('allocate');
      },
      child: CustomPaint(
        painter: _DeskPainter(eq: eq, value: value, shocked: shocked),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DeskPainter extends CustomPainter {
  _DeskPainter({required this.eq, required this.value, required this.shocked});
  final double eq;
  final double value;
  final bool shocked;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0B0F14));
    final Path p = Path()..moveTo(20, size.height * 0.6);
    for (int i = 1; i < 40; i++) {
      final double y = size.height * (0.55 - math.sin(i / 4) * 0.08 * (shocked ? 1.6 : 1) * eq);
      p.lineTo(20 + i * (size.width - 40) / 40, y);
    }
    canvas.drawPath(
      p,
      Paint()
        ..color = shocked ? const Color(0xFFEF4444) : const Color(0xFF3DDBAD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.62, 120, 120),
      -math.pi / 2,
      2 * math.pi * eq,
      true,
      Paint()..color = const Color(0xFF3B82F6),
    );
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.62, 120, 120),
      -math.pi / 2 + 2 * math.pi * eq,
      2 * math.pi * (1 - eq),
      true,
      Paint()..color = const Color(0xFFFBBF24),
    );
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: '\$${value.round()}',
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(24, 24));
  }

  @override
  bool shouldRepaint(covariant _DeskPainter old) =>
      old.eq != eq || old.shocked != shocked;
}

class AccountingWorkspace extends StatelessWidget {
  const AccountingWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final String open = session.getv<String>('doc') ?? '';
    return Row(
      children: <Widget>[
        SizedBox(
          width: 160,
          child: ListView(
            children: <String>['Invoice', 'Bank rec', 'Journal', 'Trial balance']
                .map(
                  (String d) => ListTile(
                    title: Text(d, style: const TextStyle(color: Colors.white)),
                    selected: open == d,
                    onTap: () {
                      session.setVar('doc', d, inspectorText: 'Opened $d');
                      session.act('open', data: d);
                      final Set<String> seen = (session.getv<List<dynamic>>('seen') ?? <dynamic>[])
                          .map((dynamic e) => e.toString())
                          .toSet()
                        ..add(d);
                      session.setVar('seen', seen.toList());
                      if (d == 'Invoice') {
                        session.act(
                          'inspect',
                          inspect:
                              'INV-4419 dated 3 Jan. Goods shipped 28 Dec. Do not stop at one document.',
                        );
                      } else if (d == 'Journal') {
                        session.act(
                          'inspect',
                          inspect: 'Dec 31 credit to Revenue \$48,000. No shipping document in December.',
                        );
                      } else if (d == 'Trial balance') {
                        session.act(
                          'inspect',
                          inspect: 'January cash is \$48,000 higher than the subledger unless cutoff is reversed.',
                        );
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFF4EFE4),
            padding: const EdgeInsets.all(18),
            child: Text(
              open.isEmpty
                  ? 'Open Invoice, Journal, and Trial balance. Then use Flag cutoff — do not guess from one line.'
                  : open == 'Invoice'
                      ? 'INV-4419  ·  dated 3 Jan  ·  shipped 28 Dec  ·  \$48,000\nCash booked January. Shipping December. Compare the journal before you call cutoff.'
                      : '$open\nLines almost tie except January cash from INV-4419. Keep tracing.',
              style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class BusinessWorkspace extends StatelessWidget {
  const BusinessWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final String view = session.getv<String>('view') ?? 'company';
    return CustomPaint(
      painter: _HqPainter(view: view),
      child: GestureDetector(
        onTapDown: (TapDownDetails d) {
          final double x = d.localPosition.dx;
          final String view = session.getv<String>('view') ?? 'company';
          if (x < 200) {
            session.setVar('view', 'region', inspectorText: 'Region A +4% · Region B −31%');
            session.act('drill');
          } else if (view == 'region') {
            session.setVar('view', 'product', inspectorText: 'Product X −42% after the 12 Mar price change');
            session.act('drill');
          } else {
            session.setVar(
              'view',
              'complaints',
              inspectorText: 'Complaint volume +61% in Region B, Product X. Price, not weather.',
            );
            session.act('inspect');
          }
        },
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HqPainter extends CustomPainter {
  _HqPainter({required this.view});
  final String view;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0E1620));
    canvas.drawRect(Rect.fromLTWH(20, size.height * 0.3, 80, size.height * 0.5 * 0.82), Paint()..color = const Color(0xFF22C55E));
    canvas.drawRect(
      Rect.fromLTWH(120, size.height * 0.25, 80, size.height * 0.55),
      Paint()..color = view == 'region' ? const Color(0xFFEF4444) : const Color(0xFF64748B),
    );
    canvas.drawRect(
      Rect.fromLTWH(240, size.height * 0.45, 90, size.height * 0.35),
      Paint()..color = view == 'product' ? const Color(0xFFF59E0B) : const Color(0xFF334155),
    );
  }

  @override
  bool shouldRepaint(covariant _HqPainter old) => old.view != view;
}

class EconomicsWorkspace extends StatelessWidget {
  const EconomicsWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final double rate = session.getv<double>('rate') ?? 0.4;
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails d) {
        final double n = (rate + d.delta.dx / 400).clamp(0, 1);
        session.setVar(
          'rate',
          n,
          inspectorText:
              'Policy rate ${(2 + n * 6).toStringAsFixed(1)}%  ·  inflation ${(8.2 - n * 3).toStringAsFixed(1)}%  ·  u ${(4.2 + n * 2.4).toStringAsFixed(1)}%',
        );
        session.act('adjust');
      },
      child: CustomPaint(
        painter: _PolicyPainter(rate: rate),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PolicyPainter extends CustomPainter {
  _PolicyPainter({required this.rate});
  final double rate;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0C1220));
    final Path inf = Path()..moveTo(30, size.height * (0.3 + rate * 0.2));
    final Path u = Path()..moveTo(30, size.height * (0.55 - rate * 0.15));
    for (int i = 1; i < 40; i++) {
      inf.lineTo(30.0 + i * (size.width - 60) / 40, size.height * (0.3 + rate * 0.2) + i);
      u.lineTo(30.0 + i * (size.width - 60) / 40, size.height * (0.55 - rate * 0.15) - i * 0.4);
    }
    canvas.drawPath(inf, Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawPath(u, Paint()..color = const Color(0xFF3B82F6)..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant _PolicyPainter old) => old.rate != rate;
}

class MarketingWorkspace extends StatelessWidget {
  const MarketingWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final double search = session.getv<double>('search') ?? 0.4;
    final bool launched = session.getv<bool>('launched') ?? false;
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails d) {
        session.setVar(
          'search',
          (search + d.delta.dx / 500).clamp(0.05, 0.9),
          inspectorText:
              'Search share ${((search) * 100).round()}%. Launch to read CAC / ROAS.',
        );
        session.act('allocate');
      },
      child: CustomPaint(
        painter: _CampaignPainter(search: search, launched: launched),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CampaignPainter extends CustomPainter {
  _CampaignPainter({required this.search, required this.launched});
  final double search;
  final bool launched;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF120C18));
    canvas.drawRect(
      Rect.fromLTWH(40, size.height * (1 - search) * 0.5, 50, size.height * search * 0.5),
      Paint()..color = const Color(0xFF3DDBAD),
    );
    canvas.drawRect(
      Rect.fromLTWH(120, size.height * 0.4, 50, size.height * 0.3),
      Paint()..color = const Color(0xFF8B5CF6),
    );
    if (launched) {
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: 'ROAS ${(1.2 + search * 2).toStringAsFixed(2)}x   CAC \$${(80 - search * 30).round()}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, const Offset(24, 24));
    }
  }

  @override
  bool shouldRepaint(covariant _CampaignPainter old) =>
      old.search != search || old.launched != launched;
}

class LawWorkspace extends StatelessWidget {
  const LawWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final Set<String> open = (session.getv<List<dynamic>>('ex') ?? <dynamic>[]).cast<String>().toSet();
    return Stack(
      children: <Widget>[
        const ColoredBox(color: Color(0xFF1A140F)),
        for (final ({String id, Alignment a, String t}) e in const <({String id, Alignment a, String t})>[
          (id: 'complaint', a: Alignment(-0.6, -0.4), t: 'Complaint'),
          (id: 'contract', a: Alignment(0.1, -0.5), t: 'Contract'),
          (id: 'email', a: Alignment(0.6, -0.2), t: 'Emails'),
          (id: 'photo', a: Alignment(-0.3, 0.3), t: 'Photo'),
          (id: 'statute', a: Alignment(0.5, 0.4), t: 'Statute'),
        ])
          Align(
            alignment: e.a,
            child: GestureDetector(
              onTap: () {
                final List<dynamic> next = List<dynamic>.from(
                  session.getv<List<dynamic>>('ex') ?? <dynamic>[],
                )..add(e.id);
                session.setVar('ex', next, inspectorText: 'Opened ${e.t}');
                session.act('open', data: e.id);
                if (e.id == 'photo') {
                  session.act(
                    'inspect',
                    inspect:
                        'Photograph of spoiled goods. Probative of condition; prejudicial if used as theatre.',
                  );
                }
              },
              child: Container(
                width: 110,
                height: 140,
                color: open.contains(e.id) ? const Color(0xFF3DDBAD) : const Color(0xFFE7DCC8),
                alignment: Alignment.center,
                child: Text(e.t, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
      ],
    );
  }
}

class PsychWorkspace extends StatelessWidget {
  const PsychWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final List<double> rts =
        (session.getv<List<dynamic>>('rts') ?? <dynamic>[]).map((dynamic e) => (e as num).toDouble()).toList();
    return GestureDetector(
      onTap: () {
        final math.Random r = math.Random();
        final List<dynamic> next = List<dynamic>.from(session.getv<List<dynamic>>('rts') ?? <dynamic>[])
          ..add(280 + r.nextInt(180));
        session.setVar('rts', next, inspectorText: 'N=${next.length}  mean RT recorded');
        session.act('run');
      },
      child: CustomPaint(
        painter: _HistPainter(rts: rts),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HistPainter extends CustomPainter {
  _HistPainter({required this.rts});
  final List<double> rts;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF100818));
    if (rts.isEmpty) return;
    for (int i = 0; i < rts.length; i++) {
      final double h = (rts[i] / 500) * size.height * 0.6;
      canvas.drawRect(
        Rect.fromLTWH(20.0 + i * 14, size.height * 0.8 - h, 10, h),
        Paint()..color = const Color(0xFFA78BFA),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HistPainter old) => old.rts.length != rts.length;
}

class HistoryWorkspace extends StatelessWidget {
  const HistoryWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final double t = session.getv<double>('year') ?? 0.4;
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails d) {
        session.setVar('year', (t + d.delta.dx / 500).clamp(0, 1), inspectorText: 'Timeline ${1800 + (t * 50).round()}');
        session.act('inspect');
      },
      onTap: () => session.act('claim', inspect: 'You pinned a source on the map. Name what it can actually prove.'),
      child: CustomPaint(
        painter: _MapPainter(t: t),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1B2A1A));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * (0.4 + t * 0.1), size.height * 0.45), width: 180, height: 120),
      Paint()..color = const Color(0xFF4B7B4A),
    );
    canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.42), 6, Paint()..color = const Color(0xFF3DDBAD));
    canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.5), 6, Paint()..color = const Color(0xFFFBBF24));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.t != t;
}

class GeographyWorkspace extends StatelessWidget {
  const GeographyWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (ScaleUpdateDetails d) {
        session.setVar('zoom', d.scale);
        session.act('inspect', inspect: 'Scale ${d.scale.toStringAsFixed(2)} — compare layers at this zoom.');
      },
      child: CustomPaint(
        painter: _GisPainter(
          climate: session.layersOn.contains('Climate'),
          pop: session.layersOn.contains('Population'),
          land: session.layersOn.contains('Land use'),
          hydro: session.layersOn.contains('Hydrology'),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GisPainter extends CustomPainter {
  _GisPainter({
    required this.climate,
    required this.pop,
    required this.land,
    required this.hydro,
  });
  final bool climate;
  final bool pop;
  final bool land;
  final bool hydro;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0B1C18));
    if (hydro) {
      canvas.drawPath(
        Path()
          ..moveTo(20, size.height * 0.4)
          ..quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width - 20, size.height * 0.35),
        Paint()
          ..color = const Color(0xFF38BDF8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
    }
    if (climate) {
      canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.45), 70, Paint()..color = const Color(0x55F59E0B));
    }
    if (land) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * 0.3, size.height * 0.5, 140, 80),
        Paint()..color = const Color(0x6684CC16),
      );
    }
    if (pop) {
      for (int i = 0; i < 8; i++) {
        canvas.drawCircle(
          Offset(size.width * 0.35 + i * 18.0, size.height * 0.52),
          5,
          Paint()..color = const Color(0xFFFB7185),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GisPainter old) =>
      old.climate != climate || old.pop != pop || old.land != land || old.hydro != hydro;
}

class ArchitectureWorkspace extends StatelessWidget {
  const ArchitectureWorkspace({super.key, required this.session});
  final LabSession session;

  @override
  Widget build(BuildContext context) {
    final double yaw = session.getv<double>('yaw') ?? 0.4;
    final double sun = session.getv<double>('sun') ?? 0.4;
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails d) {
        session.setVar('yaw', yaw + d.delta.dx * 0.01, inspectorText: 'Orbit ${(yaw).toStringAsFixed(2)}');
        session.act('inspect');
      },
      child: CustomPaint(
        painter: _BuildingPainter(yaw: yaw, sun: sun),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BuildingPainter extends CustomPainter {
  _BuildingPainter({required this.yaw, required this.sun});
  final double yaw;
  final double sun;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF101018));
    final Offset c = Offset(size.width / 2, size.height * 0.55);
    canvas.drawRect(
      Rect.fromCenter(center: c + Offset(yaw * 20, 0), width: 120, height: 180),
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawRect(
      Rect.fromLTWH(c.dx + 40 + yaw * 20, c.dy - 90, 30, 180 * sun),
      Paint()..color = const Color(0x66FBBF24),
    );
  }

  @override
  bool shouldRepaint(covariant _BuildingPainter old) => old.yaw != yaw || old.sun != sun;
}
