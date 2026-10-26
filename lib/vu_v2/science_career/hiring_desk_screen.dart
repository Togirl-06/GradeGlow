import 'package:flutter/material.dart';

import 'science_career_progress.dart';
import 'science_career_theme.dart';

/// Employer hiring desk — review random applicants; hire or reject.
class HiringDeskScreen extends StatefulWidget {
  const HiringDeskScreen({super.key, required this.progress});

  final ScienceCareerProgress progress;

  @override
  State<HiringDeskScreen> createState() => _HiringDeskScreenState();
}

class _HiringDeskScreenState extends State<HiringDeskScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_onProgress);
    _seed();
  }

  @override
  void dispose() {
    widget.progress.removeListener(_onProgress);
    super.dispose();
  }

  void _onProgress() {
    if (mounted) setState(() {});
  }

  Future<void> _seed() async {
    await widget.progress.ensureHiringDeskSeeded(count: 3);
  }

  Future<void> _withBusy(Future<void> Function() fn) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await fn();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _hire(String id, String name) async {
    await _withBusy(() async {
      final bool ok = await widget.progress.hireApplicant(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'Hired $name · welcome to the team' : 'Could not hire $name',
          ),
        ),
      );
    });
  }

  Future<void> _reject(String id, String name) async {
    await _withBusy(() async {
      final bool ok = await widget.progress.rejectApplicant(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'Rejected $name · they were notified' : 'Could not reject $name',
          ),
        ),
      );
    });
  }

  Future<void> _hireRandom() async {
    await _withBusy(() async {
      final String? name = await widget.progress.hireRandomApplicant();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            name == null
                ? 'No applicants available — try Find more applicants'
                : 'Hired $name at random',
          ),
        ),
      );
    });
  }

  Future<void> _spawnMore() async {
    await _withBusy(() async {
      final List<Map<String, dynamic>> added =
          await widget.progress.spawnRandomApplicants(count: 2);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added.isEmpty
                ? 'Applicant pool exhausted for now'
                : '${added.length} new applicant${added.length == 1 ? '' : 's'} applied',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> pending =
        widget.progress.pendingApplicants;
    final List<Map<String, dynamic>> team = widget.progress.hiredTeam;

    return Scaffold(
      backgroundColor: SciCosmic.bg,
      appBar: SciCosmic.appBar(
        context: context,
        title: 'Hiring desk',
        icon: Icons.groups_rounded,
        subtitle: '${pending.length} pending · ${team.length} hired',
      ),
      body: SciStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: SciCosmic.panelBox(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Review applicants',
                    style: TextStyle(
                      color: SciCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'People apply at random. Hire the ones you want on your '
                    'team — or reject them after they apply.',
                    style: TextStyle(color: SciCosmic.mute, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: _busy ? null : _hireRandom,
                        style: FilledButton.styleFrom(
                          backgroundColor: SciCosmic.success,
                        ),
                        icon: const Icon(Icons.casino_rounded, size: 18),
                        label: const Text('Hire at random'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _spawnMore,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SciCosmic.electric,
                          side: const BorderSide(color: SciCosmic.stroke),
                        ),
                        icon: const Icon(Icons.person_add_alt_1_rounded,
                            size: 18),
                        label: const Text('Find more applicants'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pending applications',
              style: TextStyle(
                color: SciCosmic.ink,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            if (pending.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: SciCosmic.panelBox(radius: 14),
                child: const Text(
                  'No pending applicants. Tap Find more applicants.',
                  style: TextStyle(color: SciCosmic.mute),
                ),
              )
            else
              ...pending.map((Map<String, dynamic> a) {
                final String id = '${a['id']}';
                final String name = '${a['name']}';
                final String role = '${a['role']}';
                final String blurb = '${a['blurb']}';
                final String skills = '${a['skills']}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: SciCosmic.panelBox(radius: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: SciCosmic.purple,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: SciCosmic.ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    role,
                                    style: const TextStyle(
                                      color: SciCosmic.mute,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SciCosmic.pill(
                              'Applied',
                              bg: SciCosmic.blue.withValues(alpha: 0.18),
                              fg: SciCosmic.electric,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          blurb,
                          style: const TextStyle(
                            color: SciCosmic.ink,
                            height: 1.35,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          skills,
                          style: const TextStyle(
                            color: SciCosmic.teal,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FilledButton(
                                onPressed:
                                    _busy ? null : () => _hire(id, name),
                                style: FilledButton.styleFrom(
                                  backgroundColor: SciCosmic.success,
                                ),
                                child: const Text('Hire'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    _busy ? null : () => _reject(id, name),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: SciCosmic.danger,
                                  side: BorderSide(
                                    color: SciCosmic.danger
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            if (team.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              const Text(
                'Your team',
                style: TextStyle(
                  color: SciCosmic.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              ...team.map((Map<String, dynamic> a) {
                final String name = '${a['name']}';
                final String role = '${a['role']}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: SciCosmic.panelBox(radius: 14),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: SciCosmic.teal,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                name,
                                style: const TextStyle(
                                  color: SciCosmic.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                role,
                                style: const TextStyle(
                                  color: SciCosmic.mute,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SciCosmic.pill(
                          'Hired',
                          bg: SciCosmic.success.withValues(alpha: 0.16),
                          fg: SciCosmic.success,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
