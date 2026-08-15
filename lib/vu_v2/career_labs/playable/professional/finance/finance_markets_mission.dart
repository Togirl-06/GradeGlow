import 'package:flutter/material.dart';

import '../shared/professional_case_store.dart';
import '../shared/professional_theme.dart';
import '../shared/professional_widgets.dart';

/// Analyze statements → allocate portfolio → face market shock.
class FinanceMarketsMission extends StatefulWidget {
  const FinanceMarketsMission({
    super.key,
    required this.store,
    required this.onComplete,
  });

  final ProCaseStore store;
  final VoidCallback onComplete;

  @override
  State<FinanceMarketsMission> createState() => _FinanceMarketsMissionState();
}

class _FinanceMarketsMissionState extends State<FinanceMarketsMission> {
  static const ProSimTheme t = ProSimTheme.finance;

  String _tab = 'income';
  double _equity = 40;
  double _bonds = 30;
  double _cash = 20;
  double _other = 10;
  bool _shocked = false;
  Map<String, String>? _result;
  String? _action;
  String? _feedback;
  final TextEditingController _explain = TextEditingController();

  double get _sum => _equity + _bonds + _cash + _other;

  double get _risk =>
      (_equity * 0.8 + _other * 0.7 + _bonds * 0.3 + _cash * 0.05) / 100;

  double get _expectedReturn =>
      (_equity * 0.09 + _bonds * 0.04 + _cash * 0.02 + _other * 0.07);

  Future<void> _normalize() async {
    final double s = _sum;
    if (s <= 0) return;
    setState(() {
      _equity = _equity / s * 100;
      _bonds = _bonds / s * 100;
      _cash = _cash / s * 100;
      _other = _other / s * 100;
    });
  }

