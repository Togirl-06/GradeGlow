import 'package:flutter/material.dart';

import '../../data/vu_v2_progress_store.dart';
import '../../data/vu_v2_session.dart';
import 'vu_v2_biz_company_state.dart';
import 'vu_v2_biz_decision_engine.dart';
import 'vu_v2_biz_department_catalog.dart';
import 'vu_v2_biz_mentor.dart';
import 'vu_v2_biz_rooms.dart';
import 'vu_v2_biz_theme.dart';

/// Business Simulation Center — executive HQ for Virtual University Labs.
class VuV2BusinessSimulationCenter extends StatefulWidget {
  const VuV2BusinessSimulationCenter({
    super.key,
    this.initialRoom,
    this.session,
    this.progress,
  });

  final VuV2BizRoomId? initialRoom;
  final VuV2Session? session;
  final VuV2ProgressStore? progress;

  @override
  State<VuV2BusinessSimulationCenter> createState() =>
      _VuV2BusinessSimulationCenterState();
}

class _VuV2BusinessSimulationCenterState
    extends State<VuV2BusinessSimulationCenter>
    with SingleTickerProviderStateMixin {
  final VuV2BizCompanyState _company = VuV2BizCompanyState();
  late VuV2BizRoomId _room;
  late AnimationController _kpiAnim;
  bool _mentorOpen = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _room = widget.initialRoom ?? VuV2BizRoomId.dashboard;
    _kpiAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _boot();
  }

  Future<void> _boot() async {
    await _company.ensureLoaded(
      displayName: widget.session?.displayName,
    );
    if (mounted) {
      setState(() {});
      _company.addListener(_onCompany);
      if (!_company.dayOneComplete) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showDayOne();
          }
        });
      }
    }
  }

  Future<void> _showDayOne() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: VuV2BizColors.elevated,
          title: const Text(
            'Day 1 · You are the CEO',
            style: TextStyle(
              color: VuV2BizColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'This is not a quiz.\n\n'
              'You own one company for your whole degree path. '
              'Marketing mistakes become brand debt. Skipped QC becomes a recall. '
              'Your AI mentor remembers how YOU decide — not just the KPIs.\n\n'
              'Loop: Brief → Decide → Consequence → Debrief → Next.\n\n'
              'Tap Continue simulation when you are ready to work.',
              style: TextStyle(color: VuV2BizColors.mute, height: 1.45),
            ),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () async {
                await _company.completeDayOne();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              },
              style: FilledButton.styleFrom(backgroundColor: VuV2BizColors.royal),
              child: const Text('I accept the role'),
            ),
          ],
        );
      },
    );
  }

  void _onCompany() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _company.removeListener(_onCompany);
    _kpiAnim.dispose();
    super.dispose();
  }

  void _go(VuV2BizRoomId id) {
    setState(() => _room = id);
    if (id == VuV2BizRoomId.dashboard) {
      _kpiAnim.forward(from: 0);
    }
  }

  bool get _isPremium => widget.progress?.isPremium ?? false;

  String get _greeting {
    final int h = DateTime.now().hour;
    if (h < 12) {
      return 'Good morning';
    }
    if (h < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide = width >= 980;
    final bool medium = width >= 720;

    return Scaffold(
      backgroundColor: VuV2BizColors.deepNavy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              VuV2BizColors.deepNavy,
              Color(0xFF0F1A2E),
              VuV2BizColors.midnight,
            ],
          ),
        ),
        child: SafeArea(
          child: !_company.loaded
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CircularProgressIndicator(color: VuV2BizColors.royal),
                      SizedBox(height: 16),
                      Text(
                        'Opening headquarters…',
                        style: TextStyle(
                          color: VuV2BizColors.mute,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: <Widget>[
                    _topBar(),
                    Expanded(
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                _sideRail(),
                                Expanded(child: _body(medium)),
                                if (_mentorOpen &&
                                    _room == VuV2BizRoomId.dashboard)
                                  SizedBox(
                                    width: 320,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 12, 16, 16),
                                      child: VuV2BizMentorPanel(
                                        company: _company,
                                        pulse: true,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Column(
                              children: <Widget>[
                                Expanded(child: _body(medium)),
                                _mobileNav(),
                              ],
                            ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: wide
          ? null
          : FloatingActionButton(
              backgroundColor: VuV2BizColors.royal,
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: VuV2BizColors.elevated,
                  isScrollControlled: true,
                  builder: (BuildContext ctx) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: VuV2BizMentorPanel(
                        company: _company,
                        pulse: true,
                      ),
                    );
                  },
                );
              },
              child: const Icon(Icons.psychology_alt),
            ),
    );
  }

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: VuV2BizColors.midnight.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: VuV2BizColors.stroke),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: VuV2BizColors.ink),
          ),
          const Text(
            'BUSINESS LAB',
            style: TextStyle(
              color: VuV2BizColors.ink,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: TextField(
                onChanged: (String v) => setState(() => _search = v),
                style: const TextStyle(color: VuV2BizColors.ink, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search departments…',
                  hintStyle: const TextStyle(color: VuV2BizColors.mute),
                  prefixIcon:
                      const Icon(Icons.search, color: VuV2BizColors.mute),
                  filled: true,
                  fillColor: VuV2BizColors.deepNavy,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: VuV2BizColors.stroke),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: VuV2BizColors.stroke),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'AI Mentor',
            onPressed: () => setState(() => _mentorOpen = !_mentorOpen),
            icon: Icon(
              Icons.psychology_alt,
              color: _mentorOpen ? VuV2BizColors.royal : VuV2BizColors.mute,
            ),
          ),
          IconButton(
            tooltip: 'Achievements',
            onPressed: () => _go(VuV2BizRoomId.achievements),
            icon: const Icon(Icons.emoji_events_outlined,
                color: VuV2BizColors.gold),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: VuV2BizColors.royal.withValues(alpha: 0.3),
            child: Text(
              _company.ceoName.isNotEmpty
                  ? _company.ceoName.substring(0, 1).toUpperCase()
                  : 'C',
              style: const TextStyle(
                color: VuV2BizColors.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _sideRail() {
    final String q = _search.trim().toLowerCase();
    final List<VuV2BizDepartment> items = <VuV2BizDepartment>[];
    for (int i = 0; i < VuV2BizDepartmentCatalog.all.length; i++) {
      final VuV2BizDepartment d = VuV2BizDepartmentCatalog.all[i];
      if (d.id == VuV2BizRoomId.multiplayer) {
        continue;
      }
      if (q.isEmpty ||
          d.title.toLowerCase().contains(q) ||
          d.blurb.toLowerCase().contains(q)) {
        items.add(d);
      }
    }
    return Container(
      width: 232,
      margin: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: VuV2BizColors.elevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(VuV2BizRadii.lg),
        border: Border.all(color: VuV2BizColors.stroke),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final VuV2BizDepartment d = items[index];
          final bool on = d.id == _room;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Material(
              color: on
                  ? d.accent.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _go(d.id),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        d.icon,
                        color: on ? d.accent : VuV2BizColors.mute,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          d.label,
                          style: TextStyle(
                            color: on ? VuV2BizColors.ink : VuV2BizColors.mute,
                            fontWeight:
                                on ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _mobileNav() {
    return Container(
      decoration: const BoxDecoration(
        color: VuV2BizColors.elevated,
        border: Border(top: BorderSide(color: VuV2BizColors.stroke)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: <Widget>[
              for (int i = 0; i < VuV2BizDepartmentCatalog.all.length; i++)
                if (VuV2BizDepartmentCatalog.all[i].id !=
                    VuV2BizRoomId.multiplayer)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => _go(VuV2BizDepartmentCatalog.all[i].id),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: _room == VuV2BizDepartmentCatalog.all[i].id
                              ? VuV2BizColors.royal.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              VuV2BizDepartmentCatalog.all[i].icon,
                              color: _room == VuV2BizDepartmentCatalog.all[i].id
                                  ? VuV2BizColors.royal
                                  : VuV2BizColors.mute,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              VuV2BizDepartmentCatalog.all[i].label,
                              style: TextStyle(
                                color:
                                    _room == VuV2BizDepartmentCatalog.all[i].id
                                        ? VuV2BizColors.ink
                                        : VuV2BizColors.mute,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(bool medium) {
    final Widget room = _roomContent(medium);
    return VuV2BizLabScope(
      onOpenRoom: _go,
      child: room,
    );
  }

  Widget _roomContent(bool medium) {
    switch (_room) {
      case VuV2BizRoomId.dashboard:
        return _dashboard(medium);
      case VuV2BizRoomId.marketing:
        return VuV2BizMarketingRoom(company: _company, onOpenRoom: _go);
      case VuV2BizRoomId.finance:
        return VuV2BizFinanceRoom(company: _company, onOpenRoom: _go);
      case VuV2BizRoomId.hr:
        return VuV2BizHrRoom(company: _company, onOpenRoom: _go);
      case VuV2BizRoomId.operations:
        return VuV2BizOperationsRoom(company: _company);
      case VuV2BizRoomId.strategy:
        return VuV2BizStrategyRoom(company: _company);
      case VuV2BizRoomId.negotiation:
        return VuV2BizNegotiationRoom(company: _company);
      case VuV2BizRoomId.board:
        return VuV2BizBoardRoom(company: _company);
      case VuV2BizRoomId.startup:
        return VuV2BizStartupRoom(company: _company);
      case VuV2BizRoomId.crisis:
        return VuV2BizCrisisRoom(company: _company);
      case VuV2BizRoomId.analytics:
        return VuV2BizAnalyticsRoom(company: _company);
      case VuV2BizRoomId.expansion:
        return VuV2BizExpansionRoom(company: _company);
      case VuV2BizRoomId.achievements:
        return VuV2BizAchievementsRoom(company: _company);
      case VuV2BizRoomId.lessons:
        return VuV2BizLessonsRoom(company: _company);
      case VuV2BizRoomId.multiplayer:
        return VuV2BizMultiplayerRoom(
          company: _company,
          isPremium: _isPremium,
        );
    }
  }

  Widget _dashboard(bool medium) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: <Widget>[
        Text(
          '$_greeting,',
          style: const TextStyle(
            color: VuV2BizColors.mute,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        Text(
          _company.ceoName,
          style: const TextStyle(
            color: VuV2BizColors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 32,
            letterSpacing: -0.8,
          ),
        ),
        Text(
          'CEO of ${_company.companyName}',
          style: const TextStyle(
            color: VuV2BizColors.royal,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 14),
        VuV2BizGlassCard(
          borderColor: VuV2BizColors.royal.withValues(alpha: 0.35),
          child: const Text(
            'How this lab works: Brief → Decide → See consequence → '
            'Debrief with your AI mentor → Next challenge. '
            'One company. Choices compound. Nothing resets.',
            style: TextStyle(
              color: VuV2BizColors.mute,
              height: 1.4,
              fontSize: 13,
            ),
          ),
        ),
        if (_company.crisisInterruptActive) ...<Widget>[
          const SizedBox(height: 14),
          VuV2BizGlassCard(
            borderColor: VuV2BizColors.danger,
            glowColor: VuV2BizColors.danger,
            onTap: () => _go(VuV2BizRoomId.crisis),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'EARNED CRISIS INTERRUPT',
                  style: TextStyle(
                    color: VuV2BizColors.danger,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _company.pendingCrisis ?? _company.currentChallenge,
                  style: const TextStyle(
                    color: VuV2BizColors.ink,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Caused by your prior choices — tap to respond now.',
                  style: TextStyle(color: VuV2BizColors.mute, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: _kpiAnim,
          builder: (BuildContext context, Widget? child) {
            final double t = Curves.easeOutCubic.transform(_kpiAnim.value);
            return Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 12),
                child: child,
              ),
            );
          },
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final int cols = c.maxWidth >= 900
                  ? 4
                  : c.maxWidth >= 560
                      ? 2
                      : 1;
              final double gap = 12;
              final double cardW =
                  (c.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  SizedBox(
                    width: cardW,
                    child: VuV2BizKpiCard(
                      label: 'Revenue',
                      value: VuV2BizCompanyState.money(_company.monthlyRevenue),
                      deltaLabel: '/ month',
                      accent: VuV2BizColors.emerald,
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  SizedBox(
                    width: cardW,
                    child: VuV2BizKpiCard(
                      label: 'Expenses',
                      value:
                          VuV2BizCompanyState.money(_company.monthlyExpenses),
                      deltaLabel: '/ month',
                      accent: VuV2BizColors.warning,
                      icon: Icons.receipt_long_outlined,
                    ),
                  ),
                  SizedBox(
                    width: cardW,
                    child: VuV2BizKpiCard(
                      label: 'Company Value',
                      value: VuV2BizCompanyState.money(_company.companyValue),
                      deltaLabel: 'CEO L${_company.ceoLevel}',
                      accent: VuV2BizColors.gold,
                      icon: Icons.diamond_outlined,
                    ),
                  ),
                  SizedBox(
                    width: cardW,
                    child: VuV2BizKpiCard(
                      label: 'Customer Satisfaction',
                      value: VuV2BizCompanyState.pct(_company.satisfaction),
                      deltaLabel:
                          'Morale ${VuV2BizCompanyState.pct(_company.morale)}',
                      accent: VuV2BizColors.royal,
                      icon: Icons.favorite_outline,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        VuV2BizGlassCard(
          borderColor: VuV2BizColors.royal.withValues(alpha: 0.45),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: <Color>[
                      VuV2BizColors.royal,
                      VuV2BizColors.emerald,
                    ],
                  ),
                ),
                child: const Icon(Icons.apartment, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _company.companyName,
                      style: const TextStyle(
                        color: VuV2BizColors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '${_company.industry} Company',
                      style: const TextStyle(color: VuV2BizColors.mute),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: <Widget>[
                        _meta('Founded', '${_company.foundedYear}'),
                        _meta('Employees', '${_company.employees}'),
                        _meta('Countries', '${_company.markets.length}'),
                        _meta(
                          'Reputation',
                          VuV2BizCompanyState.pct(_company.reputation),
                        ),
                        _meta(
                          'Cash',
                          VuV2BizCompanyState.money(_company.cash),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Markets: ${_company.markets.join(', ')}',
                      style: const TextStyle(
                        color: VuV2BizColors.mute,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Quality ${VuV2BizCompanyState.pct(_company.qualityIndex)} · '
                      'Brand ${VuV2BizCompanyState.pct(_company.brandStrength)}',
                      style: const TextStyle(
                        color: VuV2BizColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _company.decisionStyleSummary,
                      style: const TextStyle(
                        color: VuV2BizColors.mute,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        VuV2BizGlassCard(
          borderColor: VuV2BizColors.warning,
          glowColor: VuV2BizColors.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Current challenge',
                style: TextStyle(
                  color: VuV2BizColors.warning,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _company.currentChallenge,
                style: const TextStyle(
                  color: VuV2BizColors.ink,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                VuV2BizDecisionEngine.nextChallengeHint(_company),
                style: const TextStyle(
                  color: VuV2BizColors.mute,
                  height: 1.35,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {
                  _go(VuV2BizDecisionEngine.nextRecommendedRoom(_company));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _company.crisisInterruptActive
                      ? VuV2BizColors.danger
                      : VuV2BizColors.warning,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  _company.crisisInterruptActive
                      ? 'Enter Crisis Center'
                      : 'Continue simulation → ${VuV2BizDepartmentCatalog.byId(VuV2BizDecisionEngine.nextRecommendedRoom(_company)).label}',
                ),
              ),
            ],
          ),
        ),
        if (_company.decisionLog.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          VuV2BizGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Recent decisions (they still count)',
                  style: TextStyle(
                    color: VuV2BizColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                for (int i = 0;
                    i < _company.decisionLog.length && i < 4;
                    i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Q${_company.decisionLog[i].quarter} · '
                      '${_company.decisionLog[i].department} · '
                      '${_company.decisionLog[i].title}',
                      style: const TextStyle(
                        color: VuV2BizColors.mute,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        const Text(
          'Headquarters',
          style: TextStyle(
            color: VuV2BizColors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            final int cols = c.maxWidth >= 900
                ? 3
                : c.maxWidth >= 560
                    ? 2
                    : 1;
            final double gap = 12;
            final double cardW = (c.maxWidth - gap * (cols - 1)) / cols;
            final List<VuV2BizDepartment> depts = <VuV2BizDepartment>[];
            for (int i = 0; i < VuV2BizDepartmentCatalog.all.length; i++) {
              final VuV2BizDepartment d = VuV2BizDepartmentCatalog.all[i];
              if (d.id != VuV2BizRoomId.dashboard &&
                  d.id != VuV2BizRoomId.multiplayer) {
                depts.add(d);
              }
            }
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                for (int i = 0; i < depts.length; i++)
                  SizedBox(
                    width: cardW,
                    child: _deptCard(depts[i]),
                  ),
              ],
            );
          },
        ),
        if (!medium) ...<Widget>[
          const SizedBox(height: 16),
          VuV2BizMentorPanel(company: _company, pulse: true),
        ],
      ],
    );
  }

  Widget _meta(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(k,
            style: const TextStyle(
                color: VuV2BizColors.mute, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(v,
            style: const TextStyle(
                color: VuV2BizColors.ink, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _deptCard(VuV2BizDepartment d) {
    return VuV2BizGlassCard(
      onTap: () => _go(d.id),
      borderColor: d.accent.withValues(alpha: 0.4),
      glowColor: d.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(d.icon, color: d.accent, size: 28),
          const SizedBox(height: 10),
          Text(
            d.title,
            style: const TextStyle(
              color: VuV2BizColors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            d.blurb,
            style: const TextStyle(
              color: VuV2BizColors.mute,
              height: 1.35,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter →',
            style: TextStyle(
              color: d.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
