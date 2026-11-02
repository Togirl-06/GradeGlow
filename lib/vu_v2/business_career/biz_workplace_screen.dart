import 'package:flutter/material.dart';

import 'biz_signature_mission_screen.dart';
import 'business_career_content.dart';
import 'business_career_progress.dart';
import 'business_career_theme.dart';
import 'declining_company_mission_screen.dart';

/// Workplace — clock in/out, complete paid tasks, launch signature mission.
class BizWorkplaceScreen extends StatefulWidget {
  const BizWorkplaceScreen({super.key, required this.progress});

  final BusinessCareerProgress progress;

  @override
  State<BizWorkplaceScreen> createState() => _BizWorkplaceScreenState();
}

class _BizWorkplaceScreenState extends State<BizWorkplaceScreen> {
  bool _clockBusy = false;
  final Set<String> _localDone = <String>{};

  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.progress.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<_WorkTask> get _tasks => _WorkTask.forMajor(widget.progress.majorId);

  bool _taskDone(String id) =>
      _localDone.contains(id) ||
      widget.progress.completedMissions.contains('task_$id') ||
      widget.progress.completedChallenges.contains('task_$id');

  Future<void> _toggleClock() async {
    if (!widget.progress.hasAnyJob || _clockBusy) return;
    setState(() => _clockBusy = true);
    if (widget.progress.clockedIn) {
      await widget.progress.clockOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Clocked out · Bank ${widget.progress.balanceLabel}',
          ),
        ),
      );
    } else {
      final String jobId = widget.progress.activeJobId ??
          (widget.progress.employedJobIds.isNotEmpty
              ? widget.progress.employedJobIds.first
              : '');
      if (jobId.isEmpty) {
        if (!mounted) return;
        setState(() => _clockBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active job to clock into.')),
        );
        return;
      }
      await widget.progress.clockIn(jobId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clocked in · shift started')),
      );
    }
    if (mounted) setState(() => _clockBusy = false);
  }

  Future<void> _completeTask(_WorkTask t) async {
    if (!widget.progress.clockedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clock in before completing work tasks.')),
      );
      return;
    }
    if (_taskDone(t.id)) return;
    await widget.progress.completeWorkTask(
      t.id,
      payCents: t.payCents,
      xpGain: t.xpGain,
    );
    if (!mounted) return;
    setState(() => _localDone.add(t.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${t.title} done · +\$${(t.payCents / 100).toStringAsFixed(2)} · +${t.xpGain} XP',
        ),
      ),
    );
  }

  Future<void> _openSignature() async {
    final String majorId = widget.progress.majorId;
    final Widget screen = majorId == 'business_administration'
        ? DecliningCompanyMissionScreen(progress: widget.progress)
        : BizSignatureMissionScreen(
            progress: widget.progress,
            majorId: majorId,
          );
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final BusinessCareerProgress p = widget.progress;
    final BusinessMajor major = BusinessMajors.byId(p.majorId);
    final bool hired = p.hasAnyJob;

    return Scaffold(
      backgroundColor: BizCosmic.bg,
      appBar: BizCosmic.appBar(
        context: context,
        title: 'Company District',
        icon: Icons.apartment_rounded,
        trailing: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BizCosmic.pill(
              p.clockedIn ? 'On shift' : 'Off clock',
              bg: p.clockedIn
                  ? BizCosmic.success.withValues(alpha: 0.2)
                  : BizCosmic.panelAlt,
              fg: p.clockedIn ? BizCosmic.success : BizCosmic.mute,
            ),
          ),
        ],
      ),
      body: BizStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BizCosmic.panelBox(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    major.facility,
                    style: const TextStyle(
                      color: BizCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hired
                        ? '${p.jobActionLabel()} · Bank ${p.balanceLabel}'
                        : 'Accept a job offer to unlock paid shifts.',
                    style: const TextStyle(color: BizCosmic.mute),
                  ),
                  const SizedBox(height: 12),
                  if (!hired)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BizCosmic.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Locked until hired — finish Career Center → Interview → Accept offer.',
                        style: TextStyle(color: BizCosmic.warning, height: 1.35),
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _clockBusy ? null : _toggleClock,
                      icon: Icon(
                        p.clockedIn
                            ? Icons.logout_rounded
                            : Icons.login_rounded,
                      ),
                      label: Text(p.clockedIn ? 'Clock out' : 'Clock in'),
                      style: FilledButton.styleFrom(
                        backgroundColor: p.clockedIn
                            ? BizCosmic.warning
                            : BizCosmic.emerald,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(46),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Today\'s work tasks',
              style: TextStyle(
                color: BizCosmic.ink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ..._tasks.map(( _WorkTask t) {
              final bool done = _taskDone(t.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BizCosmic.panelBox(radius: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              t.title,
                              style: const TextStyle(
                                color: BizCosmic.ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          BizCosmic.pill(
                            done ? 'Done' : '+\$${(t.payCents / 100).toStringAsFixed(0)}',
                            bg: done
                                ? BizCosmic.success.withValues(alpha: 0.2)
                                : BizCosmic.gold.withValues(alpha: 0.18),
                            fg: done ? BizCosmic.success : BizCosmic.gold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.blurb,
                        style: const TextStyle(
                          color: BizCosmic.mute,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: (!hired || done) ? null : () => _completeTask(t),
                          style: FilledButton.styleFrom(
                            backgroundColor: BizCosmic.royal,
                            disabledBackgroundColor: BizCosmic.stroke,
                          ),
                          child: Text(done ? 'Completed' : 'Complete · +${t.xpGain} XP'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: hired ? _openSignature : null,
              icon: const Icon(Icons.flag_rounded),
              label: Text(
                majorIdLabel(major.id),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: BizCosmic.gold,
                foregroundColor: Colors.black,
                disabledBackgroundColor: BizCosmic.stroke,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Signature mission is the flagship simulation for your major.',
              style: TextStyle(color: BizCosmic.mute, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String majorIdLabel(String id) {
    if (id == 'business_administration') {
      return 'Signature mission · Declining Company';
    }
    return 'Signature mission · ${BusinessMajors.byId(id).exampleMission}';
  }
}

class _WorkTask {
  const _WorkTask({
    required this.id,
    required this.title,
    required this.blurb,
    required this.payCents,
    required this.xpGain,
  });

  final String id;
  final String title;
  final String blurb;
  final int payCents;
  final int xpGain;

  static List<_WorkTask> forMajor(String majorId) {
    switch (majorId) {
      case 'accounting':
        return const <_WorkTask>[
          _WorkTask(id: 'ac_recon', title: 'Bank reconciliation pack', blurb: 'Clear three open items before close.', payCents: 1400, xpGain: 40),
          _WorkTask(id: 'ac_ap', title: 'AP aging cleanup', blurb: 'Flag duplicates and late invoices.', payCents: 1200, xpGain: 35),
          _WorkTask(id: 'ac_workpaper', title: 'Audit workpaper review', blurb: 'Cross-tie schedules to the trial balance.', payCents: 1500, xpGain: 45),
          _WorkTask(id: 'ac_flux', title: 'P&L flux analysis', blurb: 'Explain MoM swings over 10%.', payCents: 1300, xpGain: 40),
          _WorkTask(id: 'ac_close', title: 'Month-end checklist', blurb: 'Confirm accruals and cutoffs.', payCents: 1600, xpGain: 50),
        ];
      case 'finance':
        return const <_WorkTask>[
          _WorkTask(id: 'fi_comps', title: 'Comps refresh', blurb: 'Update peer multiples for the deck.', payCents: 1500, xpGain: 45),
          _WorkTask(id: 'fi_dcf', title: 'DCF sanity check', blurb: 'Stress WACC ±1% and growth.', payCents: 1600, xpGain: 50),
          _WorkTask(id: 'fi_risk', title: 'Risk memo', blurb: 'Call out liquidity and concentration.', payCents: 1400, xpGain: 40),
          _WorkTask(id: 'fi_hedge', title: 'Hedge recommendation', blurb: 'Propose forwards for FX exposure.', payCents: 1450, xpGain: 42),
          _WorkTask(id: 'fi_board', title: 'Board KPI snapshot', blurb: 'One-pager for weekly markets review.', payCents: 1300, xpGain: 38),
        ];
      case 'economics':
        return const <_WorkTask>[
          _WorkTask(id: 'ec_cpi', title: 'CPI brief', blurb: 'Summarize drivers vs last print.', payCents: 1300, xpGain: 40),
          _WorkTask(id: 'ec_elast', title: 'Demand elasticity note', blurb: 'Estimate response to a fee change.', payCents: 1400, xpGain: 42),
          _WorkTask(id: 'ec_labor', title: 'Labor market dashboard', blurb: 'Unemployment vs wage growth chart.', payCents: 1200, xpGain: 35),
          _WorkTask(id: 'ec_policy', title: 'Policy trade-off memo', blurb: 'Frame winners/losers clearly.', payCents: 1500, xpGain: 48),
          _WorkTask(id: 'ec_forecast', title: 'Scenario forecast', blurb: 'Base / adverse / upside paths.', payCents: 1550, xpGain: 50),
        ];
      case 'entrepreneurship':
        return const <_WorkTask>[
          _WorkTask(id: 'en_cust', title: 'Customer interviews', blurb: 'Log five discovery calls.', payCents: 1200, xpGain: 40),
          _WorkTask(id: 'en_mvp', title: 'MVP backlog trim', blurb: 'Cut scope to one monetizable loop.', payCents: 1300, xpGain: 42),
          _WorkTask(id: 'en_burn', title: 'Burn & runway update', blurb: 'Refresh cash model for investors.', payCents: 1400, xpGain: 45),
          _WorkTask(id: 'en_pitch', title: 'Pitch narrative polish', blurb: 'Tighten problem → proof → ask.', payCents: 1350, xpGain: 40),
          _WorkTask(id: 'en_unit', title: 'Unit economics sheet', blurb: 'CAC, LTV, payback in one view.', payCents: 1500, xpGain: 50),
        ];
      case 'marketing':
        return const <_WorkTask>[
          _WorkTask(id: 'mk_brief', title: 'Creative brief', blurb: 'Audience, message, CTA, proof.', payCents: 1200, xpGain: 38),
          _WorkTask(id: 'mk_channel', title: 'Channel mix plan', blurb: 'Allocate \$8k across 3 channels.', payCents: 1400, xpGain: 45),
          _WorkTask(id: 'mk_ab', title: 'A/B test design', blurb: 'Hypothesis, sample, success metric.', payCents: 1300, xpGain: 40),
          _WorkTask(id: 'mk_report', title: 'Campaign readout', blurb: 'CAC and creative winners.', payCents: 1450, xpGain: 45),
          _WorkTask(id: 'mk_brand', title: 'Brand voice guide', blurb: 'Do / don’t for campus creators.', payCents: 1250, xpGain: 36),
        ];
      case 'human_resource_management':
        return const <_WorkTask>[
          _WorkTask(id: 'hr_intake', title: 'Requisition intake', blurb: 'Clarify must-haves vs nice-to-haves.', payCents: 1200, xpGain: 35),
          _WorkTask(id: 'hr_screen', title: 'Screen scorecards', blurb: 'Calibrate interviewers on criteria.', payCents: 1300, xpGain: 40),
          _WorkTask(id: 'hr_offer', title: 'Offer band check', blurb: 'Align comp to market + equity.', payCents: 1400, xpGain: 42),
          _WorkTask(id: 'hr_onboard', title: '30-60-90 plan', blurb: 'Ship new-hire checklist.', payCents: 1250, xpGain: 38),
          _WorkTask(id: 'hr_pulse', title: 'Retention pulse', blurb: 'Summarize stay-interview themes.', payCents: 1500, xpGain: 48),
        ];
      case 'international_business':
        return const <_WorkTask>[
          _WorkTask(id: 'ib_market', title: 'Market screen memo', blurb: 'Rank 3 countries on demand + risk.', payCents: 1400, xpGain: 45),
          _WorkTask(id: 'ib_tariff', title: 'Tariff impact sheet', blurb: 'Landed cost before/after duty.', payCents: 1450, xpGain: 45),
          _WorkTask(id: 'ib_fx', title: 'FX exposure note', blurb: 'Natural hedge vs forward options.', payCents: 1350, xpGain: 40),
          _WorkTask(id: 'ib_partner', title: 'Partner diligence', blurb: 'References + compliance checklist.', payCents: 1500, xpGain: 48),
          _WorkTask(id: 'ib_entry', title: 'Entry mode brief', blurb: 'Distributor vs JV recommendation.', payCents: 1550, xpGain: 50),
        ];
      default: // business_administration
        return const <_WorkTask>[
          _WorkTask(id: 'ba_standup', title: 'Ops standup prep', blurb: 'Surface blockers and owners.', payCents: 1200, xpGain: 35),
          _WorkTask(id: 'ba_kpi', title: 'Store KPI pack', blurb: 'Margin, traffic, and SLA exceptions.', payCents: 1400, xpGain: 42),
          _WorkTask(id: 'ba_vendor', title: 'Vendor follow-ups', blurb: 'Close three open PO exceptions.', payCents: 1300, xpGain: 38),
          _WorkTask(id: 'ba_process', title: 'Process map refresh', blurb: 'Document the returns flow.', payCents: 1350, xpGain: 40),
          _WorkTask(id: 'ba_status', title: 'Executive status note', blurb: 'One page: risks and asks.', payCents: 1500, xpGain: 48),
        ];
    }
  }
}
