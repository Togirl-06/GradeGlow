import 'package:flutter/material.dart';

import '../shared/professional_case_store.dart';
import '../shared/professional_theme.dart';
import '../shared/professional_widgets.dart';

/// National dashboard → diagnose inflation → set policy → RUN ECONOMY.
class EconomicsPolicyMission extends StatefulWidget {
  const EconomicsPolicyMission({
    super.key,
    required this.store,
    required this.onComplete,
  });

  final ProCaseStore store;
  final VoidCallback onComplete;

  @override
  State<EconomicsPolicyMission> createState() => _EconomicsPolicyMissionState();
}

class _EconomicsPolicyMissionState extends State<EconomicsPolicyMission> {
  static const ProSimTheme t = ProSimTheme.economics;

  double _rate = 3.5;
  double _spend = 50;
  double _tax = 50;
  String? _diagnosis;
  Map<String, String>? _result;
  String? _feedback;
  final TextEditingController _report = TextEditingController();

  Future<void> _runEconomy() async {
    if (_diagnosis == null) {
      setState(() => _feedback = 'Diagnose the shock before moving policy levers.');
      return;
    }
    if (_report.text.trim().length < 40) {
      setState(() => _feedback = 'Write a policy memo (40+ chars) for government.');
      return;
    }

    final bool demandShock = _diagnosis == 'Excess demand / overheating';
    final bool supplyShock = _diagnosis == 'Supply disruption / cost-push';

    // Simple IS-LM-ish toy: hike rates cool inflation but raise unemployment.
    final double rateDelta = _rate - 3.5;
    final double spendDelta = _spend - 50;
    final double taxDelta = _tax - 50;

    double inflation = 8.2 - rateDelta * 0.6 + spendDelta * 0.05 - taxDelta * 0.04;
    double unemployment = 5.1 + rateDelta * 0.35 - spendDelta * 0.04 + taxDelta * 0.03;
    double gdp = 2.0 - rateDelta * 0.25 + spendDelta * 0.06 - taxDelta * 0.05;
    double debt = 60 + spendDelta * 0.3 - taxDelta * 0.25;

    if (supplyShock && rateDelta > 1.5 && spendDelta < 0) {
      // Aggressive demand restraint on supply shock: growth tanks
      gdp -= 1.2;
      unemployment += 0.8;
    }
    if (demandShock && rateDelta >= 1.0) {
      inflation -= 0.8;
    }

    await widget.store.applyMeters(<String, double>{
      'GDP': (gdp * 10).clamp(0, 100),
      'Inflation': (100 - inflation * 8).clamp(0, 100),
      'Unemployment': (100 - unemployment * 8).clamp(0, 100),
      'Debt': (100 - debt).clamp(0, 100),
      'Confidence': (55 + gdp * 5 - inflation).clamp(0, 100),
    });
    await widget.store.addDecision(
      'Dx=$_diagnosis rate=$_rate spend=$_spend tax=$_tax',
    );
    await widget.store.addNote(_report.text.trim());

    setState(() {
      _result = <String, String>{
        'Inflation': '${inflation.toStringAsFixed(1)}%',
        'Unemployment': '${unemployment.toStringAsFixed(1)}%',
        'GDP growth': '${gdp.toStringAsFixed(1)}%',
        'Debt/GDP': '${debt.toStringAsFixed(0)}%',
      };
      _feedback = demandShock && rateDelta >= 0.75
          ? 'Advisor Okada: “Tradeoffs acknowledged. Defend why growth may slow.”'
          : 'Central Banker: “Policy mix may not match the diagnosis. Re-read the data.”';
    });

    final bool ok = (demandShock && rateDelta >= 0.75 && inflation < 7.2) ||
        (supplyShock && spendDelta >= 0 && rateDelta <= 1.0 && inflation < 8.0);
    if (ok && _report.text.trim().length >= 40) {
      await widget.store.awardXp(170, coinsGain: 5, skill: 'Policy Reasoning');
      await widget.store.awardXp(40, skill: 'Economic Analysis');
      await widget.store.completeMission('inflation');
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _report.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1320),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          Text(
            'Dr. Okada: “Inflation hit 8.2%. Diagnose, set policy, RUN ECONOMY — then explain tradeoffs.”',
            style: TextStyle(color: t.accent, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _dash(),
          const SizedBox(height: 12),
          Text('DIAGNOSIS',
              style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
          ProSelectList(
            accent: t.accent,
            value: _diagnosis,
            onChanged: (String v) => setState(() => _diagnosis = v),
            options: const <String>[
              'Excess demand / overheating',
              'Supply disruption / cost-push',
              'Purely psychological panic',
              'Currency collapse only',
            ],
          ),
          Text('POLICY CONTROLS',
              style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
          _sl('Interest rate %', _rate, 0, 10, (double v) => setState(() => _rate = v)),
          _sl('Gov spending index', _spend, 20, 80, (double v) => setState(() => _spend = v)),
          _sl('Tax index', _tax, 20, 80, (double v) => setState(() => _tax = v)),
          TextField(
            controller: _report,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Policy memo to government',
              labelStyle: TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: _runEconomy,
            style: FilledButton.styleFrom(
              backgroundColor: t.accent,
              foregroundColor: Colors.black,
            ),
            child: const Text('RUN ECONOMY',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_result != null) ...<Widget>[
            const SizedBox(height: 12),
            ProConsequencePanel(
              theme: t,
              title: 'ECONOMIC OUTCOMES',
              deltas: _result!,
              interpretation: _feedback ?? '',
            ),
          ],
          if (_feedback != null && _result == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
            ),
        ],
      ),
    );
  }

  Widget _dash() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('NATIONAL DASHBOARD',
              style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const <String>[
              'GDP +1.4%',
              'Inflation 8.2%',
              'Unemployment 5.1%',
              'Policy rate 3.5%',
              'Debt/GDP 61%',
              'Consumer conf. 42',
              'Business conf. 48',
              'News: Port delays + energy spike',
            ]
                .map(
                  (String s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 11)),
                    backgroundColor: const Color(0xFF1A2438),
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _sl(
    String label,
    double v,
    double min,
    double max,
    ValueChanged<double> onC,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('$label  ${v.toStringAsFixed(1)}',
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
        Slider(value: v, min: min, max: max, onChanged: onC, activeColor: t.accent),
      ],
    );
  }
}
