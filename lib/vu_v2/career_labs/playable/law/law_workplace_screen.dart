import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'law_case_data.dart';
import 'law_case_file_screen.dart';
import 'law_interview_screen.dart';

/// Enter the firm. Not a lab list — a workplace.
class LawWorkplaceScreen extends StatefulWidget {
  const LawWorkplaceScreen({super.key});

  @override
  State<LawWorkplaceScreen> createState() => _LawWorkplaceScreenState();
}

class _LawWorkplaceScreenState extends State<LawWorkplaceScreen> {
  static const String _prefPrefix = 'law_playable_';

  bool _ready = false;
  bool _sawHire = false;
  bool _interviewDone = false;
  bool _caseFileUnlocked = false;
  bool _caseFileDone = false;
  int _intakeScore = 0;
  String _locationId = 'reception';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    setState(() {
      _sawHire = p.getBool('${_prefPrefix}saw_hire') ?? false;
      _interviewDone = p.getBool('${_prefPrefix}interview_done') ?? false;
      _caseFileUnlocked = p.getBool('${_prefPrefix}case_unlocked') ?? false;
      _caseFileDone = p.getBool('${_prefPrefix}case_done') ?? false;
      _intakeScore = p.getInt('${_prefPrefix}intake_score') ?? 0;
      _locationId = p.getString('${_prefPrefix}location') ?? 'reception';
      _ready = true;
    });
    if (!_sawHire) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_sawHire) _openHireFlow();
      });
    }
  }

  Future<void> _persist() async {
    final SharedPreferences p = await SharedPreferences.getInstance();
    await p.setBool('${_prefPrefix}saw_hire', _sawHire);
    await p.setBool('${_prefPrefix}interview_done', _interviewDone);
    await p.setBool('${_prefPrefix}case_unlocked', _caseFileUnlocked);
    await p.setBool('${_prefPrefix}case_done', _caseFileDone);
    await p.setInt('${_prefPrefix}intake_score', _intakeScore);
    await p.setString('${_prefPrefix}location', _locationId);
  }

  Future<void> _openHireFlow() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF14100C),
          title: const Text(
            'YOU ARE HIRED\nJunior Law Associate',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Hartwell & Associates\n'
            'Supervisor: Senior Associate Maya Chen\n\n'
            'This is not a quiz. You work cases.',
            style: TextStyle(color: Colors.white70, height: 1.45),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: Colors.black,
              ),
              child: const Text('ENTER THE FIRM', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1510),
          title: const Text(
            'Maya Chen · Senior Associate',
            style: TextStyle(color: Color(0xFFD4A574), fontWeight: FontWeight.w800),
          ),
          content: const Text(
            '“Good morning. We have a new client — Jordan Hale. '
            'I want you to handle the initial interview.\n\n'
            'Conference room. Don\'t make me regret this.”',
            style: TextStyle(color: Colors.white, height: 1.5),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: Colors.black,
              ),
              child: const Text('MEET THE CLIENT', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    setState(() {
      _sawHire = true;
      _locationId = 'conference';
    });
    await _persist();
    if (mounted) await _openInterview();
  }

  Future<void> _openInterview() async {
    setState(() => _locationId = 'conference');
    await _persist();
    if (!mounted) return;
    final int? score = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(builder: (_) => const LawInterviewScreen()),
    );
    if (!mounted) return;
    if (score != null) {
      setState(() {
        _interviewDone = true;
        _caseFileUnlocked = true;
        _intakeScore = score;
        _locationId = 'evidence';
      });
      await _persist();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (BuildContext ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1510),
          title: const Text('Case file unlocked', style: TextStyle(color: Colors.white)),
          content: Text(
            'Intake score: $score / 100\n\n'
            'Documents are in the Evidence Room. Open them. Tag what matters. '
            'Build the timeline.',
            style: const TextStyle(color: Colors.white70, height: 1.45),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Stay in office'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _openCaseFile();
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: Colors.black,
              ),
              child: const Text('Open case file'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openCaseFile() async {
    if (!_caseFileUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interview the client first.')),
      );
      return;
    }
    setState(() => _locationId = 'evidence');
    await _persist();
    if (!mounted) return;
    final bool? done = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => LawCaseFileScreen(intakeScore: _intakeScore),
      ),
    );
    if (!mounted) return;
    if (done == true) {
      setState(() => _caseFileDone = true);
      await _persist();
    }
  }

  void _go(String id) {
    setState(() => _locationId = id);
    _persist();
    if (id == 'conference' && !_interviewDone) {
      _openInterview();
    } else if (id == 'evidence' && _caseFileUnlocked) {
      _openCaseFile();
    } else if (id == 'courtroom') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Courtroom unlocks after research & deposition — coming next.'),
        ),
      );
    } else if (id == 'library' && _caseFileDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Legal research desk is next on the build — case file complete.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C0A08),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFD4A574))),
      );
    }

    _Room current = _rooms.first;
    for (final _Room r in _rooms) {
      if (r.id == _locationId) {
        current = r;
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C0A08),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  ),
                  const Expanded(
                    child: Text(
                      'HARTWELL & ASSOCIATES',
                      style: TextStyle(
                        color: Color(0xFFD4A574),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    _interviewDone ? 'On the case' : 'Day one',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                'Monday — 8:47 AM',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Text(
                current.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: Text(
                current.blurb,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65), height: 1.4),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF1C1612), Color(0xFF12100E)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF3A2E24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      current.atmosphere,
                      style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 15),
                    ),
                    const Spacer(),
                    if (!_interviewDone)
                      _ActionBanner(
                        title: 'ACTIVE SITUATION',
                        body: 'New client waiting in the Conference Room.',
                        cta: 'Meet the client',
                        onTap: _openInterview,
                      )
                    else if (_caseFileUnlocked && !_caseFileDone)
                      _ActionBanner(
                        title: 'CASE FILE READY',
                        body: '${LawCaseVault.caseCaption} — Evidence Room.',
                        cta: 'Open case file',
                        onTap: _openCaseFile,
                      )
                    else if (_caseFileDone)
                      _ActionBanner(
                        title: 'NEXT: LEGAL RESEARCH',
                        body: 'Library unlocks research — under construction. Replay interview or case file anytime.',
                        cta: 'Revisit case file',
                        onTap: _openCaseFile,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 108,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _rooms.map((_Room r) {
                  final bool locked = r.id == 'courtroom' && !_caseFileDone;
                  final bool here = r.id == _locationId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: locked ? null : () => _go(r.id),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 118,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: here ? const Color(0xFF2A2118) : const Color(0xFF161310),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: here ? const Color(0xFFD4A574) : const Color(0xFF2E261F),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(locked ? '🔒' : r.icon, style: const TextStyle(fontSize: 20)),
                            const Spacer(),
                            Text(
                              r.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: locked ? Colors.white38 : Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ActionBanner extends StatelessWidget {
  const _ActionBanner({
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });

  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A574).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4A574).withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD4A574),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(color: Colors.white, height: 1.35)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD4A574),
              foregroundColor: Colors.black,
            ),
            child: Text(cta, style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _Room {
  const _Room({
    required this.id,
    required this.name,
    required this.icon,
    required this.blurb,
    required this.atmosphere,
  });

  final String id;
  final String name;
  final String icon;
  final String blurb;
  final String atmosphere;
}

const List<_Room> _rooms = <_Room>[
  _Room(
    id: 'reception',
    name: 'Reception',
    icon: '🏛️',
    blurb: 'Glass doors. Soft carpet. The firm\'s first impression.',
    atmosphere:
        'The receptionist nods. A client folder waits at the front desk — '
        'Hale v. Northline. Maya wants you in the conference room.',
  ),
  _Room(
    id: 'bullpen',
    name: 'Associates',
    icon: '💻',
    blurb: 'Desks, monitors, quiet urgency.',
    atmosphere:
        'Keyboards click. Someone argues a motion under their breath. '
        'Your desk has a blank notepad and a firm badge: Junior Associate.',
  ),
  _Room(
    id: 'conference',
    name: 'Conference',
    icon: '🗣️',
    blurb: 'Where clients tell their story — if you ask well.',
    atmosphere:
        'Long table. Water pitcher. A nervous client sits at the far end. '
        'This is your interview.',
  ),
  _Room(
    id: 'library',
    name: 'Law Library',
    icon: '📚',
    blurb: 'Reporters, treatises, quiet focus.',
    atmosphere:
        'Shelves of bound reporters. Research terminals hum. '
        'Legal research unlocks after your case file work.',
  ),
  _Room(
    id: 'evidence',
    name: 'Evidence Room',
    icon: '📁',
    blurb: 'Documents, photos, timelines.',
    atmosphere:
        'A digital case folder waits on the terminal. '
        'Police report. Contract. Emails. Photos. Build the timeline.',
  ),
  _Room(
    id: 'partner',
    name: 'Partner Office',
    icon: '🚪',
    blurb: 'Partner Vargas reviews strategy.',
    atmosphere:
        'Heavy wood desk. Closed blinds. Vargas is in a hearing — '
        'Maya is your day-to-day supervisor for now.',
  ),
  _Room(
    id: 'courtroom',
    name: 'Courtroom',
    icon: '⚖️',
    blurb: 'Trial floor — unlock later.',
    atmosphere: 'Not yet. Earn the courtroom.',
  ),
];
