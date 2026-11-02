import 'package:flutter/material.dart';

import 'hiring_desk_screen.dart';
import 'job_catalog.dart';
import 'science_career_progress.dart';
import 'science_career_theme.dart';

class NorthwindWorkplaceScreen extends StatefulWidget {
  const NorthwindWorkplaceScreen({super.key, required this.progress});

  final ScienceCareerProgress progress;

  @override
  State<NorthwindWorkplaceScreen> createState() =>
      _NorthwindWorkplaceScreenState();
}

class _NorthwindWorkplaceScreenState extends State<NorthwindWorkplaceScreen> {
  static const String _ticketId = 'NW-142';
  static const String _jobId = 'northwind_junior';

  String _dialogueChoice = '';
  bool _check400 = false;
  bool _checkValid = false;
  bool _checkTest = false;
  int _impl = 0;
  List<String>? _testLog;
  bool _running = false;
  bool _clockBusy = false;
  bool _acceptBusy = false;

  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_onProgress);
    if (widget.progress.isEmployedAtNorthwind) {
      widget.progress.ensureHiringDeskSeeded(count: 3);
    }
  }

  @override
  void dispose() {
    widget.progress.removeListener(_onProgress);
    super.dispose();
  }

  void _onProgress() {
    if (mounted) setState(() {});
  }

  bool get _hired => widget.progress.isEmployedAtNorthwind;

  bool get _hasOffer {
    if (widget.progress.offerReceived) return true;
    if (widget.progress.statusFor(_jobId) == 'offered') return true;
    for (final MapEntry<String, String> e
        in widget.progress.applicationStatus.entries) {
      if (e.value == 'offered' && CareerJobs.isNorthwindJob(e.key)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _acceptHere() async {
    if (_acceptBusy) return;
    setState(() => _acceptBusy = true);
    final bool ok = await widget.progress.acceptOffer(
      jobId: _jobId,
      company: 'Northwind Labs',
    );
    if (!mounted) return;
    setState(() => _acceptBusy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Northwind offer found. Apply in Career Center first.'),
        ),
      );
    }
  }

  bool get _onClock => widget.progress.clockedIn;

  bool get _done => widget.progress.ticketsCleared.contains(_ticketId);

  Future<void> _toggleClock() async {
    if (!_hired || _clockBusy) return;
    setState(() => _clockBusy = true);
    if (_onClock) {
      final int earned = await widget.progress.clockOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Clocked out · +\$${(earned / 100).toStringAsFixed(2)} deposited · Bank ${widget.progress.balanceLabel}',
          ),
        ),
      );
    } else {
      final bool ok = await widget.progress.clockIn(jobId: _jobId);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clocked in · shift started at \$28.00/hr'),
          ),
        );
      }
    }
    if (mounted) setState(() => _clockBusy = false);
  }

  Future<void> _runTests() async {
    if (!_onClock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clock in before working on tickets.')),
      );
      return;
    }
    setState(() {
      _running = true;
      _testLog = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final bool fixed = _impl == 1;
    setState(() {
      _running = false;
      _testLog = fixed
          ? <String>[
              '5 passed, 0 failed.',
              'test_missing_email_returns_400: ok',
              'test_valid_login: ok',
            ]
          : <String>[
              '4 passed, 1 failed.',
              'test_missing_email_returns_400: expected 400, got 500.',
            ];
      if (fixed) {
        _check400 = true;
        _checkValid = true;
        _checkTest = true;
      }
    });
  }

  Future<void> _submit() async {
    if (!_onClock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clock in before submitting work.')),
      );
      return;
    }
    if (_done) return;
    if (_impl != 1 || !_check400 || !_checkValid || !_checkTest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fix the bug, run tests, and complete the checklist first.'),
        ),
      );
      return;
    }
    // \$12.00 task bonus in cents while on shift.
    await widget.progress.clearTicket(_ticketId, xpGain: 120, pay: 1200);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Priya approved your fix · +\$12.00 task bonus · Bank ${widget.progress.balanceLabel}',
        ),
      ),
    );
  }

  static const String _buggy = '''def login(request):
  data = request.json
  email = data.get("email").lower()  # crashes when email is None
  user = find_user(email)
  if user is None or not user.check(data["password"]):
    return {"error": "Invalid login"}, 401
  return {"token": make_token(user)}, 200''';

  static const String _fixed = '''def login(request):
  data = request.json
  email = data.get("email")
  if not email:
    return {"error": "Email is required"}, 400
  email = email.lower()
  user = find_user(email)
  if user is None or not user.check(data["password"]):
    return {"error": "Invalid login"}, 401
  return {"token": make_token(user)}, 200''';

  @override
  Widget build(BuildContext context) {
    final Duration? elapsed = widget.progress.currentShiftElapsed;
    final String shiftLabel = elapsed == null
        ? 'Off the clock'
        : 'On shift · ${elapsed.inHours}h ${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}m';

    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: AppBar(
        backgroundColor: SciCosmic.bg.withValues(alpha: 0.92),
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
          label: const Text('Campus'),
          style: TextButton.styleFrom(foregroundColor: SciCosmic.mute),
        ),
        leadingWidth: 108,
        title: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 14,
              backgroundColor: SciCosmic.blue,
              child: const Text(
                'N',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Northwind Labs',
                style: TextStyle(
                  color: SciCosmic.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SciCosmic.pill('Junior Software Engineer'),
          ],
        ),
        actions: <Widget>[
          if (_hired)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          HiringDeskScreen(progress: widget.progress),
                    ),
                  );
                },
                icon: const Icon(Icons.groups_rounded, size: 16),
                label: Text(
                  widget.progress.pendingApplicants.isEmpty
                      ? 'Hiring'
                      : 'Hiring (${widget.progress.pendingApplicants.length})',
                ),
                style: TextButton.styleFrom(foregroundColor: SciCosmic.electric),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                shiftLabel,
                style: const TextStyle(color: SciCosmic.mute, fontSize: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SciCosmic.pill(
              'Bank ${widget.progress.balanceLabel}',
              icon: Icons.account_balance_wallet_rounded,
              bg: SciCosmic.gold.withValues(alpha: 0.18),
              fg: SciCosmic.gold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SciCosmic.pill(
              'Made ${widget.progress.lifetimeEarnedLabel}',
              icon: Icons.trending_up_rounded,
              bg: SciCosmic.success.withValues(alpha: 0.16),
              fg: SciCosmic.success,
            ),
          ),
        ],
      ),
      body: SciStarfield(
        child: !_hired
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _hasOffer
                              ? 'You have a Northwind offer waiting. Accept it to enter the office and clock in.'
                              : 'You are not employed here yet. Apply and accept a Northwind offer in Career Center first.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: SciCosmic.mute, height: 1.4),
                        ),
                        if (_hasOffer) ...<Widget>[
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _acceptBusy ? null : _acceptHere,
                            style: FilledButton.styleFrom(
                              backgroundColor: SciCosmic.success,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: Text(
                              _acceptBusy
                                  ? 'Accepting…'
                                  : 'Accept Northwind offer',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: SciCosmic.panelBox(radius: 14),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _onClock
                                    ? 'You are clocked in · \$28.00/hr'
                                    : widget.progress.hasStartedWork
                                        ? 'Continue your job — clock in for this shift'
                                        : 'Start your job — clock in for your first shift',
                                style: const TextStyle(
                                  color: SciCosmic.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _onClock
                                    ? 'Work tickets now. Clock out to deposit wages to your bank.'
                                    : 'Clock in → do work → submit → clock out → get paid.',
                                style: const TextStyle(
                                  color: SciCosmic.mute,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: <Widget>[
                              FilledButton(
                                onPressed: _clockBusy ? null : _toggleClock,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _onClock
                                      ? SciCosmic.orange
                                      : SciCosmic.teal,
                                ),
                                child: Text(
                                  _onClock
                                      ? 'Clock out'
                                      : widget.progress.hasStartedWork
                                          ? 'Continue job'
                                          : 'Start job',
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute<void>(
                                      builder: (_) => HiringDeskScreen(
                                        progress: widget.progress,
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: SciCosmic.electric,
                                  side: const BorderSide(
                                    color: SciCosmic.stroke,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.groups_rounded,
                                  size: 16,
                                ),
                                label: const Text('Hiring desk'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_onClock)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: SciCosmic.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Workstation locked until you clock in.',
                        style: TextStyle(color: SciCosmic.orange, fontSize: 12),
                      ),
                    ),
                  Expanded(
                    child: IgnorePointer(
                      ignoring: !_onClock,
                      child: Opacity(
                        opacity: _onClock ? 1 : 0.45,
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints c) {
                            final bool wide = c.maxWidth >= 1000;
                            final Widget left = _ManagerPane(
                              choice: _dialogueChoice,
                              onChoice: (String t) =>
                                  setState(() => _dialogueChoice = t),
                            );
                            final Widget center = _TaskPane(
                              buggy: _buggy,
                              fixed: _fixed,
                              impl: _impl,
                              onImpl: (int i) => setState(() {
                                _impl = i;
                                _testLog = null;
                              }),
                              check400: _check400,
                              checkValid: _checkValid,
                              checkTest: _checkTest,
                              onToggle400: (bool v) =>
                                  setState(() => _check400 = v),
                              onToggleValid: (bool v) =>
                                  setState(() => _checkValid = v),
                              onToggleTest: (bool v) =>
                                  setState(() => _checkTest = v),
                              testLog: _testLog,
                              running: _running,
                              done: _done,
                              onRun: _runTests,
                              onHint: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Hint: data.get("email") can be None — guard before .lower().',
                                    ),
                                  ),
                                );
                              },
                              onSubmit: _submit,
                            );
                            final Widget right = _SprintPane(
                              done: _done,
                              balance: widget.progress.balanceLabel,
                              stubs: widget.progress.payStubs,
                            );
                            if (wide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  SizedBox(width: 280, child: left),
                                  Expanded(child: center),
                                  SizedBox(width: 260, child: right),
                                ],
                              );
                            }
                            return ListView(
                              children: <Widget>[
                                SizedBox(height: 300, child: left),
                                center,
                                SizedBox(height: 300, child: right),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ManagerPane extends StatelessWidget {
  const _ManagerPane({required this.choice, required this.onChoice});
  final String choice;
  final ValueChanged<String> onChoice;

  @override
  Widget build(BuildContext context) {
    const List<String> choices = <String>[
      "On it. I'll reproduce it first.",
      'Where should I start looking?',
      'How urgent is this?',
    ];
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: SciCosmic.panelBox(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: SciCosmic.panelAlt,
            ),
            alignment: Alignment.center,
            child: const Text(
              'Sprint 1 board',
              style: TextStyle(color: SciCosmic.mute),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: SciCosmic.teal,
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Jordan Reyes',
                    style: TextStyle(
                      color: SciCosmic.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Engineering manager',
                    style: TextStyle(color: SciCosmic.mute, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SciCosmic.panelAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Morning. Customers are seeing a 500 when they leave the email '
              "box empty. Can you fix it and add a test before tomorrow's standup?",
              style: TextStyle(color: SciCosmic.ink, height: 1.4, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),
          ...choices.map(
            (String t) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: OutlinedButton(
                onPressed: () => onChoice(t),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      choice == t ? SciCosmic.electric : SciCosmic.ink,
                  side: BorderSide(
                    color: choice == t ? SciCosmic.electric : SciCosmic.stroke,
                  ),
                  minimumSize: const Size.fromHeight(40),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskPane extends StatelessWidget {
  const _TaskPane({
    required this.buggy,
    required this.fixed,
    required this.impl,
    required this.onImpl,
    required this.check400,
    required this.checkValid,
    required this.checkTest,
    required this.onToggle400,
    required this.onToggleValid,
    required this.onToggleTest,
    required this.testLog,
    required this.running,
    required this.done,
    required this.onRun,
    required this.onHint,
    required this.onSubmit,
  });

  final String buggy;
  final String fixed;
  final int impl;
  final ValueChanged<int> onImpl;
  final bool check400;
  final bool checkValid;
  final bool checkTest;
  final ValueChanged<bool> onToggle400;
  final ValueChanged<bool> onToggleValid;
  final ValueChanged<bool> onToggleTest;
  final List<String>? testLog;
  final bool running;
  final bool done;
  final VoidCallback onRun;
  final VoidCallback onHint;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: SciCosmic.panelBox(radius: 18),
      child: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'NW-142',
                style: TextStyle(
                  color: SciCosmic.mute,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              SciCosmic.pill(
                done ? 'Passed' : 'In progress',
                bg: SciCosmic.purple.withValues(alpha: 0.25),
              ),
              const SizedBox(width: 6),
              SciCosmic.pill(
                'High priority',
                bg: SciCosmic.orange.withValues(alpha: 0.2),
                fg: SciCosmic.orange,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Login returns 500 when email is missing.',
            style: TextStyle(
              color: SciCosmic.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          _Check(
            value: check400,
            onChanged: done ? null : onToggle400,
            label: 'A missing email returns 400 with a clear message.',
          ),
          _Check(
            value: checkValid,
            onChanged: done ? null : onToggleValid,
            label: 'Valid logins still work.',
          ),
          _Check(
            value: checkTest,
            onChanged: done ? null : onToggleTest,
            label: 'A regression test covers the missing-email case.',
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const Text(
                'auth.py',
                style: TextStyle(
                  color: SciCosmic.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              DropdownButton<int>(
                value: impl,
                dropdownColor: SciCosmic.panelAlt,
                underline: const SizedBox.shrink(),
                items: const <DropdownMenuItem<int>>[
                  DropdownMenuItem<int>(
                    value: 0,
                    child: Text(
                      'Current (buggy)',
                      style: TextStyle(color: SciCosmic.ink),
                    ),
                  ),
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text(
                      'Fixed version',
                      style: TextStyle(color: SciCosmic.ink),
                    ),
                  ),
                ],
                onChanged: done
                    ? null
                    : (int? v) {
                        if (v != null) onImpl(v);
                      },
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D111C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SciCosmic.stroke),
            ),
            child: Text(
              impl == 0 ? buggy : fixed,
              style: TextStyle(
                color: const Color(0xFFD4E0FF),
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.45,
                backgroundColor: impl == 0
                    ? SciCosmic.orange.withValues(alpha: 0.08)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (testLog != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SciCosmic.panelAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                testLog!.join('\n'),
                style: const TextStyle(
                  color: SciCosmic.mute,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton(
                onPressed: running || done ? null : onRun,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SciCosmic.ink,
                  side: const BorderSide(color: SciCosmic.stroke),
                ),
                child: Text(running ? 'Running…' : 'Run tests'),
              ),
              OutlinedButton(
                onPressed: onHint,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SciCosmic.ink,
                  side: const BorderSide(color: SciCosmic.stroke),
                ),
                child: const Text('Hint'),
              ),
              FilledButton(
                onPressed: done ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: SciCosmic.purple,
                ),
                child: Text(done ? 'Submitted' : 'Submit for review'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged == null ? null : (bool? v) => onChanged!(v ?? false),
      dense: true,
      contentPadding: EdgeInsets.zero,
      activeColor: SciCosmic.purple,
      title: Text(
        label,
        style: const TextStyle(color: SciCosmic.ink, fontSize: 13),
      ),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class _SprintPane extends StatelessWidget {
  const _SprintPane({
    required this.done,
    required this.balance,
    required this.stubs,
  });

  final bool done;
  final String balance;
  final List<Map<String, dynamic>> stubs;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: SciCosmic.panelBox(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Payroll',
            style: TextStyle(
              color: SciCosmic.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bank $balance',
            style: const TextStyle(
              color: SciCosmic.gold,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const Text(
            '\$28.00 / hr · min 15 min credited per clock-out',
            style: TextStyle(color: SciCosmic.mute, fontSize: 11),
          ),
          const SizedBox(height: 14),
          const Text('Sprint board', style: TextStyle(color: SciCosmic.mute)),
          Text(
            done ? 'NW-142 cleared' : 'In progress: NW-142',
            style: const TextStyle(color: SciCosmic.ink, fontSize: 12),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SciCosmic.panelAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Recent pay stubs',
                  style: TextStyle(
                    color: SciCosmic.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                if (stubs.isEmpty)
                  const Text(
                    'Clock out after a shift to see deposits here.',
                    style: TextStyle(color: SciCosmic.mute, fontSize: 11),
                  )
                else
                  ...stubs.take(3).map((Map<String, dynamic> s) {
                    final int cents = s['earnedCents'] as int? ?? 0;
                    final Object? hours = s['hours'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '+\$${(cents / 100).toStringAsFixed(2)} · ${hours}h',
                        style: const TextStyle(
                          color: SciCosmic.success,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 8),
                const Text(
                  'Task bonus: +\$12.00 when NW-142 is approved on shift.',
                  style: TextStyle(color: SciCosmic.mute, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
