import 'package:flutter/material.dart';

import '../shared/professional_case_store.dart';
import '../shared/professional_theme.dart';
import '../shared/professional_widgets.dart';

/// Mission: Why did sales drop 20%?
class BusinessSalesDropMission extends StatefulWidget {
  const BusinessSalesDropMission({
    super.key,
    required this.store,
    required this.onComplete,
  });

  final ProCaseStore store;
  final VoidCallback onComplete;

  @override
  State<BusinessSalesDropMission> createState() =>
      _BusinessSalesDropMissionState();
}

class _BusinessSalesDropMissionState extends State<BusinessSalesDropMission> {
  static const ProSimTheme t = ProSimTheme.business;

  String _tab = 'sales';
  final List<String> _pinned = <String>[];
  String? _rootCause;
  String? _strategy;
  Map<String, String>? _result;
  String? _feedback;
  final TextEditingController _rec = TextEditingController();

  static const List<String> _evidencePool = <String>[
    'Revenue ↓20% QoQ',
    '18–25 segment −34%',
    'Competitor price −12%',
    'Churn ↑ in youth segment',
    'AOV stable',
    'Delivery delays +1.4 days',
    'Brand NPS flat',
  ];

  Future<void> _pin(String e) async {
    setState(() {
      if (_pinned.contains(e)) {
        _pinned.remove(e);
      } else {
        _pinned.add(e);
      }
    });
    await widget.store.addEvidence(e);
  }

