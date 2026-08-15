import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// Stackwright — Junior Software Engineer under Avery Nova.
Widget csCareerPlayableScreen() => const CsCareerPlayableScreen();

class CsCareerPlayableScreen extends StatelessWidget {
  const CsCareerPlayableScreen({super.key});

  static const Color accent = Color(0xFF22D3EE);
  static const Color bg = Color(0xFF050B12);
  static const Color surface = Color(0xFF0B1622);

  static const PlayableCareer career = PlayableCareer(
    id: 'cs_career',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'Stackwright',
    clockLine: 'Monday — 10:04 AM',
    roleTitle: 'Junior Software Engineer',
    supervisorName: 'Avery Nova',
    supervisorRole: 'Staff Engineer',
    hireTagline: 'Build under pressure. Read the code. Ship the fix.',
    supervisorBrief:
        '“Checkout is red in production. You own the incident lane — '
        'logs, root cause, fix, tests.\n\n'
        'Then we ship password recovery. No hand-waving.”',
    enterCta: 'ENTER ENGINEERING FLOOR',
    startCta: 'OPEN INCIDENT',
    startLocationId: 'incident',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'lobby',
        name: 'Lobby',
        icon: '🏢',
        blurb: 'Badge gates and standee boards.',
        atmosphere: 'Stackwright HQ. Deploy boards glow green — except payments.',
      ),
      PlayableRoom(
        id: 'incident',
        name: 'Incident War Room',
        icon: '🚨',
        blurb: 'Pager noise and log walls.',
        atmosphere: 'PAYMENT SYSTEM FAILING. Avery wants a line number and a fix.',
      ),
      PlayableRoom(
        id: 'ide',
        name: 'Dev IDE',
        icon: '💻',
        blurb: 'Your workstation.',
        atmosphere: 'Monorepo open. Feature branch for password recovery waits.',
        lockedUntilStageId: 'lab1',
      ),
      PlayableRoom(
        id: 'ci',
        name: 'CI Bay',
        icon: '🧪',
        blurb: 'Test runners and gates.',
        atmosphere: 'Green builds ship. Red builds stay on the desk.',
      ),
      PlayableRoom(
        id: 'avery',
        name: 'Avery\'s Desk',
        icon: '🧑‍💻',
        blurb: 'Staff review.',
        atmosphere: 'Avery reviews diffs like a hawk. Bring evidence.',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'incident',
        bannerTitle: 'PAYMENT SYSTEM FAILING',
        bannerBody: 'Read logs, find the bug line, choose a fix, run tests.',
        cta: 'Triage the outage',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'ide',
        bannerTitle: 'FEATURE WORK',
        bannerBody:
            'Password recovery: requirements → design → implement → clear AI review issues.',
        cta: 'Build recovery flow',
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
            MaterialPageRoute<bool>(builder: (_) => const _CsLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _CsLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

// ─── Lab 1: Payment outage ─────────────────────────────────────────────────

class _CsLab1Screen extends StatefulWidget {
  const _CsLab1Screen();

  @override
  State<_CsLab1Screen> createState() => _CsLab1ScreenState();
}

class _CsLab1ScreenState extends State<_CsLab1Screen> {
  int _step = 0;
  String? _bugLine;
  String? _fix;
  bool _testsRun = false;
  String? _feedback;

  static const List<String> _logs = <String>[
    '10:01:12 INFO  checkout.start order=8821',
    '10:01:12 WARN  retry.queue depth=41',
    '10:01:13 ERROR charge: NullPointerException at PaymentService.java:147',
    '10:01:13 ERROR   → token.providerId used after refresh without null check',
    '10:01:14 INFO  rollback.txn order=8821',
  ];

  void _advanceFromLogs() {
    setState(() {
      _step = 1;
      _feedback = null;
    });
  }

  void _submit() {
    if (_bugLine != '147') {
      setState(() => _feedback = 'Avery: “Wrong line. Re-read the stack.”');
      return;
    }
    if (_fix != 'null_guard') {
      setState(() =>
          _feedback = 'Avery: “That fix won’t hold. Guard the refreshed token.”');
      return;
    }
    if (!_testsRun) {
      setState(() => _feedback = 'Run the payment regression suite before you claim done.');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: CsCareerPlayableScreen.surface,
          title: const Text(
            'Avery Nova — Incident closed',
            style: TextStyle(
              color: CsCareerPlayableScreen.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            '“Null guard on providerId after refresh. Tests green.\n\n'
            'Next: password recovery feature on your board.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: CsCareerPlayableScreen.accent,
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
      backgroundColor: CsCareerPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: CsCareerPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Payment outage', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CsCareerPlayableScreen.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.55)),
            ),
            child: const Text(
              'ALERT · PAYMENT SYSTEM FAILING\nCheckout success rate: 12%',
              style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.w800, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          if (_step == 0) ...<Widget>[
            const Text('LOGS', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _logs
                    .map(
                      (String l) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          l,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: l.contains('ERROR')
                                ? const Color(0xFFF87171)
                                : Colors.white70,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _advanceFromLogs,
              style: FilledButton.styleFrom(
                backgroundColor: CsCareerPlayableScreen.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('LOCATE BUG LINE', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ] else ...<Widget>[
            const Text('BUG LINE', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
            ...<(String, String)>[
              ('89', 'Line 89 — retry backoff'),
              ('147', 'Line 147 — token.providerId after refresh'),
              ('210', 'Line 210 — log formatter'),
            ].map(((String, String) o) {
              final bool on = _bugLine == o.$1;
              return ListTile(
                tileColor: CsCareerPlayableScreen.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: on ? CsCareerPlayableScreen.accent : Colors.transparent),
                ),
                title: Text(o.$2, style: const TextStyle(color: Colors.white, fontSize: 14)),
                leading: Icon(
                  on ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: CsCareerPlayableScreen.accent,
                ),
                onTap: () => setState(() => _bugLine = o.$1),
              );
            }),
            const SizedBox(height: 12),
            const Text('FIX', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
            ...<(String, String)>[
              ('retry_more', 'Increase retries to 20'),
              ('null_guard', 'Add null check after token refresh'),
              ('disable_payments', 'Disable payments globally'),
            ].map(((String, String) o) {
              final bool on = _fix == o.$1;
              return ListTile(
                tileColor: CsCareerPlayableScreen.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: on ? CsCareerPlayableScreen.accent : Colors.transparent),
                ),
                title: Text(o.$2, style: const TextStyle(color: Colors.white, fontSize: 14)),
                leading: Icon(
                  on ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: CsCareerPlayableScreen.accent,
                ),
                onTap: () => setState(() => _fix = o.$1),
              );
            }),
            const SizedBox(height: 12),
            ListTile(
              tileColor: CsCareerPlayableScreen.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text(
                _testsRun ? 'Tests passed · payment_regression' : 'Run payment regression tests',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              trailing: Icon(
                _testsRun ? Icons.check_circle : Icons.play_arrow,
                color: CsCareerPlayableScreen.accent,
              ),
              onTap: () => setState(() => _testsRun = true),
            ),
            if (_feedback != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24), height: 1.4)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: CsCareerPlayableScreen.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('SHIP FIX', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Lab 2: Password recovery feature ──────────────────────────────────────

class _CsLab2Screen extends StatefulWidget {
  const _CsLab2Screen();

  @override
  State<_CsLab2Screen> createState() => _CsLab2ScreenState();
}

class _CsLab2ScreenState extends State<_CsLab2Screen> {
  int _phase = 0; // 0 req · 1 design · 2 impl · 3 review
  final Set<String> _reqs = <String>{};
  String? _design;
  final Set<String> _impl = <String>{};
  final Set<String> _reviewFixed = <String>{};
  String? _feedback;

  static const List<(String, String)> _reqItems = <(String, String)>[
    ('email', 'Email + rate-limited reset link'),
    ('expiry', 'Token expires in 15 minutes'),
    ('audit', 'Audit log every reset attempt'),
  ];

  static const List<(String, String)> _implSteps = <(String, String)>[
    ('endpoint', 'Add /auth/recover endpoint'),
    ('token', 'Generate hashed single-use token'),
    ('mailer', 'Queue recovery email'),
    ('ui', 'Build reset form with strength meter'),
  ];

  static const List<(String, String)> _issues = <(String, String)>[
    ('timing', 'Token compare is not constant-time'),
    ('enum', 'Error messages enumerate valid emails'),
  ];

  void _next() {
    if (_phase == 0 && _reqs.length < 3) {
      setState(() => _feedback = 'Capture all three requirements from Avery’s brief.');
      return;
    }
    if (_phase == 1 && _design != 'token_email') {
      setState(() =>
          _feedback = 'Avery: “SMS-only is out of scope. Email + expiring token.”');
      return;
    }
    if (_phase == 2 && _impl.length < 4) {
      setState(() => _feedback = 'Finish every implement step before review.');
      return;
    }
    if (_phase == 3 && _reviewFixed.length < 2) {
      setState(() => _feedback = 'AI review still red. Fix both issues.');
      return;
    }
    setState(() {
      _feedback = null;
      if (_phase < 3) {
        _phase++;
      } else {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) {
            return AlertDialog(
              backgroundColor: CsCareerPlayableScreen.surface,
              title: const Text(
                'Avery Nova — Feature accepted',
                style: TextStyle(
                  color: CsCareerPlayableScreen.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: const Text(
                '“Requirements, design, implementation, and review notes — all clean. '
                'Welcome to the floor.”',
                style: TextStyle(color: Colors.white, height: 1.45),
              ),
              actions: <Widget>[
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: CsCareerPlayableScreen.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> titles = <String>[
      'Requirements',
      'Design choice',
      'Implement',
      'AI review',
    ];
    return Scaffold(
      backgroundColor: CsCareerPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: CsCareerPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: Text(
          'Password recovery · ${titles[_phase]}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          if (_phase == 0)
            ..._reqItems.map(((String, String) o) {
              final bool on = _reqs.contains(o.$1);
              return CheckboxListTile(
                value: on,
                activeColor: CsCareerPlayableScreen.accent,
                title: Text(o.$2, style: const TextStyle(color: Colors.white)),
                onChanged: (bool? v) {
                  setState(() {
                    if (v == true) {
                      _reqs.add(o.$1);
                    } else {
                      _reqs.remove(o.$1);
                    }
                  });
                },
              );
            }),
          if (_phase == 1)
            ...<(String, String)>[
              ('sms', 'SMS one-time code only'),
              ('token_email', 'Email link + hashed expiring token'),
              ('security_q', 'Security questions'),
            ].map(((String, String) o) {
              final bool on = _design == o.$1;
              return ListTile(
                tileColor: CsCareerPlayableScreen.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: on ? CsCareerPlayableScreen.accent : Colors.transparent),
                ),
                leading: Icon(
                  on ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: CsCareerPlayableScreen.accent,
                ),
                title: Text(o.$2, style: const TextStyle(color: Colors.white)),
                onTap: () => setState(() => _design = o.$1),
              );
            }),
          if (_phase == 2)
            ..._implSteps.map(((String, String) o) {
              final bool on = _impl.contains(o.$1);
              return ListTile(
                tileColor: CsCareerPlayableScreen.surface,
                title: Text(o.$2, style: const TextStyle(color: Colors.white)),
                trailing: Icon(
                  on ? Icons.check_circle : Icons.circle_outlined,
                  color: CsCareerPlayableScreen.accent,
                ),
                onTap: () => setState(() => _impl.add(o.$1)),
              );
            }),
          if (_phase == 3) ...<Widget>[
            const Text(
              'AI PROFESSOR REVIEW',
              style: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.w900, fontSize: 11),
            ),
            const SizedBox(height: 8),
            ..._issues.map(((String, String) o) {
              final bool fixed = _reviewFixed.contains(o.$1);
              return ListTile(
                tileColor: CsCareerPlayableScreen.surface,
                title: Text(o.$2, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  fixed ? 'Patched' : 'Open issue — tap to fix',
                  style: TextStyle(color: fixed ? const Color(0xFF34D399) : Colors.white54),
                ),
                onTap: () => setState(() => _reviewFixed.add(o.$1)),
              );
            }),
          ],
          if (_feedback != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24), height: 1.4)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _next,
            style: FilledButton.styleFrom(
              backgroundColor: CsCareerPlayableScreen.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              _phase == 3 ? 'SUBMIT FOR MERGE' : 'CONTINUE',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
