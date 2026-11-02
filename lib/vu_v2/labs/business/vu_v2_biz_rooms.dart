import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../screens/business/business_school_screen.dart';
import '../../../services/business_school_progress_service.dart';
import 'vu_v2_biz_company_state.dart';
import 'vu_v2_biz_decision_engine.dart';
import 'vu_v2_biz_department_catalog.dart';
import 'vu_v2_biz_mentor.dart';
import 'vu_v2_biz_theme.dart';

typedef BizApply = Future<void> Function(VuV2BizOutcome outcome);

class VuV2BizLabScope extends InheritedWidget {
  const VuV2BizLabScope({
    super.key,
    required this.onOpenRoom,
    required super.child,
  });

  final ValueChanged<VuV2BizRoomId> onOpenRoom;

  static VuV2BizLabScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<VuV2BizLabScope>();
  }

  @override
  bool updateShouldNotify(covariant VuV2BizLabScope oldWidget) {
    return onOpenRoom != oldWidget.onOpenRoom;
  }
}

class VuV2BizRoomScaffold extends StatelessWidget {
  const VuV2BizRoomScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.child,
    this.actions,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: VuV2BizColors.mute, height: 1.4),
        ),
        if (actions != null) ...<Widget>[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: actions!),
        ],
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class VuV2BizChoiceTile extends StatelessWidget {
  const VuV2BizChoiceTile({
    super.key,
    required this.title,
    required this.body,
    required this.onTap,
    this.accent = VuV2BizColors.royal,
  });

  final String title;
  final String body;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: VuV2BizGlassCard(
        onTap: onTap,
        borderColor: accent.withValues(alpha: 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: VuV2BizColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: const TextStyle(
                color: VuV2BizColors.mute,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _apply(
  BuildContext context,
  VuV2BizCompanyState company,
  VuV2BizOutcome outcome, {
  ValueChanged<VuV2BizRoomId>? onOpenRoom,
}) async {
  await company.applyOutcome(outcome);
  if (outcome.department == 'crisis') {
    await company.clearCrisisFlag();
  }
  if (!context.mounted) {
    return;
  }
  final VuV2BizRoomId? next = await showBizLoopDialog(
    context,
    company: company,
    outcome: outcome,
  );
  if (!context.mounted) {
    return;
  }
  final ValueChanged<VuV2BizRoomId>? nav =
      onOpenRoom ?? VuV2BizLabScope.maybeOf(context)?.onOpenRoom;
  if (next != null && nav != null) {
    nav(next);
  }
}

// ── Marketing ──────────────────────────────────────────────────────────────

class VuV2BizMarketingRoom extends StatefulWidget {
  const VuV2BizMarketingRoom({
    super.key,
    required this.company,
    this.onOpenRoom,
  });
  final VuV2BizCompanyState company;
  final ValueChanged<VuV2BizRoomId>? onOpenRoom;

  @override
  State<VuV2BizMarketingRoom> createState() => _VuV2BizMarketingRoomState();
}

class _VuV2BizMarketingRoomState extends State<VuV2BizMarketingRoom> {
  String _audience = 'Young professionals';
  String _platform = 'TikTok';
  double _budget = 15000;
  bool _retention = false;
  final TextEditingController _slogan = TextEditingController(
    text: 'Clarity beats noise.',
  );

  @override
  void dispose() {
    _slogan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VuV2BizRoomScaffold(
      title: 'Marketing Campaign Builder',
      subtitle:
          'Brief → configure → launch → see channel lift → debrief with the mentor.',
      accent: const Color(0xFF8B5CF6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          VuV2BizGlassCard(
            borderColor: VuV2BizColors.royal.withValues(alpha: 0.4),
            child: Text(
              'Brief: Grow revenue without training customers to ignore the brand. '
              'Your style so far — ${widget.company.decisionStyleSummary}',
              style: const TextStyle(color: VuV2BizColors.mute, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          VuV2BizGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Target audience',
                    style: TextStyle(
                        color: VuV2BizColors.mute, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <String>[
                    'Young professionals',
                    'Enterprise buyers',
                    'Students',
                    'Parents',
                  ].map((String a) {
                    final bool on = _audience == a;
                    return ChoiceChip(
                      label: Text(a),
                      selected: on,
                      onSelected: (_) => setState(() => _audience = a),
                      selectedColor: const Color(0xFF8B5CF6),
                      labelStyle: TextStyle(
                        color: on ? Colors.white : VuV2BizColors.mute,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: VuV2BizColors.midnight,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text('Platform',
                    style: TextStyle(
                        color: VuV2BizColors.mute, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <String>[
                    'TikTok',
                    'Instagram',
                    'Search',
                    'TV Ads',
                    'Email',
                  ].map((String p) {
                    final bool on = _platform == p;
                    return ChoiceChip(
                      label: Text(p),
                      selected: on,
                      onSelected: (_) => setState(() => _platform = p),
                      selectedColor: VuV2BizColors.royal,
                      labelStyle: TextStyle(
                        color: on ? Colors.white : VuV2BizColors.mute,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: VuV2BizColors.midnight,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  'Budget: ${VuV2BizCompanyState.money(_budget)}',
                  style: const TextStyle(
                    color: VuV2BizColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Slider(
                  value: _budget,
                  min: 2000,
                  max: 60000,
                  divisions: 29,
                  activeColor: const Color(0xFF8B5CF6),
                  onChanged: (double v) => setState(() => _budget = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Attach retention offer',
                    style: TextStyle(
                      color: VuV2BizColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Balances acquisition-heavy habits; lifts loyalty.',
                    style: TextStyle(color: VuV2BizColors.mute, fontSize: 12),
                  ),
                  value: _retention,
                  activeTrackColor: VuV2BizColors.emerald,
                  onChanged: (bool v) => setState(() => _retention = v),
                ),
                TextField(
                  controller: _slogan,
                  style: const TextStyle(color: VuV2BizColors.ink),
                  decoration: const InputDecoration(
                    labelText: 'Slogan',
                    labelStyle: TextStyle(color: VuV2BizColors.mute),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: VuV2BizColors.stroke),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    if (_slogan.text.trim().length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Write a real slogan (8+ characters) before launch — interns do not ship blank creative.',
                          ),
                        ),
                      );
                      return;
                    }
                    final VuV2BizOutcome o =
                        VuV2BizDecisionEngine.marketingLaunch(
                      platform: _platform,
                      budget: _budget,
                      audience: _audience,
                      retentionBundle: _retention,
                      slogan: _slogan.text,
                    );
                    await _apply(
                      context,
                      widget.company,
                      o,
                      onOpenRoom: widget.onOpenRoom,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Launch campaign'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Finance ────────────────────────────────────────────────────────────────

class VuV2BizFinanceRoom extends StatefulWidget {
  const VuV2BizFinanceRoom({
    super.key,
    required this.company,
    this.onOpenRoom,
  });
  final VuV2BizCompanyState company;
  final ValueChanged<VuV2BizRoomId>? onOpenRoom;

  @override
  State<VuV2BizFinanceRoom> createState() => _VuV2BizFinanceRoomState();
}

class _VuV2BizFinanceRoomState extends State<VuV2BizFinanceRoom> {
  late double _revenue;
  late double _cogs;
  late double _payroll;
  late double _marketing;
  late double _rent;
  late double _other;
  late double _recv;
  late double _inv;
  late double _equip;
  late double _pay;
  late double _debt;

  @override
  void initState() {
    super.initState();
    final VuV2BizCompanyState c = widget.company;
    _revenue = c.pnlRevenue;
    _cogs = c.pnlCogs;
    _payroll = c.pnlPayroll;
    _marketing = c.pnlMarketing;
    _rent = c.pnlRent;
    _other = c.pnlOther;
    _recv = c.bsReceivables;
    _inv = c.bsInventory;
    _equip = c.bsEquipment;
    _pay = c.bsPayables;
    _debt = c.bsDebt;
  }

  double get _gross => _revenue - _cogs;
  double get _opex => _payroll + _marketing + _rent + _other;
  double get _net => _gross - _opex;
  double get _assets => widget.company.cash + _recv + _inv + _equip;
  double get _liab => _pay + _debt;
  double get _equity => _assets - _liab;

  @override
  Widget build(BuildContext context) {
    final VuV2BizCompanyState company = widget.company;
    return VuV2BizRoomScaffold(
      title: 'Finance · Books & capital',
      subtitle:
          'Build this quarter\'s P&L and balance sheet — then face a capital shock.',
      accent: VuV2BizColors.emerald,
      child: Column(
        children: <Widget>[
          VuV2BizGlassCard(
            borderColor: VuV2BizColors.emerald.withValues(alpha: 0.45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Simplified P&L (you produce these numbers)',
                  style: TextStyle(
                    color: VuV2BizColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                _slider('Revenue', _revenue, 0, 250000, (double v) {
                  setState(() => _revenue = v);
                }),
                _slider('COGS', _cogs, 0, 120000, (double v) {
                  setState(() => _cogs = v);
                }),
                _slider('Payroll', _payroll, 0, 120000, (double v) {
                  setState(() => _payroll = v);
                }),
                _slider('Marketing', _marketing, 0, 80000, (double v) {
                  setState(() => _marketing = v);
                }),
                _slider('Rent', _rent, 0, 40000, (double v) {
                  setState(() => _rent = v);
                }),
                _slider('Other opex', _other, 0, 40000, (double v) {
                  setState(() => _other = v);
                }),
                const Divider(color: VuV2BizColors.stroke),
                _kv('Gross profit', VuV2BizCompanyState.money(_gross)),
                _kv('Operating expenses', VuV2BizCompanyState.money(_opex)),
                _kv('Net income', VuV2BizCompanyState.money(_net)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          VuV2BizGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Balance sheet',
                  style: TextStyle(
                    color: VuV2BizColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                _kv('Cash (ops)', VuV2BizCompanyState.money(company.cash)),
                _slider('Receivables', _recv, 0, 120000, (double v) {
                  setState(() => _recv = v);
                }),
                _slider('Inventory', _inv, 0, 100000, (double v) {
                  setState(() => _inv = v);
                }),
                _slider('Equipment', _equip, 0, 500000, (double v) {
                  setState(() => _equip = v);
                }),
                _slider('Payables', _pay, 0, 120000, (double v) {
                  setState(() => _pay = v);
                }),
                _slider('Debt', _debt, 0, 400000, (double v) {
                  setState(() => _debt = v);
                }),
                const Divider(color: VuV2BizColors.stroke),
                _kv('Total assets', VuV2BizCompanyState.money(_assets)),
                _kv('Total liabilities', VuV2BizCompanyState.money(_liab)),
                _kv('Equity', VuV2BizCompanyState.money(_equity)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    await company.commitStudentBooks(
                      revenue: _revenue,
                      cogs: _cogs,
                      payroll: _payroll,
                      marketing: _marketing,
                      rent: _rent,
                      other: _other,
                      receivables: _recv,
                      inventory: _inv,
                      equipment: _equip,
                      payables: _pay,
                      debt: _debt,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    await _apply(
                      context,
                      company,
                      VuV2BizDecisionEngine.booksClosed(company),
                      onOpenRoom: widget.onOpenRoom,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: VuV2BizColors.emerald,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Close the books this quarter'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Unexpected capital event',
              style: TextStyle(
                color: VuV2BizColors.warning,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const VuV2BizGlassCard(
            child: Text(
              'Factory machine broke. Choose a response — it compounds into quality.',
              style: TextStyle(color: VuV2BizColors.ink, height: 1.4),
            ),
          ),
          const SizedBox(height: 10),
          VuV2BizChoiceTile(
            title: 'Repair — \$40,000',
            body: 'Fast fix. Residual failure risk remains.',
            accent: VuV2BizColors.emerald,
            onTap: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.financeEvent('repair'),
              onOpenRoom: widget.onOpenRoom,
            ),
          ),
          VuV2BizChoiceTile(
            title: 'Replace — \$80,000',
            body: 'Higher reliability and capacity.',
            accent: VuV2BizColors.royal,
            onTap: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.financeEvent('replace'),
              onOpenRoom: widget.onOpenRoom,
            ),
          ),
          VuV2BizChoiceTile(
            title: 'Lease — \$15,000 / month',
            body: 'Lower upfront cash, higher ongoing burn.',
            accent: VuV2BizColors.warning,
            onTap: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.financeEvent('lease'),
              onOpenRoom: widget.onOpenRoom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: VuV2BizColors.mute, fontWeight: FontWeight.w600)),
            ),
            Text(VuV2BizCompanyState.money(value),
                style: const TextStyle(
                    color: VuV2BizColors.ink, fontWeight: FontWeight.w800)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: VuV2BizColors.emerald,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(k,
                style: const TextStyle(
                    color: VuV2BizColors.mute, fontWeight: FontWeight.w600)),
          ),
          Text(v,
              style: const TextStyle(
                  color: VuV2BizColors.ink, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

// ── HR ─────────────────────────────────────────────────────────────────────

class VuV2BizHrRoom extends StatefulWidget {
  const VuV2BizHrRoom({
    super.key,
    required this.company,
    this.onOpenRoom,
  });
  final VuV2BizCompanyState company;
  final ValueChanged<VuV2BizRoomId>? onOpenRoom;

  @override
  State<VuV2BizHrRoom> createState() => _VuV2BizHrRoomState();
}

class _VuV2BizHrRoomState extends State<VuV2BizHrRoom> {
  final TextEditingController _notes = TextEditingController();
  String _candidate = 'Amina Okoro';

  static const List<String> _candidates = <String>[
    'Amina Okoro — Senior ops · strong systems, expensive',
    'Leo Park — Junior generalist · cheap, needs coaching',
    'Samir Haddad — Mid sales · closes deals, culture risk',
  ];

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VuV2BizCompanyState company = widget.company;
    return VuV2BizRoomScaffold(
      title: 'People Ops · Live hiring desk',
      subtitle:
          'Interview like an intern who wants the full-time offer. Notes are required.',
      accent: const Color(0xFFEC4899),
      child: Column(
        children: <Widget>[
          VuV2BizGlassCard(
            child: Text(
              'Floor status — Headcount ${company.employees} · '
              'Morale ${VuV2BizCompanyState.pct(company.morale)}',
              style: const TextStyle(
                color: VuV2BizColors.ink,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          VuV2BizGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Interview slate',
                  style: TextStyle(
                    color: VuV2BizColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < _candidates.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: VuV2BizChoiceTile(
                      title: _candidates[i].split(' — ').first,
                      body: _candidates[i].contains(' — ')
                          ? _candidates[i].split(' — ').last
                          : '',
                      accent: _candidate == _candidates[i].split(' — ').first
                          ? const Color(0xFFEC4899)
                          : VuV2BizColors.stroke,
                      onTap: () => setState(
                        () =>
                            _candidate = _candidates[i].split(' — ').first,
                      ),
                    ),
                  ),
                TextField(
                  controller: _notes,
                  maxLines: 3,
                  style: const TextStyle(color: VuV2BizColors.ink),
                  decoration: const InputDecoration(
                    labelText: 'Interview notes (required)',
                    labelStyle: TextStyle(color: VuV2BizColors.mute),
                    hintText: 'Strengths, risks, culture fit…',
                    hintStyle: TextStyle(color: VuV2BizColors.mute),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    if (_notes.text.trim().length < 25) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Write real interview notes (25+ chars). Empty forms get rejected.',
                          ),
                        ),
                      );
                      return;
                    }
                    final bool senior = _candidate.contains('Amina');
                    await _apply(
                      context,
                      company,
                      VuV2BizDecisionEngine.hireEmployee(senior: senior),
                      onOpenRoom: widget.onOpenRoom,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text('Extend offer to $_candidate'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Escalation · Two managers in open conflict',
              style: TextStyle(
                color: VuV2BizColors.warning,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const VuV2BizGlassCard(
            child: Text(
              'Jordan (Sales) and Riley (Ops) argued in Slack in front of the team. Customers wait on a delayed shipment. You own the next 30 minutes.',
              style: TextStyle(color: VuV2BizColors.ink, height: 1.4),
            ),
          ),
          const SizedBox(height: 10),
          VuV2BizChoiceTile(
            title: 'Mediate now (private room + written agreement)',
            body: 'Internship-standard: restore trust, document next steps.',
            accent: VuV2BizColors.emerald,
            onTap: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.hrConflict('mediate'),
              onOpenRoom: widget.onOpenRoom,
            ),
          ),
          VuV2BizChoiceTile(
            title: 'Issue written warning to both',
            body: 'Clarity first. Watch for chill effect on the floor.',
            onTap: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.hrConflict('discipline'),
              onOpenRoom: widget.onOpenRoom,
            ),
          ),
          VuV2BizChoiceTile(
            title: 'Ignore until Friday',
            body: 'Avoid discomfort — often the worst internship instinct.',
            accent: VuV2BizColors.danger,
            onTap: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.hrConflict('ignore'),
              onOpenRoom: widget.onOpenRoom,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Operations ─────────────────────────────────────────────────────────────

class VuV2BizOperationsRoom extends StatelessWidget {
  const VuV2BizOperationsRoom({super.key, required this.company});
  final VuV2BizCompanyState company;

  @override
  Widget build(BuildContext context) {
    return VuV2BizRoomScaffold(
      title: 'Operations Lab',
      subtitle:
          'Quality debt compounds. Skip QC twice and a defect crisis will earn itself.',
      accent: const Color(0xFF0EA5E9),
      child: Column(
        children: <Widget>[
          VuV2BizGlassCard(
            child: Text(
              'Quality index ${VuV2BizCompanyState.pct(company.qualityIndex)} · '
              'Neglect streak ${company.consecutiveQualityNeglect}',
              style: const TextStyle(
                color: VuV2BizColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          VuV2BizChoiceTile(
            title: 'Invest in quality control',
            body: 'Spend now; reduce defect risk and brand drag.',
            accent: VuV2BizColors.emerald,
            onTap: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.investQuality(),
            ),
          ),
          VuV2BizChoiceTile(
            title: 'Defer QC to hit shipment targets',
            body: 'Short-term throughput. Quality debt stacks toward a crisis.',
            accent: VuV2BizColors.danger,
            onTap: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.skipQualityControl(),
            ),
          ),
          const SizedBox(height: 8),
          const VuV2BizGlassCard(
            child: Text(
              'Supplier delay detected. Customer orders are at risk this week.',
              style: TextStyle(color: VuV2BizColors.ink, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          VuV2BizChoiceTile(
            title: 'Authorize air freight',
            body: 'Protect SLAs. Expensive but preserves trust.',
            accent: VuV2BizColors.emerald,
            onTap: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.operationsShock('air_freight'),
            ),
          ),
          VuV2BizChoiceTile(
            title: 'Switch to alternate supplier',
            body: 'Diversify risk; modest unit-cost increase.',
            onTap: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.operationsShock('alternate_supplier'),
            ),
          ),
          VuV2BizChoiceTile(
            title: 'Accept the delay',
            body: 'Conserve cash; risk satisfaction and share.',
            accent: VuV2BizColors.danger,
            onTap: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.operationsShock('accept_delay'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Strategy ───────────────────────────────────────────────────────────────

class VuV2BizStrategyRoom extends StatefulWidget {
  const VuV2BizStrategyRoom({super.key, required this.company});
  final VuV2BizCompanyState company;

  @override
  State<VuV2BizStrategyRoom> createState() => _VuV2BizStrategyRoomState();
}

class _VuV2BizStrategyRoomState extends State<VuV2BizStrategyRoom> {
  final TextEditingController _why = TextEditingController();

  @override
  void dispose() {
    _why.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VuV2BizRoomScaffold(
      title: 'Strategy Room',
      subtitle: 'Digital war-room. Justify market moves with evidence.',
      accent: const Color(0xFF6366F1),
      child: Column(
        children: <Widget>[
          VuV2BizGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('SWOT snapshot',
                    style: TextStyle(
                        color: VuV2BizColors.gold, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(
                  'Strengths: brand trust ${VuV2BizCompanyState.pct(widget.company.reputation)}\n'
                  'Weaknesses: cash ${VuV2BizCompanyState.money(widget.company.cash)}\n'
                  'Opportunities: adjacent markets\n'
                  'Threats: ${widget.company.currentChallenge}',
                  style: const TextStyle(
                      color: VuV2BizColors.mute, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const VuV2BizGlassCard(
            child: Text(
              'AI Mentor: Should your company enter the Asian market?',
              style: TextStyle(
                color: VuV2BizColors.ink,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _why,
            maxLines: 3,
            style: const TextStyle(color: VuV2BizColors.ink),
            decoration: InputDecoration(
              hintText: 'Justify your decision in 2–3 sentences…',
              hintStyle: const TextStyle(color: VuV2BizColors.mute),
              filled: true,
              fillColor: VuV2BizColors.midnight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(VuV2BizRadii.md),
                borderSide: const BorderSide(color: VuV2BizColors.stroke),
              ),
            ),
          ),
          const SizedBox(height: 12),
          VuV2BizChoiceTile(
            title: 'Enter Asia',
            body: 'Commit capital to localization and partnerships.',
            accent: VuV2BizColors.emerald,
            onTap: () async {
              if (_why.text.trim().length < 40) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Write a real justification (40+ chars) with cash, risk, or competitor evidence.',
                    ),
                  ),
                );
                return;
              }
              await _apply(
                context,
                widget.company,
                VuV2BizDecisionEngine.strategyExpand(
                  true,
                  justification: _why.text,
                ),
              );
            },
          ),
          VuV2BizChoiceTile(
            title: 'Stay focused on core markets',
            body: 'Protect runway; revisit expansion later.',
            onTap: () async {
              if (_why.text.trim().length < 40) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Defend the deferral in writing — Boards reject vibes.',
                    ),
                  ),
                );
                return;
              }
              await _apply(
                context,
                widget.company,
                VuV2BizDecisionEngine.strategyExpand(
                  false,
                  justification: _why.text,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Negotiation ────────────────────────────────────────────────────────────

class VuV2BizNegotiationRoom extends StatefulWidget {
  const VuV2BizNegotiationRoom({super.key, required this.company});
  final VuV2BizCompanyState company;

  @override
  State<VuV2BizNegotiationRoom> createState() => _VuV2BizNegotiationRoomState();
}

class _VuV2BizNegotiationRoomState extends State<VuV2BizNegotiationRoom> {
  final List<_ChatLine> _lines = <_ChatLine>[
    const _ChatLine(
      fromAi: true,
      text:
          'I am Mira Chen, partner at Apex Ventures. Why should I invest \$2M in your company?',
    ),
  ];
  final TextEditingController _reply = TextEditingController();
  int _playerTurns = 0;
  bool _mentionedEconomics = false;
  bool _offeredConcession = false;

  static const List<String> _rubricPreview = <String>[
    'Clarity of ask (unit economics / payback)',
    'Tone & rapport',
    'Concession strategy (give/get)',
    'Preparation (multi-turn engagement)',
  ];

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  void _send() {
    final String t = _reply.text.trim();
    if (t.isEmpty) {
      return;
    }
    final String lower = t.toLowerCase();
    if (lower.contains('margin') ||
        lower.contains('retention') ||
        lower.contains('payback') ||
        lower.contains('cac') ||
        lower.contains('ltv') ||
        lower.contains('unit economic')) {
      _mentionedEconomics = true;
    }
    if (lower.contains('concession') ||
        lower.contains('board seat') ||
        lower.contains('in exchange') ||
        lower.contains('offer') ||
        lower.contains('willing to')) {
      _offeredConcession = true;
    }
    _playerTurns += 1;
    String ai;
    if (_playerTurns == 1) {
      ai =
          'Interesting. Traction matters more than vision. Show me retention, '
          'gross margin, and a path to payback. What is your ask beyond capital?';
    } else if (_playerTurns == 2) {
      ai =
          'If I take more dilution risk, what concrete concession do I get — '
          'information rights, board observer, or milestone tranches?';
    } else {
      ai =
          'I have enough to decide. Close assertively, collaboratively, or walk — '
          'I will score you on the published rubric, not vibes.';
    }
    setState(() {
      _lines.add(_ChatLine(fromAi: false, text: t));
      _lines.add(_ChatLine(fromAi: true, text: ai));
      _reply.clear();
    });
  }

  Future<void> _close(String stance) async {
    await _apply(
      context,
      widget.company,
      VuV2BizDecisionEngine.negotiation(
        stance: stance,
        messageCount: _playerTurns,
        mentionedUnitEconomics: _mentionedEconomics,
        offeredConcession: _offeredConcession,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VuV2BizRoomScaffold(
      title: 'Negotiation Room',
      subtitle:
          'Soft-skill arena. Graded on a visible rubric — not a black box.',
      accent: VuV2BizColors.gold,
      child: Column(
        children: <Widget>[
          VuV2BizGlassCard(
            borderColor: VuV2BizColors.emerald.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Published rubric (max 20)',
                  style: TextStyle(
                    color: VuV2BizColors.emerald,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < _rubricPreview.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${_rubricPreview[i]}',
                      style: const TextStyle(
                        color: VuV2BizColors.mute,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          VuV2BizGlassCard(
            borderColor: VuV2BizColors.gold.withValues(alpha: 0.45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Mira Chen · Apex Ventures',
                  style: TextStyle(
                    color: VuV2BizColors.gold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                for (int i = 0; i < _lines.length; i++)
                  Align(
                    alignment: _lines[i].fromAi
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        color: _lines[i].fromAi
                            ? VuV2BizColors.midnight
                            : VuV2BizColors.royal.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: VuV2BizColors.stroke),
                      ),
                      child: Text(
                        _lines[i].text,
                        style: const TextStyle(
                          color: VuV2BizColors.ink,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _reply,
                        style: const TextStyle(color: VuV2BizColors.ink),
                        decoration: const InputDecoration(
                          hintText:
                              'Pitch with margins, retention, payback, concessions…',
                          hintStyle: TextStyle(color: VuV2BizColors.mute),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send, color: VuV2BizColors.gold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Close the round',
            style: TextStyle(
              color: VuV2BizColors.mute,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          VuV2BizChoiceTile(
            title: 'Assertive close',
            body: 'Push for strong terms and ownership clarity.',
            accent: VuV2BizColors.emerald,
            onTap: () => _close('assertive'),
          ),
          VuV2BizChoiceTile(
            title: 'Collaborative partnership',
            body: 'Trade some terms for long-term alignment.',
            onTap: () => _close('collaborative'),
          ),
          VuV2BizChoiceTile(
            title: 'Walk away',
            body: 'Protect downside; seek a better fit.',
            accent: VuV2BizColors.danger,
            onTap: () => _close('walk'),
          ),
        ],
      ),
    );
  }
}

class _ChatLine {
  const _ChatLine({required this.fromAi, required this.text});
  final bool fromAi;
  final String text;
}

// ── Board ──────────────────────────────────────────────────────────────────

class VuV2BizBoardRoom extends StatefulWidget {
  const VuV2BizBoardRoom({super.key, required this.company});
  final VuV2BizCompanyState company;

  @override
  State<VuV2BizBoardRoom> createState() => _VuV2BizBoardRoomState();
}

class _VuV2BizBoardRoomState extends State<VuV2BizBoardRoom> {
  bool _leadWithEconomics = true;
  bool _nameRisks = true;
  bool _askForCapital = false;
  final TextEditingController _opening = TextEditingController(
    text: 'This quarter we protected unit economics while funding growth.',
  );

  @override
  void dispose() {
    _opening.dispose();
    super.dispose();
  }

  String _qualityFromPrep() {
    int score = 0;
    if (_leadWithEconomics) score += 2;
    if (_nameRisks) score += 2;
    if (_opening.text.trim().length >= 40) score += 1;
    if (_askForCapital && widget.company.cash < 120000) score -= 1;
    if (score >= 4) return 'strong';
    if (score >= 2) return 'mixed';
    return 'weak';
  }

  @override
  Widget build(BuildContext context) {
    final VuV2BizCompanyState company = widget.company;
    return VuV2BizRoomScaffold(
      title: 'Board Meeting',
      subtitle:
          'Build the presentation from YOUR books — then face the directors.',
      accent: const Color(0xFF14B8A6),
      child: Column(
        children: <Widget>[
          VuV2BizGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Auto-built packet (from company state)',
                  style: TextStyle(
                    color: VuV2BizColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Revenue ${VuV2BizCompanyState.money(company.monthlyRevenue)}/mo · '
                  'Net (books) ${VuV2BizCompanyState.money(company.netIncome)}\n'
                  'Value ${VuV2BizCompanyState.money(company.companyValue)} · '
                  'Cash ${VuV2BizCompanyState.money(company.cash)}\n'
                  'Quality ${VuV2BizCompanyState.pct(company.qualityIndex)} · '
                  'Satisfaction ${VuV2BizCompanyState.pct(company.satisfaction)}\n'
                  'Open risk: ${company.currentChallenge}',
                  style: const TextStyle(
                    color: VuV2BizColors.mute,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          VuV2BizGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Your opening (required)',
                  style: TextStyle(
                    color: VuV2BizColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextField(
                  controller: _opening,
                  maxLines: 3,
                  style: const TextStyle(color: VuV2BizColors.ink),
                  decoration: const InputDecoration(
                    hintText: 'Lead with one number and one risk…',
                    hintStyle: TextStyle(color: VuV2BizColors.mute),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Lead with unit economics',
                      style: TextStyle(
                          color: VuV2BizColors.ink, fontWeight: FontWeight.w700)),
                  value: _leadWithEconomics,
                  activeTrackColor: const Color(0xFF14B8A6),
                  onChanged: (bool v) => setState(() => _leadWithEconomics = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Name the biggest risk out loud',
                      style: TextStyle(
                          color: VuV2BizColors.ink, fontWeight: FontWeight.w700)),
                  value: _nameRisks,
                  activeTrackColor: const Color(0xFF14B8A6),
                  onChanged: (bool v) => setState(() => _nameRisks = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ask for more capital this meeting',
                      style: TextStyle(
                          color: VuV2BizColors.ink, fontWeight: FontWeight.w700)),
                  subtitle: const Text(
                    'Risky if runway is already thin.',
                    style: TextStyle(color: VuV2BizColors.mute, fontSize: 12),
                  ),
                  value: _askForCapital,
                  activeTrackColor: VuV2BizColors.warning,
                  onChanged: (bool v) => setState(() => _askForCapital = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._members.map((String m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: VuV2BizGlassCard(
                child: Text(
                  m,
                  style: const TextStyle(color: VuV2BizColors.ink, height: 1.35),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _apply(
              context,
              company,
              VuV2BizDecisionEngine.boardPresentation(_qualityFromPrep()),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(52),
            ),
            icon: const Icon(Icons.present_to_all),
            label: const Text('Present to the board'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Rubric is visible after you present: finance, logic, calibrated confidence, communication.',
            style: TextStyle(color: VuV2BizColors.mute, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static const List<String> _members = <String>[
    'Elena Park — Chair · Mood: Skeptical · “Show me payback, not slides.”',
    'James Okonkwo — CFO seat · Mood: Analytical · “What happens if churn +2pts?”',
    'Sofia Alvarez — Independent · Mood: Curious · “Where is defensibility?”',
  ];
}

// ── Startup Builder ────────────────────────────────────────────────────────

class VuV2BizStartupRoom extends StatefulWidget {
  const VuV2BizStartupRoom({super.key, required this.company});
  final VuV2BizCompanyState company;

  @override
  State<VuV2BizStartupRoom> createState() => _VuV2BizStartupRoomState();
}

class _VuV2BizStartupRoomState extends State<VuV2BizStartupRoom> {
  int _step = 0;
  String _industry = 'Technology';
  final TextEditingController _name = TextEditingController(text: 'Nova Technologies');

  static const List<String> _steps = <String>[
    'Idea',
    'Business Model',
    'Branding',
    'Funding',
    'Hiring',
    'Launch',
    'Growth',
  ];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VuV2BizRoomScaffold(
      title: 'Startup Builder',
      subtitle: 'Incubator track — build from idea to growth.',
      accent: VuV2BizColors.warning,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _steps.length,
              separatorBuilder: (BuildContext context, int index) => const Icon(
                Icons.chevron_right,
                color: VuV2BizColors.mute,
                size: 18,
              ),
              itemBuilder: (BuildContext context, int i) {
                final bool on = i == _step;
                final bool done = i < _step;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: on
                        ? VuV2BizColors.warning.withValues(alpha: 0.2)
                        : VuV2BizColors.midnight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: on || done
                          ? VuV2BizColors.warning
                          : VuV2BizColors.stroke,
                    ),
                  ),
                  child: Text(
                    _steps[i],
                    style: TextStyle(
                      color: on || done
                          ? VuV2BizColors.ink
                          : VuV2BizColors.mute,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          VuV2BizGlassCard(
            child: _stepBody(),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              if (_step > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _step -= 1),
                  child: const Text('Back'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  if (_step < _steps.length - 1) {
                    setState(() => _step += 1);
                    return;
                  }
                  if (widget.company.decisionLog.isNotEmpty) {
                    final bool? ok = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          backgroundColor: VuV2BizColors.elevated,
                          title: const Text(
                            'Reset the company?',
                            style: TextStyle(color: VuV2BizColors.ink),
                          ),
                          content: const Text(
                            'Launching a new startup wipes your current balance sheet, '
                            'awards progress, and decision history. This is permanent.',
                            style: TextStyle(color: VuV2BizColors.mute),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: VuV2BizColors.danger,
                              ),
                              child: const Text('Wipe & launch'),
                            ),
                          ],
                        );
                      },
                    );
                    if (ok != true) {
                      return;
                    }
                  }
                  await widget.company.resetStartup(
                    name: _name.text,
                    industryLabel: _industry,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  await _apply(
                    context,
                    widget.company,
                    VuV2BizOutcome(
                      title: 'Startup launched',
                      department: 'startup',
                      brief:
                          'You chose $_industry and named ${widget.company.companyName}.',
                      narrative:
                          '${widget.company.companyName} is live. One company, one balance sheet — '
                          'every later course inherits these compounding choices.',
                      debriefPrompt:
                          'What is the first KPI you will refuse to sacrifice in year one?',
                      tags: const <String>['retention_focus'],
                      xpGain: 80,
                      award: 'Startup Founder',
                      advanceQuarter: false,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: VuV2BizColors.warning,
                  foregroundColor: Colors.black,
                ),
                child: Text(_step < _steps.length - 1 ? 'Next' : 'Launch company'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepBody() {
    if (_step == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Choose industry',
              style: TextStyle(
                  color: VuV2BizColors.ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <String>[
              'Technology',
              'Healthcare',
              'Fashion',
              'Education',
              'Finance',
              'Food',
              'Gaming',
              'Manufacturing',
            ].map((String i) {
              final bool on = _industry == i;
              return ChoiceChip(
                label: Text(i),
                selected: on,
                onSelected: (_) => setState(() => _industry = i),
                selectedColor: VuV2BizColors.warning,
                labelStyle: TextStyle(
                  color: on ? Colors.black : VuV2BizColors.mute,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: VuV2BizColors.midnight,
              );
            }).toList(),
          ),
        ],
      );
    }
    if (_step == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Company name',
              style: TextStyle(
                  color: VuV2BizColors.ink, fontWeight: FontWeight.w800)),
          TextField(
            controller: _name,
            style: const TextStyle(color: VuV2BizColors.ink),
          ),
          const SizedBox(height: 10),
          const Text(
            'Logo studio: AI suggests a clean wordmark + geometric mark '
            'in midnight blue and emerald — exportable later.',
            style: TextStyle(color: VuV2BizColors.mute, height: 1.4),
          ),
        ],
      );
    }
    final List<String> copy = <String>[
      '',
      'Pick a model: SaaS subscription, marketplace take-rate, or product sales. '
          'Write the one-sentence value prop before raising.',
      '',
      'Seed targets: friends/family, angels, or a strategic partner. '
          'Practice your ask in Negotiation before taking money.',
      'Hire a founding engineer and a customer-facing generalist first.',
      'Ship an MVP to a beachhead segment. Measure activation, not vanity installs.',
      'Reinvest early profits into the winning channel. Avoid premature multi-market sprawl.',
    ];
    return Text(
      copy[_step],
      style: const TextStyle(color: VuV2BizColors.mute, height: 1.45),
    );
  }
}

// ── Crisis ─────────────────────────────────────────────────────────────────

class VuV2BizCrisisRoom extends StatefulWidget {
  const VuV2BizCrisisRoom({super.key, required this.company});
  final VuV2BizCompanyState company;

  @override
  State<VuV2BizCrisisRoom> createState() => _VuV2BizCrisisRoomState();
}

class _VuV2BizCrisisRoomState extends State<VuV2BizCrisisRoom>
    with SingleTickerProviderStateMixin {
  int _seconds = 45;
  Timer? _timer;
  late AnimationController _shake;
  bool _resolved = false;

  bool get _live => widget.company.crisisInterruptActive;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    if (_live) {
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        if (_resolved) return;
        if (_seconds <= 0) {
          t.cancel();
          _autoFail();
          return;
        }
        setState(() => _seconds -= 1);
        if (_seconds <= 10) _shake.forward(from: 0);
      });
    }
  }

  Future<void> _autoFail() async {
    if (_resolved || !mounted) return;
    _resolved = true;
    await _apply(
      context,
      widget.company,
      VuV2BizDecisionEngine.crisisResponse('deny'),
    );
  }

  Future<void> _pick(String choice) async {
    if (_resolved) return;
    _resolved = true;
    _timer?.cancel();
    await _apply(
      context,
      widget.company,
      VuV2BizDecisionEngine.crisisResponse(choice),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_live) {
      return VuV2BizRoomScaffold(
        title: 'Crisis Center · Standby',
        subtitle: 'No active interrupt. Crises are earned by prior choices — not random pop quizzes.',
        accent: VuV2BizColors.danger,
        child: Column(
          children: <Widget>[
            VuV2BizGlassCard(
              child: Text(
                'Current watchlist: ${widget.company.currentChallenge}\n\n'
                'Quality ${VuV2BizCompanyState.pct(widget.company.qualityIndex)} · '
                'Neglect streak ${widget.company.consecutiveQualityNeglect}.\n\n'
                'Skip QC twice or burn cash while quality slips — then this room lights up with a live countdown.',
                style: const TextStyle(color: VuV2BizColors.mute, height: 1.45),
              ),
            ),
            const SizedBox(height: 12),
            VuV2BizChoiceTile(
              title: 'Drill: practice a transparent response (no KPI penalty)',
              body: 'Training mode — builds muscle memory without a live fire.',
              accent: VuV2BizColors.royal,
              onTap: () => _apply(
                context,
                widget.company,
                const VuV2BizOutcome(
                  title: 'Crisis drill complete',
                  department: 'crisis',
                  brief: 'Practice transparent communication under calm conditions.',
                  narrative:
                      'Drill logged. In a live interrupt you would pay cash and protect reputation by owning the issue fast.',
                  debriefPrompt: 'What would you say in the first customer email?',
                  xpGain: 15,
                  advanceQuarter: false,
                  syncBooks: false,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _shake,
      builder: (BuildContext context, Widget? child) {
        final double dx =
            math.sin(_shake.value * math.pi * 6) * (_seconds <= 10 ? 4 : 0);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: VuV2BizRoomScaffold(
        title: 'Crisis Center · LIVE',
        subtitle: 'Earned interrupt. Decide before the clock hits zero.',
        accent: VuV2BizColors.danger,
        child: Column(
          children: <Widget>[
            VuV2BizGlassCard(
              borderColor: VuV2BizColors.danger,
              glowColor: VuV2BizColors.danger,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '⏱ $_seconds s',
                    style: const TextStyle(
                      color: VuV2BizColors.danger,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Breaking news',
                    style: TextStyle(
                      color: VuV2BizColors.warning,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.company.pendingCrisis ?? widget.company.currentChallenge,
                    style: const TextStyle(
                      color: VuV2BizColors.ink,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            VuV2BizChoiceTile(
              title: 'Transparent response',
              body: 'Own it, remedy it, communicate fast.',
              accent: VuV2BizColors.emerald,
              onTap: () => _pick('transparent'),
            ),
            VuV2BizChoiceTile(
              title: 'Discount blitz',
              body: 'Buy goodwill with price — margin risk.',
              onTap: () => _pick('discount'),
            ),
            VuV2BizChoiceTile(
              title: 'Deny and delay',
              body: 'Hope it fades. It usually will not.',
              accent: VuV2BizColors.danger,
              onTap: () => _pick('deny'),
            ),
          ],
        ),
      ),
    );
  }
}

class VuV2BizAnalyticsRoom extends StatefulWidget {
  const VuV2BizAnalyticsRoom({super.key, required this.company});
  final VuV2BizCompanyState company;

  @override
  State<VuV2BizAnalyticsRoom> createState() => _VuV2BizAnalyticsRoomState();
}

class _VuV2BizAnalyticsRoomState extends State<VuV2BizAnalyticsRoom> {
  String _driver = 'marketing';
  final TextEditingController _hyp = TextEditingController();

  @override
  void dispose() {
    _hyp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VuV2BizCompanyState company = widget.company;
    final List<VuV2BizHistoryPoint> h = company.history;
    double maxR = 1;
    for (final VuV2BizHistoryPoint p in h) {
      if (p.revenue > maxR) maxR = p.revenue;
    }
    return VuV2BizRoomScaffold(
      title: 'Business Analytics Center',
      subtitle: 'Internship task: file a root-cause memo from the live dashboard.',
      accent: const Color(0xFF22D3EE),
      child: Column(
        children: <Widget>[
          VuV2BizGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Revenue trend (your company)',
                    style: TextStyle(
                        color: VuV2BizColors.ink, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      for (int i = 0; i < h.length; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor:
                                          (h[i].revenue / maxR).clamp(0.05, 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          gradient: const LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: <Color>[
                                              VuV2BizColors.royal,
                                              Color(0xFF22D3EE),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(h[i].label,
                                    style: const TextStyle(
                                        color: VuV2BizColors.mute, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          VuV2BizGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Submit root-cause hypothesis',
                    style: TextStyle(
                        color: VuV2BizColors.gold, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: <String>['marketing', 'operations', 'competitor', 'finance']
                      .map((String d) {
                    final bool on = _driver == d;
                    return ChoiceChip(
                      label: Text(d),
                      selected: on,
                      onSelected: (_) => setState(() => _driver = d),
                      selectedColor: const Color(0xFF22D3EE),
                      labelStyle: TextStyle(
                        color: on ? Colors.black : VuV2BizColors.mute,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: VuV2BizColors.midnight,
                    );
                  }).toList(),
                ),
                TextField(
                  controller: _hyp,
                  maxLines: 4,
                  style: const TextStyle(color: VuV2BizColors.ink),
                  decoration: const InputDecoration(
                    hintText:
                        'Cite 2 numbers from the dashboard and one causal story…',
                    hintStyle: TextStyle(color: VuV2BizColors.mute),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    if (_hyp.text.trim().length < 40) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Write a real memo (40+ chars). Analysts do not submit vibes.',
                          ),
                        ),
                      );
                      return;
                    }
                    await _apply(
                      context,
                      company,
                      VuV2BizDecisionEngine.analyticsHypothesis(
                        driver: _driver,
                        hypothesis: _hyp.text,
                        company: company,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF22D3EE),
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('File analysis to leadership'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          VuV2BizMentorPanel(company: company, compact: true, pulse: true),
        ],
      ),
    );
  }
}

// ── Expansion ──────────────────────────────────────────────────────────────

class VuV2BizExpansionRoom extends StatelessWidget {
  const VuV2BizExpansionRoom({super.key, required this.company});
  final VuV2BizCompanyState company;

  @override
  Widget build(BuildContext context) {
    const List<String> regions = <String>[
      'USA',
      'Canada',
      'UK',
      'Germany',
      'Brazil',
      'Japan',
      'Australia',
      'Nigeria',
    ];
    return VuV2BizRoomScaffold(
      title: 'Global Expansion',
      subtitle: 'Regions glow when active. Tap to open a beachhead.',
      accent: const Color(0xFF34D399),
      child: Column(
        children: <Widget>[
          VuV2BizGlassCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: regions.map((String r) {
                final bool owned = company.markets.contains(r);
                return InkWell(
                  onTap: owned
                      ? null
                      : () => _apply(
                            context,
                            company,
                            VuV2BizDecisionEngine.expandMarket(r),
                          ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: owned
                          ? VuV2BizColors.emerald.withValues(alpha: 0.2)
                          : VuV2BizColors.midnight,
                      border: Border.all(
                        color: owned
                            ? VuV2BizColors.emerald
                            : VuV2BizColors.stroke,
                      ),
                      boxShadow: owned
                          ? <BoxShadow>[
                              BoxShadow(
                                color:
                                    VuV2BizColors.emerald.withValues(alpha: 0.25),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          r,
                          style: const TextStyle(
                            color: VuV2BizColors.ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          owned ? 'Active market' : 'Tap to expand',
                          style: TextStyle(
                            color: owned
                                ? VuV2BizColors.emerald
                                : VuV2BizColors.mute,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Achievements ───────────────────────────────────────────────────────────

class VuV2BizAchievementsRoom extends StatelessWidget {
  const VuV2BizAchievementsRoom({super.key, required this.company});
  final VuV2BizCompanyState company;

  @override
  Widget build(BuildContext context) {
    return VuV2BizRoomScaffold(
      title: 'Achievement Showcase',
      subtitle: 'Trophy room — CEO level, net worth, awards.',
      accent: VuV2BizColors.gold,
      child: Column(
        children: <Widget>[
          VuV2BizGlassCard(
            glowColor: VuV2BizColors.gold,
            borderColor: VuV2BizColors.gold.withValues(alpha: 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'CEO Level ${company.ceoLevel}',
                  style: const TextStyle(
                    color: VuV2BizColors.gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Company value ${VuV2BizCompanyState.money(company.companyValue)}\n'
                  'Reputation ${VuV2BizCompanyState.pct(company.reputation)}\n'
                  'Market share ${VuV2BizCompanyState.pct(company.marketShare)}',
                  style: const TextStyle(
                      color: VuV2BizColors.mute, height: 1.45),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (company.xp / (company.ceoLevel * 100)).clamp(0.0, 1.0),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                  color: VuV2BizColors.gold,
                  backgroundColor: VuV2BizColors.stroke,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (company.awards.isEmpty)
            const VuV2BizGlassCard(
              child: Text(
                'No awards yet. Mediate well, negotiate cleanly, survive crises.',
                style: TextStyle(color: VuV2BizColors.mute),
              ),
            )
          else
            ...company.awards.map((String a) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: VuV2BizGlassCard(
                  borderColor: VuV2BizColors.gold.withValues(alpha: 0.4),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.emoji_events, color: VuV2BizColors.gold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          a,
                          style: const TextStyle(
                            color: VuV2BizColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ── Lessons ────────────────────────────────────────────────────────────────

class VuV2BizLessonsRoom extends StatelessWidget {
  const VuV2BizLessonsRoom({super.key, required this.company});
  final VuV2BizCompanyState company;

  @override
  Widget build(BuildContext context) {
    return VuV2BizRoomScaffold(
      title: 'Executive Briefings',
      subtitle: 'Lessons feel like board prep — then open Business School.',
      accent: const Color(0xFFA78BFA),
      child: Column(
        children: <Widget>[
          VuV2BizGlassCard(
            glowColor: const Color(0xFFA78BFA),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Business Strategy · Week briefing',
                  style: TextStyle(
                    color: VuV2BizColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Today's goal: how companies gain competitive advantage.\n"
                  'Estimated time: 35 minutes · AI Professor ready.',
                  style: TextStyle(color: VuV2BizColors.mute, height: 1.45),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () async {
                    final BusinessSchoolProgressService progress =
                        BusinessSchoolProgressService();
                    await progress.load();
                    if (!context.mounted) {
                      return;
                    }
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChangeNotifierProvider<
                            BusinessSchoolProgressService>.value(
                          value: progress,
                          child: const BusinessSchoolScreen(),
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFA78BFA),
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Business School lesson'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Multiplayer stub ───────────────────────────────────────────────────────

class VuV2BizMultiplayerRoom extends StatelessWidget {
  const VuV2BizMultiplayerRoom({
    super.key,
    required this.company,
    required this.isPremium,
  });

  final VuV2BizCompanyState company;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return VuV2BizRoomScaffold(
      title: 'Multiplayer Arena',
      subtitle: 'Compete, partner, and climb valuation boards.',
      accent: const Color(0xFFFB7185),
      child: Column(
        children: <Widget>[
          VuV2BizGlassCard(
            borderColor: const Color(0xFFFB7185),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isPremium ? 'Premium unlocked' : 'Premium feature',
                  style: const TextStyle(
                    color: Color(0xFFFB7185),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Coming soon: compete in the same industry, buy rivals, '
                  'negotiate contracts, form partnerships, and compare company '
                  'valuations on a global leaderboard.\n\n'
                  'Guardrail: multiplayer state will not bleed into graded coursework — '
                  'competition stays optional and capped so understanding wins over min-maxing.',
                  style: TextStyle(color: VuV2BizColors.mute, height: 1.45),
                ),
                const SizedBox(height: 14),
                ...<String>[
                  'Same-industry competition',
                  'Acquisitions & partnerships',
                  'Live valuation leaderboard',
                ].map((String row) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          isPremium ? Icons.lock_open : Icons.lock_outline,
                          color: VuV2BizColors.mute,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            row,
                            style: const TextStyle(color: VuV2BizColors.ink),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (!isPremium)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Open to every student when multiplayer goes live.',
                      style: TextStyle(
                        color: VuV2BizColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