  Future<void> _runShock() async {
    await _normalize();
    if (_explain.text.trim().length < 30) {
      setState(() => _feedback = 'Explain your allocation before the market moves.');
      return;
    }
    if (_action == null) {
      setState(() => _feedback = 'Choose a response to the market alert.');
      return;
    }

    double equity = _equity;
    double bonds = _bonds;
    double cash = _cash;
    double other = _other;
    switch (_action) {
      case 'Reduce equity exposure':
        cash += equity * 0.25;
        equity *= 0.75;
        break;
      case 'Increase equity':
        equity += cash * 0.4;
        cash *= 0.6;
        break;
      case 'Rebalance to target':
        equity = 40;
        bonds = 30;
        cash = 20;
        other = 10;
        break;
      default:
        break;
    }

    // Shock: equities −18%, bonds +2%, other −10%
    final double value =
        equity * 0.82 + bonds * 1.02 + cash * 1.0 + other * 0.9;
    final double delta = value - 100;

    await widget.store.applyMeters(<String, double>{
      'Portfolio': delta.clamp(-30, 30),
      'Risk': (_risk * 100 - 50),
      'Liquidity': cash - 20,
      'Diversification': (100 - (equity - 40).abs()) / 5 - 10,
    });
    await widget.store.addDecision(
      'Alloc E${equity.toStringAsFixed(0)}/B${bonds.toStringAsFixed(0)}/C${cash.toStringAsFixed(0)} · $_action',
    );
    await widget.store.addNote(_explain.text.trim());

    setState(() {
      _shocked = true;
      _equity = equity;
      _bonds = bonds;
      _cash = cash;
      _other = other;
      _result = <String, String>{
        'Portfolio value': '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}%',
        'Equity sleeve': '−18% shock applied',
        'Bonds': '+2%',
        'Action': _action!,
      };
      _feedback =
          'Senior Analyst: “Returns alone don’t grade you. Defend risk, liquidity, and diversification.”';
    });

    if (_cash >= 15 && _equity <= 55 && _explain.text.trim().length >= 30) {
      await widget.store.awardXp(160, coinsGain: 4, skill: 'Risk Management');
      await widget.store.awardXp(40, skill: 'Portfolio Strategy');
      await widget.store.completeMission('markets');
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _explain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B1320),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 180,
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                _nav('income', 'Income Statement'),
                _nav('balance', 'Balance Sheet'),
                _nav('cashflow', 'Cash Flow'),
                _nav('portfolio', 'Portfolio'),
                _nav('shock', 'Market Alert'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: <Widget>[
                Text(
                  'Hale Chen (PM): “Analyze NovaGrid. Build a \$100k sleeve. Then survive the shock.”',
                  style: TextStyle(color: t.accent, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (_tab == 'income')
                  _stmt('INCOME STATEMENT — NovaGrid Inc.', const <List<String>>[
                    <String>['Line', '\$000'],
                    <String>['Revenue', '12,400'],
                    <String>['COGS', '(7,100)'],
                    <String>['Operating income', '2,850'],
                    <String>['Net income', '1,920'],
                    <String>['YoY growth', '+6%'],
                  ]),
                if (_tab == 'balance')
                  _stmt('BALANCE SHEET', const <List<String>>[
                    <String>['Assets', '18,200'],
                    <String>['Liabilities', '9,400'],
                    <String>['Equity', '8,800'],
                    <String>['Current ratio', '1.6'],
                    <String>['Debt/Equity', '0.72'],
                  ]),
                if (_tab == 'cashflow')
                  _stmt('CASH FLOW', const <List<String>>[
                    <String>['Operating', '+2,100'],
                    <String>['Investing', '(980)'],
                    <String>['Financing', '(420)'],
                    <String>['Net change', '+700'],
                  ]),
                if (_tab == 'portfolio') _portfolio(),
                if (_tab == 'shock') _shock(),
                if (_result != null) ...<Widget>[
                  const SizedBox(height: 12),
                  ProConsequencePanel(
                    theme: t,
                    title: 'MARKET SHOCK RESULTS',
                    deltas: _result!,
                    interpretation: _feedback ?? '',
                  ),
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
    return ListTile(
      dense: true,
      selected: on,
      selectedTileColor: t.accent.withValues(alpha: 0.15),
      title: Text(label,
          style: TextStyle(
              color: on ? t.accent : Colors.white70,
              fontWeight: FontWeight.w800,
              fontSize: 12)),
      onTap: () => setState(() => _tab = id),
    );
  }

  Widget _stmt(String title, List<List<String>> rows) {
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
          Text(title,
              style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...rows.map(
            (List<String> r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      r.first,
                      style: TextStyle(
                        color: rows.first == r ? t.accent : Colors.white70,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (r.length > 1)
                    Text(r[1],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _portfolio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('PORTFOLIO ALLOCATOR',
            style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
        _sl('Equity', _equity, (double v) => setState(() => _equity = v)),
        _sl('Bonds', _bonds, (double v) => setState(() => _bonds = v)),
        _sl('Cash', _cash, (double v) => setState(() => _cash = v)),
        _sl('Other', _other, (double v) => setState(() => _other = v)),
        Text(
          'Sum ${_sum.toStringAsFixed(0)}% · Risk ${(_risk * 100).round()} · Exp. return ${_expectedReturn.toStringAsFixed(1)}%',
          style: const TextStyle(color: Colors.white70),
        ),
        TextButton(onPressed: _normalize, child: const Text('NORMALIZE TO 100%')),
      ],
    );
  }

  Widget _shock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('🚨 MARKET ALERT — Energy shock / risk-off',
            style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text(
          'Equities −18% in the scenario. Decide how to respond, then run.',
          style: TextStyle(color: Colors.white70),
        ),
        ProSelectList(
          accent: t.accent,
          value: _action,
          onChanged: (String v) => setState(() => _action = v),
          options: const <String>[
            'Maintain position',
            'Reduce equity exposure',
            'Increase equity',
            'Rebalance to target',
            'Hold cash',
          ],
        ),
        TextField(
          controller: _explain,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Explain decision (risk + liquidity)',
            labelStyle: TextStyle(color: Colors.white54),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: _shocked ? null : _runShock,
          style: FilledButton.styleFrom(
            backgroundColor: t.accent,
            foregroundColor: Colors.black,
          ),
          child: const Text('RUN MARKET SIMULATION',
              style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        if (_feedback != null && _result == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ),
      ],
    );
  }

  Widget _sl(String label, double v, ValueChanged<double> onC) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('$label ${v.toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
        Slider(value: v, min: 0, max: 100, onChanged: onC, activeColor: t.accent),
      ],
    );
  }
}