  Future<void> _runQuarter() async {
    if (_rootCause == null || _strategy == null) {
      setState(() => _feedback = 'Identify root cause and choose a strategy first.');
      return;
    }
    if (_pinned.length < 3) {
      setState(() => _feedback = 'Pin at least 3 pieces of evidence before running.');
      return;
    }

    final bool youth =
        _rootCause == 'Youth segment lost to competitor pricing';
    final bool priceCut = _strategy == 'Match competitor price (−8%)';
    final bool retain = _strategy == 'Youth retention offer + loyalty';
    final bool ads = _strategy == 'Increase youth ad spend';

    final Map<String, double> delta = <String, double>{
      'Revenue': youth && (priceCut || retain)
          ? 8
          : (ads ? 3 : -2),
      'Profit': priceCut ? -4 : (retain ? 2 : (ads ? -3 : 0)),
      'Customers': youth && retain
          ? 6
          : (priceCut ? 5 : (ads ? 2 : -3)),
      'Market share': youth && (priceCut || retain || ads) ? 4 : -2,
      'Cash': priceCut || ads ? -5 : 1,
      'Brand': retain ? 3 : (priceCut ? -1 : 0),
    };

    await widget.store.applyMeters(delta);
    await widget.store.addDecision(
      'Cause=$_rootCause · Strategy=$_strategy · Evidence=${_pinned.join(" | ")}',
    );
    await widget.store.addNote(_rec.text.trim().isEmpty
        ? 'Ran next quarter after sales-drop investigation.'
        : _rec.text.trim());

    setState(() {
      _result = delta.map(
        (String k, double v) => MapEntry(k, v >= 0 ? '+${v.round()}%' : '${v.round()}%'),
      );
      _feedback = youth
          ? 'AI CEO Maya: “Your evidence trail holds. Tradeoffs appeared — explain them.”'
          : 'AI CEO Maya: “The data does not fully support that root cause. Re-investigate.”';
    });

    if (youth && (priceCut || retain) && _rec.text.trim().length >= 40) {
      await widget.store.awardXp(150, coinsGain: 5, skill: 'Data Analysis');
      await widget.store.awardXp(40, skill: 'Strategy');
      await widget.store.completeMission('sales_drop');
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1320),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 200,
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                _nav('sales', '📈 Sales Dashboard'),
                _nav('customers', '👥 Customers'),
                _nav('competitor', '🕵️ Competitor'),
                _nav('ops', '🚚 Operations'),
                _nav('board', '🧷 Evidence Board'),
                _nav('strategy', '♟️ Strategy'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: <Widget>[
                Text(
                  'CEO Maya Reed: “Sales dropped 20% this quarter. Find out why — then fix it.”',
                  style: TextStyle(
                    color: t.accent,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                if (_tab == 'sales') _sales(),
                if (_tab == 'customers') _customers(),
                if (_tab == 'competitor') _competitor(),
                if (_tab == 'ops') _ops(),
                if (_tab == 'board')
                  ProEvidenceBoard(
                    theme: t,
                    available: _evidencePool,
                    pinned: _pinned,
                    onToggle: _pin,
                  ),
                if (_tab == 'strategy') _strategyPanel(),
                if (_result != null) ...<Widget>[
                  const SizedBox(height: 12),
                  ProConsequencePanel(
                    theme: t,
                    title: 'QUARTER RESULTS',
                    deltas: _result!,
                    interpretation: _feedback ?? '',
                  ),
                ],
                if (_feedback != null && _result == null) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nav(String id, String label) {
    final bool on = _tab == id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        selected: on,
        selectedTileColor: t.accent.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          label,
          style: TextStyle(
            color: on ? t.accent : Colors.white70,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        onTap: () => setState(() => _tab = id),
      ),
    );
  }

  Widget _sales() {
    return _table(
      'SALES DASHBOARD',
      const <List<String>>[
        <String>['Metric', 'Last Q', 'This Q', 'Δ'],
        <String>['Revenue', '\$4.2M', '\$3.36M', '−20%'],
        <String>['Units', '84k', '69k', '−18%'],
        <String>['AOV', '\$50', '\$49', '−2%'],
        <String>['Retention', '72%', '64%', '−8 pts'],
        <String>['West region', '\$1.1M', '\$1.05M', '−5%'],
        <String>['Youth SKU', '\$980k', '\$640k', '−35%'],
      ],
    );
  }

  Widget _customers() {
    return _table(
      'CUSTOMER SEGMENTS',
      const <List<String>>[
        <String>['Segment', 'Share', 'Churn', 'Sat'],
        <String>['18–25', '22%', '18% → 31%', '3.4'],
        <String>['26–40', '41%', '9%', '4.1'],
        <String>['41–55', '27%', '7%', '4.3'],
        <String>['55+', '10%', '5%', '4.5'],
      ],
    );
  }

  Widget _competitor() {
    return _table(
      'COMPETITOR REPORT — RIVELINE',
      const <List<String>>[
        <String>['Item', 'Us', 'Riveline'],
        <String>['Starter plan', '\$19', '\$16 (−12%)'],
        <String>['Youth promo', 'None', 'Campus Pass'],
        <String>['Market share 18–25', '38%', '47%'],
        <String>['New SKU', '—', 'GlowLite'],
      ],
    );
  }

  Widget _ops() {
    return _table(
      'OPERATIONS',
      const <List<String>>[
        <String>['Metric', 'Value'],
        <String>['Avg delivery', '3.1 → 4.5 days'],
        <String>['Stockouts (youth SKU)', '↑ after promo rush'],
        <String>['Warehouse OTIF', '91%'],
      ],
    );
  }

  Widget _strategyPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('ROOT CAUSE', style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        ProSelectList(
          accent: t.accent,
          value: _rootCause,
          onChanged: (String v) => setState(() => _rootCause = v),
          options: const <String>[
            'Youth segment lost to competitor pricing',
            'Ops delivery delays alone',
            'Brand reputation collapse',
            'Overall demand recession',
          ],
        ),
        Text('STRATEGY', style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
        ProSelectList(
          accent: t.accent,
          value: _strategy,
          onChanged: (String v) => setState(() => _strategy = v),
          options: const <String>[
            'Match competitor price (−8%)',
            'Youth retention offer + loyalty',
            'Increase youth ad spend',
            'Cut all marketing',
          ],
        ),
        TextField(
          controller: _rec,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Recommendation to CEO (min 40 chars)',
            labelStyle: TextStyle(color: Colors.white54),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _runQuarter,
          style: FilledButton.styleFrom(
            backgroundColor: t.accent,
            foregroundColor: Colors.black,
          ),
          child: const Text('RUN NEXT QUARTER', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }

  Widget _table(String title, List<List<String>> rows) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Table(
            children: rows
                .map(
                  (List<String> r) => TableRow(
                    children: r
                        .map(
                          (String c) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                            child: Text(
                              c,
                              style: TextStyle(
                                color: rows.first == r ? t.accent : Colors.white70,
                                fontWeight:
                                    rows.first == r ? FontWeight.w900 : FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
