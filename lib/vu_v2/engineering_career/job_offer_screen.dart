import 'package:flutter/material.dart';

import 'engineering_career_content.dart';
import 'engineering_career_progress.dart';
import 'engineering_career_theme.dart';
import 'mechworks_workplace_screen.dart';
import 'work_task_board_screen.dart';

/// Screen 10 — accept or decline a fictional job offer.
class JobOfferScreen extends StatefulWidget {
  const JobOfferScreen({
    super.key,
    required this.progress,
    required this.jobId,
  });

  final EngineeringCareerProgress progress;
  final String jobId;

  @override
  State<JobOfferScreen> createState() => _JobOfferScreenState();
}

class _JobOfferScreenState extends State<JobOfferScreen> {
  bool _busy = false;

  EngJob? get _job => EngJobs.byId(widget.jobId);

  Future<void> _accept() async {
    setState(() => _busy = true);
    final bool ok = await widget.progress.acceptOffer(widget.jobId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        backgroundColor: EngCosmic.panel,
        title: const Text('Offer accepted',
            style: TextStyle(color: EngCosmic.ink)),
        content: const Text(
          'This is an in-game employment simulation — not a real job offer. '
          'Your first onboarding task is ready on the Work Task Board.',
          style: TextStyle(color: EngCosmic.mute, height: 1.4),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      WorkTaskBoardScreen(progress: widget.progress),
                ),
              );
            },
            child: const Text('Open task board'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      MechWorksWorkplaceScreen(progress: widget.progress),
                ),
              );
            },
            child: const Text('Enter workplace'),
          ),
        ],
      ),
    );
  }

  Future<void> _decline() async {
    setState(() => _busy = true);
    await widget.progress.declineOffer(widget.jobId);
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final EngJob? job = _job;
    if (job == null) {
      return Scaffold(
        backgroundColor: EngCosmic.bg,
        appBar: EngCosmic.appBar(context: context, title: 'Offer'),
        body: const Center(
          child: Text('Offer not found', style: TextStyle(color: EngCosmic.mute)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: EngCosmic.bg,
      appBar: EngCosmic.appBar(
        context: context,
        title: 'Job offer',
        icon: Icons.mail_rounded,
      ),
      body: EngStarfield(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: EngCosmic.panelBox(radius: 18),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: EngCosmic.blue,
                    child: Text(
                      job.company[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    job.company,
                    style: const TextStyle(
                      color: EngCosmic.mute,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: EngCosmic.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const CircleAvatar(
                    backgroundColor: EngCosmic.teal,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Samira Okonkwo · Engineering Manager',
                    style: TextStyle(color: EngCosmic.mute, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We\'d like to offer you the ${job.title} role on our '
                    'MechWorks rotation. You\'ll ship conceptual designs, run '
                    'teaching simulations, and own tickets on the floor.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: EngCosmic.ink, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: EngCosmic.panelBox(radius: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _row('In-game pay', job.payLabel),
                  _row('Workplace', 'MechWorks / Apex Dynamics floor'),
                  _row('Unlocks', 'Task board · clock-in · manager feedback'),
                  const SizedBox(height: 8),
                  const Text(
                    'Simulated offer for educational play — not real employment.',
                    style: TextStyle(color: EngCosmic.orange, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _accept,
              style: FilledButton.styleFrom(
                backgroundColor: EngCosmic.success,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Accept Offer',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _busy ? null : _decline,
              style: OutlinedButton.styleFrom(
                foregroundColor: EngCosmic.danger,
                side: BorderSide(color: EngCosmic.danger.withValues(alpha: 0.5)),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Decline Offer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 100,
              child: Text(k, style: const TextStyle(color: EngCosmic.mute)),
            ),
            Expanded(
              child: Text(
                v,
                style: const TextStyle(
                  color: EngCosmic.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
}
