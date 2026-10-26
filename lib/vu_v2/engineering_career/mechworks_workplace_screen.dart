import 'package:flutter/material.dart';

import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'engineering_sims.dart';

/// Apex Dynamics / MechWorks workplace after hire.
class MechWorksWorkplaceScreen extends StatefulWidget {
  const MechWorksWorkplaceScreen({super.key, required this.progress});

  final EngineeringCareerProgress progress;

  @override
  State<MechWorksWorkplaceScreen> createState() =>
      _MechWorksWorkplaceScreenState();
}

class _MechWorksWorkplaceScreenState extends State<MechWorksWorkplaceScreen> {
  static const String _taskId = 'apex_vibration_v1';
  double _rpm = 1800;
  double _massUnbalanceG = 12;
  String? _diag;
  bool _busy = false;

  bool get _hired => widget.progress.hasAnyJob;
  bool get _onClock => widget.progress.clockedIn;
  bool get _done => widget.progress.workplaceTasksDone.contains(_taskId);

  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_tick);
  }

  @override
  void dispose() {
    widget.progress.removeListener(_tick);
    super.dispose();
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleClock() async {
    setState(() => _busy = true);
    if (_onClock) {
      final int earned = await widget.progress.clockOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Clocked out · +\$${(earned / 100).toStringAsFixed(2)} · '
              'Bank ${widget.progress.balanceLabel}',
            ),
          ),
        );
      }
    } else {
      final String jobId = widget.progress.activeJobId ??
          (widget.progress.employedJobIds.isNotEmpty
              ? widget.progress.employedJobIds.first
              : 'apex_mech_junior');
      final bool ok = await widget.progress.clockIn(jobId: jobId);
      if (mounted && ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Clocked in · \$${(widget.progress.hourlyWageCents / 100).toStringAsFixed(2)}/hr',
            ),
          ),
        );
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  void _analyze() {
    // Simplified: severity index ≈ unbalance * (rpm/1000)^2
    final double severity =
        _massUnbalanceG * (_rpm / 1000) * (_rpm / 1000);
    final bool needsBalance = severity > 25;
    setState(() {
      _diag = needsBalance
          ? 'Elevated vibration index ${severity.toStringAsFixed(1)}. '
              'Recommend dynamic balancing / reduce unbalance below 8 g '
              'or lower operating RPM. (${EngineeringSims.disclaimer})'
          : 'Vibration index ${severity.toStringAsFixed(1)} within '
              'this simplified demo threshold.';
    });
  }

  Future<void> _submit() async {
    if (!_onClock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clock in before submitting.')),
      );
      return;
    }
    if (_diag == null || !_diag!.contains('Recommend')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Investigate until you find a corrective recommendation.'),
        ),
      );
      return;
    }
    final bool ok = await widget.progress.completeWorkplaceTask(
      _taskId,
      xpGain: 110,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Manager approved · +\$12.00 task bonus · Bank ${widget.progress.balanceLabel}'
              : 'Task already submitted.',
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'MechWorks · Apex Dynamics',
        icon: Icons.factory_rounded,
        subtitle: _onClock ? 'On shift' : 'Off clock',
      ),
      body: EngStarfield(
        child: !_hired
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Get hired via Career Center to enter MechWorks.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: EngCosmic.mute),
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: EngCosmic.panelBox(radius: 14),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _onClock
                                ? 'Clocked in · \$${(widget.progress.hourlyWageCents / 100).toStringAsFixed(2)}/hr'
                                : 'Start your shift to work tickets',
                            style: const TextStyle(
                              color: EngCosmic.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: _busy ? null : _toggleClock,
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                _onClock ? EngCosmic.orange : EngCosmic.teal,
                          ),
                          child: Text(_onClock ? 'Clock out' : 'Clock in'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: EngCosmic.panelBox(radius: 16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: EngCosmic.teal,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Samira Okonkwo',
                                  style: TextStyle(
                                    color: EngCosmic.ink,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Engineering manager',
                                  style: TextStyle(
                                    color: EngCosmic.mute,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Morning. Cell 3 reports vibration on the pick-and-place '
                          'arm after the weekend rebuild. Investigate unbalance vs RPM, '
                          'write a recommendation, and submit before standup.',
                          style: TextStyle(
                            color: EngCosmic.ink,
                            height: 1.4,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Opacity(
                    opacity: _onClock ? 1 : 0.45,
                    child: IgnorePointer(
                      ignoring: !_onClock,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: EngCosmic.panelBox(radius: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const Expanded(
                                  child: Text(
                                    'Ticket · Machine vibration',
                                    style: TextStyle(
                                      color: EngCosmic.ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (_done)
                                  EngCosmic.pill(
                                    'Passed',
                                    bg: EngCosmic.success.withValues(alpha: 0.18),
                                    fg: EngCosmic.success,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'RPM ${_rpm.toStringAsFixed(0)} · Unbalance '
                              '${_massUnbalanceG.toStringAsFixed(0)} g',
                              style: const TextStyle(color: EngCosmic.mute),
                            ),
                            Slider(
                              value: _rpm,
                              min: 800,
                              max: 3600,
                              activeColor: EngCosmic.electric,
                              onChanged: (double v) =>
                                  setState(() => _rpm = v),
                            ),
                            Slider(
                              value: _massUnbalanceG,
                              min: 2,
                              max: 40,
                              activeColor: EngCosmic.orange,
                              onChanged: (double v) =>
                                  setState(() => _massUnbalanceG = v),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _analyze,
                                    child: const Text('Investigate'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: _done ? null : _submit,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: EngCosmic.success,
                                    ),
                                    child: const Text('Submit report'),
                                  ),
                                ),
                              ],
                            ),
                            if (_diag != null) ...<Widget>[
                              const SizedBox(height: 10),
                              Text(
                                _diag!,
                                style: const TextStyle(
                                  color: EngCosmic.electric,
                                  height: 1.4,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bank ${widget.progress.balanceLabel} · '
                    'Made ${widget.progress.lifetimeEarnedLabel}',
                    style: const TextStyle(
                      color: EngCosmic.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
