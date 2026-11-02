import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// Fairfield / Moss Accounting — Junior Accountant under Helen Moss.
class AccountingPlayableScreen extends StatelessWidget {
  const AccountingPlayableScreen({super.key});

  static const Color accent = Color(0xFFA78BFA);
  static const Color bg = Color(0xFF0C0B14);
  static const Color surface = Color(0xFF161428);

  static const PlayableCareer career = PlayableCareer(
    id: 'accounting',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'Moss & Fairview LLP',
    clockLine: 'Monday — 8:05 AM',
    roleTitle: 'Junior Accountant',
    supervisorName: 'Helen Moss',
    supervisorRole: 'Controller',
    hireTagline: 'Books first. Opinions later. This is the job — not a quiz.',
    supervisorBrief:
        '“Inbox has twenty transactions waiting. Classify them cleanly.\n\n'
        'When you\'re done, the trial balance is off. Find the mispost.”',
    enterCta: 'ENTER THE FIRM',
    startCta: 'OPEN THE LEDGER',
    startLocationId: 'workstations',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'reception',
        name: 'Reception',
        icon: '🗂️',
        blurb: 'Client folders stacked neat.',
        atmosphere: 'Moss & Fairview. Quiet printers. Coffee that means business.',
      ),
      PlayableRoom(
        id: 'workstations',
        name: 'Workstations',
        icon: '💻',
        blurb: 'Classification queue.',
        atmosphere: 'Your screen shows unposted transactions. Helen wants clean coding.',
      ),
      PlayableRoom(
        id: 'vault',
        name: 'Document Vault',
        icon: '📁',
        blurb: 'Invoices and bank slips.',
        atmosphere: 'Source docs for every line. Match before you argue.',
      ),
      PlayableRoom(
        id: 'helen',
        name: 'Helen\'s Office',
        icon: '🚪',
        blurb: 'Controller review.',
        atmosphere: 'Helen signs nothing that doesn\'t balance.',
      ),
      PlayableRoom(
        id: 'warroom',
        name: 'Close Room',
        icon: '🧮',
        blurb: 'Trial balance hunt.',
        atmosphere: 'Debits ≠ credits. Someone misposted. Find them.',
        lockedUntilStageId: 'lab1',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'workstations',
        bannerTitle: 'ACTIVE SITUATION',
        bannerBody: 'Categorize each transaction into Assets, Liabilities, Equity, Revenue, or Expense.',
        cta: 'Classify transactions',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'warroom',
        bannerTitle: 'DISCREPANCY HUNT',
        bannerBody: 'Accounts don\'t balance. Find the misposted entry.',
        cta: 'Find the mispost',
        unlockKey: 'lab2',
        requiresKey: 'lab1',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return PlayableWorkplaceScreen(
      career: augmentCareerWithVisualLabs(career),
      onOpenStage: (BuildContext ctx, PlayableStage stage) async {
        final bool? visual = await tryRunVisualStage(ctx, stage);
        if (visual != null) return visual;
        if (!ctx.mounted) return false;
        if (stage.id == 'lab1') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _AccountingLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _AccountingLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

enum _Acct { asset, liability, equity, revenue, expense }

extension on _Acct {
  String get label {
    switch (this) {
      case _Acct.asset:
        return 'Assets';
      case _Acct.liability:
        return 'Liabilities';
      case _Acct.equity:
        return 'Equity';
      case _Acct.revenue:
        return 'Revenue';
      case _Acct.expense:
        return 'Expense';
    }
  }
}

class _Txn {
  const _Txn(this.id, this.desc, this.correct);
  final String id;
  final String desc;
  final _Acct correct;
}

class _AccountingLab1Screen extends StatefulWidget {
  const _AccountingLab1Screen();

  @override
  State<_AccountingLab1Screen> createState() => _AccountingLab1ScreenState();
}

class _AccountingLab1ScreenState extends State<_AccountingLab1Screen> {
  static const List<_Txn> _txns = <_Txn>[
    _Txn('t1', 'Client pays \$2,400 invoice — cash received', _Acct.asset),
    _Txn('t2', 'Office rent paid for May — \$3,200', _Acct.expense),
    _Txn('t3', 'Bank loan proceeds deposited — \$15,000', _Acct.liability),
    _Txn('t4', 'Consulting fee earned and billed — \$5,000', _Acct.revenue),
    _Txn('t5', 'Owner capital contribution — \$10,000 cash', _Acct.equity),
    _Txn('t6', 'Utilities bill unpaid at month-end — \$480', _Acct.liability),
    _Txn('t7', 'New laptop purchased with cash — \$1,800', _Acct.asset),
    _Txn('t8', 'Staff wages paid — \$6,500', _Acct.expense),
  ];

  final Map<String, _Acct?> _picks = <String, _Acct?>{};
  String? _feedback;

  int get _correctCount {
    int n = 0;
    for (final _Txn t in _txns) {
      if (_picks[t.id] == t.correct) n++;
    }
    return n;
  }

  Future<void> _classify(_Txn t) async {
    final _Acct? chosen = await showModalBottomSheet<_Acct>(
      context: context,
      backgroundColor: AccountingPlayableScreen.surface,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _Acct.values.map((_Acct a) {
              return ListTile(
                title: Text(a.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx, a),
              );
            }).toList(),
          ),
        );
      },
    );
    if (chosen != null) setState(() => _picks[t.id] = chosen);
  }

  void _submit() {
    if (_picks.length < _txns.length) {
      setState(() => _feedback = 'Classify every transaction first.');
      return;
    }
    if (_correctCount < 6) {
      setState(() {
        _feedback =
            'Helen: “Too many misses. Assets vs expenses — and loans are liabilities, not equity.”';
      });
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AccountingPlayableScreen.surface,
          title: const Text(
            'Helen Moss — Queue cleared',
            style: TextStyle(color: AccountingPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            '“$_correctCount / ${_txns.length} coded correctly. Good enough to move on.\n\n'
            'Close room next — the trial balance is off.”',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AccountingPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AccountingPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: AccountingPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Classify transactions', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text(
            'Tap each line and assign Assets / Liabilities / Equity / Revenue / Expense.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), height: 1.4),
          ),
          const SizedBox(height: 12),
          ..._txns.map((_Txn t) {
            final _Acct? pick = _picks[t.id];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: AccountingPlayableScreen.surface,
                title: Text(t.desc, style: const TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text(
                  pick?.label ?? 'Tap to classify',
                  style: TextStyle(
                    color: pick == null
                        ? Colors.white38
                        : AccountingPlayableScreen.accent,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: () => _classify(t),
              ),
            );
          }),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24), height: 1.4)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AccountingPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('SUBMIT TO HELEN', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _AccountingLab2Screen extends StatefulWidget {
  const _AccountingLab2Screen();

  @override
  State<_AccountingLab2Screen> createState() => _AccountingLab2ScreenState();
}

class _AccountingLab2ScreenState extends State<_AccountingLab2Screen> {
  /// Mispost: office supplies expense coded as Equipment (asset) for \$900.
  static const String _mispostId = 'm4';

  static const List<({String id, String line, String postedAs})> _lines =
      <({String id, String line, String postedAs})>[
    (id: 'm1', line: 'Cash sale \$1,200', postedAs: 'Dr Cash / Cr Revenue'),
    (id: 'm2', line: 'Pay vendor AP \$800', postedAs: 'Dr AP / Cr Cash'),
    (id: 'm3', line: 'Owner draw \$500', postedAs: 'Dr Equity / Cr Cash'),
    (
      id: 'm4',
      line: 'Office supplies \$900 (consumed this month)',
      postedAs: 'Dr Equipment (Asset) / Cr Cash',
    ),
    (id: 'm5', line: 'Bank loan interest \$220', postedAs: 'Dr Interest Expense / Cr Cash'),
    (id: 'm6', line: 'Customer prepay \$1,000', postedAs: 'Dr Cash / Cr Unearned Revenue'),
  ];

  String? _picked;
  String? _feedback;

  void _submit() {
    if (_picked != _mispostId) {
      setState(() {
        _feedback =
            'Helen: “Still unbalanced. Look for something that should be an expense '
            'but landed in assets.”';
      });
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AccountingPlayableScreen.surface,
          title: const Text(
            'Helen Moss — Books corrected',
            style: TextStyle(color: AccountingPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“Supplies were misposted to Equipment. Recode to Expense — trial balance clears.\n\n'
            'That\'s the job.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AccountingPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AccountingPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: AccountingPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Discrepancy hunt', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AccountingPlayableScreen.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF87171).withValues(alpha: 0.5)),
            ),
            child: const Text(
              'Trial balance: Debits \$128,400 · Credits \$127,500\n'
              'Off by \$900. Tap the misposted entry.',
              style: TextStyle(color: Colors.white, height: 1.45),
            ),
          ),
          const SizedBox(height: 14),
          ..._lines.map((({String id, String line, String postedAs}) row) {
            final bool selected = _picked == row.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: selected
                    ? AccountingPlayableScreen.accent.withValues(alpha: 0.15)
                    : AccountingPlayableScreen.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _picked = row.id),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(row.line, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(row.postedAs, style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24), height: 1.4)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AccountingPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('FLAG MISPOST', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
