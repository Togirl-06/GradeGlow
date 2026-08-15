import 'package:flutter/material.dart';

import '../shared/playable_models.dart';
import '../shared/playable_workplace_screen.dart';
import '../visual/visual_career_bridge.dart';

/// ShieldOps SOC — Security Analyst under Camila Reyes.
Widget cybersecurityPlayableScreen() => const CybersecurityPlayableScreen();

class CybersecurityPlayableScreen extends StatelessWidget {
  const CybersecurityPlayableScreen({super.key});

  // Defend palette — crimson / deep SOC dark (distinct from CS cyan build floor)
  static const Color accent = Color(0xFFEF4444);
  static const Color bg = Color(0xFF0A0506);
  static const Color surface = Color(0xFF1A0E10);

  static const PlayableCareer career = PlayableCareer(
    id: 'cybersecurity',
    accent: accent,
    bg: bg,
    surface: surface,
    workplaceName: 'ShieldOps SOC',
    clockLine: 'Thursday — 11:47 PM',
    roleTitle: 'Security Analyst',
    supervisorName: 'Camila Reyes',
    supervisorRole: 'SOC Lead',
    hireTagline: 'Defend the perimeter. Classify before you contain.',
    supervisorBrief:
        '“SUSPICIOUS LOGIN just fired. Investigate logs, account, device, network — '
        'then classify benign / suspicious / malicious.\n\n'
        'Your call shapes the next alert. Contain when it’s real.”',
    enterCta: 'ENTER SOC',
    startCta: 'OPEN ALERT',
    startLocationId: 'console',
    rooms: <PlayableRoom>[
      PlayableRoom(
        id: 'lobby',
        name: 'SOC Lobby',
        icon: '🛡️',
        blurb: 'Badge + retina gate.',
        atmosphere: 'ShieldOps. Red team posters. Night shift hum.',
      ),
      PlayableRoom(
        id: 'console',
        name: 'Analyst Console',
        icon: '🖥️',
        blurb: 'SIEM and tickets.',
        atmosphere: 'SUSPICIOUS LOGIN blinking. Evidence before labels.',
      ),
      PlayableRoom(
        id: 'intel',
        name: 'Threat Intel',
        icon: '📡',
        blurb: 'IOCs and feeds.',
        atmosphere: 'Known bad ASNs and impossible travel hints.',
      ),
      PlayableRoom(
        id: 'contain',
        name: 'Containment Bay',
        icon: '🔒',
        blurb: 'Isolate and revoke.',
        atmosphere: 'Second alert develops from your first decision.',
        lockedUntilStageId: 'lab1',
      ),
    ],
    stages: <PlayableStage>[
      PlayableStage(
        id: 'lab1',
        locationId: 'console',
        bannerTitle: 'SUSPICIOUS LOGIN',
        bannerBody: 'Investigate logs / account / device / network. Classify the alert.',
        cta: 'Investigate alert',
        unlockKey: 'lab1',
      ),
      PlayableStage(
        id: 'lab2',
        locationId: 'contain',
        bannerTitle: 'ESCALATION',
        bannerBody: 'Second alert develops from your prior decision — contain the threat.',
        cta: 'Contain the threat',
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
            MaterialPageRoute<bool>(builder: (_) => const _CyberLab1Screen()),
          );
          return ok == true;
        }
        if (stage.id == 'lab2') {
          final bool? ok = await Navigator.of(ctx).push<bool>(
            MaterialPageRoute<bool>(builder: (_) => const _CyberLab2Screen()),
          );
          return ok == true;
        }
        return false;
      },
    );
  }
}

class _CyberLab1Screen extends StatefulWidget {
  const _CyberLab1Screen();

  @override
  State<_CyberLab1Screen> createState() => _CyberLab1ScreenState();
}

class _CyberLab1ScreenState extends State<_CyberLab1Screen> {
  final Set<String> _opened = <String>{};
  String? _class;
  String? _feedback;

  static const List<(String, String, String)> _evidence = <(String, String, String)>[
    (
      'logs',
      'Auth logs',
      '23:41 UTC success from ASN 64512 (new). Prior 14 days: office /VPN only. MFA push approved in 2s.',
    ),
    (
      'account',
      'Account panel',
      'User: j.ortiz · role finance · no travel ticket · password age 11 days · recovery email changed yesterday.',
    ),
    (
      'device',
      'Device posture',
      'New unmanaged Windows host · no EDR · hostname WIN-TEMP-882 · first seen tonight.',
    ),
    (
      'network',
      'Network',
      'Geo: impossible travel vs morning NYC VPN · destination share: finance_Q_export.xlsx',
    ),
  ];

