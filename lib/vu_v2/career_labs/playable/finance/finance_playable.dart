import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// Apex Capital — Junior Financial Analyst under Nora Hale.
class FinancePlayableScreen extends StatelessWidget {
  const FinancePlayableScreen({super.key});

  static const Color accent = Color(0xFF34D399);
  static const Color bg = Color(0xFF06140F);
  static const Color surface = Color(0xFF0C1F18);

  static const PlayableCareer career = PlayableCareer(
    id: 'finance',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'Apex Capital',
    clockLine: 'Monday — 7:18 AM',
    roleTitle: 'Junior Financial Analyst',
    supervisorName: 'Nora Hale',
    supervisorRole: 'VP / Markets Desk',
    hireTagline: 'Price risk honestly. This desk is not a quiz.',
    supervisorBrief:
        '“Client packet on your screen — statements only. '
        'Find what is wrong before the market open.\n\n'
        'Then we allocate. No guessing.”',
    enterCta: 'ENTER THE DESK',
    startCta: 'OPEN STATEMENTS',
    startLocationId: 'desk',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'lobby',
        name: 'Lobby',
        icon: '🏛️',
        blurb: 'Quiet marble and market tickers.',
        atmosphere: 'Apex Capital. Phones muted until open. Coffee already cold.',
      ),
      PlayableRoom(
        id: 'desk',
        name: 'Analyst Desk',
        icon: '💻',
        blurb: 'Screens, models, silence.',
        atmosphere: 'Your terminal waits. Statements first. Diagnosis before allocation.',
      ),
      PlayableRoom(
        id: 'research',
        name: 'Research Bay',
        icon: '📈',
        blurb: 'Filings and sector notes.',
        atmosphere: 'Sector notes lean defensive. Liquidity talk is louder than alpha talk.',
      ),
      PlayableRoom(
        id: 'risk',
        name: 'Risk Office',
        icon: '🛡️',
        blurb: 'Limits and stress tests.',
        atmosphere: 'Risk wants cash coverage before any equity overweight.',
      ),
      PlayableRoom(
        id: 'hale',
        name: 'Nora\'s Office',
        icon: '🚪',
        blurb: 'VP review.',
        atmosphere: 'Nora wants a one-sentence problem and a defensible allocation.',
      ),
      PlayableRoom(
        id: 'trading',
        name: 'Trading Floor',
        icon: '📡',
        blurb: 'Simulated market move.',
        atmosphere: 'When you allocate, the floor runs a one-day shock.',
        lockedUntilStageId: 'lab1',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'desk',
        bannerTitle: 'ACTIVE SITUATION',
        bannerBody: 'Analyze company statements. Identify the real problem.',
        cta: 'Read the statements',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'trading',
        bannerTitle: 'PORTFOLIO SESSION',
        bannerBody: 'Allocate stocks / bonds / cash, take the market move, explain the call.',
        cta: 'Build the book',
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
            MaterialPageRoute<bool>(builder: (_) => const _FinanceLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _FinanceLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

class _FinanceLab1Screen extends StatefulWidget {
  const _FinanceLab1Screen();

  @override
  State<_FinanceLab1Screen> createState() => _FinanceLab1ScreenState();
}

class _FinanceLab1ScreenState extends State<_FinanceLab1Screen> {
  String? _diagnosis;
  String? _feedback;

  void _submit() {
    if (_diagnosis != 'cashflow') {
      setState(() {
        _feedback =
            'Nora: “Look again. Revenue is fine. Debt is manageable. '
            'Where does the squeeze show up?”';
      });
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: FinancePlayableScreen.surface,
          title: const Text(
            'Nora Hale — Confirmed',
            style: TextStyle(color: FinancePlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“Cash flow squeeze. Working capital and receivables are eating liquidity.\n\n'
            'Next: allocate the client book for a one-day shock.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: FinancePlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  Widget _line(String k, String v, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(k, style: const TextStyle(color: Colors.white70))),
          Text(v, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinancePlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: FinancePlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Client statements', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FinancePlayableScreen.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: FinancePlayableScreen.accent.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'MERIDIAN SUPPLY CO. — TTM',
                  style: TextStyle(
                    color: FinancePlayableScreen.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 12),
                _line('Revenue', '\$48.2M  (+6% YoY)'),
                _line('Operating expenses', '\$41.1M'),
                _line('Net income', '\$3.4M'),
                _line('Long-term debt', '\$12.0M  (interest covered 4.1×)'),
                _line('Operating cash flow', '\$0.9M  (−62% YoY)', color: const Color(0xFFF87171)),
                _line('Cash & equivalents', '\$1.1M  (was \$3.8M)', color: const Color(0xFFF87171)),
                _line('Days sales outstanding', '68  (was 41)', color: const Color(0xFFFBBF24)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'WHAT IS THE PROBLEM?',
            style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8),
          ),
          ...const <(String, String)>[
            ('revenue', 'Collapsing revenue'),
            ('debt', 'Unsustainable debt load'),
            ('cashflow', 'Cash flow squeeze'),
            ('expenses', 'Expense explosion'),
          ].map(((String, String) o) {
            final bool on = _diagnosis == o.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: on ? FinancePlayableScreen.accent : Colors.transparent,
                  ),
                ),
                tileColor: FinancePlayableScreen.surface,
                leading: Icon(
                  on ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: FinancePlayableScreen.accent,
                ),
                title: Text(o.$2, style: const TextStyle(color: Colors.white)),
                onTap: () => setState(() => _diagnosis = o.$1),
              ),
            );
          }),
          if (_feedback != null)
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24), height: 1.4)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: FinancePlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('SEND TO NORA', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _FinanceLab2Screen extends StatefulWidget {
  const _FinanceLab2Screen();

  @override
  State<_FinanceLab2Screen> createState() => _FinanceLab2ScreenState();
}

class _FinanceLab2ScreenState extends State<_FinanceLab2Screen> {
  double _stocks = 0.45;
  double _bonds = 0.35;
  // cash = remainder
  bool _shocked = false;
  final TextEditingController _explain = TextEditingController();

  double get _cash => (1.0 - _stocks - _bonds).clamp(0.0, 1.0);

  void _normalizeFromStocks(double v) {
    setState(() {
      _stocks = v.clamp(0.0, 1.0);
      if (_stocks + _bonds > 1.0) _bonds = 1.0 - _stocks;
    });
  }

  void _normalizeFromBonds(double v) {
    setState(() {
      _bonds = v.clamp(0.0, 1.0 - _stocks);
    });
  }

  double get _outcome {
    // Simulated risk-off day: stocks −8%, bonds +1.5%, cash 0
    if (!_shocked) return 0;
    return _stocks * -8.0 + _bonds * 1.5 + _cash * 0.0;
  }

  void _runShock() {
    setState(() => _shocked = true);
  }

  void _finish() {
    if (!_shocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Run the market move first.')),
      );
      return;
    }
    if (_explain.text.trim().length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Explain your allocation in a sentence or two.')),
      );
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        final String sign = _outcome >= 0 ? '+' : '';
        return AlertDialog(
          backgroundColor: FinancePlayableScreen.surface,
          title: const Text(
            'Nora Hale — Desk note',
            style: TextStyle(color: FinancePlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: Text(
            'One-day shock P&L: $sign${_outcome.toStringAsFixed(1)}%\n\n'
            '“You sized for a cash-flow-aware client. Keep explaining risk in plain English.”',
            style: const TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: FinancePlayableScreen.accent,
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
  void dispose() {
    _explain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinancePlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: FinancePlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Portfolio allocation', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Text(
            'Client needs liquidity while statements recover. Allocate, then take the shock.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), height: 1.4),
          ),
          const SizedBox(height: 16),
          Text('Stocks  ${(_stocks * 100).round()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _stocks,
            onChanged: _normalizeFromStocks,
            activeColor: FinancePlayableScreen.accent,
          ),
          Text('Bonds  ${(_bonds * 100).round()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          Slider(
            value: _bonds,
            max: 1.0 - _stocks,
            onChanged: _normalizeFromBonds,
            activeColor: FinancePlayableScreen.accent,
          ),
          Text(
            'Cash  ${(_cash * 100).round()}%',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (_shocked)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: FinancePlayableScreen.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _outcome >= 0
                      ? FinancePlayableScreen.accent
                      : const Color(0xFFF87171),
                ),
              ),
              child: Text(
                'Market move (risk-off day)\nStocks −8% · Bonds +1.5% · Cash flat\n\n'
                'Book P&L: ${_outcome >= 0 ? '+' : ''}${_outcome.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, height: 1.45),
              ),
            )
          else
            OutlinedButton(
              onPressed: _runShock,
              style: OutlinedButton.styleFrom(
                foregroundColor: FinancePlayableScreen.accent,
                side: const BorderSide(color: FinancePlayableScreen.accent),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('RUN MARKET MOVE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _explain,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Explain your allocation to Nora…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              filled: true,
              fillColor: FinancePlayableScreen.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _finish,
            style: FilledButton.styleFrom(
              backgroundColor: FinancePlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('SUBMIT TO NORA', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
