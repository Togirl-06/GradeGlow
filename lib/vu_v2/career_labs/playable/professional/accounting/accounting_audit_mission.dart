import 'package:flutter/material.dart';

import '../shared/professional_case_store.dart';
import '../shared/professional_theme.dart';
import '../shared/professional_widgets.dart';

/// Classify transactions → journal entry → find the discrepancy.
class AccountingAuditMission extends StatefulWidget {
  const AccountingAuditMission({
    super.key,
    required this.store,
    required this.onComplete,
  });

  final ProCaseStore store;
  final VoidCallback onComplete;

  @override
  State<AccountingAuditMission> createState() => _AccountingAuditMissionState();
}

class _AccountingAuditMissionState extends State<AccountingAuditMission> {
  static const ProSimTheme t = ProSimTheme.accounting;

  final Map<String, String> _class = <String, String>{};
  String _debitAcct = 'Cash';
  String _creditAcct = 'Revenue';
  final TextEditingController _debit = TextEditingController(text: '2500');
  final TextEditingController _credit = TextEditingController(text: '2500');
  String? _errorPick;
  String? _feedback;
  bool _balanced = false;

  static const List<_Txn> _txns = <_Txn>[
    _Txn('INV-10482', 'Client invoice \$2,500', 'Revenue'),
    _Txn('RCP-221', 'Office supplies \$180', 'Expense'),
    _Txn('BNK-881', 'Loan proceeds \$10,000', 'Liability'),
    _Txn('PAY-44', 'Payroll \$6,200', 'Expense'),
    _Txn('PO-90', 'Equipment purchase \$4,000', 'Asset'),
    _Txn('ERR-17', 'Owner draw coded as Expense \$900', 'Equity'),
  ];

  int get _correctClass => _txns
      .where(( _Txn x) => _class[x.id] == x.correct)
      .length;

  Future<void> _checkJournal() async {
    final double? d = double.tryParse(_debit.text);
    final double? c = double.tryParse(_credit.text);
    if (d == null || c == null || d != c) {
      setState(() {
        _balanced = false;
        _feedback = 'Debits must equal credits.';
      });
      return;
    }
    setState(() {
      _balanced = true;
      _feedback = 'Entry posts. Ledger updated.';
    });
    await widget.store.addNote(
      'JE: Dr $_debitAcct $d / Cr $_creditAcct $c',
    );
  }

  Future<void> _submitAudit() async {
    if (_correctClass < 5) {
      setState(() => _feedback = 'Reclassify transactions — accuracy matters.');
      return;
    }
    if (!_balanced) {
      setState(() => _feedback = 'Post a balanced journal entry first.');
      return;
    }
    if (_errorPick != 'ERR-17') {
      setState(() =>
          _feedback = 'Trace Net Income → Expenses → find the misclassified draw.');
      return;
    }
    await widget.store.addEvidence('Misclassified owner draw ERR-17');
    await widget.store.addDecision('Corrected equity classification; statements reconcile');
    await widget.store.awardXp(170, coinsGain: 4, skill: 'Accuracy');
    await widget.store.awardXp(40, skill: 'Audit Skills');
    await widget.store.completeMission('audit');
    setState(() => _feedback =
        'Partner Helen: “Trail is clean. Owner draw was burying equity. Good catch.”');
    widget.onComplete();
  }

  @override
  void dispose() {
    _debit.dispose();
    _credit.dispose();
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
            'Helen Moss (Partner): “Statements don’t balance. Classify, post, then find the discrepancy.”',
            style: TextStyle(color: t.accent, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text('1 · CLASSIFY DOCUMENTS',
              style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
          ..._txns.map(( _Txn x) {
            return Card(
              color: const Color(0xFF111A2A),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${x.id} — ${x.label}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800)),
                    Wrap(
                      spacing: 6,
                      children: <String>[
                        'Asset',
                        'Liability',
                        'Equity',
                        'Revenue',
                        'Expense',
                      ]
                          .map(
                            (String c) => ChoiceChip(
                              label: Text(c),
                              selected: _class[x.id] == c,
                              onSelected: (_) =>
                                  setState(() => _class[x.id] = c),
                              selectedColor: t.accent,
                              labelStyle: TextStyle(
                                color: _class[x.id] == c
                                    ? Colors.black
                                    : Colors.white70,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                              backgroundColor: const Color(0xFF1A2438),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          }),
          Text('Classified $_correctClass / ${_txns.length}',
              style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 14),
          Text('2 · JOURNAL ENTRY LAB',
              style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
          Row(
            children: <Widget>[
              Expanded(child: _acctPick(true)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _debit,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Debit',
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(child: _acctPick(false)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _credit,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Credit',
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _checkJournal,
            child: const Text('POST ENTRY'),
          ),
          const SizedBox(height: 14),
          Text('3 · AUDIT TRAIL — FIND THE ERROR',
              style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
          const Text(
            'Net Income looks low. Trace Expenses → which document is wrong?',
            style: TextStyle(color: Colors.white70),
          ),
          ProSelectList(
            accent: t.accent,
            value: _errorPick,
            onChanged: (String v) => setState(() => _errorPick = v),
            options: _txns.map(( _Txn x) => x.id).toList(),
          ),
          if (_errorPick != null)
            Text(
              _txns.firstWhere(( _Txn x) => x.id == _errorPick).label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          FilledButton(
            onPressed: _submitAudit,
            style: FilledButton.styleFrom(
              backgroundColor: t.accent,
              foregroundColor: Colors.black,
            ),
            child: const Text('SUBMIT AUDIT FINDINGS',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          ],
        ],
      ),
    );
  }

  Widget _acctPick(bool debit) {
    final String v = debit ? _debitAcct : _creditAcct;
    return DropdownButtonFormField<String>(
      initialValue: v,
      dropdownColor: const Color(0xFF1A2438),
      decoration: InputDecoration(
        labelText: debit ? 'Debit account' : 'Credit account',
        labelStyle: const TextStyle(color: Colors.white54),
      ),
      items: const <String>[
        'Cash',
        'Revenue',
        'Expense',
        'Equipment',
        'Loan Payable',
        'Owner Equity',
      ]
          .map(
            (String a) => DropdownMenuItem<String>(
              value: a,
              child: Text(a, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      onChanged: (String? n) {
        if (n == null) return;
        setState(() {
          if (debit) {
            _debitAcct = n;
          } else {
            _creditAcct = n;
          }
        });
      },
    );
  }
}

class _Txn {
  const _Txn(this.id, this.label, this.correct);
  final String id;
  final String label;
  final String correct;
}