  Future<void> _open((String, String, String) e) async {
    setState(() => _opened.add(e.$1));
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: CybersecurityPlayableScreen.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                e.$2.toUpperCase(),
                style: const TextStyle(
                  color: CybersecurityPlayableScreen.accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Text(e.$3, style: const TextStyle(color: Colors.white, height: 1.45)),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    if (_opened.length < 4) {
      setState(() => _feedback = 'Reyes: “Open all four evidence panes.”');
      return;
    }
    if (_class != 'malicious') {
      setState(() =>
          _feedback = 'Reyes: “New device, impossible travel, recovery email change — classify harder.”');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: CybersecurityPlayableScreen.surface,
          title: const Text(
            'Camila Reyes — Classified malicious',
            style: TextStyle(color: CybersecurityPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“Good call. Watch the console — a second alert will bloom from this session. Contain it.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: CybersecurityPlayableScreen.accent,
                foregroundColor: Colors.white,
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
      backgroundColor: CybersecurityPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: CybersecurityPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('SUSPICIOUS LOGIN', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CybersecurityPlayableScreen.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CybersecurityPlayableScreen.accent.withValues(alpha: 0.55)),
            ),
            child: const Text(
              'ALERT · suspicious login · j.ortiz · finance share access',
              style: TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          ..._evidence.map(((String, String, String) e) {
            final bool seen = _opened.contains(e.$1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                tileColor: CybersecurityPlayableScreen.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: Icon(
                  seen ? Icons.folder_open : Icons.folder,
                  color: CybersecurityPlayableScreen.accent,
                ),
                title: Text(e.$2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                subtitle: Text(seen ? 'Reviewed' : 'Tap to investigate', style: const TextStyle(color: Colors.white54)),
                onTap: () => _open(e),
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text('CLASSIFY', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11)),
          ...<(String, String)>[
            ('benign', 'Benign'),
            ('suspicious', 'Suspicious'),
            ('malicious', 'Malicious'),
          ].map(((String, String) o) {
            final bool on = _class == o.$1;
            return ListTile(
              tileColor: CybersecurityPlayableScreen.surface,
              leading: Icon(
                on ? Icons.radio_button_checked : Icons.radio_button_off,
                color: CybersecurityPlayableScreen.accent,
              ),
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              onTap: () => setState(() => _class = o.$1),
            );
          }),
          if (_feedback != null) Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: CybersecurityPlayableScreen.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('FILE CLASSIFICATION', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _CyberLab2Screen extends StatefulWidget {
  const _CyberLab2Screen();

  @override
  State<_CyberLab2Screen> createState() => _CyberLab2ScreenState();
}

class _CyberLab2ScreenState extends State<_CyberLab2Screen> {
  final Set<String> _actions = <String>{};
  String? _feedback;

  static const List<(String, String)> _steps = <(String, String)>[
    ('disable', 'Disable j.ortiz interactive login'),
    ('revoke', 'Revoke active sessions + tokens'),
    ('isolate', 'Isolate WIN-TEMP-882 from network'),
    ('share', 'Lock finance share & rotate keys'),
    ('ignore', 'Mark as false positive and close'),
  ];

  void _submit() {
    final bool good = _actions.containsAll(<String>['disable', 'revoke', 'isolate', 'share']) &&
        !_actions.contains('ignore');
    if (!good) {
      setState(() =>
          _feedback = 'Reyes: “Contain fully — account, sessions, host, share. Do not close as FP.”');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: CybersecurityPlayableScreen.surface,
          title: const Text(
            'Camila Reyes — Contained',
            style: TextStyle(color: CybersecurityPlayableScreen.accent, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“Second-wave exfil attempt stopped. Ticket closed with containment timeline. Solid night.”',
            style: TextStyle(color: Colors.white, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: CybersecurityPlayableScreen.accent,
                foregroundColor: Colors.white,
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
      backgroundColor: CybersecurityPlayableScreen.bg,
      appBar: AppBar(
        backgroundColor: CybersecurityPlayableScreen.bg,
        foregroundColor: Colors.white,
        title: const Text('Containment', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CybersecurityPlayableScreen.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CybersecurityPlayableScreen.accent.withValues(alpha: 0.55)),
            ),
            child: const Text(
              'FOLLOW-ON ALERT · large file read on finance share from WIN-TEMP-882\n'
              'Developed from prior malicious login classification.',
              style: TextStyle(color: Colors.white, height: 1.4, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          ..._steps.map(((String, String) o) {
            final bool on = _actions.contains(o.$1);
            return CheckboxListTile(
              value: on,
              activeColor: CybersecurityPlayableScreen.accent,
              title: Text(o.$2, style: const TextStyle(color: Colors.white)),
              onChanged: (bool? v) {
                setState(() {
                  if (v == true) {
                    _actions.add(o.$1);
                  } else {
                    _actions.remove(o.$1);
                  }
                });
              },
            );
          }),
          if (_feedback != null) Text(_feedback!, style: const TextStyle(color: Color(0xFFFBBF24))),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: CybersecurityPlayableScreen.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('EXECUTE CONTAINMENT', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
